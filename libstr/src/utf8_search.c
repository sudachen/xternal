
#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

bool Utf8_Equal_Nocase_Len(const char *S, const char *T, size_t L)
{
    wchar_t c;
    const char *Se = S+L;
    const char *Te = T+L;

    if (!L) return 0;

    do
    {
        if ( (c = Utf8_Get_Wide(&S)) != Utf8_Get_Wide(&T) )
            return 0;
    }
    while ( c && S < Se && T < Te );
    return 1;
}

static int Utf8_Submatch(const char *S, const char *patt, int nocase);
static int Utf8_Submatch_Nocase(const char *S, const char *patt)
{
    char *SS = S;

    if ( *S )
    {
        do
        {
            int l = Utf8_Char_Length[(uint8_t)*S];
            if ( l == 1 )
                ++S;
            else
            {
                if ( *(S+l) )
                    if ( Utf8_Submatch_Nocase(S+l,patt) )
                        return 1;
                break;
            }
        }
        while ( *S );

        for ( ; S != SS; --S )
            if ( Utf8_Submatch(S,patt,1) )
                return 1;
    }

    return 0;
}

int Utf8_Submatch(const char *S, const char *patt, int nocase)
{
    if ( S && patt )
    {
        while ( *S && *patt )
        {
            const char *SS = S;
            int c = nocase ? Utf8_Get_Wide(&SS) : *SS++;
            int pc = nocase ? Utf8_Get_Wide(&patt) : *patt++;

            switch ( pc )
            {
                case '?': S = SS; break;
                case '*':
                    if ( !*patt )
                        return 1;
                    if ( nocase )
                        return Utf8_Submatch_Nocase(SS,patt);
                    else
                    {
                        while ( *SS ) ++SS;
                        while ( S != --SS )
                            if ( Utf8_Submatch(SS,patt,0) )
                                return 1;
                    }
                    return 0;
                //case '[':
                default:
                    if ( c != pc ) return 0;
                    S = SS;
            }
        }
        return !*S && *S==*patt;
    }
    return 0;
}

int Utf8_Match(const char *S, const char *patt)
{
    return  Utf8_Submatch(S,patt,0);
}

int Utf8_Match_Nocase(const char *S, const char *patt)
{
    return  Utf8_Submatch(S,patt,1);
}
