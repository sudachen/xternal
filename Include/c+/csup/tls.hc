
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

Thread Local Store

__Tls_Define, __Tls_Declare, __Tls_Set, __Tls_Get

it is included by C+.hc

*/

#ifndef _THREADS
# define __Tls_Define(Name)  void *Name = 0
# define __Tls_Declare(Name) extern void *Name
# define __Tls_Set(Name,Val) ((Name) = (Val))
# define __Tls_Get(Name)     (Name)

#else /* use threads (-D _THREADS) */

# if defined _MSC_VER && !defined _PTHREADS && !defined _RTTLS
#   define __Tls_Define(Name)  __declspec(thread) void *Name = 0
#   define __Tls_Declare(Name) extern __declspec(thread) void *Name
#   define __Tls_Set(Name,Val) ((Name) = (Val))
#   define __Tls_Get(Name)     (Name)

# else /* use dynamic TLS */

#   define __Tls_Set(Name,Val) Tls_Set(&Name,Val)
#   define __Tls_Get(Name)     Tls_Get(Name)
#   if defined __windoze && !defined _PTHREADS
#     define INVALID_TLS_VALUE TLS_OUT_OF_INDEXES
#     define __Tls_Define(Name)  ulong_t volatile Name = INVALID_TLS_VALUE;
#     define __Tls_Declare(Name) extern ulong_t volatile Name;

void Tls_Set(ulong_t volatile *name, void *val)
#ifdef _C_CORE_BUILTIN
  {
    if ( *name == INVALID_TLS_VALUE ) 
      {
        ulong_t tmp = TlsAlloc();
        if ( InterlockedCompareExchange(name,tmp,INVALID_TLS_VALUE) != INVALID_TLS_VALUE )
          TlsFree(tmp);
      }
    TlsSetValue(*name,val);
  }
#endif
  ;
  
void *Tls_Get(ulong_t name)
#ifdef _C_CORE_BUILTIN
  {
    if ( name == INVALID_TLS_VALUE ) 
      return 0;
    return TlsGetValue(name);
  }
#endif
  ; 

#   else /* POSIX threads */
#     define INVALID_TLS_VALUE ((pthread_key_t)-1) 
#     define __Tls_Define(Name)  pthread_key_t Name = INVALID_TLS_VALUE; /* pthread_once way is madness! */
#     define __Tls_Declare(Name) extern pthread_key_t Name;

void Tls_Set(pthread_key_t volatile *name, void *val)
#ifdef _C_CORE_BUILTIN
  {
    if ( *name == INVALID_TLS_VALUE ) 
      {
        pthread_key_t tmp;
        pthread_key_create(&tmp,0);
        if ( !Atomic_CmpXchg(name,tmp,INVALID_TLS_VALUE) )
          pthread_key_delete(tmp);
      }
    pthread_setspecific(*name,val);
  }
#endif
  ;  
  
void *Tls_Get(pthread_key_t name)
#ifdef _C_CORE_BUILTIN
  {
    if ( name == INVALID_TLS_VALUE ) 
      return 0;
    return pthread_getspecific(name);
  }
#endif
  ;

#   endif /* PSIX threads */
# endif /* dynamic TLS */
#endif /* use THREADS */
