
/*
%%
%% There are situations in which some contexts of a score item are
%% undetermined before search. For instance, if the timing structure
%% of a score shall be found during the search process, the
%% simultaneous items of most score items are undetermined and can
%% therefore not be accessed directly and constrained. See thesis "
%% Composing Music by Composing Rules", Sec. 6.3 "Constraining
%% Inaccessible Score Contexts" for a discussion of this matter.
%%
%% The thesis suggests two solutions (besides reformulating the
%% problem): delayed rule application and using logical connectives
%% such as FD.impl. The thesis argues that using logical connectives
%% is more expressive. For example, the following FOL expression
%% constrains "both ways": if the two notes are not simultaneous they
%% are constrained not to be consonant, and if they are not consonant
%% they are constrained not to be simultaneous.

isSimultaneous(note1, note2) -> isConsonant(note1, note2) 

%% However, the thesis did not carefully compare the performance of
%% the two approaches using either delayed constraints or logical
%% connectives.
%%
%% I meanwhile realised that a suitable test when delaying constraints
%% is a reified constraint together with an equality test. For
%% example: find all notes simultaneous to MyNote and apply some
%% constraint to them.

{ForAll {MyScore filter($ fun {$ X}
			     {X isNote($)} andthen
			     X \= MyNote andthen % ignore Note
			     {MyNote isSimultaneousItemR($ X)} == 1
			  end)}
 MyConstraint}

%% With this construct, the score context "notes simultaneous to
%% MyNote" is returned as soon as the score contains enough
%% information to isolate this context. Before that, the accessor
%% simply blocks, which makes it easy to simply apply constraints to
%% the score context. The constraint application is then delayed until
%% enough information is available -- but not any longer.
%%
%% This example defines two variants of a CSP: a canon where the
%% rhythmical structure is undetermined in the problem definition. The
%% two top-level definitions are SimpleCanonReified and
%% SimpleCanonDelayed. Both definitions are idential except for two
%% different harmony constraints constraining the context of
%% simultaneous notes. SimpleCanonReified uses the rule
%% NoDissonanceReified whereas SimpleCanonDelayed uses the rule
%% NoDissonanceDelayed.
%% 
%% The performance in both cases is very similar (using left-to-right
%% distribution strategy). In some quick test the delayed constraint
%% application case seems to be slightly faster in this example, but
%% this needs more exact measurements.
%%
%% Moreover, in this specific case, all variables are determined in
%% this case, whereas there are undetermined variables left in the
%% case using FD.impl: in rule NoDissonanceReified, the variable
%% Consonance is not determined for non-simultaneous notes.
%%
%%
*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Canon (minimal rule set ;-)
%%%

declare
local
   Durations = [4 8 16]
   proc {StartAndEndWithLongest Note}
      C = {Note getTemporalAspect($)}
   in
      if {Note isFirstItem($ C)} orelse
	 {Note isLastItem($ C)}
      then
	 {Note getDuration($)} = {List.last Durations}
      end
   end
   proc {SlowRhythmChanges Note}
      C = {Note getTemporalAspect($)}
   in
      if {Note hasPredecessor($ C)}
      then
	 Dur1 = {{Note getPredecessor($ C)} getDuration($)}
	 Dur2 = {Note getDuration($)}
	 HalveDur1 
      in
	 %{FD.decl HalveDur1}
	 {FD.times HalveDur1 2 Dur1}
	 {FD.times HalveDur1 {FD.int [1 2 4]} Dur2}
      end
   end
   %% MIDI pitch domain reduction: only 'wite keys' (c major)
   proc {InCMajor Note}
      {List.forAll [1 3 6 8 10]	% list of 'black' pitch classes (c=0)
       proc {$ BlackKey}
	  {FD.modI {Note getPitch($)} 12} \=: BlackKey
       end}
   end
   proc {StartAndEndWithFundamental Note}
      C = {Note getTemporalAspect($)}
   in
      if {Note isFirstItem($ C)} orelse
	 {Note isLastItem($ C)}
      then
	 {Note getPitch($)} = 60
      end
   end
   %% voice leading: only intervals up to a fifth, no pitch repetition
   %% (context dependent constraint -- getPredecessor -- but this
   %% context is predetermined by predetermined hierarchic structure)
   proc {NoBigJump Note}
      C = {Note getTemporalAspect($)}
   in
      if {Note hasPredecessor($ C)}
      then
	 Pitch1 = {{Note getPredecessor($ C)} getPitch($)}
	 Pitch2 = {Note getPitch($)}
      in
	 %% all intervals between minor second and fourth are allowed
	 {FD.distance Pitch1 Pitch2 '>:' 0}
	 {FD.distance Pitch1 Pitch2 '<:' 5}
      end
   end
   %% harmony: only consonants 
   proc {NoDissonanceReified Note1 Voice2}
      Voice2Notes = {Voice2 getItems($)}
      Pitch1 = {Note1 getPitch($)}
   in
      {ForAll Voice2Notes
       proc {$ Note2}
	  Pitch2 = {Note2 getPitch($)}
	  Consonance = {FD.int [3 4 7 8 9 12 15 16]}		
       in
	  %% !! Consonance does not necessarily get determined: the
	  %% solution diamond in the explorer are light green
	  %Consonance = {FD.int [3 4 7 8 9 12 15 16]}
	  {FD.impl		
	   {Note1 isSimultaneousItemR($ Note2)}
	   ( Pitch1 + Consonance =: Pitch2 )
	   1}
       end}
   end
   %% harmony: only consonants 
   proc {NoDissonanceDelayed Note1 MyScore}
      thread 
	 Pitch1 = {Note1 getPitch($)}
	 %% returns immediately after enough is known about temporal
	 %% structure to know which notes are simultaneous
	 SimNotes = {MyScore filter($ fun {$ X}
					 {X isNote($)} andthen
					 X \= Note1 andthen % ignore Note1
					 {Note1 isSimultaneousItemR($ X)} == 1
				      end)}
	 SimPitches = {Map SimNotes fun {$ Note} {Note getPitch($)} end}
      in
	 % {Browse {Length SimPitches}}
	 {ForAll SimPitches
	  proc {$ Pitch2}
	     Consonance = {FD.int [3 4 7 8 9 12 15 16]}
	  in
	     Pitch1 + Consonance =: Pitch2
	  end}
      end
   end
in
   proc {SimpleCanonReified MyScore}
      EndTime Voice1 Voice2
   in
      MyScore =
      {Score.makeScore
       sim(items: [seq(items: {LUtils.collectN 30
			       fun {$}
				  note(duration: {FD.int Durations}
				       offsetTime: 0
				       timeUnit:beats(4)
				       pitch: {FD.int 53#67}
				       amplitude: 80)
			       end}
		       offsetTime:0
		       endTime:EndTime
		       handle:Voice1)
		   seq(items: {LUtils.collectN 25
			       fun {$}
				  note(duration: {FD.int Durations}
				       offsetTime: 0
				       timeUnit:beats(4)
				       pitch: {FD.int 53#72}
				       amplitude: 80)
			       end}
		       offsetTime:{List.last Durations}*2
		       endTime:EndTime
		       handle:Voice2)]
	   startTime: 0 offsetTime:0)
       unit}
      %%
      %% Apply compositional rules:
      %%
      %% rules for al notes
      {MyScore forAll(test: isNote
		      proc {$ Note}
			 {InCMajor Note}
			 {NoBigJump Note}
			 {StartAndEndWithLongest Note}
			 {SlowRhythmChanges Note}
		      end)}
      %% rules for notes of first voice
      {Voice1 forAll(test: isNote
		     proc {$ Note}
			{StartAndEndWithFundamental Note}
			{NoDissonanceReified Note Voice2}
			% {NoDissonanceDelayed Note MyScore}
		     end)}
      %% The first 12 notes of each voice form a canon in a fifth
      %% (can be an abstracted rule as well)
      for
	 Note1 in {List.take {Voice1 getItems($)} 12}
	 Note2 in {List.take {Voice2 getItems($)} 12}
      do
	 {Note1 getPitch($)} + 7 =: {Note2 getPitch($)}
	 {Note1 getDuration($)} =: {Note2 getDuration($)}
      end
      %% search strategy (i.e. distribution strategy)
      {FD.distribute
       {SDistro.makeFDDistribution
	unit(order:startTime
	     %value:random
	     value:min
	    )}
       {MyScore collect($ test:fun {$ X}
				  {X isParameter($)} andthen
				  {Not {X isTimePoint($)}} andthen
				  {Not {{X getItem($)} isContainer($)}}
			       end)}}
   end
   %% copy of SimpleCanonReified, a single rule is replaced
   proc {SimpleCanonDelayed MyScore}
      EndTime Voice1 Voice2
   in
      MyScore =
      {Score.makeScore
       sim(items: [seq(items: {LUtils.collectN 30
			       fun {$}
				  note(duration: {FD.int Durations}
				       offsetTime: 0
				       timeUnit:beats(4)
				       pitch: {FD.int 53#67}
				       amplitude: 80)
			       end}
		       offsetTime:0
		       endTime:EndTime
		       handle:Voice1)
		   seq(items: {LUtils.collectN 25
			       fun {$}
				  note(duration: {FD.int Durations}
				       offsetTime: 0
				       timeUnit:beats(4)
				       pitch: {FD.int 53#72}
				       amplitude: 80)
			       end}
		       offsetTime:{List.last Durations}*2
		       endTime:EndTime
		       handle:Voice2)]
	   startTime: 0 offsetTime:0)
       unit}
      %%
      %% Apply compositional rules:
      %%
      %% rules for al notes
      {MyScore forAll(test: isNote
		      proc {$ Note}
			 {InCMajor Note}
			 {NoBigJump Note}
			 {StartAndEndWithLongest Note}
			 {SlowRhythmChanges Note}
		      end)}
      %% rules for notes of first voice
      {Voice1 forAll(test: isNote
		     proc {$ Note}
			{StartAndEndWithFundamental Note}
			%{NoDissonanceReified Note Voice2}
			{NoDissonanceDelayed Note MyScore}
		     end)}
      %% The first 12 notes of each voice form a canon in a fifth
      %% (can be an abstracted rule as well)
      for
	 Note1 in {List.take {Voice1 getItems($)} 12}
	 Note2 in {List.take {Voice2 getItems($)} 12}
      do
	 {Note1 getPitch($)} + 7 =: {Note2 getPitch($)}
	 {Note1 getDuration($)} =: {Note2 getDuration($)}
      end
      %% search strategy (i.e. distribution strategy)
      {FD.distribute
       {SDistro.makeFDDistribution
	unit(order:startTime
	     % order:timeParams
	     %value:random
	     value:min
	    )}
       {MyScore collect($ test:fun {$ X}
				  {X isParameter($)} andthen
				  {Not {X isTimePoint($)}} andthen
				  {Not {{X getItem($)} isContainer($)}}
			       end)}}
   end
end

/*

{ExploreOne SimpleCanonReified}


{ExploreOne SimpleCanonDelayed}

*/

