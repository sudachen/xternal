
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

#include "Strarg.hxx"
#include "Refcounted.hxx"
#include "RccPtr.hxx"
#include "Stream.hxx"

namespace foobar
{
    struct BufferDataStream : BasicStream
    {
        std::vector<uint8_t> bf;
        size_t pos;

        BufferDataStream() : BasicStream(GetAPI()), pos(0)
        {
            BasicStream::Init(this, None, STREAM_READ | STREAM_WRITE | STREAM_SEEK);
        }

        int64_t Size() OVERRIDE
        {
            return bf.size();
        }

        void SwapBuffer(std::vector<uint8_t>& nbf)
        {
            swap(nbf, bf);
            pos = 0;
        }

        static int _bf_fread(void* buf, size_t size, size_t count, BufferDataStream* self)
        {
            if (self->bf.size() < self->pos)
                return -1;
            if (self->bf.size() < self->pos + size * count)
                count = (self->bf.size() - self->pos) / size;
            if (count)
                memcpy(buf, &self->bf[self->pos], size * count);
            return count;
        }

        static int _bf_fwrite(void* buf, size_t size, size_t count, BufferDataStream* self)
        {
            if (self->bf.size() < self->pos + size * count)
                self->bf.resize(self->pos + size * count, 0);
            std::copy((uint8_t*)buf, (uint8_t*)buf + size * count, self->bf.begin() + self->pos);
            return count;
        }

        static int64_t _bf_fseek(BufferDataStream* self, int64_t offs, int orign)
        {
            switch (orign)
            {
                case SEEK_SET:
                    if (offs < 0) return -1;
                    self->pos = offs;
                    break;
                case SEEK_CUR:
                    if (offs + (int64_t)self->pos < 0) return -1;
                    self->pos = size_t((int64_t)self->pos + offs);
                    break;
                case SEEK_END:
                    if (offs + (int64_t)self->bf.size() < 0) return -1;
                    self->pos = size_t((int64_t)self->bf.size() + offs);
                    break;
            }
            return (int64_t)self->pos;
        }

        static int64_t _bf_ftell(BufferDataStream* self)
        {
            return (int64_t)self->pos;
        }

        static int _bf_feof(BufferDataStream* self)
        {
            return self->pos >= self->bf.size();
        }

        static const BasicStream::API* GetAPI()
        {
            static const BasicStream::API api =
            {
                (BasicStream::API::fread_t)& _bf_fread,
                (BasicStream::API::fwrite_t)& _bf_fwrite,
                (BasicStream::API::fseek_t)& _bf_fseek,
                (BasicStream::API::ftell_t)& _bf_ftell,
                (BasicStream::API::fflush_t)0,
                (BasicStream::API::fclose_t)0,
                (BasicStream::API::feof_t)&  _bf_feof,
                (void*)0,
            };
            return &api;
        }
    };
}
