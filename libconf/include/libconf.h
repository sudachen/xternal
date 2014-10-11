
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

#ifndef C_once_97FCCED6_BE34_4DFF_B19B_63443F394EB1
#define C_once_97FCCED6_BE34_4DFF_B19B_63443F394EB1

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#define C_CONST const
#else
#define C_CONST
#endif

#if ( defined _DLL && !defined LIBCONF_STATIC ) || defined LIBCONF_DLL || defined LIBCONF_BUILD_DLL
#  if defined LIBCONF_BUILD_DLL
#    define LIBCONF_EXPORTABLE __declspec(dllexport)
#  else
#    define LIBCONF_EXPORTABLE __declspec(dllimport)
#  endif
#else
#define LIBCONF_EXPORTABLE
#endif

typedef struct XNODE XNODE;
typedef struct XDATA XDATA;
typedef struct XNODE XVALUE;

enum
{
    XVALUE_KIND_NONE     = 0x08000,
    XVALUE_KIND_INT      = 0x08001,
    XVALUE_KIND_FLT      = 0x08002,
    XVALUE_KIND_STR      = 0x08003,
    XVALUE_KIND_BIN      = 0x08004,
    XVALUE_KIND_BOOL     = 0x08005,
    XVALUE_KIND_LIT      = 0x08006,
    XVALUE_KIND_STR_ARR  = 0x08007,
    XVALUE_KIND_FLT_ARR  = 0x08008,
};

#ifndef LIBCONF_BUILD
typedef struct LIBCONF_BUFFER
{
	union
	{
		void* data;
		char* chars;
		uint8_t* at;
	};
	size_t count;
	size_t capacity;
} LIBCONF_BUFFER;
#endif

LIBCONF_EXPORTABLE void  Libconf_Buffer_Kill(LIBCONF_BUFFER* bf);
LIBCONF_EXPORTABLE void  Libconf_Cstr_Kill(char* cstr);

LIBCONF_EXPORTABLE int   Libconf_Error_Occured(int clear);
LIBCONF_EXPORTABLE char* Libconf_Error_String(int clear);

LIBCONF_EXPORTABLE XVALUE* Xnode_Value(XNODE* node, C_CONST char* valtag, int create_if_dnt_exist);
LIBCONF_EXPORTABLE XVALUE* Xnode_First_Value(XNODE* node);
LIBCONF_EXPORTABLE XVALUE* Xnode_Next_Value(XNODE* node, XVALUE* value);
LIBCONF_EXPORTABLE LIBCONF_BUFFER* Xvalue_Get_Binary(XVALUE* val);
LIBCONF_EXPORTABLE int64_t Xvalue_Get_Int(XVALUE* val, int64_t dfltval);
LIBCONF_EXPORTABLE double  Xvalue_Get_Flt(XVALUE* val, double dfltval);

LIBCONF_EXPORTABLE void  Xvalue_Purge(XVALUE* val);
LIBCONF_EXPORTABLE char* Xvalue_Copy_Str(XVALUE* val, C_CONST char* dfltval);
LIBCONF_EXPORTABLE C_CONST char* Xvalue_Get_Str(XVALUE* val, C_CONST char* dfltval);
LIBCONF_EXPORTABLE int   Xvalue_Get_Bool(XVALUE* val, int dfltval);
LIBCONF_EXPORTABLE void  Xvalue_Set_Str(XVALUE* val, C_CONST char* str, int length);
LIBCONF_EXPORTABLE void  Xvalue_Set_Binary(XVALUE* val, void* data, int length);
LIBCONF_EXPORTABLE void  Xvalue_Set_Int(XVALUE* val, int64_t ival);
LIBCONF_EXPORTABLE void  Xvalue_Set_Flt(XVALUE* val, double fval);
LIBCONF_EXPORTABLE void  Xvalue_Set_Bool(XVALUE* val, int bval);
LIBCONF_EXPORTABLE int   Xvalue_Get_Kind(XVALUE* val);


LIBCONF_EXPORTABLE XDATA* Xdata_Init();
LIBCONF_EXPORTABLE void   Xdata_Addref(XDATA*);
LIBCONF_EXPORTABLE void   Xdata_Release(XDATA*);
LIBCONF_EXPORTABLE void   Xnode_Addref(XNODE*);
LIBCONF_EXPORTABLE void   Xnode_Release(XNODE*);

LIBCONF_EXPORTABLE XDATA* Xnode_Get_Xdata(XNODE* node);
LIBCONF_EXPORTABLE XNODE* Xdata_Get_Root(XDATA* xdata);
LIBCONF_EXPORTABLE char*  Xnode_Get_Tag(XNODE* node);
LIBCONF_EXPORTABLE int    Xnode_Tag_Is(XNODE* node, C_CONST char* tag);
LIBCONF_EXPORTABLE char*  Xnode_Value_Get_Tag(XNODE* node, XVALUE* value);

LIBCONF_EXPORTABLE XNODE* Xnode_Down(XNODE* node);
LIBCONF_EXPORTABLE XNODE* Xnode_Down_If(XNODE* node, C_CONST char* tag);
LIBCONF_EXPORTABLE XNODE* Xnode_Down_If_Named(XNODE* node, C_CONST char* named_of_tag);
LIBCONF_EXPORTABLE XNODE* Xnode_Down_Match(XNODE* node, C_CONST char* patt);

LIBCONF_EXPORTABLE XNODE* Xnode_Next(XNODE* node);
LIBCONF_EXPORTABLE XNODE* Xnode_Next_If(XNODE* node, C_CONST char* tag);
LIBCONF_EXPORTABLE XNODE* Xnode_Last(XNODE* node);
LIBCONF_EXPORTABLE int    Xnode_Count(XNODE* node);

LIBCONF_EXPORTABLE XNODE* Xnode_Append(XNODE* node, C_CONST char* tag);
LIBCONF_EXPORTABLE XNODE* Xnode_Append_Refnode(XNODE* node, C_CONST char* tag, XNODE* ref);
LIBCONF_EXPORTABLE XNODE* Xnode_Insert(XNODE* node, C_CONST char* tag);

LIBCONF_EXPORTABLE XVALUE* Xnode_Match_Value(XNODE* node, C_CONST char* patt);
LIBCONF_EXPORTABLE XVALUE* Xnode_Query_Value(XNODE* n, C_CONST char* query);
LIBCONF_EXPORTABLE XVALUE* Xnode_Deep_Value(XNODE* n, C_CONST char* query);
LIBCONF_EXPORTABLE XNODE*  Xnode_Query_Node(XNODE* n, C_CONST char* query);

LIBCONF_EXPORTABLE LIBCONF_BUFFER* Xnode_Format(XNODE* n, unsigned flags);

#ifdef __cplusplus
} /* extern "C" */
#endif /*__cplusplus*/

#endif /* C_once_97FCCED6_BE34_4DFF_B19B_63443F394EB1 */
