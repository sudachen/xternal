
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_9BC53BB4_C8E2_49F9_98D7_180BECC3819D
#define C_once_9BC53BB4_C8E2_49F9_98D7_180BECC3819D

#ifdef _BUILTIN
#define _C_OJ_BUILTIN
#endif

#include "C+.hc"
#include "array.hc"
#include "dicto.hc"
#include "buffer.hc"
#include "file.hc"

int Oj_Count(void *self)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_ARRAY_TYPEID )
		return Array_Count((C_ARRAY*)self);
	else if ( oj->dynamic->typeid == C_REF_DICTO_TYPEID )
		return Dicto_Count((C_DICTO*)self);
	else
	{
		int (*count)(void *) = C_Find_Method_Of(&self,Oj_Count_OjMID,C_RAISE_ERROR);
		return count(self);
	}
}
#endif
;

void Oj_Sort(void *self)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_ARRAY_TYPEID )
		Array_Sort((C_ARRAY*)self);
	else
	{
		void (*sort)(void *) = C_Find_Method_Of(&self,Oj_Sort_OjMID,C_RAISE_ERROR);
		sort(self);
	}
}
#endif
;

void Oj_Sorted_Insert(void *self, void *val)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_ARRAY_TYPEID )
		Array_Sorted_Insert((C_ARRAY*)self,__Refe(val));
	else
	{
		void (*insert)(void *, void *) = C_Find_Method_Of(&self,Oj_Sorted_Insert_OjMID,C_RAISE_ERROR);
		insert(self,__Refe(val));
	}
}
#endif
;

void *Oj_Sorted_Find(void *self, void *val)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_ARRAY_TYPEID )
		return Array_Binary_Find((C_ARRAY*)self,val);
	else
	{
		void *(*find)(void *, void *) = C_Find_Method_Of(&self,Oj_Sorted_Find_OjMID,C_RAISE_ERROR);
		return find(self,val);
	}
}
#endif
;

void Oj_Push(void *self, void *val)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_ARRAY_TYPEID )
		Array_Push((C_ARRAY*)self,__Refe(val));
	else
	{
		void (*push)(void *, void *) = C_Find_Method_Of(&self,Oj_Push_OjMID,C_RAISE_ERROR);
		push(self,__Refe(val));
	}
}
#endif
;

void *Oj_Pop(void *self)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_ARRAY_TYPEID )
		return Array_Pop((C_ARRAY*)self);
	else
	{
		void *(*pop)(void *) = C_Find_Method_Of(&self,Oj_Pop_OjMID,C_RAISE_ERROR);
		return pop(self);
	}
}
#endif
;

void Oj_Push_Front(void *self, void *val)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_ARRAY_TYPEID )
		Array_Push_Front((C_ARRAY*)self,__Refe(val));
	else
	{
		void (*push)(void *, void *) = C_Find_Method_Of(&self,Oj_Push_Front_OjMID,C_RAISE_ERROR);
		push(self,__Refe(val));
	}
}
#endif
;

void *Oj_Pop_Front(void *self)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_ARRAY_TYPEID )
		return Array_Pop_Front((C_ARRAY*)self);
	else
	{
		void *(*pop)(void *) = C_Find_Method_Of(&self,Oj_Pop_Front_OjMID,C_RAISE_ERROR);
		return pop(self);
	}
}
#endif
;

void *Oj_Remove(void *self, int index)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_ARRAY_TYPEID )
		return Array_Take((C_ARRAY*)self,index);
	else
	{
		void *(*take)(void *,int) = C_Find_Method_Of(&self,Oj_Remove_OjMID,C_RAISE_ERROR);
		return take(self,index);
	}
}
#endif
;

void Oj_Erase(void *self, int index, int count)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_ARRAY_TYPEID )
		Array_Del((C_ARRAY*)self,index,count);
	else
	{
		void *(*erase)(void *,int,int) = C_Find_Method_Of(&self,Oj_Erase_OjMID,C_RAISE_ERROR);
		erase(self,index,count);
	}
}
#endif
;

void Oj_Put(void *self, char *key, void *val)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_DICTO_TYPEID )
		Dicto_Put((C_DICTO*)self,key,__Refe(val));
	else
	{
		void (*put)(void *, char *, void *) = C_Find_Method_Of(&self,Oj_Put_OjMID,C_RAISE_ERROR);
		put(self,key,__Refe(val));
	}
}
#endif
;

void *Oj_Get(void *self, char *key, void *dflt)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_DICTO_TYPEID )
		return Dicto_Get((C_DICTO*)self,key,dflt);
	else
	{
		void *(*get)(void *, char *, void *) = C_Find_Method_Of(&self,Oj_Get_OjMID,C_RAISE_ERROR);
		return get(self,key,dflt);
	}
}
#endif
;

void *Oj_Take(void *self, char *key)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_ARRAY_TYPEID )
		return Dicto_Take((C_DICTO*)self,key);
	else
	{
		void *(*take)(void *,char *) = C_Find_Method_Of(&self,Oj_Take_OjMID,C_RAISE_ERROR);
		return take(self,key);
	}
}
#endif
;

void Oj_Del(void *self, char *key)
#ifdef _C_OJ_BUILTIN
{
	C_OBJECT *oj = Oj_Object_Or_Die(self);
	if ( oj->dynamic->typeid == C_REF_ARRAY_TYPEID )
		Dicto_Del((C_DICTO*)self,key);
	else
	{
		void (*del)(void *, char *) = C_Find_Method_Of(&self,Oj_Del_OjMID,C_RAISE_ERROR);
		del(self,key);
	}
}
#endif
;

__Inline void *Oj_Array() { return Array_Refs(); }
__Inline void *Oj_Dicto() { return Dicto_Refs(); }

/*
char *Oj_String(char *text)
#ifdef _C_OJ_BUILTIN
{
	;// create text object with refcount and ro file interface
}
#endif
;
*/

#endif /* C_once_9BC53BB4_C8E2_49F9_98D7_180BECC3819D */
