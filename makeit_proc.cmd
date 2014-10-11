@echo off 
rem set MAKEIT_NAME=project name here
rem set MAKEIT_DIR=%~dp0
set MAKEIT_ENV=x64
set MAKEIT_REL=debug
set MAKEIT_DEPS=NO
set MEKEIT_PROC_DIR=%~dp0
set MAKEIT_DYNAMIC=dll

:next
if .%1. == .. 		goto :build
if .%1. == .release. 	set MAKEIT_REL=
if .%1. == .debug. 	set MAKEIT_REL=
if .%1. == .deps.  	set MAKEIT_DEPS=YES
if .%1. == .x86. 	set MAKEIT_ENV=
if .%1. == .x64. 	set MAKEIT_ENV=
if .%1. == .x*. 	set MAKEIT_ENV=
if .%1. == .*. 	        set MAKEIT_ENV=
if .%1. == .*. 	        set MAKEIT_REL=
shift
goto :next

:build
if .%MAKEIT_DEPS%. == .YES. (
	if exist %MAKEIT_DIR%deps.txt for /F %%i in (%MAKEIT_DIR%deps.txt) do (
		if exist %MAKEIT_DIR%..\%%i ( cd %MAKEIT_DIR%..\%%i ) else ( cd %MAKEIT_DIR%..\%%i.SRC )
		if errorlevel 1 exit 
		cmd /c makeit.cmd %*
	)
)

if errorlevel 1 exit
cd %MAKEIT_DIR%..
cmd /c %MEKEIT_PROC_DIR%make_one.cmd %MAKEIT_NAME% %MAKEIT_ENV% %MAKEIT_REL% %*

