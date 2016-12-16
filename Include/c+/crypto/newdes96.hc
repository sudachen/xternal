
/*

//
// NEWDES96 
// Released to the public domain by Robert Scott
// -  Originally published in Cryptologia, Jan. 1985
//

*/

/*

Copyright © 2010-2012, Alexéy Sudachén, alexey@sudachen.name
DesaNova Ltda, http://desanova.com/libcplus, Viña del Mar, Chile.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

http://www.gnu.org/licenses/

*/

#ifndef C_once_144D66DB_5194_4393_9B79_FCE53D00D162
#define C_once_144D66DB_5194_4393_9B79_FCE53D00D162

#ifdef _BUILTIN
#define _C_NEWDES96_BUILTIN
#endif

#include "C+.hc"
#include "cipher.hc"
#include "md5.hc"

#ifdef _C_NEWDES96_BUILTIN
static byte_t NEWDES96_SBOX[256] = {
    32, 137, 239, 188, 102, 125, 221, 72, 212, 68, 81, 37, 86, 237, 147, 149,
    70, 229, 17, 124, 115, 207, 33, 20, 122, 143, 25, 215, 51, 183, 138, 142,
    146, 211, 110, 173, 1, 228, 189, 14, 103, 78, 162, 36, 253, 167, 116, 255,
    158, 45, 185, 50, 98, 168, 250, 235, 54, 141, 195, 247, 240, 63, 148, 2,
    224, 169, 214, 180, 62, 22, 117, 108, 19, 172, 161, 159, 160, 47, 43, 171,
    194, 175, 178, 56, 196, 112, 23, 220, 89, 21, 164, 130, 157, 8, 85, 251,
    216, 44, 94, 179, 226, 38, 90, 119, 40, 202, 34, 206, 35, 69, 231, 246,
    29, 109, 74, 71, 176, 6, 60, 145, 65, 13, 77, 151, 12, 127, 95, 199,
    57, 101, 5, 232, 150, 210, 129, 24, 181, 10, 121, 187, 48, 193, 139, 252,
    219, 64, 88, 233, 96, 128, 80, 53, 191, 144, 218, 11, 106, 132, 155, 104,
    91, 136, 31, 42, 243, 66, 126, 135, 30, 26, 87, 186, 182, 154, 242, 123,
    82, 166, 208, 39, 152, 190, 113, 205, 114, 105, 225, 84, 73, 163, 99, 111,
    204, 61, 200, 217, 170, 15, 198, 28, 192, 254, 134, 234, 222, 7, 236, 248,
    201, 41, 177, 156, 92, 131, 67, 249, 245, 184, 203, 9, 241, 0, 27, 46,
    133, 174, 75, 18, 93, 209, 100, 120, 76, 213, 16, 83, 4, 107, 140, 52,
    58, 55, 3, 244, 97, 197, 238, 227, 118, 49, 79, 230, 223, 165, 153, 59
  };
#endif

typedef struct _C_NEWDES96
  {
    byte_t key[15];
  } C_NEWDES96;

void NEWDES96_Destruct(C_NEWDES96 *self)
#ifdef _C_NEWDES96_BUILTIN
  {
    __Destruct(self);
  }
#endif
  ;

void NEWDES96_Encrypt8(C_NEWDES96 *self, void *d)
#ifdef _C_NEWDES96_BUILTIN
  {
    byte_t *data = d;
    byte_t *key = self->key;
    byte_t *f = NEWDES96_SBOX;
 
    byte_t B0 = data[0], B1 = data[1], B2 = data[2], B3 = data[3], 
           B4 = data[4], B5 = data[5], B6 = data[6], B7 = data[7];

    int i = 0;
    byte_t ex = 0;
    for (;;)
      {
        B4 = B4 ^ f[B0 ^ key[i] ^ ex];
        if ( ++i == 15 )
          {
            i = 0;
            ex = key[7];
          }
        B5 = B5 ^ f[B1 ^ key[i] ^ ex];
        if ( ++i == 15 )
          {
            i = 0;
            ex = key[8];
          }
        B6 = B6 ^ f[B2 ^ key[i] ^ ex];
        if ( ++i == 15 )
          {
            i = 0;
            ex = key[9];
          }
        B7 = B7 ^ f[B3 ^ key[i] ^ ex];
        if (++i == 15)
          break;

        B1 = B1 ^ f[B4 ^ key[i++] ^ ex];
        B2 = B2 ^ f[B4 ^ B5];
        B3 = B3 ^ f[B6 ^ key[i++] ^ ex];
        B0 = B0 ^ f[B7 ^ key[i++] ^ ex];
      }

    data[0] = B0;
    data[1] = B1;
    data[2] = B2;
    data[3] = B3;
    data[4] = B4;
    data[5] = B5;
    data[6] = B6;
    data[7] = B7;
  }
#endif
  ;
  
void NEWDES96_Decrypt8(C_NEWDES96 *self, void *d)
#ifdef _C_NEWDES96_BUILTIN
  {
    byte_t *data = d;
    byte_t *key = self->key;
    byte_t *f = NEWDES96_SBOX;

    byte_t B0 = data[0], B1 = data[1], B2 = data[2], B3 = data[3], 
           B4 = data[4], B5 = data[5], B6 = data[6], B7 = data[7];

    int i = 14;
    byte_t ex = key[9];
    for (;;)
      {
        B7 = B7 ^ f[B3 ^ key[i] ^ ex];
        if (--i < 0)
          {
            i = 14;
            ex = key[8];
          }
        B6 = B6 ^ f[B2 ^ key[i] ^ ex];
        if (--i < 0)
          {
            i = 14;
            ex = key[7];
          }
        B5 = B5 ^ f[B1 ^ key[i] ^ ex];
        if (--i < 0)
          {
            i = 14;
            ex = 0;
          }
        B4 = B4 ^ f[B0 ^ key[i] ^ ex];
        if (--i < 0)
          break;

        B0 = B0 ^ f[B7 ^ key[i--] ^ ex];
        B3 = B3 ^ f[B6 ^ key[i--] ^ ex];
        B2 = B2 ^ f[B4 ^ B5];
        B1 = B1 ^ f[B4 ^ key[i--] ^ ex];
      }
  
    data[0] = B0;
    data[1] = B1;
    data[2] = B2;
    data[3] = B3;
    data[4] = B4;
    data[5] = B5;
    data[6] = B6;
    data[7] = B7;
  }
#endif
  ;

C_NEWDES96 *NEWDES96_Init_Static(C_NEWDES96 *self, void *key, int key_len)
#ifdef _C_NEWDES96_BUILTIN
  {
    memcpy(self->key,key,C_MIN(key_len,sizeof(self->key)));
    return self;
  }
#endif
  ;

void *NEWDES96_Init(void *key, int key_len)
#ifdef _C_NEWDES96_BUILTIN
  {
    static C_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID, NEWDES96_Destruct},
        {Oj_Encrypt8_OjMID, NEWDES96_Encrypt8},
        {Oj_Decrypt8_OjMID, NEWDES96_Decrypt8},
        {0}};
    C_NEWDES96 *self = __Object(sizeof(C_NEWDES96),funcs);
    return NEWDES96_Init_Static(self, key, key_len);
  }
#endif
  ;
  
void *NEWDES96_Object_Init_With_Text_Key(char *Skey)
#ifdef _C_NEWDES96_BUILTIN
  {
    byte_t key[16] = {0};
    Md5_Digest(Skey,strlen(Skey),key);
    return NEWDES96_Init(key+1,15);
  }
#endif
  ;

#define NEWDES96_Decipher(Skey) NEWDES96_Object_Init_With_Text_Key(Skey)
#define NEWDES96_Encipher(Skey) NEWDES96_Object_Init_With_Text_Key(Skey)
#define NEWDES96_Cipher(Skey) NEWDES96_Object_Init_With_Text_Key(Skey)
#define NEWDES96_Init_Cipher(Key,Key_Len) NEWDES96_Init(Key,Key_Len)

void NEWDES96_Encrypt_Bytes(void *data, int len, void *key, int key_len)
#ifdef _C_NEWDES96_BUILTIN
  {
    int i;
    C_NEWDES96 nds;
    NEWDES96_Init_Static(&nds, key, key_len);
    if ( len % 8 ) __Raise(C_ERROR_UNALIGNED,0);
    for ( i = 0; i < len; i += 8 )
      NEWDES96_Encrypt8(&nds,(byte_t*)data+i);  
  }
#endif
  ;
  
void NEWDES96_Encrypt(void *data, int len, char *S)
#ifdef _C_NEWDES96_BUILTIN
  {
    byte_t key[16];
    Md5_Digest(S,strlen(S),key);
    NEWDES96_Encrypt_Bytes(data,len&~7,key+1,15);
  }
#endif
  ;

void NEWDES96_Decrypt_Bytes(void *data, int len, void *key, int key_len)
#ifdef _C_NEWDES96_BUILTIN
  {
    int i;
    C_NEWDES96 nds;
    NEWDES96_Init_Static(&nds, key, key_len);
    if ( len % 8 ) __Raise(C_ERROR_UNALIGNED,0);
    for ( i = 0; i < len; i += 8 )
      NEWDES96_Decrypt8(&nds,(byte_t*)data+i);  
  }
#endif
  ;

void NEWDES96_Decrypt(void *data, int len, char *S)
#ifdef _C_NEWDES96_BUILTIN
  {
    byte_t key[16];
    Md5_Digest(S,strlen(S),key);
    NEWDES96_Decrypt_Bytes(data,len&~7,key+1,15);
  }
#endif
  ;

#endif /* C_once_144D66DB_5194_4393_9B79_FCE53D00D162 */

