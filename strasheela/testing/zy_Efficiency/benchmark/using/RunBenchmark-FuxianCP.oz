
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
TimeTestNo = 25



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Distribution strategies
%%
%%

Value = random			% can be set to random, mid...
MyDistros = [
% 	     {Adjoin HS.distro.leftToRight_TypewiseTieBreaking
% 	      unit(value:Value
% 		   '0-doc':'left-to-right strategy with breaking ties by type')}
% 	     {Adjoin HS.distro.typewise
% 	      unit(value:Value
% 		   '0-doc':'type-wise distribution')}
	     unit(oder:startTime
		  value:Value
		  '0-doc':'left-to-right distribution')
	     unit(oder:'dom'
		  value:Value
		  '0-doc':'first-fail distribution')
	     unit(oder:'dom/deg'
		  value:Value)
	     unit(oder:'dom+deg'
		  value:Value)
	     unit(oder:deg
		  value:Value)
	     unit(oder:'deg+dom'
		  value:Value)
	     unit(oder:naive
		  value:Value)
	    ]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% The CSPs
%%
%%

%% fuxian counterpoint
\insert ../../../../examples/02-Fuxian-firstSpecies-Counterpoint.oz

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% The actual measurements 
%%
%%


/*

{Benchmark.testRuntimes Fux_FirstSpecies
 MyDistros
 unit(testNo:TimeTestNo
      scriptDescr:"Homophonic chord progression"
      solver:Benchmark.searchOne
      solverDescr:"depth-first search")}


{Benchmark.testMemories Fux_FirstSpecies
 MyDistros
 unit(testNo:1
      scriptDescr:"Homophonic chord progression"
      solver:Benchmark.searchOne
      solverDescr:"depth-first search")}


{Benchmark.testRuntimes Fux_FirstSpecies
 MyDistros
 unit(testNo:TimeTestNo
      scriptDescr:"Homophonic chord progression"
      solver:{Benchmark.makeFixedRecomputationSolver 25}
      solverDescr:"depth-first search, fixed recomputation with distance 25")}

{Benchmark.testMemories Fux_FirstSpecies
 MyDistros
 unit(testNo:1
      scriptDescr:"Homophonic chord progression"
      solver:{Benchmark.makeFixedRecomputationSolver 25}
      solverDescr:"depth-first search, fixed recomputation with distance 25")}


*/


/* % preliminary results (maching was not complety unloaded)

%% NOTE: different distros hardly differ with such a relatively simple CSP

%% random value ordering
% Runtime (walltime) test for script <P/1 Fux_FirstSpecies> (Homophonic chord progression),
%  using solver <P/3 SearchOne> (depth-first search), each test run 25 times, at 15:45, 16-6-2008
% Runtime 44 msec, distribution unit('0-doc':'left-to-right distribution' oder:startTime value:random)
% Runtime 48 msec, distribution unit('0-doc':'first-fail distribution' oder:dom value:random)
% Runtime 41 msec, distribution unit(oder:'dom/deg' value:random)
% Runtime 41 msec, distribution unit(oder:'dom+deg' value:random)
% Runtime 40 msec, distribution unit(oder:deg value:random)
% Runtime 42 msec, distribution unit(oder:'deg+dom' value:random)
% Runtime 43 msec, distribution unit(oder:naive value:random)

%% mid value ordering	   
% Runtime (walltime) test for script <P/1 Fux_FirstSpecies> (Homophonic chord progression),
%  using solver <P/3 SearchOne> (depth-first search), each test run 25 times, at 15:43, 16-6-2008
% Runtime 42 msec, distribution unit('0-doc':'left-to-right distribution' oder:startTime value:mid)
% Runtime 42 msec, distribution unit('0-doc':'first-fail distribution' oder:dom value:mid)
% Runtime 42 msec, distribution unit(oder:'dom/deg' value:mid)
% Runtime 42 msec, distribution unit(oder:'dom+deg' value:mid)
% Runtime 42 msec, distribution unit(oder:deg value:mid)
% Runtime 43 msec, distribution unit(oder:'deg+dom' value:mid)
% Runtime 43 msec, distribution unit(oder:naive value:mid)


%% heap measurements differ slightly
% Memory (active heap maximum) test for script <P/1 Fux_FirstSpecies> (Homophonic chord progression),
%  using solver <P/3 SearchOne> (depth-first search), each test run 1 times, at 15:47, 16-6-2008
% Memory 410624 bytes, distribution unit('0-doc':'left-to-right distribution' oder:startTime value:random)
% Memory 312320 bytes, distribution unit('0-doc':'first-fail distribution' oder:dom value:random)
% Memory 229376 bytes, distribution unit(oder:'dom/deg' value:random)
% Memory 365568 bytes, distribution unit(oder:'dom+deg' value:random)
% Memory 355328 bytes, distribution unit(oder:deg value:random)
% Memory 365568 bytes, distribution unit(oder:'deg+dom' value:random)
% Memory 229376 bytes, distribution unit(oder:naive value:random)

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% NOTE: OLD STUFF 
%%
%%


/*

%%
%% First test: compare tradeoff of runtime and memory with and without recomputation using a simple example and only a single distribution strategy.
%%

%% No recomputation

%% NOTE: results reported at stdout
{Benchmark.testRuntimes Fux_FirstSpecies [unit]
 unit(testNo:25
      solver:SDistro.searchOne)}

{Benchmark.testMemories Fux_FirstSpecies [unit]
 unit(testNo:1
      solver:SDistro.searchOne)}

%% With recomputation 

{Benchmark.testRuntimes Fux_FirstSpecies [unit]
 unit(testNo:25
      solver:{Benchmark.makeFixedRecomputationSolver 10}
      solverDescr:"depth-first search, fixed recomputation with distance 10")}

{Benchmark.testMemories Fux_FirstSpecies [unit]
 unit(testNo:1
      solver:{Benchmark.makeFixedRecomputationSolver 10}
      solverDescr:"depth-first search, fixed recomputation with distance 10")}


%%
%% Results:
%%
%% - using recomputation does in this case not increase runtime at all
%% - the memory consumption of this simple example (226 KB without and 94KB with recomputation) is very low -- although I am using my Strasheela music representation inside the space. So, I can confidently publish these memory measurements: with the memory of nowadays computers these figures are very reasonable :) 
%%

*/


