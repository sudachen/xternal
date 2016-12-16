
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_B16E23B4_712C_4444_9C55_D12A063F3395
#define C_once_B16E23B4_712C_4444_9C55_D12A063F3395

#ifdef _BUILTIN
#define _C_STDF_BUILTIN
#endif

#include "C+.hc"
#include "file.hc"

enum 
  { 
    C_STDF_PUMP_BUFFER = 1*KILOBYTE,
    C_STDF_PUMP_BUFFER_W = C_STDF_PUMP_BUFFER-1,
  };

int Stdf_Read_In(FILE *stdf,char *buf, int L)
#ifdef _C_STDF_BUILTIN
  {
    int i;
    for ( i = 0; i < L; )
      {
        int q = fread(buf+i,1,L-i,stdf);
        if ( q ) 
          i += q;
        else if ( feof(stdf) )
          break;
        else
          {
            int err = ferror(stdf);
            if ( err == EAGAIN ) continue;
            __Raise_Format(C_ERROR_IO,("failed to read: %s",strerror(err)));
          }
      }
    buf[i] = 0;
    return i;
  }
#endif
  ;
  
#define Stdf_Pump(stdf,buf) Stdf_Read_In(stdf,buf,C_STDF_PUMP_BUFFER_W)
char *Stdf_Pump_Part(FILE *stdf, char *buf, char *S, int *L)
#ifdef _C_STDF_BUILTIN
  {
    int l = *L;
    if ( !S ) S = buf+l;
    l -= ( S-buf);
    if ( l ) memmove(buf,S,l);
    l += Stdf_Read_In(stdf,buf+l,C_STDF_PUMP_BUFFER_W-l);
    *L = l;
    STRICT_REQUIRE(l <= C_STDF_PUMP_BUFFER_W);
    buf[l] = 0;
    return buf;
  }
#endif
  ;
  
char *Oj_Pump_Part(void *f, char *buf, char *S, int *L)
#ifdef _C_STDF_BUILTIN
  {
    int l = *L;
    if ( !S ) S = buf+l;
    l -= ( S-buf);
    if ( l ) memmove(buf,S,l);
    l += Oj_Read(f,buf+l,C_STDF_PUMP_BUFFER_W-l,0);
    *L = l;
    STRICT_REQUIRE(l <= C_STDF_PUMP_BUFFER_W);
    buf[l] = 0;
    return buf;
  }
#endif
  ;

#define Stdout_Put(S) if (!S); else fputs(S,stdout)
#define Stdin_Pump(B) Stdf_Pump(stdin,B)
#define Stdin_Pump_Part(B,S,L) Stdf_Pump_Part(stdin,B,S,L)

/* returns -1 if error and read bytes count on success */
typedef int Unknown_Write_Proc(void *buf, uptrword_t f, int count, int *err);

int Stdf_Write(void *buf, uptrword_t f, int count, int *err)
#ifdef _C_STDF_BUILTIN
  {
    int q = fwrite(buf,1,count,(FILE*)f);
    if ( !q )
      {
        *err = ferror((FILE*)f);
        q = -1;
      }
    return q;
  }
#endif
  ;

int Fdf_Write(void *buf, uptrword_t f, int count, int *err)
#ifdef _C_STDF_BUILTIN
  {
    int q = write((int)f,buf,count);
    if ( q < 0 )
      q = errno;
    return q;
  }
#endif
  ;

int Bf_Write(void *buf, uptrword_t f, int count, int *err)
#ifdef _C_STDF_BUILTIN
  {
    Buffer_Append((C_BUFFER*)f,buf,count);
    return count;
  }
#endif
  ;

int Cf_Write(void *buf, uptrword_t f, int count, int *err)
#ifdef _C_STDF_BUILTIN
  {
    return Stdf_Write(buf,(uptrword_t)((C_FILE*)f)->fd,count,err);
  }
#endif
  ;

int Unknown_Write(uptrword_t f, void *bf, int count, Unknown_Write_Proc xwrite)
#ifdef _C_STDF_BUILTIN
  {
    int i;
    for ( i = 0; i < count; )
      {
        int err = 0;
        int r = xwrite((char*)bf+i,f,count-i,&err);
        if ( r > 0 ) i += r;
        else if ( err != EAGAIN )
          __Raise_Format(C_ERROR_IO,("failed to write: %s",strerror(err)));
      }
    return i;
  }
#endif
  ;

#endif /* C_once_B16E23B4_712C_4444_9C55_D12A063F3395 */

