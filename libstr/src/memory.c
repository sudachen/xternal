#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

void *Str_Malloc(size_t size)
{
    void *ptr = malloc(size);
    if ( ptr == NULL )
        abort();
    return ptr;
}

void *Str_Zero_Malloc(size_t size)
{
    void *ptr = malloc(size);
    if ( ptr == NULL )
        abort();
    memset(ptr,0,size);
    return ptr;
}

void *Str_Free(void *ptr)
{
    if ( ptr )
        free(ptr);
}

void *Str_Realloc(void *ptr,size_t size)
{
    void *nptr = realloc(ptr,size);
    if ( nptr == NULL )
        abort();
    return nptr;
}
