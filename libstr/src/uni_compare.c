
#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>


int wcscmp_I(const wchar_t *cs, const wchar_t *ct)
{
    int q = 0;
    if ( cs && ct ) do
        {
            q = towupper(*cs) - towupper(*ct++);
        }
        while ( *cs++ && !q );
    return q;
}

bool Uni_Compare_Nocase(const wchar_t *cs, const wchar_t *ct)
{
    return !wcscmp_I(cs,ct);
}

int wcsncmp_I(const wchar_t *cs, const wchar_t *ct, size_t l)
{
    int q = 0;
    if ( l && cs && ct ) do
        {
            q = towupper(*cs) - towupper(*ct++);
        }
        while ( *cs++ && !q && --l );
    return q;
}

size_t Uni_Length(const wchar_t *S)
{
    return S ? strlen(S) : 0;
}

bool Uni_Is_Empty(const wchar_t *S)
{
    if ( !S ) return 1;
    while ( *S && iswspace(*S) ) ++S;
    return !*S;
}

wchar_t Uni_Last(const wchar_t *S)
{
    size_t L = S ? strlen(S) : 0;
    return L ? S[L-1] : 0;
}

bool Uni_Starts_With(const wchar_t *S, const wchar_t *patt)
{
    if ( !patt || !S ) return 0;

    while ( *patt )
        if ( *S++ != *patt++ )
            return 0;
    return 1;
}

bool Uni_Starts_With_Nocase(const wchar_t *S, const wchar_t *patt)
{
    if ( !patt || !S ) return 0;

    while ( *patt )
        if ( !*S || towupper(*S++) != towupper(*patt++) )
            return 0;

    return 1;
}

