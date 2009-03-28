:: compiles and installs all of strasheela
:: Problem: some parts require C compiler

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
cd ../contributions

set currentdir=%CD%
:: collect all makefiles
dir /s /b makefile.oz > makefiles.tmp
for /f "usebackq tokens=1* delims==" %%a in (makefiles.tmp) do (echo "cd ../contributions/%%~pa; ozmake --install" &  cd %%~pa & ozmake --install)
cd %currentdir%
del makefiles.tmp
cd %scriptDir%

