
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
#include "Refcounted.hxx"
#include "RccPtr.hxx"
#include "Range.hxx"

namespace foobar
{
    struct UnknownStream : Ireferred
    {

        enum
        {
            CAN_REWIND      = 1,
            CAN_SEEK        = CAN_REWIND | 2,
            CAN_WRITE       = 4,
            CAN_READ        = 8,
            CAN_STEPBACK    = 16,
        };

        RccPtr<UnknownStream> Ref() { return rcc_refe(this); }

        virtual void Error(NoneValue) = 0;
        virtual bool Error(const Strarg<char>& error) = 0;
        virtual bool ErrorOccured(bool clean = false) = 0;

        virtual int ReadData(void* p, size_t count, size_t min_count) = 0;
        virtual int WriteData(void const* p, size_t count, size_t min_count) = 0;

        virtual int64_t Size()
        {
            if (ClaimFeature(CAN_SEEK))
            {
                int64_t p = Tell();
                Seek(0);
                int64_t avail = Available();
                Seek(p);
                return avail;
            }
            return -1;
        }

        virtual int64_t Available() = 0;
        virtual int64_t Tell() = 0;
        virtual int64_t Seek(int64_t, int whence = SEEK_SET) = 0;
        virtual unsigned Features() = 0;
        virtual bool Flush() = 0;
        virtual bool Close() = 0;
        virtual bool Eof() { return !Available(); }

        virtual bool Rewind()
        {
            if (ClaimFeature(CAN_SEEK))
            {
                Seek(0);
                return Good();
            }
            return false;
        }

        virtual bool Skip(int64_t count)
        {
            if (Features() && CAN_SEEK)
            {
                Seek(count, SEEK_CUR);
                return Good();
            }
            else
            {
                uint8_t bf[512];
                while (count)
                {
                    int was_read = ReadData(bf, 512, 1);
                    if (was_read < 0) return false;
                    FOOBAR_ASSERT(was_read > 0); // was required to read least 1 byte
                    count -= was_read;
                }
                if (count)
                    return Error("to small data to skip");
                return true;
            }
        }

        bool ClaimFeature(unsigned feature)
        {
            if ( (Features() & feature) != feature)
            {
                return Error("claimed unsupported feature");
            }
            return true;
        }

        bool Good()
        {
            return !ErrorOccured();
        }

        virtual std::string ErrorString(bool clean = false) = 0;
        std::string GetErrorStringAndClean() { return ErrorString(true); }

        NO_INLINE int Read(std::vector<uint8_t>& bf, size_t count, Option<size_t> min_count = None)
        {
            bf.clear();
            enum { READ_BLOCK = 512 };

            if (min_count == None) min_count = count;
            while (Good() && count)
            {
                size_t require = std::min<size_t>(READ_BLOCK, count);
                size_t pos = bf.size();
                bf.resize(pos + require);
                int c = this->ReadData(&bf[pos], require, min_count);
                if (c > 0)
                {
                    if (min_count > 0)
                        *min_count -= std::min<size_t>(*min_count, c);
                    bf.resize(pos + c);
                    count -= c;
                }
                else
                    bf.resize(pos);
                if (c < 0 || c == 0 && min_count == 0)
                    break;
            }

            return Good() && min_count == 0 ? (int)bf.size() : -1;
        }

        NO_INLINE int ReadAll(std::vector<uint8_t>& bf)
        {
            bf.clear();
            enum { READ_BLOCK = 512 };

            while (Good())
            {
                size_t pos = bf.size();
                bf.resize(pos + READ_BLOCK);
                int c = this->ReadData(&bf[pos], READ_BLOCK, 0);
                bf.resize(c >= 0 ? pos + c : pos);
                if (c <= 0) break;
            }

            return Good() ? (int)bf.size() : -1;
        }

        NO_INLINE int Write(const void* bytes, size_t count, Option<size_t> min_count = None)
        {
            return Write(Range<uint8_t>((uint8_t*)bytes,count),min_count);
        }

        NO_INLINE int Write(const Range<uint8_t>& bf, Option<size_t> min_count = None)
        {
            if (length_of(bf) > 0)
            {
                if (min_count == None) min_count = length_of(bf);
                int c = this->WriteData(begin(bf), length_of(bf), min_count);
                return Good() && c > 0 ? (int)c : -1;
            }
            return 0;
        }

        NO_INLINE int WriteText(const Strarg<char>& text)
        {
            if ( text != None )
                if ( Write(text.Cstr(),text.Length()) != text.Length() )
                    return -1;
            return (int)text.Length();
        }

        NO_INLINE int WriteLine(const Strarg<char>& text = None)
        {
            if ( text != None )
                if ( Write(text.Cstr(),text.Length()) != text.Length() )
                    return -1;
            #ifdef _WIN32
            if ( Write("\r\n",2) != 2 ) return -1;
            return (int)(text.Length() + 2);
            #else
            if ( Write("\n",1) != 1 ) return -1;
            return (int)(text.Length() + 1);
            #endif
        }

        uint64_t Read64be()     { uint64_t v = 0; return Read64be(&v), v; }
        uint64_t Read64le()     { uint64_t v = 0; return Read64le(&v), v; }
        uint32_t Read32be()     { uint32_t v = 0; return Read32be(&v), v; }
        uint32_t Read32le()     { uint32_t v = 0; return Read32le(&v), v; }
        uint16_t Read16be()     { uint16_t v = 0; return Read16be(&v), v; }
        uint16_t Read16le()     { uint16_t v = 0; return Read16le(&v), v; }
        uint8_t  Read8()        { uint8_t v = 0;  return Read8(&v), v; }
        float    ReadIeee32be() { float v = 0;    return ReadIeee32be(&v), v; }
        float    ReadIeee32le() { float v = 0;    return ReadIeee32le(&v), v; }
        double   ReadIeee64be() { double v = 0;   return ReadIeee64be(&v), v; }
        double   ReadIeee64le() { double v = 0;   return ReadIeee64le(&v), v; }

        NO_INLINE int ReadIeee32be(float* fu)
        {
            return Read32be((uint32_t*)fu);
        }

        NO_INLINE int ReadIeee32le(float* fu)
        {
            return Read32le((uint32_t*)fu);
        }

        NO_INLINE int ReadIeee64be(double* fu)
        {
            return Read64be((uint64_t*)fu);
        }

        NO_INLINE int ReadIeee64le(double* fu)
        {
            return Read64le((uint64_t*)fu);
        }

        NO_INLINE int Read64be(uint64_t* u)
        {
            uint8_t b[8];
            if (ReadData(b, 8, 8) == 8)
            {
                *u  = ((uint64_t)b[0]) << 56;
                *u |= ((uint64_t)b[1]) << 48;
                *u |= ((uint64_t)b[2]) << 40;
                *u |= ((uint64_t)b[3]) << 32;
                *u |= ((uint64_t)b[4]) << 24;
                *u |= ((uint64_t)b[5]) << 16;
                *u |= ((uint64_t)b[6]) << 8;
                *u |= ((uint64_t)b[7]);
                return 8;
            }
            return -1;
        }

        NO_INLINE int Read64le(uint64_t* u)
        {
            uint8_t b[8];
            if (ReadData(b, 8, 8) == 8)
            {
                *u  = ((uint64_t)b[0]);
                *u |= ((uint64_t)b[1]) << 8;
                *u |= ((uint64_t)b[2]) << 16;
                *u |= ((uint64_t)b[3]) << 24;
                *u |= ((uint64_t)b[4]) << 32;
                *u |= ((uint64_t)b[5]) << 40;
                *u |= ((uint64_t)b[6]) << 48;
                *u |= ((uint64_t)b[7]) << 56;
                return 8;
            }
            return -1;
        }

        NO_INLINE int Read32be(uint32_t* u)
        {
            uint8_t b[4];
            if (ReadData(b, 4, 4) == 4)
            {
                *u  = ((uint32_t)b[0]) << 24;
                *u |= ((uint32_t)b[1]) << 16;
                *u |= ((uint32_t)b[2]) << 8;
                *u |= ((uint32_t)b[3]);
                return 4;
            }
            return -1;
        }

        NO_INLINE int Read32le(uint32_t* u)
        {
            uint8_t b[4];
            if (ReadData(b, 4, 4) == 4)
            {
                *u  = ((uint32_t)b[0]);
                *u |= ((uint32_t)b[1]) << 8;
                *u |= ((uint32_t)b[2]) << 16;
                *u |= ((uint32_t)b[3]) << 24;
                return 4;
            }
            return -1;
        }

        NO_INLINE int Read16be(uint16_t* u)
        {
            uint8_t b[2];
            if (ReadData(b, 2, 2) == 2)
            {
                *u  = ((uint16_t)b[0]) << 8;
                *u |= ((uint16_t)b[1]);
                return 2;
            }
            return -1;
        }

        NO_INLINE int Read16le(uint16_t* u)
        {
            uint8_t b[2];
            if (ReadData(b, 2, 2) == 2)
            {
                *u  = ((uint16_t)b[0]);
                *u |= ((uint16_t)b[1]) << 8;
                return 2;
            }
            return -1;
        }

        NO_INLINE int Read8(uint8_t* u)
        {
            if (ReadData(u, 1, 1) == 1)
                return 1;
            return -1;
        }

        NO_INLINE int WriteIeee32be(float fu)
        {
            return Write32be((uint32_t const&)fu);
        }

        NO_INLINE int WriteIeee32le(float fu)
        {
            return Write32le((uint32_t const&)fu);
        }

        NO_INLINE int WriteIeee64be(double fu)
        {
            return Write64be((uint64_t const&)fu);
        }

        NO_INLINE int WriteIeee64le(double fu)
        {
            return Write64le((uint64_t const&)fu);
        }

        NO_INLINE int Write64be(uint64_t u)
        {
            uint8_t b[8];
            b[0] = uint8_t(u >> 56);
            b[1] = uint8_t(u >> 48);
            b[2] = uint8_t(u >> 40);
            b[3] = uint8_t(u >> 32);
            b[4] = uint8_t(u >> 24);
            b[5] = uint8_t(u >> 16);
            b[6] = uint8_t(u >> 8);
            b[7] = uint8_t(u);
            return WriteData(b, 8, 8);
        }

        NO_INLINE int Write64le(uint64_t u)
        {
            uint8_t b[8];
            b[7] = uint8_t(u >> 56);
            b[6] = uint8_t(u >> 48);
            b[5] = uint8_t(u >> 40);
            b[4] = uint8_t(u >> 32);
            b[3] = uint8_t(u >> 24);
            b[2] = uint8_t(u >> 16);
            b[1] = uint8_t(u >> 8);
            b[0] = uint8_t(u);
            return WriteData(b, 8, 8);
        }

        NO_INLINE int Write32be(uint32_t u)
        {
            uint8_t b[4];
            b[0] = uint8_t(u >> 24);
            b[1] = uint8_t(u >> 16);
            b[2] = uint8_t(u >> 8);
            b[3] = uint8_t(u);
            return WriteData(b, 4, 4);
        }

        NO_INLINE int Write32le(uint32_t u)
        {
            uint8_t b[4];
            b[3] = uint8_t(u >> 24);
            b[2] = uint8_t(u >> 16);
            b[1] = uint8_t(u >> 8);
            b[0] = uint8_t(u);
            return WriteData(b, 4, 4);
        }

        NO_INLINE int Write16be(uint16_t u)
        {
            uint8_t b[2];
            b[0] = uint8_t(u >> 8);
            b[1] = uint8_t(u);
            return WriteData(b, 2, 2);
        }

        NO_INLINE int Write16le(uint16_t u)
        {
            uint8_t b[2];
            b[1] = uint8_t(u >> 8);
            b[0] = uint8_t(u);
            return WriteData(b, 2, 2);
        }

        int Write8(uint8_t u)
        {
            return WriteData(&u, 1, 1);
        }
    };

    typedef RccPtr<UnknownStream> Stream;

    enum
    {
        FILEOPEN_DISPOSITION = 0x0f00,
        FILEOPEN_EXISTING    = 0x0000, /* open existing */
        FILEOPEN_TRUNCATE    = 0x0100, /* trancate existing */
        FILEOPEN_CREATE      = 0x0200, /* create if does not exists */
        FILEOPEN_CREATEALWAYS= 0x0300, /* alwayes create new file */
        FILEOPEN_CREATENEW   = 0x0400, /* create only if does not exists otherwise fail */
        FILEOPEN_TEXT        = 1,
        FILEOPEN_CREATE_PATH = 2,
        STREAM_SEEK          = 4,
        STREAM_READ          = 8,
        STREAM_WRITE         = 16,
        STREAM_DONOT_CLOSE   = 32,
    };

    struct BadStream : RefcountedT<UnknownStream>
    {
        BadStream(const Strarg<char>& text)
            : error(text.Str())
        {}

        bool ErrorOccured(bool) OVERRIDE
        {
            return true;
        }

        std::string ErrorString(bool) OVERRIDE
        {
            return this->error;
        }

        int64_t Tell() OVERRIDE { return 0; }
        int64_t Seek(int64_t,int) OVERRIDE { return 0; }
        int64_t Available() OVERRIDE { return 0; }
        unsigned Features() OVERRIDE { return 0; }
        bool Flush() OVERRIDE { return false; }
        bool Close() OVERRIDE { return false; }
        void Error(NoneValue) OVERRIDE {;}
        bool Error(const Strarg<char>&) OVERRIDE { return false; }
        int ReadData(void*, size_t, size_t) OVERRIDE { return -1; }
        int WriteData(void const*, size_t, size_t) OVERRIDE { return -1; }

    private:
        std::string error;
    };

    struct BasicStream : RefcountedT<UnknownStream>
    {
        struct API
        {
            typedef int (*fread_t)(void*, size_t, size_t, void*);
            typedef int (*fwrite_t)(void const*, size_t, size_t, void*);
            typedef int64_t(*fseek_t)(void*, int64_t, int);
            typedef int64_t(*ftell_t)(void*);
            typedef int (*fflush_t)(void*);
            typedef int (*fclose_t)(void*);
            typedef int (*feof_t)(void*);

            fread_t  f_read;
            fwrite_t f_write;
            fseek_t  f_seek;
            ftell_t  f_tell;
            fflush_t f_flush;
            fclose_t f_close;
            feof_t   f_eof;
            void*    invalid_fd_value;
        };

        const API* api;
        void* fd;
        std::string name;
        Option<std::string> error;

        bool can_read;
        bool can_seek;
        bool can_write;
        bool do_not_close;

        void Error(NoneValue) OVERRIDE
        {
            this->error = None;
        }

        bool Error(const Strarg<char>& error) OVERRIDE
        {
            this->error = error.Str();
            return false;
        }

        bool ErrorOccured(bool clean) OVERRIDE
        {
            if (this->error == None) return false;
            else
            {
                if (clean) this->error = None;
                return true;
            }
        }

        std::string ErrorString(bool clean = false) OVERRIDE
        {
            if (this->error == None) return "";
            else
            {
                if (clean)
                    return Option<std::string>().Swap(this->error);
                return this->error;
            }
        }

        BasicStream(const API* api)
            : api(api), can_read(false), can_seek(false), can_write(false), do_not_close(false), fd(api->invalid_fd_value)
        {
        }

        ~BasicStream()
        {
            Close();
        }

        void Init(void* fd, const Strarg<char>& name, int opt)
        {
            can_read = can_write = can_seek = false;
            this->fd = fd;
            if (opt & (STREAM_WRITE))
                can_write = true;
            if (opt & STREAM_READ)
                can_read = true;
            if (opt & STREAM_SEEK)
                can_seek = true;
            if ( opt & STREAM_DONOT_CLOSE )
                do_not_close = true;
            this->name = name.Str();
            Error(None);
        }

        bool ClaimOperable()
        {
            if (fd != api->invalid_fd_value)
                return true;
            else
                return Error("inoperable");
        }

        int64_t Seek(int64_t pos, int whence = SEEK_SET) OVERRIDE
        {
            if (ClaimOperable() && ClaimFeature(CAN_SEEK))
            {
                int64_t npos = api->f_seek(fd, pos, whence);
                if (npos < 0)
                    return Error("failed to seek to new position"), -1;
                return npos;
            }
            else
                return -1;
        }

        int64_t Tell() OVERRIDE
        {
            if (ClaimOperable() && ClaimFeature(CAN_SEEK))
            {
                int64_t cur = api->f_tell(fd);
                if (cur < 0)
                    return Error("failed to get current position"), -1;
                return cur;
            }
            else
                return -1;
        }

        int64_t Available() OVERRIDE
        {
            if (ClaimOperable() && ClaimFeature(CAN_SEEK))
            {
                int64_t cur = api->f_tell(fd);
                if (cur < 0)
                    return Error("failed to get current position"), -1;
                if (api->f_seek(fd, 0, SEEK_END) < 0)
                    return Error("failed to seek to end"), -1;
                int64_t end = api->f_tell(fd);
                if (end < 0)
                    return Error("failed to get current position"), -1;
                if (api->f_seek(fd, cur, SEEK_SET) < 0)
                    return Error("failed to seek to current position"), -1;
                return end - cur;
            }
            else
                return -1;
        }

        int WriteData(void const* buf, size_t count, size_t min_count) OVERRIDE
        {
            int wrote = 0;
            if (!ClaimOperable() || !ClaimFeature(CAN_WRITE))
                return -1;

            FOOBAR_ASSERT(count >= min_count);
            if (min_count)
            {
                wrote = api->f_write(buf, min_count, 1, fd);
                if (wrote < 0)
                    return Error("failed to write"), -1;
                wrote = 0;
            }

            if (count != min_count)
            {
                wrote = api->f_write(buf, 1, count - min_count, fd);
                if (wrote < 0)
                    return Error("failed to write"), -1;
            }

            return (int)(min_count + wrote);
        }

        int ReadData(void* buf, size_t count, size_t min_count) OVERRIDE
        {
            int read = 0;
            if (!ClaimOperable() || !ClaimFeature(CAN_READ))
                return -1;

            FOOBAR_ASSERT(count >= min_count);

            if (min_count)
            {
                read = api->f_read(buf, min_count, 1, fd);
                if ( read == 0 )
                    read = api->f_read(buf, min_count, 1, fd);
                if (read < 1)
                    return Error("failed to read"), -1;
            }

            size_t i = min_count;

            while (i != count)
            {
                read = api->f_read((uint8_t*)buf + i, 1, count - i, fd);
                if (read < 0)
                {
                    if (api->f_eof(fd))
                        break;
                    return Error("failed to read"), -1;
                }
                else if (read > 0)
                    i += read;
                else if ( read == 0)
                    break;
            }

            return (int)i;
        }

        unsigned Features() OVERRIDE
        {
            unsigned fts = 0;
            if (can_write) fts |= CAN_WRITE;
            if (can_read)  fts |= CAN_READ;
            if (can_seek)  fts |= CAN_SEEK;
            return fts;
        }

        bool Flush() OVERRIDE
        {
            if (ClaimOperable())
            {
                if ( api->f_flush && api->f_flush(fd) < 0)
                    return Error("failed to fush buffers"), false;
                return true;
            }
            return false;
        }

        bool Close() OVERRIDE
        {
            if (fd != api->invalid_fd_value)
            {
                if (!do_not_close && api->f_close) api->f_close(fd);
                fd = api->invalid_fd_value;
            }
            return true;
        }

        static unsigned DecodeCopts(const char* s)
        {
            unsigned opts = 0;
            for (; *s; ++s)
                switch (tolower(*s))
                {
                    case '+': opts |= STREAM_WRITE|STREAM_SEEK; /*falldown*/
                    case 'r': opts |= STREAM_READ|STREAM_SEEK; break;
                    case 'w': opts = (opts&~FILEOPEN_DISPOSITION)|STREAM_WRITE|FILEOPEN_CREATEALWAYS; break;
					case 'c': opts = (opts&~FILEOPEN_DISPOSITION) | STREAM_WRITE | FILEOPEN_TRUNCATE; break;
					case 'x': opts = (opts&~FILEOPEN_DISPOSITION) | STREAM_WRITE | FILEOPEN_CREATENEW; break;
                    case 't': opts |= FILEOPEN_TEXT; break;
					case 'p': opts |= FILEOPEN_CREATE_PATH; break;
                    default: break;
                }
            return opts;
        }
    };

}
