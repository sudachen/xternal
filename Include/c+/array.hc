
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/


#ifndef C_once_44A7F9A5_269A_48D5_AABB_F08291F9087B
#define C_once_44A7F9A5_269A_48D5_AABB_F08291F9087B

#ifdef _BUILTIN
#define _C_ARRAY_BUILTIN
#endif

#include "C+.hc"

enum { C_REF_ARRAY_TYPEID = 0xa463 };

#ifdef _C_ARRAY_BUILTIN
# define _C_ARRAY_BUILTIN_CODE(Code) Code
# define _C_ARRAY_EXTERN 
#else
# define _C_ARRAY_BUILTIN_CODE(Code)
# define _C_ARRAY_EXTERN extern 
#endif

void *Lower_Boundary(void **S, int S_len, void *compare, void *val, int *found)
#ifdef _C_ARRAY_BUILTIN
{
	typedef int (*Tcmp)(void *,void*);
	int cmp_r = 0;
	void **iS = S;
	void **middle = iS;
	int half;
	int len = S_len;

	if ( len  )
	{
		while (len > 0)
		{
			half = len >> 1;
			middle = iS + half;
			if ( (cmp_r = ((Tcmp)compare)(*middle,val)) < 0 )
			{
				iS = middle;
				++iS;
				len = len - half - 1;
			}
			else
				len = half;
		}

		if ( middle != iS && iS < S+S_len )
		{
			cmp_r = ((Tcmp)compare)(*iS,val);
		}
	}

	*found = !cmp_r;
	return iS;
}
#endif
;

typedef struct _C_ARRAY
{
	void **at;
	int count;
	int capacity;
} C_ARRAY;

void Array_Del(C_ARRAY *a,int pos,int n)
#ifdef _C_ARRAY_BUILTIN
{
	int i;
	void *self = a;
	void (*destruct)(void *) = C_Find_Method_Of(&self,Oj_Destruct_Element_OjMID,0);

	if ( pos < 0 ) pos = a->count + pos;
	if ( n < 0 || pos + n > a->count ) n = a->count-pos;
	if ( pos < 0 || pos+n > a->count ) 
		C_Raise(C_ERROR_OUT_OF_RANGE,0,__C_FILE__,__LINE__);

	if ( destruct )
		for ( i = 0; i < n; ++i )
			destruct((a->at)[i+pos]);

	if ( pos != a->count-n )
		memmove(a->at+pos,a->at+(pos+n),(a->count-(pos+n))*sizeof(void*));
	a->count -= n;
}
#endif
;

void *Array_Take_Npl(C_ARRAY *a,int pos)
#ifdef _C_ARRAY_BUILTIN
{
	void *Q = 0;

	if ( pos < 0 ) pos = a->count + pos;
	if ( pos < 0 || pos >= a->count ) 
		C_Raise(C_ERROR_OUT_OF_RANGE,0,__C_FILE__,__LINE__);

	Q = (a->at)[pos];

	if ( pos != a->count-1 )
		memmove(a->at+pos,a->at+(pos+1),(a->count-(pos+1))*sizeof(void*));
	a->count -= 1;

	return Q;
}
#endif
;

void *Array_Take(C_ARRAY *a,int pos)
#ifdef _C_ARRAY_BUILTIN
{
	void *self = a;
	void (*destruct)(void *) = C_Find_Method_Of(&self,Oj_Destruct_Element_OjMID,C_RAISE_ERROR);
	void *Q = Array_Take_Npl(a,pos);

	if ( Q )
		__Pool_Ptr(Q,destruct);

	return Q;
}
#endif
;

void Array_Grow(C_ARRAY *a,int require)
#ifdef _C_ARRAY_BUILTIN
{
	int capacity = Min_Pow2(require*sizeof(void*));
	if ( !a->at || a->capacity < capacity )
	{
		a->at = __Realloc_Npl(a->at,capacity);
		a->capacity = capacity;
	}
}
#endif
;

void Array_Resize(C_ARRAY *a,int count)
#ifdef _C_ARRAY_BUILTIN
{
	if ( !a->at || a->count < count )
	{
		int capacity = count*sizeof(void*);
		if ( !a->at || a->capacity < capacity )
		{
			a->at = __Realloc_Npl(a->at,capacity);
			a->capacity = capacity;
		}
		memset(a->at+a->count,0,sizeof(void*)*(count-a->count));
		a->count = count;
	}
	else if ( a->count > count ) 
	{
		int i = 0;
		void *self = a;
		void (*destructor)(void *) = C_Find_Method_Of(&self,Oj_Destruct_Element_OjMID,0);
		if ( destructor )
		{
			for ( i = count; i < a->count; ++i )
			{	
				destructor(a->at[i]);
				a->at[i] = 0;
			}
		}
		a->count = count;
	}
}
#endif
;

void Array_Insert(C_ARRAY *a,int pos,void *p)
#ifdef _C_ARRAY_BUILTIN
{
	if ( pos < 0 ) pos = a->count + pos + 1;
	if ( pos < 0 || pos > a->count ) 
	{
		void *self = a;
		void (*destruct)(void *) = C_Find_Method_Of(&self,Oj_Destruct_Element_OjMID,0);
		if ( destruct ) destruct(p);
		C_Raise(C_ERROR_OUT_OF_RANGE,0,__C_FILE__,__LINE__);
	}

	Array_Grow(a,a->count+1);
	if ( pos < a->count )
		memmove(a->at+pos+1,a->at+pos,(a->count-pos)*sizeof(void*));
	a->at[pos] = p;
	++a->count;
}
#endif
;

void Array_Fill(C_ARRAY *a,int pos,void *p, int count)
#ifdef _C_ARRAY_BUILTIN
{
	int i;

	if ( !count ) return;
	else if ( count < 0 || pos < 0 ) 
		C_Raise(C_ERROR_INVALID_PARAM,0,__C_FILE__,__LINE__);

	if ( !a->at || a->count-pos < count )
	{
		Array_Grow(a,a->count-pos+count);
		memset(a->at+pos,0,sizeof(void*)*count);
		a->count = a->count-pos+count;
	}

	for ( i = 0; i < count; ++i ) 
	{
		if ( a->at[pos+i] )
		{
			void *self = a;
			void (*destruct)(void *) = C_Find_Method_Of(&self,Oj_Destruct_Element_OjMID,0);
			if ( destruct ) destruct(a->at[pos+i]);
		}
		a->at[pos+i] = p;
	}
}
#endif
;

void Array_Set(C_ARRAY *a,int pos,void *val)
#ifdef _C_ARRAY_BUILTIN
{
	void *self = a;
	void (*destruct)(void *) = C_Find_Method_Of(&self,Oj_Destruct_Element_OjMID,0);

	if ( pos < 0 ) pos = a->count + pos;
	if ( pos < 0 || pos >= a->count ) 
	{
		if ( destruct ) destruct(val);
		__Raise(C_ERROR_OUT_OF_RANGE,0);
	}

	if ( destruct )
		destruct((a->at)[pos]);

	a->at[pos] = val;
}
#endif
;

int Array_Sorted_Lower_Boundary(C_ARRAY *a,void *val,int *found,int except)
#ifdef _C_ARRAY_BUILTIN
{
	void *self = a;
	int (*compare)(void *, void *);

	if ( !a->count ) 
	{
		*found = 0;
		return 0;
	}

	if ( 0 != (compare = C_Find_Method_Of(&self,Oj_Compare_Elements_OjMID,0)) )
	{
		void **p = Lower_Boundary(a->at,a->count,compare,val,found);
		return p - a->at;
	}
	else if (except)
		__Raise(C_ERROR_UNSORTABLE,"array is unsortable");
	else
		return -1;

	return 0;
}
#endif
;

void Array_Sorted_Insert(C_ARRAY *a,void *p)
#ifdef _C_ARRAY_BUILTIN
{
	if ( !a->count )
		Array_Insert(a,-1,p);
	else
	{
		int found = 0;
		int pos ;

		pos = Array_Sorted_Lower_Boundary(a,p,&found,0);

		if ( pos < 0 )
		{
			void *self = a;
			void (*destructor)(void *) = C_Find_Method_Of(&self,Oj_Destruct_Element_OjMID,0);
			if ( destructor )
				destructor(p);
			__Raise(C_ERROR_UNSORTABLE,"array is unsortable");
		}

		if ( !found )
			Array_Insert(a,pos,p);
		else
			Array_Set(a,pos,p);
	}
}
#endif
;

void *Array_Binary_Find(C_ARRAY *a, void *p)
#ifdef _C_ARRAY_BUILTIN
{
	int found = 0;
	int pos = Array_Sorted_Lower_Boundary(a,p,&found,1);
	return found ? a->at[pos] : 0;
}
#endif
;

#ifdef _C_ARRAY_BUILTIN
int Array_Sort_Qsort_Compare(int (*compare)(void *a,void *b), void **a, void **b)
{
	return compare(*a,*b);
}
int (*Array_Sort_Qsort_Compare_Static_Compare)(void *a,void *b) = 0;
int Array_Sort_Qsort_Compare_Static(void **a, void **b)
{
	return Array_Sort_Qsort_Compare_Static_Compare(*a,*b);
}
#endif

void Array_Sort(C_ARRAY *a)
#ifdef _C_ARRAY_BUILTIN
{
	void *self = a;
	void *compare;
	if ( a->at && a->count )
	{
		if ( 0 != (compare = C_Find_Method_Of(&self,Oj_Compare_Elements_OjMID,0)) )
		{
#if defined __windoze && _MSC_VER > 1400 
			qsort_s(a->at,a->count,sizeof(void*)
				,compare
				,(void*)Array_Sort_Qsort_Compare);
#elif defined __APPLE__
			qsort_r(a->at,a->count,sizeof(void*)
				,compare
				,(void*)Array_Sort_Qsort_Compare);
#else /* use global variable */
			__Xchg_Interlock
			{
				Array_Sort_Qsort_Compare_Static_Compare = compare;
				qsort(a->at,a->count,sizeof(void*)
					,(void*)Array_Sort_Qsort_Compare_Static);
			}
#endif
		}
		else
			__Raise(C_ERROR_UNSORTABLE,"array is unsortable");
	}
}
#endif
;

#define Array_COUNT(Arr)          ((int)((C_ARRAY *)(Arr))->count+0)
#define Array_BEGIN(Arr)          (((C_ARRAY *)(Arr))->at)
#define Array_END(Arr)            (Array_BEGIN(Arr)+Array_COUNT(Arr))
#define Array_AT(Arr,Idx)         ((((C_ARRAY *)(Arr))->at)[Idx])
#define Array_Push(Arr,Val)       Array_Insert(Arr,-1,Val)
#define Array_Pop(Arr)            Array_Take(Arr,-1)
#define Array_Pop_Npl(Arr)        Array_Take_Npl(Arr,-1)
#define Array_Push_Front(Arr,Val) Array_Insert(Arr,0,Val)
#define Array_Pop_Front(Arr)      Array_Take(Arr,0)
#define Array_Pop_Front_Npl(Arr)  Array_Take_Npl(Arr,0)

void Array_Push_Oj(C_ARRAY *a, void *val)
#ifdef _C_ARRAY_BUILTIN
{
	Array_Push(a,val);
}
#endif
;

void *Array_Pop_Oj(C_ARRAY *a)
#ifdef _C_ARRAY_BUILTIN
{
	return Array_Pop(a);
}
#endif
;

void *Array_Pop_Npl_Oj(C_ARRAY *a)
#ifdef _C_ARRAY_BUILTIN
{
	return Array_Pop_Npl(a);
}
#endif
;

void Array_Push_Front_Oj(C_ARRAY *a, void *val)
#ifdef _C_ARRAY_BUILTIN
{
	Array_Push_Front(a,val);
}
#endif
;

void *Array_Pop_Front_Oj(C_ARRAY *a)
#ifdef _C_ARRAY_BUILTIN
{
	return Array_Pop_Front(a);
}
#endif
;

void *Array_Pop_Front_Npl_Oj(C_ARRAY *a)
#ifdef _C_ARRAY_BUILTIN
{
	return Array_Pop_Front_Npl(a);
}
#endif
;

int Array_Count(C_ARRAY *a)
#ifdef _C_ARRAY_BUILTIN
{
	if ( a )
		return Array_COUNT(a);
	return 0;
}
#endif
;

void *Array_Begin(C_ARRAY *a)
#ifdef _C_ARRAY_BUILTIN
{
	if ( a )
		return Array_BEGIN(a);
	return 0;
}
#endif
;

void *Array_End(C_ARRAY *a)
#ifdef _C_ARRAY_BUILTIN
{
	if ( a )
		return Array_END(a);
	return 0;
}
#endif
;

void *Array_At(C_ARRAY *a,int pos)
#ifdef _C_ARRAY_BUILTIN
{
	if ( a )
	{
		if ( pos < 0 ) pos = a->count + pos;
		if ( pos < 0 || pos >= a->count ) 
			C_Raise(C_ERROR_OUT_OF_RANGE,0,__C_FILE__,__LINE__);
		return Array_AT(a,pos);
	}
	return 0;
}
#endif
;

void Array_Destruct(C_ARRAY *a)
#ifdef _C_ARRAY_BUILTIN
{
	int i = 0;
	void *self = a;
	void (*destructor)(void *) = C_Find_Method_Of(&self,Oj_Destruct_Element_OjMID,0);
	if ( destructor )
		for ( i = 0; i < a->count; ++i )
			if ( a->at[i] ) 
				destructor(a->at[i]);
	if ( a->at )
		free(a->at);
	__Destruct(a);
}
#endif
;

void Array_Clear(C_ARRAY *a)
#ifdef _C_ARRAY_BUILTIN
{
	int i = 0;
	void *self = a;
	void (*destructor)(void *) = C_Find_Method_Of(&self,Oj_Destruct_Element_OjMID,0);
	if ( destructor )
		for ( i = 0; i < a->count; ++i )
			destructor(a->at[i]);
	if ( a->at )
		memset(a->at,0,a->count*sizeof(a->at[0]));
	a->count = 0;
}
#endif
;

#define Array_Init() Array_Void()
void *Array_Void(void)
#ifdef _C_ARRAY_BUILTIN
{
	static C_FUNCTABLE funcs[] = 
	{ {0},
	{Oj_Destruct_OjMID,         Array_Destruct},
	{Oj_Count_OjMID,            Array_Count},
	{0}};
	C_ARRAY *arr = __Object(sizeof(C_ARRAY),funcs);
	return arr;
}
#endif
;

void *Array_Refs(void)
#ifdef _C_ARRAY_BUILTIN
{
	static C_FUNCTABLE funcs[] = 
    { {0,(void*)C_REF_ARRAY_TYPEID},
	{Oj_Destruct_OjMID,         Array_Destruct},
	{Oj_Destruct_Element_OjMID, __Unrefe},
	{Oj_Count_OjMID,            Array_Count},
    {0,}};
	C_ARRAY *arr = __Object(sizeof(C_ARRAY),funcs);
	return arr;
}
#endif
;

void *Array_Refs_Copy(void *refs, int count)
#ifdef _C_ARRAY_BUILTIN
{
	C_ARRAY *arr = Array_Refs();
	int i;
	Array_Fill(arr,0,0,count);
	for ( i = 0; i < count; ++i )
		arr->at[i] = __Refe(((void**)refs)[i]);
	return arr;
}
#endif
;

void *Array_Ptrs(void)
#ifdef _C_ARRAY_BUILTIN
{
	static C_FUNCTABLE funcs[] = 
	{ {0},
	{Oj_Destruct_OjMID,         Array_Destruct},
	{Oj_Destruct_Element_OjMID, free},
	{Oj_Count_OjMID,            Array_Count},
	{0}};
	C_ARRAY *arr = __Object(sizeof(C_ARRAY),funcs);
	return arr;
}
#endif
;

void *Array_Pchars(void)
#ifdef _C_ARRAY_BUILTIN
{
	static C_FUNCTABLE funcs[] = 
	{ {0},
	{Oj_Destruct_OjMID,         Array_Destruct},
	{Oj_Destruct_Element_OjMID, free},
	{Oj_Compare_Elements_OjMID, strcmp},
	{Oj_Count_OjMID,            Array_Count},
	{0}};
	C_ARRAY *arr = __Object(sizeof(C_ARRAY),funcs);
	return arr;
}
#endif
;

#ifdef _C_ARRAY_BUILTIN
int __wcscmp(void *a, void *b) { return wcscmp(a,b); }
#endif

void *Array_Pwide(void)
#ifdef _C_ARRAY_BUILTIN
{
	static C_FUNCTABLE funcs[] = 
	{ {0,0},
	{Oj_Destruct_OjMID,         Array_Destruct},
	{Oj_Destruct_Element_OjMID, free},
	{Oj_Compare_Elements_OjMID, __wcscmp},
	{Oj_Sort_OjMID,             Array_Sort},
	{Oj_Count_OjMID,            Array_Count},
	{0}};
	C_ARRAY *arr = __Object(sizeof(C_ARRAY),funcs);
	return arr;
}
#endif
;

void *Array_Take_Data_Npl(C_ARRAY *a)
#ifdef _C_ARRAY_BUILTIN
{
	void *p = a->at;
	a->at = 0;
	a->capacity = a->count = 0;
	return p;
}
#endif
;

#endif /* C_once_44A7F9A5_269A_48D5_AABB_F08291F9087B */

