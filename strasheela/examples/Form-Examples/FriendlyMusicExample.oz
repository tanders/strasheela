%%
%% This file contains more complex examples which constrain the rhythmical, melodic, harmonic, and formal structure. 
%%
%% Usage: first feed buffer for aux defs, then feed example (solver calls at the end)
%%
%%

%%
%% TODO: fix example again: example seems broken (search takes much longer than before -- does it find solution at all?)
%%

declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}

%% Symbolic duration names (no tuplets for simplicity): Note durations
%% are then written as follows: R.d16 (16th note), R.d8 (eighth note)
%% and so forth, R.d8_ (dotted eighth note). See doc of
%% MUtils.makeNoteLengthsTable for more details.
Beat = 4
R = {MUtils.makeNoteLengthsRecord Beat nil}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Music representation
%%
%%


fun {MakeDefaultET31ChordArgs}
   ChordIndices = {Map ['major'
			'minor'
% 			'harmonic diminished'
% 			'augmented'
		       ]
		   HS.db.getChordIndex}
in
   chord(index:{FD.int ChordIndices}
	 duration:{FD.int 1#FD.sup}  % no non-existing chords
	 getScales: fun {$ Self}
		       {Self getSimultaneousItems($ test:HS.score.isScale)}
		    end
	 inScaleB:1 % only decatonic chord pitches
	 %% just to remove symmetri{HS.score.ratioToInterval 2#1}es (if inversion chord is used)
				      % sopranoChordDegree:1
	)
end

fun {MakeDefaultET31ScaleArgs}
   scale(index:{HS.db.getScaleIndex
		'major'
					     % 'standard pentachordal major'
	       }
	 transposition:{ET31.pc 'C'}
	)
end


Octave = {HS.score.ratioToInterval 2#1}
Fifth = {HS.score.ratioToInterval 3#2}
MajSecond = {HS.score.ratioToInterval 9#8}
SeptimalSecond = {HS.score.ratioToInterval 8#7}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Motif definitions
%%
%%

/** %% Returns default arguments for textual note objects. Defined as function, because some params are variables. 
%% */
fun {MakeDefaultNoteArgs}
   note(pitch:{FD.int {ET31.pitch 'C'#3}#{ET31.pitch 'C'#5}}
	duration:{FD.int [R.d16 R.d8 R.d4 R.d2 R.d2_]}
	inChordB:{FD.int 0#1}
	getChords: fun {$ Self}
		      [{Self findSimultaneousItem($ test:HS.score.isChord)}]
		   end
	inScaleB:1
	getScales: fun {$ Self}
		      [{Self findSimultaneousItem($ test:HS.score.isScale)}]
		   end
	amplitude:64
	amplitudeUnit:velo)
end


/** %% Returns a note with an added parameter for the motif index. 
%% */
fun {MakeMotifIndexNoteArgs}
   MyParam = {New Score.parameter
	      init(info:motifIndex
		   value:{FD.decl})}
in
   {Adjoin {MakeDefaultNoteArgs}
    note(addParameters:[MyParam])}
end
/** %% Expects a note object and returns its note index variable.
%% */
fun {GetMotifIndex N}
   {{LUtils.find {N getParameters($)}
     fun {$ X} {X hasThisInfo($ motifIndex)} end}
    getValue($)}
end

%% TODO: shall I save this proc in some utilities record for later use?
%%
/* %% This "motif definition" outputs a sequential container with Args.n notes. No extra constraints are applied, except for the implicit constraints of the music representation.
%%
%% Args:
%% n (integer): number of notes in the sequential container.
%% makeNote (nullary function): note constructor, can return textual score or (not fully initialised) note objects.
%% notesRule (unary procedure): constraint applied to the list of all notes. 
%% any other argument is handed over as an init argument for the sequential container. 
%% */
proc {NoteSeq Args ?MyScore}
   Defaults = unit(n:1		 % number of contained notes
		   %% note constructor, can output textual representation. If an object is returned, the default note class (HS.score.note) is overwritten
		   makeNote: MakeDefaultNoteArgs
		   constructors: add(note:HS.score.note)
		   notesRule: proc {$ Notes} skip end
		  )
   As = {Adjoin Defaults Args}
in
   MyScore = {Score.makeScore2 {Adjoin {Record.subtractList As [n makeNote notesRule constructors]}
				seq(items:{LUtils.collectN As.n As.makeNote})}
	      As.constructors}
   %% user-defined constraints 
   thread			% apply constraints only after score is initialised
      {As.notesRule {MyScore getItems($)}}
   end
end


/** %% "Wellformedness rule": all items contained in MyMotif have the same end time. 
%% */
proc {AllContainedItemsHaveSameEndTime MyMotif}
   {Pattern.for2Neighbours {MyMotif mapItems($ getEndTime)}
    proc {$ End1 End2} End1 = End2 end}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Constraint definitions
%%
%%

/* %% The harmonic rhythm expresses the metric structure: chords must only start at specific metric positions. Present def: all chords start with a new measure.
%% TODO: TMP: def for now: chord starts always with measure.
%% */
proc {HarmonicRhythm Chords}
   {ForAll Chords
    proc {$ C}
       thread 			% delay until sim measure is known
	  M = {C getSimultaneousItems($ test:Measure.isUniformMeasures)}.1
       in
	  %% chord starts on measure
	  {M onMeasureStartR($ {C getStartTime($)})} = 1
       end
    end}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Distribution strategy
%%
%%

fun {ParameterFilterTest X}
   %% Filter out container parameters, measure parameters, time points and note pitches. 
   {Not {{X getItem($)} isContainer($)}} orelse
   {Not {Measure.isUniformMeasures {X getItem($)}}} orelse 
   {HS.distro.isNoTimepointNorPitch X}
end


TypewiseWithPatternMotifs_LeftToRightTieBreaking_Distro
= unit(
     value:random 
     select: {SDistro.makeMarkNextParam
	      [fun {$ X}
		  {HS.score.isPitchClass X} andthen
		  {{X getItem($)} isNote($)}
	       end
	       # [getOctaveParameter]
	      ]}
     order: {SDistro.makeVisitMarkedParamsFirst
	     %% edited version of HS.distro.makeOrder_TimeScaleChordPitchclass
	     {SDistro.makeSetPreferredOrder
	      %% first visit motif index, then rhythmic structure etc
	      [fun {$ X} {X hasThisInfo($ motifIndex)} end 
	       fun {$ X} {X isTimeParameter($)} end
	       fun {$ X} {HS.score.isScale {X getItem($)}} end
	       fun {$ X} {HS.score.isChord {X getItem($)}} end
	       fun {$ X} {HS.score.isPitchClass X} end]
	      {SDistro.makeLeftToRight SDistro.dom}}}
     test: ParameterFilterTest)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Explorer output 
%%
%%

%% set longest unsplit note dur to dotted halve (full 3/4 bar)
{Init.setMaxLilyRhythm 3.0}
% {Init.setMaxLilyRhythm 16.0}

%% Explorer output 
proc {RenderLilypondAndCsound I X}
   if {Score.isScoreObject X}
   then 
      FileName = out#{GUtils.getCounterAndIncr}#'-'#I#'-'#{OS.rand}
   in
      {ET31.out.renderAndShowLilypond X
       unit(file: FileName
	    %% ignore measure objects
	    clauses:[Measure.isUniformMeasures#fun {$ _} nil end]
	    %% See http://lilypond.org/doc/v2.11/Documentation/user/lilypond/Automatic-note-splitting#Automatic-note-splitting
	    %% Note: automatic note splitting ignores explicit ties
	    wrapper:["\\layout { \\context {\\Voice \\remove \"Note_heads_engraver\" \\remove \"Forbid_line_break_engraver\" \\consists \"Completion_heads_engraver\" }} \n\n\\score{"
		     %% TODO: accidental-style does not work yet, see
		     %% http://lilypond.org/doc/v2.11/Documentation/user/lilypond/Automatic-accidentals#Automatic-accidentals
		     % NOTE: I possibly have to use \override instead of \set
%		     "\\layout { \\context {\\Voice \\remove \"Note_heads_engraver\" \\remove \"Forbid_line_break_engraver\" \\consists \"Completion_heads_engraver\" } {\\Staff \\set Staff.extraNatural = ##f #(set-accidental-style 'forget)}}"
		     "\n}"]
% 	    wrapper:["\\layout { \\context {\\Voice \\remove \"Forbid_line_break_engraver\"  } }"
% 		     "\n}"]
	   )}
      {Out.renderAndPlayCsound X
       unit(file: FileName)}
   end
end
{Explorer.object
 add(information RenderLilypondAndCsound
     label: 'to Lily + Csound: Friendly Music Example (31 ET)')}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Other output settings
%%
%%

{Init.setTempo 80.0}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Solver calls
%%
%%

/* 

declare
%% Script definition, using HS.score.harmoniseMotifs
%% wrapped script in explicit proc so I can use local variables like MyChords
proc {MyScript MyScore}
   %% NOTE: Changing ChordNo requires refactoring (e.g., some chord constraints applied to specific chord number, and number devided by 2 for bass note no of section)
   ChordNo = 8			
   MyChords
   /** %% Returns a noteSeq definition (expected by constructor NoteSeq) for four beats.
   %% Args is same as for NoteSeq. Arg 'notesRule' defines additional constraints than what is defined by MakeMelodySection. Args 'n' and 'makeNote' overwrite the defaul def of MakeMelodySection.
   %% */
   fun {MelodySection Args}
      Default = unit(motifNo:1	    % index used for accessing the right portion of sim chords
		     %% NOTE: hardwired -- changing chord number (number of bars) breaks this
		     n: 4+4+2+2 % ChordNo div 2 * 3
		     makeNote:fun {$}
				 {Adjoin {MakeMotifIndexNoteArgs}
				  note(pitch:{FD.int {ET31.pitch 'C'#4}#{ET31.pitch 'G'#5}})}
			      end
		     notesRule: proc {$ Ns} skip end)
      As = {Adjoin Default Args}
   in
      {Score.makeScore2
       noteSeq(
	  n: As.n
	  makeNote: As.makeNote
	  notesRule:proc {$ Notes}
		       %% I know that the chords for part a1 are 1-4, and for part a2 are 5-8.
		       SimChords = case As.motifNo of 1 then
				      {List.take MyChords 4}
				   [] 2 then
				      {List.drop MyChords 4}
				   end
		       %% rhythmic motifs
		       Motifs = [
% 				 [R.d4 R.d4 R.d8 R.d8]
% 				 [R.d4_ R.d8 R.d8 R.d8] % no solution for this, why?
				 [R.d4 R.d8 R.d8 R.d4]
				 [R.d4 R.d2]
				 [R.d2 R.d4]
% 				 [R.d2_]
% 				 ['_' % just in case: allow for anything
				]
		    in
		       {Pattern.useMotifs {Map Notes fun {$ N} {N getDuration($)} end}
			Motifs
			%% this index param is distributed..
			unit(indices:{Map Notes GetMotifIndex}
			     workOutEven:false)}
		       %% NOTE: Music ends in longer note
		       {{List.last Notes} getDuration($)} >=: R.d2
		       {HS.rules.maxInterval Notes Octave}
		       %% TMP comment (I change def of this constraint)
% 		       {HS.rules.maxNonharmonicNoteSequence Notes 3}
% 				    {HS.rules.maxNonharmonicNotePercent Notes 10}
		       {HS.rules.minPercentSteps Notes 50 unit}
		       {HS.rules.maxRepetitions Notes 0}
		       {HS.rules.resolveNonharmonicNotesStepwise Notes unit}
		       %% 
		       {As.notesRule Notes}
% 		       %% Generalised SimChords access in case I change things later. Does this block until all sim chords are known?
% 		       thread 
% 			  SimChords = {LUtils.removeDuplicates
% 				       {LUtils.mappend Notes
% 					fun {$ N} {N getSimultaneousItems($ test:HS.score.isChord)} end}}
% 		       end
		       %% restrict non-harmonic tones (suspension etc.)
		       {HS.rules.clearHarmonyAtChordBoundaries SimChords Notes}
		       {HS.rules.clearDissonanceResolution Notes}
		    end)
       add(noteSeq:NoteSeq)}
   end
   /** %% Same as MelodySection, but for bass
   %% */
   fun {BassSection Args}
      Default = unit(n:ChordNo div 2 
		     makeNote:fun {$}
				 {Adjoin {MakeDefaultNoteArgs}
				  note(pitch:{FD.int {ET31.pitch 'E'#2}#{ET31.pitch 'E'#4}})}
			      end
		     notesRule: proc {$ Ns} skip end)
      As = {Adjoin Default Args}
   in
      {Score.makeScore2
       noteSeq(
	  n: As.n
	  makeNote: As.makeNote
	  notesRule:proc {$ Notes}
		       %% Determine first octave
		       {Notes.1 getOctave($)} = 3
		       {ForAll Notes
			proc {$ N}
			   MyChord = {N getChords($)}.1
			in
			   %% play harmonic rhythm
			   {N getDuration($)} = {MyChord getDuration($)}
			   %% always play root
			   {MyChord getRoot($)} = {N getPitchClass($)}
			end}
		       {HS.rules.maxInterval Notes Octave}
		       %% 
		       {As.notesRule Notes}
		    end)
       add(noteSeq:NoteSeq)}
   end
   proc {ChordRule Chords}
      %% There is only a single scale, so I can access it from any chord
      MyScale = {Chords.1 getScales($)}.1
   in	     %%
      {HarmonicRhythm Chords}
      %% First and last chord are tonic (different chord types possible)
      {MyScale getRoot($)} = {Chords.1 getRoot($)} = {{List.last Chords}
						      getRoot($)}
      %% part a1 (first half) ends in dominant
      %% NOTE: hard coded chord number. Otherwise I may need to access chord which ends 4th bar..
      %% I don't necessarily know key, so I transpose scale root by fifth
      {{Nth Chords 4} getRoot($)} = {HS.score.transposePC {MyScale getRoot($)} {ET31.pc 'G'}}
      %% constraints on the root progression (not very strict for now...)
      {HS.rules.schoenberg.resolveDescendingProgressions Chords
       unit(allowInterchangeProgression:false
	    allowRepetition:false)}
      %% end in cadence of ascending chords
      {HS.rules.cadence MyScale {LUtils.lastN Chords 3}}
      %%
%       {ForAll Chords HS.rules.expressAllChordPCs}
      {ForAll Chords HS.rules.expressAllChordPCs_AtChordStart}
      %% 
      {Pattern.for2Neighbours {LUtils.lastN Chords 3}
       proc {$ C1 C2} {HS.rules.schoenberg.ascendingProgressionR C1 C2 1} end}
   end
in
   %% create and call script
   MyScore 
   = {{GUtils.extendedScriptToScript HS.score.harmoniseMotifs
       unit(motifs:
	       [%% section a1
		sim(items: [melodySection(motifNo:1)
			    melodySection(motifNo:1)
			    bassSection]
		    timeUnit:beats(Beat))
		%%% section a2
		sim(items: [melodySection(motifNo:2)
			    melodySection(motifNo:2)
			    bassSection])
	       ]
	    constructors:add(melodySection:MelodySection
			     bassSection:BassSection)
	    motifsRule:
	       proc {$ [SectionA1 SectionA2]}
		  %% TMP 
		  Notes = {Append {SectionA1 collect($ test:isNote)}
			   {SectionA2 collect($ test:isNote)}}
		  %% no prime, fifths, octaves to avoid parallels
		  ConsonantIntervalsForDiss = {LUtils.mappend {Map ['Eb' 'E' 'F' 'Ab' 'A']
							       ET31.pc}
					       fun {$ X} [X X+31 X+62] end}
	       in
		  %% wellformedness rule
		  {ForAll [SectionA1 SectionA2] AllContainedItemsHaveSameEndTime}
		  %% 
		  {HS.rules.intervalBetweenNonharmonicTonesIsConsonant Notes
		   ConsonantIntervalsForDiss}
		  %% also no soluion in a reasonable amount of time 
% 		  {ForAll [SectionA1 SectionA2] PCsOfSimNotesDiffer}
		  %% no solution found in a reasonable amount of time
% 		  {UnifyViewpoint SectionA1 SectionA2
% 		   [GetPitchContour]}
% 		  {UnifyViewpoint_Soft SectionA1 SectionA2
% 		   [GetPitchContour] 80 100}
	       end
	    chordNo: ChordNo
	    myChords:MyChords
	    makeChord: MakeDefaultET31ChordArgs
	    chordsRule:ChordRule
	    makeScale:MakeDefaultET31ScaleArgs
	    measure: measure(beatNumber:3 %% 3/4 beat
			     beatDuration:Beat)
	    %% Lilypond time signature code, should be set according to measure
	    lilyTimeSignature: "\\time  3/4"
	   )}}
end
%% Actual solver call
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript
 TypewiseWithPatternMotifs_LeftToRightTieBreaking_Distro}



%% test for seeing errors
{MyScript}



*/

