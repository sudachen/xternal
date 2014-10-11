
@echo off

set OUTDIR_ROOT=%~dp0
cmd /c make_one.cmd %*

echo suceeded
goto :eof

:error
echo failed 
exit 1

