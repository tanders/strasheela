
%%
%% Fontifier gets a a programming language spec and source code VS or file and returns the source code enriched with fontification information. Fontifier calls emacs in the background. 
%%
%% for Fontifier doc see <mozart-source>/contrib/doc/code/Fontifier.oz 

declare
[Fontifier] = {ModuleLink ['x-oz://contrib/doc/code/Fontifier']}


% (browse with string setting for browser)
{Fontifier.processVirtualString oz 'declare
fun {Test X}
   X * X
end
'}



/*

%% test (set Browser to VS and browse..): default loadpath OK 
{Fontifier.loadpath.get}
{Fontifier.requires.get}

*/

