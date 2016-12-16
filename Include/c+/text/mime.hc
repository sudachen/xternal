
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_E5DC0CBD_6EF6_4E8C_A4F5_CF78FA971011
#define C_once_E5DC0CBD_6EF6_4E8C_A4F5_CF78FA971011

#include "../C+.hc"
#include "../string.hc"

#ifdef _BUILTIN
#define _C_MIME_BUILTIN
#endif

#ifdef _C_MIME_BUILTIN
  #define _C_MIME_BUILTIN_CODE(Code) Code
  #define _C_MIME_EXTERN 
#else
  #define _C_MIME_BUILTIN_CODE(Code)
  #define _C_MIME_EXTERN extern
#endif

enum
  {
    C_MIME_NONE  = __FOUR_CHARS('`','`','`','`'),
    C_MIME_OCTS  = __FOUR_CHARS('O','C','T','S'),
    C_MIME_JPEG  = __FOUR_CHARS('J','P','E','G'),
    C_MIME_PNG   = __FOUR_CHARS('x','P','N','G'),
    C_MIME_GIF   = __FOUR_CHARS('x','G','I','F'),
    C_MIME_PICT  = __FOUR_CHARS('P','I','C','T'),
    C_MIME_HTML  = __FOUR_CHARS('H','T','M','L'),
    C_MIME_TEXT  = __FOUR_CHARS('T','E','X','T'),
    C_MIME_GZIP  = __FOUR_CHARS('G','Z','I','P'),
    C_MIME_PKZIP = __FOUR_CHARS('x','Z','I','P'),
    C_MIME_7ZIP  = __FOUR_CHARS('7','Z','I','P'),
    C_MIME_APP   = __FOUR_CHARS('x','A','P','P'),
    C_MIME_JS    = __FOUR_CHARS('x','x','J','S'),
    C_MIME_CSS   = __FOUR_CHARS('x','C','S','S'),
    C_MIME_EXE   = __FOUR_CHARS('x','E','X','E'),
    C_MIME_JSON  = __FOUR_CHARS('J','S','O','N'),
    C_MIME_UNKNOWN = -1,
  };

typedef struct _C_EXT_MAP_RECORD
  {
    char *ext;
    int   extlen;
    int   code;
  } C_EXT_MAP_RECORD; 

_C_MIME_EXTERN C_EXT_MAP_RECORD Mime_Ext_Map[] 
#ifdef _C_MIME_BUILTIN
  = { 
    {".html", 5, C_MIME_HTML},
    {".htm",  4, C_MIME_HTML},
    {".txt",  4, C_MIME_TEXT},
    {".jpeg", 5, C_MIME_JPEG},
    {".jpg",  4, C_MIME_JPEG},
    {".png",  4, C_MIME_PNG},
    {".gif",  4, C_MIME_GIF},
    {".zip",  4, C_MIME_PKZIP},
    {".7z",   3, C_MIME_7ZIP},
    {".gz",   3, C_MIME_GZIP},
    {".exe",  4, C_MIME_APP},
    {".js",   3, C_MIME_JS},
    {".css",  4, C_MIME_CSS},
    {".json", 5, C_MIME_JSON},
    {0,0}
  }
#endif
  ;

int Mime_Code_Of_Path(char *path, int dflt)
#ifdef _C_MIME_BUILTIN
  {
    C_EXT_MAP_RECORD *R = Mime_Ext_Map;
    int L = strlen(path);
    for ( ; R->ext; ++R )
      {
        if ( L >= R->extlen && !strncmp_I(path+L-R->extlen,R->ext,R->extlen) )
          return R->code;
      }
    return dflt;
  }
#endif
  ;
  
int Mime_Code_Of(char *mime_type)
#ifdef _C_MIME_BUILTIN
  {
    int i;
    char SS[80] = {0,};
    char *S = SS;
    for ( i = 0; mime_type[i] && i < sizeof(SS)-1; ++i ) SS[i] = Tolower(mime_type[i]);
    if ( !strncmp(S,"application/",12) )
      {
        S += 12;
        if ( !strncmp(S,"x-",2) ) S +=2;
        if ( !strcmp(S,"octet-stream") ) return C_MIME_OCTS;
        if ( !strcmp(S,"javascript") )   return C_MIME_JS;
        if ( !strcmp(S,"msdownload") )   return C_MIME_EXE;
        if ( !strcmp(S,"json") )         return C_MIME_JSON;
        if ( !strcmp(S,"gzip") )         return C_MIME_GZIP;
        if ( !strcmp(S,"zip") )          return C_MIME_PKZIP;
        if ( !strcmp(S,"7zip") )         return C_MIME_7ZIP;
        return C_MIME_APP;
      }
    else if ( !strncmp(S,"text/",5) )
      {
        S += 5;
        if ( !strncmp(S,"x-",2) ) S +=2;
        if ( !strcmp(S,"html") ) return C_MIME_HTML;
        if ( !strcmp(S,"css") )   return C_MIME_CSS;
        if ( !strcmp(S,"javascript") ) return C_MIME_JS;
        if ( !strcmp(S,"json") ) return C_MIME_JSON;
        else return C_MIME_TEXT;
      }
    else if ( !strncmp(S,"image/",6) )
      {
        S += 6;
        if ( !strncmp(S,"x-",2) ) S +=2;
        if ( !strcmp(S,"jpeg") ) return C_MIME_JPEG;
        if ( !strcmp(S,"png") )  return C_MIME_PNG;
        if ( !strcmp(S,"gif") )  return C_MIME_GIF;
        return C_MIME_PICT;
      }
    return C_MIME_NONE;
  }
#endif
  ;

int Mime_Is_Image(int mime)
#ifdef _C_MIME_BUILTIN
  {
    switch(mime)
      {
        case C_MIME_JPEG:  
        case C_MIME_PNG:   
        case C_MIME_GIF: 
        case C_MIME_PICT: 
          return 1;
      }
    return 0;
  }
#endif
  ;
  
int Mime_Is_Compressed(int mime)
#ifdef _C_MIME_BUILTIN
  {
    switch(mime)
      {
        case C_MIME_JPEG:  
        case C_MIME_PNG:   
        case C_MIME_GIF: 
        case C_MIME_GZIP: 
        case C_MIME_PKZIP: 
        case C_MIME_7ZIP: 
          return 1;
      }
    return 0;
  }
#endif
  ;
  
int Mime_Is_Text(int mime)
#ifdef _C_MIME_BUILTIN
  {
    switch(mime)
      {
        case C_MIME_HTML:
        case C_MIME_TEXT:
        case C_MIME_JS:
        case C_MIME_CSS:
        case C_MIME_JSON:
          return 1;
      }
    return 0;
  }
#endif
  ;
  
int Mime_Is_Binary(int mime)
#ifdef _C_MIME_BUILTIN
  {
    return !Mime_Is_Text(mime);
  }
#endif
  ;
  
#define Mime_String_Of_Npl(Mime) Str_Copy_Npl(Mime_String_Of(Mime),-1)
char *Mime_String_Of(int mime)
#ifdef _C_MIME_BUILTIN
  {
    switch(mime)
      {
        case C_MIME_OCTS: return "application/octet-stream";
        case C_MIME_JPEG: return "image/jpeg";
        case C_MIME_PNG:  return "image/png";
        case C_MIME_GIF:  return "image/gif";
        case C_MIME_PICT: return "image/octet-stream";
        case C_MIME_HTML: return "text/html";
        case C_MIME_TEXT: return "text/plain";
        case C_MIME_GZIP: return "application/x-gzip";
        case C_MIME_PKZIP:return "application/zip";
        case C_MIME_7ZIP: return "application/x-7zip";
        case C_MIME_APP:  return "application/octet-stream";
        case C_MIME_CSS:  return "text/css";
        case C_MIME_JS:   return "text/javascript";
        case C_MIME_EXE:  return "application/x-msdownload";
        case C_MIME_JSON: return "application/json";
      }
    return "application/octet-stream";
  }
#endif
  ;

_C_MIME_EXTERN char Oj_Mimetype_Of_OjMID[] _C_MIME_BUILTIN_CODE( = "mimetype_of/@"); 
int Oj_Mimetype_Of(void *o) _C_MIME_BUILTIN_CODE(
  { return ((int(*)(void*))C_Find_Method_Of(&o,Oj_Mimetype_Of_OjMID,C_RAISE_ERROR))
        (o); });
  
#endif /* C_once_E5DC0CBD_6EF6_4E8C_A4F5_CF78FA971011 */

