
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_B6590472_37D1_4589_84F6_BFC339C3E407
#define C_once_B6590472_37D1_4589_84F6_BFC339C3E407

#ifdef _BUILTIN
#define _C_UNAME_BUILTIN
#endif

#include "../C+.hc"
#include "../string.hc"

typedef struct _C_CPUINFO
  {
    char id[16];
    char tag[64];
    unsigned family;
    unsigned model;
    unsigned stepping;
    unsigned revision;
    unsigned number;
    unsigned L2k;
    unsigned FPU:1;
    unsigned MMX:1;
    unsigned MMX2:1;
    unsigned SSE:1;
    unsigned SSE2:1;
    unsigned SSE3:1;
    unsigned SSSE3:1;
    unsigned HTT:1;
    unsigned EST:1;
    unsigned PAE:1;
    unsigned X64:1;
    unsigned CX8:1;
    unsigned MSR:1;
    unsigned AES:1;
    unsigned RDRND:1;
    
  } C_CPUINFO;

int cpuid(unsigned id, uint_t *rgs);

#ifdef _C_UNAME_BUILTIN
  #if defined __GNUC__ && (defined __i386 || defined __x86_64)
    int cpuid(unsigned id, uint_t *rgs)
      {
        rgs[0] = id;
        asm volatile(
            "mov %%ebx, %%edi;"
            "cpuid;"
            "mov %%ebx, %%esi;"
            "mov %%edi, %%ebx;"
            :"+a" (rgs[0]), "=S" (rgs[1]), "=c" (rgs[2]), "=d" (rgs[3])
            : :"edi");
        return 1;
      }
  #elif defined _MSC_VER
    #if _MSC_VER <= 1400 // VS 2003
      int cpuid(unsigned id, uint_t *rgs)
        {
          __asm mov eax, id
          __asm push esi
          __asm push ebx
          __asm push ecx
          __asm push edx
          __asm _emit 0x0f
          __asm _emit 0xa2
          __asm mov esi,rgs
          __asm mov [esi],eax
          __asm mov [esi+4],ebx
          __asm mov [esi+8],ecx
          __asm mov [esi+12],edx
          __asm pop edx
          __asm pop ecx
          __asm pop ebx
          __asm pop esi
          return 1;
        }
    #else // VS2005 and later
      #include <intrin.h>
      #define cpuid(Id,Rgs) (__cpuid(Rgs,Id), 1)
      /*int cpuid(unsigned id, uint_t *rgs)
        {
          typedef int int4[4];
          __cpuid((int*)rgs,id);
          return 1;
        }*/
    #endif 
  #else
    int cpuid(unsigned id, uint_t *rgs) { return 0; }
  #endif
#endif /* _C_UNAME_BUILTIN */

int Get_Cpu_Info(C_CPUINFO *cpui)
#ifdef _C_UNAME_BUILTIN
  {
    int i;
    uint_t r[4];
    memset(cpui,0,sizeof(*cpui));

    if ( !cpuid(0,r) ) return 0;
    
    *(unsigned*)(cpui->id+0) = r[1];
    *(unsigned*)(cpui->id+4) = r[3];
    *(unsigned*)(cpui->id+8) = r[2];

    cpuid(1,r);
    cpui->family = (r[0]>>8)&0x0f;
    cpui->model  = (r[0]>>4)&0x0f;
    cpui->stepping  = r[0]&0x0f;
    //if ( 2 == (r[0] & 0x3000) >> 12 ) cpui->dual = 1;
    cpui->number = (r[1] >> 16) &0xff;

    if ( r[3] & C32_BIT(0) )  cpui->FPU = 1;
    if ( r[3] & C32_BIT(23) ) cpui->MMX = 1;
    if ( r[3] & C32_BIT(24) ) cpui->MMX2 = 1;
    if ( r[3] & C32_BIT(25) ) cpui->SSE = 1;
    if ( r[3] & C32_BIT(26) ) cpui->SSE2 = 1;
    if ( r[3] & C32_BIT(28) ) cpui->HTT = 1;
    if ( r[3] & C32_BIT(29) ) cpui->X64 = 1;
    if ( r[3] & C32_BIT(8) )  cpui->CX8 = 1;
    if ( r[3] & C32_BIT(7) )  cpui->MSR = 1;

    if ( r[2] & C32_BIT(7) )  cpui->EST = 1;
    if ( r[2] & C32_BIT(6) )  cpui->PAE = 1;
    if ( r[2] & C32_BIT(0) )  cpui->SSE3 = 1;
    if ( r[2] & C32_BIT(9) )  cpui->SSSE3 = 1;
    if ( r[2] & C32_BIT(25) ) cpui->AES = 1;
    if ( r[2] & C32_BIT(30) ) cpui->RDRND = 1;

    cpuid(0x80000002,(void*)cpui->tag);
    cpuid(0x80000003,(void*)(cpui->tag+16));
    cpuid(0x80000004,(void*)(cpui->tag+32));
    
    cpuid(0x80000006,r);
    cpui->L2k = r[2] >> 16;
    
    for ( i = 1; i < 64 && cpui->tag[i] ; ) {
      if ( cpui->tag[i] == cpui->tag[i-1] && cpui->tag[i] == ' ')
        memmove(cpui->tag+i-1,cpui->tag+i,64-i);
      else ++i;
    }
    
    return 1;
  }
#endif
  ;
  
char *Format_Cpu_Info(C_CPUINFO *cpui)
#ifdef _C_UNAME_BUILTIN
  {
    char *ret = 0;
    C_CPUINFO _cpui;
    
    if ( !cpui )
      {
        cpui = &_cpui;
        if ( !Get_Cpu_Info(cpui) )
          return Str_Copy("unknown");
      }
    
    __Auto_Ptr(ret)
      {
        int i = 0;
        char *Q[32] = {0};
        
        if (0);
        else if ( cpui->SSSE3 ) Q[i++] = "ssse3";
        else if ( cpui->SSE3 )  Q[i++] = "sse3";
        else if ( cpui->SSE2 )  Q[i++] = "sse2";
        else if ( cpui->SSE )   Q[i++] = "sse";
        else if ( cpui->MMX2 )  Q[i++] = "mmx2";
        else if ( cpui->MMX )   Q[i++] = "mmx";
        else if ( cpui->FPU )   Q[i++] = "fpu";
        
        if ( cpui->HTT )   Q[i++] = "htt";
        if ( cpui->EST )   Q[i++] = "est";
        if ( cpui->PAE )   Q[i++] = "pae";
        if ( cpui->X64 )   Q[i++] = "x64";
        if ( cpui->AES )   Q[i++] = "aes";
        if ( cpui->MSR )   Q[i++] = "msr";
        if ( cpui->RDRND ) Q[i++] = "rdrnd";

        ret = __Format("%s /%d {%s} L2/%dk",
          (cpui->tag[0]?cpui->tag:cpui->id),
          cpui->number,Str_Join_Q(' ',Q),cpui->L2k);
      }
      
    return ret;
  }
#endif
  ;
  
char *Get_OS_Target()
#ifdef _C_UNAME_BUILTIN
  {
  #ifdef __windoze 
    return "windows";
  #elif defined __APPLE__
    return "darwin";
  #elif defined __linux__
    return "linux";
  #elif defined __NetBSD__
    return "netbsd";
  #elif defined __FreeBSD__
    return "freebsd";
  #elif defined __unix__ 
    return "unix";
  #else
    return "unknown";
  #endif
  }
#endif
  ;
  
char *Get_OS_Name()
#ifdef _C_UNAME_BUILTIN
  {
  #ifdef __windoze
    char *osname = 0;
    __Auto_Ptr(osname)
      {
        unsigned Maj,Min;
        OSVERSIONINFOEX osinfo;
        osinfo.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
        GetVersionEx((OSVERSIONINFO*)&osinfo);
        Maj = osinfo.dwMajorVersion, Min = osinfo.dwMinorVersion;
        if ( Maj == 5 && Min == 0 ) osname = "Windows 2000";
        else if ( Maj == 5 && Min == 1 ) osname = "Windows XP";
        else if ( Maj == 5 && Min == 2 ) osname = "Windows Server 2003";
        else if ( Maj == 6 && Min == 0 )
          if ( osinfo.wProductType == VER_NT_WORKSTATION ) osname = "Windows Vista";
          else osname = "Windows Server 2008";
        else if ( Maj == 6 && Min == 1 )
          if ( osinfo.wProductType == VER_NT_WORKSTATION ) osname = "Windows 7";
          else osname = "Windows Server 2008 R2";
        else
          osname = __Format("Unknown Windows %d.%d",Maj,Min);
        osname = __Format("%s build %d",osname,osinfo.dwBuildNumber);
        if ( osinfo.szCSDVersion[0] )
          osname = __Format("%s (%s)",osname,osinfo.szCSDVersion);
      }
    return osname;
  #else
    return "";
  #endif
  }
#endif
  ;
  
#endif /* C_once_B6590472_37D1_4589_84F6_BFC339C3E407 */
