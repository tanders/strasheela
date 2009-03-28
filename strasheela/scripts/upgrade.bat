:: recompiles/installs all of Strasheela, except those bits which depend on a C compiler

@echo off

:: script must be called from script dir
set scriptDir=%CD%
:: set scriptDir = %~p0

:: first install tmp Path contribution
echo "cd ../contributions/tmp/Path; ozmake --upgrade"
cd ../contributions/tmp/Path
ozmake --upgrade 

cd %scriptDir%
echo "cd ..; ozmake --upgrade"
cd ..
ozmake --upgrade 

cd %scriptDir%

for /f "usebackq tokens=1* delims==" %%a in (makefiles-no-cc.txt) do (echo "cd %%~pa; ozmake --upgrade" &  cd %%~pa & ozmake --upgrade & cd %scriptDir%)


