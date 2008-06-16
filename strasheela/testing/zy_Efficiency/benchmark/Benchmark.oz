
%%
%% TODO: 
%%
%% - Add option: log file is not overwritten, but new log entries are added
%%
%% - For random value ordering: make it possible that random value ordering changes for each try. For example, use a solver with before the search resets the random seed.
%%


/** %% This functor exports abstractions for easy runtime and memory performance measurements of musical CSPs.
%% */

functor
import
   System Property
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   SDistro at 'x-ozlib://anders/strasheela/source/ScoreDistribution.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
%   Browser(browse:Browse) % temp for debugging

export

   TestRuntimes TestMemories
   MakeFixedRecomputationSolver SearchOne

   %% export for testing
   TestRuntime TestMemoryOnce TestMemory MakeGetHeapIncrement

define

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Runtime
%%%

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




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Memory
%%%


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

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Aux defs
%%%

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

   /** %% [for convenience] Creates a depth-first search solver for fixed recomputation with the given RecomputationDistance. Solver always first initialises the random seed (so different search runs with random value ordering differ).
   %% */
   fun {MakeFixedRecomputationSolver RecomputationDistance}
      fun {$ MyScript Args}
	 {GUtils.setRandomGeneratorSeed 0}
	 {SDistro.searchOneDepth MyScript RecomputationDistance
	  Args _}
      end
   end

   
   /** %% Depth-first solver which first initialises the random seed (so different search runs with random value ordering differ).
   %% */
   fun {SearchOne MyScript Args}
      {GUtils.setRandomGeneratorSeed 0}
      {SDistro.searchOne MyScript Args}
   end
   
end

