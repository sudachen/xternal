
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_FF657866_8205_4CAE_9D01_65B8583E9D19
#define C_once_FF657866_8205_4CAE_9D01_65B8583E9D19

#ifdef _BUILTIN
#define _C_RANDOM_BUILTIN
#endif

#include "C+.hc"
#include "../crc.hc"
#include "sha1.hc"

#ifdef __windoze
# include <wincrypt.h>
# ifdef _MSC_VER
#  pragma comment(lib,"advapi32.lib")
# endif
#else
#endif

#define _C_DEV_RANDOM "/dev/urandom"

#ifdef _C_RANDOM_BUILTIN
# define _C_RANDOM_EXTERN
# define _C_RANDOM_BUILTIN_CODE(Code) Code
#else
# define _C_RANDOM_EXTERN extern
# define _C_RANDOM_BUILTIN_CODE(Code)
#endif

enum
{
    Oj_RANDOM_GROUP = Oj_CRC_GROUP_END,
    Oj_Random_32_OjMID,
    Oj_Random_Flt_OjMID,
    Oj_Random_OjMID,
    Oj_RANDOM_GROUP_END,
};

void Soft_Random(void *_bits, int count)
#ifdef _C_RANDOM_BUILTIN
{
	static uquad_t rnd_ct[4] = {0};
	static byte_t  rnd_bits[20] = {0}; 
	static int rnd_bcont = 0;
	static int initialized = 0;
	byte_t *bits = _bits;
	__Xchg_Interlock
	{
		if ( !initialized )
		{
			rnd_ct[0] = ((quad_t)getpid() << 48 ) | (quad_t)time(0);
			rnd_ct[1] = 0;
			rnd_ct[2] = 0;
			rnd_ct[3] = __Ptr_Word(&bits);
			initialized = 1;
		}

		while ( count )
		{
			if ( !rnd_bcont )
			{
				rnd_ct[1] = clock();
				rnd_ct[2] = (rnd_ct[2] + ((quad_t)count ^ __Ptr_Word(bits))) >> 1;
				Sha1_Digest(rnd_ct,sizeof(rnd_ct),rnd_bits);
				++rnd_ct[3];
				rnd_bcont = sizeof(rnd_bits);
			}
			*bits++ = rnd_bits[--rnd_bcont];
			--count;
		}
	}
}
#endif
;

byte_t *Soft_Random_Bytes(int count)
#ifdef _C_RANDOM_BUILTIN
{
	byte_t *b = __Malloc(count);
	Soft_Random(b,count);
	return b;
}
#endif
;

void System_Random(void *bits,int count /* of bytes*/ )
#ifdef _C_RANDOM_BUILTIN
{
#ifdef _SOFTRND
	goto simulate;
#elif !defined __windoze
	int i, fd = open(_C_DEV_RANDOM,O_RDONLY|O_NONBLOCK);
	if ( fd >= 0 )
	{
		for ( i = 0; i < count; )
		{
			int rd = read(fd,bits+i,count-i);
			if ( rd < 0 )
			{
				if ( rd == EAGAIN )
				{
					Soft_Random(bits+i,count-i);
					break;
				}
				else
				{
					char *err = strerror(errno);
					close(fd);
					__Raise_Format(C_ERROR_IO,
						(_C_DEV_RANDOM " does not have required data: %s",err));
				}
			}
			i += rd;
		}
		close(fd);
		return;
	}
	else
		goto simulate;
#else
	typedef BOOL (__stdcall *tCryptAcquireContext)(HCRYPTPROV*,LPCTSTR,LPCTSTR,DWORD,DWORD);
	typedef BOOL (__stdcall *tCryptGenRandom)(HCRYPTPROV,DWORD,BYTE*);
	static tCryptAcquireContext fCryptAcquireContext = 0;
	static tCryptGenRandom fCryptGenRandom = 0;
	static HCRYPTPROV cp = 0;
	if ( !fCryptAcquireContext )
	{
		HMODULE hm = LoadLibraryA("advapi32.dll");
		fCryptAcquireContext = (tCryptAcquireContext)GetProcAddress(hm,"CryptAcquireContextA");
		fCryptGenRandom = (tCryptGenRandom)GetProcAddress(hm,"CryptGenRandom");
	}
	if ( !cp && (!fCryptAcquireContext || !fCryptAcquireContext(&cp, 0, 0,PROV_RSA_FULL, CRYPT_VERIFYCONTEXT)) )
		goto simulate;
	if ( !fCryptGenRandom || !fCryptGenRandom(cp,count,(unsigned char*)bits) )
		goto simulate;
	if ( count >= 4 && *(unsigned*)bits == 0 )
		goto simulate;
	return;
#endif      
simulate:
	Soft_Random(bits,count);
}
#endif
;

ulong_t Random_Bits(int no)
#ifdef _C_RANDOM_BUILTIN
{
	static byte_t bits[128] = {0};
	static int bits_count = 0;
	ulong_t r = 0;

	STRICT_REQUIRE( no > 0 && no <= sizeof(ulong_t)*8 );

	__Xchg_Interlock
		while ( no )
		{
			if ( !bits_count )
			{
				System_Random(bits,sizeof(bits));
				bits_count = sizeof(bits)*8;
			}
			no -= Bits_Pop(&r,bits,&bits_count,no);
		}

		return r;
}
#endif
;

#if 0
ulong_t Get_Random(unsigned min, unsigned max)
#ifdef _C_RANDOM_BUILTIN
{
	ulong_t r;
	int k = sizeof(r)*8/2;
	STRICT_REQUIRE(max > min);
	r = ((Random_Bits(k)*(max-min))>>k) + min;
	STRICT_REQUIRE(r >= min && r < max);
	return r;
}
#endif
;
#endif

uint_t Get_Random(uint_t min, uint_t max)
#ifdef _C_RANDOM_BUILTIN
{
	uint_t r;
	uint_t dif = max - min;
	STRICT_REQUIRE(max > min);
	r = (uint_t)(((uquad_t)Random_Bits(32)*dif) >> 32) + min;
	STRICT_REQUIRE(r >= min && r < max);
	return r;
}
#endif
;

/*
Tiny Mersenne Twister only 127 bit internal state
Mutsuo Saito (Hiroshima University)
Makoto Matsumoto (University of Tokyo)
Copyright (C) 2011 Mutsuo Saito, Makoto Matsumoto,
Hiroshima University and The University of Tokyo.
All rights reserved.
The 3-clause BSD License is applied to this software
*/

enum
{
	C_FASTRND_TINYMT32_MEXP = 127,
	C_FASTRND_TINYMT32_SH0  = 1,
	C_FASTRND_TINYMT32_SH1  = 10,
	C_FASTRND_TINYMT32_SH8  = 8,
	C_FASTRND_TINYMT32_MASK = 0x7fffffff,
};

typedef struct _C_FASTRND
{
	uint_t status[4];
	uint_t mat1;
	uint_t mat2;
	uint_t tmat;
} C_FASTRND;

void Fast_Random_Next_State(C_FASTRND *random)
#ifdef _C_RANDOM_BUILTIN
{
	uint_t x;
	uint_t y;

	y = random->status[3];
	x = (random->status[0] & C_FASTRND_TINYMT32_MASK)
		^ random->status[1]
	^ random->status[2];
	x ^= (x << C_FASTRND_TINYMT32_SH0);
	y ^= (y >> C_FASTRND_TINYMT32_SH0) ^ x;
	random->status[0] = random->status[1];
	random->status[1] = random->status[2];
	random->status[2] = x ^ (y << C_FASTRND_TINYMT32_SH1);
	random->status[3] = y;
	random->status[1] ^= -((int)(y & 1)) & random->mat1;
	random->status[2] ^= -((int)(y & 1)) & random->mat2;
}
#endif
;

uint_t Fast_Random_Temper(C_FASTRND *random)
#ifdef _C_RANDOM_BUILTIN
{
	uint_t t0, t1;
	t0 = random->status[3];
	t1 = random->status[0] + (random->status[2] >> C_FASTRND_TINYMT32_SH8);
	t0 ^= t1;
	t0 ^= -((int)(t1 & 1)) & random->tmat;
	return t0;
}
#endif
;

uint_t Oj_Random_32(void *random) _C_RANDOM_BUILTIN_CODE(
{ 
	return ((uint_t(*)(void*))
		C_Find_Method_Of(&random,Oj_Random_32_OjMID,C_RAISE_ERROR))
			(random); 
});

float Oj_Random_Flt(void *random) _C_RANDOM_BUILTIN_CODE(
{ 
	return ((float(*)(void*))
		C_Find_Method_Of(&random,Oj_Random_Flt_OjMID,C_RAISE_ERROR))
			(random); 
});

int Oj_Random(void *random,int min_val,int max_val) _C_RANDOM_BUILTIN_CODE(
{ 
	return ((int(*)(void*,int,int))
		C_Find_Method_Of(&random,Oj_Random_OjMID,C_RAISE_ERROR))
			(random,min_val,max_val); 
});

uint_t Fast_Random_Next_32(C_FASTRND *random)
#ifdef _C_RANDOM_BUILTIN
{
	Fast_Random_Next_State(random);
	return Fast_Random_Temper(random);
}
#endif
;

float Fast_Random_Next_Flt(C_FASTRND *random)
#ifdef _C_RANDOM_BUILTIN
{
	Fast_Random_Next_State(random);
	return Fast_Random_Temper(random) * (1.0f / 4294967296.0f);
}
#endif
;

int Fast_Random(C_FASTRND *random,int min_val, int max_val)
#ifdef _C_RANDOM_BUILTIN
{
	quad_t q;
	Fast_Random_Next_State(random);
	q = Fast_Random_Temper(random);
	return (int)((q * max_val)>>32) + min_val;
}
#endif
;

void Fast_Random_Period_Certification(C_FASTRND *random) 
#ifdef _C_RANDOM_BUILTIN
{
	if ( !(random->status[0] & C_FASTRND_TINYMT32_MASK)
		&& !random->status[1] 
	&& !random->status[2]
	&& !random->status[3]) 
	{
		random->status[0] = 'T';
		random->status[1] = 'I';
		random->status[2] = 'N';
		random->status[3] = 'Y';
	}
}
#endif
;

C_FASTRND *Fast_Random_Init_Static(C_FASTRND *random,uint_t seed)
#ifdef _C_RANDOM_BUILTIN
{
	int i;
	random->status[0] = seed;
	random->status[1] = random->mat1;
	random->status[2] = random->mat2;
	random->status[3] = random->tmat;
	for (i = 1; i < 8; i++) 
	{
		random->status[i & 3] ^= i + 1812433253U
			* (random->status[(i - 1) & 3]
		^ (random->status[(i - 1) & 3] >> 30));
	}
	Fast_Random_Period_Certification(random);
	for (i = 0; i < 8; i++)
		Fast_Random_Next_State(random);
	return random;
}
#endif
;

C_FASTRND *Fast_Random_Init(uint_t seed)
#ifdef _C_RANDOM_BUILTIN
{
	static C_FUNCTABLE funcs[] = 
	{ {0},
	{Oj_Random_32_OjMID,  Fast_Random_Next_32},
	{Oj_Random_Flt_OjMID, Fast_Random_Next_Flt},
	{Oj_Random_OjMID,     Fast_Random},
	{0}};
	C_FASTRND *random = __Object(sizeof(C_FASTRND),funcs);
	return Fast_Random_Init_Static(random,seed);
}
#endif
;

#endif /* C_once_FF657866_8205_4CAE_9D01_65B8583E9D19 */

