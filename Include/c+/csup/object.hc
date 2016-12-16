
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

Dynamic Object Model.

__Object, __Object_Dtor, __Destruct
__Refe, __Unrefe

is included by C+.hc

*/

void *C_Find_Method_Of(void *self /* VOID**  */, uptrword_t ojmid, unsigned flags);

enum {
    OJ_DEFAULT_GROUP = 0,

    /* zero ID is unused because it represents end of table */

    /* object destructor */
    Oj_Destruct_OjMID,

    /* element destructor (is used by containers) */
    Oj_Destruct_Element_OjMID,

    /* compare contained elements (is used by containers) */
    Oj_Compare_Elements_OjMID,

    /* compare contained keys (is used by containers) */
    Oj_Compare_Keys_OjMID,

    /* clone object */
    Oj_Clone_OjMID,

    /* count contained elements */
    Oj_Count_OjMID,

    /* put element into container */
    Oj_Put_OjMID,

    /* get element contained element */
    Oj_Get_OjMID,

    /* check for element existance in container */
    Oj_Has_OjMID,

    /* delete element from container */
    Oj_Del_OjMID,

    /* get contained element and remove it from container */
    Oj_Take_OjMID,

    /* sort contained elements */
    Oj_Sort_OjMID,

    /* push element to end of contained elements list */
    Oj_Push_OjMID,

    /* pop element from the end of contained elements list */
    Oj_Pop_OjMID,

    /* ordered insert element into contained elements list */
    Oj_Sorted_Insert_OjMID,

    /* binary search in contened elements list */
    Oj_Sorted_Find_OjMID,

    /* push element into the begin of contained elements list */
    Oj_Push_Front_OjMID,

    /* pop element from the begin of contained elements list */
    Oj_Pop_Front_OjMID,

    /* delete contained element by specified index */
    Oj_Erase_OjMID,

    /* delete contained elements from specified index */
    Oj_Remove_OjMID,
};

typedef struct _C_FUNCTABLE
{
    uptrword_t ojmid;
    void      *func;
} C_FUNCTABLE;

typedef struct _C_CORE_DYNAMIC
{
    /* struct can be represented in
       the first record of C_FUNCTION table */
    uptrword_t contsig;
    uptrword_t typeid;  /* in this case it is the func field
                           of the first record */
    /* the table should be finalized by zero record */
    C_FUNCTABLE funcs[1];
}
C_DYNAMIC;

typedef struct _C_CORE_OBJECT
{
    uint_t signature; /* C_OBJECT_SIGNATURE */
    uint_t rc;
    C_DYNAMIC *dynamic;
}
C_OBJECT;

#define C_BASE(Ptr)          ((C_OBJECT*)(Ptr) - 1)
#define C_RC(Ptr)            (C_BASE(Ptr)->rc)
#define C_SIGNAT(Ptr)        (C_BASE(Ptr)->signature)
#define C_SIGNAT_IS_OK(Ptr)  ((C_BASE(Ptr)->signature&0x00ffffff) == C_OBJECT_SIGNATURE_PFX)

void *__Refe(void *p)
#ifdef _C_CORE_BUILTIN
{
    if ( p && STRICT_CHECK(C_SIGNAT_IS_OK(p)) )
        __Atomic_Increment(&C_RC(p));
    return p;
}
#endif
;

void __Object_Destruct(void *ptr);
void *__Unrefe(void *p)
#ifdef _C_CORE_BUILTIN
{
    if ( p && STRICT_CHECK(C_SIGNAT_IS_OK(p))
         && !(__Atomic_Decrement(&C_RC(p))&0x7fffff) )
    {
        void (*destruct)(void *) = C_Find_Method_Of(&p,Oj_Destruct_OjMID,0);
        if ( !destruct )
            __Object_Destruct(p);
        else
            destruct(p);
        return 0;
    }
    return p;
}
#endif
;

#ifdef _C_CORE_BUILTIN
uint_t __Typeid_Counter = 0x0ffff;
#endif

#ifdef _C_CORE_BUILTIN
void **__Mempool_Blocks = 0;
void *__Mempool_Slots[C_MEMPOOL_SLOTS_COUNT] = {0,};
int __Mempool_Counts[C_MEMPOOL_SLOTS_COUNT] = {0,};
int __Mempool_Spinlock[C_MEMPOOL_SLOTS_COUNT] = {0,};
#endif

void __Mempool_Free(void *p,int plidx)
#ifdef _C_CORE_BUILTIN
{
    void **Q = p;
    STRICT_REQUIRE(plidx >= 0 && plidx <C_MEMPOOL_SLOTS_COUNT);
    __Gogo
    {
        void * volatile *S = __Mempool_Slots+plidx;
        int volatile *l = __Mempool_Spinlock+plidx;
        while ( !__Atomic_CmpXchg(l,1,0) ) { Switch_to_Thread(); }
        __RwBarrier();
        *Q = *S;
        *S = Q;
        __Atomic_Decrement(l);
    }
}
#endif
;

#ifdef _C_CORE_BUILTIN
void ___Mempool_Extend(int plidx)
{
    void **S = __Mempool_Slots+plidx;
    int i,piece = (plidx+1)*C_MEMPOOL_PIECE_STEP;
    void **Q = __Malloc_Npl(piece*C_MEMPOOL_PIECE_ON_BLOCK);
    void **R = __Malloc_Npl(sizeof(void*)*2);
    R[1] = Q;
    R[0] = __Mempool_Blocks;
    __Mempool_Blocks = R;
    __Mempool_Counts[plidx] += C_MEMPOOL_PIECE_ON_BLOCK;
    for ( i=0; i < C_MEMPOOL_PIECE_ON_BLOCK; ++i, Q = (void**)((byte_t*)Q + piece) )
    {
        *Q = *S;
        *S = Q;
    }
}
#endif
;

void *__Mempool_Zalloc(int plidx)
#ifdef _C_CORE_BUILTIN
{
    void **Q;
    STRICT_REQUIRE(plidx >= 0 && plidx <C_MEMPOOL_SLOTS_COUNT);
    __Gogo
    {
        void * volatile *S = __Mempool_Slots+plidx;
        int volatile *l = __Mempool_Spinlock+plidx;
        while ( !__Atomic_CmpXchg(l,1,0) ) { Switch_to_Thread(); }
        __RwBarrier();
        if ( !*S )
            ___Mempool_Extend(plidx);
        Q = *S;
        *S = *Q;
        __Atomic_Decrement(l);
    }
    memset(Q,0,(plidx+1)*C_MEMPOOL_PIECE_STEP);
    return Q;
}
#endif
;

void C_Mempool_Cleanup()
#ifdef _C_CORE_BUILTIN
{
    while ( __Mempool_Blocks )
    {
        void **Q = __Mempool_Blocks;
        __Mempool_Blocks = *Q;
        free(Q[1]);
        free(Q);
    }
}
#endif
;

enum { C_DYNCO_NYD = 0x4e5944/*'NYD'*/, C_DYNCO_ATS = 0x415453/*'ATS'*/ };

void *C_Clone_Dynamic( C_DYNAMIC *dynco, int extra )
#ifdef _C_CORE_BUILTIN
{
    int count = dynco->contsig&0x0ff;
    int fc = count?count-1:0;
    int fcc = (count+extra)?count+extra-1:0;
    C_DYNAMIC *d = __Malloc_Npl(sizeof(C_DYNAMIC)+sizeof(C_FUNCTABLE)*fcc);
    *d = *dynco;
    if ( fc )
        memcpy(d->funcs+1,dynco->funcs+1,sizeof(C_FUNCTABLE)*fc);
    d->contsig = (C_DYNCO_NYD<<8)|count;
    return d;
}
#endif
;

void *C_Extend_Dynamic( C_DYNAMIC *dynco, int extra )
#ifdef _C_CORE_BUILTIN
{
    int count = dynco->contsig&0x0ff;
    int fcc = (count+extra)?count+extra-1:0;
    C_DYNAMIC *d = __Realloc_Npl(dynco,sizeof(C_DYNAMIC)+sizeof(C_FUNCTABLE)*fcc);
    return d;
}
#endif
;

void *__Object_Extend( void *o, uptrword_t ojmid, void *func )
#ifdef _C_CORE_BUILTIN
{
    C_OBJECT *T = C_BASE(o);
    C_FUNCTABLE *f;

    if ( !T )
        C_Raise(C_ERROR_NULL_PTR,"failed to extend nullptr",__C_FILE__,__LINE__);

    if ( T->dynamic )
    {
        if ( (T->dynamic->contsig >> 8) == C_DYNCO_ATS )
            T->dynamic = C_Clone_Dynamic(T->dynamic,1);
        else
            T->dynamic = C_Extend_Dynamic(T->dynamic,1);
    }
    else
    {
        T->dynamic = __Malloc_Npl(sizeof(C_DYNAMIC));
        T->dynamic->contsig = C_DYNCO_NYD<<8;
    }

    T->dynamic->typeid = __Atomic_Increment(&__Typeid_Counter);
    f = T->dynamic->funcs+(T->dynamic->contsig&0x0ff);
    ++T->dynamic->contsig;
    f->func = func;
    f->ojmid = ojmid;

    return o;
}
#endif
;

C_OBJECT *C_Object_Alloc(int size)
#ifdef _C_CORE_BUILTIN
{
    C_OBJECT *o;
    if ( size + sizeof(C_OBJECT) > C_MEMPOOL_PIECE_MAXSIZE )
    {
        o = __Zero_Malloc_Npl(sizeof(C_OBJECT)+size);
        o->signature = C_OBJECT_SIGNATURE_HEAP;
    }
    else
    {
        int plidx = (sizeof(C_OBJECT)+size-1)/C_MEMPOOL_PIECE_STEP;
        o = __Mempool_Zalloc(plidx);
        o->signature = C_OBJECT_SIGNATURE_PFX + (plidx<<24);
    }
    return o;
}
#endif
;

void __Object_Free(C_OBJECT *o)
#ifdef _C_CORE_BUILTIN
{
    int plidx = o->signature >> 24;
    if ( plidx >= C_MEMPOOL_SLOTS_COUNT )
        free(o);
    else
        __Mempool_Free(o,plidx);
}
#endif
;

#define __Clone(Size,Ptr) __Object_Clone(Size,Ptr)
void *__Object_Clone(int size, void *orign)
#ifdef _C_CORE_BUILTIN
{
    C_OBJECT *o;
    C_OBJECT *T = C_BASE(orign);
    if ( !T )
        C_Raise(C_ERROR_NULL_PTR,"failed to clone nullptr",__C_FILE__,__LINE__);

    o = C_Object_Alloc(size);
    o->rc = 1;
    memcpy(o+1,orign,size);

    if ( T->dynamic )
    {
        if ( (T->dynamic->contsig>>8) == C_DYNCO_ATS )
            o->dynamic = T->dynamic;
        else
        {
            STRICT_REQUIRE( (T->dynamic->contsig>>8) == C_DYNCO_NYD );
            o->dynamic = C_Clone_Dynamic(T->dynamic,0);
        }
    }
    else
        o->dynamic = 0;

    return __Pool_Ptr(o+1,__Unrefe);
}
#endif
;

void *__Object(int size,C_FUNCTABLE *tbl)
#ifdef _C_CORE_BUILTIN
{
    C_OBJECT *o = C_Object_Alloc(size);
    o->rc = 1;
    o->dynamic = (C_DYNAMIC*)tbl;

    if ( tbl ) __Xchg_Interlock
    {
        C_DYNAMIC *dynco = (C_DYNAMIC*)tbl;
        if ( !dynco->contsig )
        {
            int count;
            for ( count = 0; tbl[count+1].ojmid; )
            {
                ++count;
            }
            dynco->contsig = (C_DYNCO_ATS<<8)|count;
            if ( !dynco->typeid )
            {
                dynco->typeid = __Atomic_Increment(&__Typeid_Counter);
            }
        }
    }
        return __Pool_Ptr(o+1,__Unrefe);
}
#endif
;

void *__Object_Dtor(int size,void *dtor)
#ifdef _C_CORE_BUILTIN
{
    int Sz = C_Align(sizeof(C_OBJECT)+size);
    C_OBJECT *o = C_Object_Alloc(Sz+sizeof(C_DYNAMIC));
    o->rc = 1;
    o->dynamic = (C_DYNAMIC*)((char*)o + Sz);
    o->dynamic->contsig = (C_DYNCO_ATS<<8)|1;
    o->dynamic->funcs[0].ojmid = Oj_Destruct_OjMID;
    o->dynamic->funcs[0].func = dtor?dtor:__Object_Destruct;
    o->dynamic->typeid = __Atomic_Increment(&__Typeid_Counter);
    return __Pool_Ptr(o+1,__Unrefe);
}
#endif
;

#define __Destruct(Ptr) __Object_Destruct(Ptr)
void __Object_Destruct(void *ptr)
#ifdef _C_CORE_BUILTIN
{
    if ( ptr )
    {
        C_OBJECT *o = (C_OBJECT *)ptr - 1;
        if ( o->dynamic && (o->dynamic->contsig>>8) == C_DYNCO_NYD )
            free(o->dynamic);
        o->dynamic = 0;
        __Object_Free(o);
    }
}
#endif
;

C_OBJECT *Oj_Object(void *ptr)
{
    if ( !C_SIGNAT_IS_OK(ptr) )
        return 0;
    return C_BASE(ptr);
}

C_OBJECT *Oj_Object_Or_Die(void *ptr)
{
    if ( !C_SIGNAT_IS_OK(ptr) )
        __Raise_Format(C_ERROR_ISNT_OBJECT,("pointer is not refer to object"));
    return C_BASE(ptr);
}

void *C_Find_Method_In_Table(uptrword_t ojmid, C_FUNCTABLE *tbl, int count, int flags)
#ifdef _C_CORE_BUILTIN
{
    int i;
    for ( i = 0; i < count; ++i )
        if ( tbl[i].ojmid == ojmid )
            return tbl[i].func;
    return 0;
}
#endif
;

void *C_Find_Method_Of(void *self /* VOID**  */, uptrword_t ojmid, unsigned flags)
#ifdef _C_CORE_BUILTIN
{
    void *o = *(void**)self;

    if ( o && STRICT_CHECK(C_SIGNAT_IS_OK(o)) )
    {
        C_DYNAMIC *dynco = C_BASE(o)->dynamic;
        if ( dynco )
        {
            if ( 1 && STRICT_CHECK((dynco->contsig>>8) == C_DYNCO_ATS || (dynco->contsig>>8) == C_DYNCO_NYD) )
            {
                void *f = C_Find_Method_In_Table(ojmid,dynco->funcs,(dynco->contsig&0x0ff),flags);
                if ( f ) return f;
            }
            else
                __Raise(C_ERROR_DYNCO_CORRUPTED,"object descriptor is not good");
        }
    }

    if (flags & C_RAISE_ERROR)
        __Raise_Format(C_ERROR_METHOD_NOT_FOUND,("method with ojmid %d not found",ojmid));
    return 0;
}
#endif
;

uptrword_t C_Find_Constant_Of(void *o, uptrword_t ojmid, unsigned flags, uptrword_t dflt)
#ifdef _C_CORE_BUILTIN
{
    if ( o && STRICT_CHECK(C_SIGNAT_IS_OK(o)) )
    {
        C_DYNAMIC *dynco = C_BASE(o)->dynamic;
        if ( dynco )
        {
            if ( 1 && STRICT_CHECK((dynco->contsig>>8) == C_DYNCO_ATS || (dynco->contsig>>8) == C_DYNCO_NYD) )
            {
                void *f = C_Find_Method_In_Table(ojmid,dynco->funcs,(dynco->contsig&0x0ff),flags);
                if ( f )
                    return (uptrword_t)f;
            }
            else
                __Raise(C_ERROR_DYNCO_CORRUPTED,"object descriptor is not good");
        }
    }

    if (flags & C_RAISE_ERROR)
        __Raise_Format(C_ERROR_METHOD_NOT_FOUND,("method with ojmid %d not found",ojmid));

    return dflt;
}
#endif
;

void *Oj_Clone(void *p)
#ifdef _C_CORE_BUILTIN
{
    if ( p )
    {
        void *(*clone)(void *) = C_Find_Method_Of(&p,Oj_Clone_OjMID,C_RAISE_ERROR);
        return clone(p);
    }
    return p;
}
#endif
;

