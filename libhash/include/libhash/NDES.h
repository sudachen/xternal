

#ifndef C_once_6ea1d37e_eace_4986_b99a_fcd335057356
#define C_once_6ea1d37e_eace_4986_b99a_fcd335057356

#include <stdint.h>
#include "libhash_common.h"

#ifdef __cplusplus
extern "C" {
#endif

enum
{
    NDES_BLOCK_BYTES = 8,
    NDES_KEY_BYTES   = 15,
    NDES_UNRAV_BYTES = 60,
    NDES_UNRAV_BYTES_1 = 68
};

typedef struct _NDES_CONTEXT
{
    uint8_t u[NDES_UNRAV_BYTES_1];
} NDES_CONTEXT;

LIBHASH_EXPORTABLE void NDES_Cipher_8(const NDES_CONTEXT* self, void* block8);
LIBHASH_EXPORTABLE void NDES_Cipher(const NDES_CONTEXT* self, void* data, size_t count);
LIBHASH_EXPORTABLE void NDES_Init_Encipher(NDES_CONTEXT* self, const void* key);
LIBHASH_EXPORTABLE void NDES_Init_Decipher(NDES_CONTEXT* self, const void* key);

#ifdef __cplusplus
}
#endif

#endif /* C_once_D690E508_42FB_45FC_A21F_57C71E658EB1 */
