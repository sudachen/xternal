
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

namespace foobar
{
    inline size_t count_cstring_region(char* str) { return str ? strlen(str) : 0; }
    inline size_t count_cstring_region(wchar_t* str) { return str ? wcslen(str) : 0; }

    template <class T>
    struct Range : NonCopyable
    {
        const T* at;
        size_t count;

        Range(NoneValue)
            : at(0), count(0)
        {}

        Range(const T* at, size_t count)
            : at(at), count(count)
        {}

        Range(const T* at, const T* until)
            : at(at), count(until - at)
        {}

        Range(const T* until_zero) /* will compile successful only for char and wchar_t */
            : at(until_zero), count(count_cstring_region(until_zero))
        {}

        template <size_t N>
        Range(const T(&arr)[N])
            : at(arr), count(N)
        {}

        Range(const std::basic_string<T>& str)
            : at(str->c_str()), count(str->length())
        {}

        Range(const Option<std::basic_string<T>>& str)
            : at(str != None ? str->c_str() : 0 ), count( str != None ? str->length() : 0 )
        {}

        Range(const std::vector<T>& vect)
            : at(&vect[0]), count(vect.size())
        {}

        const T& operator[](int idx) const
        {
            FOOBAR_ASSERT(at != 0);
            FOOBAR_ASSERT(idx >= 0 && idx <= count);
            return at[idx];
        }

        bool operator ==(NoneValue) const { return at == 0; }
        bool operator !=(NoneValue) const { return at != 0; }
    };

    typedef const Range<char>& chars_t;
    typedef const Range<uint8_t>& bytes_t;

    template <class T>
    bool is_empty(const Range<T>& range)
    {
        return !range.count;
    }

    template <class T>
    bool is_null(const Range<T>& range)
    {
        return !range.at;
    }

    template <class T>
    size_t length_of(const Range<T>& range)
    {
        return range.count;
    }

    template <class T>
    const T* begin(const Range<T>& range)
    {
        return range.at;
    }

    template <class T>
    const T* end(const Range<T>& range)
    {
        return range.at + range.count;
    }

}

