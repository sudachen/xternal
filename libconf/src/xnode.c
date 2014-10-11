
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "cdicto.h"
#include "cbuffer.h"

#include "internal.h"

static int error_value = 0;
char error_message[256] = {0};

int Libconf_Error(int error, char *message)
{
	memset(error_message,0,sizeof(error_message));
	if ( message )
		strncpy(error_message,message,sizeof(error_message)-1);
	return error_value;
}

int Libconf_Error_Occured(int clear)
{
	int error = error_value;
	if ( clear ) error_value = 0;
	return error;
}

char *Libconf_Error_String(int clear)
{
	int error = error_value;
	if ( clear ) error_value = 0;
	return error_message;
}

void Libconf_Error_Check()
{
	if (Libconf_Error_Occured(0))
		abort();
}

void Xvalue_Purge(XVALUE* val)
{
	assert(val != 0);

	switch (val->opt & XVALUE_OPT_VALTYPE_MASK)
	{
		case XVALUE_OPT_VALTYPE_STR:
			free(val->txt);
			break;
		case XVALUE_OPT_VALTYPE_BIN:
			free(val->binary);
			break;
		case XVALUE_OPT_VALTYPE_NONE:
		case XVALUE_OPT_VALTYPE_INT:
		case XVALUE_OPT_VALTYPE_FLT:
		case XVALUE_OPT_VALTYPE_LIT:
		case XVALUE_OPT_VALTYPE_BOOL:
			break;
		default:
			abort(); /* memory corruped */
			return;
	}

	val->opt = XVALUE_OPT_VALTYPE_NONE;
	val->down = 0;
	memset(val->holder, 0, sizeof(val->holder));
}

char* Int_Strdup(uint64_t val)
{
	char syms[70] = {0};
	sprintf(syms, "%lld", val);
	return strdup(syms);
}

char* Flt_Strdup(uint64_t val)
{
	char syms[70] = {0};
	sprintf(syms, "%.3f", val);
	return strdup(syms);
}

char* Bool_Strdup(int val)
{
	if (val)
		return strdup("#true");
	else
		return strdup("#false");
}

char* Xvalue_Copy_Str(XVALUE* val, char* dfltval)
{
	if (val)
		switch (val->opt & XVALUE_OPT_VALTYPE_MASK)
		{
			case XVALUE_OPT_VALTYPE_INT:
				return Int_Strdup(val->dec);
			case XVALUE_OPT_VALTYPE_FLT:
				return Flt_Strdup(val->flt);
			case XVALUE_OPT_VALTYPE_STR:
				return strdup(val->txt);
			case XVALUE_OPT_VALTYPE_LIT:
				return strdup((char*)&val->down);
			case XVALUE_OPT_VALTYPE_NONE:
				return dfltval ? strdup(dfltval) : 0;
			case XVALUE_OPT_VALTYPE_BOOL:
				return Bool_Strdup(val->bval);
		}
	return dfltval ? strdup(dfltval) : 0;
}

char* Xvalue_Get_Str(XVALUE* val, char* dfltval)
{
	if (val)
		switch (val->opt & XVALUE_OPT_VALTYPE_MASK)
		{
			case XVALUE_OPT_VALTYPE_STR:
				return (val->txt && val->txt[0]) ? val->txt : dfltval;
			case XVALUE_OPT_VALTYPE_LIT:
				return (char*)&val->down;
			case XVALUE_OPT_VALTYPE_NONE:
				return dfltval;
			case XVALUE_OPT_VALTYPE_BOOL:
				if (val->bval)
					return "#true";
				else
					return "#false";
		}
	return dfltval;
}

int64_t Str_To_Int_Dflt(char* S, int64_t dflt)
{
	int64_t l;
	if (!S)
		l = dflt;
	else
	{
		char* ep = 0;
		l = _strtoi64(S, &ep, 0);
		if (!*S || *ep)
			l = dflt;
	}
	return l;
}

double Str_To_Flt_Dflt(char* S, double dflt)
{
	double l = 0;

	if (!S)
		l = dflt;
	else
	{
		char* ep = 0;
		l = strtod(S, &ep);
		if (!*S || *ep)
			l = dflt;
	}

	return l;
}

int64_t Xvalue_Get_Int(XVALUE* val, int64_t dfltval)
{
	if (val)
		switch (val->opt & XVALUE_OPT_VALTYPE_MASK)
		{
			case XVALUE_OPT_VALTYPE_INT:
				return val->dec;
			case XVALUE_OPT_VALTYPE_FLT:
				return (int64_t)val->flt;
			case XVALUE_OPT_VALTYPE_STR:
				return Str_To_Int_Dflt(val->txt, dfltval);
			case XVALUE_OPT_VALTYPE_LIT:
				return Str_To_Int_Dflt((char*)&val->down, dfltval);
			case XVALUE_OPT_VALTYPE_NONE:
				return 0;
			case XVALUE_OPT_VALTYPE_BOOL:
				return val->bval;
		}
	return dfltval;
}

double Xvalue_Get_Flt(XVALUE* val, double dfltval)
{
	if (val)
		switch (val->opt & XVALUE_OPT_VALTYPE_MASK)
		{
			case XVALUE_OPT_VALTYPE_INT:
				return (double)val->dec;
			case XVALUE_OPT_VALTYPE_FLT:
				return val->flt;
			case XVALUE_OPT_VALTYPE_STR:
				return Str_To_Flt_Dflt(val->txt, dfltval);
			case XVALUE_OPT_VALTYPE_LIT:
				return Str_To_Flt_Dflt((char*)&val->down, dfltval);
			case XVALUE_OPT_VALTYPE_NONE:
				return 0;
		}
	return dfltval;
}

int Str_To_Bool_Dflt(char* S, int dflt)
{
	if (S && *S == '#') ++S;
	if (!S || !*S || !stricmp(S, "no") || !stricmp(S, "off")
	    || !stricmp(S, "false") || !stricmp(S, "0"))
		return 0;
	if (!stricmp(S, "yes") || !stricmp(S, "on") || !stricmp(S, "true")
	    || !stricmp(S, "1"))
		return 1;
	return dflt;
}

int Xvalue_Get_Bool(XVALUE* val, int dfltval)
{
	if (val)
		switch (val->opt & XVALUE_OPT_VALTYPE_MASK)
		{
			case XVALUE_OPT_VALTYPE_INT:
				return val->dec ? 1 : 0;
			case XVALUE_OPT_VALTYPE_BOOL:
				return val->bval;
			case XVALUE_OPT_VALTYPE_FLT:
				return val->flt ? 1 : 0;
			case XVALUE_OPT_VALTYPE_STR:
				return Str_To_Bool_Dflt(val->txt, dfltval);
			case XVALUE_OPT_VALTYPE_LIT:
				return Str_To_Bool_Dflt((char*)&val->down, dfltval);
			case XVALUE_OPT_VALTYPE_NONE:
				return 0;
		}
	return dfltval;
}

char* Str_Copy(char* S, int len)
{
	if (S)
	{
		char* p = malloc(len + 1);
		memcpy(p, S, len);
		p[len] = 0;
		return p;
	}
	else
	{
		char* p = malloc(1);
		*p = 0;
		return p;
	}
}

void Xvalue_Set_Str(XVALUE* val, char* S, int L)
{
	Xvalue_Purge(val);
	if (L < 0) L = S ? strlen(S) : 0;
	if (L >= sizeof(val->down) + sizeof(val->holder) /*|| !S*/)
	{
		val->txt = Str_Copy(S, L);
		val->opt = XVALUE_OPT_VALTYPE_STR;
	}
	else
	{
		if (L) memcpy((char*)&val->down, S, L);
		/* already filled by 0 in Xvalue_Purge */
		val->opt = XVALUE_OPT_VALTYPE_LIT;
	}
}

void Xvalue_Set_Int(XVALUE* val, int64_t i)
{
	Xvalue_Purge(val);
	val->dec = i;
	val->opt = XVALUE_OPT_VALTYPE_INT;
}

void Xvalue_Set_Flt(XVALUE* val, double d)
{
	Xvalue_Purge(val);
	val->flt = d;
	val->opt = XVALUE_OPT_VALTYPE_FLT;
}

void Xvalue_Set_Bool(XVALUE* val, int b)
{
	Xvalue_Purge(val);
	val->bval = b ? 1 : 0;
	val->opt = XVALUE_OPT_VALTYPE_BOOL;
}

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
	if ( a ) --a;
	return 1<<Bitcount_Of(a);
}

int Xdata_Idxref_No(XDATA* doc, uint16_t idx, int* no)
{
	--idx;

	if (idx >= 32)
	{
		int ref = Bitcount_Of(idx);
		*no  = idx - (1 << (ref - 1));
		assert(ref >= 5);
		assert(ref < XNODE_NUMBER_OF_NODE_LISTS + 5);
		return ref - 5;
	}
	else
	{
		*no = idx;
		return 0;
	}
}

void* Xdata_Idxref(XDATA* doc, uint16_t idx)
{
	assert(doc);
	assert(idx);
	if (1)
	{
		XNODE* n;
		int no;
		int ref = Xdata_Idxref_No(doc, idx, &no);
		n = doc->nodes[ref] + no;
		return n;
	}
}

void Xdata_Kill(XDATA* self)
{
	int i, j;

	assert(self);
	assert(self->root.xdata == self);

	for (i = 0; i < XNODE_NUMBER_OF_NODE_LISTS; ++i)
		if (self->nodes[i])
		{
			for (j = 0; j < Number_Of_Nodes_In_List(i); ++j)
			{
				XNODE* r = self->nodes[i] + j;
				if (!(r->opt & XVALUE_OPT_IS_VALUE) && r->down == XVALUE_DOWN_REFNODE)
				{
					XNODE* ref = Xdata_Idxref(r->xdata, r->opt);
					assert(ref->opt ==  XVALUE_OPT_VALTYPE_REFNODE);
					r->down = 0;
					Xnode_Release(ref->refval);
				}
				else if (((r->opt & XVALUE_OPT_VALTYPE_MASK) == XVALUE_OPT_VALTYPE_STR
				          || (r->opt & XVALUE_OPT_VALTYPE_MASK) == XVALUE_OPT_VALTYPE_BIN))
					Xvalue_Purge(r);
			}
			free(self->nodes[i]);
		}
	free(self->tags);
	Dicto_Kill(self->dicto);
	free(self);
}

void Xdata_Release(XDATA* self)
{
	if ( !self ) return;
	assert(self->refcount > 0);
	assert(self->root.xdata == self);
	if (0 == --self->refcount)
		Xdata_Kill(self);
}

void Xdata_Addref(XDATA* self)
{
	assert(self);
	assert(self->refcount > 0);
	assert(self->root.xdata == self);
	++self->refcount;
}

void Xnode_Release(XNODE* node)
{
	if ( !node ) return;
	Xdata_Release(Xnode_Get_Xdata(node));
}

void Xnode_Addref(XNODE* node)
{
	Xdata_Addref(Xnode_Get_Xdata(node));
}

XDATA* Xnode_Get_Xdata(XNODE* node)
{
	assert(node != 0);
	assert(!(node->opt & XVALUE_OPT_IS_VALUE));
	assert(node->xdata != 0);
	return node->xdata;
}

#define Xnode_Resolve_Name(Node,Name,Cine) Xdata_Resolve_Name(Node->xdata,tag,Cine)
char* Xdata_Resolve_Name(XDATA* doc, char* tag, int create_if_doesnt_exist)
{
	if (tag && tag > XNODE_MAX_NAME_INDEX_PTR)
	{
		char* q;
		q = Dicto_Get(doc->dicto, tag, 0);
		if (q)
			;
		else if (create_if_doesnt_exist)
		{
			char* stored;
			q = (char*)(uintptr_t)(++doc->last_tag);
			assert(q < XNODE_MAX_NAME_INDEX_PTR);
			stored = Dicto_Put(doc->dicto, tag, q);
			doc->tags = realloc(doc->tags, sizeof(char*) * (doc->last_tag + 1));
			assert(doc->tags != 0);
			doc->tags[doc->last_tag - 1] = stored;
		}
		return q;
	}
	else
		return tag;
}

XDATA* Xdata_Init()
{
	XDATA* doc = calloc(1, sizeof(XDATA));
	doc->refcount = 1;
	doc->dicto = Dicto_Init(0);
	doc->root.xdata = doc;
	doc->root.tag = (uint16_t)(uintptr_t)Xdata_Resolve_Name(doc, "root", 1);
	return doc;
}

char* Xnode_Get_Tag(XNODE* node)
{
	assert(node != 0);
	assert((node->opt & XVALUE_OPT_IS_VALUE) == 0);
	assert(node->tag > 0 && node->tag <= node->xdata->last_tag);

	return node->xdata->tags[node->tag - 1];
}

int Xnode_Tag_Is(XNODE* node, char* tag_name)
{
	uint16_t tag;

	assert(node != 0);
	assert((node->opt & XVALUE_OPT_IS_VALUE) == 0);
	assert(node->tag > 0 && node->tag <= node->xdata->last_tag);

	tag = (uint16_t)(uintptr_t)Xdata_Resolve_Name(node->xdata, tag_name, 0);
	return node->tag == tag;
}

XNODE* Xnode_Refacc(XNODE* node)
{
	assert(node != 0);
	if (!(node->opt & XVALUE_OPT_IS_VALUE) && node->down == XVALUE_DOWN_REFNODE)
	{
		XNODE* ref = Xdata_Idxref(node->xdata, node->opt);
		assert(ref->opt ==  XVALUE_OPT_VALTYPE_REFNODE);
		node = ref->refval;
	}
	return node;
}

char* Xnode_Value_Get_Tag(XNODE* node, XVALUE* value)
{
	assert(node);
	assert(value);

	node = Xnode_Refacc(node);

	assert((node->opt & XVALUE_OPT_IS_VALUE) == 0);
	assert((value->opt & XVALUE_OPT_IS_VALUE) != 0);
	assert(value->tag > 0 && value->tag <= node->xdata->last_tag);

	return node->xdata->tags[value->tag - 1];
}

XNODE* Xnode_Down(XNODE* node)
{
	assert(node != 0);
	assert((node->opt & XVALUE_OPT_IS_VALUE) == 0);

	node = Xnode_Refacc(node);
	if (node->down)
		return Xdata_Idxref(node->xdata, node->down);

	return 0;
}

XVALUE* Xnode_First_Value(XNODE* node)
{
	assert(node != 0);
	assert((node->opt & XVALUE_OPT_IS_VALUE) == 0);

	node = Xnode_Refacc(node);
	if (node->opt)
		return (XVALUE*)Xdata_Idxref(node->xdata, node->opt);

	return 0;
}

XVALUE* Xnode_Next_Value(XNODE* node, XVALUE* value)
{
	assert(node != 0);
	assert((node->opt & XVALUE_OPT_IS_VALUE) == 0);
	assert(value != 0);
	assert((value->opt & XVALUE_OPT_IS_VALUE) != 0);

	node = Xnode_Refacc(node);
	if (value->next)
		return (XVALUE*)Xdata_Idxref(node->xdata, value->next);

	return 0;
}

XNODE* Xnode_Next(XNODE* node)
{
	assert(node != 0);
	assert((node->opt & XVALUE_OPT_IS_VALUE) == 0);

	if (node->next)
	{
		XNODE* n = Xdata_Idxref(node->xdata, node->next);
		assert(n != node);
		return n;
	}

	return 0;
}

XNODE* Xnode_Last(XNODE* node)
{
	XNODE* n = 0;

	assert(node != 0);
	assert((node->opt & XVALUE_OPT_IS_VALUE) == 0);

	node = Xnode_Down(node);

	while (node)
	{
		n = node;
		node = Xnode_Next(node);
	}

	return n;
}

int Xnode_Count(XNODE* node)
{
	int i = 0;

	assert(node);
	assert((node->opt & XVALUE_OPT_IS_VALUE) == 0);

	node = Xnode_Down(node);

	while (node)
	{
		++i;
		node = Xnode_Next(node);
	}

	return i;
}

XNODE* Xdata_Allocate(XDATA* doc, char* tag, uint16_t* idx)
{
	int no, ref, newidx;
	XNODE* n;

	assert(doc != 0);
	assert(tag != 0);
	assert(idx != 0);

	newidx = ++doc->last_node;
	ref = Xdata_Idxref_No(doc, (uint16_t)newidx, &no);
	if (!doc->nodes[ref])
	{
		int count = sizeof(XNODE) * Number_Of_Nodes_In_List(ref);
		doc->nodes[ref] = malloc(count);
		memset(doc->nodes[ref], 0xff, count);
	}

	*idx = newidx;
	n = doc->nodes[ref] + no;
	memset(n, 0, sizeof(XNODE));
	n->tag = (uint16_t)(uintptr_t)Xdata_Resolve_Name(doc, tag, 1);
	return n;
}

XNODE* Xdata_Create_Node(XDATA* doc, char* tag, uint16_t* idx)
{
	XNODE* n;
	n = Xdata_Allocate(doc, tag, idx);
	n->xdata = doc;
	return n;
}

XVALUE* Xdata_Create_Value(XDATA* doc, char* tag, uint16_t* idx)
{
	XNODE* n = Xdata_Allocate(doc, tag, idx);
	n->opt = XVALUE_OPT_VALTYPE_NONE;
	return n;
}

XNODE* Xnode_Append(XNODE* node, char* tag)
{
	uint16_t idx;
	XNODE* n;

	assert(node != 0);
	assert(tag != 0);
	assert((node->opt & XVALUE_OPT_IS_VALUE) == 0);

	node = Xnode_Refacc(node);
	n = Xdata_Create_Node(node->xdata, tag, &idx);

	if (node->down)
	{
		XNODE* last = Xnode_Last(node);
		last->next = idx;
	}
	else
	{
		node->down = idx;
	}

	assert(n->next != idx);
	return n;
}

XNODE* Xnode_Append_Refnode(XNODE* node, char* tagname, XNODE* ref)
{
	XNODE* n;
	XNODE* v;

	assert(ref != 0);
	assert((ref->opt & XVALUE_OPT_IS_VALUE) == 0);

	node = Xnode_Refacc(node);

	if (!tagname) tagname = Xnode_Get_Tag(ref);
	n = Xnode_Append(node, tagname);
	v = Xdata_Allocate(node->xdata, ".refout.", &n->opt);
	n->down = XVALUE_DOWN_REFNODE;
	v->opt = XVALUE_OPT_VALTYPE_REFNODE;
	v->refval = ref;
	Xnode_Addref(v->refval);
	return n;
}

XNODE* Xnode_Insert(XNODE* node, char* tag)
{
	uint16_t idx;
	XNODE* n;

	assert(node != 0);
	assert(tag);
	assert((node->opt & XVALUE_OPT_IS_VALUE) == 0);

	n = Xdata_Create_Node(node->xdata, tag, &idx);
	n->next = node->down;
	node->down = idx;

	assert(n->next != idx);

	return n;
}

XNODE* Xnode_Down_If(XNODE* node, char* tag_name)
{
	uint16_t tag;
	XNODE* n;

	if (!node) return 0;
	node = Xnode_Refacc(node);

	assert(node);
	assert(tag_name);
	assert((node->opt & XVALUE_OPT_IS_VALUE) == 0);

	tag = (uint16_t)(uintptr_t)Xdata_Resolve_Name(node->xdata, tag_name, 0);

	if (tag)
	{
		n = Xnode_Down(node);
		while (n && n->tag != tag)
			n = Xnode_Next(n);

		if (n && n->tag == tag)
			return n;
	}

	return 0;
}

XNODE* Xnode_Next_If(XNODE* node, char* tag_name)
{
	uint16_t tag;
	XNODE* n = node;

	if (!node) return 0;
	//n = Xnode_Refacc(node);

	assert(n);
	assert(tag_name);
	assert((n->opt & XVALUE_OPT_IS_VALUE) == 0);

	tag = (uint16_t)(uintptr_t)Xdata_Resolve_Name(n->xdata, tag_name, 0);

	if (tag)
	{
		do
			n = Xnode_Next(n);
		while (n && n->tag != tag);

		if (n && n->tag == tag)
			return n;
	}

	return 0;
}

XVALUE* Xnode_Value(XNODE* node, char* valtag_S, int create_if_dnt_exist)
{
	XVALUE* value = 0;
	XDATA*  doc;
	uint16_t* next;
	uint16_t valtag;

	node = Xnode_Refacc(node);

	assert(node != 0);
	assert(valtag_S);
	assert((node->opt & XVALUE_OPT_IS_VALUE) == 0);

	doc = node->xdata;

	if (valtag_S > XNODE_MAX_NAME_INDEX_PTR)
		valtag = (uint16_t)(uintptr_t)Xdata_Resolve_Name(doc, valtag_S, create_if_dnt_exist);
	else
		valtag = (uint16_t)(uintptr_t)valtag_S;

	next = &node->opt;
	if (valtag)
	{
		while (*next)
		{
			value = (XVALUE*)Xdata_Idxref(doc, *next);
			assert(value != 0);
			if (value->tag == valtag)
				goto found;
			next = &value->next;
		}

		assert(!*next);
		if (create_if_dnt_exist)
		{
			assert(valtag);
			value = Xdata_Create_Value(doc, (char*)(uintptr_t)valtag, next);
			goto found;
		}
	}
	return 0;

found:
	return value;
}

int Xvalue_Get_Kind(XVALUE* val)
{
	if (val)
		return val->opt;
	return 0;
}

XNODE* Xdata_Get_Root(XDATA *xdata)
{
	assert(xdata != 0);
	return &xdata->root;
}

void Libconf_Buffer_Kill(LIBCONF_BUFFER *bf)
{
	Buffer_Kill(bf);
}

void Libconf_Cstr_Kill(char *str)
{
	free(str);
}
