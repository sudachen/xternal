
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

#include "Path.hxx"

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
                (DWORD)(buff.size() - 1),
                NULL
            );
        auto E = std::remove(buff.begin(),buff.begin()+len,'\n');
        E = std::remove(buff.begin(),E,'\r');
        return std::wstring(buff.begin(),E);
    }

    inline std::wstring format_win32_error()
    {
        return format_win32_error(GetLastError());
    }

    inline Path<wchar_t> get_executable_path()
    {
        std::vector<wchar_t> exe_path(260);
        for (;;)
        {
            ::GetModuleFileNameW(0,&exe_path[0],(DWORD)exe_path.size());
            if ( GetLastError() != ERROR_INSUFFICIENT_BUFFER )
                break;
            exe_path.resize(exe_path.size()*2);
        }
        return Path<wchar_t>(&exe_path[0]).Fullpath();
    }

    inline std::wstring get_executable_name()
    {
        return get_executable_path().Name();
    }


    inline const OSVERSIONINFOW& get_windows_version_info()
    {
        static OSVERSIONINFOW nfo = {0,};
        if ( nfo.dwOSVersionInfoSize == 0 )
        {
            nfo.dwOSVersionInfoSize = sizeof(nfo);
            ::GetVersionExW(&nfo);
        }
        return nfo;
    }

    inline size_t windows_version()
    {
        const OSVERSIONINFOW& nfo = get_windows_version_info();
        return nfo.dwMajorVersion * 100
               +  nfo.dwMinorVersion;
    }

    const size_t WINDOWS81_VERSION    = 603;
    const size_t SERVER2012R2_VERSION = 603;
    const size_t WINDOWS8_VERSION     = 602;
    const size_t WINDOWS7_VERSION     = 601;
    const size_t WINDOWSVISTA_VERSION = 600;
}

