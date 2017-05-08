
@echo off

set OUTDIR_ROOT=%~dp0
set ACTION=info

if .%1. == .. set ACTION=build
if .%1. == .build. set ACTION=build
if .%1. == .clean. set ACTION=clean
if .%1. == .rebuild. set ACTION=rebuild

if .%XTERNAL_TARGET%. == .. set XTERNAL_TARGET=x*

for /F %%i in (projects.dll.txt) do (
	cmd /c make_one.cmd %%i dll %XTERNAL_TARGET% %ACTION%
	if errorlevel 1 goto :error
)

for /F %%i in (projects.lib.txt) do (
	cmd /c make_one.cmd %%i static %XTERNAL_TARGET% %ACTION%
	if errorlevel 1 goto :error
)

echo suceeded
goto :eof

:error
echo failed 
exit 1

