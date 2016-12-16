
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_7BF4D1A1_7ED4_4CFB_AA04_0E72090D6614
#define C_once_7BF4D1A1_7ED4_4CFB_AA04_0E72090D6614

#include "../C+.hc"

#ifndef _THREADS
#error threads are disabled, to enable use -D_THREADS
#endif

#if defined __windoze && !defined _PTHREADS
typedef HANDLE thread_t;
# define INVALID_THREAD_VALUE ((HANDLE)0)
#define Thread_Is_OK(Thr) ( Thr != INVALID_THREAD_VALUE )
#else
typedef pthread_t thread_t;
static pthread_t INVALID_THREAD_VALUE; // zero initialized
#define Thread_Is_OK(Thr) ( 0 != memcmp(&Thr,&INVALID_THREAD_VALUE,sizeof(pthread_t)) )
# ifndef INFINITE
#  define INFINITE -1 
# endif
#endif

#ifdef _BUILTIN
# define _C_THREADS_BUILTIN
#endif

enum 
  {
    THREAD_STILL_ACTIVE = -1,
  };

typedef void (*thread_func_t)(void*);

#ifdef _C_THREADS_BUILTIN
typedef struct _C_THREAD_COOKIE
  {
    thread_func_t func;
    void *o;    
  } C_THREAD_COOKIE;
static void _Thread_Release_Cookie(C_THREAD_COOKIE *cookie) 
  {
    free(cookie);
  }
static C_THREAD_COOKIE *_Thread_Allocate_Cookie(thread_func_t func, void *o) 
  {
    C_THREAD_COOKIE *cookie = malloc(sizeof(C_THREAD_COOKIE));
    cookie->func = func;
    cookie->o = o;
    return cookie;
  }

#if defined __windoze && !defined _PTHREADS 
#define _THREAD_START_STDCALL_DECL __stdcall
typedef unsigned (__stdcall *thread_proc_t)(void*);
#else
#define _THREAD_START_STDCALL_DECL
typedef void *(*thread_proc_t)(void*);
#endif
static int _THREAD_START_STDCALL_DECL _Thread_Proc(C_THREAD_COOKIE *cookie)
  {
    thread_func_t func = cookie->func;
    void *o = cookie->o;    
    _Thread_Release_Cookie(cookie);
    func(o);
    return 0;
  }
#endif

thread_t Thread_Get_Current()
#ifdef _C_THREADS_BUILTIN
  {
  #if defined __windoze && !defined _PTHREADS
    return GetCurrentThread();
  #else
    return pthread_self();
  #endif
  }
#endif
  ;

thread_t Thread_Run(thread_func_t func, void *o, int stacksize)
#ifdef _C_THREADS_BUILTIN
  {
    C_THREAD_COOKIE *cookie = _Thread_Allocate_Cookie(func,o);
  #if defined __windoze && !defined _PTHREADS
    thread_t thr = (thread_t)_beginthreadex(0,stacksize,(thread_proc_t)_Thread_Proc,cookie,0,0);
    if ( thr == INVALID_THREAD_VALUE )
      _Thread_Release_Cookie(cookie);
  #else
    int err;
    thread_t thr;
    pthread_attr_t att;

    memset(&INVALID_THREAD_VALUE,-1,sizeof(INVALID_THREAD_VALUE));
    pthread_attr_init(&att);
    pthread_attr_setstacksize(&att,stacksize);
    err = pthread_create(&thr,&att,(thread_proc_t)_Thread_Proc,cookie);
    pthread_attr_destroy(&att);
    if ( err )
      {
        _Thread_Release_Cookie(cookie);
        memset(&thr,-1,sizeof(thr));
      }
  #endif
    return thr;
  }
#endif
  ;
 
#ifdef _C_THREADS_BUILTIN
static void __No_Return _Thread_Raise_Error()
  {
    __Raise_System_Error();
  }
#endif
        
/* be sure thread is running */
thread_t Thread_Run_Sure(thread_func_t func, void *o, int stacksize)
#ifdef _C_THREADS_BUILTIN
  {
    thread_t thr = Thread_Run(func,o,stacksize);
    if ( !Thread_Is_OK(thr) )
       _Thread_Raise_Error();
    return thr;
  }
#endif
  ;
  
void Thread_Close(thread_t thr)
#ifdef _C_THREADS_BUILTIN
  {
    if ( Thread_Is_OK(thr) )
      {
      #if defined __windoze && !defined _PTHREADS
        CloseHandle(thr);
      #else
        pthread_detach(thr);
      #endif
      }
  }
#endif
  ;

void Thread_Run_Close(thread_func_t func, void *o, int stacksize)
#ifdef _C_THREADS_BUILTIN
  {
    thread_t thr = Thread_Run(func,o,stacksize);
    if ( Thread_Is_OK(thr) )
      Thread_Close(thr);
    else
      _Thread_Raise_Error();
  }
#endif
  ;
  
    
int Thread_Join(thread_t thr)
#ifdef _C_THREADS_BUILTIN
  {
    if ( Thread_Is_OK(thr) )
      {
    #if defined __windoze && !defined _PTHREADS
        for(;;)
          {
            DWORD ecode;
            if ( GetExitCodeThread(thr,&ecode) )
              if ( ecode != STILL_ACTIVE )
                return ecode;
            WaitForSingleObject(thr,100);
          }
    #else
        void *r;
        pthread_join(thr,&r);
    #endif  
      }
      
    return 0;
  }
#endif
  ;
    
void Thread_Terminate(thread_t thr)
#ifdef _C_THREADS_BUILTIN
  {
    if ( Thread_Is_OK(thr) )
      {
      #if defined __windoze && !defined _PTHREADS
        TerminateThread(thr,-1);
        CloseHandle(thr);
      #else
        void *r;
        pthread_cancel(thr);
        pthread_join(thr,&r);
      #endif
      }
  } 
#endif
  ;
     
#if defined __windoze && !defined _PTHREADS

typedef struct _C_MUTEX
  {
    CRITICAL_SECTION *cs;
  #ifdef _USECONDWAIT
    CONDITION_VARIABLE *condwait;
  #else
    HANDLE condwait;
  #endif
  } C_MUTEX;
  
void Mutex_Free(C_MUTEX *l)
#ifdef _C_THREADS_BUILTIN
  {
    if ( l->cs )
      {
        DeleteCriticalSection(l->cs);
        free(l->cs);
        l->cs = 0;
      }
    if ( l->condwait )
      {
      #ifdef _USECONDWAIT
        free(l->condwait);
      #else
        CloseHandle(l->condwait);
      #endif
        l->condwait = 0;
      }
  }
#endif
  ;

void Mutex_Init_CS(CRITICAL_SECTION * volatile *cs)
#ifdef _C_THREADS_BUILTIN
  {
    CRITICAL_SECTION *ccs = malloc(sizeof(CRITICAL_SECTION));
    InitializeCriticalSection(ccs);
    if ( 0 != InterlockedCompareExchangePointer(cs,ccs,0) )
      {
        DeleteCriticalSection(ccs);
        free(ccs);
      }
  }
#endif
  ;
  
void Mutex_Init_Condwait(void * volatile *condwait)
#ifdef _C_THREADS_BUILTIN
  {
  #ifdef _USECONDWAIT
    CONDITION_VARIABLE *tmp = malloc(sizeof(CONDITION_VARIABLE));
    InitializeConditionVariable(tmp);
    if ( 0 != InterlockedCompareExchangePointer(condwait,tmp,0) )
      free(tmp);
  #else
    HANDLE h = CreateEvent(0,0,0,0);
    if ( 0 != InterlockedCompareExchangePointer(condwait,h,0) )
      CloseHandle(h);
  #endif
  }
#endif
  ;

void Mutex_Wait(C_MUTEX *l, long ms)
#ifdef _C_THREADS_BUILTIN
  {
    if ( !l->cs ) Mutex_Init_CS(&l->cs);
    if ( !l->condwait ) Mutex_Init_Condwait(&l->condwait);
  #ifdef _USECONDWAIT
    SleepConditionVariableCS(l->condwait,l->cs,ms);
  #else
    LeaveCriticalSection(l->cs);
    WaitForSingleObject(l->condwait,ms>=0?ms:INFINITE);
    EnterCriticalSection(l->cs);
  #endif
  }
#endif
  ;

void Mutex_Notify(C_MUTEX *l)
#ifdef _C_THREADS_BUILTIN
  {
    if ( !l->condwait ) Mutex_Init_Condwait(&l->condwait);
  #ifdef _USECONDWAIT
    WakeConditionVariable(l->condwait);
  #else
    SetEvent(l->condwait);
  #endif
  }
#endif
  ;

void Mutex_Lock(C_MUTEX *l)
#ifdef _C_THREADS_BUILTIN
  {
    if ( !l->cs ) 
      Mutex_Init_CS(&l->cs);
    EnterCriticalSection(l->cs);
  }
#endif
  ;

void Mutex_Unlock(C_MUTEX *l)
#ifdef _C_THREADS_BUILTIN
  {
    if ( l->cs )
      LeaveCriticalSection(l->cs);
  }
#endif
  ;

/* __windoze way ends here */

#else /* POSIX */

typedef struct _C_MUTEX
  {
    pthread_mutex_t *cs;
    pthread_cond_t  *condwait;
  } C_MUTEX;
  
void Mutex_Free(C_MUTEX *l)
#ifdef _C_THREADS_BUILTIN
  {
    if ( l->cs )
      {
        pthread_mutex_destroy(l->cs);
        free(l->cs);
        l->cs = 0;
      }
    if ( l->condwait )
      {
        pthread_cond_destroy(l->condwait);
        free(l->condwait);
        l->condwait = 0;
      }
  }
#endif
  ;

void Mutex_Init_CS(pthread_mutex_t * volatile *cs)
#ifdef _C_THREADS_BUILTIN
  {
    pthread_mutex_t *ccs = malloc(sizeof(pthread_mutex_t));
    pthread_mutex_init(ccs,0);
    if ( !Atomic_CmpXchg_Ptr(cs,ccs,0) )
      {
        pthread_mutex_destroy(ccs);
        free(ccs);
      }
  }
#endif
  ;
  
void Mutex_Init_Condwait(pthread_cond_t * volatile *condwait)
#ifdef _C_THREADS_BUILTIN
  {
    pthread_cond_t *cnd = malloc(sizeof(pthread_cond_t));
    pthread_cond_init(cnd,0);
    if ( !Atomic_CmpXchg_Ptr(condwait,cnd,0) )
      {
        pthread_cond_destroy(cnd);
        free(cnd);
      }
  }
#endif
  ;

void Mutex_Wait(C_MUTEX *l, long ms)
#ifdef _C_THREADS_BUILTIN
  {
    if ( !l->condwait ) Mutex_Init_Condwait(&l->condwait);
    if ( !l->cs ) Mutex_Init_CS(&l->cs); 
    if ( ms == INFINITE )
      pthread_cond_wait(l->condwait,l->cs);
    else
      {
        quad_t us = Get_System_Useconds() + ((quad_t)ms * 1000);
        struct timespec ts;
        ts.tv_nsec = 0;//(us%1000000)*1000;
        ts.tv_sec = 0;//us/(1000000);
        pthread_cond_timedwait(l->condwait,l->cs,&ts);
      }
  }
#endif
  ;

void Mutex_Notify(C_MUTEX *l)
#ifdef _C_THREADS_BUILTIN
  {
    if ( !l->condwait ) Mutex_Init_Condwait(&l->condwait);
    pthread_cond_signal(l->condwait);
  }
#endif
  ;

void Mutex_Lock(C_MUTEX *l)
#ifdef _C_THREADS_BUILTIN
  {
    if ( !l->cs ) 
      Thread_Init_CS(&l->cs);
    pthread_mutex_lock(l->cs);
  }
#endif
  ;

void Mutex_Unlock(C_MUTEX *l)
#ifdef _C_THREADS_BUILTIN
  {
    if ( l->cs )
      pthread_mutex_unlock(l->cs);
  }
#endif
  ;

#endif 


void C_MUTEX_Destruct(C_MUTEX *l)
#ifdef _C_THREADS_BUILTIN
  {
    Mutex_Free(l);
    __Destruct(l);
  }
#endif
  ;
  
C_MUTEX *Mutex_Init()
#ifdef _C_THREADS_BUILTIN
  {
    return __Object_Dtor(sizeof(C_MUTEX),C_MUTEX_Destruct);
  }
#endif
  ;
  

#define C_MUTEX_INIT { 0, 0 }

typedef  C_MUTEX C_MUTEX;
#define __Mutex_Lock(l) \
              __Interlock_Opt(((void)0),l, \
                  Mutex_Lock,Mutex_Unlock,Mutex_Unlock)

#endif /*C_once_7BF4D1A1_7ED4_4CFB_AA04_0E72090D6614*/
