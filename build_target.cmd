
@echo off
if not exist %~dp0posixtime.exe goto :notime
for /F %%i in ('%~dp0posixtime.exe') do set BUILDTIME=%%i
:notime
if not exist %~dp0random.exe goto :norandom
for /F %%i in ('%~dp0random.exe') do set BUILDRANDOM=%%i
:norandom
cd %PROJECT_DIR%
set MAKEFILE_DIR=%CD%
nmake -nologo -f makefile.mak DEBUG=%DEBUG% CPU=%TARGET_CPU% %*
