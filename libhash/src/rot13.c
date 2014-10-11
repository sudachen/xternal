
#include "../include/libhash/ROT13.h"

uint32_t ROT13_Update(uint32_t rot13, const void* data, size_t count)
{
	size_t i;
	for (i = 0; i < count; ++i)
	{
		rot13 += *((uint8_t*)data + i);
		rot13 -= (rot13 << 13) | (rot13 >> 19);
	}
	return rot13;
}

