
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
#include "Guid.hxx"
#include "RccPtr.hxx"
#include "Interlocked.hxx"

namespace foobar
{
	FOOBAR_DECLARE_GUIDOF_(Ireferred, 0xcafebabe, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8);

	struct Ireferred
	{
		void Release() const { const_cast<Ireferred*>(this)->Release(); }
		void AddRef() const { const_cast<Ireferred*>(this)->AddRef(); }
		virtual void Release() = 0;
		virtual void AddRef() = 0;
		virtual ~Ireferred() { }

		virtual void* QueryInterface(Guid const& guid)
		{
            if (guid == guid_Of(this)) return this;
			return 0;
		}
	};

	template < class T = Ireferred >
	struct RefcountedT : NonCopyableT<T>
	{
		void Release() OVERRIDE
		{
			FOOBAR_ASSERT(refcount > 0);
			if (!interlocked::dec(refcount))
				delete this;
		}

		void AddRef() OVERRIDE
		{
			FOOBAR_ASSERT(refcount > 0);
			interlocked::inc(refcount);
		}

		RefcountedT() : refcount(1) { }

		long Refcount()
		{
			return refcount;
		}

	protected:
		~RefcountedT() { }

	private:
		volatile long refcount;
	};

	typedef RefcountedT<> Refcounted;

	template < class T >
	RccPtr<T> rcc_cast(RccPtr<Ireferred> const& p)
	{
		return p
		       ? rcc_refe((T*)p->QueryInterface(*guid_Of((T*)0)))
		       : RccPtr<T> (0);
	}

}
