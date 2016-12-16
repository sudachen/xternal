@echo off 
set MAKEIT_DIR=%~dp0
set WORKSPACE=MY_OWN_WORKSPACE
rem set MAKEIT_NAME=myProjectName

cmd /c %XTERNAL%\makeit_proc.cmd %* 
