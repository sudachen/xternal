@echo off

if not "%VS100COMNTOOLS%" == "" goto callVCenv
if .%PROCESSOR_ARCHITECTURE%. == .x86. set VS100COMNTOOLS="%ProgramFiles%\Microsoft Visual Studio 10.0\Common7\Tools\" 
if not .%PROCESSOR_ARCHITECTURE%. == .x86. set VS100COMNTOOLS="%ProgramFiles(x86)%\Microsoft Visual Studio 10.0\Common7\Tools\" 

:callVCenv

if .%PROCESSOR_ARCHITECTURE%. == .x86. call "%VS100COMNTOOLS%\..\..\VC\vcvarsall.bat" x86_amd64
if .%PROCESSOR_ARCHITECTURE%. == .x86. call "%VS100COMNTOOLS%\..\..\VC\bin\x86_amd64\vcvarsx86_amd64.bat" x86_amd64
if not .%PROCESSOR_ARCHITECTURE%. == .x86. call "%VS100COMNTOOLS%\..\..\VC\vcvarsall.bat" amd64

set TARGET_CPU=X64
set TARGET_INFIX=_64r10

%*

