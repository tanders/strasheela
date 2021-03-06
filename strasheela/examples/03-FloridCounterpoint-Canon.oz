
%%% *************************************************************
%%% Copyright (C) Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% ** HOW TO USE THIS EXAMPLE? **
%%
%% First feed the whole buffer. Then scroll down to the section 'Call
%% solver' (wrapped in a block comment to prevent unintended feeding)
%% and feed the examples one by one.
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% ** EXAMPLE DESCRIPTION **
%%
%% This example demonstrates Strasheela's capabilities for polyphonic
%% CSP where both the pitch structure as well as the rhythmical
%% structure is constrained by rules. The example was designed to be
%% relatively simple. Therefore, it compiles rules from various
%% sources instead of following a specific author closely (as did the
%% Fuxian first species counterpoint example). For example, some rules
%% are variants from Fuxian rules introduced before, but rhythmical
%% rules were inspired by Motte [1981]. Accordingly, the result does
%% also not imitate a particular historical style (but neither does
%% Fux, cf. Jeppesen).
%%
%%
%%
%% This example creates a two voice counterpoint as the Fuxian
%% example. The music representation is hence very similar to this
%% example. The representation consists in two parallel voices (Voice1
%% and Voice2) -- two sequential containers nested in a simultaneous
%% container -- as before. The Voice1 contains 17 and Voice2 15 notes.
%% 
%% The start time and end time of both voices is further
%% restricted. Voice1 begins a bar before Voice2. This is expressed by
%% setting the offset time of these two sequential containers
%% (contained in a simultaneous container) to different values (the
%% offset of Voice1 is 0, and the offset of Voice2 is a semibreve,
%% i.e. 16 as the temporal unit is beats(4), that is a quarter note
%% has duration 4). Besides, both voices end at the same time (the end
%% time of both sequential containers is unified).
%%
%% In contrast to the Fuxian example, all pitches but also all
%% durations are searched for. Each note duration has the domain [2 4
%% 8] (i.e. the set {eighth, quarter, halve note}). The pitch domain
%% for each note in Voice1 is set to 53#67 (i.e. {f3, ..., g4}, the
%% domain for the note pitches of Voice2 is slightly greater 53#72
%% (i.e. {f3, ..., c4}).
%% 
%% The example defines rules on various aspects of the music. The
%% example applies rhythmic rules, melodic rules, harmonic rules,
%% voice-leading rules and rules on the formal structure.
%%
%% Rhythmical rules constrain each voice to start and end with a halve
%% note value. Note durations may change only slowly across a voice:
%% neighbouring note values are either of equal length or differ by
%% 50% at maximum (e.g. a eighth can be followed by a quarter, but not
%% by a halve). Also, the last note of each voices must start with a
%% full bar.
%% 
%% Melodic rules restrict each note pitch to the diatonic pitches of
%% the C-major scale. The first and last note of Voice1 must start and
%% end with the root $c$. The melodic interval between neighbouring
%% pitches in a voice is limited to a minor third at maximum
%% (i.e. less than in the Fuxian example). In addition and most
%% importantly, one rule constrains melodic peaks: the maximum and
%% minimum pitch in a phrase occurs exactly once and it is not the
%% first or last note of the phrase. In this example, a phrase is
%% defined simply as half a melody. Finally, the pitch maxima and
%% minima of phrases must differ. This rule on the melodic contour --
%% inspired by Schoenberg -- has great influence on the personally
%% evaluated quality of the result but also on the combinatorial
%% complexity of the CSP.
%% 
%% Simultaneous notes must be consonant. The only exception permitted
%% here are passing tones, where Note1 is a passing tone (i.e. the
%% intervals to its predecessor and successor are steps and both steps
%% occur in the same direction) and the simultaneous Note2 started
%% more early than Note1, and this Note2 is consonant to predecessor
%% of Note1. Because the rhythmical structure of the result is
%% undetermined in the problem definition, the context of simultaneous
%% notes can not be accessed directly and is therefore constrained by
%% logical connectives.
%%
%% Note that this dissonance treatment works fine for many cases, but it is too simplistic (e.g., for cases where passing tones occur in both voices at the same time).
%% 
%% Open parallel fifth and octaves are not allowed. Still, hidden
%% parallels are unaffected here -- in contrast to the previous
%% example.
%% 
%% Finally, both voices form a canon in the fifth: the first N notes
%% of both voices form (transposed) equivalents. In the case here,
%% N=10.
%%
%%


declare

%%
%% Top-level definition (defines constraint script) 
%%

proc {Canon Args MyScore}
   Defaults = unit(%% Number of notes per voice
		   voice1NoteNo: 17 
		   voice2NoteNo: 15 
		   %% how much later does second voice start
		   voice2OffsetTime: MaxDur*2 % (a semibreve)
		   %% interval by which the second voice transposes the first voice (in canon) 
		   transpositionInterval: 0
		   voice1PitchDomain: 53#67
		   voice2PitchDomain: 53#72
		  )
   As = {Adjoin Defaults Args}
   EndTime Voice1 Voice2
in
   MyScore =
   %% Score.makeScore transforms textual music representation into
   %% nested score object
   {Score.makeScore
    sim(items: [seq(%% when MyScore is created from this textual
		    %% representation, then Voice1 is bound to the
		    %% sequential object to which this arg handle
		    %% belongs
		    handle:Voice1  
		    items: {LUtils.collectN As.voice1NoteNo
			    %% LUtils.collectN returns a list of 17
			    %% note specs with individual variables at the
			    %% parameters duration and pitch
			    fun {$}
			       note(duration: {FD.int DurDomain}
				    pitch: {FD.int As.voice1PitchDomain}
				    amplitude: 80)
			    end}
		    offsetTime:0
		    %% Voice1 and Voice2 end at the same time (unified end times)
		    endTime:EndTime)
		seq(handle:Voice2
		    items: {LUtils.collectN As.voice2NoteNo
			    fun {$}
			       note(duration: {FD.int DurDomain}
				    pitch: {FD.int As.voice2PitchDomain}
				    amplitude: 80)
			    end}
		    %% start of Voice2 is delayed by As.voice2OffsetTime
		    offsetTime:As.voice2OffsetTime
		    endTime:EndTime)]
	startTime: 0 
	timeUnit:beats(4))  % a beat has length 4 (i.e. 1 denotes a sixteenth note)
    %% use default score constructors (i.e. the constructor for seq,
    %% sim, and note are not overwritten by user)
    unit}
   %%
   %% Apply compositional rules:
   %%
   %% rules for al notes
   {MyScore forAll(test: isNote
		   proc {$ Note}
		      {InCMajor Note}
		   end)}
   %% rules for notes of first voice
   {StartInTonic Voice1}
   %% rules applied to both voices
   {ForAll [Voice1 Voice2]
    proc {$ MyVoice}
       {StartAndEndWithLongest MyVoice}
       {EndOnFullBar MyVoice}
       {SlowRhythmChanges MyVoice}
       {NoBigJump MyVoice}
       {MaxPitchOnlyOnce MyVoice}
%        {MaxAndMinPitchOnlyOnce_AlsoForPhrases MyVoice} 
    end}
   {EndInPerfectConsonance Voice1 Voice2}
   {EndWithContraryMotion Voice1 Voice2}
   %% NOTE: tmp comment
   {ConstraintDissonance Voice1 Voice2}
   {NoParallels Voice1 Voice2}
   {IsCanon Voice1 Voice2 unit(interval:As.transpositionInterval)}
end

%%
%% Rule definitions
%%

/** %% Domain for durations
%% */
DurDomain = [8 4 2]
%% largest duration 
MaxDur = 8

/** %% The first and last note's duration of MyVoice is the greatest duration domain value (a halve note).
%% */
proc {StartAndEndWithLongest MyVoice}
   FirstNote = {MyVoice getItems($)}.1
   LastNote = {List.last {MyVoice getItems($)}}
in
   {FirstNote getDuration($)} = {LastNote getDuration($)} = MaxDur
end

/** %% The last note of MyVoice starts on a full halve note (the greatest duration domain value), that is at the beginning or the middle of a 4/4 bar. 
%% */
proc {EndOnFullBar MyVoice}
   LastNote = {List.last {MyVoice getItems($)}}
in
   {FD.modI {LastNote getStartTime($)} MaxDur} = 0
end

/** %% Two neighbouring notes in MyVoice either have the same duration, or they differ by their halve duration value (e.g., a halve note can be followed by a quarter but not by an eighth note).
%% */
proc {SlowRhythmChanges MyVoice}
   {Pattern.for2Neighbours {MyVoice mapItems($ getDuration test:isNote)}
    proc {$ Dur1 Dur2}
       HalveDur1 
    in
       {FD.times HalveDur1 2 Dur1}
       {FD.times HalveDur1 {FD.int [1 2 4]} Dur2}
    end}
end

%% MIDI pitch domain reduction: only 'white keys' (c major)
proc {InCMajor Note}
   PitchClass = {FD.int [0 2 4 5 7 9 11]}
in
   PitchClass = {FD.modI {Note getPitch($)} 12}
end
% proc {StartAndEndWithFundamental Note}
%    C = {Note getTemporalAspect($)}
% in
%    if {Note isFirstItem($ C)} orelse
%       {Note isLastItem($ C)}
%    then
%       {Note getPitch($)} = 60
%    end
% end

/** %% The first note of MyVoice is either C, E or G.
%% */
proc {StartInTonic MyVoice}
   PitchClass = {FD.int [0 4 7]}
in
   PitchClass = {FD.modI {{MyVoice getItems($)}.1 getPitch($)} 12}
end

%% voice leading: only intervals up to a fifth, no pitch repetition
%% (context dependent constraint -- getPredecessor -- but this
%% context is predetermined by predetermined hierarchic structure)
proc {NoBigJump MyVoice}
   {Pattern.for2Neighbours {MyVoice mapItems($ getPitch test:isNote)}
    proc {$ Pitch1 Pitch2}
       %% all intervals between minor second and minor third are allowed
       {FD.distance Pitch1 Pitch2 '>:' 0}
       {FD.distance Pitch1 Pitch2 '<:' 4}
    end}
end

/** %% 
%% */
proc {MaxAndMinPitchOnlyOnce_AlsoForPhrases Voice}
   proc {Aux Pitches}
      Max = {Pattern.max Pitches}
      Min = {Pattern.min Pitches}
   in
      %% the max/min pitch value occurs exactly once
      {FD.sum {Map Pitches
	       proc {$ X B}
		  B = (X =: Max)
	       end}
       '=:' 1}
      {FD.sum {Map Pitches
	       proc {$ X B}
		  B = (X =: Min)
	       end}
       '=:' 1}
      %% the first and last pitches are not max/min
      Pitches.1 \=: Max
      {List.last Pitches} \=: Max	 
      Pitches.1 \=: Min
      {List.last Pitches} \=: Min
   end
   Pitches = {Voice map($ getPitch test:isNote)}
   FirstHalfPitches
   SecondhalfPitches
in
   {List.takeDrop Pitches ({Length Pitches} div 2)
    FirstHalfPitches SecondhalfPitches}
   %% Aux applied to whole pitch sequence, but also to first and
   %% second subpart (this is a bit arbitrary, however...)
   %% NB: inefficient nesting: 'higher-level' application only needs
   %% to constraint max values of lower level
   {Aux Pitches} {Aux FirstHalfPitches} {Aux SecondhalfPitches} 
end

/** %%
%% */
proc {MaxPitchOnlyOnce MyVoice}
   proc {Aux Pitches}
      Max = {Pattern.max Pitches}
   in
      %% the max pitch value occurs exactly once
      {FD.sum {Map Pitches
	       proc {$ X B}
		  B = (X =: Max)
	       end}
       '=:' 1}
      %% the first and last pitches are not max
      Pitches.1 \=: Max
      {List.last Pitches} \=: Max
   end
   Pitches = {MyVoice map($ getPitch test:isNote)}
in
   {Aux Pitches} 
end

proc {ConstraintDissonance Voice1 Voice2}
   FirstVoiceNotes = {Voice1 getItems($)}
   SecondVoiceNotes = {Voice2 getItems($)}
in
   {List.forAllInd FirstVoiceNotes
    proc {$ I Note1}
       {List.forAllInd SecondVoiceNotes
	proc {$ J Note2}
	   IsSimultaneous = {Note1 isSimultaneousItemR($ Note2)}
	   IsConsonant = {IsConsonanceR Note1 Note2}
	in
	   %% for all notes with pre- and successor
	   if {Note1 hasPredecessor($ {Note1 getTemporalAspect($)})} andthen
	      {Note1 hasSuccessor($ {Note1 getTemporalAspect($)})} andthen
	      {Note2 hasPredecessor($ {Note2 getTemporalAspect($)})} andthen
	      {Note2 hasSuccessor($ {Note2 getTemporalAspect($)})}
	      %% if not passing note then consonant  
	   then 
	      {FD.impl IsSimultaneous
	       {Pattern.disjAll
		%% note1 is passing note, simultaneous note2 started
		%% more early, and note2 is consonant to predecessor of
		%% note1 (or the other way round)
		[{Pattern.conjAll
		  [{IsPassingNoteR Note1}
		   ({Note1 getStartTime($)} >: {Note2 getStartTime($)})
		   {IsConsonanceR {Note1 getTemporalPredecessor($)} Note2}]}
		 {Pattern.conjAll
		  [{IsPassingNoteR Note2}
		   ({Note2 getStartTime($)} >: {Note1 getStartTime($)})
		   {IsConsonanceR {Note2 getTemporalPredecessor($)} Note1}]}
		 IsConsonant]}
	       1}
	   else 
	      {FD.impl IsSimultaneous IsConsonant 1}
	   end
	end}
    end}
end
%%
proc {IsConsonanceR Note1 Note2 B}
   Pitch1 = {Note1 getPitch($)}
   Pitch2 = {Note2 getPitch($)}
   Consonances = {FS.value.make [0 3 4 7 8 9 12 15 16]}
   % Consonances = {FS.value.make [0 3 4 7 8 9 15 16]}	% alternative: no octave
   Interval = {FD.decl}
in   
   {FD.distance Pitch1 Pitch2 '=:' Interval}
   {FS.reified.include Interval Consonances B}
end
proc {PerfectConsonance Note1 Note2}
   Pitch1 = {Note1 getPitch($)}
   Pitch2 = {Note2 getPitch($)}
   Interval = {FD.int [0 7 12]}
in   
   {FD.distance Pitch1 Pitch2 '=:' Interval}
end
/** %% Interval of the last two notes (which I already know are simultaneous) is consonant. The lower note is the root.
%% */
proc {EndInPerfectConsonance Voice1 Voice2}
   Last1 = {List.last {Voice1 getItems($)}}
   Last2 = {List.last {Voice2 getItems($)}}
   MinPitch = {FD.decl}
in 
   {PerfectConsonance Last1 Last2}
   %% lower note is root 'C'
   {FD.min {Last1 getPitch($)} {Last2 getPitch($)} MinPitch}
   {FD.modI MinPitch 12} = 0
end
/** %% Cadence constraint surrogate: at least the voices should move into last interval by contrary motion.
%% */
proc {EndWithContraryMotion Voice1 Voice2}
   fun {GetLastTwoNotes MyVoice}
      {List.drop {MyVoice getItems($)} {Length {MyVoice getItems($)}}-2}
   end
   LastNotes1 = {GetLastTwoNotes Voice1}
   Dir1 = {Pattern.direction {LastNotes1.1 getPitch($)} {LastNotes1.2.1 getPitch($)}}
   LastNotes2 = {GetLastTwoNotes Voice2}
   Dir2 = {Pattern.direction {LastNotes2.1 getPitch($)} {LastNotes2.2.1 getPitch($)}}
in
   Dir1 \=: Dir2
   Dir1 \=: {Pattern.symbolToDirection '='}
   Dir2 \=: {Pattern.symbolToDirection '='}
end
proc {IsPassingNoteR Note2 B}
   Pitch1 = {{Note2 getPredecessor($ {Note2 getTemporalAspect($)})}
	     getPitch($)}
   Pitch2 = {Note2 getPitch($)}
   Pitch3 = {{Note2 getSuccessor($ {Note2 getTemporalAspect($)})}
	     getPitch($)}
   proc {IsStepR Pitch1 Pitch2 B}
      {FD.disj
       %% ?? FD.reified.distance has problems? -- I use it elsewhere here...
       {FD.conj (Pitch1 - Pitch2 >: 0) (Pitch1 - Pitch2 =<: 2)}
       {FD.conj (Pitch2 - Pitch1 >: 0)(Pitch2 - Pitch1 =<: 2)}
       B}
   end
   proc {IsContinuousDirection Pitch1 Pitch2 Pitch3 B}
      %% all pitches either lead up or down
      B = {FD.disj
	   {FD.conj (Pitch1<:Pitch2) (Pitch2<:Pitch3)}
	   {FD.conj (Pitch1>:Pitch2) (Pitch2>:Pitch3)}}
   end
in
   {Pattern.conjAll    
    %% unused: Note2 is on an easy beat (startTime is odd)
    [%% all intervals between successive pitches must be steps in same direction
     {IsStepR Pitch1 Pitch2}
     {IsStepR Pitch2 Pitch3}
     {IsContinuousDirection Pitch1 Pitch2 Pitch3}]
    B}
end
%% two notes starting at the same time (ie. simultaneous),
%% interval is perfect consonance and interval between
%% predecessors has also been that very perfect consonance
proc {OpenParallelsR Note1 Note2 B}
   %% only two voices, i.e. only one simultaneous note
        %Note2 = {Note1 getSimultaneousItems($ test:isNote)}.1
   Pitch1 = {Note1 getPitch($)}
   Pitch2 = {Note2 getPitch($)}
   PrePitch1 = {{Note1 getPredecessor($ {Note1 getTemporalAspect($)})} getPitch($)}
   PrePitch2 = {{Note2 getPredecessor($ {Note2 getTemporalAspect($)})} getPitch($)}
   %% Do note1 and note2 start at the same time?
   B1 = ({Note1 getStartTime($)} =: {Note2 getStartTime($)})
   %% Is pitch1 and pitch2 interval fifth?
   B2 = {FD.reified.distance Pitch1 Pitch2 '=:' 7}
   %% Is pitch1 predecessor and pitch2 predecessor interval fifth?
   B3 = {FD.reified.distance PrePitch1 PrePitch2 '=:' 7}
   B4 = {FD.reified.distance Pitch1 Pitch2 '=:' 0}
   B5 = {FD.reified.distance PrePitch1 PrePitch2 '=:' 0}
   B6 = {FD.reified.distance Pitch1 Pitch2 '=:' 12}
   B7 = {FD.reified.distance PrePitch1 PrePitch2 '=:' 12}
in
   %% Conjunction of all three truth values must be false
   {FD.conj B1
    {FD.disj
     {FD.conj B2 B3}
     {FD.disj
      {FD.conj B4 B5}
      {FD.conj B6 B7}}}
    B}
end
proc {NoParallels Voice1 Voice2}
   FirstVoiceNotes = {Voice1 getItems($)}
   SecondVoiceNotes = {Voice2 getItems($)}
in
   {List.forAllInd FirstVoiceNotes
    proc {$ I Note1}
       {List.forAllInd SecondVoiceNotes
	proc {$ J Note2}
	   if {Note1 hasPredecessor($ {Note1 getTemporalAspect($)})} andthen
	      {Note2 hasPredecessor($ {Note2 getTemporalAspect($)})}
	   then {OpenParallelsR Note1 Note2 0}
	   end
	end}
    end}
end

%% NOTE: with present constraint set, no solution with interval = 7.
proc {IsCanon Voice1 Voice2 Args}
   Defaults = unit(
		 %% The first CanonNo notes of each voice form a canon in a fifth
		 canonNo: 10
		 %% Interval by which second voice is transposed
		 interval:0)
   As = {Adjoin Defaults Args}
in
   for
      Note1 in {List.take {Voice1 getItems($)} As.canonNo}
      Note2 in {List.take {Voice2 getItems($)} As.canonNo}
   do
      {Note1 getPitch($)} + As.interval =: {Note2 getPitch($)}
      {Note1 getDuration($)} =: {Note2 getDuration($)}
   end
end


%%
%% Call solver (A few different distribution strategies are proposed
%% to solve this CSP).
%%

/*

{Init.setTempo 100.0}

{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit}
 unit(order:startTime
      value:mid)}


%% Randomised solution
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit}
 unit(order:startTime
      value:random)}



%% different args 
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit(voice1NoteNo: 17+6 
			  voice2NoteNo: 15+6
			  transpositionInterval: 7)}
 unit(order:startTime
      value:random)}



%% different args 
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit(voice1NoteNo: 17+6 
			  voice2NoteNo: 15+6
			  transpositionInterval: 0)}
 unit(order:startTime
      value:random)}


%%%%%%%%%%%%%%%%

%% First-fail with randomised solution
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit}
 unit(order:dom
      value:random)}



%% Randomised solution
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit(voice1PitchDomain:55#72
			  voice2PitchDomain:48#65)}
 unit(order:startTime
      value:random)}


%%%%%%%%%%%%%%%%

%% First-fail
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit}
 unit(order:dom
      value:mid)}



%% 
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit}
 unit(order:'dom/deg'
      value:mid)}


%% left to right
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit}
 unit(order:startTime
      value:mid)}


%% explicitly type-wise: first rhythmic structure than pitches
%% same performance as dom
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit}
 unit(order:{SDistro.makeSetPreferredOrder
	     [fun {$ X} {X isTimeParameter($)} end
	      fun {$ X} {X isPitch($)} end]
	     SDistro.dom}
      value:mid)}


%% even naive has reasonable performance..
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit}
 unit(order:naive
      value:mid)}


%%%%%%%%%%%%%%%%

%%
%% canon in fifth: variable ordering left-to-right is much faster than first-fail
%%

%%  
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit(transpositionInterval: 7)}
 unit(order:startTime
      value:mid)}


%% 
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit(transpositionInterval: 7)}
 unit(order:dom
      value:mid)}




{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit(transpositionInterval: 7)}
 unit(order:startTime
      value:random)}


{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript Canon
		     unit(transpositionInterval: 7)}
 unit(order:dom
      value:random)}




*/

