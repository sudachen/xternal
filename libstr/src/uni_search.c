
#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>


int Uni_Search_Part( const wchar_t *S, size_t len, const wchar_t *patt, size_t pattL, int nocase)
{
    const wchar_t *p, *pE;
    if ( len < pattL ) return -1;

    for ( p = S, pE = S+len-pattL+1; p < pE; ++p )
        if ( *p == *patt )
        {
            int i = 0;
            for ( ; i < pattL; ++i )
                if ( !nocase )
                { if ( patt[i] != p[i] ) break; }
                else
                { if ( towupper(patt[i]) != towupper(p[i]) ) break; }
            if (i == pattL)
                return p-S;
        }

    return -1;
}

int Uni_Search(const wchar_t *S, const wchar_t *patt)
{
    size_t S_len = S?wcslen(S):0;
    size_t patt_len = patt?wcslen(patt):0;

    return Uni_Search_Part(S,S_len,patt,patt_len,0);
}

int Uni_Search_Nocase(const wchar_t *S, const wchar_t *patt)
{
    size_t S_len = S?wcslen(S):0;
    size_t patt_len = patt?wcslen(patt):0;

    return Uni_Search_Part(S,S_len,patt,patt_len,1);
}

wchar_t *Uni_Replace_Part(const wchar_t *S, size_t len, const wchar_t *patt, size_t pattL, const wchar_t *val, size_t valL,
                          int nocase)
{
    size_t i;
    wchar_t *R = 0;
    size_t R_count = 0;
    size_t R_capacity = 0;

    if ( pattL )
        while ( 0 <= (i = Uni_Search_Part(S,len,patt,pattL,nocase)) )
        {
            if ( i )
                R_count += __Elm_Append(&R,R_count,S,i,sizeof(wchar_t),&R_capacity);
            if ( valL )
                R_count += __Elm_Append(&R,R_count,val,valL,sizeof(wchar_t),&R_capacity);
            S += i+pattL; len -= i+pattL;
        }

    if ( len )
        __Elm_Append(&R,R_count,S,len,sizeof(wchar_t),&R_capacity);

    return R;
}

wchar_t *Uni_Replace(const wchar_t *S, const wchar_t *patt, const wchar_t *val)
{
    size_t S_len = S?wcslen(s):0;
    size_t patt_len = patt?wcslen(patt):0;
    size_t val_len = val?wcslen(val):0;

    return Uni_Replace_Part(S,S_len,patt,patt_len,val,val_len,0);
}

wchar_t *Uni_Replace_Nocase(const wchar_t *S, const wchar_t *patt, const wchar_t *val)
{
    size_t S_len = S?wcslen(s):0;
    size_t patt_len = patt?wcslen(patt):0;
    size_t val_len = val?wcslen(val):0;

    return Uni_Replace_Part(S,S_len,patt,patt_len,val,val_len,1);
}
