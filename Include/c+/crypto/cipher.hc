
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_1F19AF84_9BBE_46CC_87A4_8252243D7219
#define C_once_1F19AF84_9BBE_46CC_87A4_8252243D7219

#ifdef _BUILTIN
#define _C_CIPHER_BUILTIN
#endif

#include "C+.hc"
#include "../crc.hc"
#include "random.hc"
#include "md5.hc"
#include "sha2.hc"
#include "buffer.hc"

#ifdef _C_CIPHER_BUILTIN
# define _C_CIPHER_BUILTIN_CODE(Code) Code
# define _C_CIPHER_EXTERN 
#else
# define _C_CIPHER_BUILTIN_CODE(Code)
# define _C_CIPHER_EXTERN extern 
#endif

enum
{
    Oj_CIPHER_GROUP = Oj_RANDOM_GROUP_END,
    Oj_Encrypt8_OjMID,
    Oj_Decrypt8_OjMID,
    Oj_Encrypt16_OjMID,
    Oj_Decrypt16_OjMID,
    Oj_CIPHER_GROUP_END
};

void Oj_Encrypt8(void *cipher,void *block8) _C_CIPHER_BUILTIN_CODE(
  { ((void(*)(void*,void*))C_Find_Method_Of(cipher,Oj_Encrypt8_OjMID,C_RAISE_ERROR))
        (cipher,block8); });

void Oj_Decrypt8(void *cipher,void *block8) _C_CIPHER_BUILTIN_CODE(
  { ((void(*)(void*,void*))C_Find_Method_Of(cipher,Oj_Decrypt8_OjMID,C_RAISE_ERROR))
        (cipher,block8); });
        
void Oj_Encrypt16(void *cipher,void *block16) _C_CIPHER_BUILTIN_CODE(
  { ((void(*)(void*,void*))C_Find_Method_Of(cipher,Oj_Encrypt16_OjMID,C_RAISE_ERROR))
        (cipher,block16); });

void Oj_Decrypt16(void *cipher,void *block16) _C_CIPHER_BUILTIN_CODE(
  { ((void(*)(void*,void*))C_Find_Method_Of(cipher,Oj_Decrypt16_OjMID,C_RAISE_ERROR))
        (cipher,block16); });

void _Oj_Check_Buffer_Size_N_Alignment_8(int S_len)
#ifdef _C_CIPHER_BUILTIN
  {
    if ( S_len < 8 ) 
      __Raise(C_ERROR_NO_ENOUGH,"data buffer to small");
    
    if ( S_len % 8 )
      __Raise(C_ERROR_UNALIGNED,"size of data buffer should be aligned to 8 bytes");
  }
#endif
  ;

void _Oj_Check_Buffer_Size_N_Alignment_16(int S_len)
#ifdef _C_CIPHER_BUILTIN
  {
    if ( S_len < 16 ) 
      __Raise(C_ERROR_NO_ENOUGH,"data buffer to small");
    
    if ( S_len % 16 )
      __Raise(C_ERROR_UNALIGNED,"size of data buffer should be aligned to 16 bytes");
  }
#endif
  ;

void _Oj_Encrypt_Decrypt_ECB_8(void *cipher, void (*f8)(void*,void*), void *S, int S_len)
#ifdef _C_CIPHER_BUILTIN
  {
    int i;
    
    _Oj_Check_Buffer_Size_N_Alignment_8(S_len);
    
    for ( i = 0; i < S_len/8; ++i )
      {
        byte_t *p = (byte_t*)S+i*8;
        f8(cipher,p);
      }
  }
#endif
  ;

void _Oj_Encrypt_Decrypt_ECB_16(void *cipher, void (*f16)(void*,void*), void *S, int S_len)
#ifdef _C_CIPHER_BUILTIN
  {
    int i;
    
    _Oj_Check_Buffer_Size_N_Alignment_16(S_len);
    
    for ( i = 0; i < S_len/16; ++i )
      {
        byte_t *p = (byte_t*)S+i*16;
        f16(cipher,p);
      }
  }
#endif
  ;

void Oj_Encrypt_ECB(void *cipher, void *S, int S_len)
#ifdef _C_CIPHER_BUILTIN
  {
    void (*f)(void*,void*) = C_Find_Method_Of(&cipher,Oj_Encrypt8_OjMID,0);
    
    if ( f )
      _Oj_Encrypt_Decrypt_ECB_8(cipher,f,S,S_len);
    else if ( 0 != (f = C_Find_Method_Of(&cipher,Oj_Encrypt16_OjMID,0)) )
      _Oj_Encrypt_Decrypt_ECB_16(cipher,f,S,S_len);
    else
      __Raise(C_ERROR_METHOD_NOT_FOUND,
              "cipher does not contain Oj_Encrypt8_OjMID or Oj_Encrypt16_OjMID mothod");
  }
#endif
  ;

void Oj_Decrypt_ECB(void *cipher, void *S, int S_len)
#ifdef _C_CIPHER_BUILTIN
  {
    void (*f)(void*,void*) = C_Find_Method_Of(&cipher,Oj_Decrypt8_OjMID,0);
    
    if ( f )
      _Oj_Encrypt_Decrypt_ECB_8(cipher,f,S,S_len);
    else if ( 0 != (f = C_Find_Method_Of(&cipher,Oj_Decrypt16_OjMID,0)) )
      _Oj_Encrypt_Decrypt_ECB_16(cipher,f,S,S_len);
    else
      __Raise(C_ERROR_METHOD_NOT_FOUND,
              "cipher does not contain Oj_Decrypt8_OjMID or Oj_Decrypt16_OjMID mothod");
  }
#endif
  ;

quad_t _Oj_Encrypt_Decrypt_XEX_8(void *cipher, void (*f8)(void*,void*), void *cipher2, void (*xex)(void*,void*), void *S, int S_len, quad_t st)
#ifdef _C_CIPHER_BUILTIN
  {
    int i,j, n = xex?8:16;
    byte_t q16[16] = {0};
    
    _Oj_Check_Buffer_Size_N_Alignment_8(S_len);
    
    for ( i = 0; i < S_len/8; ++i )
      {
        byte_t *p = (byte_t*)S+i*8;
        ++st;
        Quad_To_Eight(st,q16);
        
        if ( xex )
          xex(cipher2,q16);
        else
          Md5_Digest(q16,8,q16);
        
        for ( j = 0; j < n; ++j )
          p[j%8] ^= q16[j];
        f8(cipher,p);
        for ( j = 0; j < n; ++j )
          p[j%8] ^= q16[j];
      }
    
    return st;
  }
#endif
  ;

quad_t _Oj_Encrypt_Decrypt_XEX_16(void *cipher, void (*f16)(void*,void*), void *cipher2, void (*xex)(void*,void*), void *S, int S_len, quad_t st)
#ifdef _C_CIPHER_BUILTIN
  {
    int i,j, n = xex?16:32;
    byte_t q32[32] = {0};
    
    _Oj_Check_Buffer_Size_N_Alignment_16(S_len);
    
    for ( i = 0; i < S_len/16; ++i )
      {
        byte_t *p = (byte_t*)S+i*16;
        ++st;
        Quad_To_Eight(st,q32);
        ++st;
        Quad_To_Eight(st,q32+8);
        
        if ( xex )
          xex(cipher2,q32);
        else
          Sha2_Digest(q32,16,q32);
          
        for ( j = 0; j < n; ++j )
          p[j%16] ^= q32[j];
        f16(cipher,p);
        for ( j = 0; j < n; ++j )
          p[j%16] ^= q32[j];
      }
    
    return st;
  }
#endif
  ;

quad_t Oj_Encrypt_XEX_2(void *cipher, void *cipher2, void *S, int S_len, quad_t st)
#ifdef _C_CIPHER_BUILTIN
  {
    void (*encrypt)(void*,void*) = C_Find_Method_Of(&cipher,Oj_Encrypt8_OjMID,0);
    if ( encrypt ) 
      {
        if ( !cipher2 )
          return _Oj_Encrypt_Decrypt_XEX_8(cipher,encrypt,0,0,S,S_len,st);
        else
          {
            void (*encrypt2)(void*,void*) = C_Find_Method_Of(&cipher2,Oj_Encrypt8_OjMID,C_RAISE_ERROR);
            return _Oj_Encrypt_Decrypt_XEX_8(cipher,encrypt,cipher2,encrypt2,S,S_len,st);
          }
      }
    else if ( 0 != (encrypt = C_Find_Method_Of(&cipher,Oj_Encrypt16_OjMID,0)) ) 
      {
        if ( !cipher2 )
          return _Oj_Encrypt_Decrypt_XEX_16(cipher,encrypt,0,0,S,S_len,st);
        else
          {
            void (*encrypt2)(void*,void*) = C_Find_Method_Of(&cipher2,Oj_Encrypt16_OjMID,C_RAISE_ERROR);
            return _Oj_Encrypt_Decrypt_XEX_16(cipher,encrypt,cipher2,encrypt2,S,S_len,st);
          }
      }
    else
      __Raise(C_ERROR_METHOD_NOT_FOUND,
              "cipher does not contain Oj_Encrypt8_OjMID or Oj_Encrypt16_OjMID mothod");
    return 0;
  }
#endif
  ;

quad_t Oj_Decrypt_XEX_2(void *cipher, void *cipher2, void *S, int S_len, quad_t st)
#ifdef _C_CIPHER_BUILTIN
  {
    void (*decrypt)(void*,void*) = C_Find_Method_Of(&cipher,Oj_Decrypt8_OjMID,0);
    if ( decrypt )
      {
        if ( !cipher2 )
          return _Oj_Encrypt_Decrypt_XEX_8(cipher,decrypt,0,0,S,S_len,st);
        else
          {
            void (*encrypt)(void*,void*) = C_Find_Method_Of(&cipher2,Oj_Encrypt8_OjMID,C_RAISE_ERROR);
            return _Oj_Encrypt_Decrypt_XEX_8(cipher,decrypt,cipher2,encrypt,S,S_len,st);
          }
      }
    else if ( 0 != (decrypt = C_Find_Method_Of(&cipher,Oj_Decrypt16_OjMID,0)) )
      {
        if ( !cipher2 )
          return _Oj_Encrypt_Decrypt_XEX_16(cipher,decrypt,0,0,S,S_len,st);
        else
          {
            void (*encrypt)(void*,void*) = C_Find_Method_Of(&cipher2,Oj_Encrypt16_OjMID,C_RAISE_ERROR);
            return _Oj_Encrypt_Decrypt_XEX_16(cipher,decrypt,cipher2,encrypt,S,S_len,st);
          }
      }
    else
      __Raise(C_ERROR_METHOD_NOT_FOUND,
              "cipher does not contain Oj_Decrypt8_OjMID or Oj_Decrypt16_OjMID mothod");
    return 0;
  }
#endif
  ;

quad_t Oj_Encrypt_XEX(void *cipher, void *S, int S_len, quad_t st)
#ifdef _C_CIPHER_BUILTIN
  {
    return Oj_Encrypt_XEX_2(cipher,cipher,S,S_len,st);
  }
#endif
  ;

quad_t Oj_Decrypt_XEX(void *cipher, void *S, int S_len, quad_t st)
#ifdef _C_CIPHER_BUILTIN
  {
    return Oj_Decrypt_XEX_2(cipher,cipher,S,S_len,st);
  }
#endif
  ;

quad_t Oj_Encrypt_XEX_MDSH(void *cipher, void *S, int S_len, quad_t st)
#ifdef _C_CIPHER_BUILTIN
  {
    return Oj_Encrypt_XEX_2(cipher,0,S,S_len,st);
  }
#endif
  ;

quad_t Oj_Decrypt_XEX_MDSH(void *cipher, void *S, int S_len, quad_t st)
#ifdef _C_CIPHER_BUILTIN
  {
    return Oj_Decrypt_XEX_2(cipher,0,S,S_len,st);
  }
#endif
  ;

quad_t Oj_Encrypt_Buffer_XEX_MDSH(void *cipher, C_BUFFER *bf, quad_t st)
#ifdef _C_CIPHER_BUILTIN
  {
    void *foo = cipher;
    int K = C_Find_Method_Of(&foo,Oj_Encrypt8_OjMID,0)?7:15;
    int L = (bf->count + K) & ~K;    
    Buffer_Resize(bf,L);
    return Oj_Encrypt_XEX_2(cipher,0,bf->at,L,st);
  }
#endif
  ;

quad_t Oj_Decrypt_Buffer_XEX_MDSH(void *cipher, C_BUFFER *bf, quad_t st)
#ifdef _C_CIPHER_BUILTIN
  {
    return Oj_Decrypt_XEX_2(cipher,0,bf->at,bf->count,st);
  }
#endif
  ;

C_BUFFER *Oj_Encrypt_Bytes(void *cipher, void *S, int L)
#ifdef _C_CIPHER_BUILTIN
  {
    C_BUFFER *bf = 0;
    __Auto_Ptr(bf)
      {
        void (*encrypt)(void*,void*) = 0;
        void *foo = cipher;
        quad_t st;
        byte_t ivt[16] = {0,};
        bf = Buffer_Init(0);
        Soft_Random(ivt,sizeof(ivt));
        ivt[7] = (8 - (L % 8));
        Unsigned_To_Two(Crc_16(0,S,L),ivt+5);
        st = Eight_To_Quad(ivt);
        if (( encrypt = C_Find_Method_Of(&foo,Oj_Encrypt8_OjMID,0) )) 
          {
            int K = (L + 7) & ~7;
            encrypt(foo,ivt); 
            Buffer_Resize(bf,K+8);
            memcpy(bf->at,ivt,8);
            memcpy(bf->at+8,S,L);
            Oj_Encrypt_XEX_MDSH(cipher,bf->at+8,K,st);
          }
        else 
          {
            int K = (L + 15) & ~15;
            encrypt = C_Find_Method_Of(&foo,Oj_Encrypt16_OjMID,C_RAISE_ERROR);
            encrypt(foo,ivt);
            Buffer_Resize(bf,K+16);
            memcpy(bf->at,ivt,16);
            strcpy(bf->at+16,S);
            Oj_Encrypt_XEX_MDSH(cipher,bf->at+16,K,st);
          }
      }
    return bf;
  }
#endif
  ;

char *Oj_Decrypt_Bytes(void *cipher, C_BUFFER *bf)
#ifdef _C_CIPHER_BUILTIN
  {
    __Auto_Release
      {
        void (*decrypt)(void*,void*) = 0;
        void *foo = cipher;
        int L = bf->count;
        quad_t st;
        if (( decrypt = C_Find_Method_Of(&foo,Oj_Decrypt8_OjMID,0) )) 
          {
            decrypt(foo,bf->at);
            st = Eight_To_Quad(bf->at);
            foo = bf->at+8;
            L = ( L - 8 ) & ~7; 
          }
        else
          {
            decrypt = C_Find_Method_Of(&foo,Oj_Decrypt16_OjMID,C_RAISE_ERROR);
            decrypt(foo,bf->at);
            st = Eight_To_Quad(bf->at);
            foo = bf->at+16;
            L = ( L - 16 ) & ~15; 
          }
        Oj_Decrypt_XEX_MDSH(cipher,foo,L,st);
        L -= bf->at[7]; 
        if ( L < 1 || Crc_16(0,foo,L) != Two_To_Unsigned(bf->at+5) )
          __Raise(C_ERROR_CORRUPTED,0);
        memmove(bf->at,foo,L);
        bf->count = L;
      }
      
    return bf->at;
  }
#endif
  ;

char *Oj_Encrypt_Str2Hex(void *cipher, char *S)
#ifdef _C_CIPHER_BUILTIN
  {
    char *ret;
    __Auto_Ptr(ret)
      {
        C_BUFFER *bf = Oj_Encrypt_Bytes(cipher,S,strlen(S)+1);
        ret = Str_Hex_Encode(bf->at,bf->count);
      }
    return ret;
  }
#endif
  ;

char *Oj_Decrypt_Hex2Str(void *cipher, char *S)
#ifdef _C_CIPHER_BUILTIN
  {
    char *ret = 0;
    __Auto_Ptr(ret)
      {
        int L;
        C_BUFFER *bf = Buffer_Init(strlen(S)/2+1);
        Str_Hex_Decode_(S,&bf->count,bf->at);
        Oj_Decrypt_Bytes(cipher,bf);
        ret = Buffer_Take_Data(bf);
      }
    return ret;
  }
#endif
  ;
  
#endif /* C_once_1F19AF84_9BBE_46CC_87A4_8252243D7219 */

