
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_8D00296D_5AEA_48BA_BCAA_AAA1C0CB05A4
#define C_once_8D00296D_5AEA_48BA_BCAA_AAA1C0CB05A4

#include "C+.hc"

#ifdef _BUILTIN
#define _C_SLIST_BUILTIN
#endif

#define Slist_Remove_By(ListPtr,Next,Val) C_Slist_Remove((void**)ListPtr,(int)((size_t)(&(*ListPtr)->Next)-(size_t)(*ListPtr)),Val)
#define Slist_Remove(ListPtr,Val) Slist_Remove_By(ListPtr,next,Val)

void C_Slist_Remove(void **p, int offs_of_next, void *val)
#ifdef _C_SLIST_BUILTIN
  {
    if ( p ) 
      {
        while ( *p )
          {
            if ( *p == val )
              {
                void *r = *p;
                *p = *(void**)((byte_t*)r + offs_of_next);
                *(void**)((byte_t*)r + offs_of_next) = 0;
                break;
              }
            else
              p =  (void**)((byte_t*)*p + offs_of_next);
          }
      }
  }
#endif
  ;

#define Slist_Push_By(ListPtr,Next,Val) C_Slist_Push((void**)ListPtr,(int)((size_t)(&(*ListPtr)->Next)-(size_t)(*ListPtr)),Val)
#define Slist_Push(ListPtr,Val) Slist_Push_By(ListPtr,next,Val)

void C_Slist_Push(void **p, int offs_of_next, void *val)
#ifdef _C_SLIST_BUILTIN
  {
    if ( p ) 
      {
        while ( *p )
          {
            p =  (void**)((byte_t*)*p + offs_of_next);
          }
        *p = val;
        *(void**)((byte_t*)*p + offs_of_next) = 0;
      }
  }
#endif
  ;
  
#define Slist_Pop_By(ListPtr,Next) C_Slist_Pop((void**)ListPtr,(int)((size_t)(&(*ListPtr)->Next)-(size_t)(*ListPtr)))
#define Slist_Pop(ListPtr) Slist_Pop_By(ListPtr,next)

void *C_Slist_Pop(void **p, int offs_of_next)
#ifdef _C_SLIST_BUILTIN
  {
    void *r = 0;
    
    if ( p )
      {
        r = *p;
        if ( r ) 
          {
            *p = *(void**)((byte_t*)r + offs_of_next);
            *(void**)((byte_t*)r + offs_of_next) = 0;
          }
      }
      
    return r;
  }
#endif
  ;

#endif /* C_once_8D00296D_5AEA_48BA_BCAA_AAA1C0CB05A4 */

