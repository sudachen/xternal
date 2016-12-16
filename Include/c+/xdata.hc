
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_E46D6A8A_889E_4AE9_9F89_5B0AB5263C95
#define C_once_E46D6A8A_889E_4AE9_9F89_5B0AB5263C95

#ifdef _BUILTIN
#define _C_XDATA_BUILTIN
#endif

#include "C+.hc"
#include "string.hc"
#include "dicto.hc"

#define XNODE_MAX_NAME_INDEX_PTR  ((char*)0x07fff)
#define XNODE_NUMBER_OF_NODE_LISTS 9

enum XVALUE_OPT_VALTYPE
  {
    XVALUE_OPT_VALTYPE_NONE     = 0x08000,
    XVALUE_OPT_VALTYPE_INT      = 0x08001,
    XVALUE_OPT_VALTYPE_FLT      = 0x08002,
    XVALUE_OPT_VALTYPE_STR      = 0x08003,
    XVALUE_OPT_VALTYPE_BIN      = 0x08004,
    XVALUE_OPT_VALTYPE_BOOL     = 0x08005,
    XVALUE_OPT_VALTYPE_LIT      = 0x08006,
    XVALUE_OPT_VALTYPE_STR_ARR  = 0x08007,
    XVALUE_OPT_VALTYPE_FLT_ARR  = 0x08008,
    XVALUE_OPT_VALTYPE_REFNODE  = 0x08009,
    XVALUE_OPT_VALTYPE_MASK     = 0x0800f,
    XVALUE_OPT_IS_VALUE         = 0x08000,
    XVALUE_DOWN_REFNODE         = 0x0ffff,
  };

struct _C_XNODE;
struct _C_XDATA;
struct _C_XVALUE_BINARY;

typedef struct _C_XNODE
  {
    ushort_t tag;
    ushort_t opt;
    ushort_t next;
    ushort_t down; 
    union       
      {
        char   *txt;
        double  flt;
        long    dec;
        byte_t  bval;
        C_BUFFER *binary;
        C_ARRAY  *strarr;
        struct _C_XDATA *xdata;
        struct _C_XNODE *refval;
        char   holder[C_MAX(sizeof(double),sizeof(void*))];
      };
  } C_XNODE;

typedef C_XNODE C_XVALUE;

typedef struct _C_XDATA
  {
    struct _C_XNODE root;    
    struct _C_XNODE *nodes[XNODE_NUMBER_OF_NODE_LISTS];
    char **tags;
    C_DICTO *dicto;
    ushort_t last_tag;
    ushort_t last_node;
  } C_XDATA;

void *C_XDATA_RAISE_DOESNT_EXIST 
#ifdef _C_XDATA_BUILTIN
  = (void*)-1
#endif
  ;

#define Number_Of_Nodes_In_List(No) (1<<(5+(No)))

void Xvalue_Purge(C_XVALUE *val)
#ifdef _C_XDATA_BUILTIN
  {
    ushort_t tp = val->opt & XVALUE_OPT_VALTYPE_MASK;
    
    switch ( tp )
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
          break;
        default:
          __Raise(C_ERROR_UNEXPECTED_VALUE,0);
      }
      
    val->opt = XVALUE_OPT_VALTYPE_NONE;
    val->down = 0;
    memset(val->holder,0,sizeof(val->holder));
  }
#endif
  ;
  
char *Xvalue_Copy_Str(C_XVALUE *val, char *dfltval)
#ifdef _C_XDATA_BUILTIN
  {
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_INT:
            return Str_From_Int(val->dec);
          case XVALUE_OPT_VALTYPE_FLT:          
            return Str_From_Flt(val->flt);
          case XVALUE_OPT_VALTYPE_STR:
            return Str_Copy(val->txt);
          case XVALUE_OPT_VALTYPE_LIT:
            return Str_Copy((char*)&val->down);
          case XVALUE_OPT_VALTYPE_NONE:
            return Str_Copy(dfltval);
          case XVALUE_OPT_VALTYPE_BOOL:
            return Str_From_Bool(val->bval);
          default:
            __Raise(C_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval?Str_Copy(dfltval):0;
  }
#endif
  ;
  
char *Xvalue_Get_Str(C_XVALUE *val, char *dfltval)
#ifdef _C_XDATA_BUILTIN
  {
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_STR:
            return ( val->txt && val->txt[0] ) ? val->txt : dfltval;
          case XVALUE_OPT_VALTYPE_LIT:
            return (char*)&val->down;
          case XVALUE_OPT_VALTYPE_NONE:
            return dfltval;
          case XVALUE_OPT_VALTYPE_BOOL:
            if ( val->bval )
              return "yes";
            else
              return "no";
          default:
            __Raise(C_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval;
  }
#endif
  ;

C_BUFFER *Xvalue_Get_Binary(C_XVALUE *val)
#ifdef _C_XDATA_BUILTIN
  {
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_BIN:
            return val->binary;
          default:
            __Raise(C_ERROR_UNEXPECTED_VALUE,0);
        }
    return 0;
  }
#endif
  ;

long Xvalue_Get_Int(C_XVALUE *val, long dfltval)
#ifdef _C_XDATA_BUILTIN
  {
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_INT:
            return val->dec;
          case XVALUE_OPT_VALTYPE_FLT:          
            return (long)val->flt;
          case XVALUE_OPT_VALTYPE_STR:
            return Str_To_Int_Dflt(val->txt,dfltval);
          case XVALUE_OPT_VALTYPE_LIT:
            return Str_To_Int_Dflt((char*)&val->down,dfltval);
          case XVALUE_OPT_VALTYPE_NONE:
            return 0;
          case XVALUE_OPT_VALTYPE_BOOL:
            return val->bval;
          default:
            __Raise(C_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval;
  }
#endif
  ;
  
double Xvalue_Get_Flt(C_XVALUE *val, double dfltval)
#ifdef _C_XDATA_BUILTIN
  {
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_INT:
            return (double)val->dec;
          case XVALUE_OPT_VALTYPE_FLT:          
            return val->flt;
          case XVALUE_OPT_VALTYPE_STR:
            return Str_To_Flt_Dflt(val->txt,dfltval);
          case XVALUE_OPT_VALTYPE_LIT:
            return Str_To_Flt_Dflt((char*)&val->down,dfltval);
          case XVALUE_OPT_VALTYPE_NONE:
            return 0;
          default:
            __Raise(C_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval;
  }
#endif
  ;
  
int Xvalue_Get_Bool(C_XVALUE *val, int dfltval)
#ifdef _C_XDATA_BUILTIN
  {
    if ( val )
      switch (val->opt&XVALUE_OPT_VALTYPE_MASK) 
        {
          case XVALUE_OPT_VALTYPE_INT:
            return val->dec?1:0;
          case XVALUE_OPT_VALTYPE_BOOL:
            return val->bval;
          case XVALUE_OPT_VALTYPE_FLT:          
            return val->flt?1:0;
          case XVALUE_OPT_VALTYPE_STR:
            return Str_To_Bool_Dflt(val->txt,dfltval);
          case XVALUE_OPT_VALTYPE_LIT:
            return Str_To_Bool_Dflt((char*)&val->down,dfltval);
          case XVALUE_OPT_VALTYPE_NONE:
            return 0;
          default:
            __Raise(C_ERROR_UNEXPECTED_VALUE,0);
        }
    return dfltval;
  }
#endif
  ;
  
void Xvalue_Set_Str(C_XVALUE *val, char *S, int L)
#ifdef _C_XDATA_BUILTIN
  {
    Xvalue_Purge(val);
    if ( L < 0 ) L = S?strlen(S):0;
    if ( L >= sizeof(val->down)+sizeof(val->holder) /*|| !S*/ )
      {
        //if ( S )
          {
            val->txt = Str_Copy_Npl(S,L);
            val->opt = XVALUE_OPT_VALTYPE_STR;
          }
        //else
        //  val->opt = XVALUE_OPT_VALTYPE_NONE;
      }
    else
      {
        if (L) memcpy((char*)&val->down,S,L);
        /* already filled by 0 in Xvalue_Purge //((char*)&val->down)[L] = 0; */
        val->opt = XVALUE_OPT_VALTYPE_LIT;
      }
  }
#endif
  ;
  
void Xvalue_Put_Str(C_XVALUE *val, __Acquire char *S)
#ifdef _C_XDATA_BUILTIN
  {
    STRICT_REQUIRE( val != 0 );
    //STRICT_REQUIRE( S != 0 );
    Xvalue_Purge(val);
    val->txt = S?S:Str_Copy_Npl("",0);
    val->opt = XVALUE_OPT_VALTYPE_STR;
  }
#endif
  ;
  
void Xvalue_Set_Or_Put_Str(C_XVALUE *val, char *S)
#ifdef _C_XDATA_BUILTIN
  {
    int L = S?strlen(S):0;
    if ( L >= sizeof(val->down)+sizeof(val->holder) )
      Xvalue_Put_Str(val,__Retain(S));
    else
      {
        Xvalue_Purge(val);
        if (L) memcpy((char*)&val->down,S,L);
        /* already filled by 0 in Xvalue_Purge //((char*)&val->down)[L] = 0; */
        val->opt = XVALUE_OPT_VALTYPE_LIT;
      }
  }
#endif
  ;
  
void Xvalue_Put_Binary(C_XVALUE *val, __Acquire C_BUFFER *bf)
#ifdef _C_XDATA_BUILTIN
  {
    STRICT_REQUIRE( val != 0 );
    STRICT_REQUIRE( bf != 0 );
    Xvalue_Purge(val);
    val->binary = bf;
    val->opt = XVALUE_OPT_VALTYPE_BIN;
  }
#endif
  ;

void Xvalue_Set_Binary(C_XVALUE *val, void *S, int L)
#ifdef _C_XDATA_BUILTIN
  {
    C_BUFFER *bf = Buffer_Copy(S,L);
    Xvalue_Put_Binary(val,bf);
  }
#endif
  ;

void Xvalue_Put_Flt_Array(C_XVALUE *val, __Acquire C_BUFFER *bf)
#ifdef _C_XDATA_BUILTIN
  {
    Xvalue_Put_Binary(val,bf);
    val->opt = XVALUE_OPT_VALTYPE_FLT_ARR;
  }
#endif
  ;

void Xvalue_Put_Str_Array(C_XVALUE *val, __Acquire C_ARRAY *arr)
#ifdef _C_XDATA_BUILTIN
  {
    STRICT_REQUIRE( val != 0 );
    STRICT_REQUIRE( arr != 0 );
    Xvalue_Purge(val);
    val->strarr = arr;
    val->opt = XVALUE_OPT_VALTYPE_STR_ARR;
  }
#endif
  ;

void Xvalue_Set_Int(C_XVALUE *val, long i)
#ifdef _C_XDATA_BUILTIN
  {
    STRICT_REQUIRE ( val );
    Xvalue_Purge(val);
    val->dec = i;
    val->opt = XVALUE_OPT_VALTYPE_INT;
  }
#endif
  ;

void Xvalue_Set_Flt(C_XVALUE *val, double d)
#ifdef _C_XDATA_BUILTIN
  {
    STRICT_REQUIRE ( val );
    Xvalue_Purge(val);
    val->flt = d;
    val->opt = XVALUE_OPT_VALTYPE_FLT;
  }
#endif
  ;

void Xvalue_Set_Bool(C_XVALUE *val, int b)
#ifdef _C_XDATA_BUILTIN
  {
    STRICT_REQUIRE ( val );
    Xvalue_Purge(val);
    val->bval = b?1:0;
    val->opt = XVALUE_OPT_VALTYPE_BOOL;
  }
#endif
  ;

int Xdata_Idxref_No(C_XDATA *doc, ushort_t idx, int *no)
#ifdef _C_XDATA_BUILTIN
  {
    --idx;
    
    if ( idx >= 32 )
      {
        int ref = Bitcount_Of(idx);
        *no  = idx - (1<<(ref-1)); //((1<<ref)-(1<<(ref-1)));
        STRICT_REQUIRE(ref >= 5);
        STRICT_REQUIRE(ref < XNODE_NUMBER_OF_NODE_LISTS+5);
        return ref-5;
      }
    else
      {
        *no = idx;
        return 0;
      }
  }
#endif
  ;

void *Xdata_Idxref(C_XDATA *doc, ushort_t idx)
#ifdef _C_XDATA_BUILTIN
  {
    STRICT_REQUIRE( doc );
    STRICT_REQUIRE( idx );
    __Gogo
      {
        C_XNODE *n;
        int no;
        int ref = Xdata_Idxref_No(doc,idx,&no);
        n = doc->nodes[ref]+no;
        return n;
      }
  }
#endif
  ;

void C_XDATA_Destruct(C_XDATA *self)
#ifdef _C_XDATA_BUILTIN
  {
    int i,j;
    
    for ( i = 0; i < XNODE_NUMBER_OF_NODE_LISTS; ++i )
      if ( self->nodes[i] )
        {
          for ( j = 0; j < Number_Of_Nodes_In_List(i); ++j )
            {
              C_XNODE *r = self->nodes[i]+j;
              if ( !(r->opt&XVALUE_OPT_IS_VALUE) && r->down == XVALUE_DOWN_REFNODE )
                {
                  C_XNODE *ref = Xdata_Idxref(r->xdata,r->opt);
                  STRICT_REQUIRE(ref->opt ==  XVALUE_OPT_VALTYPE_REFNODE);
                  r->down = 0;
                  __Unrefe(ref->refval);
                }
              else if (((r->opt&XVALUE_OPT_VALTYPE_MASK) == XVALUE_OPT_VALTYPE_STR
                  || (r->opt&XVALUE_OPT_VALTYPE_MASK) == XVALUE_OPT_VALTYPE_BIN ))
                Xvalue_Purge(r);
            }
          free(self->nodes[i]);
        }
    free(self->tags);
    __Unrefe(self->dicto);
    __Destruct(self);
  }
#endif
  ;

C_XDATA *Xnode_Get_Xdata(C_XNODE *node)
#ifdef _C_XDATA_BUILTIN
  {
    if ( node->opt&XVALUE_OPT_IS_VALUE )
      __Raise(C_ERROR_INVALID_PARAM,0);
    return node->xdata;
  }
#endif
  ;

#define Xnode_Resolve_Name(Node,Name,Cine) Xdata_Resolve_Name(Node->xdata,tag,Cine)
char *Xdata_Resolve_Name(C_XDATA *doc, char *tag, int create_if_doesnt_exist)
#ifdef _C_XDATA_BUILTIN
  {
    if ( tag && tag > XNODE_MAX_NAME_INDEX_PTR )
      {
        char *q;
        q = Dicto_Get(doc->dicto,tag,0);
        if ( q )
          ;
        else if ( create_if_doesnt_exist )
          {
            char *stored;
            q = (char*)(uptrword_t)(++doc->last_tag);
            STRICT_REQUIRE(q < XNODE_MAX_NAME_INDEX_PTR);
            stored = Dicto_Put(doc->dicto,tag,q);
            doc->tags = __Resize_Npl(doc->tags,sizeof(char*)*(doc->last_tag+1),0);
            doc->tags[doc->last_tag-1] = stored;
          }
        return q;
      }
    else
      return tag;
  }
#endif
  ;

void *Xdata_Init()
#ifdef _C_XDATA_BUILTIN
  {
    C_XDATA *doc = __Object_Dtor(sizeof(C_XDATA),C_XDATA_Destruct);
    doc->dicto = __Refe(Dicto_Init());
    doc->root.xdata = doc;
    doc->root.tag = (ushort_t)(uptrword_t)Xdata_Resolve_Name(doc,"root",1);
    return doc;
  }
#endif
  ;

char *Xnode_Get_Tag(C_XNODE *node)
#ifdef _C_XDATA_BUILTIN
  {
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    STRICT_REQUIRE( node->tag > 0 && node->tag <= node->xdata->last_tag );

    return node->xdata->tags[node->tag-1];
  }
#endif
  ;
  
int Xnode_Tag_Is(C_XNODE *node, char *tag_name)
#ifdef _C_XDATA_BUILTIN
  {
    ushort_t tag;
    
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    STRICT_REQUIRE( node->tag > 0 && node->tag <= node->xdata->last_tag );
     
    tag = (ushort_t)(uptrword_t)Xdata_Resolve_Name(node->xdata,tag_name,0);
    return node->tag == tag;
  }
#endif
  ;

C_XNODE *Xnode_Refacc(C_XNODE *node)
#ifdef _C_XDATA_BUILTIN
  {
    if ( !(node->opt&XVALUE_OPT_IS_VALUE) && node->down == XVALUE_DOWN_REFNODE )
      {
        C_XNODE *ref = Xdata_Idxref(node->xdata,node->opt);
        STRICT_REQUIRE(ref->opt ==  XVALUE_OPT_VALTYPE_REFNODE);
        node = ref->refval;
      }
    return node;
  }
#endif
  ;

char *Xnode_Value_Get_Tag(C_XNODE *node,C_XVALUE *value)
#ifdef _C_XDATA_BUILTIN
  {
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( value );

    node = Xnode_Refacc(node);

    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    STRICT_REQUIRE( (value->opt&XVALUE_OPT_IS_VALUE) != 0 );
    STRICT_REQUIRE( value->tag > 0 && value->tag <= node->xdata->last_tag );
    
    return node->xdata->tags[value->tag-1];
  }
#endif
  ;

C_XNODE *Xnode_Down(C_XNODE *node)
#ifdef _C_XDATA_BUILTIN
  {
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    node = Xnode_Refacc(node);
    if ( node->down )
      return Xdata_Idxref(node->xdata,node->down);

    return 0;
  }
#endif
  ;

C_XVALUE *Xnode_First_Value(C_XNODE *node)
#ifdef _C_XDATA_BUILTIN
  {
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );

    node = Xnode_Refacc(node);
    if ( node->opt )
      return (C_XVALUE*)Xdata_Idxref(node->xdata,node->opt);
  
    return 0;
  }
#endif
  ;

C_XVALUE *Xnode_Next_Value(C_XNODE *node, C_XVALUE *value)
#ifdef _C_XDATA_BUILTIN
  {
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    STRICT_REQUIRE( value );
    STRICT_REQUIRE( (value->opt&XVALUE_OPT_IS_VALUE) != 0 );

    node = Xnode_Refacc(node);
    if ( value->next )
      return (C_XVALUE*)Xdata_Idxref(node->xdata,value->next);
  
    return 0;
  }
#endif
  ;

C_XNODE *Xnode_Next(C_XNODE *node)
#ifdef _C_XDATA_BUILTIN
  {
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );

    if ( node->next )
      {
        C_XNODE *n = Xdata_Idxref(node->xdata,node->next);
        STRICT_REQUIRE( n != node );
        return n;
      }
      
    return 0;
  }
#endif
  ;

C_XNODE *Xnode_Last(C_XNODE *node)
#ifdef _C_XDATA_BUILTIN
  {
    C_XNODE *n = 0;

    STRICT_REQUIRE( node );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    node = Xnode_Down(node);
    
    while ( node ) 
      {
        n = node;
        node = Xnode_Next(node);
      }
    
    return n;
  }
#endif
  ;

int Xnode_Count(C_XNODE *node)
#ifdef _C_XDATA_BUILTIN
  {
    int i = 0;

    STRICT_REQUIRE( node );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    node = Xnode_Down(node);
    
    while ( node ) 
      {
        ++i;
        node = Xnode_Next(node);
      }
    
    return i;
  }
#endif
  ;

void *Xdata_Allocate(C_XDATA *doc, char *tag, ushort_t *idx)
#ifdef _C_XDATA_BUILTIN
  {
    int no,ref,newidx;
    C_XNODE *n;
    
    STRICT_REQUIRE( doc );
    STRICT_REQUIRE( tag );
    STRICT_REQUIRE( idx );
    
    newidx = ++doc->last_node;
    ref = Xdata_Idxref_No(doc,(ushort_t)newidx,&no);
    if ( !doc->nodes[ref] )
      {
        int count = sizeof(C_XNODE)*Number_Of_Nodes_In_List(ref);
        doc->nodes[ref] = __Malloc_Npl(count);
        memset(doc->nodes[ref],0xff,count);
      }

    *idx = newidx;
    n = doc->nodes[ref]+no;
    memset(n,0,sizeof(C_XNODE));
    n->tag = (ushort_t)(uptrword_t)Xdata_Resolve_Name(doc,tag,1);
    return n;
  }
#endif
  ;

C_XNODE *Xdata_Create_Node(C_XDATA *doc, char *tag, ushort_t *idx)
#ifdef _C_XDATA_BUILTIN
  {
    C_XNODE *n = Xdata_Allocate(doc,tag,idx);
    n->xdata = doc;
    return n;
  }
#endif
  ;

C_XVALUE *Xdata_Create_Value(C_XDATA *doc, char *tag, ushort_t *idx)
#ifdef _C_XDATA_BUILTIN
  {
    C_XNODE *n = Xdata_Allocate(doc,tag,idx);
    n->opt = XVALUE_OPT_VALTYPE_NONE;
    return n;
  }
#endif
  ;

C_XNODE *Xnode_Append(C_XNODE *node, char *tag)
#ifdef _C_XDATA_BUILTIN
  {
    ushort_t idx;
    C_XNODE *n;
    
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( tag );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    node = Xnode_Refacc(node);
    n = Xdata_Create_Node(node->xdata,tag,&idx);

    if ( node->down )
      {
        C_XNODE *last = Xnode_Last(node);
        last->next = idx;
      }
    else
      {
        node->down = idx;
      }

    STRICT_REQUIRE( n->next != idx );
    return n;
  }
#endif
  ;

C_XNODE *Xnode_Append_Refnode(C_XNODE *node, char *tagname, C_XNODE *ref)
#ifdef _C_XDATA_BUILTIN
  {
    C_XNODE *n;
    C_XNODE *v;
    
    STRICT_REQUIRE( ref );
    STRICT_REQUIRE( (ref->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    node = Xnode_Refacc(node);

    if ( !tagname ) tagname = Xnode_Get_Tag(ref);
    n = Xnode_Append(node,tagname);
    v = Xdata_Allocate(node->xdata,".refout.",&n->opt);
    n->down = XVALUE_DOWN_REFNODE;
    v->opt = XVALUE_OPT_VALTYPE_REFNODE;
    v->refval = ref;
    __Refe( v->refval );
    return n;
  }
#endif
  ;

C_XNODE *Xnode_Insert(C_XNODE *node, char *tag)
#ifdef _C_XDATA_BUILTIN
  {
    ushort_t idx;
    C_XNODE *n;
    
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( tag );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    n = Xdata_Create_Node(node->xdata,tag,&idx);
    n->next = node->down;
    node->down = idx;
      
    STRICT_REQUIRE( n->next != idx );
    
    return n;
  }
#endif
  ;

C_XNODE *Xnode_Down_If(C_XNODE *node, char *tag_name)
#ifdef _C_XDATA_BUILTIN
  {
    ushort_t tag;
    C_XNODE *n;
      
    if ( !node ) return 0;
    node = Xnode_Refacc(node);

    STRICT_REQUIRE( node );
    STRICT_REQUIRE( tag_name );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );

    tag = (ushort_t)(uptrword_t)Xdata_Resolve_Name(node->xdata,tag_name,0);
    
    if ( tag )
      {
        n = Xnode_Down(node);
        while ( n && n->tag != tag )
          n = Xnode_Next(n);
      
        if ( n && n->tag == tag )
          return n;
      }
      
    return 0;
  }
#endif
  ;

C_XNODE *Xnode_Next_If(C_XNODE *node, char *tag_name)
#ifdef _C_XDATA_BUILTIN
  {
    ushort_t tag;
    C_XNODE *n = node;
      
    if ( !node ) return 0;
    //n = Xnode_Refacc(node);
    
    STRICT_REQUIRE( n );
    STRICT_REQUIRE( tag_name );
    STRICT_REQUIRE( (n->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    tag = (ushort_t)(uptrword_t)Xdata_Resolve_Name(n->xdata,tag_name,0);
    
    if ( tag )
      {
        do
          n = Xnode_Next(n);
        while ( n && n->tag != tag );
      
        if ( n && n->tag == tag )
          return n;
      }
    
    return 0;
  }
#endif
  ;

#define Xnode_Value_Is_Int(Node,Valtag) \
  ((Xnode_Opt_Of_Value(Node,Valtag)&XVALUE_OPT_VALTYPE_MASK) \
    == XVALUE_OPT_VALTYPE_INT)

#define Xnode_Value_Is_Flt(Node,Valtag) \
  ((Xnode_Opt_Of_Value(Node,Valtag)&XVALUE_OPT_VALTYPE_MASK) \
    == XVALUE_OPT_VALTYPE_FLT)

#define Xnode_Value_Is_Str(Node,Valtag) \
  ((Xnode_Opt_Of_Value(Node,Valtag)&XVALUE_OPT_VALTYPE_MASK) \
    == XVALUE_OPT_VALTYPE_STR)

#define Xnode_Value_Is_None(Node,Valtag) \
  ((Xnode_Opt_Of_Value(Node,Valtag)&XVALUE_OPT_VALTYPE_MASK) \
    == XVALUE_OPT_VALTYPE_NONE)

C_XVALUE *Xnode_Value(C_XNODE *node, char *valtag_S, int create_if_dnt_exist)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *value = 0;
    C_XDATA  *doc;
    ushort_t *next;
    ushort_t valtag;
    
    node = Xnode_Refacc(node);

    STRICT_REQUIRE( node );
    STRICT_REQUIRE( valtag_S );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    doc = node->xdata;

    if ( valtag_S > XNODE_MAX_NAME_INDEX_PTR )
      valtag = (ushort_t)(uptrword_t)Xdata_Resolve_Name(doc,valtag_S,create_if_dnt_exist);
    else
      valtag = (ushort_t)(uptrword_t)valtag_S;
      
    next = &node->opt;
    if ( valtag ) 
      {
        while ( *next )
          {
            value = (C_XVALUE *)Xdata_Idxref(doc,*next);
            STRICT_REQUIRE( value != 0 );
            if ( value->tag == valtag )
              goto found;
            next = &value->next;
          }
    
        STRICT_REQUIRE( !*next );
        if ( create_if_dnt_exist )
          {
            STRICT_REQUIRE( valtag );
            value = Xdata_Create_Value(doc,(char*)(uptrword_t)valtag,next);
            goto found;
          }
      }
    return 0;
      
  found:
    return value;
  }
#endif
  ;
  
C_XVALUE *Xnode_Match_Value(C_XNODE *node, char *patt)
#ifdef _C_XDATA_BUILTIN
  {
    C_XDATA  *doc;
    ushort_t *next;
    
    node = Xnode_Refacc(node);

    STRICT_REQUIRE( node );
    STRICT_REQUIRE( patt );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    doc = node->xdata;
    next = &node->opt;

    while ( *next )
      {
        C_XVALUE *value = (C_XVALUE *)Xdata_Idxref(doc,*next);
        STRICT_REQUIRE( value != 0 );
        if ( Str_Match( Xnode_Value_Get_Tag(node,value), patt ) )
          return value;
      }

    return 0;
  }
#endif
  ;

int Xnode_Opt_Of_Value(C_XNODE *node, char *valtag)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val = Xnode_Value(node,valtag,0);
    if ( val )
      return val->opt;
    return 0; 
  }
#endif
  ;
  

long Xnode_Value_Get_Int(C_XNODE *node, char *valtag, long dfltval)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val = Xnode_Value(node,valtag,0);
    return Xvalue_Get_Int(val,dfltval);
  }
#endif
  ;
  
void Xnode_Value_Set_Int(C_XNODE *node, char *valtag, long i)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val = Xnode_Value(node,valtag,1);
    Xvalue_Set_Int(val,i);
  }
#endif
  ;
  
int Xnode_Value_Get_Bool(C_XNODE *node, char *valtag, int dfltval)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val = Xnode_Value(node,valtag,0);
    return Xvalue_Get_Bool(val,dfltval);
  }
#endif
  ;
  
void Xnode_Value_Set_Bool(C_XNODE *node, char *valtag, int i)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val = Xnode_Value(node,valtag,1);
    Xvalue_Set_Bool(val,i);
  }
#endif
  ;

double Xnode_Value_Get_Flt(C_XNODE *node, char *valtag, double dfltval)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val = Xnode_Value(node,valtag,0);
    return Xvalue_Get_Flt(val,dfltval);
  }
#endif
  ;
  
void Xnode_Value_Set_Flt(C_XNODE *node, char *valtag, double d)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val = Xnode_Value(node,valtag,1);
    Xvalue_Set_Flt(val,d);
  }
#endif
  ;
  
char *Xnode_Value_Get_Str(C_XNODE *node, char *valtag, char *dfltval)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val = Xnode_Value(node,valtag,0);
    return Xvalue_Get_Str(val,dfltval);
  }
#endif
  ;
  
char *Xnode_Value_Copy_Str(C_XNODE *node, char *valtag, char *dfltval)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val = Xnode_Value(node,valtag,0);
    return Xvalue_Copy_Str(val,dfltval);
  }
#endif
  ;
  
void Xnode_Value_Set_Str(C_XNODE *node, char *valtag, char *S)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val;
    val = Xnode_Value(node,valtag,1);
    Xvalue_Set_Str(val,S,-1);
  }
#endif
  ;
  
void Xnode_Value_Put_Str(C_XNODE *node, char *valtag, __Acquire char *S)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val;
    __Pool(S);
    val = Xnode_Value(node,valtag,1);
    Xvalue_Put_Str(val,__Retain(S));
  }
#endif
  ;
  
void Xnode_Value_Put_Binary(C_XNODE *node,char *valtag, C_BUFFER *bf)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val = Xnode_Value(node,valtag,0);
    Xvalue_Put_Binary(val,__Refe(bf));
  }
#endif
  ;

void Xnode_Value_Set_Binary(C_XNODE *node,char *valtag, void *data, int len)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val = Xnode_Value(node,valtag,0);
    Xvalue_Set_Binary(val,data,len);
  }
#endif
  ;
  
C_BUFFER *Xnode_Value_Get_Binary(C_XNODE *node,char *valtag)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val = Xnode_Value(node,valtag,0);
    return Xvalue_Get_Binary(val);
  }
#endif
  ;
  
C_BUFFER *Xnode_Value_Copy_Binary(C_XNODE *node,char *valtag)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *val = Xnode_Value(node,valtag,0);
    C_BUFFER *bf = Xvalue_Get_Binary(val);
    if ( bf )
      return Buffer_Copy(bf->at,bf->count);
    return 0;
  }
#endif
  ;

enum
  {
    C_XNODE_QUERY_EQUAL = 1,
    C_XNODE_QUERY_NAMED = 2,
    C_XNODE_QUERY_MATCH = 3,
  };

int Xnode_Query_Chop_Op(char **query, char *elm, int elm_size)
#ifdef _C_XDATA_BUILTIN
  {
    int patt = C_XNODE_QUERY_EQUAL;
    int i = 0;
    
    if ( !query || !*query || !**query )
      return 0;
      
    while ( **query )
      {
        if ( i >= elm_size - 1 ) __Raise(C_ERROR_OUT_OF_RANGE,0);
        if ( **query != '.' )
          {
            char c = *(*query)++;
            if ( c == '*' || c == '[' || c == '?' )
              patt = C_XNODE_QUERY_MATCH;
            else if ( c == '@' && patt < C_XNODE_QUERY_MATCH && **query )
              patt = C_XNODE_QUERY_NAMED;
            elm[i++] = c;
          }
        else
          {
            ++*query;
            break;
          }
      }
      
    elm[i] = 0;
    if (!**query) *query = 0;
    return patt;
  }
#endif
  ;

C_XNODE *Xnode_Down_If_Named(C_XNODE *node, char *named_tag)
#ifdef _C_XDATA_BUILTIN
  {
    C_XNODE *n;
    int tag_len = 0;
    char *name;
    char *tag;
      
    node = Xnode_Refacc(node);

    STRICT_REQUIRE( node );
    STRICT_REQUIRE( named_tag );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );

    tag = named_tag;
    for (; *named_tag && *named_tag != '@'; ++named_tag )
      ++tag_len;
    name = tag+tag_len;
    if ( name[0] == '@' ) ++name;
    
    n = Xnode_Down(node);
    while ( n )
      {
        if ( !tag_len || !strncmp(Xnode_Get_Tag(n),tag,tag_len) )
          if ( !*name || Str_Equal_Nocase(Xnode_Value_Get_Str(n,"@",""),name) )
            break;
        n = Xnode_Next(n);
      }
      
    return n;
  }
#endif
  ;

C_XNODE *Xnode_Down_Match(C_XNODE *node, char *patt)
#ifdef _C_XDATA_BUILTIN
  {
    C_XNODE *n;
    char tag_patt[128];
    char name_patt[128];
      
    STRICT_REQUIRE( node );
    STRICT_REQUIRE( patt );
    STRICT_REQUIRE( (node->opt&XVALUE_OPT_IS_VALUE) == 0 );

    n = Xnode_Down(node);
    name_patt[0] = 0;
    tag_patt[sizeof(tag_patt)-1] = 0;
    strncpy(tag_patt,patt,sizeof(tag_patt)-1);
    
    __Gogo
      {
        int i;
        char *p = patt;
        for ( ; *p; ++p )
          if ( *p  == '@' )
            {
              i = p-patt;
              if ( i > sizeof(tag_patt)-1 )
                __Raise(C_ERROR_OUT_OF_RANGE,0);
              memcpy(tag_patt,patt,i); tag_patt[i] = 0;
              i = 0;
              ++p;
              for ( ; *p && i < sizeof(name_patt)-1; ++i )
                name_patt[i] = p[i];
              if ( *p )
                __Raise(C_ERROR_OUT_OF_RANGE,0);
              name_patt[i] = 0;
              break;
            }
      }

    while ( n )
      {
        if ( !tag_patt[0] || Str_Match(Xnode_Get_Tag(n),tag_patt) )
          if ( !name_patt[0] || Str_Match_Nocase(Xnode_Value_Get_Str(n,"@",0),name_patt) )
            break;
        n = Xnode_Next(n);
      }
      
    return n;
  }
#endif
  ;

C_XVALUE *Xnode_Deep_Value(C_XNODE *n, char *query)
#ifdef _C_XDATA_BUILTIN
  {
    C_XNODE *nn;
    int qtype;
    char elm[128];
    
    while( 0 != (qtype=Xnode_Query_Chop_Op(&query,elm,sizeof(elm))) )
      {
        if ( qtype == C_XNODE_QUERY_MATCH )
          __Raise(C_ERROR_ILLFORMED,
            "Xnode_Deep_Value not supports matching requests");
          
        if ( !query && qtype != C_XNODE_QUERY_NAMED ) /* looking for value? */
          {
            STRICT_REQUIRE( qtype == C_XNODE_QUERY_EQUAL );
            return Xnode_Value(n,elm,1);
          }
          
        if ( qtype == C_XNODE_QUERY_NAMED )
          nn = Xnode_Down_If_Named(n,elm);
        else /* qtype == C_XNODE_QUERY_EQUAL */
          nn = Xnode_Down_If(n,elm);
      
        if ( !nn )
          {
            if ( qtype == C_XNODE_QUERY_EQUAL ) lb_trivial_append:
              nn = Xnode_Append(n,elm);
            else /* qtype == C_XNODE_QUERY_NAMED */
              {
                char *c = strchr(elm,'@');
                if ( !c ) goto lb_trivial_append;
                *c = 0; ++c;
                nn = Xnode_Append(n,(!elm[0]?"node":elm));
                Xnode_Value_Set_Str(nn,"@",c);
              }
          }
          
        n = nn;
      }
    
    return Xnode_Value(n,"$",1);
  }
#endif
  ;

C_XNODE *Xnode_Query_Node(C_XNODE *n, char *query)
#ifdef _C_XDATA_BUILTIN
  {
    int qtype;
    char elm[128];
    
    while( n && (qtype=Xnode_Query_Chop_Op(&query,elm,sizeof(elm))) )
      {
        if ( qtype == C_XNODE_QUERY_MATCH )
          n = Xnode_Down_Match(n,elm);
        else if ( qtype == C_XNODE_QUERY_NAMED )
          n = Xnode_Down_If_Named(n,elm);
        else /* qtype == C_XNODE_QUERY_EQUAL */
          n = Xnode_Down_If(n,elm);
      }

    return n;
  }
#endif
  ;

#if 0
#define Xnode_Query_Node(N,Q) Xnode_Query_Node_Or_Create(N,Q,0)
#define Xnode_Query_Create_Node(N,Q) Xnode_Query_Node_Or_Create(N,Q,1)

C_XNODE *Xnode_Query_Node_Or_Create(C_XNODE *n, char *query, int create_if_dsnt_exist)
#ifdef _C_XDATA_BUILTIN
  {
    int qtype;
    char elm[128];
    
    while( n && (qtype=Xnode_Query_Chop_Op(&query,elm,sizeof(elm))) )
      {
        C_XNODE *r = 0;
        if ( qtype == C_XNODE_QUERY_MATCH )
          {
            r = Xnode_Down_Match(n,elm);
            if ( create_if_dsnt_exist ) __Raise_User_Error("failed to create fuse node");
          }
        else if ( qtype == C_XNODE_QUERY_NAMED )
          {
            r = Xnode_Down_If_Named(n,elm);
            if ( !r && create_if_dsnt_exist )
              {
                char *name = elm;
                for (; *name && *name != '@';  ) ++name;
                if ( name[0] == '@' ) 
                  {
                    *name = 0;
                    ++name;
                  }
                r = Xnode_Append(n,elm);
                Xnode_Value_Set_Str(r,"@",name);
              }
          }
        else /* qtype == C_XNODE_QUERY_EQUAL */
          {
            r = Xnode_Down_If(n,elm);
            if ( !r && create_if_dsnt_exist )
              r = Xnode_Append(n,elm);
          }
        n = r;
      }  

    return n;
  }
#endif
  ;
#endif

C_XVALUE *Xnode_Query_Value(C_XNODE *n, char *query)
#ifdef _C_XDATA_BUILTIN
  {
    int qtype;
    char elm[128];
    
    while( n && (qtype=Xnode_Query_Chop_Op(&query,elm,sizeof(elm))) )
      {
        if ( !query && qtype != C_XNODE_QUERY_NAMED ) /* looking for value? */
          {
            C_XVALUE *value;
            if ( qtype == C_XNODE_QUERY_EQUAL )
              {
                value = Xnode_Value(n,elm,0);
              }
            else /* qtype == C_XNODE_QUERY_MATCH */
              {
                value = Xnode_Match_Value(n,elm);
              }
            
            if ( value )
              return value;
          }
        
        if ( qtype == C_XNODE_QUERY_MATCH )
          n = Xnode_Down_Match(n,elm);
        else if ( qtype == C_XNODE_QUERY_NAMED )
          n = Xnode_Down_If_Named(n,elm);
        else /* qtype == C_XNODE_QUERY_EQUAL */
          n = Xnode_Down_If(n,elm);
      }
    
    if ( n )
      return Xnode_Value(n,"$",0);
    
    return 0;
  }
#endif
  ;

char *Xvalue_Str_Bf(C_XVALUE *value,C_BUFFER *bf)
#ifdef _C_XDATA_BUILTIN
  {
    if ( value )
      {
        int start = bf->count;
        char *S = Xvalue_Get_Str(value,0);
        if ( S )
          Buffer_Append(bf,S,-1);
        else
          {
            S = Xvalue_Copy_Str(value,"");
            Buffer_Append(bf,S,-1);
            __Release(S);
          }
        return (char*)bf->at+start;
      }
    
    return 0;
  }
#endif
  ;
  
/*
  be carrefull when assume non-null result as succeeded
  if add empty string to empty buffer, retvalue will be 0
*/
char *Xnode_Query_Str_Bf(C_BUFFER *bf, C_XNODE *n, char *query)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *value = Xnode_Query_Value(n,query);
    return Xvalue_Str_Bf(value,bf);
  }
#endif
  ;

char *Xnode_Query_Str_Dflt(C_XNODE *n, char *query, char *dflt)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *value;
    
    value = Xnode_Query_Value(n,query);
    if ( value )
      return Xvalue_Get_Str(value,dflt);
      
    return dflt;
  }
#endif
  ;

char *Xnode_Query_Str_Copy(C_XNODE *n, char *query)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *value;
    
    value = Xnode_Query_Value(n,query);
    if ( value )
      return Xvalue_Copy_Str(value,"");
      
    return 0;
  }
#endif
  ;

int Xnode_Query_Int(C_XNODE *n, char *query, int dflt)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *value;
    
    value = Xnode_Query_Value(n,query);
    if ( value )
      return Xvalue_Get_Int(value,dflt);
      
    return dflt;
  }
#endif
  ;

/*C_XVALUE *Xnode_Query_Create_Value(C_XNODE *n, char *query)
#ifdef _C_XDATA_BUILTIN
  {
    char *S = strrchr(query,'.');
    if ( S )
      {
        int l = S-query;
        query = memcpy(alloca(l+1),query,l);
        query[l] = 0;
        ++S; 
      }
    n = Xnode_Query_Create_Node(n,query);
    return Xnode_Value(n,(S&&*S)?S:"$",1);
  }
#endif
  ;
*/

void Xnode_Query_Set_Int(C_XNODE *n, char *query, int val)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *v = Xnode_Deep_Value(n,query);
    Xvalue_Set_Int(v,val);
  }
#endif
  ;

void Xnode_Query_Set_Str(C_XNODE *n, char *query, char *val)
#ifdef _C_XDATA_BUILTIN
  {
    C_XVALUE *v = Xnode_Deep_Value(n,query);
    Xvalue_Set_Str(v,val,-1);
  }
#endif
  ;

#endif /*C_once_E46D6A8A_889E_4AE9_9F89_5B0AB5263C95*/

