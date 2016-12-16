
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_F8F16072_F92E_49E7_A983_54F60965F4C9
#define C_once_F8F16072_F92E_49E7_A983_54F60965F4C9

#include "../C+.hc"
#include "../string.hc"
#include "../file.hc"
#include "../datetime.hc"
#include "../system/tasque.hc"

#ifdef _MSC_VER
#pragma comment(lib,"ws2_32.lib")
#endif

#ifdef __windoze
  #include <winsock2.h>
  #ifdef _IPV6
    #include <ws2tcpip.h>
  #endif
  typedef SOCKET socket_t;
#else
  #include <errno.h>
  #include <sys/types.h>
  #include <sys/socket.h>
  #include <netdb.h>
  #include <netinet/in.h>
  #include <arpa/inet.h>
  typedef int socket_t;
  #define INVALID_SOCKET -1
  #define SD_SEND SHUT_WR
  #define SD_BOTH SHUT_RDWR
#endif

#ifdef _BUILTIN
#define _C_TCPIP_BUILTIN
#endif

typedef struct ipaddr_t 
  { 
    u32_t v4;
  #ifdef _IPV6
    u16_t e6[6];
  #endif 
  } ipaddr_t;

typedef struct 
  {
    struct sockaddr_in addr4;
  #ifdef _IPV6
    struct sockaddr_in6 addr6;
  #endif
  } IPV4V6_ADDR_MIX;

void Tcp_Expand_Ip_Addr(ipaddr_t *ip, int port, IPV4V6_ADDR_MIX *addr, int *addr_len)
#ifdef _C_TCPIP_BUILTIN
  {
    memset(addr,0,sizeof(*addr));
    #ifdef _IPV6
    if ( !memcmp( ip->e6, "\xff\xff\0\0\0\0\0\0\0\0\0\0", 12) )
      {
    #endif
        addr->addr4.sin_family = AF_INET;
        addr->addr4.sin_port   = htons((ushort_t)port);
        addr->addr4.sin_addr.s_addr = ip->v4;
        *addr_len = sizeof(addr->addr4);
    #ifdef _IPV6
      }
    else
      {
        addr->addr6.sin6_family = AF_INET6;
        addr->addr6.sin6_port   = htons(port);
        memcpy(&addr->addr6.sin6_addr,ip,sizeof(*ip));
        *addr_len = sizeof(addr->addr6);
      }
    #endif
  } 
#endif
  ;
  
ipaddr_t Tcp_Sin_Ip(void *_a)
#ifdef _C_TCPIP_BUILTIN
  {
    ipaddr_t ip;
    struct sockaddr_in *a = _a;
    memset(&ip,sizeof(ip),0);
    if ( a->sin_family == AF_INET ) 
      {
        ip.v4 = (ulong_t)a->sin_addr.s_addr;
  #ifdef _IPV6
        ip.e6[0] = 0x0ffff;
      }
    else if ( ((struct sockaddr_in6*)a)->sin6_family == AF_INET6 )
      {
        memcpy(&ip,&((struct sockaddr_in6*)a)->sin6_addr,sizeof(ip));
  #endif  
      }
    return ip; 
  }
#endif
  ;
  
typedef struct _C_TCPSOK
  {
    ipaddr_t  ip;
    int       skt;
    int       port;
  } C_TCPSOK;

enum  
  {
    TCP_AIO_COMPLETE    = 0,
    TCP_AIO_FAIL        = 0x80000000,
    TCP_PERMANENT_ERROR = 0x40000000,
    TCP_IS_CLOSED       = 0x20000000,
  };

#ifdef __windoze

#define Tcp_Errno() WSAGetLastError()

void _WSA_Term(void)
#ifdef _C_TCPIP_BUILTIN
  {
    WSACleanup();
  }
#endif
  ;
  
void _WSA_Init()
#ifdef _C_TCPIP_BUILTIN
  {
    static int wsa_status = -1;
    static WSADATA wsa_data = {0};
    if ( wsa_status != 0 )
      {
        if ( 0 != WSAStartup(MAKEWORD(2, 2), &wsa_data) )
          { 
            __Raise(C_ERROR_SUBSYSTEM_INIT,"failed to initialize WSA subsystem");
          }
        else
          {
            wsa_status = 0;
            atexit(_WSA_Term);
          }
      }
  }
#endif
  ;

#else
#define Tcp_Errno() errno
#define _WSA_Init() 
#endif

#define Tcp_Format_Error() Tcp_Format_Error_Code(Tcp_Errno())

char *Tcp_Format_Error_Code(int err)
#ifdef _C_TCPIP_BUILTIN
  {
  #ifdef __windoze
    char *msg = __Malloc(1024);
    FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS |
                  FORMAT_MESSAGE_MAX_WIDTH_MASK, NULL, err,
                  MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                  (LPSTR)msg, 1024,0);
    return msg;  
  #else
    return strerror(errno);
  #endif
  }
#endif
  ;

#define Ip_Format(Ip) Ipv4_Format(Ip)
#define Ip_Format_Npl(Ip) Ipv4_Format_Npl(Ip)
#define Ipv4_Format(Ip) __Pool(Ipv4_Format_Npl(Ip))
char *Ipv4_Format_Npl(ipaddr_t ip)
#ifdef _C_TCPIP_BUILTIN
  {
    return __Format_Npl("%d.%d.%d.%d"
              ,( ip.v4     &0x0ff)
              ,((ip.v4>>8) &0x0ff)
              ,((ip.v4>>16)&0x0ff)
              ,((ip.v4>>24)&0x0ff));
  }
#endif
  ;
  
int Dns_IPv4_Resolve(char *host, ipaddr_t *ip)
#ifdef _C_TCPIP_BUILTIN
  {
    struct hostent *hstn = 0;
   
    memset(ip,0,sizeof(*ip));
  
  #ifdef _IPV6
    ip->e6[0] = 0x0ffff;
  #endif
        
    if ( !strcmp_I(host,"localhost") ) 
      {
        ip->v4 = 0x0100007f;
        return 0;
      }
      
    ip->v4 = inet_addr(host);
    if ( ip->v4 != 0x0ffffffff ) return 0;
  l:
    if ( !!(hstn = gethostbyname(host)) )
      {
        memcpy(&ip->v4,hstn->h_addr,C_MAX(sizeof(ip->v4),hstn->h_length));
        return 0;
      }
    else
      {
        int err = Tcp_Errno();
        if ( err == TRY_AGAIN )
          goto l;
        return err;
      }
    return 0;
  }        
#endif
  ;

ipaddr_t Dns_Resolve(char *host)
#ifdef _C_TCPIP_BUILTIN
  {
    ipaddr_t ip;

    _WSA_Init();

    switch ( Dns_IPv4_Resolve(host,&ip) )
      {
        case 0:
          break;
        case NO_RECOVERY:
          __Raise(C_ERROR_DNS,"unrecoverable DNS error");
        default: 
          __Raise_Format(C_ERROR_DNS,("DNS couldn't resolve ip for name %s",host));
      }
    return ip;
  }        
#endif
  ;
  
void Tcp_Close(C_TCPSOK *sok)
#ifdef _C_TCPIP_BUILTIN
  {
    if ( sok->skt != INVALID_SOCKET ) 
      {
#ifdef __windoze
        closesocket(sok->skt);
#else      
        close(sok->skt);
#endif
        sok->skt = -1;
      }
  }
#endif
  ;
  
void Tcp_Graceful_Close(C_TCPSOK *sok)
#ifdef _C_TCPIP_BUILTIN
  {
    if ( sok->skt != INVALID_SOCKET ) 
      {
        struct linger lin;
        lin.l_onoff=1;
        lin.l_linger=3;      
        setsockopt(sok->skt,SOL_SOCKET,SO_LINGER,(void*)&lin,sizeof(lin));
        shutdown(sok->skt,SD_BOTH);
        Switch_to_Thread();
        Tcp_Close(sok);
      }
  }
#endif
  ;

void C_TCPSOK_Destruct(C_TCPSOK *sok)
#ifdef _C_TCPIP_BUILTIN
  {
    Tcp_Graceful_Close(sok);
    __Destruct(sok);
  }
#endif
  ;
  
int Tcp_Read(C_TCPSOK *sok, void *out, int count, int mincount)
#ifdef _C_TCPIP_BUILTIN  
  {
    char *b = out;
    int cc = count;
    while ( cc )
      {
        int q = recv(sok->skt,b,cc,0);
        if ( q < 0 )
          {
            int err = Tcp_Errno();
            __Raise_Format(C_ERROR_IO,("tcp recv failed with error %s",
                                          Tcp_Format_Error_Code(err)));
          }
        STRICT_REQUIRE( q <= cc );
        cc -= q;
        b += q;
        if ( count-cc >= mincount )
          break;
      }
    return count-cc;
  }
#endif
  ;

int Tcp_Write(C_TCPSOK *sok, void *out, int count, int mincount)
#ifdef _C_TCPIP_BUILTIN
  {
    char *b = out;
    int cc = count;
    while ( cc )
      {
        int q = send(sok->skt,b,cc,0);
        if ( q < 0 )
          {
            int err = Tcp_Errno();
            __Raise_Format(C_ERROR_IO,("tcp send failed with error %s",
                                          Tcp_Format_Error_Code(err)));
          }
        STRICT_REQUIRE( q <= cc );
        cc -= q;
        b += q;
        if ( q == 0 && count-cc >= mincount )
          break;
      }
    return count-cc;
  }
#endif
  ;
 
typedef void (*tcp_resolve_callback_t)(void *obj, int status, ipaddr_t ip);
typedef void (*tcp_recv_callback_t)(void *obj, int status, int count);
typedef void (*tcp_send_callback_t)(void *obj, int status);
typedef void (*tcp_accept_callback_t)(void *obj, int status, C_TCPSOK *sok);
typedef void (*tcp_any_callback_t)(void *obj, int status, ...);
typedef void (*tcp_connect_callback_t)(void *obj,int status);

typedef struct _C_TCP_IOT
  {
    socket_t skt;
    union 
      {
        uquad_t accum;
        ipaddr_t ip; 
        IPV4V6_ADDR_MIX addr;
      };
    union
      {
        int mincount;
        int port;
      };
    int err, count;
    void *obj, *dta;
    char *host;
    tcp_any_callback_t cbk;
    struct _C_TCP_IOT *next;
  } C_TCP_IOT;
 
#ifdef _C_TCPIP_BUILTIN
static C_TCP_IOT *Tcp_Iot_Pool = 0;
#endif

void C_TCP_IOT_Destruct(C_TCP_IOT *iot)
#ifdef _C_TCPIP_BUILTIN
  {
    free(iot->host);
    __Unrefe(iot->obj);
    iot->next = Tcp_Iot_Pool;
    Tcp_Iot_Pool = iot;
    __Destruct(iot);
  }
#endif
  ;

C_TCP_IOT *Tcp_Alloc_Iot()
#ifdef _C_TCPIP_BUILTIN
  {
    return __Object_Dtor(sizeof(C_TCP_IOT),C_TCP_IOT_Destruct);
  }
#endif
  ;
  
void Wrk_Tcp_Send(C_TCP_IOT *iot)
#ifdef _C_TCPIP_BUILTIN
  {
    char *b = iot->dta;
    int count = iot->count;
    int cc = count;
    while ( cc )
      {
        int q = send(iot->skt,b,cc,0);
        if ( q < 0 )
          {
            iot->count = count-cc;
            iot->err = Tcp_Errno();
            return;
          }
        STRICT_REQUIRE( q <= cc );
        cc -= q;
        b += q;
        if ( count-cc >= iot->mincount )
          break;
      }
    iot->count = count-cc;
    iot->err = 0;
  }
#endif
  ;
  
void Cbk_Tcp_Send(C_TCPSOK *sok, C_TCP_IOT *iot, int status)
#ifdef _C_TCPIP_BUILTIN
  {
    if ( iot->err && sok->skt == INVALID_SOCKET )
      iot->cbk(iot->obj,TCP_AIO_FAIL|TCP_PERMANENT_ERROR|TCP_IS_CLOSED);
    else if ( status || iot->err )
      iot->cbk(iot->obj,TCP_AIO_FAIL);
    else
      iot->cbk(iot->obj,TCP_AIO_COMPLETE);
  }
#endif
  ;
    
void Tcp_Aio_Send(C_TCPSOK *sok, void *out, int count, /*tcp_send_callback_t*/ void *callback, void *obj)
#ifdef _C_TCPIP_BUILTIN
  {
    __Auto_Release 
      {
        C_TCP_IOT *iot = Tcp_Alloc_Iot();
        iot->skt = sok->skt;
        iot->cbk = (tcp_any_callback_t)callback;
        iot->mincount = iot->count = count;
        iot->dta = out;
        iot->obj = __Refe(obj);
        Tasque_Queue((tasque_proc_t)Wrk_Tcp_Send,iot,(tasque_update_t)Cbk_Tcp_Send,sok);
      }
  }
#endif
  ;

void Wrk_Tcp_Recv(C_TCP_IOT *iot)
#ifdef _C_TCPIP_BUILTIN
  {
    char *b = iot->dta;
    int count = iot->count;
    int cc = count;
    iot->err = 0;
    while ( cc )
      {
        int q = recv(iot->skt,b,cc,0);
        if ( q < 0 )
          {
            iot->err = Tcp_Errno();
            break;
          }
        if ( !q )
          {
            if ( count-cc < iot->mincount )
              iot->err = -1;
            break;
          }
        STRICT_REQUIRE( q <= cc );
        cc -= q;
        b += q;
        if ( count-cc >= iot->mincount )
          break;
      }
    
    iot->count = count-cc;
    
    {
      char bf[80];
      char bbf[128];
      sprintf(bf,"err:%%d,count:%%d,bytes:%%.%ds\n",C_Minu(iot->count,80)); 
      sprintf(bbf,bf,iot->err,iot->count,iot->dta);
    }
  }
#endif
  ;
  
void Cbk_Tcp_Recv(C_TCPSOK *sok, C_TCP_IOT *iot, int status)
#ifdef _C_TCPIP_BUILTIN
  {
    if ( iot->err && sok->skt == INVALID_SOCKET )
      iot->cbk(iot->obj,TCP_AIO_FAIL|TCP_PERMANENT_ERROR|TCP_IS_CLOSED,0);
    else if ( status || iot->err )
      iot->cbk(iot->obj,TCP_AIO_FAIL,0);
    else
      iot->cbk(iot->obj,TCP_AIO_COMPLETE,iot->count);
  }
#endif
  ;
    
void Tcp_Aio_Recv(C_TCPSOK *sok, void *out, int count, int mincount, /*tcp_recv_callback_t*/ void *callback, void *obj)
#ifdef _C_TCPIP_BUILTIN
  {
    __Auto_Release 
      {
        C_TCP_IOT *iot = Tcp_Alloc_Iot();
        iot->skt = sok->skt;
        iot->cbk = (tcp_any_callback_t)callback;
        iot->count = count;
        iot->mincount = mincount?mincount:count;
        iot->dta = out;
        iot->obj = __Refe(obj);
        Tasque_Queue((tasque_proc_t)Wrk_Tcp_Recv,iot,(tasque_update_t)Cbk_Tcp_Recv,sok);
      }
  }
#endif
  ;
  
C_TCPSOK *Tcp_Socket()
#ifdef _C_TCPIP_BUILTIN  
  {
    static C_FUNCTABLE funcs[] = 
      { {0},
        {Oj_Destruct_OjMID,    C_TCPSOK_Destruct},
        {Oj_Close_OjMID,       Tcp_Close},
        {Oj_Read_OjMID,        Tcp_Read},
        {Oj_Write_OjMID,       Tcp_Write},
        //{Oj_Available_OjMID,   Tcp_Available},
        //{Oj_Eof_OjMID,         Tcp_Eof},
        {0}
      };

    C_TCPSOK *sok = __Object(sizeof(C_TCPSOK),funcs);
    sok->skt = INVALID_SOCKET;
    return sok;
  }
#endif
  ;

void Wrk_Tcp_Connect(C_TCP_IOT *iot)
#ifdef _C_TCPIP_BUILTIN
  {
    if ( iot->skt != INVALID_SOCKET )
      { 
        if ( 0 > connect(iot->skt,(struct sockaddr *)&iot->addr,iot->count) )
          iot->err = Tcp_Errno();
      }
  }
#endif
  ;
  
void Cbk_Tcp_Connect(C_TCPSOK *sok, C_TCP_IOT *iot, int status)
#ifdef _C_TCPIP_BUILTIN
  {
    if ( iot->err || status )
      {
        Tcp_Close(sok);
        iot->cbk(iot->obj,TCP_AIO_FAIL);
      }
    else
      iot->cbk(iot->obj,TCP_AIO_COMPLETE);
  }
#endif
  ;
        
#define Tcp_Ip_Connect(Sok,Ip,Port) Tcp_Ip_Connect_(0,Sok,Ip,Port,0,0)
#define Tcp_Aio_Ip_Connect(Sok,Ip,Port,callback,obj) Tcp_Ip_Connect_(1,Sok,Ip,Port,callback,obj)

int Tcp_Ip_Connect_(int use_aio, C_TCPSOK *sok, ipaddr_t ip, int port, /*tcp_connect_callback_t*/ void *callback, void *obj)
#ifdef _C_TCPIP_BUILTIN
  {
    socket_t skt;
    int conerr;
    int addr_len = 0;
    IPV4V6_ADDR_MIX addr;
    
    _WSA_Init();

    Tcp_Expand_Ip_Addr(&ip,port,&addr,&addr_len);
    sok->port = port;
    sok->ip   = ip;
    
    skt = socket(PF_INET,SOCK_STREAM,IPPROTO_TCP);
    sok->skt = skt;

    if ( use_aio )
      {
        __Auto_Release
          {
            C_TCP_IOT *iot = Tcp_Alloc_Iot();
            memcpy(&iot->addr,&addr,sizeof(addr));
            iot->count = addr_len;
            iot->skt = sok->skt;
            iot->cbk = (tcp_any_callback_t)callback;
            iot->obj = __Refe(obj);
            Tasque_Queue((tasque_proc_t)Wrk_Tcp_Connect,iot,(tasque_update_t)Cbk_Tcp_Connect,sok);
          }
        return 0;
      }
    else
      {
        conerr = (skt != INVALID_SOCKET ) ? connect(skt,(struct sockaddr*)&addr,addr_len) : -1;
        
        if ( conerr < 0 )
          {
            int err = Tcp_Errno();
            __Raise_Format(C_ERROR_IO,
                            ("tcp connection failed: sok %d, point %s:%d, error %s"
                            ,skt
                            ,Ip_Format(ip)
                            ,port
                            ,Tcp_Format_Error_Code(err)));
          }
          
        return 0;
      }
  }
#endif
  ;

  
void Wrk_Tcp_Resolve(C_TCP_IOT *iot)
#ifdef _C_TCPIP_BUILTIN
  {
    iot->err = Dns_IPv4_Resolve(iot->host,&iot->ip);
  }
#endif
  ;
  
void Cbk_Tcp_Resolve(void *_, C_TCP_IOT *iot, int status)
#ifdef _C_TCPIP_BUILTIN
  {
    if ( iot->cbk ) 
      {
        if ( status )
          {
            iot->cbk(iot->obj,TCP_AIO_FAIL,0);
          }
        else if ( iot->err )
          {
            if ( iot->err == HOST_NOT_FOUND )
              iot->cbk(iot->obj,TCP_AIO_FAIL|TCP_PERMANENT_ERROR,iot->ip);
            else
              iot->cbk(iot->obj,TCP_AIO_FAIL,iot->ip);
          }
        else
          iot->cbk(iot->obj,0,iot->ip);
      }
  }
#endif
  ;
   
void Tcp_Aio_Resolve(char *host, /*tcp_resolve_callback_t*/ void *callback, void *obj)
#ifdef _C_TCPIP_BUILTIN
  {
    _WSA_Init();

    __Auto_Release
      { 
        C_TCP_IOT *o = Tcp_Alloc_Iot();
        o->host = Str_Copy_Npl(host,-1);
        o->cbk = (tcp_any_callback_t)callback;
        o->obj = __Refe(obj);
        Tasque_Queue((tasque_proc_t)Wrk_Tcp_Resolve,o,(tasque_update_t)Cbk_Tcp_Resolve,0);
      }
  }
#endif
  ;

typedef struct _C_HOST_CONNECT
  {
    C_TCPSOK *sok;
    int port;
    void *cbkobj;
    tcp_connect_callback_t callback;
  } C_HOST_CONNECT;
  
void C_HOST_CONNECT_Destruct(C_HOST_CONNECT *o)
#ifdef _C_TCPIP_BUILTIN
  {
    __Unrefe(o->sok);
    __Unrefe(o->cbkobj);
    __Destruct(o);
  }
#endif
  ;
    
void Cbk_Tcp_Host_Connect(C_HOST_CONNECT *o, int status, ipaddr_t ip)
#ifdef _C_TCPIP_BUILTIN
  {
    if ( status )
      ( o->callback ) ? o->callback( o->cbkobj, status ) : 0;
    else
      Tcp_Aio_Ip_Connect(o->sok,ip,o->port,o->callback,o->cbkobj);
  }
#endif
  ;
      
void Tcp_Connect(C_TCPSOK *sok,char *host,int port)
#ifdef _C_TCPIP_BUILTIN
  {
    ipaddr_t ip = Dns_Resolve(host);
    Tcp_Ip_Connect(sok,ip,port);    
  }
#endif
  ;

void Tcp_Aio_Connect(C_TCPSOK *sok,char *host,int port, /*tcp_connect_callback_t*/ void *callback,void *obj)
#ifdef _C_TCPIP_BUILTIN
  {
    C_HOST_CONNECT *o = __Object_Dtor(sizeof(C_HOST_CONNECT),C_HOST_CONNECT_Destruct);
    o->sok = __Refe(sok);
    o->port = port;
    o->cbkobj = __Refe(obj);
    o->callback = callback;
    Tcp_Aio_Resolve(host,(tcp_resolve_callback_t)Cbk_Tcp_Host_Connect,o);
  }
#endif
  ;

C_TCPSOK *Tcp_Open(char *host, int port)
#ifdef _C_TCPIP_BUILTIN
  {
    C_TCPSOK *sok = Tcp_Socket();
    Tcp_Connect(sok,host,port);
    return sok;
  }
#endif
  ;

C_TCPSOK *Tcp_Listen(char *host, int port, int listlen)
#ifdef _C_TCPIP_BUILTIN
  {
    C_TCPSOK *sok;
    ipaddr_t ip;
    int addr_len = 0, on;
    IPV4V6_ADDR_MIX addr;
    
    ip = Dns_Resolve(host);
    Tcp_Expand_Ip_Addr(&ip,port,&addr,&addr_len);
    
    sok = __Refe(Tcp_Socket());
    sok->port = port;
    sok->ip = ip;
    
    if ( INVALID_SOCKET == (sok->skt = socket(PF_INET,SOCK_STREAM,IPPROTO_TCP)) )  goto sok_error;
    setsockopt( sok->skt, SOL_SOCKET, SO_REUSEADDR, (void*)&on, sizeof(on) );
    if ( -1 == bind(sok->skt,(struct sockaddr*)&addr,addr_len) ) goto sok_error;
    if ( -1 == listen(sok->skt,(listlen?listlen:SOMAXCONN)) ) goto sok_error;

    if ( sok->skt == INVALID_SOCKET )
      {       
    sok_error: 
        __Raise_Format(C_ERROR_IO,
                        ("tcp bind/listen failed: sok %d, point %s:%d, error %s"
                        ,sok->skt
                        ,Ip_Format(ip)
                        ,port
                        ,Tcp_Format_Error()));
      }
      
    return sok;
  }
#endif
  ;

#ifdef _C_TCPIP_BUILTIN

void Cbk_Tcp_Accept(C_TCPSOK *sok, C_TCP_IOT *iot, int status)
  {
    if ( !status && !iot->err )
      {
        C_TCPSOK *sok2 = Tcp_Socket();
        sok2->ip   = iot->ip;
        sok2->port = iot->port;
        sok2->skt  = iot->skt;
        iot->cbk(iot->obj,TCP_AIO_COMPLETE,sok2);
      }
    else
      {
        if ( sok->skt == INVALID_SOCKET )
          iot->cbk(iot->obj,TCP_AIO_FAIL|TCP_PERMANENT_ERROR|TCP_IS_CLOSED);
        else
          iot->cbk(iot->obj,TCP_AIO_FAIL);
      }
  }

void Wrk_Tcp_Accept(C_TCP_IOT *iot)
  {
    int skt,addr_len = sizeof(iot->addr);
    
    skt = accept(iot->skt,(struct sockaddr*)&iot->addr,&addr_len);
    if ( skt != INVALID_SOCKET )
      {
        iot->ip   = Tcp_Sin_Ip(&iot->addr);
        iot->port = ntohs(iot->addr.addr4.sin_port);
        iot->skt  = skt;
        iot->err  = 0;
        iot->count = addr_len;
      }
    else
      {
        iot->skt = INVALID_SOCKET;
        iot->err = Tcp_Errno();
      }
  }
#endif

void Tcp_Aio_Accept(C_TCPSOK *sok, /*tcp_accept_callback_t*/ void *callback, void *obj)
#ifdef _C_TCPIP_BUILTIN
  {
    __Auto_Release
      {
        C_TCP_IOT *iot = Tcp_Alloc_Iot();
        iot->skt = sok->skt;
        iot->cbk = (tcp_any_callback_t)callback;
        iot->obj = __Refe(obj);
        Tasque_Queue((tasque_proc_t)Wrk_Tcp_Accept,iot,(tasque_update_t)Cbk_Tcp_Accept,sok);
      }
  }
#endif
  ;

#define Tcp_Shutdown(Sok) Tcp_Graceful_Close(Sok)

#endif /* C_once_F8F16072_F92E_49E7_A983_54F60965F4C9 */

