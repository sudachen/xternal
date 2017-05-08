
#include <assert.h>
#include "../include/libhash/NDES.h"

void NDES_Normalize_(NDES_CONTEXT *ctx, uint8_t const *kunrav)
{
    int i,j;
    memset(ctx->u,0,sizeof(ctx->u));
    for ( i = 0; i < 9; ++i )
    {
        for ( j = 0; j < 4; ++j )
            ctx->u[i*8+j] = kunrav[i*7+j];
        if ( i < 8 )
        {
            ctx->u[i*8+j]   = kunrav[i*7+j]; ++j;
            ctx->u[i*8+j+1] = kunrav[i*7+j]; ++j;
            ctx->u[i*8+j+1] = kunrav[i*7+j]; ++j;
        }
    }
}

void NDES_Init_Encipher(NDES_CONTEXT *ctx, void const* key)
{
    int i,j;
    #if defined _X86_ASSEMBLER
    uint8_t kunrav[NDES_UNRAV_BYTES];
    #else
    uint8_t* kunrav = ctx->u;
    #endif
    for ( j=0; j < NDES_UNRAV_BYTES; )
        for ( i=0; i < NDES_KEY_BYTES; ++i)
            kunrav[j++] = ((uint8_t const*)key)[i];
    #if defined _X86_ASSEMBLER
    Normalize_(ctx,kunrav);
    #endif
}

void NDES_Init_Decipher(NDES_CONTEXT *ctx, void const *_key)
{
    #if defined _X86_ASSEMBLER
    uint8_t kunrav[NDES_UNRAV_BYTES];
    #else
    uint8_t* kunrav = ctx->u;
    #endif
    uint8_t* k = kunrav;
    uint8_t const* key = (uint8_t const*)_key;
    int i = 11, j=0;
    while (1)
    {
        *(k++) = key[i];
        i = ((i+1) % NDES_KEY_BYTES );
        *(k++) = key[i];
        i = ((i+1) % NDES_KEY_BYTES );
        *(k++) = key[i];
        i = ((i+1) % NDES_KEY_BYTES );

        *(k++) = key[i];
        i = (i+9) % 15;
        if (i == 12) break;

        *(k++) = key[i++];
        *(k++) = key[i++];
        *(k++) = key[i];
        i = (i+9) % 15;
    }
    #if defined _X86_ASSEMBLER
    NDES_Normalize_(ctx,kunrav);
    #endif
}

#if !defined _X86_ASSEMBLER
void NDES_Cipher_8(NDES_CONTEXT const *ctx, void* _b)
{
    static uint8_t rotor[] =
    {
        32,137,239,188,102,125,221, 72,212, 68, 81, 37, 86,237,147,149,
        70,229, 17,124,115,207, 33, 20,122,143, 25,215, 51,183,138,142,
        146,211,110,173,  1,228,189, 14,103, 78,162, 36,253,167,116,255,
        158, 45,185, 50, 98,168,250,235, 54,141,195,247,240, 63,148,  2,
        224,169,214,180, 62, 22,117,108, 19,172,161,159,160, 47, 43,171,
        194,175,178, 56,196,112, 23,220, 89, 21,164,130,157,  8, 85,251,
        216, 44, 94,179,226, 38, 90,119, 40,202, 34,206, 35, 69,231,246,
        29,109, 74, 71,176,  6, 60,145, 65, 13, 77,151, 12,127, 95,199,
        57,101,  5,232,150,210,129, 24,181, 10,121,187, 48,193,139,252,
        219, 64, 88,233, 96,128, 80, 53,191,144,218, 11,106,132,155,104,
        91,136, 31, 42,243, 66,126,135, 30, 26, 87,186,182,154,242,123,
        82,166,208, 39,152,190,113,205,114,105,225, 84, 73,163, 99,111,
        204, 61,200,217,170, 15,198, 28,192,254,134,234,222,  7,236,248,
        201, 41,177,156, 92,131, 67,249,245,184,203,  9,241,  0, 27, 46,
        133,174, 75, 18, 93,209,100,120, 76,213, 16, 83,  4,107,140, 52,
        58, 55,  3,244, 97,197,238,227,118, 49, 79,230,223,165,153, 59
    };

    size_t count;
    const uint8_t* k = ctx->u;
    uint8_t* b = (uint8_t*)_b;
    for (count=8; count--;)
    {
        b[4] = b[4] ^ rotor[b[0] ^ *(k++)];
        b[5] = b[5] ^ rotor[b[1] ^ *(k++)];
        b[6] = b[6] ^ rotor[b[2] ^ *(k++)];
        b[7] = b[7] ^ rotor[b[3] ^ *(k++)];

        b[1] = b[1] ^ rotor[b[4] ^ *(k++)];
        b[2] = b[2] ^ rotor[b[4] ^ b[5]];
        b[3] = b[3] ^ rotor[b[6] ^ *(k++)];
        b[0] = b[0] ^ rotor[b[7] ^ *(k++)];
    }
    b[4] = b[4] ^ rotor[b[0] ^ *(k++)];
    b[5] = b[5] ^ rotor[b[1] ^ *(k++)];
    b[6] = b[6] ^ rotor[b[2] ^ *(k++)];
    b[7] = b[7] ^ rotor[b[3] ^ *(k++)];
}

void NDES_Cipher(NDES_CONTEXT const *ctx, void* data, size_t count)
{
    size_t i;
    for (i = 0; i < count; ++i)
        NDES_Cipher_8(ctx,(uint8_t*)data+NDES_BLOCK_BYTES*i);
}

#endif
