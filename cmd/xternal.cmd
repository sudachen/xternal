@echo off
if "x%XTERNAL%" == "x" set XTERNAL=c:\Xternal

set PATH=%CD%\~Release;%CD%\~Debug;%XTERNAL%\~Release;%XTERNAL%\~Debug;%XTERNAL%\Env;%PATH%
set LIB=%XTERNAL%\~Release\.lib;%XTERNAL%\~Debug\.lib;%LIB%
set INCLUDE=%XTERNAL%\Include;%INCLUDE%

%*


