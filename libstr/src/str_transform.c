
#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>


char *Str_Split_First_Into(ARRAY *L, const char *S, const char *delims)
{
    if ( !S || !*S ) return 0;

    if ( delims )
    {
        const char *d;
        size_t j = 0;
        for ( ; S[j]; ++j )
            for ( d = delims; *d; ++d )
                if ( S[j] == *d )
                    goto l;
    l:
        Array_Push(L,Str_Copy_Part(S,j));
        return S[j] ? S+(j+1) : 0;
    }
    else // split by spaces
    {
        const char *p = S, *q;
        while ( *p && Isspace(*p) ) ++p;
        q = p;
        while ( *q && !Isspace(*q) ) ++q;
        Array_Push(L,Str_Copy_Part(p,q-p));
        while ( *q && Isspace(*q) ) ++q;
        return *q ? q : 0;
    }
}

void Str_Split_Once(ARRAY *L, const char *S,const char *delims)
{
    if ( S )
    {
        S = Str_Split_First_Into(L,S,delims);
        if ( S )
            Array_Push(L,Str_Copy(S));
    }
    return L;
}

void Str_Split(ARRAY *L, const char *S, const char *delims)
{
    while ( S )
        S = Str_Split_First_Into(L,S,delims);
    return L;
}

char *Str_Concat(const char *a, const char *b)
{
    size_t a_len = a?strlen(a):0;
    size_t b_len = b?strlen(b):0;
    char *out = Str_Malloc(a_len+b_len+1);
    if ( a_len )
        memcpy(out,a,a_len);
    if ( b_len )
        memcpy(out+a_len,b,b_len);
    out[a_len+b_len] = 0;
    return out;
}

char *Str_Join_Q(char sep, size_t count, const char *const *Sx)
{
    size_t i;
    size_t len = 0;
    char *q = 0, *out = 0;
    for ( i = 0; !!(q = Sx[i]) && i < count; ++i )
        len += strlen(q)+(sep?1:0);
    if ( len )
    {
        char *Q = out = Str_Malloc(len+(sep?0:1));
        for ( i = 0; !!(q = Sx[i]) && i < count; ++i )
        {
            int l = strlen(q);
            if ( sep && Q != out )
                *Q++ = sep;
            memcpy(Q,q,l);
            Q += l;
        }
        *Q = 0;
    }
    else
    {
        out = Str_Malloc(1);
        *out = 0;
    }
    return out;
}

char *Str_Join_Va(char sep, va_list va)
{
    size_t len = 0;
    char *q = 0, *out = 0;
    va_list va2;
    #ifdef __GNUC__
    va_copy(va2,va);
    #else
    va2 = va;
    #endif
    while ( !!(q = va_arg(va2,char *)) )
        len += strlen(q)+(sep?1:0);
    if ( len )
    {
        char *Q = out = Str_Malloc(len+(sep?0:1));
        while ( !!(q = va_arg(va,char *)) )
        {
            int l = strlen(q);
            if ( sep && Q != out )
                *Q++ = sep;
            memcpy(Q,q,l);
            Q += l;
        }
        *Q = 0;
    }
    else
    {
        out = Str_Malloc(1);
        *out = 0;
    }
    return out;
}

char *Str_Join_0(char sep, ...)
{
    char *out;
    va_list va;
    va_start(va,sep);
    out = Str_Join_Va(sep,va);
    va_end(va);
    return out;
}

char *Str_Join_2(char sep, const char *s1, const char *s2)
{
    return Str_Join_0(sep,s1,s2,NULL);
}

char *Str_Join_3(char sep, const char *s1, const char *s2, const char *s3)
{
    return Str_Join_0(sep,s1,s2,s3,NULL);
}

char *Str_Join_4(char sep, const char *s1, const char *s2, const char *s3, const char *s4)
{
    return Str_Join_0(sep,s1,s2,s3,s4,NULL);
}

char *Str_Join_5(char sep, const char *s1, const char *s2, const char *s3, const char *s4, const char *s5)
{
    return Str_Join_0(sep,s1,s2,s3,s4,s5,NULL);
}

char *Str_Join_6(char sep, const char *s1, const char *s2, const char *s3, const char *s4, const char *s5, const char *s6)
{
    return Str_Join_0(sep,s1,s2,s3,s4,s5,s6,NULL);
}

char *Str_Join_7(char sep, const char *s1, const char *s2, const char *s3, const char *s4, const char *s5, const char *s6,
                 const char *s7)
{
    return Str_Join_0(sep,s1,s2,s3,s4,s5,s6,s7,NULL);
}

void Str_Cat_Part(char **inout, const char *S, size_t len)
{
    int count = *inout?strlen(*inout):0;
    __Elm_Append(inout,count,S,len,1,0);
}

void Str_Cat(char **inout, const char *S)
{

    size_t len = S?strlen(S):0;
    return Str_Cat_Part(inout,S,len);
}

char *Str_Fetch_Substr(const char *S, const char *prefx, const char *skip, const char *stopat)
{
    size_t j = 0;
    char *qoo;
    char *Q = strstr(S,prefx);
    if ( Q )
    {
        Q += strlen(prefx);
        if ( skip )
        l:
            for ( qoo = skip; *Q && *qoo; ++qoo )
                if ( *qoo == *Q )
                {
                    ++Q;
                    goto l;
                }

        for ( ; Q[j]; ++j )
            if ( stopat )
                for ( qoo = stopat; *qoo; ++qoo )
                    if ( *qoo == Q[j] )
                        goto ret;
    }
ret:
    if ( Q && j ) return Str_Copy_Part(Q,j);
    return 0;
}

char *Str_Reverse_Part(const char *S, size_t len)
{
    size_t i;
    char *ret;
    ret = Str_Malloc(len+1);
    for ( i = 0; i < len; ++i )
        ret[i] = S[(len-i)-1];
    ret[len] = 0;
    return ret;
}

char *Str_Reverse(const char *S)
{
    return Str_Reverse_Part(S,S?strlen(S):0);
}

char *Str_Transform(const char *S, size_t len, char (*transform)(char))
{
    size_t i;
    char *ret;
    ret = Str_Malloc(len+1);
    for ( i = 0; i < len; ++i )
        ret[i] = transform(S[i]);
    ret[i] = 0;
    return ret;
}

char *Str_Upper(const char *S)
{
    return Str_Transform(S,S?strlen(S):0,toupper);
}

char *Str_Lower(const char *S)
{
    return Str_Transform(S,S?strlen(S):0,tolower);
}

