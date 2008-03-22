
/** %% This functor defines constraints on chord progressions. These constraints are strongly inspired by Schoenberg's Theory of Harmony (Chapter "Einige Anweisungen zur Erzielung guenstiger Folgen", my Chapter title translation: "Some Directions on Writing Favourable Progressions"). In this chapter, he introduces the notion of ascending (strong), descending ('weak') and superstrong progressions. A summary of this notion can also be found at the beginning of his book "Structural Functions of Harmony".
%%
%% The present functor implements constraints for this notion. Nevertheless, my actual constraints differ from Schoenbergs rules. The proposed constraints are more general than Schoenbergs rules in the sense that these constraints are suitable even for chords with a large number of notes (as long as we know their root), and in particular also for microtonal music beyond 5-limit. 
%%
%% The main difference between Schoenberg's rules and the present constraints is that Schoenberg's rules are based on the (scale degree) intervals between chord roots, whereas my constraints exploint whether the root pitch class of some chord is contained in the pitch class set of another chord. For chord progressions of diatonic triads in major, my constraints and Schoenberg's rules are equivalent (e.g., the constraint AscendingProgressionR returns 1 for progressions which Schoenberg calls ascending). Still, the behaviour of the constraints and Schoenberg's rules differ for more complex cases. According to Schoenberg, a progression is superstrong if the root interval is a step up or down. For example, the progression V7 IV is superstrong according to Schoenberg. For the present constraints, however, this progression is descending (!), because the root of IV is contained in V7 (e.g. in G7 F, the F's root pitchclass f is already contained in G7). Indeed, this progression is rare in music. Also, the progression I IIIb (e.g., C Eb) is a descending progression in Schoenbergs original definition. For the present constraints, however, this is an ascending progression (the root of Es is not contained in C), and indeed for me the progression feels strong.
%%
%% I should perhaps mention that the ideas for my generalisation are mostly already contained in his Schoenberg's when he explains the directions he gives. One could say that I turned Schoenbergs explanation of his rules into generalised rules. 
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
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   
export
   AscendingProgressionR
   DescendingProgressionR
   SuperstrongProgressionR
   ProgressionStrength

   ResolveDescendingProgressions

define
   
   /** %% B=1 <-> the progression from chord/scale X to chord/scale Y is ascending (or strong): X and Y have common pitch classes, but the root of Y does not occur in the set of X's pitchclasses.
   %% */
   proc {AscendingProgressionR X Y B}
      B = {FD.int 0#1}
      B = {FD.conj
	   {FD.nega {FS.reified.include {Y getRoot($)} {X getPitchClasses($)}}}
	   {HS.rules.commonPCsR X Y}}
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


   /*
   %% B=1 <-> the two scales X and Y have a common root but their pitchclasses differ. This case is ommited by Schoenberg discussing root progressions (he likely implicitly disallowed it).
   %% 
   proc {ConstantProgressionR X Y B}
      B = ({X getRoot($)} =: {Y getRoot($)})
   end
   */


   /** %% Expects two chord/scale objects X and Y, and returns N (an FD int) expressing the 'strength' of the harmonic progression encoded by a single integer.
   %% More specifically, N can be used to distinguish between the following cases.
   %% N = 0: X and Y share the same root 
   %% 0 < N < PitchesPerOctave: descending progression, N = PitchesPerOctave-1 for 1 common pitch class between X and Y, N = PitchesPerOctave-2 for 2 common pitch classes etc.
   %% PitchesPerOctave < N < PitchesPerOct * 2: ascending progression, N = PitchesPerOctave*2-1 for 1 common pitch class between X and Y, N = PitchesPerOctave*2-2 for 2 common pitch classes etc.
   %% N = PitchesPerOct * 2: superstrong progression.
   %%
   */
   proc {ProgressionStrength X Y N}
      PitchesPerOct = {HS.db.getPitchesPerOctave}
      CommonPCsStrength = {FD.decl}  
      DescB = {DescendingProgressionR X Y}
      AscB = {AscendingProgressionR X Y}
      SuperB = {SuperstrongProgressionR X Y}
   in
      N = {FD.decl}
      CommonPCsStrength =: PitchesPerOct - {HS.rules.commonPCs_Card X Y}
      N =: CommonPCsStrength * DescB
           + PitchesPerOct * AscB + CommonPCsStrength * AscB
           + PitchesPerOct * 2 * SuperB
   end

   /** %% [TODO: doc and test]
   %% */ 
   %% in case of a descending progression, the next chord forms a strong/superstrong progression from the first chord.
   %%
   %% TODO: allow for mere interchange progressions too (e.g., I V I), with additional arg
   proc {ResolveDescendingProgressions Xs}
      {Pattern.forNeighbours Xs 3
       proc {$ [X Y Z]}
	  {FD.impl {DescendingProgressionR X Y}
	   {FD.disj {AscendingProgressionR Y Z}
	    {SuperstrongProgressionR Y Z}}
	   1}
       end}
   end

end
