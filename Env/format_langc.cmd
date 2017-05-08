@echo off
for %%q in (%*) do (
	pushd %%~dpq
	for %%i in (%%~xnq) do %~dp0astyle.exe --style=allman -s4 -xk -S -N -xw -w -m0 -H -k3 -W1 -O -o -c -xy -xC128 -L %%i
	popd
)


