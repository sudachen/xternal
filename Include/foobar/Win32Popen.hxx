
/*

(C)2014, Alexey Sudachen, alexey.sudachen@desanova.cl

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
#include "Strarg.hxx"
#include "Stream.hxx"
#include "Win32.hxx"

namespace foobar
{
    struct PopenObject : Refcounted
    {
        enum CMD_OPT { USE_CMD = 1 };
        Option<std::string> error;

        bool Good() const
        {
            return error == None;
        }

        HANDLE _process;
        Stream _out;
        HANDLE _out1, _out2;
        Stream _in;
        HANDLE _in1, _in2;

        PopenObject()
            : _process(0), _out1(0), _out2(0), _in1(0), _in2(0)
        {
        }

        bool _Init(STARTUPINFOW* si)
        {
            HANDLE foo;
            SECURITY_ATTRIBUTES saa;
            saa.nLength = sizeof(SECURITY_ATTRIBUTES);
            saa.bInheritHandle = TRUE;
            saa.lpSecurityDescriptor = NULL;

            if (!CreatePipe(&_in1, &_in2, &saa, 0))
            { error = Strarg<char>(format_win32_error()).Str(); return false; }
            if (!CreatePipe(&_out2, &_out1, &saa, 0))
            { error = Strarg<char>(format_win32_error()).Str(); return false; }
            DuplicateHandle(INVALID_HANDLE_VALUE, _in1, INVALID_HANDLE_VALUE, &foo, 0, FALSE, DUPLICATE_SAME_ACCESS);
            CloseHandle(_in1); _in1 = foo;
            DuplicateHandle(INVALID_HANDLE_VALUE, _out1, INVALID_HANDLE_VALUE, &foo, 0, FALSE, DUPLICATE_SAME_ACCESS);
            CloseHandle(_out1); _out1 = foo;

            si->cb = sizeof(STARTUPINFOW);
            si->dwFlags    = STARTF_USESTDHANDLES;
            si->hStdInput  = _in2;
            si->hStdOutput = _out2;
            si->hStdError  = _out2;
            si->wShowWindow = SW_HIDE;

            _out = Win32Stream::OperateOver(_out1, STREAM_READ, "<popen-stdout>");
            _in  = Win32Stream::OperateOver(_in1, STREAM_WRITE, "<popen-stdin>");

            return true;
        }

        ~PopenObject()
        {
            if (_process) CloseHandle(_process);
            if (_in1) CloseHandle(_in1);
            if (_out1) CloseHandle(_out1);
            if (_in2) CloseHandle(_in2);
            if (_out2) CloseHandle(_out2);
        }

        bool _Exec(const Strarg<wchar_t>& command, Option<CMD_OPT> use_cmd = None)
        {
            STARTUPINFOW si;
            PROCESS_INFORMATION pi;

            if (_Init(&si))
            {
                if (use_cmd != None && *use_cmd == USE_CMD)
                {
                    std::vector<wchar_t> comspec(256, L'\0');
                    if (!GetEnvironmentVariableW(L"COMSPEC", &comspec[0], comspec.size()))
                    { error = Strarg<char>(format_win32_error()).Str(); return false; }
                    std::wstring cmdline = L"\"";
                    cmdline += &comspec[0];
                    cmdline += L"\" /c \"";
                    cmdline += command.Cstr();
                    cmdline += L"\"";
                    if (!CreateProcessW(
                            NULL,
                            (wchar_t*)cmdline.c_str(),
                            NULL,
                            NULL,
                            TRUE,
                            CREATE_NO_WINDOW,
                            NULL,
                            NULL,
                            &si,
                            &pi))
                    { error = Strarg<char>(format_win32_error()).Str(); return false; }
                }
                else
                {
                    if (!CreateProcessW(
                            NULL,
                            (wchar_t*)command.Cstr(),
                            NULL,
                            NULL,
                            TRUE,
                            CREATE_NO_WINDOW,
                            NULL,
                            NULL,
                            &si,
                            &pi))
                    { error = Strarg<char>(format_win32_error()).Str(); return false; }
                }

                _process = pi.hProcess;
                CloseHandle(pi.hThread);
            }

            return true;
        }

        Stream Out() { return _out; }
        Stream In() { return _in; }

        void Kill()
        {
            if ( _process )
            {
                TerminateProcess(_process,-1);
                if (_out) _out->Close();
                if (_in) _in->Close();
                _process = 0;
            }
        }

        bool StillActive()
        {
            if (_process)
            {
                DWORD ecode;
                if ( GetExitCodeProcess(_process,&ecode) && ecode == STILL_ACTIVE )
                    return true;
            }

            return false;
        }

        uint32_t ExitCode()
        {
            if (_process)
            {
                DWORD ecode;
                if ( GetExitCodeProcess(_process,&ecode) )
                    return ecode;
            }

            return ~uint32_t(0);
        }
    };

    struct Popen : RccPtr<PopenObject>
    {
        static Popen Exec(const Strarg<wchar_t>& command)
        {
            auto p = std::unique_ptr<PopenObject>(new PopenObject());
            p->_Exec(command);
            return Popen(p.release());
        }

        static Popen Cmd(const Strarg<wchar_t>& command)
        {
            auto p = std::unique_ptr<PopenObject>(new PopenObject());
            p->_Exec(command,PopenObject::USE_CMD);
            return Popen(p.release());
        }

        Popen() {}

    private:
        Popen(PopenObject* o) : RccPtr<PopenObject>(o) {}
    };


}