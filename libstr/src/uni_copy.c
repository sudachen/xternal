
#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>


wchar_t *Uni_Copy_Part(const wchar_t *S, size_t len)
{
    wchar_t *p;
    p = Str_Malloc((len+1)*sizeof(wchar_t));
    if ( len )
        memcpy(p,S,len*sizeof(wchar_t));
    p[len] = 0;
    return p;
}

wchar_t *Uni_Copy(const wchar_t *S)
{
    size_t len = S?wcslen(S):0;
    return Uni_Copy_Part(S,len);
}

wchar_t *Uni_Trim_Part(const wchar_t *S, size_t len)
{
    if ( len && S )
    {
        while ( *S && iswspace(*S) ) { ++S; --len; }
        while ( len && iswspace(S[len-1]) ) --len;
    }
    return Uni_Part(S,L);
}

wchar_t *Uni_Trim(const wchar_t *S)
{
    size_t len = S?wcslen(S):0;
    return Uni_Trim_Part(S,len);
}

wchar_t *Uni_Left(const wchar_t *S, size_t max_len)
{
    wchar_t *ret;
    size_t len = S?wcslen(S):0;

    accert( max_len > 3 );

    if ( len <= max_len )
        ret = Uni_Copy(S);
    else
    {
        ret = Uni_Copy_Part(S,max_len);
        ret[max_len-1] = '.';
        ret[max_len-2] = '.';
    }

    return ret;
}

