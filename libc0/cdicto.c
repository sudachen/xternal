
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "cdicto.h"

typedef struct C_DICTO_REC
{
	struct C_DICTO_REC* next;
	void* ptr;
	uint8_t hashcode;
	char key[1];
} C_DICTO_REC;

int Dicto_Width_Values[] = {5, 11, 23, 47, 97, 181, 256};

C_DICTO_REC** Dicto_Backet(C_DICTO* o, uint8_t hashcode, char* key)
{
	C_DICTO_REC** nrec;

	if (!o->table)
	{
		o->width = Dicto_Width_Values[0];
		o->table = calloc(o->width, sizeof(void*));
	}

	nrec = &o->table[hashcode % o->width];

	while (*nrec)
	{
		if (hashcode == (*nrec)->hashcode && !strcmp((*nrec)->key, key))
			break;
		nrec = &(*nrec)->next;
	}

	return nrec;
}

C_DICTO_REC* Dicto_Allocate(char* key)
{
	int keylen = strlen(key);
	C_DICTO_REC* Q = malloc(sizeof(C_DICTO_REC) + keylen);
	memcpy(Q->key, key, keylen + 1);
	Q->hashcode = Dicto_Hash_1(key);
	Q->next = 0;
	Q->ptr = 0;
	return Q;
}

void* Dicto_Get(C_DICTO* o, char* key, void* dflt)
{
	if (key)
	{
		uint8_t hashcode = Dicto_Hash_1(key);
		C_DICTO_REC* Q = *Dicto_Backet(o, hashcode, key);
		if (Q)
			return Q->ptr;
	}
	return dflt;
}

void* Dicto_Get_Key_Ptr(C_DICTO* o, char* key)
{
	if (key)
	{
		uint8_t hashcode = Dicto_Hash_1(key);
		C_DICTO_REC* Q = *Dicto_Backet(o, hashcode, key);
		if (Q)
			return Q->key;
	}
	return 0;
}

int Dicto_Has(C_DICTO* o, char* key)
{
	if (key)
	{
		uint8_t hashcode = Dicto_Hash_1(key);
		if (*Dicto_Backet(o, hashcode, key))
			return 1;
	}
	return 0;
}

char* Dicto_Put(C_DICTO* o, char* key, void* val)
{
	if (key)
	{
		uint8_t hashcode = Dicto_Hash_1(key);
		C_DICTO_REC** Q = Dicto_Backet(o, hashcode, key);
		if (*Q)
		{
			C_DICTO_REC* p = *Q;
			if (o->destructor)
				o->destructor(p->ptr);
			p->ptr = val;
			key = (*Q)->key;
		}
		else
		{
			*Q = Dicto_Allocate(key);
			key = (*Q)->key;
			(*Q)->ptr = val;
			++o->count;
			if (o->count > o->width * 3)
				Dicto_Rehash(o);
		}
		return key;
	}
	else
		return 0;
}

void Dicto_Del(C_DICTO* o, char* key)
{
	if (key)
	{
		uint8_t hashcode = Dicto_Hash_1(key);
		C_DICTO_REC** Q = Dicto_Backet(o, hashcode, key);
		if (*Q)
		{
			C_DICTO_REC* p = *Q;
			if (o->destructor)
				o->destructor(p->ptr);
			*Q = (*Q)->next;
			free(p);
			assert(o->count >= 1);
			--o->count;
		}
	}
}

void* Dicto_Take(C_DICTO* o, char* key)
{
	if (key)
	{
		uint8_t hashcode = Dicto_Hash_1(key);
		C_DICTO_REC** Q = Dicto_Backet(o, hashcode, key);
		if (*Q)
		{
			C_DICTO_REC* p = *Q;
			void* ret = p->ptr;
			*Q = (*Q)->next;
			free(p);
			assert(o->count >= 1);
			--o->count;
			return ret;
		}
	}
	return 0;
}

void Dicto_Clear(C_DICTO* o)
{
	int i;
	if (o->table)
		for (i = 0; i < o->width; ++i)
			while (o->table[i])
			{
				C_DICTO_REC* Q = o->table[i];
				o->table[i] = Q->next;
				if (o->destructor)
					o->destructor(Q->ptr);
				free(Q);
			}

	if (o->table) free(o->table);
	o->table = 0;
	o->width = 0;
	o->count = 0;
}

void Dicto_Rehash(C_DICTO* o)
{
	if (o->table && o->count)
	{
		int i;
		int width = 256;
		C_DICTO_REC** table;

		for (i = 0; Dicto_Width_Values[i] < 256; ++i)
			if (o->count <= Dicto_Width_Values[i] + Dicto_Width_Values[i] / 2)
			{
				width = Dicto_Width_Values[i];
				break;
			}

		if (width > o->width)
		{
			table = calloc(width, sizeof(void*));

			for (i = 0; i < o->width; ++i)
				while (o->table[i])
				{
					C_DICTO_REC* Q = o->table[i];
					o->table[i] = Q->next;
					Q->next = table[Q->hashcode % width];
					table[Q->hashcode % width] = Q;
				}

			free(o->table);
			o->width = width;
			o->table = table;
		}
	}
}

void Dicto_Kill(C_DICTO* o)
{
	Dicto_Clear(o);
	free(o);
}

C_DICTO* Dicto_Init(void(*destructor)(void*))
{
	C_DICTO* dicto = calloc(1,sizeof(C_DICTO));
	dicto->destructor = destructor;
	return dicto;
}

typedef void (*dicto_apply_filter_t)(char*, void*, void*);

void Dicto_Apply(
    C_DICTO* o
    , /*dicto_apply_filter_t*/ void* _filter
    , void* state)
{
	int i;
	C_DICTO_REC* nrec;
	dicto_apply_filter_t filter = _filter;
	if (o && o->table)
		for (i = 0; i < o->width; ++i)
		{
			nrec = o->table[i];
			while (nrec)
			{
				filter(nrec->key, nrec->ptr, state);
				nrec = nrec->next;
			}
		}
}

