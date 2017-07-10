@echo off

if not "x%VS2017HOME%" == "x" goto callVCenv
if .%PROCESSOR_ARCHITECTURE%. == .x86. set VS2017HOME=%ProgramFiles%\Microsoft Visual Studio\2017
if not .%PROCESSOR_ARCHITECTURE%. == .x86. set VS2017HOME=%ProgramFiles(x86)%\Microsoft Visual Studio\2017

:callVCenv

set VCVARSSCRIPT=%VS2017HOME%\Community\VC\Auxiliary\Build\vcvarsall.bat

if .%PROCESSOR_ARCHITECTURE%. == .x86. call "%VCVARSSCRIPT%" x86_amd64 > NUL
if not .%PROCESSOR_ARCHITECTURE%. == .x86. call "%VCVARSSCRIPT%" amd64 > NUL

set TARGET_CPU=X64
set TARGET_INFIX=_64r14

call %~dp0QT5.cmd

set PATH=%QT5HOME%\msvc2017_64\bin;%PATH%
set INCLUDE=%QT5HOME%\msvc2017_64\include;%INCLUDE%
set LIB=%QT5HOME%\msvc2017_64\lib;%LIB%

call %~dp0PY3.cmd

%*

