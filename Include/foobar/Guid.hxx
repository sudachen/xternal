
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

#if !defined _WIN32 && !defined FOOBAR_REUSE_GUID

typedef struct GUID
{
	u32_t Data1;
	u16_t Data2;
	u16_t Data3;
	byte_t Data4[8];
} GUID;

#elif defined _WIN32
#  include <Guiddef.h>
#endif

namespace foobar
{
    struct Guid
    {
      GUID value;
      operator const GUID&() const { return value; }
      operator GUID&() { return value; }
    };

	template < class T >
	struct guid_Of_Type
	{
		typedef typename T::Guid Guid;
	};

	template < class T > inline
    GUID const& guid_Of(T const* /*fake*/ = 0)
	{
		typedef typename guid_Of_Type<T>::Guid Guid;
        return Guid::value.value;
	}

	template < unsigned tLx,
	         unsigned tWx1, unsigned tWx2,
	         unsigned tBx1, unsigned tBx2, unsigned tBx3, unsigned tBx4,
	         unsigned tBx5, unsigned tBx6, unsigned tBx7, unsigned tBx8 >
	struct GuidDef
	{
		static Guid const value;
	};

	template < unsigned tLx,
	         unsigned tWx1, unsigned tWx2,
	         unsigned tBx1, unsigned tBx2, unsigned tBx3, unsigned tBx4,
	         unsigned tBx5, unsigned tBx6, unsigned tBx7, unsigned tBx8 >
	Guid const GuidDef <tLx, tWx1, tWx2, tBx1, tBx2, tBx3, tBx4, tBx5, tBx6, tBx7, tBx8>
	::value = { tLx, tWx1, tWx2, { tBx1, tBx2, tBx3, tBx4, tBx5, tBx6, tBx7, tBx8 } };

	struct GuidLesser
	{
		bool operator()(Guid const& a, Guid const& b) const
		{
			return memcmp(&a, &b, sizeof(Guid)) < 0;
		}
	};

	inline int guid_cmpf(void const* a, void const* b)
	{
		return memcmp(a, b, sizeof(Guid));
	}

	inline bool operator ==(Guid const& a, Guid const& b)
	{
		return guid_cmpf(&a, &b) == 0;
	}

    inline std::string to_string(const GUID& guid)
    {
      std::array<char,48> bf;
      sprintf(&bf[0],"%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
          guid.Data1,guid.Data2,guid.Data3,
          guid.Data4[0],guid.Data4[1],guid.Data4[2],guid.Data4[3],
          guid.Data4[4],guid.Data4[5],guid.Data4[6],guid.Data4[7]);
      return std::string(&bf[0]);
    }

    inline std::wstring to_wstring(const GUID& guid)
    {
      std::array<wchar_t,48> bf;
      swprintf(&bf[0],L"%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
          guid.Data1,guid.Data2,guid.Data3,
          guid.Data4[0],guid.Data4[1],guid.Data4[2],guid.Data4[3],
          guid.Data4[4],guid.Data4[5],guid.Data4[6],guid.Data4[7]);
      return std::wstring(&bf[0]);
    }
}

#define FOOBAR_DECLARE_GUID(x,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
    typedef ::foobar::GuidDef<l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8> x

#define FOOBAR_DECLARE_GUIDOF(x,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
	template <> \
    struct ::foobar::guid_Of_Type<x> { typedef foobar::GuidDef<l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8> Guid; }

#define FOOBAR_DECLARE_GUIDOF_(x,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
	struct x; \
	FOOBAR_DECLARE_GUIDOF(x,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8)

#define FOOBAR_GUIDOF_(x) ::foobar::guid_Of_Type<x>::Guid
#define FOOBAR_GUIDOF(x)  ::foobar::guid_Of<x>()
