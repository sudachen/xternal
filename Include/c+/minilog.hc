
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_9629B105_86D6_4BF5_BAA2_62AB1ACE54EC
#define C_once_9629B105_86D6_4BF5_BAA2_62AB1ACE54EC

#ifdef _BUILTIN
#define _C_MINILOG_BUILTIN
#endif

#include "C+.hc"
#include "file.hc"

enum 
  {
    C_LOG_ERROR   = 0,
    C_LOG_WARN    = 10,
    C_LOG_INFO    = 20,
    C_LOG_DEBUG   = 50,
    C_LOG_ALL     = 100,
  };

#ifdef _C_MINILOG_BUILTIN
static clock_t C_Log_Clock = 0;
static int C_Log_Line_No = 0;
static int C_Log_Fd = -1;
static int C_Log_Opt = 0;
int C_Log_Level = C_LOG_INFO;
/* static int C_Log_Pid = 0; */
#else
int C_Log_Level;
#endif

enum
  {
    C_LOG_DATESTAMP = 1 << 16,
    C_LOG_PID       = 1 << 17,
    C_LOG_DATEMARK  = 1 << 18,
    C_LOG_LINENO    = 1 << 19,
    C_LOG_LEVEL     = 1 << 20,
  };
  
void Close_Log()
#ifdef _C_MINILOG_BUILTIN  
  {
    if ( C_Log_Fd >= 0 )
      {
        close(C_Log_Fd);
        C_Log_Fd = -1;
      }
  }
#endif
  ;
  
void Append_Log(char *logname, int opt)
#ifdef _C_MINILOG_BUILTIN  
  {
    Close_Log();
    Create_Required_Dirs(logname);
    C_Log_Fd = Open_File_Raise(logname,O_CREAT|O_APPEND|O_WRONLY);
    C_Log_Opt = opt;
    C_Log_Level = opt & 0x0ff;
  }
#endif
  ;
  
void Rewrite_Log(char *logname, int opt)
#ifdef _C_MINILOG_BUILTIN  
  {
    Close_Log();
    Create_Required_Dirs(logname);
    C_Log_Fd = Open_File_Raise(logname,O_CREAT|O_APPEND|O_WRONLY|O_TRUNC);
    C_Log_Opt = opt;
    C_Log_Level = opt & 0x0ff;
  }
#endif
  ;
  
void Set_Wirte_Log_Opt(int opt)
#ifdef _C_MINILOG_BUILTIN  
  {
    C_Log_Opt = opt;
    C_Log_Level = opt & 0x0ff;
  }
#endif
  ;

#define Log_Level(L) (C_Log_Level<L)

void Write_Log(int level, char *text)
#ifdef _C_MINILOG_BUILTIN  
  {
    if ( level <= C_Log_Level )
      __Xchg_Interlock
        {        
          int log_fd = C_Log_Fd >= 0 ? C_Log_Fd : fileno(stderr);
          char mark[80] = {0};
          int len = strlen(text);
          if ( C_Log_Opt & C_LOG_DATESTAMP )
            {
              clock_t t = clock();
              if ( t - C_Log_Clock > CLOCKS_PER_SEC )
                {
                  C_Log_Clock = t;
                  sprintf(mark, "%%clocks%% %.3f\n",(double)C_Log_Clock/CLOCKS_PER_SEC);
                  Write_Out(log_fd,mark,strlen(mark));
                }
            }
          if ( C_Log_Opt & (C_LOG_LEVEL) )
            {
              if ( level == C_LOG_ERROR )
                Write_Out(log_fd,"{error} ",8);
              else if ( level == C_LOG_WARN )
                Write_Out(log_fd,"{warn!} ",8);
              else if ( level == C_LOG_INFO )
                Write_Out(log_fd,"{info!} ",8);
              else
                Write_Out(log_fd,"{debug} ",8);
            }
          if ( C_Log_Opt & (C_LOG_DATEMARK|C_LOG_PID|C_LOG_LINENO) )
            {
              int i = 1;
              mark[0] = '[';
              if ( C_Log_Opt & C_LOG_LINENO )
                i += sprintf(mark+i,"%4d",C_Log_Line_No);
              if ( C_Log_Opt & C_LOG_PID ) 
                {
                  int C_Log_Pid = getpid();
                  if ( i > 1 ) mark[i++] = ':';
                  i += sprintf(mark+i,"%5d",C_Log_Pid);
                }
              if ( C_Log_Opt & C_LOG_DATEMARK ) 
                {
                  time_t t = time(0);
                  struct tm *tm = localtime(&t);
                  if ( i > 1 ) mark[i++] = ':';
                  i += sprintf(mark+i,"%02d%02d%02d/%02d:%02d",
                          tm->tm_mday,tm->tm_mon+1,(tm->tm_year+1900)%100,
                          tm->tm_hour,tm->tm_min);
                }
              mark[i++] = ']';
              mark[i++] = ' ';
              mark[i] = 0;  
              Write_Out(log_fd,mark,i);
            }
          ++C_Log_Line_No;
          Write_Out(log_fd,text,len);
          if ( !len || text[len-1] != '\n' )
            Write_Out(log_fd,"\n",1);
        }
  }
#endif
  ;
  
void Logf(int level, char *fmt, ...)
#ifdef _C_MINILOG_BUILTIN  
  {
    if ( level <= C_Log_Level )
      {
        va_list va;
        char *text;
        va_start(va,fmt);
        text = C_Format_(fmt,va);
        Write_Log(level,text);
        free(text);
        va_end(va);
      }
  }
#endif
  ;

#define Log_Debug if (C_Log_Level<C_LOG_DEBUG); else Log_Debug_
void Log_Debug_(char *fmt, ...)
#ifdef _C_MINILOG_BUILTIN  
  {
    va_list va;
    char *text;
    va_start(va,fmt);
    text = C_Format_(fmt,va);
    Write_Log(C_LOG_DEBUG,text);
    free(text);
    va_end(va);
  }
#endif
  ;


#define Log_Info if (C_Log_Level<C_LOG_INFO); else Log_Info_
void Log_Info_(char *fmt, ...)
#ifdef _C_MINILOG_BUILTIN  
  {
    va_list va;
    char *text;
    va_start(va,fmt);
    text = C_Format_(fmt,va);
    Write_Log(C_LOG_INFO,text);
    free(text);
    va_end(va);
  }
#endif
  ;

#define Log_Warning if (C_Log_Level<C_LOG_WARN); else Log_Warning_
void Log_Warning_(char *fmt, ...)
#ifdef _C_MINILOG_BUILTIN  
  {
    va_list va;
    char *text;
    va_start(va,fmt);
    text = C_Format_(fmt,va);
    Write_Log(C_LOG_WARN,text);
    free(text);
    va_end(va);
  }
#endif
  ;

void Log_Error(char *fmt, ...)
#ifdef _C_MINILOG_BUILTIN  
  {
    va_list va;
    char *text;
    va_start(va,fmt);
    text = C_Format_(fmt,va);
    Write_Log(C_LOG_ERROR,text);
    free(text);
    va_end(va);
  }
#endif
  ;

#endif /* C_once_9629B105_86D6_4BF5_BAA2_62AB1ACE54EC */

