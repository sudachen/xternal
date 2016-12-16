
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_750A77B2_260B_4E33_B9EA_15F01DDD61FF
#define C_once_750A77B2_260B_4E33_B9EA_15F01DDD61FF

#ifdef _BUILTIN
#define _C_XDEF_BUILTIN
#endif

#include "../C+.hc"
#include "../string.hc"
#include "../buffer.hc"
#include "../xdata.hc"
#include "../file.hc"

enum
{
	C_XDEF_INDENT_WIDTH = 2,
	XDEF_FORMAT_XDEF = 0,
	XDEF_FORMAT_JSON = 0x100,
	XDEF_FORMAT_MASK = 0x300,
};

typedef struct _C_XDEF_STATE
{
	char *text;
	int lineno;
	char *dirname;
} C_XDEF_STATE;

void Def_Parse_Skip_Spaces(C_XDEF_STATE *st)
#ifdef _C_XDEF_BUILTIN
{
	while ( *st->text && Isspace(*st->text) )
	{
		if ( *st->text == '\n' ) ++st->lineno;
		++st->text;
	}
}
#endif
;

char *Def_Parse_Get_Literal(C_XDEF_STATE *st)
#ifdef _C_XDEF_BUILTIN
{
	int capacity = 127;
	int len = 0;
	char *out = 0;

	if ( *st->text == '"' || *st->text == '\'')
	{
		char brk = *st->text;
		++st->text;
		for ( ; *st->text && *st->text != brk; ++st->text )
		{
			if ( *st->text == '\\' )
			{
				++st->text;
				if ( *st->text == '\n' )
					++st->lineno;
				else if ( *st->text == '\r' )
					; /* none */
				else if ( *st->text == '\\' || *st->text == '"' || *st->text == '\'' )
					__Vector_Append(&out,&len,&capacity,st->text,1);
				else if ( *st->text == 'n' )
					__Vector_Append(&out,&len,&capacity,"\n",1);
				else if ( *st->text == 'r' )
					__Vector_Append(&out,&len,&capacity,"\r",1);
				else if ( *st->text == 't' )
					__Vector_Append(&out,&len,&capacity,"\t",1);
				else if ( *st->text == 'x' )
				{
					byte_t q = Str_Unhex_Byte(st->text+1,0,0);
					st->text += 2;
					__Vector_Append(&out,&len,&capacity,&q,1);
				}
				else 
					__Raise(C_ERROR_ILLFORMED,__Format("invalid esc sequence at line %d",st->lineno));
			}
			else
				__Vector_Append(&out,&len,&capacity,st->text,1);
		}

		if ( *st->text == brk ) ++st->text;
	}
	else
	{
		char *q = st->text;
		while ( *st->text && !Isspace(*st->text) 
			&& *st->text != '(' && *st->text != ')' 
			&& *st->text != '{' && *st->text != '}'
			&& *st->text != '[' && *st->text != ']'  
			&& *st->text != ',' && *st->text != '=' )
			++st->text;
		__Vector_Append(&out,&len,&capacity,q,st->text-q);
	}

	return out;
}
#endif
;


char *Def_Parse_Get_Node_Literal(C_XDEF_STATE *st)
#ifdef _C_XDEF_BUILTIN
{
	if ( *st->text == '"' || *st->text == '\'' )
		return Def_Parse_Get_Literal(st);
	else
	{
		int brc_depth = 0;
		int capacity = 127;
		int len = 0;
		char *out = 0;
		char *q = st->text;
		while ( *st->text && ( *st->text != ')' || brc_depth ) )
		{
			if ( *st->text == ')' ) --brc_depth;
			else if ( *st->text == '(' ) ++brc_depth;
			++st->text;
		}
		__Vector_Append(&out,&len,&capacity,q,st->text-q);
		return out;
	}
}
#endif
;

typedef struct
{
	int type;
	union
	{
		C_ARRAY  *arr;
		C_BUFFER *dat;
		char   *txt;
		int     dec;
		double  flt;
	};
} C_XDEF_VALUE;

void Def_Parse_Get_Value(C_XDEF_STATE *st, C_XDEF_VALUE *val)
#ifdef _C_XDEF_BUILTIN
{
	if ( *st->text == '[' )
	{
		++st->text;
		if ( st->text[1] == '[' ) /* binary data */
		{
			byte_t b;
			val->dat = Buffer_Init(0);
			Def_Parse_Skip_Spaces(st);

			while ( Isxdigit(*st->text) )
			{
				if ( !Isxdigit(st->text[1]) )
					__Raise(C_ERROR_ILLFORMED,
					__Format("expected hex byte value at line %d",st->lineno));

				b = Str_Unhex_Byte(st->text,0,0);
				Buffer_Append(val->dat,&b,1);
				st->text += 2;
				Def_Parse_Skip_Spaces(st);
			}

			if ( !*st->text || *st->text != ']' || st->text[1] != ']' )
				__Raise(C_ERROR_ILLFORMED,
				__Format("expected ']]' at line %d",st->lineno));

			val->type = XVALUE_OPT_VALTYPE_BIN;
			st->text += 2;
		}
		else /* array */
		{ 
			C_XDEF_VALUE lval;
			Def_Parse_Skip_Spaces(st);
			Def_Parse_Get_Value(st,&lval);
			if ( lval.type == XVALUE_OPT_VALTYPE_STR )
			{
				val->arr = Array_Ptrs();
				val->type= XVALUE_OPT_VALTYPE_STR_ARR;
				Array_Push(val->arr,__Retain(lval.txt));
			}
			else if ( lval.type == XVALUE_OPT_VALTYPE_INT 
				|| lval.type == XVALUE_OPT_VALTYPE_FLT )
			{
				val->dat = Buffer_Init(sizeof(double));
				val->type= XVALUE_OPT_VALTYPE_FLT_ARR;
				if ( lval.type == XVALUE_OPT_VALTYPE_INT )
					*(double*)val->dat->at = lval.dec;
				else
					*(double*)val->dat->at = lval.flt;
			}

			Def_Parse_Skip_Spaces(st);
			while ( *st->text == ',' )
			{
				++st->text;
				Def_Parse_Skip_Spaces(st);
				Def_Parse_Get_Value(st,&lval);
				if ( val->type == XVALUE_OPT_VALTYPE_STR )
				{
					if ( val->type != XVALUE_OPT_VALTYPE_STR )
						__Raise(C_ERROR_ILLFORMED,
						__Format("expected string value at line %d",st->lineno));
					Array_Push(val->arr,__Retain(lval.txt));
				}
				else /* XVALUE_OPT_VALUETYPE_FLT_ARR */
				{

					if ( lval.type == XVALUE_OPT_VALTYPE_INT )
					{
						double f = lval.dec;
						Buffer_Append(val->dat,&f,sizeof(double));
					}
					else if ( lval.type == XVALUE_OPT_VALTYPE_FLT )
						Buffer_Append(val->dat,&lval.flt,sizeof(double));
					else
						__Raise(C_ERROR_ILLFORMED,
						__Format("expected numeric value at line %d",st->lineno));
				}
				Def_Parse_Skip_Spaces(st);
			}

			if ( *st->text != ']' )
				__Raise(C_ERROR_ILLFORMED,
				__Format("expected ']' at line %d",st->lineno));

			++st->text;
		}
	}
	else if ( *st->text == '#' )
	{
		int l = 0;
		if ( (Str_Starts_With(st->text+1,"yes") && (l = 4))
			|| (Str_Starts_With(st->text+1,"true") && (l = 5))
			|| (Str_Starts_With(st->text+1,"on") && (l = 3))
			|| (Str_Starts_With(st->text+1,"1") && (l = 2)) )
		{
			val->dec = 1;
			val->type = XVALUE_OPT_VALTYPE_BOOL;
			st->text += l;
		}
		else if ( (Str_Starts_With(st->text+1,"no") && (l = 3))
			|| (Str_Starts_With(st->text+1,"false") && (l = 6))
			|| (Str_Starts_With(st->text+1,"off") && (l = 4))
			|| (Str_Starts_With(st->text+1,"0") && (l = 2)) )
		{
			val->dec = 0;
			val->type = XVALUE_OPT_VALTYPE_BOOL;
			st->text += l;
		}
		else
			__Raise(C_ERROR_ILLFORMED,
			__Format("expected boolean value at line %d",st->lineno));
	}
	else if ( (*st->text == '"' && st->text[1] == '"' && st->text[2] == '"')
		||(*st->text == '\'' && st->text[1] == '\'' && st->text[2] == '\'') )
	{
		char *Q = st->text;
		st->text += 3;
		while ( *st->text && strncmp(st->text,Q,3) ) ++st->text;
		val->txt = Str_Copy_Npl(Q+3,st->text-Q-3);
		val->type = XVALUE_OPT_VALTYPE_STR;
		if ( *st->text ) st->text += 3;
	} 
	else if ( !Isdigit(*st->text) 
		&& ( (*st->text != '.' && *st->text != '-') || !Isdigit(st->text[1]) ) )
	{
		val->txt = Def_Parse_Get_Literal(st);
		val->type = XVALUE_OPT_VALTYPE_STR;
	}
	else /* number */
	{
		if ( *st->text == '0' )
		{
			++st->text;
			val->dec = 0;

			if ( *st->text == 'x' && Isxdigit(st->text[1]) ) /* hex value */
			{
				++st->text;
				do
				{
					val->dec = val->dec << 4;
					STR_UNHEX_HALF_OCTET(st->text,val->dec,0);
					++st->text;
				}
				while ( Isxdigit(*st->text) );
			}
			else if ( *st->text >= '0' && *st->text <= '7' )
			{
				++st->text;
				do
				{
					val->dec = (val->dec << 3) | (*st->text-'0'); 
					++st->text;
				}
				while ( *st->text >= '0' && *st->text <= '7' );
			}
			else if ( Isspace(*st->text) )
			{
				; /* nothing, it's zero value */
			}
			else if ( *st->text == '.' )
				goto float_value;
			else
				goto invalid_numeric;

			val->type = XVALUE_OPT_VALTYPE_INT;

		}
		else if ( Isdigit(*st->text) || *st->text == '.' || *st->text == '-' ) /* decimal or float value */
		{
			int neg, value;
float_value:

			neg = 1;
			value = 0;

			if ( *st->text == '-' ) { neg = -1; ++st->text; }

			for ( ; Isdigit(*st->text); ++st->text )
				value = value * 10 + ( *st->text - '0' );

			if ( *st->text == '.' )
			{
				double exp = 1;
				double d = value*neg;
				++st->text;
				for ( ; Isdigit(*st->text); ++st->text )
				{
					d = d * 10 + ( *st->text - '0' );
					exp *= 10;
				}
				val->flt = d/exp;
				val->type = XVALUE_OPT_VALTYPE_FLT;
			}
			else
			{
				val->type = XVALUE_OPT_VALTYPE_INT;
				val->dec = value*neg;
			}
		}

		if ( *st->text 
			&& !Isspace(*st->text) && *st->text != ')' 
			&& *st->text != '}' && *st->text != ',' && *st->text != ']' )
invalid_numeric:
		__Raise(C_ERROR_ILLFORMED,
			__Format("invalid numeric value at line %d",st->lineno));
	}
}
#endif
;

void Def_Parse_In_Node_Set_Value(C_XNODE *n, char *name, C_XDEF_VALUE *val)
#ifdef _C_XDEF_BUILTIN
{
	C_XVALUE *xv = Xnode_Value(n,name,1);;
	switch ( val->type )
	{
	case XVALUE_OPT_VALTYPE_INT:
		Xvalue_Set_Int(xv,val->dec);
		break;
	case XVALUE_OPT_VALTYPE_BOOL:
		Xvalue_Set_Bool(xv,val->dec);
		break;
	case XVALUE_OPT_VALTYPE_FLT:
		Xvalue_Set_Flt(xv,val->flt);
		break;
	case XVALUE_OPT_VALTYPE_STR:
		Xvalue_Put_Str(xv,__Retain(val->txt));
		break;
	case XVALUE_OPT_VALTYPE_BIN:
		Xvalue_Put_Binary(xv,__Refe(val->dat));
		break;
	case XVALUE_OPT_VALTYPE_FLT_ARR:
		Xvalue_Put_Flt_Array(xv,__Refe(val->dat));
		break;
	case XVALUE_OPT_VALTYPE_STR_ARR:
		Xvalue_Put_Str_Array(xv,__Refe(val->arr));
		break;
	default:
		__Raise(C_ERROR_UNEXPECTED_VALUE,0);
	}

}
#endif
;

C_XDATA *Def_Parse_File(char *filename);
void Def_Parse_In_Node( C_XDEF_STATE *st, C_XNODE *n )
#ifdef _C_XDEF_BUILTIN
{
	Def_Parse_Skip_Spaces(st);

	for ( ; *st->text && *st->text != '}' ; Def_Parse_Skip_Spaces(st) ) 
	{
		int set_if_not_set = 0;
		int go_deeper = 0;
		C_XNODE *nn = 0;

		__Auto_Release
		{
			C_XDEF_VALUE value = {0};
			char *name; 
			char *nodename = 0;
			name = Def_Parse_Get_Literal(st);
			Def_Parse_Skip_Spaces(st);

			if ( *st->text == '(' )
			{
				++st->text;
				Def_Parse_Skip_Spaces(st);
				nodename = Def_Parse_Get_Node_Literal(st);
				Def_Parse_Skip_Spaces(st);
				if ( *st->text != ')' )
					__Raise(C_ERROR_ILLFORMED,__Format("expected ')' at line %d",st->lineno));
				++st->text;
				Def_Parse_Skip_Spaces(st);
			}


			if ( *st->text == '?' && st->text[1] == '=' )
			{
				set_if_not_set = 1;
				++st->text;
			}

			if ( *st->text == '=' )
			{
				++st->text;
				Def_Parse_Skip_Spaces(st);
				Def_Parse_Get_Value(st,&value);
				Def_Parse_Skip_Spaces(st);
			}

			if ( *st->text == '<' && st->text[1] == '=' )
			{
				C_XDATA *xd = 0; 
				C_XNODE *sn = 0;
				char *include_file;
				char *subnode = 0;
				int  skip_if_dsnt_exists = 0;
				st->text += 2;
				Def_Parse_Skip_Spaces(st);
				include_file = Def_Parse_Get_Literal(st);
				Def_Parse_Skip_Spaces(st);
				if ( *include_file == '?' )
				{
					++include_file;
					skip_if_dsnt_exists = 1;
				}
				subnode = strchr(include_file,':');
				if ( subnode ) *subnode++ = 0;
				if ( st->dirname ) include_file = Path_Join(st->dirname,include_file);
				if ( !skip_if_dsnt_exists || File_Exists(include_file) )
				{
					xd = Def_Parse_File(include_file);
					sn = subnode?Xnode_Query_Node(&xd->root,subnode):&xd->root;
					if ( sn )
					{
						nn = Xnode_Append_Refnode(n,name,sn);
						name = 0;
					}
				}
			}

			if ( nodename )
			{
				if ( !nn )
					nn = Xnode_Append(n,name);
				Xnode_Value_Set_Str(nn,"@",nodename);
				name = 0;
			}            

			if ( *st->text == '{' )
			{
				++st->text;
				go_deeper = 1;
				if ( !nn )
					nn = Xnode_Append(n,name);
				if ( value.type )
					Def_Parse_In_Node_Set_Value(nn,"$",&value);
			}
			else if ( value.type )
			{
				if ( name || !nn )
				{
					if ( !set_if_not_set || !Xnode_Value(n,name,0) )
						Def_Parse_In_Node_Set_Value(n,name,&value);
				}
				else
					Def_Parse_In_Node_Set_Value(nn,"$",&value);
			}

		}

		if ( go_deeper )
		{
			Def_Parse_In_Node(st,nn);
			if ( *st->text != '}' )
				__Raise(C_ERROR_ILLFORMED,__Format("expected '}' at line %d",st->lineno));
			++st->text;
		}
	}
}
#endif
;

C_XDATA *Def_Parse_Str(char *text)
#ifdef _C_XDEF_BUILTIN
{
	C_XDEF_STATE st = { text, 1, 0 };
	C_XDATA *doc = Xdata_Init();
	Def_Parse_In_Node(&st,&doc->root);
	return doc;
}
#endif
;

C_XDATA *Def_Parse_File(char *filename)
#ifdef _C_XDEF_BUILTIN
{
	C_XDATA *ret = 0;

	__Auto_Ptr(ret)
	{
		C_BUFFER *bf = Oj_Read_All(Cfile_Open(filename,"rt"));
		C_XDEF_STATE st = { bf->at, 1, Path_Dirname(filename) };
		ret = Xdata_Init();
		Def_Parse_In_Node(&st,&ret->root);
	}
	return ret;
}
#endif
;

void Def_Format_Value(C_BUFFER *bf, C_XVALUE *val, int flags, int indent)
#ifdef _C_XDEF_BUILTIN
{
	switch ( val->opt&XVALUE_OPT_VALTYPE_MASK )
	{
	case XVALUE_OPT_VALTYPE_NONE:
		if ( (flags&XDEF_FORMAT_MASK) == XDEF_FORMAT_JSON )
			Buffer_Append(bf,"null",-1);
		else /* XDEF */
			Buffer_Append(bf,"#none",-1);
		break;

	case XVALUE_OPT_VALTYPE_BOOL:
		if ( val->bval )
			if ( (flags&XDEF_FORMAT_MASK) == XDEF_FORMAT_JSON )
				Buffer_Append(bf,"true",-1);
			else /* XDEF */
				Buffer_Append(bf,"#true",-1);
		else
			if ( (flags&XDEF_FORMAT_MASK) == XDEF_FORMAT_JSON )
				Buffer_Append(bf,"false",-1);
			else /* XDEF */
				Buffer_Append(bf,"#false",-1);
		break;

	case XVALUE_OPT_VALTYPE_INT:
		Buffer_Printf(bf,"%ld",val->dec);
		break;

	case XVALUE_OPT_VALTYPE_FLT:
		if ( val->flt - (double)((long)val->flt) > 0.0009999999 )
			Buffer_Printf(bf,"%.3f",val->flt);
		else
			Buffer_Printf(bf,"%.f",val->flt);
		break;

	case XVALUE_OPT_VALTYPE_STR:
		Buffer_Append(bf,"\"",1);
		Buffer_Quote_Append(bf,val->txt,-1,'"');
		Buffer_Append(bf,"\"",1);
		break;

	case XVALUE_OPT_VALTYPE_LIT:
		Buffer_Append(bf,"\"",1);
		Buffer_Quote_Append(bf,(char*)&val->down,-1,'"');
		Buffer_Append(bf,"\"",1);
		break;

	case XVALUE_OPT_VALTYPE_BIN:
		if ( (flags&XDEF_FORMAT_MASK) == XDEF_FORMAT_XDEF )
		{
			int bytes_per_line = 30;
			int q = 0;

			Buffer_Append(bf,"[[",2);

			if ( val->binary->count > bytes_per_line )
			{  
				Buffer_Append(bf,"\n",1);
				Buffer_Fill_Append(bf,' ',(indent+1)*C_XDEF_INDENT_WIDTH);
			}

			while ( q < val->binary->count )
			{
				int l = val->binary->count - q;
				if ( l > bytes_per_line ) l = bytes_per_line;
				Buffer_Hex_Append(bf,val->binary->at+q,l);
				q += l;
				if ( q < val->binary->count )
				{
					Buffer_Append(bf,"\n",1);
					Buffer_Fill_Append(bf,' ',(indent+1)*C_XDEF_INDENT_WIDTH);
				}
			}

			Buffer_Append(bf,"]]",2);
		}
		break;

	case XVALUE_OPT_VALTYPE_STR_ARR:
		{
			int q = 0;
			int count = Array_Count(val->strarr);

			Buffer_Append(bf,"[\n",2);
			Buffer_Fill_Append(bf,' ',(indent+1)*C_XDEF_INDENT_WIDTH);

			for ( ; q < count; ++q )
			{
				Buffer_Append(bf,"\"",1);
				Buffer_Quote_Append(bf,val->strarr->at[q],-1,'"');
				Buffer_Fill_Append(bf,'"',1);
				if ( q+1 < count ) Buffer_Fill_Append(bf,',',1);
				Buffer_Fill_Append(bf,'\n',1);
				Buffer_Fill_Append(bf,' ',(indent+1)*C_XDEF_INDENT_WIDTH);
			}

			Buffer_Fill_Append(bf,']',1);
			break;
		}
	case XVALUE_OPT_VALTYPE_FLT_ARR:
		{
			int q = 0;
			int nums_per_line = 5;

			Buffer_Fill_Append(bf,'[',1);

			if ( val->binary->count > nums_per_line*iszof_double )
			{  
				Buffer_Fill_Append(bf,'\n',1);
				Buffer_Fill_Append(bf,' ',(indent+1)*C_XDEF_INDENT_WIDTH);
			}

			while ( q+iszof_double <= val->binary->count )
			{
				int l = (val->binary->count - q)/iszof_double;
				if ( l > nums_per_line ) l = nums_per_line;
				for ( ; l > 0; --l )
				{
					double d = *(double*)(val->binary->at+q*iszof_double);

					if ( (d - (double)((long)d)) > 0.000999999 )
						Buffer_Printf(bf,"%.3f",d);
					else
						Buffer_Printf(bf,"%.f",d);

					q += iszof_double;
					if ( q+iszof_double <= val->binary->count )
						Buffer_Append(bf,",",1);
				}
				if ( q+iszof_double <= val->binary->count )
				{
					Buffer_Fill_Append(bf,'\n',1);
					Buffer_Fill_Append(bf,' ',(indent+1)*C_XDEF_INDENT_WIDTH);
				}
			}

			Buffer_Fill_Append(bf,']',1);
			break;
		}
	}
}
#endif
;

int Def_Has_Xdef_Subitems(C_XNODE *r)
#ifdef _C_XDEF_BUILTIN
{
	if ( Xnode_Down(r) ) 
		return 1;
	else
	{
		C_XVALUE *val = Xnode_First_Value(r);
		for ( ; val; val = Xnode_Next_Value(r,val) )
		{
			char *tag = Xnode_Value_Get_Tag(r,val);
			if ( !Str_Starts_With(tag,"$$$")
				&& strcmp(tag,"@") 
				&& strcmp(tag,"$"))
				return 1;
		}
	}
	return 0;
}
#endif
;

void Def_Format_Node_In_Depth(C_BUFFER *bf, C_XNODE *r, int flags, int indent)
#ifdef _C_XDEF_BUILTIN
{
	__Gogo
	{
		C_XVALUE *val = Xnode_First_Value(r);
		for ( ; val; val = Xnode_Next_Value(r,val) )
		{
			char *tag = Xnode_Value_Get_Tag(r,val);
			if ( Str_Starts_With(tag,"$$$") ) 
				continue;
			if ( (flags&XDEF_FORMAT_MASK) == XDEF_FORMAT_XDEF
				&& ( !strcmp(tag,"@") || !strcmp(tag,"$") ) )
				continue;

			Buffer_Fill_Append(bf,' ',indent*C_XDEF_INDENT_WIDTH);
			if ( (flags&XDEF_FORMAT_MASK) == XDEF_FORMAT_JSON )
			{
				Buffer_Fill_Append(bf,'"',1);
				Buffer_Append(bf,tag,-1);
				Buffer_Fill_Append(bf,'"',1);
				Buffer_Append(bf," : ",3);
			}
			else /* XDEF */
			{
				Buffer_Append(bf,tag,-1);
				Buffer_Append(bf," = ",3);
			}

			Def_Format_Value(bf,val,flags,indent);

			if ( (flags&XDEF_FORMAT_MASK) == XDEF_FORMAT_JSON )
				if ( Xnode_Next_Value(r,val) || r->down )
					Buffer_Fill_Append(bf,',',1);

			Buffer_Fill_Append(bf,'\n',1);
		}
	}

	if ( (flags&XDEF_FORMAT_MASK) == XDEF_FORMAT_JSON )
	{
		u32_t *L;
		int i, ncount;
		C_XNODE *n;
		r = Xnode_Refacc(r);
		n = Xnode_Down(r);
		if ( n )
		{
			ncount = Xnode_Count(r);
			L = alloca(32*ncount);
			L[0] = r->down|((u32_t)n->tag << 16);
			for ( i = 1; n->next; ++i ) 
			{
				C_XNODE *nn = Xnode_Next(n);
				STRICT_REQUIRE(i<ncount);
				L[i] = n->next|((u32_t)nn->tag << 16);
				n = nn;
			}
			qsort(L,ncount,4,Compare_u32);
			for ( i = 0; i < ncount; )
			{
				char *tag = r->xdata->tags[(L[i]>>16)-1];
				n = Xdata_Idxref(r->xdata,(ushort_t)(L[i]&0x0ffff));
				Buffer_Fill_Append(bf,' ',indent*C_XDEF_INDENT_WIDTH);
				Buffer_Fill_Append(bf,'"',1);
				Buffer_Append(bf,tag,-1);
				if ( i + 1 < ncount && !((L[i]^L[i+1])>>16) )
				{
					Buffer_Append(bf,"\" : [",5);
					for(;;) 
					{
						Buffer_Append(bf,"{\n",2);
						Def_Format_Node_In_Depth(bf,n,flags,indent+1);
						Buffer_Fill_Append(bf,' ',indent*C_XDEF_INDENT_WIDTH);
						Buffer_Fill_Append(bf,'}',1);
						++i;
						if ( i < ncount && !((L[i-1]^L[i])>>16) )
						{
							Buffer_Fill_Append(bf,',',1);
							Buffer_Fill_Append(bf,'\n',1);
							Buffer_Fill_Append(bf,' ',indent*C_XDEF_INDENT_WIDTH);
							n = Xdata_Idxref(r->xdata,(ushort_t)(L[i]&0x0ffff));
						}
						else
							break;
					}
					Buffer_Fill_Append(bf,']',1);
				}
				else
				{
					Buffer_Append(bf,"\" : {\n",6);
					Def_Format_Node_In_Depth(bf,n,flags,indent+1);
					Buffer_Fill_Append(bf,' ',indent*C_XDEF_INDENT_WIDTH);
					Buffer_Fill_Append(bf,'}',1);
					++i;
				}
				if ( i && i < ncount )
					Buffer_Fill_Append(bf,',',1);
				Buffer_Fill_Append(bf,'\n',1);
			}
		}
	}
	else /* XDEF */
	{
		C_XVALUE *val;
		C_XNODE *n = Xnode_Down(r);
		for ( ; n; n = Xnode_Next(n) )
		{
			int has_dflt_val = 0, has_name_val = 0, has_subitems; 
			Buffer_Fill_Append(bf,' ',indent*C_XDEF_INDENT_WIDTH);
			Buffer_Append(bf,Xnode_Get_Tag(n),-1);
			if (( val = Xnode_Value(n,"@",0) ))
			{
				has_name_val = 1;
				Buffer_Fill_Append(bf,'(',1);
				Buffer_Append(bf,Xvalue_Get_Str(val,""),-1);
				Buffer_Fill_Append(bf,')',1);
			}
			if (( val = Xnode_Value(n,"$",0) ))
			{
				Buffer_Append(bf," = ",3);
				Def_Format_Value(bf,val,flags,indent);
				has_dflt_val = 1;
			}
			if ( ((has_subitems = Def_Has_Xdef_Subitems(n))) || !has_name_val )
			{
				Buffer_Append(bf," {",2);
				if ( has_subitems ) 
				{
					Buffer_Fill_Append(bf,'\n',1);
					Def_Format_Node_In_Depth(bf,n,flags,indent+1);
					Buffer_Fill_Append(bf,' ',indent*C_XDEF_INDENT_WIDTH);
				}
				Buffer_Append(bf,"}\n",2);
			}
			else
				Buffer_Append(bf,"\n",1);
		}
	}
}
#endif
;

char *Def_Format_Into(C_BUFFER *bf, C_XNODE *r, int flags)
#ifdef _C_XDEF_BUILTIN
{
	int indent = (flags&0xff);
	if ( !bf ) bf = Buffer_Init(0);
	Def_Format_Node_In_Depth(bf,r,flags,indent);
	return (char*)bf->at;
}
#endif
;

char *Def_Format(C_XNODE *r, int flags)
#ifdef _C_XDEF_BUILTIN
{
	char *ret = 0;
	__Auto_Ptr(ret)
	{
		C_BUFFER *bf = Buffer_Init(0);
		Def_Format_Into(bf,r,flags);
		ret = Buffer_Take_Data(bf);
	}
	return ret;
}
#endif
;

void Def_Format_File(char *fname, C_XNODE *r, int flags)
#ifdef _C_XDEF_BUILTIN
{
	__Auto_Release
	{
		C_BUFFER *bf = Buffer_Init(0);
		Def_Format_Into(bf,r,flags);
		Oj_Write_Full(Cfile_Open(fname,"w+P"),bf->at,bf->count);
	}
}
#endif
;

#endif /* C_once_750A77B2_260B_4E33_B9EA_15F01DDD61FF */

