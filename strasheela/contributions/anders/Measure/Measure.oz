
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
%% * So far no metric hierarchy, only a seq of measures.. (constraints in MeasureSeq use only getItems etc.) -- see doc of MeasureSeq
%%
%% * Lilypond Output ... (eventuell haarig)
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


functor
import
   FD FS
%    Browser(browse:Browse) % temp for debugging
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   Out at 'source/Output.ozf'
   
export
   Out
   
   Measure IsMeasure
   % MeasureSeq IsMeasureSeq
   UniformMeasures IsUniformMeasures
   
prepare
   MeasureType = {Name.new}
   % MeasureSeqType = {Name.new}
   UniformMeasuresType = {Name.new}
   
define

   /** %% Measure is a silent timed element representing the meter of a score for the duration of the Measure. Measures are contained in a silent MeasureSeq/UniformMeasures and a MeasureSeq/UniformMeasures runs in parallel to the actual (i.e. sounding) score. That way, the metric structure is freely constrainable independent of other parameters and the hierarchic structure of the rest of the score. 
   %% The Measure parameters 'beatNumber' and 'beatDuration' represent the meter of the measure. For instance, in case the time unit of the score is beats(4) and thus 4 represents a quarter note (see doc Score.timeMixin) then the meter 3/8 is represented by beatNumber=3 and beatDuration=2. Usually, beatDuration will equal the number of ticks per beat defined in the time unit of the score (exceptions are needed in case the score contains measures with different beat durations).
   %% The attribute 'beats' (a list of FD ints) represents the relative startTimes of the beats in the measure. For instance, in case beatNumber=3 and beatDuration=2 then beats=[0 2 4].
   %% The attribute 'accents' (a list of FD ints) represents the relative startTimes of the strong beats in the measure. The strong beats depend on the beatNumber of the measure. The accent patterns in common praxis music are highly standardised (e.g. the meter 4/4 has strong beats on the first and the third beat). Nonetheless, Measure allows to freely define these accent patterns for each possible beatNumber value for each Measure at the optional init method argument 'accentIdxDB'. This argument expects a record (with only integer features) of lists of integers to specify an accent pattern for each beatNumber. For instance, the specification of the common praxis tripel and quadruple meter is unit(3:[1] 4:[1 3]).
   %% The default of 'accentIdxDB' defines the usual common praxis accent patterns for single (1/2, 1/4, 1/8), duple (2/2, 2/4, 2/8), triple (3/2, 3/4, 3/8), and quadruple (4/2, 4/4, 4/8) meter, as well as compound duple (6/2, 6/4, 6/8), compound triple (9/4, 9/8), and compound quadruple (12/4, 12/8, 12/16) meter. The compound meters may also be used to express 'prolatione perfecta' for old music, while the non-coumpound meters express 'prolatione imperfecta'. For the quintuple meter (5/4 etc.), the accent pattern 3/4 + 2/4 is the default. 
   %%  NB: the initialisation constraints for both beats and accents are delayed until beatNumber is determined (i.e. in a CSP the beatNumber of each beat is either predetermined or the distribution strategy should determine all beatNumbers before other parameter values which are related to the measure by constraints).
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
% 				       {TimeInMeasure Time MeasureStart}
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
% 				       {TimeInMeasure Time MeasureStart}
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
      %% !! blocks until measure duration is determined (i.e. both beatNumber and beatDuration are determined)
      proc {TimeInMeasure Time MeasureDur ?RelTime}
	 RelTime = {FD.decl}
	 RelTime =: {FD.modI Time MeasureDur}
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
	 %% */
	 meth getMeasureAt(I Time)
	    %% !!?? is there some cheaper implementation
	    MDur = {self getMeasureDuration($)}
	 in
	    (I - 1) * MDur =<: Time
	    I * MDur >: Time
	 end

	 /** %% I is the index of the accent at Time (one-based). Accents are only counted within individual measures (the first accent in the 2nd measure is again index 1). If Time is between accents then the index of the accent before Time is returned.
	 %% Method blocks until measure duration is determined (i.e. both beatNumber and beatDuration are determined).
	 %% */
	 meth getAccentInMeasureAt(I Time)
	    RelTime = {TimeInMeasure Time {self getMeasureDuration($)}}
	    Accents = {self getAccents($)}
	 in
	    I = {LUtils.findPositions {LUtils.matTrans
				       [Accents
					{Append Accents [{self getMeasureDuration($)}]}]}
		 fun {$ A1 A2}
		    (A1 =<: RelTime) == 1 andthen
		    (A2 >: RelTime) == 1
		 end}
	 end
	 
	 /** %% I is the index of the beat at Time (one-based). Beats are counted across all measures in self. If Time is between beats then the intex of the last beat before is returned.
	 %% */
	 meth getBeatAt(I Time)
	    %% !!?? is there some cheaper implementation
	    BDur = {self getBeatDuration($)}
	 in
	    (I - 1) * BDur =<: Time
	    I * BDur >: Time
	 end
	 /** %% I is the index of the beat at Time (one-based). Beats are only counted within individual measures (the first beat in the 2nd measure is again index 1). If Time is between beats then the index of the beat before Time is returned.
	 %% Constraint blocks until beatNumber is determined.
	 %% */
	 meth getBeatInMeasureAt(I Time)
	    TotalI = {FD.decl}
	 in
	    {self getBeatAt(TotalI Time)}
	    I = {FD.modI TotalI {self getBeatNumber($)}}
	 end
	 
	 
	 /** %% B=1 <-> Time equals the start time of some measure in UniformMeasures. Time is FD int, B is implicitly constrained to 0/1-int.
	 %%
	 %% NB: Constraint blocks until both beatNumber and beatDuration are determined.
	 %% NB: method does not take n into account -- to limit truth value B to the actual time span within start and end time of UniformMeasures add necessary constraints outside of this method.
	 %% */
	 meth onMeasureStartR(B Time)
	    %% for old version: NB: constraint blocks until measure duration is determined (i.e. both beatNumber and beatDuration are determined). There is no propagation with neither beatNumber and beatDuration and Time or B.
% 	 B = {FD.int 0#1}
% 	 B =: ({TimeInMeasure Time {self getMeasureDuration($)}}
% 	       =: {self getStartTime($)})
	    %%
	    B = {FD.int 0#1}
	    B =: ({FD.modI Time {self getMeasureDuration($)}} =: 0)
	 end
	 /** %% Variant of onMeasureStartR which does domain propagation (which can be very expensive). However, propagation of Time does only happen after B got determined.
	 %%
	 %% !!?? constraint suspends and performs OK if it first calls {Browse Time}?
	 %% */
	 %% !! MeasureDuration is constrained anyway in Measure -- here I add the same constraints with domain propagation (however, often MeasureDuration is determined soon anyway).
	 meth onMeasureStartDR(B Time)	 
	    MeasureDuration = {self getMeasureDuration($)}
	    RelTime = {FD.decl}
	 in
	    MeasureDuration = {FD.timesD {self getBeatNumber($)} {self getBeatDuration($)}}
	    RelTime = {FD.modD Time MeasureDuration}
	    B = {FD.int 0#1}
	    B =: (RelTime =: 0)
	 end
	 /** %% B=1 <-> Time equals some strong beat in some measure in UniformMeasures. Time is FD int, B is implicitly constrained to 0/1-int.
	 %%
	 %% NB: Constraint blocks until both beatNumber and beatDuration are determined.
	 %% NB: method does not take n into account -- to limit truth value B to the actual time span within start and end time of UniformMeasures add necessary constraints outside of this method.
	 %% */
	 meth onAccentR(B Time)
	    %% Constraint blocks until measure duration is determined (i.e. both beatNumber and beatDuration are determined). There is no propagation with neither beatNumber and beatDuration and Time or B. 
	    %% !! constrain performs probably very little propagation: Time -- transformed into measure only by bounds propagation -- is constrained whether it is element in set...
	    B = {FD.int 0#1}
	    B = {FS.reified.include
		 {TimeInMeasure Time {self getMeasureDuration($)}}
		 {self getAccentsFS($)}}
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
% 		  {TimeInMeasure Time {self getMeasureDuration($)}}
% 		  {self getBeatsFS($)}}
	    %%
	    B = {FD.int 0#1}
	    B =: ({FD.modI Time {self getBeatDuration($)}} =: 0)
	 end
	 /** %% Variant of onBeatR which does domain propagation (which can be very expensive). However, propagation of Time does only happen after B got determined.
	 %% */
	 %% !!?? constraint suspends and performs OK if it first calls {Browse Time}?
	 meth onBeatDR(B Time)
	    RelTime = {FD.decl}
	 in
	    RelTime = {FD.modD Time {self getBeatDuration($)}}
	    B = {FD.int 0#1}
	    B =: (RelTime =: 0)
	 end

	 /** %% B=1 <-> an event lasting from Start to End is a syncope at measure level: Start and End fall in different measures.
	 %% */
	 meth overlapsBarlineR(B Start End)
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
	 end

	 /** %% Same as overlapsBarlineR
	 %% */
	 meth measureSyncopationR(B Start End)
	    {self overlapsBarlineR(B Start End)}
	 end

	 /** %% B=1 <-> an event lasting from Start to End is a syncope at accent level: Start is not on an accent, and Start and End fall between different accents.
	 %% BUG: B=0 for an event that is a syncope at accent level, but its duration is some multiple of the measure duration.
	 %% */
	 meth accentSyncopationR(B Start End)
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
	 end
	 
	 /** %% B=1 <-> an event lasting from Start to End is a syncope at beat level: Start is not on a beat, and Start and End fall between different beats. 
	 %% */
	 meth beatSyncopationR(B Start End)
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

   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%
   %% old code and documentation kept in case of some redesign or alternative defs in future
   %%
 

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

   
end
