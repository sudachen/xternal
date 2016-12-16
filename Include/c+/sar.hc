
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_B280024F_42F5_4D98_9F57_2A5BEABC1C88
#define C_once_B280024F_42F5_4D98_9F57_2A5BEABC1C88

#include "C+.hc"

#ifdef _BUILTIN
#define _C_SAR_BUITIN
#endif

typedef struct _C_STRUCTED_ARRAY
  {
    byte_t *at;
    int  count;
    int  allocated;
  } C_STRUCTED_ARRAY;

void *Structed_Array_Insert(C_STRUCTED_ARRAY *arr,void *el,int width,int at, int count)
#ifdef _C_SAR_BUITIN
  {
    STRICT_REQUIRE( arr != 0 );
    if ( at < 0 ) at = arr->count+at+1;
    STRICT_REQUIRE( at >= 0 );
    STRICT_REQUIRE( count >= 0 );
    STRICT_REQUIRE( el != 0 );
    STRICT_REQUIRE( width >= 0 );
    
    arr->count += C_Elm_Insert_Npl((void**)&arr->at,at,arr->count,el,count,width,&arr->allocated);
    return arr->at+(at*width);
  }
#endif
  ;
  
int Structed_Array_Remove(C_STRUCTED_ARRAY *arr,int width,int at,int count)
#ifdef _C_SAR_BUITIN
  {
    STRICT_REQUIRE( arr != 0 );
    if ( at < 0 ) at = arr->count+at+1;
    STRICT_REQUIRE( at >= 0 );
    STRICT_REQUIRE( count >= 0 );
    STRICT_REQUIRE( width >= 0 );
    STRICT_REQUIRE( count <= arr->count );
    
    if ( arr->count < count && at < arr->count - count )
      memmove(arr->at+at*width,arr->at+(at+count)*width,arr->count-(at+count)*width);
    arr->count -= count;
    return count;
  }
#endif
  ;
  
int Structed_Array_Resize(C_STRUCTED_ARRAY *arr,int width,int count)
#ifdef _C_SAR_BUITIN
  {
    STRICT_REQUIRE( arr != 0 );
    STRICT_REQUIRE( count >= 0 );
    STRICT_REQUIRE( width >= 0 );

    if ( count*width > arr->allocated )
      C_Elm_Resize_Npl((void**)&arr->at,count,width,&arr->allocated);
    if ( arr->count < count ) memset(arr->at+(arr->count*width),0,(count-arr->count)*width);
    arr->count = count;
    return arr->allocated/width;
  }
#endif
  ;

int Structed_Array_Reserve(C_STRUCTED_ARRAY *arr,int width,int count)
#ifdef _C_SAR_BUITIN
  {
    STRICT_REQUIRE( arr != 0 );
    STRICT_REQUIRE( count >= 0 );
    STRICT_REQUIRE( width >= 0 );

    if ( count*width > arr->allocated )
      C_Elm_Resize_Npl((void**)&arr->at,count,width,&arr->allocated);
    return arr->allocated/width;
  }
#endif
  ;
  
#define C_STRUCTED_ARRAY(Fpfx,Arr_Tp,Elm_Tp) \
  typedef struct _##Arr_Tp\
    {\
      Elm_Tp *at;\
      int count;\
      int _;\
    } Arr_Tp;\
  Elm_Tp *Fpfx##_Insert(Arr_Tp *arr,Elm_Tp el,int at)\
    {\
      return Structed_Array_Insert((C_STRUCTED_ARRAY*)arr,&el,sizeof(Elm_Tp),at,1);\
    }\
  Elm_Tp *Fpfx##_Insert_Ptr(Arr_Tp *arr,Elm_Tp *el,int at,int count)\
    {\
      return Structed_Array_Insert((C_STRUCTED_ARRAY*)arr,el,sizeof(Elm_Tp),at,count);\
    }\
  Elm_Tp *Fpfx##_Push(Arr_Tp *arr,Elm_Tp el)\
    {\
      return Structed_Array_Insert((C_STRUCTED_ARRAY*)arr,&el,sizeof(Elm_Tp),-1,1);\
    }\
  Elm_Tp *Fpfx##_Push_Zero(Arr_Tp *arr)\
    {\
      byte_t el[sizeof(Elm_Tp)] = {0};\
      return Structed_Array_Insert((C_STRUCTED_ARRAY*)arr,el,sizeof(Elm_Tp),-1,1);\
    }\
  Elm_Tp *Fpfx##_Push_Ptr(Arr_Tp *arr,Elm_Tp *el,int count)\
    {\
      return Structed_Array_Insert((C_STRUCTED_ARRAY*)arr,el,sizeof(Elm_Tp),-1,count);\
    }\
  Elm_Tp *Fpfx##_Push_Front(Arr_Tp *arr,Elm_Tp el)\
    {\
      return Structed_Array_Insert((C_STRUCTED_ARRAY*)arr,&el,sizeof(Elm_Tp),0,1);\
    }\
  Elm_Tp *Fpfx##_Push_Front_Ptr(Arr_Tp *arr,Elm_Tp *el,int count)\
    {\
      return Structed_Array_Insert((C_STRUCTED_ARRAY*)arr,el,sizeof(Elm_Tp),0,count);\
    }\
  int Fpfx##_Remove(Arr_Tp *arr,int at,int count)\
    {\
      return Structed_Array_Remove((C_STRUCTED_ARRAY*)arr,sizeof(Elm_Tp),at,count);\
    }\
  int Fpfx##_Empty(Arr_Tp *arr)\
    {\
      return !arr->count;\
    }\
  int Fpfx##_Pop(Arr_Tp *arr,Elm_Tp *top)\
    {\
      int result = 0;\
      if ( top && arr->count ) { *top = arr->at[arr->count-1]; result = 1; }\
      Structed_Array_Remove((C_STRUCTED_ARRAY*)arr,sizeof(Elm_Tp),-1,1);\
      return result;\
    }\
  int Fpfx##_Pop_Front(Arr_Tp *arr,Elm_Tp *top)\
    {\
      int result = 0;\
      if ( top && arr->count ) { *top = arr->at[0]; result = 1; }\
      Structed_Array_Remove((C_STRUCTED_ARRAY*)arr,sizeof(Elm_Tp),0,1);\
      return result;\
    }\
  int Fpfx##_Resize(Arr_Tp *arr,int count)\
    {\
      return Structed_Array_Resize((C_STRUCTED_ARRAY*)arr,sizeof(Elm_Tp),count);\
    }\
  int Fpfx##_Reserve(Arr_Tp *arr,int count)\
    {\
      return Structed_Array_Reserve((C_STRUCTED_ARRAY*)arr,sizeof(Elm_Tp),count);\
    }\
  void Arr_Tp##_Destruct(Arr_Tp *arr)\
    {\
      free(arr->at);\
      __Destruct(arr);\
    }\
  Arr_Tp *Fpfx##_Init()\
    {\
      Arr_Tp *arr = __Object_Dtor(sizeof(Arr_Tp),Arr_Tp##_Destruct);\
      return arr;\
    }\
  Arr_Tp *Fpfx##_Alloc(int count)\
    {\
      Arr_Tp *arr = __Object_Dtor(sizeof(Arr_Tp),Arr_Tp##_Destruct);\
      if ( count ) Fpfx##_Resize(arr,count);\
      return arr;\
    }

#define C_STRUCTED_ARRAY_DEF(Fpfx,Arr_Tp,Elm_Tp) \
  typedef struct _##Arr_Tp\
    {\
      Elm_Tp *at;\
      int count;\
      int _;\
    } Arr_Tp;\
  Elm_Tp *Fpfx##_Insert(Arr_Tp *arr,Elm_Tp el,int at);\
  Elm_Tp *Fpfx##_Insert_Ptr(Arr_Tp *arr,Elm_Tp *el,int at,int count);\
  Elm_Tp *Fpfx##_Push(Arr_Tp *arr,Elm_Tp el);\
  Elm_Tp *Fpfx##_Push_Zero(Arr_Tp *arr);\
  Elm_Tp *Fpfx##_Push_Ptr(Arr_Tp *arr,Elm_Tp *el,int count);\
  Elm_Tp *Fpfx##_Push_Front(Arr_Tp *arr,Elm_Tp el);\
  Elm_Tp *Fpfx##_Push_Front_Ptr(Arr_Tp *arr,Elm_Tp *el,int count);\
  int Fpfx##_Remove(Arr_Tp *arr,int at,int count);\
  int Fpfx##_Empty(Arr_Tp *arr);\
  int Fpfx##_Pop(Arr_Tp *arr,Elm_Tp *top);\
  int Fpfx##_Pop_Front(Arr_Tp *arr,Elm_Tp *top);\
  int Fpfx##_Resize(Arr_Tp *arr,int count);\
  int Fpfx##_Reserve(Arr_Tp *arr,int count);\
  void Arr_Tp##_Destruct(Arr_Tp *arr);\
  Arr_Tp *Fpfx##_Init();\
  Arr_Tp *Fpfx##_Alloc(int count);

#endif /*C_once_B280024F_42F5_4D98_9F57_2A5BEABC1C88*/
