
%%
%% TODO:
%% 
%% - All defs shared by all benchmarks (e.g., solvers and distro strategies) are defined in one common file in this folder and \insert-ed (or in benchmark functor)
%%

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
TimeTestNo = 1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Distribution strategies
%%
%%

MyDistros = [
% 	     {Adjoin HS.distro.leftToRight_TypewiseTieBreaking
% 	      unit(value:random
% 		   '0-doc':'left-to-right strategy with breaking ties by type')}
% 	     {Adjoin HS.distro.typewise
% 	      unit(value:random
% 		   '0-doc':'type-wise distribution')}
	     unit(oder:startTime
		  value:random
		  '0-doc':'left-to-right distribution')
% 	     unit(oder:'dom'
% 		  value:random
% 		  '0-doc':'first-fail distribution')
% 	     unit(oder:'dom/deg'
% 		  value:random
% 		  '0-doc':'first-fail distribution')
	    ]


/* % pilot test

Runtime (walltime) test for script <P/1> (Homophonic chord progression),
 using solver <P/3 SearchOne>, each test run 1 times, at 15:18, 16-6-2008
Runtime 190 msec, distribution unit('0-doc':'left-to-right strategy with breaking ties by type' order:<P/3> test:<P/2 IsNoTimepointNorPitch> value:random)

Runtime (walltime) test for script <P/1> (Homophonic chord progression),
 using solver <P/3 SearchOne>, each test run 1 times, at 15:22, 16-6-2008
Runtime 200420 msec, distribution unit('0-doc':'type-wise distribution' order:<P/3 Typewise_Distro.order> select:<P/2 Typewise_Distro.select> test:<P/2 IsNoTimepointNorPitch> value:random)

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% The CSP
%%
%%

%% Homophonic chord progression (Schoenberg Harmony) 
\insert ../../../../examples/HomophonicChordProgression.oz

MyScript = {GUtils.extendedScriptToScript HomophonicChordProgression
	    unit(key:'Bb'#'major'
		 n:9)}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% The actual measurements 
%%
%%

/*

{Benchmark.testRuntimes MyScript
 MyDistros
 unit(testNo:TimeTestNo
      scriptDescr:"Homophonic chord progression"
      solver:Benchmark.searchOne
      solverDescr:"depth-first search")}


{Benchmark.testMemories MyScript
 MyDistros
 unit(testNo:1
      scriptDescr:"Homophonic chord progression"
      solver:Benchmark.searchOne
      solverDescr:"depth-first search")}


{Benchmark.testRuntimes MyScript
 MyDistros
 unit(testNo:TimeTestNo
      scriptDescr:"Homophonic chord progression"
      solver:{Benchmark.makeFixedRecomputationSolver 25}
      solverDescr:"depth-first search, fixed recomputation with distance 25")}

{Benchmark.testMemories MyScript
 MyDistros
 unit(testNo:1
      scriptDescr:"Homophonic chord progression"
      solver:{Benchmark.makeFixedRecomputationSolver 25}
      solverDescr:"depth-first search, fixed recomputation with distance 25")}


*/
