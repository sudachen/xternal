
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_38B1FFE7_1462_42EB_BABE_AA8E0BE62203
#define C_once_38B1FFE7_1462_42EB_BABE_AA8E0BE62203

#ifdef _BUILTIN
#define _C_DICTO_BUILTIN
#endif

enum { C_REF_DICTO_TYPEID = 0xaa3d };

#include "C+.hc"
#include "crc.hc"
#include "buffer.hc"
#include "array.hc"
#include "string.hc"

typedef struct _C_DICTO_REC
  {
    struct _C_DICTO_REC *next;
    void *ptr;
    byte_t hashcode;
    char key[1];
  } C_DICTO_REC;

typedef struct _C_DICTO
  {
    struct _C_DICTO_REC **table; 
    int count;
    int width;
  } C_DICTO;


#define Dicto_Hash_1(Key) Crc_8_Of_Cstr(Key)
#define Dicto_Count(Dicto) ((int)((C_DICTO*)(Dicto))->count+0)

void Dicto_Rehash(C_DICTO *o);

#ifdef _C_DICTO_BUILTIN  
int Dicto_Width_Values[] = {5,11,23,47,97,181,256};
#endif

C_DICTO_REC **Dicto_Backet(C_DICTO *o, byte_t hashcode, char *key)
#ifdef _C_DICTO_BUILTIN  
  {
    C_DICTO_REC **nrec;
    
    if ( !o->table )
      {
        o->width = Dicto_Width_Values[0];
        o->table = __Malloc_Npl(o->width*sizeof(void*));
        memset(o->table,0,o->width*sizeof(void*));
      }
      
    nrec = &o->table[hashcode%o->width];
    
    while ( *nrec )
      {
        if ( hashcode == (*nrec)->hashcode && !strcmp((*nrec)->key,key) )
          break;
        nrec = &(*nrec)->next;
      }
    
    return nrec;
  }
#endif
  ;

C_DICTO_REC *Dicto_Allocate(char *key)
#ifdef _C_DICTO_BUILTIN  
  {
    int keylen = strlen(key);
    C_DICTO_REC *Q = __Malloc_Npl(sizeof(C_DICTO_REC) + keylen);
    memcpy(Q->key,key,keylen+1);
    Q->hashcode = Dicto_Hash_1(key);
    Q->next = 0;
    Q->ptr = 0;
    return Q;
  }
#endif
  ;

void *Dicto_Get(C_DICTO *o, char *key, void *dflt)
#ifdef _C_DICTO_BUILTIN  
  {
    if ( key )
      {
        byte_t hashcode = Dicto_Hash_1(key);
        C_DICTO_REC *Q = *Dicto_Backet(o,hashcode,key);
        if ( Q )
          return Q->ptr;
      }
    return dflt;
  }
#endif
  ;

void *Dicto_Get_Key_Ptr(C_DICTO *o, char *key)
#ifdef _C_DICTO_BUILTIN  
  {
    if ( key )
      {
        byte_t hashcode = Dicto_Hash_1(key);
        C_DICTO_REC *Q = *Dicto_Backet(o,hashcode,key);
        if ( Q )
          return Q->key;
      }
    return 0;
  }
#endif
  ;

int Dicto_Has(C_DICTO *o, char *key)
#ifdef _C_DICTO_BUILTIN  
  {
    if ( key )
      {
        byte_t hashcode = Dicto_Hash_1(key);
        if ( *Dicto_Backet(o,hashcode,key) )
          return 1;
      }
    return 0;
  }
#endif
  ;

void *Dicto_Put(C_DICTO *o, char *key, void *val)
#ifdef _C_DICTO_BUILTIN  
  {
    if ( key )
      {
        byte_t hashcode = Dicto_Hash_1(key);
        C_DICTO_REC **Q = Dicto_Backet(o,hashcode,key);
        if ( *Q )
          {
            C_DICTO_REC *p = *Q;
            void *self = o;
            void (*destructor)(void*) = 
                               C_Find_Method_Of(&self
                                                ,Oj_Destruct_Element_OjMID,0);
            if ( destructor )
              (*destructor)(p->ptr);
            p->ptr = val;
            key = (*Q)->key;
          }
        else
          {
            *Q = Dicto_Allocate(key);
            key = (*Q)->key;
            (*Q)->ptr = val;
            ++o->count;
            if ( o->count > o->width*3 )
              Dicto_Rehash(o);
          }
        return key;
      }
    else
      return 0;
  }
#endif
  ;

void Dicto_Del(C_DICTO *o, char *key)
#ifdef _C_DICTO_BUILTIN  
  {
    if ( key )
      {
        byte_t hashcode = Dicto_Hash_1(key);
        C_DICTO_REC **Q = Dicto_Backet(o,hashcode,key);
        if ( *Q )
          {
            C_DICTO_REC *p = *Q;
            void *self = o;
            void (*destructor)(void*) = 
                               C_Find_Method_Of(&self
                                                ,Oj_Destruct_Element_OjMID,0);
            if ( destructor )
              (*destructor)(p->ptr);
            *Q = (*Q)->next;
            free(p);
            STRICT_REQUIRE ( o->count >= 1 );
            --o->count;
          }
      }
  }
#endif
  ;

/* returns unmanaged value */
void *Dicto_Take_Npl(C_DICTO *o, char *key)
#ifdef _C_DICTO_BUILTIN  
  {
    if ( key )
      {
        byte_t hashcode = Dicto_Hash_1(key);
        C_DICTO_REC **Q = Dicto_Backet(o,hashcode,key);
        if ( *Q )
          {
            C_DICTO_REC *p = *Q;
            void *ret = p->ptr;
            *Q = (*Q)->next;
            free(p);
            STRICT_REQUIRE ( o->count >= 1 );
            --o->count;
            return ret;
          }
      }
    return 0;
  }
#endif
  ;

void *Dicto_Take(C_DICTO *o, char *key)
#ifdef _C_ARRAY_BUILTIN
  {
    void *self = o;
    void (*destruct)(void *) = C_Find_Method_Of(&self
                                                ,Oj_Destruct_Element_OjMID
                                                ,C_RAISE_ERROR);
    void *Q = Dicto_Take_Npl(o,key);
    
    if ( Q )
      __Pool_Ptr(Q,destruct);
      
    return Q;
  }
#endif
  ;

void Dicto_Clear(C_DICTO *o)
#ifdef _C_DICTO_BUILTIN  
  {
    int i;
    void *self = o;
    void (*destructor)(void*) = C_Find_Method_Of(&self
                                                 ,Oj_Destruct_Element_OjMID,0);
    
    if ( o->table )
      for ( i = 0; i < o->width; ++i )
        while ( o->table[i] )
          {
            C_DICTO_REC *Q = o->table[i];
            o->table[i] = Q->next;
            if ( destructor )
              (*destructor)(Q->ptr);
            free(Q);
          }

    if ( o->table ) free( o->table );
    o->table = 0;
    o->width = 0;
    o->count = 0;      
  }
#endif
  ;

#ifdef _C_DICTO_BUILTIN  
void Dicto_Rehash(C_DICTO *o)
  {
    if ( o->table && o->count )
      {
        int i;
        int width = 256;
        C_DICTO_REC **table;
        
        for ( i = 0; Dicto_Width_Values[i] < 256; ++i )
          if ( o->count <= Dicto_Width_Values[i] + Dicto_Width_Values[i]/2  )
            {
              width = Dicto_Width_Values[i]; 
              break;
            }
        
        if ( width > o->width ) 
          {
            table = __Malloc_Npl(width*sizeof(void*));
            memset(table,0,width*sizeof(void*));
        
            for ( i = 0; i < o->width; ++i )
              while ( o->table[i] )
                {
                  C_DICTO_REC *Q = o->table[i];
                  o->table[i] = Q->next;
                  Q->next = table[Q->hashcode%width];
                  table[Q->hashcode%width] = Q;
                }
      
            free(o->table);
            o->width = width;
            o->table = table;    
          }
      }
  }
#endif
  ;

void Dicto_Destruct(C_DICTO *o)
#ifdef _C_DICTO_BUILTIN  
  {
    Dicto_Clear(o);
    __Destruct(o);
  }
#endif
  ;

void *Dicto_Refs(void)
#ifdef _C_DICTO_BUILTIN  
  {
    static C_FUNCTABLE funcs[] = 
      { {0, (void*)C_REF_DICTO_TYPEID },
        {Oj_Destruct_OjMID, Dicto_Destruct},
        {Oj_Destruct_Element_OjMID, __Unrefe},
        {0}};
    C_DICTO *dicto = __Object(sizeof(C_DICTO),funcs);
    return dicto;
  }
#endif
  ;

void *Dicto_Ptrs(void)
#ifdef _C_DICTO_BUILTIN  
  {
    static C_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID, Dicto_Destruct},
        {Oj_Destruct_Element_OjMID, free},
        {0}};
    C_DICTO *dicto = __Object(sizeof(C_DICTO),funcs);
    return dicto;
  }
#endif
  ;

void *Dicto_Init(void)
#ifdef _C_DICTO_BUILTIN  
  {
    C_DICTO *dicto = __Object_Dtor(sizeof(C_DICTO),Dicto_Destruct);
    return dicto;
  }
#endif
  ;

typedef void (*dicto_apply_filter_t)(char *,void *,void *);

void Dicto_Apply(C_DICTO *o
                , /*dicto_apply_filter_t*/ void *_filter
                , void *state)  
#ifdef _C_DICTO_BUILTIN  
  {
    int i;
    C_DICTO_REC *nrec;
    dicto_apply_filter_t filter = _filter;
    if ( o && o->table ) 
      for ( i = 0; i < o->width; ++i )
        {      
          nrec = o->table[i];
          while ( nrec )
            {
              __Auto_Release filter(nrec->key,nrec->ptr,state);
              nrec = nrec->next;
            }  
        }
  }
#endif
  ;

void _Dicto_Filter_Push_Value(char *key, void *value, C_ARRAY *a)
#ifdef _C_DICTO_BUILTIN  
  {
    Array_Push(a,value);
  }
#endif
  ;
    
C_ARRAY *Dicto_Values(C_DICTO *o)
#ifdef _C_DICTO_BUILTIN  
  {
    C_ARRAY *a = Array_Void();
    Dicto_Apply(o,(dicto_apply_filter_t)_Dicto_Filter_Push_Value,a);
    return a;
  }
#endif
  ;
    
void _Dicto_Filter_Push_Key(char *key, void *value, C_ARRAY *a)
#ifdef _C_DICTO_BUILTIN  
  {
    Array_Push(a,key);
  }
#endif
  ;
    
C_ARRAY *Dicto_Keys(C_DICTO *o)
#ifdef _C_DICTO_BUILTIN  
  {
    C_ARRAY *a = Array_Void();
    Dicto_Apply(o,(dicto_apply_filter_t)_Dicto_Filter_Push_Key,a);
    return a;
  }
#endif
  ;
  
typedef void (*dicto_format_printer_t)(C_BUFFER *bf,void *S);

char *Dicto_Format(C_DICTO *o
                  , /*dicto_format_printer_t*/ void *_print
                  , C_BUFFER *_bf, int pretty)
#ifdef _C_DICTO_BUILTIN  
  {
    int start = 0, i, j=0;
    C_BUFFER *bf = _bf;
    C_DICTO_REC *nrec;
    dicto_format_printer_t print = _print;

    if ( !bf ) bf = Buffer_Init(0);
    start = bf->count;
    
    Buffer_Fill_Append(bf,'{',1);
    if ( pretty )
      Buffer_Fill_Append(bf,'\n',1); 

    if ( o && o->table ) 
      for ( i = 0; i < o->width; ++i )
        {      
          nrec = o->table[i];
          while ( nrec )
            {
              if ( j ) 
                if ( pretty )
                  Buffer_Fill_Append(bf,'\n',1); 
                else 
                  Buffer_Append(bf,", ",2); 
              else 
                j = 1; 
              if ( pretty )
                Buffer_Fill_Append(bf,' ',2); 
              Buffer_Append(bf,nrec->key,-1);
              Buffer_Append(bf,": ",2);
              __Auto_Release print(bf,nrec->ptr);
              nrec = nrec->next;
            }  
        }
    
    if ( j && pretty )
      Buffer_Fill_Append(bf,'\n',1); 
    Buffer_Fill_Append(bf,'}',1);

    if ( !_bf )
      return Buffer_Take_Data(bf);
    else
      return bf->at+start;
  }
#endif
  ;

C_DICTO *Dicto_Set_Str(C_DICTO *dicto, char *key, void *val)
#ifdef _C_DICTO_BUILTIN  
  {
    if ( !dicto )
      dicto = Dicto_Ptrs();
    Dicto_Put(dicto,key,Str_Copy_Npl(val,-1));
    return dicto; 
  }
#endif
  ;
  
#endif /* C_once_38B1FFE7_1462_42EB_BABE_AA8E0BE62203 */

