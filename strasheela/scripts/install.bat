
rem The user still has to do the following manually:
rem 
rem > Open a shell (or a DOS promt) and move into the directory Strasheela/ 
rem > contributions/tmp/Path/. Then type
rem > 
rem > ozmake --install
rem > 
rem > Move to the top-level Strasheela directory, then type
rem > 
rem > ozmake --install
rem 
rem After these steps are complete, they should go to the contributions folder and execute the batch, which will 
rem  
rem > Move to any contribution (e.g., Strasheela/contributions/anders/ 
rem > Pattern or Strasheela/contributions/anders/Tutorial) and call ozmake 
rem > again.

set currentdir=%CD%
dir /s /b /ad > folders.tmp
for /f "usebackq tokens=1* delims==" %%a in (folders.tmp) do (cd %%a & ozmake)
cd %currentdir%
del folders.tmp
