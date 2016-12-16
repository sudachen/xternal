
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_9163E833_294D_46EF_8F36_5F86432BD5F8
#define C_once_9163E833_294D_46EF_8F36_5F86432BD5F8

#ifdef _BUILTIN
#define _C_JSON_BUILTIN
#endif

#include "C+.hc"
#include "string.hc"
#include "buffer.hc"
#include "xdata.hc"
#include "file.hc"
#include "ctoken.hc"
#include "xdef.hc"

void Json_Parse_Block(C_CTOKST *a, C_XNODE *n, C_BUFFER *bf1, C_BUFFER *bf2)
#ifdef _C_JSON_BUILTIN
  {
    C_XVALUE *val;
    C_ARRAY *arr;
    C_XNODE *n2;
    int tk;
    for(;;)
      {
        tk = Ctok_Token(a,bf1);
        if ( tk != C_CTOKEN_CSTRING && tk != '}' )
          __Raise_Format(C_ERROR_ILLFORMED,("JSON expects string or '}' at %s:%d:%d",a->source,a->lineno,a->charno));
        if ( tk == '}' )
          break;
          
        tk = Ctok_Token(a,0);
        if ( tk != ':' )
          __Raise_Format(C_ERROR_ILLFORMED,("JSON expects ':' at %s:%d:%d",a->source,a->lineno,a->charno));
        tk = Ctok_Token(a,bf2);
        if ( tk == '{' )
          {
            n2 = Xnode_Append(n,bf1->at);
            Json_Parse_Block(a,n2,bf1,bf2);
          }
        else if ( tk == '[' )
          {
            tk = Ctok_Token(a,bf2);
            if ( tk == '{' ) 
              {
                n2 = Xnode_Append(n,bf1->at);
                for (;;)
                  {
                    Json_Parse_Block(a,n2,bf1,bf2);
                    tk = Ctok_Token(a,bf2);
                    if ( tk != ']' && tk != ',' )
                      __Raise_Format(C_ERROR_ILLFORMED,("JSON expects ']' or ',' at %s:%d:%d",a->source,a->lineno,a->charno));
                    if ( tk == ']' ) break;
                    if ( Ctok_Token(a,bf2) != '{' )
                      __Raise_Format(C_ERROR_ILLFORMED,("JSON expects '{' at %s:%d:%d",a->source,a->lineno,a->charno));
                    n2 = Xnode_Append(n,Xnode_Get_Tag(n2));
                  }
              }
            else if ( tk == ']' )
              {
                /* empty array */
                val = Xnode_Value(n,bf1->at,1);
                Xvalue_Put_Str_Array(val,__Retain(Array_Ptrs()));
              }
            else
              {
                /* array of strings */
                val = Xnode_Value(n,bf1->at,1);
                arr = Array_Ptrs();
                for (;;)
                  {
                    switch( tk )
                      {
                      dafault:
                        __Raise_Format(C_ERROR_ILLFORMED,("JSON expects value at %s:%d:%d",a->source,a->lineno,a->charno));
                      case C_CTOKEN_CSTRING:
                      case C_CTOKEN_DIGITS:
                      case C_CTOKEN_XDIGITS:
                      case C_CTOKEN_FLOAT:
                        Array_Push(arr,Str_Copy_Npl(bf2->at,-1));
                      }
                    tk = Ctok_Token(a,bf2);
                    if ( tk != ']' && tk != ',' )
                      __Raise_Format(C_ERROR_ILLFORMED,("JSON expects ']' or ',' at %s:%d:%d",a->source,a->lineno,a->charno));
                    if ( tk == ']' ) 
                      break;
                    tk = Ctok_Token(a,bf2);
                    if ( tk == '{' )
                      __Raise_Format(C_ERROR_ILLFORMED,("JSON disallow objects and values in one array at %s:%d:%d",a->source,a->lineno,a->charno));
                  }
                Xvalue_Put_Str_Array(val,__Retain(arr));
              }            
          }
        else
          {
            val = Xnode_Value(n,bf1->at,1);
            switch ( tk )
              {
              default:
              bad_value:
                __Raise_Format(C_ERROR_ILLFORMED,("JSON expects value at %s:%d:%d",a->source,a->lineno,a->charno));
              case C_CTOKEN_CSTRING:
                Xvalue_Set_Str(val,bf2->at,-1);
                break;
              case C_CTOKEN_DIGITS:
              case C_CTOKEN_XDIGITS:
                Xvalue_Set_Int(val,strtol(bf2->at,0,0));
                break;
              case C_CTOKEN_FLOAT:
                Xvalue_Set_Flt(val,strtod(bf2->at,0));
                break;
              case C_CTOKEN_ID:
                if ( !strcmp(bf2->at,"true") )
                  Xvalue_Set_Bool(val,1);
                else if ( !strcmp(bf2->at,"false") )
                  Xvalue_Set_Bool(val,0);
                else if ( !strcmp(bf2->at,"null") )
                  ;
                else goto bad_value;
                break;
              }
          }
          
        tk = Ctok_Token(a,0);
        if ( tk != ',' && tk != '}' )
          __Raise_Format(C_ERROR_ILLFORMED,("JSON expects ',' or '}' at %s:%d:%d",a->source,a->lineno,a->charno));
        if ( tk == '}' )
          break;
      }
  }
#endif
  ;
  
C_XDATA *Json_Parse_Text(char *text, char *source)
#ifdef _C_JSON_BUILTIN
  {
    C_CTOKST a; 
    C_BUFFER *bf1,*bf2;
    C_XNODE  *n = Xdata_Init();
    
    __Auto_Ptr(n)
      {
        Ctok_Init(&a,text,text+strlen(text),source);
        bf1 = Buffer_Init(0);
        bf2 = Buffer_Init(0);
        
        if ( Ctok_Token(&a,0) == '{' )
          Json_Parse_Block(&a,n,bf1,bf2);
        else
          __Raise_Format(C_ERROR_ILLFORMED,("JSON expects '{' at %s:%d:%d",a.source,a.lineno,a.charno));
      }
      
    return n->xdata;
  }
#endif
  ;
  
C_XDATA *Json_Parse_Str(char *text)
#ifdef _C_JSON_BUILTIN
  {
    return Json_Parse_Text(text,"<str>");
  }
#endif
  ;

C_XDATA *Json_Parse_File(char *filename)
#ifdef _C_JSON_BUILTIN
  {
    C_XDATA *ret = 0;
    
    __Auto_Ptr(ret)
      {
        C_BUFFER *bf = Oj_Read_All(Cfile_Open(filename,"rt"));
        ret = Json_Parse_Text((char*)bf->at,filename);
      }
      
    return ret;
  }
#endif
  ;

char *Json_Format_Into(C_BUFFER *bf, C_XNODE *r, int flags)
#ifdef _C_JSON_BUILTIN
  {
    int indent = (flags&0xff);
    if ( !bf ) bf = Buffer_Init(0);
    Buffer_Append(bf,"{\n",2);
    Def_Format_Node_In_Depth(bf,r,flags|XDEF_FORMAT_JSON,indent+1);
    Buffer_Append(bf,"}\n",2);
    return (char*)bf->at;
  }
#endif
  ;
  
char *Json_Format(C_XNODE *r, int flags)
#ifdef _C_JSON_BUILTIN
  {
    char *ret = 0;
    __Auto_Ptr(ret)
      {
        C_BUFFER *bf = Buffer_Init(0);
        Json_Format_Into(bf,r,flags);
        ret = Buffer_Take_Data(bf);
      }
    return ret;
  }
#endif
  ;

void Json_Format_File(char *fname, C_XNODE *r, int flags)
#ifdef _C_JSON_BUILTIN
  {
    __Auto_Release
      {
        C_BUFFER *bf = Buffer_Init(0);
        Json_Format_Into(bf,r,flags);
        Oj_Write_Full(Cfile_Open(fname,"w+P"),bf->at,bf->count);
      }
  }
#endif
  ;

#endif /* C_once_750A77B2_260B_4E33_B9EA_15F01DDD61FF */

