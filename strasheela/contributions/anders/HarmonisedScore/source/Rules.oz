
%%% *************************************************************
%%% Copyright (C) 2005 Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% This functor defines several general rules/constraints (i) on chords and/or scales and (ii) melodic rules etc.
%%
%%
%%
%% Background info to melodic rules: conventional non-harmonic note pitch conditions (according to Piston. Counterpoint, Norton, 1947) 
%%
%%   - appoggiatura (Vorhalt?): stressed dissonance: step or skip (more common than step, adds emphasis) from any direction into dissonance, resolved in second below or above. Dissonance on strong beat (requires metric position). Dissonance can be further stressed by a note duration longer than following note.
%%    Torsten added: 'likes' to resolve in semitone, specially if upwards (Mozart..)
%%
%%   - passing note (Durchgang): diatonic or chormatic progression continued in same direction. Passing note always weak rhythmical quality -- even when occuring on first beat of measure (!!). According to Piston, notes are analysed as either appoggiatura or passing only depending on their rhythmic weight.
%%     Exceptionally are 'passing notes' without any directly preceeding notes (this note sounded in other voice). 
%%
%%   - suspension (vorbereiteter Vorhalt?): in classic case, a (comparatively long) harmonic note is 'tied over' -- the harmony changes and turnes the 'tied over' note into a non-harmonic note. Usually/often, this dissonance longs at least a beat. Suspensions are resolved in stepwise motion (usually downwards, upwards more likely in case of leading notes  or chormatically raised notes). The suspension may resolved into next harmony (i.e. after the harmony it formed a dissonance in). The suspendend note is (in all cases?) longer than its successor.
%%
%%   - anticipation (Vorausnahme): dissonant note on easy beat preceeding the same consonant note pitch on strong beat (i.e. the harmony changed). The dissonant anticipation is shorter than its consonant successor.
%%
%%   - auxiliary (Nebennote): ornamental single note, leaving and returning to the same note by a second up or down. The harmony may meanwhile change.
%%
%%   - echappee/cambiata (Torsten: standardised case of ornamental resolution?): stepwise movement of melody 'ornamented' note between. Echappee: leaves first note by stepwise motion in opposite direction and 'resolves' by skip of third to destination. Cambiata: first note by skip of third in opposite direction and 'resolves' by step to destination. Echappee and cambiata are rhythmically weak.
%%     Variants with more freedom: larger skip than third or all movements in same direction (quasi like passing note with skip). Combination to double auxiliary (or changing-tones): echappee and cambiata follow each other directly as two dissonances.  
%%
%%   - ornamental resolution: (i) multiple 'standard' dissonances directly following each other. E.g., appoggiatura directly followed by cambiata (i.e. with delayed resolution). (ii) arbitrary consonant chord note between 'standard' dissonance treatment. E.g., before passing note skip to some other chord note and (possibly) skip back to actual passing note. (iii) a group of interpolated tones (Piston recomments studying Bach 'Italian Concerto')
%%
%%
%% Problem with specific non-harmonic pitches, especially appoggiatura, in this context: how to 'motivate' non-harmonic pitches. E.g. in case of melody harmonisation, obviously harmonic pitches followed by a passing note could be understood as non-harmonic pitches which resolve into a harmonic pitch..
%%
%% */


%%
%% TODO:
%%
%% * redesign/abstract the constraints/rules in comments
%%
%% 
%% Rules 
%% 
%%
%% - Rule defined for single note object which allows to access of its predecessors/successors in seq and the chord: any skip from previous note are fine if both are chord tones, but non-chord tones must be connected by step to previous note (and successor note??)
%%   -> This allows for passing tones and auxiliary tones. If previous and/or successor note does not need to be chord tone either, then I have multiple 
%% -> extra rule: last note in seq is chord tone..
%%
%%


%%
%% define the following non-harmonic tones (perhaps try to generalise)
%% Problem: I don't necessarily have representation of / access to rhythmic weight
%%
% Literature: Piston, Counterpoint, p. 46 ff


%      preceding interval	 successing interval	rhythmic weight

%      appogiatura: 
%      usually skip	 step			strong beat (often longer note)


%      passing tone:
%      step		step (same direction)	weak (often short note)


%      auxiliary
%      step		step (opposite dir.)	weak

%      suspension
%      same tone (tie)	step			strong (often long note)


%      anticipation
%      ?? step or skip	same tone		very weak


%      echappee / cambiata: both are ornamented steps (or larger intervals?). Both can directly follow each other (double auxiliary)
%      echappee: ornamented step (or skip) where diss. middle tone moves first in opposite direction
%      step		 skip (opposite dir.)  weak
%      cambiata: ornamented step where diss. middle tone moves first 'too far'
%      skip		 step (opposite dir.)
     


% Problem: Multiple non-harmonic tones can be combined in succession. Problem: a non-harmonic tone may relate to later tone and other non-harmonic tones are inserted before. E.g. in C-major: c d [passing tone leading to e] f [cambiata] e
%%
%% -> I can define this with reified constraints relating diss note to first note pitch with InChordB=1, but still it is rather complex..
%%



functor
import
   
   FD FS
%    Browser(browse:Browse) % temp for debugging
   Select at 'x-ozlib://duchier/cp/Select.ozf'
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
   SMapping at 'x-ozlib://anders/strasheela/source/ScoreMapping.ozf'
%    Score at 'x-ozlib://anders/strasheela/ScoreCore.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS_Score at 'Score.ozf'
   DB at 'Database.ozf'
   Schoenberg at 'Schoenberg.ozf'
   
export

   %% subfunctors
   Schoenberg

   %% chord / scale rules
   GetFeature
   UnequalParameter UnequalParameterR NeighboursWithUnequalParameter
   Distinct DistinctR DistinctNeighbours
   PairwiseDistinct ButNDistinct DistinctForN
   CommonPCs CommonPCs_Card CommonPCsR NeighboursWithCommonPCs 
   ParameterDistance ParameterDistanceR LimitParameterDistanceOfNeighbours

   Cadence
   DiatonicChord NoteInPCCollection

   ExpressAllChordPCs ExpressAllChordPCs_AtChordStart ExpressEssentialChordPCs ExpressEssentialPCs_AtChordStart
   ClearHarmonyAtChordBoundaries

   VoiceLeadingDistance VoiceLeadingDistance_Percent
   SmallIntervalProgressions SmallIntervalProgressions_Percent

   %% melodic rules
   IsStep IsStepR
   ResolveStepwiseR
   PassingNotePitches PassingNotePitchesR
   IsPassingNoteR
   IsBetweenChordNotesR
   IsAuxiliaryR
   IsBetweenStepsR

   ResolveNonharmonicNotesStepwise

   ClearDissonanceResolution IntervalBetweenNonharmonicTonesIsConsonant
   MaxInterval MaxNonharmonicNoteSequence MaxNonharmonicNotePercent MaxRepetitions MinPercentSteps

   

   %% aux constraints 
   GetInterval
   ConstrainMaxIntervalR
   
define

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% rules on chord(s)/scale(s)
%%%
   
   /** %% Constraints the chord/scale X: the arbitrary (user defined) chord/scale database feature value at Feat is accessed/constrained to I (a FD int or FS var, depending on the feature). For instance, if X is a chord and the chord database defines a numeric 'dissonanceDegree' for each chord in the database, <code> {GetFeature X 'dissonanceDegree' 2} </code> constraints the index of X to point to a chord spec in the database which has a dissonanceDegree of 2.
   %% NB. GetFeature employs a selection constrain: multiple applications of GetFeature with the same Feat will accessed/constrain the same value I with multiple selection constraint propagators, which should be avoided..
   %%
   %% !! NB: does not work for intervalDB, because there is no interval ADT which defines getDB and getIndex for interval.
   %% */
   proc {GetFeature X Feat I}
      FeatDB = {X getDB($)}.Feat
      % FD or FS selection constraint needed?
      SelectConstraint = if {FD.is FeatDB.1}
			 then Select.fd
			 elseif {GUtils.isFS FeatDB.1}
			 then Select.fs
			 else raise malformedFeatDB(FeatDB) end
			 end
   in
      I = {SelectConstraint FeatDB {X getIndex($)}} 
   end

   
   /** %% The chords/scales X and Y differ in the parameter/attribute accessed by Fn (a unary function or method). For instance, <code> {UnequalParameter X Y getIndex} </code> constrains the indices of X and Y to differ.
   %% */
   %% !!?? I could generalise this def by providing an additional arg A (a relation symbol as '=:', '>:', '>=:', '<:', '=<:', or '\\=:')
   proc {UnequalParameter X Y Fn}
      {{GUtils.toFun Fn} X} \=: {{GUtils.toFun Fn} Y}
   end
   /** %% Reified version of DistinctParameter: B=1 <-> chords/scales X and Y differ in the parameter/attribute accessed by Fn.
   %% */
   proc {UnequalParameterR X Y Fn B}
      B = ({{GUtils.toFun Fn} X} \=: {{GUtils.toFun Fn} Y})
   end
   /** %% All successive chord/scale pairs in list Xs differ in the parameter/attribute accessed by Fn.
   %% */ 
   %% !!?? do reified version as well
   proc {NeighboursWithUnequalParameter Xs Fn}
      {Pattern.for2Neighbours Xs
       proc {$ X Y}
	  {UnequalParameter X Y Fn}
	  % {{GUtils.toFun Fn} X} \=: {{GUtils.toFun Fn} Y}
       end}
   end
   
   /** %% The chords/scales X and Y have either different indices or different transpositions or both. 
   %% */
   proc {Distinct X Y}
      {DistinctR X Y 1}
   end
   /** %%  B=1 <-> The chords/scales X and Y have either different indices or different transpositions or both.
   %% */
   proc {DistinctR X Y B}
      {FD.disj
       ({X getIndex($)} \=: {Y getIndex($)})
       ({X getTransposition($)} \=: {Y getTransposition($)})
       B}
   end
   /** %% All successive chord/scale pairs in list Xs have either different indices or different transpositions or both.
   %% */ 
   %% !!?? do reified version as well
   proc {DistinctNeighbours Xs}
      {Pattern.for2Neighbours Xs Distinct}
   end
   /** %% All chords/scales in list Xs are pairwise distinct, i.e. they have either different indices or different transpositions or both.
   %% */
   proc {PairwiseDistinct Xs}
      {ButNDistinct Xs 0}
   end  
   /** %% All but N (a FD int) chords/scales in list Xs are pairwise distinct, i.e. they have either different indices or different transpositions or both. That is, N=4 <-> four chords/scales are not unique in Xs (either all four are the same or two different chords/scales repeated).
   %% */
   proc {ButNDistinct Xs N}
      {FD.sum {Pattern.mapPairwise Xs
	       fun {$ X Y} {FD.nega {DistinctR X Y}} end}
       '=:' N}
   end
  
   /** %% Xs (a list of chords/scales) is split into sublists of length N: in each sublist, all chords/scales are pairwise distinct.
   %% */
   %% !!?? I may generalise calling ButNDistinct instead of PairwiseDistinct: each sublist may have a (constrainable) number of chord/scale doubles. 
   proc {DistinctForN Xs N}
      %% Split Xs into sublists of length N
      Xss = {Map {List.number 0 {Length Xs}-N N}
	     fun {$ I} {List.take {List.drop Xs I} N} end}
   in
      {ForAll Xss PairwiseDistinct}
   end


   /** %% Constraints the chords/scales X and Y to have at least 1 common pitch class.
   %% */
   proc {CommonPCs X Y}
      PC1 = {X getPitchClasses($)}
      PC2 = {Y getPitchClasses($)}
      HarmBand = {FS.var.decl}
      HarmBandWidth = {FS.card HarmBand}
   in
      HarmBandWidth >: 0 
      {FS.intersect PC1 PC2 HarmBand}
   end

   
   /** %% N (an FD int) is the cardiality of the set of common pitch classes between the chords/scales X and Y.
   %% */
   proc {CommonPCs_Card X Y N}
      PC1 = {X getPitchClasses($)}
      PC2 = {Y getPitchClasses($)}
      HarmBand = {FS.var.decl}
   in
      N = {FS.card HarmBand}
      {FS.intersect PC1 PC2 HarmBand}
   end
   
   /** %% Reified version of CommonPCs: B=1 <-> chords/scales X and Y have at least 1 common pitch class. 
   %% */
   proc {CommonPCsR X Y B}
      HarmBandWidth = {CommonPCs_Card X Y}
   in
      B = {FD.int 0#1}
      B =: (HarmBandWidth >: 0) 
   end
   /** %% Each successive chord/scale pair in list Xs has at least 1 common pitch class.
   %% NB: The constraint introduces auxilary variables which possibly remain undetermined in the solution. 
   %% */
   %% !!?? do reified version as well
   proc {NeighboursWithCommonPCs Xs}
      {Pattern.for2Neighbours Xs CommonPCs}
   end
   

   /** %% Constraints the distance between the parameter/feature accessible with Fn of the chords/scales X and Y to I (a FD integer). For instance, if X and Y are chords and the chord database defines the numeric feature dissonanceDegree, the dissonanceDegree distance between X and Y is set to 1 by
   %% <code> {ParameterDistance X Y fun {$ X} {GetFeature X dissonanceDegree} end 1} </code>
   %% */
   proc {ParameterDistance X Y Fn I}
      {FD.distance
       {{GUtils.toFun Fn} X}
       {{GUtils.toFun Fn} Y}
       '=:' I}
   end
   /** %% Reified version of ParameterDistance.
   %% */
   proc {ParameterDistanceR X Y Fn I B}
      B = {FD.decl}
      B = {FD.reified.distance
	   {{GUtils.toFun Fn} X}
	   {{GUtils.toFun Fn} Y}
	   '=:' I}
   end
   /** %% Limits the the distance between the parameter/feature accessible with Fn of the neigbouring chords/scales in Xs not to exceed Max (a FD integer, but in most cases an integer will do).
   %%
   %% !! Better define LimitDistanceOfNeighbours as Pattern expecting list of FD ints..
   %% */
   proc {LimitParameterDistanceOfNeighbours Xs Fn Max}
      {Pattern.for2Neighbours Xs
       proc {$ X Y}
	  {FD.distance
	   {{GUtils.toFun Fn} X}
	   {{GUtils.toFun Fn} Y}
	   '=<:' Max}
       end}
   end


   /** %% Constraints the union of the pitch classes of Chords (a list of chord objects) to be the same set as the set of pitch classes of MyScale (a scale object). In other words, all chords only use scale tones (diatonic chords) and all scale tones are played.  Also, the root of the last chord is constrained to the root of the scale.
   %% In common usage, Chords has length three and is applied to the last three chords of a progression.
   %% This constraint goes well with HS.rules.schoenberg.ascendingProgressionR and frieds (results in the common cadences for major in 12 ET, and plagal cadences for natural minor).
   %%
   %% Note: this constraint implements a particular strict notion of a cadence, were all scale notes must sound. A less strict version would require that only pitch classes which distinguish a scale among all other likely scales are sufficient (e.g., the pitch classes G, B, and F are sufficient to distinguish C-major between all major scales). However, such a constraint is more context dependent and requires information on all scales which are alternatively possible (e.g., G, B, and F are not sufficient to confirm C-major if the scale could also be Dorian). 
   %% */
   proc {Cadence MyScale Chords}
      {MyScale getPitchClasses($)} = {FS.unionN
				      {Map Chords fun {$ C} {C getPitchClasses($)} end}}
      {MyScale getRoot($)} = {{List.last Chords} getRoot($)}
   end
   /** %% All pitch classes of MyChord are in MyScale (scale must of course not diatonic, procedure name uses the phrase "diatonic to" as a synonym for "belonging to"). 
   %% */
   proc {DiatonicChord MyChord MyScale}
      {FS.subset {MyChord getPitchClasses($)} {MyScale getPitchClasses($)}}
   end
   /** %% The pitch class of MyNote is in MyPCCollection (a chord or a scale).
   %% */
   proc {NoteInPCCollection MyNote MyPCCollection}
      {FS.include {MyNote getPitchClass($)} {MyPCCollection getPitchClasses($)}}
   end
   

   /** %% The union of the pitch classes of all notes notes simultaneous to MyChord fully expresses the pitch class set of this chord (more pitch classes are possibly, but all chord pitch classes must be played). 
   %% */
   proc {ExpressAllChordPCs MyChord}
      thread	% waits until sim notes are accessible
	 PCs = {Map {MyChord getSimultaneousItems($ test:isNote)}
		fun {$ N} {N getPitchClass($)} end}
	 PCsFS = {GUtils.intsToFS PCs}
      in
	 {FS.subset {MyChord getPitchClasses($)} PCsFS}
      end
   end
   /** %% More strict variant of ExpressAllChordPCs: all pitch classes must sound when chord starts.
   %% */
   proc {ExpressAllChordPCs_AtChordStart MyChord}
      thread	% waits until sim notes are accessible
	 PCs = {Map {MyChord getSimultaneousItems($ test:fun {$ X}
							    {X isNote($)} andthen
							    ({X getStartTime($)} =<: {MyChord getStartTime($)}) == 1
							 end)}
		fun {$ N} {N getPitchClass($)} end}
	 PCsFS = {GUtils.intsToFS PCs}
      in
	 {FS.subset {MyChord getPitchClasses($)} PCsFS}
      end
   end

   /** %% The union of the pitch classes of all notes notes simultaneous to MyChord fully express at least all essential pitch classes of this chord.
   %% NB: the the essential pitch classes must be defined with the feature essentialPitchClasses in the chord DB.
   %%
   %% BUG: this constraint failed where ExpressAllChordPCs worked -- so there is likely a serious bug.
   %% */
   proc {ExpressEssentialChordPCs MyChord}
      thread	% waits until sim notes are accessible
	 PCs = {Map {MyChord getSimultaneousItems($ test:isNote)}
		fun {$ N} {N getPitchClass($)} end}
	 PCsFS = {GUtils.intsToFS PCs}
      in
	 {FS.subset {GetFeature MyChord essentialPitchClasses} PCsFS}
      end
   end
   /** %% More strict variant of ExpressEssentialChordPCs: all essential pitch classes must sound when chord starts.
   %% Because constraint application is not delayed so long, this more strict version can actuallyt be more efficient. 
   %%
   %% BUG: this constraint failed where ExpressAllChordPCs worked -- so there is likely a serious bug.
   %% */
   proc {ExpressEssentialPCs_AtChordStart MyChord}
      thread	% 
	 PCs = {Map {MyChord getSimultaneousItems($ test:fun {$ X}
							    {X isNote($)} andthen
							    ({X getStartTime($)} =<: {MyChord getStartTime($)}) == 1
							 end)}
		fun {$ N} {N getPitchClass($)} end}
	 PCsFS = {GUtils.intsToFS PCs}
      in
	 {FS.subset {GetFeature MyChord essentialPitchClasses} PCsFS}
      end
   end



   /** %% Defines contrapuntal constraint which implements proper suspension and other things. Chords is a list of chord objects and VoiceNotes a list of note objects which all belong to a single voice. At the border between two chords, the last voice note simultaneous to the preceeding chord and the first note simultaneous to the succeeding chord, these two notes should not be both non-chord tones (note: these two notes can be the same or different score objects, and have the same or different pitches).
   %% If the first note of a chord is a non-chord tone, then it should have the same pitch as the last of the previous chord. In other words: if a chord starts with a non-chord tone, then it must be a suspension (suspension are of course less clear in a solo line...). 
   %% NB: this constraint assumes that neighbouring chords differ (e.g., have a different root), otherwise it is too strict.
   %% NB: this constraint does not define that non-chord tones are resolved stepwise, but it can be combined, e.g.., with ResolveNonharmonicNotes.
   %%
   %% Internally, each chord accesses its first/last simultaneous note within VoiceNotes. 
   %% */
   proc {ClearHarmonyAtChordBoundaries Chords VoiceNotes}
      {Pattern.for2Neighbours Chords 
       proc {$ C1 C2}
	  thread	% waits until sim notes are accessible
	     C1_LastNote = {List.last {SMapping.filterSimultaneous VoiceNotes C1}}
	     C2_FirstNote = {SMapping.filterSimultaneous VoiceNotes C2}.1
	  in
	     %% at least one is a chord tone
	     {C1_LastNote getInChordB($)} + {C2_FirstNote getInChordB($)} >=: 1
	     %% if a chord starts with a non-chord tone, then it must be a suspension
	     {FD.impl {FD.nega {C2_FirstNote getInChordB($)}}
	      ({C1_LastNote getPitch($)} =: {C2_FirstNote getPitch($)})
	      1}
	  end
       end}
   end

   /** %% Harmonic constraint on directionless voice-leading distance N (FD int, measured in steps of the present equal temperament) between two chords Chord1 and Chord2. The distance N is the minimal sum of intervals between Chord1 and Chord2. The voice-leading distance is directionless in the sense that regardless whether a voice moves up or down, always the smaller interval is taken into account.  
   %% 
   %% Example (in 12 ET): {VoiceLeadingDistance C_Major Ab_Major} = 2
   %% C->C=0 + E->Eb=1 + G->Ab=1, so the sum is 2
   %%
   %% Note: Only the minimal intervals from all Chord2 pitch classes to Chord1 pitch classes are taking into account. Swapping the arguments can lead to different results: there may be pitch classes in Chord1 which are ignored as all pitch classes of Chord2 may be closer to some other pitch classes of Chord1.
   %%
   %% Example: C-maj -> F#-maj = 4
   %% C->C#=1, C->A#=2, G->F#=1 -- the E of C-maj is ignored in the computation  
   %%
   %% Note: relatively expensive constraint. Also, only effective after of both Chord1 and Chord2 are (mostly) determined.
   %% */
   proc {VoiceLeadingDistance Chord1 Chord2 N}
      thread	    % blocks until cardiality of chords are determined
	 PC_Dom = 0#{DB.getPitchesPerOctave}-1
	 Card1 = {FS.card {Chord1 getPitchClasses($)}}
	 Card2 = {FS.card {Chord2 getPitchClasses($)}}
	 MaxCard = {Max Card1 Card2}
	 Chord1_PCs = {FD.list Card1 PC_Dom}
	 Chord2_PCs = {FD.list Card2 PC_Dom}
      in
	 %% theoretical max: all intervals are halve octave
	 N = {FD.int 0#MaxCard*{DB.getPitchesPerOctave} div 2}	 
	 %% blocks until chord PCs are know?
	 {FS.int.match {Chord1 getPitchClasses($)} Chord1_PCs}
	 {FS.int.match {Chord2 getPitchClasses($)} Chord2_PCs}
	 %%
	 N = {FD.sum
	      {Map Chord2_PCs
	       %% Return min interval of PC2 to any of Chord1_PCs
	       fun {$ PC2}
		  {Pattern.min
		   {Map Chord1_PCs
		    %% return min of PC2->PC1 interval and its complement
		    fun {$ PC1}
		       PC_Interval = {DB.makePitchClassFDInt}
		       PC_Interval_Compl = {FD.int 1#{DB.getPitchesPerOctave}}
		    in
		       {HS_Score.transposePC PC2 PC_Interval PC1}
		       PC_Interval_Compl =: {DB.getPitchesPerOctave} - PC_Interval
		       {FD.min PC_Interval PC_Interval_Compl}
		    end}}
	       end}
	      '=:'}
      end
   end

   /** %% Like VoiceLeadingDistance, but returns a percentage value depending on the cardiality of both Chord1 and Chord2. 100 percent is the theoretical maximum that all intervals are halve octaves.
   %% */ 
   fun {VoiceLeadingDistance_Percent Chord1 Chord2}
      thread
	 Card1 = {FS.card {Chord1 getPitchClasses($)}}
	 Card2 = {FS.card {Chord2 getPitchClasses($)}}
	 MaxCard = {Max Card1 Card2}
	 N = {VoiceLeadingDistance Chord1 Chord2}
      in
	 {GUtils.percent N MaxCard*{DB.getPitchesPerOctave} div 2}
      end
   end
   
   /** %% Harmonic constraint for creating chord progressions where many pitch classes change by small intervals. N (FD int, implicitly declared) is the number of pitch class intervals between Chord1 and Chord2 which are =< some maximal interval, typically a semitone. 
   %% Args:
   %% 'maxInterval': the maximum size of the interval which counts into the percentage. Default is the septimal diatonic semitone (15#14).
   %% 'ignoreUnisons': if true (the default), unisons do not count into the percentage.
   %% 
   %% Examples:
   %%
   %% {SmallIntervalProgression C_Major Ab_Major unit} = 2
   %% Small intervals counting: E->Eb, G->Ab 
   %%
   %% {SmallIntervalProgression C_Major Ab_Major unit(ignoreUnisons:false)} = 3
   %% Small intervals counting: C->C, E->Eb, G->Ab 
   %%
   %% Note: relatively expensive constraint. Also, only effective after of both Chord1 and Chord2 are (mostly) determined. 
   %% */
   proc {SmallIntervalProgressions Chord1 Chord2 Args ?N}
      Defaults = unit(maxInterval: 15#14
		      ignoreUnisons:true)
      As = {Adjoin Defaults Args}
      MaxInterval = {FloatToInt {MUtils.ratioToKeynumInterval As.maxInterval
				 {IntToFloat {DB.getPitchesPerOctave}}}}
   in
      N = {FD.decl}
      thread	    % blocks until cardiality of chords are determined
	 PC_Dom = 0#{DB.getPitchesPerOctave}-1
	 Card1 = {FS.card {Chord1 getPitchClasses($)}}
	 Card2 = {FS.card {Chord2 getPitchClasses($)}}
	 MaxCard = {Max Card1 Card2}
	 Chord1_PCs = {FD.list Card1 PC_Dom}
	 Chord2_PCs = {FD.list Card2 PC_Dom}
      in
	 N = {FD.int 0#MaxCard}
	 %% blocks until chord PCs are know?
	 {FS.int.match {Chord1 getPitchClasses($)} Chord1_PCs}
	 {FS.int.match {Chord2 getPitchClasses($)} Chord2_PCs}
	 %%
	 N = {FD.sum
	      {Pattern.mapCartesianProduct Chord1_PCs Chord2_PCs
	       proc {$ PC1 PC2 B}
		  PC_Interval = {DB.makePitchClassFDInt}
		  PC_Interval_Compl = {FD.int 1#{DB.getPitchesPerOctave}}
		  PC_Interval_Aux = {DB.makePitchClassFDInt} % redundant..
	       in
		  {HS_Score.transposePC PC1 PC_Interval PC2}
		  PC_Interval_Compl =: {DB.getPitchesPerOctave} - PC_Interval
		  PC_Interval_Aux = {FD.min PC_Interval PC_Interval_Compl}
		  if As.ignoreUnisons then
		     B = {FD.conj
			  (PC_Interval_Aux =<: MaxInterval)
			  (PC1 \=: PC2)}
		  else
		     B = (PC_Interval_Aux =<: MaxInterval)
		  end
	       end}
	      '=:'}
      end
   end
   
   
   /** %% Like SmallIntervalProgressions, but returns a percentage value depending on the cardiality of both Chord1 and Chord2. 100 percent is the cardiality of the chord with more notes.
   %% */ 
   fun {SmallIntervalProgressions_Percent Chord1 Chord2 Args}
      thread
	 Card1 = {FS.card {Chord1 getPitchClasses($)}}
	 Card2 = {FS.card {Chord2 getPitchClasses($)}}
	 MaxCard = {Max Card1 Card2}
	 N = {SmallIntervalProgressions Chord1 Chord2 Args}
      in
	 {GUtils.percent N MaxCard}
      end
   end
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% melodic rules
%%%

   /** %% [aux def] Returns the list of items of the temporal aspect X is contained in.
   %% */
   fun {GetTemporalAspectItems X}
      {{X getTemporalAspect($)} getItems($)}
   end

   /** %% The interval between Pitch1 and Pitch2 is in [1, MaxStep].
   %% */
   proc {IsStep Pitch1 Pitch2 MaxStep}
      Interval = {FD.int 1#MaxStep}
   in
      {FD.distance Pitch1 Pitch2 '=:' Interval}
   end
   /** %% In case B=1, the interval between Pitch1 and Pitch2 is in [1, MaxStep]. B is implicitly declared an 0/1 integer. 
   %% */
   proc {IsStepR Pitch1 Pitch2 MaxStep B}
      Interval = {FD.int 1#MaxStep}
   in
      B = {FD.reified.distance Pitch1 Pitch2 '=:' Interval}
   end

   /** %% Constraints the interval between the pitches of Note and its successor to be in [0, MaxStep]. MaxStep defaults to 2 and can be set as optional feature of Args. Per default, the successor note is the successor of Note in the sequence of items contained in the temporal aspect of Note (i.e. the sequence/list returned by {GetTemporalAspectItems Note}). This setting can be changed with the optional Args feature getXs (e.g. to a function which does return the list of items recursively contained in the temporal aspect of the temporal aspect Note. Such setting would apply ResolveStepwiseR even across container boundaries when Note is the last element in its temporal aspect).
   %% In case Note has no successor, B=0.
   %%
   %% BTW: ResolveStepwiseR defines a dissonance treatment simplification. Most of the conventional non-harmonic note pitch conditions identified by Piston (see above) are permitted: appoggiatura, passing note, suspension, anticipation, auxiliary, and cambiata. Only the echappee is excluded by ResolveStepwiseR.
   %% Nevertheless, the simplification ResolveStepwiseR allows also cases which are not permitted by the conventional non-harmonic note pitch treatment (e.g. an appoggiatura on an easy beat, or a long anticipation which preceeds a short note on an easy beat).
   %% Problem: if any note (even regardless of metric position) can be understood as appoggiatura, the implicit harmony is easily misread.
   %% */
   proc {ResolveStepwiseR Note Args B}
      Defaults = unit(maxStep:2
		      getXs:GetTemporalAspectItems)
      As = {Adjoin Defaults Args}
   in
      {SMapping.patternMatchingApply2 Note {As.getXs Note}
       [x o]		
       proc {$ [Note1 Note2]}
	  %% difference to IsStepR: interval can be 0
	  B = {FD.reified.distance
	       {Note1 getPitch($)} {Note2 getPitch($)} '=<:' As.maxStep}
       end
       %% else
       proc {$} B=0 end}
   end

   
   /** %% In case B=1, both the predecessor and successor of Note return 1 (i.e. true) for the method isInChord (which means that both notes are harmonic notes: their pitch class is included in the pitch classes of their repsective chord).  Args is a record with the optional argument getXs, a unary function applied to Note returning the list of items in the melody including Note, defaults to the items in the temporal aspect of Note.   
   %% In case Note has no predecessor or successor, B=0. 
   %% */
   proc {IsBetweenChordNotesR Note Args B}
      Defaults = unit(getXs:GetTemporalAspectItems)
      As = {Adjoin Defaults Args}
   in
      {SMapping.patternMatchingApply2 Note {As.getXs Note}
       [o x o]	
       proc {$ [Note1 _ Note3]}
	  B = {FD.conj
	       {Note1 isInChord($)}
	       {Note3 isInChord($)}}
       end
       %% else
       proc {$} B=0 end}
   end
   
   /** %% Constraints [Pitch1 Pitch2 Pitch3] such that Pitch2 forms a passing note pitch. The intervals between neighbouring pitches are in [1, MaxStep] (usually, MaxStep = PitchesPerOctave div 6) and the pitch sequence is either monotonically increasing or decreasing. All pitches are FD ints, MaxStep is int.
   %% NB: for this rule, it is irrelevant whether any pitch is consonant, or dissonant and whether it is a chord pitch or not.
   %% */
   proc {PassingNotePitches [Pitch1 Pitch2 Pitch3] MaxStep}
      %% all intervals between successive pitches must be steps
      {IsStep Pitch1 Pitch2 MaxStep}
      {IsStep Pitch2 Pitch3 MaxStep}
      %% all pitches either lead up or down
      {FD.disj
       {FD.conj (Pitch1<:Pitch2) (Pitch2<:Pitch3)}
       {FD.conj (Pitch1>:Pitch2) (Pitch2>:Pitch3)}
       1}
   end

   /** %% Reified version of PassingNotes (see above).
   %% NB: Introduces a FD int which may not be determined (in case B=0).
   %% */
   proc {PassingNotePitchesR [Pitch1 Pitch2 Pitch3] MaxStep B}
      B = {FD.conj
	   %% all intervals between successive pitches must be steps
	   {FD.conj {IsStepR Pitch1 Pitch2 MaxStep}
	    {IsStepR Pitch2 Pitch3 MaxStep}} 
	   %% all pitches either lead up or down
	   {FD.disj
	    {FD.conj (Pitch1<:Pitch2) (Pitch2<:Pitch3)}
	    {FD.conj (Pitch1>:Pitch2) (Pitch2>:Pitch3)}}}
   end

   /** %% In case B=1, Note is a passing note between its predecessor and successor. Args is a record of optional arguments: maxStep (defaults to 2) and getXs, a unary function applied to Note returning the list of items in the melody including Note, defaults to the items in the temporal aspect of Note.
   %% See also PassingNotePitches and PassingNotePitchesR above.
   %% In case Note has no predecessor or successor, B=0.
   %% BTW: IsPassingNoteR is a generic passing note definition which can be applied, e.g., to a melody across container boundaries (e.g. a melody consisting in motifs which consist in note sequences) by returning the list of notes in this melody from getXs.
   %% NB: Predecessor and successor of Note must be notes as well!
   %% */ 
   proc {IsPassingNoteR Note Args B}
      Defaults = unit(maxStep:2
		      getXs:GetTemporalAspectItems)
      As = {Adjoin Defaults Args}
   in
      {SMapping.patternMatchingApply2 Note {As.getXs Note}
       [o x o]			% apply to [Predecessor Note Successor]
       proc {$ [Note1 Note2 Note3]}
	  B = {PassingNotePitchesR
	       [{Note1 getPitch($)}
		{Note2 getPitch($)}
		{Note3 getPitch($)}]
	       As.maxStep}
% 	  if {Note1 isNote($)} andthen {Note2 isNote($)} andthen {Note3 isNote($)}
% 	  then B = {PassingNotePitchesR
% 		    [{Note1 getPitch($)}
% 		     {Note2 getPitch($)}
% 		     {Note3 getPitch($)}]
% 		    As.maxStep}
% 	  else {Browse 'warning: '#IsPassingNoteR#' tried to apply pitch constraint on these objects: '#[Note1 Note2 Note3]}
% 	  end
       end
       %% else
       proc {$} B=0 end}
   end

   /** %% In case B=1, both the predecessor and successor of Note have the same pitch and the pitch of Note is only a step away.
   %% Args is a record with the optional argument maxStep (defaults to 2) and getXs (a unary function applied to Note returning the list of items in the melody including Note, defaults to the items in the temporal aspect of Note). See also ResolveStepwiseR for an explaination of Args.
   %% In case Note has no predecessor or successor, B=0. 
   %% NB: Predecessor and successor of Note must be notes as well!
   %% */
   proc {IsAuxiliaryR Note Args B}
      Defaults = unit(maxStep:2
		      getXs:GetTemporalAspectItems)
      As = {Adjoin Defaults Args}
   in
      {SMapping.patternMatchingApply2 Note {As.getXs Note}
       [o x o]	
       proc {$ [Note1 Note2 Note3]}
	  Pitch1 = {Note1 getPitch($)}
	  Pitch2 = {Note2 getPitch($)}
	  Pitch3 = {Note3 getPitch($)}
       in
	  B = {FD.conj
	       (Pitch1 =: Pitch3)
	       {IsStepR Pitch1 Pitch2 As.maxStep}}
       end
       %% else
       proc {$} B=0 end}
   end
   
   /** %% In case B=1, both the pitches of the predecessor and successor are only a step away from Note's pitch.
   %% Args is a record with the optional argument maxStep (defaults to 2) and getXs (a unary function applied to Note returning the list of items in the melody including Note, defaults to the items in the temporal aspect of Note). See also ResolveStepwiseR for an explaination of Args.
   %% In case Note has no predecessor or successor, B=0.
   %%
   %% BTW: This rule generalises passing note and auxiliary. Nevertheless, a further case is also permitted: pitch contour between three successive notes as for an auxiliary, but predecessor and successor have different pitches. For instance, in case maxStep=2, predecessor and successor differ by a semitone.
   %% NB: Predecessor and successor of Note must be notes as well!
   %% */
   proc {IsBetweenStepsR Note Args B}
      Defaults = unit(maxStep:2
		      getXs:GetTemporalAspectItems)
      As = {Adjoin Defaults Args}
   in
      {SMapping.patternMatchingApply2 Note {As.getXs Note}
       [o x o]	
       proc {$ [Note1 Note2 Note3]}
	  Pitch1 = {Note1 getPitch($)}
	  Pitch2 = {Note2 getPitch($)}
	  Pitch3 = {Note3 getPitch($)}
       in
	  B = {FD.conj
	       {IsStepR Pitch1 Pitch2 As.maxStep}
	       {IsStepR Pitch2 Pitch3 As.maxStep}}
       end
       %% else
       proc {$} B=0 end}
   end


   /** %% Melodic constraint for list of Notes: non-chord tones are only permitted if they are reached and left by a step. The first and last element of Notes is constrained to a chord tone.
   %%
   %% Args:
   %% 'maxInterval': an ratio spec for the maximum step-size permitted. Default is a septimal second (8#7). 
   %% */
   proc {ResolveNonharmonicNotesStepwise Notes Args}
      Defaults = unit(maxInterval: 8#7)
      As = {Adjoin Defaults Args}
      MaxInterval = {FloatToInt {MUtils.ratioToKeynumInterval As.maxInterval
				 {IntToFloat {DB.getPitchesPerOctave}}}}
   in
      {Pattern.forNeighbours Notes 3
       proc {$ [N1 N2 N3]}
	  /** %% B=1 <-> MyNote is entered and left by a step.
	  %% */
	  proc {Aux N2 B}
	     B = {FD.int 0#1}		% needed?
	     B = {FD.conj {ConstrainMaxIntervalR N1 N2 MaxInterval}
		  {ConstrainMaxIntervalR N2 N3 MaxInterval}}
	  end
       in
	  {N2 nonChordPCConditions([Aux])}
       end}
      %% Explicitly constrain that first and last note must be chord tones
      {Notes.1 getInChordB($)} = 1
      {{List.last Notes} getInChordB($)} = 1
   end
% /** %% Variant of ResolveNonharmonicNotesStepwise which accesses the predecessor and sucessor note from a given note explicitly. Non-chord tones are only permitted for MyNote if they are reached and left by a step. If no predecessor or successor is accessible for MyNote, then it must be a chord tone. 
% %%
% %% Args:
% %% 'maxInterval': an integer specifying the maximum step-size permitted. Default is the interval corresponding to a septimal second (8/7). 
% %% 'getPredecessor' and 'getSuccessor': unary function returning the predecessor/successor for the given note. Default are the methods getTemporalPredecessor/getTemporalSuccessor.
% %% NOTE: If motifs are wrapped in containers, then the first (last) motif note has no predecessor (successor) and consequently must be a chord tone. This default behaviour can be changed using different 'getPredecessor' and 'getSuccessor' settings.
% %% NOTE: the default 'getPredecessor' and 'getSuccessor' do allow for pauses between chord tones and non-harmonic tones. Classical music theory does this as well, but not completely unrestricted. Again, this can be changed by using different 'getPredecessor' and 'getSuccessor' settings.
% %% */
% proc {ResolveNonharmonicNotesStepwise2 MyNote Args}
%    Defaults = unit(getPredecessor: fun {$ N}
% 				      X = {N getTemporalPredecessor($)}
% 				   in 
% 				      %% replace X by comment if pauses should not occur between predecessor/successor and MyNote
% 				      X
% % 				      if X == nil orelse {X isPause($)} orelse ({N getOffsetTime} >: 0) == 1
% % 				      then nil
% % 				      else X
% % 				      end
% 				   end
% 		   getSuccessor: fun {$ N}
% 				    X = {N getTemporalSuccessor($)}
% 				 in
% 				    %% replace X by comment if pauses should not occur between predecessor/successor and MyNote
% 				    X
% % 				    if X == nil orelse {X isPause($)} orelse ({X getOffsetTime} >: 0) == 1
% % 				    then nil
% % 				    else X
% % 				    end
% 				 end
% 		   %%
% 		   maxInterval: SeptimalSecond
% 		  )
%    As = {Adjoin Defaults Args}
%    /** %% B=1 <-> MyNote is entered and left by a step.
%    %% */
%    proc {Aux MyNote B}
%       Pre = {As.getPredecessor MyNote}
%       Succ = {As.getSuccessor MyNote}
%    in
%       B = {FD.int 0#1}		% needed?
%       if Pre \= nil andthen Succ \= nil
%       then
% 	 B = {FD.conj {ConstrainMaxIntervalR Pre MyNote As.maxInterval}
% 	      {ConstrainMaxIntervalR MyNote Succ As.maxInterval}}
%       else B=0			% otherwise always a consonance
%       end
%    end
% in
%    thread			% accessors block
%       {MyNote nonChordPCConditions([Aux])}
%    end
% end


   
   
   /** %% [contrapuntual constraint] If in one voice there occurs a non-chord tone followed by a chord tone (a dissonance resolution), then no other voice should obscure this resolution by a non-chord tone starting together with the tone resolving the dissonance. However, simultaneous dissonances can start more early or later.
   %% */
   proc {ClearDissonanceResolution VoiceNotes}
      {Pattern.for2Neighbours VoiceNotes
       proc {$ N1 N2}
	  thread 			% accessing sim notes may block
	     SimNotes = {N2 getSimultaneousItems($ test:fun {$ X}
							   {X isNote($)} andthen
							   ({X getStartTime($)} =: {N2 getStartTime($)}) == 1
							end)}
	  in
	     {FD.impl {FD.conj
		       ({N1 getInChordB($)} =: 0)
		       ({N2 getInChordB($)} =: 1)}
	      {Pattern.conjAll
	       {Map SimNotes fun {$ N} {N getInChordB($)} end}}
	      1}
	  end
       end}
   end

   
   /** %% [contrapuntual constraint] Constraints that all pairs of simultaneous non-harmonic tones (i.e. the inChordB parameter = 0) form consonant intervals among each other. Notes is the list of all notes which potentially are non-harmonic tones (e.g., all notes in the score). ConsonantIntervals is a FD int domain specification (e.g., a list of integers) which specifies the allowed intervals.
   %% */
   proc {IntervalBetweenNonharmonicTonesIsConsonant Notes ConsonantIntervals}
      fun {IsNonharmonicNote N} {N getInChordB($)} == 0 end
      %% N1 and N2 form a consonant interval
      proc {ConsonantInterval N1 N2}
	 Interval = {FD.int ConsonantIntervals}
      in
	 {FD.distance {N1 getPitch($)} {N2 getPitch($)} '=:' Interval} 
      end
   in
      %% TODO: revise ForSimultaneousPairs interface
      {SMapping.forSimultaneousPairs {LUtils.cFilter Notes IsNonharmonicNote}
       ConsonantInterval
       unit(test:isNote
	    cTest:IsNonharmonicNote)}
   end


   
   /** %% Constraints that no pitch interval between consecutive Notes (list of note objects) exceeds MaxInterval (FD int).
   %% */
   proc {MaxInterval Notes MaxInterval}
      Intervals = {Pattern.map2Neighbours Notes GetInterval}
   in
      {ForAll Intervals proc {$ I} I =<: MaxInterval end}
   end
   
   /** %% Restrict the number of consecutive non-harmonic Notes (list of note objects) to N at maximum. Non-harmonic notes are notes for which the method getInChordB returns 0 (i.e. false).
   %% */
   %% BUG: ?? causes problems in 22 ET but not 31 ET?
   proc {MaxNonharmonicNoteSequence Notes N}
      {Pattern.forNeighbours Notes N+1
       proc {$ Ns}
	  {FD.sum {Map Ns fun {$ N} {N getInChordB($)} end} '=<:' N}
       end}
   end

   /** %% Restrict the maximum percentage of non-harmonic Notes (list of note objects) to MaxPercent.
   %% */
   proc {MaxNonharmonicNotePercent Notes MaxPercent}
      {Pattern.percentTrue_Range {Map Notes fun {$ N} {FD.nega {N getInChordB($)}} end}
       0 MaxPercent}
   end

   /** %% N specifies how many pitch repetitions occur at maximum between consecutive Notes (list of note objects), i.e. how many pitch intervals are 0. If N=0 then no repetitions are permitted.
   %% */
   proc {MaxRepetitions Notes N}
      Bs = {Pattern.map2Neighbours Notes
	    proc {$ N1 N2 B} B = ({GetInterval N1 N2} =: 0) end}
   in
      {Pattern.percentTrue_Range Bs 0 N}
   end

   /** %% Constrains the interval between Notes (list of note objects): there are at least MinPercent steps. The optional argument 'step' sets the step size as a frequency ratio (default 8#7).
   %% */
   proc {MinPercentSteps Notes MinPercent Args}
      Default = unit(step:8#7)
      As = {Adjoin Args Default}
      Bs = {Pattern.map2Neighbours Notes
	    proc {$ N1 N2 B} B = ({GetInterval N1 N2} =<: {HS_Score.ratioToInterval As.step}) end}
   in
      {Pattern.percentTrue_Range Bs MinPercent 100}
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Aux Constraints 
%%%

   /** %% Returns the absolute pitch interval (a FD int) between the note objects Note1 and Note2. Interval is implicitly declared a FD int.
   %% */
   %% NOTE: consider memoization, as this function is possibly called multiple times with same notes (e.g., multiple other constraints use it).
   proc {GetInterval Note1 Note2 ?Interval}
      Interval = {FD.decl}
      {FD.distance {Note1 getPitch($)} {Note2 getPitch($)} '=:' Interval}
   end
   
   
   /** %% B=1 <-> constraints the absolute pitch interval between Note1 and Note2 (note objects) to MaxInterval (an integer) at most.
   %% */
   proc {ConstrainMaxIntervalR Note1 Note2 MaxInterval B}
      B = {FD.int 0#1}
      {FD.reified.distance {Note1 getPitch($)} {Note2 getPitch($)} '=<:' MaxInterval
       B}
   end

   
   
   /*
   %% ?? combining multiple  non-harmonic pitch conditions (e.g. for ornamental resolution)
   %% 
   %% * ?? I may need additional 0/1 int for note: 1 in case note has chord pitch or fulfills some non-harmonic pitch condition and 0 otherwise. When these 0/1 ints are 1 for all notes, then all non-harmonic pitches are somehow properly introduced/resolved.
   %% -> Hm, implizit ist das mit der 'in case non-harmonic pitch then match one of the conditions' schon ausgedrueckt
   %%

   */

   
%    %% Constraining chord index and/or transposition pattern (or dissonance degree or whatever...) -- I put this here just to keep such ideas in mind ;-)
% %    fun {MkCycleChords As}
% %       Defaults = unit(indicesL:3
% % 		      transpositionsL:4
% % 		      distinctIndices:true
% % 		      distinctTranspositions:true)
% %       Args = {Adjoin Defaults As}
% %    in
% %       proc {$ ChordSeq}
% % 	 Chords = {ChordSeq getItems($)}
% % 	 Indices = {Map Chords {GUtils.toFun getIndex}}
% % 	 Transpositions = {Map Chords {GUtils.toFun getTransposition}}
% %       in
% % 	 {Pattern.cycle Indices Args.indicesL}
% % 	 {Pattern.cycle Transpositions Args.transpositionsL}
% % 	 if Args.distinctIndices
% % 	 then {FD.distinct {List.take Indices Args.indicesL}}
% % 	 end
% % 	 if Args.distinctTranspositions
% % 	 then {FD.distinct {List.take Transpositions Args.transpositionsL}}
% % 	 end
% %       end
% %    end



   %%
   %% TODO:  
   %%
   %% Strength of 'harmonic step' (Schoenberg's concept, Harmonielehre p. 134ff, p. 144 Zsfassung):
   %% - strong / ascending (root of predecessor is non-root pitchclass in successor). Schoenberg differs strong steps further: the less common pitch classes the stronger (V I is stronger than III I). 
   %% - weak / descending (non-root PC of predecessor is root of successor). Again, the more common pitch classes the weaker.
   %% - superstrong (ueberspringend) (no common pitchclasses between two neighbouring chords).  ueberspringend steps requires [besonderen Anlass]
   %% Omitted case: chord repetition or two different chords with same root -- it seems Schoenberg disallows this progression implicitly altogether. Still, in rare cases, this can be a strong progression.
   %%
   %% Schoenberg recommends preference for strong progressions (i.e. avoid weak if you don't know what you are doing), and also [Abwechslung] of the degree of strength (i.e. no mechanical repetition of specific step). Paraphrasing: On a higher level, repetition and [abwechslung] should create form.
   %% Should rating based on number of common chord tones abstract from total chord tone number (e.g. divide by chord tone number -- always multiply by, say, 100, to map float into int)?
   %%
   %% 
   %%
   %% Combine categories strong/weak/ueberspringend with rating how much common pitch classes. E.g., represent both by integer, multiply category by PitchClassesPerOctave and add both
   /*
   %% Expects two chord objects and FD int X expressing the 'strength' of the harmonic progression. 
   proc {ProgressionStrength Chord1 Chord2 X} end
   */


end

   
%% !! Format of this rule not consistent with other rules in this functor -- I better provide general rule templates (e.g. {WithPredecessor X Proc}) elsewhere..
%%
%    /** %% If X has a TemporalAspect predecessor then X has at least 1 common pitch class with this predecessor.
%    %% */
%    proc {CommonPCsWithPredecessor X}   
%       if {X hasTemporalPredecessor($)}
%       then Y = {X getTemporalPredecessor($)}
%       in
% 	 {CommonPCs X Y}
%       end
%    end


   
%% !! These two rules also need mainly a general rule template, e.g. {ForFirstAndLastItem Container Proc}
%%
%    /** %% Returns a unary rule for a chord: if MyChord is either the first or last element in its TemporalAspect then its Transposition is set to 0.
%    %% */
%    proc {StartAndEndSetTransposition0 MyChord}
%       if {ScoreAdd.isFirstOrLastInTemporalAspect MyChord}
%       then 
% 	 {MyChord getTransposition($)} = 0		
%       end
%    end
%    /** %% Returns a unary rule for a chord: if MyChord is either the first or last element in its TemporalAspect then its DissonanceDegree is MaxDissonanceDegree at maximum.
%    %% */
%    fun {MkStartAndEndLimitDissonanceDegree MaxDissonanceDegree}
%       proc {$ MyChord}
% 	 if {ScoreAdd.isFirstOrLastInTemporalAspect MyChord}
% 	 then 
% 	    DissonanceDegree = {ChordDB.selectDissonanceDegree {MyChord getIndex($)}}
% 	 in
% 	    DissonanceDegree =<: MaxDissonanceDegree		
% 	 end
%       end
%    end

   
   
%% !! Rules depend on interval DB (need predef. dissonance degree in interval DB) -- how can I generalise??
%%
%    /** %% Returns a unary rule on a list of chords: the dissonance degree of the transposition interval between two neighboring chords is constrained to DissonanceDegree (FD int domain). [Dissonance degrees for intervals are specified in IntervalDB.oz for the Partch scale.]
%    %% */
%    %% !!?? rule introduces FD ints which are possibly not determined ?
%    fun {MkSetChordTranspositionIntervalDissonanceDegree2 DissonanceDegreeDomain}
%       proc {$ Chords}
% 	 {Pattern.for2Neighbours Chords
% 	  proc {$ Chord1 Chord2}
% 	     {ChordTranspositionIntervalDissonanceDegree Chord1 Chord2
% 	      {FD.int DissonanceDegreeDomain}}
% 	  end}
%       end
%    end
%%
%% !! instead of transposition use chord/scale roots (see below, but use root parameter of course)
%%
%    /** %% Constraints the interval between the transpositions of Chord1 and Chord2 to DissonanceDegree (FD int) according to the dissonance degrees for intervals specified in IntervalDB.oz for the Partch scale.
%    %% */
%    proc {ChordTranspositionIntervalDissonanceDegree Chord1 Chord2 DissonanceDegree}
%       Transposition1 = {Chord1 getTransposition($)}
%       Transposition2 = {Chord2 getTransposition($)}
%       IntervalIndex Interval      
%    in
%       %% ?? shall I differ between upward and downward intervals
%       Interval = {IntervalDB.selectPitchClass IntervalIndex}
%       {FD.distance Transposition1 Transposition2 '=:' Interval}
%       DissonanceDegree = {IntervalDB.selectDissonanceDegree IntervalIndex}
%    end
%    /** %% Returns a unary rule on a list of chords: the dissonance degree of the fundamental interval between two neighboring chords is constrained to DissonanceDegree (FD int domain). [Dissonance degrees for intervals are specified in IntervalDB.oz for the Partch scale.]
%    %% */
%    %% !!?? rule introduces FD ints which are possibly not determined ?
%    fun {MkSetChordFundamentalIntervalDissonanceDegree2 DissonanceDegreeDomain}
%       proc {$ Chords}
% 	 %% !! this does not take into account transposition !
% 	 {Pattern.for2Neighbours Chords
% 	  proc {$ Chord1 Chord2}
% 	     {ChordFundamentalIntervalDissonanceDegree Chord1 Chord2
% 	      {FD.int DissonanceDegreeDomain}}
% 	  end}
%       end
%    end
%    /** %% Constraints the interval between the (transposed) fundamentals of Chord1 and Chord2 to DissonanceDegree (FD int) according to the dissonance degrees for intervals specified in IntervalDB.oz for the Partch scale.
%    %% */
%    proc {ChordFundamentalIntervalDissonanceDegree Chord1 Chord2 DissonanceDegree}
%       Fundamental1 = {FD.decl}
%       Fundamental2 = {FD.decl}
%       IntervalIndex = {FD.decl}
%       Interval = {FD.decl}
%    in
%       {{MkSetFundamentalPC Fundamental1} Chord1}
%       {{MkSetFundamentalPC Fundamental2} Chord2}
%       %% ?? shall I differ between upward and downward intervals
%       Interval = {IntervalDB.selectPitchClass IntervalIndex}
%       {FD.distance Fundamental1 Fundamental2 '=:' Interval}
%       DissonanceDegree = {IntervalDB.selectDissonanceDegree IntervalIndex}
%    end

