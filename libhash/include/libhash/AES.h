
#ifndef C_once_88F44E4C_C507_47B8_A162_CBEC13D572DA
#define C_once_88F44E4C_C507_47B8_A162_CBEC13D572DA

#include <stdint.h>
#include "libhash_common.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct AES_CONTEXT
{
	int nr;
	uint32_t* rk;
	uint32_t rawk[68];
} AES_CONTEXT;

LIBHASH_EXPORTABLE void AES_Init_Encipher(AES_CONTEXT* ctx, const void* key, size_t key_len);
LIBHASH_EXPORTABLE void AES_Init_Decipher(AES_CONTEXT* ctx, const void* key, size_t key_len);
LIBHASH_EXPORTABLE void AES_Encrypt16(AES_CONTEXT* ctx, void* block16);
LIBHASH_EXPORTABLE void AES_Decrypt16(AES_CONTEXT* ctx, void* block16);

#ifdef __cplusplus
} /*extern "C"*/
#endif

#endif /*C_once_88F44E4C_C507_47B8_A162_CBEC13D572DA*/
