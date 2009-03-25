
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

%%
%% HOWTO do parallel search with Strasheela objects
%% - Import every required functor not from Oz base environment into the "script functor"
%% - Avoid constraint equation syntax in distributed programs
%%
%% :: / :::   - FD.decl / FD.int
%% Addition   - FD.sum, FD.plus, FD.minus
%% =: / \=:   -  
%% <: etc.    - FD.less, FD.lesseq, FD.greater, FD.greatereq


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Working dummy example using objects
%%

declare
%% dummy functor with class
functor MyDataF
import
   FD
export
   MyClass
define
   class MyClass      
      attr val
      meth init(val:?Val<={FD.decl})
	 @val = Val
      end
      meth val($) @val end
   end
end
Machines = init(localhost:2)
functor ScriptF
import
   %% Any ressources except from the Oz base environment must be treated explicitly for distribution: import any functor needed (FD, MyData) within the functor/script 
   FD
   Module
export Script
define
   [MyData] = {Module.apply [MyDataF]}
   %% dummy script 
   proc {Script Root}
      %%
      X = {New MyData.myClass init}
      Y = {New MyData.myClass init}
      Z = {New MyData.myClass init(val: 7)}
   in
      Root = unit(X Y Z)
      %% Avoid constraint equation syntax in distributed programs 
      {FD.sum [{X val($)} {Y val($)}] '=:' {Z val($)}}
      {FD.less {X val($)} {Y val($)}}
      %%
      {FD.distribute ff [{X val($)} {Y val($)}]}
   end
end
%% create search engine for two processes on localhost
SearchEngine = {New Search.parallel Machines}
Solution = {SearchEngine one(ScriptF $)}
{Browse {Record.map Solution.1 fun {$ X} {X val($)} end}}

{SearchEngine close}

{SearchEngine stop}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Example which uses score objects with trick: root variable is score
%% in textual representation. So, CSP def is simplified, but score
%% distro strategies do not work
%%

%%
%% TODO: replace any constraint equation syntax in Strasheela with explicit procedures 
%%

/* 

declare
%% parallel search
Machines = init(localhost:4)
functor ScriptF
import
   Module
   FD 
export Script
define
   %% import Strasheela
   [Strasheela] = {Module.apply ['x-ozlib://anders/strasheela/Strasheela.ozf']}
   Init = Strasheela.init
   GUtils = Strasheela.gUtils
   LUtils = Strasheela.lUtils
   MUtils = Strasheela.mUtils
   Score = Strasheela.score
   SMapping = Strasheela.sMapping
   SDistro = Strasheela.sDistro
   Out = Strasheela.out
   %% NOTE: first remove declare statement on top of this file 
   \insert '02-Fuxian-firstSpecies-Counterpoint.oz'
   /* %% Top-level script where score is nested record, and distro strategy is defined within script. 
   %% N is number of notes per voice.
   %% */
   fun {Fux_FirstSpecies N}
      proc {$ MyScore_Text}
	 %% The pitches of the cantus firmus are given as MIDI keynumbers
	 %% (the cantus is taken from Fux). For the definition of MakeVoice
	 %% see below.
	 Voice1 = {MakeVoice {FD.list N 60#76} 'voice 1'}
	 %% The pitches of the counterpoint are undetermined and only
	 %% restricted to a certain range. For example, the pitches are
	 %% restricted to the interval [60,76] (i.e. the counterpoint is
	 %% above the cantus) or [48, 64] (the counterpoint is below the
	 %% cantus).
	 %%
	 %% The definition could be changed such that the pitch range of the
	 %% Counterpoint can be given as an argument, but there exist only
	 %% few solutions if the Counterpoint is the lower voice.
	 Voice2 = {MakeVoice {FD.list N 60#76} 'voice 2'}
   % Counterpoint = {MakeVoice {FD.list 11 48#64}}
	 Voice1Notes = {Voice1 getItems($)}
	 Voice2Notes = {Voice2 getItems($)}
	 %% create the score: two voices (Voice1 + Counterpoint) run
	 %% in parallel. A simultaneous container is used which is a
	 %% temporal container whose contained items (the two voices) are
	 %% implicitly constrained to run in parallel.
	 MyScore = {Score.makeScore sim(items: [Voice1 Voice2]
					%% the whole voice starts at time 0
					startTime: 0
					%% the duration 1 denotes a quarter note.
					timeUnit:beats)
		    unit}
      in
	 MyScore_Text = {MyScore toInitRecord($)}
	 %%
	 %% Rules for first voice
	 %%
	 {OnlyDiatonicPitches Voice1Notes}
	 {RestrictMelodicIntervals Voice1}
	 %% hard-coded: start and end with D
	 {Voice1Notes.1 getPitch($)} = 62
	 {{List.last Voice1Notes} getPitch($)} = 62
%    {FD.modI {Voice1Notes.1 getPitch($)} 12 2}
%    {FD.modI {{List.last Voice1Notes} getPitch($)} 12 2}
	 %%
	 %% Rules for second voice
	 %%
	 %% every note is diatonic, except the cadence note (the butlast note)
	 {OnlyDiatonicPitches
	  {List.last Voice2Notes} | {List.take Voice2Notes
				     {Length Voice2Notes}-2}}
	 %% Note: simple approach, only suitable for Dorian mode
	 %% hard-coded cadence: but last pitch is C#
	 {FD.modI {{LUtils.lastN Voice2Notes 2}.1 getPitch($)} 12 1}
	 %% No chromatic interval: C must not lead into C#
	 local PC = {FD.decl} in 
	    {FD.modI {{LUtils.lastN Voice2Notes 3}.1 getPitch($)} 12 PC}
	    PC \=: 0 
	 end
	 {RestrictMelodicIntervals Voice2}
	 {OnlyConsonances Voice2}
	 {PreferImperfectConsonances Voice2}
	 {NoDirectMotionIntoPerfectConsonance Voice2}
	 {StartAndEndWithPerfectConsonance Voice2}
	 %%
	 %%
	 {FD.distribute ff {MyScore map($ getValue test:isParameter)}}
      end
   end
   %%
   Script = {Fux_FirstSpecies 11}
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



%%%%%%%%%%%%%%%%%%

%% plain search (no parallisation)
{ExploreOne {Fux_FirstSpecies 11}}

declare
[MyScore_Text] = {SearchOne {Fux_FirstSpecies 14}}
MyScore = {Score.make MyScore_Text unit}
{MyScore wait}
{Out.renderAndShowLilypond MyScore
 unit}


%%%%%%%%%%%%%%%%%

%% results in similar error as when score is returned by script 


*** Warning: Unable to reach the net, using localhost instead

*** Warning: Unable to reach the net, using localhost instead

*** Warning: Unable to reach the net, using localhost instead

*** Warning: Unable to reach the net, using localhost instead

*** Warning: Unable to reach the net, using localhost instead


%********************** error in application ********************
%**
%** Application of non-procedure and non-object
%**
%** In statement: {<Resource> 60#76 _<optimized>}
%**
%** Call Stack:
%** procedure 'FdList' in file "/Users/ggutierrez/Work/mozart-1-3-2/mozart/share/lib/cp/FD.oz", line 254, column 6, PC = 4459856
%**--------------------------------------------------------------

%****************** Error: remote module manager ****************
%**
%** remote(crashed <O: ManagerProxy> apply(<Chunk> 'export'(worker:<P/1 PS>)))
%**
%** Call Stack:
%** procedure 'ManagerProxy,SyncSend/fast' in file "/Users/ggutierrez/Work/mozart-1-3-2/mozart/share/lib/dp/Remote.oz", line 196, column 6, PC = 25791264
%** procedure 'Process,plain/fast' in file "/Users/ggutierrez/Work/mozart-1-3-2/mozart/share/lib/cp/par/ParProcess.oz", line 48, column 6, PC = 25731548
%** procedure 'MapT' in file "/usr/staff/raph/devel/trunk/mozart/share/lib/base/Record.oz", line 76, column 3, PC = 4390288
%** procedure 'Engine,one/fast' in file "/Users/ggutierrez/Work/mozart-1-3-2/mozart/share/lib/cp/par/ParSearch.oz", line 105, column 6, PC = 25714276
%** procedure 'TimeSpend' in file "/Users/tanders/oz/music/Strasheela/strasheela/trunk/strasheela/source/GeneralUtils.oz", line 544, column 3, PC = 25638612
%**--------------------------------------------------------------

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Example which does not work: uses score objects
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




