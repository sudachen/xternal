
@echo off
setlocal ENABLEDELAYEDEXPANSION
set args=
set CLX=%~dp0
set M_CPU=64
set M_RT=141
set M_XP=
set M_CMD=cl.exe
set M_ICL_SETUP=0

set CC=cl.exe
set LD=link.exe
set AR=lib.exe

:arg_repeat
if :%1: == :: goto :arg_end
set arg_append=1

for %%i in ("/r6" "-r6" "/r7" "-r7" "/r9" "-r9" "/r100" "-r100" "/r120" "-r120" "/r140" "-r140" "/r141" "-r141") do (
	set Q=%%~i
	if :%1: == :%%~i: ( 
		set M_RT=!Q:~2!
		set arg_append=0
	)
)

if "%M_RT%"=="6" set M_CPU=32
if "%M_RT%"=="7" set M_CPU=32

for %%i in ("/m32" "-m32" "/m64" "-m64") do (
	set Q=%%~i
	if :%1: == :%%~i: ( 
		set M_CPU=!Q:~2!
		set arg_append=0
	)
)

for %%i in ("/Link" "-Link") do (
	if :%1: == :%%~i: ( 
	       	set M_CMD=link.exe
       		set arg_append=0
	)
)

for %%i in ("/Lib" "-Lib") do (
	if :%1: == :%%~i: ( 
	       	set M_CMD=lib.exe
       		set arg_append=0
	)
)

for %%i in ("/Make" "-Make") do (
	if :%1: == :%%~i: ( 
	       	set M_CMD=nmake.exe
       		set arg_append=0
	)
)

for %%i in ("/Dump" "-Dump") do (
	if :%1: == :%%~i: ( 
	       	set M_CMD=dumpbin.exe
       		set arg_append=0
	)
)

for %%i in ("/Icl" "-Icl") do (
	if :%1: == :%%~i: ( 
	       	if "x%M_CMD%" == "xcl.exe"  set M_CMD=icl.exe
	       	if "x%M_CMD%" == "xlink.exe" set M_CMD=xilink.exe
	       	if "x%M_CMD%" == "xlib.exe"  set M_CMD=xilib.exe
                set CC=icl.exe
                set LD=xilink.exe
                set AR=xilib.exe
                set M_ICL_SETUP=1
       		set arg_append=0
	)
)

for %%i in ("/Help" "-Help") do (
	if :%1: == :%%~i: ( 
                echo use mscc [Tool] [Opts] [Tool Args]
                echo .   mscc hello.c            ~ compiles hello.c with VS2017 for amd64
	        echo .   mscc -Icl -r100 hello.c ~ compiles hello.c with Intel Composer/VS2010
	        echo .   mscc -m32 -r140 hello.c ~ compiles hello.c with VS2015 for i386
	        echo .   mscc -Make -m64 -r9     ~ runs nmake with VS2008 for amd64
	        echo .   mscc -Make -Icl -r141   ~ runs nmake with with Intel Composer/VS2017
                echo .   mscc -Link /?           ~ help for VS2017 link.exe
                echo .   mscc -Link -Icl -qhelp  ~ help for Intel Composer/VS2017 xilink.exe 
                echo .
                echo Possible Tool:
		echo .   -Link ~ to use LINK 
		echo .   -Lib  ~ to use LIB
		echo .   -Dump ~ to use DUMPBIN
		echo .   -Make ~ to use NMAKE
		echo .   -Icl  ~ to use Intel Composer XE
                echo .           will combined if placed after other one
                echo .
                echo Possible Opts:
                echo .   -r6   ~ to use Visual Studio 6
		echo .   -r7   ~ to use Visual Studio 2003
		echo .   -r9   ~ to use Visual Studio 2008
                echo .   -r100 ~ to use Visual Studio 2010
                echo .   -r140 ~ to use Visual Studio 2015
                echo .   -r141 ~ to use Visual Studio 2017
                echo .   -m64  ~ set target to amd64
                echo .   -m32  ~ set target to i386
		exit 0
	)
)

if %arg_append% == 1 set args=%args% %1
shift
goto :arg_repeat
:arg_end

if not "x%ICLVARS_BAT%" == "x" goto :icl_arch
if .%PROCESSOR_ARCHITECTURE%. == .x86. set ICLVARS_BAT=%ProgramFiles%\Intel\Composer XE\bin\iclvars.bat
if not .%PROCESSOR_ARCHITECTURE%. == .x86. set ICLVARS_BAT=%ProgramFiles(x86)%\Intel\Composer XE\bin\iclvars.bat
:icl_arch
if "x%M_ICL_SETUP%" == "x1" (
	if %M_CPU% == 32 set ICL_ARCH=ia32
	if %M_CPU% == 64 set ICL_ARCH=intel64
)
if "x%M_ICL_SETUP%" == "x1" call "%ICLVARS_BAT%" %ICL_ARCH% >NUL

%CLX%xternal.cmd env%M_CPU%_%M_RT% %M_CMD% %args%
