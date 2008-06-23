
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


%%
%% NB: this CSP generalises the first-species Fuxian counterpoint
%% example in strasheela/examples. It defines a parameterised script
%% (e.g., the user can specify the cantus firmus, even in different
%% modes). The rule set has been refined with respect to the more
%% simple example in strasheela/examples. Also, this example
%% demonstrates the use of scale objects together with note objects.
%%

%     This example defines two-voice first species counterpoint as
%     explained by Fux, J. J. (1965, orig. 1725). The Study of
%     Counterpoint. from Johann Joseph Fux's Gradus ad
%     Parnassum. W.W. Norton & Company. translated and edited by Alfred
%     Mann.
    
%     In first species counterpoint for two voices, the task is writing a
%     fitting counter-melodie (the counterpoint) for a given melody (the
%     cantus firmus). In this first species, note durations are
%     irrelevant: notes of parallel voices always start and end together
%     (i.e. all notes are of equal length, usually all notes are
%     semibreve). Also, both voices start and end together (i.e. the
%     cantus firmus and the counterpoint have the same number of notes).
    
%     A few rules restrict the melodic aspect of the counterpoint
%     writing. Only melodic intervals up to a fourth are allowed, or a
%     fifth, or an octave. No note repetition is permitted. All notes
%     must be diatonic pitches (i.e. there can be no augmented,
%     diminished, or chromatic melodic intervals). The counterpoint
%     remains in a narrow pitch range.  Melodic steps are preferred (this
%     rule is not mentioned by Fux).
    
%     Furthermore, some rules restrict the relation between both
%     voices. Open and hidden parallels are forbidden, that is direct
%     motion in a perfect consonance is not allowed. Only consonances are
%     permitted as intervals between simultaneous notes and there should
%     be more imperfect than perfect consonances. The first and last
%     notes, however, must form a perfect consonance. Finally, the
%     counterpoint must be in the same mode as the cantus firmus.
    
    
%     BTW: a few Fuxian rules are omitted here for brevity (most of these
%     rules are only given in footnotes the the Fux translation by
%     Mann). The omitted rules are the following:
    
%     - No melodic skips follow each other in same direction.
      
%     - Skips must be compensated for.
      
%     - A tone can only be repeated once at maximum (instead, the
%       example shown here completely prohibts repetitions).

%     - There must be no tritone in the melody, even when this interval
%       is reached stepwise (in the example shown here, only the tritone
%       between two neighbouring notes is prohibted).

%     - From a consonance larger than an octave motion by a skip into an
%       octave is not allowed.
%       Similarily: from a consonance into unison by a skip is not
%       allowed (can hardly be avoided in bass in compositions for 8
%       voices).
%       Similarily: from unison to other consonance by skip is bad
%       (except the c.f. does it, where we have no influence)

%     - ?? Fa leads up / Mi leads down -- adjust Fa by # if movement
%       ascends (Fux, p. 39)

%     - Imperfect consonances should be carefully used in parallel
%       succession (no more than 3-4 following each other). p.21,
%       footnote 2

%     - Fux allows for minor sixth upwards, here only intervals up to a fifth and the octave are permitted


%%
%% If I change this example more drastically, I can simply save it in strasheela/examples as Fuxian-Counterpoint-revised.oz or something and mention that this implementation is more true to Fux.. It is then also OK if the example contains less comments as the first Fuxian counterpoint example
%%

%%
%% Changes compared to Fuxian counterpoint example in strasheela/examples
%%
%% - Fux permits unison in examples (Fig. 13): changed IsConsonance
%%   NB: later in text he says that unison is only permitted at beginning and end (Fux p.38)
%%
%%



%%
%% TODO:
%%
%% - NOTE: I only implement rules explicitly given by Fux. I.e., I don't analyse his examples to infer further rules. 
%%
%% - check omitted rules above: which shall I additionally include 
%%
%% - refine: unison only permitted at beginning and end (Fux p.38)
%%
%% - ?? check whether definition introduces symmetries: same pitch sequence in counterpoint in different solutions?
%%
%% - ?? disallow tritone not only between successive melodic notes, but also between local min and maxima (dir changes or first/last melody notes)  
%%
%% ?? - memoize GetInterval
%%
%% OK - use reduced note class: I only need Score.note PitchClassMixin InScaleMixinForNote, ScaleDegreeMixinForNote
%%
%% OK - add constraint: but-last note is always raised VII degree (forms cadence)
%% OK - ?? generalise so that different cantus firmi can be used?
%%
%% OK - make CantusFirmus argument (so it can be given by user)
%%
%% OK - make Counterpoint pitch range argument
%%
%% OK - ?? Refactor: use HS.score.note and HS.score.scale and scale degree
%%   -> that way I can constrain: all countepoint pitches are diatonic, except for last which is raised VII degree. NB: example Fig 21, p. 39 brings raised VII degree already two notes early.. 
%% OK  ?? is scale derived from cantus or given as explicit argument? 
%%

declare

[ET12] = {ModuleLink ['x-ozlib://anders/strasheela/ET12/ET12.ozf']}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Top-level of definition 
%%

/** %% Top-level script. Args: cantusFirmus: list of pitch integers, counterpointDomain: domain spec for the counterpoint note pitches.
%% Note that pitch classes must all be in {0, 2, 4, 5, 7, 9, 11}, that butlast note must be II scale/mode degree (e.g., E if mode is dorian) and last note must be root of mode. 
%% */
proc {Fux_FirstSpecies Args ?MyScore}
   Defaults = unit(cantusFirmus: {Map ['D'#4 'F'#4 'E'#4 'D'#4
				       'G'#4 'F'#4 'A'#4 'G'#4
				       'F'#4 'E'#4 'D'#4]
				  ET12.pitch} 
		   counterpointDomain:{ET12.pitch 'C'#4}#{ET12.pitch 'E'#5})
   As = {Adjoin Defaults Args}
   %% Fully initialise scale (use Score.makeScore): it is not included in score
   MyScale = {Score.makeScore	
	      scale(duration:4	% irrelevant
		    startTime:0 % irrelevant
		    %% index:1
		    transposition:0)
	   unit(scale:HS.score.scale)}
   CantusFirmus = {MakeVoice As.cantusFirmus MyScale 'c.f.'}
   Counterpoint = {MakeVoice {FD.list {Length As.cantusFirmus}
			      As.counterpointDomain}
		   MyScale 'cpt.'}
in
   MyScore = {Score.makeScore sim(info:scale(MyScale)
				  items: [Counterpoint CantusFirmus]
				  startTime: 0
				  timeUnit:beats)
	      unit}
   {SetScaleRoot MyScale CantusFirmus}
   {DoCadence Counterpoint}
   {RestrictMelodicIntervals Counterpoint}
   {OnlyConsonances Counterpoint}
   {PreferImperfectConsonances Counterpoint}
   {NoDirectMotionIntoPerfectConsonance Counterpoint}
   {StartAndEndWithPerfectConsonance Counterpoint}
   {ResoveSkip Counterpoint}
   {NoChromaticInterval Counterpoint}
end
/** %% Only single scale candidate defined for note, so we can make it directly accessible.
%% */
fun {GetScale MyNote}
   {MyNote getScales($)}.1
end

fun {MakeVoice Pitches MyScale VoiceName}
   {Score.makeScore2
    seq(info:lily("\\set Staff.instrumentName = \""#VoiceName#"\"")
	items: {Map Pitches fun {$ Pitch}
			       note(duration: 4
				    pitch: Pitch
				    inScaleB:{FD.int 0#1}
				    getScales:proc {$ Self Scales} 
						 Scales = [MyScale]
					      end
				    isRelatedScale:proc {$ Self Scale B} B=1 end
				    amplitude: 80)
			    end})
    add(note:HS.score.scaleNote)}
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Scale database
%%

MyScales = scales(1: scale(pitchClasses:[0 2 4 5 7 9 11]
			 roots:[0]
			 comment:'Ionian')
		2: scale(pitchClasses:[0 2 4 5 7 9 11]
			 roots:[2]
			 comment:'Dorian')
		3: scale(pitchClasses:[0 2 4 5 7 9 11]
			 roots:[4]
			 comment:'Phrygian')
		4: scale(pitchClasses:[0 2 4 5 7 9 11]
			 roots:[5]
			 comment:'Lydian')
		5: scale(pitchClasses:[0 2 4 5 7 9 11]
			 roots:[7]
			 comment:'Mixolydian')
		6: scale(pitchClasses:[0 2 4 5 7 9 11]
			 roots:[9]
			 comment:'Aeolian'))

{HS.db.setDB unit(scaleDB:MyScales)}

/*

%% test
declare
MyScale = {Score.makeScore	
	      scale(transposition:0)
	   unit(scale:HS.score.scale)}
CantusFirmus = {MakeVoice {Map ['E'#4 'C'#4 'D'#4 'C'#4
				'A'#3 'A'#4 'G'#4 'E'#4
				'F'#4 'E'#4]
			   ET12.pitch}
		MyScale}
{Score.initScore CantusFirmus}
{SetScaleRoot MyScale CantusFirmus}

%% OK, root is 4
{Browse {MyScale getRoot($)}}

*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% new Rule definitions 
%%

%%
%% TODO: put these rules into a more suitable place in file
%%

/** %% Constraints scale root to pitch class of last cantus firmus note.
%% NOTE: the c.f. must end in I scale degree.
%% */
proc {SetScaleRoot MyScale CantusFirmus}
   {MyScale getRoot($)} = {{List.last {CantusFirmus getItems($)}}
			   getPitchClass($)}
end

/** %% All counterpoint pitches are diatonic. The only exception is the butlast pitch, which must be a raised VII scale degree in case the mode is Dorian, Mixolydian or Aeolian. Also, the butlast interval must be less than an octave.
%%
%% NOTE: problem of this rule: skip can occur into raised VII degree, e.g., a4 c#5 d5. Fux never does this in his examples.
%% */
proc {DoCadence Counterpoint}
   AllNotes = {Counterpoint getItems($)}
   PenultimateNote = {Nth AllNotes {Length AllNotes}-1}
   AllButPenultimateNotes = {LUtils.remove AllNotes
			     fun {$ X} X == PenultimateNote end}
   ScaleIndex = {{GetScale PenultimateNote} getIndex($)}
in
   %% Raise seventh degree for Dorian, Mixolydian or Aeolian.
   %% Mode know at time of problem def, so I can simply use if
   thread
      if {Member ScaleIndex {Map ['Dorian' 'Mixolydian' 'Aeolian']
			     HS.db.getScaleIndex}}
      then {PenultimateNote getScaleAccidental($)} = {ET12.acc '#'}  
      else {PenultimateNote getScaleAccidental($)} = {ET12.acc ''} 
      end
   end
   {PenultimateNote getScaleDegree($)} = 7
   %% interval to sim note is less than octave
   {GetInterval PenultimateNote {GetSimNote PenultimateNote}} <: 12
   %% 
   {ForAll AllButPenultimateNotes
    proc {$ X} {X getScaleAccidental($)} = {HS.score.absoluteToOffsetAccidental 0} end}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Rule definitions 
%%

%% The first and last note pitch of the Counterpoint must form a
%% perfect consonance to counterpoint and must be in same mode. This
%% restricts the start and end pitch of the counterpoint: it is either
%% an octave below, or a prime, fifth, or octave above cantus firmus.
local
   AllowedIntervals = [~12 0 7 12] % octave below, prime, fifth, or octave above
   proc {IsSuitableInterval CounterpointPitch CantusPitch}
      Interval
   in
      %% offset of 12 to avoid FD ints < 0
      Interval :: {Map AllowedIntervals fun {$ X} X+12 end}
      Interval =: CounterpointPitch - CantusPitch + 12
   end
in
   proc {StartAndEndWithPerfectConsonance Counterpoint}
      Notes = {Counterpoint getItems($)}
      FirstNote = Notes.1
      LastNote = {List.last Notes}
   in
      {IsSuitableInterval
       {FirstNote getPitch($)} {{GetSimNote FirstNote} getPitch($)}}
      {IsSuitableInterval
       {LastNote getPitch($)} {{GetSimNote LastNote} getPitch($)}}
   end
end   

%% Only certain melodic intervals are allowed and small intervals are preferred.
local
   %% only the specified intervals are allowed
   %% NOTE: note repetition (int 0) is not allowed
   proc {RestrictIntervalDomain Interval}
      Interval :: [1#5 7 12]
   end
   %% prefer melodic steps (constraints the average interval)
   %% Alternative: constrain number of steps with Pattern.howManyTrue 
   proc {PreferSteps Intervals}
      AverageIntervalEnc = {FD.int 15#30} %% encoded value: 1.5 - 3.0
   in
      %% uses a constraint from the Pattern contribution 
      {Pattern.arithmeticMean Intervals AverageIntervalEnc 10}
   end
in
   %% Melodic rules constraining the intervals between neighbouring
   %% note pitch pairs of MyVoice: only intervals up to a fourth or a
   %% fifth or an octave are permitted, no pitch repetition, steps are
   %% preferred.
   proc {RestrictMelodicIntervals MyVoice}
      Intervals = {Pattern.map2Neighbours {MyVoice getItems($)}
		   GetInterval}
   in
      {ForAll Intervals RestrictIntervalDomain}
      {PreferSteps Intervals}
   end
end

%% The interval between every pair of simultaneous note pitches is consonant
proc {OnlyConsonances CounterPoint}
   %% apply rule IsConsonance on each pair of simultaneous notes
   {ForAll {CounterPoint getItems($)}
    proc {$ Note1}
       {IsConsonance {GetInterval Note1 {GetSimNote Note1}}}
    end}
end

%% Imperfect consonances are preferred over perfect consonances. The
%% number of perfect consonances between simultaneous notes is less
%% than then half of the total number of voice notes.
proc {PreferImperfectConsonances Counterpoint}
   Notes = {Counterpoint getItems($)}
   SimIntervals = {Map Notes
		   proc {$ Note1 Interval}
		      Interval = {GetInterval Note1 {GetSimNote Note1}}
		   end}
   NumberPerfectConsonances = {FD.decl}
in
   NumberPerfectConsonances = {FD.sum {Map SimIntervals IsPerfectConsonanceR} '=:'}
   NumberPerfectConsonances <: ({Length Notes} div 2)
end
      
%% Open and hidden parallels are forbidden: perfect consonances must
%% not be reached by both voices in the same direction
proc {NoDirectMotionIntoPerfectConsonance CounterPoint}
   {Pattern.for2Neighbours {CounterPoint getItems($)}
    proc {$ NotePre NoteSucc}
       %% direction of interval of voice1
       %% NB: Pattern.direction does not propagate well (see doc)
       Dir1 = {Pattern.direction
	       {NotePre getPitch($)} {NoteSucc getPitch($)}}
       Dir2 = {Pattern.direction
	       {{GetSimNote NotePre} getPitch($)}
	       {{GetSimNote NoteSucc} getPitch($)}}
    in
       {FD.impl
	%% interval between sim successor notes
	{IsPerfectConsonanceR {GetInterval NoteSucc {GetSimNote NoteSucc}}}
	(Dir1 \=: Dir2)
	1}
    end}
end


/** %% When a skip occurs, continue by step in opposite direction.
%% */ 
proc {ResoveSkip Counterpoint}
   {Pattern.forNeighbours {Counterpoint getItems($)} 3
    proc {$ [N1 N2 N3]}
       Dir1 = {Pattern.direction
	       {N1 getPitch($)} {N2 getPitch($)}}
       Dir2 = {Pattern.direction
	       {N2 getPitch($)} {N3 getPitch($)}}
    in
       {FD.impl {IsSkip N1 N2}
	{FD.conj (Dir1 \=: Dir2) {FD.nega {IsSkip N2 N3}}}
	1}
    end}
end

/** %% If two successive notes are on the same scale degree, then the share the same accidental.
%% */
proc {NoChromaticInterval Counterpoint}
   {Pattern.for2Neighbours {Counterpoint getItems($)}
    proc {$ N1 N2}
       {FD.impl  ({N1 getScaleDegree($)} =: {N2 getScaleDegree($)}) 
	({N1 getScaleAccidental($)} =: {N2 getScaleAccidental($)})
	1}    
    end}
end
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Auxiliary definitions
%%
   
%% Returns the (single) note which is simultaneous to MyNote.
fun {GetSimNote MyNote}
   %% getSimultaneousItems returns a list with the simultaneous items
   {MyNote getSimultaneousItems($ test:isNote)}.1
end

%% Constrains Interval to the absolute distance between the pitches of
%% Note1 and Note2.
%%
%% NB: Every call to GetInterval returns a fresh constrained
%% variable. An optimised version memorizes note pairs to avoid
%% creating additional variables and propagators for the same interval
%% computed multiple times (cf. the contribution Memo)
%% TODO: rewrite with Memoization
proc {GetInterval Note1 Note2 Interval}
   Interval = {FD.decl}
   {FD.distance {Note1 getPitch($)} {Note2 getPitch($)} '=:' Interval}
end

%% Constrains Interval to a consonance.
proc {IsConsonance Interval}
   %% It appears Fux does not explicitly restrict maximum interval
   %% between voices, but 10th is largest interval Fux uses in
   %% examples
   Interval :: [0 3 4 7 8 9 12 15 16]
end

%% Constrains Interval to a perfect consonance.
local
   PerfectConsonance = {FS.value.make [0 7 12]}
in
   proc {IsPerfectConsonanceR Interval B}
      B = {FS.reified.include Interval PerfectConsonance}
   end
end

%% B=1 <-> interval between notes N1 and N2 is greater than a mojor second.
proc {IsSkip N1 N2 B}
   B = {FD.reified.distance {N1 getPitch($)} {N2 getPitch($)} '>:' 2}
end


%% Sets the tempo for output formats such as MIDI and Csound.
{Init.setTempo 120.0}
%{Init.setTempo 100.0}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Call solver (a few alternative solver calls are shown)
%%

/*

%% A few different score distribution strategies are
%% demonstrated. Yet, for this simple example their performance does
%% not differ.

%% Score distribution strategy: (i) first-fail variable ordering:
%% select the leftmost variable, whose domain is minimal. (ii) value
%% ordering: select the element, which is closest to the middle of the
%% domain (the arithmetical means between the lower and upper bound of
%% the domain).
%%
%% Select a suitable output format in the Explorer menu
%% Nodes:Information Action
{GUtils.setRandomGeneratorSeed 0} % always find different solution..
{SDistro.exploreOne {GUtils.extendedScriptToScript Fux_FirstSpecies
		     unit}
 unit(order:size
      value:random)}


{GUtils.setRandomGeneratorSeed 0} 
{SDistro.exploreOne {GUtils.extendedScriptToScript Fux_FirstSpecies
		     unit(counterpointDomain:{ET12.pitch 'C'#3}#{ET12.pitch 'E'#4})}
 unit(order:size
      value:random)}


%% use cantus firmus in a mode where cadence does _not_ require a raised note
{SDistro.exploreOne {GUtils.extendedScriptToScript Fux_FirstSpecies
		     unit(cantusFirmus:{Map ['E'#4 'C'#4 'D'#4 'C'#4
					     'A'#3 'A'#4 'G'#4 'E'#4
					     'F'#4 'E'#4]
					ET12.pitch})}
 unit(order:size
      value:random)}



%% use cantus firmus in a non-dorian mode, which nevertheless requires a raised cadence note
{SDistro.exploreOne {GUtils.extendedScriptToScript Fux_FirstSpecies
		     unit(cantusFirmus:{Map ['G'#3 'C'#4 'B'#3 'G'#3
					     'C'#4 'E'#4 'D'#4 'G'#4
					     'E'#4 'C'#4 'D'#4 'B'#3
					     'A'#3 'G'#3]
					ET12.pitch})}
 unit(order:size
      value:random)}




*/
