

/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#if defined __little_endian
#define Eight_To_Quad(Eight)  (*(quad_t*)(Eight))
#else
__Inline quad_t Eight_To_Quad(void *b)
#ifdef _C_CORE_BUILTIN
{
	uint_t q0,q1;
	q0 =   (unsigned int)((unsigned char*)b)[0]
	| ((unsigned int)((unsigned char*)b)[1] << 8)
		| ((unsigned int)((unsigned char*)b)[2] << 16)
		| ((unsigned int)((unsigned char*)b)[3] << 24);
	b = (char*)b+4;
	q1 =   (unsigned int)((unsigned char*)b)[0]
	| ((unsigned int)((unsigned char*)b)[1] << 8)
		| ((unsigned int)((unsigned char*)b)[2] << 16)
		| ((unsigned int)((unsigned char*)b)[3] << 24);
	return (quad_t)q0 | ((quad_t)q1 << 32);
}
#endif
;
#endif

#if defined __little_endian
#define Quad_To_Eight(Q,Eight) ((*(quad_t*)(Eight)) = (Q))
#else
__Inline void Quad_To_Eight(quad_t q, void *b)
{
	byte_t *p = b;
	p[0] = (byte_t)q;
	p[1] = (byte_t)(q>>8);
	p[2] = (byte_t)(q>>16);
	p[3] = (byte_t)(q>>24);
	p[4] = (byte_t)(q>>32);
	p[5] = (byte_t)(q>>40);
	p[6] = (byte_t)(q>>48);
	p[7] = (byte_t)(q>>56);
}
#endif

#if defined __little_endian
#define Four_To_Unsigned(Four)  (*(uint_t*)(Four))
#else
__Inline uint_t Four_To_Unsigned(void *b)
{
	byte_t *p = b;
	uint_t q =   p[0]
	|  (p[1] << 8)
		|  (p[2] << 16)
		|  (p[3] << 24);
	return q;
}
#endif

#if defined __little_endian
#define Unsigned_To_Four(Uval,Four) ((*(uint_t*)(Four)) = (Uval))
#else
__Inline Unsigned_To_Four(uint_t q, void *b)
{
	byte_t *p = b;
	p[0] = (byte_t)q;
	p[1] = (byte_t)(q>>8);
	p[2] = (byte_t)(q>>16);
	p[3] = (byte_t)(q>>24);
}
#endif

__Inline uint_t Four_To_Unsigned_BE(void *b)
{
	byte_t *p = b;
	uint_t q =   p[3]
	|  (p[2] << 8)
		|  (p[1] << 16)
		|  (p[0] << 24);
	return q;
}

__Inline void Unsigned_To_Four_BE(uint_t q, void *b)
{
	byte_t *p = b;
	p[3] = (byte_t)q;
	p[2] = (byte_t)(q>>8);
	p[1] = (byte_t)(q>>16);
	p[0] = (byte_t)(q>>24);
}

__Inline uint_t Two_To_Unsigned(void *b)
{
	uint_t q =   (unsigned int)((unsigned char*)b)[0]
	| ((unsigned int)((unsigned char*)b)[1] << 8);
	return q;
}

__Inline void Unsigned_To_Two(uint_t q, void *b)
{
	byte_t *p = b;
	p[0] = (byte_t)q;
	p[1] = (byte_t)(q>>8);
}

_C_CORE_EXTERN byte_t Bitcount_8_Q[]
#ifdef _C_CORE_BUILTIN
= {0, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4,
	5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
	6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
	6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8}
#endif
;

#define Bitcount_8(q) (Bitcount_8_Q[(q)&0x0ff])
__Inline uint_t Bitcount_Of( uint_t u )
{
	int i;
	uint_t q;
	if ( u )
		for ( i = sizeof(u)*8-8; i >= 0; i-=8 )
			if ( !!(q = Bitcount_8(u>>i)) )
				return q+i;
	return 0;
}

__Inline uint_t Min_Pow2(uint_t a)
{
	if ( a ) --a;
	return 1<<Bitcount_Of(a);
}

__Inline int	C_Mini(int a, int b) { return C_MIN(a,b); };
__Inline int	C_Maxi(int a, int b) { return C_MAX(a,b); };
__Inline uint_t C_Minu(uint_t a, uint_t b) { return C_MIN(a,b); }
__Inline uint_t C_Maxu(uint_t a, uint_t b) { return C_MAX(a,b); }
__Inline uint_t C_Absi(int a) { return C_ABS(a); };

__Inline uint_t Align_To_Pow2(uint_t a, uint_t mod)
{
	uint_t Q;
	if ( !mod ) mod = 1;
	Q = Min_Pow2(mod) - 1;
	return (a+Q)&~Q;
}

int Compare_u32(void const *a, void const *b)
#ifdef _C_CORE_BUILTIN
{
	return *(u32_t*)a - *(u32_t*)b;
}
#endif
;

int Compare_Int(void const *a, void const *b)
#ifdef _C_CORE_BUILTIN
{
	return *(int*)a - *(int*)b;
}
#endif
;

__Inline ulong_t C_Align(ulong_t val)
{
	return (val + 7)&~7;
}

#define C_LENGTH_OF(a) (sizeof(a)/sizeof(*(a)))
#define C_LENGTH_OF_1(a) (sizeof(a)/sizeof(*(a))-1)
