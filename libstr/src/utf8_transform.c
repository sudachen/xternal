
#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>


static const char Utf8_Char_Length[] =
{
    /* Map UTF-8 encoded prefix byte to sequence length.  zero means
    illegal prefix.  see RFC 2279 for details */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 0, 0
};

wchar_t Utf8_Char_Decode(const void *S,size_t *cnt)
{
    const uint8_t *text = S;
    int c = -1;
    int c0 = *text++;
    if ( cnt ) ++*cnt;
    if (c0 < 0x80)
        c = (wchar_t)c0;
    else
    {
        int c1 = 0;
        int c2 = 0;
        int c3 = 0;
        int l = Utf8_Char_Length[c0];
        switch ( l )
        {
            case 2:
                if ( (c1 = *text) > 0 )
                    c = ((c0 & 0x1f) << 6) + (c1 & 0x3f);
                if ( cnt ) ++*cnt;
                break;
            case 3:
                if ( (c1 = *text) > 0 && (c2 = text[1]) > 0 )
                    c = ((c0 & 0x0f) << 12) + ((c1 & 0x3f) << 6) + (c2 & 0x3f);
                if ( cnt ) *cnt += 2;
                break;
            case 4: // hm, UCS4 ????
                if ( (c1 = *text) > 0 && (c2 = text[1]) > 0 && (c3 = text[2]) > 0 )
                    c = ((c0 & 0x7) << 18) + ((c1 & 0x3f) << 12) + ((c2 & 0x3f) << 6) + (c3 & 0x3f);
                if ( cnt ) *cnt += 3;
                break;
            default:
                break;
        }
    }
    return c;
}

int Utf8_Wide_Length(wchar_t c)
{
    if ( c < 0x80 )
        return 1;
    else if ( c < 0x0800 )
        return 2;
    else
        return 3;
    return 0;
}

char *Utf8_Wide_Encode(char *out,wchar_t c,size_t *cnt)
{
    int l = 0;
    if ( c < 0x80 )
    {
        *out++ = (char)c;
        l = 1;
    }
    else if ( c < 0x0800 )
    {
        *out++ = (char)(0xc0 | (c >> 6));
        *out++ = (char)(0x80 | (c & 0x3f));
        l = 2;
    }
    else
    {
        *out++ = (char)(0xe0 | (c >> 12));
        *out++ = (char)(0x80 | ((c >> 6) & 0x3f));
        *out++ = (char)(0x80 | (c & 0x3f));
        l = 3;
    }
    if ( cnt ) *cnt += l;
    return out;
}

wchar_t Utf8_Get_Wide(char const **S)
{
    wchar_t out = 0;
    if ( S && *S )
    {
        size_t cnt = 0;
        out = Utf8_Char_Decode(*S,&cnt);
        while ( **S && cnt-- ) ++*S;
    }
    return out;
}

char *Utf8_Skip(char *S,size_t count)
{
    if ( S )
        while ( *S && count-- )
        {
            int q = Utf8_Char_Length[(uint8_t)*S];
            if ( q ) while ( q-- && *S ) ++S;
            else ++S;
        }
    return S;
}

wchar_t *Utf8_To_Uni_Convert(const char *S, wchar_t *out, size_t max_len)
{
    size_t i = 0;
    if ( S )
    {
        for (; *S && i < max_len; ) { out[i++] = Utf8_Get_Wide(&S); }
    }
    if ( i < max_len ) out[i] = 0;
    return out;
}

wchar_t *Utf8_To_Uni(const char *S)
{
    wchar_t *out = 0;
    if ( S )
    {
        size_t n = 0;
        char *Q = S;
        while ( *Q ) { Utf8_Get_Wide(&Q); ++n; }
        out = Str_Malloc((n+1)*sizeof(wchar_t));
        for ( n = 0; *S; ) { out[n++] = Utf8_Get_Wide(&S); }
        out[n] = 0;
    }
    return out;
}

char *Uni_To_Utf8_Convert(const wchar_t *S, char *out, size_t max_len)
{
    size_t i = 0;
    if ( S )
    {
        for (; *S && i + Utf8_Wide_Length(*S) < max_len; )
        { Utf8_Wide_Encode(out+i,*S++,&i); }
    }
    if ( i < max_len ) out[i] = 0;
    return out;
}

char *Uni_To_Utf8(const wchar_t *S)
{
    char *out = 0;
    if ( S )
    {
        size_t n = 0;
        const wchar_t *Q = S;
        while ( *Q )
            n += Utf8_Wide_Length(*Q++);
        out = Str_Malloc(n+1);
        for ( n = 0; *S; )
            Utf8_Wide_Encode(out+n,*S++,&n);
        out[n] = 0;
    }
    return out;
}

char *Utf8_Transform(const char *S, size_t len, wchar_t (*transform)(wchar_t) )
{
    const char *E;
    char *R = 0;
    int R_capacity = 1;
    int R_count = 0;

    if ( S )
    {
        R_capacity = L+1;
        for ( E = S+len; S < E; )
        {
            int wc_L = 0;
            uint8_t b[8];
            wchar_t wc = Utf8_Get_Wide(&S);
            wc = transform(wc);
            Utf8_Wide_Encode(b,wc,&wc_L);
            R_count += __Elm_Append(&R,R_count,b,wc_L,1,&R_capacity);
        }
    }

    __Elm_Append(&R,R_count,"\0",1,1,&R_capacity);
    return R;
}

char *Utf8_Upper(const char *S)
{
    return Utf8_Transform(S,S?strlen(S):0,towupper);
}

char *Utf8_Lower(const char *S)
{
    return Utf8_Transform(S,S?strlen(S):0,towlower);
}


#ifdef _WIN32

char *Mbt_To_Utf8(const char *S)
{
    wchar_t *tmp = Mbt_To_Uni(S);
    char *ret = Uni_To_Utf8(tmp);
    Str_Free(tmp);
    return ret;
}

#endif
