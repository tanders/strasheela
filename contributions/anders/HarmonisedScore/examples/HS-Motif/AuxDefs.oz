
%%
%% TODO
%%
%% * 
%%

functor
import
   FD Combinator
   Score at 'x-ozlib://anders/strasheela/ScoreCore.ozf'
   SDistro at 'x-ozlib://anders/strasheela/ScoreDistribution.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   Motif at 'x-ozlib://anders/strasheela/Motif/Motif.ozf'
export

   DurationsAndContourMotifConstraint DurationsAndContourMotifConstraint2
   
   MyCreators
   MyDistribution
define


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Motif constraints
%%

local
   %% DB is a tuple of records. CollectFeats returns the values of all records in DB at feature Feat in a list.
   fun {CollectFeats DB Feat}
      {Map DB fun {$ X} X.Feat end}
   end
in
   /** %% Motif constraint: MyMotif is a Motif.sequence with notes and B an 0/1-int. Entries in the motif database of MyMotif (a list of records) specifies two features: pitchContour and durations. DurationsAndContourMotifConstraint constraints the durations of the notes in MyMotif to follow the durations of the respective motif database entry (according to the parameter motifIndex of MyMotif) and the contour of pitches to follow the pitch contour of the respective motif database entry.
   %% */
   %% !! TODO: keep this def in some more reusable functor (in Motif contribution, e.g. Motif.motifs)
   proc {DurationsAndContourMotifConstraint MyMotif B}
      {Combinator.'reify'
       proc {$}
	  MotifDB = {MyMotif getMotifDB($)}
	  ContourDB = {CollectFeats MotifDB pitchContour}
	  DurDB = {CollectFeats MotifDB durations}
	  MyDurs = {MyMotif mapItems($ getDuration)} 
	  MyPitches = {MyMotif mapItems($ getPitch)}
	  MyContour = {FD.list {Length MyPitches}-1 0#2}
	  MotifIndex = {MyMotif getMotifIndex($)}
       in
	  MyDurs = {Pattern.selectList DurDB MotifIndex}
	  MyContour = {Pattern.selectList ContourDB MotifIndex}
	  {Pattern.contour MyPitches MyContour}
       end
       B}
   end
   /** %% Variant of DurationsAndContourMotifConstraint which also binds offset times according motif database.
   %% */
   proc {DurationsAndContourMotifConstraint2 MyMotif B}
      {Combinator.'reify'
       proc {$}
	  MotifDB = {MyMotif getMotifDB($)}
	  ContourDB = {CollectFeats MotifDB pitchContour}
	  DurDB = {CollectFeats MotifDB durations}
	  OffsetDB = {CollectFeats MotifDB offsets}
	  MyDurs = {MyMotif mapItems($ getDuration)} 
	  MyOffsets = {MyMotif mapItems($ getOffsetTime)} 
	  MyPitches = {MyMotif mapItems($ getPitch)}
	  MyContour = {FD.list {Length MyPitches}-1 0#2}
	  MotifIndex = {MyMotif getMotifIndex($)}
       in
	  MyDurs = {Pattern.selectList DurDB MotifIndex}
	  MyOffsets = {Pattern.selectList OffsetDB MotifIndex}
	  MyContour = {Pattern.selectList ContourDB MotifIndex}
	  {Pattern.contour MyPitches MyContour}
       end
       B}
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Constructors
%%
   
   /** %% Note constructor: score with predetermined rhythmic structure and note pitch is in a chord. There is no scale..
   %% NoteRecord label must be note.
   %% */
   %% Copy from ../*AuxDefs.oz
   fun {MakeNote NoteRecord}
      Defaults = note(inChordB:1
		      %% !! in a CSP in which the rhythmic structure of the chord progression remains undetermined, this did NOT block
		      getChords:proc {$ Self Chords}
				   Chords = {Self getSimultaneousItems($ test:HS.score.isChord)}
				end
		      isRelatedChord:proc {$ Self Chord B} B=1 end
		      inScaleB:0
% 		      getScales:proc {$ Self Scales} 
% 				   Scales = {Self getSimultaneousItems($ test:HS.score.isScale)}
% 				% Scales = nil
% 				end
% 		      isRelatedScale:proc {$ Self Scale B} B=1 end
		      amplitude:64
		      amplitudeUnit:velo
		     )
      L = {Label NoteRecord}
   in
      {Score.makeScore2 {Adjoin Defaults NoteRecord}
       unit(L:HS.score.note)}	
   end
   %% !! slightly edited copy from MakeNote
   fun {MakeDiatonicNote NoteRecord}
      Defaults = diatonicNote(inChordB:1
		      %% !! in a CSP in which the rhythmic structure of the chord progression remains undetermined, this did NOT block
		      getChords:proc {$ Self Chords}
				   Chords = {Self getSimultaneousItems($ test:HS.score.isChord)}
				end
		      isRelatedChord:proc {$ Self Chord B} B=1 end
		      inScaleB:1
		      getScales:proc {$ Self Scales} 
				   Scales = {Self getSimultaneousItems($ test:HS.score.isScale)}
				% Scales = nil
				end
		      isRelatedScale:proc {$ Self Scale B} B=1 end
		      amplitude:64
		      amplitudeUnit:velo)
      L = {Label NoteRecord}
   in
      {Score.makeScore2 {Adjoin Defaults NoteRecord}
       unit(L:HS.score.note)}
   end
   /** %% Chord constructur.
   %% ChordRecord label must be 'diatonicChord'.
   %% */
   %% Copy from ../*AuxDefs.oz
   fun {MakeDiatonicChord ChordRecord}
      Defaults = diatonicChord(inScaleB:1
			       getScales:proc {$ Self Scales} 
					    Scales = {Self getSimultaneousItems($ test:HS.score.isScale)}
					 end
			       isRelatedScale:proc {$ Self Scale B} B=1 end)
      L = {Label ChordRecord}
   in
      {Score.makeScore2 {Adjoin Defaults ChordRecord}
       unit(L:HS.score.diatonicChord)}
   end
   /** %% Constructors for note etc.
   %% */
   MyCreators = unit(note:MakeNote
		     diatonicNote:MakeDiatonicNote
		     chord:HS.score.chord
		     diatonicChord:MakeDiatonicChord
		     scale:HS.score.scale
		     seq:Score.sequential
		     sim:Score.simultaneous
		     motif:Motif.sequential)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Distribution strategy
%%
   

   /** %% Suitable distribution strategy: determined motif params first, then determine chord/scale params etc and pitch classes + octave. However, don't distribute timing params at all.
   %% */
   PreferredOrder = {SDistro.makeSetPreferredOrder
		     %% Preference order of distribution strategy
		     [fun {$ X}
			 {X hasThisInfo($ motifIndex)} orelse
			 {X hasThisInfo($ motifConstraint)}
		      end
		      %% in case timing structure is not fully determined. Nevertheless, do it after determining the motif as the motif mostly determines the timing structure.
		      fun {$ X} {X isTimeInterval($)} end 
		      fun {$ X}
			 {HS.score.isPitchClassCollection {X getItem($)}} andthen
			 ({X hasThisInfo($ index)} orelse
			  {X hasThisInfo($ transposition)})
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
   %% !!?? Bug (perhaps only due impossible analysis of random distro): (i) octave is already marked, although pitch class is still undetermined, (ii) octave does not get distributed next anyway.
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
				 %% only distribute these params: time interval (if determined it is filtered out, otherwise it is essential), motif index, motif constraint, chord/scale params, and pitch classes + octaves.
				 {X isTimeInterval($)} orelse
				 {X hasThisInfo($ motifIndex)} orelse
				 {X hasThisInfo($ motifConstraint)} orelse 
				 {HS.score.isPitchClassCollection {X getItem($)}} andthen
				 ({X hasThisInfo($ index)} orelse
				  {X hasThisInfo($ transposition)}) orelse
				 {HS.score.isPitchClass X} orelse
				 {X hasThisInfo($ octave)}
% 			      %% {Not {{X getItem($)} isContainer($)}} orelse
% 			      {Not {X isTimePoint($)}} orelse
% 			      {Not {X isPitch($)} andthen
% 			       ({X hasThisInfo($ root)} orelse
% 				{X hasThisInfo($ untransposedRoot)} orelse
% 				{X hasThisInfo($ notePitch)})}
			      end)

end

   
