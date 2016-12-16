
/*

Copyright © 2010-2016, Alexéy Sudachén, alexey@sudachen.name
http://libcplus.keepmywork.com/
See license rules in C+.hc

*/

#ifndef C_once_AF69CAD4_02C8_492E_9C13_B69483693E5F
#define C_once_AF69CAD4_02C8_492E_9C13_B69483693E5F

#ifdef _BUILTIN
#define _C_PROG_BUILTIN
#endif

#include "C+.hc"
#include "dicto.hc"
#include "array.hc"
#include "string.hc"
#include "minilog.hc"

#ifdef _C_PROG_BUILTIN
static void *Prog_Data_Opts = 0;
static void *Prog_Data_Args = 0;
static char *Prog_Dir_S = 0;
static char *Prog_Nam_S = 0;
static char *Prog_Arg_Nam_S = 0;
#endif

enum _C_ROG_FLAGS
{
	PROG_CMDLINE_OPTS_FIRST = 1,
    PROG_EXIT_ON_ERROR		= 2,
    PROG_RAISE_ON_ERROR		= 4,
	PROG_USAGE_ON_ERROR		= 8,
    PROG_USAGE_ON_NOARGS	= 16,
	PROG_USAGE_ON_HELP		= 32,
    PROG_PRINT_ON_ERROR		= 64,
    PROG_USAGE_ON_ANY		= PROG_USAGE_ON_ERROR|PROG_USAGE_ON_NOARGS|PROG_USAGE_ON_HELP,
    PROG_EXIT_ON_HELP		= 128,
    PROG_EXIT_ON_NOARGS		= 256,
    PROG_EXIT_ON_ANY		= PROG_EXIT_ON_ERROR|PROG_EXIT_ON_HELP|PROG_EXIT_ON_NOARGS,

    PROG_UTF8_COMMAND_LINE  = 512,
};

typedef enum _C_PROG_PARAM_FEATURES
{
	PROG_PARAM_HAS_NO_ARGUMENT,
	PROG_PARAM_HAS_ARGUMENT,
	PROG_PARAM_CAN_HAVE_ARGUMENT
} C_PROG_PARAM_FEATURES;

typedef struct _C_PROG_PARAM_INFO
{
	void *vals;
	int  *present;
	C_PROG_PARAM_FEATURES features;
} C_PROG_PARAM_INFO;

void Prog_Param_Info_Destruct(C_PROG_PARAM_INFO *o)
#ifdef _C_PROG_BUILTIN
{
	__Unrefe(o->vals);
	__Unrefe(o->present);
	__Destruct(o);
}
#endif
;

void *Prog_Param_Info(void)
#ifdef _C_PROG_BUILTIN
{
	return __Object_Dtor(sizeof(C_PROG_PARAM_INFO),Prog_Param_Info_Destruct);
}
#endif
;

void *Prog_Parse_Command_Line_Pattern(char *patt)
#ifdef _C_PROG_BUILTIN
{
	int i,j;
	void *dt = Dicto_Refs();
	C_ARRAY *L = Str_Split(patt,",; \t\n\r");

	for ( i = 0; i < L->count; ++i )
	{
		C_ARRAY *Q = Str_Split(L->at[i],"|");
		if ( Q->count )
		{
			int *present = __Object(sizeof(int),0);
			void *vals = 0;

			for ( j = 0; j < Q->count; ++j )
			{
				C_PROG_PARAM_INFO *nfo = Prog_Param_Info();
				char *S = Q->at[j];
				int S_Ln = strlen(S)-1;

				if ( S[S_Ln] == ':' )
				{ 
					nfo->features = PROG_PARAM_HAS_ARGUMENT; 
					S[S_Ln] = 0;
				}
				else if ( S[S_Ln] == '=' )
				{ 
					nfo->features = PROG_PARAM_CAN_HAVE_ARGUMENT; 
					S[S_Ln] = 0; 
				}
				else
					nfo->features = PROG_PARAM_HAS_NO_ARGUMENT;

				if ( nfo->features != PROG_PARAM_HAS_NO_ARGUMENT )
				{
					if ( !vals )
						vals = Array_Ptrs();
					nfo->vals = __Refe(vals);
				}

				nfo->present = __Refe(present);  
				Dicto_Put(dt,S,__Refe(nfo));
			}
		}
	}

	return dt;
}
#endif
;

void Prog_Parse_Command_Line(int argc, char **argv, char *patt, unsigned flags)
#ifdef _C_PROG_BUILTIN
{
	int i;
	void *args = Array_Void();
	void *opts = Prog_Parse_Command_Line_Pattern(patt);

	int argument_passed = 0;
	for ( i = 1; i < argc; ++i )
	{
		if ( (*argv[i] == '-' && argv[i][1] && (argv[i][1] != '-' || argv[i][2]))
			&& (!(flags&PROG_CMDLINE_OPTS_FIRST)||!argument_passed) )
		{
			C_ARRAY *L;
			C_PROG_PARAM_INFO *a;
			char *Q = argv[i]+1;

			if ( *Q == '-' ) ++Q;
			if ( !*Q ) continue;

			L = Str_Split_Once(Q,"=");
			if ( 0 != (a = Dicto_Get(opts,L->at[0],0)) )
			{
				if ( a->features == PROG_PARAM_HAS_ARGUMENT && L->count == 1 )
				{
					if ( argc > i+1 )
					{
#ifdef __windoze
                        if ( !(flags & PROG_UTF8_COMMAND_LINE) )
                            Array_Push(L,Str_Locale_To_Utf8_Npl(argv[i+1]));
                        else
#endif
                            Array_Push(L,Str_Copy_Npl(argv[i+1],-1));
						++i;
					}
					else
						__Raise_Format(C_ERROR_ILLFORMED,
                        ("commandline option -%s requires parameter"
						,(L->at)[0]));
				}

				if ( a->features == PROG_PARAM_HAS_NO_ARGUMENT && L->count > 1 )
					__Raise_Format(C_ERROR_ILLFORMED,
                    ("commandline option -%s does not have parameter"
					,(L->at)[0]));
				*a->present = 1;
				if ( L->count > 1 )
					Array_Push(a->vals,Array_Take_Npl(L,1));
			}
			else
				__Raise_Format(C_ERROR_ILLFORMED,
                ("unknown commandline option -%s",(L->at)[0]));
		}
		else
		{
			argument_passed = 1;
			Array_Push(args,argv[i]);
		}
	}

	Prog_Data_Opts = __Refe(opts);
	Prog_Data_Args = __Refe(args);
}
#endif
;

void Prog_Clear_At_Exit(void)
#ifdef _C_PROG_BUILTIN
{
	Close_Log();
	__Unrefe(Prog_Data_Opts);
	__Unrefe(Prog_Data_Args);
	C_Thread_Cleanup();
	C_Global_Cleanup();
	free(Prog_Dir_S);
	free(Prog_Nam_S);
	free(Prog_Arg_Nam_S);
}
#endif
;

int Prog_Init(int argc, char **argv, char *patt, unsigned flags, ...)
#ifdef _C_PROG_BUILTIN
{
    typedef int (*usage_f)(int,...);
	int rt = 0;
	usage_f usage;
	va_list va;
	
	va_start(va,flags);
	usage = va_arg(va,usage_f);
	va_end(va);

	__Try_Ptr(0)
	{
		setlocale(LC_NUMERIC,"C");
		setlocale(LC_TIME,"C");
#ifdef __windoze
		__Gogo
		{
			int L = 256;
			wchar_t *buf = __Malloc((256+1)*sizeof(wchar_t));
			GetModuleFileNameW(0,buf,L);
			Prog_Nam_S = Str_Unicode_To_Utf8_Npl(buf);
		}
#else
		Prog_Nam_S = __Retain(Path_Fullname(argv[0]));
#endif
        Prog_Arg_Nam_S = __Retain(Path_Basename(argv[0]));
		Prog_Dir_S = __Retain(Path_Dirname(Prog_Nam_S));
		REQUIRE(Prog_Dir_S != 0);
		rt = 1;
		atexit(Prog_Clear_At_Exit);

        Prog_Parse_Command_Line(argc,argv,patt,flags);

        if ( (flags & PROG_USAGE_ON_NOARGS) && !Prog_Arguments_Count() )
		{
			rt = usage(PROG_USAGE_ON_NOARGS);
            if ( flags & PROG_EXIT_ON_NOARGS )
              exit(rt);
		}
        else if ( (flags & PROG_USAGE_ON_HELP) && Prog_Has_Opt("help") )
		{
			rt = usage(PROG_USAGE_ON_HELP);
            if ( flags & PROG_EXIT_ON_HELP )
              exit(rt);
        }
	}
	__Except
	{
        if ( flags & PROG_PRINT_ON_ERROR )
        {
			fprintf(stderr,"\n(!) %s\n\n",__Error_Message);
        }

        if ( flags & PROG_USAGE_ON_ERROR )
        {
            rt = usage(PROG_USAGE_ON_ERROR,__Error_Message);
            if ( rt != 0 && (flags & PROG_EXIT_ON_ERROR) )
              exit(rt);
        }
        else if ( flags & PROG_EXIT_ON_ERROR )
        {
              exit(-1);
        }
        else
		{
			if ( !Prog_Data_Opts )
				Prog_Data_Opts = __Refe(Dicto_Refs());
			if ( !Prog_Data_Args )
				Prog_Data_Args = __Refe(Array_Void());

			if ( flags & PROG_RAISE_ON_ERROR )
				__Raise_Occured();
		}
	}

	return rt;
}
#endif
;

C_ARRAY *Prog_Argc_Argv(char *input)
#ifdef _C_PROG_BUILTIN
{
	C_ARRAY *argv = Array_Pchars();

	__Auto_Release
	{
		int   argc;
		char *arg;
		char *copybuf;
		int   dquote = 0;
		int   lquote = 0;

		if ( input )
		{
			copybuf = __Malloc(strlen(input) + 1);
			for ( ; *input ; )
			{
				while ( ' ' == *input || '\t' == *input ) ++input;

				arg = copybuf;
				while ( *input )
				{
					if ( (*input == ' ' || *input == '\t' ) && !dquote && !lquote )
						break;
					else
					{
						if (0) ;
						else if (dquote)
						{
							if (*input == '"') 
							{
								if ( input[1] == '"' )
									*arg++ = *input++;
								dquote = 0;
							}
							else *arg++ = *input;
						}
						else if (lquote)
						{
							if (*input == '>') lquote = 0;
							*arg++ = *input;
						}
						else // !dquote && !lquote
						{
							if (0) ;
							else if (*input == '"') dquote = 1;
							else 
							{
								if (*input == '<') lquote = 1;
								*arg++ = *input;
							}
						}
						input++;
					}
				}
				*arg = 0;

				Array_Push(argv,Str_Copy_Npl(copybuf,-1));

				while ( *input && (' ' == *input || '\t' == *input) ) ++input;
			}
		}

		argc = argv->count;
		Array_Push(argv,0);
		argv->count = argc;
	}

	return argv;
}
#endif
;

#ifdef __windoze
int Prog_Init_Windoze(char *patt, unsigned flags)
#ifdef _C_PROG_BUILTIN
{
	int rt;

	__Auto_Release
	{
		C_ARRAY *argv = Prog_Argc_Argv(Str_Unicode_To_Utf8(GetCommandLineW()));
		rt = Prog_Init(argv->count,(char**)argv->at,patt,flags);
	}

	return rt;
}
#endif
;
#endif

#ifdef __windoze
int Prog_Init_Unicode(int argc, wchar_t **wargv, char *patt, unsigned flags, ...)
#ifdef _C_PROG_BUILTIN
{
    int rt = 0, i;
    typedef void (*usage_f)();
    usage_f usage;

    va_list va;
    va_start(va,flags);
    usage = va_arg(va,usage_f);
    va_end(va);

    __Auto_Release
    {
        C_ARRAY *argv = Array_Pchars();
        for ( i = 0; i < argc; ++i )
        {
            Array_Push(argv,Str_Unicode_To_Utf8_Npl(wargv[i]));
        }
        rt = Prog_Init(argc,(char**)argv->at,patt,flags|PROG_UTF8_COMMAND_LINE,usage);
    }

    return rt;
}
#endif
;
#endif


int Prog_Arguments_Count()
#ifdef _C_PROG_BUILTIN
{
	return Array_Count(Prog_Data_Args);
}
#endif
;

char *Prog_Argument(int no)
#ifdef _C_PROG_BUILTIN
{
	return Array_At(Prog_Data_Args,no);
}
#endif
;

char *Prog_Argument_Dflt(int no,char *dflt)
#ifdef _C_PROG_BUILTIN
{
	if ( no < 0 || no >= Array_Count(Prog_Data_Args) )
		return dflt;
	return Array_At(Prog_Data_Args,no);
}
#endif
;

int Prog_Argument_Int(int no)
#ifdef _C_PROG_BUILTIN
{
	char *S = Array_At(Prog_Data_Args,no);
	return strtol(S,0,10);
}
#endif
;

int Prog_Has_Opt(char *name)
#ifdef _C_PROG_BUILTIN
{
	C_PROG_PARAM_INFO *i = Dicto_Get(Prog_Data_Opts,name,0);
	return i && *i->present;    
}
#endif
;

int Prog_Opt_Count(char *name)
#ifdef _C_PROG_BUILTIN
{
	C_PROG_PARAM_INFO *i = Dicto_Get(Prog_Data_Opts,name,0);
	if ( i && *i->present && i->vals )
		return Array_Count(i->vals);
	return 0;
}
#endif
;

char *Prog_Opt(char *name,int no)
#ifdef _C_PROG_BUILTIN
{
	C_PROG_PARAM_INFO *i = Dicto_Get(Prog_Data_Opts,name,0);
	if ( !i || !*i->present || !i->vals )
		return 0;
	return Array_At(i->vals,no);
}
#endif
;

char *Prog_First_Opt(char *name,char *dflt)
#ifdef _C_PROG_BUILTIN
{
	C_PROG_PARAM_INFO *i = Dicto_Get(Prog_Data_Opts,name,0);
	if ( !i || !*i->present || !i->vals || !Array_Count(i->vals) )
		return dflt;
	return Array_At(i->vals,0);
}
#endif
;

int Prog_First_Opt_Int(char *name,int dflt)
#ifdef _C_PROG_BUILTIN
{
	char *Q = Prog_First_Opt(name,0);
	if ( !Q ) return dflt;
	return strtol(Q,0,10);
}
#endif
;

char *Prog_Last_Opt(char *name,char *dflt)
#ifdef _C_PROG_BUILTIN
{
	C_PROG_PARAM_INFO *i = Dicto_Get(Prog_Data_Opts,name,0);
	if ( !i || !*i->present || !i->vals || !Array_Count(i->vals) )
		return dflt;
	return Array_At(i->vals,-1);
}
#endif
;

int Prog_Last_Opt_Int(char *name,int dflt)
#ifdef _C_PROG_BUILTIN
{
	char *Q = Prog_Last_Opt(name,0);
	if ( !Q ) return dflt;
	return strtol(Q,0,10);
}
#endif
;

char *Prog_Directory()
#ifdef _C_PROG_BUILTIN
{
	return Prog_Dir_S;
}
#endif
;

char *Prog_Fullname()
#ifdef _C_PROG_BUILTIN
{
	return Prog_Nam_S;
}
#endif
;

char *Prog_Name()
#ifdef _C_PROG_BUILTIN
{
    return Prog_Arg_Nam_S;
}
#endif
;

void Prog_Print(const char* text)
#ifdef _C_PROG_BUILTIN
{
    fputs(text,stdout);
}
#endif
;

#endif /* C_once_AF69CAD4_02C8_492E_9C13_B69483693E5F */

