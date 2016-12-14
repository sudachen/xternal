
#ifndef C_once_C5021104_5DB9_4FCC_BAFC_AFB22BD458D3
#define C_once_C5021104_5DB9_4FCC_BAFC_AFB22BD458D3

#include <stdint.h>
#include "libhash_common.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MD5_CONTEXT
{
	uint32_t state[4];   /* state (ABCD) */
	uint32_t count[2];   /* number of bits, modulo 2^64 (lsb first) */
	uint8_t  buffer[64];
	int      finished;
} MD5_CONTEXT;

typedef struct MD5_HMAC_CONTEXT
{
	MD5_CONTEXT md5;
	uint8_t ipad[64];
	uint8_t opad[64];
} MD5_HMAC_CONTEXT;

#define MD5_INITIALIZER {{0x67452301,0xefcdab89,0x98badcfe,0x10325476},{0},{0},0}

LIBHASH_EXPORTABLE void MD5_Start(MD5_CONTEXT*);
LIBHASH_EXPORTABLE void MD5_Update(MD5_CONTEXT*, const void* bytes, size_t count);
LIBHASH_EXPORTABLE void MD5_Finish(MD5_CONTEXT*, void* digest);
LIBHASH_EXPORTABLE void MD5_HMAC_Start(MD5_HMAC_CONTEXT* hmac, const void* key, size_t length);
LIBHASH_EXPORTABLE void MD5_HMAC_Update(MD5_HMAC_CONTEXT* hmac, const void* bytes, size_t count);
LIBHASH_EXPORTABLE void MD5_HMAC_Finish(MD5_HMAC_CONTEXT* hmac, void* digest);

#ifdef __cplusplus
} /* extern "C" */

#include <array>
#include "Digest.h"

namespace libhash
{
	struct MD5;

	template<> struct Digest<MD5>
	{
		enum { BytesRequired = 16 };
		typedef std::array<uint8_t, BytesRequired> Type;
	};

	struct MD5 : DigestAlgo <
			MD5_CONTEXT,
			Digest<MD5>,
			MD5_Start,
			MD5_Update,
			MD5_Finish >
	{
	};

	struct MD5_HMAC : DigestHmacAlgo <
			MD5_HMAC_CONTEXT,
			Digest<MD5>,
			MD5_HMAC_Start,
			MD5_HMAC_Update,
			MD5_HMAC_Finish >
	{
	};

	static const DigestFunction<MD5> md5_digest = DigestFunction<MD5>();
	static const DigestHmacFunction<MD5> md5_hmac_digest = DigestHmacFunction<MD5>();
}

#endif /*__cplusplus*/

#endif /* C_once_C5021104_5DB9_4FCC_BAFC_AFB22BD458D3 */
