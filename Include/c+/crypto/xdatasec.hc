
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_9CC5C44A_A9F9_40B3_85DA_10A2EE2AD4FC
#define C_once_9CC5C44A_A9F9_40B3_85DA_10A2EE2AD4FC

#include "../xdata.hc"
#include "sha1.hc"
#include "sha2.hc"
#include "md5.hc"
#include "bigint.hc"

#ifdef _BUILTIN
  #define _C_XDATASEC_BUILTIN
#endif

C_ARRAY *Xnode_Sorted_Names(C_XNODE *n)
#ifdef _C_XDATASEC_BUILTIN
  {
    char      *tag; 
    ushort_t  next;
    C_XDATA  *doc;
    C_XNODE  *nod;
    C_XVALUE *val;
    C_ARRAY  *a = Array_Void();
    __Object_Extend(a,Oj_Compare_Elements_OjMID,strcmp);
    
    n = Xnode_Refacc(n);
    STRICT_REQUIRE( (n->opt&XVALUE_OPT_IS_VALUE) == 0 );
    
    doc = n->xdata;
    next = n->opt;
    
    while ( next )
      {
        val = (C_XVALUE *)Xdata_Idxref(doc,next);
        tag = doc->tags[val->tag-1];
        if ( !Str_Starts_With(tag,"$$") )
          Array_Sorted_Insert(a,tag);
        next = val->next;
      }
      
    next = n->down;
    while ( next )
      {
        nod = (C_XNODE *)Xdata_Idxref(doc,next);
        tag = doc->tags[nod->tag-1];
        if ( !Str_Starts_With(tag,"$$") )
          Array_Sorted_Insert(a,tag);
        next = nod->next;
      }

    return a;    
  }      
#endif
  ;

void Xvalue_Normal_Print(C_XVALUE *val, C_BUFFER *bf)
#ifdef _C_XDATASEC_BUILTIN
  {__Auto_Release {
    int i;
    byte_t dgst[16];
    char   hexdgst[33];
    
    switch ( val->opt&XVALUE_OPT_VALTYPE_MASK )
      {
      case XVALUE_OPT_VALTYPE_NONE:
        Buffer_Append(bf,"\0\0",2);
        break;
      case XVALUE_OPT_VALTYPE_BOOL:
        Buffer_Append(bf,(val->bval?"1":"0"),1);
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
        Buffer_Append(bf,val->txt,-1);
        break;
      case XVALUE_OPT_VALTYPE_LIT:
        Buffer_Append(bf,(char*)&val->down,-1);
        break;
      case XVALUE_OPT_VALTYPE_BIN:
        Md5_Digest(val->binary->at,val->binary->count,dgst);
        Str_Hex_Encode_(dgst,16,hexdgst);
        Buffer_Fill_Append(bf,'\3',1);
        Buffer_Append(bf,hexdgst,32);
      case XVALUE_OPT_VALTYPE_STR_ARR:
        Buffer_Fill_Append(bf,'[',1);
        for ( i = 0; i < val->strarr->count; ++i )
          {
            Buffer_Fill_Append(bf,'\1',1);
            Buffer_Append(bf,val->strarr->at[i],-1);
          }
        Buffer_Fill_Append(bf,']',1);
        break;
      case XVALUE_OPT_VALTYPE_FLT_ARR:
        for ( i = 0; i+iszof_double <= val->binary->count; i+=iszof_double )
          {
            double d = *(double*)(val->binary->at+i*iszof_double);
            Buffer_Fill_Append(bf,'\1',1);
            if ( (d - (double)((long)d)) > 0.000999999 )
              Buffer_Printf(bf,"%.3f",d);
            else
              Buffer_Printf(bf,"%.f",d);
          }
        break;
      }   
  }}
#endif
  ;

void Xnode_Normal_Print(C_XNODE *n, C_BUFFER *bf)
#ifdef _C_XDATASEC_BUILTIN
  {__Auto_Release {
    int i;
    C_ARRAY *a = Xnode_Sorted_Names(n);
    
    Buffer_Fill_Append(bf,'{',1);
    for( i = 0; i < a->count; ++i )
      {
        C_XNODE  *nod, *next;
        C_XVALUE *val = Xnode_Value(n,a->at[i],0);
  
        Buffer_Fill_Append(bf,'\1',1);
  
        if ( val )
          {
            Buffer_Append(bf,a->at[i],-1);
            Buffer_Fill_Append(bf,'\2',1);
            Xvalue_Normal_Print(val,bf);
          }
  
        nod = Xnode_Down_If(n,a->at[i]);
        next = Xnode_Next_If(nod,a->at[i]);
  
        if ( val && nod )
          Buffer_Fill_Append(bf,'\1',1);

        if ( nod )
          {    
            Buffer_Append(bf,a->at[i],-1);
            Buffer_Fill_Append(bf,'\2',1);
        
            if ( next )
              {
                Buffer_Fill_Append(bf,'[',1);
                Buffer_Fill_Append(bf,'\1',1);
              }
              
            Xnode_Normal_Print(nod,bf);

            while ( next )
              {
                Buffer_Fill_Append(bf,'\1',1);
                Xnode_Normal_Print(next,bf);
                next = Xnode_Next_If(next,a->at[i]);
                if ( !next )
                  Buffer_Fill_Append(bf,']',1);
              }
          }
      }
    Buffer_Fill_Append(bf,'}',1);
  }}
#endif
  ;

void Xdata_Sha1_Digest_Update(C_XDATA *xdata,byte_t dgst[20])
#ifdef _C_XDATASEC_BUILTIN
  {__Auto_Release {
    C_BUFFER *bf = Buffer_Init(0);
    Xnode_Normal_Print(&xdata->root,bf);
    Sha1_Digest(bf->at,bf->count,dgst);      
  }}
#endif
  ;

void Xdata_Sha1_Update(C_XDATA *xdata)
#ifdef _C_XDATASEC_BUILTIN
  {
    byte_t dgst[20];
    byte_t hex[41];
    Xdata_Sha1_Digest_Update(xdata,dgst);
    Xnode_Value_Set_Str(&xdata->root,"$$sha1",Str_Hex_Encode_(dgst,20,hex));
  }
#endif
  ;
  
void Xdata_Sha2_Digest_Update(C_XDATA *xdata,byte_t dgst[32])
#ifdef _C_XDATASEC_BUILTIN
  {__Auto_Release {
    C_BUFFER *bf = Buffer_Init(0);
    Xnode_Normal_Print(&xdata->root,bf);
    Sha2_Digest(bf->at,bf->count,dgst);      
  }}
#endif
  ;

void Xdata_Sha2_Update(C_XDATA *xdata)
#ifdef _C_XDATASEC_BUILTIN
  {
    byte_t dgst[32];
    byte_t hex[65];
    Xdata_Sha2_Digest_Update(xdata,dgst);
    Xnode_Value_Set_Str(&xdata->root,"$$sha2",Str_Hex_Encode_(dgst,32,hex));
  }
#endif
  ;

int Xdata_Sha1_Verify(C_XDATA *xdata)
#ifdef _C_XDATASEC_BUILTIN
  {
    byte_t dgst1[20] = {0};
    byte_t dgst2[20] = {0};
    char *sha1 = Xnode_Value_Get_Str(&xdata->root,"$$sha1",0);
    if ( sha1 && strlen(sha1) == 40 )
      {
        Str_Hex_Decode_(sha1,0,dgst1);
        Xdata_Sha1_Digest_Update(xdata,dgst2);
        return !memcmp(dgst2,dgst1,20);
      }
    return 0;
  }
#endif
  ;

void Xdata_Rsa_Update(C_XDATA *xdata,C_BIGINT *K,C_BIGINT *N)
#ifdef _C_XDATASEC_BUILTIN
  {__Auto_Release {
    byte_t dgst[20];
    C_BUFFER *bf = Buffer_Init(0);
    Xnode_Normal_Print(&xdata->root,bf);
    Sha1_Digest(bf->at,bf->count,dgst);
    Xnode_Value_Set_Str(&xdata->root,"$$rsa",Bigint_Hex_Sign(K,N,dgst,20));      
  }}
#endif
  ;

int Xdata_Rsa_Verify(C_XDATA *xdata,C_BIGINT *K,C_BIGINT *N)
#ifdef _C_XDATASEC_BUILTIN
  {
    int ok = 0;
    char *hex = Xnode_Value_Get_Str(&xdata->root,"$$rsa",0);
    if ( hex ) __Auto_Release 
      {
        byte_t dgst[20];
        C_BUFFER *bf = Buffer_Init(0);
        Xnode_Normal_Print(&xdata->root,bf);
        Sha1_Digest(bf->at,bf->count,dgst);
        ok = Bigint_Hex_Verify(K,N,hex,dgst,20);
      }
    return ok;
  }
#endif
  ;

#endif /* C_once_9CC5C44A_A9F9_40B3_85DA_10A2EE2AD4FC */

