@echo off

set CLHOME=c:\Opt\C++\7.1
set PSDKHOME=c:\Opt\C++\PSDK71
set PATH=%CLHOME%\bin;%PSDKHOME%\bin;%PATH%
set LIB=%CLHOME%\lib;%PSDKHOME%\lib;%LIB%
set INCLUDE=%CLHOME%\include;%PSDKHOME%\include;%INCLUDE%

set TARGET_CPU=X86
set TARGET_INFIX=_32r7

%*

