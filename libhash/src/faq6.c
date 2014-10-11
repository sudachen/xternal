
#include "../include/libhash/FAQ6.h"

uint32_t FAQ6_Update(uint32_t faq6, const void* data, size_t count)
{
	size_t i;
	for (i = 0; i < count; ++i)
	{
		faq6 += *((uint8_t*)data + i);
		faq6 += (faq6 << 10);
		faq6 ^= (faq6 >> 6);
	}
	return faq6;
}

uint32_t FAQ6_Finish(uint32_t faq6)
{
	faq6 += (faq6 << 3);
	faq6 ^= (faq6 >> 11);
	faq6 += (faq6 << 15);
	return faq6;
}
