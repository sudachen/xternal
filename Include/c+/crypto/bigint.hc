
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/


#ifndef C_once_B4220D86_3019_4E13_8682_D7F809F4E829
#define C_once_B4220D86_3019_4E13_8682_D7F809F4E829

#ifdef _BUILTIN
#define _C_BIGINT_BUILTIN
#endif

#include "../string.hc"
#include "../buffer.hc"
#include "random.hc"

typedef struct _C_BIGINT
{
	unsigned short digits;
	signed char sign;
	unsigned char capacity; /* extra blocks count */
	uhalflong_t value[1];
} C_BIGINT;

enum
{
	C_BIGINT_BLOCKSIZE   = 128,
	C_BIGINT_BLOCKMASK   = C_BIGINT_BLOCKSIZE-1,
	C_BIGINT_MINDIGITS   = (C_BIGINT_BLOCKSIZE-sizeof(C_BIGINT))/sizeof(uhalflong_t)+1, 
	C_BIGINT_BLKDIGITS   = C_BIGINT_BLOCKSIZE/sizeof(uhalflong_t), 
	SizeOf_Min_C_BIGINT  = sizeof(C_BIGINT)+(C_BIGINT_MINDIGITS-1)*sizeof(uhalflong_t),
	C_BIGINT_DIGIT_SHIFT = sizeof(uhalflong_t)*8,	
};

#define C_BIGINT_DIGIT_MASK  ((uhalflong_t)-1L)

typedef struct _C_BIGINT_STATIC
{
	C_BIGINT bint;
	uhalflong_t space[C_BIGINT_MINDIGITS-1];
} C_BIGINT_STATIC;

#define Bigint_Size_Of_Digits(Digits) (((((Digits)-1)*sizeof(uhalflong_t)+sizeof(C_BIGINT))+C_BIGINT_BLOCKMASK)&~C_BIGINT_BLOCKMASK)
#define Bigint_Digits_Of_Bits(Bits) (((Bits)+sizeof(uhalflong_t)*8-1)/(sizeof(uhalflong_t)*8))
#define Bigint_Digits_Of_Bytes(Bytes) (((Bytes)+sizeof(uhalflong_t)-1)/sizeof(uhalflong_t))
#define Bigint_Bytes_Count(Val) ((Val)->digits*sizeof(uhalflong_t))

#define Bigint_Init(Value) Bigint_Init_Digits(Value,1)
C_BIGINT *Bigint_Init_Digits(quad_t val, int digits)
#ifdef _C_BIGINT_BUILTIN
{
	int i = 0;
	C_BIGINT *bint;
	if ( digits < C_BIGINT_MINDIGITS ) digits = C_BIGINT_MINDIGITS;
	bint = __Malloc(Bigint_Size_Of_Digits(digits));
	if ( val < 0 ) { bint->sign = -1; val = -val; } else bint->sign = 1;
	while ( val & C_BIGINT_DIGIT_MASK )
	{
		bint->value[i++] = val & C_BIGINT_DIGIT_MASK;
		val >>= C_BIGINT_DIGIT_SHIFT; 
	}
	if ( i < digits )
		memset(bint->value+i,0,(digits-i)*sizeof(uhalflong_t));
	bint->digits = C_MAX(i,1);
	bint->capacity = ((digits-C_BIGINT_MINDIGITS)+C_BIGINT_BLKDIGITS-1)/C_BIGINT_BLKDIGITS;
	return bint;
}
#endif
;

int Bigint_Bitcount(C_BIGINT *bint) 
#ifdef _C_BIGINT_BUILTIN
{
	int bc,bcc;
	int i = bint->digits - 1;
	while ( i >= 0 && !bint->value[i] ) --i;
	if ( i < 0 ) return 0;
	bc = Bitcount_Of(bint->value[i]);
	bcc = bc + i*C_BIGINT_DIGIT_SHIFT;   
	return bcc;
}
#endif
;

int Bigint_Is_1(C_BIGINT *bint)
#ifdef _C_BIGINT_BUILTIN
{
	int i;
	if ( bint->value[0] != 1 )
		return 0;
	for ( i = 1; i < bint->digits; ++i )
		if ( bint->value[i] ) 
			return 0;
	return 1;
}
#endif
;

int Bigint_Is_0(C_BIGINT *bint)
#ifdef _C_BIGINT_BUILTIN
{
	int i = 0;
	for ( ; i < bint->digits; ++i )
		if ( bint->value[i] ) 
			return 0;
	return 1;
}
#endif
;

#define Bigint_Copy(Bint) Bigint_Copy_Expand(Bint,0)
C_BIGINT *Bigint_Copy_Expand(C_BIGINT *bint, int extra_digits)
#ifdef _C_BIGINT_BUILTIN
{
	C_BIGINT *out = 0;
	int digits, gap;

	STRICT_REQUIRE( extra_digits >= 0 );

	if ( bint )
	{
		digits = bint->digits+extra_digits;
		STRICT_REQUIRE( bint->digits > 0 );
	}
	else
		digits = extra_digits;

	if ( digits <= C_BIGINT_MINDIGITS ) 
		gap = 0;
	else
		gap = digits-C_BIGINT_MINDIGITS;

	out = __Malloc(Bigint_Size_Of_Digits(digits));
	memset(out,0,Bigint_Size_Of_Digits(digits));
	if ( bint )
		memcpy(out,bint,sizeof(*bint)+((bint->digits-1)*sizeof(uhalflong_t)));
	else
		out->sign = 1;

	out->digits = digits;
	out->capacity = (gap+C_BIGINT_BLKDIGITS-1)/C_BIGINT_BLKDIGITS;

	return out;
}
#endif
;

C_BIGINT *Bigint_Expand(C_BIGINT *bint, int extra_digits)
#ifdef _C_BIGINT_BUILTIN
{
	if ( bint )
	{
		int digits = bint->digits+extra_digits;

		STRICT_REQUIRE( bint );
		STRICT_REQUIRE( bint->digits > 0 );
		STRICT_REQUIRE( extra_digits >= 0 );

		if ( bint->capacity*C_BIGINT_BLKDIGITS + C_BIGINT_MINDIGITS >= digits )
		{
			memset(bint->value+bint->digits,0,extra_digits*sizeof(uhalflong_t));
			bint->digits = digits;
			return bint;
		}
	}

	return Bigint_Copy_Expand(bint,extra_digits);
}
#endif
;

#define Bigint_Expand_If_Small_Bits(Bint,Bits) \
	Bigint_Expand_If_Small(Bint,Bigint_Digits_Of_Bits(Bits))

C_BIGINT *Bigint_Expand_If_Small(C_BIGINT *bint, int required)
#ifdef _C_BIGINT_BUILTIN
{
	if ( !bint )
		return Bigint_Copy_Expand(0,required);
	else if ( bint->digits < required )
		return Bigint_Expand(bint,required - bint->digits);
	else
		return bint;
}
#endif
;

#define Bigint_Alloca_Bits(Bits) Bigint_Alloca(Bigint_Digits_Of_Bits(Bits))
#define Bigint_Alloca(Digits) Bigint_Setup_(alloca(Bigint_Size_Of_Digits(Digits)), Digits)
C_BIGINT *Bigint_Setup_(C_BIGINT *bint, int digits)
#ifdef _C_BIGINT_BUILTIN
{
	REQUIRE(bint);

	memset(bint,0,Bigint_Size_Of_Digits(digits));
	bint->digits = 1;
	bint->sign = 1;
	if ( digits > C_BIGINT_MINDIGITS )
		bint->capacity =  ((digits-C_BIGINT_MINDIGITS)+C_BIGINT_BLKDIGITS-1)/C_BIGINT_BLKDIGITS;
	return bint;
}
#endif
;

C_BIGINT *Bigint_Copy_To(C_BIGINT *bint, C_BIGINT *dst)
#ifdef _C_BIGINT_BUILTIN
{
	if ( dst->digits < bint->digits )
		dst = Bigint_Expand(dst,bint->digits-dst->digits);
	memcpy(dst->value,bint->value,sizeof(uhalflong_t)*bint->digits);
	dst->digits = bint->digits;
	dst->sign   = bint->sign;
	return dst;
}
#endif
;

#define Bigint_Less(Bint,Q)  ( Bigint_Cmp(Bint,Q) <  0 )
#define Bigint_Equal(Bint,Q) ( Bigint_Cmp(Bint,Q) == 0 )
widelong_t Bigint_Cmp(C_BIGINT *bint, C_BIGINT *q)
#ifdef _C_BIGINT_BUILTIN
{
	if ( bint != q )
	{
		int ac  = bint->digits;
		int bc  = q->digits;
		uhalflong_t *a = bint->value+(ac-1); 
		uhalflong_t *b = q->value+(bc-1); 
		widelong_t QQ, Q = ac-bc;

		if ( Q )
		{
			uhalflong_t **qq = ( Q < 0 )?&b:&a;
			QQ = Q;
			if ( QQ < 0 ) QQ = -QQ;
			while ( QQ-- ) if ( *(*qq)-- ) return Q; 
			Q = C_MIN(ac,bc);
			STRICT_REQUIRE(bint->value+(Q-1) == a);
			STRICT_REQUIRE(q->value+(Q-1) == b);
		}
		else 
			Q = ac;

		for ( QQ = Q; QQ--;  )
			if ( ( Q = (widelong_t)*a-- - (widelong_t)*b-- ) ) 
				return Q;
	}

	return 0;
}
#endif
;

C_BIGINT *Bigint_Mul_Short(C_BIGINT *bint,uhalflong_t d)
#ifdef _C_BIGINT_BUILTIN
{
	int i,j;
	uwidelong_t Q = 0;
	uwidelong_t C = 0;

	for ( i = 0, j = bint->digits; i < j; ++i )
	{
		Q = (uwidelong_t)bint->value[i] * (uwidelong_t)d + Q;
		C = (Q & C_BIGINT_DIGIT_MASK) + C;
		bint->value[i] = (uhalflong_t)C;
		Q >>= C_BIGINT_DIGIT_SHIFT;
		C >>= C_BIGINT_DIGIT_SHIFT;
	}

	if ( Q )
	{
		if ( bint->digits >= C_BIGINT_MINDIGITS )
			bint = Bigint_Expand(bint,1);
		else ++bint->digits;
		bint->value[i] = (uhalflong_t)Q;
	}

	return bint;
}
#endif
;

C_BIGINT *Bigint_Add_Short(C_BIGINT *bint,uhalflong_t d)
#ifdef _C_BIGINT_BUILTIN
{
	uhalflong_t *i, *iE;
	uwidelong_t Q = (uwidelong_t)bint->value[0]+d;

	bint->value[0] = (uhalflong_t)Q;
	Q >>= C_BIGINT_DIGIT_SHIFT;

	if ( Q )
		for ( i = bint->value+1, iE = bint->value+bint->digits; i < iE && Q; ++i )
		{
			Q += (uwidelong_t)*i;
			*i = (uhalflong_t)Q;
			Q >>= C_BIGINT_DIGIT_SHIFT;
		}

		if ( Q )
		{
			int j = i-bint->value;
			if ( bint->digits >= C_BIGINT_MINDIGITS )
				bint = Bigint_Expand(bint,1);
			else ++bint->digits;
			bint->value[j] = (uhalflong_t)Q;
		}

		return bint;
}
#endif
;

C_BIGINT *Bigint_Sub_Short(C_BIGINT *bint,uhalflong_t d)
#ifdef _C_BIGINT_BUILTIN
{
	uhalflong_t *i, *iE;
	uwidelong_t Q;

	if ( bint->sign < 1 ) return Bigint_Add_Short(bint,d);

	Q = (uwidelong_t)bint->value[0]-d;
	bint->value[0] = (uhalflong_t)Q;

	Q = ( Q >> C_BIGINT_DIGIT_SHIFT ) & 1;

	if ( Q )
		for ( i = bint->value+1, iE = bint->value+bint->digits; i < iE && Q; ++i )
		{
			Q = (uwidelong_t)*i;
			--Q;
			*i = (uhalflong_t)Q;
			Q = ( Q >> C_BIGINT_DIGIT_SHIFT ) & 1;
		}

		if ( Q )
		{
			int j;
			bint->sign = -bint->sign;
			for ( j = 0; j < bint->digits; ++j )
				bint->value[j] = ~bint->value[j];
			bint = Bigint_Add_Short(bint,1);
		}

		return bint;
}
#endif
;

C_BIGINT *Bigint_Reset(C_BIGINT *bint,int digits)
#ifdef _C_BIGINT_BUILTIN
{
	if ( !bint )
		bint = Bigint_Expand(bint,digits);
	else
	{
		if ( digits > bint->digits && digits > C_BIGINT_MINDIGITS )
			bint = Bigint_Expand(bint,digits-bint->digits);
		else
			bint->digits = C_MAX(digits,1);
	}

	memset(bint->value,0,sizeof(uhalflong_t)*bint->digits);
	return bint;
}
#endif
;

#define Bigint_Bit(Bint,i) \
	(((Bint)->value[i/C_BIGINT_DIGIT_SHIFT] >> (i%C_BIGINT_DIGIT_SHIFT)) & 1 )
#define Bigint_Setbit_(p,val) (p) = ((p)&~(val))|(val)
#define Bigint_Setbit(Bint,i,val) Bigint_Setbit_(\
	(Bint)->value[i/C_BIGINT_DIGIT_SHIFT],\
	(val&1) << (i%C_BIGINT_DIGIT_SHIFT))

C_BIGINT *Bigint_Hishift_Q(C_BIGINT *bint,C_BIGINT *lo,int count,int *bits)
#ifdef _C_BIGINT_BUILTIN
{
	int i = *bits-1, j;
	bint = Bigint_Reset(bint,(count+C_BIGINT_DIGIT_SHIFT-1)/C_BIGINT_DIGIT_SHIFT);

	count = C_MIN(count,*bits);
	*bits -= count;

	for ( j = count-1 ; j >= 0 ; --j, --i ) 
	{
		uhalflong_t d = lo->value[i/C_BIGINT_DIGIT_SHIFT];
		d >>= (i%C_BIGINT_DIGIT_SHIFT);
		bint->value[j/C_BIGINT_DIGIT_SHIFT] |= ( (d&1) << (j%C_BIGINT_DIGIT_SHIFT));
	}

	return bint;
}
#endif
;

C_BIGINT *Bigint_Hishift_1(C_BIGINT *bint, C_BIGINT *lo,int *bits)
#ifdef _C_BIGINT_BUILTIN
{
	uhalflong_t Q = 0;
	uhalflong_t *i, *iE;

	if ( *bits )
	{
		--*bits;
		Q = Bigint_Bit(lo,*bits);
	}

	for ( i = bint->value, iE = bint->value+bint->digits; i != iE; ++i )
	{
		uhalflong_t S = *i;
		*i = ( S << 1 ) | Q;
		Q = S >> (C_BIGINT_DIGIT_SHIFT-1);
	}

	if ( Q )
	{
		int j = bint->digits;
		if ( bint->digits >= C_BIGINT_MINDIGITS )
			bint = Bigint_Expand(bint,1);
		else ++bint->digits;
		bint->value[j] = (uhalflong_t)Q;
	}

	return bint;
}
#endif
;

C_BIGINT *Bigint_Lshift_1(C_BIGINT *bint)
#ifdef _C_BIGINT_BUILTIN
{
	uhalflong_t *i, *iE;
	uhalflong_t Q = 0;

	for ( i = bint->value, iE = bint->value+bint->digits; i != iE; ++i )
	{
		uhalflong_t k = *i;
		*i = ( k << 1 ) | Q;
		Q = k >> (C_BIGINT_DIGIT_SHIFT-1);
	}

	if ( Q )
	{
		int j = bint->digits;
		if ( bint->digits >= C_BIGINT_MINDIGITS )
			bint = Bigint_Expand(bint,1);
		else ++bint->digits;
		bint->value[j] = (uhalflong_t)Q;
	}

	return bint;
}
#endif
;

C_BIGINT *Bigint_Rshift_1(C_BIGINT *bint)
#ifdef _C_BIGINT_BUILTIN
{
	uhalflong_t *i, *iE;
	uhalflong_t Q = 0;

	for ( i = bint->value+bint->digits-1, iE = bint->value-1; i != iE; --i )
	{
		uhalflong_t k = *i;
		*i = ( k >> 1 ) | Q;
		Q = k << (C_BIGINT_DIGIT_SHIFT-1);
	}

	return bint;
}
#endif
;

C_BIGINT *Bigint_Lshift(C_BIGINT *bint,unsigned count)
#ifdef _C_BIGINT_BUILTIN
{
	int i, dif;
	int w = count%C_BIGINT_DIGIT_SHIFT;
	uwidelong_t Q = 0;

	if ( w ) for ( i = 0; i < bint->digits; ++i )
	{
		Q |= ((uwidelong_t)bint->value[i]<<w);
		bint->value[i] = (uhalflong_t)Q;
		Q = (Q>>C_BIGINT_DIGIT_SHIFT);
	}

	if ( Q )
	{
		if ( bint->digits >= C_BIGINT_MINDIGITS )
			bint = Bigint_Expand(bint,1);
		else ++bint->digits;
		bint->value[i] = (uhalflong_t)Q;
	}

	dif = count/C_BIGINT_DIGIT_SHIFT;
	if ( dif ) 
	{
		int digits = bint->digits;
		if ( digits+dif > C_BIGINT_MINDIGITS )
			bint = Bigint_Expand(bint,dif);
		else bint->digits += dif;
		memmove(bint->value+dif,bint->value,digits*sizeof(uhalflong_t));
		memset(bint->value,0,dif*sizeof(uhalflong_t));
	}

	return bint;
}
#endif
;

C_BIGINT *Bigint_Rshift(C_BIGINT *bint,unsigned count)
#ifdef _C_BIGINT_BUILTIN
{
	int i, dif;
	int w = count%C_BIGINT_DIGIT_SHIFT;

	bint->value[0] = bint->value[0] >> w;

	if ( w ) for ( i = 1; i < bint->digits; ++i )
	{
		uhalflong_t Q = bint->value[i];
		bint->value[i-1] |= Q << (C_BIGINT_DIGIT_SHIFT-w);
		bint->value[i] = Q >> w;
	}

	dif = count/C_BIGINT_DIGIT_SHIFT;
	if ( dif )
	{
		int j = C_MAX(bint->digits-dif,0);
		if ( j )
			memmove(bint->value,bint->value+dif,j*sizeof(uhalflong_t));
		memset(bint->value+j,0,(bint->digits-j)*sizeof(uhalflong_t));
		bint->digits = C_MAX(j,1);
	}

	return bint;
}
#endif
;

C_BIGINT *Bigint_Sub_Unsign(C_BIGINT *bint,C_BIGINT *q,int sign)
#ifdef _C_BIGINT_BUILTIN
{
	uwidelong_t Q;
	int i,j;

	if ( bint->digits < q->digits )
		if ( q->digits > C_BIGINT_MINDIGITS )
			bint = Bigint_Expand(bint,q->digits);
		else
		{
			memset(bint->value+bint->digits,0,sizeof(uhalflong_t)*(q->digits-bint->digits));
			bint->digits = q->digits;
		}

		Q = 0;
		for ( i = 0, j = q->digits; i < j; ++i )
		{
			Q = (uwidelong_t)bint->value[i] - (uwidelong_t)q->value[i] - Q;
			bint->value[i] = (uhalflong_t)Q;
			Q >>= C_BIGINT_DIGIT_SHIFT;
			Q &= 1;
		};

		for ( ; Q && i < bint->digits; ++i )
		{
			Q = (uwidelong_t)bint->value[i] - Q;
			bint->value[i] = (uhalflong_t)Q;
			Q >>= C_BIGINT_DIGIT_SHIFT;
			Q &= 1;
		}

		if ( Q )
		{
			bint->sign = -sign;
			for ( i = 0, j = bint->digits; i < j; ++i )
				bint->value[i] = ~bint->value[i];
			Bigint_Add_Short(bint,1);
		}
		else
			bint->sign = sign;

		return bint;
}
#endif
;

C_BIGINT *Bigint_Add_Unsign(C_BIGINT *bint,C_BIGINT *q,int sign)
#ifdef _C_BIGINT_BUILTIN
{
	uwidelong_t Q;
	int i,j;

	if ( bint->digits < q->digits )
		if ( q->digits > C_BIGINT_MINDIGITS )
			bint = Bigint_Expand(bint,q->digits);
		else
		{
			memset(bint->value+bint->digits,0,sizeof(uhalflong_t)*(q->digits-bint->digits));
			bint->digits = q->digits;
		}

		Q = 0;
		for ( i = 0, j = q->digits; i < j; ++i )
		{
			Q = (uwidelong_t)bint->value[i] + (uwidelong_t)q->value[i] + Q;
			bint->value[i] = (uhalflong_t)Q;
			Q >>= C_BIGINT_DIGIT_SHIFT;
		};

		for ( ; Q && i < bint->digits; ++i )
		{
			Q = (uwidelong_t)bint->value[i] + Q;
			bint->value[i] = (uhalflong_t)Q;
			Q >>= C_BIGINT_DIGIT_SHIFT;
		}

		if ( Q )
		{
			if ( bint->digits >= C_BIGINT_MINDIGITS )
				bint = Bigint_Expand(bint,1);
			else ++bint->digits;
			bint->value[i] = (uhalflong_t)Q;
		}

		bint->sign = sign;
		return bint;
}
#endif
;

C_BIGINT *Bigint_Sub(C_BIGINT *bint,C_BIGINT *q)
#ifdef _C_BIGINT_BUILTIN
{
	if ( bint->sign != q->sign )
		return Bigint_Add_Unsign(bint,q,-q->sign);
	else
		return Bigint_Sub_Unsign(bint,q,q->sign);
}
#endif
;

C_BIGINT *Bigint_Add(C_BIGINT *bint,C_BIGINT *q)
#ifdef _C_BIGINT_BUILTIN
{
	if ( bint->sign != q->sign )
		return Bigint_Sub_Unsign(bint,q,-q->sign);
	else
		return Bigint_Add_Unsign(bint,q,q->sign);
}
#endif
;

#define Bigint_Div(Bint,Q) Bigint_Divrem(Bint,Q,0)
C_BIGINT *Bigint_Divrem(C_BIGINT *bint, C_BIGINT *q, C_BIGINT **rem)
#ifdef _C_BIGINT_BUILTIN
{
	C_BIGINT *R, *Q = Bigint_Init(0);
	int bits    = Bigint_Bitcount(bint);
	int divbits = Bigint_Bitcount(q);

	if ( divbits > bits ) 
	{
		if ( rem ) *rem = Bigint_Copy(bint);
		return Q;
	}

	if ( !divbits ) 
		__Raise(C_ERROR_ZERODIVIDE,0);

	R = Bigint_Init(0);
	Q = Bigint_Hishift_Q(Q,bint,divbits,&bits);

	for(;;) 
	{
		if ( !Bigint_Less(Q,q) )
		{ 
			Q = Bigint_Sub(Q,q); 
			R = Bigint_Add_Short(R,1); 
			STRICT_REQUIRE(Bigint_Less(Q,q));
		}
		if ( !bits ) break;
		R = Bigint_Lshift_1(R);
		Q = Bigint_Hishift_1(Q,bint,&bits);
	}

	if ( rem ) *rem = Q;
	return R;
}
#endif
;

C_BIGINT *Bigint_Divrem_Short(C_BIGINT *bint, uhalflong_t q, uhalflong_t *rem)
#ifdef _C_BIGINT_BUILTIN
{
	int i;
	uwidelong_t Q = 0;
	for ( i = bint->digits-1; i >= 0; --i )
	{
		Q <<= C_BIGINT_DIGIT_SHIFT;
		Q |= bint->value[i];
		bint->value[i] = (uhalflong_t)(Q/q);
		Q = Q%q;
	}
	if ( rem ) *rem = (uhalflong_t)Q;
	return bint;
}
#endif
;

uhalflong_t Bigint_Modulo_Short(C_BIGINT *bint, uhalflong_t q)
#ifdef _C_BIGINT_BUILTIN
{
	int i;
	uwidelong_t Q = 0;
	for ( i = bint->digits-1; i >= 0; --i )
	{
		Q <<= C_BIGINT_DIGIT_SHIFT;
		Q |= bint->value[i];
		Q = Q%q;
	}
	return (uhalflong_t)Q;
}
#endif
;

#define Bigint_Decode_10(S) Bigint_Decode_10_Into(0,S)
#define Bigint_Decode_16(S) Bigint_Decode_16_Into(0,S)
#define Bigint_Decode_2(S)  Bigint_Decode_2_Into(0,S)

C_BIGINT *Bigint_Decode_2_Into(C_BIGINT *bint, char *S)
#ifdef _C_BIGINT_BUILTIN
{
	char *p = S;

	__Auto_Ptr(bint)
	{
		bint = Bigint_Reset(bint,1);

		if ( p )
		{
			for ( ;*p; ++p )
			{
				if ( *p != '0' && *p != '1' ) __Raise_Format(C_ERROR_ILLFORMED,("invalid binary number %s",S));
				bint = Bigint_Lshift_1(bint);
				bint->value[0] |= (byte_t)(*p-'0');
			}
		}
	}

	return bint;
}
#endif
;

C_BIGINT *Bigint_Decode_10_Into(C_BIGINT *bint, char *S)
#ifdef _C_BIGINT_BUILTIN
{
	char *p = S;

	__Auto_Ptr(bint)
	{
		bint =  Bigint_Reset(bint,1);

		if ( p )
		{
			if ( *p == '-' ) { bint->sign = -1; ++p; }
			else if ( *p == '+' ) ++p;

			for ( ;*p; ++p )
			{
				if ( !Isdigit(*p) ) __Raise_Format(C_ERROR_ILLFORMED,("invalid decimal number %s",S));
				bint = Bigint_Mul_Short(bint,10);
				bint = Bigint_Add_Short(bint,*p-'0');
			}
		}
	}    
	return bint;
}
#endif
;

C_BIGINT *Bigint_Decode_16_Into(C_BIGINT *bint, char *S)
#ifdef _C_BIGINT_BUILTIN
{
	char *p = S;

	__Auto_Ptr(bint)
	{
		bint = Bigint_Reset(bint,1);

		if ( p )
		{
			for ( ;*p; ++p )
			{
				if ( !Isxdigit(*p) || !Isxdigit(p[1]) ) 
					__Raise_Format(C_ERROR_ILLFORMED,("invalid hexadecimal number %s",S));
				bint = Bigint_Lshift(bint,8);
				bint->value[0] |= Str_Unhex_Byte(p,0,0);
				++p;
			}
		}
	}    
	return bint;
}
#endif
;

char *Bigint_Encode_2(C_BIGINT *bint)
#ifdef _C_BIGINT_BUILTIN
{
	char *ret = 0;
	__Auto_Ptr(ret)
	{
		int i = 0, bc = Bigint_Bitcount(bint);
		char *S = __Malloc(bc+1);

		S[bc] = 0;

		if ( bc ) for ( ; i < bc; ++i )
			S[i] = Bigint_Bit(bint,i) ? '1' : '0';

		ret = Str_Reverse(S,bc);
	}
	return ret;
}
#endif
;

char *Bigint_Encode_10(C_BIGINT *bint)
#ifdef _C_BIGINT_BUILTIN
{
	char *ret = 0;
	__Auto_Ptr(ret)
	{
		C_BUFFER *bf = Buffer_Init(0);
		C_BIGINT *R = Bigint_Copy(bint);

		if ( !Bigint_Is_0(R) )
		{
			do
			{
				uhalflong_t rem;
				R = Bigint_Divrem_Short(R,10,&rem);
				Buffer_Fill_Append(bf,'0'+rem,1);
			}
			while ( R->value[0] || !Bigint_Is_0(R) );
			while ( bf->at[bf->count-1] == '0' ) --bf->count;
			if ( bint->sign < 0 ) Buffer_Fill_Append(bf,'-',1);
		}
		else
			Buffer_Fill_Append(bf,'0',1);
		ret = Str_Reverse(bf->at,bf->count);
	}
	return ret;
}
#endif
;

char *Bigint_Encode_16(C_BIGINT *bint)
#ifdef _C_BIGINT_BUILTIN
{
	char *ret = 0;
	__Auto_Ptr(ret)
	{
		int i,L,bc = (Bigint_Bitcount(bint)+7)/8;
		ret = Str_Hex_Encode(bint->value,bc);
		L = ret?strlen(ret):0;
		for ( i = 0; i < L/2; i+=2 )
		{ 
			char T;
			T = ret[i]; ret[i] = ret[(L-i)-2]; ret[(L-i)-2] = T;
			T = ret[i+1]; ret[i+1] = ret[(L-i)-1]; ret[(L-i)-1] = T;
		}
	}
	return ret;
}
#endif
;

C_BIGINT *Bigint_Mul(C_BIGINT *bint, C_BIGINT *d)
#ifdef _C_BIGINT_BUILTIN
{
	C_BIGINT *R = Bigint_Alloca(bint->digits+d->digits+1);
	int i, Qdigi, j, Tdigi;

	R->digits = bint->digits+d->digits+1;

	for ( i = 0, Qdigi = d->digits, Tdigi = bint->digits; i < Qdigi; ++i )
	{
		uwidelong_t Q = 0;
		uwidelong_t C = 0;
		for ( j = 0; j < Tdigi; ++j )
		{
			Q = (uwidelong_t)d->value[i] * (uwidelong_t)bint->value[j] + Q;
			C = (uwidelong_t)R->value[j+i] + (Q & C_BIGINT_DIGIT_MASK) + C;
			R->value[j+i] = (uhalflong_t)C;
			Q >>=C_BIGINT_DIGIT_SHIFT;
			C >>= C_BIGINT_DIGIT_SHIFT;
		}
		do 
		{
			C = (uwidelong_t)R->value[Tdigi+i] + (Q & C_BIGINT_DIGIT_MASK) + C;
			R->value[Tdigi+i] = (uhalflong_t)C;
			Q >>= C_BIGINT_DIGIT_SHIFT;
			C >>= C_BIGINT_DIGIT_SHIFT;
		}
		while ( i < Qdigi && C ); 
	}

	while ( R->digits > 1 && !R->value[R->digits-1] ) --R->digits;
	if ( d->sign != bint->sign ) R->sign = -1;
	return Bigint_Copy_To(R,bint);
}
#endif
;

C_BIGINT *Bigint_Modulo(C_BIGINT *bint, C_BIGINT *mod)
#ifdef _C_BIGINT_BUILTIN
{
	int bits = Bigint_Bitcount(bint);
	int modbits = Bigint_Bitcount(mod);
	C_BIGINT *R = Bigint_Alloca(mod->digits+1);

	if ( modbits > bits ) return bint;

	R = Bigint_Hishift_Q(R,bint,modbits,&bits);

	for(;;) 
	{
		if ( !Bigint_Less(R,mod) )
		{
			R = Bigint_Sub(R,mod);
			STRICT_REQUIRE(Bigint_Less(R,mod));
		}
		if ( !bits ) break;
		R = Bigint_Hishift_1(R,bint,&bits);
	}

	return Bigint_Copy_To(R,bint);
}
#endif
;

C_BIGINT *Bigint_Modmul(C_BIGINT *bint, C_BIGINT *d, C_BIGINT *mod)
#ifdef _C_BIGINT_BUILTIN
{
	C_BIGINT *R = Bigint_Alloca(bint->digits+d->digits+1);
	int i, Qdigi, j, Tdigi;
	int bits, modbits;
	R->digits = bint->digits+d->digits+1;

	for ( i = 0, Qdigi = d->digits, Tdigi = bint->digits; i < Qdigi; ++i )
	{
		uwidelong_t Q = 0;
		uwidelong_t C = 0;
		for ( j = 0; j < Tdigi; ++j )
		{
			Q = (uwidelong_t)d->value[i] * (uwidelong_t)bint->value[j] + Q;
			C = (uwidelong_t)R->value[j+i] + (Q & C_BIGINT_DIGIT_MASK) + C;
			R->value[j+i] = (uhalflong_t)C;
			Q >>=C_BIGINT_DIGIT_SHIFT;
			C >>= C_BIGINT_DIGIT_SHIFT;
		}
		do 
		{
			C = (uwidelong_t)R->value[Tdigi+i] + (Q & C_BIGINT_DIGIT_MASK) + C;
			R->value[Tdigi+i] = (uhalflong_t)C;
			Q >>= C_BIGINT_DIGIT_SHIFT;
			C >>= C_BIGINT_DIGIT_SHIFT;
		}
		while ( i < Qdigi && C ); 
	}

	while ( R->digits > 1 && !R->value[R->digits-1] ) --R->digits;
	if ( d->sign != bint->sign ) R->sign = -1;

	bits = Bigint_Bitcount(R);
	modbits = Bigint_Bitcount(mod);

	if ( modbits > bits ) return Bigint_Copy_To(R,bint);

	bint = Bigint_Hishift_Q(bint,R,modbits,&bits);

	for(;;) 
	{
		if ( !Bigint_Less(bint,mod) )
		{
			bint = Bigint_Sub(bint,mod);
			STRICT_REQUIRE(Bigint_Less(bint,mod));
		}
		if ( !bits ) break;
		bint = Bigint_Hishift_1(bint,R,&bits);
	}

	return bint;
}
#endif
;

C_BIGINT *Bigint_Modpow2(C_BIGINT *bint,C_BIGINT *mod)
#ifdef _C_BIGINT_BUILTIN
{
	uwidelong_t Q,T;
	int modbits, bits;
	C_BIGINT *R;
	int i, j, k, Tdigi;

	R = Bigint_Alloca(bint->digits*2);
	R->digits = bint->digits*2;

	for ( i = 0, Tdigi = bint->digits; i < Tdigi; ++i )
	{
		T = (uwidelong_t)bint->value[i] * bint->value[i];
		j = i*2;
		Q = (uwidelong_t)R->value[j] + (T&C_BIGINT_DIGIT_MASK);
		R->value[j] = (halflong_t)Q;
		Q = (T>>C_BIGINT_DIGIT_SHIFT) + (Q >> C_BIGINT_DIGIT_SHIFT);

		++j;
		for (k = i+1; k < Tdigi; ++k, ++j )
		{
			T = (uwidelong_t)bint->value[i] * bint->value[k];
			Q = (uwidelong_t)R->value[j] + (T&C_BIGINT_DIGIT_MASK)*2 + Q;
			R->value[j] = (halflong_t)Q;
			Q = (T>>(C_BIGINT_DIGIT_SHIFT-1)&(uwidelong_t)~1) + (Q>>C_BIGINT_DIGIT_SHIFT);
		}

		for( ;j < R->digits && Q; ++j )
		{
			Q = (R->value[j] + Q);
			R->value[j] = (halflong_t)Q;
			Q >>= C_BIGINT_DIGIT_SHIFT;
		}

		STRICT_REQUIRE(!Q);
	}

	while ( R->digits > 1 && !R->value[R->digits-1] ) --R->digits;
	R->sign = 1;

	bits = Bigint_Bitcount(R);
	modbits = Bigint_Bitcount(mod);

	if ( modbits > bits ) return Bigint_Copy_To(R,bint);

	bint = Bigint_Hishift_Q(bint,R,modbits,&bits);

	for(;;) 
	{
		if ( !Bigint_Less(bint,mod) )
		{
			bint = Bigint_Sub(bint,mod);
			STRICT_REQUIRE(Bigint_Less(bint,mod));
		}
		if ( !bits ) break;
		bint = Bigint_Hishift_1(bint,R,&bits);
	}

	return bint;
}
#endif
;

C_BIGINT *Bigint_Expmod(C_BIGINT *bint, C_BIGINT *e,C_BIGINT *mod)
#ifdef _C_BIGINT_BUILTIN
{
	C_BIGINT *E = Bigint_Alloca(e->digits);
	C_BIGINT *t = Bigint_Alloca(mod->digits);
	C_BIGINT *R = 0;

	__Auto_Ptr(R)
	{
		E = Bigint_Copy_To(e,E);
		t = Bigint_Modulo(Bigint_Copy_To(bint,t),mod);
		R = bint;
		R->value[0] = 1;
		R->digits = 1;

		if ( !Bigint_Is_0(E) ) for(;;) 
		{
			if ( E->value[0] & 1 )
				R = Bigint_Modmul(R,t,mod);
			Bigint_Rshift_1(E);
			if ( !E->value[0] && Bigint_Is_0(E) ) break;
			//t = Bigint_Modmul(t,t,mod);
			t = Bigint_Modpow2(t,mod);
		}
	}

	return R;
}
#endif
;

C_BIGINT *Bigint_Invmod(C_BIGINT *bint, C_BIGINT *mod)
#ifdef _C_BIGINT_BUILTIN
{
	C_BIGINT *i = 0;

	__Auto_Ptr(i)
	{
		C_BIGINT *b = Bigint_Copy(mod);
		C_BIGINT *j = Bigint_Init(1);
		C_BIGINT *c = Bigint_Copy(bint);
		i = Bigint_Init(0);

		while ( c->value[0] || !Bigint_Is_0(c) )
		{
			C_BIGINT *y;
			C_BIGINT *q;
			C_BIGINT *x;
			x = Bigint_Divrem(b,c,&y);
			b = c;
			c = y;
			q = Bigint_Sub(i,Bigint_Mul(Bigint_Copy(j),x));
			i = j;
			j = q;
		}

		if ( i->sign < 0 ) i = Bigint_Add(i,mod);
	}

	return i;
}
#endif
;

#ifndef _C_BIGINT_BUILTIN
extern
#endif
	unsigned short First_Prime_Values[]
#ifdef _C_BIGINT_BUILTIN
= {
#include "prime_values.inc"        
}
#endif
;

#ifndef _C_BIGINT_BUILTIN
extern
#endif
	int First_Prime_Values_Count
#ifdef _C_BIGINT_BUILTIN
	= sizeof(First_Prime_Values)/sizeof(First_Prime_Values[0])
#endif
	;

#ifdef _C_BIGINT_BUILTIN
enum 
{ 
	C_PRIME_MAX_COUNT = /*1229*/ sizeof(First_Prime_Values)/sizeof(First_Prime_Values[0]),
	C_PRIME_RSAPUBLIC_MIN = 256, 
	C_PRIME_RSAPUBLIC_MAX = C_PRIME_MAX_COUNT,
	C_PRIME_TEST_Q = 32,
};
#endif

uhalflong_t First_Prime(int no)
#ifdef _C_BIGINT_BUILTIN
{
	STRICT_REQUIRE(no >= 0 && no < C_PRIME_MAX_COUNT);
	return First_Prime_Values[no];
}
#endif
;

int Bigint_Ferma_Prime_Test(C_BIGINT *bint, int q)
#ifdef _C_BIGINT_BUILTIN
{
	int is_prime = 1;
	__Auto_Release
	{
		int i;
		C_BIGINT *p   = Bigint_Alloca(bint->digits);
		C_BIGINT *p_1 = Bigint_Alloca(bint->digits);
		C_BIGINT *t   = Bigint_Alloca(1);

		if ( !q ) q = C_PRIME_TEST_Q;
		STRICT_REQUIRE( q > 0 && q < C_PRIME_MAX_COUNT );

		p = Bigint_Copy_To(bint,p);
		p_1 = Bigint_Sub_Short(Bigint_Copy_To(bint,p_1),1);

		for ( i =0; is_prime && i < q; ++i )
		{
			t->value[0] = First_Prime_Values[i];
			t->digits = 1;
			if ( !Bigint_Is_1(Bigint_Expmod(t,p_1,p)) )
				is_prime = 0;
		}
	}

	return is_prime;
}
#endif
;

#define Bigint_Random_Bytes(Bint,Count) Bigint_Random_Bits(Bint,Count*8) 
C_BIGINT *Bigint_Random_Bits(C_BIGINT *bint,int bits)
#ifdef _C_BIGINT_BUILTIN
{
	int i;
	byte_t *b;
	bint = Bigint_Expand_If_Small_Bits(bint,bits);
	b = (byte_t*)bint->value;
	Soft_Random(b,(bits+7)/8);
	i = (bits+7)&~7;
	while ( --i >= bits ) b[i/8] &= ~(1<<(i%8));
	b[i/8] |= 1<<(i%8);
	return bint;
}
#endif
;

C_BIGINT *Bigint_Prime(int bits, int q, int maxcount,C_BIGINT *tmp)
#ifdef _C_BIGINT_BUILTIN
{
	int i,n;
	C_BIGINT *ret = 0;
	C_BIGINT *r = tmp;

	if ( !q ) q = 11;//C_PRIME_TEST_Q;
	if ( !maxcount ) maxcount = 1001;

	STRICT_REQUIRE( maxcount > 0 );
	STRICT_REQUIRE( bits > 8 );
	STRICT_REQUIRE( q > 0 && q < C_PRIME_MAX_COUNT );

	n = C_MAX(11,bits-3);
	if ( !r )
		r = Bigint_Alloca(Bigint_Digits_Of_Bits(bits)+1);

	while ( !ret && maxcount-- ) __Auto_Ptr(ret)
	{
		byte_t *b = (byte_t*)r->value;
		r->digits = Bigint_Digits_Of_Bits(bits);
		memset(b,0,Bigint_Bytes_Count(r));
		Soft_Random(b,(bits+7)/8);

		i = (bits+7)&~7;
		while ( --i >= bits ) b[i/8] &= ~(1<<(i%8));
		b[i/8] |= 1<<(i%8);
		--i;
		b[i/8] &= ~(1<<(i%8));
		b[0] |= 1;

		STRICT_REQUIRE( Bigint_Bitcount(r) == bits );
		STRICT_REQUIRE( Bigint_Less(Bigint_Lshift(Bigint_Init(1),bits-1),r) ); 
		STRICT_REQUIRE( Bigint_Less(r,Bigint_Lshift(Bigint_Init(3),bits-1)) ); 

		for ( i = 0; i < n; ++i )
		{
			int j;
			for ( j = 1; j < C_MIN(1000,First_Prime_Values_Count); ++j ) 
			{
				if ( !Bigint_Modulo_Short(r,First_Prime_Values[j]) )
					goto cont;
			}
			if ( Bigint_Ferma_Prime_Test(r,q) )
			{
				ret = !tmp ? Bigint_Copy(r) : r;
				break;
			}
cont:
			r = Bigint_Add_Short(r,2);
		}
	}

	if ( !ret )
		__Raise(C_ERROR_LIMIT_REACHED,"failed to generate prime");
	return ret;
}
#endif
;

void Bigint_Generate_Rsa_PQ(
	C_BIGINT /*out*/ **rsa_P, int pBits,
	C_BIGINT /*out*/ **rsa_Q, int qBits,
	C_BIGINT /*out*/ **rsa_N)
#ifdef _C_BIGINT_BUILTIN
{
	int lt = 0;
	int bits = qBits+pBits-1;
	C_BIGINT *nMax = Bigint_Init(1);
	C_BIGINT *nMin = Bigint_Init(1);
	C_BIGINT *n, *p, *q;
	C_BIGINT *pr = Bigint_Alloca(Bigint_Digits_Of_Bits(pBits)+1);
	C_BIGINT *qr = Bigint_Alloca(Bigint_Digits_Of_Bits(qBits)+1);
	C_BIGINT *nr = Bigint_Alloca(Bigint_Digits_Of_Bits(bits)+1);

	nMax = Bigint_Sub_Short(Bigint_Lshift(nMax,bits),1);
	nMin = Bigint_Lshift(nMin,bits-1);

	REQUIRE(bits >= 33);
	STRICT_REQUIRE(pBits > 0);
	STRICT_REQUIRE(qBits > 0);
	STRICT_REQUIRE(Bigint_Less(nMin,nMax));

	for(;;)
	{
		__Purge(&lt);
		p = q = 0;
		p = Bigint_Prime(pBits,0,0,pr);
		q = Bigint_Prime(qBits,0,0,qr);
		n = Bigint_Mul(Bigint_Copy_To(p,nr),q);
		if ( Bigint_Less(n,nMax) && Bigint_Less(nMin,n) )
			break;
	}

	*rsa_P = (p == pr) ? Bigint_Copy(p) : p;
	*rsa_Q = (q == qr) ? Bigint_Copy(q) : q; 
	*rsa_N = (n == nr) ? Bigint_Copy(n) : n;
}
#endif
;

C_BIGINT *Bigint_Mutal_Prime(C_BIGINT *bint, int bits)
#ifdef _C_BIGINT_BUILTIN
{
	C_BIGINT *ret = 0;
	C_BIGINT *r = Bigint_Alloca(Bigint_Digits_Of_Bits(bits)+1);
	C_BIGINT *d = Bigint_Alloca(bint->digits);
	while (!ret) __Auto_Ptr(ret)
	{
		C_BIGINT *x = Bigint_Prime(bits,0,0,r);
		Bigint_Copy_To(bint,d);
		if ( !Bigint_Is_0(Bigint_Modulo(d,x)) )
			ret = (x == r) ? Bigint_Copy(x) : x;
	}
	return ret;
}
#endif
;

C_BIGINT *Bigint_First_Mutal_Prime(C_BIGINT *bint, int skip_primes)
#ifdef _C_BIGINT_BUILTIN
{
	int i;
	uhalflong_t rem = 0;
	uhalflong_t prime;
	C_BIGINT *r = Bigint_Alloca(bint->digits);

	REQUIRE(skip_primes > 0 && skip_primes < C_PRIME_MAX_COUNT/2 );

	for ( i = skip_primes; !rem && i < C_PRIME_MAX_COUNT; ++i )
	{
		C_BIGINT *x = Bigint_Copy_To(bint,r);
		prime = First_Prime_Values[i];
		Bigint_Divrem_Short(x,prime,&rem);
	}

	if ( rem )         
		return Bigint_Init(prime);

	return 0;      
}
#endif
;

C_BIGINT *Bigint_From_Int(C_BIGINT *bint, widelong_t val)
#ifdef _C_BIGINT_BUILTIN
{
	int i;
	int digits = Bigint_Digits_Of_Bytes((sizeof(val)*8+C_BIGINT_DIGIT_SHIFT-1)/C_BIGINT_DIGIT_SHIFT);
	bint = Bigint_Expand_If_Small(bint,digits);
	bint->sign = val < 0 ? -1 : 1;
	val = val < 0 ? -val : val;
	for ( i = 0; i < digits; ++i )
	{
		bint->value[i] = val&C_BIGINT_DIGIT_MASK;
		val >>= C_BIGINT_DIGIT_SHIFT;
	}
	return bint;
}
#endif
;


#define Bigint_Generate_Rsa_Key_Pair(Pub,Priv,Mod,Bits) Bigint_Generate_Rsa_Key_Pair_(Pub,Priv,Mod,Bits,0)
void Bigint_Generate_Rsa_Key_Pair_(
	C_BIGINT /*out*/ **rsa_pub, 
	C_BIGINT /*out*/ **rsa_priv, 
	C_BIGINT /*out*/ **rsa_mod,
	int bits,
	widelong_t prime)
#ifdef _C_BIGINT_BUILTIN
{
	__Auto_Ptr(*rsa_mod)
	{
		C_BIGINT *p, *q, *n, *phi;
		int pBits = Get_Random(bits/5,bits/2);
		int qBits = (bits+1)-pBits;

		STRICT_REQUIRE(pBits < bits/2 && pBits > 0 );
		STRICT_REQUIRE(pBits+qBits == bits+1);

		n = 0;
		while ( !n ) __Auto_Ptr(n)
		{
			Bigint_Generate_Rsa_PQ(&p,pBits,&q,qBits,&n);

			phi = Bigint_Mul(Bigint_Sub_Short(p,1),Bigint_Sub_Short(q,1));

			if ( prime )
				*rsa_pub = Bigint_From_Int(0,prime);
			else
				*rsa_pub = Bigint_Mutal_Prime(phi,bits/3);

			if ( !*rsa_pub ) n = 0;
			else
			{
				*rsa_priv  = Bigint_Invmod(*rsa_pub,phi);
				__Retain(*rsa_pub);
				__Retain(*rsa_priv);
				*rsa_mod = n;
			}
		}
	}

	__Pool(*rsa_pub);
	__Pool(*rsa_priv);
}
#endif
;

C_BIGINT *Bigint_From_Bytes(C_BIGINT *bint, void *data, int len)
#ifdef _C_BIGINT_BUILTIN
{
#if defined __i386 || defined __x86_64
	int digits = Bigint_Digits_Of_Bytes(len);
	bint = Bigint_Expand_If_Small(bint,digits);
	memset(bint->value,0,bint->digits*sizeof(uhalflong_t));
	memcpy(bint->value,data,len);
	return bint;
#else
#error fixme!
#endif
}
#endif
;

int Bigint_To_Bytes(C_BIGINT *bint, void *out, int maxlen)
#ifdef _C_BIGINT_BUILTIN
{
#if defined __i386 || defined __x86_64
	int l = sizeof(uhalflong_t)*bint->digits;
	byte_t *p = (byte_t*)(bint->value+bint->digits) - 1;
	while ( p != (byte_t*)bint->value && !*p ) --l;
	if ( l > maxlen )
		__Raise(C_ERROR_NO_ENOUGH,"raw bigint outbuffer to small!");
	memcpy(out,bint->value,l);
	return l;
#else
#error fixme!
#endif
}
#endif
;

C_BIGINT *Bigint_Sign(C_BIGINT *K,C_BIGINT *N,void *data,int len)
#ifdef _C_BIGINT_BUILTIN
{
	C_BIGINT *tmp = 0;
	int mbits = Bigint_Bitcount(N)-1;
	if ( len*8 > mbits )
		__Raise_Format(C_ERROR_OUT_OF_RANGE,
		("data length is %d bytes, maximum %bytes alowed to sign with %d bits keys",
		len,mbits/8,mbits));

	__Auto_Ptr(tmp)
	{
		void *Q = __Zero_Malloc((mbits+7)/8);
		//Soft_Random(Q,(mbits+1)/8);
		memcpy(Q,data,len);
		((byte_t*)Q)[mbits/8] &= ~(1<<(mbits%8)); 
		tmp = Bigint_From_Bytes(0,Q,mbits/8);
		tmp = Bigint_Expmod(tmp,K,N);
	}

	return tmp;
}
#endif
;

char *Bigint_Hex_Sign(C_BIGINT *K,C_BIGINT *N,void *data,int len)
#ifdef _C_BIGINT_BUILTIN
{
	char *hex = 0;
	__Auto_Ptr(hex)
	{
		C_BIGINT *bint = Bigint_Sign(K,N,data,len);
		hex = Bigint_Encode_16(bint);
	}
	return hex;
}
#endif
;

int Bigint_Verify(C_BIGINT *K,C_BIGINT *N,C_BIGINT *digest,void *data,int len)
#ifdef _C_BIGINT_BUILTIN
{
	int correct = 0;
	int mbits = Bigint_Bitcount(N)-1;
	if ( len*8 > mbits )
		__Raise_Format(C_ERROR_OUT_OF_RANGE,
		("data length is %d bytes, maximum %bytes alowed to sign with %d bits keys",
		len,mbits/8,mbits));

	__Auto_Release
	{
		C_BIGINT *tmp = Bigint_Copy(digest);
		tmp = Bigint_Expmod(tmp,K,N);
		if ( Bigint_Bitcount(tmp) <= len*8 && !memcmp(tmp->value,data,len) )
			correct = 1;
	}

	return correct;
}
#endif
;

int Bigint_Hex_Verify(C_BIGINT *K,C_BIGINT *N,char *S,void *data,int len)
#ifdef _C_BIGINT_BUILTIN
{
	int correct = 0;
	__Auto_Release
	{
		correct = Bigint_Verify(K,N,
								Bigint_Decode_16(S),
								data,len);
	}
	return correct;
}
#endif
;

void Bigint_Rsa_Key_Decode(char *S, C_BIGINT **K, C_BIGINT **N)
#ifdef _C_BIGINT_BUILTIN
{
	C_ARRAY *L = Str_Split(S,":");
	*K = *N = 0;
	if ( L->count != 4 )
		__Raise(C_ERROR_ILLFORMED,"invalid key format");    
	if ( !strcmp(L->at[0],"hex") )
	{
		*K = Bigint_Decode_16(L->at[2]);  
		*N = Bigint_Decode_16(L->at[3]);  
	}
	else if ( !strcmp(L->at[0],"dec") )
	{
		*K = Bigint_Decode_10(L->at[2]);  
		*N = Bigint_Decode_10(L->at[3]);  
	}
	else
		__Raise(C_ERROR_UNSUPPORTED,"unsupported key format");    
}
#endif
;  

#endif /* C_once_B4220D86_3019_4E13_8682_D7F809F4E829 */


