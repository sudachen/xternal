
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

#include "Common.hxx"
#include "Buffer.hxx"

namespace foobar
{
	inline uint8_t utf8_char_length(int c)
	{
		static char length[256] =
		{
			/* see RFC 2279 for details */
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
			2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
			3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
			4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 0, 0
		};
		return length[((uint8_t)c)];
	}

	template < class T >
	bool utf8_different(std::back_insert_iterator<T>&,std::back_insert_iterator<T> const&)
	{ return true; }

	template < class T >
	bool utf8_different(T& a,T const& b)
	{ return a != b; }

	template < class Itr, class Otr >
	bool utf8_decode(Itr i, Itr iE, Otr o, Option<const Otr&> oE = None)
	{
		while (i != iE && (oE == None || utf8_different(o,*oE) != 0 ))
		{
			uint32_t c = ~uint32_t(0);
			uint32_t c0 = (uint8_t)*i; ++i;
			if (c0 < 0x80)
				c = c0;
			else
			{
				uint32_t c1 = 0;
				uint32_t c2 = 0;
				uint32_t c3 = 0;
				uint32_t l = utf8_char_length(c0);
				if (iE - i < l - 1)
					return false;
				c1 = (uint8_t)*i; ++i;
				switch (l)
				{
					case 2:
						c = ((c0 & 0x1f) << 6) + (c1 & 0x3f);
						break;
					case 3:
						c2 = (uint8_t)*i; ++i;
						c = ((c0 & 0x0f) << 12) + ((c1 & 0x3f) << 6) + (c2 & 0x3f);
						break;
					case 4: // hm, UCS4 ????
						c2 = (uint8_t)*i; ++i;
						c3 = (uint8_t)*i; ++i;
						c = ((c0 & 0x7) << 18) + ((c1 & 0x3f) << 12) + ((c2 & 0x3f) << 6) + (c3 & 0x3f);
						break;
					default:
						return false;
				}
			}
			*o = c; ++o;
		}
		return true;
	}

	template < class Itr, class Otr >
	bool utf8_encode(Itr i, Itr iE, Otr o, Option<const Otr&> oE = None)
	{
		while (i != iE && (oE == None || utf8_different(o,*oE)))
		{
			uint32_t c = (unsigned int) * i; ++i;
			if (c < 0x80)
			{
				*o = (char)c; ++o;
			}
			else if (c < 0x0800)
			{
				*o = (char)(0xc0 | (c >> 6)); ++o;
				if (oE != None && !utf8_different(o,*oE)) return false;
				*o = (char)(0x80 | (c & 0x3f)); ++o;
			}
			else
			{
				*o = (char)(0xe0 | (c >> 12)); ++o;
				if (oE != None && !utf8_different(o,*oE)) return false;
				*o = (char)(0x80 | ((c >> 6) & 0x3f)); ++o;
				if (oE != None && !utf8_different(o,*oE)) return false;
				*o = (char)(0x80 | (c & 0x3f)); ++o;
			}
		}
		return true;
	}

	template< class Tchr >
	std::basic_string<Tchr>& append_to(std::basic_string<Tchr>& str, int chr)
	{
		str.insert(str.end(), 1, (Tchr)chr);
		return str;
	}

	template< class Tchr >
	std::basic_string<Tchr>& append_to(std::basic_string<Tchr>& str, const Tchr* chrs, size_t count)
	{
		str.insert(str.end(), chrs, chrs + count);
		return str;
	}

	template < class Otr >
    inline bool utf8_convert(const char* chars, size_t count, Otr o, Option<const Otr&> oE = None)
	{
		return utf8_decode(chars, chars + count, o, oE);
	}

	template < class Otr >
    inline bool utf8_convert(const wchar_t* chars, size_t count, Otr o, Option<const Otr&> oE = None)
	{
		return utf8_encode(chars, chars + count, o, oE);
	}

	template< class Tchr >
	std::basic_string<Tchr>& append_to(std::basic_string<Tchr>& str, const typename Opposite<Tchr>::Type* chrs, size_t count)
	{
		auto otr = std::back_insert_iterator<std::basic_string<Tchr>>(str);
		utf8_convert(chrs, count, otr);
		return str;
	}

	inline size_t length_of(const char* str) { return str ? strlen(str) : 0; }
	inline size_t length_of(const wchar_t* str) { return str ? wcslen(str) : 0; }
	inline size_t length_of(const std::string& str) { return str.length(); }
	inline size_t length_of(const std::wstring& str) { return str.length(); }

	inline bool is_empty(const char* str) { return str ? !strlen(str) : true; }
	inline bool is_empty(const wchar_t* str) { return str ? !wcslen(str) : true; }
	inline bool is_empty(const std::string& str) { return !str.length(); }
	inline bool is_empty(const std::wstring& str) { return !str.length(); }

	inline bool is_null(const char* str) { return !str; }
	inline bool is_null(const wchar_t* str) { return !str; }

	inline const wchar_t* c_str(const wchar_t* str) { return str; }
	inline const char*    c_str(const char* str) { return str; }
	inline const char*    c_str(const std::string& str) { return str.c_str(); }
	inline const wchar_t* c_str(const std::wstring& str) { return str.c_str(); }
	inline const char*    c_str(const std::exception& e) { return e.what(); }

	inline const std::string& to_string(const std::string& str) { return str; }
	inline std::string to_string(const std::wstring& wstr) { std::string str; return append_to(str,wstr.c_str(),wstr.length()); }
	inline std::string to_string(const char* str) { return str; }
	inline std::string to_string(const wchar_t* wstr) { std::string str; return append_to(str,wstr,length_of(wstr)); }

	template < class Tchr>
	typename std::basic_string<Tchr>::const_iterator begin(const std::basic_string<Tchr>& str) { return str.begin(); }
	template < class Tchr>
	typename std::basic_string<Tchr>::iterator begin(std::basic_string<Tchr>& str) { return str.begin(); }
	template < class Tchr>
	typename std::basic_string<Tchr>::const_iterator end(const std::basic_string<Tchr>& str) { return str.end(); }
	template < class Tchr>
	typename std::basic_string<Tchr>::iterator end(std::basic_string<Tchr>& str) { return str.end(); }

	template <class Tchr> struct Strarg : NonCopyable
	{
		typedef std::function<void(Tchr*& str, size_t& length)> Converter;
		typedef typename Opposite<Tchr>::Type Tsrc;

		Converter fcvt;
		mutable Tchr* object;
		mutable size_t length;

		static void _GetLen(Tchr*& str, size_t& length)
		{
			if (str
			    && ((length & need_to_resolve_len) == need_to_resolve_len))
			{
				length = length_of(str);
			}
			else
			{
				length = 0;
			}
		}

        static void _c_strConvert(Tchr*& str, size_t& length)
		{
			if (str
			    && ((length & need_to_resolve_all) == need_to_resolve_all))
			{
				Buffer<Tchr> tmp;
                Tsrc* cstr = (Tsrc*)str;
                utf8_convert(cstr, length_of(cstr), buffer_inserter(tmp));
				append_to(tmp, Tchr(0));
				str = take_off(tmp);
				length = have_to_delete | length_of(str);
			}
			else
			{
				length = 0;
			}
		}

		static void _StringConvert(Tchr*& str, size_t& length)
		{
			if ((length & need_to_resolve_all) == need_to_resolve_all)
			{	
				Buffer<Tchr> tmp;
				const std::basic_string<Tsrc>& stdstr = *(std::basic_string<Tsrc>*)str;
				utf8_convert(stdstr.c_str(), stdstr.length(), buffer_inserter(tmp));
				append_to(tmp, Tchr(0));
				str = take_off(tmp);
				length = have_to_delete | length_of(str);
			}
		}

		static void _BufferConvert(Tchr*& str, size_t& length)
		{
			if ((length & need_to_resolve_all) == need_to_resolve_all)
			{
				Buffer<Tchr> tmp;
				const Buffer<Tsrc>& vec = *(Buffer<Tsrc>*)str;
				utf8_convert(&vec[0], vec.Count(), buffer_inserter(tmp));
				append_to(tmp, Tchr(0));
				str = take_off(tmp);
				length = have_to_delete | length_of(str);
			}
		}

		static const size_t have_to_delete = size_t(1) << (sizeof(size_t) * 8 - 1);
		static const size_t need_to_resolve_len = ((size_t(0) - 1) << 1)& ~have_to_delete;
		static const size_t need_to_resolve_all = ((size_t(0) - 1) << 1 | 1)& ~have_to_delete;

        template < class T >
		Strarg(const T& any)
		{
			fcvt    = strarg_cvt_from(ExactType2<T, Tchr>());
			object  = (Tchr*)&any;
			length  = need_to_resolve_all;
        }

        Strarg(Tchr* strPtr)
		{
			fcvt      = _GetLen;
			object    = (Tchr*)strPtr;
			length    = need_to_resolve_len;
		}

		Strarg(const Tchr* strPtr)
		{
			fcvt      = _GetLen;
			object    = (Tchr*)strPtr;
			length    = need_to_resolve_len;
		}

		Strarg(typename Opposite<Tchr>::Type* strPtr)
		{
            fcvt      = _c_strConvert;
			object    = (Tchr*)strPtr;
			length    = need_to_resolve_all;
		}

		Strarg(const typename Opposite<Tchr>::Type* strPtr)
		{
            fcvt      = _c_strConvert;
			object    = (Tchr*)strPtr;
			length    = need_to_resolve_all;
		}

		Strarg(const std::basic_string<typename Opposite<Tchr>::Type>& str)
		{
			fcvt      = _StringConvert;
			object    = (Tchr*)&str;
			length    = need_to_resolve_all;
		}

		Strarg(const Buffer<typename Opposite<Tchr>::Type>& str)
		{
			fcvt      = _BufferConvert;
			object    = (Tchr*)&str;
			length    = need_to_resolve_all;
		}

		Strarg(const std::basic_string<Tchr>& str)
		{
            fcvt      = nullptr;
			object    = (Tchr*)str.c_str();
			length    = str.length();
		}

		Strarg(const Buffer<Tchr>& str)
		{
            fcvt      = nullptr;
			object    = (Tchr*)&str[0];
			length    = str.Count();
		}

		Strarg(NoneValue)
		{
            fcvt      = nullptr;
			object    = 0;
			length    = 0;
		}

        const Tchr* Cstr() const
		{
			if ((length & need_to_resolve_all) == need_to_resolve_all)
				fcvt(object, length);
			return object;
		}

		std::basic_string<Tchr> Str() const
		{
			if ((length & need_to_resolve_all) == need_to_resolve_all)
				fcvt(object, length);
			static Tchr e[1] = {0};
			return std::basic_string<Tchr>((object ? object : e), Length());
		}

		size_t Length() const
		{
			if ((length & need_to_resolve_len) == need_to_resolve_len)
				fcvt(object, length);
			return ~have_to_delete & length;
		}

		~Strarg()
		{
			if (length & have_to_delete)
				delete[] object;
		}

		bool operator == (NoneValue) const { return object == 0; }
		bool operator != (NoneValue) const { return object != 0; }

	private:
		Strarg(int);
		Strarg(const Strarg<typename Opposite<Tchr>::Type>&);
	};

	typedef const Strarg<char>& strarg_t;
	typedef const Strarg<wchar_t>& wcsarg_t;

	template <class Tchr>
	size_t length_of(const Strarg<Tchr>& strarg)
	{
		return strarg.Length();
	}

	template <class Tchr>
	bool is_empty(const Strarg<Tchr>& strarg)
	{
		return !strarg.Length();
	}

	template <class Tchr>
	bool is_null(const Strarg<Tchr>& strarg)
	{
		return strarg == None;
	}

	template <class Tchr>
	const Tchr* c_str(const Strarg<Tchr>& strarg)
	{
        return strarg.Cstr();
	}

	inline std::string to_string(const Strarg<char>& strarg) 
	{ 
		return strarg.Str(); 
	}

	inline std::string to_string(const Strarg<wchar_t>& strarg) 
	{ 
		return Strarg<char>(strarg.Cstr()).Str(); 
	}

	template <class Tchr>
	const Tchr* begin(const Strarg<Tchr>& strarg)
	{
        return strarg.Cstr();
	}

	template <class Tchr>
	const Tchr* end(const Strarg<Tchr>& strarg)
	{
        return strarg.Cstr() + strarg.Length();
	}

    /*  template < class Tchr >
        inline typename Strarg<Tchr>::Converter strarg_cvt_from(ExactType2<Tchr*,Tchr>)
        {
            return [](Tchr*& str, size_t& length)
            {
                str = *(Tchr**)str;
                length = length_of(str);
            };
        }

        template < class Tchr >
        inline typename Strarg<Tchr>::Converter strarg_cvt_from(ExactType2<typename Opposite<Tchr>::Type*,Tchr>)
        {
            return [](Tchr*& str, size_t& length)
            {
                str = *(Tchr**)str;
                _c_strConvert(str,length);
            };
        }
    */
};
