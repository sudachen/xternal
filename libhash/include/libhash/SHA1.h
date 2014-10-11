
#ifndef C_once_1409D846_F10D_4C7A_8FD2_8691DFB38EA5
#define C_once_1409D846_F10D_4C7A_8FD2_8691DFB38EA5

#include <stdint.h>
#include "libhash_common.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct SHA1_CONTEXT
{
	uint32_t state[5];   /* state (ABCDE) */
	uint32_t count[2];   /* number of bits, modulo 2^64 (lsb first) */
	uint8_t  buffer[64]; /* input buffer */
	int      finished;
} SHA1_CONTEXT;

typedef struct SHA1_HMAC_CONTEXT
{
	SHA1_CONTEXT sha1;
	uint8_t ipad[64];
	uint8_t opad[64];
} SHA1_HMAC_CONTEXT;

#define SHA1_INITIALIZER {{0x67452301,0xefcdab89,0x98badcfe,0x10325476,0xc3d2e1f0},{0},{0},0}

LIBHASH_EXPORTABLE void SHA1_Start(SHA1_CONTEXT*);
LIBHASH_EXPORTABLE void SHA1_Update(SHA1_CONTEXT*, const void* bytes, size_t count);
LIBHASH_EXPORTABLE void SHA1_Finish(SHA1_CONTEXT*, void* digest);
LIBHASH_EXPORTABLE void SHA1_HMAC_Start(SHA1_HMAC_CONTEXT* hmac, const void* key, size_t length);
LIBHASH_EXPORTABLE void SHA1_HMAC_Update(SHA1_HMAC_CONTEXT* hmac, const void* bytes, size_t count);
LIBHASH_EXPORTABLE void SHA1_HMAC_Finish(SHA1_HMAC_CONTEXT* hmac, void* digest);

#ifdef __cplusplus
} /* extern "C" */

#include <array>
#include "Digest.h"

namespace libhash
{
	struct SHA1;

	template<> struct Digest<SHA1>
	{
		enum { BytesRequired = 20 };
		typedef std::array<uint8_t, BytesRequired> Type;
	};

	struct SHA1 : DigestAlgo <
			SHA1_CONTEXT,
			typename Digest<SHA1>::Type,
			SHA1_Start,
			SHA1_Update,
			SHA1_Finish >
	{
	};

	struct SHA1_HMAC : DigestHmacAlgo <
			SHA1_HMAC_CONTEXT,
			typename Digest<SHA1>::Type,
			SHA1_HMAC_Start,
			SHA1_HMAC_Update,
			SHA1_HMAC_Finish >
	{
	};

	static const DigestFunction<SHA1> sha1_digest = DigestFunction<SHA1>();
	static const DigestHmacFunction<SHA1> sha1_hmac_digest = DigestHmacFunction<SHA1>();
}

#endif /*__cplusplus*/

#endif /* C_once_1409D846_F10D_4C7A_8FD2_8691DFB38EA5 */
