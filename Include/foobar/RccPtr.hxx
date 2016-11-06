
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

namespace foobar
{
    template <class T> inline T* refe(T* ref)
    {
        if ( ref ) ref->AddRef();
        return ref;
    }

    template <class T> inline void unrefe(T*& ref)
    {
        if ( ref ) ref->Release();
        ref = 0;
    }

    template <class T>
    struct RccPtr
    {
        mutable T* ref_;

        typedef RccPtr<T> const& Ref;

        explicit RccPtr(T* t = 0)
            : ref_(t) { }

        explicit RccPtr(T* t, bool addref)
            : ref_(t)
        {
            if (addref)
                refe(ref_);
        }

        RccPtr(struct NoneValue)
            : ref_(0) { }

        RccPtr(struct NewValue)
            : ref_(new T()) { }

        RccPtr(const RccPtr<T>& a)
        {
            ref_ = refe(a.ref_);
        }

        ~RccPtr()
        {
            unrefe(ref_);
        }

        template <class Q> operator RccPtr<Q> () const
        {
            return RccPtr<Q> (refe(ref_));
        }

        bool operator !() const
        {
            return !ref_;
        }

        typedef T* (RccPtr<T>::*BoolType)();

        operator BoolType() const
        {
            return ref_ != 0 ? &RccPtr<T>::Forget : 0;
        }

        T& operator *() const
        {
            return *ref_;
        }

        T* operator -> () const
        {
            return ref_;
        }

        const RccPtr& operator=(const RccPtr& a)
        {
            Reset(refe(a.ref_));
            return *this;
        }

        bool operator ==(NoneValue) const
        {
            return ref_ == 0;
        }

        bool operator ==(const RccPtr& a) const
        {
            return ref_ == a.ref_;
        }

        bool operator !=(NoneValue) const
        {
            return ref_ != 0;
        }

        bool operator !=(const RccPtr& a) const
        {
            return ref_ != a.ref_;
        }

        bool operator<(const RccPtr& a) const
        {
            return ref_ < a.ref_;
        }

        bool operator>(const RccPtr& a) const
        {
            return ref_ > a.ref_;
        }

        T*& operator +() const
        {
            return ref_;
        }

        T* Get() const
        {
            return ref_;
        }

        void Reset(T* t)
        {
            unrefe(ref_);
            ref_ = t;
        }

        T* Forget()
        {
            T* t = ref_;
            ref_ = 0;
            return t;
        }

        void Swap(RccPtr& p)
        {
            swap(p.ref_, ref_);
        }

        template<class... Args>
        static RccPtr Make( Args&& ... args )
        {
            return RccPtr(new T(std::forward<Args>(args)...));
        }

    private:
        void operator=(const T*);
    };

    template <class T> inline
    T* refe(const RccPtr<T>& ref)
    {
        refe(ref.ref_);
        return ref.ref_;
    }

    template <class T> inline
    void unrefe(RccPtr<T>& ref)
    {
        ref.Reset((T*)0);
    }

    template <class T> inline
    T* forget(RccPtr<T>& ref)
    {
        return ref.Forget();
    }

    template <class T> inline
    void reset(RccPtr<T>& ref, T* p)
    {
        ref.Reset(p);
    }

    template <class T> inline
    RccPtr<T> rcc_ptr(T* ref)
    {
        return RccPtr<T> (ref);
    }

    template <class T> inline
    RccPtr<T> rcc_refe(T* ref)
    {
        return RccPtr<T> (refe(ref));
    }

    template <class T> inline
    void swap(RccPtr<T>& to, RccPtr<T>& from)
    {
        to.Swap(from);
    }

    template <class T> inline
    bool is_null(const RccPtr<T>& ptr)
    {
        return !ptr.Get();
    }

}

