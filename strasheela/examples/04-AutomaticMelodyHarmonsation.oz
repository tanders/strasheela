
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
%% Module linking: link all Strasheela modules are loaded as
%% demonstrated in the template init file ../_ozrc
%%
%% Additionally, this example makes use of auxiliary definitions defined in
%% ./AuxDefs/AuxDefs.ozf.  To link the functor with auxiliary
%% definition of this file: within OPI (i.e. emacs) start Oz from
%% within this buffer (e.g. by C-. b). This sets the current working
%% directory to the directory of the buffer.
declare
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs/AuxDefs.ozf.bin']}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% This example creates a harmony progression which accompanies a
%% given melody such as a folk tune. In this CSP, voicing is
%% irrelevant: only chord 'symbols' are search for here (still, the
%% voicing could be addressed adeaquatly by extending the CSP).
%%
%% The harmonic rhythm in this example is slower than the rhythm of
%% the melody (e.g. one chord per bar). Therefore, the CSP allows for
%% non-harmonic notes (e.g. passing notes).
%%
%%
%% Music Representation
%%
%% The melody is expressed by sequences of notes (i.e. contained in a
%% sequential container). The note pitches and durations of the melody
%% are given in some simple list [Dur1#Pitch1 ... DurN#PitchN] which
%% is then transformed into the OOP representation (a sequences of
%% notes).
%%
%% The chord progression is expressed by a sequences of chord objects
%% (see doc of HS contribution: ../contributions/anders/HarmonisedScore/doc),
%% also in a sequential container. For simplicity, all chords are of
%% equal duration. This defines quasi a `grid' for the harmonic
%% rhythm. Longer chords are simply expressed by repeating the chord
%% (i.e. chord repetitions are interpreted as prolongation of
%% preceeding chord).
%%
%% Both both sequential containers (melody and chord progression) run
%% in parallel in a simultaneous container such that for each note
%% there exists a simultaneous chord object.
%%
%%
%% Chord Database 
%%
%% The set of possible chords (i.e. what is contained in the chord
%% database, see doc of HS contribution) are (i) major triad, (ii)
%% minor triad, and (iii) dominant seventh (i.e. major triad plus
%% minor seventh). These chords can be transposed.
%%
%%
%% Melodic Rules
%%
%% All note pitch classes are diatonic pitches (all notes are simply
%% constrained to be in C-major, for a more sophisticated model see
%% the scale object in HS).
%%
%% The pitch class of (most) melody notes are a member of the pitch
%% class set of the chord which is simultaneous to the note
%% (i.e. these pitches are harmonic pitches).
%%
%% Some non-harmonic note cases are permitted which must meet specific
%% conditions. These permitted exceptions are (i) passing note and
%% (ii) auxiliary note (the HS doc explains how this is modeled).
%%
%%
%% Harmonic Rules
%%
%% The harmony rule borrow from Schoenberg [1911]. 
%%
%% All chord pitch classes are restricted to diatonic pitches (again,
%% all notes constrained to be in C-major, but a more sophisticated
%% model could use the scale object).
%%
%% The chord progression starts and ends with the same chord. This
%% rule ensures that the model finds the tonic by itself
%% (consequently, the melody must start and end with the tonic).
%%
%% A seventh chord must be resolved by a `fourth upwards the
%% fundament' (e.g. V^7, I). Schoenberg introduces this progression as
%% the simplest resolution form for seventh chords.
%%
%% All neighbouring chords share at least one common pitch class. This
%% rule stems from the preliminary rule set of Schoenberg
%% [1911]. Schoenberg calls this notion `harmonic band' (later, he
%% refines this rule by introducing the notion of (i) ascending, (ii)
%% descending progressions, and (iii) superstrong progression and
%% proposes instructions to treat each progression adequately).
%%   
%%
%% Discussion
%%
%% Again, the example is kept simple for brevity (e.g. only an early
%% model of Schoenberg [1911] and only a few non-harmonic note cases
%% are implemented). Therefore, this CSP works well for some melodies
%% and less good for others. These are the primary limitations cause
%% by the simplification.
%%
%%  * The melody must not use any accidential. For instance, the
%%  melody is in C-major or a-minor, and does not modulate.
%%
%%  * The melody must start and end with the tonic.
%%
%%  * The harmonic rhythm of the melody must fit the harmonic rhythm
%%  specified for the CSP (the harmonic rhythm of the melody can be
%%  slower as chord repetitions are permitted)
%%
%%  * The non-harmonic pitches of the melody must fit the cases
%%  defined. For instance, non-harmonic notes can not be repeated and
%%  different non-harmonic notes can not follow each other (i.e. there
%%  can be no figuration containing multiple non-harmonic notes in
%%  sequence).
%%
%%  * The resulting chord progression ignores the formal structure of
%%  a melody. For instance, no information on phrases or cadencing is
%%  given to the CSP nor does the CSP attempt to retrieve such
%%  information by analysis.
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Top-level definition (a parameterised constraint script)
%%

/** %% AutomaticHarmonisation returns the script of a automatic harmonisation CSP for a diatonic melody. CSP creates a diatonic chord progression with a single chord per ChordDur (chords may be repeated).
%% A few simple rules on chord progression (inspired by the simplified rule set at the beginning of Schoenberg's Theory of Harmony) prefer 'reasonable' solutions: (i) start and end with the same chord (i.e. tonique). (ii) only chord neighbours with 'harmonic band' (which also allows for repetitions). (iii) seventh chords are resolved (the root skips a fourth upwards).
%% MelodyNoteDurPitchPairs introduces a very simple textual music representation. MelodyNoteDurPitchPairs specifies the melody as a list of the form [Dur1#Pitch1 .. DurN#PitchN]. ChordDur (an integer) defines the Duration of each chord (which must remain constant throughout the piece but chord repetitions are permitted).
%% Only very few and simple cases for non-harmonic pitches in the melody are permitted: auxiliary notes and passing notes with are preceeded and followed by chord pitches.
%% NB: This simple example rule set only produces results for suitable melodies. For example, the rule enforcing a 'harmonic band' band may be too strict for certain cases (i.e. no solution may be possible) but this rule is an important device to improve the solution quality considerably in many cases.
%% */
fun {AutomaticHarmonisation MelodyNoteDurPitchPairs ChordDur}
   proc {$ MyScore}
      FullDur = {LUtils.accum {Map MelodyNoteDurPitchPairs
			       fun {$ Dur#_/*Pitch*/} Dur end}
		 Number.'+'}
      ChordNr = FullDur div ChordDur
      %% default scale DB: C major scale
      MyScale = {Score.makeScore2 scale(index:1 transposition:0
					startTime:0 duration:0 %% !!??
				       )
		 Aux.myCreators}
      proc {GetMyScale Self Scales} Scales = [MyScale] end
      MyChordSeq = {Score.makeScore2
		    seq(items:{LUtils.collectN ChordNr
			       fun {$}
				  diatonicChord(duration:ChordDur
						inScaleB:1
						getScales:GetMyScale)
			       end})
		    %% Aux.myCreators contains score object
		    %% constructurs (classes and functions) customised
		    %% for harmonic CSPs. See their definition in
		    %% ../AuxDefs/AuxDefs.oz
		    Aux.myCreators}
      MyVoice = {Score.makeScore2 
		 seq(items:{Map MelodyNoteDurPitchPairs
			    fun {$ Dur#Pitch}
			       note(duration:Dur
				    pitch:Pitch
				    inChordB:{FD.int 0#1}
				    inScaleB:1
				    getScales:GetMyScale) 
			    end})
		 Aux.myCreators}
      MyChords 
   in
      MyScore = {Score.makeScore
		 sim(items:[MyVoice
			    MyChordSeq]
		     startTime:0
		     timeUnit:beats(1))
		 Aux.myCreators}
      MyChords = {MyChordSeq getItems($)}
      %%
      %% Rule applications
      %%
      %% non-harmonic pitches may be passing notes and auxiliaries
      {MyVoice
       forAllItems(proc {$ MyNote}
		      %% The note method nonChordPCConditions expects
		      %% a list of reified rules which define allowed
		      %% non-harmonic note cases (see HS doc). To
		      %% support additional exceptions (e.g. to allow
		      %% for suspensions) just extend this list.
		      %%
		      %% Test different non-harmonic pitch rules:
		      %% (Aux.resolveStepwiseR is very simple alternative)
		      {MyNote nonChordPCConditions([IsPassingNoteR
						    IsAuxiliaryR])} 
		   end)}
      %%
      %% constrain chord progression
      {HS.rules.neighboursWithCommonPCs MyChords}
      %% chord progression starts and ends with tonic
      {MyChords.1 getRoot($)} = {{List.last MyChords} getRoot($)}
      {Pattern.for2Neighbours MyChords
       proc {$ Chord1 Chord2}
	  %% in case Chord1 are Chord2 distinct (i.e. no chord
	  %% repretition occurs), then apply additional constraint to
	  %% resolve seventh chord
	  {FD.impl {HS.rules.distinctR Chord1 Chord2}
	   {ResolvedSeventhR Chord1 Chord2}
	   1}
       end}
      %% redundant constraint which considerably reduces the search
      %% space. For isntance, for all solutions of first example below
      %% number of fails goes down by 50 percent (constraint requires
      %% scale to be C major).
      {ForAll MyChords RedundantV7Constraint}
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Setting the chord database
%%

%% NB: the scale database defaults to major and minor scale as
%% required.
{HS.db.setDB
 unit(chordDB: chords(chord(pitchClasses:[0 4 7] 
			    roots:[0]
			    comment:major)
		      chord(pitchClasses:[0 4 7 10] % seventh added  10
			    roots:[0]
			    comment:"major with minor 7")
		      chord(pitchClasses:[0 3 7]
			    %% according to Schoenberg the root of a
			    %% minor chord is 0 (other authors propose
			    %% [7], but then I need to change other
			    %% rules as well).
			    roots:[0] 
			    comment:minor)))}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Rule definitions
%%

local
   /** %% Index of a major chord with minor seventh is 2 in the chord DB above.
   %% */
   MajorWithMajorSeventhIndex = 2
in
   /** %% Simplified case: in this example, the only possible seventh chord is a major chord with minor seventh, which is recognised by its index.
   %% */
   proc {IsSeventhChord MyChord B}
      B = ({MyChord getIndex($)} =: MajorWithMajorSeventhIndex)
   end
   /** %% Redundant rule to enforce propagation: in C major, a major chord with minor seventh can only be G7 (i.e. transposition=7).
   %% */
   proc {RedundantV7Constraint MyChord}
      {FD.impl ({MyChord getIndex($)} =: MajorWithMajorSeventhIndex)
       ({MyChord getTransposition($)} =: 7)
       1}
   end
end
/** %% B=1 <-> in case Chord1 is a seventh chord, then adequately resolve (fourth skip upwards) into Chord2. (Rule by Schoenberg's Theory of Harmony, in more simple rule set for beginner)
%% */
proc {ResolvedSeventhR Chord1 Chord2 B}
   RootsInterval = {HS.db.makePitchClassFDInt}
in
   {HS.score.transposePC {Chord1 getRoot($)} RootsInterval {Chord2 getRoot($)}}
   B = {FD.int 0#1}
   B = {FD.impl {IsSeventhChord Chord1}
	 (RootsInterval =: 5)}
end
/** %% The passing note (defined by HS.rules.isPassingNoteR) is situated between chord pitches.
%% */
proc {IsPassingNoteR Note B}
   B = {FD.conj 
	{HS.rules.isPassingNoteR Note unit}
	{HS.rules.isBetweenChordNotesR Note unit}}
end
/** %% The auxiliary note (defined by HS.rules.isAuxiliaryR) is situated between chord pitches.
%% */
proc {IsAuxiliaryR Note B}
   B = {FD.conj 
	{HS.rules.isAuxiliaryR Note unit}
	{HS.rules.isBetweenChordNotesR Note unit}}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Customising the Oz Explorer (adding a new output format)
%%

%%
%% Define a new Explorer information action for Lilypond output which
%% prints information on the chord progression. Select this
%% information action in the Explorer Nodes menu to become
%% effective. Please read the documentation of Lilypond output to
%% understand this definition.
%%


/** %% Returns unary function expecting chord. Lilyout: Outputs single root note and all added signs returned by MakeAddedSigns (unary fun expecting chord and returing articulations etc added to the root note)
%% */
%% !! bug: skips offsetTime before X
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
/** %% 
%% */
%%
%% !!?? NB: this def causes Lilypond parse error on some machines but not on others: could it be that this def only works for old Lily version 2.4?
%% similar problems occur with Lily output defs in OZRC...
proc {RenderLilypondForHS I X}
   if {Score.isScoreObject X}
   then 
      FileName = out#{GUtils.getCounterAndIncr}
   in
      %% NB: on Mac with new Lily, pdf is shown automatically after
      %% rendering (i.e. Out.renderAndShowLilypond could be replaced
      %% by Out.renderLilypond.
      {Out.renderAndShowLilypond X
       unit(file: FileName#'-'#I
	    clauses:[%% define chord output which prints the chord
                     %% root as pitch and the comment of the chord
                     %% database to provide further information
		     HS.score.isChord
		     #{MakeChordToLily
		       fun {$ MyChord}	    
			  RootMicroPitch = {Out.lilyMakeMicroPitch
					    {MyChord getRootParameter($)}}
			  ChordComment
			    = {HS.db.getInternalChordDB}.comment.{MyChord getIndex($)}
			  ChordDescr = if {IsRecord ChordComment}
					  andthen {HasFeature ChordComment
						   comment}
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
		    ])}
   end
end
{Explorer.object
 add(information RenderLilypondForHS
     label: 'to Lilypond (HS: show chord roots with comments)')}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Calling the solver
%%

/*

%% simple melody with two solution chord progressions (with determined scale and no seventh chord)
%% ?? 4 solutions, in case V7 is permitted (V either with or without seventh)
%% ?? there are only 2 solutions now -- which seems to be correct..
%%
%% NB: Use the explorer output action 'to Lilypond (HS: show chord roots with comments)' (defined above)
{SDistro.exploreOne
 {AutomaticHarmonisation [3#60 1#62   2#64 1#62 1#60   3#59 1#62   4#60] 4}
 {Adjoin Aux.myDistribution
 unit(value:mid)}}


%% 'Horch was kommt von draussen rein' (first four measures): there
%% are 4 solutions in total -- seems to be correct.
{SDistro.exploreOne
 {AutomaticHarmonisation
  %% line per measure
  [1#60 1#62 1#64 1#65
   1#67 1#69 2#67
   1#65 1#62 2#71
   1#67 1#64 2#72]
  4}
 Aux.myDistribution}


%% 'Horch was kommt von draussen rein' (full melody)
{SDistro.exploreOne
 {AutomaticHarmonisation
  %% line per measure
  [1#60 1#62 1#64 1#65
   1#67 1#69 2#67
   1#65 1#62 2#71
   1#67 1#64 2#72
   %% repetition of four measures skipped..
   1#60 1#62 1#64 1#65
   1#67 1#69 2#67
   1#65 1#62 1#71 1#74
   4#72
   %%
   2#69 2#69			% geht vor-
   2#72 1#71 1#69		% bei und 
   2#67 2#64			% schaut nicht
   4#67				% rein
   2#65 2#62			% hola
   4#71				% hi
   2#67 2#64			% hola
   4#72				% ho
   %% repetition skipped
   2#69 2#69			% wirds wohl
   2#72 1#71 1#69		% nicht ge-
   2#67 2#64			% wesen
   4#67				% sein
   2#65 2#62			% hola 
   2#71 2#74			% hia
   4#72				% ho   
  ]
  4}
 Aux.myDistribution}


*/




%%
%% Issues / Questions:
%%
%%  * two dissonances following each other causes trouble!
%%
%%  * F and G7 have common pitch.. but that is indeed a reasonable progression!
%%
%%  * ?? best solution: maximise number of distinct chords?
%%

