
/*

(C)2014, Alexey Sudachen, alexey@sudachen.name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Except as contained in this notice, the name of a copyright holder shall not
be used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization of the copyright holder.

*/

#pragma once

#include <typeinfo>
#include "Common.hxx"
#include "Strarg.hxx"

namespace foobar
{
	struct FormatParam;

	struct FormatToolkit : NonCopyable
	{
		virtual void Format(
		    const char* fmt,
		    const FormatParam* const args[],
		    size_t count) = 0;

		virtual void Format(
		    const wchar_t* fmt,
		    const FormatParam* const args[],
		    size_t count) = 0;

		virtual void FormatSigned(int64_t val, size_t width) = 0;
		virtual void FormatUnsigned(uint64_t val) = 0;
		virtual void FormatFloat(double val) = 0;
		virtual void FormatPointer(const void* val) = 0;
		virtual void FormatString(const char* str, size_t length) = 0;
		virtual void FormatString(const wchar_t* str, size_t length) = 0;
		virtual ~FormatToolkit() {}

		void FormatString(const std::string& str) { FormatString(str.c_str(), str.length()); }
		void FormatString(const std::wstring& str) { FormatString(str.c_str(), str.length()); }

		template < class Tchr >
		void FormatStrarg(const Strarg<Tchr> strarg)
		{
			FormatString(strarg.Cstr(), strarg.Length());
		}

        virtual int Kind() = 0;
	};

	typedef std::function<void(const void* obj, FormatToolkit* toolkit)> Formatter;

	struct FormatParam : NonCopyable
	{
		const void* obj;
		Formatter formatter;
		typedef FormatParam Type;

		template <class T>
		FormatParam(const T& val)
			: obj(&val), formatter(select_formatter(ExactType<T>()))
		{}

		FormatParam(NoneValue)
			: obj(0), formatter((Formatter)nullptr)
		{}

        template <class Tchr, size_t N>
		FormatParam(const Tchr(&str)[N])
			: obj(&str[0]), formatter((Formatter)nullptr)
		{
			formatter =
			    [](const void * o, FormatToolkit * toolkit)
			{
				auto e = (const Tchr*)o;
				toolkit->FormatString(e, length_of(e));
			};
		}

		FormatParam(const std::exception& e)
			: obj(&e), formatter((Formatter)nullptr)
		{
			const char* const name = typeid(e).name();
			formatter =
			    [name](const void * o, FormatToolkit * toolkit)
			{
				auto e = (std::exception*)o;
				std::string info = std::string(name) + "{" + e->what() + "}";
				toolkit->FormatString(info.c_str(), info.length());
			};
		}
	};

	Formatter select_formatter(ExactType<NoneValue>)
	{
		return [](const void*, FormatToolkit * toolkit)
		{
			toolkit->FormatString("<none>", 6);
		};
	}

	Formatter select_formatter(ExactType<char>)
	{
		return [](const void * o, FormatToolkit * toolkit)
		{
			toolkit->FormatString((const char*)o, 1);
		};
	}

	template <class Tchr>
	Formatter select_formatter(ExactType<Strarg<Tchr>>)
	{
		return [](const void * o, FormatToolkit * toolkit)
		{
			auto str = (const Strarg<Tchr>*)o;
			toolkit->FormatString(str->Cstr(), str->Length());
		};
	}

	template <class Tchr>
	Formatter select_formatter(ExactType<std::basic_string<Tchr>>)
	{
		return [](const void * o, FormatToolkit * toolkit)
		{
			auto str = (const std::basic_string<Tchr>*)o;
			toolkit->FormatString(str->c_str(), str->length());
		};
	}

	Formatter select_formatter(ExactType<std::vector<char>>)
	{
		return [](const void * o, FormatToolkit * toolkit)
		{
			auto str = (const std::vector<char>*)o;
			toolkit->FormatString(&(*str)[0], str->size());
		};
	}

	Formatter select_formatter(ExactType<std::vector<wchar_t>>)
	{
		return [](const void * o, FormatToolkit * toolkit)
		{
			auto str = (const std::vector<wchar_t>*)o;
			toolkit->FormatString(&(*str)[0], str->size());
		};
	}

	Formatter select_formatter(ExactType<Buffer<char>>)
	{
		return [](const void * o, FormatToolkit * toolkit)
		{
			auto str = (const Buffer<char>*)o;
			toolkit->FormatString(&(*str)[0], str->Count());
		};
	}

	Formatter select_formatter(ExactType<Buffer<wchar_t>>)
	{
		return [](const void * o, FormatToolkit * toolkit)
		{
			auto str = (const Buffer<wchar_t>*)o;
			toolkit->FormatString(&(*str)[0], str->Count());
		};
	}

	inline Formatter select_formatter(ExactType<const char*>)
	{
		return [](const void * o, FormatToolkit * toolkit)
		{
			auto str = *(const char**)o;
			toolkit->FormatString(str, length_of(str));
		};
	}
	inline Formatter select_formatter(ExactType<char*>)
	{
		return select_formatter(ExactType<const char*>());
	}

	inline Formatter select_formatter(ExactType<const wchar_t*>)
	{
		return [](const void * o, FormatToolkit * toolkit)
		{
			auto str = *(const wchar_t**)o;
			toolkit->FormatString(str, length_of(str));
		};
	}
	inline Formatter select_formatter(ExactType<wchar_t*>)
	{
		return select_formatter(ExactType<const wchar_t*>());
	}

	template <class T> Formatter select_signed_formatter(const T*)
	{
		return [](const void * o, FormatToolkit * toolkit)
		{
			int64_t val = *(const T*)o;
			toolkit->FormatSigned(val, sizeof(T) * 8);
		};
	}

	template <class T> Formatter select_unsigned_formatter(const T*)
	{
		return [](const void * o, FormatToolkit * toolkit)
		{
			uint64_t val = *(const T*)o;
			toolkit->FormatUnsigned(val);
		};
	}

	inline Formatter select_formatter(ExactType<int64_t>)  { return select_signed_formatter<int64_t>(0); }
	inline Formatter select_formatter(ExactType<int32_t>)  { return select_signed_formatter<int32_t>(0); }
	inline Formatter select_formatter(ExactType<int16_t>)  { return select_signed_formatter<int16_t>(0); }
	inline Formatter select_formatter(ExactType<int8_t>)   { return select_signed_formatter<int8_t>(0); }
	inline Formatter select_formatter(ExactType<long>)     { return select_signed_formatter<long>(0); }
	inline Formatter select_formatter(ExactType<uint64_t>) { return select_unsigned_formatter<uint64_t>(0); }
	inline Formatter select_formatter(ExactType<uint32_t>) { return select_unsigned_formatter<uint32_t>(0); }
	inline Formatter select_formatter(ExactType<uint16_t>) { return select_unsigned_formatter<uint16_t>(0); }
	inline Formatter select_formatter(ExactType<uint8_t>)  { return select_unsigned_formatter<uint8_t>(0); }
	inline Formatter select_formatter(ExactType<unsigned long>) { return select_unsigned_formatter<unsigned long>(0); }

    template <class T>
    Formatter select_formatter(ExactType<T*>)
	{
        static const char* const name = typeid(T).name();
        return [](const void * o, FormatToolkit * toolkit)
		{
			const void* val = *(const void**)o;
            if ( toolkit->Kind() == '?' )
            {
              std::string info = "{"+std::string(name)+"*:";
              toolkit->FormatString(info.c_str(), info.length());
              toolkit->FormatPointer(val);
              toolkit->FormatString("}");
            }
            else
              toolkit->FormatPointer(val);
		};
	}

    template <class Tchr, class Otr>
	struct WriterFormatToolkit: FormatToolkit
	{
		typedef typename Opposite<Tchr>::Type Ochr;
		Otr& writer;

		Tchr    filler;
		Tchr    quote_left;
		Tchr    quote_right;
		int     precision;
		int     kind;
		int     align;
		int     width;
		//int     truncate;

		enum { ALIGN_LEFT, ALIGN_RIGHT };
		static char const tbl_b[];
		static char const tbl_x[];
		static char const tbl_X[];
		static char const tbl_o[];

		WriterFormatToolkit(Otr& writer) : writer(writer) {}

        int Kind() { return kind; }

        void Format_Internal(
		    const Tchr* fmt,
		    const FormatParam* const args[],
		    size_t count)
		{
			int arg_idx = 0;

			do
			{
				const Tchr* fmt_S = fmt;
				while (*fmt && *fmt != (Tchr)'%') ++fmt;

				if (fmt_S != fmt)
					std::copy(fmt_S, fmt, writer);

				while (*fmt == (Tchr)'%')
				{
					++fmt;
					if (*fmt == (Tchr)'%')
					{
						++fmt;
						*writer++ = (Tchr)'%';
						break;
					}

					filler = 0;
					quote_left = 0;
					quote_right = 0;
					precision = -3;
					align = ALIGN_LEFT;
					width = 0;
					kind = 0;
					int arg_ref = -1;

					for (; *fmt && !kind;)
					{
						switch (*fmt)
						{
							case (Tchr)'>': align = ALIGN_RIGHT; break;
							case (Tchr)'<': align = ALIGN_LEFT; break;
							case (Tchr)'\'':  quote_left = quote_right = '\''; break;
							case (Tchr)'"' :  quote_left = quote_right = '"'; break;
							case (Tchr)'?':
							case (Tchr)'x': case 'X': case 'o': case 'b':
							case (Tchr)'d': case 'u': case 'i':
							case (Tchr)'f': case 'e': case 'g':
							case (Tchr)'p': case 's': case 'S':
              case (Tchr)'c':
								kind = uint8_t(*fmt++); break;
							default:
								if (isdigit((char)*fmt))
								{
									if (width) { kind = -1; break; }
									for (; isdigit((char)*fmt) ; fmt++)
										width = width * 10 + ((*fmt) - '0');
									if (*fmt == (Tchr)'.') goto lb_prec;
								}
								else if (*fmt == (Tchr)'.')
								{
								lb_prec:
									++fmt;
									if (precision >= 0) { kind = -1; break; }
									precision = 0;
									for (; isdigit((char)*fmt) ; fmt++)
										precision = precision * 10 + (char(*fmt) - '0');
								}
								else if (*fmt == (Tchr)'{')
								{
									++fmt;
									arg_ref = 0;
									for (; isdigit((char)*fmt) ; fmt++)
										arg_ref = arg_ref * 10 + (char(*fmt) - '0');
									if (*fmt != (Tchr)'}') { kind = -1; break; }
									++fmt;
								}
								else
								{
									kind = -1; break;
								}
						}
					}

					precision = precision < 0 ? -precision : precision;

					if (kind > 0)
					{
						size_t arg_no = arg_ref >= 0 ? arg_ref : arg_idx++;
						if (arg_no < count && args[arg_no]->formatter)
							args[arg_no]->formatter(args[arg_no]->obj, this);
						else
						{
							static const char bad_param[] = "<badparam>";
							width = 0;
							kind = '?';
							align = ALIGN_LEFT;
							this->FormatString(bad_param, sizeof(bad_param) - 1);
						}
					}
					else
					{
						static const char bad_param[] = "<badformat>";
						width = 0;
						kind = '?';
						align = ALIGN_LEFT;
						this->FormatString(bad_param, sizeof(bad_param) - 1);
					}
				}
			}
			while (*fmt);
		}

		void Format(
		    const Tchr* fmt,
		    const FormatParam* const args[],
		    size_t count) OVERRIDE
		{
			return Format_Internal(fmt, args, count);
		}

		void Format(
		    const Ochr* fmt,
		    const FormatParam* const args[],
		    size_t count) OVERRIDE
		{
			return Format_Internal(Strarg<Tchr>(fmt).Cstr(), args, count);
		}

		static void utf8_copy_to(const Tchr* s, size_t len, Otr& writer)
		{
			std::copy(s, s + len, writer);
		}

		static void utf8_copy_to(const Ochr* s, size_t len, Otr& writer)
		{
			utf8_convert(s, len, writer);
		}

		template <class Tc>
		void FormatAjusted(const Tc* chars, size_t chars_count)
		{
			int count = (int)chars_count;
			int quote_width = (quote_left ? 1 : 0) + (quote_right ? 1 : 0);
			if (align == ALIGN_LEFT)
			{
				if (quote_left)
					*writer++ = quote_left;
				utf8_copy_to(chars, count, writer);
				if (quote_left)
					*writer++ = quote_right;
				if (width > count + quote_width)
					std::fill_n(writer, width - count - quote_width, filler);
			}
			else
			{
				if (width > count + quote_width)
					std::fill_n(writer, width - count - quote_width, filler);
				if (quote_left)
					*writer++ = quote_left;
				utf8_copy_to(chars, count, writer);
				if (quote_left)
					*writer++ = quote_right;
			}
		}

		void FormatXdigits(uint64_t val, char const symbols[], unsigned bitwidth, const char* pfx = 0, int width = 0)
		{
			char foo[(sizeof(val) * 8) + 1];
			unsigned mask = 0x0ff >> (8 - bitwidth);
			int i = sizeof(foo);

			if (val)
			{
				for (uint64_t v = val; v > 0;)
				{
					FOOBAR_ASSERT(i > 1);
					foo[--i] = symbols[ v & mask ];
					v >>= bitwidth;
				}
			}
			else
				foo[--i] = '0';

			while (sizeof(foo) - i < width)
			{
				FOOBAR_ASSERT(i > 0);
				foo[--i] = '0';
			}

			if (pfx)
			{
				size_t len = length_of(pfx);
				FOOBAR_ASSERT(i > len);
				while (len--)
					foo[--i] = (Tchr)pfx[len];
			}

			FormatAjusted(foo + i, sizeof(foo) - i);
		}

		void PrepareDigits(std::array<Tchr, 128>& p, size_t& i, uint64_t val)
		{
			if (val)
			{
				while (val > 0)
				{
					FOOBAR_ASSERT(i > 1);
					p[--i] = '0' + (val % 10);
					val /= 10;
				}
			}
			else
				p[--i] = '0';
		}

    void FormatChar(uint64_t val)
    {
      char c[2] = {'.',0};
      if ( val >= 20 && val < 127 ) c[0] = (char)val;
      FormatAjusted(c,1);
    }

		void FormatDigits(uint64_t val, bool negative)
		{
			std::array<Tchr, 128> p = {0};
			size_t i = p.size();

			PrepareDigits(p, i, val);

			if (negative) p[--i] = (Tchr)'-';
			FormatAjusted(&p[i], p.size() - i);
		}

		void FormatSigned(int64_t val, size_t width) OVERRIDE
		{
			if (kind == 'x' || kind == 'X' || kind == 'b' || kind == 'o' || kind == 'p' || kind == 'u' || kind == 'c')
			{
				uint64_t mask = ~(0 - (uint64_t(1) << width));
				FormatUnsigned((uint64_t)val & mask);
			}
			else
			{
				uint64_t v = val >= 0 ? val : -val;
				bool negative = val < 0;
				FormatDigits(v, negative);
			}
		}

		void FormatUnsigned(uint64_t val) OVERRIDE
		{
			if (kind == 'p')
				FormatPointer((void*)(uintptr_t)val);
			else if (kind == 'o')
				FormatXdigits(val, tbl_o, 3);
            else if (kind == 'x')
				FormatXdigits(val, tbl_x, 4);
            else if (kind == 'X')
				FormatXdigits(val, tbl_X, 4);
			else if (kind == 'b')
				FormatXdigits(val, tbl_b, 1);
			else if (kind == 'c')
				FormatChar(val);
			else
				FormatDigits(val, false);
		}

		void FormatFloat(double val) OVERRIDE
		{
			static int perc[] = { 0, 10, 100, 1000, 10000, 100000, 1000000 };
			if (precision > 6) precision = 6;
			std::array<Tchr, 128> foo;
			size_t i = foo.size();
			val = val > 0 ? val + 1e-7 : val - 1e-7;
			double abs_val = val >= 0 ? val : -val;
			if (precision)
			{
				uint64_t val0 = (uint64_t(abs_val * perc[precision])) % perc[precision] + perc[precision];
				PrepareDigits(foo, i, val0);
				foo[i] = '.';
			}
			PrepareDigits(foo, i, uint64_t(abs_val));
			if (val < 0) foo[--i] = (Tchr)'-';
			FormatAjusted(&foo[i], foo.size() - i);
		}

		void FormatPointer(const void* val) OVERRIDE
		{
			FormatXdigits((uintptr_t)val, tbl_x, 4, "#", sizeof(void*) * 2);
		}

		void FormatString(const Tchr* str, size_t length) OVERRIDE
		{
			FormatAjusted(str, length);
		}

		void FormatString(const Ochr* str, size_t length) OVERRIDE
		{
			if (width && align != ALIGN_LEFT)
			{
				std::basic_string<Tchr> bf;
				append_to(bf, str, length);
				FormatAjusted(bf.c_str(), bf.length());
			}
			else
				FormatAjusted(str, length);
		}
	};

	template < class Tchr, class Otr >
	const char WriterFormatToolkit<Tchr, Otr>::tbl_b[] =
	{
		'0', '1'
	};
	template < class Tchr, class Otr >
	const char WriterFormatToolkit<Tchr, Otr>::tbl_x[] =
	{
		'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
	};
	template < class Tchr, class Otr >
	const char WriterFormatToolkit<Tchr, Otr>::tbl_X[] =
	{
		'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
	};
	template < class Tchr, class Otr >
	const char WriterFormatToolkit<Tchr, Otr>::tbl_o[] =
	{
		'0', '1', '2', '3', '4', '5', '6', '7'
	};

	template <class Tchr>
	NO_INLINE std::basic_string<Tchr> format_into_string(
	    const Tchr* fmt,
	    const FormatParam* const args[],
	    size_t count)
	{
		std::basic_string<Tchr> ret;
		std::back_insert_iterator<std::basic_string<Tchr>> w(ret);
		WriterFormatToolkit<Tchr, decltype(w)>(w).Format(fmt, args, count);
		return ret;
	}

	template <class Tchr>
	NO_INLINE std::basic_string<Tchr> format(
	    const Tchr* fmt,
	    const FormatParam& a0 = None)
	{
		const FormatParam* const args[] = {&a0};
		return format_into_string(fmt, args, 1);
	}

	template <class Tchr>
	NO_INLINE std::basic_string<Tchr> format(
	    const Tchr* fmt,
	    const FormatParam& a0,
	    const FormatParam& a1,
	    const FormatParam& a2 = None
	)
	{
		const FormatParam* const args[] = {&a0, &a1, &a2};
		return format_into_string(fmt, args, 3);
	}

	template <class Tchr>
	std::basic_string<Tchr> format(
	    const Tchr* fmt,
	    const FormatParam& a0,
	    const FormatParam& a1,
	    const FormatParam& a2,
	    const FormatParam& a3,
	    const FormatParam& a4 = None,
	    const FormatParam& a5 = None,
	    const FormatParam& a6 = None,
	    const FormatParam& a7 = None,
	    const FormatParam& a8 = None,
	    const FormatParam& a9 = None
	)
	{
		const FormatParam* const args[] = {&a0, &a1, &a2, &a3, &a4, &a5, &a6, &a7, &a8, &a9};
		return format_into_string(fmt, args, sizeof(args) / sizeof(args[0]));
	}

	template <class Tval>
	std::string to_string(const Tval& value, const char* fmt = "%?") { return format(fmt,value); }
}

#define FOOBAR_FORMAT_EMUN_PAIR(a) {a, #a}
#define FOOBAR_FORMAT_EXPAND_ENUMS(...) FOOBAR_PARAMS(FOOBAR_FORMAT_EMUN_PAIR,__VA_ARGS__)

#define FOOBAR_ENUM_FORMATTER(Enum, ... ) \
	struct _selecet_formatter_helper_##Enum \
	{ \
		static void F(const void* o, foobar::FormatToolkit * toolkit) \
		{ \
			struct DESCRIPTOR { Enum value; const char *name; }; \
			static const DESCRIPTOR table[] = { \
			                                    FOOBAR_FORMAT_EXPAND_ENUMS(__VA_ARGS__), \
			                                  }; \
			\
			Enum value = *(Enum*)o; \
			\
			auto desc = std::find_if(foobar::begin(table),foobar::end(table), \
			[value](const DESCRIPTOR &r){ return r.value == value; }); \
			\
			if ( desc != foobar::end(table) ) \
				toolkit->FormatString(desc->name,strlen(desc->name)); \
			else \
				toolkit->FormatString(foobar::format("%?{%?}",#Enum,(int)value)); \
		}; \
	}; \
	\
	inline foobar::Formatter select_formatter(foobar::ExactType<Enum>) \
	{ \
		return &_selecet_formatter_helper_##Enum::F; \
	} \
	 

