for %%i in (*.hxx) do %~dp0astyle.exe --style=allman -s4 -xk -S -N -xw -w -m0 -H -k1 -W1 -O -o -c -xy -xC128 -L %%i

