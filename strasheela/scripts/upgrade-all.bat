:: recompiles/installs all of Strasheela

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
cd ../contributions

set currentdir=%CD%
:: collect all makefiles
dir /s /b makefile.oz > makefiles.tmp
for /f "usebackq tokens=1* delims==" %%a in (makefiles.tmp) do (echo "cd ../contributions/%%~pa; ozmake --upgrade" &  cd %%~pa & ozmake --upgrade)
cd %currentdir%
del makefiles.tmp
cd %scriptDir%

