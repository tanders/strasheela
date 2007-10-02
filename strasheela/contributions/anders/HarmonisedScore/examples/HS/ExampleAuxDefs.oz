
functor
import
   FD
   Score at 'x-ozlib://anders/strasheela/ScoreCore.ozf'
   SDistro at 'x-ozlib://anders/strasheela/ScoreDistribution.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
export

   % MakeNote MakeDiatonicChord
   MyCreators
   % PreferredOrder
   MyDistribution

   IsPassingNoteR IsBetweenChordNotesR IsProperPassingNote
   ResolveStepwiseR IsAuxiliaryR IsBetweenStepsR
   
define
   
   %%
   %% Aux defs
   %%
   
/** %% Note constructor: score with predetermined rhythmic structure and note pitch is in a chord. There is no scale..
%% NoteRecord label must be note.
%% */
fun {MakeNote NoteRecord}
   Defaults = note(inChordB:1	
		   getChords:proc {$ Self Chords}
				Chords = {Self getSimultaneousItems($ test:HS.score.isChord)}
			     end
		   isRelatedChord:proc {$ Self Chord B} B=1 end
		   inScaleB:0
		   getScales:proc {$ Self Scales} 
				Scales = {Self getSimultaneousItems($ test:HS.score.isScale)}
				% Scales = nil
			     end
		   isRelatedScale:proc {$ Self Scale B} B=1 end
		   amplitude:64
		   amplitudeUnit:velo
		  )
in
   %% NoteRecord label must be 'note' -- I could generalise this
   {Score.makeScore2 {Adjoin Defaults NoteRecord}
    unit(note:HS.score.note)}	
end
/** %% Chord constructur.
%% ChordRecord label must be 'diatonicChord'.
%% */
fun {MakeDiatonicChord ChordRecord}
   Defaults = diatonicChord(inScaleB:1
			    getScales:proc {$ Self Scales} 
					 Scales = {Self getSimultaneousItems($ test:HS.score.isScale)}
				      end
			    isRelatedScale:proc {$ Self Scale B} B=1 end)
in
   %% label must be 'diatonicChord' -- I could generalise this
   {Score.makeScore2 {Adjoin Defaults ChordRecord}
    unit(diatonicChord:HS.score.diatonicChord)}
end
/** %% Constructors for note etc.
%% */
MyCreators = unit(note:MakeNote
		  chord:HS.score.chord
		  diatonicChord:MakeDiatonicChord
		  scale:HS.score.scale
		  sim:Score.simultaneous
		  seq:Score.sequential)


/** %% Suitable distribution strategy: first determine chords etc
%% */
PreferredOrder = {SDistro.makeSetPreferredOrder
		  %% Preference order of distribution strategy
		  [%% !!?? first always timing?
		   fun {$ X} {X isTimeParameter($)} end
		   fun {$ X}
		      {HS.score.isPitchClassCollection {X getItem($)}}
		      %{HS.score.isChord {X getItem($)}} orelse
		      %{HS.score.isScale {X getItem($)}}
		   end
		   %% prefer pitch class over octave (after a pitch class, always the octave is determined, see below)
		   %% !!?? does this always make sense? Anyway, usually the pitch class is the more sensitive param. Besides, allowing a free order between pitch class and octave makes def to determine the respective pitch class / octave next much more difficult
		   fun {$ X}
		      %% only for note pitch classes: pitch classes in chord or scale are already more preferred by checking that item is isPitchClassCollection
		      {HS.score.isPitchClass X}
		      % {X hasThisInfo($ pitchClass)}
		   end
		  ]
		  %% in case of params with same 'preference index'
		  %% prefer var with smallest domain size
		  fun {$ X Y}
		     fun {GetDomSize X}
			{FD.reflect.size {X getValue($)}}
		     end
		  in
		     {GetDomSize X} < {GetDomSize Y}
		  end}
%%
%% after determining a pitch class of a note, the next distribution
%% step has to determine the octave of that note! Such distribution
%% strategy results in clear performance increasing -- worth
%% discussion in thesis. Increases performance by factor 10 at least !!
%%
%% Bug: (i) octave is already marked, although pitch class is still undetermined, (ii) octave does not get distributed next anyway.
MyDistribution = unit(value:random % mid % min % 
		      select: fun {$ X}
				 %% !! needs abstraction
				 %%
				 %% mark param to determine next
				 if {HS.score.isPitchClass X} andthen
				    {{X getItem($)} isNote($)}
				 then {{{X getItem($)} getOctaveParameter($)}
				       addInfo(distributeNext)}
				 end
				 %% the ususal parameter value select
				 {X getValue($)}
			      end
		      order:fun {$ X Y}
			       %% !! needs abstraction
			       %%
			       %% always checking both vars: rather inefficient.. 
			       if {X hasThisInfo($ distributeNext)}
			       then true
			       elseif {Y hasThisInfo($ distributeNext)}
			       then false
				  %% else do the usual distribution
			       else {PreferredOrder X Y}
			       end
			    end
		      test:fun {$ X}
			      %% {Not {{X getItem($)} isContainer($)}} orelse
			      {Not {X isTimePoint($)}} orelse
			      {Not {X isPitch($)} andthen
			       ({X hasThisInfo($ root)} orelse
				{X hasThisInfo($ untransposedRoot)} orelse
				{X hasThisInfo($ notePitch)})}
			   end)
%%
% MyDistribution = unit(value:mid % random 
% 		      order:{SDistro.makeSetPreferredOrder
% 			     %% Preference order of distribution strategy
% 			     [fun {$ X} {X isTimeParameter($)} end
% 			      fun {$ X}
% 				 {HS.score.isChord {X getItem($)}} orelse
% 				 {HS.score.isScale {X getItem($)}}
% 			      end
% 			      %% note pitches are already filtered out, so this has no effect..
% 			      fun {$ X}
% 				 {X isNote($)} andthen
% 				 {X hasThisInfo($ pitchClass)}
% 			      end]
% 			     %% in case of params with same 'preference index'
% 			     fun {$ X Y}
% 				fun {GetDomSize X}
% 				   {FD.reflect.size {X getValue($)}}
% 				end
% 			     in
% 				{GetDomSize X} < {GetDomSize Y}
% 			     end}
% 		      test:fun {$ X}
% 			      %% {Not {{X getItem($)} isContainer($)}} orelse
% 			      {Not {X isTimePoint($)}} orelse
% 			      {Not {X isPitch($)} andthen
% 			       ({X hasThisInfo($ root)} orelse
% 				{X hasThisInfo($ untransposedRoot)} orelse
% 				{X hasThisInfo($ notePitch)})}
% 			   end)
/* %% postpone
%% avoiding the non-determinism introduced above with approach proposed by Raphael Collet (email Wed, 02 Feb 2005 to users@mozart-oz.org)
{SDistro.exploreOne
 proc {$ MyScore}
    RandGen = {MakeRandomGenerator}
 in
    MyScore = {Score.makeScore
	       note(duration:4
		    amplitude:1
		    pitch:{FD.int 60#72}
		    startTime:0
		    timeUnit:beats(4))
	       unit}
 end
 MyDistribution
 value:{SDistro.makeRandomDistributionValue RandGen}
}
*/
%%
%% This is replaced by more general SMapping.patternMatchingApply and friends 
%% !!?? where to put this? Into ScoreCore? 
%%
% proc {ApplyToNoteAndSuccessorR Note1 Rule B}
%    if {Not {Note1 hasTemporalSuccessor($)}}
%    then B = 0
%    else Note2 = {Note1 getTemporalSuccessor($)}
%    in
%       {Rule [Note1 Note2] B}
%    end
% end
% proc {ApplyToNoteAndPredecessorR Note2 Rule B}
%    if {Not {Note2 hasTemporalPredecessor($)}}
%    then B = 0
%    else Note1 = {Note2 getTemporalPredecessor($)}
%    in
%       {Rule [Note1 Note2] B}
%    end
% end
% proc {ApplyToNoteAndPreAndSuccessorR Note2 Rule B}
%    %% !! variant accessing precessing/successing in different container
%    if {Not {Note2 hasTemporalPredecessor($)}} orelse
%       {Not {Note2 hasTemporalSuccessor($)}}
%    then B=0
%    else
%       Note1 = {Note2 getTemporalPredecessor($)}
%       Note3 = {Note2 getTemporalSuccessor($)}
%    in
%       {Rule [Note1 Note2 Note3] B}
%    end
% end
%%
%
% proc {IsPassingNoteR Note B}
%    MaxStep = 2
% in
%    B = {ApplyToNoteAndPreAndSuccessorR Note
% 	proc {$ [Note1 Note2 Note2] B}
% 	   B = {HS.rules.passingNotesR
% 		[{Note1 getPitch($)} {Note2 getPitch($)} {Note3 getPitch($)}]
% 		MaxStep} 
% 	end}
% end
% /** %% For the predecessor and successor of Note2, inChord is 1
% %% */
% proc {IsBetweenChordNotesR Note B}
%    B = {ApplyToNoteAndPreAndSuccessorR Note
% 	proc {$ [Note1 Note2 Note2] B}
% 	   B = {FD.conj
% 		{Note1 isInChord($)}
% 		{Note3 isInChord($)}}
% 	end}
% end
proc {IsPassingNoteR Note B}
   {HS.rules.isPassingNoteR Note unit B}
end
proc {IsBetweenChordNotesR Note B}
   {HS.rules.isBetweenChordNotesR Note unit B}
end
proc {IsProperPassingNote Note B}
   {FD.conj
    {IsPassingNoteR Note}
    {IsBetweenChordNotesR Note}
    B}
end
proc {ResolveStepwiseR Note B}
   {HS.rules.resolveStepwiseR Note unit B}
end
proc {IsAuxiliaryR Note B}
   {HS.rules.isAuxiliaryR Note unit B}
end
proc {IsBetweenStepsR Note B}
   {HS.rules.isBetweenStepsR Note unit B}
end

end
