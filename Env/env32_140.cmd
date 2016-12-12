@echo off

if not "%VS140COMNTOOLS%" == "" goto callVCenv
if .%PROCESSOR_ARCHITECTURE%. == .x86. set VS140COMNTOOLS="%ProgramFiles%\Microsoft Visual Studio 14.0\Common7\Tools\" 
if not .%PROCESSOR_ARCHITECTURE%. == .x86. set VS140COMNTOOLS="%ProgramFiles(x86)%\Microsoft Visual Studio 14.0\Common7\Tools\" 

:callVCenv

call "%VS140COMNTOOLS%\..\..\VC\vcvarsall.bat" x86

set TARGET_CPU=X86
set TARGET_INFIX=_32r14

%*

