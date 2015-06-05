
@echo off
setlocal ENABLEDELAYEDEXPANSION
set args=
set CLX=%~dp0
set M_CPU=64
set M_RT=12
set M_XP=

:arg_repeat
if :%1: == :: goto :arg_end
set arg_append=1
for %%i in ("/m32" "-m32" "/m64" "-m64") do (
	set Q=%%~i
	if :%1: == :%%~i: ( 
		set M_CPU=!Q:~2!
		set arg_append=0
	)
)

for %%i in ("/v7" "-v7" "/v9" "-v9" "/v10" "-v10" "/v12" "-v12" ) do (
	set Q=%%~i
	if :%1: == :%%~i: ( 
		set M_RT=!Q:~2!
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
	if %M_CPU% == 32 set SUBSYSTEM="-SUBSYSTEM:CONSOLE,5.01"
	if %M_CPU% == 64 set SUBSYSTEM="-SUBSYSTEM:CONSOLE,5.02"
	set M_LINK=!SUBSYSTEM!
	set args=%args% -DUSING_V110_SDK71
)

if %M_CPU% == 32 call %CLX%mcpu32.cmd
if %M_CPU% == 64 call %CLX%mcpu64.cmd

if not .%M_LINK%. == .. set args=%args% -link %M_LINK%

cl %args%
