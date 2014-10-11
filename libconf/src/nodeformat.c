
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <malloc.h>
#include "cdicto.h"
#include "cbuffer.h"
#include "internal.h"

static int Compare_Uint32(void const* a, void const* b)
{
	return *(uint32_t*)a - *(uint32_t*)b;
}

static int Str_Starts_With(char* S, char* patt)
{
	if (!patt || !S) return 0;

	while (*patt)
		if (*S++ != *patt++)
			return 0;
	return 1;
}

#define LIBCONF_INDENT_WIDTH 4

enum
{
    LIBCONF_FORMAT_MASK = 0x0300,
    LIBCONF_FORMAT_XDEF = 0x0000,
    LIBCONF_FORMAT_JSON = 0x0100,
};

void Xnode_Format_Value(C_BUFFER* bf, XVALUE* val, int flags, int indent)
{
	switch (val->opt & XVALUE_OPT_VALTYPE_MASK)
	{
		case XVALUE_OPT_VALTYPE_NONE:
			if ((flags & LIBCONF_FORMAT_MASK) == LIBCONF_FORMAT_JSON)
				Buffer_Append(bf, "null", -1);
			else /* XDEF */
				Buffer_Append(bf, "#none", -1);
			break;

		case XVALUE_OPT_VALTYPE_BOOL:
			if (val->bval)
				if ((flags & LIBCONF_FORMAT_MASK) == LIBCONF_FORMAT_JSON)
					Buffer_Append(bf, "true", -1);
				else /* XDEF */
					Buffer_Append(bf, "#true", -1);
			else if ((flags & LIBCONF_FORMAT_MASK) == LIBCONF_FORMAT_JSON)
				Buffer_Append(bf, "false", -1);
			else /* XDEF */
				Buffer_Append(bf, "#false", -1);
			break;

		case XVALUE_OPT_VALTYPE_INT:
			Buffer_Printf(bf, "%lld", val->dec);
			break;

		case XVALUE_OPT_VALTYPE_FLT:
			if (val->flt - (double)((long)val->flt) > 0.0009999999)
				Buffer_Printf(bf, "%.3f", val->flt);
			else
				Buffer_Printf(bf, "%.f", val->flt);
			break;

		case XVALUE_OPT_VALTYPE_STR:
			Buffer_Append(bf, "\"", 1);
			Buffer_Quote_Append(bf, val->txt, -1, '"');
			Buffer_Append(bf, "\"", 1);
			break;

		case XVALUE_OPT_VALTYPE_LIT:
			Buffer_Append(bf, "\"", 1);
			Buffer_Quote_Append(bf, (char*)&val->down, -1, '"');
			Buffer_Append(bf, "\"", 1);
			break;

		case XVALUE_OPT_VALTYPE_BIN:
			if ((flags & LIBCONF_FORMAT_MASK) == LIBCONF_FORMAT_XDEF)
			{
				int bytes_per_line = 30;
				int q = 0;

				Buffer_Append(bf, "[[", 2);

				if (val->binary->count > bytes_per_line)
				{
					Buffer_Append(bf, "\n", 1);
					Buffer_Fill_Append(bf, ' ', (indent + 1)*LIBCONF_INDENT_WIDTH);
				}

				while (q < val->binary->count)
				{
					int l = val->binary->count - q;
					if (l > bytes_per_line) l = bytes_per_line;
					Buffer_Hex_Append(bf, val->binary->at + q, l);
					q += l;
					if (q < val->binary->count)
					{
						Buffer_Append(bf, "\n", 1);
						Buffer_Fill_Append(bf, ' ', (indent + 1)*LIBCONF_INDENT_WIDTH);
					}
				}

				Buffer_Append(bf, "]]", 2);
			}
			break;

			/*case XVALUE_OPT_VALTYPE_STR_ARR:
			    {
			        int q = 0;
			        int count = Array_Count(val->strarr);

			        Buffer_Append(bf,"[\n",2);
			        Buffer_Fill_Append(bf,' ',(indent+1)*LIBCONF_INDENT_WIDTH);

			        for ( ; q < count; ++q )
			        {
			            Buffer_Append(bf,"\"",1);
			            Buffer_Quote_Append(bf,val->strarr->at[q],-1,'"');
			            Buffer_Fill_Append(bf,'"',1);
			            if ( q+1 < count ) Buffer_Fill_Append(bf,',',1);
			            Buffer_Fill_Append(bf,'\n',1);
			            Buffer_Fill_Append(bf,' ',(indent+1)*LIBCONF_INDENT_WIDTH);
			        }

			        Buffer_Fill_Append(bf,']',1);
			        break;
			    }*/

		case XVALUE_OPT_VALTYPE_FLT_ARR:
		{
			int q = 0;
			int nums_per_line = 5;

			Buffer_Fill_Append(bf, '[', 1);

			if (val->binary->count > nums_per_line * sizeof(double))
			{
				Buffer_Fill_Append(bf, '\n', 1);
				Buffer_Fill_Append(bf, ' ', (indent + 1)*LIBCONF_INDENT_WIDTH);
			}

			while (q + sizeof(double) <= val->binary->count)
			{
				int l = (val->binary->count - q) / sizeof(double);
				if (l > nums_per_line) l = nums_per_line;
				for (; l > 0; --l)
				{
					double d = *(double*)(val->binary->at + q * sizeof(double));

					if ((d - (double)((long)d)) > 0.000999999)
						Buffer_Printf(bf, "%.3f", d);
					else
						Buffer_Printf(bf, "%.f", d);

					q += sizeof(double);
					if (q + sizeof(double) <= val->binary->count)
						Buffer_Append(bf, ",", 1);
				}
				if (q + sizeof(double) <= val->binary->count)
				{
					Buffer_Fill_Append(bf, '\n', 1);
					Buffer_Fill_Append(bf, ' ', (indent + 1)*LIBCONF_INDENT_WIDTH);
				}
			}

			Buffer_Fill_Append(bf, ']', 1);
			break;
		}
	}
}

static int Xnode_Has_Subitems(XNODE* r)
{
	if (Xnode_Down(r))
		return 1;
	else
	{
		XVALUE* val = Xnode_First_Value(r);
		for (; val; val = Xnode_Next_Value(r, val))
		{
			char* tag = Xnode_Value_Get_Tag(r, val);
			if (!Str_Starts_With(tag, "$$$")
			    && strcmp(tag, "@Name")
			    && strcmp(tag, "@Value"))
				return 1;
		}
	}
	return 0;
}

static void Xnode_Format_Node_In_Depth(C_BUFFER* bf, XNODE* r, unsigned flags, int indent)
{
	XVALUE* val = Xnode_First_Value(r);
	for (; val; val = Xnode_Next_Value(r, val))
	{
		char* tag = Xnode_Value_Get_Tag(r, val);
		if (Str_Starts_With(tag, "$$$"))
			continue;
		if ((flags & LIBCONF_FORMAT_MASK) == LIBCONF_FORMAT_XDEF
		    && (!strcmp(tag, "@Name") || !strcmp(tag, "@Value")))
			continue;

		Buffer_Fill_Append(bf, ' ', indent * LIBCONF_INDENT_WIDTH);
		if ((flags & LIBCONF_FORMAT_MASK) == LIBCONF_FORMAT_JSON)
		{
			Buffer_Fill_Append(bf, '"', 1);
			Buffer_Append(bf, tag, -1);
			Buffer_Fill_Append(bf, '"', 1);
			Buffer_Append(bf, " : ", 3);
		}
		else /* XDEF */
		{
			Buffer_Append(bf, tag, -1);
			Buffer_Append(bf, " = ", 3);
		}

		Xnode_Format_Value(bf, val, flags, indent);

		if ((flags & LIBCONF_FORMAT_MASK) == LIBCONF_FORMAT_JSON)
			if (Xnode_Next_Value(r, val) || r->down)
				Buffer_Fill_Append(bf, ',', 1);

		Buffer_Fill_Append(bf, '\n', 1);
	}

	if ((flags & LIBCONF_FORMAT_MASK) == LIBCONF_FORMAT_JSON)
	{
		uint32_t* L;
		int i, ncount;
		XNODE* n;
		r = Xnode_Refacc(r);
		n = Xnode_Down(r);
		if (n)
		{
			ncount = Xnode_Count(r);
			L = alloca(32 * ncount);
			L[0] = r->down | ((uint32_t)n->tag << 16);
			for (i = 1; n->next; ++i)
			{
				XNODE* nn = Xnode_Next(n);
				assert(i < ncount);
				L[i] = n->next | ((uint32_t)nn->tag << 16);
				n = nn;
			}
			qsort(L, ncount, 4, Compare_Uint32);
			for (i = 0; i < ncount;)
			{
				char* tag = r->xdata->tags[(L[i] >> 16) - 1];
				n = Xdata_Idxref(r->xdata, (uint16_t)(L[i] & 0x0ffff));
				Buffer_Fill_Append(bf, ' ', indent * LIBCONF_INDENT_WIDTH);
				Buffer_Fill_Append(bf, '"', 1);
				Buffer_Append(bf, tag, -1);
				if (i + 1 < ncount && !((L[i]^L[i + 1]) >> 16))
				{
					Buffer_Append(bf, "\" : [", 5);
					for (;;)
					{
						Buffer_Append(bf, "{\n", 2);
						Xnode_Format_Node_In_Depth(bf, n, flags, indent + 1);
						Buffer_Fill_Append(bf, ' ', indent * LIBCONF_INDENT_WIDTH);
						Buffer_Fill_Append(bf, '}', 1);
						++i;
						if (i < ncount && !((L[i - 1]^L[i]) >> 16))
						{
							Buffer_Fill_Append(bf, ',', 1);
							Buffer_Fill_Append(bf, '\n', 1);
							Buffer_Fill_Append(bf, ' ', indent * LIBCONF_INDENT_WIDTH);
							n = Xdata_Idxref(r->xdata, (uint16_t)(L[i] & 0x0ffff));
						}
						else
							break;
					}
					Buffer_Fill_Append(bf, ']', 1);
				}
				else
				{
					Buffer_Append(bf, "\" : {\n", 6);
					Xnode_Format_Node_In_Depth(bf, n, flags, indent + 1);
					Buffer_Fill_Append(bf, ' ', indent * LIBCONF_INDENT_WIDTH);
					Buffer_Fill_Append(bf, '}', 1);
					++i;
				}
				if (i && i < ncount)
					Buffer_Fill_Append(bf, ',', 1);
				Buffer_Fill_Append(bf, '\n', 1);
			}
		}
	}
	else /* XDEF */
	{
		XVALUE* val;
		XNODE* n = Xnode_Down(r);
		for (; n; n = Xnode_Next(n))
		{
			int has_dflt_val = 0, has_name_val = 0, has_subitems;
			Buffer_Fill_Append(bf, ' ', indent * LIBCONF_INDENT_WIDTH);
			Buffer_Append(bf, Xnode_Get_Tag(n), -1);
			if ((val = Xnode_Value(n, "@Name", 0)))
			{
				has_name_val = 1;
				Buffer_Fill_Append(bf, '(', 1);
				Buffer_Append(bf, Xvalue_Get_Str(val, ""), -1);
				Buffer_Fill_Append(bf, ')', 1);
			}
			if ((val = Xnode_Value(n, "@Value", 0)))
			{
				Buffer_Append(bf, " = ", 3);
				Xnode_Format_Value(bf, val, flags, indent);
				has_dflt_val = 1;
			}
			if (((has_subitems = Xnode_Has_Subitems(n))) || !has_name_val)
			{
				Buffer_Append(bf, " {", 2);
				if (has_subitems)
				{
					Buffer_Fill_Append(bf, '\n', 1);
					Xnode_Format_Node_In_Depth(bf, n, flags, indent + 1);
					Buffer_Fill_Append(bf, ' ', indent * LIBCONF_INDENT_WIDTH);
				}
				Buffer_Append(bf, "}\n", 2);
			}
			else
				Buffer_Append(bf, "\n", 1);
		}
	}
}

char* Xnode_Format_Into(C_BUFFER* bf, XNODE* r, int flags)
{
	int start, indent = (flags & 0x0ff);
	assert(bf != 0);
	start = bf->count;
	Xnode_Format_Node_In_Depth(bf, r, flags, indent);
	return bf->at + start;
}

C_BUFFER* Xnode_Format(XNODE* r, unsigned flags)
{
	C_BUFFER* bf = Buffer_Init(0);
	Xnode_Format_Into(bf, r, flags);
	return bf;
}
