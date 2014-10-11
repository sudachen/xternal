
#ifndef C_once_69174D93_5C0A_4DD8_83B7_DD53726DD491
#define C_once_69174D93_5C0A_4DD8_83B7_DD53726DD491

#include <stdint.h>
#include "libhash_common.h"

#ifdef __cplusplus
extern "C" {
#endif

LIBHASH_EXPORTABLE uint32_t FAQ6_Update(uint32_t faq6, const void* data, size_t count);
LIBHASH_EXPORTABLE uint32_t FAQ6_Finish(uint32_t faq6);

#ifdef __cplusplus
} /* extern "C" */

#include "Digest.h"

namespace libhash
{
	struct FAQ6;

	template<> struct Digest<FAQ6>
	{
		enum { BytesRequired = 4 };
		typedef uint32_t Type;
	};

	struct FAQ6
	{
		uint32_t acc;
		FAQ6() : acc(0) {}
		void Update(const void *bytes, size_t count)
		{
			acc = FAQ6_Update(acc,bytes,count);
		}
		void Finish(void *digest, size_t digest_size)
		{
			assert(digest_size == 4);
			uint32_t q = FAQ6_Finish(acc);
			memcpy(digest,&q,4);
		}
	};

	static const DigestFunction<FAQ6> faq6_digest = DigestFunction<FAQ6>();
}

#endif /*__cplusplus*/

#endif /* C_once_69174D93_5C0A_4DD8_83B7_DD53726DD491 */
