
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_C02CA609_3FE5_45AB_B64B_15A73FD72214
#define C_once_C02CA609_3FE5_45AB_B64B_15A73FD72214

#include "../C+.hc"
#include "../string.hc"
#include "../buffer.hc"
#include "../stdf.hc" 
#include "../xdata.hc"
#include "../minilog.hc"
#include "../text/mime.hc"
#include "../text/def.hc"
#include "../text/json.hc"

#ifdef _BUILTIN
#define _C_CGI_BUILTIN
#endif

extern char **environ;

enum 
  {
    C_CGI_BAD_METHOD     = 0,
    C_CGI_GET            = 1,
    C_CGI_POST           = 2,
    C_CGI_HTTP_X_X       = 300000,
    C_CGI_HTTP_1_0       = 300100,
    C_CGI_HTTP_1_1       = 300101,
    C_CGI_CGI_GW         = 100000,
    C_CGI_CGI_X_X        = 100000,
    C_CGI_CGI_1_0        = 100100,
    C_CGI_CGI_1_1        = 100101,
    C_CGI_FAST_CGI_GW    = 200000,
    C_CGI_FAST_CGI_X_X   = 200000,
    C_CGI_FAST_CGI_1_0   = 200100,
    C_CGI_FAST_CGI_1_1   = 200101,
    C_CGI_NO_CONTENT     = 0,
    C_CGI_URLENCODED     = 1,
    C_CGI_OCTETSTREAM    = 2,
    C_CGI_MULTIPART      = 3,
    C_CGI_POST_MAX_PAYLOAD = 64*KILOBYTE,
    CGI_OUT_TEXTHTML      = 200,
    CGI_OUT_REDIRECT      = 301,
    CGI_OUT_DATASTREAM    = 299,
    CGI_OUT_NOTFOUND      = 404,
    CGI_OUT_TEXTJSON      = 200,
    CGI_OUT_TEXTPLAIN     = 10002,
  };

/* C_CGI_COOKIE does not require specific destructor, use free */
typedef struct _C_CGI_COOKIE
  {
    struct _C_CGI_COOKIE *next;
    char *value;
    time_t expire;
    int  secure;
    char name[1];
  } C_CGI_COOKIE;

typedef struct _C_CGI_UPLOAD
  {
    struct _C_CGI_UPLOAD *next;
    char *path;
    char *mimetype;
    char *original;
    int length;
    int status;
    char name[1];
  } C_CGI_UPLOAD;

typedef struct _C_CGI
  {
    C_XNODE *params;
    char *document_root;
    char *server_software;
    char *server_name;
    char *script_name;
    char *request_uri;
    char *remote_addr;
    char *referer;
    char *query_string;
    char *path_info;
    char *content_boundary; /* can be null */
    char **langlist;
    int gateway_interface;
    int server_protocol;
    int server_port;
    int request_method;
    int content_length;
    int content_type;
    C_CGI_COOKIE *cookie_in;
    C_CGI_COOKIE *cookie_out;
    C_CGI_UPLOAD *upload;
    C_BUFFER *out;
    void *dstrm;
    char *dstrm_mimetype;
    void *istrm;
    void *ostrm;
  } C_CGI;

#define Cgi_Langlist(Cgir) ((Cgir)->langlist)

void Cgi_Destruct(C_CGI *self)
#ifdef _C_CGI_BUILTIN
  {
    __Gogo
      {
        C_CGI_COOKIE *qoo;
        for ( qoo = self->cookie_in; qoo; ) { void *q = qoo->next; free(qoo); qoo = q; }
        for ( qoo = self->cookie_out; qoo; ) { void *q = qoo->next; free(qoo); qoo = q; }
      }
    
    __Gogo
      {
        C_CGI_UPLOAD *qoo, *qoo1;
        for ( qoo = self->upload; qoo; )
          {
            qoo1 = qoo->next;
            if ( qoo->path && File_Exists(qoo->path) ) 
              __Try_Except
                File_Unlink(qoo->path,0);
              __Except
                Log_Error("when unlink uploaded file `%s`, occured: %s",
                                         qoo->path, __Format_Error());
            free(qoo);
            qoo = qoo1;
          }
      }
    
    if (self->langlist) 
      {
        char **qoo;
        for ( qoo = self->langlist; *qoo; ++qoo )
          free(*qoo);
        free(self->langlist);
      }
    
    free(self->document_root);
    free(self->script_name);
    free(self->server_software);
    free(self->server_name);
    free(self->request_uri);
    free(self->remote_addr);
    free(self->referer);
    free(self->query_string);
    free(self->path_info);
    free(self->content_boundary);
    free(self->dstrm_mimetype);
    __Unrefe(self->params);
    __Unrefe(self->out);
    __Unrefe(self->dstrm);
    __Unrefe(self->ostrm);
    __Unrefe(self->istrm);
    memset(self,0xfe,sizeof(*self)); /* !!! */
    __Destruct(self);
  }
#endif
  ;
  
char *Cgi_Pump_Part(C_CGI *cgi, char *buf, char *S, int *L)
#ifdef _C_CGI_BUILTIN
  {
    if ( cgi->istrm )
      return Oj_Pump_Part(cgi->istrm,buf,S,L);
    else
      return Stdin_Pump_Part(buf,S,L);
  }
#endif
  ;
    
int Cgi_Pump(C_CGI *cgi, char *buf)
#ifdef _C_CGI_BUILTIN
  {
    if ( cgi->istrm )
      return Oj_Read(cgi->istrm,buf,C_STDF_PUMP_BUFFER_W,0);
    else
      return Stdin_Pump(buf);  
  }
#endif
  ;
    
C_CGI_COOKIE **Cgi_Find_Cookie_(C_CGI_COOKIE **qoo,char *name, int name_len)
#ifdef _C_CGI_BUILTIN
  {
    while ( *qoo )
      {
        int i;
        char *Q = (*qoo)->name;
        char *N = name;
        for ( i = 0; i < name_len; ++i )
          if ( Q[i] != N[i] )
            break;
        if ( i == name_len && !Q[i] )
          break;
        qoo = &(*qoo)->next;
      }
    return qoo;
  }
#endif
  ;

#define Cgi_Set_Cookie(Cgir,Name,Value,Expire) Cgi_Set_Cookie_(&(Cgir)->cookie_out,(Name),-1,(Value),-1,0,(Expire));
#define Cgi_Set_Secure_Cookie(Cgir,Name,Value,Expire) Cgi_Set_Cookie_(&(Cgir)->cookie_out,(Name),-1,(Value),-1,1,(Expire));
void Cgi_Set_Cookie_(C_CGI_COOKIE **qoo, char *name, int name_len, char *value, int value_len, int secure, time_t expire)
#ifdef _C_CGI_BUILTIN
  {
    C_CGI_COOKIE **cookie;
    
    if ( name_len < 0 ) name_len = name?strlen(name):0;
    if ( value_len < 0 ) value_len = value?strlen(value):0;
    
    cookie = Cgi_Find_Cookie_(qoo,name,name_len);
    if ( *cookie )
      {
        free(*cookie);
        *cookie = 0;
      }
      
    *cookie = __Malloc_Npl(sizeof(C_CGI_COOKIE)+(name_len+value_len+1));
    (*cookie)->value = (*cookie)->name+name_len+1;
    memcpy((*cookie)->name,name,name_len);
    (*cookie)->name[name_len] = 0;
    memcpy((*cookie)->value,value,value_len);
    (*cookie)->value[value_len] = 0;
    (*cookie)->secure = secure;
    (*cookie)->expire = expire;
    (*cookie)->next = 0;
  }
#endif
  ;
  
char *Cgi_Get_Cookie(C_CGI *cgi,char *name)
#ifdef _C_CGI_BUILTIN
  {
    if ( name )
      {
        C_CGI_COOKIE **q = Cgi_Find_Cookie_(&cgi->cookie_in,name,strlen(name));
        if ( *q )
          return (*q)->value;
      }
    return 0;
  }
#endif
  ;

C_CGI_UPLOAD *Cgi_Find_Upload(C_CGI *cgi, char *upload_name)
#ifdef _C_CGI_BUILTIN
  {
    C_CGI_UPLOAD *up = cgi->upload;
    for ( ; up ; up = up->next )
      if ( Str_Equal_Nocase(up->name,upload_name) )
        break;
    return up;
  }
#endif
  ;

char *Cgi_Mime_Of_Upload(C_CGI *cgi, char *upload_name)
#ifdef _C_CGI_BUILTIN
  {
    C_CGI_UPLOAD *up = Cgi_Find_Upload(cgi,upload_name);
    if ( up )
      return up->mimetype;
    return 0;
  }
#endif
  ;

char *Cgi_Get_Upload_Path(C_CGI *cgi, char *upload_name)
#ifdef _C_CGI_BUILTIN
  {
    C_CGI_UPLOAD *up = Cgi_Find_Upload(cgi,upload_name);
    if ( up )
      return up->path;
    else
      __Raise_Format(C_ERROR_INVALID_PARAM,
        ("CGI request does not have upload with name '%s'",upload_name));
    return 0;
  }
#endif
  ;

void *Cgi_Open_Upload(C_CGI *cgi, char *upload_name)
#ifdef _C_CGI_BUILTIN
  {
    return Cfile_Open(Cgi_Get_Upload_Path(cgi,upload_name),"r");
  }
#endif
  ;

C_CGI_UPLOAD *Cgi_Attach_Upload(C_CGI_UPLOAD **upload, char *path, char *mimetype, char *name, char *original, int len)
#ifdef _C_CGI_BUILTIN
  {
    int path_len = path?strlen(path):0;
    int mime_len = mimetype?strlen(mimetype):0;
    int name_len = name?strlen(name):0;
    int orig_len = original?strlen(original):0;
    int mem_len = path_len+1+mime_len+1+orig_len+1+name_len+sizeof(C_CGI_UPLOAD);
    C_CGI_UPLOAD *u = __Malloc_Npl(mem_len);
    memset(u,0,mem_len);
    u->path = u->name+name_len+1;
    u->mimetype = u->path+path_len+1;
    u->original = u->mimetype+mime_len+1;
    if ( name_len ) memcpy(u->name,name,name_len);
    if ( path_len ) memcpy(u->path,path,path_len);
    if ( mime_len ) memcpy(u->mimetype,mimetype,mime_len);
    if ( orig_len ) memcpy(u->original,original,orig_len);
    u->length = len;
    
    while ( *upload ) upload = &(*upload)->next;
    *upload = u;
    return u;
  }
#endif
  ;

int Cgi_Recognize_Request_Method(char *method)
#ifdef _C_CGI_BUILTIN
  {
    if ( method )
      {
        if ( !strcmp_I(method,"get") )
          return C_CGI_GET;
        if ( !strcmp_I(method,"post") )
          return C_CGI_POST;
      }
    return 0;
  } 
#endif
  ;
  
int Cgi_Recognize_Content_Type(char *cont_type)
#ifdef _C_CGI_BUILTIN
  {
    if ( cont_type )
      {
        while ( Isspace(*cont_type) ) ++cont_type;
        if ( !strncmp_I(cont_type,"multipart/form-data;",20) )
          return C_CGI_MULTIPART;
        if ( !strcmp_I(cont_type,"application/x-www-form-urlencoded") )
          return C_CGI_URLENCODED;
        if ( !strcmp_I(cont_type,"application/octet-stream") )
          return C_CGI_OCTETSTREAM;
      }
    return 0;
  }
#endif
  ;
  
int Cgi_Recognize_Gateway_Ifs(char *gwifs)
#ifdef _C_CGI_BUILTIN
  {
    if ( gwifs )
      {
        while ( Isspace(*gwifs) ) ++gwifs;
        if ( !strncmp_I(gwifs,"cgi/1.1",9) )
          return C_CGI_CGI_1_1;
        if ( !strncmp_I(gwifs,"cgi/1.0",9) )
          return C_CGI_CGI_1_0;
      }
    return C_CGI_CGI_X_X;
  }
#endif
  ;
  
int Cgi_Recognize_Protocol(char *proto)
#ifdef _C_CGI_BUILTIN
  {
    if ( proto )
      {
        while ( Isspace(*proto) ) ++proto;
        if ( !strncmp_I(proto,"http/1.1",10) )
          return C_CGI_HTTP_1_1;
        if ( !strncmp_I(proto,"http/1.0",10) )
          return C_CGI_HTTP_1_0;
      }
    return 0;
  }
#endif
  ;
  
char *Cgi_Get_Env(char **env,char *name)
#ifdef _C_CGI_BUILTIN
  {
    if ( !env ) 
      return getenv(name); 
    else
      {
        int L = strlen(name);
        for (; *env; ++env ) 
          {
            if ( !strncmp(*env,name,L) && (*env)[L] == '=' ) 
              return *env + L + 1;
          }
      }
    return 0;
  }
#endif
  ;
    
C_CGI *Cgi_Init_(C_CGI *self,char **env)
#ifdef _C_CGI_BUILTIN
  {
    setlocale(LC_NUMERIC,"C");
    setlocale(LC_TIME,"C");

    self->server_software = Str_Copy_Npl(Cgi_Get_Env(env,"SERVER_SOFTWARE"),-1);
    self->gateway_interface = Cgi_Recognize_Gateway_Ifs(Cgi_Get_Env(env,"GATEWAY_INTERFACE"));
    self->server_protocol = Cgi_Recognize_Protocol(Cgi_Get_Env(env,"SERVER_PROTOCOL"));

    self->server_name = Str_Copy_Npl(Cgi_Get_Env(env,"SERVER_NAME"),-1);
    self->server_port = Str_To_Int_Dflt(Cgi_Get_Env(env,"SERVER_PORT"),80);

    self->request_uri = Str_Copy_Npl(Cgi_Get_Env(env,"REQUEST_URI"),-1);
    self->remote_addr = Str_Copy_Npl(Cgi_Get_Env(env,"REMOTE_ADDR"),-1);
    self->referer = Str_Copy_Npl(Cgi_Get_Env(env,"HTTP_REFERER"),-1);

    self->request_method = Cgi_Recognize_Request_Method(Cgi_Get_Env(env,"REQUEST_METHOD"));
    self->query_string = Str_Copy_Npl(Cgi_Get_Env(env,"QUERY_STRING"),-1);
    self->path_info = Str_Copy_Npl(Cgi_Get_Env(env,"PATH_INFO"),-1);    
    self->script_name = Str_Copy_Npl(Cgi_Get_Env(env,"SCRIPT_NAME"),-1);    
    self->content_length = Str_To_Int_Dflt(Cgi_Get_Env(env,"CONTENT_LENGTH"),0);
    self->document_root = Str_Copy_Npl(Cgi_Get_Env(env,"DOCUMENT_ROOT"),-1);
    
    __Gogo
      {
        char *S = Cgi_Get_Env(env,"CONTENT_TYPE");
        self->content_type = Cgi_Recognize_Content_Type(S);
        if ( self->content_type == C_CGI_MULTIPART )
          {
            char *bndr = strchr(S,';');
            if ( bndr )
              {
                ++bndr;
                while ( Isspace(*bndr) ) ++bndr;
                if ( Str_Starts_With(bndr,"boundary=") )
                  self->content_boundary = Str_Concat_Npl("--",bndr+9);
              }
          }
      }
     
     __Gogo
      {
        char *S = Cgi_Get_Env(env,"HTTP_COOKIE");
        if ( S ) while (*S)
          {
            int nam_len,val_len;
            char *nam;
            char *val;
            while ( Isspace(*S) ) ++S;
            nam = S;
            while ( *S && *S != '=' && *S != ';' ) ++S;
            if ( *S == '=' )
              {
                nam_len = S - nam;
                ++S;
                val = S;
                while ( *S && *S != ';' ) ++S;
              }
            else
              {
                val = nam;
                nam_len = 0;
              }
            val_len = S-val;
            if ( *S == ';' ) ++S;
            Cgi_Set_Cookie_(&self->cookie_in,nam,nam_len,val,val_len,0,0);
          }
      }
      
    __Gogo
      {
        C_ARRAY *arr = 0;
        char *S1, *S2, *S = Cgi_Get_Env(env,"HTTP_ACCEPT_LANGUAGE");
        if ( S )
          {
            arr = Array_Pchars();
            while ( *S )
              {
                S1 = S;
                S2 = S;
                while ( *S && *S != ',' ) ++S;
                while ( S2 < S && *S2 != ';' ) ++S2;
                Array_Push(arr,Str_Copy_Npl(S1,S2-S1));
                while ( *S == ',' ) ++S;
              }
            Array_Push(arr,0);
            self->langlist = Array_Take_Data_Npl(arr);
          }
      }
    
    self->out = __Refe(Buffer_Init(0));
    return self;
  }
#endif
  ;
  
C_CGI *Cgi_Init()
#ifdef _C_CGI_BUILTIN
  {
    C_CGI *self = __Object_Dtor(sizeof(C_CGI),Cgi_Destruct);
    return Cgi_Init_(self,0);
  }
#endif
  ;
    
C_CGI *Cgi_Init_2(void *istrm, void *ostrm, char **env)
#ifdef _C_CGI_BUILTIN
  {
    C_CGI *self = __Object_Dtor(sizeof(C_CGI),Cgi_Destruct);
    self->istrm = __Refe(istrm);
    self->ostrm = __Refe(ostrm);
    return Cgi_Init_(self,env);
  }
#endif
  ;
  
void Cgi_Format_Bf(C_CGI *self, C_BUFFER *bf)
#ifdef _C_CGI_BUILTIN
  {
    C_CGI_COOKIE *q;
    C_CGI_UPLOAD *u;
    
    Buffer_Printf(bf,"C_CGI(%08x){\n",self);
    Buffer_Printf(bf,"  server_software = '%s'\n",self->server_software);
    Buffer_Printf(bf,"  server_name = '%s'\n",self->server_name);
    Buffer_Printf(bf,"  request_uri = '%s'\n",self->request_uri);
    Buffer_Printf(bf,"  remote_addr = '%s'\n",self->remote_addr);
    Buffer_Printf(bf,"  referer = '%s'\n",self->referer);
    Buffer_Printf(bf,"  query_string = '%s'\n",self->query_string);
    Buffer_Printf(bf,"  path_info = '%s'\n",self->path_info);
    Buffer_Printf(bf,"  content_boundary = '%s'\n",self->content_boundary?self->content_boundary:"");
    Buffer_Printf(bf,"  gateway_interface = %d\n",self->gateway_interface);
    Buffer_Printf(bf,"  server_protocol = %d\n",self->server_protocol);
    Buffer_Printf(bf,"  server_port = %d\n",self->server_port);
    Buffer_Printf(bf,"  request_method = %d\n",self->request_method);
    Buffer_Printf(bf,"  content_length = %d\n",self->content_length);
    Buffer_Printf(bf,"  content_type = %d\n",self->content_type);
    Buffer_Append(bf,"  params:\n",-1);
    if (self->params) Def_Format_Into(bf,self->params,2);
    Buffer_Append(bf,"  cookie-in:\n",-1);
    for ( q = self->cookie_in; q; q = q->next ) 
      Buffer_Printf(bf,"    %s => %s\n",q->name,q->value);
    Buffer_Append(bf,"  cookie-out:\n",-1);
    for ( q = self->cookie_out; q; q = q->next ) 
      Buffer_Printf(bf,"    %s => %s  ((%sexpire:%ld))\n",q->name,q->value,q->secure?"SECURED ":"",q->expire);
    Buffer_Append(bf,"  upload:\n",-1);
    for ( u = self->upload; u; u = u->next )
      Buffer_Printf(bf,"    %s => %s (%d bytes) %s `%s`\n",u->name,u->path,u->length,u->mimetype,u->original);
    Buffer_Printf(bf,"}\n");
  }
#endif
  ;
  
char *Cgi_Format_Str(C_CGI *self)
#ifdef _C_CGI_BUILTIN
  {
    C_BUFFER *bf = Buffer_Init(0);
    Cgi_Format_Bf(self,bf);
    return Buffer_Take_Data(bf);
  }
#endif
  ;

char *Cgi_Format_Cookies_Out(C_CGI *self)
#ifdef _C_CGI_BUILTIN
  {
    C_CGI_COOKIE *q;
    C_BUFFER bf = {0};
    for ( q = self->cookie_out; q; q = q->next ) 
      {
        Buffer_Append(&bf,"Set-Cookie: ",-1);
        Buffer_Append(&bf,q->name,-1);
        Buffer_Fill_Append(&bf,'=',1);
        Buffer_Append(&bf,q->value,-1);
        if ( q->expire )
          {
            //time_t gmt_time;
            static char *wday [] = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
            static char *mon  [] = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                                     "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };
            struct tm *tm = gmtime(&q->expire);
            Buffer_Printf(&bf,"; expires=%s, %02d-%s-%04d %02d:%02d:%02d GMT",
              wday[tm->tm_wday%7],
              tm->tm_mday,
              mon[tm->tm_mon%12],
              tm->tm_year+1900,
              tm->tm_hour,tm->tm_min,tm->tm_sec);
          }
        if ( q->secure )
          Buffer_Append(&bf,"; secure",-1);

        Buffer_Append(&bf,"; HttpOnly",-1);
        if ( q->next )
          Buffer_Fill_Append(&bf,'\n',1);
      }
    if ( bf.at )
      return Buffer_Take_Data(&bf);
    else
      return "";
  }
#endif
  ;

char *Cgi_Upload_Part(
  C_CGI *cgi, uptrword_t out, Unknown_Write_Proc xwrite, 
  char *S, char *bf, int *L, int maxlen)
#ifdef _C_CGI_BUILTIN
  {
    int count = 0;
    int cb_l = strlen(cgi->content_boundary);
    
    while (S && *L)
      {
        int j = 0, k = 0;
        if ( strncmp(S,cgi->content_boundary,cb_l) == 0 )
          break;
        
        //++j;
        
        while ( *L-j >= cb_l+2 )
          {
            k = 0;
            if ( S[j] == '\r' ) ++k;
            if ( S[j+k] == '\n' ) ++k;
            if ( 0 == strncmp(S+j+k,cgi->content_boundary,cb_l) )
              break;
            ++j;
          }
        
        if ( count + j > maxlen )
          __Raise(C_ERROR_TO_BIG,"payload size out of limit");
        Unknown_Write(out,S,j,xwrite);
        count += j;
        S = Cgi_Pump_Part(cgi,bf,S+j+k,L);
        if ( *L < cb_l ) 
          __Raise(C_ERROR_IO,"uncomplete request");
      }

    return S;
  }
#endif
  ;
  
char *Cgi_Strip(char *S)
#ifdef _C_CGI_BUILTIN
  {
    if ( S && *S == '"' )
      {
        int L = strlen(S);
        if ( S[L-1] == '"' ) S[L-1] = 0;
        return S+1;
      }
    return S;
  }
#endif
  ;
  
char *Cgi_Multipart_Next(
  C_CGI *cgi, char *upload_dir, int upload_maxsize, char *bf,char *S, int *L)
#ifdef _C_CGI_BUILTIN
  {
    char *SE;
    char *name, *filename, *ctype;
    int cb_l = strlen(cgi->content_boundary);
     
    while ( *S && Isspace(*S) ) ++S;
    
    if ( 0 == strncmp(S,cgi->content_boundary,cb_l) )
      {
        S = Cgi_Pump_Part(cgi,bf,S,L);
        SE = S+1;
        while ( *SE )
          {
            if ( *SE == '\n' && SE[1] == '\n' ) 
              { SE += 2; break; }
            if ( *SE == '\n' && SE[1] == '\r' && SE[2] == '\n') 
              { SE += 3; break; }
            ++SE;
          }
        if ( *SE )
          {
            SE[-1] = 0;
            name = Cgi_Strip(Str_Fetch_Substr(S,"name=",0,";\n\r"));
            filename = Cgi_Strip(Str_Fetch_Substr(S,"filename=",0,";\n\r"));
            ctype = Cgi_Strip(Str_Fetch_Substr(S,"Content-Type:"," ",";\n\r"));
            S = Cgi_Pump_Part(cgi,bf,SE,L);
            if ( ctype || filename )
              {
                char *tmpfname = Path_Unique_Name(upload_dir,"cgi-",".upl");
                C_FILE *f = Cfile_Open(tmpfname,"w+P");
                C_CGI_UPLOAD *u = Cgi_Attach_Upload(&cgi->upload,tmpfname,ctype,name,filename,0);
                S = Cgi_Upload_Part(cgi,(uptrword_t)f,&Cf_Write,S,bf,L,upload_maxsize);
                Cfile_Flush(f);
                u->length = Cfile_Length(f);
                Cfile_Close(f);
              }
            else
              {
                C_BUFFER *val = Buffer_Init(0);
                S = Cgi_Upload_Part(cgi,(uptrword_t)val,&Bf_Write,S,bf,L,C_CGI_POST_MAX_PAYLOAD);
                Xvalue_Set_Str(Xnode_Deep_Value(cgi->params,name),val->at,val->count);
              }
            return S;
          }
      }
    return 0;
  }
#endif
  ;
  
void Cgi_Process_Multipart_Content(C_CGI *cgi, char *upload_dir, int upload_maxsize)
#ifdef _C_CGI_BUILTIN
  {
    char bf[C_STDF_PUMP_BUFFER];
    int L = Cgi_Pump(cgi,bf);
    char *S = bf;
    while ( S && L )
      __Auto_Release
        S = Cgi_Multipart_Next(cgi,upload_dir,upload_maxsize,bf,S,&L);
  }
#endif
  ;
  
C_CGI *Cgi_Query_Params(C_CGI *cgi, char *upload_dir, int upload_maxsize)
#ifdef _C_CGI_BUILTIN
  {
    if ( !cgi ) cgi = Cgi_Init();
    
    if ( !cgi->params ) __Auto_Release
      {
        char lbuf[1024], c;
        char *q, *key, *value, *qE = lbuf+(sizeof(lbuf)-1);
        char *S = 0;
        cgi->params = __Refe(Xdata_Init());
        if ( !upload_dir ) upload_dir = Temp_Directory();
        if ( cgi->request_method == C_CGI_GET )
          {
            S = cgi->query_string;
          }
        else if ( cgi->request_method == C_CGI_POST )
          {
            if ( cgi->content_type == C_CGI_MULTIPART )
              {
                if ( cgi->content_boundary )
                  Cgi_Process_Multipart_Content(cgi,upload_dir,upload_maxsize);
              }
            else if ( cgi->content_length < C_CGI_POST_MAX_PAYLOAD )
              {
                int count = cgi->content_length;
                int l = 0;
                S = __Malloc(count+1);
                while ( l < count )
                  {
                    int q = fread(S+l,1,count-l,stdin);
                    if ( q < 0 )
                      __Raise_Format(C_ERROR_IO,
                        ("failed to read request content: %s",strerror(ferror(stdin))));
                    l += q;
                  }
                S[count] = 0;
              }
            else
              __Raise(C_ERROR_TO_BIG,"payload size out of limit");
          }
        if ( S && (cgi->request_method == C_CGI_GET || cgi->content_type == C_CGI_URLENCODED) )
          {
            while ( *S )
              {
                value = 0;
                key = q = lbuf;
                while ( *S && *S == '&' ) ++S;
                while ( *S && *S != '=' && *S != '&' )
                  {
                    c = ( *S != '%' && *S != '+' ) ? *S++ : Str_Urldecode_Char(&S);
                    if ( q >= lbuf && q < qE ) *q++ = c;
                  }
                if ( q >= lbuf && q < qE ) *q++ = 0;
                value = q; *q = 0; /* if (q == qE) there is one more char for final zero */
                if ( *S == '=' ) 
                  {
                    ++S;
                    while ( *S && *S != '&' )
                      {
                        c = ( *S != '%' && *S != '+' ) ? *S++ : Str_Urldecode_Char(&S);
                        if ( q >= lbuf && q < qE ) *q++ = c;
                      }
                  }
                *q = 0; /* if (q == qE) there is one more char for final zero */
                Xvalue_Set_Str(Xnode_Deep_Value(cgi->params,key),value,q-value);
              }
          }
      }
      
    return cgi;
  }
#endif
  ;
  
#define Cgi_Get_Outbuf(Cgir) ((Cgir)->out)
#define Cgi_Get_Len(Cgir) ((Cgir)->out->count)
#define Cgi_Get_Cstr(Cgir) ((Cgir)->out->at)
#define Cgi_Puts(Cgir,S) Buffer_Puts(Cgir->out,S)
#define Cgi_Fill(Cgir,C,N) Buffer_Fill_Append(Cgir->out,C,N)
#define Cgi_Append(Cgir,S,L) Buffer_Append(Cgir->out,S,L)

void Cgi_Printf(C_CGI *cgi, char *fmt, ...)
#ifdef _C_CGI_BUILTIN
  {
    va_list va;
    va_start(va,fmt);
    Buffer_Printf_Va(cgi->out,fmt,va);
    va_end(va);
  }
#endif
  ;

void Cgi_Put_Out_(C_CGI *cgi, char *S)
#ifdef _C_CGI_BUILTIN
  {
    if (!S); else 
      if ( cgi->ostrm ) 
        Oj_Print(cgi->ostrm,S);
      else
        fputs(S,stdout);
  }
#endif
  ;
  
void Cgi_Write_Out(C_CGI *cgi, int out_status)
#ifdef _C_CGI_BUILTIN
  {
    if ( out_status == CGI_OUT_TEXTHTML )
      {
        Cgi_Put_Out_(cgi,"Content-Type: text/html; charset=utf-8\r\n");
        Cgi_Put_Out_(cgi,__Format("Content-Length: %d\r\n\r\n",Cgi_Get_Len(cgi)));
        Cgi_Put_Out_(cgi,cgi->out->at);
      }
    else if ( out_status == CGI_OUT_TEXTJSON )
      {
        Cgi_Put_Out_(cgi,"Content-Type: text/json; charset=utf-8\r\n");
        Cgi_Put_Out_(cgi,__Format("Content-Length: %d\r\n\r\n",Cgi_Get_Len(cgi)));
        Cgi_Put_Out_(cgi,cgi->out->at);
      }
    else if ( out_status == CGI_OUT_TEXTPLAIN )
      {
        Cgi_Put_Out_(cgi,"Content-Type: text/plain; charset=utf-8\r\n");
        Cgi_Put_Out_(cgi,__Format("Content-Length: %d\r\n\r\n",Cgi_Get_Len(cgi)));
        Cgi_Put_Out_(cgi,cgi->out->at);
      }
    else if ( out_status == CGI_OUT_REDIRECT )
      {
        Cgi_Put_Out_(cgi,"Location: ");
        Cgi_Put_Out_(cgi,cgi->out->at);
        Cgi_Put_Out_(cgi,"\r\n");
        Cgi_Put_Out_(cgi,Cgi_Format_Cookies_Out(cgi));
        Cgi_Put_Out_(cgi,"\r\n\r\n");
      }
    else if ( out_status == CGI_OUT_DATASTREAM )
      {
        char bf[C_FILE_COPY_BUFFER_SIZE];
        int count = 0;
        void *src = cgi->dstrm;
        int (*xread)(void*,void*,int,int) = C_Find_Method_Of(&src,Oj_Read_OjMID,C_RAISE_ERROR);
        int len = Oj_Available(cgi->dstrm);
        Cgi_Put_Out_(cgi,"Content-Type: ");
        Cgi_Put_Out_(cgi,cgi->dstrm_mimetype);
        Cgi_Put_Out_(cgi,"\r\n");
        Cgi_Put_Out_(cgi,__Format("Content-Length: %d\r\n\r\n",len));
        for ( ;; )
          {
            int i = xread(src,bf,C_FILE_COPY_BUFFER_SIZE,0);
            if ( !i ) break;
            if ( cgi->ostrm )
              Oj_Write_Full(cgi->ostrm,bf,i);
            else
              fwrite(bf,1,i,stdout);
            count += i;
          }
      }
    else /* empty page */
      {
        Cgi_Put_Out_(cgi,"Content-Type: text/html; charset=utf-8\n");
        Cgi_Put_Out_(cgi,"Content-Length: 0\n\n");
      }
      
    if ( cgi->ostrm ) 
      Oj_Flush(cgi->ostrm);
    else 
      fflush(stdout);
  }
#endif
  ;

void Cgi_JQ_Json(C_CGI *cgi, C_XNODE *n)
#ifdef _C_CGI_BUILTIN
  {
    char *jq = Xnode_Value_Get_Str(cgi->params,"jsoncallback",0);
    if ( jq )
      {
        Buffer_Append(cgi->out,jq,-1); 
        Buffer_Append(cgi->out,"(",1);
      }
    Json_Format_Into(cgi->out,n,0);
    if ( jq )
      {
        Buffer_Append(cgi->out,")",1);
      }
  }
#endif
  ;
  
void Cgi_Json_Out(C_CGI *cgi, C_XNODE *n)
#ifdef _C_CGI_BUILTIN
  {
    Cgi_JQ_Json(cgi,n);
    Cgi_Write_Out(cgi,CGI_OUT_TEXTJSON);
  }
#endif
  ;

#endif /* C_once_C02CA609_3FE5_45AB_B64B_15A73FD72214 */
