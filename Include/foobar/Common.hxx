
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

#include <cstdint>
#include <cassert>
#include <array>
#include <string>
#include <vector>
#include <memory>
#include <functional>
#include <algorithm>
#include <stdexcept>

#ifdef _MSC_VER
#pragma warning(disable:4512) // sugestion to use secured _s functions
#pragma warning(disable:4996) // swprintf ISO warning
#pragma warning(disable:4129) // assignment operator could not be generated
#pragma warning(disable:4239) // nonstandard extension used
#endif

#ifndef _FOOBAR
#define _FOOBAR 0x100
#endif

#if defined _MSC_VER && _MSC_VER >= 1400
# define FAKE_INLINE inline __declspec(noinline)
#else
# define FAKE_INLINE inline
#endif

#if defined _MSC_VER && _MSC_VER >= 1400
# define NO_INLINE __declspec(noinline)
#else
# if defined __GNUC__
#  define NO_INLINE  __attribute__((noinline))
# else
#  define NO_INLINE
# endif
#endif

#if defined WIN32 || defined _WIN32 || defined _MSC_VER || defined __MINGW32_VERSION
# define __windoze
# if !defined __i386 && !defined __x86_64
#  ifdef _M_IX86
#   define __i386
#  elif defined _M_AMD64
#   define __x86_64
#  else
#   error "unknown processor"
#  endif
# endif
#endif

#define OVERRIDE
#define FOOBAR_ASSERT(Expr)  assert(Expr)
#define FOOBAR_UNREACHABLE() abort()

#define FOOBAR_CONCAT(a,b) a##b
#define FOOBAR_E2(a,b) a b
#define FOOBAR_COUNT_N(__a, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,...) a16
#define FOOBAR_COUNT_CONCAT(__a, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,...) __a##a16
#define FOOBAR_ARG_CONCAT(Q,...) FOOBAR_E2(FOOBAR_COUNT_CONCAT,(Q,##__VA_ARGS__, 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0))
#define FOOBAR_PARAMS(Q,...) FOOBAR_ARG_CONCAT(FOOBAR_PARAM_,__VA_ARGS__)(Q,__VA_ARGS__)
#define FOOBAR_PARAM_1(_Q,a) _Q(a)
#define FOOBAR_PARAM_2(_Q,b,a) _Q(b), _Q(a)
#define FOOBAR_PARAM_3(_Q,c,b,a) _Q(c), FOOBAR_PARAM_2(_Q,b,a)
#define FOOBAR_PARAM_4(_Q,d,c,b,a) _Q(d), FOOBAR_PARAM_3(_Q,c,b,a)
#define FOOBAR_PARAM_5(_Q,e,d,c,b,a) _Q(e), FOOBAR_PARAM_4(_Q,d,c,b,a)
#define FOOBAR_PARAM_6(_Q,f,e,d,c,b,a) _Q(f), FOOBAR_PARAM_5(_Q,e,d,c,b,a)
#define FOOBAR_PARAM_7(_Q,g,f,e,d,c,b,a) _Q(g), FOOBAR_PARAM_6(_Q,f,e,d,c,b,a)
#define FOOBAR_PARAM_8(_Q,i,g,f,e,d,c,b,a) _Q(i), FOOBAR_PARAM_7(_Q,g,f,e,d,c,b,a)
#define FOOBAR_PARAM_9(_Q,j,i,g,f,e,d,c,b,a) _Q(j), FOOBAR_PARAM_8(_Q,i,g,f,e,d,c,b,a)
#define FOOBAR_PARAM_10(_Q,k,j,i,g,f,e,d,c,b,a) _Q(k), FOOBAR_PARAM_9(_Q,j,i,g,f,e,d,c,b,a)
#define FOOBAR_PARAM_11(_Q,l,k,j,i,g,f,e,d,c,b,a) _Q(l), FOOBAR_PARAM_10(_Q,k,j,i,g,f,e,d,c,b,a)
#define FOOBAR_PARAM_12(_Q,m,l,k,j,i,g,f,e,d,c,b,a) _Q(m), FOOBAR_PARAM_11(_Q,l,k,j,i,g,f,e,d,c,b,a)
#define FOOBAR_PARAM_13(_Q,n,m,l,k,j,i,g,f,e,d,c,b,a) _Q(n), FOOBAR_PARAM_12(_Q,m,l,k,j,i,g,f,e,d,c,b,a)
#define FOOBAR_PARAM_14(_Q,o,n,m,l,k,j,i,g,f,e,d,c,b,a) _Q(o), FOOBAR_PARAM_13(_Q,n,m,l,k,j,i,g,f,e,d,c,b,a)
#define FOOBAR_PARAM_15(_Q,p,o,n,m,l,k,j,i,g,f,e,d,c,b,a) _Q(p), FOOBAR_PARAM_14(_Q,o,n,m,l,k,j,i,g,f,e,d,c,b,a)

#define NO_VTABLE __declspec(novtable)

namespace foobar
{

    template <class T>
    struct Enum
    {
        T value;
        operator T() const { return value; }
        operator int() const { return value; }
        operator unsigned int() const { return value; }
        Enum& operator = (int a) { value = a; return *this; }
        Enum& operator |= (int a) { value = T(value | a); return *this; }
        T operator | (T a) const { return T (value | a); }
        Enum(int a) : value((T)a) {}
        Enum(T a) : value(a) {}
    };

    struct NewValue
    {
        char _;
        template <class T> operator std::unique_ptr<T>() const
        { return std::unique_ptr<T>(new T()); }
        template <class T> operator std::shared_ptr<T>() const
        { return std::shared_ptr<T>(new T()); }
    };
    static const NewValue New = {0};

    struct NoneValue
    {
        char _;
        template <class T> operator std::unique_ptr<T>() const
        { return std::unique_ptr<T>(0); }
        template <class T> operator std::shared_ptr<T>() const
        { return std::shared_ptr<T>(0); }
    };
    static const NoneValue None = {0};

    struct NonCopyableFiller {};

    template <class T = NonCopyableFiller>
    struct NonCopyableT : T
    {
    protected:
        NonCopyableT() {}
        ~NonCopyableT() {}
    private:
        NonCopyableT(const NonCopyableT&);
        const NonCopyableT& operator=(const NonCopyableT&);
    };

    typedef NonCopyableT<> NonCopyable;

    template <class T> struct Opposite { typedef void    Type; };
    template<> struct Opposite<char>     { typedef wchar_t Type; };
    template<> struct Opposite<wchar_t>  { typedef char    Type; };

    template <class T>
    struct Option
    {
        #ifdef __x86_64
        __declspec(align(8))
        #else
        __declspec(align(4))
        #endif
        uint8_t value[sizeof(T)];
        bool specified;
        Option() : specified(false) {}
        Option(NoneValue) : specified(false) {}
        Option(T value) : specified(true)
        {
            new (&this->value[0]) T(value);
        }

        ~Option()
        {
            if ( specified ) ((T*)&this->value[0])->~T();
        }

        Option& operator=(const Option& o)
        {
            Option(o).Swap(*this);
            return *this;
        }

        Option(const Option& o) : specified(o.specified)
        {
            if ( specified ) { new (&this->value[0]) T(*(T*)&o.value[0]); }
        }

        Option(Option&& o) : specified(o.specified)
        {
            memcpy(this->value,o.value,sizeof(this->value));
        }

        T& operator *() { return Get(); }
        const T& operator *() const { return Get(); }
        operator T& () { return Get(); }
        operator const T& () const { return Get(); }

        T* operator ->() { return &Get(); }
        const T* operator ->() const { return &Get(); }

        bool operator ==(NoneValue) const { return !specified; }
        bool operator !=(NoneValue) const { return specified; }
        bool Exists() const { return specified; }

        Option& Swap(Option& o)
        {
            for (auto i = &value[0], j = &o.value[0],
                 iE = &value[0]+sizeof(T);
                 i != iE; ++i, ++j)
                std::swap(*i,*j);

            std::swap(specified, o.specified);
            return *this;
        }

        T& Get()
        {
            FOOBAR_ASSERT(specified != false);
            return *(T*)&value[0];
        }

        const T& Get() const
        {
            FOOBAR_ASSERT(specified != false);
            return *(T*)&value[0];
        }

        typedef const T& (Option<T>::*BooleanType)() const;
        operator BooleanType() const { return &Option<T>::Get; }

    };

    template <class T>
    struct Option<T&>
    {
        T* value;
        bool specified;
        Option() {}
        Option(T& value) : value(&value), specified(true) {}
        Option(NoneValue) : value(), specified(false) {}

        T& operator *() const  { return *value; }
        operator T& () const   { return *value; }
        T* operator ->() const { return value; }

        bool operator ==(NoneValue) { return !specified; }
        bool operator !=(NoneValue) { return specified; }

        const T& Get() const { return *value;}
        typedef const T& (Option<T&>::*BooleanType)() const;
        operator BooleanType() const { return &Option<T&>::Get; }

    private:
        void operator =(const Option&);
    };

    /*
    template <class T>
    inline T& operator <<=(Option<T>& opt, T value)
    {
        opt = value;
        return opt.Get();
    }
    */

    template <class T> struct ExactType
    {
        typedef T Type;
        ExactType() {}
    };

    template <class T1, class T2> struct ExactType2
    {
        typedef T1 Type1;
        typedef T2 Type2;
        ExactType2() {}
    };

    template <class T, size_t N> T* begin(T(&a)[N]) { return a; }
    template <class T, size_t N> T* end(T(&a)[N]) { return a + N; }
    template <class T, size_t N> size_t length_of(T(&a)[N]) { return N; }

    template <class Trng, class Tfn>
    void for_each(Trng& rng, Tfn fn)
    {
        for (auto i = begin(rng), iE = end(rng); i != iE; ++i)
            fn(*i);
    }

    struct Boolean
    {
        int value;
        explicit Boolean(int value) : value(value?1:0) {}
        Boolean operator !() const { return Boolean(value?0:1); }
        operator int() const { return value; }
    };

    static const Boolean True = Boolean(1);
    static const Boolean False = Boolean(0);

    struct VoidValue
    {
        VoidValue() {}
        VoidValue(NoneValue) {}
    };

    template<class T, class Ex>
    struct Either
    {
        Option<T> r;
        Option<Ex> ex;
        Either(T&& value) : r(std::move(value)) {}
        Either(const T& value) : r(value) {}
        Either(Ex&& e) : ex(std::move(e)) {}
        Either(const Ex& e) : ex(e) {}
        Either(const Option<T>& value, const Option<Ex>& e) : r(value), ex(e) {}
        const T& Get() const
        {
            if ( ex != None ) throw ex.Get();
            if ( r != None ) return r.Get();
            FOOBAR_UNREACHABLE();
        }
        operator const T& () const { return Get(); }
        bool Succeeded() const { return ex == None && r != None; }
        bool Failed() const { return !Succeeded(); }
        const T& operator->() const { return Get(); }
        T& operator->() { return const_cast<T&>(Get()); }
    };

    template<class Ex>
    struct Either<void,Ex>
    {
        Option<Ex> ex;
        Either(Ex&& e) : ex(std::move(e)) {}
        Either(VoidValue) {}
        Either(const Ex& e) : ex(e) {}
        Either(const Option<VoidValue>& value, const Option<Ex>& e) : ex(e) {}
        bool Succeeded() const { return ex == None; }
        bool Failed() const { return !Succeeded(); }
    };

    //typedef std::runtime_error Error;

    struct Error: std::runtime_error
    {
        Error(const char* text)
            : std::runtime_error(text)
        {}
        Error(std::string&& text)
            : std::runtime_error(std::move(text))
        {}
        Error(const std::string& text)
            : std::runtime_error(text)
        {}

        template <class T, class E>
        Error(const Either<T, E>& e)
            : std::runtime_error(e.ex == None ? "none error": e.ex->what())
        {}
    };

    template <class T> struct UnVoid { typedef T Type; };
    template <> struct UnVoid<void> { typedef VoidValue Type; };

    template <class T>
    struct Result : Either<T, Error>
    {
        typedef Either<T, Error> _Base;
        typedef typename UnVoid<T>::Type X;
        Result(X&& value) : _Base(std::move(value)) {}
        Result(const X& value) : _Base(value) {}
        Result(Error&& e) : _Base(std::move(e)) {}
        Result(const Error& e) : _Base(e) {}
        Result(NoneValue) : _Base(X(None)) {}
        //template <class U> Result(const Option<T>& value, const Result<U>& r) : _Base(value,r.ex){}
    };

    struct Die
    {
        template <class T, class Ex> void operator ||(const Either<T,Ex>& e) const
        {
            if ( e.ex.Exists() )
            {
                throw* e.ex;
            }
        }

        template <class T, class Ex> void operator |(const Either<T,Ex>& e) const
        {
            operator || (*this,e);
        }
    };

    template <class T, class Ex> void operator ||(const Either<T,Ex>& e, Die d) { d || e; }
    template <class T, class Ex> void operator |(const Either<T,Ex>& e, Die d) { d || e; }

    static const Die die = {};
    inline void die_now(const char* text) { throw std::runtime_error(text); }
}
