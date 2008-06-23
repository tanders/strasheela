
%%
%% 
%% This file defines the top-level of a number of Strasheela benchmarks which compare the performance of different distribution strategies (and recomputation strategies etc ?)
%%
%%

%%
%% NOTE: Important things for memory and runtime measurements
%%
%% - Does the first measurement always take a bit longer and takes more memory? So, I should always have a first measurement run before doing the actual measurements.
%%
%% - For true measurements make sure that the machine is "unloaded", i.e. nothing else is running (in particular no websurver or other likely CPU and memory hungry apps). 
%%
%% - If you run multiple tests in one go, make sure that they don't run concurrently. Having memory and runtime test running concurrently would really obscure the results. So: do not feed multiple statements independently!
%%
%% - For runtime measurements I do 25 tests, but for memory I feel 1 (max 5) should be enough -- it just takes too long.
%%
%%


declare

[Benchmark] = {ModuleLink ['x-ozlib://anders/strasheela/Benchmark/Benchmark.ozf']}


/** %% How often are the runtime tests executed (for computing the average).
%% */
TimeTestNo = 10


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Distribution strategies
%%
%%

Value = random %  mid 
MyDistros = [
% 	     {Adjoin HS.distro.leftToRight_TypewiseTieBreaking
% 	      unit(value:Value
% 		   '0-doc':'left-to-right strategy with breaking ties by type')}
% 	     {Adjoin HS.distro.typewise
% 	      unit(value:Value
% 		   '0-doc':'type-wise distribution')}
	     unit(order:'startTime'
		  value:Value)
	     unit(order:{SDistro.makeLeftToRight {SDistro.makeTimeParams SDistro.domDivDeg}}
		  value:Value
		  '0-doc':'left-to-right distribution, breaking ties with dom/deg')
	     unit(order:{SDistro.makeLeftToRight {SDistro.makeTimeParams SDistro.dom}}
		  value:Value
		  '0-doc':'left-to-right distribution, breaking ties with dom')
	     unit(order:'dom'
		  value:Value)
	     unit(order:'dom/deg'
		  value:Value)
	     unit(order:'naive'
		  value:Value)
	    ]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% The CSPs
%%
%%

\insert ../../../../examples/03-FloridCounterpoint-Canon.oz

%% TODO: try both canon in fifth and canon in octave: the performance seems to differ drastically
MyScript_Fifth = {GUtils.extendedScriptToScript Canon
		  unit(voice1NoteNo: 17 %+6 
		       voice2NoteNo: 15 %+6
		       transpositionInterval: 7)}


MyScript_Octave = {GUtils.extendedScriptToScript Canon
		  unit(voice1NoteNo: 17 %+6 
		       voice2NoteNo: 15 %+6
		       transpositionInterval: 0)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% The actual measurements 
%%
%%

/*

{Benchmark.testRuntimes MyScript_Fifth
 MyDistros
 unit(testNo:TimeTestNo
      scriptDescr:"Florid counterpoint"
      solver:Benchmark.searchOne
      solverDescr:"depth-first search")}


{Benchmark.testMemories MyScript_Fifth
 MyDistros
 unit(testNo:1
      scriptDescr:"Florid counterpoint"
      solver:Benchmark.searchOne
      solverDescr:"depth-first search")}

{Benchmark.testRuntimes MyScript_Fifth
 MyDistros
 unit(testNo:TimeTestNo
      scriptDescr:"Florid counterpoint"
      solver:{Benchmark.makeFixedRecomputationSolver 25}
      solverDescr:"depth-first search, fixed recomputation with distance 25")}
{Benchmark.testMemories MyScript_Fifth
 MyDistros
 unit(testNo:1
      scriptDescr:"Florid counterpoint"
      solver:{Benchmark.makeFixedRecomputationSolver 25}
      solverDescr:"depth-first search, fixed recomputation with distance 25")}

%%
%% pre-results
%%


%% random avlue ordering: 
%%
% Runtime (walltime) test for script <P/1> (Florid counterpoint),
%  using solver <P/3 SearchOne> (depth-first search), each test run 10 times, at 22:44, 19-6-2008
% Runtime 1187 msec, distribution unit(order:startTime value:random)
% Runtime 1583 msec, distribution unit('0-doc':'left-to-right distribution, breaking ties with dom/deg' order:<P/3> value:random)
% Runtime 857 msec, distribution unit('0-doc':'left-to-right distribution, breaking ties with dom' order:<P/3> value:random)
% Runtime 492404 msec, distribution unit(order:dom value:random)
% Runtime 24974 msec, distribution unit(order:'dom/deg' value:random)
% NOTE: naive did not finish after a whole nights computation


%% mid value ordering: measurements 
%%
% Runtime (walltime) test for script <P/1> (Florid counterpoint),
%  using solver <P/3 SearchOne> (depth-first search), each test run 1 times, at 22:44, 19-6-2008
% Runtime 1910 msec, distribution unit(order:startTime value:mid)
% Runtime 2040 msec, distribution unit('0-doc':'left-to-right distribution, breaking ties with dom/deg' order:<P/3> value:mid)
% Runtime 1910 msec, distribution unit('0-doc':'left-to-right distribution, breaking ties with dom' order:<P/3> value:mid)
% Runtime 249440 msec, distribution unit(order:dom value:mid)
% Runtime 2430 msec, distribution unit(order:'dom/deg' value:mid)
% Runtime 2420 msec, distribution unit(order:naive value:mid)


*/


/* %% pre-test, just to be sure the script and solver are OK. Note that search times of explorer are longer than plain solver

%% takes a long time...
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript_Fifth
 unit(order:dom
      value:Value)}

%% takes about 4 sec (value mid)
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript_Fifth
 unit(order:startTime
      value:Value)}

%% funny: naive is also efficient (and much more so than 'dom'): ~ 19 sec
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript_Fifth
 unit(order:naive
      value:Value)}

declare
MyScore = {Benchmark.searchOne MyScript_Fifth
	   unit(order:startTime
		value:Value)}
{Browse ok}


declare
MyScore = {Benchmark.searchOne MyScript_Fifth
	   MyDistros.1}
{Browse ok}

*/


/* %% NOTE: canon in fifth is much harder to solve than canon in octave




%% preliminary Results 

%% NOTE: for value ordering mid, all distros need more or less equal time!!

% Runtime (walltime) test for script <P/1 Canon> (Florid counterpoint),
%  using solver <P/3 SearchOne> (depth-first search), each test run 1 times, at 15:57, 16-6-2008
% Runtime 1930 msec, distribution unit('0-doc':'left-to-right distribution, breaking ties with dom/deg' oder:<P/3> value:mid)
% Runtime 1600 msec, distribution unit('0-doc':'left-to-right distribution, breaking ties with dom' oder:<P/3> value:mid)
% Runtime 1610 msec, distribution unit(oder:startTime value:mid)
% Runtime 1720 msec, distribution unit(oder:dom value:mid)
% Runtime 1870 msec, distribution unit(oder:'dom/deg' value:mid)

*/ 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% NOTE: OLD STUFF
%%


/*

%%
%% NOTE: old measurements with previous version of CSP
%%

{Benchmark.testRuntimes Canon MyDistros
 unit(testNo:TestNo
      solver:SDistro.searchOne)}
{Benchmark.testMemories Canon MyDistros
 unit(testNo:TestNo
      solver:SDistro.searchOne)}
%% With recomputation 
{Benchmark.testRuntimes Canon MyDistros
 unit(testNo:TestNo
      solver:{Benchmark.makeFixedRecomputationSolver 10}
      solverDescr:"depth-first search, fixed recomputation with distance 10")}
{Benchmark.testMemories Canon MyDistros
 unit(testNo:TestNo
      solver:{Benchmark.makeFixedRecomputationSolver 10}
      solverDescr:"depth-first search, fixed recomputation with distance 10")}

%%
%% Results:
%%

% Runtime (walltime) test for script <P/1 Canon>,
%  using solver <P/3 SearchOne>, each test run 1 times, at 18:29, 30-5-2008
% Runtime 3510 msec, distribution unit(order:startTime value:mid)
% Runtime 6550 msec, distribution unit(order:startTime value:random)

% Memory (active heap maximum) test for script <P/1 Canon>,
%  using solver <P/3 SearchOne>, each test run 1 times, at 18:43, 30-5-2008
% Memory 17055744 bytes, distribution unit(order:startTime value:mid)
% Memory 25819136 bytes, distribution unit(order:startTime value:random)

% Runtime (walltime) test for script <P/1 Canon>,
%  using solver <P/3> (depth-first search, fixed recomputation with distance 10), each test run 1 times, at 18:43, 30-5-2008
% Runtime 4510 msec, distribution unit(order:startTime value:mid)
% Runtime 10770 msec, distribution unit(order:startTime value:random)

% Memory (active heap maximum) test for script <P/1 Canon>,
%  using solver <P/3> (depth-first search, fixed recomputation with distance 10), each test run 1 times, at 19:8, 30-5-2008
% Memory 6915072 bytes, distribution unit(order:startTime value:mid)
% Memory 8154112 bytes, distribution unit(order:startTime value:random)
			   
*/




