
#ifndef C_once_2124CF1C_AA06_4AF0_A022_834A731FD965
#define C_once_2124CF1C_AA06_4AF0_A022_834A731FD965

#include <stdint.h>
#include "libhash_common.h"

#ifdef __cplusplus
extern "C" {
#endif

	LIBHASH_EXPORTABLE uint32_t Crc_32(uint32_t start, const void *bytes, size_t count);
	LIBHASH_EXPORTABLE uint32_t Crc_32_16(uint32_t start, uint16_t val);
	LIBHASH_EXPORTABLE uint32_t Crc_32_32(uint32_t start, uint32_t val);
	LIBHASH_EXPORTABLE uint32_t Crc_32_64(uint32_t start, uint64_t val);

#ifdef __cplusplus
} /* extern "C" */

#include "Digest.h"

namespace libhash
{
	struct CRC32
	{
		uint32_t acc;
		CRC32() : acc(0) {}
		void Update(const void *bytes, size_t count)
		{
			acc = Crc_32(acc,bytes,count);
		}
		void Finish(void *digest, size_t digest_size)
		{
			assert(digest_size == 4);
			memcpy(digest,&acc,4);
		}
	};

	template<> struct Digest<CRC32>
	{
		typedef uint32_t Type;
		enum { BytesRequired = 4 };
	};

	static const DigestFunction<CRC32> crc32_digest = DigestFunction<CRC32>();
}

#endif /* __cplusplus */

#endif /* C_once_2124CF1C_AA06_4AF0_A022_834A731FD965 */
