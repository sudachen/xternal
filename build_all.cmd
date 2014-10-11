
@echo off

set OUTDIR_ROOT=%~dp0
set ACTION=info

if .%1. == .. set ACTION=build
if .%1. == .build. set ACTION=build
if .%1. == .clean. set ACTION=clean
if .%1. == .rebuild. set ACTION=rebuild

for /F %%i in (projects.dll.txt) do (
	cmd /c make_one.cmd %%i dll %ACTION%
	if errorlevel 1 goto :error
)

for /F %%i in (projects.lib.txt) do (
	cmd /c make_one.cmd %%i static x* %ACTION%
	if errorlevel 1 goto :error
)

echo suceeded
goto :eof

:error
echo failed 
exit 1

