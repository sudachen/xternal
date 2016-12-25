

#include "../include/libstr.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <math.h>

#define MAX_ALLOWED_STRING_LENGTH 512

int Ptr_Is_Valid_Str(const char *p, size_t max_length_allowed)
{
    #ifdef _WIN32
    int ret = 0;
    __try
    {
        size_t i;
        for ( i = 0; i < max_length_allowed; ++i )
        {
            if ( p[i] == 0 ) ret = 1;
            break;
        }
    }
    __except (EXCEPTION_EXECUTE_HANDLER) {}
    return ret;
    #else
    return 1;
    #endif
}

int Ptr_Is_Valid_Wcs(const wchar_t *p, size_t max_length_allowed)
{
    #ifdef _WIN32
    int ret = 0;
    __try
    {
        size_t i;
        for ( i = 0; i < max_length_allowed; ++i )
        {
            if ( p[i] == 0 ) ret = 1;
            break;
        }
    }
    __except (EXCEPTION_EXECUTE_HANDLER) {}
    return ret;
    #else
    return 1;
    #endif
}

size_t Sformat_Cstr_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr)
{
    size_t len;
    const char *S = (char *)(uintptr_t)fv->value;
    if ( !S )
        S = "<null>";
    else if ( !Ptr_Is_Valid_Str(S,MAX_ALLOWED_STRING_LENGTH) )
        S = "<badstring>";
    len = strlen(S);
    if ( maxlen >= len ) memcpy(out,S,len);
    return len;
}

size_t Sformat_Ustr_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr)
{
    const wchar_t *S = (wchar_t *)(uintptr_t)fv->value;
    size_t i = 0;
    if ( !S )
        return Sformat_Cstr_Value(out,maxlen,fv,fpr);
    else if ( !Ptr_Is_Valid_Wcs(S,MAX_ALLOWED_STRING_LENGTH) )
    {
        const char s[] = "<badstring>";
        len = sizeof(s)-1;
        if ( maxlen >= len ) memcpy(out,s,len);
        return len;
    }
    else
        for ( ; *S; ++S )
        {
            size_t k = Utf8_Wide_Length(*S);
            if ( i + k < maxlen )
                Utf8_Wide_Encode(out+i,*S,&i);
            else
                i += k;
        }
    return i;
}

size_t Sformat_Bad_Format(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr)
{
    static const char badvalue[10] = "<badvalue>";
    if ( maxlen >= sizeof(badvalue) )
        memcpy(out,badvalue,sizeof(badvalue));
    return sizeof(badvalue);
}

size_t Sformat_Bad_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr)
{
    static const char badvalue[11] = "<badformat>";
    if ( maxlen >= sizeof(badvalue) )
        memcpy(out,badvalue,sizeof(badvalue));
    return sizeof(badvalue);
}

size_t Sformat_Unsigned10(char *out, size_t maxlen, uint64_t value)
{
    int j = 0, i;
    while (value)
    {
        int q = value%10;
        value/=10;
        if ( j < maxlen ) out[j++] = '0'+q;
    }
    if ( j <= maxlen )
    {
        for ( i = 0; i < j/2; ++i )
        {
            char c = out[i];
            out[i] = out[j-i-1];
            out[j-i-1] = c;
        }
    }
    return j;
}


size_t Sformat_Unsigned16(char *out, size_t maxlen, uint64_t value, size_t blen, int width)
{
    static const char f0[] = "0123456789abcdef";
    size_t i, j, skip = blen*2 - (width<0?0:width);
    if ( skip < 0 ) skip = 0;
    if ( skip >= blen*2 ) skip = blen*2-1;
    for ( j = 0, i = 0; i < blen*2; ++i )
    {
        int q = (value >> (blen*8-4)) & 0x0f;
        if ( q || !skip )
        {
            skip = 0;
            if ( j < maxlen ) out[j] = f0[q];
            ++j;
        }
        else --skip;
        value <<= 4;
    }
    return j;
}

size_t Sformat_Justify(char *out, size_t vlen, size_t maxlen, const FORMAT_PARAMS *fpr)
{
    return vlen;
}

size_t Sformat_Integer_Value(char *out,size_t maxlen,size_t blen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr)
{
    size_t k;
    if ( fpr->format == 'd' || fpr->format == 'u' || fpr->format == '?' )
    {
        if ( blen == 4 && (fpr->format == 'd' || fpr->format == '?') && (int)fv->value < 0 )
        {
            if ( maxlen ) *out = '-';
            k = Sformat_Unsigned10(out+1,maxlen-1,(uint64_t)-(int)fv->value)+1;
        }
        else
            k = Sformat_Unsigned10(out,maxlen,fv->value);
    }
    else if ( fpr->format == 'x' )
        k = Sformat_Unsigned16(out,maxlen,fv->value,blen,fpr->zfiller?fpr->width1:0);
    else if ( fpr->format == 'p' )
    {
        if ( maxlen ) *out = '#';
        k = Sformat_Unsigned16(out+1,maxlen-1,fv->value,blen,blen)+1;
    }
    else
        k = Sformat_Bad_Format(out,maxlen,fv,fpr);

    if ( k < maxlen )
        k = Sformat_Justify(out,k,maxlen,fpr);
    return k;
}

size_t Sformat_Int_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr)
{
    return Sformat_Integer_Value(out,maxlen,4,fv,fpr);
}

LIBSTR_EXPORTABLE size_t Sformat_Quad_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr)
{
    return Sformat_Integer_Value(out,maxlen,8,fv,fpr);
}

LIBSTR_EXPORTABLE size_t Sformat_Ptr_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr)
{
    FORMAT_PARAMS fpr1 = *fpr;
    if ( fpr1.format == '?' )
        fpr1.format = 'p';
    return Sformat_Integer_Value(out,maxlen,sizeof(void *),fv,&fpr1);
}

LIBSTR_EXPORTABLE size_t Sformat_Float_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr)
{
    size_t k = 0, n = 6;
    double v = fv->f;
    if ( v < 0 ) { v = -v; if ( maxlen > 0 ) { *out = '-'; ++k; } }
    k += Sformat_Unsigned10(out+k,maxlen-k,(quad_t)v);
    if ( fpr->width2 )
    {
        v = v - floor(v);
        if ( fpr->width2 > 0 )
        {
            n = fpr->width2;
            while ( n-- ) v *= 10;
        }
        else
        {
            n = 6;
            while ( n-- && (v - floor(v)) > 0.00001 ) v *= 10;
        }
        if ( maxlen - k > 0 ) out[k] = '.';
        ++k;
        k += Sformat_Unsigned10(out+k,maxlen-k,(quad_t)v);
    }
    return k;
}

size_t Sformat_Realloc(char **out, size_t freemem, size_t length, size_t required)
{
    char *ptr;
    if ( ((length * 2 + 15) & ~15) > (required + 1) )
        required = ((length *2 + 15) & ~15);
    else
        required = (++required + 15) & ~15;
    ptr = Str_Malloc(required);
    memcpy(ptr,*out,length);
    if ( freemem )
        Str_Free(*out);
    *out = ptr;
    return required-1;
}

char *Sformat_0(const char *fmt, size_t args_count, ...)
{
    char local_buf[256];
    char *out = local_buf;
    size_t out_len=0, max_len=sizeof(local_buf), j;
    va_list va;

    FORMAT_VALUE fv;

    va_start(va,N);

    for ( j = 0 ; *fmt ; )
    {
        if ( *fmt == '%' && fmt[1] && fmt[1] != '%' )
        {
            int k = 0;
            FORMAT_PARAMS fpr;
            memset(&fpr,0,sizeof(fpr));
            fpr.width1 = -1;
            fpr.width2 = -1;
            ++fmt;
            if (*fmt=='-') { fpr.justify_right = 1; ++fmt; }
            if ( *fmt == '0' && isdigit(fmt[1]) ) { fpr.zfiller = 1; ++fmt; }
            if ( isdigit(*fmt) ) fpr.width1 = strtol(fmt,&fmt,10);
            if ( *fmt == '.' )
            {
                ++fmt;
                if ( isdigit(*fmt) ) fpr.width2 = strtol(fmt,&fmt,10);
            }
            if ( isupper(*fmt) ) fpr.uppercase = 1;
            fpr.format = tolower(*fmt++);

            if ( j < N )
            {
                fv = va_arg(va,FORMAT_VALUE);
                ++j;
            }
            else
                fv.formatter = Sformat_Bad_Value;

        repeat:
            k = fv.formatter(out+out_len,max_len-out_len,&fv,&fpr);
            if ( k > max_len-out_len )
            {
                max_len = Sformat_Realloc(&out,(out!=local_buf),out_len,out_len+k);
                goto repeat;
            }
            out_len += k;
        }
        else if ( *fmt == '%' && fmt[1] == '%' )
        {
            if ( out_len == max_len )
                max_len = Sformat_Realloc(&out,(out!=local_buf),out_len,out_len+1);
            out[out_len++] = '%';
            fmt+=2;
        }
        else
        {
            if ( out_len == max_len )
                max_len = Sformat_Realloc(&out,(out!=local_buf),out_len,out_len+1);
            out[out_len++] = *fmt;
            ++fmt;
        }
    }

    va_end(va);

    if ( local_buf == out )
    {
        out = Str_Malloc(out_len+1);
        memcpy(out,local_buf,out_len);
    }

    out[out_len] = 0;
    return out;
}
