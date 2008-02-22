



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% distribution with random variable ordering, which even works for
%% recomputation
%%


%%%%%%%%
%%
%% Example with plain variables (no score object). The solution is
%% randomised. However, calling the solver again always results in the
%% same first solution. For finding a different first random solution,
%% call GUtils.setRandomGeneratorSeed.
%%

declare
%% NOTE: MakeRandomGenerator must be called inside script
{GUtils.setRandomGeneratorSeed 0}
proc {DummyScript Sol}   
   %% dummy example without constraints: 
   %% distribution decides randomly for variable domain values
   Sol = {FD.list 5 1#10}
   %%
   {FD.distribute
    generic(value:{SDistro.makeRandomDistributionValue
		   {GUtils.makeRandomGenerator}})
    Sol}
end

{Browse {SearchOne DummyScript}}

{ExploreOne DummyScript}


/*
%% randomise the randomisation (otherwise, at similar times there is a tendency for the first random values to be similar)
{OS.srand 0}
{GUtils.setRandomGeneratorSeed {OS.rand}}
*/



%%%%%%%%
%%
%% Example constraining a score object using a convenient
%% SDistro-solver with integrated distribution strategy definition,
%% and which also supports a random value ordering.  Again, the
%% solution is randomised but re-calling the solver returns the same
%% solution -- until a new seed has been set.
%%


declare
{GUtils.setRandomGeneratorSeed 0}
proc {DummyScript MyScore}   
   MyScore = {Score.makeScore seq(items:{LUtils.collectN 5
					 fun {$}
					    note(duration:1
						 pitch:{FD.int 60#72})
					 end}
				  startTime:0
				  timeUnit:beats)
	      unit}
end

declare
MyScore = {SDistro.searchOne DummyScript
	   unit(order:size
		value:random)}.1
{Out.renderAndShowLilypond MyScore
 %% create unique file name 
 unit(file:"test-"#{GUtils.getCounterAndIncr})}


%% Select some score output under Notes->Information Action
{SDistro.exploreOne DummyScript 
 unit(order:size
      value:random)}



%%%%%%%%
%%
%% Example using recomputation: highly complex problems may take too
%% much memory. Recomputation trades memory for runtime. The
%% predefined distribution strategy with random value ordering
%% supports recomputation.
%%

%%
%% TODO: demonstrate how recomputation uses less memory, but takes
%% more time. With profiler?
%%

declare
{GUtils.setRandomGeneratorSeed 0}
proc {DummyScript MyScore}   
   MyScore = {Score.makeScore seq(items:{LUtils.collectN 5
					 fun {$}
					    note(duration:1
						 pitch:{FD.int 60#72})
					 end}
				  startTime:0
				  timeUnit:beats)
	      unit}
end



declare
RecomputationDistance = 10
MyScore = {SDistro.searchOneDepth DummyScript RecomputationDistance
	   unit(order:size
		value:random)
	  _ /* KillP */}.1
{Out.renderAndShowLilypond MyScore
 %% create unique file name 
 unit(file:"test-"#{GUtils.getCounterAndIncr})}



%% Recomputation can also be specified in the Explorer
%% (options->search)
{SDistro.exploreOne DummyScript 
 unit(order:size
      value:random)}





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% OLD:
%%
%% SDistro.makeFDDistribution is not exported any more. Use the more
%% convenient predefined solvers or MakeSearchScript instead
%%


{SDistro.makeFDDistribution ff}

{SDistro.makeFDDistribution startTime}

{SDistro.makeFDDistribution firstTimingFF}

{SDistro.makeFDDistribution generic(filter: undet
				   order: size
				   select: value
				   value: min
				   procedure: proc {$} skip end)}


{SDistro.makeFDDistribution 
 generic(filter: fun {$ X}
		    {FD.reflect.size {X getValue($)}} > 1
		 end
	 order: fun {$ X Y}
		   {FD.reflect.size {X getValue($)}}
		   <
		   {FD.reflect.size {Y getValue($)}}
		end
	 select: fun {$ X} {X value($)} end
	 value: FD.reflect.min
	 procedure: proc {$} skip end)}


%% test exception
{SDistro.makeFDDistribution generic(order: blabla)}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% simple script to compare and study distribution strategies 
%%

declare
fun {MakeSearchScript Distribution}
   proc {$ PPScore}
      MyScore = {Score.makeScore seq(items:[note note note]) unit}
      proc {InitScore S}
	 {S getStartTime($)}=0 
	 {S getOffsetTime($)}=0	% aritrary
	 {S forAll(test:isNote proc {$ X} {X getOffsetTime($)}=0 end)}
	 {S forAll(test:isNote proc {$ X} {X getAmplitude($)}=1 end)} % arbitrary
	 {S forAll(test:isParameter initFD)}
	 {ForAll S|{S collect($ test:isTimeMixin)}
	  {GUtils.toProc constrainTiming}}
      end
   in
      PPScore = {MyScore toPPrintRecord($)}
      {InitScore MyScore}
      %% actual Constraints:
      %% all note durations >: 0
      {MyScore applyRuleIf(unit(test:isNote
				accessObject: getDuration)
			   proc {$ D} D >: 0 end)}
      %% all note durations distinct
      {FD.distinct {Map {MyScore getItems($)}
		    fun {$ X} {X getDuration($)} end}}
      %% all note pitches >=: 48
      {MyScore applyRuleIf(unit(test:isNote
				accessObject: getPitch)
			   proc {$ D} D >=: 48 end)}
      %% all note pitches <: than pitch of successor note
      {MyScore applyRuleIf(
		  unit(test: fun {$ X} {X isItem($)} andthen 
				{X hasPredecessor($ {X getTemporalAspect($)})}
			     end
		       accessList: 
			  fun {$ X} 
			     [{X getPredecessor($ {X getTemporalAspect($)})} X]
			  end
		       accessObject: getPitch) 
		  proc {$ Pre Succ} Pre <: Succ end)}
      %% Distribute
      {FD.distribute Distribution
       {MyScore collect($ test:isParameter)}}
   end
end

{ExploreOne {MakeSearchScript {SDistro.makeFDDistribution ff}}}

{ExploreOne {MakeSearchScript {SDistro.makeFDDistribution firstTimingFF}}}

{ExploreOne {MakeSearchScript {SDistro.makeFDDistribution startTime}}}


