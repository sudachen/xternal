
@echo off

set MAKEDIR=%~dp0
call %~dp0Env\perl_home.cmd
call %~dp0Env\python_home.cmd
set PATH=%~dp0Env;%SystemRoot%;%SystemRoot%\System32;%~dp0Env\gnu;%PERL_HOME%\bin;%PYTHON_HOME%

if "%XTERNAL%" == "" set XTERNAL=%~dp0

call %~dp0define_env.cmd 
if exist .\define_env.cmd call define_env.cmd 

set ACTION=build
set DEBUG_SET=YES,NO
set DEBUG_SET_YES=x
set DEBUG_SET_NO=x
set STATIC_SET=NO

set PROJECT=%1
shift

if .%PROJECT%. == .. goto :eof
set PROJECT_DIR=%PROJECT%
if not exist %PROJECT_DIR% set PROJECT_DIR=%PROJECT%.SRC
if not exist %PROJECT_DIR% goto :eof

:next_arg
if .%1. == .. 		goto :no_more
if .%1. == .rebuild. 	set ACTION=rebuild
if .%1. == .info. 	set ACTION=info
if .%1. == .clean. 	set ACTION=clean
if .%1. == .debug. 	set DEBUG_SET_YES=YES
if .%1. == .release. 	set DEBUG_SET_NO=NO
if .%1. == .static.  	set STATIC_SET=YES
if .%1. == .dynamic. 	set STATIC_SET=NO
if .%1. == .dll.     	set STATIC_SET=NO
if .%1. == .monodll. 	set STATIC_SET=YENO
if .%1. == .x64.  	set ENVIRONS=env64
if .%1. == .x86.  	set ENVIRONS=env32
if .%1. == .x*.  	set ENVIRONS=env32 env64
if .%1. == .nodeps. 	set WITHDEPS=NO
if .%1. == .deps.   	set WITHDEPS=YES
shift
goto :next_arg
:no_more

if not .%DEBUG_SET_YES%%DEBUG_SET_NO%. == .xx. set DEBUG_SET=x,%DEBUG_SET_YES%,%DEBUG_SET_NO%

for %%n in (%ENVIRONS%) do (
	for %%d in (%DEBUG_SET%) do (
		if not .%%d. == .x. (
	            	for %%s in (%STATIC_SET%) do (
				echo %PROJECT%
          			set DEBUG=%%d
          			set STATIC=%%s
          			cmd /c %%n %MAKEDIR%build_target.cmd %ACTION%
				if errorlevel 1 exit 1
			)
		)
	)
)

