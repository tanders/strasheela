
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
%% ** HOW TO USE THIS EXAMPLE? **
%%
%% First feed the whole buffer. Then scroll down to the section 'Call
%% solver' (wrapped in a block comment to prevent unintended feeding)
%% and feed the examples one by one.
%%

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

%% for easy creation of doc output
% OutDir = {OS.getCWD}#"/Output/"
%% tmp
% OutDir = "/home/t/oz/music/Strasheela/private/examples/Standard-Examples-Output/07-Harmonised-L-system/"


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% ** EXAMPLE DESCRIPTION **
%%
%%
%% This example demonstrates how constraint-based algorithmic composition can be combined with 'classical' deterministic algorithmic composition techniques. 
%%
%% In this example, the global form of the music is created with an Lindenmayer system (L-system, [Prusinkiewicz and Lindenmayer, 1990]), a popular algorithmic composition techniques (cf. the rewrite pattern in Common Music). The  L-system generates a sequence of motifs specifications. Details of the music, on the other hand (e.g. the actual pitches of the motifs), are generated by constraint programming.
%%
%% The L-system generates a textual representation for the Strasheela music representation. This textual representation is used to defined the CSP. An L-system generates a sequence of symbols, where each symbol can have further parameters (cf. [Prusinkiewicz and Lindenmayer, 1990]). In this example, the symbol sequence denotes the order of motifs. Symbol parameters denote further arguments for the motif creation. In the CSP, each motif symbol is transformed into a small sub-CSP (encapsulated in its own function) which creates the music representation for this motif and applies a few constraints. For instance, one motif symbol is 'run', which is transformed into a short run (a sequence of notes forming a short scale gesture). However, each sub-CSP is integrated into the whole CSP which applies further constraints on the motifs. E.g. the whole CSP creates also a harmonic progression for the music and constraints the motifs to express its underlying harmonies. 
%%

%% [!! outdated doc, def now more general] The music representation consists in a sequence of motifs with a sequence of chords running in parallel (links between score items and chords created implicitly -- see constructors in Aux defs). 

/*
sim(items:[seq(items:Motifs)
	   ChordSeq]
   )
*/

%% The variable Motifs denotes a list of motifs. Each motif is either a monophonic note sequence or some more complex musical segment. The list of motif declarations is created by an L-system. The constructor of each motif is denoted by its label and this constructor expects a few additional motif attributes (e.g. n = number of motif notes). The L-system creates the motif labels and these attributes.
%%
%% Each motif constructor determines some aspects of its motif and constraints others (e.g. number of notes in motif and the rhythmic structure is determined and pitch contour is constrained).
%%
%% A few additional constraints are applied:
%%
%% * All motif note pitches are either chord notes, or fulfill additional conditions (e.g. passing notes [how to define this for polyphonic motifs?])
%%
%% * The harmonic progression follows some simple rules 
%%
%% * Some motifs start a new chord. Such motifs are explicitly marked. 
%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Setting the database.  
%%
%% (these setting allow for the easy creation of microtonal variants of this example)
%%


PitchesPer100Cent = 1
PitchesPerOctave = 12 * PitchesPer100Cent
%% NB: in case PitchesPer100Cent changes, these databases must be adapted as well
{HS.db.setDB unit(chordDB:HS.dbs.jazz.vierklaenge
		  intervalDB:HS.dbs.default.intervals
		  pitchesPerOctave:PitchesPerOctave
		  scaleDB:HS.dbs.default.scales)}

%% NB: these code fragments depend on this database setting (i.e. they may require adaptation in case the database is change):
%%
%% * MakeChordInCMajor (expects first scale in DB to be major)
%%
%% * ChordSeqRules (expects first chord in DB to be major with major 7)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Top-level definition 
%%

/** %% HarmoniseScore expects a list of motif specs (e.g. created with the L-system) and the record of creator functions for these motifs (cf. the creator argument of Score.makeScore). HarmoniseScore returns the CSP script for the harmonised motif sequence. 
%% */
%%
%% !! TODO: I could generalise this definition as a variant of HS.score.harmoniseScore expecting a textual score spec and a boolean function which returns true for all textual score objects which start with a new chord.
fun {HarmoniseScore ScoreSpec MotifCreators}
   fun {IsStartingWithChord X}
      {IsRecord X} andthen {Not {IsList X}} andthen 
      {HasFeature X isStartingWithChord}
   end
in
   proc {$ FullScore}
      %% add feat handle to each item which is starting with with a chord
      FullScoreSpecs = {MapRecursively ScoreSpec
			fun {$ X}
			   if {IsStartingWithChord X}
			   then {Adjoin unit(handle:_) X}
			   else X
			   end
			end}
      %% Create sequence of motifs: each record in MotifSpecs is
      %% transformed into a score object by calling the matching motif
      %% creator functions with the motif spec as argument.
      MyScore = {Score.makeScore2 {Adjoin % provide defaults 
				    seq(info:mainScore
					startTime:0 
					timeUnit:beats(16))
				    FullScoreSpecs}
		  {Adjoin Aux.myCreators MotifCreators}}
      %% collect all items starting with chord via their handle
      ItemsStartingWithChord = {Map {FilterRecursively FullScoreSpecs
				     IsStartingWithChord}
				fun {$ Spec} Spec.handle end}
      ChordSeq
   in
      %% create full score (extends MotifSeq by chord progression and
      %% constrains the note pitches in MotifSeq to express the chords
      %% of this progression)
      FullScore = {HS.score.harmoniseScore MyScore ItemsStartingWithChord
		   unit(chord:MakeChordInCMajor) ChordSeq}
      %%
      {ChordSeqRules ChordSeq}
   end
end 

% /** %% HarmoniseMotifSeq expects a list of motif specs (e.g. created with the L-system) and the record of creator functions for these motifs (cf. the creator argument of Score.makeScore). HarmoniseMotifSeq returns the CSP script for the harmonised motif sequence. 
% %% */
% fun {HarmoniseMotifSeq MotifSpecs MotifCreators}
%    proc {$ FullScore}
%       %% add feat handle to each item which is starting with with a chord
%       FullMotifSpecs = {Map MotifSpecs fun {$ X}
% 					if {HasFeature X isStartingWithChord}
% 					then {Adjoin unit(handle:_) X}
% 					else X
% 					end
% 				       end}
%       %% Create sequence of motifs: each record in MotifSpecs is
%       %% transformed into a score object by calling the matching motif
%       %% creator functions with the motif spec as argument.
%       MotifSeq = {Score.makeScore2 seq(info:motifSeq
% 				       items:FullMotifSpecs
% 				       startTime:0
% 				       timeUnit:beats(16))
% 		  {Adjoin Aux.myCreators MotifCreators}}
%       %% collect all items starting with chord via their handle
%       ItemsStartingWithChord = {Map {Filter FullMotifSpecs
% 				     fun {$ X}
% 					{HasFeature X isStartingWithChord}
% 				     end}
% 				fun {$ Spec} Spec.handle end}
%       ChordSeq
%    in
%       %% create full score (extends MotifSeq by chord progression and
%       %% constrains the note pitches in MotifSeq to express the chords
%       %% of this progression)
%       FullScore = {HS.score.harmoniseScore MotifSeq ItemsStartingWithChord
% 		   unit(chord:MakeChordInCMajor) ChordSeq}
%       %%
%       {ChordSeqRules ChordSeq}
%    end
% end

%%
%% Aux defs
%%

fun {FilterRecursively X F}
   fun {Process X} if {F X} then [X] else nil end end
in
   %% atom is also a record, so check that first..
   if {IsAtom X} then {Process X}
   elseif {IsList X} then {Append
			   {Process X}
			   {LUtils.mappend X
			    fun {$ Y} {FilterRecursively Y F} end}}
   elseif {IsRecord X} then {Append
			     {Process X}
			     {LUtils.mappend {Record.toList X}
			      fun {$ Y} {FilterRecursively Y F} end}}
      %% otherwise
   else {Process X}
   end
end


fun {MapRecursively X F}
   %% atom is also a record, so check that first..
   if {IsAtom X} then {F X}
   elseif {IsList X} then {F {List.map X fun {$ Y} {MapRecursively Y F} end}}
   elseif {IsRecord X} then {F {Record.map X fun {$ Y} {MapRecursively Y F} end}}
      %% otherwise
   else {F X}
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Three motif definitions: MakeRun, MakeChordRepetition, and MakeArpeggio.
%%
%% Each function returns a motif (a small CSP, encapsulated a container). The returned motif is not fully initialised (and thus can be used to compose a larger score).
%%


/** %% Returns a motif (a seq with a few notes) which forms a short run. The motif is shaped by a few implicit constraints. Non-harmonic notes in the run must be passing notes, but are otherwise arbitrary pitches (i.e. not necessarily scale notes). 
%%
%% NB: The argument Args is ignored and only included for a uniform interface of all motif generators. Confer the definition of MakeArpeggio below to see how to implement a motif constructor that understands various arguments including any feature of the sequential container embracing the motif.
%% */
%% !!?? Bug: IsPassingNoteR does not work?
%%
proc {MakeRun Args MyMotif}
   Default = unit(n:5
		  direction: '<:' % relation to predecessor pitch within motif
		  averageInterval: 4*PitchesPer100Cent % between pitches
		  nonChordPCConditions:[IsPassingNoteR]
		  noteArgs: note(duration:4
				 %% each constrained var must be unique,
				 %% therefore encapsulated in fun
				 inChordB:fun {$} {FD.int 0#1} end))
   Settings = {Adjoin Default Args}
   %% A passing note situated between chord pitches.
   proc {IsPassingNoteR Note B}
      B = {FD.conj 
	   {HS.rules.isPassingNoteR Note unit(maxStep:2)}
	   {HS.rules.isBetweenChordNotesR Note unit}}
   end
in   
   %% score creation
   MyMotif = {Score.makeScore2
	      %% adjoin, so any feature of the seq (e.g. handle) can
	      %% be given via Args
	      {Adjoin {Record.subtractList Settings
		       [n direction averageInterval nonChordPCConditions noteArgs isStartingWithChord]}
	       seq(info:run
		   items:{LUtils.collectN Settings.n
			  fun {$} {MakeNote Settings.noteArgs} end})}
	      Aux.myCreators}
   %%
   %% rules (rule application is delayed until score is fully
   %% initialised)
   %%
   thread 			
      Pitches = {MyMotif mapItems($ getPitch)}
   in
      %% contour
      {Pattern.continuous Pitches Settings.direction}
      %% span
      {FD.distance Pitches.1 {List.last Pitches} '=<:'
       Settings.averageInterval * Settings.n}
      %% non-harmonic pitches
      {MyMotif forAllItems(proc {$ X}
			      {X nonChordPCConditions(Settings.nonChordPCConditions)}
			   end)}
   end
end 


/* 
%% Test motif

%% call explorer 
{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {Score.makeScore
	       sim(items:[{MakeRun unit}
			  chord(% (motif n * motif note duration)
				duration:5*4 
				index:1
				transposition:0)]
		   startTime:0
		   timeUnit:beats(16))
	       Aux.myCreators}
 end
 unit(order:size value:mid)}

*/

%%%%%%%

/** %% Returns a motif (a seq of sims with a few notes) which consists of repeated chord.
%% Disambiguity information: here 'chord' does not mean an analytic chord (as represented by the HS.score.chord class), but an actually sounding simultaneous group of notes.
%%
%% NB: The argument Args is ignored and only included for a uniform interface of all motif generators. 
%% */
proc {MakeChordRepetition Args MyMotif}
   %% argument processing
   Defaults = unit(%% No. of chords
		   n:3		
		   %% No. of notes per chord (NB: chords in DB must
		   %% have this number of notes)
		   chordN:4	
		   %% chord pitch range (something between 1 or 2 octaves)
		   widthDomain:12*PitchesPer100Cent#24*PitchesPer100Cent
		   noteArgs:note(duration:12 
				 inChordB:1))
   Settings = {Adjoin Defaults Args}
in
   %% score creation
   MyMotif = {Score.makeScore2
	      %% adjoin, so any feature of the seq (e.g. handle) can
	      %% be given via Args
	      {Adjoin {Record.subtractList Settings
		       [n chordN widthDomain noteArgs isStartingWithChord]}
	       seq(info:akkRepetition
		   items:{LUtils.collectN Settings.n
			  %% create Settings.n sims
			  fun {$}
			     sim(items:{LUtils.collectN Settings.chordN
					%% create Settings.chordN notes per sim
					fun {$} {MakeNote Settings.noteArgs}  end})
			  end})}
	      Aux.myCreators}
   %%
   %% rules (delayed until score is fully initialised)
   %%
   thread 
      PitchLists = {MyMotif mapItems($ fun {$ Chord} {Chord mapItems($ getPitch)} end)}
      PCLists = {MyMotif mapItems($ fun {$ Chord} {Chord mapItems($ getPitchClass)} end)}
   in
      %% all note PC in a single chord are distinct (constraining the
      %% first chord sufficient, as all chords are equal)
      {FD.distinct PCLists.1}
      %% repeated chords: equal PitchLists 
      {ForAll {LUtils.matTrans PitchLists} Pattern.allEqual}
      %% pitch range
      {ForAll PitchLists
       proc {$ Pitches}
	  Width = {FD.int Settings.widthDomain}
       in
	  %% range of whole chord
	  {FD.distance Pitches.1 {List.last Pitches} '=:' Width}
	  %% intervals between chord notes (notes in ascending order)
	  %% is decreasing: 'wellformed' chord
	  {Pattern.decreasing
	   {Pattern.map2Neighbours Pitches proc {$ Pitch1 Pitch2 Interval}
					      Interval = {FD.decl}
					      Pitch2 - Pitch1 =: Interval
					   end}}
       end}
   end
end


/* 
%% Test motif

{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {Score.makeScore
	       sim(items:[{MakeChordRepetition unit}
			  chord(% (motif n * motif note duration)
				duration:3*12
				index:1
				transposition:0)]
		   startTime:0
		   timeUnit:beats(16))
	       Aux.myCreators}
 end
 unit(order:size value:mid)}

*/

%%%%%%%%%


/** %%  Returns a motif (a seq with a few notes) which forms an arpeggio. Neighbouring arpeggio motifs are constrained such that the first note of the second motif is higher, but neverhteless the distance of the first notes of both motifs major is a third at maximum.
%%
%% MakeArpeggio expects a few arguments which are later created by a parameterised L-system, such (e.g. n, direction). Args also supports all features which are supported by its embracing sequential container (e.g. handle). 
%% In case Args contains the feature isStartingWithChord, then the motif starts with a new analytic chord (which is created by the function HS.score.harmoniseScore, called in the top-level definition). 
%% */ 
proc {MakeArpeggio Args MyMotif}
   Default = unit(n:3		% No. of motif notes
		  direction:'>:' % relation to predecessor
		  averageInterval:4*PitchesPer100Cent
		  noteArgs:note(duration:8
				inChordB:1))
   Settings = {Adjoin Default Args}
in
   %% score creation
   MyMotif = {Score.makeScore2
	      %% adjoin, so any feature of the seq (e.g. handle) can
	      %% be given via Args
	      {Adjoin {Record.subtractList Settings
		       [n direction averageInterval noteArgs isStartingWithChord]}
	       seq(info:arpeggio
		   items:{LUtils.collectN Settings.n
			  fun {$} {MakeNote Settings.noteArgs} end})}
	      Aux.myCreators}
   %%
   %% rules
   %%
   thread
      Pitches = {MyMotif mapItems($ getPitch)}
   in
      %% contour
      {Pattern.continuous Pitches Settings.direction}
      %% ambitus
      {FD.distance Pitches.1 {List.last Pitches} '=<:'
       Settings.averageInterval * Settings.n}
      %% constrain relation to predecessor arpeggio motif
      {ConstrainFirstNotePitchesOfArpeggio MyMotif}
   end
end 


/* 
%% Test motif

{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {Score.makeScore
	       sim(items:[{MakeArpeggio unit}
			  chord(% (motif n * motif note duration)
				duration:3*8
				index:1
				transposition:0)]
		   startTime:0
		   timeUnit:beats(16))
	       Aux.myCreators}
 end
 unit(order:size value:mid)}

%%

%% object already accessible via handle before score is fully initialised
declare
MySpec = arpeggio(handle:_)
MyScore = {Score.makeScore2 MySpec unit(arpeggio:MakeArpeggio)}

{Browse MySpec.handle}

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Global form definition with L-system 
%%

/** %% Returns a list of textually represented motif sequences which are internally created by an L-system. The arg n indicates the L-system generation returned.
%% The arg axiom is the first pattern period. The arg rules is a record of symbol transformation specifications. A record features matches a symbol to transform (i.e. the label of a record in the motif sequence). The corresponding feature value is a unary function expecting the current record and returning a list of symbols which replace the record in the next generation.     
%%
%% Per default, this L-system uses three symbols (arpeggio, chordRepetition, run), where each symbol denotes a specific motif. 
%% */
%%
fun {MyLSystemMotifs Args}
   Default = unit(n:1
		  %% The axiom of the L-system (i.e. the 1st generation).
		  axiom: [arpeggio(n:2 direction:'>:' isStartingWithChord:unit)
			  chordRepetition]
		  rules: unit(arpeggio: fun {$ R}
					   [arpeggio(n:R.n+1
						     direction:R.direction
						     isStartingWithChord:unit)
					    arpeggio(n:{Max R.n-1 2}
						     direction:R.direction)
					    chordRepetition]
					end
			      chordRepetition: fun {$ R}
						  [run
						   arpeggio(n:2
							    direction:'>:'
							    isStartingWithChord:unit)]
					       end
			      run:  fun {$ R}
				       [arpeggio(n:2
						 direction:'<:')]
				    end))
   Settings = {Adjoin Default Args}
in
   %% Each L-system generation is terminated by the symbol '|'. The function Pattern.makeLSystem all N generations in a single list. The symbol '|' at the end of each generation with is then used for a generation-wise splitting in order to return only the last generation.
   {List.last
    {LUtils.split
     {Pattern.makeLSystem {Append Settings.axiom ['|']} Settings.n
      fun {$ R}
	 L = {Label R}
      in
	 if {HasFeature Settings.rules L}
	 then {Settings.rules.L R}
	    %% otherwise rule (for '|') 
	 else [R]
	 end
      end}
     '|'}}
end

%%
%% old def
%%
% fun {MyLSystemMotifs Args}
%    Default = unit(n:1
% 		  %% The axiom of the L-system (i.e. the 1st generation).
% 		  axiom: [arpeggio(n:2 direction:'>:' isStartingWithChord:unit)
% 			  chordRepetition])
%    Settings = {Adjoin Default Args}
% in
%    %% Each L-system generation is terminated by the symbol '|'. The function Pattern.makeLSystem all N generations in a single list. The symbol '|' at the end of each generation with is then used for a generation-wise splitting in order to return only the last generation.
%    {List.last
%     {LUtils.split
%      {Pattern.makeLSystem {Append Settings.axiom ['|']} Settings.n
%       fun {$ R}
% 	 L = {Label R}
%       in
% 	 case L
% 	    %% !!?? is there a case variant 
% 	 of arpeggio then [arpeggio(n:R.n+1
% 				    direction:R.direction
% 				    isStartingWithChord:unit)
% 			   arpeggio(n:{Max R.n-1 2}
% 				    direction:R.direction)
% 			   chordRepetition]
% 	 [] chordRepetition then [run
% 				  arpeggio(n:2
% 					   direction:'>:'
% 					   isStartingWithChord:unit)]
% 	 [] run then [arpeggio(n:2
% 			       direction:'<:')]
% 	    %% otherwise rule (for '|') 
% 	 else [R]			
% 	 end
%       end}
%      '|'}}
% end

/*
%% test: examine global form created by MyLSystemMotifs

%% test defaults (browse results)

{MyLSystemMotifs unit(n:2)}

{MyLSystemMotifs unit(n:4)}

%% specify new L system

{MyLSystemMotifs unit(n:7
		      axiom: [b]
		      rules: unit(a: fun {$ R} [a b] end
				  b: fun {$ R} [a] end))}


%% motif sequence can quickly become pretty long..
{Length {MyLSystemMotifs unit(n:5)}}

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Rules
%%

/** %% Constrain the harmonic progression. 
%% */
proc {ChordSeqRules ChordSeq}
   MyChords = {ChordSeq getItems($)}
in
   %% all neighbouring chords are connected by a 'harmonic band'
   {HS.rules.neighboursWithCommonPCs MyChords}
   %% chord progression starts and ends with tonic 
   {{MyChords.1 getScales($)}.1 getRoot($)} 
     = {MyChords.1 getRoot($)} = {{List.last MyChords} getRoot($)}
   %% neighbouring chords have different roots (if there are at least 3 chords)
   if {Length MyChords} > 2
   then {Pattern.for2Neighbours MyChords
	 proc {$ Chord1 Chord2} {Chord1 getRoot($)} \=: {Chord2 getRoot($)} end}
   end
   %% last chord major with major 7
   1 = {{List.last MyChords} getIndex($)}
end 


/** %% A rule applied to each arpeggio motif: 
%% if predecessor motif also arpeggio then 
%% - distance of the first notes of both motifs major third at max
%% - the first note of the second motif is higher that the first not of the first
%% */
proc {ConstrainFirstNotePitchesOfArpeggio MyMotif}
   if {MyMotif hasTemporalPredecessor($)} andthen
      {{MyMotif getTemporalPredecessor($)} hasThisInfo($ arpeggio)}
   then
      FirstPitch1 = {{MyMotif getTemporalPredecessor($)} mapItems($ getPitch)}.1
      FirstPitch2 = {MyMotif mapItems($ getPitch)}.1
   in
      FirstPitch1 <: FirstPitch2
      FirstPitch2 - FirstPitch1 <: 4*PitchesPer100Cent
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Auxiliary definitions
%%

/** %% Create full note spec 
%% */
fun {MakeNote NoteArgs}
   NoteDefault = note(pitch:fun {$}
			       {FD.int 48*PitchesPer100Cent#72*PitchesPer100Cent}
			    end)
in 
   {Adjoin {Record.map {Adjoin NoteDefault NoteArgs}
	    fun {$ X}
	       if {IsProcedure X}
	       then {X}
	       else X
	       end
	    end}
    note} % to ensure the correct label 'note'
end

local
   %% major scale set in chord DB at index 1, transposition=0 results in C major
   CMajorScale = {Score.makeScore2 scale(index:1 transposition:0
				     startTime:0 duration:0 %% !!??
				    )
	      Aux.myCreators}
in
   /** %% Returns a diatonic chord in C major.
   %% */
   fun {MakeChordInCMajor _/*Args*/}
      Settings = diatonicChord(inScaleB:1
			       getScales:proc {$ Self Scales} Scales = [CMajorScale] end
			       isRelatedScale:proc {$ Self Scale B} B=1 end)
   in
      {Score.makeScore2 Settings unit(diatonicChord:HS.score.diatonicChord)}
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% solver calls
%%

/*

%% set tempo (so far, this works only for sound output such as Csound and MIDI)
{Init.setTempo 85.0}


%% Harmonised handcoded sequence of motif specs together with the predefined motif creators MakeArpeggio, MakeChordRepetition, and MakeRun.
declare
MotifSeqSpec = [arpeggio(n:4
			 direction:'<:'
			 isStartingWithChord:unit)
		chordRepetition
		run
		arpeggio(n:2
			 direction:'>:')
		arpeggio(n:5
			 direction:'>:'
			 isStartingWithChord:unit)]
{SDistro.exploreOne
 {HarmoniseScore seq(items:MotifSeqSpec)
  unit(arpeggio:MakeArpeggio
       chordRepetition:MakeChordRepetition
       run:MakeRun)}
 Aux.myDistribution}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Harmonised handcoded sequence of motif specs together with a new motif creator MakeMyFreeMotif. 
declare
/** %% 'free' motif without any further constraints on the note pitches (except that they must be chord notes, as inChordB defaults to 1 in Aux.myCreators.note).
%% */
proc {MakeMyFreeMotif _/*Args*/ MyMotif}
   MyMotif = {Score.makeScore2
	      seq(info:freeMotif
		  items:[note(duration:4 pitch:{FD.int 48#72})
			 note(duration:4 pitch:{FD.int 48#72})
			 note(duration:4 pitch:{FD.int 48#72})
			 note(duration:4 pitch:{FD.int 48#72})])
	      Aux.myCreators}
   %%  Arbitrary further constraints can be added here...
end
proc {MakeMyFreeMotif2 Args MyMotif}
   Default = unit(n:4
		   noteDuration:4)
   Settings = {Adjoin Default Args}
in
   MyMotif = {Score.makeScore2
	      %% adjoin, so any feature of the seq (e.g. handle) can
	      %% be given via Args
	      {Adjoin {Record.subtractList Settings
		       [n noteDuration isStartingWithChord]}
	       seq(info:freeMotif
		   items: {LUtils.collectN Settings.n
			   fun {$}
			      note(duration:Settings.noteDuration
				   pitch:{FD.int 48#72})
			   end})}
	      Aux.myCreators}
end
MotifSeqSpec = [arpeggio(n:4
			 direction:'>:'
			 isStartingWithChord:unit)
		freeMotif
		arpeggio(n:2
			 direction:'<:')
		freeMotif
		arpeggio(n:5
			 direction:'>:'
			 isStartingWithChord:unit)]

%% solver call
{SDistro.exploreOne
 {HarmoniseScore seq(items:MotifSeqSpec)
  unit(arpeggio:MakeArpeggio
       freeMotif:MakeMyFreeMotif)}
 Aux.myDistribution}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Handcoded sequence of motif specs together with a new motif creator which creates a fixed motif.  
declare
%% NB: the notes of these motif are of class Score.note and not HS.score.note (i.e. instead of Aux.myCreators, the default creators of Score.makeScore2 are used). Thus, these notes do not support any chord-related attribute or functionality.
proc {MakeMyFixedMotif _/*Args*/ MyMotif}
   MyMotif = {Score.makeScore2
	      seq(info:fixedMotif
		  items:[note(duration:4
			      pitch:60)
			 note(duration:4
			      pitch:62)
			 note(duration:4
			      pitch:64)
			 note(duration:4
			      pitch:65)])
	      unit}
end
MotifSeqSpec = [arpeggio(n:4
			 direction:'>:'
			 isStartingWithChord:unit)
		fixedMotif
		arpeggio(n:2
			 direction:'<:')
		fixedMotif
		arpeggio(n:5
			 direction:'>:'
			 isStartingWithChord:unit)]
{SDistro.exploreOne
 {HarmoniseScore seq(items:MotifSeqSpec)
  unit(arpeggio:MakeArpeggio
       fixedMotif:MakeMyFixedMotif)}
 % unit(order:size value:mid)
 Aux.myDistribution}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Harmonised motif seq created by second L-system generation
{SDistro.exploreOne
 {HarmoniseScore seq(items:{MyLSystemMotifs unit(n:2)})
  unit(arpeggio:MakeArpeggio
       chordRepetition:MakeChordRepetition
       run:MakeRun)}
 % unit(order:size value:mid)
 Aux.myDistribution}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Harmonised motif seq created by the forth L-system generation (in reversed order): this examples needs a few seconds to finish (even on 3.1 GHz machine)
{SDistro.exploreOne
 {HarmoniseScore seq(items:{Reverse {MyLSystemMotifs unit(n:4)}})
  unit(arpeggio:MakeArpeggio
       chordRepetition:MakeChordRepetition
       run:MakeRun)}
 Aux.myDistribution}

%%
%% NB: a long motif seq results in a rather large score object. The search consumes much RAM, because this object is copied very often during the search process. For larger examples therefore consider recomputation (where memory is traded for computation time).
%%

%% The example above again, now with recomputation which needs less memery, but often needs more run time (see http://www.mozart-oz.org/documentation/explorer/node8.html#chapter.object)
{Explorer.object option(search search:5
			information:25
			failed:true)}
{SDistro.exploreOne
 {HarmoniseScore seq(items:{Reverse {MyLSystemMotifs unit(n:4)}})
  unit(arpeggio:MakeArpeggio
       chordRepetition:MakeChordRepetition
       run:MakeRun)}
 %% non-random distribution
 {Adjoin Aux.myDistribution unit(value:mid)}}


*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% create output for doc
%%

/*

%% MakeRun
declare
File = "07-Harmonised-L-system-ex1"
MySolution = {SDistro.searchOne
	      proc {$ MyScore}
		 MyScore = {Score.makeScore
			    sim(items:[{MakeRun unit}
				       chord(% (motif n * motif note duration)
					     duration:5*4 
					     index:1
					     transposition:0)]
				startTime:0
				timeUnit:beats(16))
			    Aux.myCreators}
	      end
	      unit(order:size value:mid)}.1
%% output
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}

%% MakeChordRepetition
declare
File = "07-Harmonised-L-system-ex2"
MySolution = {SDistro.searchOne
	      proc {$ MyScore}
		 MyScore = {Score.makeScore
			    sim(items:[{MakeChordRepetition unit}
				       chord(% (motif n * motif note duration)
					     duration:3*12
					     index:1
					     transposition:0)]
				startTime:0
				timeUnit:beats(16))
			    Aux.myCreators}
	      end
	      unit(order:size value:mid)}.1
%% output
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}

%% MakeArpeggio
declare
File = "07-Harmonised-L-system-ex3"
MySolution = {SDistro.searchOne
	      proc {$ MyScore}
		 MyScore = {Score.makeScore
			    sim(items:[{MakeArpeggio unit}
				       chord(% (motif n * motif note duration)
					     duration:3*8
					     index:1
					     transposition:0)]
				startTime:0
				timeUnit:beats(16))
			    Aux.myCreators}
	      end
	      unit(order:size value:mid)}.1
%% output
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}

%% MakeArpeggio again
declare
File = "07-Harmonised-L-system-ex3b"
MySolution = {SDistro.searchOne
	      proc {$ MyScore}
		 MyScore = {Score.makeScore
			    sim(items:[{MakeArpeggio unit(n:5		% No. of motif notes
							  direction:'<:' % relation to predecessor
							  averageInterval:6*PitchesPer100Cent)}
				       chord(% (motif n * motif note duration)
					     duration:5*8
					     index:1
					     transposition:0)]
				startTime:0
				timeUnit:beats(16))
			    Aux.myCreators}
	      end
	      unit(order:size value:mid)}.1
%% output
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}

% handcoded global form
declare
File = "07-Harmonised-L-system-ex4"
MySolution = {SDistro.searchOne
	      {HarmoniseScore seq(items:[arpeggio(n:4
						  direction:'<:'
						  isStartingWithChord:unit)
					 chordRepetition(isStartingWithChord:unit)
					 chordRepetition(isStartingWithChord:unit)
					 arpeggio(n:3
						  direction:'>:'
						  isStartingWithChord:unit)
					 arpeggio(n:4
						  direction:'>:'
						  isStartingWithChord:unit)
					])
	       unit(arpeggio:MakeArpeggio
		    chordRepetition:MakeChordRepetition
		    run:MakeRun)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}


%% !! unfinished and unused yet: needs long search, smaller version below
declare
File = "07-Harmonised-L-system-ex4a"
MySolution = {SDistro.searchOne
	      {HarmoniseScore
	       seq(items:[sim(items:[arpeggio(n:4
					      direction:'<:'
					      isStartingWithChord:unit)
				     arpeggio(n:4
					      direction:'<:')])
			  sim(items:[arpeggio(n:4
					      direction:'<:'
					      isStartingWithChord:unit)
				     arpeggio(n:4
					      direction:'<:')])
			  chordRepetition(isStartingWithChord:unit)
			  chordRepetition(isStartingWithChord:unit)
			  sim(items:[arpeggio(n:7
					      direction:'>:'
					      isStartingWithChord:unit)
				     arpeggio(n:5
					      offsetTime:2
					      direction:'>:')
				     arpeggio(n:3
					      offsetTime:4
					      direction:'>:')])])
	       unit(arpeggio:MakeArpeggio
		    chordRepetition:MakeChordRepetition
		    run:MakeRun)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}



%% !! unfinished and unused yet: works in principle, but pitches of sim notes do not necessarily differ ...
declare
File = "07-Harmonised-L-system-ex4a"
MySolution = {SDistro.searchOne
	      {HarmoniseScore
	       seq(items:[sim(items:[arpeggio(n:4
					      direction:'<:'
					      isStartingWithChord:unit)
				     arpeggio(n:4
					      direction:'<:')])])
	       unit(arpeggio:MakeArpeggio
		    chordRepetition:MakeChordRepetition
		    run:MakeRun)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}




%% MakeMyFreeMotif (feed motif def above)
declare
File = "07-Harmonised-L-system-ex5"
MySolution = {SDistro.searchOne
	      proc {$ MyScore}
		 MyScore = {Score.makeScore
			    sim(items:[{MakeMyFreeMotif unit}
				       chord(% (motif n * motif note duration)
					     duration:4*4
					     index:1
					     transposition:0)]
				startTime:0
				timeUnit:beats(16))
			    Aux.myCreators}
	      end
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}

%% MakeMyFreeMotif2 (feed motif def above)
declare
File = "07-Harmonised-L-system-ex6"
MySolution = {SDistro.searchOne
	      proc {$ MyScore}
		 MyScore = {Score.makeScore
			    sim(items:[{MakeMyFreeMotif2 unit(n:6
							      noteDuration:8)}
				       chord(duration:6*8
					     index:1
					     transposition:0)]
				startTime:0
				timeUnit:beats(16))
			    Aux.myCreators}
	      end
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}



%% handcoded motif seq again
declare
File = "07-Harmonised-L-system-ex7"
MySolution = {SDistro.searchOne
	      {HarmoniseScore seq(items:[run(isStartingWithChord:unit)
					 chordRepetition(isStartingWithChord:unit)
					 run(isStartingWithChord:unit)
					 chordRepetition(isStartingWithChord:unit)
					 chordRepetition(isStartingWithChord:unit)
					 freeMotif(n:7
						   noteDuration:4)
					 arpeggio(n:6
						  direction:'>:'
						  isStartingWithChord:unit)])
	       unit(arpeggio:MakeArpeggio
		    chordRepetition:MakeChordRepetition
		    run:MakeRun
		    freeMotif:MakeMyFreeMotif2)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}


%%
%% L-system output 
%%


declare
File = "07-Harmonised-L-system-ex8"
MySolution = {SDistro.searchOne
	      {HarmoniseScore seq(items:{MyLSystemMotifs unit(n:2)})
	       unit(arpeggio:MakeArpeggio
		    chordRepetition:MakeChordRepetition
		    run:MakeRun)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}
%% output score spec 
{Out.writeToFile {Value.toVirtualString {MyLSystemMotifs unit(n:2)} 1000 1000}
 OutDir#File#".oz"}


declare
File = "07-Harmonised-L-system-ex8a"
MySolution = {SDistro.searchOne
	      {HarmoniseScore seq(items:{MyLSystemMotifs unit(n:3)})
	       unit(arpeggio:MakeArpeggio
		    chordRepetition:MakeChordRepetition
		    run:MakeRun)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}
%% output score spec 
{Out.writeToFile {Value.toVirtualString {MyLSystemMotifs unit(n:3)} 1000 1000}
 OutDir#File#".oz"}


%% NB: the edited version of this is "07-Harmonised-L-system"
declare
File = "07-Harmonised-L-system-ex9"
MySolution = {SDistro.searchOne
	      {HarmoniseScore seq(items:{MyLSystemMotifs unit(n:4)})
	       unit(arpeggio:MakeArpeggio
		    chordRepetition:MakeChordRepetition
		    run:MakeRun)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}
%% output score spec 
{Out.writeToFile {Value.toVirtualString {MyLSystemMotifs unit(n:4)} 1000 1000}
 OutDir#File#".oz"}




*/
