
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

#ifndef C_once_38B1FFE7_1462_42EB_BABE_AA8E0BE62203
#define C_once_38B1FFE7_1462_42EB_BABE_AA8E0BE62203

#include <stdint.h>
#include "crc8.h"

struct C_DICTO_REC;

typedef struct C_DICTO
{
	struct C_DICTO_REC** table;
	int count;
	int width;
	void (*destructor)(void*);
} C_DICTO;

#ifndef _CDICTO_PREFIX
#define _CDICTO_PREFIX Cdicto
#endif

#define Dicto_Hash_1(Key) Crc_8_Of_Cstr(Key)
#define Dicto_Count(Dicto) ((int)((C_DICTO*)(Dicto))->count+0)

#define Dicto_Rehash	   	_CDICTO_PREFIX##_Rehash
#define Dicto_Backet		_CDICTO_PREFIX##_Backet
#define Dicto_Allocate		_CDICTO_PREFIX##_Allocate
#define Dicto_Get 			_CDICTO_PREFIX##_Get
#define Dicto_Get_Key_Ptr 	_CDICTO_PREFIX##_Get_Key_Ptr
#define Dicto_Has 			_CDICTO_PREFIX##_Has
#define Dicto_Put			_CDICTO_PREFIX##_Put
#define Dicto_Del			_CDICTO_PREFIX##_Del
#define Dicto_Take			_CDICTO_PREFIX##_Take
#define Dicto_Clear			_CDICTO_PREFIX##_Clear
#define Dicto_Rehash		_CDICTO_PREFIX##_Rehash
#define Dicto_Kill			_CDICTO_PREFIX##_Kill
#define Dicto_Init			_CDICTO_PREFIX##_Init
#define Dicto_Apply 		_CDICTO_PREFIX##_Apply


void Dicto_Rehash(C_DICTO* o);
struct C_DICTO_REC** Dicto_Backet(C_DICTO* o, uint8_t hashcode, char* key);
struct C_DICTO_REC* Dicto_Allocate(char* key);
void* Dicto_Get(C_DICTO* o, char* key, void* dflt);
void* Dicto_Get_Key_Ptr(C_DICTO* o, char* key);
int Dicto_Has(C_DICTO* o, char* key);
char* Dicto_Put(C_DICTO* o, char* key, void* val);
void Dicto_Del(C_DICTO* o, char* key);
void* Dicto_Take(C_DICTO* o, char* key);
void Dicto_Clear(C_DICTO* o);
void Dicto_Rehash(C_DICTO* o);
void Dicto_Kill(C_DICTO* o);
C_DICTO* Dicto_Init(void(*destructor)(void*));

typedef void (*dicto_apply_filter_t)(char*, void*, void*);
void Dicto_Apply(
    C_DICTO* o
    , /*dicto_apply_filter_t*/ void* _filter
    , void* state);

#endif /* C_once_38B1FFE7_1462_42EB_BABE_AA8E0BE62203 */

