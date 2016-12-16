
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_FDCDEF27_5EA4_4C1D_99AB_1CD0A992A18A
#define C_once_FDCDEF27_5EA4_4C1D_99AB_1CD0A992A18A

#include "../C+.hc"
#include "../slist.hc"
#include "threads.hc"

#ifdef _BUILTIN
#define _C_TASQUE_BUILTIN
#endif

typedef void (*tasque_proc_t)(void *obj);
typedef void (*tasque_update_t)(void *monitor, void *obj, int status);
typedef void (*tasque_alert_t)(void *obj, int status);

enum 
  {
    TASQUE_COMPLETE = 0,
    TASQUE_FAIL     = 0x80000000,
    TASQUE_STACK_SIZE = 64*KILOBYTE,
  };

typedef struct _C_TASQUE_PROCESSOR
  {
    thread_t thr;
    struct _C_TASQUE_PROCESSOR **prev;
    struct _C_TASQUE_PROCESSOR *next;
  } C_TASQUE_PROCESSOR;

typedef struct _C_TASQUE_TASK
  {
    struct _C_TASQUE_TASK *next;
    tasque_proc_t task;  
    void *obj;
    tasque_update_t update;
    void *monitor;
    C_TASQUE_PROCESSOR *processor;
  } C_TASQUE_TASK;

typedef struct _C_TASQUE_ALERT
  {
    struct _C_TASQUE_ALERT *next;
    tasque_alert_t callback;  
    void *obj;
    quad_t deadline;
  } C_TASQUE_ALERT;

#ifdef _C_TASQUE_BUILTIN
int Tasque_MAX = 1000;
int Tasque_RESERVE = 5;
int Tasque_ONCARE = 0;
int Tasque_COUNT = 0;
C_TASQUE_TASK * volatile Tasque_Task_In = 0;
C_TASQUE_TASK * volatile Tasque_Task_Out = 0;
C_TASQUE_TASK * volatile Tasque_Task_Care = 0;
C_TASQUE_ALERT *Tasque_Alerts_List = 0;
C_MUTEX Tasque_Start_Lock = C_MUTEX_INIT;
C_MUTEX Tasque_Lock = C_MUTEX_INIT;
C_MUTEX Tasque_Out_Monitor = C_MUTEX_INIT;
C_MUTEX Tasque_Out_Monitor1 = C_MUTEX_INIT;  
C_TASQUE_PROCESSOR *Tasque_Proc_List = 0;
#else
extern int Tasque_MAX;
extern int Tasque_RESERVE;
#endif

void C_TASQUE_TASK_Destruct(C_TASQUE_TASK *tpt)
#ifdef _C_TASQUE_BUILTIN
  {
    STRICT_REQUIRE(!tpt->next);
    __Unrefe(tpt->obj);
    __Unrefe(tpt->monitor);
    __Destruct(tpt);
  }
#endif
  ;
  
void C_TASQUE_ALERT_Destruct(C_TASQUE_ALERT *tpt)
#ifdef _C_TASQUE_BUILTIN
  {
    STRICT_REQUIRE(!tpt->next);
    __Unrefe(tpt->obj);
    __Destruct(tpt);
  }
#endif
  ;

void Tasque_Task_Processor(C_TASQUE_PROCESSOR **_pcs)
#ifdef _C_TASQUE_BUILTIN
  {
    int alive = 1;
    C_TASQUE_TASK *t = 0;
    C_TASQUE_PROCESSOR pcs;
    
    Mutex_Lock(&Tasque_Lock);
    ++Tasque_ONCARE;
    ++Tasque_COUNT;
    pcs.next = Tasque_Proc_List;
    if ( pcs.next ) pcs.next->prev = &pcs.next;
    Tasque_Proc_List = &pcs;
    pcs.prev = &Tasque_Proc_List;
    *_pcs = &pcs;
    Mutex_Unlock(&Tasque_Lock);
    
    Mutex_Lock(&Tasque_Start_Lock);
    // now caller have to done all required work.  
    Mutex_Unlock(&Tasque_Start_Lock);
    
    while ( alive ) 
      {
        Mutex_Lock(&Tasque_Lock);
        if ( Tasque_Task_In ) 
          {
            t = Slist_Pop((C_TASQUE_TASK**)&Tasque_Task_In);

            STRICT_REQUIRE(Tasque_ONCARE > 0);
            STRICT_REQUIRE(!t->processor);

            t->processor = &pcs;
            Slist_Push((C_TASQUE_TASK**)&Tasque_Task_Care,t);
            --Tasque_ONCARE;
          }
        else
          {
            if ( Tasque_ONCARE > Tasque_RESERVE ) 
              {
                alive = 0;
                --Tasque_COUNT;
                --Tasque_ONCARE;
                if ( pcs.next ) pcs.next->prev = pcs.prev;
                *pcs.prev = pcs.next;
                pcs.prev = 0;
                pcs.next = 0;
              }
            else
              {
                Mutex_Wait(&Tasque_Lock,10);
              }
          }
        Mutex_Unlock(&Tasque_Lock);
          
        if ( t )
          {
            t->task(t->obj);

            Mutex_Lock(&Tasque_Lock);
            Slist_Remove((C_TASQUE_TASK**)&Tasque_Task_Care,t);
            t->processor = 0; 
            Slist_Push((C_TASQUE_TASK**)&Tasque_Task_Out,t);
            t = 0;
            ++Tasque_ONCARE;
            Mutex_Unlock(&Tasque_Lock);
            Mutex_Notify(&Tasque_Out_Monitor);
         }
      }
      
    Mutex_Notify(&Tasque_Lock);
  }
#endif
  ;

void Tasque_Queue(
  /*tasque_proc_t*/ void *task, void *obj, 
  /*tasque_update_t*/ void *update, void *monitor)
#ifdef _C_TASQUE_BUILTIN
  {
    __Mutex_Lock(&Tasque_Lock)
      {
        C_TASQUE_TASK *t = __Object_Dtor(sizeof(C_TASQUE_TASK),
                                          C_TASQUE_TASK_Destruct);
        t->task = task;
        t->obj  = __Refe(obj);
        t->update = update;
        t->monitor = __Refe(monitor);
        Slist_Push((C_TASQUE_TASK**)&Tasque_Task_In,__Retain(t));
      }
    
    Mutex_Notify(&Tasque_Lock);
    Switch_to_Thread();
  }
#endif
  ;

void Tasque_Alert(int ms, /*tasque_alert_t*/ void *callback, void *obj)
#ifdef _C_TASQUE_BUILTIN
  {
    C_TASQUE_ALERT *t = __Object_Dtor(sizeof(C_TASQUE_ALERT),
                                       C_TASQUE_ALERT_Destruct);
    quad_t deadline = Get_System_Millis() + ms;
    t->deadline = deadline;
    t->callback = callback;
    t->obj = __Refe(obj);
    Slist_Push(&Tasque_Alerts_List,__Retain(t));
  }
#endif
  ;
  
void Tasque_Perform_Alert()
#ifdef _C_TASQUE_BUILTIN
  {
    quad_t deadline = Get_System_Millis();
    C_TASQUE_ALERT **a; 
    C_TASQUE_ALERT *k;
        
    if ( Tasque_Alerts_List )
      {
        a = &Tasque_Alerts_List;
        do 
          {
            if ( (*a)->deadline > deadline ) 
              a = &(*a)->next;
            else __Auto_Release
              {
                k = __Pool_RefPtr(*a);
                *a = k->next;
                k->next = 0;
                k->callback(k->obj,TASQUE_COMPLETE);
              }
          }
        while ( *a );
      }
  }
#endif
  ;
    
int Tasque_Perform_Update(int ms, int worktime)
#ifdef _C_TASQUE_BUILTIN
  {
    int i;
    quad_t deadline = worktime ? Get_System_Millis() + worktime : 0;
    C_TASQUE_TASK *t;

    if ( !Tasque_ONCARE && Tasque_COUNT < Tasque_MAX )
      {
        C_TASQUE_PROCESSOR * volatile p = 0;
        __Mutex_Lock(&Tasque_Start_Lock)
          {
            thread_t thr = Thread_Run_Sure((thread_func_t)Tasque_Task_Processor
                                           ,(void*)&p
                                           ,TASQUE_STACK_SIZE);        
            while ( !p ) 
              {
                Switch_to_Thread();
                __RwBarrier();
              }
              
            p->thr = thr;
          }
      }
      
    Tasque_Perform_Alert();
    
    if ( !Tasque_Task_Out  )
      __Mutex_Lock(&Tasque_Out_Monitor)
        {
          if ( Tasque_Task_In || Tasque_Task_Care ) 
            Mutex_Wait(&Tasque_Out_Monitor,ms);  
        }
        
    do for ( i=0; i < 10 && Tasque_Task_Out; ++i ) __Auto_Release
      {
        __Mutex_Lock(&Tasque_Lock)
          t = __Pool_RefPtr(Slist_Pop((C_TASQUE_TASK**)&Tasque_Task_Out));
        t->update(t->monitor,t->obj,TASQUE_COMPLETE);
        Tasque_Perform_Alert();
      }
    while (Tasque_Task_Out && ( !deadline || Get_System_Millis() < deadline) ); 
    
    Tasque_Perform_Alert();

    __Mutex_Lock(&Tasque_Lock)
      i =     !!Tasque_Task_In || !!Tasque_Task_Out || !!Tasque_Task_Care 
           || !!Tasque_Alerts_List;
    return i;
  }
#endif
  ;

void Tasque_Finish_Task_List(C_TASQUE_TASK * volatile *lst,int status)
#ifdef _C_TASQUE_BUILTIN
  {
    C_TASQUE_TASK *t;
    while ( *lst ) __Auto_Release
      {
        t = __Pool_RefPtr(Slist_Pop((C_TASQUE_TASK**)lst));
        __Mutex_Lock(&Tasque_Lock)
          if ( t->processor )
            Thread_Terminate(t->processor->thr);
        t->update(t->monitor,t->obj,status);
      }
  }
#endif
  ;
  
void Tasque_Terminate_Alerts()
#ifdef _C_TASQUE_BUILTIN
  {
    C_TASQUE_ALERT **a; 
    C_TASQUE_ALERT *k;
        
    if ( Tasque_Alerts_List )
      {
        a = &Tasque_Alerts_List;
        do __Auto_Release 
          {
            k = __Pool_RefPtr(*a);
            *a = k->next;
            k->next = 0;
            k->callback(k->obj,TASQUE_FAIL);
          }
        while ( *a );
      }
  }
#endif
  ;
  
void Tasque_Terminate()
#ifdef _C_TASQUE_BUILTIN
  {
    C_TASQUE_TASK *t;
    Tasque_MAX = 0;
    Tasque_RESERVE = 0;
 
    if ( Tasque_COUNT )
      {
        Mutex_Notify(&Tasque_Lock);
        Sleep(30);
      }
          
    __Mutex_Lock(&Tasque_Lock)
      {
        Tasque_Finish_Task_List(&Tasque_Task_Care,TASQUE_FAIL);
        Tasque_Finish_Task_List(&Tasque_Task_In,TASQUE_FAIL);
        Tasque_Finish_Task_List(&Tasque_Task_Out,TASQUE_FAIL);
      }
      
    Tasque_Terminate_Alerts();
  }
#endif
  ;

void Tasque_Stop(long ms)
#ifdef _C_TASQUE_BUILTIN
  {
    quad_t t = System_Millis() + ms;
    Tasque_MAX = 0;
    Tasque_RESERVE = 0;
    
    do 
      {
        Mutex_Notify(&Tasque_Lock);
        Sleep(10);
      }
    while ( Tasque_ONCARE && t > System_Millis() );

    __Mutex_Lock(&Tasque_Lock)
      Tasque_Finish_Task_List(&Tasque_Task_Out,TASQUE_COMPLETE);
    
    Tasque_Terminate();
  }
#endif
  ;

void Tasque_Finish(int finish_in_ms, int wait_ms)
#ifdef _C_TASQUE_BUILTIN
  {
    quad_t deadline = System_Millis() + finish_in_ms;
    while ( Tasque_Perform_Update(wait_ms,0) && System_Millis() < deadline );
  }
#endif
  ;  
  
#endif /* C_once_FDCDEF27_5EA4_4C1D_99AB_1CD0A992A18A */

