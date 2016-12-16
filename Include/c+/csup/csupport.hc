
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

C extended

__Try, __Catch, __Try_Except ,__Except, __Try_Abort, __Try_Exit
__Auto_Release, __Auto_Ptr, __Retain, __Refresh, __Release 

it is included by C+.hc

*/

#ifdef __windoze
#include <Psapi.h>
#pragma comment(lib,"Psapi.lib")
#pragma comment(lib,"Dbghelp.lib")
#endif

#define __try 1___SEH_try_is_disabled___1
#define __except 1___SEH_except_is_disabled___1

#define RAISE_IF_FAILED(Error, Expr) \
	if ( !(Expr) ) C_Raise(Error,#Expr,__C_FILE__,__LINE__)

#define __Verify(Expr)			RAISE_IF_FAILED(C_ERROR_VERIFY, Expr)
#define __Verify_0(Expr)		RAISE_IF_FAILED(C_ERROR_VERIFY,(Expr) == 0)
#define __Verify_Not_0(Expr)	RAISE_IF_FAILED(C_ERROR_NULL_PTR,(Expr)!= 0)

#define __Verify_Range(Expr,Left,Right) /* Expr in [left,right) */ \
	RAISE_IF_FAILED(C_ERROR_OUT_OF_RANGE, \
	(Left) <= (Expr) && (Expr) < (Right))

#define __Require(Expr)			REQUIRE(Expr)
#define __Strict(Expr)			STRICT_REQUIRE(Expr)
#define __Strict_Unreachable()  STRICT_UNREACHABLE

#define __Error_Code            (C_Error_Code())
#define __Error_Message         (C_Error_Message())
#define __Error_File            (C_Error_File())
#define __Error_Line            (C_Error_Line())

#ifdef __has_va_args
#define __Sformat(Fmt,...) C_Safe_Format(Fmt,C_ARGS_COUNT(__VA_ARGS__),C_PARAMS(__quoted_format_argument__,__VA_ARGS__))
#define __Raise_Sformat(Err,Fmt,...) C_Raise(Err,C_Safe_Format(Fmt,C_ARGS_COUNT(__VA_ARGS__),C_PARAMS(__quoted_format_argument__,__VA_ARGS__)),__C_FILE__,__LINE__)
#define __Fatal_Sformat(Fmt,...) C_Fatal(C_FATAL_ERROR,C_Safe_Format(Fmt,C_ARGS_COUNT(__VA_ARGS__),C_PARAMS(__quoted_format_argument__,__VA_ARGS__)),__C_FILE__,__LINE__)
#endif

#define __Sformat1(Fmt,a) C_Safe_Format(Fmt,1,C_PARAM_1(__quoted_format_argument__,a))
#define __Raise_Sformat1(Err,Fmt,a) C_Raise(Err,__Sformat1(Fmt,a),__FILE__,__LINE__)
#define __Fatal_Sformat1(Fmt,a) C_Fatal(C_FATAL_ERROR,__Sformat1(Fmt,a),__FILE__,__LINE__)
#define __Sformat2(Fmt,a,b) C_Safe_Format(Fmt,2,C_PARAM_2(__quoted_format_argument__,a,b))
#define __Raise_Sformat2(Err,Fmt,a,b) C_Raise(Err,__Sformat2(Fmt,a,b),__FILE__,__LINE__)
#define __Fatal_Sformat2(Fmt,a,b) C_Fatal(C_FATAL_ERROR,__Sformat2(Fmt,a,b),__FILE__,__LINE__)
#define __Sformat3(Fmt,a,b,c) C_Safe_Format(Fmt,3,C_PARAM_3(__quoted_format_argument__,a,b,c))
#define __Raise_Sformat3(Err,Fmt,a,b,c) C_Raise(Err,__Sformat3(Fmt,a,b,c),__FILE__,__LINE__)
#define __Fatal_Sformat3(Fmt,a,b,c) C_Fatal(C_FATAL_ERROR,__Sformat3(Fmt,a,b,c),__FILE__,__LINE__)
#define __Sformat4(Fmt,a,b,c,d) C_Safe_Format(Fmt,4,C_PARAM_4(__quoted_format_argument__,a,b,c,d))
#define __Raise_Sformat4(Err,Fmt,a,b,c,d) C_Raise(Err,__Sformat4(Fmt,a,b,c,d),__FILE__,__LINE__)
#define __Fatal_Sformat4(Fmt,a,b,c,d) C_Fatal(C_FATAL_ERROR,__Sformat4(Fmt,a,b,c,d),__FILE__,__LINE__)
#define __Sformat5(Fmt,a,b,c,d,e) C_Safe_Format(Fmt,5,C_PARAM_5(__quoted_format_argument__,a,b,c,d,e))
#define __Raise_Sformat5(Err,Fmt,a,b,c,d,e) C_Raise(Err,__Sformat5(Fmt,a,b,c,d,e),__FILE__,__LINE__)
#define __Fatal_Sformat5(Fmt,a,b,c,d,e) C_Fatal(C_FATAL_ERROR,__Sformat5(Fmt,a,b,c,d,e),__FILE__,__LINE__)

#define __Try_Ptr(Ptr) \
	switch (setjmp(C_Push_JmpBuf()->b)) if (1) { \
	void *__Cplus__try_ptr_Ptr; \
	case 0: \
	__Cplus__try_ptr_Ptr = Ptr; {

#define __Except \
	} C_Cleanup_JmpBuf(__Cplus__try_ptr_Ptr); } \
	else default:    

#define __Catch(e) \
	} C_Cleanup_JmpBuf(__Cplus__try_ptr_Ptr); } \
	else if (1) default: C_Raise(C_RERAISE_CURRENT_ERROR,0,0,0); \
	else case e:    

#define __Auto   __Auto_Ptr(0)
#define __Try    __Try_Ptr(0)

#define __Safe_Prolog_Epilog(Prolog,Epilog)  \
	switch ( setjmp(C_Push_JmpBuf()->b) ) \
	if (1) /* guards exception way */ while (1) \
	if (1) /* on second while's step if executed without errors */ \
		{ Epilog; C_Pop_JmpBuf(); break; } \
	  else if (1) /* if unexpected */ \
		{ Epilog; __Raise_Occured(); } \
	  else /* there is protected code */ \
	  /* switch jumps to here */ \
	case 0: if (1) { Prolog; goto C_LOCAL_ID(ap_Body); } else \
	C_LOCAL_ID(ap_Body):

#define __Enter_Once(Flag) if ( Flag ); else __Safe_Prolog_Epilog(Flag=1,Flag=0)

#define __Release(Pooled)  ((void)__Unpool((Pooled),1))
#define __Retain(Pooled)   __Unpool((Pooled),0)
#define __Refresh(Old,New) __Refresh_Ptr(Old,New,0)
#define __Pool(Ptr)        __Pool_Ptr(Ptr,0)
#define __Pool_RefPtr(Ptr) __Pool_Ptr(Ptr,__Unrefe)

#define __Auto_Release \
	switch ( 0 ) /* jumps to `case 0:`in while loop body */ while ( 1 ) \
	if ( 1 ) /* on secon while's step if executed without errors */ \
	{ \
		int C_LOCAL_ID(breaker); \
		__Pool_Truncate(C_LOCAL_ID(breaker),0); \
		break; \
	case 0: \
		C_LOCAL_ID(breaker) = __Pool_Breaker(); \
		goto C_LOCAL_ID(body);\
	} \
	else \
		C_LOCAL_ID(body):
/* first while's step continues here */

#define __Auto_Ptr(Ptr) \
	switch ( 0 ) /* jumps to `case 0:`in while loop body */ while ( 1 ) \
	if ( 1 ) /* on secon while's step if executed without errors */ \
	{ \
		int C_LOCAL_ID(breaker); \
		__Pool_Truncate(C_LOCAL_ID(breaker),Ptr); \
		break; \
	case 0: \
		C_LOCAL_ID(breaker) = __Pool_Breaker(); \
		goto C_LOCAL_ID(body);\
	} \
	else \
		C_LOCAL_ID(body): \
	/* first while's step continues here */

#define __Try_Exit __Try_Specific(default: Error_Exit(__Error_Code)) __Auto
//#define __Try_Except __Try_Specific((void)0)
//#define __Try_Abort __Try_Specific(default: Error_Abort())

#define __Try_Specific(What)  \
	switch ( setjmp(C_Push_JmpBuf()->b) ) \
	if (1) /* guards exception way */ while (1) \
	if (1) /* on second while's step if executed without errors */ \
		{ C_Pop_JmpBuf(); break; } \
	  else if (1) /* if unexpected */ \
		{ /* default: */ What; } \
	  else /* there is protected code */ \
	  /* switch jumps to here */ \
	case 0:

//#define __Catch(Code) \
//    else if (0) /* else branch of guards if */ \
//      case (Code):

//#define __Except /* using with __Try_Except */ \
//    else /* else branch of guards if */ \
//      default:

typedef void (*pool_cleanup_t)(void*); 
typedef struct _C_AUTORELEASE
{
	void *ptr;
	pool_cleanup_t cleanup;
}
C_AUTORELEASE;

enum { C_MAX_ERROR_BTRACE = 25 };

typedef struct _C_ERROR_INFO
{
	char *msg;
	char *filename;
	int  code;
	int  lineno;
	int  bt_count;
	void *bt_cbk[C_MAX_ERROR_BTRACE];
} C_ERROR_INFO;

enum { C_MAX_CS_COUNT = 7 };
enum { C_INI_JB_COUNT = 5 };
enum { C_EXT_JB_COUNT = 3 };
enum { C_INI_POOL_COUNT = 256 };
enum { C_EXT_POOL_COUNT = 128 };

typedef void (*C_JMPBUF_Unlock)(void *);
void C_JmpBuf_Push_Cs(void *cs,C_JMPBUF_Unlock unlock);
void C_JmpBuf_Pop_Cs(void *cs);
extern void C_Print_Line(char *text);
#define __Raise_Occured() _C_Raise(C_RERAISE_CURRENT_ERROR,0,0,0)
__No_Return void _C_Raise(int err,char *msg,char *filename,int lineno);
__No_Return void C_Abort(char *msg);
__No_Return void C_Btrace_N_Abort(char *prefix, char *msg, char *filename, int lineno);
int backtrace( void **cbk, int count );

typedef struct _C_JMPBUF_LOCK
{
	void *cs;
	C_JMPBUF_Unlock unlock;
} C_JMPBUF_LOCK;

typedef struct _C_JMPBUF
{
	jmp_buf b;
	C_JMPBUF_LOCK locks[C_MAX_CS_COUNT];
	int auto_top;
} C_JMPBUF;

typedef struct _C_SUPPORT_INFO
{
	int auto_count;
	int auto_top;
	int jb_count;
	int jb_top;
	struct
	{
		unsigned unwinding: 1;
	} stats;
	C_ERROR_INFO err;
	C_AUTORELEASE *auto_pool;
	C_JMPBUF jb[C_INI_JB_COUNT];
} C_SUPPORT_INFO;

#ifdef _C_CORE_BUILTIN
__Tls_Define(__Csup_Nfo_Tls);
#else
__Tls_Declare(__Csup_Nfo_Tls);
#endif

#if defined _MSC_VER && _MSC_VER < 1300
#  define __VSCPRINTF
#endif

#if defined _C_CORE_BUILTIN && defined __windoze && defined __VSCPRINTF
int _vscprintf(char *fmt,va_list va)
{
	static char simulate[4096*4] = {0};
	return vsprintf(simulate,fmt,va);
}
#endif

int C_Detect_Required_Buffer_Size(char *fmt,va_list va)
#ifdef _C_CORE_BUILTIN
{
#ifdef __windoze
	return _vscprintf(fmt,va)+1;
#else
	va_list qva;
	va_copy(qva,va);
	return vsnprintf(0,0,fmt,qva)+1;
#endif
}
#endif
;

char *C_Format_(char *fmt,va_list va)
#ifdef _C_CORE_BUILTIN
{
	int rq_len = C_Detect_Required_Buffer_Size(fmt,va);
	char *b = __Malloc_Npl(rq_len);
#ifdef __windoze
	_vsnprintf(b,rq_len,fmt,va);
#else
	vsnprintf(b,rq_len,fmt,va);
#endif
	return b;
}
#endif
;

char *C_Format_Npl(char *fmt,...)
	_C_CORE_BUILTIN_CODE({va_list va;char *t; va_start(va,fmt); t = C_Format_(fmt,va);va_end(va); return t;});

char *C_Format(char *fmt,...)
	_C_CORE_BUILTIN_CODE({va_list va;char *t; va_start(va,fmt); t = __Pool(C_Format_(fmt,va));va_end(va); return t;});

C_SUPPORT_INFO *__Acquire_Csup_Nfo()
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo = __Malloc_Npl(sizeof(C_SUPPORT_INFO));
	memset(nfo,0,sizeof(*nfo));
	nfo->jb_count = sizeof(nfo->jb)/sizeof(nfo->jb[0]);
	nfo->jb_top = -1;
	nfo->auto_pool = __Malloc_Npl(sizeof(*nfo->auto_pool)*C_INI_POOL_COUNT);
	nfo->auto_count = C_INI_POOL_COUNT;
	nfo->auto_top = -1;
	__Tls_Set(__Csup_Nfo_Tls,nfo);
	return nfo;
}
#endif
;

C_SUPPORT_INFO *__Support_Nfo()
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo = __Tls_Get(__Csup_Nfo_Tls);
	if ( !nfo ) nfo = __Acquire_Csup_Nfo();
	return nfo;
}
#endif
;

C_SUPPORT_INFO *__Extend_Csup_JmpBuf()
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo = __Tls_Get(__Csup_Nfo_Tls);
	nfo = __Realloc_Npl(nfo,sizeof(C_SUPPORT_INFO)
		+ (nfo->jb_count - C_INI_JB_COUNT + C_EXT_JB_COUNT)*sizeof(C_JMPBUF));
	nfo->jb_count += C_EXT_JB_COUNT;
	__Tls_Set(__Csup_Nfo_Tls,nfo);
	return nfo;
}
#endif
;

void __Extend_Csup_Autopool()
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo = __Tls_Get(__Csup_Nfo_Tls);
	uint_t ncount = nfo->auto_count + C_EXT_POOL_COUNT;
	nfo->auto_pool = __Realloc_Npl(nfo->auto_pool,sizeof(*nfo->auto_pool)*ncount);
	nfo->auto_count = ncount;
}
#endif
;

C_AUTORELEASE *__Find_Ptr_In_Pool(C_SUPPORT_INFO *nfo, void *p)
#ifdef _C_CORE_BUILTIN
{
	int n = nfo->auto_top;
	while ( n >= 0 )
	{
		if ( nfo->auto_pool[n].ptr == p )
			return &nfo->auto_pool[n];
		--n;
	}
	return 0;
}
#endif
;

void *__Unrefe(void *p);
void *__Pool_Ptr(void *ptr,void *cleanup)
#ifdef _C_CORE_BUILTIN
{
	if ( ptr )
	{
		C_SUPPORT_INFO *nfo = __Tls_Get(__Csup_Nfo_Tls);
		if ( !nfo ) nfo = __Acquire_Csup_Nfo();
		STRICT_REQUIRE( (cleanup == __Unrefe)
			||!__Find_Ptr_In_Pool(nfo,ptr) );

		++nfo->auto_top;
		STRICT_REQUIRE(nfo->auto_top <= nfo->auto_count);

		if ( nfo->auto_top == nfo->auto_count )
			__Extend_Csup_Autopool();
		nfo->auto_pool[nfo->auto_top].ptr = ptr;
		nfo->auto_pool[nfo->auto_top].cleanup = cleanup?cleanup:(void*)free;
	}
	return ptr;
}
#endif
;

void *__Unpool(void *pooled,int do_cleanup)
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo = __Tls_Get(__Csup_Nfo_Tls);
	if ( nfo && pooled )
	{
		int n = nfo->auto_top;
		while ( n >= 0 )
		{
			if ( nfo->auto_pool[n].ptr == pooled )
			{
				C_AUTORELEASE *q = &nfo->auto_pool[n];
				if ( do_cleanup && q->ptr ) q->cleanup(q->ptr);
				q->ptr = 0;
				q->cleanup = 0;
				break; // while
			}
			--n;
		}
	}
	return pooled;
}
#endif
;

int __Pool_Breaker()
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo = __Tls_Get(__Csup_Nfo_Tls);
	if ( !nfo ) nfo = __Acquire_Csup_Nfo();
	return nfo->auto_top;
}
#endif
;

void *__Pool_Truncate(int breaker, void *pooled)
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo = __Tls_Get(__Csup_Nfo_Tls);
	if ( nfo )
	{
		C_AUTORELEASE *q_p = 0;
		nfo->stats.unwinding = 1;
		while ( nfo->auto_top > breaker )
		{
			C_AUTORELEASE *q = &nfo->auto_pool[nfo->auto_top];
			STRICT_REQUIRE(nfo->auto_top <= nfo->auto_count);
			if ( q->ptr )
			{
				if ( !pooled || q->ptr != pooled )
				{
					q->cleanup(q->ptr);
				}
				else
					q_p = q;
			}
			--nfo->auto_top;
		}
		REQUIRE(nfo->auto_top < nfo->auto_count);
		if ( q_p )
		{
			++nfo->auto_top;
			nfo->auto_pool[nfo->auto_top] = *q_p;
		}
		nfo->stats.unwinding = 0;
	}
	return pooled;
}
#endif
;

void *__Refresh_Ptr(void *old,void *new,void *cleaner)
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo;
	REQUIRE( new != 0 );
	if ( old && !!(nfo = __Tls_Get(__Csup_Nfo_Tls)) )
	{
		C_AUTORELEASE *p = __Find_Ptr_In_Pool(nfo,old);
		if ( !p ) C_Fatal(C_ERROR_OUT_OF_POOL,old,0,0);
		p->ptr = new;
	}
	else
		__Pool_Ptr(new,cleaner);
	return new;
}
#endif
;

enum { C_DEFAULT_PURGE_CAP = 5 };

int __Pool_Purge(int *thold, int cap)
#ifdef _C_CORE_BUILTIN
{
	return 1;
}
#endif
;

void C_Cleanup_JmpBuf(void *ptr)
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo = __Tls_Get(__Csup_Nfo_Tls);
	__Pool_Truncate(nfo->jb[nfo->jb_top].auto_top,ptr);\
		--nfo->jb_top;
}
#endif
;

#define C_Pop_JmpBuf() \
	(--((C_SUPPORT_INFO *)__Tls_Get(__Csup_Nfo_Tls))->jb_top)

C_JMPBUF *C_Push_JmpBuf(void)
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo = __Support_Nfo();
	C_JMPBUF *jb;

	STRICT_REQUIRE(nfo->jb_top < nfo->jb_count);
	STRICT_REQUIRE(nfo->jb_top >= -1);

	if ( nfo->jb_top == nfo->jb_count-1 )
		nfo = __Extend_Csup_JmpBuf();
	++nfo->jb_top;

	jb = &nfo->jb[nfo->jb_top];
	memset(jb->locks,0,sizeof(jb->locks));
	jb->auto_top = nfo->auto_top;

	return jb;
}
#endif
;

void C_JmpBuf_Push_Cs(void *cs,C_JMPBUF_Unlock unlock)
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo = __Tls_Get(__Csup_Nfo_Tls);
	STRICT_REQUIRE ( cs );
	if ( nfo && cs )
	{
		STRICT_REQUIRE(nfo->jb_top < nfo->jb_count);
		STRICT_REQUIRE(nfo->jb_top >= -1);
		if ( nfo->jb_top > -1 && !nfo->stats.unwinding )
		{
			int i;
			C_JMPBUF_LOCK *locks = nfo->jb[nfo->jb_top].locks;
			for ( i = C_MAX_CS_COUNT-1; i >= 0; --i )
				if ( !locks[i].cs )
				{
					locks[i].cs = cs;
					locks[i].unlock = unlock;
					return;
				}
				C_Fatal(C_FATAL_ERROR,("no enough lock space"),__C_FILE__,__LINE__);
		}
	}
}
#endif
;

void C_JmpBuf_Pop_Cs(void *cs)
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo = __Tls_Get(__Csup_Nfo_Tls);
	if ( nfo && cs )
	{
		STRICT_REQUIRE(nfo->jb_top < nfo->jb_count);
		STRICT_REQUIRE(nfo->jb_top >= -1);
		if ( nfo->jb_top > -1 && !nfo->stats.unwinding )
		{
			int i;
			C_JMPBUF_LOCK *locks = nfo->jb[nfo->jb_top].locks;
			for ( i = C_MAX_CS_COUNT-1; i >= 0; --i )
				if ( locks[i].cs == cs )
				{
					memset(&locks[i],0,sizeof(locks[i]));
					return;
				}
				C_Fatal(C_FATAL_ERROR,("trying to pop unexistent lock"),__C_FILE__,__LINE__);
		}
	}
}
#endif
;

__No_Return void _C_Raise(int err,char *msg,char *filename,int lineno)
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo = __Tls_Get(__Csup_Nfo_Tls);
	STRICT_REQUIRE( !nfo || nfo->jb_top < nfo->jb_count );

	//printf(("err: %d, msg: %s, filename: %s, lineno: %d\n"),err,msg,filename,lineno);

#if defined _DEBUG && defined __windoze
	if ( IsDebuggerPresent() ) __debugbreak();
#endif  

	if ( err == C_RERAISE_CURRENT_ERROR && (!nfo || !nfo->err.code) )
		C_Fatal(C_ERROR_UNEXPECTED,("no errors occured yet"),filename,lineno);

	if ( nfo && nfo->jb_top >= 0 && !nfo->stats.unwinding )
	{
		int i;
		char *old_msg = nfo->err.msg;
		C_JMPBUF_LOCK *locks = nfo->jb[nfo->jb_top].locks;

		if ( err != C_RERAISE_CURRENT_ERROR )
		{
			nfo->err.msg = msg ? strdup(msg) : 0;
			nfo->err.code = err?err:-1;
			nfo->err.filename = filename;
			nfo->err.lineno = lineno;
			nfo->err.bt_count = backtrace(nfo->err.bt_cbk,C_MAX_ERROR_BTRACE);
			free( old_msg );
		}

		for ( i = C_MAX_CS_COUNT-1; i >= 0; --i )
			if (  locks[i].cs )
				locks[i].unlock(locks[i].cs);

		__Pool_Truncate(nfo->jb[nfo->jb_top].auto_top,0);

		--nfo->jb_top;
		STRICT_REQUIRE(nfo->jb_top >= -1);

#ifdef _TRACEXPT
		C_Print_Btrace();
#endif
		if ( err == C_RERAISE_CURRENT_ERROR ) 
			err = nfo->err.code;
		longjmp(nfo->jb[nfo->jb_top+1].b,err?err:-1);
	}
	else
	{
		if ( err != C_RERAISE_CURRENT_ERROR )
			C_Fatal(err,msg,filename,lineno);
		else
			C_Fatal(nfo->err.code,nfo->err.msg,nfo->err.filename,nfo->err.lineno);
	}
}
#endif
;

__No_Return void C_Abort(char *msg)
#ifdef _C_CORE_BUILTIN
{
	C_Print_Line(msg);
	abort();
}
#endif
;

void C_Print_Line(char *text)
#ifdef _C_CORE_BUILTIN
{
	__Xchg_Interlock
	{
		fputs(text,stderr);
		fputc('\n',stderr);
		fflush(stderr);
	}
}
#endif
;

char *C__basename(char *S)
#ifdef _C_CORE_BUILTIN
{
	if ( S )
	{
		char *a = strrchr(S,'/');
		char *b = strrchr(S,'\\');
		if ( b > a ) a = b;
		return a ? a+1 : S;
	}
	return 0;
}
#endif
;

__No_Inline
char *C_Btrace_Format(size_t frames, void **cbk, char *bt, size_t max_bt, size_t tabs)
#ifdef _C_CORE_BUILTIN
{
#if defined __windoze
	SYMBOL_INFO  *symbol;
	HMODULE *modules; 
	uint32_t modules_size;
	size_t   modules_count;
	char module_name[256] = {0 ,};
#endif
	int i;
	char *bt_p;

	if (!bt)
	{
		max_bt = 4096;
		bt = (char*)__Malloc(max_bt);
	}
	bt_p = bt;
	memset(bt_p,0,max_bt--);

#if defined __windoze
	SymInitialize(GetCurrentProcess(), NULL, TRUE);
	symbol = (SYMBOL_INFO *)alloca(sizeof(SYMBOL_INFO) + 256);
	symbol->MaxNameLen = 255;
	symbol->SizeOfStruct = sizeof(SYMBOL_INFO);
	EnumProcessModules(GetCurrentProcess(), 0, 0, &modules_size);
	modules = (HMODULE*)alloca(modules_size);
	if (EnumProcessModules(GetCurrentProcess(), modules, modules_size, &modules_size))
		modules_count = modules_size / sizeof(HMODULE);
#endif

	for (i = 0; i < frames; ++i)
	{
		if (!cbk[i]) continue;
		if (max_bt <= tabs) break;
		memset(bt_p, '\t', tabs); max_bt -= tabs; bt_p += tabs;

#if defined __windoze 
		
		int l;
		uint64_t dif = 0;
		HMODULE hmod = 0;
		for (l = 0; l < modules_count; ++l)
			if (hmod < modules[l] && cbk[i] > modules[l])
				hmod = modules[l];
		if (!hmod)
			module_name[0] = 0;
		else
			GetModuleFileNameA(hmod, module_name, sizeof(module_name) - 1);
		
		if (SymFromAddr(GetCurrentProcess(), (uint64_t)cbk[i], &dif, symbol))
		{
			l = snprintf(bt_p, max_bt, ("%-2d=> %s +%x %p:%s\n"),
				i,
				symbol->Name,
				(uint32_t)dif,
				cbk[i],
				module_name
				);
		}
		else
		{
			l = snprintf(bt_p, max_bt, ("%-2d=> %p:%s\n"),
				i,
				cbk[i],
				module_name
				);
		}

		if (l > 0)
		{
			max_bt -= l;
			bt_p += l;
		}
		else break;
#else
		Dl_info dlinfo = {0};
		if ( dladdr(cbk[i], &dlinfo) )
		{
			int dif = (char*)cbk[i]-(char*)dlinfo.dli_saddr;
			char c = dif > 0?'+':'-';
			int l = snprintf(bt_p,max_bt,("%-2d=> %s %c%x (%p at %s)\n"),
				i,
				dlinfo.dli_sname,
				c,
				dif>0?dif:-dif,
				cbk[i],
				C__basename((char*)dlinfo.dli_fname));
			if ( l > 0 )
			{
				max_bt -= l;
				bt_p += l;
			}
			else break;
		}
#endif
	}

	return bt;
}
#endif
;

__No_Inline
char *C_Btrace(void)
#ifdef _C_CORE_BUILTIN
{
	void *cbk[32] = {0};
	int frames = backtrace(cbk,32);
	return C_Btrace_Format(frames,cbk,0,0,1);
}
#endif
;

__No_Inline
void C_Print_Btrace(void)
#ifdef _C_CORE_BUILTIN
{
	void *cbk[32] = {0};
	int frames = backtrace(cbk,32);
	C_Print_Line(C_Btrace_Format(frames,cbk,0,0,1));
}
#endif
;

#if defined __windoze  && defined _C_CORE_BUILTIN

int backtrace( void **cbk, int count )
{
	return CaptureStackBackTrace(1, count, cbk, NULL);
}

#elif defined __GNUC__ && defined _C_CORE_BUILTIN \
	&& !(defined __APPLE__ || defined __linux__)

typedef struct _C_BACKTRACE
{
	void **cbk;
	int count;
} C_BACKTRACE;

_Unwind_Reason_Code backtrace_Helper(struct _Unwind_Context* ctx, C_BACKTRACE *bt)
{
	if ( bt->count )
	{
		void *eip = (void*)_Unwind_GetIP(ctx);
		if ( eip )
		{
			*bt->cbk++ = eip;
			--bt->count;
		}
	}
#if 0
	else
		return _URC_NORMAL_STOP;
#endif
	return _URC_NO_REASON;
}

int backtrace( void **cbk, int count )
{
	C_BACKTRACE T = { cbk, count };
	_Unwind_Backtrace((_Unwind_Trace_Fn)&backtrace_Helper, &T);
	return count-T.count;
}
#endif /* __GNUC__  && _C_CORE_BUILTIN */


C_ERROR_INFO *C_Error_Info()
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo = __Tls_Get(__Csup_Nfo_Tls);
	if ( nfo && nfo->err.code )
		return &nfo->err;
	else
		return 0;
}
#endif
;

char *C_Error_Message(void)
#ifdef _C_CORE_BUILTIN
{
	C_ERROR_INFO *info = C_Error_Info();
	if ( info && info->msg )
		return info->msg;
	return "";
}
#endif
;

int C_Error_Code(void)
#ifdef _C_CORE_BUILTIN
{
	C_ERROR_INFO *info = C_Error_Info();
	if ( info )
		return info->code;
	return 0;
}
#endif
;

char *C_Error_File(void)
#ifdef _C_CORE_BUILTIN
{
	C_ERROR_INFO *info = C_Error_Info();
	if ( info && info->filename )
		return info->filename;
	return ("<file>");
}
#endif
;

int C_Error_Line(void)
#ifdef _C_CORE_BUILTIN
{
	C_ERROR_INFO *info = C_Error_Info();
	if ( info )
		return info->lineno;
	return 0;
}
#endif
;

__No_Inline
char *C_Error_Btrace(void)
#ifdef _C_CORE_BUILTIN
{
	C_ERROR_INFO *info = C_Error_Info();
	if ( info && info->bt_count )
	{
		return C_Btrace_Format(info->bt_count,info->bt_cbk,0,0,1);
	}
	return ("\tbacktrace unavailable");
}
#endif
;

__No_Return void C_Btrace_N_Abort(char *prefix, char *msg, char *filename, int lineno)
#ifdef _C_CORE_BUILTIN
{
	char *at = filename?C_Format_Npl((" [%s(%d)]"),C__basename(filename),lineno):"";
	char *pfx = prefix?C_Format_Npl(("%s: "),prefix):"";
	C_Print_Btrace();
	C_Print_Line(C_Format_Npl(("%s%s%s"),pfx,msg,at));
	abort();
}
#endif
;

__No_Return void _C_Fatal(int err,void *ctx,char *filename,int lineno)
#ifdef _C_CORE_BUILTIN
{
	switch (err)
	{
	case C_ERROR_OUT_OF_MEMORY:
		C_Abort(("out of memory"));
	case C_ERROR_REQUIRE_FAILED:
		C_Btrace_N_Abort(("require"),ctx,filename,lineno);
	case C_FATAL_ERROR:
		C_Btrace_N_Abort(("fatal"),ctx,filename,lineno);
	case C_ERROR_DYNCO_CORRUPTED:
		C_Btrace_N_Abort(("fatal"),
			C_Format_Npl(("corrupted dynco (%p)"),ctx),filename,lineno);
	default:
		{
			char err_pfx[60];
			sprintf(err_pfx,("unexpected(%08x)"),err);
			C_Btrace_N_Abort(err_pfx,ctx,filename,lineno);
		}
	}
}
#endif
;

__No_Return void Error_Abort()
#ifdef _C_CORE_BUILTIN
{
	C_Btrace_N_Abort(
		C_Format_Npl(("\ncaught(0x%08x)"),C_Error_Code()),
		C_Error_Message(),C_Error_File(),C_Error_Line());
}
#endif
;

char *C_Error_Format()
#ifdef _C_CORE_BUILTIN
{
	int code = C_Error_Code();
	char *msg = C_Error_Message();

	if ( C_ERROR_IS_USER_ERROR(code) )
		return C_Format(("error(%d): %s"),code,msg);
	else
		return C_Format(("error(%08x): %s"),code,msg);
}
#endif
;

__No_Return void Error_Exit(int err_code)
#ifdef _C_CORE_BUILTIN
{
	int code = C_Error_Code();
	char *msg = C_Error_Message();

#ifndef _BACKTRACE
	if ( (code & C_TRACED_ERROR_GROUP) || !C_Error_Info()->msg )
#endif
		C_Print_Line(C_Error_Btrace());

	if ( code == C_ERROR_USER )
		C_Print_Line(C_Format("\n%s: %s","error",msg));
	else if ( C_ERROR_IS_USER_ERROR(code) )
		C_Print_Line(C_Format("\n%s(%d): %s","error",code,msg));
	else
		C_Print_Line(C_Format("\n%s(%08x): %s","error",code,msg));
	if ( code & C_FATAL_ERROR_GROUP )
		abort();
	__Pool_Truncate(-1,0);
	exit(err_code?err_code:code);
}
#endif
;

void C_Thread_Cleanup()
#ifdef _C_CORE_BUILTIN
{
	C_SUPPORT_INFO *nfo;
	__Pool_Truncate(-1,0);
	if ( !!(nfo = __Tls_Get(__Csup_Nfo_Tls)) )
	{
		free(nfo->err.msg);
		free(nfo->auto_pool);
		free(nfo);
		__Tls_Set(__Csup_Nfo_Tls,0);
	}
}
#endif
;

char *C_Format_System_Error()
#ifdef _C_CORE_BUILTIN
{
#ifdef __windoze
	int err = GetLastError();
	char *msg = __Malloc(1024);
	FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS |
		FORMAT_MESSAGE_MAX_WIDTH_MASK, NULL, err,
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPSTR)msg, 1024,0);
	return msg;  
#else
	return strerror(errno);
#endif
}
#endif
;

#define __Purge(TholdPtr)               __Pool_Purge(TholdPtr,C_DEFAULT_PURGE_CAP)
#define __Raise(Err,Msg)                C_Raise(Err,Msg,__C_FILE__,__LINE__)
#define __Raise_User_Error(Msg_)        C_Raise(C_ERROR_USER,Msg_,__C_FILE__,__LINE__)
#define __Raise_Format(Err,Fmt)         C_Raise(Err,(C_Format Fmt),__C_FILE__,__LINE__)
#define __Raise_System_Error()          C_Raise(C_ERROR_SYSTEM,C_Format_System_Error(),__C_FILE__,__LINE__)
#define __Fatal(Ctx)                    C_Fatal(C_FATAL_ERROR,Ctx,__C_FILE__,__LINE__)
#define __Fatal_Format(x)               C_Fatal(C_FATAL_ERROR,(C_Format_Npl x),__C_FILE__,__LINE__)
#define __Format                        C_Format
#define __Format_Npl                    C_Format_Npl
#define __Format_Error()                C_Error_Format()
#define __Format_Btrace()               C_Btrace()
#define __Format_Error_Btrace()         C_Error_Btrace()
#define __Format_System_Error()         C_Format_System_Error()

#define __Ref_Set(PP,R)                 if (0); else { __Unrefe(PP); PP = __Refe(R); }   
#define __Ptr_Set(PP,R)                 if (0); else { __Free(PP); PP = R; }   

typedef struct C_FORMAT_PARAMS C_FORMAT_PARAMS;
typedef struct C_FORMAT_VALUE C_FORMAT_VALUE;
typedef int (*C_format_value_t)(char *out, int maxlen, C_FORMAT_VALUE *fv, C_FORMAT_PARAMS *fpr);

struct C_FORMAT_VALUE 
{
	union {
		uquad_t value;
		double f;
	};
	C_format_value_t formatter;
};

struct C_FORMAT_PARAMS
{
	int justify_right: 1;
	int uppercase:1;
	int zfiller:1;
	int width1, width2; 
	int format;
};

int C_Format_Bad_Format(char *out,int maxlen,C_FORMAT_VALUE *fv, C_FORMAT_PARAMS *fpr)
#ifdef _C_CORE_BUILTIN
{
	static const char badvalue[11] = "<badformat>";
	if ( maxlen >= iszof(badvalue) )
		memcpy(out,badvalue,iszof(badvalue)); 
	return iszof(badvalue);  
}
#endif
;

int C_Format_Bad_Value(char *out,int maxlen,C_FORMAT_VALUE *fv, C_FORMAT_PARAMS *fpr)
#ifdef _C_CORE_BUILTIN
{
	static const char badvalue[10] = "<badvalue>";
	if ( maxlen >= iszof(badvalue) )
		memcpy(out,badvalue,iszof(badvalue)); 
	return iszof(badvalue);  
}
#endif
;

int C_Format_Unsigned10(char *out, int maxlen, uquad_t value)
#ifdef _C_CORE_BUILTIN
{
	int j = 0, i;
	while(value)
	{
		int q = value%10;
		value/=10;
		if ( j < maxlen ) out[j++] = '0'+q;
	}
	if ( j <= maxlen )
	{
		for ( i = 0; i < j/2; ++i )
		{
			char c = out[i];
			out[i] = out[j-i-1];
			out[j-i-1] = c;
		}  
	}
	return j;
}
#endif
;

int C_Format_Unsigned16(char *out, int maxlen, uquad_t value, int blen, int width)
#ifdef _C_CORE_BUILTIN
{
	static const char f0[] = "0123456789abcdef";
	int i, j, skip = blen*2 - (width<0?0:width);
	if ( skip < 0 ) skip = 0;
	if ( skip >= blen*2 ) skip = blen*2-1;
	for ( j = 0, i = 0; i < blen*2; ++i )
	{
		int q = (value >> (blen*8-4)) & 0x0f;
		if ( q || !skip )
		{
			skip = 0;
			if ( j < maxlen ) out[j] = f0[q];
			++j;
		}
		else --skip;
		value <<= 4; 
	}
	return j;
}
#endif
;

int C_Format_Justify(char *out, int vlen, int maxlen, C_FORMAT_PARAMS *fpr)
#ifdef _C_CORE_BUILTIN
{
	return vlen;
}
#endif
;

int C_Format_Integer_Value(char *out, int maxlen, int blen, C_FORMAT_VALUE *fv, C_FORMAT_PARAMS *fpr)
#ifdef _C_CORE_BUILTIN
{
	int k;
	if ( fpr->format == 'd' || fpr->format == 'u' || fpr->format == '?' )
	{
		if ( blen == 4 && (fpr->format == 'd' || fpr->format == '?') && (int)fv->value < 0 )
		{
			if ( maxlen ) *out = '-';
			k = C_Format_Unsigned10(out+1,maxlen-1,(quad_t)-(int)fv->value)+1;
		}
		else
			k = C_Format_Unsigned10(out,maxlen,fv->value);
	}
	else if ( fpr->format == 'x' )
		k = C_Format_Unsigned16(out,maxlen,fv->value,blen,fpr->zfiller?fpr->width1:0);
	else if ( fpr->format == 'p' )
	{
		if ( maxlen ) *out = '#';
		k = C_Format_Unsigned16(out+1,maxlen-1,fv->value,blen,blen)+1;
	}
	else
		k = C_Format_Bad_Format(out,maxlen,fv,fpr);

	if ( k < maxlen ) 
		k = C_Format_Justify(out,k,maxlen,fpr);
	return k;
}
#endif
;

int C_Format_Int_Value(char *out,int maxlen,C_FORMAT_VALUE *fv, C_FORMAT_PARAMS *fpr)
#ifdef _C_CORE_BUILTIN
{
	return C_Format_Integer_Value(out,maxlen,4,fv,fpr);
}
#endif
;

int C_Format_Quad_Value(char *out,int maxlen,C_FORMAT_VALUE *fv, C_FORMAT_PARAMS *fpr)
#ifdef _C_CORE_BUILTIN
{
	return C_Format_Integer_Value(out,maxlen,8,fv,fpr);
}
#endif
;

int C_Format_Float_Value(char *out,int maxlen,C_FORMAT_VALUE *fv, C_FORMAT_PARAMS *fpr)
#ifdef _C_CORE_BUILTIN
{
	int k = 0, n = 6;
	double v = fv->f;
	if ( v < 0 ) { v = -v; if ( maxlen > 0 ) { *out = '-'; ++k; } }
	k += C_Format_Unsigned10(out+k,maxlen-k,(quad_t)v);
	if ( fpr->width2 )
	{
		v = v - floor(v);
		if ( fpr->width2 > 0 ) 
		{ 
			n = fpr->width2;
			while ( n-- ) v *= 10;
		}
		else
		{
			n = 6;
			while ( n-- && (v - floor(v)) > 0.00001 ) v *= 10;
		}
		if ( maxlen - k > 0 ) out[k] = '.';
		++k;
		k += C_Format_Unsigned10(out+k,maxlen-k,(quad_t)v);
	}
	return k;
}
#endif
;

int C_Format_Cstr_Value(char *out,int maxlen,C_FORMAT_VALUE *fv, C_FORMAT_PARAMS *fpr)
#ifdef _C_CORE_BUILTIN
{
	int len;
	char *S = (char*)(uintptr_t)fv->value;
	if ( !S ) S = "<null>";
	len = strlen(S);
	if ( maxlen >= len ) memcpy(out,S,len);
	return len;
}
#endif
;

int C_Format_Ptr_Value(char *out,int maxlen,C_FORMAT_VALUE *fv, C_FORMAT_PARAMS *fpr)
#ifdef _C_CORE_BUILTIN
{
	C_FORMAT_PARAMS fpr1 = *fpr;
	if ( fpr1.format == '?' )
		fpr1.format = 'p';
	return C_Format_Integer_Value(out,maxlen,sizeof(void*),fv,&fpr1);
}
#endif
;

__Inline C_FORMAT_VALUE C_format_value_i(int a)           
{ C_FORMAT_VALUE r = {(uquad_t)a, C_Format_Int_Value}; return r; }
__Inline C_FORMAT_VALUE C_format_value_q(quad_t a)        
{ C_FORMAT_VALUE r = {(uquad_t)a, C_Format_Quad_Value}; return r; }
__Inline C_FORMAT_VALUE C_format_value_S(const char *a)   
{ C_FORMAT_VALUE r = {__Ptr_Word(a), C_Format_Cstr_Value}; return r; }
__Inline C_FORMAT_VALUE C_format_value_p(const wchar_t *a)
{ C_FORMAT_VALUE r = {__Ptr_Word(a), C_Format_Ptr_Value}; return r; }
__Inline C_FORMAT_VALUE C_format_value_f(double a)
{ C_FORMAT_VALUE r = {0, C_Format_Float_Value}; r.f = a; return r; }

#define $4(a) C_format_value_i(a)
#define $8(a) C_format_value_q(a)
#define $S(a) C_format_value_S(a)
#define $p(a) C_format_value_p(a)
#define $f(a) C_format_value_f(a)

__Inline C_FORMAT_VALUE __quoted_format_argument__(C_FORMAT_VALUE fv) { return fv; }

int C_Safe_Format_Realloc(char **out, int freemem, int length, int required)
#ifdef _C_CORE_BUILTIN
{
	char *ptr;
	if ( ((length * 2 + 15) & ~15) > (required + 1) ) 
		required = ((length *2 + 15) & ~15);
	else 
		required = (++required + 15) & ~15;
	ptr = __Malloc_Npl(required);
	if ( freemem )
		__Refresh_Ptr(*out,ptr,free);
	else
		__Pool_Ptr(ptr,free);
	memcpy(ptr,*out,length);
	if ( freemem )
		free(*out);
	*out = ptr;
	return required-1;
}
#endif
;

char *C_Safe_Format(char *fmt, int N, ...)
#ifdef _C_CORE_BUILTIN
{
	char local_buf[4/*256*/];
	char *out = local_buf;
	int out_len=0, max_len=sizeof(local_buf), j;    
	va_list va;
	C_FORMAT_VALUE fv;

	va_start(va,N);

	for ( j = 0 ; *fmt ; ) 
	{
		if ( *fmt == '%' && fmt[1] && fmt[1] != '%' )
		{
			int k = 0;
			C_FORMAT_PARAMS fpr;
			memset(&fpr,0,sizeof(fpr));
			fpr.width1 = -1;
			fpr.width2 = -1;
			++fmt;
			if (*fmt=='-') { fpr.justify_right = 1; ++fmt; }
			if ( *fmt == '0' && isdigit(fmt[1]) ) { fpr.zfiller = 1; ++fmt; }
			if ( isdigit(*fmt) ) fpr.width1 = strtol(fmt,&fmt,10);
			if ( *fmt == '.' ) 
			{
				++fmt;
				if ( isdigit(*fmt) ) fpr.width2 = strtol(fmt,&fmt,10);
			}
			if ( isupper(*fmt) ) fpr.uppercase = 1;
			fpr.format = tolower(*fmt++);

			if ( j < N )
			{
				fv = va_arg(va,C_FORMAT_VALUE);
				++j;
			}
			else 
				fv.formatter = C_Format_Bad_Value;

repeat:
			k = fv.formatter(out+out_len,max_len-out_len,&fv,&fpr);
			if ( k > max_len-out_len ) 
			{
				max_len = C_Safe_Format_Realloc(&out,(out!=local_buf),out_len,out_len+k);
				goto repeat;
			}
			out_len += k;
		}
		else if ( *fmt == '%' && fmt[1] == '%' )
		{
			if ( out_len == max_len ) 
				max_len = C_Safe_Format_Realloc(&out,(out!=local_buf),out_len,out_len+1);
			out[out_len++] = '%';
			fmt+=2;
		}
		else
		{
			if ( out_len == max_len ) 
				max_len = C_Safe_Format_Realloc(&out,(out!=local_buf),out_len,out_len+1);
			out[out_len++] = *fmt;
			++fmt;
		}
	}

	va_end(va);

	if ( local_buf == out ) 
	{
		out = __Malloc(out_len+1);
		memcpy(out,local_buf,out_len);
	}

	out[out_len] = 0;
	return out;
}
#endif
;
