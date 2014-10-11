
#ifndef C_once_18F7EAA7_0DBC_4720_BA4A_7E0B1A9A5B1E
#define C_once_18F7EAA7_0DBC_4720_BA4A_7E0B1A9A5B1E

#include <stdint.h>
#include "libhash_common.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct SHA2_CONTEXT
{
	uint32_t state[8];   /* state (ABCDEFGH) */
	uint32_t count[2];   /* number of bits, modulo 2^64 (lsb first) */
	uint8_t  buffer[64]; /* input buffer */
	int      finished;
} SHA2_CONTEXT;

typedef struct SHA2_HMAC_CONTEXT
{
	SHA2_CONTEXT sha2;
	uint8_t ipad[64];
	uint8_t opad[64];
} SHA2_HMAC_CONTEXT;

#define SHA2_CONTEXT_INITIALIZER {\
		{0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, \
			0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19}, \
		{0},{0},0}

LIBHASH_EXPORTABLE void SHA2_Start(SHA2_CONTEXT* sha2);
LIBHASH_EXPORTABLE void SHA2_Update(SHA2_CONTEXT* sha2, const void* data, size_t len);
LIBHASH_EXPORTABLE void SHA2_Finish(SHA2_CONTEXT* sha2, void* digest);
LIBHASH_EXPORTABLE void SHA2_HMAC_Start(SHA2_HMAC_CONTEXT* hmac, const void* key, size_t key_len);
LIBHASH_EXPORTABLE void SHA2_HMAC_Update(SHA2_HMAC_CONTEXT* hmac, const void* bytes, size_t count);
LIBHASH_EXPORTABLE void SHA2_HMAC_Finish(SHA2_HMAC_CONTEXT* hmac, void* digest);

#ifdef __cplusplus
} /* extern "C" */

#include <array>
#include "Digest.h"

namespace libhash
{
	struct SHA2;

	template<> struct Digest<SHA2>
	{
		enum { BytesRequired = 32 };
		typedef std::array<uint8_t, BytesRequired> Type;
	};

	struct SHA2 : DigestAlgo <
			SHA2_CONTEXT,
			typename Digest<SHA2>::Type,
			SHA2_Start,
			SHA2_Update,
			SHA2_Finish >
	{
	};

	struct SHA2_HMAC : DigestHmacAlgo <
			SHA2_HMAC_CONTEXT,
			typename Digest<SHA2>::Type,
			SHA2_HMAC_Start,
			SHA2_HMAC_Update,
			SHA2_HMAC_Finish >
	{
	};

	static const DigestFunction<SHA2> sha2_digest = DigestFunction<SHA2>();
	static const DigestHmacFunction<SHA2_HMAC> sha2_hmac_digest = DigestHmacFunction<SHA2_HMAC>();
}

#endif /*__cplusplus*/

#endif /* C_once_18F7EAA7_0DBC_4720_BA4A_7E0B1A9A5B1E */

