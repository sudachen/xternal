
#include "../include/libhash/Fortuna.h"
#include "../include/libhash/AES.h"
#include "../include/libhash/SHA2.h"
#include <assert.h>
#include <time.h>

#ifdef _WIN32
uint32_t __stdcall GetCurrentProcessId();
#endif

static AES_CONTEXT g_AES;
static uint8_t g_C[16] = {0,};
static uint8_t g_K[32] = {0,};
static uint8_t g_S[32] = {0,};
static int initialized = 0;

static void Increment(uint8_t C[16])
{
	size_t i;
	uint32_t a = 1;
	for ( i = 0; i < 16 /*&& a*/ ; ++i )
	{
		a = (uint32_t)C[i] + a;
		C[i] = (uint8_t)a;
		a >>= 8;
	}
}

static void Entropy()
{
	volatile size_t i;
	uint8_t j = g_S[sizeof(g_S)-1];
	for ( i = 0; i < 31; ++i )
		g_S[i+1] = g_S[i] ^ *((uint8_t*)&i + i - 512); /* stack content */
	g_S[0] = j;
	*(clock_t*)g_S ^= clock();
	*(intptr_t*)((clock_t*)g_S+1) ^= (intptr_t)&i;
}

static void Reseed()
{
	SHA2_CONTEXT sha2_ctx = SHA2_CONTEXT_INITIALIZER;
	memcpy(g_K,g_C,16);
	AES_Encrypt16(&g_AES,g_K);
	Increment(g_C);
	memcpy(g_K+16,g_C,16);
	AES_Encrypt16(&g_AES,g_K+16);
	Increment(g_C);
	SHA2_Update(&sha2_ctx,g_K,32);
	SHA2_Update(&sha2_ctx,g_S,32);
	SHA2_Finish(&sha2_ctx,g_K);
	AES_Init_Encipher(&g_AES,g_K,32);
}

static void Fortuna_Generate_Bytes_Step(void* bytes, size_t count)
{
	size_t i;
	uint8_t block[16];
	Entropy();
	
	if ( !initialized )
	{
		SHA2_CONTEXT sha2_ctx = SHA2_CONTEXT_INITIALIZER;
		*(time_t*)&g_S[sizeof(g_S)-sizeof(time_t)] ^= time(0);
		#ifdef _WIN32
		*(uint32_t*)&g_S[sizeof(g_S)-sizeof(time_t)-4] ^= GetCurrentProcessId();
		#endif
		SHA2_Update(&sha2_ctx,g_S,32);
		SHA2_Finish(&sha2_ctx,g_K);
		AES_Init_Encipher(&g_AES,g_K,32);
		memcpy(g_K,g_C,16);
		AES_Encrypt16(&g_AES,g_K);
		Increment(g_C);
		memcpy(g_K+16,g_C,16);
		AES_Encrypt16(&g_AES,g_K+16);
		Increment(g_C);
		Reseed();
		initialized = 1;
	}

	for( i = 0; i < count; i += 16 )
	{
		size_t j = count-i;
		if ( j > 16 ) j = 16;
		memcpy(block,g_C,16);
		AES_Encrypt16(&g_AES,block);
		Increment(g_C);
		memcpy((uint8_t*)bytes + i, block, j);
	}

	Reseed();
}

void Fortuna_Bytes(void* bytes, size_t count)
{
	size_t i,j;
	for ( i = 0; i < count; )
	{
		j = count -i;
		if ( j > 1024*1024 ) j = 1024*1024;
		Fortuna_Generate_Bytes_Step((uint8_t*)bytes+i,j);
		i += j;
	}
}

