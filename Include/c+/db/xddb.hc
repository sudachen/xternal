
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_63CF3893_FBF5_4DA0_9B2D_792FE7BBBCAB
#define C_once_63CF3893_FBF5_4DA0_9B2D_792FE7BBBCAB

#include "../xdata.hc"
#include "../text/mime.hc"
#include "../text/def.hc"
#include "../compress/zlib.hc"

#ifdef _BUILTIN
#define _C_XDDB_BUILTIN
#endif

#ifdef _C_XDDB_BUILTIN
# define _C_XDDB_BUILTIN_CODE(Code) Code
# define _C_XDDB_EXTERN 
#else
# define _C_XDDB_BUILTIN_CODE(Code)
# define _C_XDDB_EXTERN extern 
#endif

typedef struct _C_XDDB
  {
    int doc_format;
    int esc_put: 1;
    int esc_get: 1;
    int encrypt: 1;
    void *encipher16;
    void *decipher16;
  } C_XDDB;

#define C_XDDB_KEY_PROPERTY "$$$key"
#define C_XDDB_REV_PROPERTY "$$$rev"

enum
  {
    XDDB_FORMAT_TEXT          = 'A',
    XDDB_FORMAT_BINARY        = 'B',
    XDDB_FORMAT_ZIPPED_TEXT   = 'a',
    XDDB_FORMAT_ZIPPED_BINARY = 'b',
    C_XDDB_MAX_KEYLEN         = 128,
    C_XDDB_UUID_LENGTH        = 9,
    XDDB_OPEN_EXISTING        = 0,
    XDDB_OPEN_READONLY        = 1,
    XDDB_CREATE_IF_DSNT_EXIST = 2,
    XDDB_CREATE_NEW           = 3,
    XDDB_CREATE_ALWAYS        = 4,
  };

#define XDDB_RAISE_IF_DSNT_EXSIST ((void*)1)
#define XDDB_EMPTY_IF_DSNT_EXSIST ((void*)2)

char *Xddb_Get_Key(C_XDATA *doc)
#ifdef _C_XDDB_BUILTIN 
  {
    return Xnode_Value_Get_Str(&doc->root,C_XDDB_KEY_PROPERTY,0);
  }
#endif
  ;
  
int Xddb_Get_Revision(C_XDATA *doc)
#ifdef _C_XDDB_BUILTIN 
  {
    return Xnode_Value_Get_Int((C_XNODE*)doc,C_XDDB_REV_PROPERTY,0);
  }
#endif
  ;
  
void Xddb_Set_Revision(C_XDATA *doc, int rev)
#ifdef _C_XDDB_BUILTIN 
  {
    Xnode_Value_Set_Int((C_XNODE*)doc,C_XDDB_REV_PROPERTY,rev);
  }
#endif
  ;

C_XDATA *Xddb_Binary_Decode(byte_t *at,int count,int zipped)
#ifdef _C_XDDB_BUILTIN 
  {
    C_XDATA *doc = Xdata_Init();
    return doc;
  }
#endif
  ;

void Xddb_Binary_Encode_Into(C_BUFFER *bf, C_XDATA *doc, int zipped)
#ifdef _C_XDDB_BUILTIN 
  {
  }
#endif
  ;

C_BUFFER *Xddb_Encode(C_XDDB *xddb, C_XDATA *doc, int revision)
#ifdef _C_XDDB_BUILTIN 
  {
    int key_len, hdr_len;
    char *key;
    char prefix[] = ".,.,.,.,_.*+-.*+-.*+";
    C_BUFFER *bf = Buffer_Init(0);
    if ( !revision ) revision = Xddb_Get_Revision(doc);
    Unsigned_To_Hex8(revision,prefix);
    prefix[8] = (char)xddb->doc_format;
    Buffer_Append(bf,prefix,20);
    
    key = Xddb_Get_Key(doc);
    key_len = strlen(key);
    Buffer_Printf(bf,"%02x",key_len);
    Buffer_Append(bf,key,key_len);
    
    hdr_len = bf->count;
    Unsigned_To_Hex2(hdr_len,bf->at+13);
    
    if ( xddb->doc_format == XDDB_FORMAT_TEXT )
      {
        Def_Format_Into(bf,&doc->root,0);
      }
    else if ( xddb->doc_format == XDDB_FORMAT_ZIPPED_TEXT )
      {
        int original;
        int compressed;
        C_BUFFER *tmp = Buffer_Init(0);
        Def_Format_Into(tmp,&doc->root,0);
        original = tmp->count;
        compressed = Zlib_Buffer_Compress(tmp);
        Buffer_Append(bf,tmp->at,tmp->count);
        if ( !compressed )
          bf->at[8] = XDDB_FORMAT_TEXT;
        else
          Unsigned_To_Hex4(original,bf->at+9);
      }
    else if ( xddb->doc_format == XDDB_FORMAT_BINARY )
      ;//Xdata_Binary_Encode_Into(bf,doc,0);
    else if ( xddb->doc_format == XDDB_FORMAT_ZIPPED_BINARY )
      ;//Xdata_Binary_Encode_Into(bf,doc,1);
    else
      __Raise(C_ERROR_INCONSISTENT,"unsupported document format");

    Unsigned_To_Hex4(Crc_16(0,bf->at+hdr_len,bf->count-hdr_len),bf->at+16);

    if ( xddb->esc_put || xddb->encrypt )
      {
        if ( xddb->encrypt )
          {
          }
        if ( xddb->esc_put ) __Auto_Release
          {
            C_BUFFER *tmp = Buffer_Reserve(0,bf->count + bf->count/25);
            Buffer_Esc_Append(tmp,bf->at,bf->count);
            Buffer_Swap(tmp,bf);
          }
      }
      
    return bf;
  }
#endif
  ;

C_XDATA *Xddb_Decode(C_XDDB *xddb, byte_t *at,int count)
#ifdef _C_XDDB_BUILTIN 
  {
    C_XDATA *doc = 0;
    C_BUFFER *bf = 0;
    int hdr_len;
    int key_len;
    char *key;
    
    __Auto_Ptr(doc)
      {
        if ( count < 20 ) 
          __Raise(C_ERROR_CORRUPTED,"document is corrupted");
        
        if ( xddb->esc_get || xddb->encrypt )
          {
            if ( xddb->encrypt )
              {
              }
            if ( xddb->esc_get )
              {
                bf = Buffer_Reserve(0,count);
                //Buffer_Unesc_Append(bf,at,count);
                at = bf->bytes;
                count = bf->count;
              }
          }
          
        hdr_len = Hex2_To_Unsigned(at+13);
          
        if ( hdr_len < 21 || hdr_len > count 
           || Crc_16(0,at+hdr_len,count-hdr_len) != Hex4_To_Unsigned(at+16) )
          __Raise(C_ERROR_CORRUPTED,"document corrupted");

        switch ( at[8] )
          {
            case XDDB_FORMAT_TEXT:
              doc = Def_Parse_Str(at+hdr_len);
              break;
            case XDDB_FORMAT_ZIPPED_TEXT:
              {
                int zOk;
                long final_size = Hex4_To_Unsigned(at+9);
                bf = Buffer_Init(final_size);
                zOk = Zlib_Uncompress(bf->at,&final_size
                                     ,at+hdr_len,count-hdr_len);
                if ( zOk != 0 )
                  __Raise_Format(C_ERROR_DECOMPRESS_DATA
							,("failed to decompress document: %s"
                            ,Zlib_Error(zOk)));
                /*doc = Def_Parse_Str(bf->at);
                bf = Buffer_Copy(at+16,count-16);
                Zlib_Buffer_Uncompress(bf,final_size);*/
                doc = Def_Parse_Str(bf->at);
                break;
              }
            case XDDB_FORMAT_BINARY:
            case XDDB_FORMAT_ZIPPED_BINARY:
              //doc = Xdata_Binary_Decode(at+16,count-16);
              break;
            default:
              __Raise(C_ERROR_INCONSISTENT
                     ,"unsupported document format");
          }
        key_len = Hex2_To_Unsigned(at+20);
        if ( 22 + key_len != hdr_len ) 
          __Raise(C_ERROR_CORRUPTED,"document corrupted");
        Xvalue_Set_Str(Xnode_Value(&doc->root,C_XDDB_KEY_PROPERTY,1)
                      ,at+22,key_len);
        Xddb_Set_Revision(doc,Hex8_To_Unsigned(at));
      }
      
    return doc;
  }
#endif
  ;

#define Xddb_Build_Unique_Key() __Pool(Xddb_Build_Unique_Key_Npl())
char *Xddb_Build_Unique_Key_Npl()
#ifdef _C_XDDB_BUILTIN 
  {
    int pid = getpid();
    
    /* 8 bytes garanty */
    byte_t uuid[C_XDDB_UUID_LENGTH] = {0,0,0,0,0,0,0,0};
    /* 8 bytes garanty */
    static byte_t uuid1[C_XDDB_UUID_LENGTH] = {0,0,0,0,0,0,0,0}; 
    char   out[(C_XDDB_UUID_LENGTH*8+5)/6 + 1] = {0,};
    
    do {
    
      time_t tmx = time(0);
      double clo = clock();
      
      Unsigned_To_Two(pid,uuid);
      Unsigned_To_Four((uint_t)tmx,uuid+2);
      Unsigned_To_Two((uint_t)((clo/CLOCKS_PER_SEC)*10000),uuid+6);

      if ( !memcmp(uuid1,uuid,8) )
        {
          Switch_to_Thread();
          continue;
        }
         
      memcpy(uuid1,uuid,8);
      System_Random(uuid+8,sizeof(uuid)-8);

      Str_Xbit_Encode(uuid,sizeof(uuid)*8,6,Str_6bit_Encoding_Table,out);
      
      STRICT_REQUIRE( out[sizeof(out)-1] == 0 );
      break;
      
    } while ( 1 );
    
    return __Memcopy_Npl(out,sizeof(out));
  }
#endif
  ;

_C_XDDB_EXTERN char Xddb_Delete_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_delete/@*"); 
void Xddb_Delete(C_XDDB *xddb, char *key) 
  _C_XDDB_BUILTIN_CODE(
  { ((void(*)(void*,void*))
        C_Find_Method_Of(&xddb,Xddb_Delete_OjMID,C_RAISE_ERROR))
            (xddb,key); });

_C_XDDB_EXTERN char Xddb_Get_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_get/@**"); 
void *Xddb_Get(C_XDDB *xddb, char *key, C_XDATA *dflt) 
  _C_XDDB_BUILTIN_CODE(
  { return ((void*(*)(void*,void*,void*))
        C_Find_Method_Of(&xddb,Xddb_Get_OjMID,C_RAISE_ERROR))
            (xddb,key,dflt); });

_C_XDDB_EXTERN char Xddb_Has_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_has/@*"); 
int Xddb_Has(C_XDDB *xddb, char *key) 
  _C_XDDB_BUILTIN_CODE(
  { return ((int(*)(void*,void*))
        C_Find_Method_Of(&xddb,Xddb_Has_OjMID,C_RAISE_ERROR))
            (xddb,key); });

_C_XDDB_EXTERN char Xddb_Store_OjMID[]   
                     _C_XDDB_BUILTIN_CODE( = "xddb_store/@*i"); 
int Xddb_Store(C_XDDB *xddb, C_XDATA *doc, int strict_revision) 
  _C_XDDB_BUILTIN_CODE(
  { return ((int(*)(void*,void*,int))
        C_Find_Method_Of(&xddb,Xddb_Store_OjMID,C_RAISE_ERROR))
            (xddb,doc,strict_revision); });

#define Xddb_Update(Xddb,Doc) Xddb_Store(Xddb,Doc,1)

int Xddb_Newdoc(C_XDDB *xddb, C_XDATA *doc, char *key)
#ifdef _C_XDDB_BUILTIN 
  {
    Xnode_Value_Set_Str(&doc->root,C_XDDB_KEY_PROPERTY,key);
    return Xddb_Store(xddb,doc,-1);
  }
#endif
  ;

int Xddb_Overwrite(C_XDDB *xddb, C_XDATA *doc, char *key)
#ifdef _C_XDDB_BUILTIN 
  {
    if ( key )
      Xnode_Value_Set_Str(&doc->root,C_XDDB_KEY_PROPERTY,key);
    return Xddb_Store(xddb,doc,0);
  }
#endif
  ;

char *Xddb_Unique(C_XDDB *xddb, C_XDATA *doc)
#ifdef _C_XDDB_BUILTIN 
  {
    char *k = Xddb_Build_Unique_Key();
    Xnode_Value_Set_Str(&doc->root,C_XDDB_KEY_PROPERTY,k);
    Xddb_Store(xddb,doc,-1);
    return k;
  }
#endif
  ;
    
char *Xddb_Unique_Pfx(C_XDDB *xddb, C_XDATA *doc, char *pfx)
#ifdef _C_XDDB_BUILTIN 
  {
    char *k = Str_Join_2(':',pfx,Xddb_Build_Unique_Key());
    Xnode_Value_Set_Str(&doc->root,C_XDDB_KEY_PROPERTY,k);
    Xddb_Store(xddb,doc,-1);
    return k;
  }
#endif
  ;

_C_XDDB_EXTERN char Xddb_Source_String_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_source_string/@"); 
char *Xddb_Source_String(void *xddb) 
  _C_XDDB_BUILTIN_CODE(
  { return ((char*(*)(void*))
        C_Find_Method_Of(&xddb,Xddb_Source_String_OjMID,C_RAISE_ERROR))
            (xddb); });

char *Xddb_Format_String(C_XDDB *xddb)
#ifdef _C_XDDB_BUILTIN 
  {
    switch ( xddb->doc_format )
      {
      case XDDB_FORMAT_TEXT:   return "text";
      case XDDB_FORMAT_BINARY: return "binary";
      case XDDB_FORMAT_ZIPPED_BINARY: return "zbinary";
      case XDDB_FORMAT_ZIPPED_TEXT: return "ztext";
      }
    return "unknown";
  }
#endif
  ;

char *Xddb_Key_Prefix(char *key)
#ifdef _C_XDDB_BUILTIN 
  {
    char *p = strrchr(key,':');
    if ( p )
      {
        return Str_Copy_L(key,(p-key)+1);
      }
    return 0;
  }
#endif
  ;
  
_C_XDDB_EXTERN char Xddb_Strm_Cancel_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_strm_cancel/@"); 
void Xddb_Strm_Cancel(void *strm) 
  _C_XDDB_BUILTIN_CODE(
  { ((void(*)(void*))
      C_Find_Method_Of(&strm,Xddb_Strm_Cancel_OjMID,C_RAISE_ERROR))
          (strm); });

_C_XDDB_EXTERN char Xddb_Strm_Commit_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_strm_commit/@*i"); 
char *Xddb_Strm_Commit(void *strm, char *key, int overwrite) 
  _C_XDDB_BUILTIN_CODE(
  { return ((char*(*)(void*,void*,int))
        C_Find_Method_Of(&strm,Xddb_Strm_Commit_OjMID,C_RAISE_ERROR))
            (strm,key,overwrite); });

#define Xddb_Strm_Commit_Overwrite(Strm,Key) Xddb_Strm_Commit(Strm,Key,1)
#define Xddb_Strm_Commit_New(Strm,Key) Xddb_Strm_Commit(Strm,Key,0)
#define Xddb_Strm_Commit_Unique(Strm) Xddb_Strm_Commit(Strm,0,0)

_C_XDDB_EXTERN char Xddb_Strm_Open_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_strm_open/@*"); 
void *Xddb_Strm_Open(C_XDDB *xddb, char *key) 
  _C_XDDB_BUILTIN_CODE(
  { return ((void*(*)(void*,void*))
        C_Find_Method_Of(&xddb,Xddb_Strm_Open_OjMID,C_RAISE_ERROR))
            (xddb,key); });

_C_XDDB_EXTERN char Xddb_Strm_Create_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_strm_create/@i"); 
void *Xddb_Strm_Create(C_XDDB *xddb, int mime) 
  _C_XDDB_BUILTIN_CODE(
  { return ((void*(*)(void*,int))
        C_Find_Method_Of(&xddb,Xddb_Strm_Create_OjMID,C_RAISE_ERROR))
            (xddb,mime); });

_C_XDDB_EXTERN char Xddb_Strm_Delete_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_strm_delete/@*"); 
void Xddb_Strm_Delete(C_XDDB *xddb, char *key) 
  _C_XDDB_BUILTIN_CODE(
  { ((void(*)(void*,void*))
        C_Find_Method_Of(&xddb,Xddb_Strm_Delete_OjMID,C_RAISE_ERROR))
            (xddb,key); });

_C_XDDB_EXTERN char Xddb_Seq_Open_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_seq_open/@*i"); 
void *Xddb_Seq_Open(C_XDDB *xddb, char *key, int mknew) 
  _C_XDDB_BUILTIN_CODE(
  { return ((void *(*)(void*,void*, int))
        C_Find_Method_Of(&xddb,Xddb_Seq_Open_OjMID,C_RAISE_ERROR))
            (xddb,key,mknew); });

_C_XDDB_EXTERN char Xddb_Seq_Delete_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_seq_delete/@*"); 
void Xddb_Seq_Delete(C_XDDB *xddb, char *key) 
  _C_XDDB_BUILTIN_CODE(
  { ((void(*)(void*,void*))
        C_Find_Method_Of(&xddb,Xddb_Seq_Delete_OjMID,C_RAISE_ERROR))
            (xddb,key); });

_C_XDDB_EXTERN char Xddb_Seq_Take_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_seq_take/@"); 
C_XDATA *Xddb_Seq_Take(void *seq) 
  _C_XDDB_BUILTIN_CODE(
  { return ((void*(*)(void*))
        C_Find_Method_Of(&seq,Xddb_Seq_Take_OjMID,C_RAISE_ERROR))
            (seq); });

_C_XDDB_EXTERN char Xddb_Seq_Next_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_seq_next/@"); 
C_XDATA *Xddb_Seq_Next(void *seq) 
  _C_XDDB_BUILTIN_CODE(
  { return ((void*(*)(void*))
        C_Find_Method_Of(&seq,Xddb_Seq_Next_OjMID,C_RAISE_ERROR))
            (seq); });

_C_XDDB_EXTERN char Xddb_Seq_Multi_Next_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_seq_multi_next/@i"); 
C_ARRAY *Xddb_Seq_Multi_Next(void *seq,int count) 
  _C_XDDB_BUILTIN_CODE(
  { return ((void*(*)(void*,int))
        C_Find_Method_Of(&seq,Xddb_Seq_Multi_Next_OjMID,C_RAISE_ERROR))
            (seq,count); });

_C_XDDB_EXTERN char Xddb_Seq_Push_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_seq_push/@*"); 
void Xddb_Seq_Push(C_XDDB *seq, C_XDATA *doc) 
  _C_XDDB_BUILTIN_CODE(
  { ((void(*)(void*,void*))
        C_Find_Method_Of(&seq,Xddb_Seq_Push_OjMID,C_RAISE_ERROR))
            (seq,doc); });

_C_XDDB_EXTERN char Xddb_Seq_Erase_OjMID[] 
                     _C_XDDB_BUILTIN_CODE( = "xddb_seq_erase/@*"); 
void Xddb_Seq_Erase(C_XDDB *seq) 
  _C_XDDB_BUILTIN_CODE(
  { ((void(*)(void*))
        C_Find_Method_Of(&seq,Xddb_Seq_Erase_OjMID,C_RAISE_ERROR))
            (seq); });

#endif /* C_once_63CF3893_FBF5_4DA0_9B2D_792FE7BBBCAB */
