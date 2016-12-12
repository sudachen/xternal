@echo off

if not "%VS100COMNTOOLS%" == "" goto callVCenv
if .%PROCESSOR_ARCHITECTURE%. == .x86. set VS100COMNTOOLS="%ProgramFiles%\Microsoft Visual Studio 10.0\Common7\Tools\" 
if not .%PROCESSOR_ARCHITECTURE%. == .x86. set VS100COMNTOOLS="%ProgramFiles(x86)%\Microsoft Visual Studio 10.0\Common7\Tools\" 

:callVCenv

call "%VS100COMNTOOLS%\..\..\VC\vcvarsall.bat" x86

set TARGET_CPU=X86
set TARGET_INFIX=_32r10

%*

