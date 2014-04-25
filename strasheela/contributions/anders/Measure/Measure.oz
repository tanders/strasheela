
%%% *************************************************************
%%% Copyright (C) 2004-2005 Torsten Anders (t.anders@qub.ac.uk) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

%%
%% TODO:
%%
%% Accent constraints
%%
%% Ideas for additional accent constraints see [[file:~/oz/music/Strasheela/strasheela/trunk/strasheela/others/TODO/Strasheela-TODO.org::*%5B#A%5D%20Ideas%20for%20further%20accent%20constraints][Ideas for further accent constraints]]
%%


%%
%% * So far no metric hierarchy, only a seq of measures.. (constraints in MeasureSeq use only getItems etc.) -- see doc of MeasureSeq
%%
%% * [Done -- Fomus output] Lilypond Output ... (eventuell haarig)
%%
%% * fix MeasureSeq (temporarily commented because of severe flaws in design)
%%
%% * !! doc
%%
%% * keep / transform comments on decision process of design after functor as doc
%%
%% * Measure: init constraints for beats and accents block until beatNumber is determined: any (not too expensive) way around that (see also old comments at end of this file)? 
%%
%% * UniformMeasures: constraints as onBeatR block until both beatNumber and beatDuration is determined: any (not too expensive) way around that?
%%
%% * ?? UniformMeasures redesign: unclean design: mirroring of 'contained' measure params and measure startTime and endTime unused. For instance, I may define some mixin with all necessay attrs, params and initConstraints for the measure and inherit both Measure and UniformMeasures from this mixin.
%%
%% * ?? UniformMeasures/MeasureSeq: add constraints similar to onBeatR and friend for determined Time arg: find simultaneous beat and apply constraint  
%%

%%
%% Further comments: see old code and comments after measure class definitions
%%

functor
import
   FD FS
   % Browser(browse:Browse) % temp for debugging
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   Out at 'source/Output.ozf'
   
export
   Out
   
   Measure IsMeasure
   % MeasureSeq IsMeasureSeq
   UniformMeasures IsUniformMeasures

   AccentRatingMixin IsAccentRatingMixin
   MakeAccentRatingClass Note
   
   Accent_If Accent_If2 SetAccentRating NoteAtMetricPosition
   Make_HasAtLeastDuration
   IsFirstItem
   IsLongerThanDirectNeighbours IsLongerThanPredecessor IsLongerThanPredecessorSimple
   IsLongerThanPredecessor_Rated IsLongerThanSurrounding_Rated
   IsFirstOfEqualNoteValues
   IsHigherThanDirectNeighbours IsHigherThanPredecessor
   IsSkip
   IsHigherThanPredecessor_Rated IsHigherThanSurrounding_Rated
   HasTextureAccent
   WeightConstraint

   Make_HasAnacrusis
   Anacrusis_AccentLonger
   Anacrusis_DirectionChange
   Anacrusis_LocalMax
   Anacrusis_ShorterThanAccent Anacrusis_FirstNShorterThanAccent
   Anacrusis_NoLongerThanAccent Anacrusis_FirstNNoLongerThanAccent
   Anacrusis_PossibilyShorterTowardsAccent Anacrusis_FirstNPossibilyShorterTowardsAccent
   Anacrusis_EvenDurations Anacrusis_FirstNEvenDurations
   Anacrusis_UpwardPitchIntervals Anacrusis_FirstNUpwardPitchIntervals
   Anacrusis_SameDirectionPitchIntervals Anacrusis_FirstNSameDirectionPitchIntervals
   
prepare
   MeasureType = {Name.new}
   % MeasureSeqType = {Name.new}
   UniformMeasuresType = {Name.new}
   AccentRatingType = {Name.new}
   
define


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Measure class definitions
%%%

   
   /** %% Measure is a silent timed element representing the meter of a score for the duration of the Measure. Measures are contained in a silent MeasureSeq/UniformMeasures and a MeasureSeq/UniformMeasures runs in parallel to the actual (i.e. sounding) score. That way, the metric structure is freely constrainable independent of other parameters and the hierarchic structure of the rest of the score. 
   %% The Measure parameters 'beatNumber' and 'beatDuration' represent the meter of the measure. For instance, in case the time unit of the score is beats(4) and thus 4 represents a quarter note (see doc Score.timeMixin) then the meter 3/8 is represented by beatNumber=3 and beatDuration=2. Usually, beatDuration will equal the number of ticks per beat defined in the time unit of the score (exceptions are needed in case the score contains measures with different beat durations).
   %% The attribute 'beats' (a list of FD ints) represents the relative startTimes of the beats in the measure (i.e., the start times counting from the beginning of the measure). For instance, in case beatNumber=3 and beatDuration=2 then beats=[0 2 4].
   %% The attribute 'accents' (a list of FD ints) represents the relative startTimes of the strong beats in the measure. The strong beats depend on the beatNumber of the measure. The accent patterns in common praxis music are highly standardised (e.g. the meter 4/4 has strong beats on the first and the third beat). Nonetheless, Measure allows to freely define these accent patterns for each possible beatNumber value for each Measure at the optional init method argument 'accentIdxDB'. This argument expects a record (with only integer features) of lists of integers to specify an accent pattern for each beatNumber. For instance, the specification of the common praxis tripel and quadruple meter is unit(3:[1] 4:[1 3]).
   %% The default of 'accentIdxDB' defines the usual common praxis accent patterns for single (1/2, 1/4, 1/8), duple (2/2, 2/4, 2/8), triple (3/2, 3/4, 3/8), and quadruple (4/2, 4/4, 4/8) meter, as well as compound duple (6/2, 6/4, 6/8), compound triple (9/4, 9/8), and compound quadruple (12/4, 12/8, 12/16) meter. The compound meters may also be used to express 'prolatione perfecta' for old music, while the non-coumpound meters express 'prolatione imperfecta'. For the quintuple meter (5/4 etc.), the accent pattern 3/4 + 2/4 is the default. 
   %%  NB: the initialisation constraints for both beats and accents are delayed until beatNumber is determined (i.e. in a CSP the beatNumber of each beat is either predetermined or the distribution strategy should determine all beatNumbers before other parameter values which are related to the measure by constraints).
   %%
   %% Note that the class UniformMeasures is more comprehensive than this class.
   %% */
   class Measure from Score.temporalElement 
      feat !MeasureType:unit
	 label:measure

	 %% ?? in all measures the beatDuration is always constant -- I can't think of any exception
      attr beatNumber beatDuration % params
	 beats beatsFS
	 accents accentsFS

	 %% !!?? filter out timing params?? at least offsetTime?
      meth init(beatNumber:BeatNr<=_
		beatDuration:BeatDuration<=_
		%% beats:Beats<=_ accents:Accents<=_
		%%
		%% AIs.4 = [1 3] means: a measure with beatNumber 4 has an accent on the first and on the third beat.
		accentIdxDB:AIs<=accents
		...) = M
	 DefaultAIs = accents(1:[1] % single (1/2, 1/4, 1/8)
			      2:[1] % duple (2/2, 2/4, 2/8)
			      3:[1] % triple (3/2, 3/4, 3/8)
			      4:[1 3] % quadruple (4/2, 4/4, 4/8)
			      %% no alternative: quintuple 2/4 + 3/4
			      5:[1 4] % quintuple 3/4 + 2/4
			      6:[1 4] % compound duple (6/2, 6/4, 6/8)
			      7:[1 3 5] % again, only one version
			      8:[1 3 5 7]
			      9:[1 4 7] % compound triple (9/4, 9/8)
			      12:[1 4 7 10] % compound quadruple (12/4, 12/8, 12/16)
			     )
	 FullAIs = {Adjoin DefaultAIs AIs}
      in
	 Score.temporalElement, {Record.subtractList M
				 [beatNumber beatDuration accentIdxDB]}
	 @beatNumber = {New Score.parameter init(value:BeatNr info:beatNumber)}
	 @beatDuration = {New Score.timeParameter init(value:BeatDuration info:beatDuration)}
	 {self bilinkParameters([@beatNumber @beatDuration])}
	 {@beatDuration getUnit($)} = {self getTimeUnit($)}
	 %%
	 %% init constraints: 
	 %%
	 BeatNr = {FD.decl}	% !! needed ?
	 BeatDuration = {FD.decl} % !! needed ?
	 %% ?? not already FD int in Score.temporalElement, init
	 {self getDuration($)} = {FD.decl} % !!?? needed ? 
	 {self getDuration($)} =: BeatNr * BeatDuration
	 %% ?? Too strict? If I need a non-meter section I should
	 %% introduce an explicit class
	 {self getOffsetTime($)} = 0
	 %%
	 %% !! @beats and @accents are only constrained after BeatNr is determined
	 thread
	    AccentIdxs
	 in
	    if {HasFeature FullAIs BeatNr}
	    then AccentIdxs = FullAIs.BeatNr
	    else raise error(undefinedAccentsForBeatNr
			     unit(Measure accentIdxDB:FullAIs beatNumber:BeatNr))
		 end
	    end
	    %% @beats is arithmetic series: length is beatNumber, starts
	    %% with 0, difference beatDuration
	    %% (i.e. n-th beat is n * beatDuration), max is
	    %% measureDuraion-1
	    @beats = {FD.list BeatNr 0#({self getDuration($)}-1)}
	    @beats.1 = 0
	    %{List.last @beats} <: {self getDuration($)}
	    {Pattern.arithmeticSeries @beats BeatDuration}
	    %% beatsFS is matched FS (used by constraint onBeatR)
	    @beatsFS = {FS.var.decl}
	    {FS.int.match @beatsFS @beats}
	    %% @accents are the beats at AccentIdx in @beats, measured in time units
	    @accents = {FD.list {Length AccentIdxs} 0#({self getDuration($)}-1)}
	    for Idx in AccentIdxs
	       Accent in @accents
	    do
	       Accent = {Nth @beats Idx}
	    end
	    %% accentsFS is matched FS (e.g., used by constraint onAccentR)
	    @accentsFS = {FS.var.decl}
	    {FS.int.match @accentsFS @accents}
	 end
      end
      % accessors
      meth getBeatNumber(?X)
	 X = {@beatNumber getValue($)}
      end
      meth getBeatNumberParameter(?X)
	 X = @beatNumber
      end
      meth getBeatDuration(?X)
	 X = {@beatDuration getValue($)}
      end
      meth getBeatDurationParameter(?X)
	 X = @beatDuration
      end
      /** %% Returns the relative startTimes of the beats in the measure as a list of FD ints.
      %% */
      meth getBeats(?X)
	 X = @beats
      end    
      /** %% Returns the relative startTimes of the beats in the measure as a FS.
      %% */
      meth getBeatsFS(?X)
	 X = @beatsFS
      end
      /** %% Returns the relative startTimes of the strong beats in the measure as a list of FD ints. Accents only accessible after both beatNumber and beatDuration are determined (at which points the accents are determined as well).
      %% */
      meth getAccents(?X)
	 X = @accents
      end
      /** %% Returns the relative startTimes of the strong beats in the measure as a FS. Accents only accessible after both beatNumber and beatDuration are determined (at which points the accents are determined as well).
      %% */
      meth getAccentsFS(?X)
	 X = @accentsFS
      end
      
%        %% 
%       %% 
%       %% !!?? put this in TimeMixin in ScoreCore.oz?
%       meth getTicksPerBeat(?X)
% 	 case {self getTimeUnit($)}
% 	 of beats then X=1
% 	 [] beats(N) then X=N
% 	 else raise error(self timeUnitsNotInBeats) end
% 	 end
%       end
      

%      meth getAttributes(?Xs)
%	 Xs = {Append
%	       Score.temporalElement, getAttributes($)
%	       [beatNumber beatDuration beats beatsFS accents accentsFS]}
%      end
%       meth toInitRecord(?X exclude:Excluded<=nil)
% 	 X = {Record.subtractList
% 	      {Adjoin
% 	       Score.temporalElement, toInitRecord($ exclude:Excluded)
% 	       {self makeInitRecord($ [beatNumber#getBeatNumber#noMatch
% 				       beatDuration#getBeatDuration#noMatch
% 				       % accents#getAccents#noMatch
% 				       % beats#getBeats#noMatch
% 				      ])}}
% 	      %% timing implicit in beatNumber + beatDuration (shall I
% 	      %% keep startTime?)
% 	      {Append [endTime duration startTime]
% 	       Excluded}}
%       end      
      meth getInitInfo($ ...)
	 %% !!?? should timing only be measured in beatNumber + beatDuration, i.e. the other temporal params of Score.temporalElement are excluded? Should I at least keep startTime?
	 unit(superclass:Score.temporalElement
	      args:[beatNumber#getBeatNumber#noMatch
		    beatDuration#getBeatDuration#noMatch
		    %% accents#getAccents#noMatch
		    %% beats#getBeats#noMatch
		   ])
      end
      
   end

   fun {IsMeasure X}
      {Score.isScoreObject X} andthen {HasFeature X MeasureType}
   end 

   
   %%
   %% some flaws in design (see Measure-test.oz), temporarily commented
   %%
   
%    local
%       proc {TimeInMeasure Time MStart ?RelTime}
% 	 %% !! failure if Time < MyMeasure start
   %%
   %% Better alternative: transform relativ startTime of beats/accents into absolute time by, e.g., beatStartTime + measureStartTime
% 	 RelTime = {FD.decl}
% 	 RelTime =: Time - MStart
%       end
%    in
%       %% !! doc
%       class MeasureSeq from Score.sequential
% 	 feat !MeasureSeqType:unit
% 	    label:measureSeq

% 	    %% MeasureSeq contains only plain Measures. To contrain a more complex metric hierachy, I either formulate constraints on the MeasureSeq and the contained Measures directly (e.g. a pattern constrain can force some regular alteration of measures) or I define additional higher-level classes which again run in parallel to the sounding score and the MeasureSeq to represent, e.g., measure groups in a way with allows to freely constrain the metric hierarchy.
% 	    %%
% 	    %% ? n:N,
% 	    %% Measure args (dann implizit dies gl. bei allen Measures)
% %       meth init(...) = M	
% % 	 Score.sequential, {Record.subtractList M
% % 			    nil}
	 
% % 	 %% ?? Too strict? If I need a non-meter section I should
% % 	 %% introduce an explicit class
% % 	 {self getOffsetTime($)} = 0
% %       end
   
%    %% B=1 <-> Time equals the start time of some measure in UniformMeasures.
%   
% 	 meth onMeasureStartR(Time B)
% 	    {Pattern.disjAll
% 	     {self mapItems($ proc {$ MyMeasure B} 
% 				 B = {FD.int 0#1}
% 				 B =: ({MyMeasure getStartTime($)} =: Time)
% 			      end)}
% 	     B}
% 	 end

% 	  %% B=1 <-> Time equals some strong beat in of some measure in UniformMeasures.
% 	 %% NB: onAccentR blocks until all beatNumber of all Measures in self are determined.
% 	 %% 
% 	 %% !! failure if Time < some MyMeasure start 
% 	 meth onAccentR(Time B)
% 	    %% !!?? implicitly constraints/determines beatDuration of preceeding measure(s)
% 	    {Pattern.disjAll
% 	     {self mapItems($ proc {$ MyMeasure B}
% 				 MeasureStart = {MyMeasure getStartTime($)}
% 			      in
% 				 B = {FD.int 0#1}
% 				 %% !!?? does FS.reified.include determine stuff too easily?
% 				 B =: {FS.reified.include
% 				       {TimeInMeasure Time MyMeasure}
% 				       {MyMeasure getAccentsFS($)}}
% 			      end)}
% 	     B}
% 	 end

% 	 %% B=1 <-> Time equals some beat in of some measure in UniformMeasures.
% 	 %% NB: onBeatR blocks until all beatNumber of all Measures in self are determined.
% 	 %% 
% 	 %% !! failure if Time < some MyMeasure start 
% 	 meth onBeatR(Time B)
% 	    {Pattern.disjAll
% 	     {self mapItems($ proc {$ MyMeasure B}
% 				 MeasureStart = {MyMeasure getStartTime($)}
% 			      in
% 				 B = {FD.int 0#1}
% 				 B =: {FS.reified.include
% 				       {TimeInMeasure Time MyMeasure}
% 				       {MyMeasure getBeatsFS($)}}
% 			      end)}
% 	     B}
% 	 end

% %       %% Between Start and End starts a new measure
% %       meth syncopatedR(Start End B)
% %       end

% 	 %% !!?? why is this needed only to have the correct label?
% 	 %%
% 	 %% !!?? info:nil could be left out
% 	 %%
% 	 %% !!?? timeUnit is left out!
% 	 meth toInitRecord(?X exclude:Excluded<=nil)
% 	    X = {Adjoin
% 		 Score.sequential, toInitRecord($ exclude:Excluded)
% 		 {Record.subtractList
% 		  {self makeInitRecord($ nil)}
% 		  Excluded}}
% 	 end
      
%       end
%    end
%    fun {IsMeasureSeq X}
%       {Score.isScoreObject X} andthen {HasFeature X MeasureSeqType}
%    end 


   
   local      
      /** %% B=1 <=> Time is no less that the start time of MyMeasures.
      %% */
      % proc {GreaterEqualStartTime Time MyMeasures B}
      % 	 B = (Time >=: {MyMeasures getStartTime($)})
      % end
      proc {LessEqualEndTime Time MyMeasures B}
      	 B = (Time =<: {MyMeasures getEndTime($)})
      end
      
      /** %% B=1 <=> Time is no less that the start time and no more than end time of MyMeasures.
      %% */
      proc {IsWithinMeasures Time MyMeasures ?B}
	 B = {FD.int 0#1}
	 B = {FD.conj (Time >=: {MyMeasures getStartTime($)})
	      (Time =<: {MyMeasures getEndTime($)})}
      end
      /** %% B=1 <=> Start is before and End is after MyMeasures.
      %% */
      proc {IsSurroundingMeasures Start End MyMeasures ?B}
	 B = {FD.int 0#1}
	 B = {FD.conj (Start =<: {MyMeasures getStartTime($)})
	      (End >=: {MyMeasures getEndTime($)})}
      end

      
      /** %% Expects an FD int Time and a uniform measures instance MyMeasures and returns an FD int = Time - {MyMeasures getStartTime($)}. 
      %% */
      proc {TimeInUniformMeasures Time MyMeasures ?TimeAux}
	 TimeAux = {FD.decl}
	 TimeAux =: Time - {MyMeasures getStartTime($)}
      end

      /** %% Expects an FD int Time and a uniform measures instance MyMeasures and returns an FD int that is the time within a single measure of MyMeasures.
      %% NOTE: results in failure if Time < {MyMeasures getStartTime($)}
      %% */
      %% blocks until measure duration is determined (i.e. both beatNumber and beatDuration are determined)
      proc {TimeInMeasure Time MyMeasures ?RelTime}
	 RelTime = {FD.decl}
	 RelTime =: {FD.modI {TimeInUniformMeasures Time MyMeasures} {MyMeasures getMeasureDuration($)}}
      end
   in
     
      /** %% UniformMeasures is a silent timed element representing a constant meter of a score for the duration of the UniformMeasures. The parameter 'n' represents the number of measures. The parameter 'beatNumber' and 'beatDuration' represent the meter as in Measure. The further measure parameters and features (e.g. 'beats' and 'accents') are accessible by the same methods as in Measure. However, there is a difference between getDuration and getMeasureDuration: the first returns the duration of the whole UniformMeasures while the second the duration of a single measure.
      %% The similar class MeasureSeq allows to represent a sequence of measures which differ in beatNumber or beatDuration. However, this makes the constraints for MeasureSeq less efficient then the constraints for UniformMeasures.
      %%
      %% NB: The constraints defined for UniformMeasures required both BeatNr and BeatDuration to be determined.
      %%
      %% See the Measures doc for more info.
      %% */
      %%
      %% ?? param n not necessarily needed if the duration of UniformMeasures is not needed -- I may have a sequence of UniformMeasures for different parts of the score and then I really need n.
      class UniformMeasures from Score.temporalElement 
	 feat !UniformMeasuresType:unit
	    label:uniformMeasures

	 attr n beatNumber beatDuration % params
	    measure % privat (o accessors def.)
	 
	    /** %% ... Further init arguments: accentIdxDB (see Measure) ...
	    %% If the args n, beatNumber, or beatDuration are left unset, you must set them later with their respective accessor methods.
	    %% */
	    %% !!?? filter out offsetTime
	 meth init(n:N<=_
		   beatNumber:BeatNr<=_
		   beatDuration:BeatDuration<=_
		   ...) = M
	    Score.temporalElement, {Record.subtractList M
				    [n beatNumber beatDuration accentIdxDB]}

	    @n = {New Score.parameter init(value:N info:n)}
	    %% !! beatNumber and beatDuration are actually @measure parameters. They are 'mirrored' into UniformMeasures to ensure these params are accessible by the usually means (e.g. for distribution). -- I am not happy with this design, just costs more memory during search..
	    @beatNumber = {New Score.parameter init(value:BeatNr info:beatNumber)}
	    @beatDuration = {New Score.timeParameter init(value:BeatDuration
							  info:beatDuration)}
	    {self bilinkParameters([@n @beatNumber @beatDuration])}
	 
	    @measure = {Score.makeScore {Record.subtractList M
					 [n offsetTime startTime endTime duration]}
			unit(init:Measure)}
	    %% to determine timing params of measure
	    {@measure getStartTime($)} = 0
	    {@measure getTimeUnit($)} = {self getTimeUnit($)}
	    {@beatDuration getUnit($)} = {self getTimeUnit($)}
	    %%
	    %% initConstraint
	    %%
	    thread 		% in case of missing information..
	       BeatNr = {FD.decl}	% !! needed ?
	       BeatDuration = {FD.decl} % !! needed ?
	       %% ?? not already FD int in Score.temporalElement, init
	       {self getDuration($)} = {FD.decl} % !!?? needed ? 
	       {self getDuration($)} =: BeatNr * BeatDuration * N
	       %% ?? Too strict? If I need a non-meter section I should
	       %% introduce an explicit class
	       {self getOffsetTime($)} = 0
	    end
	 end
      
	 meth getN(?X)
	    X = {@n getValue($)}
	 end
	 meth getNParameter(?X)
	    X = @n
	 end
	 meth getBeatNumber(?X)
	    X = {@beatNumber getValue($)}
	 end
	 meth getBeatNumberParameter(?X)
	    X = @beatNumber
	 end
	 meth getBeatDuration(?X)
	    X = {@beatDuration getValue($)}
	 end
	 meth getBeatDurationParameter(?X)
	    X = @beatDuration
	 end      
	 meth getBeats(?X)
	    X = {@measure getBeats($)}
	 end    
	 meth getBeatsFS(?X)
	    X = {@measure getBeatsFS($)}
	 end
	 meth getAccents(?X)
	    X = {@measure getAccents($)}
	 end
	 meth getAccentsFS(?X)
	    X = {@measure getAccentsFS($)}
	 end
	 /** %% Returns the duration of a single measure. The duration of the whole UniformMeasures is returned by getDuration.
	 %% */
	 meth getMeasureDuration(?X)
	    X = {@measure getDuration($)}
	 end
	 meth getMeasureDurationParameter(?X)
	    X = {@measure getDurationParameter($)}
	 end


	 /** %% I is the index of the measure at Time (one-based). A measure starts at its start time and ends before its end time. For instance, the index for the first measure is 1, starting at Time 0. Measure 2 starts at MeasureDuration. I and Time are FD integers.
	 %% If Time is outside the boundaries of self, then I = 0.
	 %% */
	 meth getMeasureAt(I Time)
	    thread
	       if {IsWithinMeasures Time self} == 1
	       then 
		  %% !!?? is there some cheaper implementation
		  MDur = {self getMeasureDuration($)}
		  TimeAux = {TimeInUniformMeasures Time self}
	       in
		  (I - 1) * MDur =<: TimeAux
		  I * MDur >: TimeAux
	       else I = 0
	       end
	    end
	 end

	 /** %% I is the index of the accent at Time (one-based). Accents are only counted within individual measures (the first accent in the 2nd measure is again index 1). If Time is between accents then the index of the accent before Time is returned.
	 %% If Time is outside the boundaries of self, then I = 0.
	 %% Method delayed until measure duration is determined (i.e. both beatNumber and beatDuration are determined).
	 %% */
	 meth getAccentInMeasureAt(I Time)
	    thread
	       if {IsWithinMeasures Time self} == 1
	       then 
		  RelTime = {TimeInMeasure Time self}
		  Accents = {self getAccents($)}
	       in
		  thread
		     I = {LUtils.findPosition {LUtils.matTrans
					       [Accents
						{Append Accents.2 [{self getMeasureDuration($)}]}]}
			  fun {$ [A1 A2]}
			     (A1 =<: RelTime) == 1 andthen
			     (A2 >: RelTime) == 1
			  end}
		  end
	       else I = 0
	       end
	    end
	 end
	 
	 /** %% I is the index of the beat at Time (one-based). Beats are counted across all measures in self. If Time is between beats then the index of the last beat before is returned.
	 %% If Time is outside the boundaries of self, then I = 0.
	 %% */
	 meth getBeatAt(I Time)
	    thread
	       if {IsWithinMeasures Time self} == 1
	       then 
		  %% !!?? is there some cheaper implementation
		  BDur = {self getBeatDuration($)}
		  TimeAux = {TimeInUniformMeasures Time self}	       
	       in
		  (I - 1) * BDur =<: TimeAux
		  I * BDur >: TimeAux
	       else I = 0
	       end
	    end
	 end
	 /** %% I is the index of the beat at Time (one-based). Beats are only counted within individual measures (the first beat in the 2nd measure is again index 1). If Time is between beats then the index of the beat before Time is returned.
	 %% Constraint blocks until beatNumber is determined.
	 %% If Time is outside the boundaries of self, then I = 0.
	 %% */
	 meth getBeatInMeasureAt(I Time)
	    TotalI = {FD.decl}
	 in
	    {self getBeatAt(TotalI Time)}
	    I = {FD.modI TotalI {self getBeatNumber($)}}
	 end
	 
	 
	 /** %% B=1 <-> Time equals the start time of some measure in UniformMeasures. Time is FD int, B is implicitly constrained to 0/1-int.
	 %%
	 %% NB: blocks until Time is known to be at least size of start time of self.
	 %% NB: Constraint blocks until both beatNumber and beatDuration are determined.
	 %% NB: method does not take n into account -- to limit truth value B to the actual time span within start and end time of UniformMeasures add necessary constraints outside of this method.
	 %% */
	 meth onMeasureStartR(B Time)
	    %% for old version: NB: constraint blocks until measure duration is determined (i.e. both beatNumber and beatDuration are determined). There is no propagation with neither beatNumber and beatDuration and Time or B.
% 	 B = {FD.int 0#1}
% 	 B =: ({TimeInMeasure Time self}
% 	       =: {self getStartTime($)})
	    %%
	    thread
	       if {IsWithinMeasures Time self} == 1
	       then 
		  B = {FD.int 0#1}
		  B =: ({FD.modI {TimeInUniformMeasures Time self} {self getMeasureDuration($)}} =: 0)
	       else B = 0
	       end
	    end
	 end
	 /** %% Variant of onMeasureStartR which does domain propagation (which can be very expensive). However, propagation of Time does only happen after B got determined.
	 %%
	 %% !!?? constraint suspends and performs OK if it first calls {Browse Time}?
	 %% */
	 %% !! MeasureDuration is constrained anyway in Measure -- here I add the same constraints with domain propagation (however, often MeasureDuration is determined soon anyway).
	 meth onMeasureStartDR(B Time)	 
	    thread
	       if {IsWithinMeasures Time self} == 1
	       then 
		  MeasureDuration = {self getMeasureDuration($)}
		  RelTime = {FD.decl}
	       in
		  MeasureDuration = {FD.timesD {self getBeatNumber($)} {self getBeatDuration($)}}
		  RelTime = {FD.modD {TimeInUniformMeasures Time self} MeasureDuration}
		  B = {FD.int 0#1}
		  B =: (RelTime =: 0)
	       else B = 0
	       end
	    end
	 end
	 /** %% B=1 <-> Time equals some strong beat in some measure in UniformMeasures. Time is FD int, B is implicitly constrained to 0/1-int.
	 %%
	 %% NB: Constraint blocks until both beatNumber and beatDuration are determined.
	 %% NB: method does not take n into account -- to limit truth value B to the actual time span within start and end time of UniformMeasures add necessary constraints outside of this method.
	 %% */
	 meth onAccentR(B Time)
	    %% Constraint blocks until measure duration is determined (i.e. both beatNumber and beatDuration are determined). There is no propagation with neither beatNumber and beatDuration and Time or B. 
	    %% !! constrain performs probably very little propagation: Time -- transformed into measure only by bounds propagation -- is constrained whether it is element in set...
	    thread
	       if {IsWithinMeasures Time self} == 1
	       then 
		  B = {FD.int 0#1}
		  B = {FS.reified.include
		       {TimeInMeasure Time self}
		       {self getAccentsFS($)}}
	       else B = 0
	       end
	    end
	    %%
	    %% Alternative implementation using AccentDur -- does not work, because the IOI between accents may be irregular (e.g., for 5/4 time) and thus a single AccentDur cannot work.
	    %%
      % 	 Accents = {self getAccents($)}
      % 	 %% AccentDur: time between two accented beats
      % 	 AccentDur = {FD.decl}
      % in
      % 	 %% shall I put AccentDur as feature/attribute into measure itself?
      % 	 if {Length Accents} > 1 then 
      % 	    AccentDur =: {Nth Accents 2} - Accents.1
      % 	 else AccentDur = {self getMeasureDuration($)}
      % 	 end
      % 	 B = {FD.int 0#1}
      % 	 B =: ({FD.modI Time AccentDur} =: 0)
	 end
	 % /** %% Variant of onAccentR which does domain propagation (which can be very expensive). However, propagation of Time does only happen after B got determined. 
	 % %%
	 % %% !!?? constraint suspends and performs OK if it first calls {Browse Time}?
	 % %%
	 % %% BUGGY -- see comments in alternative implementation in onAccentR
	 % %% */
	 % meth onAccentDR(B Time)
	 %    AccentDur = {FD.decl}
	 %    RelTime = {FD.decl}
	 % in
	 %    AccentDur = {FD.minusD {Nth {self getAccents($)} 2} {self getAccents($)}.1}
	 %    RelTime = {FD.modD Time AccentDur}
	 %    B = {FD.int 0#1}
	 %    B =: (RelTime =: 0)
	 % end
	 /** %% B=1 <-> Time equals some beat of some measure in UniformMeasures. For instance, in case beat note value is halve note, that B=1 means that Time is on a halve-note onset or on a strong quarter-note onset.
	 %% Time is FD int, B is implicitly constrained to 0/1-int.
	 %%
	 %% NB: method does not take n into account -- to limit truth value B to the actual time span within start and end time of UniformMeasures add necessary constraints outside of this method.
	 %% */
	 meth onBeatR(B Time)
	    %% for old version with {self getBeatsFS($)}: NB: constraint blocks until measure duration is determined (i.e. both beatNumber and beatDuration are determined). There is no propagation with neither beatNumber and beatDuration and Time or B.
	    %% !! constrain performs probably very little propagation: Time -- transformed into measure only by bounds propagation -- is constrained whether it is element in set...
% 	    B = {FD.int 0#1}
% 	    B =: {FS.reified.include
% 		  {TimeInMeasure Time self}
% 		  {self getBeatsFS($)}}
	    %%
	    thread
	       if {IsWithinMeasures Time self} == 1
	       then 
		  B = {FD.int 0#1}
		  B =: ({FD.modI {TimeInUniformMeasures Time self} {self getBeatDuration($)}} =: 0)
	       else B = 0
	       end
	    end
	 end
	 /** %% Variant of onBeatR which does domain propagation (which can be very expensive). However, propagation of Time does only happen after B got determined.
	 %% */
	 %% !!?? constraint suspends and performs OK if it first calls {Browse Time}?
	 meth onBeatDR(B Time)
	    thread
	       if {IsWithinMeasures Time self} == 1
	       then 
		  RelTime = {FD.decl}
	       in
		  RelTime = {FD.modD {TimeInUniformMeasures Time self} {self getBeatDuration($)}}
		  B = {FD.int 0#1}
		  B =: (RelTime =: 0)
	       else B = 0
	       end
	    end
	 end

	 /** %% B=1 <-> an event lasting from Start to End is a syncope at measure level: Start and End fall in different measures (either within self or beyond).
	 %% Note: if both Start and End are outside self then B = 0 (even though the respective event might be a syncope at measure level for other uniform measures instances).
	 %% */
	 meth overlapsBarlineR(B Start End)
	    thread 
	       if {IsWithinMeasures Start self} == 1
	       then
		  if {LessEqualEndTime End self} == 1
		     %% Start and End within self
		  then 
		     StartBar = {FD.decl} % index of bar of Start
		     EndBar = {FD.decl}
		  in
		     B = {FD.int 0#1}
		     {self getMeasureAt(StartBar Start)}
		     {self getMeasureAt(EndBar End)}
		     B =: {FD.conj {FD.nega {self onMeasureStartR($ Start)}}
			   {FD.conj (StartBar \=: EndBar)
			    %% exclude case that event lasts exactly after the end of StartBar 
			    {FD.nega {FD.conj {self onMeasureStartR($ End)}
				      (EndBar - StartBar =: 1)}}}}
		     %% overlapping end of self
		  else B = 1
		  end
	       else 
		  if {IsWithinMeasures End self} == 1 orelse
		     {IsSurroundingMeasures Start End self} == 1
		     %% overlapping start of self or start before and end after measure
		  then B = 1
		     %% both Start and End outside self, either before or after
		  else B = 0
		  end
	       end
	    end
	 end

	 /** %% Same as overlapsBarlineR
	 %% */
	 meth measureSyncopationR(B Start End)
	    {self overlapsBarlineR(B Start End)}
	 end

	 /** %% B=1 <-> an event lasting from Start to End is a syncope at accent level: Start is not on an accent, and Start and End fall between different accents.
	 %% Note: if both Start or End are outside self then B = 0 (even though the respective event might be a syncope in other uniform measures instances).
	 %% BUG: B=0 for an event that is a syncope at accent level, but its duration is some multiple of the measure duration.
	 %% */
	 %% BUG: seems not always to work -- debug carefully
	 meth accentSyncopationR(B Start End)
	    thread
	       if {IsWithinMeasures Start self} == 1
	       then
		  if {LessEqualEndTime End self} == 1
		     %% Start and End within self
		  then
		     StartAcc = {FD.decl} % index of beat of Start
		     EndAcc = {FD.decl}
		  in
		     B = {FD.int 0#1}
		     {self getAccentInMeasureAt(StartAcc Start)}
		     {self getAccentInMeasureAt(EndAcc End)}
		     B =: {FD.conj {FD.nega {self onAccentR($ Start)}}
			   {FD.conj (StartAcc \=: EndAcc)
			    %% exclude case that event lasts exactly after the end of StartAcc 
			    {FD.nega {FD.conj {self onAccentR($ End)}
				      %% BUG: note that getAccentInMeasureAt is measured only within bar
				      (EndAcc - StartAcc =: 1)}}}}
		     %% overlapping end of self
		  else B = 1
		  end
	       else 
		  if {IsWithinMeasures End self} == 1 orelse
		     {IsSurroundingMeasures Start End self} == 1
		     %% overlapping start of self or start before and end after measure
		  then B = 1
		     %% both Start and End outside self, either before or after
		  else B = 0
		  end
	       end
	    end
	 end
	 
	 /** %% B=1 <-> an event lasting from Start to End is a syncope at beat level: Start is not on a beat, and Start and End fall between different beats.
	 %% Note: if both Start or End are outside self then B = 0 (even though the respective event might be a syncope in other uniform measures instances).
	 %% */
	 %% BUG: seems not always to work -- debug carefully
	 meth beatSyncopationR(B Start End)
	    thread 
	       if {IsWithinMeasures Start self} == 1
	       then
		  if {LessEqualEndTime End self} == 1
		     %% Start and End within self
		  then
		     StartBeat = {FD.decl} % index of beat of Start
		     EndBeat = {FD.decl}
		  in
		     B = {FD.int 0#1}
		     {self getBeatAt(StartBeat Start)}
		     {self getBeatAt(EndBeat End)}
		     B =: {FD.conj {FD.nega {self onBeatR($ Start)}}
			   {FD.conj (StartBeat \=: EndBeat)
			    %% exclude case that event lasts exactly after the end of StartBeat 
			    {FD.nega {FD.conj {self onBeatR($ End)}
				      (EndBeat - StartBeat =: 1)}}}}
		     %% overlapping end of self
		  else B = 1
		  end
	       else 
		  if {IsWithinMeasures End self} == 1 orelse
		     {IsSurroundingMeasures Start End self} == 1
		     %% overlapping start of self or start before and end after measure
		  then B = 1
		     %% both Start and End outside self, either before or after
		  else B = 0
		  end
	       end
	    end
	 end
	 
%      meth getAttributes(?Xs)
%	 Xs = {Append
%	       Score.temporalElement, getAttributes($)
%	       [n measure]}
%      end
%       meth toInitRecord(?X exclude:Excluded<=nil)
% 	 X = {Record.subtractList
% 	      {Adjoin
% 	       Score.temporalElement, toInitRecord($ exclude:Excluded)
% 	       {self makeInitRecord($ [n#getN#noMatch
% 				       beatNumber#getBeatNumber#noMatch
% 				       beatDuration#getBeatDuration#noMatch
% 				       % accents#getAccents#noMatch
% 				       % beats#getBeats#noMatch
% 				      ])}}
% 	      Excluded
% 	      %% timing implicit in beatNumber + beatDuration (shall I
% 	      %% keep startTime?)
% 		 % {Append [endTime duration startTime]
% 		 %  Excluded}
% 	     }
%       end
           
	 meth getInitInfo($ ...)
	    %% !!?? should timing only be measured in beatNumber + beatDuration, i.e. the other temporal params of Score.temporalElement are excluded? Should I at least keep startTime?
	    unit(superclass:Score.temporalElement
		 args:[n#getN#noMatch
		       beatNumber#getBeatNumber#noMatch
		       beatDuration#getBeatDuration#noMatch
		       %% accents#getAccents#noMatch
		       %% beats#getBeats#noMatch
		      ])
	 end
      end
   end
   fun {IsUniformMeasures X}
      {Score.isScoreObject X} andthen {HasFeature X UniformMeasuresType}
   end
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Notes with accent rating parameter
%%%
  
   /** %% [abstract mixin class] AccentRatingMixin extends note classes with an accent rating parameter. No further constraints are applied.
   %% */
   class AccentRatingMixin
      feat !AccentRatingType:unit
      attr accentRating 
      meth initAccentRatingMixin(accentRating:AR<=_) = M
	 @accentRating = {New Score.parameter init(value:AR info:accentRating)}
	 {self bilinkParameters([@accentRating])} 
      end
      meth getAccentRating(X)
	 X = {@accentRating getValue($)}
      end
      meth getAccentRatingParameter(X)
	 X= @accentRating
      end
   end
   fun {IsAccentRatingMixin X}
      {Score.isScoreObject X} andthen {HasFeature X AccentRatingType}
   end

   /** %% [concrete class constructor] Expects a note class, and returns this class extended by an accent rating parameter (see AccentRatingMixin).
   %% */
   fun {MakeAccentRatingClass SuperClass}
      class $ from SuperClass AccentRatingMixin
	 meth init(accentRating:AR<=_ ...) = M
	    SuperClass, {Record.subtract M accentRating}
	    AccentRatingMixin, initAccentRatingMixin(accentRating:AR)
	 end
	 meth getInitInfo($ ...)       
	    unit(superclass:SuperClass
		 args:[accentRating#getAccentRating#noMatch]) 
	 end
      end
   end

   /** %% [concrete class] The standard note class extended with an accent rating parameter.
   %% */
   Note = {MakeAccentRatingClass Score.note}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% old code and documentation kept in case of some redesign or alternative defs in future
%%%
 

   %%
   %% A more general (and more costly) way to constrain the relation between Measure BeatNr and Accents (here Accents mean AccentIdxs). This is kep here as a documentation, in case...
   %%
   /** %% Imposes constraint on self which associates certain BeatNr values to their typical Accent pattern in common praxis. This constraint is applied to self if the init arg isClassic equals true, which is the default.
   %% For non-classical measure types (e.g. 9/8 as 2/8 + 2/8+ 2/8 + 3/8) don't use this constraint (i.e. init arg isClassic=false) and apply alternative constraints.
   %% Accents are 0 based, i.e. an accent at 0 is an accent at the measure start.
   %% */
%       meth classicAccents
% 	 %% !!?? could selection constraints help here to have better propagation (e.g. defining a database of beatNumber and accent patterns and deciding for an index)
% 	 %%
% 	 BeatNr = {self getBeatNumber($)}
% 	 Accents = {self GetAccents($)}
%       in
% 	 {Pattern.disjAll
% 	  [{FD.conj 
% 	    (BeatNr=:4) % quadruple (4/2, 4/4, 4/8)
% 	    {FS.reified.equal Accents {FS.value.make [0 2]}}}
% 	   {FD.conj 
% 	    (BeatNr=:3) % triple (3/2, 3/4, 3/8)
% 	    {FS.reified.equal Accents {FS.value.make [0]}}}
% 	   {FD.conj 
% 	    (BeatNr=:2) % duple (2/2, 2/4, 2/8)
% 	    {FS.reified.equal Accents {FS.value.make [0]}}}
% 	   {FD.conj 
% 	    (BeatNr=:1) % single (1/2, 1/4, 1/8)
% 	    {FS.reified.equal Accents {FS.value.make [0]}}}
% 	   {FD.conj 
% 	    (BeatNr=:6) % compound duple (6/2, 6/4, 6/8)
% 	    {FS.reified.equal Accents {FS.value.make [0 3]}}}
% 	   {FD.conj 
% 	    (BeatNr=:9) % compound triple (9/4, 9/8)
% 	    {FS.reified.equal Accents {FS.value.make [0 3 6]}}}
% 	   {FD.conj 
% 	    (BeatNr=:12) % compound quadruple (12/4, 12/8, 12/16)
% 	    {FS.reified.equal Accents {FS.value.make [0 3 6 9]}}}
% 	   {FD.conj 
% 	    (BeatNr=:5) % quintuple 2/4 + 3/4
% 	    {FS.reified.equal Accents {FS.value.make [0 2]}}}
% 	   {FD.conj 
% 	    (BeatNr=:5) % quintuple 3/4 + 2/4
% 	    {FS.reified.equal Accents {FS.value.make [0 3]}}}
% 	   %%
% 	   %% further meters may be defined here (adjust else case):
% 	   %%
% 	   %% else case
% 	   {FD.conj 
% 	    {FD.disj
% 	     {FS.reified.include BendBeatNr {FS.value.make [7 8 10 11]}}
% 	     (BendBeatNr>:12)}
% 	    {FS.reified.equal Accents {FS.value.make [0]}}}]
% 	  1}
%       end
   %%

   
   %%
   %% Nachdenken:
   %%
   %% attr beatNumber und beatDuration definieren measure vollstaendig (2 entscheidungen noetig)
   %%
   %% implizit:
   %%
   %% * beats (list, tuple of FD or FS): relative startZeiten der beats in measure
   %%   Formalism: arithmetic series: number beatNumber, starts with 0, difference beatDuration
   %%
   %% * accents (list, tuple of FD or FS): either relative startZeiten der akzentuierten/betonten beats oder indices der akzentuierten beats.
   %%   Formalism: indices are selected dependent on beatNumber. the relative startTimes are then the beats at these indices
   %%
   %%
   %% Problemchen: wenn ich beats und accents entsprechend modelliere und per default constraine, dann gibt es keine billigere Variante mit weniger Propagatoren mehr.. -- verwende extra alternative Klasse UniformMeasureSeq instead of MeasureSeq.
   %%
   %%
   %% Benoetigte Constraints:
   %%
% %% * propagiere beatNumber zu beats length/card (and indirectly to accents)
% %%
% %%   -> erledigt, wenn beatNumber erst determiniert sein muss
% %%
% %%   - FS: FS.card
% %%
% %%   - tuple: RecordC.width (what effect has this propagator?)
% %%
% %%   - list/stream ??
   %%
   %% * numerische constraints (arithmetic series),
   %%
   %%   - FS ?? (FS.forAllIn needs determined set)
   %%
   %%   - OK: list/stream: Pattern constraint 
   %%
   %%   - OK: tuple ?? (Record.forAll blocks for undetermined RecordC. However, when I somehow add features to RecordC I know these (and may also monitor them))
   %%
% %% * propagiere beatNumber zu decision for accent indices into beats
   %%
   %%   Simplification: no constraint and no special case for different 5 meters: optional arg is tuple with accentPatterns (features represent beatNumber) and once beatNumber is determined the appropriate accentPattern is taken out of the tuple -- keep old constraint solution in a comment as an alternative more general proposal

   %%
% %%
% %%   -> erledigt, wenn beatNumber erst determiniert sein muss
% %%
% %%   - FS:
% %%
% %%      + large reified disj using FS.reified.equal and others
% %%
% %%      + Select from database with entries like unit(beatNumber accents)
% %%
% %%   - Tuple/List ?? (option as soon as beatNumber is determined: or combinator, also selection constraints)
% %%   
   %%
   %% * access accents in beats dependent on indices into beats,
   %%
   %%   - FS: ?? (how to access the ith element in a FS as a FD int -- there is no order in a set!: selection constraints?)
   %%
   %%   - OK? tuple/list: selection constraint (?? needs length of both beats and accents determined?)
   %%
   %% * actual score item constraint: reified include/select some time in beats/accents (in onAccentR/onBeatR)
   %%
   %%   - OK: local (memorised ?) FS (matched to data): FS: FS.reified.include
   %% 
   %%   - tuple/list: ?? (crude reified Select?)
   %%
   %%
   %% -> Ergo: FS keine option: mir fehlt Reihenfolge (access at index in Set) und ich kann numerische constraints nicht recht anwenden
   %%
   %% -> list / tuple sind moegl. aber blockieren bis beatsNr determiniert ist. Auch hier Problem: wie 
   %%
   %% -> sobald beatsNr determiniert ist kann ich representationen FS und list/tuple matchen (FS.int.match, braucht determinierten vector von FD ints) und so constraints aus beiden Welten haben (zusaetzl. vars, speicherhungrig..) 
   %%
   %% FS toot Chap. 4 kombiniert FS and RecordC, aber da ist width und aritity of RecordC bekannt und RecordC erlaubt nur ein etwas kuerzeres script.
   %%
   %% -> !!!! Entscheidung: beatsNr muss moeglichst frueh determiniert werden: application of constraints wird bis dahin delayed (dies keinerlei Beschraenkung fuer alte Musik bis 1900, da hier Takt ueblicherweise ohnehin am Anfang des Kompositionsprozesses festgelegt wird)
   %%
   %% Vague idea: I may use BeatNr as index for two selection constraints to select (a) the accents (FS) and (b) the beats (FS). Warscheinlich SchnapsIdee: beats abhaengig von sowohl beatNumber als auch beatDuration (kann nicht einfach selectiert werden) und die numerischen Constraints kann ich mit FS immer noch nicht ausdruecken



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Accent constraints
%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Constraint applicators: Accent_If etc.
%%%


   /** %% With Accent_If various musical aspects and parameters can be constrained so that the resulting music expresses the underlying metric structure (simultaneous measure objects). This constraint applicator is inspired by the chapter on rhythm in Berry, Wallace. 1987. Structural Functions in Music. Courier Dover Publications. 
   %% The start time of N coincides with the given "position" in a simultaneous measure (e.g., the measure's start or any accentuated beat), if given a list of given conditions is fulfilled well enough. These conditions (AccentConstraints) are a list of unary functions: the input is N and the return value is a rating of N (an FD int), where 0 means condition not fulfilled and higher values mean that the condition is increasingly better fulfilled. The sum of the return values of all conditions must be equal or exceed a given threshold (arg minRating) in order to trigger that the start time of N is constrained to a certain metric position. Predefined accent constraints include IsLongerThanSurrounding and IsHigherThanSurrounding (see their documentation for further details).
   %%
   %% Args:
   %%
   %% metricPosition (FD int or atom, default 'accent'): if N sufficiently meets the conditions, then its start time is constrained to this "position" in the measure. The following values are supported.
   %%   measureStart: N starts with a measure
   %%   accent: N starts with a strong beat (depends on the measure definition)
   %%   beat: N starts with a beat
   %%   an FD int: N starts at a specified time within a measure (e.g., if 0 then N starts on measure start, if 1 it starts on measure start + 1 etc.). Should not be larger than the measure duration.
   %%
   %% minRating (FD int, default 1): Minimum accumulated rating of accent constraint outputs. If the sum of the return values of all accent constraints are equal or exceed a minRating, then in order the start time of N is constrained to the metric position metricPosition.
   %%
   %% strictness (atom, default 'note'): Must the constrained be fulfilled for all notes meeting the criteria or for all given metric positions? There are three different cases.
   %%   note: if note/item meets the accent criteria it must be on a specified metric position, but even if this constraint is applied to all notes there can be accentuated metric positions without notes meeting such criteria
   %%   position: if note/item is at a specified metric position then it must meet the accent criteria, but even if this constraint is applied to all notes there can be accentuated notes at other positions. 
   %%   noteAndPosition: if note/item meets the accent criteria it is on a specified metric position and vice versa
   %% NOTE: none of the possible values for strictness enforces that there actually starts a note at any metric position specified in metricPosition. Use the constraint NoteAtMetricPosition for this purpose.
   %%
   %% toplevel (default false): The container in which N is contained that should be considered the top level for finding the simultaneous measure object (if false, then the whole score is searched). This argument is for optimisation purposes only.
   %%
   %% measureTest (default IsUniformMeasures): A Boolean function that returns true for the relevant measure objects. (currently only works with uniform measures?)
   %%
   %% rating (an FD int, default {FD.decl}): this argument is bound to the accumulated rating of accent constraint outputs for N. This variable can that way be constrained outside the call of Accent_If (e.g., to constrain the accent structure of some musical section, the number of occurances of some minumum rating or the minimum sum of ratings over multiple notes can be constrained).
   %%
   %% Note: if N inherited from IsAccentRatingMixin then the rating is automatically added to its parameter accentRating. Therefore, Accent_If (or SetAccentRating) should only be called once for such a note.
   %% It is often good practice to combine all accent constraints into a single rating anyway. Exceptions would be special cases where, e.g., accents expressed by duration-relations and accents expressed by pitch-relations should fall on different metric positions. In such cases it is sufficient to avoid using notes that inherited from IsAccentRatingMixin.
   %%
   %% */
   %%
   %% BUG:
   %% - Is first note ignored in accent rating calculation?
   %%
   %% TODO:
   %% - metricPosition: allow for FS as arg value that contains all the "allowed" times for accents within a measure
   %%
   proc {Accent_If N AccentConstraints Args}
      %% SetAccentRating and Accent_If2 share the same Args.rating
      Rating = {FD.decl}
   in
      {SetAccentRating N AccentConstraints {Adjoin unit(rating: Rating) Args}}
      {Accent_If2 N {Adjoin unit(rating: Rating) Args}}
   end

   /** %% Same as Accent_If, but no accent constraints are applied (use SetAccentRating for this). This can be useful, e.g., to combine multiple calls of Accent_If2, say, with different values for Args.metricPosition and Args.minRating.
   %% */
   proc {Accent_If2 N Args}
      Defaults = unit(metricPosition: accent 
		      minRating: 1
		      %% The following is likely too complicated, and not quite worth the effort
                    % %% Minimum number of accent constraints involved. Note: must be =< than {Length AccentConstraints}. If < than {Length AccentConstraints}, then an accent constraint is applied if at least the given number of AccentConstraints return a value > 0 for N.
                    % minConstraints: 1
		      strictness: note
		      measureTest: IsUniformMeasures
		      toplevel: false
		      applyConstraint: true
		      rating: _)
      As = {Adjoin Defaults Args}
      Relation = case As.strictness of
		    note then FD.impl
		 [] position then proc {$ B1 B2 B3} {FD.impl B2 B1 B3} end
		 [] noteAndPosition then FD.equi
		 end
   in
      thread
	 SimMeasure = {N findSimultaneousItem($ test:As.measureTest toplevel:As.toplevel)}
	 MeasureConstraint
	 = if {FD.is As.metricPosition}
	   then
	      proc {$ N ?B}
		 B = ({FD.modI {N getStartTime($)} {SimMeasure getMeasureDuration($)}}
		      =: As.metricPosition)
	      end
	   else 
	      case As.metricPosition of
		 measureStart then proc {$ N ?Result}
				      {SimMeasure onMeasureStartR(Result {N getStartTime($)})}
				   end
	      [] accent then proc {$ N ?Result}
				{SimMeasure onAccentR(Result {N getStartTime($)})}
			     end
	      [] beat then proc {$ N ?Result}
			      {SimMeasure onBeatR(Result {N getStartTime($)})}
			   end
	      end
	   end
      in
	 {Relation (As.rating >=: As.minRating)
	  {MeasureConstraint N}
	  1}
      end
   end

   
   
   /** %% SetAccentRating sets an accumulated accent rating for the note N. AccentConstraints are a list of unary functions: the input is N and the return value is an accent rating of N (an FD int), where 0 means no accent and higher values mean a stronger accent. SetAccentRating sets the accent rating of N to the sum of all AccentConstraint results. Predefined accent constraints include IsLongerThanSurrounding and IsHigherThanSurrounding (see their documentation for further details).
   %%
   %% Args:
   %%
   %% 'rating' (an FD int, default {FD.decl}): this argument is bound to the accumulated rating of accent constraint outputs for N. This variable can that way be constrained outside the call of SetAccentRating (e.g., shared with Accent_If, or constrain the accent structure of some musical section, the number of occurances of some minumum rating or the minimum sum of ratings over multiple notes can be constrained).
   %%
   %% If N inherited from IsAccentRatingMixin then the rating is automatically added to its parameter accentRating. Therefore, SetAccentRating (or Accent_If) should only be called once for such a note.
   %% It is often good practice to combine all accent constraints into a single rating anyway. Exceptions would be special cases where, e.g., accents expressed by duration-relations and accents expressed by pitch-relations should fall on different metric positions. In such cases it is sufficient to avoid using notes that inherited from IsAccentRatingMixin.
   %% */
   proc {SetAccentRating N AccentConstraints Args}
      Defaults = unit(rating: {FD.decl})
      As = {Adjoin Defaults Args}
   in
      thread %% TODO: remove thread
	 ConstraintRating = As.rating
      in
	 ConstraintRating = {FD.sum {Map AccentConstraints
				     proc {$ Constraint ?Rating}
					Rating = {FD.decl}   
					{Constraint N Rating}
				     end}
			     '=:'}
	 if {IsAccentRatingMixin N}
	 then {N getAccentRating($)} = ConstraintRating
	 end
      end
   end

   /** %% TODO: doc
   %% Measure (a UniformMeasures instance) 
   %% Args:
   %% metricPosition (FD int or atom, default 'accent'):
   %%   measureStart: one or more element of Notes starts with Measure
   %%   accent: one or more element of Notes starts with any accent of Measure
   %%   beat: one or more element of Notes starts with any beat
   %%   an FD int: one or more element of Notes starts at a specified time within a measure (e.g., if 0 then N starts on measure start, if 1 it starts on measure start + 1 etc.). Should not be larger than the measure duration.
   %%
   %% allowRestsAtMetricPosition (Boolean, default false): if true, then instead a note start there can be a rest at the metric positions in question introduced by a note's offset time > 0. 
   %%
   %% ?? Note: constraint application delayed until Measure is fully determined.
   %%
   %% BUG: unfinished definition. Only defined for case metricPosition:measureStart so far
   %% */
   %% TODO:
   %% - some mini language that allows to specify a subset of positions or -- even better -- some pattern of the total number of metric positions in question.
   proc {NoteAtMetricPosition MyMeasure Notes Args}
      Defaults = unit(metricPosition: accent
		      allowRestsAtMetricPosition: false)
      As = {Adjoin Defaults Args}
      %% list of the start times of all individual measures in MyMeasure
      MeasureStarts = {List.number {MyMeasure getStartTime($)}
		       {MyMeasure getEndTime($)}
		       {MyMeasure  getMeasureDuration($)}}
   in
      if {FD.is As.metricPosition}
      then
	 skip %% TODO:
      else
	 %% ?? TODO: revise: only use sim notes of Measure -- can I do that
	 %% All I want is that any propagator that can never be met is removed -- probably done automatically anyway
	 case As.metricPosition of
	    measureStart
	 then {ForAll MeasureStarts
	       proc {$ MyStart}
		  thread
		     SimNotes = {LUtils.cFilter Notes
				 fun {$ N}
				    AtTimeR_Proc = if As.allowRestsAtMetricPosition
						   then Score.atTimeR
						   else Score.atTimeR2
						   end
				 in 
				    {AtTimeR_Proc N MyStart} == 1
				 end}
		  in
		     if SimNotes \= nil
		     then
			{FD.sum {Map SimNotes
				 fun {$ N} ({N getStartTime($)} =: MyStart) end}
			 '>:' 0}
		     end
		  end
	       end}
	 [] accent then %% TODO:
	    skip
           % {FS.int.match {Measure getAccentsFS($)}
           % Accents}
           
	 [] beat then %% TODO:
	    skip
           % {FS.int.match {Measure getBeatsFS($)}
           %  Beats}
           
           % {FS.forAllIn {Measure getBeatsFS($)}
           %  proc {$ MyBeat} end}
           
	 end
      end
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Duration related accent constraints
%%%
  
  
   /** %% Returns an accent constraint (a function execting a note/item and returning a rating FD int). This resulting function returns 1 for notes with a duration of Dur or longer, and 0 otherwise.
   %% */
   fun {Make_HasAtLeastDuration Dur}
      fun {$ N}
	 ({N getDuration($)} >=: Dur)
      end
   end

   /** %% B=1 <=> Note N is the first item in its container.
   %% */
   fun {IsFirstItem N}
      if {N isFirstItem($ {N getTemporalAspect($)})}
      then 1
      else 0 end
   end
      
   /** %% B=1 <=> Note N is longer than both its preceeding and its succeeding note (duration + offsetTime used for calculating the perceived duration). If a preceeding or succeeding note does not exist (in the same temporal container) then the constraint returns 0.
   %% */
   fun {IsLongerThanDirectNeighbours N}
      fun {IsShorter N2}
	 Dur1={FD.decl} Dur2={FD.decl}
      in
	 Dur1 = {N getDuration($)} + {N getOffsetTime($)}
	 Dur2 = {N2 getDuration($)} + {N2 getOffsetTime($)}
	 (Dur2 <: Dur1)
      end
   in
      {FD.conj {ApplyIfNotnilOrFalse {N getTemporalPredecessor($)} IsShorter}
       {ApplyIfNotnilOrFalse {N getTemporalSuccessor($)} IsShorter}}
   end
      
   /** %% B=1 <=> Note N is longer than the preceeding note and not shorter than succeeding note (duration + offsetTime used for calculating the perceived duration). If a preceeding note does not exist (in the same temporal container) then the constraint returns 0, if succeeding note does not exist then it returns 1.
   %% */
   fun {IsLongerThanPredecessor N}
      Dur1={FD.decl} 
      Dur1 = {N getDuration($)} + {N getOffsetTime($)}
      fun {IsShorter N2} 
	 Dur2={FD.decl}
      in
	 Dur2 = {N2 getDuration($)} + {N2 getOffsetTime($)}
	 (Dur2 <: Dur1)
      end
      fun {IsNotLonger N2} 
	 Dur2={FD.decl}
      in
	 Dur2 = {N2 getDuration($)} + {N2 getOffsetTime($)}
	 (Dur2  =<: Dur1)
      end
   in
      {FD.conj {ApplyIfNotnilOrFalse {N getTemporalPredecessor($)} IsShorter}
       {ApplyIfNotnilOrTrue {N getTemporalSuccessor($)} IsNotLonger}}
   end

   /** %% B=1 <=> Note N is longer than the preceeding note (duration + offsetTime used for calculating the perceived duration). If a preceeding or succeeding note does not exist (in the same temporal container) then the constraint returns 0.
   %% */
   fun {IsLongerThanPredecessorSimple N}
      Dur1={FD.decl} 
      Dur1 = {N getDuration($)} + {N getOffsetTime($)}
      fun {IsShorter N2} 
	 Dur2={FD.decl}
      in
	 Dur2 = {N2 getDuration($)} + {N2 getOffsetTime($)}
	 (Dur2 <: Dur1)
      end
   in
      {ApplyIfNotnilOrFalse {N getTemporalPredecessor($)} IsShorter}
   end
      
   /** %% The higher the value of Rating, the more N is accented by its duration compared to its preceeding note (duration + offsetTime used for calculating the perceived duration).
   %% Rating=1: N is longer than its predecessor, or if there exists no predecessor.
   %% Rating=2: N is at least 2 times as long as its predecessor.
   %% Rating=3: N is at least 4 times as long as its predecessor.
   %% Rating is 0 otherwise. Rating is also 0 if N is shorter than its succeeding note.
   %% */
   %% TODO: take offset times into account
   proc {IsLongerThanPredecessor_Rated N ?Rating}
      Pre = {N getTemporalPredecessor($)}
      NDur = {FD.decl}
      NDur = {N getDuration($)} + {N getOffsetTime($)}
   in
      Rating = {FD.int 0#3}
      Rating = {ApplyIfNotnilOrTrue Pre
		fun {$ Pre}
		   PreDur = {FD.decl}
		   PreDur = {Pre getDuration($)} + {Pre getOffsetTime($)}
		in
		   (NDur >: PreDur) + (NDur >=: PreDur * 2) + (NDur >=: PreDur * 4)
		end} * {ApplyIfNotnilOrTrue {N getTemporalSuccessor($)}
			fun {$ N2} 
			   ({N2 getDuration($)} =<: NDur)
			end}
   end
      
      
   /** %% The higher the value of Rating, the more N is accented by its duration compared to its surrounding notes.
   %% 
   %% Note: The rating of the first note in a temporal container is limited to the range [1,2]. 
   %% */
   %% TODO:
   %% - better fun name
   %% - doc
   %%
   %% - ?? Take also multiple predecessors/successors into account? `
   %% 
   %% [??Outdated comment?] simplified version, see my notes
   %% TODO:
   %% - make more flexible, see my notes 
   proc {IsLongerThanSurrounding_Rated N ?Rating}
      Rating =: {IsLongerThanDirectNeighbours N} + {IsLongerThanPredecessor_Rated N}
   end


   /** %% B=1 <=> Note N is the first of 2 or more notes with equal note values (duration + offsetTime used for calculating the perceived note value), but the preceeding note value is different.
   %% If a preceeding note does not exist (in the same temporal container) then that part of the condition is considered to be fulfilled, but a succeeding note must exist for B=1.
   %% */
   fun {IsFirstOfEqualNoteValues N}
      Dur1={FD.decl} 
      Dur1 = {N getDuration($)} + {N getOffsetTime($)}
      fun {IsDifferent N2} 
	 Dur2={FD.decl}
      in
	 Dur2 = {N2 getDuration($)} + {N2 getOffsetTime($)}
	 (Dur2  \=: Dur1)
      end
      fun {IsEqual N2} 
	 Dur2={FD.decl}
      in
	 Dur2 = {N2 getDuration($)} + {N2 getOffsetTime($)}
	 (Dur2 =: Dur1)
      end
   in
      {FD.conj {ApplyIfNotnilOrTrue {N getTemporalPredecessor($)} IsDifferent}
       {ApplyIfNotnilOrFalse {N getTemporalSuccessor($)} IsEqual}}
   end
      
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Pitch related accent constraints
%%%
      
          
   /** %% B=1 <=> Note N's pitch is higher than both its preceeding and its succeeding note. If a preceeding or succeeding note does not exist (in the same temporal container) then the constraint returns 0.
   %% TODO: ?? take offset times into account: a note with an offset time > 0 has "no predecessor". If the successor has an offset time > 0 then it has "no successor".
   %% */
   fun {IsHigherThanDirectNeighbours N}
      fun {IsLower N2} 
	 ({N2 getPitch($)} <: {N getPitch($)})
      end
   in
      {FD.conj {ApplyIfNotnilOrFalse {N getTemporalPredecessor($)} IsLower}
       {ApplyIfNotnilOrFalse {N getTemporalSuccessor($)} IsLower}}
   end
      
   /** %% B=1 <=> Note N's pitch is higher than the preceeding note and not lower than succeeding note. If a preceeding or succeeding note does not exist (in the same temporal container) then the constraint returns 0.
   %% TODO: ?? take offset times into account: a note with an offset time > 0 has "no predecessor". If the successor has an offset time > 0 then it has "no successor".
   %% */
   fun {IsHigherThanPredecessor N}
      fun {IsLower N2} 
	 ({N2 getPitch($)} <: {N getPitch($)})
      end
      fun {IsNotHigher N2} 
	 ({N2 getPitch($)} =<: {N getPitch($)})
      end
   in
      {FD.conj {ApplyIfNotnilOrFalse {N getTemporalPredecessor($)} IsLower}
       {ApplyIfNotnilOrFalse {N getTemporalSuccessor($)} IsNotHigher}}
   end

   /** %% B=1 <=> Note N's pitch skips from its preceeding note by more than a minor third in either direction. If a preceeding note does not exist (in the same temporal container) then the condition is considered not to be fulfilled.
   %% TODO:
   %% - ?? take offset times into account: a note with an offset time > 0 has "no predecessor". If the successor has an offset time > 0 then it has "no successor".
   %% - !! Variant for large skips (see [Berry, 1987, p. 339, point 2]
   %% */
   fun {IsSkip N}
      fun {BeforeSkip N2}
	 {GUtils.reifiedDistance {N getPitch($)} {N2 getPitch($)} '>:' {HS.pc 'Eb'}}
	 % {FD.reified.distance {N getPitch($)} {N2 getPitch($)} '>:' {HS.pc 'Eb'}}
      end
   in
      {ApplyIfNotnilOrFalse {N getTemporalPredecessor($)} BeforeSkip}
   end
      
   /** %% The higher the value of Rating, the more N is accented by its pitch compared to its preceeding note.
   %% Rating=1: N is higher than its predecessor, or if there exists no predecessor.
   %% Rating=2: N is more than major second higher than predecessor
   %% Rating=3: N is more than fourth higher than predecessor
   %% Rating=4: N is more than major six higher than predecessor
   %% Rating is 0 otherwise. Rating is also 0 if N is lower than its succeeding note.
   %% */
   %% TODO:
   %% - take offset times into account
   proc {IsHigherThanPredecessor_Rated N ?Rating}
      Pre = {N getTemporalPredecessor($)}
      NPitch = {N getPitch($)}
   in
      Rating = {FD.int 0#3}
      Rating = {ApplyIfNotnilOrTrue Pre
		fun {$ Pre}
		   PrePitch = {Pre getPitch($)}
		in
		   (NPitch >: PrePitch) + (NPitch >: PrePitch + {HS.pc 'D'}) +
		   (NPitch >: PrePitch + {HS.pc 'F'}) + (NPitch >: PrePitch + {HS.pc 'A'})
		end} * {ApplyIfNotnilOrTrue {N getTemporalSuccessor($)}
			fun {$ N2} 
			   ({N2 getPitch($)} =<: NPitch)
			end}
   end
      
      
   /** %% The higher the value of Rating, the more N is accented by its pitch compared to its surrounding notes.
   %% 
   %% Note: The rating of the first note in a temporal container is limited to the range [1,2]. 
   %% */
   %% TODO:
   %% - better fun name
   %% - doc
   %%
   %% - ?? Take also multiple predecessors/successors into account? `
   %% 
   %% [??Outdated comment?] simplified version, see my notes
   %% TODO:
   %% - make more flexible, see my notes 
   proc {IsHigherThanSurrounding_Rated N ?Rating}
      Rating =: {IsHigherThanDirectNeighbours N} + {IsHigherThanPredecessor_Rated N}
   end
     
  
         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Texture related accent constraints
%%%

   /** %% Rating (FD int) is the number of simultaneous notes that have the same start time as MyNote (a note object). There may be more simultaneous notes with a different start time, but these do /not/ count.
   %% Note: Constraint delayed until simultaneous notes are known.
   %% */
   %% TODO:
   %% - ?? make test isNote customisable by an argument
   proc {HasTextureAccent MyNote Rating}
      Rating = {FD.decl}
      thread
	 SimNotes = {MyNote getSimultaneousItems($ test:isNote)}
      in
	 Rating = {Pattern.howMayTrue
		   {Map SimNotes fun {$ N2} ({MyNote getStartTime($)} =: {N2 getStartTime($)}) end}}
      end
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Other accent constraints
%%%


   /** %% Expects an accent constraint C (a function expecting a note and returning a rating FD int, and returns an accent constraint that is a variation of C, where the rating is multiplied by I (an FD int). 
   %% */
   fun {WeightConstraint C I}
      proc {$ N ?Rating}	 	
	 AuxRating = {FD.decl}
      in
	 AuxRating = {C N}
	 Rating =: AuxRating * I
      end
   end


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Anacrusis related accent constraints
%%%

   
   /** %% Make_HasAnacrusis returns an accent constraint, i.e. a function execting a note/item N and returning a rating FD int. The resulting function returns a positive rating for N preceeded by an anacrusis, and 0 otherwise.
   %%
   %% Args:
   %% context (record or function, default predecessorsUpToRest): This argument specifies the score context that potentially forms an anacrusis of N. If 'predecessorsUpToRest', then the notes before N up to any rest (offset time or pause object) are taken into account (within the same temporal container). If predecessors(I), then the I (an int) notes before N are taken into account (within the same temporal container). The context can also be defined by a unary function expecting N and returning the items as a list.
   %% ratingPs (list of constraints {P Xs ?Rating}, default nil): This argument specifies how the quality (rating) of an anacrusis is measured. Each ratingP is a function that expects a list of notes (of at least length 2) starting with N, then its predecessor and so forth. Each function returns a rating (an FD int). The resulting accent constraint rating is the minimum rating of any ratingP (subject to requirements, see below). Example constraint: N predecessors are of equal length (Anacrusis_FirstNEvenDurations).
   %% requirements (list of reified constraints {P Xs B}, default nil): This argument specifies requirements that must be met by the score context if it should count at all as an anacrusis. Each requirement is a function that expects a list of notes (of at least length 2) starting with N, then its predecessor and so forth. Each function returns a 0/1-int. If any requirement returns 0 then the accent constraint returns 0 for this note. If all requirements returns 1, then the value resulting from the ratingPs is returned as rating. Example constraint: N longer than its predecessor (Anacrusis_LongerThanPrevious).
   %% maxRating (int, default 2): maximum rating for N. If the computed rating exceeds maxRating then maxRating is returned instead.
   %%
   %% Note: if neither ratingPs nor requirements are given then the accent constraint returns the rating 1 for all notes. 
   %% */
   %% TODO:
   %% - ?? Is it a good idea to return 1 for all notes if neither ratingPs nor requirements are given then the accent constraint? How realistic is this case anyway?
   %% - test this constraint applicator and its constraints. Because this applicator is very flexible (good) I did not test all its possibilities (no time before Fokker-organ composition deadline
   %% BUG:
   %% - First note seems to be completely ignored in accent rating calculation (last as well?)
   fun {Make_HasAnacrusis Args}
      Defaults = unit(context: predecessorsUpToRest
		      ratingPs: nil
		      requirements: nil
		      maxRating: 2)
      As = {Adjoin Defaults Args}
      /** %% Rating will not exceed Max.
      %% */
      %% TODO: clean up..
      proc {LimitRating Rating Max LimitedRating}
	 RatingExceedsB = {FD.int 0#1}
      in
	 LimitedRating = {FD.decl}
	 RatingExceedsB = (Rating >: Max)
	 LimitedRating =: Rating * {FD.nega RatingExceedsB} + Max * RatingExceedsB
      end
   in
      proc {$ N ?Rating}
	 Context = if {IsProcedure As.context}
		   then {As.context N}
		   else case {Label As.context} of
			   predecessorsUpToRest then {N getPredecessorsUpToRest($)}
			[] predecessors then {N getTemporalPredecessors($ As.context.1)}
			end
		   end
      in
	 if {Length Context} >= 1
	 then 
	    AuxRating = {FD.decl}
	    RequirementsB = {FD.int 0#1}
	 in
	    AuxRating =: case As.ratingPs of nil then 1 % ??
			 else {Pattern.min {Map As.ratingPs fun {$ F} {F N|Context} end}}
			 end
	    RequirementsB =: {Pattern.allTrueR {Map As.requirements fun {$ F} {F N|Context} end}}
	    Rating = {LimitRating (AuxRating * RequirementsB) As.maxRating}
	 else
	    Rating = 0
	 end
      end
   end


   %% TODO:
   % fun {Anacrusis_Weight C I}
   % end

   /** %% [anacrusis requirement] The duration of the accent (1st note in Ns) is longer then the first note of the anacrusis (the 2nd note in Ns).
   %% */
   fun {Anacrusis_AccentLonger Ns}
      ({Ns.1 getDuration($)} >: {Ns.2.1 getDuration($)})
   end

   /** %% [anacrusis requirement] At the accent (1st note in Ns) happens a change in pitch direction.
   %% */
   fun {Anacrusis_DirectionChange Ns}
      fun {Aux NSucc}
	 {Pattern.directionChangeR {Ns.2.1 getPitch($)} {Ns.1 getPitch($)} {NSucc getPitch($)}}
      end
   in
      {ApplyIfNotnilOrFalse {Ns.1 getTemporalSuccessor($)} Aux}
   end

   /** %% [anacrusis requirement] The accent (1st note in Ns) is a local pitch maximum.
   %% */
   fun {Anacrusis_LocalMax Ns}
      fun {Aux NSucc}
	 {Pattern.localMaxR {Ns.2.1 getPitch($)} {Ns.1 getPitch($)} {NSucc getPitch($)}}
      end
   in
      {ApplyIfNotnilOrFalse {Ns.1 getTemporalSuccessor($)} Aux}
   end


   local
      /** %% [Anacrusis aux def] Expects a reified constraint {P Ns ?Bs} that expects a list of notes and returns a list of 0/1-ints. MakeRequirement returns an anacrusis requirement procedure (see doc of Make_HasAnacrusis).
      %% */
      fun {MakeRequirement P}
	 fun {$ Ns} {Pattern.allTrueR {P Ns}} end
      end
      /** %% [Anacrusis aux def] Expects a reified constraint {P Ns ?Bs} that expects a list of notes and returns a list of 0/1-ints. MakeRatingP returns an anacrusis ratingP procedure (see doc of Make_HasAnacrusis).
      %% */
      fun {MakeRatingP P}
	 proc {$ Ns Rating}
	    Bs = {P Ns}
	 in
	    %% NOTE: should rating be 0 or 1 if not enough notes are there to meet ratingP? I think it should be 0.
	    %% (see also SameDirectionPitchIntervalsRs)
	    case Bs of nil then Rating = 0 
	    else Rating = {Pattern.firstNTrue Bs}
	    end
	 end
      end
   in

      local
	 fun {ShorterThanAccentRs Ns}
	    N1 = Ns.1
	 in
	    {Map Ns.2 fun {$ N2} ({N2 getDuration($)} <: {N1 getDuration($)}) end}
	 end   
      in
	 /** %% [anacrusis requirement] B=1 <-> All durations of notes in Ns (a list of notes) are shorter than the accent (the first note in Ns).
	 %% */
	 Anacrusis_ShorterThanAccent = {MakeRequirement ShorterThanAccentRs}
	 /** %% [anacrusis ratingP] The first Rating (an FD int) durations of notes in Ns (a list of notes) are shorter than the accent (the first note in Ns).
	 %% */
	 Anacrusis_FirstNShorterThanAccent = {MakeRatingP ShorterThanAccentRs}
      end

      local
	 fun {NoLongerThanAccentRs Ns}
	    N1 = Ns.1
	 in
	    {Map Ns.2 fun {$ N2} ({N2 getDuration($)} =<: {N1 getDuration($)}) end}
	 end   
      in
	 /** %% [anacrusis requirement] B=1 <-> All durations of notes in Ns (a list of notes) are no longer than the accent (the first note in Ns).
	 %% */
	 Anacrusis_NoLongerThanAccent = {MakeRequirement NoLongerThanAccentRs}
	 /** %% [anacrusis ratingP] The first Rating (an FD int) durations of notes in Ns (a list of notes) are no longer than the accent (the first note in Ns).
	 %% */
	 Anacrusis_FirstNNoLongerThanAccent = {MakeRatingP NoLongerThanAccentRs}
      end

      local
	 fun {PossibilyShorterTowardsAccentRs Ns}
	    {Pattern.map2Neighbours {Map Ns.2 {GUtils.toFun getDuration}}
	     fun {$ D1 D2} (D1 =<: D2) end}
	 end   
      in
	 /** %% [anacrusis requirement] B=1 <-> All notes in Ns (a list of notes) except the first (the accent) have the same duration among themselves or they become shorter towards the accent.
	 %% */
	 Anacrusis_PossibilyShorterTowardsAccent = {MakeRequirement PossibilyShorterTowardsAccentRs}
	 /** %% [anacrusis ratingP] The first Rating (an FD int) notes in Ns (a list of notes) except the first (the accent) have the same duration among themselves or they become shorter towards the accent.
	 %% */
	 Anacrusis_FirstNPossibilyShorterTowardsAccent = {MakeRatingP PossibilyShorterTowardsAccentRs}
      end

      local
	 fun {EvenDurationsRs Ns}
	    {Pattern.map2Neighbours {Map Ns.2 {GUtils.toFun getDuration}}
	     fun {$ D1 D2} (D1 =: D2) end}
	 end   
      in
	 /** %% [anacrusis requirement] B=1 <-> All notes in Ns (a list of notes) except the first (the accent) have the same duration.
	 %% If {Length Ns} is 1 then this requirement is always met. 
	 %% */
	 Anacrusis_EvenDurations = {MakeRequirement EvenDurationsRs}
	 /** %% [anacrusis ratingP] The first Rating (an FD int) notes in Ns (a list of notes) except the first (the accent) have the same duration.
	 %% If {Length Ns} is 1 then this requirement is always met.
	 %% */
	 Anacrusis_FirstNEvenDurations = {MakeRatingP EvenDurationsRs}
      end

      local
	 fun {UpwardPitchIntervalsRs Ns}
	    {Pattern.map2Neighbours {Map Ns.2 {GUtils.toFun getPitch}}
	     fun {$ P1 P2} {Pattern.directionR P1 P2 0} end}
	 end   
      in
	 /** %% [anacrusis requirement] B=1 <-> All interval directions between the pitches of notes in Ns (a list of notes) are upwards.
	 %% */
	 Anacrusis_UpwardPitchIntervals = {MakeRequirement UpwardPitchIntervalsRs}
	 /** %% [anacrusis ratingP] The first Rating (an FD int) interval directions between the pitches of notes in Ns (a list of notes) are all upwards.
	 %% */
	 Anacrusis_FirstNUpwardPitchIntervals = {MakeRatingP UpwardPitchIntervalsRs}
      end

      local
	 fun {SameDirectionPitchIntervalsRs Ns}
	    if {Length Ns} >= 3 
	    then {Pattern.map2Neighbours
		  {Pattern.map2Neighbours {Map Ns {GUtils.toFun getPitch}}
		   fun {$ P1 P2} {Pattern.direction P1 P2} end}
		  fun {$ Dir1 Dir2} (Dir1 =: Dir2) end}	       
	       %% NOTE: should rating be 0 or 1 if not enough notes are there to meet requirement or ratingP?
	    else {Map Ns fun {$ _} 0 end}
	    end
	 end   
      in
	 /** %% [anacrusis requirement] B=1 <-> All interval directions between the pitches of notes in Ns (a list of notes) move in the same direction (upwards, downwards or repetition).
	 %% */
	 Anacrusis_SameDirectionPitchIntervals = {MakeRequirement SameDirectionPitchIntervalsRs}
	 /** %% [anacrusis ratingP] The first Rating (an FD int) interval directions between the pitches of notes in Ns (a list of notes)  move all in the same direction (upwards, downwards or repetition).
	 %% */
	 Anacrusis_FirstNSameDirectionPitchIntervals = {MakeRatingP SameDirectionPitchIntervalsRs}
      end
   end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Aux defs
%%%
   
   /** %% If X is not nil then apply F and return the result. Otherwise return 1. 
   %% */
   fun {ApplyIfNotnilOrTrue X F}
      if X == nil then 1
      else {F X}
      end
   end
   /** %% If X is not nil then apply F and return the result. Otherwise return 0. 
   %% */
   fun {ApplyIfNotnilOrFalse X F}
      if X == nil then 0
      else {F X}
      end
   end
    

      
end
