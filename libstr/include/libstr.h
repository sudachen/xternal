
/*

    Copyright (c) 2016, Alexey Sudachen, https://goo.gl/RlZcQR

*/

#pragma once

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <time.h>

#if ( defined _DLL && !defined LIBSTR_STATIC ) || defined LIBSTR_DLL || defined LIBSTR_BUILD_DLL
#  if defined LIBSTR_BUILD_DLL
#    define LIBSTR_EXPORTABLE __declspec(dllexport)
#  else
#    define LIBSTR_EXPORTABLE __declspec(dllimport)
#  endif
#else
#define LIBSTR_EXPORTABLE
#endif

#define __Str_Forceinline static __forceinline
#define __Str_Noreturn __declspec(noreturn)
#define __Str_Assert(Expr) _EVAL(_Static_assert(Expr,#Expr))
#define Str_Require(Expr) assert(Expr)

#define VARGS_COUNT_(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,...) a15
#define VARGS_COUNT(...) _EVAL(VARGS_COUNT_(__VA_ARGS__,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0))
#define VARGS_PARAMS(_Q,...) _EVAL(_CONCAT2(_PARAM_,VARGS_COUNT(__VA_ARGS__))(_Q,__VA_ARGS__))
#define _PARAM_1(_Q,a) _Q(a)
#define _PARAM_2(_Q,b,a) _Q(b), _Q(a)
#define _PARAM_3(_Q,c,b,a) _Q(c), _PARAM_2(_Q,b,a)
#define _PARAM_4(_Q,d,c,b,a) _Q(d), _PARAM_3(_Q,c,b,a)
#define _PARAM_5(_Q,e,d,c,b,a) _Q(e), _PARAM_4(_Q,d,c,b,a)
#define _PARAM_6(_Q,f,e,d,c,b,a) _Q(f), _PARAM_5(_Q,e,d,c,b,a)
#define _PARAM_7(_Q,g,f,e,d,c,b,a) _Q(g), _PARAM_6(_Q,f,e,d,c,b,a)
#define _PARAM_8(_Q,i,g,f,e,d,c,b,a) _Q(i), _PARAM_7(_Q,g,f,e,d,c,b,a)
#define _PARAM_9(_Q,j,i,g,f,e,d,c,b,a) _Q(j), _PARAM_8(_Q,i,g,f,e,d,c,b,a)
#define _PARAM_10(_Q,k,j,i,g,f,e,d,c,b,a) _Q(k), _PARAM_9(_Q,j,i,g,f,e,d,c,b,a)
#define _EVAL(a) a
#define _COMPOSE2(a,b)      a##b
#define _COMPOSE3(a,b,c)    a##b##c
#define _COMPOSE4(a,b,c,d)  a##b##c##d
#define _ID(Name,Line)      _COMPOSE4(_YoC_Label_,Name,_,Line)
#define _LOCAL_ID(Name)     _ID(Name,__LINE__)
#define _CONCAT2_(a,b)      _COMPOSE2(a,b)
#define _CONCAT2(a,b)       _CONCAT2_(a,b)
#define _CONSTSTR_(a)       #a
#define _CONSTSTR(a)        _CONSTSTR_(a)

typedef struct
{
    void **at;
    size_t count;
    size_t capacity;
    void (*f_free_valptr)(void *);
} ARRAY;

typedef struct
{
    union
    {
        uint8_t *at;
        char    *chr;
    };
    size_t count;
    size_t capacity;
} BUFFER;

typedef struct DICTO_REC DICTO_REC;
typedef struct
{
    DICTO_REC **table;
    size_t count;
    size_t width;
    void (*f_free_valptr)(void *);
} DICTO;

#define Str_5bit_Encode(S,L,Out) Str_Qbit_Encode(S,L,"0123456789abcdefgjkmnpqrstuvwxyz",5,Out)
#define Str_5bit_Encode_Upper(S,L,Out) Str_Qbit_Encode(S,L,"0123456789ABCDEFGJKMNPQRSTUVWXYZ",5,Out)
#define Str_6bit_Encode(S,L,Out) Str_Qbit_Encode(S,L,"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-",6,Out)
#define Str_5bit_Decoding_Table \
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\xff\xff\xff\xff\xff\xff"\
    "\xff\x0a\x0b\x0c\x0d\x0e\x0f\x10\xff\xff\x11\x12\xff\x13\x14\xff"\
    "\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\xff\xff\xff\xff\xff"\
    "\xff\x0a\x0b\x0c\x0d\x0e\x0f\x10\xff\xff\x11\x12\xff\x13\x14\xff"\
    "\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"
#define Str_6bit_Decoding_Table \
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\xff\xff\xff\xff\xff\xff"\
    "\xff\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f\x30\x31\x32"\
    "\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\xff\xff\xff\xff\x3e"\
    "\xff\x0a\x0b\x0c\x0d\x0e\x0f\x10\xff\xff\x11\x12\xff\x13\x14\xff"\
    "\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"\
    "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"
#define Str_5bit_Decode(S,L) Str_Qbit_Decode(S,L,Str_5bit_Decoding_Table,5)
#define Str_6bit_Decode(S,L) Str_Qbit_Decode(S,L,Str_6bit_Decoding_Table,6)

#define STR_UNHEX_HALF_OCTET(c,r,i) \
    if ( *(c) >= '0' && *(c) <= '9' ) \
        r |= (*(c)-'0') << (i); \
    else if ( *(c) >= 'a' && *(c) <= 'f' ) \
        r |= (*(c)-'a'+10) << (i); \
    else if ( *(c) >= 'A' && *(c) <= 'F' ) \
        r |= (*(c)-'A'+10) << (i); \
     
enum
{
    STR_BOM_DOESNT_PRESENT = 0,
    STR_BOM_UTF16_LE = 1,
    STR_BOM_UTF16_BE = 2,
    STR_BOM_UTF8 = 3,
};

LIBSTR_EXPORTABLE void *Str_Malloc(size_t);
LIBSTR_EXPORTABLE void *Str_Zero_Malloc(size_t);
LIBSTR_EXPORTABLE void *Str_Free(void *);
LIBSTR_EXPORTABLE void *Str_Realloc(void *,size_t);
LIBSTR_EXPORTABLE void __Elm_Resize(void **inout, size_t L, size_t type_width, size_t *capacity_ptr);
LIBSTR_EXPORTABLE size_t __Elm_Insert(void **inout, size_t pos, size_t count, const void *S, size_t L, size_t type_width,
                                      size_t *capacity_ptr);
#define __Elm_Append(Mem,Count,S,L,Width,CpsPtr) __Elm_Insert(Mem,Count,Count,S,L,Width,CpsPtr)
#define __Vector_Append(Mem,Count,Capacity,S,L) (void)(*Count += __Elm_Append(Mem,*Count,S,L,1,Capacity))

#ifdef _WIN32
LIBSTR_EXPORTABLE wchar_t *Mbt_To_Uni(const char *S);
LIBSTR_EXPORTABLE char *Mbt_To_Utf8(const char *S);
#endif

LIBSTR_EXPORTABLE bool Str_Equal_Nocase(const char *cs, const char *ct);
LIBSTR_EXPORTABLE int strcmp_I(const char *cs, const char *ct);
LIBSTR_EXPORTABLE bool Uni_Equal_Nocase(const wchar_t *cs, const wchar_t *ct);
LIBSTR_EXPORTABLE int wcscmp_I(const wchar_t *cs, const wchar_t *ct);
LIBSTR_EXPORTABLE int strncmp_I(const char *cs, const char *ct, size_t l);
LIBSTR_EXPORTABLE int wcsncmp_I(const wchar_t *cs, const wchar_t *ct, size_t l);
LIBSTR_EXPORTABLE size_t Str_Length(const char *S);
LIBSTR_EXPORTABLE bool Str_Is_Empty(char *S);
LIBSTR_EXPORTABLE char Str_Last(char *S);
LIBSTR_EXPORTABLE char *Str_Copy_Part(const char *S,size_t len);
LIBSTR_EXPORTABLE char *Str_Copy(const char *S);
LIBSTR_EXPORTABLE char *Str_Trim_Part(const char *S, size_t len);
LIBSTR_EXPORTABLE char *Str_Trim(const char *S);
LIBSTR_EXPORTABLE wchar_t *Uni_Copy_Part(const wchar_t *S, size_t len);
LIBSTR_EXPORTABLE wchar_t *Uni_Copy(const wchar_t *S);
LIBSTR_EXPORTABLE char *Str_Split_First_Into(ARRAY *L, const char *S, const char *delims);
LIBSTR_EXPORTABLE void Str_Split_Once(ARRAY *L, const char *S,const char *delims);
LIBSTR_EXPORTABLE void Str_Split(ARRAY *L, const char *S, const char *delims);
LIBSTR_EXPORTABLE uint64_t Bits_Pop(uint64_t *r, const void *b, size_t *bits_count, size_t count);
LIBSTR_EXPORTABLE void Bits_Push(uint64_t bits, const void *b, size_t *bits_count, size_t count);
LIBSTR_EXPORTABLE char *Str_Xbit_Encode(const void *data, size_t count /*of bits*/, size_t BC, const char *bit_table,
                                        char *out );
LIBSTR_EXPORTABLE char *Str_Qbit_Encode(const void *data,size_t len, const char *tbl, size_t btl, char *out);
LIBSTR_EXPORTABLE void *Str_Xbit_Decode(const char *inS, size_t len, const int BC, const char *bit_table, void *out);
LIBSTR_EXPORTABLE void *Str_Qbit_Decode(const char *S,size_t *len,const char *tbl,size_t btl);
LIBSTR_EXPORTABLE char *Str_Hex_Byte(uint8_t val,char pfx,void *out);
LIBSTR_EXPORTABLE char *Str_Hex_Encode(const void *data, size_t len, char *out);
LIBSTR_EXPORTABLE uint8_t Str_Unhex_Byte(const char *S,int pfx,size_t *cnt);
LIBSTR_EXPORTABLE void *Str_Hex_Decode(const char *S,size_t *len,void *out);
LIBSTR_EXPORTABLE int Str_Urldecode_Char(char const **S);
LIBSTR_EXPORTABLE void Quad_To_Hex16(uint64_t val,char *out);
LIBSTR_EXPORTABLE void Unsigned_To_Hex8(uint32_t val,char *out);
LIBSTR_EXPORTABLE void Unsigned_To_Hex4(uint32_t val,char *out);
LIBSTR_EXPORTABLE void Unsigned_To_Hex2(uint32_t val,char *out);
LIBSTR_EXPORTABLE uint64_t Hex16_To_Quad(const char *S);
LIBSTR_EXPORTABLE uint32_t Hex8_To_Unsigned(const char *S);
LIBSTR_EXPORTABLE uint32_t Hex4_To_Unsigned(const char *S);
LIBSTR_EXPORTABLE uint32_t Hex2_To_Unsigned(const char *S);
LIBSTR_EXPORTABLE wchar_t Utf8_Char_Decode(const void *S,size_t *cnt);
LIBSTR_EXPORTABLE int Utf8_Wide_Length(wchar_t c);
LIBSTR_EXPORTABLE char *Utf8_Wide_Encode(char *out,wchar_t c,size_t *cnt);
LIBSTR_EXPORTABLE wchar_t Utf8_Get_Wide(char const **S);
LIBSTR_EXPORTABLE char *Utf8_Skip(char *S,size_t count);
LIBSTR_EXPORTABLE wchar_t *Utf8_To_Uni_Convert(const char *S, wchar_t *out, size_t max_len);
LIBSTR_EXPORTABLE wchar_t *Utf8_To_Uni(const char *S);
LIBSTR_EXPORTABLE char *Uni_To_Utf8_Convert(const wchar_t *S, char *out, size_t max_len);
LIBSTR_EXPORTABLE char *Uni_To_Utf8(const wchar_t *S);
LIBSTR_EXPORTABLE char *Str_Concat(const char *a, const char *b);
LIBSTR_EXPORTABLE char *Str_Join_Q(char sep, size_t count, const char *const *Sx);
LIBSTR_EXPORTABLE char *Str_Join_Va(char sep, va_list va);
LIBSTR_EXPORTABLE char *Str_Join_0(char sep, ...);
LIBSTR_EXPORTABLE char *Str_Join_2(char sep, const char *s1, const char *s2);
LIBSTR_EXPORTABLE char *Str_Join_3(char sep, const char *s1, const char *s2, const char *s3);
LIBSTR_EXPORTABLE char *Str_Join_4(char sep, const char *s1, const char *s2, const char *s3, const char *s4);
LIBSTR_EXPORTABLE char *Str_Join_5(char sep, const char *s1, const char *s2, const char *s3, const char *s4, const char *s5);
LIBSTR_EXPORTABLE char *Str_Join_6(char sep, const char *s1, const char *s2, const char *s3, const char *s4, const char *s5,
                                   const char *s6);
LIBSTR_EXPORTABLE char *Str_Join_7(char sep, const char *s1, const char *s2, const char *s3, const char *s4, const char *s5,
                                   const char *s6, const char *s7);
LIBSTR_EXPORTABLE wchar_t *Uni_Concat(const wchar_t *a, const wchar_t *b);
LIBSTR_EXPORTABLE wchar_t *Uni_Join_Va(int sep, va_list va);
LIBSTR_EXPORTABLE wchar_t *Uni_Join_0(int sep, ...);
LIBSTR_EXPORTABLE wchar_t *Uni_Join_2(wchar_t sep, const wchar_t *s1, const wchar_t *s2);
LIBSTR_EXPORTABLE wchar_t *Uni_Join_3(wchar_t sep, const wchar_t *s1, const wchar_t *s2, const wchar_t *s3);
LIBSTR_EXPORTABLE wchar_t *Uni_Join_4(wchar_t sep, const wchar_t *s1, const wchar_t *s2, const wchar_t *s3, const wchar_t *s4);
LIBSTR_EXPORTABLE wchar_t *Uni_Join_5(wchar_t sep, const wchar_t *s1, const wchar_t *s2, const wchar_t *s3, const wchar_t *s4,
                                      const wchar_t *s5);
LIBSTR_EXPORTABLE wchar_t *Uni_Join_6(wchar_t sep, const wchar_t *s1, const wchar_t *s2, const wchar_t *s3, const wchar_t *s4,
                                      const wchar_t *s5, const wchar_t *s6);
LIBSTR_EXPORTABLE wchar_t *Uni_Join_7(wchar_t sep, const wchar_t *s1, const wchar_t *s2, const wchar_t *s3, const wchar_t *s4,
                                      const wchar_t *s5, const wchar_t *s6, const wchar_t *s7);
LIBSTR_EXPORTABLE char *Str_From_Int_Base(long value, int base);
LIBSTR_EXPORTABLE char *Str_From_Int(long value);
LIBSTR_EXPORTABLE char *Str_From_Flt_Perc(double value, int perc);
LIBSTR_EXPORTABLE char *Str_From_Flt(double value);
LIBSTR_EXPORTABLE char *Str_From_Bool(int b);
LIBSTR_EXPORTABLE bool Str_To_Bool_Dflt(const char *S,int dflt);
LIBSTR_EXPORTABLE bool Str_To_Bool(const char *S);
LIBSTR_EXPORTABLE int Str_To_Int_Dflt(char *S, long dflt);
LIBSTR_EXPORTABLE int Str_To_Int(const char *S);
LIBSTR_EXPORTABLE double Str_To_Flt_Dflt(const char *S, double dflt);
LIBSTR_EXPORTABLE double Str_To_Flt(const char *S);
LIBSTR_EXPORTABLE bool Str_Equal_Nocase_Len(const char *S, const char *T, size_t L);
LIBSTR_EXPORTABLE bool Str_Find_BOM(const void *S);
LIBSTR_EXPORTABLE bool Str_Starts_With(const char *S, const char *patt);
LIBSTR_EXPORTABLE bool Str_Ends_With(const char *S, const char *patt);
LIBSTR_EXPORTABLE bool Uni_Starts_With(const wchar_t *S, const wchar_t *patt);
LIBSTR_EXPORTABLE bool Uni_Starts_With_Nocase(const wchar_t *S, const wchar_t *patt);
LIBSTR_EXPORTABLE void Str_Cat_Part(char **inout, const char *S, size_t len);
LIBSTR_EXPORTABLE void Str_Cat(char **inout, const char *S);
LIBSTR_EXPORTABLE void Uni_Cat_Part(wchar_t **inout, const wchar_t *S, size_t len);
LIBSTR_EXPORTABLE void Uni_Cat(wchar_t **inout, const wchar_t *S);
LIBSTR_EXPORTABLE wchar_t *Uni_Cr_To_CfLr_Inplace(wchar_t **S_ptr);
LIBSTR_EXPORTABLE int Uni_Search_Part( const wchar_t *S, size_t len, const wchar_t *patt, size_t pattL, bool nocase);
LIBSTR_EXPORTABLE int Uni_Search(const wchar_t *S, const wchar_t *patt);
LIBSTR_EXPORTABLE int Uni_Search_Nocase(const wchar_t *S, const wchar_t *patt);
LIBSTR_EXPORTABLE int Str_Search_Part(const char *S, size_t len, const char *patt, size_t pattL );
LIBSTR_EXPORTABLE int Str_Search(const char *S, const char *patt);
LIBSTR_EXPORTABLE char *Str_Replace_Part(const char *S, size_t len, const char *patt, size_t pattL, const char *val,
        size_t valL);
LIBSTR_EXPORTABLE char *Str_Replace(const char *S, const char *patt, const char *val);
LIBSTR_EXPORTABLE wchar_t *Uni_Replace_Part(const wchar_t *S, size_t len, const wchar_t *patt, size_t pattL, const wchar_t *val,
        size_t valL, bool nocase);
LIBSTR_EXPORTABLE wchar_t *Uni_Replace(const wchar_t *S, const wchar_t *patt, const wchar_t *val);
LIBSTR_EXPORTABLE wchar_t *Uni_Replace_Nocase(const wchar_t *S, const wchar_t *patt, const wchar_t *val);
LIBSTR_EXPORTABLE int Utf8_Submatch(const char *S, const char *patt, int nocase);
LIBSTR_EXPORTABLE int Utf8_Match(const char *S, const char *patt);
LIBSTR_EXPORTABLE int Utf8_Match_Nocase(const char *S, const char *patt);
LIBSTR_EXPORTABLE char *Str_Fetch_Substr(const char *S, const char *prefx, const char *skip, const char *stopat);
LIBSTR_EXPORTABLE char *Str_Reverse_Part(const char *S, size_t len);
LIBSTR_EXPORTABLE char *Str_Reverse(const char *S);
LIBSTR_EXPORTABLE wchar_t *Uni_Transform(const wchar_t *S, size_t len, wchar_t (*transform)(wchar_t));
LIBSTR_EXPORTABLE wchar_t *Uni_Upper(const wchar_t *S);
LIBSTR_EXPORTABLE wchar_t *Uni_Lower(const wchar_t *S);
LIBSTR_EXPORTABLE char *Str_Transform(const char *S, size_t len, char (*transform)(char));
LIBSTR_EXPORTABLE char *Str_Upper(const char *S);
LIBSTR_EXPORTABLE char *Str_Lower(const char *S);
LIBSTR_EXPORTABLE char *Utf8_Transform(const char *S, size_t len, wchar_t (*transform)(wchar_t) );
LIBSTR_EXPORTABLE char *Utf8_Upper(const char *S);
LIBSTR_EXPORTABLE char *Utf8_Lower(const char *S);
LIBSTR_EXPORTABLE char *Str_Safe_Quote(const char *S);
LIBSTR_EXPORTABLE char *Str_Escape(const char *S);
LIBSTR_EXPORTABLE char *Str_Left(const char *S, size_t max_len);

#define Str_Join(Sep,...) Str_Join_0(Sep,VARGS_PARAMS(__quoted_const_char_ptr__,__VA_ARGS__),NULL)
__Str_Forceinline const char *__quoted_const_char_ptr__(const char *ptr) { return ptr; }

#define Uni_Join(Sep,...) Uni_Join_0(Sep,VARGS_PARAMS(__quoted_const_wchar_ptr__,__VA_ARGS__),NULL)
__Str_Forceinline const wchar_t *__quoted_const_wchar_ptr__(const wchar_t *ptr) { return ptr; }

LIBSTR_EXPORTABLE void Buffer_Init(BUFFER *bf,size_t size);
LIBSTR_EXPORTABLE void Buffer_Kill(BUFFER *bf);
LIBSTR_EXPORTABLE void Buffer_Clear(BUFFER *bf);
LIBSTR_EXPORTABLE size_t Buffer_Size(const BUFFER *bf);
LIBSTR_EXPORTABLE size_t Buffer_Capacity(const BUFFER *bf);
LIBSTR_EXPORTABLE uint8_t *Buffer_Begin(BUFFER *bf);
LIBSTR_EXPORTABLE uint8_t *Buffer_End(BUFFER *bf);
LIBSTR_EXPORTABLE void Buffer_Resize(BUFFER *bf,size_t size);
LIBSTR_EXPORTABLE void Buffer_Grow(BUFFER *bf,size_t size);
LIBSTR_EXPORTABLE void Buffer_Insert(BUFFER *bf, size_t pos, const void *ptr, size_t count);
LIBSTR_EXPORTABLE void Buffer_Append(BUFFER *bf,const void *ptr, size_t count);
LIBSTR_EXPORTABLE void Buffer_Fill_Append(BUFFER *bf, int c, size_t count);
LIBSTR_EXPORTABLE void Buffer_Hex_Append(BUFFER *bf, const void *ptr, size_t count);
LIBSTR_EXPORTABLE void Buffer_Print(BUFFER *bf, const char *S);
LIBSTR_EXPORTABLE void Buffer_Puts(BUFFER *bf, const char *S);
LIBSTR_EXPORTABLE void Buffer_Print_Utf8(BUFFER *bf, const wchar_t *S);
LIBSTR_EXPORTABLE void Buffer_Puts_Utf8(BUFFER *bf, const wchar_t *S);
LIBSTR_EXPORTABLE void Buffer_Set(BUFFER *bf, const void *ptr, size_t count);
LIBSTR_EXPORTABLE uint8_t *Buffer_Copy(BUFFER *bf, size_t pos, size_t count);
LIBSTR_EXPORTABLE void Buffer_Zero(BUFFER *bf);
LIBSTR_EXPORTABLE void Buffer_Swap(BUFFER *bf1,BUFFER *bf2);


LIBSTR_EXPORTABLE void Array_Init(ARRAY *a,size_t size,void(*f_free_valptr)(void *));
LIBSTR_EXPORTABLE void Array_Kill(ARRAY *a);
LIBSTR_EXPORTABLE void Array_Clear(ARRAY *bf);
LIBSTR_EXPORTABLE size_t Array_Size(const ARRAY *a);
LIBSTR_EXPORTABLE size_t Array_Capacity(const ARRAY *a);
LIBSTR_EXPORTABLE void **Array_Begin(ARRAY *a);
LIBSTR_EXPORTABLE void **Array_End(ARRAY *a);
LIBSTR_EXPORTABLE void Array_Resize(ARRAY *a,size_t size);
LIBSTR_EXPORTABLE void Array_Grow(ARRAY *a,size_t size);
LIBSTR_EXPORTABLE void Array_Fill(ARRAY *a,size_t pos, size_t count, void *value);
LIBSTR_EXPORTABLE void *Array_Insert(ARRAY *a,size_t pos,void *value);
LIBSTR_EXPORTABLE void *Array_Push_Back(ARRAY *a,void *value);
LIBSTR_EXPORTABLE void *Array_Push_Front(ARRAY *a,void *value);
LIBSTR_EXPORTABLE void *Array_Take(ARRAY *a,size_t pos);
LIBSTR_EXPORTABLE void *Array_Get(const ARRAY *a,size_t pos);
LIBSTR_EXPORTABLE void *Array_Set(ARRAY *a,size_t pos, void *value);
LIBSTR_EXPORTABLE void *Array_Xchg(ARRAY *a,size_t pos, void *value);
LIBSTR_EXPORTABLE void Array_Del(ARRAY *a,size_t pos);
LIBSTR_EXPORTABLE void Array_Remove(ARRAY *a, size_t pos, size_t count);
LIBSTR_EXPORTABLE void *Array_Sorted_Insert(ARRAY *a,void *value, int(*cmpfn)(const void *, const void *));
LIBSTR_EXPORTABLE size_t Array_Lower_Boundary(const ARRAY *a,void *value, int(*cmpfn)(const void *, const void *));
LIBSTR_EXPORTABLE void *Array_Binary_Find(const ARRAY *a,void *value, int(*cmpfn)(const void *, const void *));
LIBSTR_EXPORTABLE void Array_Sort(ARRAY *a,int(*cmpfn)(const void *, const void *));
LIBSTR_EXPORTABLE void Array_Swap(ARRAY *a1,ARRAY *a2);

LIBSTR_EXPORTABLE void Dicto_Init(DICTO *o,void(*f_free_valptr)(void *));
LIBSTR_EXPORTABLE void Dicto_Kill(DICTO *o);
LIBSTR_EXPORTABLE void Dicto_Clear(DICTO *o);
LIBSTR_EXPORTABLE void *Dicto_Get(const DICTO *o, const char *key, void *dflt);
LIBSTR_EXPORTABLE void *Dicto_Take(DICTO *o, const char *key);
LIBSTR_EXPORTABLE const char *Dicto_Get_Key_Ptr(const DICTO *o, const char *key);
LIBSTR_EXPORTABLE bool Dicto_Has(const DICTO *o, const char *key);
LIBSTR_EXPORTABLE const char *Dicto_Put(DICTO *o, const char *key, void *val);
LIBSTR_EXPORTABLE const char *Dicto_Put_Copy(DICTO *o, const char *key, const char *str);
LIBSTR_EXPORTABLE bool Dicto_Del(DICTO *o, const char *key);
LIBSTR_EXPORTABLE bool Dicto_Rehash(DICTO *o);
LIBSTR_EXPORTABLE void Dicto_Map(const DICTO *o,void (*func)(const char *,void *,void *),void *state);
LIBSTR_EXPORTABLE size_t Dicto_Get_Values(const DICTO *o, ARRAY *a);
LIBSTR_EXPORTABLE size_t Dicto_Get_Keys(const DICTO *o, ARRAY *a);
LIBSTR_EXPORTABLE const char *Dicto_Format(const DICTO *o, BUFFER *bf, int pretty);
LIBSTR_EXPORTABLE void Dicto_Swap(DICTO *o1,DICTO *o2);

#ifdef _WIN32
enum { PATH_SEPARATOR = '\\' };
#else
enum { PATH_SEPARATOR = '/' };
#endif

enum
{
    FILE_LIST_ALL = 0,
    FILE_LIST_DIRECTORIES = 1,
    FILE_LIST_FILES = 2,
};

typedef struct
{
    time_t ctime;
    time_t mtime;
    uint64_t length;

    struct
    {
        int exists: 1;
        int is_regular: 1;
        int is_tty: 1;
        int is_symlink: 1;
        int is_unisok: 1;
        int is_directory: 1;
        int is_writable: 1;
        int is_readable: 1;
        int is_executable: 1;
    } f;

} FILE_STATS;

typedef struct FILE_API FILE_API;
struct FILE_API
{
    const char *(*oj_fname)();
    uint64_t (*oj_length)();
    uint64_t (*oj_available)();
    bool (*oj_eof)();
    const char *(*oj_last_error_str)();
    int (*oj_last_error)();
    void (*oj_close)(FILE_API *** oj);
    bool (*oj_read_line)(FILE_API **oj, BUFFER *bf);
    bool (*oj_write_line)(FILE_API **oj, const char *text);
    int (*oj_read)(FILE_API **oj, void *bf, size_t count, size_t min_count);
    int (*oj_write)(FILE_API **oj, const void *bf, size_t count, size_t min_count);
    int64_t (*oj_seek)(FILE_API **oj, size_t pos, int whence);
    int64_t (*oj_tall)(FILE_API **oj);
    void (*oj_flush)(FILE_API **oj);
    int64_t (*oj_truncate)(FILE_API **oj, uint64_t length);
};

typedef struct
{
    FILE_API **fapi;
} CFILE;

LIBSTR_EXPORTABLE const char *File_Last_Error_String();
LIBSTR_EXPORTABLE int File_Last_Error();
//LIBSTR_EXPORTABLE int File_Check_Error(char *op, jmpbuf *catcher, FILE *f, char *fname, int look_to_errno);
LIBSTR_EXPORTABLE bool File_Get_Stats(const char *name,FILE_STATS *st);

__Str_Forceinline time_t File_Ctime(const char *name) { FILE_STATS st= {0}; File_Get_Stats(name,&st); st.ctime; }
__Str_Forceinline time_t File_Mtime(const char *name) { FILE_STATS st= {0}; File_Get_Stats(name,&st); st.mtime; }
__Str_Forceinline uint64_t File_Length(const char *name) { FILE_STATS st= {0}; File_Get_Stats(name,&st); st.length; }
__Str_Forceinline bool File_Exists(const char *name) { FILE_STATS st= {0}; File_Get_Stats(name,&st); st.f.exists; }
__Str_Forceinline bool File_Is_Regular(const char *name) { FILE_STATS st= {0}; File_Get_Stats(name,&st); st.f.is_regular; }
__Str_Forceinline bool File_Is_Directory(const char *name) { FILE_STATS st= {0}; File_Get_Stats(name,&st); st.f.is_directory; }
__Str_Forceinline bool File_Is_Writable(const char *name) { FILE_STATS st= {0}; File_Get_Stats(name,&st); st.f.is_writable; }
__Str_Forceinline bool File_Is_Readable(const char *name) { FILE_STATS st= {0}; File_Get_Stats(name,&st); st.f.is_readable; }
__Str_Forceinline bool File_Is_Executable(const char *name) { FILE_STATS st= {0}; File_Get_Stats(name,&st); st.f.is_executable; }

LIBSTR_EXPORTABLE char *Path_Basename(const char *path);
LIBSTR_EXPORTABLE char *Path_Dirname(const char *path);
LIBSTR_EXPORTABLE char *Temp_Directory();
LIBSTR_EXPORTABLE char *Current_Directory();
LIBSTR_EXPORTABLE bool Change_Directory(const char *dirname);
LIBSTR_EXPORTABLE char *Path_Normilize(const char *path, int sep);
LIBSTR_EXPORTABLE char *Path_Unique_Name(const char *dirname, const char *pfx, const char *sfx);
LIBSTR_EXPORTABLE char *Path_Suffix(const char *path);
LIBSTR_EXPORTABLE char *Path_Unsuffix(const char *path);
LIBSTR_EXPORTABLE char *Path_Fullname(const char *path);

#define Path_Join(...) Str_Join_0(PATH_SEPARATOR,VARGS_PARAMS(__quoted_const_char_ptr__,__VA_ARGS__),NULL)

LIBSTR_EXPORTABLE bool List_Directory(const char *dirname, unsigned flags, ARRAY *arr);
LIBSTR_EXPORTABLE bool Delete_Directory(const char *name);
LIBSTR_EXPORTABLE bool Create_Directory(char *name);
LIBSTR_EXPORTABLE bool Create_Directory_In_Depth(const char *name);
LIBSTR_EXPORTABLE bool Create_Required_Dirs(const char *name);
LIBSTR_EXPORTABLE bool File_Unlink(const char *name, bool force);
LIBSTR_EXPORTABLE bool File_Rename(const char *old_name, const char *new_name);
LIBSTR_EXPORTABLE bool File_Move(const char *old_name, const char *new_name);

LIBSTR_EXPORTABLE bool File_On_FILE(CFILE *fo, const char *path, FILE *file);
LIBSTR_EXPORTABLE bool File_Acquire_FILE(CFILE *fo, const char *path, FILE *file);
LIBSTR_EXPORTABLE bool File_On_Fd(CFILE *fo, const char *path, int fd);
LIBSTR_EXPORTABLE bool File_Acquire_Fd(CFILE *fo, const char *path, int fd);
LIBSTR_EXPORTABLE bool File_Open(CFILE *fo, const char *path, const char *accs);
LIBSTR_EXPORTABLE bool File_Popen(CFILE *fo, const char *cmd, const char *accs);
LIBSTR_EXPORTABLE bool File_Temp(CFILE *fo);
LIBSTR_EXPORTABLE bool File_On_Buffer(CFILE *fo, BUFFER *bf);
LIBSTR_EXPORTABLE bool File_Acquire_Buffer(CFILE *fo, BUFFER *bf);
LIBSTR_EXPORTABLE bool File_In_Memory(CFILE *fo, void *mem, size_t mem_leln);
LIBSTR_EXPORTABLE bool File_In_Constant_Memory(CFILE *fo, const void *mem, size_t mem_len);

LIBSTR_EXPORTABLE bool File_Close(CFILE *fo);
LIBSTR_EXPORTABLE bool File_Fill(CFILE *fo, int c, size_t count);
LIBSTR_EXPORTABLE bool File_Copy(CFILE *src, CFILE *dst, size_t count);
LIBSTR_EXPORTABLE bool File_Total_Copy(CFILE *src, CFILE *dst);
LIBSTR_EXPORTABLE bool File_Write_BOM(CFILE *fo, int bom);
LIBSTR_EXPORTABLE bool File_Read_All(CFILE *fo, BUFFER *bf);
LIBSTR_EXPORTABLE bool File_Read(CFILE *fo, void *bf, size_t count);
LIBSTR_EXPORTABLE bool File_Write(CFILE *fo, const void *bf, size_t count);
LIBSTR_EXPORTABLE int  File_Read_Part(CFILE *fo, void *bf, size_t count, size_t min_count);
LIBSTR_EXPORTABLE int  File_Write_Part(CFILE *fo, void *bf, size_t count, size_t min_count);
LIBSTR_EXPORTABLE char *File_Read_Line(CFILE *fo, BUFFER *bf);
LIBSTR_EXPORTABLE bool File_Write_Line(CFILE *fo, const char *text);
LIBSTR_EXPORTABLE bool File_Set_Pos(CFILE *fo, uint64_t pos);
LIBSTR_EXPORTABLE uint64_t File_Get_Pos(CFILE *fo);
LIBSTR_EXPORTABLE bool File_Truncate(CFILE *fo, uint64_t length);
LIBSTR_EXPORTABLE bool File_Flush(CFILE *fo);
LIBSTR_EXPORTABLE uint64_t File_Available(CFILE *fo);
LIBSTR_EXPORTABLE bool File_Eof(CFILE *fo);

typedef struct
{
    DICTO *Prog_Data_Opts;
    ARRAY *Prog_Data_Args;
    char *Prog_Dname_S;
    char *Prog_Fname_S;
    char *Prog_Full_S;
    char *Prog_Arg0_S;
} CMDL;

LIBSTR_EXPORTABLE void Cmdl_Init(CMDL *cmdl, int argc, char **argv, char *patt, unsigned flags);
LIBSTR_EXPORTABLE void Cmdl_Kill(CMDL *cmdl);
LIBSTR_EXPORTABLE void Cmdl_Uni_Init(CMDL *cmdl, int argc, wchar_t **argv, char *patt, unsigned flags);

LIBSTR_EXPORTABLE size_t Cmdl_Arg_Count(CMDL *cmdl);
LIBSTR_EXPORTABLE const char *Cmdl_Arg(CMDL *cmdl, size_t no);
LIBSTR_EXPORTABLE int Cmdl_Arg_Int(CMDL *cmdl, size_t no, int dflt);
LIBSTR_EXPORTABLE bool Cmdl_Has(CMDL *cmdl, const char *opt);
LIBSTR_EXPORTABLE size_t Cmdl_Opt_Count(CMDL *cmdl, const char *opt);
LIBSTR_EXPORTABLE const char *Cmdl_Opt(CMDL *cmdl, const char *opt, size_t no);
LIBSTR_EXPORTABLE const char *Cmdl_First(CMDL *cmdl, const char *opt, const char *dflt);
LIBSTR_EXPORTABLE const char *Cmdl_Last(CMDL *cmdl, const char *opt, const char *dflt);
LIBSTR_EXPORTABLE int Cmdl_First_Int(CMDL *cmdl, const char *opt, int dflt);
LIBSTR_EXPORTABLE int Cmdl_Last_Int(CMDL *cmdl, const char *opt, int dflt);

LIBSTR_EXPORTABLE const char *Cmdl_Prog_Dirname(CMDL *cmdl);
LIBSTR_EXPORTABLE const char *Cmdl_Prog_Filename(CMDL *cmdl);
LIBSTR_EXPORTABLE const char *Cmdl_Prog_Name(CMDL *cmdl);
LIBSTR_EXPORTABLE const char *Cmdl_Prog_Fullname(CMDL *cmdl);

#ifdef _WIN32
LIBSTR_EXPORTABLE void Cmdl_Win32_Init(CMDL *cmdl, char *patt, unsigned flags);
#endif

typedef struct FORMAT_PARAMS FORMAT_PARAMS;
typedef struct FORMAT_VALUE FORMAT_VALUE;
typedef int (*f_format_value_t)(char *out, size_t maxlen, FORMAT_VALUE *fv, FORMAT_PARAMS *fpr);

struct FORMAT_VALUE
{
    union
    {
        uint64_t value;
        double f;
    };
    f_format_value_t formatter;
};

struct FORMAT_PARAMS
{
    int justify_right: 1;
    int uppercase:1;
    int zfiller:1;
    int width1, width2;
    int format;
};

#define Sformat(Fmt,...) Sformat_0(Fmt,VARGS_COUNT(__VA_ARGS__),VARGS_PARAMS(__quoted_format_argument__,__VA_ARGS__))
#define Buffer_Sformat(Bf,Fmt,...) Buffer_Sformat_0(Bf,Fmt,VARGS_COUNT(__VA_ARGS__),VARGS_PARAMS(__quoted_format_argument__,__VA_ARGS__))
#define File_Sformat(Fo,Fmt,...) File_Sformat_0(Fo,Fmt,VARGS_COUNT(__VA_ARGS__),VARGS_PARAMS(__quoted_format_argument__,__VA_ARGS__))
__Str_Forceinline FORMAT_VALUE __quoted_format_argument__(const FORMAT_VALUE fv) { return fv; }

LIBSTR_EXPORTABLE char  *Sformat_0(const char *fmt, size_t args_count, ...);
LIBSTR_EXPORTABLE const char *Buffer_Sformat_0(BUFFER *bf, const char *fmt, size_t args_count, ...);
LIBSTR_EXPORTABLE const char *File_Sformat_0(CFILE *fo, const char *fmt, size_t args_count, ...);
LIBSTR_EXPORTABLE size_t Sformat_Bad_Format(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr);
LIBSTR_EXPORTABLE size_t Sformat_Bad_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr);
LIBSTR_EXPORTABLE size_t Sformat_Cstr_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr);
LIBSTR_EXPORTABLE size_t Sformat_Ustr_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr);
LIBSTR_EXPORTABLE size_t Sformat_Int_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr);
LIBSTR_EXPORTABLE size_t Sformat_Quad_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr);
LIBSTR_EXPORTABLE size_t Sformat_Ptr_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr);
LIBSTR_EXPORTABLE size_t Sformat_Float_Value(char *out,size_t maxlen,const FORMAT_VALUE *fv, const FORMAT_PARAMS *fpr);

__Str_Forceinline
FORMAT_VALUE Sformat_value_i(unsigned int a)
{
    FORMAT_VALUE r = {(uint64_t)a, Sformat_Int_Value};
    return r;
}

__Str_Forceinline
FORMAT_VALUE Sformat_value_q(uint64_t a)
{
    FORMAT_VALUE r = {(uint64_t)a, Sformat_Quad_Value};
    return r;
}

__Str_Forceinline
FORMAT_VALUE Sformat_value_S(const char *a)
{
    FORMAT_VALUE r = {(uintptr_t)a, Sformat_Cstr_Value};
    return r;
}

__Str_Forceinline
FORMAT_VALUE Sformat_value_U(const wchar_t *a)
{
    FORMAT_VALUE r = {(uintptr_t)a, Sformat_Ustr_Value};
    return r;
}

__Str_Forceinline
FORMAT_VALUE Sformat_value_p(void *a)
{
    FORMAT_VALUE r = {(uintptr_t)a, Sformat_Ptr_Value};
    return r;
}

__Str_Forceinline
FORMAT_VALUE Sformat_value_f(double a)
{
    FORMAT_VALUE r = {0, Sformat_Float_Value};
    r.f = a;
    return r;
}

#define $4(a) Sformat_value_i(a)
#define $8(a) Sformat_value_q(a)
#define $S(a) Sformat_value_S(a)
#define $p(a) Sformat_value_p(a)
#define $f(a) Sformat_value_f(a)
#define $U(a) Sformat_value_U(a)

// AUTO FREE LIST
typedef struct AFL AFL;

LIBSTR_EXPORTABLE void *Forget(AFL *, void *);
LIBSTR_EXPORTABLE void *Retain(AFL *, void *);
LIBSTR_EXPORTABLE void *Retain_F(AFL *, void(*)(void *), void *);
LIBSTR_EXPORTABLE AFL*  New_Afl();
LIBSTR_EXPORTABLE AFL*  Push_Afl();
LIBSTR_EXPORTABLE void  Do_Afl(AFL*);
LIBSTR_EXPORTABLE void* Do_Afl_Except_1(AFL*,void *);
LIBSTR_EXPORTABLE void  Do_Afl_Except_2(AFL*,void *,void *);
LIBSTR_EXPORTABLE void  Do_Afl_Except_3(AFL*,void *,void *,void *);

#define __Retain(Afl,Val) \
    switch(0) while(1) \
        if(1) \
            case 1: if (!Val||!Retain(Afl,Val)) break; \
        else \
            case 0: Val =

#define __Retain_F(Afl,F,Val) \
    switch(0) while(1) \
        if(1) \
            case 1: if (!Val||!Retain(Afl,F,Val)) break; \
        else \
            case 0: Val =
