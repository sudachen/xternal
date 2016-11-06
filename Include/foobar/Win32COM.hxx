
#pragma once

#include "Common.hxx"
#include "Strarg.hxx"
#include "Stream.hxx"
#include "Path.hxx"
#include "Win32.hxx"
#include "Guid.hxx"
#include "Win32Reg.hxx"

FOOBAR_DECLARE_GUIDOF_(IUnknown,0x00000000,0x0000,0x0000,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46);
FOOBAR_DECLARE_GUIDOF_(IDispatch,0x00020400,0x0000,0x0000,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46);
FOOBAR_DECLARE_GUIDOF_(IClassFactory,0x00000001,0x0000,0x0000,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46);
FOOBAR_DECLARE_GUIDOF_(ITypeLib,0x00020402,0x0000,0x0000,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46);
FOOBAR_DECLARE_GUIDOF_(ITypeInfo,0x00020401,0x0000,0x0000,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46);
FOOBAR_DECLARE_GUIDOF_(IErrorInfo,0x1CF2B120,0x547D,0x101B,0x8E,0x65,0x08,0x00,0x2B,0x2B,0xD1,0x19);
FOOBAR_DECLARE_GUIDOF_(ISupportErrorInfo,0xDF0B3D60,0x548F,0x101B,0x8E,0x65,0x08,0x00,0x2B,0x2B,0xD1,0x19);
FOOBAR_DECLARE_GUIDOF_(ITypeLib2,0x00020411,0x0000,0x0000,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46);
FOOBAR_DECLARE_GUIDOF_(ITypeInfo2,0x00020412,0x0000,0x0000,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46);
FOOBAR_DECLARE_GUIDOF_(IEnumVARIANT,0x00020404,0x0000,0x0000,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46);
FOOBAR_DECLARE_GUIDOF_(IStream,0x0000000c,0x0000,0x0000,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46);
FOOBAR_DECLARE_GUIDOF_(ISequentialStream,0x0c733a30,0x2a1c,0x11ce,0xad,0xe5,0x00,0xaa,0x00,0x44,0x77,0x3d);

namespace foobar
{

    typedef RccPtr<IUnknown>          IUnknownPtr;
    typedef RccPtr<IDispatch>         IDispatchPtr;
    typedef RccPtr<IClassFactory>     IClassFactoryPtr;
    typedef RccPtr<ITypeLib>          ITypeLibFactoryPtr;
    typedef RccPtr<ITypeInfo>         ITypeInfoPtr;
    typedef RccPtr<IErrorInfo>        IErrorInfoPtr;
    typedef RccPtr<ISupportErrorInfo> ISupportErrorInfoPtr;
    typedef RccPtr<ITypeLib2>         ITypeLib2Ptr;
    typedef RccPtr<ITypeInfo2>        ITypeInfo2Ptr;
    typedef RccPtr<IEnumVARIANT>      IEnumVARIANTPtr;
    typedef RccPtr<IStream>           IStreamPtr;
    typedef RccPtr<ISequentialStream> ISeqStreamPtr;

    template <class T>
    inline HRESULT internal_query_interface(T* self, REFIID riid, void** pI)
    {
        if ( riid == guid_Of<T>() )
        {
            *pI = refe(self);
            return S_OK;
        }
        return E_NOINTERFACE;
    }

    template <unsigned No>
    struct Fifs_ {};
    template <unsigned No>
    HRESULT internal_query_interface(Fifs_<No>* self, REFIID riid, void** pI) {return E_NOINTERFACE;}


    template <class T>
    struct NO_VTABLE Ifs0 : public T
    {

        HRESULT InternalQueryInterface(REFIID riid,void** pI)
        {
            return internal_query_interface((T*)this,riid,pI);
        }

        IUnknown* __iunknown()
        {
            return (IUnknown*)this;
        }
    };

    template <class T, class Next = IfsUnknown>
    struct NO_VTABLE Ifs : T, Next
    {
        HRESULT InternalQueryInterface(REFIID riid,void** pI)
        {
            if ( FAILED( internal_query_interface((T*)this,riid,pI)) )
                return Next::InternalQueryInterface(riid,pI);
            return S_OK;
        }

        using Next::__iunknown;
    };

    typedef Ifs0<IUnknown> IfsUnknown;


    template <class T = IfsUnknown>
    struct ComObject : T
    {
        virtual ULONG __stdcall Release()
        {
            long refcount = InterlockedDecrement(&refcount_);
            if ( refcount == 0 )
            {
                ComObject_Finalize();
                ComObject_Dispose();
            }
            return refcount;
        }

        virtual ULONG __stdcall AddRef()
        {
            long refcount = InterlockedIncrement(&refcount_);
            return refcount;
        }

        virtual HRESULT __stdcall QueryInterface(REFIID riid,void** pI)
        {
            return T::InternalQueryInterface(riid,pI);
        }

        virtual void ComObject_Dispose()
        {
            delete this;
        }

        virtual void ComObject_Finalize()
        {
            // finalization hook
        }

        virtual ~ComObject()
        {
        }

        ComObject() : refcount_(1)
        {
        }

        ULONG GetRefCount__()
        {
            return refcount_;
        }

        IUnknownPtr __iunknown_ptr()
        {
            return rcc_refe(T::__iunknown());
        }

        typedef RccPtr<ComObject<T>> Ptr;

    private:
        long refcount_;
    };

    template <
        class tIx0 = Fifs_<0>,
        class tIx1 = Fifs_<1>,
        class tIx2 = Fifs_<2>,
        class tIx3 = Fifs_<3>,
        class tIx4 = Fifs_<4>,
        class tIx5 = Fifs_<5>,
        class tIx6 = Fifs_<6>,
        class tIx7 = Fifs_<7>,
        class tIx8 = Fifs_<8>,
        class tIx9 = Fifs_<9>
        >
    struct ComObjectEx : ComObject
            <
            Ifs<tIx0,
            Ifs<tIx1,
            Ifs<tIx2,
            Ifs<tIx3,
            Ifs<tIx4,
            Ifs<tIx5,
            Ifs<tIx6,
            Ifs<tIx7,
            Ifs<tIx8,
            Ifs<tIx9
            >>>>>>>>>>
            >
    {
    };

    struct Bstr
    {
        OLECHAR* olechars;

        Bstr()
            :olechars(0)
        {}

        Bstr(OLECHAR* p, bool /*acquire*/)
            : olechars(p)
        {}

        static inline Bstr Acquire(OLECHAR* p)
        {
            return Bstr(p,true);
        }

        void _free()
        {
            if ( olechars )
            {
                ::SysFreeString(olechars);
                olechars = 0;
            }
        }

        template <class T>
        void _copy(const T& bstr)
        {
            _free();
            olechars = ::SysAllocStringLen(bstr.Cstr(),(UINT)bstr.Length());
        }

        ~Bstr()
        {
            _free();
        }

        Bstr(const Strarg<wchar_t>& s)
        {
            _copy(s);
        }

        Bstr(const Bstr& bstr) : olechars(0)
        {
            _copy(bstr);
        }

        Bstr& operator =(const Bstr& bstr)
        {
            _copy(bstr);
            return *this;
        }

        Bstr& operator =(const Strarg<wchar_t>& s)
        {
            _copy(s);
            return *this;
        }

        Bstr(Bstr&& bstr)
        {
            olechars = bstr.olechars;
            bstr.olechars = 0;
        }

        OLECHAR* Cstr() const
        {
            return olechars;
        }

        size_t Length() const
        {
            OLECHAR* s = Cstr();
            if ( s ) return s[-1];
            return 0;
        }

        std::wstring Str() const
        {
            OLECHAR* s = Cstr();
            if (s)
                return std::wstring(s,size_t(s[-1]));
            else
                return std::wstring();
        }

        std::string Utf8() const
        {
            OLECHAR* s = Cstr();
            if (s)
            {
                std::string str;
                return append_to(str,s,(size_t)s[-1]);
            }
            else
                return std::string();
        }

        OLECHAR*& operator+()
        {
            return olechars;
        }

    };

    template <class Tdst, class Tsrc>
    inline RccPtr<Tdst> ifs_cast(Tsrc* u, Tdst* = 0)
    {
        Tdst* p = 0;
        if ( u ) u->QueryInterface(FOOBAR_GUIDOF(Tdst),(void**)&p);
        return RccPtr<Tdst>(p);
    }

    template <class Tdst, class Tsrc>
    inline RccPtr<Tdst> ifs_cast(RccPtr<Tsrc> const& u, Tdst* = 0)
    {
        return ifs_cast<Tdst,Tsrc>(u.Get());
    }

    template <class Texp>
    struct ComException : public Texp
    {
        ComException()
            : Texp( GetComError() )
        {}

        static NO_INLINE std::string GetComError()
        {
            RccPtr<IErrorInfo> ierr;

            if ( SUCCEEDED(GetErrorInfo(0,&+ierr)) && ierr )
            {
                BSTR b = 0;
                if ( SUCCEEDED(ierr->GetDescription(&b)) && b)
                {
                    return Bstr::Acquire(b).Utf8();
                }
            }

            return "unknown com error";
        }
    };

    typedef ComException<std::runtime_error> StdComException;
    typedef Ifs0<ISupportErrorInfo> IfsSupportErrorInfo;

    template <class T>
    struct NO_VTABLE SupportErrorInfo : IfsSupportErrorInfo
    {
        HRESULT __stdcall InterfaceSupportsErrorInfo(REFIID riid)
        {
            return IsEqualGUID(FOOBAR_GUIDOF(T),riid)?S_OK:S_FALSE;
        }

        HRESULT NO_INLINE RaiseComError(const Strarg<wchar_t>& msg, HRESULT hr = E_FAIL)
        {
            ICreateErrorInfo* pICE = 0;
            if ( FAILED( ::CreateErrorInfo(&pICE) ) ) return E_FAIL;
            pICE->SetSource((BSTR)L"");
            pICE->SetDescription((BSTR)msg.Str());
            IErrorInfo* pIEI = 0;
            if ( SUCCEEDED( pICE->QueryInterface(FOOBAR_GUIDOF(IErrorInfo),(void**)&pIEI) ) )
            {
                ::SetErrorInfo(0L,pIEI);
                pIEI->Release();
            }
            pICE->Release();
            return hr;
        }
    };

    inline Guid gen_guid()
    {
        Guid guid;
        CoCreateGuid(&guid.value);
        return guid;
    }

    inline NO_INLINE Guid guid_from_string(const Strarg<wchar_t>& uuid)
    {
        Guid guid;
        memset(&guid,0,sizeof(guid));
        wchar_t* p = const_cast<wchar_t*>(uuid.Cstr());
        wchar_t q[3] = {0}, *qe;
        while ( *p && !iswxdigit(*p) ) ++p;
        guid.value.Data1 = (uint32_t)wcstoll(p,&p,16);
        while ( *p && !iswxdigit(*p) ) ++p;
        guid.value.Data2 = (uint16_t)wcstol(p,&p,16);
        while ( *p && !iswxdigit(*p) ) ++p;
        guid.value.Data3 = (uint16_t)wcstol(p,&p,16);
        for ( size_t i = 0; i < 8 && *p; ++i)
        {
            while ( *p && !iswxdigit(*p) ) ++p;
            q[0] = *p++;
            while ( *p && !iswxdigit(*p) ) ++p;
            q[1] = *p++;
            guid.value.Data4[i] = (uint8_t)wcstol(q,&qe,16);
        }
        return guid;
    }

    inline Result<IClassFactoryPtr> get_class(const GUID& class_uuid, const Strarg<wchar_t>& modulename = None)
    {
        std::wstring uuid = to_wstring(class_uuid);
        HMODULE dll;

        if ( modulename == None )
        {
            Result<RegNode> rgn = winreg_classes_root(L"CLSID\\{"+uuid+L"}\\InprocServer32");
            if ( rgn.Failed() )
                return Error(rgn);
            Result<std::wstring> dllname = rgn->QueryString(L"");
            if ( dllname.Failed() )
                return Error(dllname);
            dll = ::LoadLibraryW(dllname.Get().c_str());
            if ( dll == 0 )
                return Error(format("failed to load module %s: %s",
                                    dllname.Get(), format_win32_error()));
        }
        else
        {
            dll = ::LoadLibraryW(modulename.Cstr());
            if ( dll == 0 )
                return Error(format("failed to load module %s: %s",
                                    modulename,format_win32_error()));
        }


        HRESULT (__stdcall *fDllGetClassObject)(const GUID*,const GUID*,void*) = 0;
        *(void**)&fDllGetClassObject = GetProcAddress(dll,"DllGetClassObject");
        if (fDllGetClassObject == 0)
            return Error("module does not have entry DllGetClassObject");

        IClassFactoryPtr icfp;
        HRESULT hr = fDllGetClassObject(&class_uuid,&FOOBAR_GUIDOF(IClassFactory),(void**)&+icfp);
        if ( !SUCCEEDED(hr) )
            return Error(format("DllGetClassObject{%s}/COM error %08x",uuid,hr));

        return icfp;
    }

    template <class T>
    Result<RccPtr<T>> create_instance(const IClassFactoryPtr& icfp)
    {
        RccPtr<T> ip;
        HRESULT hr = icfp->CreateInstance(0,FOOBAR_GUIDOF(T),(void**)&+ip);
        if ( !SUCCEEDED(hr) )
            return Error(format("IClassFactory->CreateInstance{%s}/COM error %08x",to_wstring(FOOBAR_GUIDOF(T)),hr));
        return ip;
    }

    template <class T>
    Result<RccPtr<T>> create_instance(const GUID& class_uuid)
    {
        Result<IClassFactoryPtr> icfp = get_class(class_uuid);
        if ( icfp.Failed() )
            return Error(icfp);
        return create_instance<T>(icfp);
    }

    inline void operator ||( HRESULT hr, Die )
    {
        if ( !SUCCEEDED(hr) ) die_now(format("HRESULT error %08x",hr).c_str());
    }

    template <class T>
    struct ComClassFactory : ComObject<Ifs<IClassFactory,IfsUnknown>>
    {

        HRESULT __stdcall CreateInstance(IUnknown* _, REFIID riid, void** ret)
        {
            if ( _ != 0 )
                return CLASS_E_NOAGGREGATION;

            try
            {
                return RccPtr<T>(New)->QueryInterface(riid,ret);
            }
            catch (std::exception& e)
            {
                return E_FAIL;
            }
        }

        HRESULT __stdcall LockServer(BOOL)
        {
            return S_OK;
        }

    };

}
