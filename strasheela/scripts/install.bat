:: compiles and installs all of strasheela, except those bits which depend on a C compiler

@echo off

:: script must be called from script dir
set scriptDir=%CD%
:: set scriptDir = %~p0

:: first install tmp Path contribution
echo "cd ../contributions/tmp/Path; ozmake --install"
cd ../contributions/tmp/Path
ozmake --install 

cd %scriptDir%
echo "cd ..; ozmake --install"
cd ..
ozmake --install 

cd %scriptDir%

for /f "usebackq tokens=1* delims==" %%a in (makefiles-no-cc.txt) do (echo "cd %%~pa; ozmake --install" &  cd %%~pa & ozmake --install & cd %scriptDir%)


