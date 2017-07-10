@echo off

if not "x%VS2017HOME%" == "x" goto callVCenv
if .%PROCESSOR_ARCHITECTURE%. == .x86. set VS2017HOME=%ProgramFiles%\Microsoft Visual Studio\2017
if not .%PROCESSOR_ARCHITECTURE%. == .x86. set VS2017HOME=%ProgramFiles(x86)%\Microsoft Visual Studio\2017

:callVCenv

set VCVARSSCRIPT=%VS2017HOME%\Community\VC\Auxiliary\Build\vcvarsall.bat

call "%VCVARSSCRIPT%" x86 > NUL

set TARGET_CPU=X86
set TARGET_INFIX=_32r14

%*

