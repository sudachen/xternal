#pragma once

#include "Common.hxx"
#include "Strarg.hxx"
#include "Win32.hxx"
#include "Format.hxx"
#include "RccPtr.hxx"

namespace foobar
{
    struct RegNodeObject;
    typedef RccPtr<RegNodeObject> RegNode;

    struct RegNodeObject: Refcounted
    {
        HKEY hreg;
        bool owned_by: 1;

        RegNodeObject(HKEY h, bool acquire)
            : hreg(h), owned_by(acquire == true)
        {
        }

        ~RegNodeObject()
        {
            if ( hreg != 0 && owned_by )
                ::RegCloseKey(hreg);
        }

        bool Good() const
        {
            return hreg != 0 && hreg != INVALID_HANDLE_VALUE;
        }

        bool HasChild(const Strarg<wchar_t>& name) const
        {
            HKEY child = 0;
            long err;
            if ( ERROR_SUCCESS != ( err = ::RegOpenKeyExW(hreg,name.Cstr(),0,KEY_ALL_ACCESS,&child) ))
                return false;
            ::RegCloseKey(child);
            return true;
        }

        Result<RegNode> GetChild(const Strarg<wchar_t>& name, DWORD access = KEY_READ) const
        {
            HKEY child = 0;
            long err;
            if ( ERROR_SUCCESS != ( err = ::RegOpenKeyExW(hreg,name.Cstr(),0,access,&child) ))
                return Error(format("RegNode->GetChild: %s",format_win32_error(err)));
            return RegNode::Make(child,true);
        }

        Result<RegNode> CreateChild(const Strarg<wchar_t>& name) const
        {
            HKEY child = 0;
            long err;
            if ( ERROR_SUCCESS != ( err = ::RegCreateKeyExW(hreg,name.Cstr(),0,0,0,KEY_ALL_ACCESS,0,&child,0) ))
                return Error(format("RegNode->CreateChild: %s",format_win32_error(err)));
            return RegNode::Make(child,true);
        }

        Result<std::wstring> QueryString(const Strarg<wchar_t>& name, const Strarg<wchar_t>& dflt = None) const
        {
            std::vector<wchar_t> buf;
            DWORD ltype = REG_SZ;
            long err;
            DWORD buf_len = 0;

            if ( ERROR_SUCCESS != (err=RegQueryValueExW(hreg,name.Cstr(),0,&ltype,0,&buf_len)) )
                if ( err != ERROR_FILE_NOT_FOUND || dflt == None )
                    return Error(format("RegNode->QueryString: %s",format_win32_error(err)));
                else
                    return dflt.Str();

            if ( ltype == REG_NONE ) // ?!
                return std::wstring();
            else if ( ltype != REG_SZ && ltype != REG_EXPAND_SZ )
                return Error(format("RegNode->QueryString: registry value '%?' is not string",name));

            buf.resize(buf_len);
            if ( ERROR_SUCCESS != (err=RegQueryValueExW(hreg,name.Cstr(),0,&ltype,(LPBYTE)&buf[0],&buf_len)) )
                return Error(format("RegNode->QueryString: %s",format_win32_error(err)));

            if ( ltype == REG_SZ )
            {
                while ( buf[buf_len-1] == 0 && buf_len > 0 ) --buf_len; // remove terminating zeros
                return std::wstring(&buf[0],buf_len);
            }
            else // ltype == REG_EXPAND_SZ
            {
                size_t required = ExpandEnvironmentStringsW(&buf[0],0,0);
                std::vector<wchar_t> expand(required);
                ExpandEnvironmentStringsW(&buf[0],&expand[0],(DWORD)expand.size());
                return std::wstring(&expand[0]);
            }
        }

        Result<void> SetString(const Strarg<wchar_t>& name, const Strarg<wchar_t>& value, DWORD ltype = REG_SZ) const
        {
            long err;

            // setting string with 1 terminating zero!
            if ( ERROR_SUCCESS !=
                 (err=RegSetValueExW(hreg,name.Cstr(),0,ltype,
                                     (LPBYTE)value.Cstr(),
                                     (DWORD)(value.Length()+1)*2
                                     /* windows WCHAR is 2 bytes */)) )
                return Error(format("RegNode->SetString: %s",format_win32_error(err)));

            return None;
        }

        Result<uint32_t> QueryDword(const Strarg<wchar_t>& name, Option<uint32_t> dflt = None) const
        {
            DWORD buf;
            DWORD buf_len = 4;
            DWORD ltype = REG_DWORD;
            long err;

            if ( ERROR_SUCCESS != (err=RegQueryValueExW(hreg,name.Cstr(),0,&ltype,(LPBYTE)&buf,&buf_len)) )
                if ( err != ERROR_FILE_NOT_FOUND || dflt == None )
                    return Error(format("RegNode->QueryDword: %s",format_win32_error(err)));
                else
                    return dflt.Get();

            return (uint32_t)buf;
        }

        Result<void> SetDword(const Strarg<wchar_t>& name, uint32_t value) const
        {
            DWORD ltype = REG_DWORD;
            long err;

            if ( ERROR_SUCCESS !=
                 (err=RegSetValueExW(hreg,name.Cstr(),0,ltype,
                                     (LPBYTE)&value,4)) )
                return Error(format("RegNode->SetDword: %s",format_win32_error(err)));

            return None;
        }

        Result<void> IterateBy(std::function<Result<bool>(RegNode&& curr, std::wstring&& child)> op)
        {
            std::array<wchar_t,260> name; /*MSDN: full keyname limeted by 255 chars*/
            DWORD index = 0;
            long err;

            for (;; ++index)
            {
                err = ::RegEnumKeyW(hreg,index,&name[0],(DWORD)name.size());
                if ( err == ERROR_NO_MORE_ITEMS )
                    break;
                else if ( err != ERROR_SUCCESS )
                    return Error(format("RegNode->IterateBy: %s",format_win32_error(err)));

                Result<bool> r = op(rcc_refe(this),std::wstring(&name[0]));
                if ( r.Failed() )
                    return Error(r);
                else if ( r.Get() == false )
                    break;
            }

            return None;
        }

        Result<void> SimpleIterateBy(std::function<void(RegNode&& curr, std::wstring&& child)> op)
        {
            return IterateBy([&op](RegNode&& curr, std::wstring&& child)->Result<bool>
            {
                op(std::move(curr),std::move(child));
                return true;
            });
        }

        Result<std::vector<std::wstring>> ListChidren()
        {
            std::vector<std::wstring> lst;
            Result<void> r = SimpleIterateBy([&lst](RegNode&&, std::wstring&& child)
            {
                lst.push_back(std::move(child));
            });
            if ( r.Succeeded() )
                return lst;
            else
                return Error(r);
        }

    };

    inline Result<RegNode> winreg_current_user(const Strarg<wchar_t>& name = None)
    {
        if ( name == None )
            return RegNode::Make(HKEY_CURRENT_USER,false);
        else
            return RegNode::Make(HKEY_CURRENT_USER,false)->GetChild(name);
    }

    inline Result<RegNode> winreg_local_machine(const Strarg<wchar_t>& name = None)
    {
        if ( name == None )
            return RegNode::Make(HKEY_LOCAL_MACHINE,false);
        else
            return RegNode::Make(HKEY_LOCAL_MACHINE,false)->GetChild(name);
    }

    inline Result<RegNode> winreg_classes_root(const Strarg<wchar_t>& name = None)
    {
        if ( name == None )
            return RegNode::Make(HKEY_CLASSES_ROOT,false);
        else
            return RegNode::Make(HKEY_CLASSES_ROOT,false)->GetChild(name);
    }

}
