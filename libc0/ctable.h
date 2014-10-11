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

#ifndef C_once_A4A5D671_7124_4AFA_AA2F_7EDB68B58E85
#define C_once_A4A5D671_7124_4AFA_AA2F_7EDB68B58E85

#include <stdint.h>

struct C_TABLE_REC;

typedef struct C_TABLE_VALUE
{
	uint64_t key;
	void* ptr;
	void(*destructor)(void*);
	size_t size;
} C_TABLE_VALUE;

typedef struct C_TABLE
{
	struct C_TABLE_REC** table;
	int count;
	int width;
} C_TABLE;

#ifndef _CTABLE_PREFIX
#define _CTABLE_PREFIX Ctable
#endif

#define Table_Count(Dicto) ((int)((C_TABLE*)(Dicto))->count+0)

#define Table_Backet		_CTABLE_PREFIX##_Backet
#define Table_Allocate		_CTABLE_PREFIX##_Allocate
#define Table_Get 			_CTABLE_PREFIX##_Get
#define Table_Has 			_CTABLE_PREFIX##_Has
#define Table_Put			_CTABLE_PREFIX##_Put
#define Table_Put_Copy		_CTABLE_PREFIX##_Put_Copy
#define Table_Put_Copy_Z	_CTABLE_PREFIX##_Put_Copy_Z
#define Table_Del			_CTABLE_PREFIX##_Del
#define Table_Take			_CTABLE_PREFIX##_Take
#define Table_Clear			_CTABLE_PREFIX##_Clear
#define Table_Rehash		_CTABLE_PREFIX##_Rehash
#define Table_Kill			_CTABLE_PREFIX##_Kill
#define Table_Init			_CTABLE_PREFIX##_Init

struct C_TABLE_REC** Table_Backet(C_TABLE* o, uint64_t key);
struct C_TABLE_REC* Table_Allocate(uint64_t key);
const C_TABLE_VALUE* Table_Get(C_TABLE* o, uint64_t key);
int Table_Has(C_TABLE* o, uint64_t key);
const C_TABLE_VALUE* Table_Put(C_TABLE* o, uint64_t key, void* ptr, size_t size, void(*destructor)(void*));
const C_TABLE_VALUE* Table_Put_Copy(C_TABLE* o, uint64_t key, void* ptr, size_t size);
const C_TABLE_VALUE* Table_Put_Copy_Z(C_TABLE* o, uint64_t key, void* ptr, size_t size);
void Table_Del(C_TABLE* o, uint64_t key);
void* Table_Take(C_TABLE* o, uint64_t key);
void Table_Clear(C_TABLE* o);
void Table_Rehash(C_TABLE* o);
void Table_Kill(C_TABLE* o);
C_TABLE* Table_Init(void);

#endif /* C_once_A4A5D671_7124_4AFA_AA2F_7EDB68B58E85 */
