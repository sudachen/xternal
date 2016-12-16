
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_47E24D4B_C225_4002_B318_6FB9DDE274BE
#define C_once_47E24D4B_C225_4002_B318_6FB9DDE274BE

#include "../minilog.hc"
#include "../text/mime.hc"
#include "httpd.hc"
#include "cgi.hc"

#ifdef _BUILTIN
#define _C_WEBHOST_BUILTIN
#endif

#ifdef __windoze
#include "pipex.hc"
#else
struct _C_PIPEX;
typedef struct _C_PIPEX C_PIPEX;
#endif

enum { WEBHOST_VERSION = 100 };

struct _C_WEBHOST_CGIST;
typedef void (*webhost_callback_t)(struct _C_WEBHOST_CGIST *st,int error);

typedef struct _C_WEBHOST_SERVICE
  {
    char *prefix;
    char *ext;
    void *obj;
    webhost_callback_t callback;
  } C_WEBHOST_SERVICE;  
  
void C_WEBHOST_SERVICE_Destruct(C_WEBHOST_SERVICE *svc)
#ifdef _C_WEBHOST_BUILTIN
  {
    free(svc->prefix);
    free(svc->ext);
    __Unrefe(svc->obj);
    __Destruct(svc);
  }
#endif
  ;
    
typedef struct _C_WEBHOST
  {
    char *exec_root;
    C_ARRAY *doc_roots;
    C_ARRAY *indexes;
    C_ARRAY *services;
    
    int disable_index: 1;
  } C_WEBHOST;
  
void C_WEBHOST_Destruct(C_WEBHOST *host)
#ifdef _C_WEBHOST_BUILTIN
  {
    __Unrefe(host->indexes);
    __Unrefe(host->doc_roots);
    free(host->exec_root);
    __Destruct(host);
  }
#endif
  ;
  
typedef struct _C_WEBHOST_CGIST
  {
    C_WEBHOST *host;
    C_HTTPD_REQUEST *rqst;
    C_URL *url;
    C_PIPEX *pipex;
    C_WEBHOST_SERVICE *svc;
    C_CGI *cgi;
    char *path;
    char *script;
    char *pathinfo;
  } C_WEBHOST_CGIST;

void C_WEBHOST_CGIST_Destruct(C_WEBHOST_CGIST *st)
#ifdef _C_WEBHOST_BUILTIN
  {
    __Unrefe(st->host);
    __Unrefe(st->url);
    __Unrefe(st->rqst);
    __Unrefe(st->pipex);
    __Unrefe(st->svc);
    __Unrefe(st->cgi);
    free(st->path);
    __Destruct(st);
  }
#endif
  ;
  
C_WEBHOST *Webhost_Init()
#ifdef _C_WEBHOST_BUILTIN
  {
    C_WEBHOST *host = __Object_Dtor(sizeof(C_WEBHOST),C_WEBHOST_Destruct);
    host->indexes = __Refe(Array_Pchars());
    host->doc_roots = __Refe(Array_Pchars());
    return host;
  }
#endif
  ;
  
C_WEBHOST *Webhost_Add_Doc_Root(C_WEBHOST *host, char *doc_root)
#ifdef _C_WEBHOST_BUILTIN
  {
    if ( doc_root )
      Array_Push(host->doc_roots,Str_Copy_Npl(doc_root,-1));
    return host;
  }
#endif
  ;
  
C_WEBHOST *Webhost_Set_Exec_Root(C_WEBHOST *host, char *exec_root)
#ifdef _C_WEBHOST_BUILTIN
  {
    free(host->exec_root);
    host->exec_root = exec_root?Str_Copy_Npl(exec_root,-1):0;
    return host;
  }
#endif
  ;

C_WEBHOST *Webhost_Add_Index(C_WEBHOST *host, char *index)
#ifdef _C_WEBHOST_BUILTIN
  {
    Array_Push(host->indexes,Str_Copy_Npl(index,-1));
    return host;
  }
#endif
  ;
  
char *Webhost_Conenttype_Of(char *path)
#ifdef _C_WEBHOST_BUILTIN
  {
    int code = Mime_Code_Of_Path(path,C_MIME_OCTS);
    return Mime_String_Of(code);
  }
#endif
  ;
  
#define  Webhost_Register_Service(Host,Prefix,Callback,Obj) Webhost_Register_Service_(Host,Prefix,0,Callback,Obj)
#define  Webhost_Register_Filter(Host,Ext,Callback,Obj) Webhost_Register_Service_(Host,0,Ext,Callback,Obj)
void Webhost_Register_Service_(C_WEBHOST *host, char *prefix, char *ext, webhost_callback_t callback, void *obj)
#ifdef _C_WEBHOST_BUILTIN
  {
    __Auto_Release
      {
        C_WEBHOST_SERVICE *svc = __Object_Dtor(sizeof(C_WEBHOST_SERVICE),
                                                C_WEBHOST_SERVICE_Destruct);
        svc->callback = callback;
        svc->obj = __Refe(obj);
        svc->prefix = prefix?Str_Copy_Npl(prefix,-1):0;
        svc->ext    = ext?Str_Copy_Npl(ext,-1):0;
        
        if ( !host->services ) 
          host->services = __Refe(Array_Refs());
        
        Array_Push(host->services,__Refe(svc));
      }
  }
#endif
  ;

int Webhost_File_Exists(C_BUFFER *bf, int L, C_ARRAY *extL,int executable)
#ifdef _C_WEBHOST_BUILTIN
  {
    int i;
    
    for ( i = 0; i < extL->count; ++i )
      {
        char *ext = extL->at[i];
        int j = strlen(ext);
        if ( L > j && !strncmp_I(bf->at+(L-j),ext,j) )
          {
            C_FILE_STATS stats = {0};
            if ( File_Get_Stats(bf->at,&stats,1)->f.exists )
              {
                if ( !stats.f.is_directory )
                  return 1;
              }
            break;
          }
      }
    
    return 0;
  }
#endif
  ;
   
int Webhost_Find_File_1(C_BUFFER *bf, int L, C_ARRAY *extL, int executable)
#ifdef _C_WEBHOST_BUILTIN
  {
    int i;
    C_FILE_STATS stats = {0};
    
    bf->at[L] = 0;
    
    if ( File_Get_Stats(bf->at,&stats,1)->f.exists && !stats.f.is_directory )
      return Webhost_File_Exists(bf,L,extL,executable);
    
    if ( executable )
      for ( i = 0; i < extL->count; ++i )
        {
          char *ext = extL->at[i];
          bf->at[L] = 0;
          bf->count = L;
          Buffer_Append(bf,ext,-1); 
          if ( File_Get_Stats(bf->at,&stats,1)->f.exists )
            if ( !stats.f.is_directory )
              return 1;
        }
    
    return 0;
  }
#endif
  ;

char *Webhost_Find_File(C_BUFFER *bf, C_ARRAY *patL, int i, int *L, C_ARRAY *extL, char **script, char **pathinfo, int executable)    
#ifdef _C_WEBHOST_BUILTIN
  {  
    char *fpath = 0;    
    if ( *(char*)patL->at[i] == 0 ) return 0;
    
    Buffer_Grow(bf,*L+1);
    bf->at[*L] = C_PATH_SEPARATOR;
    Buffer_Append(bf,patL->at[i],-1);
    *L = bf->count;
    if ( Webhost_Find_File_1(bf,*L,extL,executable) )
      {
        int j;
        *L = bf->count+1;
        Buffer_Fill_Append(bf,'\0',1);
        for ( j = 0; j <= i ; ++j ) 
          {
            if ( *(char*)patL->at[j] == 0 ) continue;
            Buffer_Fill_Append(bf,'/',1);
            Buffer_Append(bf,patL->at[j],-1);
          }
        j = bf->count+1;
        Buffer_Fill_Append(bf,'\0',1);
        for ( ++i; i < patL->count ; ++i ) 
          {
            Buffer_Fill_Append(bf,'/',1);
            Buffer_Append(bf,patL->at[i],-1);
          }
        
        fpath = Buffer_Take_Data(bf);
        *script = fpath+*L;
        *pathinfo = fpath+j;
      }
    return fpath;
  }
#endif
  ;

  
char *Webhost_Find_Executable(C_WEBHOST *host, char *query, char **script, char **pathinfo)
#ifdef _C_WEBHOST_BUILTIN
  {
    char *fpath = 0;
    
    __Auto_Ptr(fpath)
      {
        int i, L;

        C_ARRAY *extL = Str_Split(getenv("PATHEXT"),";");
        C_ARRAY *patL = Str_Split(query,"/");
        C_BUFFER *bf  = Buffer_Acquire(Path_Normilize_Npl(host->exec_root));
        
        L = bf->count;
        
        for ( i = 0; i < patL->count; ++i )
          if (( fpath = Webhost_Find_File(bf,patL,i,&L,extL,script,pathinfo,1) ))
              break;
      }
      
    return fpath;    
  }
#endif
  ;
    
char *Webhost_Find_Handler(C_WEBHOST *host, char *doc_root, char *query, char **script, char **pathinfo,C_WEBHOST_SERVICE **h)
#ifdef _C_WEBHOST_BUILTIN
  {
    char *fpath = 0;
    
    if ( !host->services ) return 0;
    __Auto_Ptr(fpath)
      {
        int i, L;

        C_ARRAY *extL = Array_Init();
        C_ARRAY *patL = Str_Split(query,"/");
        C_BUFFER *bf  = Buffer_Acquire(Path_Normilize_Npl(doc_root));
        
        for ( i = 0; i < host->services->count; ++i )
          {
            C_WEBHOST_SERVICE *svc = host->services->at[i];
            if ( svc->ext ) Array_Push(extL,svc->ext);
          }
                  
        L = bf->count;
        
        for ( i = 0; i < patL->count; ++i )
          if (( fpath = Webhost_Find_File(bf,patL,i,&L,extL,script,pathinfo,0) ))
              break;
      
        if ( fpath )
          for ( i = 0; i < host->services->count; ++i )
            {
              C_WEBHOST_SERVICE *svc = host->services->at[i];
              if ( svc->ext )
                if ( Str_Ends_With(fpath,svc->ext) )
                  {
                    *h = svc; 
                    break;
                  }
            } 
      }
      
    return fpath;    
  }
#endif
  ;

C_ARRAY *Webhost_Setup_Environment(char *doc_root, C_HTTPD_REQUEST *rqst, char *path, char *script, char *pathinfo, C_URL *url)
#ifdef _C_WEBHOST_BUILTIN
  {
    C_ARRAY *env;
    __Auto_Ptr(env)
      {    
        char *method = 0;
        env = Array_Pchars();
        Array_Push(env,Str_Copy_Npl("GATEWAY_INTERFACE=CGI/1.1",-1));
        Array_Push(env,Str_Copy_Npl("GATEWAY_INTERFACE=CGI/1.1",-1));
        Array_Push(env,Str_Copy_Npl("SERVER_PROTOCOL=HTTP/1.1",-1));
        Array_Push(env,__Format_Npl("SERVER_SOFTWARE=YOYO/WEBHOST/%d",WEBHOST_VERSION));
        Array_Push(env,Str_Concat_Npl("SCRIPT_NAME=",script));
        Array_Push(env,Str_Concat_Npl("SCRIPT_FILENAME=",path));
        Array_Push(env,Str_Concat_Npl("PATH_INFO=",pathinfo));
        Array_Push(env,Str_Concat_Npl("QUERY_STRING=",url->args));
        Array_Push(env,Str_Concat_Npl("HTTP_REFERER=",rqst->referer));
        if ( rqst->instrm_type )
          {
            Array_Push(env,__Format_Npl("CONTENT_LENGTH=%d",rqst->instrm_length));
            Array_Push(env,Str_Concat_Npl("CONTENT_TYPE=",rqst->instrm_type));
          }
        else
          {
            Array_Push(env,Str_Copy_Npl("CONTENT_LENGTH=0",-1));
            Array_Push(env,Str_Copy_Npl("CONTENT_TYPE=text/html",-1));
          }
          
        switch(rqst->method)
          {
            case HTTPD_GET_METHOD:  method = "GET";  break;
            case HTTPD_POST_METHOD: method = "POST"; break;
            case HTTPD_HEAD_METHOD: method = "HEAD"; break;
            case HTTPD_PUT_METHOD:  method = "PUT";  break;
          }
        
        Array_Push(env,Str_Concat_Npl("REQUEST_METHOD=",method));
        Array_Push(env,Str_Concat_Npl("REMOTE_ADDR=",rqst->remote_addr));
        Array_Push(env,Str_Concat_Npl("REMOTE_HOST=",rqst->remote_addr));
        Array_Push(env,Str_Concat_Npl("REQUEST_URI=",url->uri));
        if ( doc_root )
          Array_Push(env,Str_Concat_Npl("DOCUMENT_ROOT=",doc_root));
        Array_Push(env,Str_Concat_Npl("HTTP_REFERRER=",Dicto_Get(rqst->qhdr,"REFERRER","")));
        if ( Dicto_Has(rqst->qhdr,"COOKIE") )
          Array_Push(env,Str_Concat_Npl("HTTP_COOKIE=",Dicto_Get(rqst->qhdr,"COOKIE","")));
        
        //("HTTP_USER_AGENT");
        //("HTTP_ACCEPT_LANGUAGE");
        //("SERVER_NAME");
        //("SERVER_PORT");
        Array_Push(env,0);
      } 
    return env;
  }
#endif
  ;
  
C_WEBHOST_SERVICE *Webhost_Find_Service(C_ARRAY *services, char *query, char **script, char **pathinfo)
#ifdef _C_WEBHOST_BUILTIN
  {
    int i,L;
    char c;
    for ( i = 0; i < services->count; ++i )
      {
        C_WEBHOST_SERVICE * svc = services->at[i];
        if ( svc->prefix && Str_Starts_With(query,svc->prefix) )
          {
            L = strlen(svc->prefix); 
            if ( L > 0 && svc->prefix[L-1] == '/' ) --L;
            c = query[L]; 
            if ( !c || c == '/' )
              {
                *script = Str_Copy_L(query,L);
                *pathinfo = Str_Copy(query+L);
                return svc;
              }
          }
      }
    return 0;
  }
#endif
  ;
    
void Webhost_Execute_Service(C_WEBHOST_CGIST *st, char *doc_root)
#ifdef _C_WEBHOST_BUILTIN
  {
    C_ARRAY *env;
    if ( !doc_root ) doc_root = st->host->doc_roots->count?st->host->doc_roots->at[0]:0;
    env = Webhost_Setup_Environment(doc_root,st->rqst,st->path,st->script,st->pathinfo,st->url);
    st->rqst->outstrm_type = Mime_String_Of_Npl(C_MIME_HTML);
    st->rqst->outstrm = __Refe(Buffer_As_File(0));//__Refe(Cfile_Temp());
    st->cgi = __Refe(Cgi_Init_2(st->rqst->instrm,st->rqst->outstrm,(char**)env->at));
    Tasque_Alert(0,st->svc->callback,st);
  }
#endif
  ;

int Webhost_CGI_Headers(C_HTTPD_REQUEST *rqst, void *strm)
#ifdef _C_WEBHOST_BUILTIN
  {
    int retcode = HTTPD_SUCCESS;
    for (;;)
      {
        static char s_Content_Type[] = "Content-Type:";
        static char s_Content_Length[] = "Content-Length:";
        static char s_Location[] = "Location:";
        static char s_Set_Cookie[] = "Set-Cookie:";
        char *S = Oj_Read_Line(strm);
        if ( Str_Is_Empty(S) )
          break;
        if ( !strncmp_I(S,s_Content_Type,sizeof(s_Content_Type)-1) )
          {
            free(rqst->outstrm_type);
            rqst->outstrm_type = Str_Trim_Copy_Npl(S+sizeof(s_Content_Type)-1,-1);
          }
        else if ( !strncmp_I(S,s_Content_Length,sizeof(s_Content_Length)-1) )
          {
            rqst->outstrm_length = strtol(S+sizeof(s_Content_Length)-1,0,0);
          }
        else if ( !strncmp_I(S,s_Location,sizeof(s_Location)-1) )
          {
            rqst->location = Str_Trim_Copy_Npl(S+sizeof(s_Location)-1,-1);
            retcode = HTTPD_REDIRECT;
          }
        else if ( !strncmp_I(S,s_Set_Cookie,sizeof(s_Set_Cookie)-1) )
          {
          }
        else
          {
          }
      }
    return retcode;
  }
#endif
  ;
    
void Webhost_Error_Service(C_WEBHOST_CGIST *st, int retcode, char *text)
#ifdef _C_WEBHOST_BUILTIN
  {
    __Auto_Release 
      {
        C_HTTPD_REQUEST *rqst = st->rqst;
        rqst->outstrm_type = Mime_String_Of_Npl(C_MIME_TEXT);
        rqst->outstrm = Buffer_As_File(Buffer_Copy(text,-1));
        rqst->outstrm_length = Oj_Available(rqst->outstrm);
      }
        
    Httpd_Continue_Request(st->rqst,retcode);
  }
#endif
  ;

void Webhost_Exit_Service(C_WEBHOST_CGIST *st, int error)
#ifdef _C_WEBHOST_BUILTIN
  {
    int retcode = 0;
    
    __Auto_Release 
      {
        if ( !error )
          {
            C_HTTPD_REQUEST *rqst = st->rqst;
            rqst->outstrm_type = Mime_String_Of_Npl(C_MIME_HTML);
            Oj_Seek(rqst->outstrm,0,0);
            retcode = Webhost_CGI_Headers(rqst,rqst->outstrm);
            rqst->outstrm_length = Oj_Available(rqst->outstrm);
          }
        else
          {
            retcode = 500;
          }
      }
        
    if ( retcode )
      Httpd_Continue_Request(st->rqst,retcode);
  }
#endif
  ;

C_WEBHOST_CGIST *Webhost_CGI_State(C_WEBHOST *host, C_HTTPD_REQUEST *rqst, char *path, char *script, char *pathinfo, C_URL *url)
#ifdef _C_WEBHOST_BUILTIN
  {
    C_WEBHOST_CGIST *st = __Object_Dtor(sizeof(C_WEBHOST_CGIST),C_WEBHOST_CGIST_Destruct);
    st->host = __Refe(host);
    st->url  = __Refe(url);
    st->rqst = __Refe(rqst);
    st->path = path;
    st->script = script;
    st->pathinfo = pathinfo;
    return st;
  }
#endif
  ;
 
#if defined __windoze && !defined _C_WITHOUT_EXEC_CGI
    
void Webhost_Check_CGI_Status(C_WEBHOST_CGIST *st, int error)
#ifdef _C_WEBHOST_BUILTIN
  {
    int retcode = 0;
    
    if ( error ) return;
    
    __Auto_Release 
      {
        __Try_Except
          {
            if (  Pipex_Exit_Code(st->pipex) == PIPEX_STILL_ACTIVE )
              {
                Tasque_Alert(0,Webhost_Check_CGI_Status,st);
              }
            else
              if ( st->pipex->exitcode == 0 )
                {
                  C_HTTPD_REQUEST *rqst = st->rqst;
                  C_BUFFER *bf = Buffer_Init(0);
                  C_BUFFER_FILE *fbf = Buffer_As_File(bf);
                  __Unrefe(rqst->outstrm);
                  rqst->outstrm_type = Mime_String_Of_Npl(C_MIME_HTML);
                  rqst->outstrm = __Refe(st->pipex->fout);
                  Oj_Seek(rqst->outstrm,0,0);
                  retcode = Webhost_CGI_Headers(rqst,rqst->outstrm);
                  rqst->outstrm_length = Oj_Available(rqst->outstrm);
                }
              else
                {
                  retcode = 500;
                }
          }
        __Except
          {
            Log_Error("[ERR/EXCEPTION] %s\n%s",__Format_Error(),__Format_Error_Btrace());
            retcode = 500;
          }
      }
        
    if ( retcode )
      Httpd_Continue_Request(st->rqst,retcode);
  }
#endif
  ;
  
int Webhost_Execute_CGI(C_WEBHOST_CGIST *st)
#ifdef _C_WEBHOST_BUILTIN
  {
    int retcode = 0;
    
    __Auto_Release 
      {
        char *curdir = Current_Directory();
        
        __Try_Except
          {
            C_ARRAY *env;
            char *doc_root = st->host->doc_roots->count?st->host->doc_roots->at[0]:0;
            Change_Directory(Path_Dirname(st->path));
            env = Webhost_Setup_Environment(doc_root,st->rqst,st->path,st->script,st->pathinfo,st->url);
            
            st->pipex = __Refe(Pipex_Exec(Path_Basename(st->path),0,PIPEX_TMPFILE,PIPEX_NONE,(char**)env->at));
            
            if ( st->rqst->instrm )
              {
                int c = Oj_Copy_File(st->rqst->instrm,st->pipex->fin);
                Oj_Flush(st->pipex->fin);
                Oj_Close(st->pipex->fin);
              }
              
            Tasque_Alert(0,Webhost_Check_CGI_Status,st);
            retcode = 0;
          }
        __Except
          {
            Log_Error("[ERR/EXCEPTION] %s\n%s",__Format_Error(),__Format_Error_Btrace());
            retcode = 500;
          }

        Change_Directory(curdir);
      }
      
    return retcode;
  }
#endif
  ;
  
#endif
    
int Webhost_Callback(void *_host, C_HTTPD_REQUEST *rqst, int status)
#ifdef _C_WEBHOST_BUILTIN
  {
    int i;
    C_WEBHOST *host = _host;
    char *script = 0, *pathinfo = 0;
    
    if ( status == HTTPD_RQST_CONNECT )
      {
        //Log_Debug("[%p] CONNECT %s:%d",rqst,rqst->remote_addr,rqst->remote_port);
        return HTTPD_ACCEPT;
      }
    else if ( status == HTTPD_RQST_POSTDTA )
      return HTTPD_ACCEPT;
    else if ( status == HTTPD_RQST_PERFORM )
      {
        C_FILE_STATS stats = {0};
        C_URL *url = Url_Parse_Uri(rqst->uri);
        char *path = 0;
        int rng_pos, rng_len;

        //Log_Info("[%p] %s/1.%d %s",rqst,Httpd_Method_String(rqst->method),rqst->httpver,rqst->uri);
        //Logout_Debug(Dicto_Format(rqst->qhdr,Buffer_Print,0,1));
        
        /*if ( rqst->instrm_length && Log_Level(C_LOG_INFO) )
          {
            enum { MAX_L = 60 };
            int L = C_Minu(MAX_L,rqst->instrm_length);
            byte_t *b = __Zero_Malloc(MAX_L+1);
            Oj_Seek(rqst->instrm,0,0);
            Oj_Read(rqst->instrm,b,L,L);
            Oj_Seek(rqst->instrm,0,0);
            for ( i = 0; i < L; ++i ) if ( b[i] < 30 || b[i] > 127 ) b[i] = '.';
            if ( rqst->instrm_length > MAX_L ) memcpy(b+MAX_L-3,">>>",3);
            Log_Info("[%p] POSTDTA %s",rqst,b);
          }*/
        
        if ( host->services )
          {
            C_WEBHOST_SERVICE *svc = 0;
            svc = Webhost_Find_Service(host->services,url->query,&script,&pathinfo);
            if ( svc )
              {
                C_WEBHOST_CGIST *st = Webhost_CGI_State(host, rqst, __Retain(path), script, pathinfo, url);
                char *doc_root = host->doc_roots->count?host->doc_roots->at[0]:0;
                st->svc = __Refe(svc);
                
                Webhost_Execute_Service(st,doc_root);
                return 0;
              }
          }
        
        #if defined __windoze && !defined _C_WITHOUT_EXEC_CGI
        if ( host->exec_root )
          {
            path = Webhost_Find_Executable(host,url->query,&script,&pathinfo);
            if ( path )
              return Webhost_Execute_CGI(Webhost_CGI_State(host, rqst, __Retain(path), script, pathinfo, url));
          }
        #endif
        
        if ( host->services )
          {
            char *doc_root = 0;
            char *path = 0;
            C_WEBHOST_SERVICE *svc = 0;
            for ( i = 0; i < host->doc_roots->count; ++i )
              {
                doc_root = host->doc_roots->at[i];
                path = Webhost_Find_Handler(host,doc_root,url->query,&script,&pathinfo,&svc);
                if ( path ) break;
              }
            if ( svc )
              {
                C_WEBHOST_CGIST *st = Webhost_CGI_State(host, rqst, __Retain(path), script, pathinfo, url);
                st->svc = __Refe(svc);
                Webhost_Execute_Service(st,doc_root);
                return 0;
              }
          }
          
        for ( i = 0; i < host->doc_roots->count; ++i )
          {
            path = Path_Join(host->doc_roots->at[i],url->query);
            path = Path_Normposix(path);
            if ( File_Get_Stats(path,&stats,1)->f.exists )
              break;
            else
              path = 0;
          }
        
        if ( path )
          {
            if ( stats.f.is_directory )
              {
                for ( i = 0; i < host->indexes->count; ++i )
                  {
                    char *path1 = Path_Join(path,host->indexes->at[i]);
                    if ( File_Get_Stats(path1,&stats,1)->f.exists )
                      {
                        path = path1;
                        goto open_file;
                      }
                  }
                /* list directory */
                if ( !host->disable_index )
                  {
                    C_BUFFER *obf = Buffer_Init(0);
                    C_ARRAY *L = File_List_Directory(path,0);
                    for ( i = 0; i < L->count; ++i )
                      {
                        Buffer_Printf(obf,"<a href=\"%s%s\">%s</a><br>",url->query,L->at[i],L->at[i]);
                      }
                    rqst->outstrm = __Refe(Buffer_As_File(obf));
                    rqst->outstrm_length = obf->count;
                    rqst->outstrm_type = Mime_String_Of_Npl(C_MIME_HTML);
                    return HTTPD_SUCCESS;
                  }
                return HTTPD_NOTFOUND;
              }
          open_file:  
          
            rqst->outstrm_type = Str_Copy_Npl(Webhost_Conenttype_Of(path),-1);
            rqst->outstrm_length = (int)stats.length;

            if ( rqst->method == HTTPD_HEAD_METHOD )
              {
                return HTTPD_SUCCESS;
              }
            else
              {
                rqst->outstrm = __Refe(Cfile_Open(path,"r"));
                if ( Httpd_Rqst_Range(rqst,&rng_pos,&rng_len) )
                  {
                    int L = (int)stats.length;
                    if ( L > rng_pos && rng_len > 0 )
                      {
                        rng_len = C_Mini(rng_len,L-rng_pos);
                        Oj_Seek(rqst->outstrm,rng_pos,0);
                        rqst->outstrm_length = rng_len;
                        Httpd_Set_Content_Range(rqst,rng_pos,rng_len,(int)stats.length);
                        return HTTPD_PARTIAL;
                      }
                    else
                      return 416; // Requested Range Not Satisfiable
                  }
                else
                  return HTTPD_SUCCESS;
              }
          }
        else
          return HTTPD_NOTFOUND;
      }
    
    return HTTPD_REJECT;
  }
#endif
  ;

#endif /*C_once_47E24D4B_C225_4002_B318_6FB9DDE274BE*/
