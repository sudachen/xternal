@echo off

if not "%VS120COMNTOOLS%" == "" goto callVCenv
if .%PROCESSOR_ARCHITECTURE%. == .x86. set VS120COMNTOOLS="%ProgramFiles%\Microsoft Visual Studio 12.0\Common7\Tools\" 
if not .%PROCESSOR_ARCHITECTURE%. == .x86. set VS120COMNTOOLS="%ProgramFiles(x86)%\Microsoft Visual Studio 12.0\Common7\Tools\" 

:callVCenv

call "%VS120COMNTOOLS%\..\..\VC\vcvarsall.bat" x86

set TARGET_CPU=X86
set TARGET_INFIX=_32

%*

