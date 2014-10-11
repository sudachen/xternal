
/*

(C)2014, Alexey Sudachen

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

#include <string>
#include <stdexcept>
#include <foobar/Common.hxx>
#include <foobar/Strarg.hxx>
#include <foobar/RccPtr.hxx>
#include <foobar/StringTool.hxx>
#include "libconf.h"

inline XNODE* refe(XNODE* ref) { if (ref) Xnode_Addref(ref); return ref; }
inline void unrefe(XNODE*& ref) { if (ref) Xnode_Release(ref); ref = 0; }

namespace libconf
{
	struct LibconfException : std::runtime_error
	{
		LibconfException() : std::runtime_error(Libconf_Error_String(1)) {}
	};

	struct Xnode
	{
		XNODE* Self()
		{
			return self.Get();
		}

		struct Value
		{
			XNODE* xnode;
			const foobar::Strarg<char>* name;

			Value(XNODE* xnode, const foobar::Strarg<char>* name) : xnode(xnode), name(name) {}

			XVALUE* _GetVal(int create_if)
			{
				char *c_name = name ? name->Cstr() : "@Value";
				XVALUE* xval = Xnode_Value(xnode, c_name, create_if);
				if (Libconf_Error_Occured(0))
					throw LibconfException();
				return xval;
			}

			XVALUE* _GetVal() const
			{
				char *c_name = name ? name->Cstr() : "@Value";
				XVALUE* xval = Xnode_Value(xnode, c_name, 0);
				if (Libconf_Error_Occured(0))
					throw LibconfException();
				return xval;
			}

			void operator =(const foobar::Strarg<char>& value)
			{
				Xvalue_Set_Str(_GetVal(1), value.Cstr(), value.Length());
				if (Libconf_Error_Occured(0))
					throw LibconfException();
			}

			void operator =(double val)
			{
				Xvalue_Set_Flt(_GetVal(1), val);
				if (Libconf_Error_Occured(0))
					throw LibconfException();
			}

			void operator =(int64_t val)
			{
				Xvalue_Set_Int(_GetVal(1), val);
				if (Libconf_Error_Occured(0))
					throw LibconfException();
			}

			void operator =(int val)
			{
				Xvalue_Set_Int(_GetVal(1), val);
				if (Libconf_Error_Occured(0))
					throw LibconfException();
			}

			void operator =(foobar::Boolean val)
			{
				Xvalue_Set_Bool(_GetVal(1), val);
				if (Libconf_Error_Occured(0))
					throw LibconfException();
			}

			bool operator !() const
			{
				return !Bool();
			}

			typedef foobar::Boolean(Value::*BoolType)() const;
			operator BoolType() const { return Bool() ? &Value::Bool : 0; }

			const char* Cstr() const
			{
				const char* retval = Xvalue_Get_Str(_GetVal(), 0);
				if (Libconf_Error_Occured(0))
					throw LibconfException();
				return retval;
			}

			std::string Str() const
			{
				auto cstr = std::unique_ptr<char, void(*)(char*)>
				            (Xvalue_Copy_Str(_GetVal(), 0), Libconf_Cstr_Kill);
				if (Libconf_Error_Occured(0))
					throw LibconfException();
				return std::string(cstr.get() ? cstr.get() : "");
			}

			foobar::Boolean Bool() const
			{
				foobar::Boolean retval = (foobar::Boolean)Xvalue_Get_Bool(_GetVal(), 0);
				if (Libconf_Error_Occured(0))
					throw LibconfException();
				return retval;
			}

			int64_t Int() const
			{
				int64_t retval = Xvalue_Get_Int(_GetVal(), 0);
				if (Libconf_Error_Occured(0))
					throw LibconfException();
				return retval;
			}

			double Flt() const
			{
				double retval = Xvalue_Get_Flt(_GetVal(), 0);
				if (Libconf_Error_Occured(0))
					throw LibconfException();
				return retval;
			}

			bool Exists() const
			{
				XVALUE* xval = _GetVal();
				return  xval != 0 && Xvalue_Get_Kind(xval) != XVALUE_KIND_NONE;
			}

			void Delete()
			{
				XVALUE* xval = _GetVal();
				if (xval) Xvalue_Purge(xval);
			}

			operator std::string() const { return Str(); }

			bool operator == (foobar::NoneValue) const
			{
				return !Exists();
			}

			bool operator != (foobar::NoneValue) const
			{
				return Exists();
			}

			bool IsEqualNocaseTo(const foobar::Strarg<wchar_t>& chars) const
			{
				const char *str = Cstr();
				if ( !str || !chars.Cstr() ) return false;
				return foobar::is_equal_nocase(str,chars);
			}

			bool IsEqualTo(const foobar::Strarg<char>& chars) const
			{
				const char *str = Cstr();
				if ( !str || !chars.Cstr() ) return false;
				return strcmp(chars.Cstr(),str) == 0;
			}
		};

		typedef Xnode (Xnode::*BoolType)();
		operator BoolType() const { return !self ? 0 : &Xnode::Down;}

		Value operator [](const foobar::Strarg<char>& name)
		{
			return Value(+self, &name);
		}

		Xnode Down()
		{
			XNODE* node = Xnode_Down(+self);
			if (Libconf_Error_Occured(0))
				throw LibconfException();
			return Xnode(node);
		}

		Xnode DownIf(const foobar::Strarg<char>& tag)
		{
			XNODE* node = Xnode_Down_If(+self, tag.Cstr());
			if (Libconf_Error_Occured(0))
				throw LibconfException();
			return Xnode(node);
		}

		Xnode operator()(const foobar::Strarg<char>& tag)
		{
			Xnode r = DownIf(tag);
			if ( !r )
				return Append(tag);
		}

		Xnode Next()
		{
			XNODE* node = Xnode_Next(+self);
			if (Libconf_Error_Occured(0))
				throw LibconfException();
			return Xnode(node);
		}

		Xnode NextIf(const foobar::Strarg<char>& tag)
		{
			XNODE* node = Xnode_Next_If(+self, tag.Cstr());
			if (Libconf_Error_Occured(0))
				throw LibconfException();
			return Xnode(node);
		}

		const char* Tag()
		{
			return Xnode_Get_Tag(+self);
		}

		Xnode(XNODE* xnode, bool add_ref) : self(xnode,add_ref) {}
		Xnode(XNODE* xnode) : self(refe(xnode)) {}
		Xnode() : self(0) {}

		Xnode(foobar::NewValue) : self(0)
		{
			XDATA* xdata = Xdata_Init();
			if (Libconf_Error_Occured(0))
				throw LibconfException();
			self = foobar::RccPtr<XNODE>(Xdata_Get_Root(xdata));
		}

		Xnode Append(const foobar::Strarg<char>& tag)
		{
			XNODE* n = Xnode_Append(+self, tag.Cstr());
			if (Libconf_Error_Occured(0))
				throw LibconfException();
			return Xnode(n);
		}

		Xnode Insert(const foobar::Strarg<char>& tag)
		{
			XNODE* n = Xnode_Insert(+self, tag.Cstr());
			if (Libconf_Error_Occured(0))
				throw LibconfException();
			return Xnode(n);
		}

		std::string Format()
		{
			auto bf = std::unique_ptr<LIBCONF_BUFFER, void(*)(LIBCONF_BUFFER*)>
			          (Xnode_Format(+self, 0), Libconf_Buffer_Kill);
			if (Libconf_Error_Occured(0))
				throw LibconfException();
			return std::string(bf->chars, bf->count);
		}

		struct NameValue
		{
			Xnode &self;
			NameValue(Xnode &xnode) : self(xnode) {}
			
			void operator =(const foobar::Strarg<char>& value)
			{
				return self["@Name"]=value;
			}

			operator std::string()
			{
				return self["@Name"].Str();
			}
		};

		NameValue Name() { return NameValue(*this); }
		Value Default() { return Value(+self,0); }
	
	private:
		foobar::RccPtr<XNODE> self;
	};

	using foobar::New;
}

