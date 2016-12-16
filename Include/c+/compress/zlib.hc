
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_EB7941BA_38FE_4713_AFDA_5DB7AC656213
#define C_once_EB7941BA_38FE_4713_AFDA_5DB7AC656213

#include "../C+.hc"
#include "../buffer.hc"

#ifdef _BUILTIN
# define _C_ZLIB_BUILTIN
#endif

#ifdef _C_ZLIB_BUILTIN
/*# include <zlib.h>*/

enum 
  {
    ZLIB_OK           = 0,
    ZLIB_STREAM_END   = 1,
    ZLIB_NEED_DICT    = 2,
    ZLIB_ERRNO        = -1,
    ZLIB_STREAM_ERROR = -2,
    ZLIB_DATA_ERROR   = -3,
    ZLIB_MEM_ERROR    = -4,
    ZLIB_BUF_ERROR    = -5,
    ZLIB_VERSION_ERROR= -6,
  };

#endif

char *Zlib_Error(int zOk)
#ifdef _C_ZLIB_BUILTIN
  {
    switch ( zOk )
      {
        case ZLIB_OK:            return "succeeded";
        case ZLIB_STREAM_END:    return "Z_STREAM_END";
        case ZLIB_NEED_DICT:     return "Z_NEED_DICT";
        case ZLIB_ERRNO:         return "Z_ERRNO";
        case ZLIB_STREAM_ERROR:  return "Z_STREAM_ERROR";
        case ZLIB_DATA_ERROR:    return "Z_DATA_ERROR";
        case ZLIB_MEM_ERROR:     return "Z_MEM_ERROR";
        case ZLIB_BUF_ERROR:     return "Z_BUF_ERROR";
        case ZLIB_VERSION_ERROR: return "Z_VERSION_ERROR";
      }
    return "unknown error";
  }
#endif
  ;
  
#undef compress
int compress(void *dst, long *dst_len, void *src, long src_len);
#undef uncompress
int uncompress(void *dst, long *dst_len, void *src, long src_len);

int Zlib_Compress(void *dst, long *dst_len, void *src, long src_len)
#ifdef _C_ZLIB_BUILTIN
  {
    return compress(dst,dst_len,src,src_len);
  }
#endif
  ;
  
int Zlib_Uncompress(void *dst, long *dst_len, void *src, long src_len)
#ifdef _C_ZLIB_BUILTIN
  {
    return uncompress(dst,dst_len,src,src_len);
  }
#endif
  ;
  
int Zlib_Buffer_Compress(C_BUFFER *bf)
#ifdef _C_ZLIB_BUILTIN
  {
    int succeded = 0;
    if ( bf->count ) __Auto_Release 
      {
        ulong_t tmp_len = bf->count;
        C_BUFFER *tmp = Buffer_Init(bf->count); 
        int zOk = compress(tmp->at,&tmp_len,bf->at,bf->count);
        if ( zOk != ZLIB_OK && zOk != ZLIB_BUF_ERROR )
          __Raise_Format(C_ERROR_INCONSISTENT,("Zlib failed to compress buffer: %s", Zlib_Error(zOk)) );
        if ( zOk == ZLIB_OK )
          {
            tmp->count = tmp_len;
            Buffer_Swap(tmp,bf);
            succeded = tmp_len;
          }
      }
    return succeded;
  }
#endif
  ;
  
void Zlib_Buffer_Uncompress(C_BUFFER *bf, int final_size)
#ifdef _C_ZLIB_BUILTIN
  {
    if ( bf->count ) __Auto_Release 
      {
        int zOk;
        ulong_t tmp_len;
        C_BUFFER *tmp = Buffer_Init(final_size?final_size:bf->count*3); 
     repeat:
        tmp_len = tmp->count;
        zOk = uncompress(tmp->at,&tmp_len,bf->at,bf->count);
        if ( zOk != ZLIB_OK && zOk != ZLIB_BUF_ERROR )
          __Raise_Format(C_ERROR_INCONSISTENT,("Zlib failed to uncompress buffer: %s", Zlib_Error(zOk)) );
        if ( zOk == ZLIB_BUF_ERROR )
          {          
            Buffer_Resize(tmp,tmp->count+bf->count);
            goto repeat;
          }
        Buffer_Swap(tmp,bf);
      }
  }
#endif
  ;
  
#endif /* C_once_EB7941BA_38FE_4713_AFDA_5DB7AC656213 */

