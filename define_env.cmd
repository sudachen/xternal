
if not .%ENVIRONS%. == .. goto skipenv
if .%PROCESSOR_ARCHITECTURE%. == .x86. set ENVIRONS=env32
if .%ENVIRONS%. == .. set ENVIRONS=env64
:skipenv

if "%OUTDIR_ROOT%" == "" set OUTDIR_ROOT=%~dp0.
if .%WORKSPACE%.   == .. set WORKSPACE=XTERNAL

set INCLUDE=%~dp0.\include;%INCLUDE%

