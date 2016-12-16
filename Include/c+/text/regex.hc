/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

/*

based on slre code https://code.google.com/p/slre/
written by Sergey Lyubka <valenok@gmail.com> 
has MIT license
forked at 18.07.2013

*/

#ifndef C_once_B119FD89_96A2_4EEC_88E8_BFFEDE65697F
#define C_once_B119FD89_96A2_4EEC_88E8_BFFEDE65697F

#include "../string.hc"
#include "../array.hc"

#ifdef _BUILTIN
#define _C_REGEX_BUILTIN
#endif

typedef struct C_REGEX
{
	byte_t code[256];
	byte_t data[256];
	int code_size;
	int data_size;
	int num_caps;   // Number of bracket pairs
	int anchored;   // Must match from string start
	int opts;
} C_REGEX;

typedef struct C_REGEX_PART 
{
	const char *subst;
	int len;
} C_REGEX_PART;

enum 
{
	C_REGEX_END, 
	C_REGEX_BRANCH, 
	C_REGEX_ANY, 
	C_REGEX_EXACT, 
	C_REGEX_ANYOF, 
	C_REGEX_ANYBUT, 
	C_REGEX_OPEN, 
	C_REGEX_CLOSE, 
	C_REGEX_BOL, 
	C_REGEX_EOL, 
	C_REGEX_STAR, 
	C_REGEX_PLUS,
	C_REGEX_STARQ, 
	C_REGEX_PLUSQ, 
	C_REGEX_QUEST, 
	C_REGEX_SPACE, 
	C_REGEX_NONSPACE, 
	C_REGEX_DIGIT,

	REGEX_CASE_INSENSITIVE = 1,
};

#ifdef _C_REGEX_BUILTIN
const char Regex_Meta_Characters[] = "|.^$*+?()[\\";
#endif

void Regex_Set_Jump(C_REGEX *r, int pc, int offset) 
{
	__Strict(offset < r->code_size);

	if ( r->code_size - offset > 0xff ) 
		__Raise(C_ERROR_LIMIT_REACHED,"Jump offset is too big");

	r->code[pc] = (byte_t) (r->code_size - offset);
}

void Regex_Emit(C_REGEX *r, int code) 
{
	__Strict( (uint_t)code <= 0x0ff );

	if ( r->code_size >= __Length_Of(r->code) )
		__Raise(C_ERROR_LIMIT_REACHED,"RE is too long (code overflow)");

	r->code[r->code_size++] = (byte_t)code;
}

void Regex_Store_Char_In_Data(C_REGEX *r, int ch) 
{
	__Strict( (uint_t)ch <= 0x0ff );

	if ( r->data_size >= iszof(r->data) )
		__Raise(C_ERROR_LIMIT_REACHED,"RE is too long (data overflow)");

	r->data[r->data_size++] = (byte_t)ch;
}

void Regex_Exact(C_REGEX *r, const char **re) 
{
	int old_data_size = r->data_size;

	while ( **re && !(strchr(Regex_Meta_Characters, **re)) ) 
		Regex_Store_Char_In_Data(r, *(*re)++);

	Regex_Emit(r, C_REGEX_EXACT);
	Regex_Emit(r, old_data_size);
	Regex_Emit(r, r->data_size - old_data_size);
}

int Regex_Get_Escape_Char(const char **re) 
{
	switch (*(*re)++) 
	{
	case 'n':  return '\n';
	case 'r':  return '\r';
	case 't':  return '\t';
	case '0':  return 0;
	case 'S':  return C_REGEX_NONSPACE << 8;
	case 's':  return C_REGEX_SPACE << 8;
	case 'd':  return C_REGEX_DIGIT << 8;
	}

	return (*re)[-1];
}

void Regex_Anyof(C_REGEX *r, const char **re) 
{
	int  esc, old_data_size = r->data_size, op = C_REGEX_ANYOF;

	if ( **re == '^' ) 
	{
		op = C_REGEX_ANYBUT;
		(*re)++;
	}

	while ( **re )
	{
		switch ( *(*re)++ ) 
		{
		case ']':
			Regex_Emit(r, op);
			Regex_Emit(r, old_data_size);
			Regex_Emit(r, r->data_size - old_data_size);
			return;
		case '\\':
			esc = Regex_Get_Escape_Char(re);
			if ( esc & 0xff ) 
				Regex_Store_Char_In_Data(r, esc);
			else
			{
				Regex_Store_Char_In_Data(r, 0);
				Regex_Store_Char_In_Data(r, esc >> 8);
			} 
			break;
		default:
			Regex_Store_Char_In_Data(r, (*re)[-1]);
		}
	}

	__Raise(C_ERROR_ILLFORMED,"No closing ']' bracket");
}

void Regex_Relocate(C_REGEX *r, int begin, int shift) 
{
	Regex_Emit(r, C_REGEX_END);
	memmove(r->code + begin + shift, r->code + begin, r->code_size - begin);
	r->code_size += shift;
}

void Regex_Quantifier(C_REGEX *r, int prev, int op) 
{
	if ( r->code[prev] == C_REGEX_EXACT && r->code[prev + 2] > 1 ) 
	{
		r->code[prev + 2]--;
		Regex_Emit(r, C_REGEX_EXACT);
		Regex_Emit(r, r->code[prev + 1] + r->code[prev + 2]);
		Regex_Emit(r, 1);
		prev = r->code_size - 3;
	}
	Regex_Relocate(r, prev, 2);
	r->code[prev] = op;
	Regex_Set_Jump(r, prev + 1, prev);
}

void Regex_Exact_One_Char(C_REGEX *r, int ch) 
{
	Regex_Emit(r, C_REGEX_EXACT);
	Regex_Emit(r, r->data_size);
	Regex_Emit(r, 1);
	Regex_Store_Char_In_Data(r, ch);
}

void Regex_Fixup_Branch(C_REGEX *r, int fixup) 
{
	if ( fixup > 0 ) 
	{
		Regex_Emit(r, C_REGEX_END);
		Regex_Set_Jump(r, fixup, fixup - 2);
	}
}

void Regex_Compile_Inner(C_REGEX *r, const char **re) 
{
	int  op, esc, branch_start, last_op, fixup, cap_no, level;

	fixup = 0;
	level = r->num_caps;
	branch_start = last_op = r->code_size;

	for (;;)
		switch ( *(*re)++ ) 
		{
		case '\0':
			(*re)--;
			return;
		case '^':
			Regex_Emit(r, C_REGEX_BOL);
			break;
		case '$':
			Regex_Emit(r, C_REGEX_EOL);
			break;
		case '.':
			last_op = r->code_size;
			Regex_Emit(r, C_REGEX_ANY);
			break;
		case '[':
			last_op = r->code_size;
			Regex_Anyof(r, re);
			break;
		case '\\':
			last_op = r->code_size;
			esc = Regex_Get_Escape_Char(re);
			if (esc & 0xff00)
				Regex_Emit(r, esc >> 8);
			else
				Regex_Exact_One_Char(r, esc);
			break;
		case '(':
			last_op = r->code_size;
			cap_no = ++r->num_caps;
			Regex_Emit(r, C_REGEX_OPEN);
			Regex_Emit(r, cap_no);
			Regex_Compile_Inner(r, re);
			if ( *(*re)++ != ')' ) 
				__Raise(C_ERROR_ILLFORMED,"No closing bracket");
			Regex_Emit(r, C_REGEX_CLOSE);
			Regex_Emit(r, cap_no);
			break;
		case ')':
			(*re)--;
			Regex_Fixup_Branch(r, fixup);
			if (level == 0)
				__Raise(C_ERROR_ILLFORMED,"Unbalanced brackets");
			return;
		case '+':
		case '*':
			op = (*re)[-1] == '*' ? C_REGEX_STAR: C_REGEX_PLUS;
			if (**re == '?') 
			{
				(*re)++;
				op = op == C_REGEX_STAR ? C_REGEX_STARQ : C_REGEX_PLUSQ;
			}
			Regex_Quantifier(r, last_op, op);
			break;
		case '?':
			Regex_Quantifier(r, last_op, C_REGEX_QUEST);
			break;
		case '|':
			Regex_Fixup_Branch(r, fixup);
			Regex_Relocate(r, branch_start, 3);
			r->code[branch_start] = C_REGEX_BRANCH;
			Regex_Set_Jump(r, branch_start + 1, branch_start);
			fixup = branch_start + 2;
			r->code[fixup] = 0xff;
			break;
		default:
			(*re)--;
			last_op = r->code_size;
			Regex_Exact(r, re);
			break;
		}
}

C_REGEX *Regex_Compile(C_REGEX *r, const char *re) 
{
	if ( !r ) 
		r = __Object_Dtor(sizeof(C_REGEX),__Object_Destruct);
	
	r->code_size = r->data_size = r->num_caps = r->anchored = 0;

	if ( *re == '^' )
		r->anchored++;

	Regex_Emit(r, C_REGEX_OPEN);  // This will capture what matches full RE
	Regex_Emit(r, 0);

	while ( *re ) 
	{
		Regex_Compile_Inner(r, &re);
	}

	if ( r->code[2] == C_REGEX_BRANCH )
		Regex_Fixup_Branch(r, 4);

	Regex_Emit(r, C_REGEX_CLOSE);
	Regex_Emit(r, 0);
	Regex_Emit(r, C_REGEX_END);
	
	return r;
}

int Regex_Match_Inner(C_REGEX *, 
	int, const char *, int, int *,
    C_REGEX_PART *, int caps_size);

void Regex_Loop_Greedy(
	C_REGEX *r, 
	int pc, 
	const char *s, int len,
	int *ofs) 
{
	int saved_offset, matched_offset;
	saved_offset = matched_offset = *ofs;

	while ( Regex_Match_Inner(r, pc + 2, s, len, ofs, NULL, 0) ) 
	{
		saved_offset = *ofs;
		if ( Regex_Match_Inner(r, pc + r->code[pc + 1], s, len, ofs, NULL, 0) ) 
			matched_offset = saved_offset;
		*ofs = saved_offset;
	}

	*ofs = matched_offset;
}

void Regex_Loop_Non_Greedy(
	C_REGEX *r, 
	int pc, 
	const char *s, int len, 
	int *ofs) 
{
	int  saved_offset = *ofs;

	while ( Regex_Match_Inner(r, pc + 2, s, len, ofs, NULL, 0) ) 
	{
		saved_offset = *ofs;
		if ( Regex_Match_Inner(r, pc + r->code[pc + 1], s, len, ofs, NULL, 0) )
			break;
	}

	*ofs = saved_offset;
}

int Regex_Is_Any_Of(const byte_t *p, int len, const char *s, int *ofs) 
{
	int  i, ch;
	ch = s[*ofs];

	for ( i = 0; i < len; ++i )
		if ( p[i] == ch ) 
		{
			(*ofs)++;
			return 1;
		}

	return 0;
}

int Regex_Is_Any_But(const byte_t *p, int len, const char *s, int *ofs) 
{
	int  i, ch;
	ch = s[*ofs];

	for ( i = 0; i < len; ++i )
		if ( p[i] == ch ) 
			return 0;

	(*ofs)++;
	return 1;
}

int Regex_Casecmp(const void *p1, const void *p2, size_t len) 
{
	const char *s1 = p1, *s2 = p2;
	int diff = 0;

	if (len > 0)
		do 
		{
			diff = Tolower(*s1++) - Tolower(*s2++);
		} while (diff == 0 && s1[-1] != '\0' && --len > 0);

	return diff;
}

int Regex_Match_Inner(
	C_REGEX *r, 
	int pc, 
	const char *s, int len,
	int *ofs, 
	C_REGEX_PART *caps, int caps_size) 
{
	int n, saved_offset, succeeded = 1;
	int (*cmp)(const void *, const void *, size_t len);

	while (succeeded && r->code[pc] != C_REGEX_END) {

		__Strict( pc < r->code_size );
		__Strict( pc < __Length_Of(r->code) );

		switch ( r->code[pc] ) 
		{
		case C_REGEX_BRANCH:
			saved_offset = *ofs;
			succeeded = Regex_Match_Inner(
							r, pc + 3, s, len, ofs, caps, caps_size);
			if ( !succeeded )
			{
				*ofs = saved_offset;
				succeeded = Regex_Match_Inner(
							r, pc + r->code[pc + 1], s, len, ofs, caps,
							caps_size);
			}
			pc += r->code[pc + 2];
			break;
		case C_REGEX_EXACT:
			succeeded = 0;
			n = r->code[pc + 2];  // String length
			cmp = r->opts & REGEX_CASE_INSENSITIVE ? Regex_Casecmp : memcmp;
			if ( n <= len - *ofs 
			  && !cmp(s + *ofs, r->data + r->code[pc + 1], n) ) 
			{
				(*ofs) += n;
				succeeded = 1;
			}
			pc += 3;
			break;
		case C_REGEX_QUEST:
			succeeded = 1;
			saved_offset = *ofs;
			if ( !Regex_Match_Inner(r, pc + 2, s, len, ofs, caps, caps_size) ) 
				*ofs = saved_offset;
			pc += r->code[pc + 1];
			break;
		case C_REGEX_STAR:
			succeeded = 1;
			Regex_Loop_Greedy(r, pc, s, len, ofs);
			pc += r->code[pc + 1];
			break;
		case C_REGEX_STARQ:
			succeeded = 1;
			Regex_Loop_Non_Greedy(r, pc, s, len, ofs);
			pc += r->code[pc + 1];
			break;
		case C_REGEX_PLUS:
			succeeded = Regex_Match_Inner(
							r, pc + 2, s, len, ofs, caps, caps_size);			
			if (!succeeded)
				break;
			Regex_Loop_Greedy(r, pc, s, len, ofs);
			pc += r->code[pc + 1];
			break;
		case C_REGEX_PLUSQ:
			succeeded = Regex_Match_Inner(
							r, pc + 2, s, len, ofs, caps, caps_size);			
			if (!succeeded)
				break;
			Regex_Loop_Non_Greedy(r, pc, s, len, ofs);
			pc += r->code[pc + 1];
			break;
		case C_REGEX_SPACE:
			succeeded = 0;
			if ( *ofs < len && Isspace(s[*ofs])) 
			{
				(*ofs)++;
				succeeded = 1;
			}
			pc++;
			break;
		case C_REGEX_NONSPACE:
			succeeded = 0;
			if ( *ofs <len && !Isspace(s[*ofs]) ) 
			{
				(*ofs)++;
				succeeded = 1;
			}
			pc++;
			break;
		case C_REGEX_DIGIT:
			succeeded = 0;
			if ( *ofs < len && Isdigit(s[*ofs]) ) 
			{
				(*ofs)++;
				succeeded = 1;
			}
			pc++;
			break;
		case C_REGEX_ANY:
			succeeded = 0;
			if ( *ofs < len ) 
			{
				(*ofs)++;
				succeeded = 1;
			}
			pc++;
			break;
		case C_REGEX_ANYOF:
			succeeded = 0;
			if ( *ofs < len )
				succeeded = Regex_Is_Any_Of(
								r->data + r->code[pc + 1], r->code[pc + 2],
								s, ofs);
			pc += 3;
			break;
		case C_REGEX_ANYBUT:
			succeeded = 0;
			if ( *ofs < len )
				succeeded = Regex_Is_Any_But(
								r->data + r->code[pc + 1], r->code[pc + 2],
								s, ofs);
			pc += 3;
			break;
		case C_REGEX_BOL:
			succeeded = *ofs == 0;
			pc++;
			break;
		case C_REGEX_EOL:
			succeeded = *ofs == len;
			pc++;
			break;
		case C_REGEX_OPEN:
			if ( caps ) 
			{
				if ( caps_size - 2 < r->code[pc + 1] )
					__Raise(C_ERROR_LIMIT_REACHED,"Too many brackets");
				else
					caps[r->code[pc + 1]].subst = s + *ofs;
			}
			pc += 2;
			break;
		case C_REGEX_CLOSE:
			if ( caps ) 
			{
				__Strict( r->code[pc + 1] >= 0 );
				__Strict( r->code[pc + 1] < caps_size );
				caps[r->code[pc + 1]].len = 
							(s + *ofs) - caps[r->code[pc + 1]].subst;
			}
			pc += 2;
			break;
		case C_REGEX_END:
			pc++;
			break;
		default:
			__Strict_Unreachable();
		}
	}

	return succeeded;
}

C_ARRAY *Regex_Match(C_REGEX *r, const char *text, int *match_ofs)
{
	C_ARRAY *R = 0;
	C_REGEX_PART caps[64] = {0};
	int ofs = 0, ofsS = 0, text_len, i, match_len;
	
	text_len = Str_Length(text);
	
	if (text_len) __Auto_Ptr(R)
	{
		if ( r->anchored )
		{
			if ( Regex_Match_Inner(r,0,text,text_len,&ofs,caps,__Length_Of(caps)) )
			{
		matched:
				match_len = ofs - ofsS;
				__Strict( match_len + ofsS <= text_len );
				R = Array_Pchars();
				Array_Push( R, Str_Copy_Npl(text+ofsS,match_len) );
				for ( i = 0; i < r->num_caps; ++i )
					Array_Push( R, Str_Copy_Npl(caps[i+1].subst,caps[i+1].len) );
				if ( match_ofs ) *match_ofs = ofsS;
			}
		}
		else
		{
			for ( i = 0; i < text_len; ++i )
			{
				ofs = ofsS = i;
				if ( Regex_Match_Inner(r,0,text,text_len,&ofs,caps,__Length_Of(caps)) )
					goto matched;
			}
		}
	}

	return R;
}

const char *Regex_Search(C_REGEX *r, const char *text, int *match_len)
{
	const char *R;
	C_REGEX_PART caps[64] = {0};
	int ofs = 0, ofsS = 0, text_len, i;
	
	text_len = Str_Length(text);
	
	if (text_len)
	{
		if ( r->anchored )
		{
			if ( Regex_Match_Inner(r,0,text,text_len,&ofs,caps,__Length_Of(caps)) )
			{
		matched:
				__Strict( ofs <= text_len );
				R = text+ofsS;
				if ( match_len ) *match_len = ofs-ofsS;
			}
		}
		else
		{
			for ( i = 0; i < text_len; ++i )
			{
				ofs = ofsS = i;
				if ( Regex_Match_Inner(r,0,text,text_len,&ofs,caps,__Length_Of(caps)) )
					goto matched;
			}
		}
	}
	return R;
}

C_ARRAY *Re_Match(const char *re, const char *text, int *ofs)
{
	C_REGEX r;
	Regex_Compile(&r,re);
	return Regex_Match(&r,text,ofs);
}

const char *Re_Search(const char *re, const char *text, int *ofs)
{
	C_REGEX r;
	Regex_Compile(&r,re);
	return Regex_Search(&r,text,ofs);
}

#endif /*C_once_B119FD89_96A2_4EEC_88E8_BFFEDE65697F*/
