
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#define __Elm_Resize_Npl(MemPptr,L,Width,CpsPtr) C_Elm_Resize_Npl((void**)MemPptr,L,Width,CpsPtr)
void C_Elm_Resize_Npl(void **inout, int L, int type_width, int *capacity_ptr)
#ifdef _C_CORE_BUILTIN
  {
    int requires = 0;
    int capacity = capacity_ptr?*capacity_ptr:0;

    if ( L )
      {
        requires = (L+1)*type_width;

        if ( *inout )
          {
            if ( !capacity )
              capacity = malloc_size(*inout);
            if ( capacity < requires )
              {
                capacity = Min_Pow2(requires);
                *inout = __Realloc_Npl(*inout,capacity);
              }
          }
        else
          {
            if ( capacity < requires )
              capacity = Min_Pow2(requires);

            *inout = __Malloc_Npl(capacity);
          }
      }

    if ( capacity_ptr ) *capacity_ptr = capacity;
  }
#endif
  ;

#define __Elm_Insert_Npl(MemPptr,Pos,Count,S,L,Width,CpsPtr) C_Elm_Insert_Npl((void**)MemPptr,Pos,Count,S,L,Width,CpsPtr)
int C_Elm_Insert_Npl(void **inout, int pos, int count, void *S, int L, int type_width, int *capacity_ptr)
#ifdef _C_CORE_BUILTIN
  {
    STRICT_REQUIRE(pos <= count);

    if ( L < 0 ) /* inserting Z-string */
      switch ( type_width )
        {
          case sizeof(wchar_t): L = wcslen(S); break;
          case 1: L = strlen(S); break;
          default: PANICA("invalid size of string element");
        }

    if ( L )
      {
        C_Elm_Resize_Npl(inout,count+L,type_width,capacity_ptr);

        if ( pos < count )
          memmove((byte_t*)*inout+(pos+L)*type_width,(byte_t*)*inout+pos*type_width,(count-pos)*type_width);
        memcpy((byte_t*)*inout+pos*type_width, S, L*type_width);
        count += L;
        memset((byte_t*)*inout+count*type_width, 0, type_width);
      }

    return L;
  }
#endif
  ;

#define __Elm_Insert(MemPptr,Pos,Count,S,L,Width,CpsPtr) C_Elm_Insert((void**)MemPptr,Pos,Count,S,L,Width,CpsPtr)
int C_Elm_Insert(void **inout, int pos, int count, void *S, int L, int type_width, int *capacity_ptr)
#ifdef _C_CORE_BUILTIN
  {
    void *old = *inout;
    int r = C_Elm_Insert_Npl(inout,pos,count,S,L,type_width,capacity_ptr);
    if ( *inout != old )
      {
        if ( old )
          __Refresh_Ptr(old,*inout,0);
        else
          __Pool_Ptr(*inout,0);
      }
    return r;
  }
#endif
  ;

#define C_Elm_Append(Mem,Count,S,L,Width,CpsPtr) C_Elm_Insert(Mem,Count,Count,S,L,Width,CpsPtr)
#define C_Elm_Append_Npl(Mem,Count,S,L,Width,CpsPtr) C_Elm_Insert_Npl(Mem,Count,Count,S,L,Width,CpsPtr)
#define __Vector_Append(Mem,Count,Capacity,S,L) (void)(*Count += C_Elm_Append((void**)Mem,*Count,S,L,1,Capacity))
#define __Elm_Append(Mem,Count,S,L,Width,CpsPtr) C_Elm_Append((void**)Mem,Count,S,L,Width,CpsPtr)
#define __Elm_Append_Npl(Mem,Count,S,L,Width,CpsPtr) C_Elm_Append_Npl((void**)Mem,Count,S,L,Width,CpsPtr)
