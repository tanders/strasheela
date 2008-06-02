
%%
%% 
%% This file defines the top-level of a number of Strasheela benchmarks which compare the performance of different distribution strategies (and recomputation strategies etc ?)
%%
%%

%%
%% Usage: first feed buffer (feeds all top-level defs), then feed commented benchmark calls 
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

%%
%% TODO: 
%%
%% - Add option: log file is not overwritten, but new log entries are added
%%
%% - For random value ordering: make it possible that random value ordering changes for each try. For example, use a solver with before the search resets the random seed.
%%



declare


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Aux defs
%%

/** %% Computes the arithmetic mean of Xs (a list of ints).
%% */
fun {Average Xs}
   N = {Length Xs}
in
   {LUtils.accum Xs Number.'+'} div N
end


/** %% Expects an "open" stream (associated with a port) and a value which unambiguously marks the end of the stream (e.g., a name). Returns all values in the stream before the EndMarker in a list.
%% */
fun {OpenStreamToList Xs EndMarker}
   if Xs.1 == EndMarker then nil
   else Xs.1 | {OpenStreamToList Xs.2 EndMarker}
   end
end

/** %% Creates a solver for fixed recomputation with the given RecomputationDistance.
%% */
fun {MakeFixedRecomputationSolver RecomputationDistance}
   fun {$ MyScript Args}
      {SDistro.searchOneDepth MyScript RecomputationDistance
       Args _}
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Runtime
%%

/** %% Computes the runtime (wall time) a musical CSP MyScript (unary proc returning a score) for different distribution strategies MyDistros (a list of score distribution strategy specs as expected by the score solvers in SDistro). 
%% Args:
%% solver: the score solver used, a binary function expecting the script and an Args record, returning the solution.
%% testNo: how often is each test run (an int)? Reported is the arithmetic mean of the run times in all trials.
%% logfile: a path (VS) or false. If logfile is a path, then the result is written to that file  (overwriting file if it existed). If logfile is false, then results are printed to stdout instead.
%% scriptDescr: a VS discribing MyScript, only used for making the resulting report more readable.
%% solverDescr: see scriptDescr.
%% */
proc {TestRuntimes MyScript MyDistros Args}
   Defaults = unit(scriptDescr:""
		   solver: SDistro.searchOne
		   solverDescr:""
		   testNo: 1 
		   logFile: false)
   As = {Adjoin Defaults Args}
   ScriptDescr = if As.scriptDescr == nil then nil
		 else " ("#As.scriptDescr#")"
		 end
   SolverDescr = if As.solverDescr == nil then nil
		 else " ("#As.solverDescr#")"
		 end
   Reports = {Map MyDistros
	      fun {$ MyDistro}
		 Runtime = {TestRuntime MyScript MyDistro As.solver As.testNo}
	      in
		 "Runtime "#Runtime#" msec, distribution "#{Value.toVirtualString MyDistro 100 100}
	      end}
   FullReport = "\nRuntime (walltime) test for script "#{Value.toVirtualString MyScript 1 1}#ScriptDescr#",\n using solver "#{Value.toVirtualString As.solver 1 1}#SolverDescr#", each test run "#As.testNo#" times, at "#{GUtils.timeVString}#"\n"
   # {Out.listToVS Reports "\n"}
in
   if As.logFile
   then {Out.writeToFile FullReport As.logFile}
   else {System.showInfo FullReport}
   end
end



/** %% [aux] Solves TestNo times MyScript using MySolver and the score distribution args MyDistro. Returns the average (arithmetic mean) of the run times. 
%% */
fun {TestRuntime MyScript MyDistro MySolver TestNo}
   proc {MyTestProc}
      _ = {MySolver MyScript MyDistro}
   end
   Runtimes = {LUtils.collectN TestNo
	       fun {$} {GUtils.timeSpend MyTestProc} end}
in
   {Average Runtimes}
end




/* %%  test

{Browse {TestRuntime Fux_FirstSpecies unit SDistro.searchOne 1}}

{Browse {TestRuntime Fux_FirstSpecies unit SDistro.searchOne 10}}

{TestRuntimes Fux_FirstSpecies [unit
				unit(value:random)
				unit(value:random)
				unit(order:naive)
				unit(order:startTime)]
 unit(scriptDecr:"First species Fuxian counterpoint"
      testNo:25)}

*/





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Memory
%%


/** %% Function returns a null-ary function. Whenever the return function is called, it outputs the memory (in bytes, an int) by which the active heap increated since calling MakeGetHeapIncrement itself.
%% 
%% Christian Schulte: Property gc.active ist der Speicher der nur von _lebendigen_ Datenstrukturen belegt wird. GC entfernt Datenstrukturen die nicht mehr von einer Berechnung benoetigt werden.
%%
%% NB: if results are output by tools like the browser, then the memory consumption of these tools is displayed as well. Using Show for output does not consume memory.
%% */
fun {MakeGetHeapIncrement}
   proc {GC}
      %% Christian Schulte: its important to do multiple garbage collections. He forgot why, but assumes it is necessay to collect really all memory [pages]. In his benchmarks he did this 4 times, so I am doing 4 times as well.
      {System.gcDo} {System.gcDo} {System.gcDo} {System.gcDo}
   end
   Start 
in
   {GC}
   Start = {Property.get 'gc.active'}
   fun {$}
      End
   in
      {GC}
      End = {Property.get 'gc.active'}
      End - Start
   end
end


/* %% test

declare
GetHeapIncrement = {MakeGetHeapIncrement}

%% Show does no add memory (in contrast to the Browser), but the very first value is not 0 when Show is used for the first time (probably the proc itself is then loaded). 
{Show {GetHeapIncrement}}

%% Following are some values -- binding these increases the value displayed by GetHeapIncrement. Note that overwriting some variable with a new declare seems not to remove the old bindings. Also, when I bind values to a cell it appears overwriting the cell does not garbarge collect the old values. Hm..
%% Anyway, let assume for now that MakeGetHeapIncrement works as it should..

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




/** %% [aux] Solves MyScript using MySolver and the score distribution args MyDistro. Returns a list with the memory measurements (active heap) for each non-failed space (distributable or solved space). Note that the distribution strategy feature procedure would be overwritten.
%% */
fun {TestMemoryOnce MyScript MyDistro MySolver}
   MyStream
   MyPort = {NewPort MyStream}
   EndMarker = {NewName}
   GetHeapIncrement = {MakeGetHeapIncrement}
in
   _ = {MySolver MyScript
	{Adjoin MyDistro
	 unit(procedure:proc {$} {Send MyPort {GetHeapIncrement}} end)}}
   %% Make sure that the EndMarker is added to the end of the list 
   {Send MyPort EndMarker}
   %% return heap values as list
   {OpenStreamToList MyStream EndMarker}
end


/** %% [aux] Solves TestNo times MyScript using MySolver and the score distribution args MyDistro. Returns the average (arithmetic mean) of the maximal memory (active heap) needed during the search process. 
%% */
fun {TestMemory MyScript MyDistro MySolver TestNo}
   MaxHeaps = {LUtils.collectN TestNo
	       fun {$}
		  HeapVals = {TestMemoryOnce MyScript MyDistro MySolver}
	       in
		  {LUtils.accum HeapVals Max}
	       end}
in
   {Average MaxHeaps}
end



/** %% Computes the memory (active heap) a musical CSP MyScript (unary proc returning a score) for different distribution strategies MyDistros (a list of score distribution strategy specs as expected by the score solvers in SDistro). 
%% Args:
%% solver: the score solver used, a binary function expecting the script and an Args record, returning the solution. 
%% testNo: how often is each test run (an int)? Reported is the arithmetic mean of the run times in all trials.
%% logfile: a path (VS) or false. If logfile is a path, then the result is written to that file  (overwriting file if it existed). If logfile is false, then results are printed to stdout instead.
%% scriptDescr: a VS discribing MyScript, only used for making the resulting report more readable.
%% solverDescr: see scriptDescr.
%% */
proc {TestMemories MyScript MyDistros Args}
   Defaults = unit(scriptDescr:""
		   solver: SDistro.searchOne
		   solverDescr:""
		   testNo: 1 
		   logFile: false)
   As = {Adjoin Defaults Args}
   ScriptDescr = if As.scriptDescr == nil then nil
		 else " ("#As.scriptDescr#")"
		 end
   SolverDescr = if As.solverDescr == nil then nil
		 else " ("#As.solverDescr#")"
		 end
   Reports = {Map MyDistros
	      fun {$ MyDistro}
		 Memory = {TestMemory MyScript MyDistro As.solver As.testNo}
	      in
		 "Memory "#Memory#" bytes, distribution "#{Value.toVirtualString MyDistro 100 100}
	      end}
   FullReport = "\nMemory (active heap maximum) test for script "#{Value.toVirtualString MyScript 1 1}#ScriptDescr#",\n using solver "#{Value.toVirtualString As.solver 1 1}#SolverDescr#", each test run "#As.testNo#" times, at "#{GUtils.timeVString}#"\n"
   # {Out.listToVS Reports "\n"}
in
   if As.logFile
   then {Out.writeToFile FullReport As.logFile}
   else {System.showInfo FullReport}
   end
end



/* %% test

declare
HeapValues = {TestMemoryOnce Fux_FirstSpecies unit SDistro.searchOne}
MaxHeapValue = {LUtils.accum HeapValues Max}
MinHeapValue = {LUtils.accum HeapValues Min}


{Browse max#MaxHeapValue}		% different values: ~ 368 KB, 220KB..
%% likely memory needed by a single full score copy
{Browse min#MinHeapValue}		
{Browse HeapValues}

%% test: how does the search tree look like
{SDistro.exploreOne Fux_FirstSpecies
 unit(order:naive)}

%% OK: every distributable space and solution adds its heap value 
{Browse {Length HeapValues}}

%%%

%% Now using recomputation

declare
HeapValues = {TestMemoryOnce Fux_FirstSpecies unit
	      {MakeFixedRecomputationSolver 10}}
MaxHeapValue = {LUtils.accum HeapValues Max}
MinHeapValue = {LUtils.accum HeapValues Min}

{Browse max#MaxHeapValue}		% different values: ~ 368 KB, 220KB..
%% likely memory needed by a single full score copy
{Browse min#MinHeapValue}		
{Browse HeapValues}



*/


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
\insert scripts/02-Fuxian-firstSpecies-Counterpoint.oz

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

{TestRuntimes Fux_FirstSpecies [unit]
 unit(testNo:25
      solver:SDistro.searchOne)}

{TestMemories Fux_FirstSpecies [unit]
 unit(testNo:25
      solver:SDistro.searchOne)}

%% With recomputation 

{TestRuntimes Fux_FirstSpecies [unit]
 unit(testNo:25
      solver:{MakeFixedRecomputationSolver 10}
      solverDescr:"depth-first search, fixed recomputation with distance 10")}

{TestMemories Fux_FirstSpecies [unit]
 unit(testNo:25
      solver:{MakeFixedRecomputationSolver 10}
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

{TestRuntimes Canon MyDistros
 unit(testNo:TestNo
      solver:SDistro.searchOne)}
{TestMemories Canon MyDistros
 unit(testNo:TestNo
      solver:SDistro.searchOne)}
%% With recomputation 
{TestRuntimes Canon MyDistros
 unit(testNo:TestNo
      solver:{MakeFixedRecomputationSolver 10}
      solverDescr:"depth-first search, fixed recomputation with distance 10")}
{TestMemories Canon MyDistros
 unit(testNo:TestNo
      solver:{MakeFixedRecomputationSolver 10}
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




