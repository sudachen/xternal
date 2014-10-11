
/*

(C)2014, Alexey Sudachen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Except as contained in this notice, the name of a copyright holder shall not
be used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization of the copyright holder.

*/

#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include <stdarg.h>

#include "cbuffer.h"

#define Bitcount_8(q) (Bitcount_8_Q[(q)&0x0ff])
static uint8_t Bitcount_8_Q[] =
{
	0, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4,
	5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
	6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
	6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
};

static uint32_t Bitcount_Of(uint32_t u)
{
	int i;
	uint32_t q;
	if (u)
		for (i = sizeof(u) * 8 - 8; i >= 0; i -= 8)
			if (!!(q = Bitcount_8(u >> i)))
				return q + i;
	return 0;
}

static uint32_t Min_Pow2(uint32_t a)
{
	if (a) --a;
	return 1 << Bitcount_Of(a);
}

void Buffer_Clear(C_BUFFER* bf)
{
	free(bf->at);
	bf->at = 0;
	bf->count = 0;
	bf->capacity = 0;
}

C_BUFFER* Buffer_Reserve(C_BUFFER* bf, size_t capacity)
{
	if (!bf) bf = Buffer_Init(0);

	if (bf->capacity < capacity || !bf->at)
	{
		bf->at = realloc(bf->at, capacity + 1);
		assert(bf->at != 0);
		bf->capacity = capacity;
		assert(bf->count <= bf->capacity);
		bf->at[bf->count] = 0;
	}

	return bf;
}

C_BUFFER* Buffer_Grow_Reserve(C_BUFFER* bf, size_t capacity)
{

	if (!bf) bf = Buffer_Init(0);

	if (bf->capacity < capacity)
	{
		capacity = Min_Pow2(capacity);
		bf->at   = realloc(bf->at, capacity + 1);
		assert(bf->at != 0);
		bf->capacity = capacity;
		assert(bf->count <= bf->capacity);
		bf->at[bf->count] = 0;
	}

	return bf;
}

void Buffer_Resize(C_BUFFER* bf, size_t count)
{
	Buffer_Reserve(bf, count);

	if (bf->count < count)
		memset(bf->at + bf->count, 0, count - bf->count);

	bf->count = count;
	assert(bf->count <= bf->capacity);
	bf->at[bf->count] = 0;
}

void Buffer_Grow(C_BUFFER* bf, size_t count)
{
	Buffer_Grow_Reserve(bf, count);

	if (bf->count < count)
		memset(bf->at + bf->count, 0, count - bf->count);

	bf->count = count;
	assert(bf->count <= bf->capacity);
	bf->at[bf->count] = 0;
}

void Buffer_Append(C_BUFFER* bf, void* S, size_t len)
{
	if (len == TILLEOS)   /* appending C string */
		len = S ? strlen(S) : 0;

	if (len && S)
	{
		Buffer_Grow_Reserve(bf, bf->count + len);
		memcpy(bf->at + bf->count, S, len);
		bf->count += len;
		assert(bf->count <= bf->capacity);
		bf->at[bf->count] = 0;
	}
}

void Buffer_Fill_Append(C_BUFFER* bf, int c, size_t count)
{
	if (count > 0)
	{
		Buffer_Grow_Reserve(bf, bf->count + count);
		memset(bf->at + bf->count, c, count);
		bf->count += count;
		assert(bf->count <= bf->capacity);
		bf->at[bf->count] = 0;
	}
}

void Buffer_Print(C_BUFFER* bf, char* S)
{
	Buffer_Append(bf, S, TILLEOS);
}

void Buffer_Puts(C_BUFFER* bf, char* S)
{
	Buffer_Append(bf, S, TILLEOS);
	Buffer_Fill_Append(bf, '\n', 1);
}

void Buffer_Set(C_BUFFER* bf, char* S, size_t L)
{
	Buffer_Resize(bf, 0);
	Buffer_Append(bf, S, L);
}

static size_t Buffer_Detect_Required_Size(char* fmt, va_list va)
{
#ifdef _WIN32
	return _vscprintf(fmt, va) + 1;
#else
	va_list qva;
	va_copy(qva, va);
	return vsnprintf(0, 0, fmt, qva) + 1;
#endif
}

void Buffer_Printf_Va(C_BUFFER* bf, char* fmt, va_list va)
{
	int q, rq_len;

	rq_len = Buffer_Detect_Required_Size(fmt, va) + 1;
	Buffer_Grow_Reserve(bf, bf->count + rq_len);

#ifdef _WIN32
	q = vsprintf((char*)bf->at + bf->count, fmt, va);
#else
	q = vsnprintf((char*)bf->at + bf->count, rq_len, fmt, va);
#endif

	if (q >= 0)
		bf->count += q;

	assert(bf->count >= 0 && bf->count <= bf->capacity);
	bf->at[bf->count] = 0;
}

void Buffer_Printf(C_BUFFER* bf, char* fmt, ...)
{
	va_list va;
	va_start(va, fmt);
	Buffer_Printf_Va(bf, fmt, va);
	va_end(va);
}

static char* Hex_Byte(uint8_t val, char pfx, void* out)
{
	static char symbols[] =
	{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
	char* q = out;
	switch (pfx & 0x7f)
	{
		case 'x': *q++ = '0'; *q++ = 'x'; break;
		case '\\': *q++ = '\\'; *q++ = 'x'; break;
		case '%': *q++ = '%'; break;
		default: break;
	}
	*q++ = symbols[(val >> 4)];
	*q++ = symbols[val & 0x0f];
	if (!pfx & 0x80)
		*q = 0;
	return out;
}

void Buffer_Hex_Append(C_BUFFER* bf, void* S, size_t len)
{
	if (len == TILLEOS)   /* appending C string */
		len = S ? strlen(S) : 0;

	if (len && S)
	{
		int i;
		Buffer_Grow_Reserve(bf, bf->count + len * 2);
		for (i = 0; i < len; ++i)
			Hex_Byte(((uint8_t*)S)[i], 0, bf->at + bf->count + i * 2);
		bf->count += len * 2;
		assert(bf->count <= bf->capacity);
		bf->at[bf->count] = 0;
	}
}

void Buffer_Esc_Append(C_BUFFER* bf, void* S, int len)
{
	uint8_t* q = S;
	uint8_t* p = q;
	uint8_t* E;

	if (len == TILLEOS)
		len = S ? strlen(S) : 0;

	E = p + len;

	while (p != E)
	{
		do
		{
			if (*p < 30 || *p > 127 || *p == '\\' ||  *p == '"' || *p == '\'')
				break;
			++p;
		}
		while (p != E);

		if (q != p)
			Buffer_Append(bf, q, p - q);

		if (p != E)
		{
			char* t;
			Buffer_Fill_Append(bf, 0, 4);
			assert(bf->count >= 5);
			t = bf->chars + bf->count - 4;
			t[0] = '\\';
			t[1] = ((*p >> 6) % 8) + '0';
			t[2] = ((*p >> 3) % 8) + '0';
			t[3] = (*p % 8) + '0';
		}

		q = ++p;
	}
}

void Buffer_Quote_Append(C_BUFFER* bf, void* S, size_t len, int brk)
{
	uint8_t* q = S;
	uint8_t* p = q;
	uint8_t* E;

	if (len == TILLEOS)
		len = S ? strlen(S) : 0;

	E = p + len;

	while (p != E)
	{
		do
		{
			if (*p < 30 || *p == '\\'
			    || (brk ? *p == brk : (*p == '"' || *p == '\'')))
				break;
			++p;
		}
		while (p != E);

		if (q != p)
			Buffer_Append(bf, q, p - q);

		if (p != E)
		{
			if (*p == '\n') Buffer_Append(bf, "\\n", 2);
			else if (*p == '\t') Buffer_Append(bf, "\\t", 2);
			else if (*p == '\r') Buffer_Append(bf, "\\r", 2);
			else if (*p == '\\') Buffer_Append(bf, "\\\\", 2);
			else if (brk && *p == brk)
			{
				Buffer_Fill_Append(bf, '\\', 1);
				Buffer_Fill_Append(bf, brk, 1);
			}
			else if (!brk && *p == '"')
				Buffer_Append(bf, "\\\"", 2);
			else if (!brk && *p == '\'')
				Buffer_Append(bf, "\\'", 2);
			else if (*p < 30)
			{
				Buffer_Append(bf, "\\x", 2);
				Buffer_Hex_Append(bf, p, 1);
			}

			++p;
		}

		q = p;
	}
}

void Buffer_Html_Quote_Append(C_BUFFER* bf, void* S, size_t len)
{
	uint8_t* q = S;
	uint8_t* p = q;
	uint8_t* E;

	if (len == TILLEOS)
		len = S ? strlen(S) : 0;

	E = p + len;

	while (p != E)
	{
		do
		{
			if (*p == '<' || *p == '>'  || *p == '&')
				break;
			++p;
		}
		while (p != E);

		if (q != p)
			Buffer_Append(bf, q, p - q);

		if (p != E)
		{
			if (*p == '<') Buffer_Append(bf, "&lt;", 4);
			else if (*p == '>') Buffer_Append(bf, "&gt;", 4);
			else if (*p == '&') Buffer_Append(bf, "&amp;", 5);
			++p;
		}

		q = p;
	}
}

void Buffer_Insert(C_BUFFER* bf, int pos, void* S, size_t len)
{
	if (len == TILLEOS)   /* appending C string */
		len = S ? strlen(S) : 0;

	if (pos < 0) pos = bf->count + pos + 1;
	assert(pos >= 0 && pos < bf->count);

	Buffer_Grow_Reserve(bf, bf->count + len);
	if (pos < bf->count)
		memmove(bf->at + pos + len, bf->at + pos, bf->count - pos);
	memcpy(bf->at + pos, S, len);
	bf->count += len;
	assert(bf->count <= bf->capacity);
	bf->at[bf->count] = 0;
}

void* Buffer_Take(C_BUFFER* bf)
{
	if (!bf) 
		return 0;
	else
	{
		void* R = bf->at;
		bf->count = 0;
		bf->at = 0;
		bf->capacity = 0;
		return R;
	}
}

void* Buffer_Take_n_Kill(C_BUFFER* bf)
{
	void* r = Buffer_Take(bf);
	Buffer_Kill(bf);
	return r;
}

size_t Buffer_Count(C_BUFFER* bf)
{
	if (bf)
		return Buffer_COUNT(bf);
	return 0;
}

size_t Buffer_Capacity(C_BUFFER* bf)
{
	if (bf)
		return Buffer_CAPACITY(bf);
	return 0;
}

void* Buffer_Begin(C_BUFFER* bf)
{
	if (bf)
		return Buffer_BEGIN(bf);
	return 0;
}

void* Buffer_End(C_BUFFER* bf)
{
	if (bf)
		return Buffer_END(bf);
	return 0;
}

void Buffer_Kill(C_BUFFER* bf)
{
	if (bf)
	{
		if (bf->at)
			free(bf->at);
		free(bf);
	}
}

C_BUFFER* Buffer_Init(int count)
{
	C_BUFFER* bf = calloc(1, sizeof(C_BUFFER));
	if (count)
		Buffer_Resize(bf, count);
	return bf;
}

C_BUFFER* Buffer_Acquire(char* S)
{
	C_BUFFER* bf = calloc(1, sizeof(C_BUFFER));
	size_t L = strlen(S);
	bf->at = S;
	bf->count = L;
	bf->capacity = L;
	return bf;
}

C_BUFFER* Buffer_Zero(int count)
{
	C_BUFFER* bf = Buffer_Init(count);
	if (bf->count)
		memset(bf->at, 0, bf->count);
	return bf;
}

C_BUFFER* Buffer_Copy(void* S, int count)
{
	C_BUFFER* bf;
	if (count < 0) count = S ? strlen(S) : 0;
	bf = Buffer_Init(count);
	if (count)
		memcpy(bf->at, S, count);
	return bf;
}

void Buffer_Swap(C_BUFFER* a, C_BUFFER* b)
{
	C_BUFFER tmp;
	memcpy(&tmp, a, sizeof(C_BUFFER));
	memcpy(a, b, sizeof(C_BUFFER));
	memcpy(b, &tmp, sizeof(C_BUFFER));
}

