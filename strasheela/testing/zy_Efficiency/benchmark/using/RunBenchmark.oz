
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% The CSPs
%%
%%

%%
%% NOTE: file included at the end, because it contains its own declare statement
%% NOTE: including files like this is simple, but definitions may be overwritten
%% So, encapulating the scripts in functors is more secure..
%%

%% fuxian counterpoint 
\insert ../scripts/02-Fuxian-firstSpecies-Counterpoint.oz

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% The actual measurements 
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


/*

%% test "orig" florid counterpoint example with different distro strategies and with/without fixed recomputation

declare
%% NOTE: for now I don't test ff, because it would just take too long. But I will do that eventually.
% MyDistros = [unit(order:startTime
% 		  value:mid)
% 	     unit(order:startTime
% 		  value:random)
% 	     unit(order:size
% 		 value:mid)]
MyDistros = [unit(order:startTime
		  value:mid)
	     unit(order:startTime
		  value:random)]
TestNo = 1
%% NOTE: multiple runs with random value ordering all use same random numbers
{GUtils.setRandomGeneratorSeed 0}


%% setting $OZPATH for inserting relative files
{OS.putEnv 'OZPATH' "/Users/t/oz/music/Strasheela/strasheela/trunk/strasheela/examples/"}

\insert 03-FloridCounterpoint-Canon.oz

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




