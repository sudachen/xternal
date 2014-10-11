
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

#ifndef C_once_29A1C0D6_2792_4035_8D0E_9DB1797A4120
#define C_once_29A1C0D6_2792_4035_8D0E_9DB1797A4120

#include <stdint.h>

#ifndef TILLEOS
#  define TILLEOS (~(size_t)0)
#elif TILLEOS != (~(size_t)0)
#    error TILLEOS defined with other value
#endif

typedef struct C_BUFFER
{
	union
	{
		void* data;
		char* chars;
		uint8_t* at;
	};
	size_t count;
	size_t capacity;
} C_BUFFER;

#ifndef _CBUFFER_PREFIX
#define _CBUFFER_PREFIX Cbuffer
#endif

#define Buffer_Clear _CBUFFER_PREFIX##_Clear
#define Buffer_Reserve _CBUFFER_PREFIX##_Reserve
#define Buffer_Grow_Reserve _CBUFFER_PREFIX##_Grow_Reserve
#define Buffer_Resize _CBUFFER_PREFIX##_Resize
#define Buffer_Grow _CBUFFER_PREFIX##_Grow
#define Buffer_Append _CBUFFER_PREFIX##_Append
#define Buffer_Fill_Append _CBUFFER_PREFIX##_Fill_Append
#define Buffer_Print _CBUFFER_PREFIX##_Print
#define Buffer_Puts _CBUFFER_PREFIX##_Puts
#define Buffer_Set _CBUFFER_PREFIX##_Set
#define Buffer_Printf_Va _CBUFFER_PREFIX##_Printf_Va
#define Buffer_Printf _CBUFFER_PREFIX##_Printf
#define Buffer_Hex_Append _CBUFFER_PREFIX##_Hex_Append
#define Buffer_Esc_Append _CBUFFER_PREFIX##_Esc_Append
#define Buffer_Quote_Append _CBUFFER_PREFIX##_Quote_Append
#define Buffer_Html_Quote_Append _CBUFFER_PREFIX##_Html_Quote_Append
#define Buffer_Insert _CBUFFER_PREFIX##_Insert
#define Buffer_Take _CBUFFER_PREFIX##_Take
#define Buffer_Take_n_Kill _CBUFFER_PREFIX##_Take_n_Kill
#define Buffer_Kill _CBUFFER_PREFIX##_Kill
#define Buffer_Count _CBUFFER_PREFIX##_Count
#define Buffer_Capacity _CBUFFER_PREFIX##_Capacity
#define Buffer_Begin _CBUFFER_PREFIX##_Begin
#define Buffer_End _CBUFFER_PREFIX##_End
#define Buffer_Init _CBUFFER_PREFIX##_Init
#define Buffer_Acquire _CBUFFER_PREFIX##_Acquire
#define Buffer_Zero _CBUFFER_PREFIX##_Zero
#define Buffer_Copy _CBUFFER_PREFIX##_Copy
#define Buffer_Swap _CBUFFER_PREFIX##_Swap

void Buffer_Clear(C_BUFFER* bf);
C_BUFFER* Buffer_Reserve(C_BUFFER* bf, size_t capacity);
C_BUFFER* Buffer_Grow_Reserve(C_BUFFER* bf, size_t capacity);
void Buffer_Resize(C_BUFFER* bf, size_t count);
void Buffer_Grow(C_BUFFER* bf, size_t count);
void Buffer_Append(C_BUFFER* bf, void* S, size_t len);
void Buffer_Fill_Append(C_BUFFER* bf, int c, size_t count);
void Buffer_Print(C_BUFFER* bf, char* S);
void Buffer_Puts(C_BUFFER* bf, char* S);
void Buffer_Set(C_BUFFER* bf, char* S, size_t L);
void Buffer_Printf_Va(C_BUFFER* bf, char* fmt, va_list va);
void Buffer_Printf(C_BUFFER* bf, char* fmt, ...);
void Buffer_Hex_Append(C_BUFFER* bf, void* S, size_t len);
void Buffer_Esc_Append(C_BUFFER* bf, void* S, int len);
void Buffer_Quote_Append(C_BUFFER* bf, void* S, size_t len, int brk);
void Buffer_Html_Quote_Append(C_BUFFER* bf, void* S, size_t len);
void Buffer_Insert(C_BUFFER* bf, int pos, void* S, size_t len);
void* Buffer_Take(C_BUFFER* bf);
void* Buffer_Take_n_Kill(C_BUFFER* bf);
void Buffer_Kill(C_BUFFER* bf);

#define Buffer_COUNT(Bf)    (((C_BUFFER *)(Bf))->count)
#define Buffer_CAPACITY(Bf) (((C_BUFFER *)(Bf))->capacity)
#define Buffer_BEGIN(Bf)    (((C_BUFFER *)(Bf))->at)
#define Buffer_END(Bf)      (Buffer_BEGIN(Bf)+Buffer_COUNT(Bf))

size_t Buffer_Count(C_BUFFER* bf);
size_t Buffer_Capacity(C_BUFFER* bf);
void* Buffer_Begin(C_BUFFER* bf);
void* Buffer_End(C_BUFFER* bf);
C_BUFFER* Buffer_Init(int count);
C_BUFFER* Buffer_Acquire(char* S);
C_BUFFER* Buffer_Zero(int count);
C_BUFFER* Buffer_Copy(void* S, int count);
void Buffer_Swap(C_BUFFER* a, C_BUFFER* b);

#endif /* C_once_29A1C0D6_2792_4035_8D0E_9DB1797A4120 */
