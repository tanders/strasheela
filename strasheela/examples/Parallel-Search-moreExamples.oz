
%%
%% I tried to use parallel search with score objects, but ran into problems. 
%% Does parallel search work with objects in the space at all?
%%
%% BTW: Parallel search is broken in Mozart 1.4.0, only works in old 1.3.2 at all. 
%%

%%
%% NOTE:
%% - parallel search with score seems not to work so easily
%%   scores are objects: can they "travel" like variables or not?
%%
%%

/* % Schoenberg's Theory of Harmony

\insert 'Harmony-Examples/Schoenberg-TheoryOfHarmony.oz'
declare
Machines = init(localhost:4)
{GUtils.setRandomGeneratorSeed 0}
functor ScriptF
% import FD
export Script
define
   %% revised root progression rules (ascending progressions,
   %% limited number of super strong progressions)
   Script 
   = {SDistro.makeSearchScript
      {GUtils.extendedScriptToScript HomophonicChordProgression
       unit(iargs:unit(n:9
		       bassChordDegree: fd#(1#2))
	    rargs:unit(maxPercentSuperstrong:20))}
      HS.distro.leftToRight_TypewiseTieBreaking}
end
Sol
%% create search engine for two processes on localhost
SearchEngine = {New Search.parallel Machines}
TimeSpend
%% now call solver
TimeSpend = {GUtils.timeSpend  	% measure runtime
	     %% NB: SearchEngine uses functor (possibly a compiled
	     %% functor), but not a module
	     proc {$} Sol={SearchEngine one(ScriptF $)} end}
%% greatly reduced search time +/- 800 msces instead of 3800 msecs
%% This time I probably just go lucky, realistic is search time of
%% single CPU divided my number of notes..
{Browse timeSpend#TimeSpend}	
{Browse solution#Sol}

{SearchEngine close}

{SearchEngine stop}


{SearchEngine trace(true)}


%% Resulting error message 


*** Warning: Unable to reach the net, using localhost instead

*** Warning: Unable to reach the net, using localhost instead

*** Warning: Unable to reach the net, using localhost instead

Tk Module: --- package require Tix
---  can't find package Tix
---

*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!
*** Warning: marshaling a variable as a resource!

%********************** error in application ********************
%**
%** Application of non-procedure and non-object
%**
%** In statement: {<Resource> element(bassChordDegree:fd#(1#2) duration:2 getScales:<P/2> inScaleB:1 timeUnit:beats) _<optimized>}
%**
%** Call Stack:
%** procedure 'IsFS' in file "/Users/tanders/oz/music/Strasheela/strasheela/trunk/strasheela/source/GeneralUtils.oz", line 94, column 3, PC = 4450432
%** procedure 'IsScoreObject' in file "/Users/tanders/oz/music/Strasheela/strasheela/trunk/strasheela/source/ScoreCore.oz", line 2373, column 3, PC = 5008364
%** procedure 'UnifyIDsAux' in file "/Users/tanders/oz/music/Strasheela/strasheela/trunk/strasheela/source/ScoreCore.oz", line 2462, column 6, PC = 25802324
%** procedure 'UnifyIDs' in file "/Users/tanders/oz/music/Strasheela/strasheela/trunk/strasheela/source/ScoreCore.oz", line 2501, column 6, PC = 5119188
%** procedure 'MakeScore2' in file "/Users/tanders/oz/music/Strasheela/strasheela/trunk/strasheela/source/ScoreCore.oz", line 2591, column 6, PC = 4419400
%** procedure 'Map' in file "/usr/staff/raph/devel/trunk/mozart/share/lib/base/List.oz", line 76, column 0, PC = 4244724
%** procedure 'MakeItems' in file "/Users/tanders/oz/music/Strasheela/strasheela/trunk/strasheela/source/ScoreCore.oz", line 2779, column 6, PC = 25798252
%** procedure in file "/Users/tanders/oz/music/Strasheela/strasheela/trunk/strasheela/source/ScoreCore.oz", line 2955, column 6, PC = 25876844
%** procedure in file "/Users/tanders/oz/music/Strasheela/strasheela/trunk/strasheela/source/ScoreCore.oz", line 2955, column 6, PC = 25690988
%** procedure 'HomophonicChordProgression' in file "/Users/tanders/oz/music/Strasheela/strasheela/trunk/strasheela/examples/Harmony-Examples/Schoenberg-TheoryOfHarmony.oz", line 54, column 0, PC = 25907960
%**--------------------------------------------------------------

%****************** Error: remote module manager ****************
%**
%** remote(crashed <O: ManagerProxy> apply(<Chunk> 'export'(worker:<P/1 PS>)))
%**
%** Call Stack:
%** procedure 'ManagerProxy,SyncSend/fast' in file "/Users/ggutierrez/Work/mozart-1-3-2/mozart/share/lib/dp/Remote.oz", line 196, column 6, PC = 25661216
%** procedure 'Process,plain/fast' in file "/Users/ggutierrez/Work/mozart-1-3-2/mozart/share/lib/cp/par/ParProcess.oz", line 48, column 6, PC = 25484252
%** procedure 'MapT' in file "/usr/staff/raph/devel/trunk/mozart/share/lib/base/Record.oz", line 76, column 3, PC = 4390288
%** procedure 'Engine,one/fast' in file "/Users/ggutierrez/Work/mozart-1-3-2/mozart/share/lib/cp/par/ParSearch.oz", line 105, column 6, PC = 25530468
%** procedure 'TimeSpend' in file "/Users/tanders/oz/music/Strasheela/strasheela/trunk/strasheela/source/GeneralUtils.oz", line 544, column 3, PC = 25599700
%**--------------------------------------------------------------


*/




