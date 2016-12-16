
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_40BDAC30_45A4_4FC1_810C_05757F2DC413
#define C_once_40BDAC30_45A4_4FC1_810C_05757F2DC413

#include "C+.hc"
#include "string.hc"
#include "buffer.hc"
#include "xdata.hc"
#include "xdef.hc"
#include "url.hc"
#include "file.hc"

#ifdef _BUILTIN
#define _C_XTMPL_BUILTIN
#endif

typedef struct _C_XTMPL_UP
  {
    C_XNODE *tmpl;
    struct _C_XTMPL_UP *up;
  } C_XTMPL_UP;

int Xtmpl_Macro_Template(C_XNODE *n, char *source, char *close_tag);

int Xtmpl_Extends_Template(C_XNODE *n, char *source)
#ifdef _C_XTMPL_BUILTIN 
  {
    char *S_source = source;
    for ( ; *source && *source != '}'; ) ++source;
    
    if ( *source == '}' )
      {
        C_XNODE *cnt = Xnode_Insert(n,"content");
        C_XNODE *ext = Xnode_Append(n,"extends");
        __Auto_Release
          {
            C_BUFFER *bf;
            void *file = 0;
            char *tmpl_home = Xnode_Value_Get_Str(&n->xdata->root,"home",".");
            char *tmpl_source = Str_Join_2('/',tmpl_home,Str_Copy_L(S_source,source-S_source));
            char *e = strrchr(tmpl_source,'.');
            if ( !e || (e && strcmp_I(e,".xtmpl")) ) tmpl_source = Str_Join_2('.',tmpl_source,"xtmpl");
            file = Cfile_Open(tmpl_source,"r");
            bf = Cfile_Read_All(file);
            Xnode_Value_Set_Str(ext,"source",tmpl_source);
            Xtmpl_Macro_Template(ext,bf->at,0);
          }
        ++source;
        return source - S_source + Xtmpl_Macro_Template(cnt,source,0);
      }

    return 0;
  }
#endif
  ;

int Xtmpl_Expand_Template(C_XNODE *n, char *source)
#ifdef _C_XTMPL_BUILTIN 
  {
    char *S_source = source;
    for ( ; *source && *source != '}'; ) ++source;
    
    if ( *source == '}' )
      {
        C_XNODE *ext = Xnode_Append(n,"expand");
        C_XVALUE *val = Xnode_Value(ext,"$",1);
        Xvalue_Set_Str(val,S_source,source-S_source);
        ++source;
        return source - S_source;
      }
      
    return 0;
  }
#endif
  ;

int Xtmpl_Quote_Template(C_XNODE *n, char *source)
#ifdef _C_XTMPL_BUILTIN 
  {
    char *S_source = source;
    for ( ; *source && *source != '}'; ) ++source;
    
    if ( *source == '}' )
      {
        C_XNODE *ext = Xnode_Append(n,"quote");
        C_XVALUE *val = Xnode_Value(ext,"$",1);
        Xvalue_Set_Str(val,S_source,source-S_source);
        ++source;
        return source - S_source;
      }
      
    return 0;
  }
#endif
  ;

int Xtmpl_Dump_Template(C_XNODE *n, char *source)
#ifdef _C_XTMPL_BUILTIN 
  {
    char *S_source = source;
    for ( ; *source && *source != '}'; ) ++source;
    
    if ( *source == '}' )
      {
        C_XNODE *ext = Xnode_Append(n,"dump");
        if ( source != S_source )
          {
            C_XVALUE *val = Xnode_Value(ext,"$",1);
            Xvalue_Set_Str(val,S_source,source-S_source);
          }
        ++source;
        return source - S_source;
      }
      
    return 0;
  }
#endif
  ;

int Xtmpl_Liftup_Template(C_XNODE *n, char *source)
#ifdef _C_XTMPL_BUILTIN 
  {
    char *S_source = source;
    for ( ; *source && *source != '}'; ) ++source;
    
    if ( *source == '}' )
      {
        C_XNODE *ext = Xnode_Append(n,"liftup");
        C_XVALUE *val = Xnode_Value(ext,"$",1);
        Xvalue_Set_Str(val,S_source,source-S_source);
        ++source;
        return source - S_source;
      }
      
    return 0;
  }
#endif
  ;

int Xtmpl_Oper_Template(C_XNODE *n, char *source, char *tag)
#ifdef _C_XTMPL_BUILTIN 
  {
    char *S_source = source;
    for ( ; *source && *source != '}'; ) ++source;
    
    if ( *source == '}' )
      {
        C_XNODE *ext = Xnode_Append(n,tag);
        C_XVALUE *val = Xnode_Value(ext,"$",1);
        Xvalue_Set_Str(val,S_source,source-S_source);
        ++source;
        return source - S_source;
      }
      
    return 0;
  }
#endif
  ;

int Xtmpl_Requr_Template(C_XNODE *n, char *source, char *tag, char *close_tag)
#ifdef _C_XTMPL_BUILTIN 
  {
    char *S_source = source;
    for ( ; *source && *source != '}'; ) ++source;
    
    if ( *source == '}' )
      {
        C_XNODE *ext = Xnode_Append(n,tag);
        char * expr = Str_Trim_Copy_L(S_source,source-S_source);
        if ( expr && *expr )
          {
            C_XVALUE *val = Xnode_Value(ext,"$",1);
            Xvalue_Set_Or_Put_Str(val,expr);
          }
        ++source;
        source += Xtmpl_Macro_Template(ext,source,close_tag);
        if ( *source == '$' )
          {
            if ( source[1] == '!' ) 
              source+=2;
            else if ( source[1] == '/' )
              {
                int L = strlen(close_tag);
                if ( !strncmp(source+2,close_tag,L) ) source += L+2;
              }
          }
        return source - S_source;
      }
      
    return 0;
  }
#endif
  ;

int Xtmpl_Alt_Template(C_XNODE *n, char *source, char *tag, char *close_tag)
#ifdef _C_XTMPL_BUILTIN 
  {
    char *S_source = source;
    for ( ; *source && *source != '}'; ) ++source;
    
    if ( *source == '}' )
      {
        C_XNODE *ext = Xnode_Append(n,tag);
        char *expr = Str_Trim_Copy_L(S_source,source-S_source);
        if ( expr && *expr )
          {
            C_XVALUE *val = Xnode_Value(ext,"$",1);
            Xvalue_Set_Or_Put_Str(val,expr);
          }
        ++source;
        source += Xtmpl_Macro_Template(ext,source,close_tag);
        return source - S_source;
      }
      
    return 0;
  }
#endif
  ;

int Xtmpl_Skip_Comment(C_XNODE *n, char *source)
#ifdef _C_XTMPL_BUILTIN 
  {
    int cmpx = 0;
    char *S_source = source;
    for ( ; *source && (cmpx = strncmp(source,"*/$",3)); ) ++source;
    if ( !cmpx )
      return source+3 - S_source;
    else
      return source - S_source;
  }
#endif
  ;

#ifdef _C_XTMPL_BUILTIN 
void Xtmpl_Append_Text(C_XNODE *n, char *S, int L)
  {
    int oldL = L;
    char *oldS = S;
    while ( L && Isspace(*S) ) { ++S; --L; }
    while ( L && Isspace(S[L-1]) ) { --L; }
    if ( L )
      {
        C_XNODE *k = Xnode_Append(n,"text");
        C_XVALUE *val = Xnode_Value(k,"$",1);
        Xvalue_Set_Str(val,oldS,oldL);
      }
    /*else if ( oldL != L )
      {
        Xnode_Append(n,"space");
      }*/
  }

int Xtmpl_Macro_Template(C_XNODE *n, char *source, char *close_tag)
  {
    static char t_extends[]  = "extends{";
    static char t_liftup[]   = "liftup{";
    static char t_gadget[]   = "gadget{";
    static char t_seleref[]  = "seleref{";
    static char t_dump[]     = "dump{";
    static char t_ifvalue[]  = "ifvalue{";
    static char t_ifgroup[]  = "ifgroup{";
    static char t_switch[]   = "switch{";
    static char t_case[]     = "case{";
    static char t_foreach[]  = "foreach{";
    static char t_else[]     = "else{";
    static char t_match[]    = "match{";
    static char t_def[]      = "def{";
    static char t_set[]      = "set{";
    static char t_repeat[]   = "repeat{";
    static char t_at[]       = "at{";
    static char t_at1[]      = "at1{";
    static char t_inc[]      = "inc{";
    static char t_dec[]      = "dec{";
    static char t_expand[]   = "{";
    static char t_quote[]    = "quote{";
    static char t_comment[]  = "/*";
    char *S_source = source;
    char *Q;
    int close_len = close_tag?strlen(close_tag):0;
    
    for ( Q = source; *source; )
      {
        if ( *source == '$' )
          {
            if ( Q != source )
              {
                Xtmpl_Append_Text(n,Q,source-Q);
                Q = source;
              }
            
            if ( close_tag )
              {
                if ( source[1] == '!' )
                  {
                    break;
                  }
                else if ( source[1] == '/' && !strncmp(source+2,close_tag,close_len) )
                  {
                    break;
                  }
              }
              
            if ( !strncmp(source+1,t_extends,sizeof(t_extends)-1) )
              {
                source += sizeof(t_extends); /* +1 ($) -1 (\0) */
                source += Xtmpl_Extends_Template(n,source);
                Q = source;
              }
            else if ( !strncmp(source+1,t_expand,sizeof(t_expand)-1) )
              {
                source += sizeof(t_expand);
                source += Xtmpl_Expand_Template(n,source);
                Q = source;
              }
            else if ( !strncmp(source+1,t_quote,sizeof(t_quote)-1) )
              {
                source += sizeof(t_quote);
                source += Xtmpl_Quote_Template(n,source);
                Q = source;
              }
            else if ( !strncmp(source+1,t_liftup,sizeof(t_liftup)-1) )
              {
                source += sizeof(t_liftup);
                source += Xtmpl_Liftup_Template(n,source);
                Q = source;
              }
            else if ( !strncmp(source+1,t_gadget,sizeof(t_gadget)-1) )
              {
                source += sizeof(t_gadget);
                source += Xtmpl_Requr_Template(n,source,"gadget","gadget");
                Q = source;
              }
            else if ( !strncmp(source+1,t_def,sizeof(t_def)-1) )
              {
                source += sizeof(t_def);
                source += Xtmpl_Requr_Template(n,source,"def","def");
                Q = source;
              }
            else if ( !strncmp(source+1,t_set,sizeof(t_set)-1) )
              {
                source += sizeof(t_set);
                source += Xtmpl_Requr_Template(n,source,"set","set");
                Q = source;
              }
            else if ( !strncmp(source+1,t_dump,sizeof(t_dump)-1) )
              {
                source += sizeof(t_dump);
                source += Xtmpl_Dump_Template(n,source);
                Q = source;
              }
            else if ( !strncmp(source+1,t_inc,sizeof(t_inc)-1) )
              {
                source += sizeof(t_inc);
                source += Xtmpl_Oper_Template(n,source,"inc");
                Q = source;
              }
            else if ( !strncmp(source+1,t_dec,sizeof(t_dec)-1) )
              {
                source += sizeof(t_dec);
                source += Xtmpl_Oper_Template(n,source,"dec");
                Q = source;
              }
            else if ( !strncmp(source+1,t_seleref,sizeof(t_seleref)-1) )
              {
                source += sizeof(t_seleref);
                source += Xtmpl_Requr_Template(n,source,"seleref","seleref");
                Q = source;
              }
            else if ( !strncmp(source+1,t_ifvalue,sizeof(t_ifvalue)-1) )
              {
                source += sizeof(t_ifvalue);
                source += Xtmpl_Requr_Template(n,source,"ifvalue","ifvalue");
                Q = source;
              }
            else if ( !strncmp(source+1,t_ifgroup,sizeof(t_ifgroup)-1) )
              {
                source += sizeof(t_ifgroup);
                source += Xtmpl_Requr_Template(n,source,"ifgroup","ifgroup");
                Q = source;
              }
            else if ( !strncmp(source+1,t_else,sizeof(t_else)-1) )
              {
                source += sizeof(t_else);
                source += Xtmpl_Alt_Template(n,source,"else",close_tag);
                Q = source;
              }
            else if ( !strncmp(source+1,t_switch,sizeof(t_switch)-1) )
              {
                source += sizeof(t_switch);
                source += Xtmpl_Requr_Template(n,source,"switch","switch");
                Q = source;
              }
            else if ( !strncmp(source+1,t_case,sizeof(t_case)-1) )
              {
                source += sizeof(t_case);
                source += Xtmpl_Alt_Template(n,source,"case",close_tag);
                Q = source;
              }
            else if ( !strncmp(source+1,t_match,sizeof(t_match)-1) )
              {
                source += sizeof(t_match);
                source += Xtmpl_Alt_Template(n,source,"match",close_tag);
                Q = source;
              }
            else if ( !strncmp(source+1,t_foreach,sizeof(t_foreach)-1) )
              {
                source += sizeof(t_foreach);
                source += Xtmpl_Requr_Template(n,source,"foreach","foreach");
                Q = source;
              }
            else if ( !strncmp(source+1,t_repeat,sizeof(t_repeat)-1) )
              {
                source += sizeof(t_repeat);
                source += Xtmpl_Requr_Template(n,source,"repeat","repeat");
                Q = source;
              }
            else if ( !strncmp(source+1,t_at,sizeof(t_at)-1) )
              {
                source += sizeof(t_at);
                source += Xtmpl_Requr_Template(n,source,"at","at");
                Q = source;
              }
            else if ( !strncmp(source+1,t_at1,sizeof(t_at1)-1) )
              {
                source += sizeof(t_at1);
                source += Xtmpl_Requr_Template(n,source,"at1","at1");
                Q = source;
              }
            else if ( !strncmp(source+1,t_comment,sizeof(t_comment)-1) )
              {
                source += sizeof(t_comment);
                source += Xtmpl_Skip_Comment(n,source);
                Q = source;
              }
            else
              {
                Q = source;
                ++source;
              }
          }
        else
          ++source;
      }
      
    if ( Q != source )
      Xtmpl_Append_Text(n,Q,source-Q);

    return source-S_source;
  }
#endif

C_XDATA *Xtmpl_Load_Template(char *tmpl_home, char *tmpl_name)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_XDATA *doc = Xdata_Init();
    
    __Auto_Release
      {
        C_BUFFER *bf;
        char *tmpl_source = Str_Join_2('/',tmpl_home,tmpl_name);
        bf = Cfile_Read_All(Cfile_Open(tmpl_source,"r"));
        Xnode_Value_Set_Str(&doc->root,"home",tmpl_home);
        Xnode_Value_Set_Str(&doc->root,"source",tmpl_source);
        Xtmpl_Macro_Template(&doc->root,bf->at,0);
      }
      
    return doc;
  }
#endif
  ;

void Xtmpl_Handle_Error_Out(C_BUFFER *bf, char *tag, char *text)
#ifdef _C_XTMPL_BUILTIN 
  {
    Buffer_Append(bf,"<span id=\"xtmpl-error\">{",-1);
    Buffer_Append(bf,tag,-1);
    Buffer_Append(bf,":",1);
    Buffer_Html_Quote_Append(bf,text,-1);
    Buffer_Append(bf,"}</span>",-1);
  }
#endif
  ;
  
typedef struct _C_XTMPL_CTX
  {
    C_XDATA *model;
    C_XNODE *each;
    C_XNODE *tmpl;
    char *eachname;
    C_DICTO *global;
  } C_XTMPL_CTX;

void Xtmpl_Handle_Node_Out(C_BUFFER *bf, C_XNODE *n, C_XTMPL_CTX *ctx);

typedef struct _C_XTMPL_MACRO
  {
    C_XNODE *defnode;
    C_XVALUE *value;
  } C_XTMPL_MACRO;
  
void C_XTMPL_MACRO_Destruct(C_XTMPL_MACRO *self)
#ifdef _C_XTMPL_BUILTIN 
  {
    if ( self->value )
      {
        Xvalue_Purge(self->value);
        free(self->value);
      }
    __Destruct(self);
  }
#endif
  ;

typedef struct _C_XTMPL_VALUE
  {
    C_XVALUE value;
  } C_XTMPL_VALUE;

void C_XTMPL_VALUE_Destruct(C_XTMPL_VALUE *self)
#ifdef _C_XTMPL_BUILTIN 
  {
    Xvalue_Purge(&self->value);
    __Destruct(self);
  }
#endif
  ;
  
char *C_XTMPL_MACRO_Out(C_XTMPL_MACRO *self, C_XTMPL_CTX *ctx, C_BUFFER *bf)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_XNODE *t = Xnode_Down(self->defnode);
    int start = bf->count;
    while ( t )
      {
        Xtmpl_Handle_Node_Out(bf,t,ctx);
        t = Xnode_Next(t);
      }
    return bf->at+start;
  }
#endif
  ;
  
C_XVALUE *C_XTMPL_MACRO_Get(C_XTMPL_MACRO *self, C_XTMPL_CTX *ctx)
#ifdef _C_XTMPL_BUILTIN 
  {
    __Auto_Release
      {
        C_BUFFER *bf = Buffer_Init(0);
        if ( !self->value )
          {
            self->value = __Malloc_Npl(sizeof(*self->value));
            self->value->opt = XVALUE_OPT_VALTYPE_NONE;
          }
        C_XTMPL_MACRO_Out(self,ctx,bf);
        Xvalue_Set_Str(self->value,bf->at,bf->count);
      }
    return self->value;
  }
#endif
  ;

char *C_XTMPL_VALUE_Out(C_XTMPL_VALUE *self, C_XTMPL_CTX *ctx, C_BUFFER *bf)
#ifdef _C_XTMPL_BUILTIN 
  {
    return Xvalue_Str_Bf(&self->value,bf);
  }
#endif
  ;
  
C_XVALUE *C_XTMPL_VALUE_Get(C_XTMPL_VALUE *self, C_XTMPL_CTX *ctx)
#ifdef _C_XTMPL_BUILTIN 
  {
    return &self->value;
  }
#endif
  ;
  
#ifdef _C_XTMPL_BUILTIN 
  static char Xtmpl_Out_OjMID[] = "xtmpl$Out/@**";
  static char Xtmpl_Get_OjMID[] = "xtmpl$Get/@*";
#endif
  
C_XTMPL_MACRO *C_XTMPL_MACRO_Init(C_XNODE *defnode)
#ifdef _C_XTMPL_BUILTIN 
  {
    static C_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID, C_XTMPL_MACRO_Destruct},
        {Xtmpl_Out_OjMID,   C_XTMPL_MACRO_Out},
        {Xtmpl_Get_OjMID,   C_XTMPL_MACRO_Get},
        {0}};
    C_XTMPL_MACRO *self = __Object(sizeof(C_XTMPL_MACRO),funcs);
    self->defnode = defnode;
    return self;
  }
#endif
  ;
  
C_XTMPL_VALUE *C_XTMPL_VALUE_Init()
#ifdef _C_XTMPL_BUILTIN 
  {
    static C_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID, C_XTMPL_VALUE_Destruct},
        {Xtmpl_Out_OjMID,   C_XTMPL_VALUE_Out},
        {Xtmpl_Get_OjMID,   C_XTMPL_VALUE_Get},
        {0}};
    C_XTMPL_VALUE *self = __Object(sizeof(C_XTMPL_VALUE),funcs);
    self->value.opt = XVALUE_OPT_VALTYPE_NONE;
    return self;
  }
#endif
  ;
  
void Xtmpl_Call_Gadget(C_XTMPL_CTX *ctx, char *operate, C_BUFFER *bf)
#ifdef _C_XTMPL_BUILTIN 
  {
    Xtmpl_Handle_Error_Out(bf,"gadget","unsupported");
  }
#endif
  ;
  
void Xtmpl_Def_Macro(C_XTMPL_CTX *ctx, C_XNODE *macro)
#ifdef _C_XTMPL_BUILTIN 
  {
    char *name = Xnode_Value_Get_Str(macro,"$",0);
    if ( name )
      {
        void *m = C_XTMPL_MACRO_Init(macro);
        Dicto_Put(ctx->global,name,__Refe(m));
      }
  }
#endif
  ;
  
void Xtmpl_Set_Value(C_XTMPL_CTX *ctx, C_XNODE *setval)
#ifdef _C_XTMPL_BUILTIN 
  {
    char *name = Xnode_Value_Get_Str(setval,"$",0);
    if ( name ) __Auto_Release
      {
        C_XNODE *t;
        C_BUFFER *bf = Buffer_Init(0);
        C_XTMPL_VALUE *m = C_XTMPL_VALUE_Init();
        Dicto_Put(ctx->global,name,__Refe(m));
        t = Xnode_Down(setval);
        while ( t )
          {
            Xtmpl_Handle_Node_Out(bf,t,ctx);
            t = Xnode_Next(t);
          }
        Xvalue_Set_Str(&m->value,bf->at,bf->count);
      }
  }
#endif
  ;
  
void Xtmpl_Inc_Value(C_XTMPL_CTX *ctx, C_XNODE *incval)
#ifdef _C_XTMPL_BUILTIN 
  {
    char *name = Xnode_Value_Get_Str(incval,"$",0);
    if ( name ) __Auto_Release
      {
        C_XTMPL_VALUE *m = Dicto_Get(ctx->global,name,0);
        if ( m )
          {
            int q = Xvalue_Get_Int(&m->value,0);
            Xvalue_Set_Str(&m->value,Str_From_Int(q+1),-1);
          }
        else
          {
            C_XTMPL_VALUE *m = C_XTMPL_VALUE_Init();
            Dicto_Put(ctx->global,name,__Refe(m));
            Xvalue_Set_Str(&m->value,"0",1);
          }
      }
  }
#endif
  ;

C_XNODE *Xtmpl_Query_Node(C_XTMPL_CTX *ctx, char *query)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_XNODE *n = 0;
    if ( query && ((*query == '$' && (query[1] == '.' || !query[1])) || *query == '.' ) )
      {
        if ( ctx->each )
          {
            if ( *query == '.' ) 
              n = Xnode_Query_Node(ctx->each,query+1);
            else if ( query[1] == '.' ) 
              n = Xnode_Query_Node(ctx->each,query+2);
            else
              n = ctx->each;
          }
      }
    else if ( query )
      n = Xnode_Query_Node(&ctx->model->root,query);
    return n;
  }
#endif
  ;

C_XVALUE *Xtmpl_Query_Value(C_XTMPL_CTX *ctx, char *query)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_XVALUE *v = 0;
    if ( query && ( (*query == '$' && (query[1] == '.' || !query[1])) || *query == '.' ) )
      {
        if ( ctx->each )
          {
            if ( *query == '.' ) 
              {
                if ( query[1] == '@' && !query[2] )
                  v = Xnode_Value(ctx->each,"@",0);
                else
                  v = Xnode_Query_Value(ctx->each,query+1);
              }
            else if ( query[1] == '.' ) 
              v = Xnode_Query_Value(ctx->each,query+2);
            else
              v = Xnode_Value(ctx->each,"$",0);
          }
      }
    else if ( query ) 
      {
        void *g = Dicto_Get(ctx->global,query,0);
        if ( g )
          {
            C_XVALUE *(*getval)() = C_Find_Method_Of(&g,Xtmpl_Get_OjMID,0);
            return getval ? getval(g,ctx) : 0;
          }
        else
          v = Xnode_Query_Value(&ctx->model->root,query);
      }
    //fprintf(stderr,"Xtmpl_Query_Value '%s' => %p\n",query,v);
    return v;
  }
#endif
  ;
  
char *Xtmpl_Query_Str_Bf(C_XTMPL_CTX *ctx, char *query, C_BUFFER *bf)
#ifdef _C_XTMPL_BUILTIN 
  {
    void *g = 0;
    
    char *S = strchr(query,':');
    if ( S ) 
      {
        char *Q = 0;
        __Auto_Release 
          {
            Q = Str_Copy_L(query,S-query);
            Q = Xtmpl_Query_Str_Bf(ctx,Q,bf);
          }
        if ( Q ) return Q;
        else 
          {
            int start = bf->count;
            Buffer_Append(bf,S+1,-1);
            return bf->at+start;
          }
      }
    
    if ( 0 != ( g = Dicto_Get(ctx->global,query,0)) )
      {
        char *(*outval)() = C_Find_Method_Of(&g,Xtmpl_Out_OjMID,0);
        return outval ? outval(g,ctx,bf) : 0;
      }
    else
      {
        C_XVALUE *v = Xtmpl_Query_Value(ctx,query);
        return Xvalue_Str_Bf(v,bf);
      }
  }
#endif
  ;

void Xtmpl_Dump_Tmpl(C_BUFFER *bf, C_XNODE *tmpl)
#ifdef _C_XTMPL_BUILTIN 
  {
    Buffer_Append(bf,"<pre style='text-align:left'>\n",-1);
    Def_Format_Into(bf,tmpl,0);
    Buffer_Append(bf,"</pre>\n",-1);
  }
#endif
  ;
  
void Xtmpl_Handle_Dump_Out(C_BUFFER *bf, C_XNODE *n, C_XTMPL_CTX *ctx)
#ifdef _C_XTMPL_BUILTIN 
  {
    char *query = Xnode_Value_Get_Str(n,"$",0);
    Buffer_Append(bf,"<pre style='text-align:left'>\n",-1);
    if ( query )
      {
        C_XNODE *nn = 0;
        if ( !strcmp(query,"#xtmpl") )
          nn = ctx->tmpl;
        else
          nn = Xtmpl_Query_Node(ctx,query);
        
        if (nn) Buffer_Html_Quote_Append(bf,Def_Format(nn,0),-1);
      }
    else
      Def_Format_Into(bf,&ctx->model->root,0);
    Buffer_Append(bf,"</pre>\n",-1);
  }
#endif
  ;
  
void Xtmpl_Handle_Ifvalue_Out(C_BUFFER *bf, C_XNODE *n, C_XTMPL_CTX *ctx)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_XNODE *down = Xnode_Down(n);
    char *query = Xnode_Value_Get_Str(n,"$",0);
    if ( (query && Xtmpl_Query_Value(ctx,query)) || (!query && Xnode_Tag_Is(n,"else")) )
      {
        while ( down )
          {
            Xtmpl_Handle_Node_Out(bf,down,ctx);
            down = Xnode_Next(down);
          }
      }
    else
      {
        C_XNODE *el = Xnode_Down_If(n,"else");
        if ( el )
          Xtmpl_Handle_Ifvalue_Out(bf,el,ctx);
      }
  }
#endif
  ;
  
void Xtmpl_Handle_Ifgroup_Out(C_BUFFER *bf, C_XNODE *n, C_XTMPL_CTX *ctx)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_XNODE *down = Xnode_Down(n);
    char *query = Xnode_Value_Get_Str(n,"$",0);
    C_XNODE *node = query ? Xtmpl_Query_Node(ctx,query) : 0;
    if ( node || (!query && Xnode_Tag_Is(n,"else")) )
      {
        C_XTMPL_CTX ctx1 = *ctx;
        if ( node ) ctx1.each = node;
        while ( down )
          {
            Xtmpl_Handle_Node_Out(bf,down,&ctx1);
            down = Xnode_Next(down);
          }
      }
    else
      {
        C_XNODE *el = Xnode_Down_If(n,"else");
        if ( el )
          Xtmpl_Handle_Ifgroup_Out(bf,el,ctx);
      }
  }
#endif
  ;

char *Xtmpl_Complete(char *val,C_XTMPL_CTX *ctx)
#ifdef _C_XTMPL_BUILTIN 
  {
    char *S, *Q;
    C_BUFFER *b = 0;

    S = strchr(val,'(');
    if ( !S ) return val;

    if ( !b ) b = Buffer_Init(0);
    __Auto_Release while ( *val && S ) 
      {
        Buffer_Append(b,val,S-val);
        val = S+1;
        S = strchr(val,')');
        if ( !S ) break;
        Q = Str_Copy_L(val,S-val);
        Xtmpl_Query_Str_Bf(ctx,Q,b);
        val = S+1;
        S = strchr(val,'(');
      }        
      
    if ( *val ) Buffer_Append(b,val,-1);
    return Buffer_Take_Data(b);
  }
#endif
  ;
  
void Xtmpl_Handle_Seleref_Out(C_BUFFER *bf, C_XNODE *n, C_XTMPL_CTX *ctx)
#ifdef _C_XTMPL_BUILTIN 
  {
    int is_it;
    C_URL *url;
    C_XNODE *down = Xnode_Down(n);
    char *ref = Xnode_Value_Get_Str(n,"$",0);
    char *rqst_ref = Xnode_Value_Get_Str(&ctx->model->root,"#request-file",0);
    
    ref = Xtmpl_Complete(ref,ctx);
    url = Url_Parse_(ref,URLX_PARSE_HOST_IF_PROTO);
    is_it = ref && Str_Equal_Nocase(rqst_ref,Path_Basename(url->uri));
    if ( is_it ) Buffer_Append(bf,"<span class=\"selfref\">",-1);
    else 
      {
        Buffer_Append(bf,"<a class=\"selfref\" href=\"",-1);
        Buffer_Append(bf,ref,-1);
        Buffer_Append(bf,"\">",-1);
      }
    while ( down )
      {
        Xtmpl_Handle_Node_Out(bf,down,ctx);
        down = Xnode_Next(down);
      }
    if ( is_it ) Buffer_Append(bf,"</span>",-1);
    else Buffer_Append(bf,"</a>",-1);
  }
#endif
  ;
  
void Xtmpl_Handle_Switch_Out(C_BUFFER *bf, C_XNODE *n, C_XTMPL_CTX *ctx)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_XNODE *down = n;
    C_XVALUE *value = 0;
    char *S = 0;
    char *query = Xnode_Value_Get_Str(n,"$",0);
    if ( query ) 
      value = Xtmpl_Query_Value(ctx,query);
    if ( value )
      S = Xvalue_Get_Str(value,0);
    while ( down )
      {
        C_XNODE *Match = 0, *Case;
        Case = Xnode_Down_If(down,"case");
        if ( !Case ) Match = Xnode_Down_If(down,"match");
        if ( Case || Match )
          {
            int ok = 0;
            if ( Case )
              {
                char *opt = Xnode_Value_Get_Str(Case,"$",0);
                ok = (!opt || !*opt) || (S && !strcmp_I(opt,S));
                down = Case;
              }
            else /* Match */
              {
                char *opt = Xnode_Value_Get_Str(Match,"$",0);
                ok = (!opt || !*opt) || (S && Str_Match_Nocase(S,opt));
                down = Match;
              }

            if ( ok )
              {
                down = Xnode_Down(down);
                while ( down )
                  {
                    Xtmpl_Handle_Node_Out(bf,down,ctx);
                    down = Xnode_Next(down);
                  }
                break;
              }
          }
        else
          down = 0;
      }
  }
#endif
  ;
  
void Xtmpl_Handle_Foreach_Out(C_BUFFER *bf, C_XNODE *n, C_XTMPL_CTX *ctx)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_XNODE *down = Xnode_Down(n);
    C_XNODE *foo = 0;
    C_XTMPL_CTX ctx1 = *ctx;
    char *tag;
    char *query = Xnode_Value_Get_Str(n,"$",0);
    char period = Str_Last(query) == ',' ? ',' : 0;
    if ( period ) query = Str_Copy_L(query,Str_Length(query)-1);
    if ( query )
      foo = Xtmpl_Query_Node(ctx,query);
    if ( foo ) tag = Xnode_Get_Tag(foo);
    while ( foo )
      {
        C_XNODE *t = down;
        ctx1.each = foo;
        while ( t )
          {
            Xtmpl_Handle_Node_Out(bf,t,&ctx1);
            t = Xnode_Next(t);
          }
        foo = Xnode_Next_If(foo,tag);
        if ( period )
          {
            if ( foo ) Buffer_Append(bf,&period,1);
          } 
      }
  }
#endif
  ;
  
void Xtmpl_Handle_At_Out(C_BUFFER *bf, C_XNODE *n, C_XTMPL_CTX *ctx, int shift)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_XNODE *down = Xnode_Down(n);
    C_XNODE *foo = 0;
    C_XTMPL_CTX ctx1 = *ctx;
    C_ARRAY *q0 = 0;
    char *query = Xnode_Value_Get_Str(n,"$",0);
    if ( query )
      q0 = Str_Split(query,0);
    if ( q0 && q0->count == 2)
      foo = Xtmpl_Query_Node(ctx,q0->at[0]);
    if ( foo ) 
      {
        int i;
        char *tag;
        i = Str_To_Int(Xvalue_Get_Str(Xtmpl_Query_Value(ctx,q0->at[1]),"0")) - shift;
        tag = Xnode_Get_Tag(foo);
        for ( ; foo && i > 0; --i )
          foo = Xnode_Next_If(foo,tag);   
        if ( foo )
          {
            C_XNODE *t = down;
            ctx1.each = foo;
            while ( t )
              {
                Xtmpl_Handle_Node_Out(bf,t,&ctx1);
                t = Xnode_Next(t);
              }
          }   
      }
  }
#endif
  ;

void Xtmpl_Handle_Repeat_Out(C_BUFFER *bf, C_XNODE *n, C_XTMPL_CTX *ctx)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_XNODE *down = Xnode_Down(n);
    C_XTMPL_CTX ctx1 = *ctx;
    char *count_S = Xnode_Value_Get_Str(n,"$","0");
    int i, count = strtol(count_S,0,0);
    char period = Str_Last(count_S) == ',' ? ',' : 0;
    __Auto_Release 
      {
        C_XNODE *foo  = Xdata_Init();

        for ( i = 0; i < count; ++i )
          {
            C_XNODE *t = down;
            Xnode_Value_Set_Str(foo,"repno",Str_From_Int(i));
            ctx1.each = foo;

            while ( t )
              {
                Xtmpl_Handle_Node_Out(bf,t,&ctx1);
                t = Xnode_Next(t);
              }
              
            if ( period && i+1 < count )
              {
                Buffer_Append(bf,&period,1);
              } 
          }
      }
   }
#endif
  ;

void Xtmpl_Handle_Node_Out(C_BUFFER *bf, C_XNODE *n, C_XTMPL_CTX *ctx)
#ifdef _C_XTMPL_BUILTIN 
  {
    if ( Xnode_Tag_Is(n,"text") )
      {
        char *value = Xnode_Value_Get_Str(n,"$",0);
        Buffer_Append(bf,value,-1);
      }
    else if ( Xnode_Tag_Is(n,"space") )
      {
        Buffer_Fill_Append(bf,' ',1);
      }
    else if ( Xnode_Tag_Is(n,"expand") )
      {
        int i;
        char *query = Xnode_Value_Get_Str(n,"$",0);
        C_ARRAY *L = Str_Split(query,",");
        for ( i = 1; i < L->count; ++i )
          {
            C_XTMPL_VALUE *m = C_XTMPL_VALUE_Init();
            char S[3];
            sprintf(S,"%d",i);
            Dicto_Put(ctx->global,S,__Refe(m));
            Xvalue_Set_Str(&m->value,L->at[i],strlen(L->at[i]));
          }
        Xtmpl_Query_Str_Bf(ctx,L->at[0],bf);
      }
    else if ( Xnode_Tag_Is(n,"quote") )
      {
        int i;
        char *query = Xnode_Value_Get_Str(n,"$",0);
        C_XVALUE *m = Xtmpl_Query_Value(ctx,query);
        if ( m ) Buffer_Quote_Append(bf,Xvalue_Get_Str(m,""),-1,0);
      }
    else if ( Xnode_Tag_Is(n,"def") )
      {
        Xtmpl_Def_Macro(ctx,n);
      }
    else if ( Xnode_Tag_Is(n,"set") )
      {
        Xtmpl_Set_Value(ctx,n);
      }
    else if ( Xnode_Tag_Is(n,"inc") )
      {
        Xtmpl_Inc_Value(ctx,n);
      }
    else if ( Xnode_Tag_Is(n,"gadget") )
      {
        char *operate = Xnode_Value_Get_Str(n,"$",0);
        Xtmpl_Call_Gadget(ctx,operate,bf);
      }
    else if ( Xnode_Tag_Is(n,"dump") )
      Xtmpl_Handle_Dump_Out(bf,n,ctx);
    else if ( Xnode_Tag_Is(n,"seleref") )
      Xtmpl_Handle_Seleref_Out(bf,n,ctx);
    else if ( Xnode_Tag_Is(n,"ifvalue") )
      Xtmpl_Handle_Ifvalue_Out(bf,n,ctx);
    else if ( Xnode_Tag_Is(n,"ifgroup") )
      Xtmpl_Handle_Ifgroup_Out(bf,n,ctx);
    else if ( Xnode_Tag_Is(n,"switch") )
      Xtmpl_Handle_Switch_Out(bf,n,ctx);
    else if ( Xnode_Tag_Is(n,"foreach") )
      Xtmpl_Handle_Foreach_Out(bf,n,ctx);
    else if ( Xnode_Tag_Is(n,"repeat") )
      Xtmpl_Handle_Repeat_Out(bf,n,ctx);
    else if ( Xnode_Tag_Is(n,"at") )
      Xtmpl_Handle_At_Out(bf,n,ctx,0);
    else if ( Xnode_Tag_Is(n,"at1") )
      Xtmpl_Handle_At_Out(bf,n,ctx,1);
    else
      /* skip */
      ;
  }
#endif
  ;

void Xtmpl_Step_Up(C_BUFFER *bf, C_XTMPL_UP *up, char *content, C_XTMPL_CTX *ctx)
#ifdef _C_XTMPL_BUILTIN 
  {
    if ( up )
      {
        C_XNODE *n = Xnode_Down_If(up->tmpl,"content");
        if ( !n ) n = up->tmpl;
        n = Xnode_Down(n);
        while ( n )
          {
            if ( Xnode_Tag_Is(n,"liftup") )
              {
                C_XTMPL_CTX ctx1 = *ctx;
                Xtmpl_Step_Up(bf,up->up,Xnode_Value_Get_Str(n,"$","content"),&ctx1);
              }
            else
              {
                Xtmpl_Handle_Node_Out(bf,n,ctx);
              }
            n = Xnode_Next(n);
          }
      }
  }
#endif
  ;

void Xtmpl_Step_Down_Global_Set(C_XNODE *tmpl, C_XNODE *end, C_DICTO *global, C_XDATA *model)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_XNODE *n;
    C_BUFFER *bf = Buffer_Init(0);
    C_XTMPL_CTX ctx = {0};
    ctx.model  = model;
    ctx.each   = &model->root;
    ctx.global = global;
    n = Xnode_Down(tmpl);
    while ( n != end )
      {
        if ( Xnode_Tag_Is(n,"liftup") )
          __Raise(C_ERROR_ILLFORMED,"liftup is found before extends");
        else
          Xtmpl_Handle_Node_Out(bf,n,&ctx);
        n = Xnode_Next(n);
      }
  }
#endif
  ;
  
#ifdef _C_XTMPL_BUILTIN 
void Xtmpl_Glob_Set(char *key, char *val, C_DICTO *glob)
  {
      C_XNODE *t;
      C_BUFFER *bf = Buffer_Init(0);
      C_XTMPL_VALUE *m = C_XTMPL_VALUE_Init();
      Dicto_Put(glob,key,__Refe(m));
      Xvalue_Set_Str(&m->value,val,-1);
  }
#endif
  
void Xtmpl_Step_Down(C_BUFFER *bf, C_XNODE *tmpl, C_XDATA *model, C_DICTO *glob)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_DICTO *global = Dicto_Refs();
    C_XTMPL_UP upstep_q[32] = { {tmpl, 0}, };
    C_XNODE *down; 
    C_XTMPL_UP *upstep = upstep_q;
    
    Dicto_Apply(glob,Xtmpl_Glob_Set,global);
    
    for ( down = Xnode_Down_If(tmpl,"extends"); down; )
      {
        Xtmpl_Step_Down_Global_Set(upstep->tmpl,down,global,model);
        upstep[1].up = upstep;
        ++upstep;
        upstep->tmpl = down;
        down = Xnode_Down_If(down,"extends");
      }
      
    fflush(stderr);
    
    __Gogo
      {
        C_XTMPL_CTX ctx = {0};
        ctx.model  = model;
        ctx.each   = &model->root;
        ctx.global = global;
        ctx.tmpl   = tmpl;
        Xtmpl_Step_Up(bf,upstep,"content",&ctx);
      }
  }
#endif
  ;

char *Xtmpl_Produce_Out(C_BUFFER *bf, C_XDATA *tmpl, C_XDATA *model, C_DICTO *glob)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_BUFFER *xbf = bf;
    if ( !xbf ) xbf = Buffer_Init(0);
    Buffer_Append(bf,"\n",1);
    Xtmpl_Step_Down(bf,&tmpl->root,model,glob);
    return bf?xbf->at:Buffer_Take_Data(xbf);
  }
#endif
  ;

#ifdef _C_XTMPL_BUILTIN 

static C_DICTO *Xtmpl_Cache_Dicto = 0;

void Xtmpl_Release_Chache_Dicto()
  {
    __Unrefe(Xtmpl_Cache_Dicto);
  }
  
C_DICTO *Xtmpl_Autoload_Dicto()
  {
    __Xchg_Interlock
      if ( !Xtmpl_Cache_Dicto )
        {
          Xtmpl_Cache_Dicto = __Refe(Dicto_Refs());
          atexit((void*)Xtmpl_Release_Chache_Dicto);
        }
    return Xtmpl_Cache_Dicto;
  }

C_XDATA *Xtmpl_Cache_Template(char *root, char *S, char *lang)
  {
    C_XDATA *doc = 0;
    C_DICTO *dt = Xtmpl_Autoload_Dicto();
    void *reco = Dicto_Get(dt,S,&doc);
    if ( reco != &doc )
      doc = reco;
    else
      {
        __Try_Ptr(doc)
          {
            C_XNODE *n;
            doc = Xtmpl_Load_Template(root,S);
            if ( lang ) 
              {
                n = Xnode_Insert(&doc->root,"set");
                Xnode_Value_Set_Str(n,"$","#language");
                n = Xnode_Insert(n,"text");
                Xnode_Value_Set_Str(n,"$",lang);
              }
          }
        __Catch(C_ERROR_DOESNT_EXIST) ;
        Dicto_Put(dt,S,__Refe(doc)); /* doc can be NULL */
      }
    return doc;
  }

#endif

void Xtmpl_Drop_Cache()
#ifdef _C_XTMPL_BUILTIN 
  {
    if ( Xtmpl_Cache_Dicto )
      {
        __Unrefe(Xtmpl_Cache_Dicto);
        Xtmpl_Cache_Dicto = __Refe(Dicto_Refs());
      }
  }
#endif
  ;
  
C_XDATA *Xtmpl_Autoload(char *root,  char *name, char **langlist /*zero terminated langiages list*/)
#ifdef _C_XTMPL_BUILTIN 
  {
    C_XDATA *doc = 0;
    __Auto_Release /* document is retaining by template cache */
      {
        if (langlist) for ( ; !doc && *langlist; ++langlist )
          {
            char *S = Str_Join_3('.',name,*langlist,"xtmpl");
            doc = Xtmpl_Cache_Template(root,S,*langlist);
          }
        if ( !doc )
          {
            char *S = Str_Join_2('.',name,"xtmpl");
            doc = Xtmpl_Cache_Template(root,S,0);
          }
      }
    if ( !doc )
      __Raise_Format(C_ERROR_DOESNT_EXIST,("template %s doesn't exist at %s",name,root));
    return doc;
  }
#endif
  ;
  
#endif /* C_once_40BDAC30_45A4_4FC1_810C_05757F2DC413 */

