
%%
%% This file defines melody and contrapuntual examples in 22 ET.
%%
%%
%% Usage: first feed buffer, to feed definitions shared by all
%% examples (these definitions are collected at the end of this
%% file). Then feed the respective example in a /* comment block */.
%%

%%
%% TODO:
%%
%% - remove all unused defs 
%%


declare
[Segs ET22 Fenv] = {ModuleLink ['x-ozlib://anders/strasheela/Segments/Segments.ozf'
				'x-ozlib://anders/strasheela/ET22/ET22.ozf'
				'x-ozlib://anders/strasheela/Fenv/Fenv.ozf']}
{HS.db.setDB ET22.db.fullDB}


{Init.setTempo 80.0}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Actual examples start here
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% A single decatonic line over a C harm 7 chord, with passing tones etc.
%%
%%

/*

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    End
    MyVoice = {Segs.makeCounterpoint_Seq
	       unit(iargs: unit(n:10
				duration: D.d4
				inScaleB: 1 % only scale tones
			       )
		    rargs: unit(maxPitch: 'A'#4 % pitch unit and notation is et22
				minPitch: 'A'#3
				maxInterval: 2#1
				maxNonharmonicNoteSequence: 1
				minPercentSteps: 60
			       )
		    endTime: End)}
 in
    MyScore
    = {Score.make
       sim([MyVoice
	    %% notes are implicitly related to simultaneous chord and scale
	    seq([chord(index:{HS.db.getChordIndex 'harmonic 7th'}
		       transposition:0
		       endTime:End)])
	    seq([scale(index:{HS.db.getScaleIndex 'standard pentachordal major'}
		       transposition:0
		       endTime:End)])]
	   startTime:0
	   timeUnit:beats(Beat))
       add(chord:HS.score.chord
	   scale:HS.score.scale)}
    %%
    {Pattern.noRepetition {MyVoice mapItems($ getPitch)}}
 end
 unit(value:random)}

*/



%%
%% Same as above, but pitch contour controlled by a Fenv and rhythm composed manually.
%%

/*

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    End
    MyVoice = {Segs.makeCounterpoint_Seq
	       unit(iargs: unit(n:10
				%% manually composed rhythm, length must fit n
				duration: each # {Map [d4 d4 d4_ d4 d4 d4 d4_ d4 d4 d1] 
						  SymbolicDurToInt}
				inScaleB: 1 % only scale tones
			       )
		    rargs: unit(maxPitch: 'A'#4 % pitch unit and notation is et22
				minPitch: 'A'#3
				maxInterval: 2#1
				maxNonharmonicNoteSequence: 1
				minPercentSteps: 60
			       )
		    endTime: End)}
    Pitches
 in
    MyScore
    = {Score.make
       sim([MyVoice
	    %% notes are implicitly related to simultaneous chord and scale
	    seq([chord(index:{HS.db.getChordIndex 'harmonic 7th'}
		       transposition:0
		       endTime:End)])
	    seq([scale(index:{HS.db.getScaleIndex 'standard pentachordal major'}
		       transposition:0
		       endTime:End)])]
	   startTime:0
	   timeUnit:beats(Beat))
       add(chord:HS.score.chord
	   scale:HS.score.scale)}
    Pitches = {MyVoice mapItems($ getPitch)}
    %% Note: constrain only restricts interval directions between consecutive pitches. So, first pitch can be highest pitch. (otherwise Pattern.matrixContour would be required.)
    {Pattern.fenvContour Pitches
     {Fenv.linearFenv [[0.0 0.0]
		       [0.2 ~1.0]
		       [0.7 1.0]
		       [1.0 0.0]]}}
    %% Last pitch does not occur before
    local LastPitch = {List.last Pitches} in
       {ForAll {LUtils.butLast Pitches}
	proc {$ P} P \=: LastPitch end}
    end
 end
 unit(value:random)}

*/




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% A decatonic melody over a chord progression
%%
%%

% % % % % % % % % % % % % % % %
%%
%% First version 
%%

%%
%% TODO:
%%
%% - OK problem: non-harmonic tones [verunklaren Harmonik]. Reconsider where to use non-harmonic tones here (e.g., only rel short tones -- ornamental dissonance) HS.rules.onlyOrnamentalDissonance_Durations
%%
%% - ?? Make harmony clearer by having longer sections (multiple motifs) with the same underlying harmony
%% 
%% - ?? Make harmony clear: all/essential chord tones should be there
%%
%% - !! There are multiple non-harmonic tones between two harmonic tones in the scale: how to choose convincingly which one is taken?
%%   I could somehow constraint to always to use the upper (or lower) one
%%
%% - !! def more convincing motif(s) (durations, rests, pitch contour...), or more simple motifs
%%
%% - ?? restrict motifs more than simply by pitch contour -- too [beliebig]
%%   e.g. also interval max-min pitch?
%%
%% - control interval between local maxima of motifs
%%  - control contour with Fenv
%%  - only steps
%%  - ?? same for mins?
%%
%% - ?? introduce breaks (offset time in motif?)
%%
%% - !! def form: how motifs change, perhaps multiple different motifs
%%
%% - consider adding chord starts more [freely], not automatically for each motif
%%
%% OK - somehow introduce motifs: which model?
%%
%% OK - avoid number of notes/chords problem: chord starts when there is a chord start marker or something similar
%%   
%%


%%
%%
%%


/*

declare
/** %% 
%%
%%
%% */
Motif_A_Ns
= {Segs.tSC.defSubscript
   unit(super: Score.makeItems_iargs
	mixins: [Segs.makeCounterpoint_Mixin]
	%% Motif features
	motif: unit(%% explicit number of notes to avoid any ambiguity
		    %% (e.g., pitchContour has less elements) 
		    n: 5
		    %% 5 notes specified
		    durations: [D.d4 D.d4 D.d4_ D.d8 D.d2_]
		    #fun {$ Ns} {Pattern.mapItems Ns getDuration} end
% 		    %% one less element than durations
		    pitchContour: [2 2 0 0]
		    #fun {$ Ns}
			{Pattern.map2Neighbours {Pattern.mapItems Ns getPitch}
			 Pattern.direction}
		     end
		    %% motif starts with quarter note rest
		    %% Note: requires appropriate domain at idefaaults.offsetTime 
		    offsetTimes: [D.d4 0 0 0 0]
		    %% ?? Does Segs.tSC.defSubscript already support dumy value '_'?
% 		    offsetTimes: [2 '_' '_' '_' '_']
		    #fun {$ Ns} {Pattern.mapItems Ns getOffsetTime} end
		   )
	%% TMP transformers -- not used so far...
	transformers: [Segs.tSC.removeShortNotes
		       Segs.tSC.substituteNote
		       Segs.tSC.diminishAdditively
		       Segs.tSC.augmentAdditively
		       Segs.tSC.diminishMultiplicatively
		       Segs.tSC.augmentMultiplicatively]
	idefaults: unit(%% to add DomSpec support
			constructor: {Score.makeConstructor HS.score.note
				      unit(inChordB: fd#(0#1))}
			offsetTime: fd#[0 D.d4]
			inScaleB: 1
			rule: proc {$ Ns}
				 {HS.rules.onlyOrnamentalDissonance_Durations Ns}
			      end)
       )
   nil				% Body
  }
%% wrap seq around and set proper args
fun {Motif_A Args}
   Default = unit(rargs: unit(maxPitch: 'D'#5 
			      minPitch: 'G'#3
			      maxInterval: 2#1
			      maxNonharmonicNoteSequence: 1
			      minPercentSteps: 60
			     ))
   Notes = {Motif_A_Ns {GUtils.recursiveAdjoin Default Args}}
in
   {Score.make2 {Adjoin
		 {Record.subtractList Args [rargs iargs]}
		 seq(% info: startChord
		     Notes)}
    unit}
end
%% TODO: rhythm for this motif
Motif_B
= {Score.defSubscript
   unit(super: Segs.makeCounterpoint_Seq
	mixins: [Segs.hook]
	idefaults: unit(n: 5
			duration: D.d2
			inScaleB: fd#(0#1)
% 			rule: proc {$ Ns}
% 				 %% Hardcoded assumption that butlast is highest...
% 				 %% butlast note is chord tone
% 				 {{Reverse Ns}.2.1 getInChordB($)} = 1
% 			      end
		       )
	rdefaults: unit(maxPitch: 'D'#5 
			minPitch: 'G'#3
			maxInterval: 2#1
			maxNonharmonicNoteSequence: 1
			minPercentSteps: 60))
   nil}
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    ChordNo = 3 % depends on number of motifs with info-tag startChord (see below)
%     ChordNo = 5 % depends on number of motifs with info-tag startChord (see below)
    Chords = {MakeChords_22ETCounterpoint
	      unit(iargs: unit(n: ChordNo
% 			       duration: D.d1_ % * 2
% 			       duration: fd#([D.d1*2 D.d1*3 D.d1*4])
			      )
		   rargs: unit(types: ['harmonic 7th'
				       'subharmonic 6th']
			       firstRoot: 'C'
			       lastRoot: 'C'
			       progressionSelector: resolveDescendingProgressions(allowInterchangeProgression: true)
			      ))}
    MotifSeq
    Akks = {Segs.makeAkkords unit(iargs: unit(n: 4
					      amplitude: 20)
				  rargs: unit(maxPitch: 'C'#5 
					      minPitch: 'C'#3 
					      minPcCard: 4)
				  akkN: ChordNo)}
    End
    fun {GetMaxMotifPitch MyMotif}
       {Pattern.max {MyMotif mapItems($ getPitch)}}
    end
    fun {GetMinMotifPitch MyMotif}
       {Pattern.min {MyMotif mapItems($ getPitch)}}
    end
    %% Ps is list of loc max pitch of each motif. Contour follows fenv, and max interval is second
    proc {LocalMaxPattern Ps}
       {Pattern.fenvContour Ps
	{Fenv.linearFenv [[0.0 0.0] [0.8 1.0] [1.0 0.0]]}}
%        {Pattern.undulating Ps unit}
%        {Pattern.increasing Ps}
       {Pattern.restrictMaxInterval Ps {HS.pc 'D'}}
    end
    %% 
%     proc {ExpressEssential}
%     end
 in
    MyScore
    = {Score.make
       sim([seq(handle: MotifSeq
		%% number must match ChordNo
		[motif_a(info: startChord)
		 motif_a(info: startChord)
		 motif_a(info: startChord)
% 		 motif_a(info: startChord)
% 		 motif_a(info: startChord)
		 %% Nice: transformers work in principle (but these are ridiculous)
		 %% TODO: def/use convincing transformers
% 		 motif_a(rargs:unit(removeShortNotes: 1))
% 		 motif_a(rargs:unit(removeShortNotes: 1))
% 		 motif_a(rargs:unit(removeShortNotes: 2))
% 		 motif_a(rargs:unit(removeShortNotes: 3))
		]
		endTime:End)
	    %% an akkord per chord
	    seq(Akks
		endTime: End)
	    %% notes are implicitly related to simultaneous chord and scale
	    seq(Chords
		endTime: End)
	    seq([scale(index:{HS.db.getScaleIndex 'standard pentachordal major'}
		       transposition:0)]	       
		endTime:End)]
	   startTime:0
	   timeUnit:beats(Beat))
       add(motif_a: Motif_A
	   %% unused so far
	   motif_b: Motif_B
	   chord:HS.score.chord
	   scale:HS.score.scale)}
    %%
    {LocalMaxPattern {MotifSeq mapItems($ GetMaxMotifPitch)}}
%     %% Each motif expresses all essential chord PCs: rather strict constraint
%     {ForAll {MotifSeq getItems($)}
%      proc {$ MyMotif}
% 	{HS.rules.
% 	{MyMotif mapItems($ getPitch)}
%      end}
    {HS.score.harmonicRythmFollowsMarkers MyScore Chords unit}
    %% Akks follow harmonic rhythm
    {ForAll {LUtils.matTrans [Chords Akks]}
     proc {$ [C A]} {C getStartTime($)} = {A getStartTime($)} end}
 end
 HS.distro.leftToRight_TypewiseTieBreaking
%  HS.distro.typewise_LeftToRightTieBreaking
}

*/


% % % % % % % % % % % % % % % %
%%
%% Second version 
%%

%%
%% TODO:
%%
%% OK - !!!! restrict motifs more than simply by pitch contour -- too [beliebig]
%%   e.g. also interval max-min pitch?
%%
%% OK? - control interval between local maxima of motifs
%%  - control contour with Fenv
%%  - only steps
%%  - ?? same for mins?
%%
%%
%% OK - Make harmony clearer by having longer sections (multiple motifs) with the same underlying harmony
%% 
%% - ?? Make harmony clear: all/essential chord tones should be there
%%
%% - !!?? There are multiple non-harmonic tones between two harmonic tones in the scale: how to choose convincingly which one is taken?
%%   I could somehow constraint to always to use the upper (or lower) one
%%
%%

% /** %% Returns the scale degree interval (FD int) between the notes N1 and N2 (instances of HS.score.scaleDegreeNote).
% %% Note: blocks until scale is determined.
% %% */
% %% BUG: needs testing...
% %% .. still unused...
% proc {ScaleDegreeInterval N1 N2 MyScale ?Interval}
%    fun {GetDegree N}
%       {HS.score.getDegree {N getPitchClass($)} MyScale
%        unit(accidentalRange:0) % only scale tones
% %        unit(accidentalRange:{HS.db.getAccidentalOffset})
%       }
%    end
%    ScaleCard = {FS.card {MyScale getPitchClasses($)}}
%    Degree1 = {GetDegree N1}
%    Degree2 = {GetDegree N2}
%    Aux = {FD.decl}
% in
%    Aux =: Degree1 - Degree2 + ScaleCard % add ScaleCard to avoid neg numbers
%    Interval = {FD.modI Aux ScaleCard}
% end


/** %% The interval between N1 and N1 is in [1, whole tone raised by a syntonic comma].
%% */
fun {IsStepR N1 N2}
   {HS.rules.isStepR {N1 getPitch($)} {N2 getPitch($)}
    {HS.pc 'D/'}
%     {HS.pc 'E'}
%     {HS.pc 'D#\\'}
   }
end
proc {IsStep N1 N2}
   {HS.rules.isStep {N1 getPitch($)} {N2 getPitch($)}
    {HS.pc 'D/'}
%     {HS.pc 'E'}
%     {HS.pc 'D#\\'}
   }
end

/* 

declare
/** %% 
%%
%%
%% */
Motif_A_Ns
= {Segs.tSC.defSubscript
   unit(super: Score.makeItems_iargs
	mixins: [Segs.makeCounterpoint_Mixin]
	%% Motif features
	motif: unit(%% explicit number of notes to avoid any ambiguity
		    %% (e.g., pitchContour has less elements) 
		    n: 6
		    %% 5 notes specified
		    durations: [D.d4 D.d4 D.d8 D.d4 D.d2 D.d2]
		    #fun {$ Ns} {Pattern.mapItems Ns getDuration} end
% 		    %% one less element than durations
		    pitchContour: [2 2 2 2 0]
		    #fun {$ Ns}
			{Pattern.map2Neighbours {Pattern.mapItems Ns getPitch}
			 Pattern.direction}
		     end
		    isStep: [0 1 1 1 0]
		      #fun {$ Ns}
			  {Pattern.map2Neighbours Ns fun {$ N1 N2} {IsStepR N1 N2} end}
		       end
		   )
	transformers: [Segs.tSC.removeShortNotes]
	idefaults: unit(%% Set note class and add DomSpec support
			constructor: {Score.makeConstructor HS.score.note
				      unit(inChordB: fd#(0#1))}
			inScaleB: 1
			rule: proc {$ Ns}
				 {HS.rules.onlyOrnamentalDissonance_Durations Ns}
			      end)
       )
   nil				% Body
  }
%% wrap seq around and set proper args
fun {Motif_A Args}
   Default = unit(rargs: unit(maxPitch: 'G'#5 
			      minPitch: 'G'#3
			      maxInterval: 8#5
% 			      step:8#7
			      maxNonharmonicNoteSequence: 1
% 			      minPercentSteps: 60
			     ))
   Notes = {Motif_A_Ns {GUtils.recursiveAdjoin Default Args}}
in
   {Score.make2 {Adjoin
		 {Record.subtractList Args [rargs iargs]}
		 seq(Notes)}
    unit}
end
%% TODO: rhythm for this motif
Motif_B
= {Score.defSubscript
   unit(super: Segs.makeCounterpoint_Seq
	mixins: [Segs.hook]
	idefaults: unit(n: 5
			offsetTime: each#[D.d8 0 0 0 0]
			duration: each#[D.d8 D.d8 D.d8 D.d4 D.d2]
			inScaleB: 1
			rule: proc {$ Ns}
				 {HS.rules.onlyOrnamentalDissonance_Durations Ns}
				 {Pattern.for2Neighbours Ns
				  proc {$ N1 N2} {IsStep N1 N2} end}
			      end)
	rdefaults: unit(maxPitch: 'G'#5 
			minPitch: 'G'#3
			maxInterval: 8#5
% 			step:8#7
			maxNonharmonicNoteSequence: 1
% 			minPercentSteps: 60
			oppositeDir: 2 % last interval goes up
		       ))
   nil}
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    ChordNo = 4 % depends on number of motifs with info-tag startChord (see below)
%     ChordNo = 5 % depends on number of motifs with info-tag startChord (see below)
    Chords = {MakeChords_22ETCounterpoint
	      unit(iargs: unit(n: ChordNo)
		   rargs: unit(types: ['harmonic 7th'
				       'subharmonic 6th']
			       firstRoot: 'C'
			       lastRoot: 'C'
			       progressionSelector: resolveDescendingProgressions(allowInterchangeProgression: true)
			      ))}
    MotifSeq
    End
    fun {GetMaxMotifPitch MyMotif}
       {Pattern.max {MyMotif mapItems($ getPitch test:isNote)}}
    end
    %% Ps is list of loc max pitch of each motif. Contour follows fenv, and max interval is second
    proc {LocalMaxPattern Ps}
%        {Pattern.fenvContour Ps
% 	{Fenv.linearFenv [[0.0 0.0] [0.8 1.0] [1.0 0.0]]}}
%        {Pattern.increasing Ps}
       {Pattern.restrictMaxInterval Ps {HS.pc 'D#\\'}}
    end
 in
    %% TODO: find some automatic way to enter bar lines..
    MyScore
    = {Score.make
       sim(info: lily("\\cadenzaOn")
	   [seq(handle: MotifSeq
		%% number of motifs with info startChord must match ChordNo
		[seq([motif_a(info: startChord)
		      motif_a
		      motif_b
		      pause(duration:D.d2)
		     ])
		 seq([motif_a(info: startChord)
		      motif_a(rargs:unit(removeShortNotes: 1))
		      motif_a(rargs:unit(removeShortNotes: 1))
		      motif_a(rargs:unit(removeShortNotes: 2))
		      motif_a(rargs:unit(removeShortNotes: 3))])
		 seq([motif_b(info: startChord)
		      motif_b
		      pause(duration:D.d2)
		     ])
		 seq([motif_a(info: startChord)])
		]
		endTime:End)
	    %% notes are implicitly related to simultaneous chord and scale
	    seq(Chords
		endTime: End)
	    seq([scale(index:{HS.db.getScaleIndex 'standard pentachordal major'}
		       transposition:0)]	       
		endTime:End)]
	   startTime:0
	   timeUnit:beats(Beat))
       add(motif_a: Motif_A
	   %% unused so far
	   motif_b: Motif_B
	   chord:HS.score.chord
	   scale:HS.score.scale)}
    %% add bar lines to all but the first motif (with current lily tag
    %% implementation, these bar lines are always placed *before* the
    %% motif)
    {ForAll {MyScore collect($ test: fun {$ X}
					{X isContainer($)} andthen {All {X mapItems($ isNote)} GUtils.identity}
				     end)}.2
     proc {$ MyMotif} {MyMotif addInfo(lily("\\ibar"))} end}
    %%
    {HS.score.harmonicRythmFollowsMarkers MyScore Chords unit}
    %%
    %% Further constraints
    %%
    %% NOTE: this constraint can cause much search, because it is
    %% applied very late (max motif pitches are known very late)
    {ForAll {MotifSeq getItems($)}
     proc {$ SubMotifseq}
	{LocalMaxPattern {SubMotifseq mapItems($ GetMaxMotifPitch test:isSequential)}}
     end}
 end
 HS.distro.leftToRight_TypewiseTieBreaking
%  HS.distro.typewise_LeftToRightTieBreaking
}

*/



/* % TMP test



*/




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Multiple decatonic lines over a chord progression.
%%
%% Constraints between voices, e.g.,
%%
%% ?? interval between non-chord tones is 7-limit consonant?
%%
%% Rhythmic constraints: ...
%% e.g., make "wendepunkte" at least as long as notes around
%%
%% allow for rests: offset times..
%%

%%
%% NOTE: unfinished example
%%

%%
%% !! first with uniform rhythm
%%
%% Try "florid" version, it might make the search problem less hard (??) 
%%
%%
%% NOTE: 
%% !! Try to give it some *form*
%%
%% - e.g., some global aspect that changes slowly such as average note durations, pitch domain...
%%

%%
%% TODO:
%%
%% OK? - clearly express harmony:
%%   - all (essential) PCs
%%   - more tones per chord
%%   - avoid unison altogether?
%%
%% - no pitch repetition
%%
%% OK - undulating (wellenfoermige Bewegung): restrict number of direction changes
%%
%% OK - min 3, max 8-9 notes in same direction 
%%
%% OK - after skip move in opposite direction (after [large] skip do step) OR ballistic curve rule
%%
%% !! - increase number of voices, so that it is more easy to have always 3 different PCs
%%
%% !! - increase pitch domain
%%
%% !?? - sim notes: always at least 3 different PCs
%%
%% - restrict bass somehow...
%%   e.g., use chord root or third... If fifths or 6th / 7th then resolve stepwise
%%
%% - stimmkreuzung nur wenn
%%   - ?? fuer mehrere Toene?
%%   - ?? schrittweise?
%%
%%
%% OK - only allow for small set of chord types
%%
%% - ?? add cadence constraint?
%%
%% - rhythm constraints
%%
%%

%%
%% Vorlaeufige Entscheidung: keine Pausen zw Noten. Erlaube Pausen optional zw Motiven im naechsten B.
%%

%%
%% TODO:
%%
%% - min number of steps: it seems in the end search tries to make up the missing steps from the beginning.
%%   ?? should value ordering instead prefer steps?
%%

/*

declare
{GUtils.setRandomGeneratorSeed 0}
/** %% Variant of Segs.makeCounterpoint that predefines new default args.
%% */
fun {MakeVoiceNotes Args}
   Defaults = unit(iargs: unit(inScaleB: 1 % only scale tones
% 			       duration: fd#[D.d8 D.d4 D.d2]
% 			       offsetTime: fd#[0 D.d4 D.d2]
			      )
		   rargs: unit(maxInterval: 2#1
			       maxNonharmonicNoteSequence: 1
			       %% hm, likely makes search more complex
% 			       minPercentSteps: 60
			      ))
in
   {Segs.makeCounterpoint
    {GUtils.recursiveAdjoin Defaults Args}}
end
{SDistro.exploreOne
 proc {$ MyScore}
    ChordNo = 5
    End
    VoiceNs1 = {MakeVoiceNotes
		unit(iargs: unit(n: ChordNo*8 % depends also on duration
				 duration: D.d4
				)
		     rargs: unit(maxPitch: 'F'#5 % pitch unit and notation is et22
				 minPitch: 'A'#3))}
    VoiceNs2 = {MakeVoiceNotes
		unit(iargs: unit(n: ChordNo*8
				 duration: D.d4
				)
		     rargs: unit(maxPitch: 'D'#5 
				 minPitch: 'G'#3))}
    VoiceNs3 = {MakeVoiceNotes
		unit(iargs: unit(n: ChordNo*8
				 duration: D.d4
				)
		     rargs: unit(maxPitch: 'D'#5 
				 minPitch: 'F'#3))}
    VoiceNs4 = {MakeVoiceNotes
		unit(iargs: unit(n: ChordNo*4
				 duration: D.d2
				)
		     rargs: unit(maxPitch: 'G'#4 
				 minPitch: 'C'#3
				))}
    VoiceNs5 = {MakeVoiceNotes
		unit(iargs: unit(n: ChordNo*4
				 duration: D.d2
				)
		     rargs: unit(maxPitch: 'D'#4 
				 minPitch: 'E'#2
				 minPercentSteps: false
				))}
    Chords = {MakeChords_22ETCounterpoint
	      unit(iargs: unit(n: ChordNo
			       duration: D.d1 * 2)
		   rargs: unit(types: ['harmonic 7th'
				       'subharmonic 6th']
			       firstRoot: 'C'
			       lastRoot: 'C'))}
    AllNotes
 in
    MyScore
    = {Score.make
       sim([seq(VoiceNs1
		endTime:End)
	    seq(VoiceNs2
		endTime:End)
	    seq(VoiceNs3
		endTime:End)
	    seq(VoiceNs4
		endTime:End)
	    seq(info:lily("\\clef bass")
		VoiceNs5
		endTime:End)
	    %% notes are implicitly related to simultaneous chords and scale
	    seq(Chords
		endTime:End)
	    seq([scale(index:{HS.db.getScaleIndex 'standard pentachordal major'}
		       transposition: {ET22.pc 'C'}
		       endTime:End)])]
	   startTime:0
	   timeUnit:beats(Beat))
       add(chord:HS.score.chord
	   scale:HS.score.scale)}
    AllNotes = {MyScore collect($ test:isNote)}
    %%
    {ForAll [VoiceNs1 VoiceNs2 VoiceNs3 VoiceNs4 VoiceNs5]
     proc {$ Ns}
	Ps = {Pattern.mapItems Ns getPitch}
     in
 	%% restrict non-harmonic tones (suspension etc.)
	{HS.rules.clearHarmonyAtChordBoundaries Chords Ns}
	{HS.rules.clearDissonanceResolution Ns}
	{Pattern.noRepetition Ps} % no direct pitch repetition
	%% seems to make search problem more complex..
	{Pattern.undulating Ps
	 unit(min:3
	      max: 8)}
	{HS.rules.ballistic Ps unit(oppositeIsStep: true)}
     end}
    %%
    %% important: always at least 3 different sim PCs
    thread
       {SMapping.forTimeslices AllNotes
	proc {$ Ns} {MinCard Ns 3} end
	unit(endTime: End
	     %% NOTE: avoid reapplication of constraint for equal consecutive sets of score object
	     step: D.d4		% ?? should be shortest note dur available..
	    )}
    end
    %%
    %% !! seems to make search problem more complex, it is not really required
%     thread  % NOTE: ?? move threads into constraint defs themselves?
%        %% Non-chord tones are consonant to each other.
%        {HS.rules.intervalBetweenNonharmonicTonesIsConsonant AllNotes
% 	{MakeConsonancePCs_multipleOctaves 2}}
%     end
    {HS.rules.noParallels2 AllNotes unit} 
 end
%  HS.distro.typewise_LeftToRightTieBreaking
 HS.distro.leftToRight_TypewiseTieBreaking
}


*/

%%
%%
%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% variant of previous example
%%
%% - less voices
%% TMP
%% - less constraints
%%
%% TODO: 
%% - More flexible rhythm
%% - Pattern motifs
%% - Make bass as flexible as upper voice and then extra constraint 
%%

%%
%% Bass constraint:
%% - ? local pitch minima in bass must be either chord degree 1 (root) or 2 (third?).
%% - ? lowest bass tone per chord must be either chord degree 1 (root) or 2 (third?). [this bass tone might be "too late"]
%%

/*

declare
{GUtils.setRandomGeneratorSeed 0}
/** %% Variant of Segs.makeCounterpoint that predefines new default args.
%% */
fun {MakeVoiceNotes Args}
   Defaults = unit(iargs: unit(inScaleB: 1 % only scale tones
% 			       duration: fd#[D.d8 D.d4 D.d2]
% 			       offsetTime: fd#[0 D.d4 D.d2]
			      )
		   rargs: unit(maxInterval: 2#1
			       maxNonharmonicNoteSequence: 1
			       %% hm, likely makes search more complex
% 			       minPercentSteps: 60
			      ))
in
   {Segs.makeCounterpoint
    {GUtils.recursiveAdjoin Defaults Args}}
end
{SDistro.exploreOne
 proc {$ MyScore}
    ChordNo = 5
    End
    VoiceNs1 = {MakeVoiceNotes
		unit(iargs: unit(n: ChordNo*8 % depends also on duration
				 duration: D.d4
				)
		     rargs: unit(maxPitch: 'F'#5 % pitch unit and notation is et22
				 minPitch: 'A'#3))}
    VoiceNs2 = {MakeVoiceNotes
		unit(iargs: unit(n: ChordNo*4
				 duration: D.d2
				)
		     rargs: unit(maxPitch: 'D'#4 
				 minPitch: 'E'#2
				 minPercentSteps: false
				))}
    Chords = {MakeChords_22ETCounterpoint
	      unit(iargs: unit(n: ChordNo
			       duration: D.d1 * 2)
		   rargs: unit(types: ['harmonic 7th'
				       'subharmonic 6th']
			       firstRoot: 'C'
			       lastRoot: 'C'))}
    AllNotes
 in
    MyScore
    = {Score.make
       sim([seq(VoiceNs1
		endTime:End)
	    seq(info:lily("\\clef bass")
		VoiceNs2
		endTime:End)
	    %% notes are implicitly related to simultaneous chords and scale
	    seq(Chords
		endTime:End)
	    seq([scale(index:{HS.db.getScaleIndex 'standard pentachordal major'}
		       transposition: {ET22.pc 'C'}
		       endTime:End)])]
	   startTime:0
	   timeUnit:beats(Beat))
       add(chord:HS.score.chord
	   scale:HS.score.scale)}
    AllNotes = {MyScore collect($ test:isNote)}
    %%
    %% TMP comment
%     {ForAll [VoiceNs1 VoiceNs2]
%      proc {$ Ns}
% 	Ps = {Pattern.mapItems Ns getPitch}
%      in
%  	%% restrict non-harmonic tones (suspension etc.)
% 	{HS.rules.clearHarmonyAtChordBoundaries Chords Ns}
% 	{HS.rules.clearDissonanceResolution Ns}
% 	{Pattern.noRepetition Ps} % no direct pitch repetition
% 	%% seems to make search problem more complex..
% 	{Pattern.undulating Ps
% 	 unit(min:3
% 	      max: 8)}
% 	{HS.rules.ballistic Ps unit(oppositeIsStep: true)}
%      end}
%     %%
%     %% important: always at least 3 different sim PCs
%     thread
%        {SMapping.forTimeslices AllNotes
% 	proc {$ Ns} {MinCard Ns 3} end
% 	unit(endTime: End
% 	     %% NOTE: avoid reapplication of constraint for equal consecutive sets of score object
% 	     step: D.d4		% ?? should be shortest note dur available..
% 	    )}
%     end
    %%
    %% !! seems to make search problem more complex, it is not really required
%     thread  % NOTE: ?? move threads into constraint defs themselves?
%        %% Non-chord tones are consonant to each other.
%        {HS.rules.intervalBetweenNonharmonicTonesIsConsonant AllNotes
% 	{MakeConsonancePCs_multipleOctaves 2}}
%     end
    {HS.rules.noParallels2 AllNotes unit} 
 end
%  HS.distro.typewise_LeftToRightTieBreaking
 HS.distro.leftToRight_TypewiseTieBreaking
}


*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% variant of previous example with flexible rhythm
%%
%% [perhaps] NOT Working Yet
%%

%%
%% NOTE: even a monophonic version of this example with no constraints between the voices is hard to solve! see below
%% The distro might not be suitable...
%%
%% Idea: first determine rhythmic structure
%%

/*

declare
{GUtils.setRandomGeneratorSeed 0}
/** %% Variant of Segs.makeCounterpoint that predefines new default args.
%% */
fun {MakeVoiceNotes Args}
   Defaults = unit(iargs: unit(inScaleB: 1 % only scale tones
			       duration: fd#[D.d4 D.d2 D.d2_ D.d1]
% 			       offsetTime: fd#[0 D.d4 D.d2]
			      )
		   rargs: unit(maxInterval: 2#1
			       maxNonharmonicNoteSequence: 1
			       %% hm, likely makes search more complex
% 			       minPercentSteps: 60
			      ))
in
   {Segs.makeCounterpoint
    {GUtils.recursiveAdjoin Defaults Args}}
end
{SDistro.exploreOne
 proc {$ MyScore}
    ChordNo = 3 % 5
    End
    VoiceNs1 = {MakeVoiceNotes
		unit(iargs: unit(n: ChordNo*5 % depends also on duration
% 				 duration: D.d4
				)
		     rargs: unit(maxPitch: 'F'#5 % pitch unit and notation is et22
				 minPitch: 'A'#3))}
    VoiceNs2 = {MakeVoiceNotes
		unit(iargs: unit(n: ChordNo*5
% 				 duration: D.d4
				)
		     rargs: unit(maxPitch: 'D'#5 
				 minPitch: 'G'#3))}
    VoiceNs3 = {MakeVoiceNotes
		unit(iargs: unit(n: ChordNo*4
% 				 duration: D.d4
				)
		     rargs: unit(maxPitch: 'D'#5 
				 minPitch: 'F'#3))}
    VoiceNs4 = {MakeVoiceNotes
		unit(iargs: unit(n: ChordNo*4
% 				 duration: D.d2
				)
		     rargs: unit(maxPitch: 'G'#4 
				 minPitch: 'C'#3
				))}
    VoiceNs5 = {MakeVoiceNotes
		unit(iargs: unit(n: ChordNo*3
% 				 duration: D.d2
				)
		     rargs: unit(maxPitch: 'D'#4 
				 minPitch: 'E'#2
				 minPercentSteps: false
				))}
    Chords = {MakeChords_22ETCounterpoint
	      unit(iargs: unit(n: ChordNo
			       duration: fd#([D.d1*2 D.d1*3 D.d1*4]))
		   rargs: unit(types: ['harmonic 7th'
				       'subharmonic 6th']
			       firstRoot: 'C'
			       lastRoot: 'C'
			       %% TMP 
			       progressionSelector: harmonicBand))}
    AllNotes
 in
    MyScore
    = {Score.make
       sim([seq(VoiceNs1
		endTime:End)
	    seq(VoiceNs2
		endTime:End)
	    seq(VoiceNs3
		endTime:End)
	    seq(VoiceNs4
		endTime:End)
	    seq(info:lily("\\clef bass")
		VoiceNs5
		endTime:End)
	    %% notes are implicitly related to simultaneous chords and scale
	    seq(Chords
		endTime:End)
	    seq([scale(index:{HS.db.getScaleIndex 'standard pentachordal major'}
		       transposition: {ET22.pc 'C'}
		       endTime:End)])]
	   startTime:0
	   timeUnit:beats(Beat))
       add(chord:HS.score.chord
	   scale:HS.score.scale)}
    AllNotes = {MyScore collect($ test:isNote)}
    %%
    {ForAll [VoiceNs1 VoiceNs2 VoiceNs3 VoiceNs4 VoiceNs5]
     proc {$ Ns}
	Ps = {Pattern.mapItems Ns getPitch}
     in
	{SlowRhythmChanges Ns}
	{StartAndEndWithGivenDur Ns {FD.int D.d1}}
 	%% restrict non-harmonic tones (suspension etc.)
	{HS.rules.clearHarmonyAtChordBoundaries Chords Ns}
	{HS.rules.clearDissonanceResolution Ns}
	{Pattern.noRepetition Ps} % no direct pitch repetition
	%% seems to make search problem more complex..
	{Pattern.undulating Ps
	 unit(min:3
	      max: 8)}
	{HS.rules.ballistic Ps unit(oppositeIsStep: true)}
     end}
    %%
    %% important: always at least 3 different sim PCs
    thread
       {SMapping.forTimeslices AllNotes
	proc {$ Ns} {MinCard Ns 3} end
	unit(endTime: End
	     %% NOTE: avoid reapplication of constraint for equal consecutive sets of score object
	     step: D.d4		% ?? should be shortest note dur available..
	    )}
    end
    %%
    %% !! seems to make search problem more complex, it is not really required
%     thread  % NOTE: ?? move threads into constraint defs themselves?
%        %% Non-chord tones are consonant to each other.
%        {HS.rules.intervalBetweenNonharmonicTonesIsConsonant AllNotes
% 	{MakeConsonancePCs_multipleOctaves 2}}
%     end
%     {HS.rules.noParallels2 AllNotes unit} 
 end
%  HS.distro.typewise_LeftToRightTieBreaking
 HS.distro.leftToRight_TypewiseTieBreaking
}


*/


/* %% TMP test


*/




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Simplified monophonic version of above for testing
%%
%%

/*

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    ChordNo = 5
    End
    %% TMP: voice created simply a sequence of notes (no structure by motifs)
    MelodyNotes = {Segs.makeCounterpoint
	       unit(iargs: unit(n: ChordNo*6
				duration: D.d4
% 				duration: fd#[D.d4 D.d2 D.d2_ D.d1]
				inScaleB: 1 
			       )
		    rargs: unit(maxPitch: 'D'#5 
				minPitch: 'G'#3
				maxInterval: 2#1
				maxNonharmonicNoteSequence: 1
				minPercentSteps: 60
			       )
		    endTime: End)}
    Chords = {MakeChords_22ETCounterpoint
	      unit(iargs: unit(n: ChordNo
			       duration: D.d1_ % * 2
% 			       duration: fd#([D.d1*2 D.d1*3 D.d1*4])
			      )
		   rargs: unit(types: ['harmonic 7th'
				       'subharmonic 6th']
			       firstRoot: 'C'
			       lastRoot: 'C'))}
 in
    MyScore
    = {Score.make
       sim([seq(MelodyNotes
		endTime:End)
	    %% notes are implicitly related to simultaneous chord and scale
	    seq(Chords
	       endTime: End)
	    seq([scale(index:{HS.db.getScaleIndex 'standard pentachordal major'}
		       transposition:0)]	       
		endTime:End)]
	   startTime:0
	   timeUnit:beats(Beat))
       add(chord:HS.score.chord
	   scale:HS.score.scale)}
    %%
    local 
	Ps = {Pattern.mapItems MelodyNotes getPitch}
     in
% 	{SlowRhythmChanges MelodyNotes}
% 	{StartAndEndWithGivenDur MelodyNotes {FD.int D.d1}}
	{Pattern.noRepetition Ps} % no direct pitch repetition
	%% seems to make search problem more complex..
	{Pattern.undulating Ps
	 unit(min:3
	      max: 8)}
       %% !! Too expensive: more simple approach: know positions of local max in motifs and constrain those..
%        {Pattern.constrainLocalMax Ps
% 	%% NB: Pattern.for2Neighbours works concurrently like Map or Filter: defined with Zip
% 	proc {$ Maxima}
% 	   %% TMP: test
% 	   {Pattern.for2Neighbours Maxima
% 	    proc {$ X Y} X <: Y end}
% 	end}
       {HS.rules.ballistic Ps unit(oppositeIsStep: true
				   maxStep: 5#4)}
    end
 end
 HS.distro.leftToRight_TypewiseTieBreaking}


*/




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Same as above, but additionally using motifs (pattern motif model)
%%
%%

%%
%% Example still missing..
%%


% Segs.makeCounterpoint_PatternMotifs_OffsetDurationPitchcontour

   %% TODO:
    %% Constraints depend on rhythm
%     {ForAll [VoiceNs1 VoiceNs2 VoiceNs3]
%      proc {$ VoiceNs}
% 	%% all voices end before/with chord/scale end times
% % 	{{List.last VoiceNotes} getEndTime($)} =<: End
% 	%%
% 	%% NOTE: in conflict with constraint requiring many steps  
% 	{HS.rules.onlyOrnamentalDissonance_Durations VoiceNs}
% 	{ChordToneBeforeRest VoiceNs}	
% % 	{ChordToneAfterRest VoiceNs} % NOTE: optional
% 	{MinLastPhraseDur VoiceNs D.d4}
% 	{MinLastDur VoiceNs D.d4}
% 	%% restrict total rest duration per voice.
    %% TODO: better alternative: restrict max total number of rests per voice
% 	{FD.sum {Pattern.mapItems VoiceNs getOffsetTime} '=<:' D.d1}
%      end}
    %%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Aux defs
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Rhythm representation
%%

%% Symbolic duration names: Note durations are then written as
%% follows: D.d16 (16th note), D.d8 (eighth note) and so forth, D.d8_
%% (dotted eighth note). See doc of MUtils.makeNoteLengthsTable for
%% more details.
Beat = 4 * 3 
D = {MUtils.makeNoteLengthsRecord Beat [3]}
/** %% Function expecting a symbolic duration name and returning the corresponding numeric duration.
%% */
fun {SymbolicDurToInt Spec} D.Spec end

F = IntToFloat


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Harmony defs
%%

/** %% 5-limit and 7-limit consonant pitch class intervals.
%% no prime, fifths, octaves to avoid parallels
%% */
ConsonancePCs 
= {Map [8#7 7#6 6#5 5#4 8#5 5#3 12#7 7#4] HS.score.ratioToInterval}
/** %% 5-limit and 7-limit consonant intervals over two octaves.
%% */
fun {MakeConsonancePCs_multipleOctaves OctaveNo}
   {LUtils.accum
    {Map {List.number 0 OctaveNo-1 1}
     fun {$ I} {Map ConsonancePCs fun {$ PC} PC + I*{HS.db.getPitchesPerOctave} end} end}
   Append}
end
Consonances_twoOctaves = {MakeConsonancePCs_multipleOctaves 2}
Consonances_threeOctaves = {MakeConsonancePCs_multipleOctaves 3}

/** %% The set of all pairwise pitch class intervals between Notes (list of HS.score.note objects) contains at least one interval which is neither a prime (octave) nor a fifths. 
%% */
proc {WithNonperfectIntervals Notes}
   if {Length Notes} >= 2
   then
      Intervals = {Pattern.mapPairwise {Pattern.mapItems Notes getPitchClass}
		   proc {$ PC1 PC2 Interval}
		      {HS.score.transposePC PC1 Interval PC2}
		   end}
      Intervals_FS = {GUtils.intsToFS Intervals}
      TestInterval = {FD.decl}
   in
      {FS.include TestInterval Intervals_FS}
      TestInterval \=: {HS.score.ratioToInterval 3#2}
      TestInterval \=: 0
   end
end

/** %% The cardiality of the set of pitchclasses of Notes (list of HS.score.note objects) is at least Card (FD int).
%% */
proc {MinCard Notes Card}
   PC_FS = {GUtils.intsToFS {Pattern.mapItems Notes getPitchClass}}
   AuxCard = {FD.decl}
in
   AuxCard = {FS.card PC_FS}
   AuxCard >=: Card
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Harmony 
%%

/** %%
%%
%% Args.rargs
%% 'firstRoot' (default false): root of first chord (pc atom)
%% 'firstToLastRootInterval' (default false): pc interval between first and last chord root (pc atom, e.g., 'C' is 0, or false).
%% 'lastRoot' (default false): root of last chord (pc atom, or false)
%% 'firstType' / 'lastType' (default false): sets the type (index) of the first/last chord in Chords to the type specified, an atom (chord name specified in the database). Disabled if false.
%%
%% 
%% */
%%
%% 
%% 'howOftenRoot' (default false): record of args unit(pc:ET31_PC min:MinPercent max:MaxPercent): constraints percentage how often given pitch class occurs as a root in chord progression.
%% Args from super script MakeSchoenbergianProgression
%%
%%
MakeChords_22ETCounterpoint
= {Score.defSubscript
   unit(super:HS.score.makeChords
	%% diatonic chord with fd args
	idefaults: unit(constructor: {Score.makeConstructor HS.score.diatonicChord
				      unit})
	rdefaults: unit(progressionSelector: resolveDescendingProgressions()
		       ))
   proc {$ Chords Args}
      {HS.rules.setBoundaryRoots Chords Args.rargs}
      {HS.rules.setBoundaryTypes Chords Args.rargs}
      {HS.rules.schoenberg.progressionSelector Chords Args.rargs.progressionSelector}
   end}


/* % test

%% check result, e.g., with Explorer action "Browse initRecord"

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    Chords
 in
    MyScore
    = {Score.make seq(Chords
		      = {MakeChords_22ETCounterpoint
			 unit(iargs: unit(n:3*3
					  duration:D.d1)
			      rargs: unit(types: ['harmonic 7th'
						  'subharmonic 6th' % Tristan chord
						 ]
					  firstRoot: 'C'
					  lastRoot: 'G'
					  %% Root c appears a few times
% 					  howOftenRoot: unit(pc:'C' min:30 max:60)
					 )
			     )} 
		      startTime: 0
		      timeUnit: beats(Beat))
       unit}
 end
 HS.distro.typewise_LeftToRightTieBreaking
}


*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Counterpoint rules
%%

/** %% A note before a rest must be a chord tone: inChordB=1 of each note which is followed by a note with offset time > 0.
%% */
proc {ChordToneBeforeRest Notes}
   {Pattern.for2Neighbours Notes
    proc {$ N1 N2}
       {FD.impl ({N2 getOffsetTime($)} >: 0)
	({N1 getInChordB($)} =: 1)
	1}
    end}
end

/* %% A note after a rest must be a chord tone: inChordB=1 of each note with offset time > 0. 
%% */
proc {ChordToneAfterRest Notes}
   {ForAll Notes
    proc {$ N}
       {FD.impl ({N getOffsetTime($)} >: 0)
	({N getInChordB($)} =: 1)
	1}
    end}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Rhythm
%%


/** %% The first and last note's duration of Notes is Dur.
%% */
proc {StartAndEndWithGivenDur Notes Dur}
   FirstNote = Notes.1
   LastNote = {List.last Notes}
in
   {FirstNote getDuration($)} = {LastNote getDuration($)} = Dur
end


/** %% Two neighbouring notes in Notes either have the same duration, or they differ by their halve duration value (e.g., a halve note can be followed by a quarter or a dotted quarter but not by an eighth note).
%% */
proc {SlowRhythmChanges Notes}
   {Pattern.for2Neighbours {Pattern.mapItems Notes getDuration}
    proc {$ Dur1 Dur2}
       HalveDur1 
    in
       {FD.times HalveDur1 2 Dur1}
       {FD.times HalveDur1 {FD.int 1#4} Dur2}
    end}
end



/** %% The last note of a "phrase" (note before a note with offset>0 and last note) has at least duration of its predecessor and is at least of duration Dur (FD int).  
%% */
proc {MinLastPhraseDur Notes Dur}
   {Pattern.for2Neighbours Notes
    proc {$ N1 N2}
       {FD.impl ({N2 getOffsetTime($)} >: 0)
	{FD.conj
	 ({N1 getDuration($)} >=: {N2 getDuration($)})
	 ({N1 getDuration($)} >=: Dur)}
       1}
    end}
end

/** %% The last note of Notes (list of notes) has at least duration Dur (FD int). 
%% */
proc {MinLastDur Notes Dur}
   {{List.last Notes} getDuration($)} >=: Dur
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Output
%%

EventToCsound_adaptiveJI 
= {Out.makeEvent2CsoundFn 1
   [getStartTimeParameter#getValueInSeconds
    fun {$ X} X end#getDurationInSeconds
    getAmplitudeParameter#getValueInNormalized
    %% max 127 velo results in max 90 dB (Csound amp value 31622.764)
%     getAmplitudeParameter#fun {$ X} {MUtils.levelToDB {X getValueInNormalized($)} 1.0} + 90.0 end
    fun {$ X} X end#fun {$ MyNote}
		       JIPitch = {HS.score.getAdaptiveJIPitch MyNote unit}
% 		       ETPitch = {MyNote getPitchInMidi($)}
		    in
		       JIPitch
% 		       %% JI may at max be 10 cent off, otherwise take ETPitch
% 		       %% 13#8 is 11 cent error
% 		       if {Abs JIPitch-ETPitch} > 0.11 then
% 			  {Browse
% 			   off_JI(ji:{HS.score.getAdaptiveJIPitch MyNote unit}
% 				  midi: {MyNote getPitchInMidi($)}
% 				  note:{MyNote toInitRecord($)}
% 				  chordIndex: {{MyNote getChords($)}.1 getIndex($)}
% 				  chordTransposition: {{MyNote getChords($)}.1 getTransposition($)}
% 				  chordPCs: {{MyNote getChords($)}.1 getPitchClasses($)}
% 				  chordRatios: {HS.db.getUntransposedRatios {MyNote getChords($)}.1}
% 				  noteDegreeInChord: {HS.score.getDegree {MyNote getPitchClass($)} {MyNote getChords($)}.1 unit(accidentalRange: 0)}
% 				 )}
% % 			  ETPitch
% 			  JIPitch
% 		       else
% % 			  {Browse ok_JI}
% % 			  {System.show
% % 			   {Out.recordToVS
% % 			    ok_JI}}
% 			  JIPitch
% 		       end
		    end
   ]}


LilyHeader 
= {Out.listToLines
   ["\\layout {"
    "\\context {"
    "\\Voice \\remove Note_heads_engraver"
    "\\remove Forbid_line_break_engraver"
    "\\consists Completion_heads_engraver"
    "}" 
%     "\\context {"
%     "\\Staff \remove Time_signature_engraver"
%     "}"
    "} "
    Segs.out.unmeteredMusic_LilyHeader
   ]}


	     
%% Explorer output 
proc {RenderCsoundAndLilypond I X}
   if {Score.isScoreObject X}
   then 
      FileName = "Test-"#I#"-"#{GUtils.getCounterAndIncr}
   in
      {Out.renderAndPlayCsound X
       unit(file: FileName)} 
      {ET22.out.renderAndShowLilypond X
       unit(file: FileName
	    wrapper: [LilyHeader 
		      "\n}\n}"]
	   )}
   end
end
proc {RenderCsoundAndLilypond_AdaptiveJI I X}
   if {Score.isScoreObject X}
   then 
      FileName = "test-"#I#"-"#{GUtils.getCounterAndIncr}#"-adaptiveJI"
   in
      {Out.renderAndPlayCsound X
       unit(file: FileName
	    event2CsoundFn: EventToCsound_adaptiveJI
	   )}
      {ET22.out.renderAndShowLilypond X
       unit(file: FileName
	    lowerMarkupMakers: [%HS.out.makeAdaptiveJI_Marker
				HS.out.makeAdaptiveJI2_Marker
				HS.out.makeChordComment_Markup
				HS.out.makeScaleComment_Markup]
	    wrapper: [LilyHeader 
		      "\n}\n}"]
	   )}
   end
end
{Explorer.object
 add(information RenderCsoundAndLilypond_AdaptiveJI
     label: 'to Csound + Lily : 22 ET (adaptive JI)')}
{Explorer.object
 add(information RenderCsoundAndLilypond
     label: 'to Csound + Lily: 22 ET')}






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Distro
%%

fun {ParameterFilterTest X}
   %% Filter out container parameters, measure parameters, time points and note pitches. 
   {Not {{X getItem($)} isContainer($)}} andthen
%    {Not {Measure.isUniformMeasures {X getItem($)}}} andthen
   {Not {X isTimePoint($)}} andthen
   {Not
    {X isPitch($)} andthen
    (%% root can be smaller domain than transposition (restricted to pitch classes), so FF would determine that.
     %% However, determining root results in poor propagation for index (because it determined transposed root, not root)
     {X hasThisInfo($ root)} orelse
%      {X hasThisInfo($ transposition)} orelse 
     {X hasThisInfo($ untransposedRoot)} orelse
     {X hasThisInfo($ notePitch)})}
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





