
#ifndef C_once_CBD817D1_A860_4F71_B185_CD58A8554CB0
#define C_once_CBD817D1_A860_4F71_B185_CD58A8554CB0

#include <stdint.h>
#include "libhash_common.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MURMUR_CONTEXT
{
	uint32_t hash;
	uint32_t tail;
	uint32_t count;
	uint32_t size;
	int		 finished;
} MURMUR_CONTEXT;

LIBHASH_EXPORTABLE void Murmur2_Start(MURMUR_CONTEXT* ctx, uint32_t seed);
LIBHASH_EXPORTABLE void Murmur2_Update(MURMUR_CONTEXT* ctx, const void* data, size_t count);
LIBHASH_EXPORTABLE void Murmur2_Finish(MURMUR_CONTEXT* ctx, uint32_t* dgst);

#ifdef __cplusplus
} /* extern "C" */

#include "Digest.h"

namespace libhash
{
	struct Murmur2;

	template<> struct Digest<Murmur2>
	{
		enum { BytesRequired = 4 };
		typedef uint32_t Type;
	};

	inline void Murmur2_Finish_(MURMUR_CONTEXT* ctx, void* dgst)
	{
		Murmur2_Finish(ctx,(uint32_t*)dgst);
	}

	struct Murmur2 : DigestAlgo <
			MURMUR_CONTEXT,
			typename Digest<Murmur2>::Type,
			Murmur2_Start,
			Murmur2_Update,
			Murmur2_Finish_ >
	{
	};

	static const DigestFunction<Murmur2> murmur2_digest = DigestFunction<Murmur2>();
}

#endif /*__cplusplus*/

#endif /* C_once_CBD817D1_A860_4F71_B185_CD58A8554CB0 */
