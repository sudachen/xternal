
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

/*
   The SHA-256 Secure Hash Standard was published by NIST in 2002.
   http://csrc.nist.gov/publications/fips/fips180-2/fips180-2.pdf
*/

#ifndef C_once_18F7EAA7_0DBC_4720_BA4A_7E0B1A9A5B1E
#define C_once_18F7EAA7_0DBC_4720_BA4A_7E0B1A9A5B1E

#ifdef _BUILTIN
#define _C_SHA2_BUILTIN
#endif

#include "../C+.hc"
#include "../crc.hc"

typedef struct _C_SHA2
  {
    uint_t state[8];   /* state (ABCDEFGH) */
    uint_t count[2];   /* number of bits, modulo 2^64 (lsb first) */
    int    finished;
    byte_t buffer[64]; /* input buffer */
  } C_SHA2;

void *Sha2_Clone(C_SHA2 *sha2)
#ifdef _C_SHA2_BUILTIN
  {
    return __Clone(sizeof(C_SHA2),sha2);
  }
#endif
  ;

void *Sha2_Start(C_SHA2 *sha2)
#ifdef _C_SHA2_BUILTIN
  {
    memset(sha2,0,sizeof(*sha2));
    sha2->state[0] = 0x6a09e667;
    sha2->state[1] = 0xbb67ae85;
    sha2->state[2] = 0x3c6ef372;
    sha2->state[3] = 0xa54ff53a;
    sha2->state[4] = 0x510e527f;
    sha2->state[5] = 0x9b05688c;
    sha2->state[6] = 0x1f83d9ab;
    sha2->state[7] = 0x5be0cd19;
    return sha2;
  }
#endif
  ;

void Sha2_Update(C_SHA2 *sha2, void *data, int len);
void *Sha2_Finish(C_SHA2 *sha2, void *digest);

void *Sha2_Init()
#ifdef _C_SHA2_BUILTIN
  {
    static C_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Clone_OjMID, Sha2_Clone },
        {Oj_Digest_Update_OjMID, Sha2_Update },
        {0}};
    
    C_SHA2 *sha2 = __Object(sizeof(C_SHA2),funcs);
    return Sha2_Start(sha2);
  }
#endif
  ;

#define C_SHA2_INITIALIZER {\
  {0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, \
   0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19} \
   ,{0},0,{0}}

void *Sha2_Digest(void *data, int len, void *digest)
#ifdef _C_SHA2_BUILTIN
  {
    C_SHA2 sha2 = C_SHA2_INITIALIZER;
    Sha2_Update(&sha2,data,len);
    return Sha2_Finish(&sha2,digest);
  }
#endif
  ;

void *Sha2_Digest_Digest(void *data, int len, void *digest)
#ifdef _C_SHA2_BUILTIN
  {
    byte_t tmp[32];
    C_SHA2 sha2 = C_SHA2_INITIALIZER;
    Sha2_Digest(data,len,tmp);
    Sha2_Update(&sha2,tmp,32);
    Sha2_Update(&sha2,data,len);
    return Sha2_Finish(&sha2,digest);
  }
#endif
  ;

#define Sha2_Digest_Of(Data,Len) Sha2_Digest(Data,Len,0)

#ifdef _C_SHA2_BUILTIN

  void Sha2_Internal_Encode(byte_t *output, uint_t *input, uint_t len) 
    {
      uint_t i, j;

      for (i = 0, j = 0; j < len; i++, j += 4) 
        {
          output[j+0] = (byte_t)(input[i] >> 24);
          output[j+1] = (byte_t)(input[i] >> 16);
          output[j+2] = (byte_t)(input[i] >> 8);
          output[j+3] = (byte_t)(input[i]);
        }
    }

  void Sha2_Internal_Decode(uint_t *output, byte_t *input, uint_t len)
    {
      uint_t i, j;
      for (i = 0, j = 0; j < len; i++, j += 4)
        output[i] = ((uint_t)input[j+3]) | (((uint_t)input[j+2]) << 8) |
          (((uint_t)input[j+1]) << 16) | (((uint_t)input[j+0]) << 24);
    }

  #define SHR(x,n) ((x) >> n)
  #define ROTR(x,n) (SHR(x,n) | (x << (32 - n)))
  #define S0(x) (ROTR(x, 7) ^ ROTR(x,18) ^  SHR(x, 3))
  #define S1(x) (ROTR(x,17) ^ ROTR(x,19) ^  SHR(x,10))
  #define S2(x) (ROTR(x, 2) ^ ROTR(x,13) ^ ROTR(x,22))
  #define S3(x) (ROTR(x, 6) ^ ROTR(x,11) ^ ROTR(x,25))
  #define F0(x,y,z) ((x & y) | (z & (x | y)))
  #define F1(x,y,z) (z ^ (x & (y ^ z)))

  #define R(t)  ( x[t] = S1(x[t-2]) + x[t-7] + S0(x[t-15]) + x[t-16] )
  #define F(a,b,c,d,e,f,g,h,x,K) \
  { \
      uint_t foo = h + S3(e) + F1(e,f,g) + K + x; \
      uint_t bar = S2(a) + F0(a,b,c); \
      d += foo; h = foo + bar; \
  }
  
  void Sha2_Internal_Transform(C_SHA2 *sha2, void *block)
    {
      uint_t *state = sha2->state;
      uint_t 
        a = state[0], 
        b = state[1], 
        c = state[2], 
        d = state[3], 
        e = state[4],
        f = state[5],
        g = state[6],
        h = state[7], 
        x[64];

      Sha2_Internal_Decode(x, block, 64);

      F( a, b, c, d, e, f, g, h, x[ 0], 0x428a2f98 );
      F( h, a, b, c, d, e, f, g, x[ 1], 0x71374491 );
      F( g, h, a, b, c, d, e, f, x[ 2], 0xb5c0fbcf );
      F( f, g, h, a, b, c, d, e, x[ 3], 0xe9b5dba5 );
      F( e, f, g, h, a, b, c, d, x[ 4], 0x3956c25b );
      F( d, e, f, g, h, a, b, c, x[ 5], 0x59f111f1 );
      F( c, d, e, f, g, h, a, b, x[ 6], 0x923f82a4 );
      F( b, c, d, e, f, g, h, a, x[ 7], 0xab1c5ed5 );
      F( a, b, c, d, e, f, g, h, x[ 8], 0xd807aa98 );
      F( h, a, b, c, d, e, f, g, x[ 9], 0x12835b01 );
      F( g, h, a, b, c, d, e, f, x[10], 0x243185be );
      F( f, g, h, a, b, c, d, e, x[11], 0x550c7dc3 );
      F( e, f, g, h, a, b, c, d, x[12], 0x72be5d74 );
      F( d, e, f, g, h, a, b, c, x[13], 0x80deb1fe );
      F( c, d, e, f, g, h, a, b, x[14], 0x9bdc06a7 );
      F( b, c, d, e, f, g, h, a, x[15], 0xc19bf174 );
      F( a, b, c, d, e, f, g, h, R(16), 0xe49b69c1 );
      F( h, a, b, c, d, e, f, g, R(17), 0xefbe4786 );
      F( g, h, a, b, c, d, e, f, R(18), 0x0fc19dc6 );
      F( f, g, h, a, b, c, d, e, R(19), 0x240ca1cc );
      F( e, f, g, h, a, b, c, d, R(20), 0x2de92c6f );
      F( d, e, f, g, h, a, b, c, R(21), 0x4a7484aa );
      F( c, d, e, f, g, h, a, b, R(22), 0x5cb0a9dc );
      F( b, c, d, e, f, g, h, a, R(23), 0x76f988da );
      F( a, b, c, d, e, f, g, h, R(24), 0x983e5152 );
      F( h, a, b, c, d, e, f, g, R(25), 0xa831c66d );
      F( g, h, a, b, c, d, e, f, R(26), 0xb00327c8 );
      F( f, g, h, a, b, c, d, e, R(27), 0xbf597fc7 );
      F( e, f, g, h, a, b, c, d, R(28), 0xc6e00bf3 );
      F( d, e, f, g, h, a, b, c, R(29), 0xd5a79147 );
      F( c, d, e, f, g, h, a, b, R(30), 0x06ca6351 );
      F( b, c, d, e, f, g, h, a, R(31), 0x14292967 );
      F( a, b, c, d, e, f, g, h, R(32), 0x27b70a85 );
      F( h, a, b, c, d, e, f, g, R(33), 0x2e1b2138 );
      F( g, h, a, b, c, d, e, f, R(34), 0x4d2c6dfc );
      F( f, g, h, a, b, c, d, e, R(35), 0x53380d13 );
      F( e, f, g, h, a, b, c, d, R(36), 0x650a7354 );
      F( d, e, f, g, h, a, b, c, R(37), 0x766a0abb );
      F( c, d, e, f, g, h, a, b, R(38), 0x81c2c92e );
      F( b, c, d, e, f, g, h, a, R(39), 0x92722c85 );
      F( a, b, c, d, e, f, g, h, R(40), 0xa2bfe8a1 );
      F( h, a, b, c, d, e, f, g, R(41), 0xa81a664b );
      F( g, h, a, b, c, d, e, f, R(42), 0xc24b8b70 );
      F( f, g, h, a, b, c, d, e, R(43), 0xc76c51a3 );
      F( e, f, g, h, a, b, c, d, R(44), 0xd192e819 );
      F( d, e, f, g, h, a, b, c, R(45), 0xd6990624 );
      F( c, d, e, f, g, h, a, b, R(46), 0xf40e3585 );
      F( b, c, d, e, f, g, h, a, R(47), 0x106aa070 );
      F( a, b, c, d, e, f, g, h, R(48), 0x19a4c116 );
      F( h, a, b, c, d, e, f, g, R(49), 0x1e376c08 );
      F( g, h, a, b, c, d, e, f, R(50), 0x2748774c );
      F( f, g, h, a, b, c, d, e, R(51), 0x34b0bcb5 );
      F( e, f, g, h, a, b, c, d, R(52), 0x391c0cb3 );
      F( d, e, f, g, h, a, b, c, R(53), 0x4ed8aa4a );
      F( c, d, e, f, g, h, a, b, R(54), 0x5b9cca4f );
      F( b, c, d, e, f, g, h, a, R(55), 0x682e6ff3 );
      F( a, b, c, d, e, f, g, h, R(56), 0x748f82ee );
      F( h, a, b, c, d, e, f, g, R(57), 0x78a5636f );
      F( g, h, a, b, c, d, e, f, R(58), 0x84c87814 );
      F( f, g, h, a, b, c, d, e, R(59), 0x8cc70208 );
      F( e, f, g, h, a, b, c, d, R(60), 0x90befffa );
      F( d, e, f, g, h, a, b, c, R(61), 0xa4506ceb );
      F( c, d, e, f, g, h, a, b, R(62), 0xbef9a3f7 );
      F( b, c, d, e, f, g, h, a, R(63), 0xc67178f2 );

      state[0] += a;
      state[1] += b;
      state[2] += c;
      state[3] += d;
      state[4] += e;
      state[5] += f;
      state[6] += g;
      state[7] += h;

    }

  #undef R
  #undef F  
  #undef S0
  #undef S1
  #undef S2
  #undef S3
  #undef F0
  #undef F1
  #undef SHR
  #undef ROTR

  void Sha2_Update(C_SHA2 *sha2, void *input, int input_length)
    {      
      int i, index, partLen;
      uint_t *count = sha2->count;
      index = (uint_t)((count[0] >> 3) & 0x3F);
      if ((count[0] += ((uint_t)input_length << 3)) < ((uint_t)input_length << 3))
        count[1]++;
      count[1] += ((uint_t)input_length >> 29);
      partLen = 64 - index;

      if (input_length >= partLen) 
        {
          memcpy(&sha2->buffer[index], input, partLen);
          Sha2_Internal_Transform(sha2,sha2->buffer);
          for (i = partLen; i + 63 < input_length; i += 64)
            Sha2_Internal_Transform(sha2,&((byte_t*)input)[i]);
          index = 0;
        }
      else
        i = 0;
      memcpy(&sha2->buffer[index],&((byte_t*)input)[i],input_length-i);
    }

  void *Sha2_Finish(C_SHA2 *sha2, void *digest)
    {
      if ( !sha2->finished )
        {
          static byte_t PADDING[64] = {
            0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          };
          byte_t bits[8];
          uint_t index, padLen;
          Sha2_Internal_Encode(bits, sha2->count+1, 4);
          Sha2_Internal_Encode(bits+4, sha2->count, 4);
          index = (uint_t)((sha2->count[0] >> 3) & 0x3f);
          padLen = (index < 56) ? (56 - index) : (120 - index);
          Sha2_Update(sha2, PADDING, padLen);
          Sha2_Update(sha2, bits, 8);
          sha2->finished = 1;
        }
      if ( !digest ) digest = __Malloc(32);
      Sha2_Internal_Encode(digest, sha2->state, 32);
      return digest;
    }

#endif /* _C_SHA2_BUILTIN */

typedef struct _C_HMAC_SHA2
  {
    C_SHA2 sha2;
    byte_t ipad[64];
    byte_t opad[64];
  } C_HMAC_SHA2;

void *Hmac_Sha2_Clone(C_HMAC_SHA2 *hmac)
#ifdef _C_SHA2_BUILTIN
  {
    return __Clone(sizeof(C_HMAC_SHA2),hmac);
  }
#endif
  ;

void *Hmac_Sha2_Start(C_HMAC_SHA2 *hmac, void *key, int key_len)
#ifdef _C_SHA2_BUILTIN
  {
    int i;
    byte_t sum[32];
    
    if ( key_len > 64 )
      {
        Sha2_Start(&hmac->sha2);
        Sha2_Update(&hmac->sha2,key,key_len);
        Sha2_Finish(&hmac->sha2,sum);
        key = sum;
        key_len = 32;
      }
    
    memset( hmac->ipad, 0x36, 64 );
    memset( hmac->opad, 0x5C, 64 );
    
    for( i = 0; i < key_len; ++i )
      {
        hmac->ipad[i] = (byte_t)( hmac->ipad[i] ^ ((byte_t*)key)[i] );
        hmac->opad[i] = (byte_t)( hmac->opad[i] ^ ((byte_t*)key)[i] );
      }
    
    Sha2_Start(&hmac->sha2);
    Sha2_Update(&hmac->sha2,hmac->ipad,64);
    
    memset(sum,0,sizeof(sum));
    return hmac;
  }
#endif
  ;

void Hmac_Sha2_Update(C_HMAC_SHA2 *hmac, void *input, int input_length)
#ifdef _C_SHA2_BUILTIN
  {
    Sha2_Update(&hmac->sha2,input,input_length);
  }
#endif
  ;

void *Hmac_Sha2_Finish(C_HMAC_SHA2 *hmac, void *digest)
#ifdef _C_SHA2_BUILTIN
  {
    byte_t tmpb[32];
    Sha2_Finish(&hmac->sha2,tmpb);
    Sha2_Start(&hmac->sha2);
    Sha2_Update(&hmac->sha2,&hmac->opad,64);
    Sha2_Update(&hmac->sha2,tmpb,32);
    memset(tmpb,0,32);
    return Sha2_Finish(&hmac->sha2,digest);
  }
#endif
  ;

void Hmac_Sha2_Reset(C_HMAC_SHA2 *hmac)
#ifdef _C_SHA2_BUILTIN
  {
    Sha2_Start(&hmac->sha2);
    Sha2_Update(&hmac->sha2,hmac->ipad,64);
  }
#endif
  ;

void *Hmac_Sha2_Digest(void *data, int len, void *key, int key_len, void *digest)
#ifdef _C_SHA2_BUILTIN
  {
    C_HMAC_SHA2 hmac2;
    Hmac_Sha2_Start(&hmac2,key,key_len);
    Sha2_Update(&hmac2.sha2,data,len);
    return Hmac_Sha2_Finish(&hmac2,digest);
  }
#endif
  ;

void *Hmac_Sha2_Init(void *key, int key_len)
#ifdef _C_SHA2_BUILTIN
  {
    static C_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Clone_OjMID, Hmac_Sha2_Clone },
        {Oj_Digest_Update_OjMID, Hmac_Sha2_Update },
        {0}};
    
    C_HMAC_SHA2 *sha2 = __Object(sizeof(C_HMAC_SHA2),funcs);
    return Hmac_Sha2_Start(sha2,key,key_len);
  }
#endif
  ;

#endif /* C_once_18F7EAA7_0DBC_4720_BA4A_7E0B1A9A5B1E */

