
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_DD56FBFA_631C_47CD_B2A4_E6C8932594C8
#define C_once_DD56FBFA_631C_47CD_B2A4_E6C8932594C8

#include "C+.hc"
#include "string.hc"
#include "buffer.hc"

#ifdef _BUILTIN
#define _C_CTOKEN_BUILTIN
#endif

enum
  {
      C_CTOKEN_ERR         = -2,
      C_CTOKEN_END         = -1,
      C_CTOKEN_DIGITS      = __FOUR_CHARS('D','I','G','T'),
      C_CTOKEN_XDIGITS     = __FOUR_CHARS('X','D','G','T'),
      C_CTOKEN_FLOAT       = __FOUR_CHARS('F','L','O','T'),
      C_CTOKEN_CSTRING     = __FOUR_CHARS('C','S','T','R'),
      C_CTOKEN_ID          = __FOUR_CHARS('I','D','N','T'),
      C_CTOKEN_CHAR        = __FOUR_CHARS('C','H','A','R'),
      C_CTOKEN_LOR         = __FOUR_CHARS(' ',' ','|','|'),
      C_CTOKEN_LOR_SET     = __FOUR_CHARS(' ',' ','|','='),
      C_CTOKEN_OR_SET      = __FOUR_CHARS(' ',' ','|','='),
      C_CTOKEN_LAND        = __FOUR_CHARS(' ',' ','&','&'),
      C_CTOKEN_LAND_SET    = __FOUR_CHARS(' ','&','&','='),
      C_CTOKEN_AND_SET     = __FOUR_CHARS(' ',' ','&','='),
      C_CTOKEN_LSHIFT      = __FOUR_CHARS(' ',' ','<','<'),
      C_CTOKEN_LSH_SET     = __FOUR_CHARS(' ','<','<','='),
      C_CTOKEN_LTEQ        = __FOUR_CHARS(' ',' ','<','='),
      C_CTOKEN_RSHIFT      = __FOUR_CHARS(' ',' ','>','>'),
      C_CTOKEN_RSH_SET     = __FOUR_CHARS(' ','>','>','='),
      C_CTOKEN_GTEQ        = __FOUR_CHARS(' ',' ','>','='),
      C_CTOKEN_INC         = __FOUR_CHARS(' ',' ','+','+'),
      C_CTOKEN_DEC         = __FOUR_CHARS(' ',' ','-','-'),
      //C_CTOKEN_INC_SET     = __FOUR_CHARS(' ',' ','+','='),
      //C_CTOKEN_DEC_SET     = __FOUR_CHARS(' ',' ','-','='),
      C_CTOKEN_ADD_SET     = __FOUR_CHARS(' ',' ','+','='),
      C_CTOKEN_SUB_SET     = __FOUR_CHARS(' ',' ','-','='),
      C_CTOKEN_MUL_SET     = __FOUR_CHARS(' ',' ','*','='),
      C_CTOKEN_DIV_SET     = __FOUR_CHARS(' ',' ','/','='),
      C_CTOKEN_MOD_SET     = __FOUR_CHARS(' ',' ','%','='),
      C_CTOKEN_XOR_SET     = __FOUR_CHARS(' ',' ','^','='),
      C_CTOKEN_ELS         = __FOUR_CHARS(' ','.','.','.'),
      C_CTOKEN_EQUAL       = __FOUR_CHARS(' ',' ','=','='),
      C_CTOKEN_NSPACE      = __FOUR_CHARS(' ',' ',':',':'),
      C_CTOKEN_NEG_SET     = __FOUR_CHARS(' ',' ','~','='),
      C_CTOKEN_NOT_SET     = __FOUR_CHARS(' ',' ','!','='),
  };

typedef struct _C_CTOKMR
  {
    char *m;
    int lineno;
    int charno;
  } C_CTOKMR;
  
typedef struct _C_CTOKST
  {
    char *pS;
    char *pE;
    char *pI;
    char *source;
    int lineno;
    int charno;

    C_CTOKMR last;
    C_CTOKMR prelast;
  } C_CTOKST;

void Ctok_Init(C_CTOKST *a, char *S, char *E, char *source)
#ifdef _C_CTOKEN_BUILTIN
  {
    memset(a,0,sizeof(*a));
    a->pI = a->pS = S;
    a->pE = E;
    a->source = source;
    a->lineno = 0;
    a->charno = 0;
  }  
#endif
  ;
  
int Ctok_GetXchr(C_CTOKST *a)
#ifdef _C_CTOKEN_BUILTIN
  {
    STRICT_REQUIRE( a->pI <= a->pE && a->pI >= a->pS );
    if ( a->pI != a->pE )
      {
        if ( *a->pI == '\n' ) 
          { ++a->lineno; a->charno = 1; } 
        else 
          ++a->charno;
        return *a->pI++;
      }
    return -1;
  }
#endif
  ;
  
int Ctok_SkipXchrUntil(char c, C_CTOKST *a)
#ifdef _C_CTOKEN_BUILTIN
  {
    for (;;)
      {
        STRICT_REQUIRE( a->pI <= a->pE && a->pI >= a->pS );
        if ( a->pE == a->pI )
          return 0;
        if ( *a->pI != c )
          {
            if ( *a->pI == '\n' ) 
              { ++a->lineno; a->charno = 1; } 
            else 
              ++a->charno;
            ++a->pI;
          }
        else
          return c;
      }
  }
#endif
  ;
  
int Ctok_GetXchrIfIs(char c, C_CTOKST *a)
#ifdef _C_CTOKEN_BUILTIN
  {
    STRICT_REQUIRE( a->pI <= a->pE && a->pI >= a->pS );
    if ( a->pE == a->pI || *a->pI != c )
      return 0;
    ++a->pI;
    return c;
  }
#endif
  ;
  
int Ctok_GetXchrIfIs_Rep(char c, C_CTOKST *a, int no)
#ifdef _C_CTOKEN_BUILTIN
  {
    int i;
    STRICT_REQUIRE( a->pI <= a->pE && a->pI >= a->pS );
    if ( a->pE-a->pI < no )
      return 0;
    for ( i = 0; i < no; ++i )
      if ( a->pI[i] != c ) 
        return 0;
    a->pI += no;
    return c;
  }
#endif
  ;
  
void Ctok_Stepback(C_CTOKST *a)
#ifdef _C_CTOKEN_BUILTIN
  {
    STRICT_REQUIRE( a->pI <= a->pE && a->pI >= a->pS );
    if ( a->pI != a->pS ) 
      {
        --a->pI;
        if ( *a->pI == '\n' ) --a->lineno;
      }
  }
#endif
  ;
    
int Ctok_Hasmore(C_CTOKST *a)
#ifdef _C_CTOKEN_BUILTIN
  {
    STRICT_REQUIRE( a->pI <= a->pE && a->pI >= a->pS );
    return a->pE - a->pI;
  }
#endif
  ;
    
void Ctok_Skip_Spaces(C_CTOKST *a)
#ifdef _C_CTOKEN_BUILTIN
  {
    while ( a->pI != a->pE && ( *a->pI == ' ' || *a->pI == '\t' || *a->pI == '\n' || *a->pI == '\r' ) )
      Ctok_GetXchr(a);
  }
#endif
  ;
  
void Ctok_Mark(C_CTOKST *a)
#ifdef _C_CTOKEN_BUILTIN
  { 
    Ctok_Skip_Spaces(a);
    a->prelast = a->last;
    a->last.lineno = a->lineno;
    a->last.charno = a->charno;
    a->last.m = a->pI;
  }
#endif
  ;
  
void Ctok_Backmark(C_CTOKST *a)
#ifdef _C_CTOKEN_BUILTIN
  { 
    if ( a->last.m )
     {
       a->pI = a->last.m;
       a->charno = a->last.charno;
       a->lineno = a->last.lineno;
      }
    a->last = a->prelast;
    memset(&a->prelast,0,sizeof(a->prelast));
  }
#endif
  ;
  
#define Ctok_Token(Area,Buf) Ctok_Token_(Area,Buf,0,0)
#define Ctok_Token_Local(Area,Buf,Plen) Ctok_Token_(Area,Buf,Plen,1)
#define Ctok_Token_Srcref(Area,Pptr,Plen) Ctok_Token_(Area,Pptr,Plen,2)

int Ctok_Token_(C_CTOKST *a, void *dst, void *opt, int srccp)
#ifdef _C_CTOKEN_BUILTIN
  {
    int tk;
    char *S;
    int c;
    STRICT_REQUIRE(a != 0);    
  
  l_repeat:  
  
    Ctok_Skip_Spaces(a);
    S = a->pI;
    
    if ( (c=Ctok_GetXchr(a)) > 0 )
      {
        switch ( c )
          {
            case '{': case '}':
            case '(': case ')':
            case '[': case ']':
            case ';': case ',':
              return c;
            case ':': 
              if ( Ctok_GetXchrIfIs(c,a) ) return C_CTOKEN_NSPACE; 
              return c;
            case '<': 
              if ( Ctok_GetXchrIfIs(c,a) ) 
                {
                  if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_LSH_SET; 
                  return C_CTOKEN_LSHIFT; 
                }
              if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_LTEQ; 
              return c;
            case '>':
              if ( Ctok_GetXchrIfIs(c,a) ) 
                {
                  if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_RSH_SET; 
                  return C_CTOKEN_RSHIFT; 
                }
              if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_GTEQ; 
              return c;
            case '*': 
              if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_MUL_SET; 
              return c;
            case '/':
              if ( Ctok_GetXchrIfIs('/',a) ) 
                { 
                  Ctok_SkipXchrUntil('\n',a); 
                  goto l_repeat; 
                }
              if ( Ctok_GetXchrIfIs('*',a) )
                { 
                  do 
                    Ctok_SkipXchrUntil('*',a); 
                  while ( Ctok_GetXchrIfIs('*',a) && Ctok_Hasmore(a) && !Ctok_GetXchrIfIs('/',a) ); 
                  goto l_repeat; 
                }
              if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_DIV_SET; 
              return c;
           case '%': 
              if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_MOD_SET; 
              return c;
            case '~': 
              if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_NEG_SET; 
              return c;
            case '^': 
              if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_XOR_SET; 
              return c;
            case '!':
              if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_NOT_SET; 
              return c;
            case '+': 
              if ( Ctok_GetXchrIfIs(c,a) ) return C_CTOKEN_INC; 
              if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_ADD_SET; 
              return '+';
            case '-': 
              if ( Ctok_GetXchrIfIs(c,a) ) return C_CTOKEN_DEC; 
              if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_SUB_SET; 
              return '-';
            case '&': 
              if ( Ctok_GetXchrIfIs(c,a) ) 
                { 
                  if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_LAND_SET; 
                  return C_CTOKEN_LAND;
                } 
              if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_AND_SET; 
              return '&';
            case '|': 
              if ( Ctok_GetXchrIfIs(c,a) ) 
                { 
                  if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_LOR_SET; 
                  return C_CTOKEN_LOR;
                } 
              if ( Ctok_GetXchrIfIs('=',a) ) return C_CTOKEN_OR_SET; 
              return '|';
            case '=': 
              if ( Ctok_GetXchrIfIs(c,a) ) return C_CTOKEN_EQUAL; 
              return '=';
            case '.': 
              if ( Ctok_GetXchrIfIs_Rep(c,a,2) ) return C_CTOKEN_ELS; 
              return '.';
          }
      
        if ( c == '"' || c == '\'')
          {
            int cc = c;
            while ( Ctok_Hasmore(a) )
              {
                c = Ctok_GetXchr(a);
                if ( c == cc )
                  break;
                if ( c == '\\' ) 
                  c = Ctok_GetXchr(a);
              }
            tk = (cc == '"' ? C_CTOKEN_CSTRING : C_CTOKEN_CHAR);
            goto end_tok; 
          }
      
        if ( isalpha(c) || c == '_' )
          {
            while ( Ctok_Hasmore(a) )
              if ( isalnum(c=Ctok_GetXchr(a)) || c == '_' )
                ;
              else { Ctok_Stepback(a); break; }
            tk = C_CTOKEN_ID;
            goto end_tok;
          }

        if ( isdigit(c) )
          {
            if ( c == '0' && Ctok_GetXchrIfIs('x',a) )
              {
                while ( Ctok_Hasmore(a) )
                  if ( isxdigit(c=Ctok_GetXchr(a)) )
                   ;
                  else { Ctok_Stepback(a); break; }
                tk = C_CTOKEN_XDIGITS;
                goto end_tok;
              }
        
            if ( c == '0' && Ctok_GetXchrIfIs('.',a) )
              { goto float_part; }
        
          digit_0: if ( c == '0' )
              {
                char cc;
                if ( Ctok_Hasmore(a) )
                  if ( isdigit(cc = Ctok_GetXchr(a)) ) { c = cc; goto digit_0; }
                  else Ctok_Stepback(a); 
                tk = C_CTOKEN_DIGITS;
                goto end_tok;
              }
        
            ;
        
            while ( Ctok_Hasmore(a) )
              if ( isdigit(c=Ctok_GetXchr(a)) )
                ;
              else { Ctok_Stepback(a); break; }
        
            if ( Ctok_GetXchrIfIs('.',a) )
              {
               float_part:
                while ( Ctok_Hasmore(a) )
                  if ( isdigit(c=Ctok_GetXchr(a)) )
                    ;
                  else { Ctok_Stepback(a); break; }
                tk = C_CTOKEN_FLOAT;
                goto end_tok;
              }
          
            tk = C_CTOKEN_DIGITS;
            goto end_tok;
          }
      }
  
    return C_CTOKEN_END;
  
  end_tok:
    c = a->pI-S;
    if ( tk == C_CTOKEN_CSTRING || tk == C_CTOKEN_CHAR ) { ++S; c-=2; } 
    if ( srccp == 0 )
      { 
        if (dst) Buffer_Set(dst,S,c); 
      }
    else
      {
      }
    return tk;     
  }
#endif
  ;
  
void Ctok_Expect_Error(char *text,C_CTOKST *a)
#ifdef _C_CTOKEN_BUILTIN
  {
    __Raise_Format(C_ERROR_SYNTAX,("synax error: %s at %s:%d:%d"
                          ,text ,a->source ,a->lineno ,a->charno) );
  }
#endif
  ;
  
char *Ctok_To_String(int tok)
#ifdef _C_CTOKEN_BUILTIN
  {
    if ( tok > 30 && tok < 128 ) return Str_Copy_L((char*)&tok,1);
    return __Format("token(%4s)",&tok);
  }
#endif
  ;
  
void Ctok_Expect(int comp, char *p, C_CTOKST *a, C_BUFFER *r)
#ifdef _C_CTOKEN_BUILTIN
  {
    int t;
    Ctok_Mark(a);
    t = Ctok_Token(a,r);
    if ( t != comp || ( p && !!strcmp(r->at,p) ) ) 
      {
        Ctok_Backmark(a);
        Ctok_Expect_Error(__Format("expected %s",Ctok_To_String(comp)),a);
      }
  }
#endif
  ;
  
int Ctok_GetIfIs(int comp, char *p, C_CTOKST *a, C_BUFFER *r)
#ifdef _C_CTOKEN_BUILTIN
  {
    int t;
    Ctok_Mark(a);
    t = Ctok_Token(a,r);
    if ( t != comp || ( p && !!strcmp(r->at,p) ) ) 
      {
        Ctok_Backmark(a);
        return 0;
      }
    return 1;
  }
#endif
  ;
  
#endif /* C_once_DD56FBFA_631C_47CD_B2A4_E6C8932594C8 */

