
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_29A1C0D6_2792_4035_8D0E_9DB1797A4120
#define C_once_29A1C0D6_2792_4035_8D0E_9DB1797A4120

#ifdef _BUILTIN
#define _C_BUFFER_BUILTIN
#endif

#include "C+.hc"
#include "string.hc"

typedef struct _C_BUFFER
  { 
    union {
      char   *at; 
      char   *chars;
      byte_t *bytes;
    };
    int count;
    int capacity;
  } C_BUFFER;

void Buffer_Clear(C_BUFFER *bf)
#ifdef _C_BUFFER_BUILTIN
  {
    free(bf->at);
    bf->at = 0;
    bf->count = 0;
    bf->capacity = 0;
  }
#endif
  ;
  
void *Buffer_Init(int count);
C_BUFFER *Buffer_Reserve(C_BUFFER *bf,int capacity)
#ifdef _C_BUFFER_BUILTIN
  {
    if ( capacity < 0 )
      __Raise(C_ERROR_OUT_OF_RANGE,0);

    if ( !bf ) bf = Buffer_Init(0);

    if ( bf->capacity < capacity || !bf->at )
      {
        bf->at = __Realloc_Npl(bf->at,capacity+1);
        bf->capacity = capacity;
        STRICT_REQUIRE(bf->count <= bf->capacity );
        bf->at[bf->count] = 0;
      }
      
    return bf;
  }
#endif
  ;

C_BUFFER *Buffer_Grow_Reserve(C_BUFFER *bf,int capacity)
#ifdef _C_BUFFER_BUILTIN
  {
    if ( capacity < 0 )
      __Raise(C_ERROR_OUT_OF_RANGE,0);

    if ( !bf ) bf = Buffer_Init(0);

    if ( bf->capacity < capacity )
      {
        capacity = Min_Pow2(capacity);
        bf->at = __Realloc_Npl(bf->at,capacity+1);
        bf->capacity = capacity;
      }
      
    return bf;
  }
#endif
  ;

void Buffer_Resize(C_BUFFER *bf,int count)
#ifdef _C_BUFFER_BUILTIN
  {
    Buffer_Reserve(bf,count);
    if ( bf->count < count ) memset(bf->at+bf->count,0,count-bf->count);
    bf->count = count;
    if ( bf->at ) bf->at[bf->count] = 0;
  }
#endif
  ;

void Buffer_Grow(C_BUFFER *bf,int count)
#ifdef _C_BUFFER_BUILTIN
  {
    Buffer_Grow_Reserve(bf,count);
    if ( bf->count < count ) memset(bf->at+bf->count,0,count-bf->count);
    bf->count = count;
    bf->at[bf->count] = 0;
  }
#endif
  ;
  
void Buffer_Append(C_BUFFER *bf,void *S,int len)
#ifdef _C_BUFFER_BUILTIN
  {
    if ( len < 0 ) /* appending C string */
      len = S?strlen(S):0;

    if ( len && S )
      {
        Buffer_Grow_Reserve(bf,bf->count+len);
        memcpy(bf->at+bf->count,S,len);
        bf->count += len;
        bf->at[bf->count] = 0;
      }
  }
#endif
  ;

void Buffer_Fill_Append(C_BUFFER *bf,int c,int count)
#ifdef _C_BUFFER_BUILTIN
  {
    STRICT_REQUIRE( count >= 0 );

    if ( count > 0 )
      {
        Buffer_Grow_Reserve(bf,bf->count+count);
        memset(bf->at+bf->count,c,count);
        bf->count += count;
        bf->at[bf->count] = 0;
      }
  }
#endif
  ;

void Buffer_Print(C_BUFFER *bf, char *S)
#ifdef _C_BUFFER_BUILTIN
  {
    Buffer_Append(bf,S,-1);
  }
#endif
  ;

void Buffer_Puts(C_BUFFER *bf, char *S)
#ifdef _C_BUFFER_BUILTIN
  {
    Buffer_Append(bf,S,-1);
    Buffer_Fill_Append(bf,'\n',1);
  }
#endif
  ;
  
void Buffer_Set(C_BUFFER *bf, char *S, int L)
#ifdef _C_BUFFER_BUILTIN
  {
    Buffer_Resize(bf,0);    
    Buffer_Append(bf,S,L);
  }
#endif
  ;

void Buffer_Printf_Va(C_BUFFER *bf, char *fmt, va_list va)
#ifdef _C_BUFFER_BUILTIN
  {
    int q, rq_len;
    
    rq_len = C_Detect_Required_Buffer_Size(fmt,va)+1;
    Buffer_Grow_Reserve(bf,bf->count+rq_len);
    
  #ifdef __windoze
    q = vsprintf((char*)bf->at+bf->count,fmt,va);
  #else
    q = vsnprintf((char*)bf->at+bf->count,rq_len,fmt,va);
  #endif
  
    if ( q >= 0 )
      bf->count += q;
    STRICT_REQUIRE(bf->count >= 0 && bf->count <= bf->capacity);
  
    bf->at[bf->count] = 0;
  }
#endif
  ;

void Buffer_Printf(C_BUFFER *bf, char *fmt, ...)
#ifdef _C_BUFFER_BUILTIN
  {
    va_list va;
    va_start(va,fmt);
    Buffer_Printf_Va(bf,fmt,va);
    va_end(va);
  }
#endif
  ;

void Buffer_Hex_Append(C_BUFFER *bf, void *S, int len)
#ifdef _C_BUFFER_BUILTIN
  {
    if ( len < 0 ) /* appending C string */
      len = S?strlen(S):0;

    if ( len && S )
      {
        int i;
        Buffer_Grow_Reserve(bf,bf->count+len*2);
        for ( i = 0; i < len; ++i )
          Str_Hex_Byte( ((byte_t*)S)[i], 0, bf->at+bf->count+i*2 );

        bf->count += len*2;
        bf->at[bf->count] = 0;
      }
  }
#endif
  ;

void Buffer_Esc_Append(C_BUFFER *bf, void *S, int len)
#ifdef _C_BUFFER_BUILTIN
  {
    byte_t *q = S;
    byte_t *p = q;
    byte_t *E;
    
    if ( len < 0 ) 
      len = S?strlen(S):0;
    
    E = p + len;
    
    while ( p != E )
      {
        do 
          { 
            if ( *p < 30 || *p > 127 ||*p == '\\' ||  *p == '"' || *p == '\'' ) 
              break; 
            ++p; 
          } 
        while ( p != E );
        
        if ( q != p )
          Buffer_Append(bf,q,p-q);
        
        if ( p != E )
          {
            char *t; 
            Buffer_Fill_Append(bf,0,4);
            STRICT_REQUIRE( bf->count >= 5 );
            t = bf->chars + bf->count - 4;
            t[0] = '\\';
            t[1] = ((*p>>6)%8) + '0';
            t[2] = ((*p>>3)%8) + '0';            
            t[3] = (*p%8) + '0';          
          }
          
        q = ++p;
      }
  }
#endif
  ;
  
void Buffer_Quote_Append(C_BUFFER *bf, void *S, int len, int brk)
#ifdef _C_BUFFER_BUILTIN
  {
    byte_t *q = S;
    byte_t *p = q;
    byte_t *E;
    
    if ( len < 0 ) 
      len = S?strlen(S):0;
    
    E = p + len;
    
    while ( p != E )
      {
        do 
          { 
            if ( *p < 30 || *p == '\\' 
              || (brk ? *p == brk : ( *p == '"' || *p == '\'' )) ) 
              break; 
            ++p; 
          } 
        while ( p != E );
        
        if ( q != p )
          Buffer_Append(bf,q,p-q);
        
        if ( p != E )
          {
            if ( *p == '\n' ) Buffer_Append(bf,"\\n",2);
            else if ( *p == '\t' ) Buffer_Append(bf,"\\t",2);
            else if ( *p == '\r' ) Buffer_Append(bf,"\\r",2);
            else if ( *p == '\\' ) Buffer_Append(bf,"\\\\",2);
            else if ( brk && *p == brk )  
              { 
                Buffer_Fill_Append(bf,'\\',1);
                Buffer_Fill_Append(bf,brk,1);
              }
            else if ( !brk && *p == '"' ) 
              Buffer_Append(bf,"\\\"",2);
            else if ( !brk && *p == '\'' ) 
              Buffer_Append(bf,"\\'",2);
            else if ( *p < 30 ) 
              {
                Buffer_Append(bf,"\\x",2);
                Buffer_Hex_Append(bf,p,1);
              }
          
            ++p;
          }
          
        q = p;
      }
  }
#endif
  ;

void Buffer_Html_Quote_Append(C_BUFFER *bf, void *S, int len)
#ifdef _C_BUFFER_BUILTIN
  {
    byte_t *q = S;
    byte_t *p = q;
    byte_t *E;
    
    if ( len < 0 ) 
      len = S?strlen(S):0;
    
    E = p + len;
    
    while ( p != E )
      {
        do 
          { 
            if ( *p == '<' || *p == '>'  || *p == '&') 
              break; 
            ++p; 
          } 
        while ( p != E );
        
        if ( q != p )
          Buffer_Append(bf,q,p-q);
        
        if ( p != E )
          {
            if ( *p == '<' ) Buffer_Append(bf,"&lt;",4);
            else if ( *p == '>' ) Buffer_Append(bf,"&gt;",4);
            else if ( *p == '&' ) Buffer_Append(bf,"&amp;",5);
            ++p;
          }
          
        q = p;
      }
  }
#endif
  ;

void Buffer_Insert(C_BUFFER *bf,int pos,void *S,int len)
#ifdef _C_BUFFER_BUILTIN
  {
    if ( len < 0 ) /* appending C string */
      len = S?strlen(S):0;

    if ( pos < 0 ) pos = bf->count + pos + 1;
    if ( pos < 0 || pos > bf->count ) 
      __Raise(C_ERROR_OUT_OF_RANGE,0);
    
    Buffer_Grow_Reserve(bf,bf->count+len);
    if ( pos < bf->count )
      memmove(bf->at+pos+len,bf->at+pos,bf->count-pos);
    memcpy(bf->at+pos,S,len);
    bf->count += len;
    bf->at[bf->count] = 0;
  }
#endif
  ;


#define Buffer_Take_Data(Bf) __Pool(Buffer_Take_Data_Npl(Bf))
void *Buffer_Take_Data_Npl(C_BUFFER *bf)
#ifdef _C_BUFFER_BUILTIN
  {
    void *R = bf->at;
    bf->count = 0;
    bf->at = 0;
    bf->capacity = 0;
    return R;
  }
#endif
  ;
  
void *Buffer_Take_Data_Non(C_BUFFER *bf)
#ifdef _C_BUFFER_BUILTIN
  {
    void *n = Buffer_Take_Data(bf);
    if ( !n ) 
      { 
        n = __Malloc(1);
        *((char*)n) = 0;
      }
    return n;
  }
#endif
  ;
  
#define Buffer_COUNT(Bf)    ((int)((C_BUFFER *)(Bf))->count)
#define Buffer_CAPACITY(Bf) ((int)((C_BUFFER *)(Bf))->capacity)
#define Buffer_BEGIN(Bf)    (((C_BUFFER *)(Bf))->at)
#define Buffer_END(Bf)      (Buffer_BEGIN(Bf)+Buffer_COUNT(Bf))

int Buffer_Count(C_BUFFER *bf)
#ifdef _C_BUFFER_BUILTIN
  {
    if ( bf )
      return Buffer_COUNT(bf);
    return 0;
  }
#endif
  ;
  
int Buffer_Capacity(C_BUFFER *bf)
#ifdef _C_BUFFER_BUILTIN
  {
    if ( bf )
      return Buffer_CAPACITY(bf);
    return 0;
  }
#endif
  ;
 void *Buffer_Begin(C_BUFFER *bf)
#ifdef _C_BUFFER_BUILTIN
  {
    if ( bf )
      return Buffer_BEGIN(bf);
    return 0;
  }
#endif
  ;

void *Buffer_End(C_BUFFER *bf)
#ifdef _C_BUFFER_BUILTIN
  {
    if ( bf )
      return Buffer_END(bf);
    return 0;
  }
#endif
  ;

void Buffer_Destruct(C_BUFFER *bf)
#ifdef _C_BUFFER_BUILTIN
  {
    if ( bf->at )
      free(bf->at);
    __Destruct(bf);
  }
#endif
  ;

void *Buffer_Init(int count)
#ifdef _C_BUFFER_BUILTIN
  {
    C_BUFFER *bf = __Object_Dtor(sizeof(C_BUFFER),Buffer_Destruct);
    if ( count )
      Buffer_Resize(bf,count);
    return bf;
  }
#endif
  ;
  
void *Buffer_Acquire(char *S)
#ifdef _C_BUFFER_BUILTIN
  {
    C_BUFFER *bf = __Object_Dtor(sizeof(C_BUFFER),Buffer_Destruct);
    int L = strlen(S);
    bf->at = S;
    bf->count = L;
    bf->capacity = L;
    return bf;
  }
#endif
  ;

void *Buffer_Zero(int count)
#ifdef _C_BUFFER_BUILTIN
  {
    C_BUFFER *bf = Buffer_Init(count);
    if ( bf->count ) 
      memset(bf->at,0,bf->count);
    return bf;
  }
#endif
  ;

void *Buffer_Copy(void *S, int count)
#ifdef _C_BUFFER_BUILTIN
  {
    C_BUFFER *bf;
    if ( count < 0 ) count = S?strlen(S):0;
    bf = Buffer_Init(count);
    if ( count )
      memcpy(bf->at,S,count);
    return bf;
  }
#endif
  ;

void Buffer_Swap(C_BUFFER *a, C_BUFFER *b)
#ifdef _C_BUFFER_BUILTIN
  {
    C_BUFFER tmp;
    memcpy(&tmp,a,sizeof(C_BUFFER));
    memcpy(a,b,sizeof(C_BUFFER));
    memcpy(b,&tmp,sizeof(C_BUFFER));
  }
#endif
  ;

#endif /* C_once_29A1C0D6_2792_4035_8D0E_9DB1797A4120 */

