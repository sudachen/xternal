
#ifndef C_once_D690E508_42FB_45FC_A21F_57C71E658EB1
#define C_once_D690E508_42FB_45FC_A21F_57C71E658EB1

#include <stdint.h>
#include "libhash_common.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _BF_CONTEXT
{
	unsigned int P[16 + 2];
	unsigned int S[4][256];
} BF_CONTEXT;

LIBHASH_EXPORTABLE void Blowfish_Encrypt8(const BF_CONTEXT* self, void* block8);
LIBHASH_EXPORTABLE void Blowfish_Decrypt8(const BF_CONTEXT* self, void* block8);
LIBHASH_EXPORTABLE void Blowfish_Init(BF_CONTEXT* self, const void* key, size_t key_len);

#ifdef __cplusplus
}
#endif

#endif /* C_once_D690E508_42FB_45FC_A21F_57C71E658EB1 */
