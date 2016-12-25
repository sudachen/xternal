
#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

void __Elm_Resize(void **inout, size_t L, size_t type_width, size_t *capacity_ptr)
{
    size_t requires = 0;
    size_t capacity = capacity_ptr?*capacity_ptr:0;

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

            *inout = Str_Malloc(capacity);
        }
    }

    if ( capacity_ptr ) *capacity_ptr = capacity;
}

size_t __Elm_Insert(void **inout, size_t pos, size_t count, const void *S, size_t L, size_t type_width, size_t *capacity_ptr)
{
    assert(pos <= count);

    if ( L == INT_MAX ) /* inserting Z-string */
        switch ( type_width )
        {
            case sizeof(wchar_t): L = wcslen(S); break;
            case 1: L = strlen(S); break;
            default: PANICA("invalid size of string element");
        }

    if ( L )
    {
        __Elm_Resize(inout,count+L,type_width,capacity_ptr);

        if ( pos < count )
            memmove((uint8_t *)*inout+(pos+L)*type_width,(uint8_t *)*inout+pos*type_width,(count-pos)*type_width);
        memcpy((uint8_t *)*inout+pos*type_width, S, L*type_width);
        count += L;
        memset((uint8_t *)*inout+count*type_width, 0, type_width);
    }

    return L;
}

