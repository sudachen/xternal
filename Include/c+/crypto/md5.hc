
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

/*
  The MD5 algorithm was designed by Ron Rivest in 1991.
  http://www.ietf.org/rfc/rfc1321.txt
*/

#ifndef C_once_C5021104_5DB9_4FCC_BAFC_AFB22BD458D3
#define C_once_C5021104_5DB9_4FCC_BAFC_AFB22BD458D3

#ifdef _BUILTIN
#define _C_MD5_BUILTIN
#endif

#include "../C+.hc"
#include "../crc.hc"
#include "../string.hc"

enum { C_MD5_DIGEST_SIZE = 16 };

typedef struct _C_MD5
  {
    uint_t state[4];   /* state (ABCD) */
    uint_t count[2];   /* number of bits, modulo 2^64 (lsb first) */
    int    finished;
    byte_t buffer[64];
  } C_MD5;

typedef C_MD5 C_MD5_SIGNER;

void *Md5_Clone(C_MD5 *md5)
#ifdef _C_MD5_BUILTIN
  {
    return __Clone(sizeof(C_MD5),md5);
  }
#endif
  ;

void * Md5_Start(C_MD5 *md5)
#ifdef _C_MD5_BUILTIN
  {
    memset(md5,0,sizeof(*md5));
    md5->state[0] = 0x67452301; 
    md5->state[1] = 0xefcdab89; 
    md5->state[2] = 0x98badcfe; 
    md5->state[3] = 0x10325476;
    return md5;
  }
#endif
  ;

void Md5_Update(C_MD5 *md5, void *data, int len);
void *Md5_Finish(C_MD5 *md5, void *digest);

void *Md5_Init()
#ifdef _C_MD5_BUILTIN
  {
    static C_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Digest_Size_OjCID, __To_Ptr(C_MD5_DIGEST_SIZE) }, 
        {Oj_Clone_OjMID, Md5_Clone },
        {Oj_Digest_Update_OjMID, Md5_Update },
        {Oj_Digest_Finish_OjMID, Md5_Finish },
        {Oj_Digest_Start_OjMID,  Md5_Start  },
        {0}};
    
    C_MD5 *md5 = __Object(sizeof(C_MD5),funcs);
    return Md5_Start(md5);
  }
#endif
  ;

#define C_MD5_INITIALIZER \
               {{0x67452301,0xefcdab89,0x98badcfe,0x10325476},{0},0,{0}}

char *Md5_Hex_Finish(C_MD5 *md5)
#ifdef _C_MD5_BUILTIN
  {
    byte_t digest[C_MD5_DIGEST_SIZE];
    return Str_Hex_Encode(Md5_Finish(md5,digest),C_MD5_DIGEST_SIZE);
  }
#endif
  ;

char *Md5_Hex_Digest(void *data, int len)
#ifdef _C_MD5_BUILTIN
  {
    C_MD5 md5 = C_MD5_INITIALIZER;
    Md5_Update(&md5,data,len);
    return Md5_Hex_Finish(&md5);
  }
#endif
  ;

void *Md5_Digest(void *data, int len, void *digest)
#ifdef _C_MD5_BUILTIN
  {
    C_MD5 md5 = C_MD5_INITIALIZER;
    Md5_Update(&md5,data,len);
    return Md5_Finish(&md5,digest);
  }
#endif
  ;

void *Md5_Digest_Digest(void *data, int len, void *digest)
#ifdef _C_MD5_BUILTIN
  {
    byte_t tmp[C_MD5_DIGEST_SIZE];
    C_MD5 md5 = C_MD5_INITIALIZER;
    Md5_Digest(data,len,tmp);
    Md5_Update(&md5,tmp,C_MD5_DIGEST_SIZE);
    Md5_Update(&md5,data,len);
    return Md5_Finish(&md5,digest);
  }
#endif
  ;

#define Md5_Digest_Of(Data,Len) Md5_Digest(Data,Len,0)

#ifdef _C_MD5_BUILTIN

  #if defined _X86 || defined __i386 || defined __x86_64
    #define Md5_Internal_Encode memcpy
    #define Md5_Internal_Decode memcpy
  #else
    void Md5_Internal_Encode(byte_t *output, uint_t *input, uint_t len) 
      {
        uint_t i, j;

        for (i = 0, j = 0; j < len; i++, j += 4) 
          {
            output[j]   = (byte_t)(input[i] & 0xff);
            output[j+1] = (byte_t)((input[i] >> 8) & 0xff);
            output[j+2] = (byte_t)((input[i] >> 16) & 0xff);
            output[j+3] = (byte_t)((input[i] >> 24) & 0xff);
          }
      }

    void Md5_Internal_Decode(uint_t *output, byte_t *input, uint_t len)
      {
        uint_t i, j;

        for (i = 0, j = 0; j < len; i++, j += 4)
          output[i] = ((uint_t)input[j]) | (((uint_t)input[j+1]) << 8) |
            (((uint_t)input[j+2]) << 16) | (((uint_t)input[j+3]) << 24);
      }
  #endif

  #define ROTATE_LEFT(x,n) (((x) << (n)) | ((x) >> (32-(n))))
  #define F(x, y, z) (((x) & (y)) | (~(x) & (z)))
  #define G(x, y, z) (((x) & (z)) | ((y) & ~(z)))
  #define H(x, y, z) ((x) ^ (y) ^ (z))
  #define I(x, y, z) ((y) ^ ((x) | ~(z)))
  #define FF(a, b, c, d, x, s, ac) (a) += F((b), (c), (d)) + (x) + (ac); \
                                   (a) = ROTATE_LEFT((a), (s)) + (b)
  #define GG(a, b, c, d, x, s, ac) (a) += G((b), (c), (d)) + (x) + (ac); \
                                   (a) = ROTATE_LEFT((a), (s)) + (b)
  #define HH(a, b, c, d, x, s, ac) (a) += H((b), (c), (d)) + (x) + (ac); \
                                   (a) = ROTATE_LEFT((a), (s)) + (b)
  #define II(a, b, c, d, x, s, ac) (a) += I((b), (c), (d)) + (x) + (ac); \
                                   (a) = ROTATE_LEFT((a), (s)) + (b)

  void Md5_Internal_Transform(C_MD5 *md5, void *block)
    {
      enum _S_constants
        {
          S11 = 7,
          S12 = 12,
          S13 = 17,
          S14 = 22,
          S21 = 5,
          S22 = 9,
          S23 = 14,
          S24 = 20,
          S31 = 4,
          S32 = 11,
          S33 = 16,
          S34 = 23,
          S41 = 6,
          S42 = 10,
          S43 = 15,
          S44 = 21
        };

      uint_t *state = md5->state;
      uint_t a = state[0], b = state[1], c = state[2], d = state[3], x[16];

      Md5_Internal_Decode (x, block, 64);

      /* Round 1 */
      FF (a, b, c, d, x[ 0], S11, 0xd76aa478); /* 1 */
      FF (d, a, b, c, x[ 1], S12, 0xe8c7b756); /* 2 */
      FF (c, d, a, b, x[ 2], S13, 0x242070db); /* 3 */
      FF (b, c, d, a, x[ 3], S14, 0xc1bdceee); /* 4 */
      FF (a, b, c, d, x[ 4], S11, 0xf57c0faf); /* 5 */
      FF (d, a, b, c, x[ 5], S12, 0x4787c62a); /* 6 */
      FF (c, d, a, b, x[ 6], S13, 0xa8304613); /* 7 */
      FF (b, c, d, a, x[ 7], S14, 0xfd469501); /* 8 */
      FF (a, b, c, d, x[ 8], S11, 0x698098d8); /* 9 */
      FF (d, a, b, c, x[ 9], S12, 0x8b44f7af); /* 10 */
      FF (c, d, a, b, x[10], S13, 0xffff5bb1); /* 11 */
      FF (b, c, d, a, x[11], S14, 0x895cd7be); /* 12 */
      FF (a, b, c, d, x[12], S11, 0x6b901122); /* 13 */
      FF (d, a, b, c, x[13], S12, 0xfd987193); /* 14 */
      FF (c, d, a, b, x[14], S13, 0xa679438e); /* 15 */
      FF (b, c, d, a, x[15], S14, 0x49b40821); /* 16 */

     /* Round 2 */
      GG (a, b, c, d, x[ 1], S21, 0xf61e2562); /* 17 */
      GG (d, a, b, c, x[ 6], S22, 0xc040b340); /* 18 */
      GG (c, d, a, b, x[11], S23, 0x265e5a51); /* 19 */
      GG (b, c, d, a, x[ 0], S24, 0xe9b6c7aa); /* 20 */
      GG (a, b, c, d, x[ 5], S21, 0xd62f105d); /* 21 */
      GG (d, a, b, c, x[10], S22,  0x2441453); /* 22 */
      GG (c, d, a, b, x[15], S23, 0xd8a1e681); /* 23 */
      GG (b, c, d, a, x[ 4], S24, 0xe7d3fbc8); /* 24 */
      GG (a, b, c, d, x[ 9], S21, 0x21e1cde6); /* 25 */
      GG (d, a, b, c, x[14], S22, 0xc33707d6); /* 26 */
      GG (c, d, a, b, x[ 3], S23, 0xf4d50d87); /* 27 */
      GG (b, c, d, a, x[ 8], S24, 0x455a14ed); /* 28 */
      GG (a, b, c, d, x[13], S21, 0xa9e3e905); /* 29 */
      GG (d, a, b, c, x[ 2], S22, 0xfcefa3f8); /* 30 */
      GG (c, d, a, b, x[ 7], S23, 0x676f02d9); /* 31 */
      GG (b, c, d, a, x[12], S24, 0x8d2a4c8a); /* 32 */

      /* Round 3 */
      HH (a, b, c, d, x[ 5], S31, 0xfffa3942); /* 33 */
      HH (d, a, b, c, x[ 8], S32, 0x8771f681); /* 34 */
      HH (c, d, a, b, x[11], S33, 0x6d9d6122); /* 35 */
      HH (b, c, d, a, x[14], S34, 0xfde5380c); /* 36 */
      HH (a, b, c, d, x[ 1], S31, 0xa4beea44); /* 37 */
      HH (d, a, b, c, x[ 4], S32, 0x4bdecfa9); /* 38 */
      HH (c, d, a, b, x[ 7], S33, 0xf6bb4b60); /* 39 */
      HH (b, c, d, a, x[10], S34, 0xbebfbc70); /* 40 */
      HH (a, b, c, d, x[13], S31, 0x289b7ec6); /* 41 */
      HH (d, a, b, c, x[ 0], S32, 0xeaa127fa); /* 42 */
      HH (c, d, a, b, x[ 3], S33, 0xd4ef3085); /* 43 */
      HH (b, c, d, a, x[ 6], S34,  0x4881d05); /* 44 */
      HH (a, b, c, d, x[ 9], S31, 0xd9d4d039); /* 45 */
      HH (d, a, b, c, x[12], S32, 0xe6db99e5); /* 46 */
      HH (c, d, a, b, x[15], S33, 0x1fa27cf8); /* 47 */
      HH (b, c, d, a, x[ 2], S34, 0xc4ac5665); /* 48 */

      /* Round 4 */
      II (a, b, c, d, x[ 0], S41, 0xf4292244); /* 49 */
      II (d, a, b, c, x[ 7], S42, 0x432aff97); /* 50 */
      II (c, d, a, b, x[14], S43, 0xab9423a7); /* 51 */
      II (b, c, d, a, x[ 5], S44, 0xfc93a039); /* 52 */
      II (a, b, c, d, x[12], S41, 0x655b59c3); /* 53 */
      II (d, a, b, c, x[ 3], S42, 0x8f0ccc92); /* 54 */
      II (c, d, a, b, x[10], S43, 0xffeff47d); /* 55 */
      II (b, c, d, a, x[ 1], S44, 0x85845dd1); /* 56 */
      II (a, b, c, d, x[ 8], S41, 0x6fa87e4f); /* 57 */
      II (d, a, b, c, x[15], S42, 0xfe2ce6e0); /* 58 */
      II (c, d, a, b, x[ 6], S43, 0xa3014314); /* 59 */
      II (b, c, d, a, x[13], S44, 0x4e0811a1); /* 60 */
      II (a, b, c, d, x[ 4], S41, 0xf7537e82); /* 61 */
      II (d, a, b, c, x[11], S42, 0xbd3af235); /* 62 */
      II (c, d, a, b, x[ 2], S43, 0x2ad7d2bb); /* 63 */
      II (b, c, d, a, x[ 9], S44, 0xeb86d391); /* 64 */

      state[0] += a;
      state[1] += b;
      state[2] += c;
      state[3] += d;

    }

  #undef F
  #undef G
  #undef H
  #undef I
  #undef ROTATE_LEFT
  #undef FF
  #undef GG
  #undef HH
  #undef II

  void Md5_Update(C_MD5 *md5, void *input, int input_length)
    {
      int i, index, partLen;
      uint_t *count = md5->count;
      index = (uint_t)((count[0] >> 3) & 0x3F);
      if ((count[0] += ((uint_t)input_length << 3)) < ((uint_t)input_length << 3))
        count[1]++;
      count[1] += ((uint_t)input_length >> 29);
      partLen = 64 - index;

      if (input_length >= partLen) 
        {
          memcpy(&md5->buffer[index], input, partLen);
          Md5_Internal_Transform(md5,md5->buffer);
          for (i = partLen; i + 63 < input_length; i += 64)
            Md5_Internal_Transform(md5,&((byte_t*)input)[i]);
          index = 0;
        }
      else
        i = 0;
      memcpy(&md5->buffer[index],&((byte_t*)input)[i],input_length-i);
    }

  void *Md5_Finish(C_MD5 *md5, void *digest)
    {
      if ( !md5->finished )
        {
          static byte_t PADDING[64] = {
            0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          };
          byte_t bits[8];
          uint_t index, padLen;
          Md5_Internal_Encode (bits, md5->count, 8);
          index = (uint_t)((md5->count[0] >> 3) & 0x3f);
          padLen = (index < 56) ? (56 - index) : (120 - index);
          Md5_Update(md5, PADDING, padLen);
          Md5_Update(md5, bits, 8);
          md5->finished = 1;
        }
      if ( !digest ) digest = __Malloc(16);
      Md5_Internal_Encode(digest, md5->state, 16);
      return digest;
    }

#endif /* _C_MD5_BUILTIN */

typedef struct _C_HMAC_MD5
  {
    C_MD5 md5;
    byte_t ipad[64];
    byte_t opad[64];
  } C_HMAC_MD5;

void *Hmac_Md5_Clone(C_HMAC_MD5 *hmac)
#ifdef _C_MD5_BUILTIN
  {
    return __Clone(sizeof(C_HMAC_MD5),hmac);
  }
#endif
  ;

void *Hmac_Md5_Start(C_HMAC_MD5 *hmac, void *key, int key_len)
#ifdef _C_MD5_BUILTIN
  {
    int i;
    byte_t sum[16];
    
    if ( key_len > 64 )
      {
        Md5_Start(&hmac->md5);
        Md5_Update(&hmac->md5,key,key_len);
        Md5_Finish(&hmac->md5,sum);
        key = sum;
        key_len = 16;
      }
    
    memset( hmac->ipad, 0x36, 64 );
    memset( hmac->opad, 0x5C, 64 );
    
    for( i = 0; i < key_len; ++i )
      {
        hmac->ipad[i] = (byte_t)( hmac->ipad[i] ^ ((byte_t*)key)[i] );
        hmac->opad[i] = (byte_t)( hmac->opad[i] ^ ((byte_t*)key)[i] );
      }
    
    Md5_Start(&hmac->md5);
    Md5_Update(&hmac->md5,hmac->ipad,64);
    
    memset(sum,0,sizeof(sum));
    return hmac;
  }
#endif
  ;

void Hmac_Md5_Update(C_HMAC_MD5 *hmac, void *input, int input_length)
#ifdef _C_MD5_BUILTIN
  {
    Md5_Update(&hmac->md5,input,input_length);
  }
#endif
  ;

void Hmac_Md5_Reset(C_HMAC_MD5 *hmac)
#ifdef _C_MD5_BUILTIN
  {
    Md5_Start(&hmac->md5);
    Md5_Update(&hmac->md5,hmac->ipad,64);
  }
#endif
  ;

void *Hmac_Md5_Finish(C_HMAC_MD5 *hmac, void *digest)
#ifdef _C_MD5_BUILTIN
  {
    byte_t tmpb[C_MD5_DIGEST_SIZE];
    Md5_Finish(&hmac->md5,tmpb);
    Md5_Start(&hmac->md5);
    Md5_Update(&hmac->md5,&hmac->opad,64);
    Md5_Update(&hmac->md5,tmpb,C_MD5_DIGEST_SIZE);
    memset(tmpb,0,C_MD5_DIGEST_SIZE);
    return Md5_Finish(&hmac->md5,digest);
  }
#endif
  ;

char *Hmac_Md5_Hex_Finish(C_HMAC_MD5 *hmac)
#ifdef _C_MD5_BUILTIN
  {
    byte_t digest[C_MD5_DIGEST_SIZE];
    return Str_Hex_Encode(Hmac_Md5_Finish(hmac,digest),C_MD5_DIGEST_SIZE);
  }
#endif
  ;

void *Hmac_Md5_Digest(void *data, int len, void *key, int key_len, void *digest)
#ifdef _C_MD5_BUILTIN
  {
    C_HMAC_MD5 hmac5;
    Hmac_Md5_Start(&hmac5,key,key_len);
    Md5_Update(&hmac5.md5,data,len);
    return Hmac_Md5_Finish(&hmac5,digest);
  }
#endif
  ;

char *Hmac_Md5_Hex_Digest(void *data, int len, void *key, int key_len)
#ifdef _C_MD5_BUILTIN
  {
    C_HMAC_MD5 hmac5;
    Hmac_Md5_Start(&hmac5,key,key_len);
    Md5_Update(&hmac5.md5,data,len);
    return Hmac_Md5_Hex_Finish(&hmac5);
  }
#endif
  ;

void *Hmac_Md5_Init(void *key, int key_len)
#ifdef _C_MD5_BUILTIN
  {
    static C_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Digest_Size_OjCID, __To_Ptr(C_MD5_DIGEST_SIZE) }, 
        {Oj_Clone_OjMID, Hmac_Md5_Clone },
        {Oj_Digest_Update_OjMID, Hmac_Md5_Update },
        {Oj_Digest_Finish_OjMID, Hmac_Md5_Finish },
        {0}};
    
    C_HMAC_MD5 *md5 = __Object(sizeof(C_HMAC_MD5),funcs);
    return Hmac_Md5_Start(md5,key,key_len);
  }
#endif
  ;

#endif /* C_once_C5021104_5DB9_4FCC_BAFC_AFB22BD458D3 */

