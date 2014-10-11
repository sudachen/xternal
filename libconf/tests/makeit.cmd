
cd %~dp0

set ACTION=build

:next_arg
if .%1. == .rebuild. set ACTION=clean build
if .%1. == .clean. set ACTION=clean
if .%1. == .. goto :no_more
shift
goto :next_arg
:no_more

vs10 nmake -f Makefile.mak %ACTION%


