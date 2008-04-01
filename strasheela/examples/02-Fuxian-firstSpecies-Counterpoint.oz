
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
%% (cf. ../01-AllIntervalSeries.oz and
%% http://strasheela.sourceforge.net/strasheela/doc/Installation.html)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% This example defines two-voice first species counterpoint as
%% explained by Fux, J. J. (1965, orig. 1725). The Study of
%% Counterpoint. from Johann Joseph Fux's Gradus ad
%% Parnassum. W.W. Norton & Company. translated and edited by Alfred
%% Mann.
%%

%%
%% In first species counterpoint for two voices, the task is writing a
%% fitting counter-melodie (the counterpoint) for a given melody (the
%% cantus firmus). In this first species, note durations are
%% irrelevant: notes of parallel voices always start and end together
%% (i.e. all notes are of equal length, usually all notes are
%% semibreve). Also, both voices start and end together (i.e. the
%% cantus firmus and the counterpoint have the same number of notes).
%% 
%% A few rules restrict the melodic aspect of the counterpoint
%% writing. Only melodic intervals up to a fourth are allowed, or a
%% fifth, or an octave. No note repetition is permitted. All notes
%% must be diatonic pitches (i.e. there can be no augmented,
%% diminished, or chromatic melodic intervals). The counterpoint
%% remains in a narrow pitch range.  Melodic steps are preferred (this
%% rule is not mentioned by Fux).
%%
%% Furthermore, some rules restrict the relation between both
%% voices. Open and hidden parallels are forbidden, that is direct
%% motion in a perfect consonance is not allowed. Only consonances are
%% permitted as intervals between simultaneous notes and there should
%% be more imperfect than perfect consonances. The first and last
%% notes, however, must form a perfect consonance. Finally, the
%% counterpoint must be in the same mode as the cantus firmus.
%%
%%
%%
%% BTW: a few Fuxian rules are omitted here for brevity (these rules
%% are only given in footnotes to the first chapter in the Fux
%% translation by Mann). The omitted rules are the following:
%%
%%   * No melodic skips follow each other in same direction.
%%
%%   * Skips must be compensated for.
%%
%%   * A tone can only be repeated once at maximum (instead, the
%%   example shown here completely prohibts repetitions).
%%
%%   * There must be no tritone in the melody, even when this interval
%%   is reached stepwise (in the example shown here, only the tritone
%%   between two neighbouring notes is prohibted).
%%
%%   * From an interval larger than an octave contrary motion into an
%%   octave is not allowed.
%%

%%
%% Note that a generalisation of this example is available at
%% strasheela/contributions/anders/HarmonisedScore/examples/HS/Fuxian-Counterpoint-with-Scale.oz.
%% This variant is parameterised (e.g., the user can specify a cantus
%% firmus, even in different modi). Also, this variant demonstrates
%% the use of scale objects together with note objects.
%%

declare

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Top-level of definition 
%%
  
%% Main definition and constraint script: creates the score and
%% applies all rules to the score.
proc {Fux_FirstSpecies MyScore}
   %% The pitches of the cantus firmus are given as MIDI keynumbers
   %% (the cantus is taken from Fux). For the definition of MakeVoice
   %% see below.
   CantusFirmus = {MakeVoice [62 65 64 62 67 65 69 67 65 64 62]}
   %% The pitches of the counterpoint are undetermined and only
   %% restricted to a certain range. For example, the pitches are
   %% restricted to the interval [60,76] (i.e. the counterpoint is
   %% above the cantus) or [48, 64] (the counterpoint is below the
   %% cantus).
   %%
   %% The definition could be changed such that the pitch range of the
   %% Counterpoint can be given as an argument, but there exist only
   %% few solutions if the Counterpoint is the lower voice.
   Counterpoint = {MakeVoice {FD.list 11 60#76}}
   % Counterpoint = {MakeVoice {FD.list 11 48#64}}
   CounterpointNotes = {Counterpoint getItems($)}
in
   %% create the score: two voices (CantusFirmus + Counterpoint) run
   %% in parallel. A simultaneous container is used which is a
   %% temporal container whose contained items (the two voices) are
   %% implicitly constrained to run in parallel.
   MyScore = {Score.makeScore sim(items: [Counterpoint CantusFirmus]
				  %% the whole voice starts at time 0
				  startTime: 0
				  %% the duration 1 denotes a quarter note.
				  timeUnit:beats)
	      unit}
   %% apply compositional rules
   %%
   %% every note is diatonic, except the cadence note (the butlast note)
   {OnlyDiatonicPitches
    {List.last CounterpointNotes} | {List.take CounterpointNotes
				     {Length CounterpointNotes}-2}}
   %% Note: simple approach, only suitable for Dorian mode
   %% Cadence: but last pitch is C#
   {FD.modI {{LUtils.lastN CounterpointNotes 2}.1 getPitch($)} 12 1}
   %% No chromatic interval: C must not lead into C#
   local PC = {FD.decl} in 
      {FD.modI {{LUtils.lastN CounterpointNotes 3}.1 getPitch($)} 12 PC}
      PC \=: 0 
   end
   {RestrictMelodicIntervals Counterpoint}
   {OnlyConsonances Counterpoint}
   {PreferImperfectConsonances Counterpoint}
   {NoDirectMotionIntoPerfectConsonance Counterpoint}
   {StartAndEndWithPerfectConsonance Counterpoint}
end

%% Auxiliary function creating a single voice. The voice is
%% represented by a sequential container (a temporal container whose
%% contained items are implicitly constrained to form a temporal
%% sequence). MakeVoice expects a list of pitches (i.e. constrained
%% variables) which are incorporated into the note objects of the
%% voice returned.
fun {MakeVoice Pitches}
   %% Score.makeScore2 (in contrast to Score.makeScore) returns a
   %% score which is not yet fully initialised and can still be
   %% integrated into other containers.
   {Score.makeScore2 seq(items: {Map Pitches fun {$ Pitch}
						note(duration: 4
						     pitch: Pitch
						     pitchUnit: midi
						     amplitude: 80
						     amplitudeUnit:velocity)
					     end})
    unit}
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


%% All pitches in MyScore are constrained to diatonic pitches (here
%% simply pitches in the C-major scale).
local 
   ScalePCs = [0 2 4 5 7 9 11] % list of pitch classes in c-major scale
   %% pitch classes of MyPitch reduced to scale degrees
   proc {InScale MyPitch} {FD.modI MyPitch 12} :: ScalePCs end
in
   proc {OnlyDiatonicPitches Notes}
      %% apply InScale to all single notes in score
      {ForAll Notes proc {$ N} {InScale {N getPitch($)}} end}
   end
end


%% Only certain melodic intervals are allowed and small intervals are preferred.
local
   %% only the specified intervals are allowed
   proc {RestrictIntervalDomain Interval}
      Interval :: [1#5 7 12]
   end
   %% prefer melodic steps (constraints the average interval)
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
proc {GetInterval Note1 Note2 Interval}
   Interval = {FD.decl}
   {FD.distance {Note1 getPitch($)} {Note2 getPitch($)} '=:' Interval}
end

%% Constrains Interval to a consonance.
proc {IsConsonance Interval}
   %% NB: no prime (i.e. Interval \=: 0)
   Interval :: [3 4 7 8 9 12 15 16]
end

%% Constrains Interval to a perfect consonance.
local
   PerfectConsonance = {FS.value.make [0 7 12]}
in
   proc {IsPerfectConsonanceR Interval B}
      B = {FS.reified.include Interval PerfectConsonance}
   end
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
{SDistro.exploreOne Fux_FirstSpecies
 unit(order:size
      value:mid)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Score distribution strategy: (i) left-to-right variable ordering:
%% select parameters in order of the start times of the events or
%% temporal containers these parameters belong to. (ii) value
%% ordering: select middle element (see above).
{SDistro.exploreOne Fux_FirstSpecies
 unit(order:startTime
      value:mid)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% The next distribution strategy generates a new result at each
%% solver call.

%% Score distribution strategy: (i) first-fail variable ordering (see
%% above). (ii) value ordering: select a random domain value.
%%
%% NB: Presently, the random value ordering does not allow for
%% recomputation (recomputation is explained, e.g., in the book
%% 'Programming Constraint Services', details and a link to the book
%% are given in the Strasheela documentation).
{SDistro.exploreOne Fux_FirstSpecies
 unit(order:size
      value:random)}




%% tmp
{SDistro.iozsefExploreOne Fux_FirstSpecies
 unit(order:size
      value:mid)}


*/
