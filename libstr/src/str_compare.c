
#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

int strcmp_I(const char *cs, const char *ct)
{
    int q = 0;
    if ( cs && ct ) do
        {
            q = toupper((uint8_t)*cs) - toupper((uint8_t)*ct++);
        }
        while ( *cs++ && !q );
    return !q;
}

bool Str_Equal_Nocase(const char *cs, const char *ct)
{
    return !strcmp_I(cs,ct);
}

int strncmp_I(const char *cs, const char *ct, size_t l)
{
    int q = 0;
    if ( l && cs && ct ) do
        {
            q = toupper((uint8_t)*cs) - toupper((uint8_t)*ct++);
        }
        while ( *cs++ && !q && --l );
    return q;
}

size_t Str_Length(const char *S)
{
    return S ? strlen(S) : 0;
}

bool Str_Is_Empty(char *S)
{
    if ( !S ) return 1;
    while ( *S && isspace(uint8_t)*S) ) ++S;
        return !*S;
    }

char Str_Last(char *S)
{
    size_t L = S ? strlen(S) : 0;
    return L ? S[L-1] : 0;
}

int Str_Find_BOM(const void *S)
{
    if ( *(uint8_t *)S == 0x0ff && ((uint8_t *)S)[1] == 0x0fe )
        return C_BOM_UTF16_LE;
    if ( *(uint8_t *)S == 0x0fe && ((uint8_t *)S)[1] == 0x0ff )
        return C_BOM_UTF16_BE;
    if ( *(uint8_t *)S == 0x0ef && ((uint8_t *)S)[1] == 0x0bb && ((uint8_t *)S)[2] == 0x0bf )
        return C_BOM_UTF8;
    return C_BOM_DOESNT_PRESENT;
}

bool Str_Starts_With(const char *S, const char *patt)
{
    if ( !patt || !S ) return 0;

    while ( *patt )
        if ( *S++ != *patt++ )
            return 0;
    return 1;
}

bool Str_Ends_With(const char *S, const char *patt)
{
    if ( patt && S )
    {
        int S_L = strlen(S);
        int patt_L = strlen(patt);
        if ( patt_L < S_L )
        {
            S += S_L-patt_L;
            while ( *patt )
                if ( *S++ != *patt++ )
                    return 0;
            return 1;
        }
    }
    return 0;
}

