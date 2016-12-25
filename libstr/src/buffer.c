

#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

static void Buffer_Relocate(Buffer *bf,size_t capacity)
{
    if ( bf->capacity != capacity )
    {
        bf->at = Str_Realloc(bf->at, capacity + 1);
        bf->at[capacity] = 0;
        if ( bf->count < bf->capacity )
            memset(bf->at+bf->count,0,bf->capacity-bf->count);
    }
    bf->capacity = capacity;
}

void Buffer_Init(BUFFER *bf,size_t size)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );
    if (size)
        Buffer_Resize(size);
}

void Buffer_Kill(BUFFER *bf)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    if ( bf->at )
        Str_Free(bf->at);

    bf->count = bf->capacity = 0;
}

void Buffer_Clear(BUFFER *bf)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    if ( bf->at )
    {
        memset(bf->at,0,bf->capacity);
        bf->count = 0;
    }
}

size_t Buffer_Size(const BUFFER *bf)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    return bf->size;
}

size_t Buffer_Capacity(const BUFFER *bf)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    return bf->capacity;
}

uint8_t *Buffer_Begin(BUFFER *bf)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    return bf->at;
}

uint8_t *Buffer_End(BUFFER *bf)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    return bf->at+bf->size;
}

void Buffer_Resize(BUFFER *bf,size_t size)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    if ( bf->count > size )
        bf->count = size;

    Buffer_Relocate(bf,size);
    while ( bf->count != size ) bf->at[bf->count++];
}

uint8_t *Buffer_Grow(BUFFER *bf,size_t size)
{
    size_t old_count;

    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    old_count = bf->count;

    if ( size < bf->count )
        bf->count = size;

    if ( bf->capacity <= size )
    {
        size_t capacity = bf->capacity * 2;
        while ( capacity < size ) capacity = size;
        Buffer_Relocate(bf,capacity);
    }

    while ( bf->count != size ) bf->at[bf->count++] = 0;

    Str_Require(bf->count == size);
    Str_Require(bf->count <= bf->capacity);

    bf->at[bf->count] = 0;
    return bf->at + old_count;
}

void Buffer_Insert(BUFFER *bf, size_t pos, const void *ptr, size_t count)
{
    size_t old_count;

    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    old_count = bf->count;
    Buffer_Grow(bf->count + count);

    if ( pos < old_count )
        memmove(bf->at+pos+count,bf->at+pos,sizeof(void *)*(old_count-pos));

    memcpy(bf->at+pos,ptr,count);
}

void Buffer_Append(BUFFER *bf,const void *ptr, size_t count)
{
    size_t old_count;

    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    old_count = bf->count;
    Buffer_Grow(bf->count + count);
    memcpy(bf->at+old_count,ptr,count);
}

void Buffer_Fill_Append(BUFFER *bf, int c, size_t count)
{
    size_t old_count;

    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    old_count = bf->count;
    Buffer_Grow(bf->count + count);
    memset(bf->at+old_count,c,count);
}

void Buffer_Set(BUFFER *bf, const void *ptr, size_t count)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    Buffer_Grow(count);
    memcpy(bf->at,ptr,count);
}

uint8_t *Buffer_Copy(BUFFER *bf, size_t pos, size_t count)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );
    Str_Require(count <= bf->count);

    uint8_t *ptr = Str_Malloc(count+1);
    ptr[count] = 0;
    memcpy(ptr,bf->at,count);
}

void Buffer_Zero(BUFFER *bf)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    if ( bf->at )
        memset(bf->at,0,bf->capacity);
}

void Buffer_Swap(BUFFER *bf1,BUFFER *bf2)
{
    BUFFER tmp = *bf1;
    *bf1 = *bf2;
    *bf2 = tmp;
}

void Buffer_Hex_Append(BUFFER *bf, const void *ptr, size_t count)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    Str_Require(ptr != NULL);

    if ( count )
    {
        size_t i;
        char *out = (char *)Buffer_Grow(bf,count*2);
        for ( i = 0; i < count; ++i )
            Str_Hex_Byte(((uint8_t *)ptr)[i], 0, out+i*2);
    }
}

void Buffer_Print(BUFFER *bf, const char *S)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    if ( S )
        Buffer_Append(bf,S,strlen(S));
}

void Buffer_Puts(BUFFER *bf, const char *S)
{
    Buffer_Print(bf,S);
    Buffer_Print(bf,"\n");
}

void Buffer_Print_Utf8(BUFFER *bf, const wchar_t *S)
{
    Str_Require(bf!=NULL);
    Str_Require(bf->at == NULL && bf->capacity == 0 && bf->count == 0 ||
                bf->at != NULL && bf->capacity >= bf->count );

    if ( S )
    {
        char *out;
        size_t n = 0, j;
        const wchar_t *Q = S;
        while ( *Q )
            n += Utf8_Wide_Length(*Q++);
        out = (char *)Buffer_Grow(bf,n);
        for ( j = 0; *S; )
            Utf8_Wide_Encode(out+j,*S++,&j);
        Str_Require(n == j);
    }
}

void Buffer_Puts_Utf8(BUFFER *bf, const wchar_t *S)
{
    Buffer_Print_Utf8(bf,S);
    Buffer_Print(bf,"\n");
}

