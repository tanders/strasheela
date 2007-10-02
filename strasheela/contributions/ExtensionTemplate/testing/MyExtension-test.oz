
%% This file contains test cases for the Strasheela extension template.

/*
%% First compile and install the functor. For example, at a command line move into the toplevel of this extension definition and then call ozmake. 

  cd strasheela/contributions/ExtensionTemplate/
  ozmake --install

%% If your extension is stored in the contribution folder of Strasheela, then it is also implicitly compiled and installed when you install Strasheela itself. Move into the toplevel of Strasheela and then call the script  upgrade-all.sh

  cd strasheela/ 
  ./scripts/upgrade-all.sh     

*/


%% After installation, you can link this extension (ModuleLink should be defined in your OZRC file, see the Strasheela installation instructions). Feed these code segments paragraph by paragraph.

declare
[MyExtension] = {ModuleLink ['x-ozlib://authorname/MyExtension/MyExtension.ozf']}

%% The following examples demonstrate/test the use of the procedures/functions provided by MyExtension


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% MyExtension.square
%%

{Browse {MyExtension.aux.square 3}}

{Browse {MyExtension.aux.square 3.0}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% MyExtension.add
%%

declare
X Y Z
{Browse [X Y Z]}

{MyExtension.add X Y Z}

Z = 5

X <: Y


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Show the functor itself
%%

{Browse MyExtension}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% TestClass
%%

declare
[ScoreInspector] = {ModuleLink ['x-ozlib://anders/strasheela/ScoreInspector/ScoreInspector.ozf']}

%% Use filter context menu of ScoreInspector to look into created score object

{ScoreInspector.inspect {Score.makeScore test(foo:{FD.int 1#10})
			 unit(test:MyExtension.classDef.testClass)}}

{ScoreInspector.inspect {Score.makeScore test(startTime:2)
			 unit(test:MyExtension.classDef.testClass)}}

{ScoreInspector.inspect {Score.makeScore test
			 unit(test:MyExtension.classDef.testClass)}}




%%%%%%%%%%%%


declare 
MyScore = {Score.makeScore test(foo:5
				duration:2)
	   unit(test:MyExtension.classDef.testClass)}

{Inspect MyScore}

{Inspect {MyScore toInitRecord($)}}

{Inspect {MyScore getFoo($)}}

{Inspect {MyScore getFooParameter($)}}


{Inspect {MyExtension.classDef.isTestClass MyScore}}

