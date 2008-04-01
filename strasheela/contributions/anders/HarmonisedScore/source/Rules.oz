
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
   Browser(browse:Browse) % temp for debugging
   Select at 'x-ozlib://duchier/cp/Select.ozf'
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
%   LUtils at 'x-ozlib://anders/strasheela/ListUtils.ozf'
   SMapping at 'x-ozlib://anders/strasheela/source/ScoreMapping.ozf'
%    Score at 'x-ozlib://anders/strasheela/ScoreCore.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   Schoenberg at 'Schoenberg.ozf'
   
export

   %% chord / scale rules
   GetFeature
   UnequalParameter UnequalParameterR NeighboursWithUnequalParameter
   Distinct DistinctR DistinctNeighbours
   PairwiseDistinct ButNDistinct DistinctForN
   CommonPCs CommonPCs_Card CommonPCsR NeighboursWithCommonPCs 
   ParameterDistance ParameterDistanceR LimitParameterDistanceOfNeighbours

   Cadence
   DiatonicChord NoteInPCCollection

   %% melodic rules
   IsStep IsStepR
   ResolveStepwiseR
   PassingNotePitches PassingNotePitchesR
   IsPassingNoteR
   IsBetweenChordNotesR
   IsAuxiliaryR
   IsBetweenStepsR

   %% subfunctors
   Schoenberg
   
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

