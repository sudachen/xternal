
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#include "../file.hc"

#ifdef __windoze
	typedef HANDLE process_t;
#else
	typedef int process_t;
#endif

#ifdef _BUILTIN
#	define _C_PIPEX_BUILTIN
#endif

#ifdef _C_PIPEX_BUILTIN
#	define C_PIPEX_EXTERN
#else
#	define C_PIPEX_EXTERN extern
#endif

#define INVALID_PROCESS_ID ((process_t)0)
enum { PIPEX_STILL_ACTIVE = -1, PIPEX_WAS_TERMINATED = -2 };

typedef struct _C_PIPEX
{
	char *command;
	C_FILE *fin;
	C_FILE *fout;
	C_FILE *ferr;
	process_t pid;
	int exitcode;
} C_PIPEX;

#ifdef __windoze

typedef struct _C_PIPEX_WINPIPE
{
	HANDLE pin;
	HANDLE pout;
	HANDLE xhndl;
}C_PIPEX_WINPIPE;

void C_PIPEX_WINPIPE_Destruct(C_PIPEX_WINPIPE *wp)
#ifdef _C_PIPEX_BUILTIN
{
	if ( wp->pin && wp->pin != INVALID_HANDLE_VALUE )
		CloseHandle(wp->pin);
	if ( wp->pout && wp->pout != INVALID_HANDLE_VALUE )
		CloseHandle(wp->pout);
	if ( wp->xhndl && wp->xhndl != INVALID_HANDLE_VALUE )
		CloseHandle(wp->xhndl);
	__Destruct(wp);
}
#endif
;

#endif

C_PIPEX_EXTERN char *PIPEX_NONE
#ifdef _C_PIPEX_BUILTIN
	= (char*)-1
#endif
	;

C_PIPEX_EXTERN char *PIPEX_WRAP
#ifdef _C_PIPEX_BUILTIN
	= (char*)0
#endif
	;

C_PIPEX_EXTERN char *PIPEX_TMPFILE
#ifdef _C_PIPEX_BUILTIN
	= (char*)-2
#endif
	;

#define PIPEX_TMPFILE(X) PIPEX_TMPFILE_GEN(X)
char *PIPEX_TMPFILE_GEN(char *fname)
#ifdef _C_PIPEX_BUILTIN
{
	return Str_Concat("~*",fname);
}
#endif
;

void Pipex_Kill(C_PIPEX *pipex)
#ifdef _C_PIPEX_BUILTIN
{
	if ( pipex->pid != INVALID_PROCESS_ID )
	{
		pipex->exitcode = PIPEX_WAS_TERMINATED;
		TerminateProcess(pipex->pid,255);
		CloseHandle(pipex->pid);
		pipex->pid = INVALID_PROCESS_ID;
	}
	__Unrefe(pipex->fin);
	__Unrefe(pipex->fout);
	__Unrefe(pipex->ferr);
}
#endif
;

void C_PIPEX_Destruct(C_PIPEX *pipex)
#ifdef _C_PIPEX_BUILTIN
{
	Pipex_Kill(pipex);
	__Destruct(pipex);
}
#endif
;

void Pipex_Init_Pipe(C_PIPEX_WINPIPE **x, char *xstd, HANDLE *ystd, int wr)
#ifdef _C_PIPEX_BUILTIN
{
	SECURITY_ATTRIBUTES saa = {0};
	saa.nLength = sizeof(SECURITY_ATTRIBUTES);
	*x = __Object_Dtor(sizeof(C_PIPEX_WINPIPE),C_PIPEX_WINPIPE_Destruct);
	if ( xstd == PIPEX_WRAP )
	{
		if ( !CreatePipe(&(*x)->pin, &(*x)->pout, &saa, 0))
			__Raise_System_Error();
		*ystd = !wr ? (*x)->pin : (*x)->pout;
	}
	else if ( xstd == PIPEX_NONE )
		;
	else
	{
		int flags = 0;
		HANDLE *xhndl = &(*x)->xhndl;

		if ( xstd == PIPEX_TMPFILE )
		{
			xstd = Str_Unicode_To_Utf8(_wtempnam(0,L"~pipex."));
			xhndl = &(*x)->pin;
			flags |= FILE_FLAG_DELETE_ON_CLOSE;
		} 
		else if ( Str_Starts_With(xstd,"~*") )
		{
			xstd = Str_Unicode_To_Utf8(_wtempnam(0,Str_Utf8_To_Unicode(xstd+2)));
			xhndl = &(*x)->pin;
			flags |= FILE_FLAG_DELETE_ON_CLOSE;
		}
		else if ( Str_Starts_With(xstd,"~") )
		{
			xhndl = &(*x)->pin;
			flags |= FILE_FLAG_DELETE_ON_CLOSE;
		}

		*xhndl = *ystd = CreateFileW(Str_Utf8_To_Unicode(xstd),
			(wr?GENERIC_WRITE:0)|GENERIC_READ,
			(wr?FILE_SHARE_WRITE:0)|FILE_SHARE_READ,0,
			(wr?CREATE_ALWAYS:OPEN_EXISTING),
			flags,0
			);

		if ( *ystd == INVALID_HANDLE_VALUE )
			__Raise_System_Error();
	}
}
#endif
;

C_FILE *Pipex_Cfile(C_PIPEX_WINPIPE *wp, int wr)
#ifdef _C_PIPEX_BUILTIN
{
	if ( !(!wr?wp->pin:wp->pout) )
		return 0;
	else
	{
		void *ret;
		int foo = _open_osfhandle(__Ptr_Word(!wr?wp->pin:wp->pout), (!wr?(_O_RDONLY|_O_BINARY):(_O_WRONLY|_O_BINARY)) );
		FILE *f = _fdopen(foo,!wr?"rb":"wb");
		ret = Cfile_Object(f,"pipex",0);
		if ( !wr )  wp->pin = 0; else wp->pout = 0;
		return ret;
	}
}
#endif
;

C_PIPEX *Pipex_Exec(char *command, char *xstdin, char *xstdout, char *xstderr, char **env)
#ifdef _C_PIPEX_BUILTIN
{
	C_PIPEX *pipex = 0;
	__Auto_Ptr(pipex)
	{
		int foo;
		PROCESS_INFORMATION piProcInfo = {0};
		STARTUPINFOW siStartInfo = {0};
		STARTUPINFOW siStartInfo1 = {0};

		C_PIPEX_WINPIPE *xin = 0, *xout = 0, *xerr = 0;
		wchar_t *comspec = __Zero_Malloc(257*sizeof(wchar_t));

		pipex = __Object_Dtor(sizeof(C_PIPEX),C_PIPEX_Destruct);

		siStartInfo1.cb = sizeof(STARTUPINFOW);
		siStartInfo1.dwFlags    = STARTF_USESTDHANDLES;
		GetStartupInfoW(&siStartInfo1);
		siStartInfo.hStdInput  = siStartInfo1.hStdInput;
		siStartInfo.hStdOutput = siStartInfo1.hStdOutput;
		siStartInfo.hStdError  = siStartInfo1.hStdError;

		Pipex_Init_Pipe(&xin,  xstdin,  &siStartInfo.hStdInput,  0);
		Pipex_Init_Pipe(&xout, xstdout, &siStartInfo.hStdOutput, 1);
		Pipex_Init_Pipe(&xerr, xstderr, &siStartInfo.hStdError,  1);

		siStartInfo.cb = sizeof(STARTUPINFOW);
		siStartInfo.dwFlags    = STARTF_USESTDHANDLES;
		siStartInfo.wShowWindow = SW_HIDE;

		if ( !siStartInfo.hStdInput )  siStartInfo.hStdInput  = GetStdHandle(STD_INPUT_HANDLE);
		if ( !siStartInfo.hStdOutput ) siStartInfo.hStdOutput = GetStdHandle(STD_OUTPUT_HANDLE);
		if ( !siStartInfo.hStdError )  siStartInfo.hStdError  = GetStdHandle(STD_ERROR_HANDLE);

		SetHandleInformation(siStartInfo.hStdInput, HANDLE_FLAG_INHERIT,HANDLE_FLAG_INHERIT);
		SetHandleInformation(siStartInfo.hStdOutput,HANDLE_FLAG_INHERIT,HANDLE_FLAG_INHERIT);
		SetHandleInformation(siStartInfo.hStdError, HANDLE_FLAG_INHERIT,HANDLE_FLAG_INHERIT);

		GetEnvironmentVariableW(L"COMSPEC", comspec, 256);

		if ( env )
			while ( *env )
			{
				wchar_t *q = Str_Utf8_To_Unicode(*env++);
				wchar_t *p = wcschr(q,'=');
				*p++ = 0;
				SetEnvironmentVariableW(q,p);
			}

			if (!CreateProcessW(NULL,
				Str_Utf8_To_Unicode(__Format("\"%s\" /c %s",Str_Unicode_To_Utf8(comspec),command)),
				NULL,
				NULL,
				TRUE,
				0,//CREATE_NO_WINDOW,
				NULL,
				NULL,
				&siStartInfo,
				&piProcInfo))
			{
				__Raise_System_Error();
			}

			CloseHandle(piProcInfo.hThread);
			pipex->pid = piProcInfo.hProcess;

			pipex->fin  = __Refe(Pipex_Cfile(xin, 1));
			pipex->fout = __Refe(Pipex_Cfile(xout,0));
			pipex->ferr = __Refe(Pipex_Cfile(xerr,0));

	}      

	return pipex;
}
#endif
;

int Pipex_Exit_Code(C_PIPEX *pipex)
#ifdef _C_PIPEX_BUILTIN
{
	unsigned long ecode;
	if ( pipex->pid != INVALID_PROCESS_ID )
		if ( GetExitCodeProcess(pipex->pid,&ecode) )
			if ( ecode == STILL_ACTIVE )
				return PIPEX_STILL_ACTIVE;
			else
				pipex->exitcode = ecode;
	return pipex->exitcode;
}
#endif
;

int Pipex_Wait(C_PIPEX *pipex, int ms)
#ifdef _C_PIPEX_BUILTIN
{
	while ( Pipex_Exit_Code(pipex) == PIPEX_STILL_ACTIVE )
	{  
		if ( WaitForSingleObject(pipex->pid,ms) == WAIT_TIMEOUT ) 
			return PIPEX_STILL_ACTIVE;
	}
	return pipex->exitcode;
}
#endif
;

