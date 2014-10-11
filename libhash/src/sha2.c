
/*
   The SHA-256 Secure Hash Standard was published by NIST in 2002.
   http://csrc.nist.gov/publications/fips/fips180-2/fips180-2.pdf
*/

#include "../include/libhash/SHA2.h"
#include <assert.h>

typedef struct SHA2_CONTEXT C_SHA2;
typedef struct SHA2_HMAC_CONTEXT C_HMAC_SHA2;

void SHA2_Start(C_SHA2* sha2)
{
	memset(sha2, 0, sizeof(*sha2));
	sha2->state[0] = 0x6a09e667;
	sha2->state[1] = 0xbb67ae85;
	sha2->state[2] = 0x3c6ef372;
	sha2->state[3] = 0xa54ff53a;
	sha2->state[4] = 0x510e527f;
	sha2->state[5] = 0x9b05688c;
	sha2->state[6] = 0x1f83d9ab;
	sha2->state[7] = 0x5be0cd19;
}

void SHA2_Internal_Encode(uint8_t* output, uint32_t* input, uint32_t len)
{
	uint32_t i, j;

	for (i = 0, j = 0; j < len; i++, j += 4)
	{
		output[j + 0] = (uint8_t)(input[i] >> 24);
		output[j + 1] = (uint8_t)(input[i] >> 16);
		output[j + 2] = (uint8_t)(input[i] >> 8);
		output[j + 3] = (uint8_t)(input[i]);
	}
}

void SHA2_Internal_Decode(uint32_t* output, uint8_t* input, uint32_t len)
{
	uint32_t i, j;
	for (i = 0, j = 0; j < len; i++, j += 4)
		output[i] = ((uint32_t)input[j + 3]) | (((uint32_t)input[j + 2]) << 8) |
		            (((uint32_t)input[j + 1]) << 16) | (((uint32_t)input[j + 0]) << 24);
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
		uint32_t foo = h + S3(e) + F1(e,f,g) + K + x; \
		uint32_t bar = S2(a) + F0(a,b,c); \
		d += foo; h = foo + bar; \
	}

void SHA2_Internal_Transform(C_SHA2* sha2, void* block)
{
	uint32_t* state = sha2->state;
	uint32_t
	a = state[0],
	b = state[1],
	c = state[2],
	d = state[3],
	e = state[4],
	f = state[5],
	g = state[6],
	h = state[7],
	x[64];

	SHA2_Internal_Decode(x, block, 64);

	F(a, b, c, d, e, f, g, h, x[ 0], 0x428a2f98);
	F(h, a, b, c, d, e, f, g, x[ 1], 0x71374491);
	F(g, h, a, b, c, d, e, f, x[ 2], 0xb5c0fbcf);
	F(f, g, h, a, b, c, d, e, x[ 3], 0xe9b5dba5);
	F(e, f, g, h, a, b, c, d, x[ 4], 0x3956c25b);
	F(d, e, f, g, h, a, b, c, x[ 5], 0x59f111f1);
	F(c, d, e, f, g, h, a, b, x[ 6], 0x923f82a4);
	F(b, c, d, e, f, g, h, a, x[ 7], 0xab1c5ed5);
	F(a, b, c, d, e, f, g, h, x[ 8], 0xd807aa98);
	F(h, a, b, c, d, e, f, g, x[ 9], 0x12835b01);
	F(g, h, a, b, c, d, e, f, x[10], 0x243185be);
	F(f, g, h, a, b, c, d, e, x[11], 0x550c7dc3);
	F(e, f, g, h, a, b, c, d, x[12], 0x72be5d74);
	F(d, e, f, g, h, a, b, c, x[13], 0x80deb1fe);
	F(c, d, e, f, g, h, a, b, x[14], 0x9bdc06a7);
	F(b, c, d, e, f, g, h, a, x[15], 0xc19bf174);
	F(a, b, c, d, e, f, g, h, R(16), 0xe49b69c1);
	F(h, a, b, c, d, e, f, g, R(17), 0xefbe4786);
	F(g, h, a, b, c, d, e, f, R(18), 0x0fc19dc6);
	F(f, g, h, a, b, c, d, e, R(19), 0x240ca1cc);
	F(e, f, g, h, a, b, c, d, R(20), 0x2de92c6f);
	F(d, e, f, g, h, a, b, c, R(21), 0x4a7484aa);
	F(c, d, e, f, g, h, a, b, R(22), 0x5cb0a9dc);
	F(b, c, d, e, f, g, h, a, R(23), 0x76f988da);
	F(a, b, c, d, e, f, g, h, R(24), 0x983e5152);
	F(h, a, b, c, d, e, f, g, R(25), 0xa831c66d);
	F(g, h, a, b, c, d, e, f, R(26), 0xb00327c8);
	F(f, g, h, a, b, c, d, e, R(27), 0xbf597fc7);
	F(e, f, g, h, a, b, c, d, R(28), 0xc6e00bf3);
	F(d, e, f, g, h, a, b, c, R(29), 0xd5a79147);
	F(c, d, e, f, g, h, a, b, R(30), 0x06ca6351);
	F(b, c, d, e, f, g, h, a, R(31), 0x14292967);
	F(a, b, c, d, e, f, g, h, R(32), 0x27b70a85);
	F(h, a, b, c, d, e, f, g, R(33), 0x2e1b2138);
	F(g, h, a, b, c, d, e, f, R(34), 0x4d2c6dfc);
	F(f, g, h, a, b, c, d, e, R(35), 0x53380d13);
	F(e, f, g, h, a, b, c, d, R(36), 0x650a7354);
	F(d, e, f, g, h, a, b, c, R(37), 0x766a0abb);
	F(c, d, e, f, g, h, a, b, R(38), 0x81c2c92e);
	F(b, c, d, e, f, g, h, a, R(39), 0x92722c85);
	F(a, b, c, d, e, f, g, h, R(40), 0xa2bfe8a1);
	F(h, a, b, c, d, e, f, g, R(41), 0xa81a664b);
	F(g, h, a, b, c, d, e, f, R(42), 0xc24b8b70);
	F(f, g, h, a, b, c, d, e, R(43), 0xc76c51a3);
	F(e, f, g, h, a, b, c, d, R(44), 0xd192e819);
	F(d, e, f, g, h, a, b, c, R(45), 0xd6990624);
	F(c, d, e, f, g, h, a, b, R(46), 0xf40e3585);
	F(b, c, d, e, f, g, h, a, R(47), 0x106aa070);
	F(a, b, c, d, e, f, g, h, R(48), 0x19a4c116);
	F(h, a, b, c, d, e, f, g, R(49), 0x1e376c08);
	F(g, h, a, b, c, d, e, f, R(50), 0x2748774c);
	F(f, g, h, a, b, c, d, e, R(51), 0x34b0bcb5);
	F(e, f, g, h, a, b, c, d, R(52), 0x391c0cb3);
	F(d, e, f, g, h, a, b, c, R(53), 0x4ed8aa4a);
	F(c, d, e, f, g, h, a, b, R(54), 0x5b9cca4f);
	F(b, c, d, e, f, g, h, a, R(55), 0x682e6ff3);
	F(a, b, c, d, e, f, g, h, R(56), 0x748f82ee);
	F(h, a, b, c, d, e, f, g, R(57), 0x78a5636f);
	F(g, h, a, b, c, d, e, f, R(58), 0x84c87814);
	F(f, g, h, a, b, c, d, e, R(59), 0x8cc70208);
	F(e, f, g, h, a, b, c, d, R(60), 0x90befffa);
	F(d, e, f, g, h, a, b, c, R(61), 0xa4506ceb);
	F(c, d, e, f, g, h, a, b, R(62), 0xbef9a3f7);
	F(b, c, d, e, f, g, h, a, R(63), 0xc67178f2);

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

void SHA2_Update(C_SHA2* sha2, const void* input, size_t input_length)
{
	int i, index, partLen;
	uint32_t* count = sha2->count;
	index = (uint32_t)((count[0] >> 3) & 0x3F);
	if ((count[0] += ((uint32_t)input_length << 3)) < ((uint32_t)input_length << 3))
		count[1]++;
	count[1] += ((uint32_t)input_length >> 29);
	partLen = 64 - index;

	if (input_length >= partLen)
	{
		memcpy(&sha2->buffer[index], input, partLen);
		SHA2_Internal_Transform(sha2, sha2->buffer);
		for (i = partLen; i + 63 < input_length; i += 64)
			SHA2_Internal_Transform(sha2, &((uint8_t*)input)[i]);
		index = 0;
	}
	else
		i = 0;
	memcpy(&sha2->buffer[index], &((uint8_t*)input)[i], input_length - i);
}

void SHA2_Finish(C_SHA2* sha2, void* digest)
{
	if (!sha2->finished)
	{
		static uint8_t PADDING[64] =
		{
			0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		};
		uint8_t bits[8];
		uint32_t index, padLen;
		SHA2_Internal_Encode(bits, sha2->count + 1, 4);
		SHA2_Internal_Encode(bits + 4, sha2->count, 4);
		index = (uint32_t)((sha2->count[0] >> 3) & 0x3f);
		padLen = (index < 56) ? (56 - index) : (120 - index);
		SHA2_Update(sha2, PADDING, padLen);
		SHA2_Update(sha2, bits, 8);
		sha2->finished = 1;
	}
	SHA2_Internal_Encode(digest, sha2->state, 32);
}

void SHA2_HMAC_Start(C_HMAC_SHA2* hmac, const void* key, size_t key_len)
{
	int i;
	uint8_t sum[32];

	if (key_len > 64)
	{
		SHA2_Start(&hmac->sha2);
		SHA2_Update(&hmac->sha2, key, key_len);
		SHA2_Finish(&hmac->sha2, sum);
		key = sum;
		key_len = 32;
	}

	memset(hmac->ipad, 0x36, 64);
	memset(hmac->opad, 0x5C, 64);

	for (i = 0; i < key_len; ++i)
	{
		hmac->ipad[i] = (uint8_t)(hmac->ipad[i] ^ ((uint8_t*)key)[i]);
		hmac->opad[i] = (uint8_t)(hmac->opad[i] ^ ((uint8_t*)key)[i]);
	}

	SHA2_Start(&hmac->sha2);
	SHA2_Update(&hmac->sha2, hmac->ipad, 64);
}

void SHA2_HMAC_Update(C_HMAC_SHA2* hmac, const void* bytes, size_t count)
{
	SHA2_Update(&hmac->sha2, bytes, count);
}

void SHA2_HMAC_Finish(C_HMAC_SHA2* hmac, void* digest)
{
	uint8_t tmpb[32];
	SHA2_Finish(&hmac->sha2, tmpb);
	SHA2_Start(&hmac->sha2);
	SHA2_Update(&hmac->sha2, &hmac->opad, 64);
	SHA2_Update(&hmac->sha2, tmpb, 32);
	memset(tmpb, 0, 32);
	SHA2_Finish(&hmac->sha2, digest);
}

