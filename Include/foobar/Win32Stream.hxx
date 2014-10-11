
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
#include "Strarg.hxx"
#include "Stream.hxx"
#include "Path.hxx"
#include "Win32.hxx"

namespace foobar
{
	struct Win32Stream : BasicStream
	{

		Win32Stream(HANDLE handle, const Strarg<char>& name, unsigned open_flags)
			: BasicStream(GetAPI())
		{
			BasicStream::Init(handle, name, open_flags);
		}

		int64_t Size() OVERRIDE
		{
			if (ClaimOperable())
			{
				DWORD hi = 0;
				DWORD lo = GetFileSize(BasicStream::fd, &hi);
				if (lo == INVALID_FILE_SIZE && GetLastError() != 0)
					return Error("windows error"), -1;
				return (int64_t)lo | (int64_t)((uint64_t)hi << 32);
			}
			return -1;
		}

		static Stream Open(
		    const Strarg<wchar_t>& file_name,
		    unsigned open_flags = STREAM_READ | STREAM_SEEK)
		{
			if (file_name != None)
			{
				DWORD access = 0;
				DWORD dispo = 0;

				if (open_flags & FILEOPEN_CREATE_PATH)
				{
					Path<wchar_t> dir = Path<wchar_t>(file_name).Fullpath().Normalize().Parent();
					if (!dir.Exists())
						if (!dir.MkDir())
							return Stream(new BadStream("couldn't create full path"));
				}

				if (open_flags & STREAM_WRITE) access |= GENERIC_WRITE;
				if (open_flags & STREAM_READ)  access |= GENERIC_READ;
				if ((open_flags & FILEOPEN_DISPOSITION) == FILEOPEN_EXISTING)
					dispo = OPEN_EXISTING;
				if ((open_flags & FILEOPEN_DISPOSITION) == FILEOPEN_CREATE)
					dispo = OPEN_ALWAYS;
				if ((open_flags & FILEOPEN_DISPOSITION) == FILEOPEN_CREATEALWAYS)
					dispo = CREATE_ALWAYS;
				if ((open_flags & FILEOPEN_DISPOSITION) == FILEOPEN_CREATENEW)
					dispo = CREATE_NEW;
				if ((open_flags & FILEOPEN_DISPOSITION) == FILEOPEN_TRUNCATE)
					dispo = TRUNCATE_EXISTING;
				HANDLE handle = CreateFileW(file_name.Cstr(), access, FILE_SHARE_READ, 0, dispo, 0, 0);
				if (handle != INVALID_HANDLE_VALUE)
					return Acquire(handle, open_flags, file_name.Cstr());
				else
					return Stream(new BadStream(format_win32_error(GetLastError())));
			}
			return Stream(new BadStream("path is not specified"));
		}

		static Stream Open(
		    const Strarg<wchar_t>& file_name,
		    const Strarg<char>& open_flags)
		{
			return Open(file_name, DecodeCopts(open_flags.Cstr()));
		}

		static Stream Acquire(
		    HANDLE handle,
		    unsigned open_flags = STREAM_READ | STREAM_WRITE | STREAM_SEEK,
		    const Strarg<char>& name = None)
		{
			return Stream(new Win32Stream(handle, name, open_flags));
		}

		static Stream Duplicate(
		    HANDLE handle,
		    unsigned open_flags = STREAM_READ | STREAM_WRITE | STREAM_SEEK,
		    const Strarg<char>& name = None)
		{
			HANDLE new_handle;
			if (DuplicateHandle(
			        INVALID_HANDLE_VALUE, handle,
			        INVALID_HANDLE_VALUE, &new_handle,
			        0, FALSE, DUPLICATE_SAME_ACCESS))
				return Acquire(new_handle, open_flags, name);
			return None;
		}

		static Stream OperateOver(
		    HANDLE hanlde,
		    unsigned open_flags = STREAM_READ | STREAM_WRITE | STREAM_SEEK,
		    const Strarg<char>& name = None)
		{
			return Acquire(hanlde, open_flags | STREAM_DONOT_CLOSE, name);
		}

		static int _hf_stream_read(void* buf, size_t size, size_t count, HANDLE fh)
		{
			unsigned l = size * count;
			for (int j = 0; j < l;)
			{
				unsigned long wr = 0;
				if (!ReadFile(fh, (char*)buf + j, l - j, &wr, 0))
					return -1;
				else
					j += wr;
				if (wr == 0)
					return (j) / size;
			}
			return count;
		}

		static int _hf_stream_write(void* buf, size_t size, size_t count, HANDLE fh)
		{
			size = size * count;
			for (int j = 0; j < size;)
			{
				unsigned long wr = 0;
				if (!WriteFile(fh, (char*)buf + j, size - j, &wr, 0))
					return -1;
				else
					j += wr;
				if (wr == 0)
					return (j) / size;
			}
			return count;
		}

		static int64_t _hf_stream_fseek(HANDLE fh, int64_t offs, int orign)
		{
			switch (orign)
			{
				case SEEK_SET: orign = FILE_BEGIN; break;
				case SEEK_CUR: orign = FILE_CURRENT; break;
				case SEEK_END: orign = FILE_END; break;
			}
			long hi = offs >> 32;
			DWORD lo = SetFilePointer(fh, (long)offs, &hi, orign);
			if (INVALID_SET_FILE_POINTER == lo && GetLastError() != 0)
				return -1;
			return (int64_t)lo | (int64_t)((uint64_t)hi << 32);
		}

		static int64_t _hf_stream_ftell(HANDLE fh)
		{
			long hi = 0;
			DWORD lo = SetFilePointer(fh, 0, &hi, FILE_CURRENT);
			if (INVALID_SET_FILE_POINTER == lo && GetLastError() != 0)
				return -1;
			return (int64_t)lo | (int64_t)((uint64_t)hi << 32);
		}

		static int _hf_stream_feof(HANDLE fh)
		{
			DWORD hi = 0;
			DWORD lo = GetFileSize(fh, &hi);
			if (lo == INVALID_FILE_SIZE && GetLastError() != 0)
				return -1;
			int64_t length = (int64_t)lo | (int64_t)((uint64_t)hi << 32);
			LONG hi1 = 0;
			lo = SetFilePointer(fh, 0, &hi1, FILE_CURRENT);
			if (INVALID_SET_FILE_POINTER == lo && GetLastError() != 0)
				return -1;
			int64_t pos = (int64_t)lo | (int64_t)((uint64_t)hi1 << 32);
			return  pos >= length;
		}

		static int _hf_stream_flush(HANDLE fh)
		{
			return !FlushFileBuffers(fh);
		}

		static int _hf_stream_fclose(HANDLE fh)
		{
			if (fh != INVALID_HANDLE_VALUE)
				CloseHandle(fh);
			return 0;
		}

		static const BasicStream::API* GetAPI()
		{
			static const BasicStream::API api =
			{
				(BasicStream::API::fread_t) _hf_stream_read,
				(BasicStream::API::fwrite_t)_hf_stream_write,
				(BasicStream::API::fseek_t) _hf_stream_fseek,
				(BasicStream::API::ftell_t) _hf_stream_ftell,
				(BasicStream::API::fflush_t)_hf_stream_flush,
				(BasicStream::API::fclose_t)_hf_stream_fclose,
				(BasicStream::API::feof_t)  _hf_stream_feof,
				(void*)INVALID_HANDLE_VALUE,
			};
			return &api;
		}
	};
}
