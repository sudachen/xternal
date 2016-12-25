
#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>


wchar_t *Uni_Concat(const wchar_t *a, const wchar_t *b)
{
    size_t a_len = a?wcslen(a):0;
    size_t b_len = b?wcslen(b):0;
    wchar_t *out = Str_Malloc((a_len+b_len+1)*sizeof(wchar_t));
    if ( a_len )
        memcpy(out,a,a_len*sizeof(wchar_t));
    if ( b_len )
        memcpy(out+a_len,b,b_len*sizeof(wchar_t));
    out[a_len+b_len] = 0;
    return out;
}

wchar_t *Uni_Join_Va(int sep, va_list va)
{
    int len = 0;
    wchar_t *q, *out = 0;
    va_list va2;
    #ifdef __GNUC__
    va_copy(va2,va);
    #else
    va2 = va;
    #endif
    while ( !!(q = va_arg(va2,wchar_t *)) )
        len += (wcslen(q)+(sep?1:0))*sizeof(wchar_t);
    if ( len )
    {
        wchar_t *Q = out = Str_Malloc( (len+(sep?0:1))*sizeof(wchar_t) );
        while ( !!(q = va_arg(va,wchar_t *)) )
        {
            int l = wcslen(q);
            if ( sep && Q != out )
                *Q++ = sep;
            memcpy(Q,q,l*sizeof(wchar_t));
            Q += l;
        }
        *Q = 0;
    }
    else
    {
        out = Str_Malloc(1*sizeof(wchar_t));
        *out = 0;
    }
    return out;
}
#endif
;

wchar_t *Uni_Join_0(int sep, ...)
{
    wchar_t *out;
    va_list va;
    va_start(va,sep);
    out = Str_Unicode_Join_Va_Npl(sep,va);
    va_end(va);
    return out;
}

wchar_t *Uni_Join_2(wchar_t sep, const wchar_t *s1, const wchar_t *s2)
{
    return Uni_Join_0(sep,s1,s2,NULL);
}

wchar_t *Uni_Join_3(wchar_t sep, const wchar_t *s1, const wchar_t *s2, const wchar_t *s3)
{
    return Uni_Join_0(sep,s1,s2,s3,NULL);
}

wchar_t *Uni_Join_4(wchar_t sep, const wchar_t *s1, const wchar_t *s2, const wchar_t *s3, const wchar_t *s4)
{
    return Uni_Join_0(sep,s1,s2,s3,s4,NULL);
}

wchar_t *Uni_Join_5(wchar_t sep, const wchar_t *s1, const wchar_t *s2, const wchar_t *s3, const wchar_t *s4, const wchar_t *s5)
{
    return Uni_Join_0(sep,s1,s2,s3,s4,s5,NULL);
}

wchar_t *Uni_Join_6(wchar_t sep, const wchar_t *s1, const wchar_t *s2, const wchar_t *s3, const wchar_t *s4, const wchar_t *s5,
                    const wchar_t *s6)
{
    return Uni_Join_0(sep,s1,s2,s3,s4,s5,s6,NULL);
}

wchar_t *Uni_Join_7(wchar_t sep, const wchar_t *s1, const wchar_t *s2, const wchar_t *s3, const wchar_t *s4, const wchar_t *s5,
                    const wchar_t *s6, const wchar_t *s7)
{
    return Uni_Join_0(sep,s1,s2,s3,s4,s5,s6,s7,NULL);
}

void Uni_Cat_Part(wchar_t **inout, const wchar_t *S, size_t len)
{
    int count = *inout?wcslen(*inout):0;
    __Elm_Append(inout,count,S,len,sizeof(wchar_t),0);
}

void Uni_Cat(wchar_t **inout, const wchar_t *S)
{
    size_t len = S?wcslen(S):0;
    return Uni_Cat_Part(inout,S,len);
}

wchar_t *Uni_Cr_To_CfLr_Inplace(wchar_t **S_ptr)
{
    int capacity = 0;
    wchar_t *S = *S_ptr;
    size_t i, len = wcslen(S);
    for ( i = 0; i < len; ++i )
    {
        if ( S[i] == '\n' && ( !i || S[i-1] != '\r' ) )
        {
            len += __Elm_Insert(&S,i,len,L"\r",1,sizeof(wchar_t),&capacity);
            ++i;
        }
    }
    *S_ptr = S;
    return S;
}

wchar_t *Uni_Transform(const wchar_t *S, size_t len, wchar_t (*transform)(wchar_t))
{
    size_t i;
    wchar_t *ret;
    ret = Str_Malloc((len+1)*sizeof(wchar_t));
    for ( i = 0; i < len; ++i )
        ret[i] = transform(S[i]);
    ret[i] = 0;
    return ret;
}

wchar_t *Uni_Upper(const wchar_t *S)
{
    return Uni_Transform(S,S?wcslen(S):0,towupper);
}

wchar_t *Uni_Lower(const wchar_t *S)
{
    return Uni_Transform(S,S?wcslen(S):0,towlower);
}



#ifdef _WIN32

wchar_t *Mbt_To_Uni(const char *S)
{
    size_t len = strlen(S);
    wchar_t *ret = Str_Malloc((len+1)*sizeof(wchar_t));
    MultiByteToWideChar(CP_ACP,0,S,-1,ret,len);
    ret[len] = 0;
    return ret;
}

#endif
