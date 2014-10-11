
/*
   The SHA-1 standard was published by NIST in 1993.
   http://www.itl.nist.gov/fipspubs/fip180-1.htm
*/

#include "../include/libhash/SHA1.h"
#include <assert.h>

typedef struct SHA1_CONTEXT C_SHA1;
typedef struct SHA1_HMAC_CONTEXT C_HMAC_SHA1;

#define C_SHA1_INITIALIZER {{0x67452301,0xefcdab89,0x98badcfe,0x10325476,0xc3d2e1f0},{0},0,{0}}

void SHA1_Start(C_SHA1* sha1)
{
	memset(sha1, 0, sizeof(*sha1));
	sha1->state[0] = 0x67452301;
	sha1->state[1] = 0xefcdab89;
	sha1->state[2] = 0x98badcfe;
	sha1->state[3] = 0x10325476;
	sha1->state[4] = 0xc3d2e1f0;
}


static void SHA1_Internal_Encode(uint8_t* output, uint32_t* input, uint32_t len)
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

static void SHA1_Internal_Decode(uint32_t* output, uint8_t* input, uint32_t len)
{
	uint32_t i, j;
	for (i = 0, j = 0; j < len; i++, j += 4)
		output[i] = ((uint32_t)input[j + 3]) | (((uint32_t)input[j + 2]) << 8) |
		            (((uint32_t)input[j + 1]) << 16) | (((uint32_t)input[j + 0]) << 24);
}

#define ROTATE_LEFT(x,n) (((x) << (n)) | ((x) >> (32-(n))))
#define R(t) (x[t&0x0f] = ROTATE_LEFT( \
                                       x[(t- 3)&0x0f] \
                                       ^ x[(t- 8)&0x0f] \
                                       ^ x[(t-14)&0x0f] \
                                       ^ x[(t   )&0x0f], \
                                       1 ))\
 
#define F(x,y,z) (z ^ ( x & ( y ^z)))
#define FF(a,b,c,d,e,q) e += ROTATE_LEFT(a,5) + F(b,c,d) + 0x5a827999u + q; b = ROTATE_LEFT(b,30)
#define G(x,y,z) (x ^ y ^ z)
#define GG(a,b,c,d,e,q) e += ROTATE_LEFT(a,5) + G(b,c,d) + 0x6ed9eba1u + q; b = ROTATE_LEFT(b,30)
#define H(x,y,z) ((x & y) | (z & (x | y)))
#define HH(a,b,c,d,e,q) e += ROTATE_LEFT(a,5) + H(b,c,d) + 0x8f1bbcdcu + q; b = ROTATE_LEFT(b,30)
#define I(x,y,z) (x ^ y ^ z)
#define II(a,b,c,d,e,q) e += ROTATE_LEFT(a,5) + I(b,c,d) + 0xca62c1d6u + q; b = ROTATE_LEFT(b,30)

static void SHA1_Internal_Transform(C_SHA1* sha1, void* block)
{
	uint32_t* state = sha1->state;
	uint32_t a = state[0], b = state[1], c = state[2], d = state[3], e = state[4], x[16];

	SHA1_Internal_Decode(x, block, 64);

	FF(a, b, c, d, e, x[0]);
	FF(e, a, b, c, d, x[1]);
	FF(d, e, a, b, c, x[2]);
	FF(c, d, e, a, b, x[3]);
	FF(b, c, d, e, a, x[4]);
	FF(a, b, c, d, e, x[5]);
	FF(e, a, b, c, d, x[6]);
	FF(d, e, a, b, c, x[7]);
	FF(c, d, e, a, b, x[8]);
	FF(b, c, d, e, a, x[9]);
	FF(a, b, c, d, e, x[10]);
	FF(e, a, b, c, d, x[11]);
	FF(d, e, a, b, c, x[12]);
	FF(c, d, e, a, b, x[13]);
	FF(b, c, d, e, a, x[14]);
	FF(a, b, c, d, e, x[15]);
	FF(e, a, b, c, d, R(16));
	FF(d, e, a, b, c, R(17));
	FF(c, d, e, a, b, R(18));
	FF(b, c, d, e, a, R(19));
	GG(a, b, c, d, e, R(20));
	GG(e, a, b, c, d, R(21));
	GG(d, e, a, b, c, R(22));
	GG(c, d, e, a, b, R(23));
	GG(b, c, d, e, a, R(24));
	GG(a, b, c, d, e, R(25));
	GG(e, a, b, c, d, R(26));
	GG(d, e, a, b, c, R(27));
	GG(c, d, e, a, b, R(28));
	GG(b, c, d, e, a, R(29));
	GG(a, b, c, d, e, R(30));
	GG(e, a, b, c, d, R(31));
	GG(d, e, a, b, c, R(32));
	GG(c, d, e, a, b, R(33));
	GG(b, c, d, e, a, R(34));
	GG(a, b, c, d, e, R(35));
	GG(e, a, b, c, d, R(36));
	GG(d, e, a, b, c, R(37));
	GG(c, d, e, a, b, R(38));
	GG(b, c, d, e, a, R(39));
	HH(a, b, c, d, e, R(40));
	HH(e, a, b, c, d, R(41));
	HH(d, e, a, b, c, R(42));
	HH(c, d, e, a, b, R(43));
	HH(b, c, d, e, a, R(44));
	HH(a, b, c, d, e, R(45));
	HH(e, a, b, c, d, R(46));
	HH(d, e, a, b, c, R(47));
	HH(c, d, e, a, b, R(48));
	HH(b, c, d, e, a, R(49));
	HH(a, b, c, d, e, R(50));
	HH(e, a, b, c, d, R(51));
	HH(d, e, a, b, c, R(52));
	HH(c, d, e, a, b, R(53));
	HH(b, c, d, e, a, R(54));
	HH(a, b, c, d, e, R(55));
	HH(e, a, b, c, d, R(56));
	HH(d, e, a, b, c, R(57));
	HH(c, d, e, a, b, R(58));
	HH(b, c, d, e, a, R(59));
	II(a, b, c, d, e, R(60));
	II(e, a, b, c, d, R(61));
	II(d, e, a, b, c, R(62));
	II(c, d, e, a, b, R(63));
	II(b, c, d, e, a, R(64));
	II(a, b, c, d, e, R(65));
	II(e, a, b, c, d, R(66));
	II(d, e, a, b, c, R(67));
	II(c, d, e, a, b, R(68));
	II(b, c, d, e, a, R(69));
	II(a, b, c, d, e, R(70));
	II(e, a, b, c, d, R(71));
	II(d, e, a, b, c, R(72));
	II(c, d, e, a, b, R(73));
	II(b, c, d, e, a, R(74));
	II(a, b, c, d, e, R(75));
	II(e, a, b, c, d, R(76));
	II(d, e, a, b, c, R(77));
	II(c, d, e, a, b, R(78));
	II(b, c, d, e, a, R(79));

	state[0] += a;
	state[1] += b;
	state[2] += c;
	state[3] += d;
	state[4] += e;

}

#undef R
#undef F
#undef G
#undef H
#undef I
#undef ROTATE_LEFT
#undef FF
#undef GG
#undef HH
#undef II

void SHA1_Update(C_SHA1* sha1, const void* input, size_t input_length)
{
	int i, index, partLen;
	uint32_t* count = sha1->count;
	index = (uint32_t)((count[0] >> 3) & 0x3F);
	if ((count[0] += ((uint32_t)input_length << 3)) < ((uint32_t)input_length << 3))
		count[1]++;
	count[1] += ((uint32_t)input_length >> 29);
	partLen = 64 - index;

	if (input_length >= partLen)
	{
		memcpy(&sha1->buffer[index], input, partLen);
		SHA1_Internal_Transform(sha1, sha1->buffer);
		for (i = partLen; i + 63 < input_length; i += 64)
			SHA1_Internal_Transform(sha1, &((uint8_t*)input)[i]);
		index = 0;
	}
	else
		i = 0;
	memcpy(&sha1->buffer[index], &((uint8_t*)input)[i], input_length - i);
}

void SHA1_Finish(C_SHA1* sha1, void* digest)
{
	assert(digest != 0);
	if (!sha1->finished)
	{
		static uint8_t PADDING[64] =
		{
			0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		};
		uint8_t bits[8] = {0};
		uint32_t index, padLen;
		SHA1_Internal_Encode(bits, sha1->count + 1, 4);
		SHA1_Internal_Encode(bits + 4, sha1->count, 4);
		index = (uint32_t)((sha1->count[0] >> 3) & 0x3f);
		padLen = (index < 56) ? (56 - index) : (120 - index);
		SHA1_Update(sha1, PADDING, padLen);
		SHA1_Update(sha1, bits, 8);
		sha1->finished = 1;
	}
	SHA1_Internal_Encode(digest, sha1->state, 20);
}

void SHA1_HMAC_Start(C_HMAC_SHA1* hmac, const void* key, size_t key_len)
{
	int i;
	uint8_t sum[20];

	if (key_len > 64)
	{
		SHA1_Start(&hmac->sha1);
		SHA1_Update(&hmac->sha1, key, key_len);
		SHA1_Finish(&hmac->sha1, sum);
		key = sum;
		key_len = 20;
	}

	memset(hmac->ipad, 0x36, 64);
	memset(hmac->opad, 0x5C, 64);

	for (i = 0; i < key_len; ++i)
	{
		hmac->ipad[i] = (uint8_t)(hmac->ipad[i] ^ ((uint8_t*)key)[i]);
		hmac->opad[i] = (uint8_t)(hmac->opad[i] ^ ((uint8_t*)key)[i]);
	}

	SHA1_Start(&hmac->sha1);
	SHA1_Update(&hmac->sha1, hmac->ipad, 64);
}

void SHA1_HMAC_Update(C_HMAC_SHA1* hmac, const void* bytes, size_t count)
{
	SHA1_Update(&hmac->sha1, bytes, count);
}

void SHA1_HMAC_Finish(C_HMAC_SHA1* hmac, void* digest)
{
	uint8_t tmpb[20];
	SHA1_Finish(&hmac->sha1, tmpb);
	SHA1_Start(&hmac->sha1);
	SHA1_Update(&hmac->sha1, &hmac->opad, 64);
	SHA1_Update(&hmac->sha1, tmpb, 20);
	memset(tmpb, 0, 20);
	SHA1_Finish(&hmac->sha1, digest);
}

