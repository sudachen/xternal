
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_7B87C216_9DAA_4229_9B48_28562A89CD0D
#define C_once_7B87C216_9DAA_4229_9B48_28562A89CD0D

#include "../datetime.hc"
#include "../crypto/sha1.hc"

#include "xddb.hc"

#ifdef _BUILTIN
#define _C_XDDBSQL_BUILTIN
#endif

#ifdef _C_XDDBSQL_BUILTIN
# define _C_XDDBSQL_BUILTIN_CODE(Code) Code
# define _C_XDDBSQL_EXTERN 
#else
# define _C_XDDBSQL_BUILTIN_CODE(Code)
# define _C_XDDBSQL_EXTERN extern 
#endif

enum
  {
    XDDBSQL_DOC_ID_LEN = 20,
    XDDBSQL_COL_ID_LEN = 20,
    XDDBSQL_DOC_ENCODED_ID_LEN = (20*8+4)/5,
    XDDBSQL_COL_ENCODED_ID_LEN = (20*8+4)/5,
  };

typedef struct _C_XDDBSQL_STATS
  {
    quad_t datetime;
    int revision;
    struct {
      int exists : 1;
    } f;
  } C_XDDBSQL_STATS;

typedef struct _C_XDDBSQL
  {
    C_XDDB xddb;
    void *sqldb;
    char *source;
  } C_XDDBSQL;

void C_XDDBSQL_Destruct(C_XDDBSQL *xddb)
  {
    free(xddb->source);
    __Unrefe(xddb->sqldb);
    __Destruct(xddb);
  };

typedef struct _C_XDDBSQL_SEQ
  {
    C_XDDBSQL *xddb;
    char       *col_id;
    void       *cursor;
  } C_XDDBSQL_SEQ;
  
void C_XDDBSQL_SEQ_Destruct(C_XDDBSQL_SEQ *seq)
  {
    free(seq->col_id);
    __Unrefe(seq->cursor);
    __Unrefe(seq->xddb);
    __Destruct(seq);
  }

_C_XDDBSQL_EXTERN char Xddbsql_Query_Doc_OjMID[] _C_XDDBSQL_BUILTIN_CODE( = "xddbsql_query_doc/@**"); 
C_BUFFER *Xddbsql_Query_Doc(void *sqldb, char *colid, char *docid, char **dtt)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    return ((void*(*)(void*,void*,void*,char**))C_Find_Method_Of(&sqldb,Xddbsql_Query_Doc_OjMID,C_RAISE_ERROR))
        (sqldb,colid,docid,dtt);
  }
#endif
  ;
  
_C_XDDBSQL_EXTERN char Xddbsql_Stats_Doc_OjMID[] _C_XDDBSQL_BUILTIN_CODE( = "xddbsql_query_stats/@**"); 
C_XDDBSQL_STATS Xddbsql_Stats_Doc(void *sqldb, char *colid, char *docid)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    return ((C_XDDBSQL_STATS(*)(void*,void*,void*))C_Find_Method_Of(&sqldb,Xddbsql_Stats_Doc_OjMID,C_RAISE_ERROR))
        (sqldb,colid,docid);
  }
#endif
  ;

_C_XDDBSQL_EXTERN char Xddbsql_Delete_Doc_OjMID[] _C_XDDBSQL_BUILTIN_CODE( = "xddbsql_delete_doc/@**"); 
int Xddbsql_Delete_Doc(void *sqldb, char *colid, char *docid)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    return ((int(*)(void*,void*,void*))C_Find_Method_Of(&sqldb,Xddbsql_Delete_Doc_OjMID,C_RAISE_ERROR))
        (sqldb,colid,docid);
  }
#endif
  ;

_C_XDDBSQL_EXTERN char Xddbsql_Update_Doc_OjMID[] _C_XDDBSQL_BUILTIN_CODE( = "xddbsql_update_doc/@**i*ii"); 
int Xddbsql_Update_Doc(void *sqldb, char *colid, char *docid, int newrev, void *data, int len, int oldrev )
#ifdef _C_XDDBSQL_BUILTIN 
  {
    return ((int(*)(void*,void*,void*,int,void*,int,int))C_Find_Method_Of(&sqldb,Xddbsql_Update_Doc_OjMID,C_RAISE_ERROR))
        (sqldb,colid,docid,newrev,data,len,oldrev);
  }
#endif
  ;

_C_XDDBSQL_EXTERN char Xddbsql_Insert_Doc_OjMID[] _C_XDDBSQL_BUILTIN_CODE( = "xddbsql_insert_doc/@**i*i"); 
int Xddbsql_Insert_Doc(void *sqldb, char *colid, char *docid, int newrev, void *data, int len )
#ifdef _C_XDDBSQL_BUILTIN 
  {
    return ((int(*)(void*,void*,void*,int,void*,int))C_Find_Method_Of(&sqldb,Xddbsql_Insert_Doc_OjMID,C_RAISE_ERROR))
        (sqldb,colid,docid,newrev,data,len);
  }
#endif
  ;

char *Xddbsql_Doc_ID(C_XDDBSQL *xddb, char *key)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    byte_t sha1[20];
    Sha1_Digest(key,strlen(key),sha1);
    return Str_5bit_Encode_Upper(sha1,20);
  }
#endif
  ;
    
char *Xddbsql_Col_ID(C_XDDBSQL *xddb, char *key)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    byte_t sha1[20] = {0};
    char *pfx = Xddb_Key_Prefix(key);
    if ( pfx )
      Sha1_Digest(pfx,strlen(pfx),sha1);
    return Str_5bit_Encode_Upper(sha1,20);
  }
#endif
  ;
    
C_XDATA *Xddbsql_Get(C_XDDBSQL *xddb, char *key, C_XDATA *dflt)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    C_XDATA *doc = dflt;
    
    __Auto_Ptr(doc)
      {
        char *doc_id = Xddbsql_Doc_ID(xddb,key);
        char *col_id = Xddbsql_Col_ID(xddb,key);
        char *dtt = 0;
        C_BUFFER *bf = Xddbsql_Query_Doc(xddb->sqldb,col_id,doc_id,&dtt);
        
        if ( bf )
          doc = Xddb_Decode(&xddb->xddb,bf->at,bf->count);
          
        if ( doc )
          Xnode_Value_Set_Str(&doc->root,"$$$dtt",dtt);
      }
    
    if ( doc == XDDB_RAISE_IF_DSNT_EXSIST )
      __Raise_Format(C_ERROR_DSNT_EXIST,("Xddb doesn't have document '%s'",key));
    else if ( doc == XDDB_EMPTY_IF_DSNT_EXSIST )
      {
        doc = Xdata_Init();
        Xnode_Value_Set_Str(&doc->root,C_XDDB_KEY_PROPERTY,key);
      }
    return doc;
  }
#endif
  ;

int Xddbsql_Has(C_XDDBSQL *xddb, char *key)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    int exists = 0;
    __Auto_Release
      {
        char *doc_id = Xddbsql_Doc_ID(xddb,key);
        char *col_id = Xddbsql_Col_ID(xddb,key);
        C_XDDBSQL_STATS stats = Xddbsql_Stats_Doc(xddb->sqldb,col_id,doc_id);
        exists = stats.f.exists;
      }
    return exists;
  }
#endif
  ;

void Xddbsql_Delete(C_XDDBSQL *xddb, char *key)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    __Auto_Release
      {
        char *doc_id = Xddbsql_Doc_ID(xddb,key);
        char *col_id = Xddbsql_Col_ID(xddb,key);
        Xddbsql_Delete_Doc(xddb->sqldb,col_id,doc_id);
      }
  }
#endif
  ;

int Xddbsql_Store(C_XDDBSQL *xddb, C_XDATA *doc, int strict_revision)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    int new_revision;
    
    __Auto_Release
      {
        C_BUFFER *bf;
        C_XDDBSQL_STATS stats;
        void *sqldb = xddb->sqldb;
        char *key, *doc_id, *col_id;
        int success;
        key = Xnode_Value_Get_Str(&doc->root,C_XDDB_KEY_PROPERTY,0);
        
        if ( !key )
          __Raise_Format(C_ERROR_ILLFORMED,
             ("%s property doesn't exist or has invalid value",
                     C_XDDB_KEY_PROPERTY));
        
        doc_id = Xddbsql_Doc_ID(xddb,key);
        col_id = Xddbsql_Col_ID(xddb,key);
        
        stats.revision = Xddb_Get_Revision(doc);
        new_revision = stats.revision + 1;
        bf = Xddb_Encode(&xddb->xddb,doc,new_revision);
        
        if ( !strict_revision )
          {
            if ( !Xddbsql_Update_Doc(xddb->sqldb, col_id, doc_id, new_revision, bf->at, bf->count, 0 ))             
              goto insert;
          }
        else if ( strict_revision > 0 )
          success = Xddbsql_Update_Doc(xddb->sqldb, col_id, doc_id, new_revision, bf->at, bf->count, stats.revision );         
        else
          insert:
            success = Xddbsql_Insert_Doc(xddb->sqldb, col_id, doc_id, new_revision, bf->at, bf->count );         
      
        if ( !success ) // revision inconsistent
          {
            stats = Xddbsql_Stats_Doc(xddb->sqldb,col_id,doc_id);
            if ( stats.f.exists && stats.revision != Xddb_Get_Revision(doc) )
              __Raise(C_ERROR_INCONSISTENT,
                __Format("inconsistent revision of document '%s', store:%d != docu:%d",
                         key,
                         stats.revision,
                         Xddb_Get_Revision(doc)));              
            else
              __Raise(C_ERROR_ALREADY_EXISTS,
                __Format("document '%s' already exists or couldn´t be updated, docu:%d",
                         key,
                         stats.revision));              
          }
          
        Xddb_Set_Revision(doc,new_revision);
      }
      
    return new_revision;
  }
#endif
  ;

_C_XDDBSQL_EXTERN char Xddbsql_Cursor_Next_OjMID[] _C_XDDBSQL_BUILTIN_CODE( = "xddbsql_cursor_next/@"); 
char *Xddbsql_Cursor_Next(void *cursor)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    return ((char *(*)(void*))C_Find_Method_Of(&cursor,Xddbsql_Cursor_Next_OjMID,C_RAISE_ERROR))
        (cursor);
  }
#endif
  ;

C_XDATA *Xddbsql_Seq_Next(C_XDDBSQL_SEQ *seq)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    C_XDATA *doc = 0;
    char *doc_id;
    
    __Auto_Ptr(doc)
      {
        if (( doc_id = Xddbsql_Cursor_Next(seq->cursor) ))
          {
            char *dtt = 0;
            C_BUFFER *bf = Xddbsql_Query_Doc(seq->xddb->sqldb,seq->col_id,doc_id,&dtt);
            if ( bf )
              doc = Xddb_Decode(&seq->xddb->xddb,bf->at,bf->count);
            if ( doc )
              Xnode_Value_Set_Str(&doc->root,"$$$dtt",dtt);
          }
      }
    return doc;
  }
#endif
  ;
  
_C_XDDBSQL_EXTERN char Xddbsql_Cursor_Open_OjMID[] _C_XDDBSQL_BUILTIN_CODE( = "xddbsql_cursor_open/@"); 
void *Xddbsql_Cursor_Open(void *sqldb, char *colid, char *seqid)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    return ((void *(*)(void*,char*,char*))C_Find_Method_Of(&sqldb,Xddbsql_Cursor_Open_OjMID,C_RAISE_ERROR))
        (sqldb,colid,seqid);
  }
#endif
  ;

void *Xddbsql_Seq_Open(C_XDDBSQL *xddb, char *key, int mknew) 
#ifdef _C_XDDBSQL_BUILTIN 
  {
    static C_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID,       C_XDDBSQL_SEQ_Destruct},
        {Xddb_Seq_Next_OjMID,     Xddbsql_Seq_Next},
        {0}};
    C_XDDBSQL_SEQ *seq = 0;
    
    __Auto_Ptr(seq)
      {
        char *seq_id = Str_Ends_With(key,":*")?0:Xddbsql_Doc_ID(xddb,key);
        char *col_id = Xddbsql_Col_ID(xddb,key);
        seq = __Object(sizeof(C_XDDBSQL_SEQ),funcs);
        
        seq->cursor = __Refe(Xddbsql_Cursor_Open(xddb->sqldb,col_id,seq_id));
        seq->xddb   = __Refe(xddb);
        seq->col_id = __Retain(col_id);
      }
      
    return seq;
  }
#endif  
  ;

char *Xddbsql_Source_String(C_XDDBSQL *xddb)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    return xddb->source;
  } 
#endif 
  ;

C_XDDB *Xddbsql_Init(void *sqldb, int format, char *source)
#ifdef _C_XDDBSQL_BUILTIN 
  {
    static C_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID,       C_XDDBSQL_Destruct},
        {Xddb_Delete_OjMID,       Xddbsql_Delete},
        {Xddb_Get_OjMID,          Xddbsql_Get},
        {Xddb_Has_OjMID,          Xddbsql_Has},
        {Xddb_Store_OjMID,        Xddbsql_Store},
      /*{Xddb_Strm_Open_OjMID,    Xddbsql_Strm_Open},
        {Xddb_Strm_Create_OjMID,  Xddbsql_Strm_Create},
        {Xddb_Strm_Delete_OjMID,  Xddbsql_Strm_Delete},*/
        {Xddb_Seq_Open_OjMID,     Xddbsql_Seq_Open},
      /*{Xddb_Seq_Delete_OjMID,   Xddbsql_Seq_Delete},*/
        {Xddb_Source_String_OjMID,Xddbsql_Source_String},
        {0}
      };

    C_XDDBSQL *xddb = __Object(sizeof(C_XDDBSQL),funcs);
    xddb->sqldb  = __Refe(sqldb);
    xddb->source = Str_Copy_Npl(source,-1);
    xddb->xddb.doc_format = format;
    return &xddb->xddb;
  }
#endif
  ;

#endif /* C_once_7B87C216_9DAA_4229_9B48_28562A89CD0D */
