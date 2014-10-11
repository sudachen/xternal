
#include <assert.h>
#include "../include/libhash/Murmur2.h"

#define M ((uint32_t)(0x5bd1e995));
#define R 24

#define mmix(h,k) { k *= M; k ^= k >> R; k *= M; h *= M; h ^= k; }

void Murmur2_Start(MURMUR_CONTEXT* ctx, uint32_t seed)
{
	assert(ctx != 0);
	memset(ctx, 0, sizeof(*ctx));
	ctx->hash = seed;
}

static void Tail(MURMUR_CONTEXT* ctx, const uint8_t** data, size_t* count)
{
	while (*count && ((*count < 4) || ctx->count))
	{
		ctx->tail |= (*(*data)++) << (ctx->count * 8);

		ctx->count++;
		*count--;

		if (ctx->count == 4)
		{
			mmix(ctx->hash, ctx->tail);
			ctx->tail = 0;
			ctx->count = 0;
		}
	}
}

void Murmur2_Update(MURMUR_CONTEXT* ctx, const void* _data, size_t count)
{
	const uint8_t* data = _data;
	assert(ctx != 0 && !ctx->finished);
	assert(data != 0);

	Tail(ctx, &data, &count);
	while (count >= 4)
	{
		uint32_t k = *(uint32_t*)data;
		mmix(ctx->hash, k);
		data += 4;
		count -= 4;
	}
	Tail(ctx, &data, &count);
}

void Murmur2_Finish(MURMUR_CONTEXT* ctx, uint32_t* dgst)
{
	assert(ctx != 0);
	if ( !ctx->finished )
	{
		mmix(ctx->hash, ctx->tail);
		mmix(ctx->hash, ctx->size);

		ctx->hash ^= ctx->hash >> 13;
		ctx->hash *= M;
		ctx->hash ^= ctx->hash >> 15;
		ctx->finished = 1;
	}
	*dgst = ctx->hash;
}

