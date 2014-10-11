
#ifndef C_once_BDA476DC_6F02_4328_94DC_B0520BF3FD4E
#define C_once_BDA476DC_6F02_4328_94DC_B0520BF3FD4E

#include <stdint.h>

#if ( defined _DLL && !defined LIBSYNFO_STATIC ) || defined LIBSYNFO_DLL || defined LIBSYNFO_BUILD_DLL
#  if defined LIBSYNFO_BUILD_DLL
#    define LIBSYNFO_EXPORTABLE __declspec(dllexport)
#  else
#    define LIBSYNFO_EXPORTABLE __declspec(dllimport)
#  endif
#else
#define LIBSYNFO_EXPORTABLE
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct SYNFO_CPU
{
	char        id[16 + 1];
	char        tag[64 + 1];
	uint8_t     family;
	uint8_t     model;
	uint8_t     stepping;
	uint8_t     revision;
	uint8_t     number;
	uint8_t     has_MMX;
	uint8_t     has_MMX2;
	uint8_t     has_SSE;
	uint8_t     has_SSE2;
	uint8_t     has_SSE3;
	uint8_t     has_SSSE3;
	uint8_t     has_HTT;
} SYNFO_CPU;

typedef enum SYNFO_ERROR
{
    SYNFO_SUCESS = 0,
    SYNFO_ERROR_INTERNAL = -999,
} SYNFO_ERROR;

enum { SYNFO_OS_STRING_LENGTH = 256, SYNFO_CPU_STRING_LENGTH = 256 };

LIBSYNFO_EXPORTABLE SYNFO_ERROR Synfo_Get_Cpu(SYNFO_CPU* nfo);
LIBSYNFO_EXPORTABLE SYNFO_ERROR Synfo_Get_Cpu_String(char outbuf[SYNFO_CPU_STRING_LENGTH]);
LIBSYNFO_EXPORTABLE SYNFO_ERROR Synfo_Get_Os_String(char outbuf[SYNFO_OS_STRING_LENGTH]);

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* C_once_BDA476DC_6F02_4328_94DC_B0520BF3FD4E */

