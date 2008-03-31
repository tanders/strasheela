
/** %% This functor defines some auxiliary functionality which is used by multiple examples and therefore this functionality is define here only once.
%% */

%%
%% NB: After editing this file, compile it with ozc, e.g., by using the Oz menu of the OPI (i.e. emacs).
%% The compiled functor was saved with the extension *.ozc.bin (instead of the usual *.ozf) such that it was not filtered out by subversion nor by the release creation script.
%%

functor
import
   FD FS
%   Browser(browse:Browse) % temp for debugging
%   GUtils at 'x-ozlib://anders/strasheela/GeneralUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   SDistro at 'x-ozlib://anders/strasheela/source/ScoreDistribution.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
export

   %% Output 
   ToMidi ToSheetMusic ToSheetMusic_ShowRatios ToSound
   
   %% Music representation 
   % MakeNote MakeDiatonicChord
   MyCreators

   %% Distribution strategy
   % PreferredOrder
   MyDistribution

   %% rules 
   IsPassingNoteR IsBetweenChordNotesR IsProperPassingNote
   ResolveStepwiseR IsAuxiliaryR IsBetweenStepsR
   
define


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   %%
   %% Output defs
   %%

   
   proc {ToMidi MyScore OutDir File}
      {Out.midi.outputMidiFile MyScore unit(file:File
					    midiDir:OutDir)}
   end

   proc {ToSheetMusic MyScore OutDir File}
      %% need lily out def supporting chords -- which is defined below
      {RenderLilypondHS MyScore unit(file:File
				     dir:OutDir
				     flags:["--preview"])}   
   end
   proc {ToSheetMusic_ShowRatios MyScore OutDir File}
      %% need lily out def supporting chords -- which is defined below
      {RenderLilypondHS_ShowRatios MyScore unit(file:File
						dir:OutDir
						flags:["--preview"])}   
   end
   
   proc {ToSound MyScore OutDir File}
      {Out.renderCsound MyScore unit(file:File
				     soundDir:OutDir
				     soundExtension: ".wav"
				     flags:['-W' '-g'])}
      {EncodeMP3 OutDir#File}
   end

   /** %% Expects soundfile with full path but without extension and renders mp3 file.
   %% */
   %% !! NB: this is a quick hack and not portable yet
   proc {EncodeMP3 SoundFile}
      %% linux with notlame 
      {Out.exec notlame ["-h" SoundFile#".wav" SoundFile#".mp3"]}
      %% MacOS installation uses lame
%      {Out.exec "/Applications/lame" ["-V2" SoundFile#".wav" SoundFile#".mp3"]}
   end


%%%%%%%%%%%

%    /** %% Returns unary function expecting chord. Lilyout: Outputs single root note and all added signs returned by MakeAddedSigns (unary fun expecting chord and returing articulations etc added to the root note)
%    %% */
%    fun {MakeChordToLily MakeAddedSigns}
%       fun {$ X}
% 	 Rhythms = {Out.lilyMakeRhythms {X getDurationParameter($)}}
%       in
% 	 if Rhythms == nil
% 	 then ' '
% 	 else 
% 	    RootPitch = {Out.lilyMakePitch {X getRootParameter($)}}
% 	    AddedSigns = {MakeAddedSigns X}
% 	    FirstChord = RootPitch#Rhythms.1#AddedSigns#' ' 
% 	 in
% 	    if {Length Rhythms} == 1
% 	    then FirstChord
% 	    else FirstChord#{Out.listToVS
% 			     {Map Rhythms.2
% 			      fun {$ Rhythm}
% 				 RootPitch#Rhythm#AddedSigns#' ' 
% 				 % RootPitch#Rhythm#RootMicroPitch 
% 			      end}
% 			     " "}
% 	    end
% 	 end
%       end
%    end
%    /** %% Expects a note and returns its MicroPitch and ChordMarker as VS.
%    %% */
%    fun {DefaultAddedSigns Note}
%       MicroPitch = {Out.lilyMakeMicroPitch
% 		    {Note getPitchParameter($)}}
%       ChordMarker = if {Note isInChord($)} == 1
% 		    then ''
% 		    else '^x'
% 		    end
%    in
%       MicroPitch#ChordMarker
%    end
%    %%
%    proc {RenderLilypondHS MyScore Args}
%       {Out.renderLilypond MyScore 
%        {Adjoin Args
% 	unit(clauses:[HS.score.isChord#{MakeChordToLily
% 					fun {$ MyChord}	    
% 					   RootMicroPitch = {Out.lilyMakeMicroPitch {MyChord getRootParameter($)}}
% 					   ChordComment = {HS.db.getInternalChordDB}.comment.{MyChord getIndex($)}
% 					   ChordDescr = if {IsRecord ChordComment} andthen {HasFeature ChordComment comment}
% 							then ChordComment.comment
% 							else ChordComment
% 							end
% 					in
% 					   if {Not {IsVirtualString ChordDescr}}
% 					   then raise noVS(chordDesc:ChordDescr) end
% 					   end
% 					   RootMicroPitch#'_\\markup{\\column < '#ChordDescr#' > }'
% 					end}
% 		      %% marking non-chord pitch notes
% 		      isNote#{Out.makeNoteToLily DefaultAddedSigns}
% 		     ])}}
%    end
   
   /** %% Transforms the pitch class PC into a ratio VS. Alternative ratio transformations are given (written like 1/2|1/3). If no transformation existists, 'n/a' is output.
   %% !! The partch DB does not contain all PC I need for et72 (I go beyond limit 11). Shall I create the necessary interval database automatically??
   %% */
   fun {PC2RatioVS PC}
      IntervalDB = {HS.dbs.partch.getIntervals {HS.db.getPitchesPerOctave}}
      fun {PrettyRatios Ratios}
	 %% alternative ratio transformations written as 1/2|1/3
	 {Out.listToVS
	  {Map Ratios fun {$ Nom#Den} Nom#'/'#Den end}
	  '|'}
      end
      Ratios = {HS.db.pc2Ratios PC IntervalDB}
   in
      if Ratios == nil
      then 'n/a'
      else {PrettyRatios Ratios}
      end
   end
   
   /** %% Returns unary function expecting chord. Lilyout: Outputs single root note and all added signs returned by MakeAddedSigns (unary fun expecting chord and returing articulations etc added to the root note)
   %% */
   fun {MakeChordToLily MakeAddedSigns}
      fun {$ X}
	 Rhythms = {Out.lilyMakeRhythms {X getDurationParameter($)}}
      in
	 if Rhythms == nil
	 then ' '
	 else 
	    RootPitch = {Out.lilyMakePitch {X getRootParameter($)}}
	    AddedSigns = {MakeAddedSigns X}
	    FirstChord = RootPitch#Rhythms.1#AddedSigns#' ' 
	 in
	    if {Length Rhythms} == 1
	    then FirstChord
	    else FirstChord#{Out.listToVS
			     {Map Rhythms.2
			      fun {$ Rhythm}
				 RootPitch#Rhythm#AddedSigns#' ' 
				 % RootPitch#Rhythm#RootMicroPitch 
			      end}
			     " "}
	    end
	 end
      end
   end

   /** %% Expects a note and returns its MicroPitch and ChordMarker as VS.
   %% */
   fun {DefaultAddedSigns Note}
      MicroPitch = {Out.lilyMakeMicroPitch
		    {Note getPitchParameter($)}}
      ChordMarker = if {Note isInChord($)} == 1
		    then ''
		    else '^x'
		    end
   in
      MicroPitch#ChordMarker
   end
   
   /** %% Expects a note and returns its MicroPitch, ChordMarker and ratio as VS.
   %% */
   fun {DefaultAddedSigns_ShowRatios Note}
      MicroPitch = {Out.lilyMakeMicroPitch
		    {Note getPitchParameter($)}}
      ChordMarker = if {Note isInChord($)} == 1
		    then ''
		    else '^x'
		    end
      Ratio = '\\markup{'#{PC2RatioVS {Note getPitchClass($)}}#'}'
   in
      MicroPitch#ChordMarker#'_'#Ratio 
   end
   
   proc {RenderLilypondHS MyScore Args}
      {Out.renderLilypond MyScore
       {Adjoin Args
	unit(clauses:[HS.score.isChord#{MakeChordToLily
					fun {$ MyChord}	    
					   RootMicroPitch = {Out.lilyMakeMicroPitch {MyChord getRootParameter($)}}
					   ChordComment = {HS.db.getInternalChordDB}.comment.{MyChord getIndex($)}
					   ChordDescr = if {IsRecord ChordComment} andthen {HasFeature ChordComment comment}
							then ChordComment.comment
							else ChordComment
							end
					in
					   if {Not {IsVirtualString ChordDescr}}
					   then raise noVS(chordDesc:ChordDescr) end
					   end
					   RootMicroPitch#'_\\markup{\\column < '#ChordDescr#' > }'
					end}
		      %% marking non-chord pitch notes
		      isNote#{Out.makeNoteToLily DefaultAddedSigns}
		     ])}}
   end
    

%   proc {RenderLilypondHS I X}
   proc {RenderLilypondHS_ShowRatios MyScore Args}
      fun {MakeChordDescr MyChord}
	 %% Transform chord PCs into ratios according to Partch
	 %% interval DB (Transposition x untransposed PC)
	 '\\column < '#	 
	 {PC2RatioVS {MyChord getTransposition($)}}#
	 ' x ('#
	 {Out.listToVS {Map {FS.reflect.lowerBoundList
			     {MyChord getUntransposedPitchClasses($)}}
			PC2RatioVS}
	  ' '}#
	 ') >' 
      end
   in
      {Out.renderLilypond MyScore
       {Adjoin Args
	unit(clauses:[HS.score.isChord#{MakeChordToLily
					fun {$ MyChord}	    
					   RootMicroPitch = {Out.lilyMakeMicroPitch {MyChord getRootParameter($)}}
					   ChordDescr = {MakeChordDescr MyChord}
					in
					   if {Not {IsVirtualString ChordDescr}}
					   then raise noVS(chordDesc:ChordDescr) end
					   end
					   RootMicroPitch#'_\\markup{'#ChordDescr#' }'
					end}
		      %% marking non-chord pitch notes
		      isNote#{Out.makeNoteToLily DefaultAddedSigns_ShowRatios}
		     ])}}
   end
    

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   %%
   %% Music representation
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
      %% label must be 'note' -- I could generalise this
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


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   %%
   %% Distribution strategy
   %%
   
   /** %% Suitable distribution strategy: first determine chords etc
   %% */
   PreferredOrder = {SDistro.makeSetPreferredOrder
		     %% Preference order of distribution strategy
		     [%% !!?? first always timing?
		      fun {$ X} {X isTimeParameter($)} end
		      %% first search for scales then for chords
		      fun {$ X} {HS.score.isScale {X getItem($)}} end
		      fun {$ X} {HS.score.isChord {X getItem($)}} end
% 		      fun {$ X}
% 			 {HS.score.isPitchClassCollection {X getItem($)}}
% 		      %{HS.score.isChord {X getItem($)}} orelse
% 		      %{HS.score.isScale {X getItem($)}}
% 		      end
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

   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   %%
   %% Rules
   %%   
   
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
