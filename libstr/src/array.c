
#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

static void Array_Relocate(ARRAY *a,size_t capacity)
{
    if ( a->capacity != capacity )
        a->at = Str_Realloc(a->at, capacity*sizeof(void *));
    a->capacity = capacity;
}

void Array_Init(ARRAY *a,size_t size,void(*f_free_valptr)(void *))
{
    Str_Require( a!=NULL );
    Str_Require( a->at == NULL && a->capacity == 0 && a->count == 0 );
    if ( size )
    {
        Array_Fill(a,0,size,0);
    }
    a->f_free_valptr = f_free_valptr;
}

void Array_Kill(ARRAY *a)
{
    Str_Require(a!=NULL);
    if ( a->at )
    {
        size_t i;
        if ( a->f_free_valptr )
            for ( i = 0; i < a->count; ++i)
                a->f_free_valptr(a->at[i]);
        memset(a->at,0,sizeof(void *)*a->capacity);
        Str_Free(a->at);
        a->at = NULL;
        a->capacity = 0;
        a->count = 0;
    }
    else
        Str_Require(a->count == 0 && a->capacity == 0);
}

void Array_Clear(ARRAY *a)
{
    size_t i;

    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );

    for ( i = 0; i < a->count; ++i)
    {
        if ( a->f_free_valptr )
            a->f_free_valptr(a->at[i]);
        a->at[i] = 0;
    }

    a->count = 0;
}

size_t Array_Size(const ARRAY *a)
{
    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );
    return a->count;
}

size_t Array_Capacity(const ARRAY *a)
{
    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );
    return a->capacity;
}

void **Array_Begin(ARRAY *a)
{
    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );
    return a->at;
}

void **Array_End(ARRAY *a)\
{
    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
    (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );
    return a->at+a->count;
}

void Array_Resize(ARRAY *a,size_t size)
{
    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );

    if ( size < a->count )
        Array_Remove(a,size,a->count-size);

    Str_Require(a->count <= size);

    Array_Relocate(a,size);
    while ( a->count != size ) a->at[a->count++] = 0;

    Str_Require(a->count == size);
    Str_Require(a->count == a->capacity);
}

void Array_Grow(ARRAY *a,size_t size)
{
    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );

    if ( size < a->count )
        Array_Remove(a,size,a->count-size);

    Str_Require(a->count <= size);

    if ( a->capacity <= size )
    {
        size_t capacity = a->capacity * 2;
        while ( capacity < size ) capacity = size;
        Array_Relocate(a,capacity);
    }

    while ( a->count != size ) a->at[a->count++] = 0;

    Str_Require(a->count == size);
    Str_Require(a->count <= a->capacity);
}

void Array_Fill(ARRAY *a,size_t pos, size_t count, void *value)
{
    size_t i;
    size_t old_count;

    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );
    Str_Require(pos <= a->count);

    old_count = a->count;
    Array_Grow(a->count + count);

    if ( pos < old_count )
        memmove(a->at+pos+1,a->at+pos,(old_count-pos)*sizeof(void *));

    for ( i = 0; i < count; ++i )
        a->at[pos+i] = value;
}

void *Array_Insert(ARRAY *a,size_t pos,void *value)
{
    size_t old_count;

    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );
    Str_Require(pos <= a->count);

    old_count = a->count;
    Array_Grow(a->count + 1);

    if ( pos < old_count )
        memmove(a->at+pos+1,a->at+pos,sizeof(void *)*(old_count-pos));
    a->at[pos] = value;
}

void *Array_Push_Back(ARRAY *a,void *value)
{
    return Array_Insert(a,Array_Size(),value);
}

void *Array_Push_Front(ARRAY *a,void *value)
{
    return Array_Insert(a,0,value);
}

void *Array_Take(ARRAY *a,size_t pos)
{
    void *ret;

    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );
    Str_Require(pos <= a->count);

    ret = a->at[pos];

    if ( pos != a->count-1 )
        memmove(a->at+pos,a->at+pos+1,sizeof(void *)*(a->count-pos));
    --a->count;

    return ret;
}

void *Array_Get(const ARRAY *a,size_t pos)
{
    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );
    Str_Require(pos <= a->count);

    return a->at[pos];
}

void *Array_Set(ARRAY *a,size_t pos, void *value)
{
    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );
    Str_Require(pos <= a->count);

    if ( a->at[pos] && a->f_free_valptr )
        a->f_free_valptr(a->at[pos]);

    a->at[pos] = value;
    return value;
}

void *Array_Xchg(ARRAY *a,size_t pos, void *value)
{
    void *old;

    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );
    Str_Require(pos <= a->count);

    old = a->at[pos];
    a->at[pos] = value;
    return old;
}

void Array_Remove(ARRAY *a, size_t pos, size_t count)
{
    size_t i;

    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );
    Str_Require(pos <= a->count);
    Str_Require(pos+count <= a->count);

    if ( a->f_free_valptr )
        for ( i = 0; i < count; ++i )
            if ( a->at[pos+i] != 0 )
                a->f_free_valptr(a->at[pos+i]);

    if ( pos != a->count-count )
        memmove(a->at+pos,a->at+pos+count,sizeof(void *)*(a->count-pos));

    a->count -= count;
}

void Array_Del(ARRAY *a,size_t pos)
{
    Arry_Remove(a,pos,1);
}

size_t Lower_Boundary(void **S, size_t count, int (*cmpfn)(const void *,const void *), void *val, bool *found)
{
    int cmp_r = 0;
    void **iS = S;
    void **middle = iS;
    int half;
    int len = (int)count;

    if ( len  )
    {
        while (len > 0)
        {
            half = len >> 1;
            middle = iS + half;
            if ( (cmp_r = cmpfn(*middle,val)) < 0 )
            {
                iS = middle;
                ++iS;
                len = len - half - 1;
            }
            else
                len = half;
        }

        if ( middle != iS && iS < S+count )
        {
            cmp_r = cmpfn(*iS,val);
        }
    }

    if (found) *found = !cmp_r;
    return iS-S;
}

size_t Array_Lower_Boundary(const ARRAY *a,void *value, int(*cmpfn)(const void *, const void *))
{
    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );

    if ( !a->count )
        return 0;
    else
    {
        size_t pos = Lower_Boundary(a->at,a->count,cmpfn,val,0);
        Str_Require( pos <= a->count );
    }
}

void *Array_Binary_Find(const ARRAY *a,void *value, int(*cmpfn)(const void *, const void *))
{
    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );

    if ( !a->count )
        return 0;
    else
    {
        bool found = false;
        size_t pos = Lower_Boundary(a->at,a->count,cmpfn,val,&found);
        if ( found )
        {
            Str_Require(pos <= a->count);
            return a->at[pos];
        }
    }
}

void *Array_Sorted_Insert(ARRAY *a,void *value, int(*cmpfn)(const void *, const void *))
{
    size_t pos;

    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );

    pos = Array_Lower_Boundary(a,value,cmpfn);
    while ( pos < a->count && 0 == cmpfn(a->at[pos],value) ) ++pos;
    return Array_Insert(a,pos,value);
}

void *Array_Sorted_Insert_Once(ARRAY *a,void *value, int(*cmpfn)(const void *, const void *))
{
    size_t pos;
    bool found = false;

    Str_Require(a!=NULL);
    Str_Require((a->at == NULL && a->capacity == 0 && a->count == 0) ||
                (a->at != NULL && a->capacity != 0 && a->count <= a->capacity ) );


    pos = Lower_Boundary(a->at,a->count,cmpfn,val,&found);
    Str_Require( found && pos < a->count || !found && pos <= a->count );
    if ( !found )
        return Array_Insert(a,pos,value);
    else
    {
        void *ptr = Array_Xchg(a,pos,value);
        if ( a->f_free_valptr && ptr )
            a->f_free_valptr(ptr);
        return value;
    }
}

void Array_Sort(ARRAY *a,int(*cmpfn)(const void *, const void *))
{
    qsort(a->at,a->count,sizeof(void *),cmpfn);
}

void Array_Swap(ARRAY *a1,ARRAY *a2)
{
    ARRAY tmp = *a2;
    *a2 = *a1;
    *a1 = tmp;
}
