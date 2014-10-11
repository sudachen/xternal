
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
	template < class T >
	struct Buffer : NonCopyable
	{
		T* data;
		size_t count;
		size_t capacity;

		size_t Capacity() const { return capacity; } 
		size_t Count() const { return count; } 

		Buffer()
			: data(0), count(0), capacity(0)
		{
		}

		Buffer(const T* from, size_t count)
			: data(new T[count]), count(count), capacity(count)
		{
			memcpy(data, from, count * sizeof(T));
		}

		~Buffer()
		{
			if (data) delete[] data;
		}

		T& operator[](int idx)
		{
			FOOBAR_ASSERT(data != 0);
			FOOBAR_ASSERT(idx >= 0);
			FOOBAR_ASSERT(idx < count);
			return data[idx];
		}

		const T& operator[](int idx) const
		{
			FOOBAR_ASSERT(data != 0);
			FOOBAR_ASSERT(idx >= 0);
			FOOBAR_ASSERT(idx < count);
			return data[idx];
		}

		void Swap(Buffer& bf)
		{
			std::swap(data,bf.data);
			std::swap(count,bf.count);
			std::swap(capacity,bf.capacity);
		}
	};

	template < class T >
	Buffer<T>& reallocate(Buffer<T>& bf, size_t capacity)
	{
		if (!bf.data || bf.capacity < capacity)
		{
			T* data = new T[capacity+1];
			data[capacity] = 0;
			if (bf.count) memcpy(data, bf.data, bf.count * sizeof(T));
			std::swap(data, bf.data);
			if (data) delete[] data;
			bf.capacity = capacity;
		}
		return bf;
	}

	template < class T >
	Buffer<T>& resize(Buffer<T>& bf, size_t count)
	{
		reallocate(bf, count);
		if ( count < bf.count ) 
			bf.data[count] = 0;
		bf.count = count;
		return bf;
	}

	template < class T >
	Buffer<T>& grow_by(Buffer<T>& bf, size_t count)
	{
		size_t capacity = bf.capacity;

		if (!capacity)
			capacity = count;

		if ( capacity < 16 ) capacity = 16;

		while (capacity < bf.count + count)
		{
			FOOBAR_ASSERT(capacity > 0);
			capacity *= 2;
			if (capacity > 1024) capacity &= ~size_t(1023);
		}

		reallocate(bf, capacity);
		bf.data[bf.count+count] = 0;
		return bf;
	}

	template < class T >
	Buffer<T>& append_to(Buffer<T>& bf, const T* val, size_t count)
	{
		size_t oldCount = bf.count;
		grow_by(bf, count);
		memcpy(bf.data + oldCount, val, sizeof(T)*count);
		bf.count += count;
		return bf;
	}

	template < class T >
	Buffer<T>& append_to(Buffer<T>& bf, const T& val)
	{
		return append_to(bf, &val, 1);
	}

	template < class T >
	T* take_off(Buffer<T>& bf)
	{
		T* data = bf.data;
		bf.data = 0;
		bf.count = 0;
		bf.capacity = 0;
		return data;
	}

	template < class T >
	T* take_off(Buffer<T>& bf, size_t* count, size_t* capacity)
	{
		T* data = bf.data;
		if (count) *count = bf.count;
		if (capacity) *capacity = bf.capacity;
		bf.data = 0;
		bf.count = bf.capacity = 0;
		return data;
	}

	template < class T >
	size_t length_of(const Buffer<T>& bf)
	{
		return bf.count;
	}

	template < class T >
	size_t capacity_of(const Buffer<T>& bf)
	{
		return bf.capacity;
	}

	template < class T >
	bool is_empty(const Buffer<T>& bf)
	{
		return !bf.count;
	}

	template < class T >
	bool is_null(const Buffer<T>& bf)
	{
		return !bf.data;
	}

	template < class T >
	const T* begin(const Buffer<T>& bf)
	{
		return bf.data;
	}

	template < class T >
	const T* end(const Buffer<T>& bf)
	{
		return bf.data + bf.count;
	}

	template < class T >
	void swap(Buffer<T>& a,Buffer<T>& b)
	{
		a.Swap(b);
	}

	template < class T >
	struct BufferInserter
	{
        Buffer<T>& bf;

        explicit BufferInserter(Buffer<T>& bf)
            : bf(bf)
		{}

		BufferInserter& operator ++() { return *this; }
		BufferInserter& operator ++(int) { return *this; }
		BufferInserter& operator *() { return *this; }
		BufferInserter& operator =(const T& t) 
		{	
			append_to(bf,t);
			return *this; 
		}

		bool operator ==(const BufferInserter&){ return false; }
		bool operator !=(const BufferInserter&){ return true; }
	};

	template < class T > 
	BufferInserter<T> buffer_inserter(Buffer<T>& bf)
	{
		return BufferInserter<T>(bf);
	}
}
