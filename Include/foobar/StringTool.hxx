
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

#include <cctype>
#include <locale>

#include "Strarg.hxx"

namespace foobar
{
	inline std::string utf8_upper(const Strarg<wchar_t>& str)
	{
		std::wstring r(length_of(str), 0);
		std::transform(begin(str), end(str), begin(r), towupper);
		return Strarg<char>(r).Str();
	}

	inline std::string c_upper(const Strarg<char>& str)
	{
		std::string r(length_of(str), 0);
		std::transform(begin(str), end(str), begin(r), toupper);
		return r;
	}

	inline std::wstring w_upper(const Strarg<wchar_t>& str)
	{
		std::wstring r(length_of(str), 0);
		std::transform(begin(str), end(str), begin(r), towupper);
		return r;
	}

	inline std::string utf8_lower(const Strarg<wchar_t>& str)
	{
		std::wstring r(length_of(str), 0);
		std::transform(begin(str), end(str), begin(r), towlower);
		return Strarg<char>(r).Str();
	}

	inline std::string c_lower(const Strarg<char>& str)
	{
		std::string r(length_of(str), 0);
		std::transform(begin(str), end(str), begin(r), tolower);
		return r;
	}

	inline std::wstring w_lower(const Strarg<wchar_t>& str)
	{
		std::wstring r(length_of(str), 0);
		std::transform(begin(str), end(str), begin(r), towlower);
		return r;
	}

	inline bool is_equal_nocase(const Strarg<wchar_t>& str1, const Strarg<wchar_t>& str2)
	{
		const wchar_t* a = str1.Cstr();
		const wchar_t* b = str2.Cstr();
		return a && b && wcscmp(a, b) == 0;
	}

	template < class Tchr >
	NO_INLINE std::basic_string<Tchr> x_replace(const Strarg<Tchr>& str, const Strarg<Tchr>& what,
	        const Strarg<Tchr>& value)
	{
		std::basic_string<Tchr> out;

		auto o = std::back_insert_iterator<std::basic_string<Tchr>>(out);
		const Tchr* i = begin(str), *iE = end(str);
		const Tchr* t = begin(what), *tE = end(what);

		while (i != iE)
		{
			auto j = i;
			i = std::search(i, iE, t, tE);
			std::copy(j, i, o);
			if (i != iE)
			{
				std::copy(begin(value), end(value), o);
				i += tE - t;
			}
		}

		return out;
	}

	inline std::string c_replace(const Strarg<char>& str, const Strarg<char>& what, const Strarg<char>& value)
	{
		return x_replace<char>(str, what, value);
	}

	inline std::wstring w_replace(const Strarg<wchar_t>& str, const Strarg<wchar_t>& what, const Strarg<wchar_t>& value)
	{
		return x_replace<wchar_t>(str, what, value);
	}

	template <class Tchr>
	NO_INLINE std::basic_string<Tchr> x_right(const Strarg<Tchr>& str, size_t width, const Strarg<Tchr>& prefix)
	{
		FOOBAR_ASSERT(width > prefix.Length());
		if (str.Length() > width)
			return prefix.Str() + (str.Cstr() + (str.Length() - width - prefix.Length()));
		else
			return str.Str();
	}

	inline std::string c_right(const Strarg<char>& str, size_t width, const Strarg<char>& prefix = "...")
	{
		return x_right<char>(str, width, prefix);
	}

	inline std::wstring w_right(const Strarg<wchar_t>& str, size_t width, const Strarg<wchar_t>& prefix = L"...")
	{
		return x_right<wchar_t>(str, width, prefix);
	}

	template <class Tchr>
	NO_INLINE std::basic_string<Tchr> x_left(const Strarg<Tchr>& str, size_t width, const Strarg<Tchr>& sfx)
	{
		FOOBAR_ASSERT(width > sfx.Length());
		if (str.Length() > width)
			return std::basic_string<Tchr>(str.Cstr(), width - sfx.Length()) + sfx.Cstr();
		else
			return str.Str();
	}

	inline std::string c_left(const Strarg<char>& str, size_t width, const Strarg<char>& sfx = "...")
	{
		return x_left<char>(str, width, sfx);
	}

	inline std::wstring w_left(const Strarg<wchar_t>& str, size_t width, const Strarg<wchar_t>& sfx = L"...")
	{
		return x_left<wchar_t>(str, width, sfx);
	}

	template <class Tchr>
	NO_INLINE std::basic_string<Tchr> x_trim(const Strarg<Tchr>& str)
	{
		const Tchr* S = str.Cstr();
		const Tchr* E = S + str.Length();

		while (S != E && *S == ' ' || *S == '\t' || *S == '\n' || *S == '\n')
			++S;

		while (S != E)
		{
			const Tchr c = *(E - 1);
			if (c == ' ' || c == '\t' || c == '\n' || c == '\n')
				--E;
			else
				break;
		}

		return std::basic_string<Tchr>(S, E);
	}

	inline std::string c_trim(const Strarg<char>& str)
	{
		return x_trim<char>(str);
	}

	inline std::wstring w_trim(const Strarg<wchar_t>& str)
	{
		return x_trim<wchar_t>(str);
	}

	inline bool meta_split(const char* S, const char* E, char d, std::function<bool(std::string&)> action)
	{
		std::string str;
		while (S != E && isspace(*S)) ++S;
		while (S != E)
		{
			auto q = S;
			S = std::find(S, E, d);
			auto p = S;
			while (p != q && isspace(*(p - 1))) --p;
			if (p != q)
			{
				str.assign(q, p);
				if (action(str)) return true;
			}
			if (S != E) ++S;
		}
		return false;
	}

	template < class Tchr >
	struct HexChar
	{
		Tchr chars[5];
		const Tchr* Cstr() const { return chars; }
		std::basic_string<Tchr> Str() const { return chars; }
	};

	template < class Tchr >
	HexChar<Tchr> x_hex_byte(uint8_t byte, Option<char> pfx)
	{
		HexChar<Tchr> c = { 0, };
		static Tchr symbols[] =
		{
			'0', '1', '2', '3', '4', '5', '6', '7', 
			'8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
		};
		Tchr* q = c.chars;
    if ( pfx != None )
		  switch (pfx.Get() & 0x7f)
		  {
			  case 'x': *q++ = '0'; *q++ = 'x'; break;
			  case '\\': *q++ = '\\'; *q++ = 'x'; break;
			  case '%': *q++ = '%'; break;
			  default: break;
		  }
		*q++ = symbols[(byte >> 4)];
		*q++ = symbols[byte & 0x0f];
		*q = 0;
		return c;
	}

	inline HexChar<char> c_hex_byte(uint8_t byte, Option<char> pfx = None)
	{
		return x_hex_byte<char>(byte,pfx);
	}

	inline HexChar<wchar_t> w_hex_byte(uint8_t byte, Option<char> pfx = None)
	{
		return x_hex_byte<wchar_t>(byte,pfx);
	}

	template<class Tchr> bool x_starts_with(const Tchr* what, size_t what_len, const Strarg<Tchr>& start)
	{
		return start.Length() >= what_len && memcmp(what,start.Cstr(),sizeof(Tchr)*what_len);
	}

	bool c_starts_with(const Strarg<char>& text,const Strarg<char>& start)
	{
		return x_starts_with<char>(text.Cstr(),text.Length(),start);
	}

	bool w_starts_with(const Strarg<wchar_t>& text,const Strarg<wchar_t>& start)
	{
		return x_starts_with<wchar_t>(text.Cstr(),text.Length(),start);
	}
}
