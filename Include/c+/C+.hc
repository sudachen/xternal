
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/

/*

If using GNU bintools:

Don't foget to use -rdynamic to see symbols in backtrace!

*/

#ifndef C_once_6973F3BA_26FA_434D_9ED9_FF5389CE421C
#define C_once_6973F3BA_26FA_434D_9ED9_FF5389CE421C
#define C_CORE_VERSION 1002

#ifdef _BUILTIN
#	define _C_CORE_BUILTIN
#endif

#if defined _MSC_VER && _MSC_VER > 1400
#	pragma warning(disable:4996) /*The POSIX name for this item is deprecated*/
#	pragma warning(disable:4204) /*nonstandard extension used*/
#	ifndef _CRT_SECURE_NO_WARNINGS
#		define _CRT_SECURE_NO_WARNINGS
#	endif
#endif

/* markers */
#define __Acquire /* a function acquires the ownership of argument */

#if defined _MSC_VER
#	define __No_Return __declspec(noreturn)
#elif defined __GNUC__
#	define __No_Return __attribute__((noreturn))
#else
#	define __No_Return
#endif

#if defined _MSC_VER
#	define __Inline  static __inline
#	define __No_Inline __declspec(noinline)
#elif defined __GNUC__ && __GNUC__ > 3
#	define __Inline  static inline
#	define __No_Inline __attributes__((noinline))
#elif defined __GNUC__
#	define __Inline  static
#	define __No_Inline __attributes__((noinline))
#else
#	define __Inline  static 
#	define __No_Inline
#endif

#if defined __GNUC__ || (defined _MSC_VER && _MSC_VER >= 1400)
#	define __has_va_args 1
#endif

#ifdef __has_va_args
#	define C_ARGS_COUNT_(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,...) a15
#	define C_ARGS_COUNT(...) C_EVAL(C_ARGS_COUNT_(__VA_ARGS__,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0))
#	define C_PARAMS(_Q,...) C_EVAL(C_CONCAT2(C_PARAM_,C_ARGS_COUNT(__VA_ARGS__))(_Q,__VA_ARGS__))
#endif

#define C_PARAM_1(_Q,a) _Q(a)
#define C_PARAM_2(_Q,b,a) _Q(b), _Q(a)
#define C_PARAM_3(_Q,c,b,a) _Q(c), C_PARAM_2(_Q,b,a)
#define C_PARAM_4(_Q,d,c,b,a) _Q(d), C_PARAM_3(_Q,c,b,a)
#define C_PARAM_5(_Q,e,d,c,b,a) _Q(e), C_PARAM_4(_Q,d,c,b,a)
#define C_PARAM_6(_Q,f,e,d,c,b,a) _Q(f), C_PARAM_5(_Q,e,d,c,b,a)
#define C_PARAM_7(_Q,g,f,e,d,c,b,a) _Q(g), C_PARAM_6(_Q,f,e,d,c,b,a)
#define C_PARAM_8(_Q,i,g,f,e,d,c,b,a) _Q(i), C_PARAM_7(_Q,g,f,e,d,c,b,a)
#define C_PARAM_9(_Q,j,i,g,f,e,d,c,b,a) _Q(j), C_PARAM_8(_Q,i,g,f,e,d,c,b,a)
#define C_PARAM_10(_Q,k,j,i,g,f,e,d,c,b,a) _Q(k), C_PARAM_9(_Q,j,i,g,f,e,d,c,b,a)

#define __FOUR_CHARS(C1,C2,C3,C4) C_FOUR_CHARS(C1,C2,C3,C4)
#define C_FOUR_CHARS(C1,C2,C3,C4) \
	(((uint_t)(C4)<<24)|((uint_t)(C3)<<16)|((uint_t)(C2)<<8)|((uint_t)(C1)))
#define __EIGHT_CHARS(C1,C2,C3,C4,C5,C6,C7,C8) C_EIGHT_CHARS(C1,C2,C3,C4,C5,C6,C7,C8)
#define C_EIGHT_CHARS(C1,C2,C3,C4,C5,C6,C7,C8) \
	((uquad_t)C_FOUR_CHARS(C1,C2,C3,C4)|((uquad_t)C_FOUR_CHARS(C5,C6,C7,C8)<<32))

#define C_EVAL(a) a
#define C_COMPOSE2(a,b)		a##b
#define C_COMPOSE3(a,b,c)	a##b##_##c
#define C_ID(Name,Line)		C_COMPOSE3(_YoC_Label_,Name,Line)
#define C_LOCAL_ID(Name)	C_ID(Name,__LINE__)
#define C_CONCAT2_(a,b)		C_COMPOSE2(a,b)
#define C_CONCAT2(a,b)		C_CONCAT2_(a,b)
#define C_CONSTSTR_(a)		#a
#define C_CONSTSTR(a)		C_CONSTSTR_(a)

#if defined __GNUC__ && ( __GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__>=6) )
#	define __Static_Assert_S(Expr,S) _Static_assert(Expr,S)
#elif !defined _MSC_VER || _MSC_VER < 1600 || defined __ICL
#	define __Static_Assert_S(Expr,S) \
	extern char C_LOCAL_ID(__assert__)[(Expr)?1:-1]
#else
#	define __Static_Assert_S(Expr,S) static_assert(Expr,S)
#endif

#define __Static_Assert(Expr) __Static_Assert_S(Expr,#Expr)

#if defined __linux__
#	define _GNU_SOURCE
#elif defined __NetBSD__
#	define _NETBSD_SOURCE
#elif defined __FreeBSD__
/* __BSD_VISIBLE defined by default! */
#endif

#if defined _HEAPINSPECTOR
#define malloc __Stdlib_malloc
#define calloc __Stdlib_calloc
#define free   __Stdlib_free
#define _msize __Msvc_memblock_size
#endif

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <setjmp.h>
#include <time.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include <limits.h>
#include <wctype.h>
#include <wchar.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <math.h>
#include <locale.h>

#if defined __i386 || defined __x86_64 || defined __arm__
#	define __little_endian
#endif

#if defined WIN32 || defined _WIN32 || defined _MSC_VER || defined __MINGW32_VERSION
#	define __windoze
#	if !defined __i386 && !defined __x86_64
#		ifdef _M_IX86
#			define __i386
#		elif defined _M_AMD64
#			define __x86_64
#           ifndef _AMD64_
#               define _AMD64_
#           endif
#		else
#			error "unknown processor"
#		endif
#	endif
#	if !defined _WINDOWS_
#		if !defined _X86_ && defined __i386
#			define _X86_ 1
#		endif
#	endif
#	if !defined WINVER
#		define WINVER 0x600
#	endif
#	if !defined _WIN32_WINNT
#		define _WIN32_WINNT 0x600
#	endif
#	define WIN32_LEAN_AND_MEAN
#	include <windef.h>
#	include <winbase.h>
#	include <excpt.h>
#	include <objbase.h>
#	include <io.h>
#	include <process.h>
#	include <malloc.h> /* alloca */
#	if defined _MSC_VER && _MSC_VER >= 1600
#		include <intrin.h>
#		pragma intrinsic(_ReadWriteBarrier)
#	elif defined _MSC_VER && _MSC_VER >= 1300
extern void _ReadWriteBarrier();
#		pragma intrinsic(_ReadWriteBarrier)
#	else
#		define _ReadWriteBarrier() ((void)0)
#	endif
#   define __WrBarrier() _ReadWriteBarrier()
#	ifdef _PTHREADS 
#		define _XTHREADS
#		ifdef __GNUC__
#			include <pthread.h>
#		else
#			include "system/winpthreads.hc" /* testing purposes only! */ 
#		endif
#	endif
#else
#	include <sys/time.h>
#	include <unistd.h>
#	include <dlfcn.h>
#	include <pthread.h>
#	if defined __APPLE__
#		include <malloc/malloc.h> /* malloc_size */
#	elif defined __NetBSD__ || defined __QNX__
#		define malloc_size(Ptr) (0)
#	else
#		define malloc_size(Ptr) malloc_usable_size(Ptr)
#	endif
#	define __RwBarrier() __asm__ __volatile__ ("" ::: "memory")
#endif

#if defined __APPLE__ || defined __linux__
#	include <execinfo.h> /* backtrace */
#elif defined __windoze
#	include <imagehlp.h>
#	define snprintf _snprintf
int backtrace( void **cbk, int count );
#elif defined __GNUC__
#	include <unwind.h>
int backtrace( void **cbk, int count );
#else
#	define backtrace(Cbk,Count) (0)
#endif

char *C_Btrace_Format(size_t frames, void **cbk, char *bt, size_t max_bt, size_t tabs);

#ifdef __windoze
#	define DECLSPEC_EXPORT __declspec(dllexport)
#else
#	define DECLSPEC_EXPORT
#endif

/* Only if x is one-byte symbol! */
#define Isspace(x)   isspace((byte_t)(x))
#define Isalpha(x)   isalpha((byte_t)(x))
#define Isalnum(x)   isalnum((byte_t)(x))
#define Isdigit(x)   isdigit((byte_t)(x))
#define Isxdigit(x)  isxdigit((byte_t)(x))
#define Toupper(x)   toupper((byte_t)(x))
#define Tolower(x)   tolower((byte_t)(x))

/* ATTENTION! int is always less then size_t! use it carefully */
#define iszof(x)     ((int)sizeof(x))
#define iszof_double ((int)sizeof(double))
#define iszof_long   ((int)sizeof(long))
#define iszof_wchar  ((int)sizeof(wchar_t))
#define iszof_arr(x) ((int)(sizeof(x)/sizeof(*x)))

typedef signed   char  ioct_t;
typedef unsigned char  byte_t;

typedef unsigned short ushort_t;
typedef unsigned short uhalf_t; /* 16 bit unsigned ( half word )*/
typedef short          half_t;  /* 16 bit signed ( half word )  */

typedef unsigned int   uint_t;
typedef unsigned int   udword_t; /* 32 bit unsigned ( i386 word ) */
typedef int            dword_t;  /* 32 bit signed ( i386 word )   */

typedef unsigned long  ulong_t;

#if !defined __windoze || defined __x86_64 
typedef unsigned long long  uquad_t; /* 64-bit unsigned ( double word ) historically named as quad word */
#	if !defined __APPLE__ && !defined __linux__
typedef long long  quad_t; /* 64-bit signed word ( double word ) */
#	endif
#else
typedef unsigned __int64  uquad_t;
typedef __int64	quad_t;
#endif

/* widelong_t is register equal unsigned type, value can be 32 or 64 bit, depends on platform */
#if defined __x86_64 && !defined _WIDELONG_IS_LONG
typedef uquad_t	uwidelong_t;
typedef quad_t	widelong_t;
#else
typedef ulong_t	uwidelong_t;
typedef long	widelong_t;
#endif

/* uhalflong_t is half of widelong_t value can be 16 or 32 bit, depends on platform */
#if defined __x86_64 && !defined _WIDELONG_IS_LONG
typedef uint_t	 uhalflong_t;  
typedef int		 halflong_t;  
#else
typedef ushort_t uhalflong_t;
typedef short	 halflong_t;
#endif

__Static_Assert( sizeof(halflong_t) == sizeof(widelong_t)/2 );
__Static_Assert( sizeof(uhalflong_t) == sizeof(uwidelong_t)/2 );

/* uptrword_t is unsigned integer value enough to store pointer value */
#if defined __x86_64 && defined __windoze
typedef uquad_t  uptrword_t;
typedef quad_t   ptrword_t;
#else
typedef ulong_t  uptrword_t;
typedef long     ptrword_t;
#endif

__Static_Assert( sizeof(ptrword_t) >= sizeof(void*) );
__Static_Assert( sizeof(uptrword_t) >= sizeof(void*) );

#define __Offset_Of(T,Memb) ((ptrword_t)(&((T*)0)->Memb))
#define __Length_Of(X) (iszof(X)/iszof(X[0]))
#define __To_Ptr(Val) ((void*)((uptrword_t)(Val)))
#define __Ptr_Word(Ptr) ((uptrword_t)(Ptr))

/* size readable aliases */
typedef uhalf_t		u16_t;
typedef udword_t	u32_t;
typedef uquad_t		u64_t;
typedef half_t		i16_t;
typedef dword_t		i32_t;
typedef quad_t		i64_t;

#ifdef __windoze
#	define _WINPOSIX(W,F) W
#else
#	define _WINPOSIX(W,F) F
#endif

#ifndef _NO__FILE__
#	define __C_FILE__ __FILE__
#	define __C_Expr__(Expr) #Expr
#	define C_Raise(Error,Msg,File,Line) _C_Raise(Error,Msg,File,Line)
#	define C_Fatal(Error,Msg,File,Line) _C_Fatal(Error,Msg,File,Line)
#else
#	define __C_FILE__ 0
#	define __C_Expr__(Expr) 0
#	define C_Raise(Error,Msg,File,Line) _C_Raise(Error,Msg,0,0)
#	define C_Fatal(Error,Msg,File,Line) _C_Fatal(Error,Msg,0,0)
#endif

#define __Gogo \
	if ( 1 ) goto C_LOCAL_ID(__gogo); \
	else C_LOCAL_ID(__gogo):

#ifdef _C_CORE_BUILTIN
#	define _C_CORE_BUILTIN_CODE(Code) Code
#	define _C_CORE_EXTERN
#else
#	define _C_CORE_BUILTIN_CODE(Code)
#	define _C_CORE_EXTERN extern
#endif

#define C_MIN(a,b) ( (a) < (b) ? (a) : (b) )
#define C_MAX(a,b) ( (a) > (b) ? (a) : (b) )
#define C_ABS(a) ( (a) > 0 ? (a) : -(a) ) /* a > 0  does not produce warning on unsigned types */
#define C_ALIGNU(a,n) ( ((a) + ((n) - 1))&~((n) - 1) )

#define C_REPN_2(Val)   Val,Val
#define C_REPN_4(Val)   C_REPN_2(Val),C_REPN_2(Val)
#define C_REPN_8(Val)   C_REPN_4(Val),C_REPN_4(Val)
#define C_REPN_16(Val)  C_REPN_8(Val),C_REPN_8(Val)
#define C_REPN_32(Val)  C_REPN_16(Val),C_REPN_16(Val)
#define C_REPN_64(Val)  C_REPN_32(Val),C_REPN_32(Val)
#define C_REPN_128(Val) C_REPN_64(Val),C_REPN_64(Val)
#define C32_BIT(No)     (1U<<No)
#define C64_BIT(No)     (1ULL<<No)

enum
{
	KILOBYTE = 1024,
	MEGABYTE = 1024*KILOBYTE,
	GIGABYTE = 1024*MEGABYTE,
};

enum _C_ERRORS
{
	C_FATAL_ERROR_GROUP         = 0x70000000,
	C_USER_ERROR_GROUP          = 0x00010000,
	C_IO_ERROR_GROUP            = 0x00020000,
	//C_TCPIP_ERROR_GROUP          = 0x00040000,
	C_RUNTIME_ERROR_GROUP       = 0x00080000,
	C_SELFCHECK_ERROR_GROUP     = 0x00100000,
	C_ENCODING_ERROR_GROUP      = 0x00200000,
	C_ILLFORMED_ERROR_GROUP     = 0x00400000,
	C_RANGE_ERROR_GROUP         = 0x00800000,
	C_CORRUPTED_ERROR_GROUP     = 0x01000000,
	C_STORAGE_ERROR_GROUP       = 0x02000000,
	//C_SYSTEM_ERROR_GROUP         = 0x04000000,

	C_XXXX_ERROR_GROUP          = 0x7fff0000,
	C_RERAISE_CURRENT_ERROR     = 0x7fff7fff,

	C_TRACED_ERROR_GROUP        = C_FATAL_ERROR_GROUP
	|C_RANGE_ERROR_GROUP
	|C_SELFCHECK_ERROR_GROUP,

	C_ERROR_BASE                = 0x00008000,
	C_ERROR_USER                = C_USER_ERROR_GROUP|0,

	C_ERROR_OUT_OF_MEMORY		= C_FATAL_ERROR_GROUP|(C_ERROR_BASE+1),
	C_FATAL_ERROR				= C_FATAL_ERROR_GROUP|(C_ERROR_BASE+2),
	C_ERROR_DYNCO_CORRUPTED		= C_FATAL_ERROR_GROUP|(C_ERROR_BASE+3),
	C_ERROR_METHOD_NOT_FOUND	= C_RUNTIME_ERROR_GROUP|(C_ERROR_BASE+4),
	C_ERROR_REQUIRE_FAILED		= C_FATAL_ERROR_GROUP|(C_ERROR_BASE+5),
	C_ERROR_ILLFORMED			= C_ILLFORMED_ERROR_GROUP|(C_ERROR_BASE+6),
	C_ERROR_OUT_OF_POOL			= C_FATAL_ERROR_GROUP|(C_ERROR_BASE+7),
	C_ERROR_UNEXPECTED			= C_FATAL_ERROR_GROUP|(C_ERROR_BASE+8),
	C_ERROR_OUT_OF_RANGE		= C_RANGE_ERROR_GROUP|(C_ERROR_BASE+9),
	C_ERROR_NULL_PTR			= C_FATAL_ERROR_GROUP|(C_ERROR_BASE+10),
	C_ERROR_CORRUPTED			= C_CORRUPTED_ERROR_GROUP|(C_ERROR_BASE+11),
	C_ERROR_IO					= C_IO_ERROR_GROUP|(C_ERROR_BASE+12),
	C_ERROR_UNSORTABLE			= C_RUNTIME_ERROR_GROUP|(C_ERROR_BASE+13),
	C_ERROR_DOESNT_EXIST		= C_IO_ERROR_GROUP|(C_ERROR_BASE+14),
	C_ERROR_DSNT_EXIST			= C_ERROR_DOESNT_EXIST,
	C_ERROR_ACCESS_DENAIED		= C_IO_ERROR_GROUP|(C_ERROR_BASE+15),
	C_ERROR_NO_ENOUGH			= C_ILLFORMED_ERROR_GROUP|(C_ERROR_BASE+16),
	C_ERROR_UNALIGNED			= C_ILLFORMED_ERROR_GROUP|(C_ERROR_BASE+17),
	C_ERROR_COMPRESS_DATA		= C_ENCODING_ERROR_GROUP|(C_ERROR_BASE+18),
	C_ERROR_ENCRYPT_DATA		= C_ENCODING_ERROR_GROUP|(C_ERROR_BASE+19),
	C_ERROR_DECOMPRESS_DATA		= C_ENCODING_ERROR_GROUP|(C_ERROR_BASE+20),
	C_ERROR_DECRYPT_DATA		= C_ENCODING_ERROR_GROUP|(C_ERROR_BASE+21),
	C_ERROR_INVALID_PARAM		= C_RUNTIME_ERROR_GROUP|(C_ERROR_BASE+22),
	C_ERROR_UNEXPECTED_VALUE	= C_FATAL_ERROR_GROUP|(C_ERROR_BASE+23),
	C_ERROR_ALREADY_EXISTS		= C_STORAGE_ERROR_GROUP|C_IO_ERROR_GROUP|(C_ERROR_BASE+24),
	C_ERROR_INCONSISTENT		= C_STORAGE_ERROR_GROUP|(C_ERROR_BASE+25),
	C_ERROR_TO_BIG				= C_STORAGE_ERROR_GROUP|(C_ERROR_BASE+26),
	C_ERROR_ZERODIVIDE			= C_FATAL_ERROR_GROUP|(C_ERROR_BASE+27),
	C_ERROR_LIMIT_REACHED		= C_RUNTIME_ERROR_GROUP|(C_ERROR_BASE+28),
	C_ERROR_UNSUPPORTED			= C_RUNTIME_ERROR_GROUP|(C_ERROR_BASE+29),
	C_ERROR_IO_EOF				= C_IO_ERROR_GROUP|(C_ERROR_BASE+30),
	C_ERROR_DNS					= C_IO_ERROR_GROUP|(C_ERROR_BASE+31),
	C_ERROR_SUBSYSTEM_INIT		= C_RUNTIME_ERROR_GROUP|(C_ERROR_BASE+32),
	C_ERROR_SYSTEM				= C_RUNTIME_ERROR_GROUP|(C_ERROR_BASE+33),
	C_ERROR_SYNTAX				= C_ILLFORMED_ERROR_GROUP|(C_ERROR_BASE+34),
	C_ERROR_TESUITE_FAIL		= C_SELFCHECK_ERROR_GROUP|(C_ERROR_BASE+35),
	C_ERROR_ASSERT_FAIL			= C_SELFCHECK_ERROR_GROUP|(C_ERROR_BASE+36),
	C_ERROR_CONSTANT_NOT_FOUND	= C_RUNTIME_ERROR_GROUP|(C_ERROR_BASE+37),
	C_ERROR_FRAGMENTED			= C_STORAGE_ERROR_GROUP|(C_ERROR_BASE+38),
	C_ERROR_NO_ENOUGH_SPACE		= C_STORAGE_ERROR_GROUP|(C_ERROR_BASE+39),
	C_ERROR_VERIFY				= C_RUNTIME_ERROR_GROUP|(C_ERROR_BASE+40),
	C_ERROR_ISNT_OBJECT			= C_RUNTIME_ERROR_GROUP|(C_ERROR_BASE+41),
};

#define C_ERROR_IS_USER_ERROR(err) !(err&C_XXXX_ERROR_GROUP)

enum _C_FLAGS
{
	C_RAISE_ERROR            = 0x70000000,
};

__No_Return void _C_Fatal(int err,void *ctx,char *filename,int lineno);
__No_Return void _C_Raise(int err,char *msg,char *filename,int lineno);

/* Interlock atomic operations */

#ifdef __windoze
#	define Switch_to_Thread() SwitchToThread()
#else
#	define Switch_to_Thread() pthread_yield()
#	define Sleep(Ms) usleep((Ms)*1000)
#endif

#if defined __GNUC__
#	define __RwBarrier() __asm__ __volatile__ ("" ::: "memory")
#	define Atomic_Increment(Ptr) __sync_add_and_fetch((i32_t volatile *)Ptr,1)
#	define Atomic_Decrement(Ptr) __sync_sub_and_fetch((i32_t volatile *)Ptr,1)
#	define Atomic_CmpXchg(Ptr,Val,Comp) __sync_bool_compare_and_swap((u32_t *volatile)Ptr,(u32_t)Comp,(u32_t)Val)
#	define Atomic_CmpXchg_Ptr(Ptr,Val,Comp) __sync_bool_compare_and_swap((void *volatile*)Ptr,(void*)Comp,(void*)Val)
#elif defined _MSC_VER 
#	define __RwBarrier() _ReadWriteBarrier()
#	define Atomic_Increment(Ptr) InterlockedIncrement(Ptr)
#	define Atomic_Decrement(Ptr) InterlockedDecrement(Ptr)
#	define Atomic_CmpXchg(Ptr,Val,Comp) (InterlockedCompareExchange(Ptr,Val,Comp) == (Comp))
#	define Atomic_CmpXchg_Ptr(Ptr,Val,Comp) (InterlockedCompareExchangePointer(Ptr,Val,Comp) == (Comp))
#endif 

#define __Interlock_Opt(Decl,Lx,Lock,Unlock,Unlock_Proc) \
	switch ( 0 ) while ( 1 ) \
		if ( 1 ) \
			goto C_LOCAL_ID(Do_Unlock); \
		else if ( 1 ) \
			case 0: \
			{ \
				Decl;\
				Lock(Lx); \
				C_JmpBuf_Push_Cs(Lx,(C_JMPBUF_Unlock)Unlock_Proc); \
				goto C_LOCAL_ID(Do_Code); \
				C_LOCAL_ID(Do_Unlock): \
				C_JmpBuf_Pop_Cs(Lx); \
				Unlock(Lx); \
				break; \
			} \
		else \
			C_LOCAL_ID(Do_Code):

#ifndef _THREADS

#	define __Atomic_Increment(Ptr) (++*(Ptr))
#	define __Atomic_Decrement(Ptr) (--*(Ptr))
#	define __Atomic_CmpXchg(Ptr,Val,Comp) ( *(Ptr) == (Comp) ? (*(Ptr) = (Val), 1) : 0 )
#	define __Atomic_CmpXchg_Ptr(Ptr,Val,Comp) ( *(Ptr) == (Comp) ? (*(Ptr) = (Val), 1) : 0 )
#	define IF_MULTITHREADED(Expr)
#	define __Xchg_Interlock if (0) {;} else
#	define __Xchg_Sync(Lx)  if (0) {;} else
#	define C_Wait_Xchg_Lock(Ptr)
#	define C_Xchg_Unlock(Ptr)

#else /* -D _THREADS */

#	define __Atomic_Increment(Ptr) Atomic_Increment(Ptr)
#	define __Atomic_Decrement(Ptr) Atomic_Decrement(Ptr)
#	define __Atomic_CmpXchg(Ptr,Val,Comp) Atomic_CmpXchg(Ptr,Val,Comp)
#	define __Atomic_CmpXchg_Ptr(Ptr,Val,Comp) Atomic_CmpXchg_Ptr(Ptr,Val,Comp)

#	define IF_MULTITHREADED(Expr) Expr

#	define _xchg_C_LOCAL_LX static int C_LOCAL_ID(lx)
#	define _xchg_C_LOCAL_ID_REF &C_LOCAL_ID(lx)
#	define __Xchg_Interlock \
	__Interlock_Opt( _xchg_C_LOCAL_LX, _xchg_C_LOCAL_ID_REF, \
	C_Wait_Xchg_Lock,C_Xchg_Unlock,C_Xchg_Unlock_Proc)

#	define __Xchg_Sync(Lx) \
	__Interlock_Opt(((void)0),Lx, \
	C_Wait_Xchg_Lock,C_Xchg_Unlock,C_Xchg_Unlock_Proc)

#	define C_Wait_Xchg_Lock(Ptr) while ( !Atomic_CmpXchg(Ptr,1,0) ) Switch_to_Thread()
#	define C_Xchg_Unlock(Ptr) Atomic_CmpXchg(Ptr,0,1)
void C_Xchg_Unlock_Proc(int volatile *p) _C_CORE_BUILTIN_CODE({Atomic_CmpXchg(p,0,1);});

#endif /* _THREADS */

#if defined _HEAPINSPECTOR
#	include "inspector.hc"
#endif

#include "csup/tls.hc"

#define __REQUIRE_FATAL(Expr) C_Fatal(C_ERROR_REQUIRE_FAILED,__C_Expr__(Expr),__C_FILE__,__LINE__)
#define PANICA(msg) C_Fatal(C_FATAL_ERROR,msg,__C_FILE__,__LINE__)
#define UNREACHABLE PANICA("unreachable code")

#if defined __GNUC__ && ( __GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__>=5) )
#	define ASSUME(Expr)  if (Expr); else __builtin_unreachable();
#	define REQUIRE(Expr) if (Expr); else { __REQUIRE_FATAL(Expr); __builtin_unreachable(); }
#elif defined _MSC_VER
#	define ASSUME(expr)  __assume(expr)
#	define REQUIRE(Expr) if (Expr); else { __REQUIRE_FATAL(Expr); __assume(0); }
#else 
#	define ASSUME(expr)  ((void)0)
#	define REQUIRE(Expr) if (Expr); else __REQUIRE_FATAL(Expr)
#endif

#ifdef _STRICT
#	define STRICT_REQUIRE(Expr) REQUIRE(Expr)
#	define STRICT_CHECK(Expr) (Expr)
#	define STRICT_UNREACHABLE UNREACHABLE
#	define STRICT_ASSUME(Expr) REQUIRE(Expr)
#else
#	define STRICT_REQUIRE(Expr) ((void)0)
#	define STRICT_CHECK(Expr) (1)
#	define STRICT_UNREACHABLE ASSUME(0);
#	define STRICT_ASSUME(Expr) ASSUME(Expr)
#endif /* _STRICT */

enum 
{ 
	C_OBJECT_SIGNATURE_PFX  =  0x00594f59, /*'YOY'*/  
	C_OBJECT_SIGNATURE_HEAP =  0x4f594f59, /*'YOYO'*/  
	C_MEMPOOL_PIECE_MAXSIZE = 1*KILOBYTE,
	C_MEMPOOL_PIECE_ON_BLOCK= 16,
	C_MEMPOOL_PIECE_STEP    = 64,
	C_MEMPOOL_SLOTS_COUNT   = C_MEMPOOL_PIECE_MAXSIZE/C_MEMPOOL_PIECE_STEP,
};

__Static_Assert(C_MEMPOOL_SLOTS_COUNT <= 'O');

#include "csup/algo.hc"

#ifdef __windoze
size_t malloc_size(void *p) _C_CORE_BUILTIN_CODE({return _msize(p);});
#endif /* __windoze */

void *__Pool_Ptr(void *ptr,void *cleanup);
void *__Refresh_Ptr(void *old,void *new,void *cleaner);

void *__Malloc_Npl(int size)
#ifdef _C_CORE_BUILTIN
{
	void *p;
	STRICT_REQUIRE(size >= 0);
	p = malloc(size);
	if ( !p )
		C_Fatal(C_ERROR_OUT_OF_MEMORY,0,0,0);
	return p;
}
#endif
;

void *__Realloc_Npl(void *p,int size)
#ifdef _C_CORE_BUILTIN
{
	STRICT_REQUIRE(size >= 0);
	p = realloc(p,size);
	if ( !p )
		C_Fatal(C_ERROR_OUT_OF_MEMORY,0,0,0);
	return p;
}
#endif
;

void *__Zero_Malloc_Npl(int size)
#ifdef _C_CORE_BUILTIN
{
	void *p = __Malloc_Npl(size);
	memset(p,0,size);
	return p;
}
#endif
;

void *__Resize_Npl(void *p,int size,int granularity)
#ifdef _C_CORE_BUILTIN
{
	int capacity = p?malloc_size(p):0;
	STRICT_REQUIRE(size >= 0);
	if ( !p || capacity < size )
	{
		if ( !granularity )
			capacity = Min_Pow2(size);
		else if ( granularity > 1 )
		{
			capacity = size+granularity-1;
			capacity -= capacity % granularity;
		}
		else
			capacity = size;
		p = realloc(p,capacity);
		if ( !p )
			C_Fatal(C_ERROR_OUT_OF_MEMORY,0,0,0);
	}
	return p;
}
#endif
;

void *__Memcopy_Npl(void *src,int size)
#ifdef _C_CORE_BUILTIN
{
	void *p;
	STRICT_REQUIRE(size >= 0);
	p = malloc(size);
	if ( !p )
		C_Fatal(C_ERROR_OUT_OF_MEMORY,0,0,0);
	memcpy(p,src,size);
	return p;
}
#endif
;

__Inline void __Free(void *p)
{
	free(p);
}

__Inline void *__Zero_Malloc(unsigned size)
{
	return __Pool_Ptr(__Zero_Malloc_Npl(size),0);
}

__Inline void *__Malloc(unsigned size)
{
	return __Pool_Ptr(__Malloc_Npl(size),0);
}

__Inline void *__Realloc(void *p,unsigned size)
{
	return __Refresh_Ptr(p,__Realloc_Npl(p,size),0);
}

__Inline void *__Memcopy(void *p,unsigned size)
{
	return __Pool_Ptr(__Memcopy_Npl(p,size),0);
}

void *__Resize(void *p,unsigned size,int granularity)
#ifdef _C_CORE_BUILTIN
{
	void *q = __Resize_Npl(p,size,granularity);
	if ( p && q != p )
		__Refresh_Ptr(p,q,0);
	else if ( !p )
		__Pool_Ptr(q,0);
	return q;
}
#endif
;

#include "csup/csupport.hc"
#include "csup/object.hc"
#include "csup/bector.hc"

void C_Global_Cleanup()
#ifdef _C_CORE_BUILTIN
{
	C_Mempool_Cleanup();
}
#endif
;

#endif /* C_once_6973F3BA_26FA_434D_9ED9_FF5389CE421C */

