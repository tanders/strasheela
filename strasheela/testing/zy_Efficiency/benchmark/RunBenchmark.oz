
%%
%% 
%% This file defines the top-level of a number of Strasheela benchmarks which compare the performance of different distribution strategies (and recomputation strategies etc ?)
%%
%%

%%
%% Usage: first feed buffer (feeds all top-level defs), then feed commented benchmark calls 
%%

%%
%% NOTE: does the first measurement always take a bit longer?
%%

declare

/** %% Computes the runtime (wall time) a musical CSP MyScript (unary proc returning a score) for different distribution strategies MyDistros (a list of score distribution strategy specs as expected by the score solvers in SDistro). 
%% Args:
%% solver: the score solver used.
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
   FullReport = "\nRuntime (walltime) test for script "#{Value.toVirtualString MyScript 1 1}#ScriptDescr#",\n using solver "#{Value.toVirtualString As.solver 1 1}#SolverDescr#", each test run "#As.testNo#" times, finished at "#{GUtils.timeVString}#"\n\n"
   # {Out.listToVS Reports "\n"}#"\n"
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
   %% Xs is list of ints 
   fun {Average Xs}
      N = {Length Xs}
   in
      {LUtils.accum Xs Number.'+'} div N
   end
   Runtimes = {LUtils.collectN TestNo
	       fun {$} {GUtils.timeSpend MyTestProc} end}
in
   {Average Runtimes}
end


/*

/** %% Script for testing purposes
%% */
proc {DummyScript }
end

*/

%%
%% NOTE: including files like this is simple, but definitions may be overwritten
%% So, encapulating the scripts in functors is more secure..
%%

%% fuxian counterpoint 
\insert scripts/02-Fuxian-firstSpecies-Counterpoint.oz


/*

%%
%% first test
%%

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



local
   proc {GC}
      %% Christian Schulte: its important to do multiple garbage collections. I forgot why, I assume to collect really all memory [pages].
      {System.gcDo} {System.gcDo} {System.gcDo} {System.gcDo}
   end
in
   /** %% Returns the memory (in bytes) the application of P (a null-ary procedure) took. Note: there must be no concurrent computations.
   %% BUG: / Misconception: calling {Property.get 'gc.active'} simply at the end of a computation is missleading -- instead I should somehow measure the memory _during_ the computation.
   %% ?? How can I do that?
   %% */
   %% Christian Schulte: Property gc.active ist der Speicher der nur von _lebendigen_ Datenstrukturen belegt wird. GC entfernt Datenstrukturen die nicht mehr von einer Berechnung benoetigt werden.  
   %% NOTE: this cannot be proper: the value returned is usually negative.
   %% Also, result can be 0 for large computations...
   fun {MemoryUsed P}
      Start End
   in
      {GC}
      Start = {Property.get 'gc.active'}
      {P}
      {GC}
      End = {Property.get 'gc.active'}
      End - Start
   end
end



/*

%%
%% test
%%

declare
Times = 1000
Size = 1000 
proc {FirstPiggy}
   {List.make Size _}
   {For 1 Times 1 SecondPiggy}
end 
proc {SecondPiggy _}
   {List.make Size _}
   {For 1 Times 1 ThirdPiggy}
end 
proc {ThirdPiggy _}
   {List.make Size _}
end 


{Browse
 piggy#{MemoryUsed
	proc {$}
	   {FirstPiggy}
	end}
}


{Browse
 {MemoryUsed
  proc {$}
     _ = {SDistro.searchOne Fux_FirstSpecies
	  unit}
  end}
}

*/



