
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_36F09FA7_8AEC_4584_91B3_D25C37490B80
#define C_once_36F09FA7_8AEC_4584_91B3_D25C37490B80

#include "../C+.hc"
#include "../string.hc"
#include "../dicto.hc"

#ifdef _BUILTIN
#define _C_URL_BUILTIN
#endif

enum 
  {
    URLX_UNKNOWN  = 0,
    URLX_HTTP     = 80,
    URLX_HTTPS    = 443,
    URLX_FILE     = -1,
  };

typedef struct _C_URL 
  {
    char *host, *user, *passw, *query, *args, *anchor, *uri, *endpoint, *proto_s;
    int   port, proto;
    C_DICTO *argv;
  } C_URL;

void C_URL_Destruct(C_URL *url)
#ifdef _C_URL_BUILTIN
  {
    free(url->host);
    free(url->user);
    free(url->passw);
    free(url->query);
    free(url->args);
    free(url->anchor);
    free(url->uri);
    free(url->endpoint);
    free(url->proto_s);
    __Unrefe(url->argv);
    __Destruct(url);
  }
#endif
  ;
  
int Url_Proto(char *S)
#ifdef _C_URL_BUILTIN
  {
    if ( !strcmp_I(S,"http")  )  return URLX_HTTP;
    if ( !strcmp_I(S,"https") )  return URLX_HTTPS;
    if ( !strcmp_I(S,"file")  )  return URLX_FILE;
    return URLX_UNKNOWN;
  }
#endif
  ;
  
enum 
  {
    URLX_PARSE_NOHOST = 1,
    URLX_PARSE_ARGUMENTS = 2,
    URLX_PARSE_HOST_IF_PROTO = 4,
  };

#define Url_Parse(Url) Url_Parse_(Url,0)
#define Url_Parse_Uri(Url) Url_Parse_(Url,URLX_PARSE_NOHOST)
#define Url_Parse_Full(Url) Url_Parse_(Url,URLX_PARSE_ARGUMENTS)
C_URL *Url_Parse_(char *url,int flags)
#ifdef _C_URL_BUILTIN
  {
    C_URL *urlout = 0;
    if ( url ) __Auto_Ptr(urlout)
      {
        /* proto://user:passwd@host:port/query#anchor?args */
      
        char *p;
        char *pS = url;
        
        char *proto = 0;
        char *host  = 0;
        char *user  = 0;
        char *passw = 0;
        char *uri   = 0;
        char *args  = 0;
        char *query = 0;
        char *anchor= 0;
        char *endpoint = 0;
        int   port  = 0;
        
        while ( *pS && Isspace(*pS) ) ++pS;
        
        if ( !(flags&URLX_PARSE_NOHOST)  )
          {
            p = pS;
            while ( *p && Isalpha(*p) ) ++p;
            
            if ( *p && *p == ':' && p[1] && p[1] == '/' && p[2] && p[2] == '/' )
              {
                proto = Str_Range(pS,p);
                pS = p+3;
              }
            else if ( flags&URLX_PARSE_HOST_IF_PROTO )
              goto parse_uri;
                
            p = pS;
            while ( *p && (Isalnum(*p) || *p == '.' || *p == '-' || *p == ':' || *p == '_') ) ++p;
            
            if ( *p == '@' ) // user/password
              {
                char *q = pS;
                while ( *q != '@' && *q != ':' ) ++q;
                if ( *q == ':' ) 
                  {
                    user = Str_Range(pS,q);
                    passw = Str_Range(q+1,p);
                  }
                else
                  user = Str_Range(pS,p);
                pS = p+1;
              }
              
            p = pS;
            while ( *p && (Isalnum(*p) || *p == '.' || *p == '-' || *p == '_') ) ++p;
            
            if ( *p == ':' )
              {
                host = Str_Range(pS,p);
                pS = p+1; ++p;
                while ( *p && Isdigit(*p) ) ++p;
                if ( *p == '/' || !*p )
                  { 
                    port = strtol(pS,0,10); 
                  }
                else
                  __Raise(C_ERROR_ILLFORMED,"invalid port value");
                pS = p;
              }
            else if ( !*p || *p == '/' )
              {
                host = Str_Range(pS,p);
                pS = p;
              }
          }
        
     parse_uri:         
        uri = Str_Copy(pS);  
        
        p = pS;
        while ( *p && *p != '?' && *p != '#' ) ++p;
        query = Str_Range(pS,p);

        if ( *p == '#' )
          {
            pS = ++p;
            while ( *p && *p != '?' ) ++p;
            anchor = Str_Range(pS,p);
          }
           
        if ( *p == '?' ) 
          {
            pS = ++p;
            while ( *p ) ++p;
            args = Str_Range(pS,p);
          }
                          
        urlout = __Object_Dtor(sizeof(C_URL),C_URL_Destruct);
        urlout->args  = __Retain(args);
        urlout->anchor= __Retain(anchor);
        urlout->query = __Retain(query);
        urlout->uri   = __Retain(uri);
        urlout->host  = __Retain(host);
        urlout->passw = __Retain(passw);
        urlout->user  = __Retain(user);
        urlout->port  = port;
        urlout->proto = Url_Proto(proto);
        urlout->proto_s = __Retain(proto);

        if ( proto )        
          {
            Str_Cat(&endpoint,proto,-1);
            Str_Cat(&endpoint,"://",3);
          }
        
        if ( host )
          {
            Str_Cat(&endpoint,host,-1);
            if ( port )
              {
                char S[13];
                sprintf(S,":%u",port);
                Str_Cat(&endpoint,S,-1);
              }
          }
          
        urlout->endpoint = __Retain(endpoint);
        
        if ( flags & URLX_PARSE_ARGUMENTS )
          {
            int i;
            C_ARRAY *a = Str_Split(urlout->args,"&");
            urlout->argv = __Refe(Dicto_Ptrs());
            for ( i = 0; i < a->count; ++i )
              {
                char *v = 0;
                char *p = strchr(a->at[i],'=');
                if ( p )
                  {
                    v = p+1;
                    *p = 0;
                  }
                Dicto_Put(urlout->argv,a->at[i],Str_Copy_Npl(v,-1));
              }
          }
      }
      
    return urlout;
  }
#endif
  ;

typedef struct _C_URL_COMPOSER
  {
    char *S;
    int  capacity;
  } C_URL_COMPOSER;

void Url_Compose_Dicto_Fitler(char *name, void *val, void *o)
#ifdef _C_URL_BUILTIN
  {
    char **inout  = &((C_URL_COMPOSER*)o)->S;
    int *capacity = &((C_URL_COMPOSER*)o)->capacity;
    int count     = *inout?strlen(*inout):0;
    count += __Elm_Append(inout,count,"&",1,1,capacity);
    count += __Elm_Append(inout,count,name,strlen(name),1,capacity);
    if ( val )
      {
        int i, iE = strlen(val);
        char C[4];
        count += __Elm_Append(inout,count,"=",1,1,capacity);
        for ( i = 0; i < iE; ++i )
          {
            byte_t b = ((char*)val)[i];
            if ( Isalnum(b) || b == '-' || b == '.' || b == '_' || b == '%' )
              count += __Elm_Append(inout,count,&b,1,1,capacity);
            else
              {
                Str_Hex_Byte(b,'%',C);
                count += __Elm_Append(inout,count,C,3,1,capacity);
              }
          }
      }
  }
#endif
  ;
  
char *Url_Compose(char *url, C_DICTO *params)
#ifdef _C_URL_BUILTIN
  {
    C_URL_COMPOSER cmps = { 0, 0 };
    int i, q = __Elm_Append(&cmps.S,0,url,strlen(url),1,&cmps.capacity);
    
    for ( i = 0; i < q ; ++i )
      if ( cmps.S[i] == '?' ) break;
    if ( i == q ) i = -1;
    
    if ( params )
      {
        Dicto_Apply(params,Url_Compose_Dicto_Fitler,&cmps);
        
        if ( !i && cmps.S[q] ) 
          {
            STRICT_REQUIRE(cmps.S[q] == '&');
            cmps.S[q] = '?';
          }
      }
        
    return cmps.S;
  }
#endif
  ;
  
char *Url_Xform_Encode(C_DICTO *params)
#ifdef _C_URL_BUILTIN
  {
    if ( params )
      {
        C_URL_COMPOSER cmps = { 0, 0 };
        Dicto_Apply(params,Url_Compose_Dicto_Fitler,&cmps);
        
        if ( cmps.S && cmps.S[0] ) 
          {
            STRICT_REQUIRE(cmps.S[0] == '&');
            cmps.S[0] = '?';
          }
          
        return cmps.S;
      }
    return 0;
  }
#endif
  ;

#endif /*C_once_36F09FA7_8AEC_4584_91B3_D25C37490B80*/

