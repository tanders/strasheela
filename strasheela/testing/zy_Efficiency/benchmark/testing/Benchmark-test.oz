
%%
%% NOTE: mainly lower-level benchmark procs are tested here, but these are not exported in the final benchmark file version
%%
%% For actual usage the benchmark file ../using/RunBenchmark.oz 
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



/* %%  test

{Browse {Benchmark.testRuntime Fux_FirstSpecies unit SDistro.searchOne 1}}

{Browse {Benchmark.testRuntime Fux_FirstSpecies unit SDistro.searchOne 10}}

%% results shown at stdout
{Benchmark.testRuntimes Fux_FirstSpecies [unit
					  unit(value:random)
					  unit(value:random)
					  unit(order:naive)
					  unit(order:startTime)]
 unit(scriptDecr:"First species Fuxian counterpoint"
      testNo:25)}

*/





/* %% test

declare
GetHeapIncrement = {Benchmark.makeGetHeapIncrement}

%% Show does no add memory (in contrast to the Browser), but the very first value is not 0 when Show is used for the first time (probably the proc itself is then loaded). 
{Show {GetHeapIncrement}}

%% Following are some values -- binding these increases the value displayed by GetHeapIncrement. Note that overwriting some variable with a new declare seems not to remove the old bindings. Also, when I bind values to a cell it appears overwriting the cell does not garbarge collect the old values. Hm..
%% Anyway, let assume for now that MakeGetHeapIncrement works as it should..
%% ... in the final proc TestMemories it seems to work: the effect of recomputation can be observed clearly

%% NOTE: repeatedly call {Show {GetHeapIncrement}} to see how the memory is affected. 

declare
X = {NewCell 1}

X := {Score.makeScore note unit}

X := {Score.makeScore seq(items:[note note]) unit}

X := 1

declare
MyScore = {Score.makeScore note unit}

declare
MyScore = {Score.makeScore seq(items:[note note]) unit}

%% minimal memory consumption
declare
MyScore = 1

*/



/* %% test

declare
HeapValues = {Benchmark.testMemoryOnce Fux_FirstSpecies unit SDistro.searchOne}
MaxHeapValue = {LUtils.accum HeapValues Max}
MinHeapValue = {LUtils.accum HeapValues Min}


{Browse max#MaxHeapValue}		% different values: ~ 368 KB, 220KB..
%% likely memory needed by a single full score copy
{Browse min#MinHeapValue}		
{Browse HeapValues}

%% OK: every distributable space and solution adds its heap value 
{Browse {Length HeapValues}}


%% just confirming how does the search tree look like
{SDistro.exploreOne Fux_FirstSpecies
 unit(order:naive)}


%%%

%% Now using recomputation

declare
HeapValues = {Benchmark.testMemoryOnce Fux_FirstSpecies unit
	      {Benchmark.makeFixedRecomputationSolver 10}}
MaxHeapValue = {LUtils.accum HeapValues Max}
MinHeapValue = {LUtils.accum HeapValues Min}

{Browse max#MaxHeapValue}		% different values: ~ 368 KB, 220KB..
%% likely memory needed by a single full score copy
{Browse min#MinHeapValue}		
{Browse HeapValues}


*/


