
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

#ifdef _WIN32
#include <windows.h>
#else
#error windows only!
#endif

namespace foobar
{

	inline std::wstring format_win32_error(int last_error)
	{
		std::array<wchar_t,1024> buff = {0,};
		size_t len = 
		    FormatMessageW(
		        FORMAT_MESSAGE_FROM_SYSTEM |
		        FORMAT_MESSAGE_IGNORE_INSERTS,
		        NULL,
		        last_error,
		        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
		        &buff[0],
		        buff.size() - 1,
		        NULL
		    );
		auto E = std::remove(buff.begin(),buff.end(),'\n');
		E = std::remove(buff.begin(),E,'\r');
		return std::wstring(buff.begin(),E);
	}

	inline std::wstring format_win32_error()
	{
		return format_win32_error(GetLastError());
	}

}

