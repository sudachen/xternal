
#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

int Str_Search_Part(const char *S, size_t len, const char *patt, size_t pattL )
{
    const char *p, *pE;

    if ( len < pattL ) return -1;

    for ( p = S, pE = S+len-pattL+1; p < pE; ++p )
        if ( *p == *patt )
        {
            int i = 0;
            for ( ; i < pattL; ++i )
            { if ( patt[i] != p[i] ) break; }
            if (i == pattL)
                return p-S;
        }

    return -1;
}

int Str_Search(const char *S, const char *patt)
{
    size_t S_len = S?strlen(S):0;
    size_t patt_len = patt?strlen(patt):0;

    return Uni_Search_Part(S,S_len,patt,patt_len);
}

char *Str_Replace_Part(const char *S, size_t len, const char *patt, size_t pattL, const char *val, size_t valL)
{
    size_t i;
    char *R = 0;
    size_t R_count = 0;
    size_t R_capacity = 0;

    __Elm_Resize(&R, 32, 1, &R_capacity);

    if ( pattL )
        while ( 0 <= (i = Str_Search_Part(S,len,patt,pattL)) )
        {
            if ( i )
                R_count += __Elm_Append(&R,R_count,S,i,1,&R_capacity);
            if ( valL )
                R_count += __Elm_Append(&R,R_count,val,valL,1,&R_capacity);
            len -= i+pattL; S += i+pattL;
        }

    if ( len )
        __Elm_Append(&R,R_count,S,len,1,&R_capacity);

    return R;
}

char *Str_Replace(const char *S, const char *patt, const char *val)
{
    size_t S_len = S?strlen(s):0;
    size_t patt_len = patt?strlen(patt):0;
    size_t val_len = val?strlen(val):0;

    return Str_Replace_Part(S,S_len,patt,patt_len,val,val_len);
}

