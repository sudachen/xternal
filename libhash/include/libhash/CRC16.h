
#ifndef C_once_BDA9DECD_0D47_499E_A132_C6F383297479
#define C_once_BDA9DECD_0D47_499E_A132_C6F383297479

#include <stdint.h>
#include "libhash_common.h"

#ifdef __cplusplus
extern "C" {
#endif

LIBHASH_EXPORTABLE uint16_t Crc_16(uint16_t start, const void* bytes, size_t count);
LIBHASH_EXPORTABLE uint16_t Crc_16_16(uint16_t start, uint16_t val);
LIBHASH_EXPORTABLE uint16_t Crc_16_32(uint16_t start, uint32_t val);
LIBHASH_EXPORTABLE uint16_t Crc_16_64(uint16_t start, uint64_t val);

#ifdef __cplusplus
} /* extern "C" */

#include <assert.h>
#include "Digest.h"

namespace libhash
{
	struct CRC16
	{
		uint16_t acc;
		CRC16() : acc(0) {}
		void Update(const void* bytes, size_t count)
		{
			acc = Crc_16(acc, bytes, count);
		}
		void Finish(void* digest, size_t digest_size)
		{
			assert(digest_size == 2);
			memcpy(digest, &acc, 2);
		}
	};

	template<> struct Digest<CRC16>
	{
		typedef uint16_t Type;
		enum { BytesRequired = 2 };
	};

	static const DigestFunction<CRC16> crc16_digest = DigestFunction<CRC16>();
}

#endif /* __cplusplus */

#endif /* C_once_BDA9DECD_0D47_499E_A132_C6F383297479 */
