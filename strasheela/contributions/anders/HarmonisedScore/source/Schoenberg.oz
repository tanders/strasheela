
/** %% This functor defines constraints on chord progressions. These constraints are strongly inspired by Schoenberg's Theory of Harmony (Chapter "Einige Anweisungen zur Erzielung guenstiger Folgen", my Chapter title translation: "Some Directions on Writing Favourable Progressions"). In this chapter, he introduces the notion of ascending (strong), descending ('weak') and superstrong progressions. A summary of this notion can also be found at the beginning of his book "Structural Functions of Harmony".
%%
%% The present functor implements constraints for this notion. Nevertheless, my actual constraints differ from Schoenberg's rules. The proposed constraints are more general than Schoenberg's rules in the sense that these constraints are suitable even for chords with a large number of notes (as long as we know their root), and in particular also for microtonal music beyond 5-limit. 
%%
%% The main difference between Schoenberg's rules and the present constraints is that Schoenberg's rules are based on the (scale degree) intervals between chord roots, whereas my constraints exploit whether the root pitch class of some chord is contained in the pitch class set of another chord. For chord progressions of diatonic triads in major, my constraints and Schoenberg's rules are equivalent (e.g., the constraint AscendingProgressionR returns 1 for progressions which Schoenberg calls ascending). Still, the behaviour of the constraints and Schoenberg's rules differ for more complex cases. According to Schoenberg, a progression is superstrong if the root interval is a step up or down. For example, the progression V7 IV is superstrong according to Schoenberg. For the present constraints, however, this progression is descending (!), because the root of IV is contained in V7 (e.g. in G7 F, the F's root pitchclass f is already contained in G7). Indeed, this progression is rare in music. By contrast, the progression I IIIb (e.g., C Eb) is a descending progression in Schoenbergs original definition. For the present constraints, however, this is an ascending progression (the root of Es is not contained in C), and indeed for me the progression feels strong.
%%
%% I should perhaps mention that the ideas for my generalisation are mostly already contained in his Schoenberg's when he explains the directions he gives. One could say that I turned Schoenbergs explanation of his rules into generalised rules (and formalised them further). 
%% 
%% */

%% TODO:
%%
%% - ?? Define Schoenbergs orig def using root intervals only. 
%%
%% - ?? rename generalised constraints to, e.g., GeneralisedAscendingProgressionR or GenAscendingProgressionR 
%%

functor
import
   FD FS Combinator
%    LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   
export
   AscendingProgressionR AscendingProgression2R
   DescendingProgressionR
   SuperstrongProgressionR
   ConstantProgressionR
   ProgressionStrength

   ResolveDescendingProgressions
   ProgressionSelector

define
   
   /** %% B=1 <-> the progression from chord/scale X to chord/scale Y is ascending (or strong): X and Y have common pitch classes, but the root of Y does not occur in the set of X's pitchclasses.
   %% */
   proc {AscendingProgressionR X Y B}
%       B = {FD.int 0#1}
      B = {FD.conj
	   {FD.nega {FS.reified.include {Y getRoot($)} {X getPitchClasses($)}}}
	   {HS.rules.commonPCsR X Y}}
   end
   /** %% More strict variant of AscendingProgressionR: B=1 <-> the root of Y does not occur in the set of X's pitchclasses, but the root of X is also a pitch class in Y.
   %% */
   proc {AscendingProgression2R X Y B}
      B = {FD.conj
	   {FD.nega {FS.reified.include {Y getRoot($)} {X getPitchClasses($)}}}
	   {FS.reified.include {X getRoot($)} {Y getPitchClasses($)}}}
   end

   /** %% B=1 <-> the progression from chord/scale X to chord/scale Y is descending (or weak): a non-root pitchclass of X is root in Y.
   %% */
   proc {DescendingProgressionR X Y B}
      {FD.conj
       {FS.reified.include {Y getRoot($)} {X getPitchClasses($)}}
       ({X getRoot($)} \=: {Y getRoot($)})
       B}
   end


   /** %% B=1 <-> the progression from chord/scale X to chord/scale Y is superstrong in a Schoenbergian sense (cf. Harmonielehre): X and Y have no common pitch classes.
   %% */
   proc {SuperstrongProgressionR X Y B}
      {Combinator.'reify' 
       proc {$} {HS.rules.commonPCs_Card X Y 0} end
       B}
   end


   %% B=1 <-> the two scales X and Y have a common root but their pitchclasses differ. This case is ommited by Schoenberg discussing root progressions (he likely implicitly disallowed it).
   %% 
   proc {ConstantProgressionR X Y B}
      B = ({X getRoot($)} =: {Y getRoot($)})
   end


   /** %% Expects two chord/scale objects X and Y, and returns N (an FD int) expressing the 'strength' of the harmonic progression encoded by a single integer.
   %% More specifically, N can be used to distinguish between the following cases.
   %% N = 0: X and Y share the same root 
   %% 0 < N < PitchesPerOctave: descending progression.
   %% PitchesPerOctave < N < PitchesPerOct * 2: ascending progression.
   %% N = PitchesPerOct * 2: superstrong progression.
   %% Within the two categories descending and ascending progression, N is rated depending on the number of common pitch classes between X and Y, the number of pitch classes of Y, and the PitchesPerOctave. For example (PitchesPerOctave=12), if a descending progression X to Y shares a single pitch class, and Y is a triad, then N is 8. If X and Y share two pitch classes, then N is 4. If Y is a tetrad, and X and Y share a single pitch classes, then N is 9.  If Y is a tetrad, and X and Y share two pitch classes, then N is 6 etc.
   */
   proc {ProgressionStrength X Y N}
      PitchesPerOct = {HS.db.getPitchesPerOctave}
      %% used as rating within categories like ascending or decending
      CommonPCsStrength = {FD.decl}  
      DescB = {DescendingProgressionR X Y}
      AscB = {AscendingProgressionR X Y}
      SuperB = {SuperstrongProgressionR X Y}
      %% cardiality of Y's pitch class set
      Y_Card = {FD.decl}
   in
      N = {FD.decl}
      %% old rating
%      CommonPCsStrength =: PitchesPerOct - {HS.rules.commonPCs_Card X Y}
      %% new rating depends on Y_Card
      Y_Card = {FS.card {Y getPitchClasses($)}}
      CommonPCsStrength =: PitchesPerOct - {HS.rules.commonPCs_Card X Y} * PitchesPerOct div Y_Card
      N =: CommonPCsStrength * DescB
           + PitchesPerOct * AscB + CommonPCsStrength * AscB
           + PitchesPerOct * 2 * SuperB
   end

   /** %% Expects a list of chord/scale objects Xs and constrains them according to Schoenberg's recommendation. For any three successive chords/scales, if the first two chords form a descending progression, then the progression from the first to the third chord forms a strong progression (so the middle chord is quasi a 'passing chord'). Also, the last chord/scale pair forms always a strong progression.
   %% Optional Args: allowInterchangeProgression (default is false). If true, then mere interchange progressions (e.g., I V I), are permitted as well. In any case, no two descending progression must follow each other. allowRepetition: if true, two neighbouring chords can have the same root. Defaults to false.
   %% */ 
   proc {ResolveDescendingProgressions Xs Args}
      Default = unit(allowInterchangeProgression:false
		     allowRepetition:false)
      As = {Adjoin Default Args}
   in
      if As.allowInterchangeProgression
      then {Pattern.forNeighbours Xs 3
	    proc {$ [X Y Z]}
	       {FD.impl {DescendingProgressionR X Y}
		{FD.disj {AscendingProgressionR X Z}
		 {ConstantProgressionR X Z}}
% 		{FD.nega {DescendingProgressionR X Z}}
		1}
	    end}
      else {Pattern.forNeighbours Xs 3
	    proc {$ [X Y Z]}
	       {FD.impl {DescendingProgressionR X Y}
		{AscendingProgressionR X Z}
% 		{FD.disj {AscendingProgressionR X Z}
% 		 {SuperstrongProgressionR X Z}}
		1}
	    end}
      end
      if {Not As.allowRepetition}
      then {Pattern.for2Neighbours Xs
	    proc {$ X Y} {ConstantProgressionR X Y} = 0 end}
      end
      if {Not As.allowInterchangeProgression}
      then {Pattern.forNeighbours Xs 3
	    proc {$ [X _ Z]} {ConstantProgressionR X Z} = 0 end}
      end
      %% the last two chords must form an ascending progression.
%      {AscendingProgressionR {List.last Xs} {LUtils.butLast Xs}
%       1}
   end

   
   /** %% [Convenience constraint] Constraints the chord root progression for a list of chord objects Cs, where the actual rule is selected by an argument. Different argument values represent different variants of Schoenbergs rule set. Supported values are (in order of their strictness):
   %% - ascending: only ascending chord progressions are permitted
   %% - resolveDescendingProgressions(...): descending progressions are resolved (arguments to ResolveDescendingProgressions can be given as Selector features)
   %% - harmonicBand: consecutive chords must share common pitch classes
   %% - commonPCs: consecutive chords must share common pitch classes
   %% */
   proc {ProgressionSelector Cs Selector}
      case Selector
      of ascending then
	 {Pattern.for2Neighbours Cs 
	  proc {$ C1 C2} {AscendingProgressionR C1 C2 1} end}
      [] resolveDescendingProgressions(...) then
	 {ResolveDescendingProgressions Cs Selector}
      [] harmonicBand then
	 {Pattern.for2Neighbours Cs 
	  proc {$ C1 C2} {HS.rules.commonPCs C1 C2} end}
      [] commonPCs then		% same as previous clause, only different selector
	 {Pattern.for2Neighbours Cs 
	  proc {$ C1 C2} {HS.rules.commonPCs C1 C2} end}
      end
   end
   
end
