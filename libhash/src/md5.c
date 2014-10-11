

/*
  The MD5 algorithm was designed by Ron Rivest in 1991.
  http://www.ietf.org/rfc/rfc1321.txt
*/

#include "../include/libhash/MD5.h"
#include <assert.h>

enum { C_MD5_DIGEST_SIZE = 16 };

typedef MD5_CONTEXT C_MD5;
typedef MD5_HMAC_CONTEXT C_MD5_HMAC;

void MD5_Start(C_MD5* md5)
{
	memset(md5, 0, sizeof(*md5));
	md5->state[0] = 0x67452301;
	md5->state[1] = 0xefcdab89;
	md5->state[2] = 0x98badcfe;
	md5->state[3] = 0x10325476;
}

#if defined _X86 || defined __i386 || defined __x86_64
#define MD5_Internal_Encode memcpy
#define MD5_Internal_Decode memcpy
#else

static void MD5_Internal_Encode(uint8_t* output, uint32_t* input, uint32_t len)
{
	uint32_t i, j;

	for (i = 0, j = 0; j < len; i++, j += 4)
	{
		output[j]     = (uint8_t)(input[i] & 0xff);
		output[j + 1] = (uint8_t)((input[i] >> 8) & 0xff);
		output[j + 2] = (uint8_t)((input[i] >> 16) & 0xff);
		output[j + 3] = (uint8_t)((input[i] >> 24) & 0xff);
	}
}

static void MD5_Internal_Decode(uint32_t* output, uint8_t* input, uint32_t len)
{
	uint32_t i, j;

	for (i = 0, j = 0; j < len; i++, j += 4)
		output[i] = ((uint32_t)input[j]) | (((uint32_t)input[j + 1]) << 8) |
		            (((uint32_t)input[j + 2]) << 16) | (((uint32_t)input[j + 3]) << 24);
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

static void MD5_Internal_Transform(C_MD5* md5, void* block)
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

	uint32_t* state = md5->state;
	uint32_t a = state[0], b = state[1], c = state[2], d = state[3], x[16];

	MD5_Internal_Decode(x, block, 64);

	/* Round 1 */
	FF(a, b, c, d, x[ 0], S11, 0xd76aa478);  /* 1 */
	FF(d, a, b, c, x[ 1], S12, 0xe8c7b756);  /* 2 */
	FF(c, d, a, b, x[ 2], S13, 0x242070db);  /* 3 */
	FF(b, c, d, a, x[ 3], S14, 0xc1bdceee);  /* 4 */
	FF(a, b, c, d, x[ 4], S11, 0xf57c0faf);  /* 5 */
	FF(d, a, b, c, x[ 5], S12, 0x4787c62a);  /* 6 */
	FF(c, d, a, b, x[ 6], S13, 0xa8304613);  /* 7 */
	FF(b, c, d, a, x[ 7], S14, 0xfd469501);  /* 8 */
	FF(a, b, c, d, x[ 8], S11, 0x698098d8);  /* 9 */
	FF(d, a, b, c, x[ 9], S12, 0x8b44f7af);  /* 10 */
	FF(c, d, a, b, x[10], S13, 0xffff5bb1);  /* 11 */
	FF(b, c, d, a, x[11], S14, 0x895cd7be);  /* 12 */
	FF(a, b, c, d, x[12], S11, 0x6b901122);  /* 13 */
	FF(d, a, b, c, x[13], S12, 0xfd987193);  /* 14 */
	FF(c, d, a, b, x[14], S13, 0xa679438e);  /* 15 */
	FF(b, c, d, a, x[15], S14, 0x49b40821);  /* 16 */

	/* Round 2 */
	GG(a, b, c, d, x[ 1], S21, 0xf61e2562);  /* 17 */
	GG(d, a, b, c, x[ 6], S22, 0xc040b340);  /* 18 */
	GG(c, d, a, b, x[11], S23, 0x265e5a51);  /* 19 */
	GG(b, c, d, a, x[ 0], S24, 0xe9b6c7aa);  /* 20 */
	GG(a, b, c, d, x[ 5], S21, 0xd62f105d);  /* 21 */
	GG(d, a, b, c, x[10], S22,  0x2441453);  /* 22 */
	GG(c, d, a, b, x[15], S23, 0xd8a1e681);  /* 23 */
	GG(b, c, d, a, x[ 4], S24, 0xe7d3fbc8);  /* 24 */
	GG(a, b, c, d, x[ 9], S21, 0x21e1cde6);  /* 25 */
	GG(d, a, b, c, x[14], S22, 0xc33707d6);  /* 26 */
	GG(c, d, a, b, x[ 3], S23, 0xf4d50d87);  /* 27 */
	GG(b, c, d, a, x[ 8], S24, 0x455a14ed);  /* 28 */
	GG(a, b, c, d, x[13], S21, 0xa9e3e905);  /* 29 */
	GG(d, a, b, c, x[ 2], S22, 0xfcefa3f8);  /* 30 */
	GG(c, d, a, b, x[ 7], S23, 0x676f02d9);  /* 31 */
	GG(b, c, d, a, x[12], S24, 0x8d2a4c8a);  /* 32 */

	/* Round 3 */
	HH(a, b, c, d, x[ 5], S31, 0xfffa3942);  /* 33 */
	HH(d, a, b, c, x[ 8], S32, 0x8771f681);  /* 34 */
	HH(c, d, a, b, x[11], S33, 0x6d9d6122);  /* 35 */
	HH(b, c, d, a, x[14], S34, 0xfde5380c);  /* 36 */
	HH(a, b, c, d, x[ 1], S31, 0xa4beea44);  /* 37 */
	HH(d, a, b, c, x[ 4], S32, 0x4bdecfa9);  /* 38 */
	HH(c, d, a, b, x[ 7], S33, 0xf6bb4b60);  /* 39 */
	HH(b, c, d, a, x[10], S34, 0xbebfbc70);  /* 40 */
	HH(a, b, c, d, x[13], S31, 0x289b7ec6);  /* 41 */
	HH(d, a, b, c, x[ 0], S32, 0xeaa127fa);  /* 42 */
	HH(c, d, a, b, x[ 3], S33, 0xd4ef3085);  /* 43 */
	HH(b, c, d, a, x[ 6], S34,  0x4881d05);  /* 44 */
	HH(a, b, c, d, x[ 9], S31, 0xd9d4d039);  /* 45 */
	HH(d, a, b, c, x[12], S32, 0xe6db99e5);  /* 46 */
	HH(c, d, a, b, x[15], S33, 0x1fa27cf8);  /* 47 */
	HH(b, c, d, a, x[ 2], S34, 0xc4ac5665);  /* 48 */

	/* Round 4 */
	II(a, b, c, d, x[ 0], S41, 0xf4292244);  /* 49 */
	II(d, a, b, c, x[ 7], S42, 0x432aff97);  /* 50 */
	II(c, d, a, b, x[14], S43, 0xab9423a7);  /* 51 */
	II(b, c, d, a, x[ 5], S44, 0xfc93a039);  /* 52 */
	II(a, b, c, d, x[12], S41, 0x655b59c3);  /* 53 */
	II(d, a, b, c, x[ 3], S42, 0x8f0ccc92);  /* 54 */
	II(c, d, a, b, x[10], S43, 0xffeff47d);  /* 55 */
	II(b, c, d, a, x[ 1], S44, 0x85845dd1);  /* 56 */
	II(a, b, c, d, x[ 8], S41, 0x6fa87e4f);  /* 57 */
	II(d, a, b, c, x[15], S42, 0xfe2ce6e0);  /* 58 */
	II(c, d, a, b, x[ 6], S43, 0xa3014314);  /* 59 */
	II(b, c, d, a, x[13], S44, 0x4e0811a1);  /* 60 */
	II(a, b, c, d, x[ 4], S41, 0xf7537e82);  /* 61 */
	II(d, a, b, c, x[11], S42, 0xbd3af235);  /* 62 */
	II(c, d, a, b, x[ 2], S43, 0x2ad7d2bb);  /* 63 */
	II(b, c, d, a, x[ 9], S44, 0xeb86d391);  /* 64 */

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

void MD5_Update(C_MD5* md5, const void* input, size_t input_length)
{
	int i, index, partLen;
	uint32_t* count = md5->count;
	index = (uint32_t)((count[0] >> 3) & 0x3F);
	if ((count[0] += ((uint32_t)input_length << 3)) < ((uint32_t)input_length << 3))
		count[1]++;
	count[1] += ((uint32_t)input_length >> 29);
	partLen = 64 - index;

	if (input_length >= partLen)
	{
		memcpy(&md5->buffer[index], input, partLen);
		MD5_Internal_Transform(md5, md5->buffer);
		for (i = partLen; i + 63 < input_length; i += 64)
			MD5_Internal_Transform(md5, &((uint8_t*)input)[i]);
		index = 0;
	}
	else
		i = 0;
	memcpy(&md5->buffer[index], &((uint8_t*)input)[i], input_length - i);
}

void MD5_Finish(C_MD5* md5, void* digest)
{
	assert(digest!=0);
	if (!md5->finished)
	{
		static uint8_t PADDING[64] =
		{
			0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		};
		uint8_t bits[8];
		uint32_t index, padLen;
		MD5_Internal_Encode(bits, md5->count, 8);
		index = (uint32_t)((md5->count[0] >> 3) & 0x3f);
		padLen = (index < 56) ? (56 - index) : (120 - index);
		MD5_Update(md5, PADDING, padLen);
		MD5_Update(md5, bits, 8);
		md5->finished = 1;
	}
	MD5_Internal_Encode(digest, md5->state, 16);
}

void MD5_HMAC_Start(C_MD5_HMAC* hmac, const void* key, size_t key_len)
{
	int i;
	uint8_t sum[16];

	if (key_len > 64)
	{
		MD5_Start(&hmac->md5);
		MD5_Update(&hmac->md5, key, key_len);
		MD5_Finish(&hmac->md5, sum);
		key = sum;
		key_len = 16;
	}

	memset(hmac->ipad, 0x36, 64);
	memset(hmac->opad, 0x5C, 64);

	for (i = 0; i < key_len; ++i)
	{
		hmac->ipad[i] = (uint8_t)(hmac->ipad[i] ^ ((uint8_t*)key)[i]);
		hmac->opad[i] = (uint8_t)(hmac->opad[i] ^ ((uint8_t*)key)[i]);
	}

	MD5_Start(&hmac->md5);
	MD5_Update(&hmac->md5, hmac->ipad, 64);

	memset(sum, 0, sizeof(sum));
}

void MD5_HMAC_Update(C_MD5_HMAC* hmac, const void* input, size_t input_length)
{
	MD5_Update(&hmac->md5, input, input_length);
}

void MD5_HMAC_Finish(C_MD5_HMAC* hmac, void* digest)
{
	uint8_t tmpb[C_MD5_DIGEST_SIZE];
	MD5_Finish(&hmac->md5, tmpb);
	MD5_Start(&hmac->md5);
	MD5_Update(&hmac->md5, &hmac->opad, 64);
	MD5_Update(&hmac->md5, tmpb, C_MD5_DIGEST_SIZE);
	memset(tmpb, 0, C_MD5_DIGEST_SIZE);
	MD5_Finish(&hmac->md5, digest);
}

