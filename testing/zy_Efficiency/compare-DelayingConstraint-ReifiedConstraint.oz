
%%
%% there are situations in which some contexts of a score item are
%% undetermined before search. For instance, if the timing structure
%% of a score shall be found during the search process, the
%% simultaneous items of most score items are undetermined and can
%% therefore not be accessed and constraint as shown above.
%%
%% Is delaying of constraints in a thread or reified a better solution
%% for this?
%%

%%
%% !! this test is not very meaningful because in the delayed version the application of the constraints is delayed until the whole timing tree is determined! It would be a slightly more fair test to first fully determine the timing structure
%%
%%
%% when distribution strategy determines timing structure first, the performance of both approaches are similar
%%
%%


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
   proc {NoDissonanceDelayed Note1}
      thread 
	 Pitch1 = {Note1 getPitch($)}
	 %% !! this only returns after the whole timing structure is determined, ie. all deterministic tests returned a boolean
	 SimPitches = {Map {Note1 getSimultaneousItems($ test:isNote)}
		       fun {$ Note} {Note getPitch($)} end}
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
   fun {GetVoice MyScore ScoreName}
      {MyScore find($ fun {$ X} {X hasThisInfo($ ScoreName)} end)}
   end
in
   proc {SimpleCanonReified MyScore}
      EndTime Voice1 Voice2
   in
      MyScore =
      {Score.makeScore
       sim(items: [seq(info:voice1
		       items: {LUtils.collectN 30
			       fun {$}
				  note(duration: {FD.int Durations}
				       offsetTime: 0
				       timeUnit:beats(4)
				       pitch: {FD.int 53#67}
				       amplitude: 80)
			       end}
		       offsetTime:0 endTime:EndTime)
		   seq(info:voice2
		       items: {LUtils.collectN 25
			       fun {$}
				  note(duration: {FD.int Durations}
				       offsetTime: 0
				       timeUnit:beats(4)
				       pitch: {FD.int 53#72}
				       amplitude: 80)
			       end}
		       offsetTime:{List.last Durations}*2
		       endTime:EndTime)]
	   startTime: 0 offsetTime:0)
       unit}
      Voice1 = {GetVoice MyScore voice1}
      Voice2 = {GetVoice MyScore voice2}
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
			%{NoDissonanceDelayed Note}
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
       sim(items: [seq(info:voice1
		       items: {LUtils.collectN 30
			       fun {$}
				  note(duration: {FD.int Durations}
				       offsetTime: 0
				       timeUnit:beats(4)
				       pitch: {FD.int 53#67}
				       amplitude: 80)
			       end}
		       offsetTime:0 endTime:EndTime)
		   seq(info:voice2
		       items: {LUtils.collectN 25
			       fun {$}
				  note(duration: {FD.int Durations}
				       offsetTime: 0
				       timeUnit:beats(4)
				       pitch: {FD.int 53#72}
				       amplitude: 80)
			       end}
		       offsetTime:{List.last Durations}*2
		       endTime:EndTime)]
	   startTime: 0 offsetTime:0)
       unit}
      Voice1 = {GetVoice MyScore voice1}
      Voice2 = {GetVoice MyScore voice2}
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
			{NoDissonanceDelayed Note}
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
	unit(%order:startTime
	     order:timeParams
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


{ExploreOne SimpleCanonReified}


{ExploreOne SimpleCanonDelayed}
