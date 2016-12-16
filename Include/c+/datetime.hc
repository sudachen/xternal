
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_A998DD5F_3579_4977_B115_DCCE42423C49
#define C_once_A998DD5F_3579_4977_B115_DCCE42423C49

#ifdef _BUILTIN
#define _C_DATETIME_BUILTIN
#endif

#include "C+.hc"

typedef quad_t datetime_t;

#define Get_Curr_Date()        ((uint_t)(Current_Gmt_Datetime()>>32))
#define Get_Curr_Datetime()    Current_Gmt_Datetime()
#define Get_Posix_Datetime(Dt) Timet_Of_Datetime(Dt)
#define Get_Gmtime_Datetime(T) Gmtime_Datetime(T)
#define Get_System_Useconds()  System_Useconds()
#define Get_System_Millis()    (Get_System_Useconds()/1000)

#define System_Millis() (System_Useconds()/1000)
quad_t System_Useconds()
#ifdef _C_DATETIME_BUILTIN
  {
  #ifdef __windoze
    SYSTEMTIME systime = {0};
    FILETIME   ftime;
    quad_t Q;
    GetSystemTime(&systime);
    SystemTimeToFileTime(&systime,&ftime);
    Q = ((quad_t)ftime.dwHighDateTime << 32) + (quad_t)ftime.dwLowDateTime;
  #if defined _MSC_VER && _MSC_VER < 1300
    { quad_t QQ = 116444736; QQ *= 1000000000; Q -= QQ; }
  #else
    Q -= 116444736000000000LL; /* posix epoche */
  #endif
    return Q/10;
  #else
    struct timeval tv = {0};
    gettimeofday(&tv,0);
    return  ( (quad_t)tv.tv_sec * 1000*1000 + (quad_t)tv.tv_usec );
  #endif
  }
#endif
  ;
  
uint_t Get_Mclocks()
#ifdef _C_DATETIME_BUILTIN
  {
    double c = clock();
    return (uint_t)((c/CLOCKS_PER_SEC)*1000);
  }
#endif
  ;

double Get_Sclocks()
#ifdef _C_DATETIME_BUILTIN
  {
    double c = clock();
    return c/CLOCKS_PER_SEC;
  }
#endif
  ;

quad_t Tm_To_Datetime(struct tm *tm,int msec)
#ifdef _C_DATETIME_BUILTIN
  {
    uint_t dt = (((uint_t)tm->tm_year+1900)<<16)|(((uint_t)tm->tm_mon+1)<<8)|tm->tm_mday;
    uint_t mt = ((uint_t)tm->tm_hour<<24)|(uint_t)(tm->tm_min<<16)|((uint_t)tm->tm_sec<<8)|((msec/10)%100);
    return ((quad_t)dt << 32)|(quad_t)mt;
  }
#endif
  ;

#define Gmtime_Datetime(T) _Gmtime_Datetime(T,0)
quad_t _Gmtime_Datetime(time_t t, int ms)
#ifdef _C_DATETIME_BUILTIN
  {
    struct tm *tm;
    tm = gmtime(&t);
    return Tm_To_Datetime(tm,ms);
  }
#endif
  ;

#define Local_Datetime(T) _Local_Datetime(T,0)
quad_t _Local_Datetime(time_t t, int ms)
#ifdef _C_DATETIME_BUILTIN
  {
    struct tm *tm;
    tm = localtime(&t);
    return Tm_To_Datetime(tm,ms);
  }
#endif
  ;

quad_t Current_Gmt_Datetime()
#ifdef _C_DATETIME_BUILTIN
  {
    quad_t usec = Get_System_Useconds();
    return _Gmtime_Datetime((time_t)(usec/1000000),(int)((usec/1000)%1000));
  }
#endif
  ;

quad_t Current_Local_Datetime()
#ifdef _C_DATETIME_BUILTIN
  {
    quad_t usec = Get_System_Useconds();
    return _Local_Datetime((time_t)(usec/1000000),(int)((usec/1000)%1000));
  }
#endif
  ;

#define Dt_Hour(Dt) ((int)((Dt)>>24)&0x0ff)
#define Dt_Min(Dt)  ((int)((Dt)>>16)&0x0ff)
#define Dt_Sec(Dt)  ((int)((Dt)>> 8)&0x0ff)
#define Dt_Msec(Dt) ((int)((Dt)>> 0)&0x0ff)
#define Dt_Year(Dt) ((int)((Dt)>>(32+16))&0x0ffff)
#define Dt_Mon(Dt)  ((int)((Dt)>>(32+ 8))&0x0ff)
#define Dt_Mday(Dt) ((int)((Dt)>>(32+ 0))&0x0ff)

quad_t Get_Datetime(uint_t year, uint_t month, uint_t day, uint_t hour, uint_t minute, uint_t segundo )
#ifdef _C_DATETIME_BUILTIN
  {
    uint_t dt = ((year%0x0ffff)<<16)|((month%13)<<8)|(day%32);
    uint_t mt = ((hour%24)<<24)|((minute%60)<<16)|((segundo%60)<<8);
    return ((quad_t)dt << 32)|(quad_t)mt;
  }
#endif
  ;

time_t Timet_Of_Datetime(quad_t dtime)
#ifdef _C_DATETIME_BUILTIN
  {
    struct tm tm;
    memset(&tm,0,sizeof(tm));
    tm.tm_year = Dt_Year(dtime)-1900;
    tm.tm_mon  = Dt_Mon(dtime)-1;
    tm.tm_mday = Dt_Mday(dtime);
    tm.tm_hour = Dt_Hour(dtime);
    tm.tm_min  = Dt_Min(dtime);
    return mktime(&tm);
  }
#endif
  ;

#ifdef __windoze
  void Timet_To_Filetime(time_t t, FILETIME *pft)
# ifdef _C_DATETIME_BUILTIN
    {
  #if defined _MSC_VER && _MSC_VER < 1300
      quad_t QQ = 116444736;
      quad_t ll = (quad_t)t * 10000000 + QQ * 1000000000;
  #else
      quad_t ll = (quad_t)t * 10000000 + 116444736000000000LL;
  #endif
      pft->dwLowDateTime = (DWORD)ll;
      pft->dwHighDateTime = (DWORD)(ll >> 32);
    }
# endif
    ;
  #define Timet_To_Largetime(T,Li) Timet_To_Filetime(T,(FILETIME*)(Li))
#endif /*__windoze*/

#define YmdHMS_Curr_Datetime(Sep1,Sep2,Sep3) YmdHMS_Datetime(Current_Gmt_Datetime(),Sep1,Sep2,Sep3) 
#define YmdHMS_Curr_Local_Datetime(Sep1,Sep2,Sep3) YmdHMS_Datetime(Current_Local_Datetime(),Sep1,Sep2,Sep3) 
char *YmdHMS_Datetime(quad_t dt,char dt_sep1,char dt_sep2,char dt_sep3)
#ifdef _C_DATETIME_BUILTIN
  {
    char sp1[2] = {dt_sep1,0};
    char sp2[2] = {dt_sep2,0};
    char sp3[2] = {dt_sep3,0};
    char *S = __Malloc(20);
    int L = sprintf(S,"%04d%s%02d%s%02d%s%02d%s%02d%s%02d",
      Dt_Year(dt),sp1,Dt_Mon(dt),sp1,Dt_Mday(dt),sp2,
      Dt_Hour(dt),sp3,Dt_Min(dt),sp3,Dt_Sec(dt));  
    STRICT_REQUIRE(L <= 19);
    S[L] = 0;
    return S;
  }
#endif
  ;
    
#define Ymd_Curr_Date(Sep) Ymd_Date(Current_Gmt_Datetime(),Sep) 
#define Ymd_Curr_Local_Date(Sep) Ymd_Date(Current_Local_Datetime(),Sep) 
char *Ymd_Date(quad_t dt,char dt_sep)
#ifdef _C_DATETIME_BUILTIN
  {
    char sp[2] = {dt_sep,0};
    char *S = __Malloc(11);
    int L = sprintf(S,"%04d%s%02d%s%02d",Dt_Year(dt),sp,Dt_Mon(dt),sp,Dt_Mday(dt));
    STRICT_REQUIRE(L <= 10);
    S[L] = 0;
    return S;
  }
#endif
  ;

quad_t YmdHMS_Parse_Datetime(char *S,char csp1,char csp2,char csp3)
#ifdef _C_DATETIME_BUILTIN
  {
    int dt_year, dt_mon, dt_day, dt_hour, dt_min, dt_sec;
    char b[32] = {0,};
    char sp1[2] = {csp1,0};
    char sp2[2] = {csp2,0};
    char sp3[2] = {csp3,0};
    sprintf(b,"%%04d%s%%02d%s%%02d%s%%02d%s%%02d%s%%02d",sp1,sp1,sp2,sp3,sp3);
    sscanf(S,b,&dt_year,&dt_mon,&dt_day,&dt_hour,&dt_min,&dt_sec);
    return Get_Datetime(dt_year,dt_mon,dt_day,dt_hour,dt_min,dt_sec);
  } 
#endif
  ;
  
#endif /* C_once_A998DD5F_3579_4977_B115_DCCE42423C49 */

