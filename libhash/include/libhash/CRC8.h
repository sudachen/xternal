
#ifndef C_once_D7C81CAD_95CD_46A3_AED7_DB59D9939CAE
#define C_once_D7C81CAD_95CD_46A3_AED7_DB59D9939CAE

#include <stdint.h>
#include "libhash_common.h"

#ifdef __cplusplus
extern "C" {
#endif

LIBHASH_EXPORTABLE uint8_t Crc_8(uint8_t start, const void* bytes, size_t count);
LIBHASH_EXPORTABLE uint8_t Crc_8_16(uint8_t start, uint16_t val);
LIBHASH_EXPORTABLE uint8_t Crc_8_32(uint8_t start, uint32_t val);
LIBHASH_EXPORTABLE uint8_t Crc_8_64(uint8_t start, uint64_t val);

#ifdef __cplusplus
} /* extern "C" */

#include <assert.h>
#include "Digest.h"

namespace libhash
{
	struct CRC8
	{
		uint8_t acc;
		CRC8() : acc(0) {}
		void Update(const void* bytes, size_t count)
		{
			acc = Crc_8(acc, bytes, count);
		}
		void Finish(void* digest, size_t digest_size)
		{
			assert(digest_size == 1);
			memcpy(digest, &acc, 1);
		}
	};

	template<> struct Digest<CRC8>
	{
		typedef uint8_t Type;
		enum { BytesRequired = 1 };
	};

	static const DigestFunction<CRC8> crc8_digest = DigestFunction<CRC8>();
}

#endif /* __cplusplus */

#endif /* C_once_D7C81CAD_95CD_46A3_AED7_DB59D9939CAE */
