
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_BE85262D_CDA8_4AF5_B684_8A30EB6D7370
#define C_once_BE85262D_CDA8_4AF5_B684_8A30EB6D7370

#include "../C+.hc"
#include "../string.hc"
#include "../buffer.hc"
#include "../dicto.hc"
#include "../file.hc"
#include "../text/url.hc"
#include "tcpip.hc"

#ifdef _BUILTIN
#define _C_HTTPD_BUILTIN
#endif

struct _C_HTTPD_REQUEST;
typedef int (*httpd_callback_t)(void *obj, struct _C_HTTPD_REQUEST *rqst, int status);
typedef struct _C_HTTPD
  {
    C_TCPSOK *sok;
    char *host;
    int port;

    struct _C_HTTPD_REQUEST *rqst;
    httpd_callback_t callback;
    void *obj;
  } C_HTTPD;

typedef struct _C_HTTPD_REQUEST
  {
    C_BUFFER *bf; /* associated with instrm when post data is small */
    
    /* request */    
    void *instrm;
    char *instrm_type; /*handle by qhdr*/
    int   instrm_length;
    C_DICTO  *qhdr;
    
    char *uri;
    char *referer;
    char *remote_addr;
    int   remote_port;
    int   method;
    int   httpver;
        
    /* response */
    void *outstrm;
    char *outstrm_type;
    char *outstrm_charset;
    int   outstrm_length;
    
    C_ARRAY *hlns;
    C_ARRAY *cookie;
    char *location;
    char *cache_control;
  
    /* internal */    
    C_TCPSOK *sok;
    C_HTTPD  *httpd;
    int nline;
    int left;
    struct _C_HTTPD_REQUEST *next;
    
    void (*on_detach)(struct _C_HTTPD_REQUEST *);
  } C_HTTPD_REQUEST;

void Httpd_Detach_Request(C_HTTPD_REQUEST *rqst)
#ifdef _C_HTTPD_BUILTIN
  {
    C_HTTPD *httpd = rqst->httpd;
    C_HTTPD_REQUEST **q = &httpd->rqst;
    
    if ( rqst->on_detach )
      rqst->on_detach(rqst);
    
    while ( *q )
      {
        if ( *q == rqst )
          {
            *q = rqst->next;
            rqst->next = 0;
            break;
          }
        q = &(*q)->next;
      }
  }
#endif
  ;
  
void C_HTTPD_REQUEST_Destruct(C_HTTPD_REQUEST *rqst)
#ifdef _C_HTTPD_BUILTIN
  {
    Httpd_Detach_Request(rqst);
    __Unrefe(rqst->httpd);
    __Unrefe(rqst->sok);
    free(rqst->remote_addr);
    free(rqst->uri);
    free(rqst->referer);
    __Unrefe(rqst->bf);
    __Unrefe(rqst->qhdr);
    __Unrefe(rqst->instrm);
    __Unrefe(rqst->outstrm);
    free(rqst->outstrm_type);
    free(rqst->location);
    free(rqst->cache_control);
    __Unrefe(rqst->cookie);
    __Unrefe(rqst->hlns);
    free(rqst->outstrm_charset);
    __Destruct(rqst);
  }
#endif
  ;
  
enum
  {
    /* status */
    HTTPD_RQST_CONNECT     = 1,
    HTTPD_RQST_POSTDTA     = 2,
    HTTPD_RQST_PERFORM     = 3,

    HTTPD_STAT_TIMER       = 0x00010000,
    HTTPD_STAT_LONGRQST    = 0x81000000,
    HTTPD_STAT_IOFAIL      = 0x82000000,
    HTTPD_STAT_ACCEPTFAIL  = 0x83000000,
    HTTPD_STAT_REJECTED    = 0x84000000,
    HTTPD_STAT_BADMETHOD   = 0x85000000,
    HTTPD_STAT_FINISHED    = 0x00000000,

    /* HTTPD_RQST_CONNECT/HTTPD_RQST_POSTDTA result */
    HTTPD_ACCEPT           = 0,
    HTTPD_REJECT           = -1,

    /* HTTPD_RQST_PERFORM result */
    HTTPD_SUCCESS          = 200,
    HTTPD_PARTIAL          = 206,

    /* HTTPD_RQST_PERFORM/HTTPD_RQST_POSTDTA result */
    HTTPD_REDIRECT         = 303,
    HTTPD_FORBIDEN         = 403,
    HTTPD_NOTFOUND         = 404,
    HTTPD_SERVERROR        = 501,

    HTTPD_MAXBUF_LENGTH          = 64*1024,
    HTTPD_MAX_REQUEST_LENGTH     = 8*1024,
    HTTPD_MAXBUF_POSTDATA_LENGTH = 64*1024,

    HTTPD_GET_METHOD       = 1001,
    HTTPD_POST_METHOD      = 1002,
    HTTPD_PUT_METHOD       = 1003,
    HTTPD_HEAD_METHOD      = 1004,
    HTTPD_DELETE_METHOD    = 1005,

  };

char *Httpd_Method_String(int method)
#ifdef _C_HTTPD_BUILTIN
  {
    switch(method)
      {
        case HTTPD_GET_METHOD:    return "GET";
        case HTTPD_POST_METHOD:   return "POST";
        case HTTPD_PUT_METHOD:    return "PUT";
        case HTTPD_HEAD_METHOD:   return "HEAD";
        case HTTPD_DELETE_METHOD: return "DELETE";
      }
      
    return "NONE";
  }
#endif
  ;

C_HTTPD_REQUEST *Httpd_Request(C_HTTPD *httpd, C_TCPSOK *sok)
#ifdef _C_HTTPD_BUILTIN
  {
    C_HTTPD_REQUEST *rqst = __Object_Dtor(sizeof(C_HTTPD_REQUEST),C_HTTPD_REQUEST_Destruct);
    rqst->httpd = __Refe(httpd);
    rqst->sok = __Refe(sok);
    rqst->remote_addr = Ipv4_Format_Npl(sok->ip);
    rqst->remote_port = sok->port;
    rqst->next = httpd->rqst;
    httpd->rqst = rqst;
    rqst->bf = __Refe(Buffer_Init(0));
    rqst->qhdr = __Refe(Dicto_Ptrs());
    rqst->cookie = __Refe(Array_Pchars());
    rqst->hlns = __Refe(Array_Pchars());
    Buffer_Reserve(rqst->bf,HTTPD_MAXBUF_LENGTH);
    return rqst;
  }
#endif
  ;
  
int Httpd_Rqst_Range(C_HTTPD_REQUEST *rqst, int *rng_pos, int *rng_len)
#ifdef _C_HTTPD_BUILTIN
  {
    char *foo = Dicto_Get(rqst->qhdr,"RANGE",0);
    
    if ( foo )
      {
        int start = 0, end = 0;
        if ( sscanf(foo,"bytes=%u-%u",&start,&end) == 2 )
          if ( start >= 0 && end >= start )
            {
              *rng_pos = start;
              *rng_len = end-start+1;
              return 1;
            }
      }
      
    return 0;
  }
#endif
  ;
  
void Httpd_Set_Content_Range(C_HTTPD_REQUEST *rqst, int rng_pos, int rng_len, int total)
#ifdef _C_HTTPD_BUILTIN
  {
    Array_Push(rqst->hlns,
              __Format_Npl("Content-Range: bytes %d-%d/%d",rng_pos,rng_len+rng_pos-1,total));
  }
#endif
  ;
  
char *Httpd_Status_Text(int st)
#ifdef _C_HTTPD_BUILTIN
  {
    switch ( st )
      {
        case 200: return "OK";
        case 201: return "Created";
        case 202: return "Accepted";
        case 203: return "Non-Authoritative Information";
        case 204: return "No Content";
        case 205: return "Reset Content";
        case 206: return "Partial Content";
        case 207: return "Multi-Status";
        case 208: return "Already Reported";
        case 226: return "IM Used";
        case 300: return "Multiple Choices";
        case 301: return "Moved Permanantly";
        case 302: return "Found";
        case 303: return "See Other";
        case 304: return "Not Modified";
        case 305: return "Use Proxy";
        case 306: return "Switch Proxy";
        case 307: return "Temporary Redirect";
        case 308: return "Resume Incomplete";
        case 400: return "Bad Request";
        case 401: return "Unauthorized";
        case 402: return "Payment Required";
        case 403: return "Forbidden";
        case 404: return "Not Found";
        case 405: return "Method Not Allowed";
        case 406: return "Not Acceptable";
        case 407: return "Proxy Authentication Required";
        case 408: return "Request Timeout";
        case 409: return "Conflict";
        case 410: return "Gone";
        case 411: return "Length Required";
        case 412: return "Precondition Failed";
        case 413: return "Request Entity Too Large";
        case 414: return "Request-URI Too Long";
        case 415: return "Unsupported Media Type";
        case 416: return "Requested Range Not Satisfiable";
        case 417: return "Expectation Failed";
        case 418: return "I'm a teapot";
        case 422: return "Unprocessable Entity";
        case 423: return "Locked";
        case 424: return "Failed Dependency";
        case 425: return "Unordered Collection";
        case 426: return "Upgrade Required";
        case 428: return "Precondition Required";
        case 429: return "Too Many Requests";
        case 431: return "Request Header Fields Too Large";
        case 500: return "Internal Server Error";
        case 501: return "Not Implemented";
        case 502: return "Bad Gateway";
        case 503: return "Service Unavailable";
        case 504: return "Gateway Timeout";
        case 505: return "HTTP Version Not Supported";
        case 506: return "Variant Also Negotiates";
        case 507: return "Insufficient Storage";
        case 508: return "Loop Detected";
        case 509: return "Bandwidth Limit Exceeded";
        case 510: return "Not Extended";
        case 511: return "Network Authentication Required";
        default:  
          return "Unknown Status"; 
      }
  }
#endif
  ;
  
void Httpd_Gen_Response(C_HTTPD_REQUEST *rqst, int st)
#ifdef _C_HTTPD_BUILTIN
  {
    int i;
    C_BUFFER *bf = rqst->bf;
    bf->count = 0;
    Buffer_Printf(bf,"HTTP/1.1 %d %s\r\n",st,Httpd_Status_Text(st));
    Buffer_Append(bf,"Connection: close\r\n",-1);
    if ( rqst->location )
      {
        Buffer_Printf(bf,"Location: %s\r\n",rqst->location);
      }
    else
      {
        //if ( rqst->cache_control )
        //  Buffer_Printf(bf,);
        if ( rqst->cookie->count ) for ( i=0; i<rqst->cookie->count; ++i )
          Buffer_Printf(bf,"Set-Cookie: %s\r\n",rqst->cookie->at[i]);
          
        if ( rqst->outstrm || rqst->method == HTTPD_HEAD_METHOD )
          {
            if ( rqst->outstrm_charset && rqst->outstrm_type )
              Buffer_Printf(bf,"Content-Type: %s; charset=%s\n\r\n",rqst->outstrm_type,rqst->outstrm_charset);
            else if ( !rqst->outstrm_type || !strncmp_I(rqst->outstrm_type,"text/",5) )
              Buffer_Printf(bf,"Content-Type: %s; charset=utf-8\r\n",rqst->outstrm_type?rqst->outstrm_type:"text/plain");
            //else if ( !rqst->outstrm_type )
            //  Buffer_Printf(bf,"Content-Type: %s\r\n","text/plain");
            else
              Buffer_Printf(bf,"Content-Type: %s\r\n",rqst->outstrm_type);
            if ( rqst->outstrm_length )
              Buffer_Printf(bf,"Content-Length: %d\r\n",rqst->outstrm_length);
            else
              Buffer_Append(bf,"Transfer-Encoding: chunked\r\n",-1);
          }
      }
      
    for ( i = 0; i < rqst->hlns->count; ++i )
      {
        Buffer_Append(bf,rqst->hlns->at[i],-1);
        Buffer_Append(bf,"\r\n",2);
      }
    
    Buffer_Append(bf,"\r\n",2);
    
    if ( rqst->outstrm )
      {
        rqst->left = rqst->outstrm_length;
        if ( rqst->left <= bf->capacity-bf->count)
          {
            int L = C_Minu(rqst->left,bf->capacity-bf->count);
            L = Oj_Read(rqst->outstrm,bf->at+bf->count,L,0);
            rqst->left -= L;
            bf->count += L;
          }
      }
  }  
#endif
  ;
  
void Cbk_Httpd_Sending_Result(C_HTTPD_REQUEST *rqst, int error)
#ifdef _C_HTTPD_BUILTIN
  {
    int L;
    C_BUFFER *bf = rqst->bf;

    if ( error )
      {
        rqst->httpd->callback(rqst->httpd->obj,rqst,HTTPD_STAT_IOFAIL);
        Tcp_Close(rqst->sok);
        return;
      }
    
    if ( rqst->outstrm )
      if ( rqst->outstrm_length )
        {
          if ( !rqst->left ) goto finished;
          L = C_Minu(rqst->left,bf->capacity);
          L = Oj_Read(rqst->outstrm,bf->at,L,0);
          if ( !L ) goto finished;
          rqst->left -= L;
          Tcp_Aio_Send(rqst->sok,bf->at,L,Cbk_Httpd_Sending_Result,rqst);
          return;
        }
      else /*chunked*/
        {
          int i, j;
          char len[30];
          L = bf->capacity - 32;        
          L = Oj_Read(rqst->outstrm,bf->at+30,L,0);
          sprintf(len,"%x\r\n",L);
          i = strlen(len);
          j = 30-i;
          memcpy(bf->at+j,len,i);
          memcpy(bf->at+30+L,"\r\n",2);
          if ( !L ) { rqst->outstrm_length = -1; rqst->left = 0; }
          Tcp_Aio_Send(rqst->sok,bf->at,L,Cbk_Httpd_Sending_Result,rqst);
          return;
        }
      
  finished:
    rqst->httpd->callback(rqst->httpd->obj,rqst,HTTPD_STAT_FINISHED);
    Tcp_Graceful_Close(rqst->sok);
  }
#endif
  ;
  
void Httpd_Continue_Request(C_HTTPD_REQUEST *rqst, int st)
#ifdef _C_HTTPD_BUILTIN
  {
    C_BUFFER *bf = rqst->bf;
    Httpd_Gen_Response(rqst,st);
    Tcp_Aio_Send(rqst->sok,bf->at,bf->count,Cbk_Httpd_Sending_Result,rqst);
  }
#endif
  ;
  
void Httpd_Perform_Request(C_HTTPD_REQUEST *rqst)
#ifdef _C_HTTPD_BUILTIN
  {
    C_BUFFER *bf = rqst->bf;
    int st;
    
    if ( rqst->method == HTTPD_POST_METHOD || rqst->method == HTTPD_PUT_METHOD )
      {
        if ( !rqst->instrm ) 
          {
            rqst->instrm_length = bf->count;
            rqst->instrm = __Refe(Buffer_As_File(bf));
          }
        Oj_Seek(rqst->instrm,0,0);
      }
      
    st = rqst->httpd->callback(rqst->httpd->obj,rqst,HTTPD_RQST_PERFORM);
    if ( st )
      Httpd_Continue_Request(rqst,st);
  }
#endif
  ;
    
void Cbk_Httpd_Getting_Postdta(C_HTTPD_REQUEST *rqst, int error, int count)
#ifdef _C_HTTPD_BUILTIN
  {
    C_BUFFER *bf = rqst->bf;
    
    if ( error )
      {
        rqst->httpd->callback(rqst->httpd->obj,rqst,HTTPD_STAT_IOFAIL);
        Tcp_Close(rqst->sok);
        return;
      }

    bf->count += count;
    rqst->left -= count;
    
    if ( rqst->instrm || bf->count > HTTPD_MAXBUF_POSTDATA_LENGTH )
      {
        if ( !rqst->instrm ) 
          {
            if ( HTTPD_ACCEPT != rqst->httpd->callback(rqst->httpd->obj,rqst,HTTPD_RQST_POSTDTA) )
              {
                rqst->httpd->callback(rqst->httpd->obj,rqst,HTTPD_STAT_LONGRQST);
                Tcp_Close(rqst->sok);
                return;
              }
            if ( !rqst->instrm )
              rqst->instrm = __Refe(Cfile_Temp());
          }
        Oj_Write(rqst->instrm,bf->at,bf->count,-1);
        rqst->instrm_length += bf->count;          
        bf->count = 0;
      }

    if ( rqst->left > 0 )
      {  
        int L;
        Buffer_Grow_Reserve(bf,bf->count+4*1024);      
        L = C_Minu(bf->capacity-bf->count,rqst->left);
        Tcp_Aio_Recv(rqst->sok,bf->at+bf->count,L,L,Cbk_Httpd_Getting_Postdta,rqst);
      }
    else
      {
        Httpd_Perform_Request(rqst);
      }  
  }
#endif
  ;
  
void Httpd_Analyze_Qline(char *text,C_HTTPD_REQUEST *rqst)
#ifdef _C_HTTPD_BUILTIN
  {
    char *S, *q;
    
    S = text;
    while ( *S && *S != '\n' && Isspace(*S) ) ++S;
    q = S;
    while ( *q && !Isspace(*q) ) ++q;
    
    if ( !strncmp_I(S,"GET",q-S) )
      rqst->method = HTTPD_GET_METHOD;
    else if ( !strncmp_I(S,"POST",q-S) )
      rqst->method = HTTPD_POST_METHOD;
    else if ( !strncmp_I(S,"HEAD",q-S) )
      rqst->method = HTTPD_HEAD_METHOD;
    else if ( !strncmp_I(S,"PUT",q-S) )
      rqst->method = HTTPD_PUT_METHOD;
    else if ( !strncmp_I(S,"DELETE",q-S) )
      rqst->method = HTTPD_DELETE_METHOD;
    else
      rqst->method = 0;
    
    S = q;
    while ( *S && Isspace(*S) ) ++S;
    q = S;
    while ( *q && !Isspace(*q) ) ++q;
    
    rqst->uri = Str_Range_Npl(S,q);
    
    S = q;
    while ( *S && Isspace(*S) ) ++S;
    q = S;
    while ( *q && !Isspace(*q) ) ++q;
    
    if ( !strncmp_I(S,"HTTP/1.",7) )
      rqst->httpver = strtol(S+7,0,10);
  }
#endif
  ;
  
void Httpd_Analyze_Headers(char *text,C_DICTO *dct)
#ifdef _C_HTTPD_BUILTIN
  {
    int i;
    char *q, *Q, *S = text;
    while (*S!='\n') ++S; /* skip HTTP/1.x query line */
    q = ++S;
    for (;;)
      {
        while ( *q != '\n' ) ++q;
        *q = 0;
        for ( i = 1; q-i > S && Isspace(q[-i]); ++i ) q[-i] = 0;
        while (Isspace(*S)) ++S;
        if ( !*S ) break; /* empty line => end of headers*/
        Q = S;
        while ( *Q && *Q != ':' ) { *Q = toupper(*Q); ++Q; }
        if ( *Q == ':' )
          {
            *Q = 0;
            for ( i = 1; Q-i > S && Isspace(Q[-i]); ++i ) Q[-i] = 0;
            ++Q;
            while ( Isspace(*Q) ) ++Q;
            Dicto_Put(dct,S,(Q=Str_Copy_Npl(Q,-1)));
          }
        S = ++q;
      }
  }
#endif
  ;

void Cbk_Httpd_Getting_Request(C_HTTPD_REQUEST *rqst, int error, int count)
#ifdef _C_HTTPD_BUILTIN
  {
    int i;
    C_BUFFER *bf = rqst->bf;

    if ( error )
      {
        rqst->httpd->callback(rqst->httpd->obj,rqst,HTTPD_STAT_IOFAIL);
        Tcp_Close(rqst->sok);
        return;
      }

    bf->count += count;

    if ( bf->count >= HTTPD_MAX_REQUEST_LENGTH )
      {
        rqst->httpd->callback(rqst->httpd->obj,rqst,HTTPD_STAT_LONGRQST);
        Tcp_Close(rqst->sok);
        return;
      }

    i = rqst->nline; 
  
  next_line:
    
    while ( i < bf->count && bf->at[i] != '\n' ) ++i;
    
    if ( bf->at[i] != '\n' )
      Tcp_Aio_Recv(rqst->sok,bf->at+bf->count,bf->capacity-bf->count,1,Cbk_Httpd_Getting_Request,rqst);
    else
      {
        if ( !rqst->nline )
          { rqst->nline = ++i; goto next_line; }
        else
          {
            int nonempty = 0;
            ++i;
            while ( rqst->nline < i )
              { nonempty |= !Isspace(bf->at[rqst->nline]); ++rqst->nline; }
            if ( nonempty )
              goto next_line;
            Httpd_Analyze_Qline(bf->at,rqst);
            Httpd_Analyze_Headers(bf->at,rqst->qhdr);
            rqst->referer = Str_Trim_Copy_Npl(Dicto_Get(rqst->qhdr,"REFERER",0),-1);
            if ( rqst->method == HTTPD_POST_METHOD 
              || rqst->method == HTTPD_PUT_METHOD )
              {
                memmove(bf->at,bf->at+rqst->nline,bf->count-rqst->nline);
                bf->count -= rqst->nline;
                rqst->left = Str_To_Int(Dicto_Get(rqst->qhdr,"CONTENT-LENGTH","0"));
                rqst->instrm_type = Str_Trim_Copy_Npl(Dicto_Get(rqst->qhdr,"CONTENT-TYPE","text/html"),-1);
                if ( bf->count >= rqst->left )
                  {
                    bf->count = rqst->left;
                    Httpd_Perform_Request(rqst);
                  }
                else
                  {
                    int L;
                    rqst->left -= bf->count;
                    Buffer_Grow_Reserve(bf,HTTPD_MAXBUF_POSTDATA_LENGTH);      
                    L = C_Minu(bf->capacity-bf->count,rqst->left);
                    Tcp_Aio_Recv(rqst->sok,bf->at+bf->count,L,L,Cbk_Httpd_Getting_Postdta,rqst);
                  }                
              }
            else if ( rqst->method == HTTPD_GET_METHOD 
              || rqst->method == HTTPD_HEAD_METHOD 
              || rqst->method == HTTPD_DELETE_METHOD )
              {
                Httpd_Perform_Request(rqst);
              }
            else
              {
                rqst->httpd->callback(rqst->httpd->obj,rqst,HTTPD_STAT_BADMETHOD);
                Tcp_Close(rqst->sok);
                return;
              }
          }
      }
  }
#endif
  ;
  
void Cbk_Httpd_Accept(C_HTTPD *httpd,int error,C_TCPSOK *sok)
#ifdef _C_HTTPD_BUILTIN
  {
    if ( error )
      {
        httpd->callback(httpd->obj,0,HTTPD_STAT_ACCEPTFAIL);
        return;
      }
    else
      {
        C_HTTPD_REQUEST *rqst;
        Tcp_Aio_Accept(httpd->sok,Cbk_Httpd_Accept,httpd);
        rqst = Httpd_Request(httpd,sok);
        if ( HTTPD_ACCEPT == httpd->callback(httpd->obj,rqst,HTTPD_RQST_CONNECT) )
          Tcp_Aio_Recv(rqst->sok,rqst->bf->at,rqst->bf->capacity,1,Cbk_Httpd_Getting_Request,rqst);
        else
          httpd->callback(httpd->obj,rqst,HTTPD_STAT_REJECTED);
      }
  }
#endif
  ;
  
void Httpd_Listen(C_HTTPD *httpd, char *host, int port, int listen)
#ifdef _C_HTTPD_BUILTIN
  {
    httpd->sok = __Refe(Tcp_Listen(host,port,listen));
    free(httpd->host);
    httpd->host = Str_Copy_Npl(host,-1);
    httpd->port = port;
    Tcp_Aio_Accept(httpd->sok,Cbk_Httpd_Accept,httpd);
  }
#endif
  ;
  
void Httpd_Shutdown(C_HTTPD *httpd)
#ifdef _C_HTTPD_BUILTIN
  {
    Tcp_Shutdown(httpd->sok);
  }
#endif
  ;
  
void C_HTTPD_Destruct(C_HTTPD *httpd)
#ifdef _C_HTTPD_BUILTIN
  {
    STRICT_REQUIRE(httpd->rqst == 0);
    free(httpd->host);
    __Unrefe(httpd->obj);
    __Unrefe(httpd->sok);
    __Destruct(httpd);
  }
#endif
  ;
  
C_HTTPD *Httpd_Server(httpd_callback_t callback,void *obj)
#ifdef _C_HTTPD_BUILTIN
  {
    C_HTTPD *httpd = __Object_Dtor(sizeof(C_HTTPD),C_HTTPD_Destruct);
    httpd->obj  = __Refe(obj);
    httpd->callback = callback;
    return httpd;
  }
#endif
  ;
  
#endif /* C_once_BE85262D_CDA8_4AF5_B684_8A30EB6D7370 */

