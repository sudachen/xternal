
#ifndef C_once_2124CF1C_AA06_4AF0_A022_834A731FD965
#define C_once_2124CF1C_AA06_4AF0_A022_834A731FD965

#include <stdint.h>
#include "libhash_common.h"

#ifdef __cplusplus
extern "C" {
#endif

	LIBHASH_EXPORTABLE uint32_t ROT13_Update(uint32_t rot13, const void *bytes, size_t count);

#ifdef __cplusplus
} /* extern "C" */

#include "Digest.h"

namespace libhash
{
	struct ROT13
	{
		uint32_t acc;
		ROT13() : acc(0) {}
		void Update(const void *bytes, size_t count)
		{
			acc = ROT13_Update(acc,bytes,count);
		}
		void Finish(void *digest, size_t digest_size)
		{
			assert(digest_size == 4);
			memcpy(digest,&acc,4);
		}
	};

	template<> struct Digest<ROT13>
	{
		typedef uint32_t Type;
		enum { BytesRequired = 4 };
	};

	static const DigestFunction<ROT13> rot13_digest = DigestFunction<ROT13>();
}

#endif /* __cplusplus */

#endif /* C_once_2124CF1C_AA06_4AF0_A022_834A731FD965 */
