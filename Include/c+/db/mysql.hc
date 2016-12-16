
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#include "../C+.hc"

#ifdef __windoze
# include <winsock2.h>
#endif

#include <mysql/mysql.h>
#include <mysql/mysqld_error.h>

#ifdef _BUILTIN
#define _C_MYSQL_BUILTIN
#endif

void Msql_free_results(MYSQL_RES *rset)
#ifdef _C_MYSQL_BUILTIN
  {
    mysql_free_result(rset);
  }
#endif
  ;
 
#define __Mysql_Results(Con,Rset) \
  switch ( 0 ) while ( 1 ) \
    if ( 1 ) \
      goto C_LOCAL_ID(Free_Rset); \
    else if ( 1 ) \
      case 0: \
        { \
          if (( Rset = mysql_store_result(Con) )) \
            { \
              C_JmpBuf_Push_Cs(Rset,(C_JMPBUF_Unlock)Msql_free_results); \
              goto C_LOCAL_ID(Do_Code); \
            } \
          else \
            __Raise_Format(C_ERROR_IO,("mySQL failed to acquire results: %s",mysql_error(Con))); \
        C_LOCAL_ID(Free_Rset): \
          C_JmpBuf_Pop_Cs(Rset); \
          Msql_free_results(Rset); \
          break; \
        } \
    else \
      C_LOCAL_ID(Do_Code): \

