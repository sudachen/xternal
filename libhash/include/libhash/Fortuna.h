

#include <stdint.h>
#include "libhash_common.h"

#ifdef __cplusplus
extern "C" {
#endif

LIBHASH_EXPORTABLE void Fortuna_Bytes(void* bytes, size_t count);

#ifdef __cplusplus
} /*extern "C"*/

namespace libhash
{

	inline void fortuna(void* bytes, size_t count)
	{
		Fortuna_Bytes(bytes,count);
	}

	inline std::vector<uint8_t> fortuna(size_t count)
	{
		std::vector<uint8_t> out(count);
		fortuna(&out[0],count);
		return out;
	}

}

#endif
