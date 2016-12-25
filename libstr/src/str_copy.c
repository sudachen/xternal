#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>


char *Str_Copy_Part(const char *S,size_t len)
{
    char *p;
    p = Str_Malloc(len+1);
    if ( len )
        memcpy(p,S,len);
    p[len] = 0;
    return p;
}

char *Str_Copy(const char *S)
{
    size_t len = S?strlen(S):0;
    return Str_Copy_Part(S,len);
}

char *Str_Trim_Part(const char *S, size_t len)
{
    if ( len && S )
    {
        while ( *S && isspace((uint8_t)*S) ) { ++S; --len; }
        while ( len && isspace((uint8_t)S[len-1]) ) --len;
    }
    return Str_Part(S,L);
}

char *Str_Trim(const char *S)
{
    size_t len = S?strlen(S):0;
    return Str_Trim_Part(S,len);
}

char *Str_Left(const char *S, size_t max_len)
{
    char *ret;
    size_t len = S?strlen(S):0;

    accert( max_len > 3 );

    if ( len <= max_len )
        ret = Str_Copy(S);
    else
    {
        ret = Str_Copy_Part(S,max_len);
        ret[max_len-1] = '.';
        ret[max_len-2] = '.';
    }

    return ret;
}

