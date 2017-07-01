@echo off

set CL9HOME=c:\Opt\C++\9.1
set PSDKHOME=c:\Opt\C++\PSDK71
set PATH=%CL9HOME%\bin\amd64;%PSDKHOME%\bin\x64;%PSDKHOME%\bin;%PATH%
set LIB=%CL9HOME%\lib\amd64;%PSDKHOME%\lib\x64;%LIB%
set INCLUDE=%CL9HOME%\include;%PSDKHOME%\include;%INCLUDE%

set TARGET_CPU=X64
set TARGET_INFIX=_64r9

%*

