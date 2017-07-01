@echo off

set CL9HOME=c:\Opt\C++\9.1
set PSDKHOME=c:\Opt\C++\PSDK71
set PATH=%CL9HOME%\bin;%PSDKHOME%\bin;%PATH%
set LIB=%CL9HOME%\lib;%PSDKHOME%\lib;%LIB%
set INCLUDE=%CL9HOME%\include;%PSDKHOME%\include;%INCLUDE%

set TARGET_CPU=X86
set TARGET_INFIX=_32r9

%*

