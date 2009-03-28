@echo off

:: script must be called from script dir
set scriptDir=%CD%
:: set scriptDir = %~p0

:: first install tmp Path contribution
echo "cd ../contributions/tmp/Path; ozmake --uninstall"
cd ../contributions/tmp/Path
ozmake --uninstall 

cd %scriptDir%
echo "cd ..; ozmake --uninstall"
cd ..
ozmake --uninstall 

cd %scriptDir%
cd ../contributions

set currentdir=%CD%
:: collect all makefiles
dir /s /b makefile.oz > makefiles.tmp
for /f "usebackq tokens=1* delims==" %%a in (makefiles.tmp) do (echo "cd ../contributions/%%~pa; ozmake --uninstall" &  cd %%~pa & ozmake --uninstall)
cd %currentdir%
del makefiles.tmp
cd %scriptDir%

