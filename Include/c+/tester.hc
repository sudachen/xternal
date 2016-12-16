/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_BD92B6D2_8BD6_43FB_A8FE_4CD6143CF68D
#define C_once_BD92B6D2_8BD6_43FB_A8FE_4CD6143CF68D

#include "string.hc"

#ifdef _BUILTIN
#define _C_TESTER_BUILTIN
#endif

typedef struct C_TEST_GROUP_INFO C_TEST_GROUP_INFO;
struct C_TEST_GROUP_INFO
{
	int passed;
	int failed;
	double time_avg;
	double time_min;
	double time_max;
	clock_t clock0;
};

#ifndef _C_TESTER_BUILTIN
extern
#endif
C_TEST_GROUP_INFO g_test_group;

#define Do_Test_Group(Info) \
switch(0) while (1) \
	if (1) { \
		fprintf(stderr,"  \x1b[30;1m" \
		               "passed:%-2d failed:%-2d time:%-6.3f" \
		               " avg:%-6.3f min:%-6.3f max:%-6.3f" \
		               "\x1b[0m\n",\
		               g_test_group.passed,\
		               g_test_group.failed,\
		               (double)(clock()-g_test_group.clock0)/CLOCKS_PER_SEC,\
		               g_test_group.time_avg,\
		               g_test_group.time_min,\
		               g_test_group.time_max);\
		break; \
	case 0: \
		memset(&g_test_group,0,sizeof(g_test_group)); \
		g_test_group.clock0 = clock(); \
		g_test_group.time_min = (double)-1;\
		g_test_group.time_max = (double)-1;\
		fputs("--- ",stderr); \
		fputs(Info,stderr); \
		fputs(" ---\n",stderr); \
		goto C_LOCAL_ID(testbody); \
	} \
	else C_LOCAL_ID(testbody):

#define Do_Test_Case(Info) \
switch ( setjmp(C_Push_JmpBuf()->b) ) while (1) \
	if (1) { \
		clock_t c0; \
		int nfo_len; \
		double c1 = (double)(clock()-c0)/CLOCKS_PER_SEC; \
		while ( nfo_len-- ) putc('\b',stderr); \
		fprintf(stderr,"  \x1b[32;1m[OK]\x1b[0m %6.3f ",c1); \
		fputs("\n",stderr); \
		C_Cleanup_JmpBuf(0); \
		g_test_group.time_avg = (g_test_group.time_avg * g_test_group.passed  + c1)/(g_test_group.passed+1); \
		++g_test_group.passed; \
		if ( g_test_group.time_max == (double)-1 || g_test_group.time_max < c1 ) \
			g_test_group.time_max = c1; \
		if ( g_test_group.time_min == (double)-1 || g_test_group.time_min > c1 ) \
			g_test_group.time_min = c1; \
		break; \
	default: \
		while ( nfo_len-- ) putc('\b',stderr); \
		fputs("  \x1b[35;1m[--]\x1b[0m ",stderr); \
		fputs("\n",stderr); \
		++g_test_group.failed; \
		break; \
    case 0: \
		{ \
			char *q = Str_Left_Part(Str_Replace(Info,"\n","\\n"),60); \
			nfo_len = strlen(q) + 7 + 7; \
			fputs("  >>> _______ ",stderr); \
			fputs(q,stderr); \
			c0 = clock(); \
		} \
		goto C_LOCAL_ID(testbody); \
	} \
	else C_LOCAL_ID(testbody): 

#define __Test_Assert( Expr, Text, ... ) if (!Expr) __Raise(C_ERROR_TESUITE_FAIL,Text);
#define __Test_STR(Expr)    #Expr

#define $B(Ptr,Len) 0

#define Test_True(Expr)   __Test_Assert( (Expr) != 0, __Test_STR((Expr) != 0), $4(!!(Expr)) )
#define Test_False(Expr)  __Test_Assert( (Expr) == 0, __Test_STR((Expr) == 0), $4(!!(Expr)) )
#define Test_Str_Equal(S1,S2) __Test_Assert( (strcmp((S1),(S2)) == 0), __Test_STR((strcmp((S1),(S2)) == 0)), $S(S1), $S(S2) )
#define Test_Int_Equal(I1,I2) __Test_Assert( ((I1) == (I2)), __Test_STR((I1) == (I2)), $4(I1), $4(I2) )
#define Test_Mem_Equal(S1,S2,L) __Test_Assert( (memcmp((S1),(S2),L) == 0), __Test_STR((memcmp((S1),(S2),L) == 0)), $B(S1,L), $B(S2,L) ) 

#define Test_Info(S) 

#endif /* C_once_BD92B6D2_8BD6_43FB_A8FE_4CD6143CF68D */
