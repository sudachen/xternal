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

#include "ctable.h"
#include <assert.h>
#include <stdlib.h>


typedef struct C_TABLE_REC C_TABLE_REC;
struct C_TABLE_REC
{
	struct C_TABLE_REC* next;
	C_TABLE_VALUE value;
};

static int Table_Width_Values[] =
{
	5, 11, 29, 59, 127, 257, 521, 1049, 2099, 4201, 8419, 16843, 33703, 67409,
	134837, 269683, 539389, 1078787, 2157587, 4315183, 8630387, 17260781,
	34521589, 69043189, 138086407, 276172823, 552345671, 1104691373
};

C_TABLE_REC** Table_Backet(C_TABLE* o, uint64_t key)
{
	C_TABLE_REC** nrec;

	assert(o != 0);

	if (!o->table)
	{
		o->width = Table_Width_Values[0];
		o->table = calloc(o->width, sizeof(void*));
	}

	nrec = &o->table[key % o->width];

	while (*nrec)
	{
		if (key == (*nrec)->value.key)
			break;
		nrec = &(*nrec)->next;
	}

	return nrec;
}

C_TABLE_REC* Table_Allocate(uint64_t key)
{
	C_TABLE_REC* Q = calloc(1, sizeof(C_TABLE_REC));
	Q->value.key = key;
	return Q;
}

const C_TABLE_VALUE* Table_Get(C_TABLE* o, uint64_t key)
{
	C_TABLE_REC* Q = *Table_Backet(o, key);
	if (Q)
		return &Q->value;
	else
		return 0;
}

int Table_Has(C_TABLE* o, uint64_t key)
{
	return !!*Table_Backet(o, key);
}

const C_TABLE_VALUE* Table_Put(C_TABLE* o, uint64_t key, void* ptr, size_t size, void(*destructor)(void*))
{
	C_TABLE_REC** Q = Table_Backet(o, key);
	if (*Q)
	{
		C_TABLE_REC* p = *Q;
		if (p->value.destructor)
			p->value.destructor(p->value.ptr);
		p->value.ptr = ptr;
		p->value.size = size;
		p->value.destructor = destructor;
		return &p->value;
	}
	else
	{
		C_TABLE_REC* p;
		p = *Q = Table_Allocate(key);
		p->value.ptr = ptr;
		p->value.size = size;
		p->value.destructor = destructor;
		++o->count;
		if (o->count > o->width * 2)
			Table_Rehash(o);
		return &p->value;
	}
}

const C_TABLE_VALUE* Table_Put_Copy(C_TABLE* o, uint64_t key, void* ptr, size_t size)
{
	void* p = malloc(size);
	memcpy(p, ptr, size);
	return Table_Put(o, key, p, size, free);
}

const C_TABLE_VALUE* Table_Put_Copy_Z(C_TABLE* o, uint64_t key, void* ptr, size_t size)
{
	void* p = malloc(size + 1);
	memcpy(p, ptr, size);
	((uint8_t*)p)[size] = 0;
	return Table_Put(o, key, p, size, free);
}

void Table_Del(C_TABLE* o, uint64_t key)
{
	C_TABLE_REC** Q = Table_Backet(o, key);
	if (*Q)
	{
		C_TABLE_REC* p = *Q;
		if (p->value.destructor)
			p->value.destructor(p->value.ptr);
		*Q = (*Q)->next;
		free(p);
		assert(o->count >= 1);
		--o->count;
	}
}

void* Table_Take(C_TABLE* o, uint64_t key)
{
	C_TABLE_REC** Q = Table_Backet(o, key);
	if (*Q)
	{
		C_TABLE_REC* p = *Q;
		void* ret = p->value.ptr;
		*Q = (*Q)->next;
		free(p);
		assert(o->count >= 1);
		--o->count;
		return ret;
	}
}

void Table_Clear(C_TABLE* o)
{
	int i;

	assert(o != 0);

	if (o->table)
		for (i = 0; i < o->width; ++i)
			while (o->table[i])
			{
				C_TABLE_REC* Q = o->table[i];
				o->table[i] = Q->next;
				if (Q->value.destructor)
					Q->value.destructor(Q->value.ptr);
				free(Q);
			}

	if (o->table) free(o->table);
	o->table = 0;
	o->width = 0;
	o->count = 0;
}

void Table_Rehash(C_TABLE* o)
{
	assert(o != 0);

	if (o->table && o->count)
	{
		int i;
		int width = Table_Width_Values[sizeof(Table_Width_Values) / sizeof(Table_Width_Values[0] - 1)];
		C_TABLE_REC** table;

		for (i = 0; i < sizeof(Table_Width_Values) / sizeof(Table_Width_Values[0]); ++i)
			if (o->count <= Table_Width_Values[i] + Table_Width_Values[i] / 2)
			{
				width = Table_Width_Values[i];
				break;
			}

		if (width > o->width)
		{
			table = calloc(width, sizeof(void*));

			for (i = 0; i < o->width; ++i)
				while (o->table[i])
				{
					C_TABLE_REC* Q = o->table[i];
					o->table[i] = Q->next;
					Q->next = table[Q->value.key % width];
					table[Q->value.key % width] = Q;
				}

			free(o->table);
			o->width = width;
			o->table = table;
		}
	}
}

void Table_Kill(C_TABLE* o)
{
	if (o)
	{
		Table_Clear(o);
		free(o);
	}
}

C_TABLE* Table_Init(void)
{
	return calloc(1, sizeof(C_TABLE));
}

