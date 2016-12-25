
#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

uint64_t Bits_Pop(uint64_t *r, const void *b, size_t *bits_count, size_t count)
{
    uint8_t const *bits = (uint8_t const *)b;
    size_t bC = *bits_count - 1;
    size_t Q = min(count,bC+1);
    size_t r_count = Q;

    if ( bC < 0 ) return 0;

    while ( ((bC+1) &7) && Q )
    {
        *r = (*r << 1) | ((bits[bC/8] >> (bC%8))&1);
        --bC; --Q;
    }

    while ( bC >= 0 && Q )
        if ( Q > 7 )
        {
            *r = ( *r << 8 ) | bits[bC/8];
            Q -= 8; bC -= 8;
        }
        else
        {
            *r = (*r << Q) | bits[bC/8] >> (8-Q);
            bC -= Q; Q = 0;
        }

    *bits_count = bC + 1;
    return r_count;
}

void Bits_Push(uint64_t bits, const void *b, size_t *bits_count, size_t count)
{
    while ( count-- )
    {
        int q = *bits_count;
        uint8_t *d = ((uint8_t *)b+q/8);
        *d = (uint8_t)(((bits&1) << (q%8)) | (*d&~(1<<(q%8))));
        ++*bits_count;
        bits >>= 1;
    }
}

char *Str_Xbit_Encode(const void *data, size_t count /*of bits*/, size_t BC, const char *bit_table, char *out )
{
    char *Q = out;
    uint64_t q = 0;
    if ( count%BC )
    {
        Bits_Pop(&q,data,&count,count%BC);
        *Q++ = bit_table[q];
    }
    while ( count )
    {
        q = 0;
        Bits_Pop(&q,data,&count,BC);
        *Q++ = bit_table[q];
    }
    return out;
}

char *Str_Qbit_Encode(const void *data,size_t len, const char *tbl, size_t btl, char *out)
{
    if ( data && len )
    {
        int rq_len = (len*8+btl-1)/btl;
        if ( !out )
            out = Str_Malloc(rq_len+1);
        memset(out,0,rq_len+1);
        return Str_Xbit_Encode(data,len*8,btl,tbl,out);
    }
    return 0;
}

void *Str_Xbit_Decode(const char *inS, size_t len, const int BC, const char *bit_table, void *out)
{
    int count = 0;
    const uint8_t *S = ((const uint8_t *)inS+len)-1, *E = (const uint8_t *)inS-1;
    while ( S != E )
    {
        uint8_t bits = bit_table[*S--];
        if ( bits == 255 )
            return 0;
        Bits_Push(bits,out,&count,BC);
    }
    return out;
}

void *Str_Qbit_Decode(const char *S,size_t *len,const char *tbl,size_t btl)
{
    void *out;
    size_t S_len = S ? strlen(S): 0;
    size_t rq_len = S_len ? (S_len*btl+7)/8 : 0;

    if ( !rq_len )
        return 0;

    out = Str_Malloc(rq_len);
    memset(out,0,rq_len);
    if ( !Str_Xbit_Decode(S,S_len,btl,tbl,out) )
    {
        Str_Free(out);
        return 0;
    }
    if ( len ) *len = rq_len;
    return out;
}

char *Str_Hex_Byte(uint8_t val,char pfx,void *out)
{
    static char symbols[] =
    { '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' };
    char *q = (char *)out;
    switch ( pfx&0x7f )
    {
        case 'x':
            *q++='0'; *q++='x';
            break;
        case '\\':
            *q++='\\'; *q++='x';
            break;
        case '%':
            *q++='%';
            break;
        default: break;
    }
    *q++ = symbols[(val>>4)];
    *q++ = symbols[val&0x0f];
    if ( !pfx&0x80 )
        *q = 0;
    return out;
}

char *Str_Hex_Encode(const void *data, size_t len, char *out)
{
    if ( data && len )
    {
        size_t i;
        size_t rq_len = len*2;
        if ( !out )
            out = Str_Malloc(rq_len+1);
        memset(out,0,rq_len+1);
        for ( i = 0; i < len; ++i )
            Str_Hex_Byte(((uint8_t *)data)[i],0,out+i*2);
        return out;
    }
    return 0;
}

uint8_t Str_Unhex_Byte(const char *S,int pfx,size_t *cnt)
{
    int i;
    uint8_t r = 0;
    uint8_t *c = (uint8_t *)S;
    if ( pfx )
    {
        if ( *c == '0' && c[1] == 'x' ) c+=2;
        else if ( *c == '\\' && c[1] == 'x' ) c+=2;
        else if ( *c == '%' ) ++c;
    }
    for ( i=4; i >= 0; i-=4, ++c )
    {
        STR_UNHEX_HALF_OCTET(c,r,i);
    }
    if ( cnt ) *cnt = c-(uint8_t *)S;
    return r;
}

void *Str_Hex_Decode(const char *S,size_t *len,void *out)
{
    size_t S_len = S ? strlen(S): 0;
    size_t rq_len = S_len ? S_len/2 : 0;

    if ( rq_len )
    {
        size_t i;

        if ( !out )
            out = Str_Zero_Malloc(rq_len+1);

        for ( i = 0; i < rq_len; ++i )
            ((uint8_t *)out)[i] = Str_Unhex_Byte(S+i*2,0,0);
        if ( len ) *len = rq_len;
        return out;
    }

    return 0;
}

void Quad_To_Hex16(uint64_t val,char *out)
{
    size_t i;
    for ( i = 0; i < 8; ++i )
        Str_Hex_Byte((uint8_t)(val>>(i*8)),0x80,out+i*2);
}

void Unsigned_To_Hex8(uint32_t val,char *out)
{
    size_t i;
    for ( i = 0; i < 4; ++i )
        Str_Hex_Byte((uint8_t)(val>>(i*8)),0x80,out+i*2);
}

void Unsigned_To_Hex4(uint32_t val,char *out)
{
    size_t i;
    for ( i = 0; i < 2; ++i )
        Str_Hex_Byte((uint8_t)(val>>(i*8)),0x80,out+i*2);
}

void Unsigned_To_Hex2(uint32_t val,char *out)
{
    Str_Hex_Byte((uint8_t)(val),0x80,out);
}

uint64_t Hex16_To_Quad(const char *S)
{
    uint64_t ret = 0;
    int i;
    for ( i = 0; i < 8; ++i )
        ret |= ( (uint64_t)Str_Unhex_Byte(S+i*2,0,0) << (i*8) );
    return ret;
}

uint32_t Hex8_To_Unsigned(const char *S)
{
    uint32_t ret = 0;
    int i;
    for ( i = 0; i < 4; ++i )
        ret |= ( (uint32_t)Str_Unhex_Byte(S+i*2,0,0) << (i*8) );
    return ret;
}

uint32_t Hex4_To_Unsigned(const char *S)
{
    uint32_t ret = 0;
    int i;
    for ( i = 0; i < 2; ++i )
        ret |= ( (uint32_t)Str_Unhex_Byte(S+i*2,0,0) << (i*8) );
    return ret;
}

uint32_t Hex2_To_Unsigned(const char *S)
{
    return (uint32_t)Str_Unhex_Byte(S,0,0);
}

