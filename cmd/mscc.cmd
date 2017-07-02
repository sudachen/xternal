
@echo off
setlocal ENABLEDELAYEDEXPANSION
set args=
set CLX=%~dp0
set M_CPU=64
set M_RT=141
set M_XP=

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

for %%i in ("/XP" "-XP") do (
	set Q=%%~i
	if :%1: == :%%~i: ( 
		set M_XP=!Q:~1!
		set arg_append=0
	)
)
if %arg_append% == 1 set args=%args% %1
shift
goto :arg_repeat
:arg_end

set M_LINK=

if "%M_XP%" == "XP" (
	if %M_CPU% == 32 set SUBSYSTEM=-SUBSYSTEM:CONSOLE,5.01
	if %M_CPU% == 64 set SUBSYSTEM=-SUBSYSTEM:CONSOLE,5.02
	set M_LINK=!SUBSYSTEM!
)

if not "x%M_LINK%" == "x" set args=-DUSING_V110_SDK71 %args% -link "%M_LINK%"

%CLX%xternal.cmd env%M_CPU%_%M_RT% cl %args%
