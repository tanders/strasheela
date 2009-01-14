
%%
%% This example implements a significant subset of Schoenberg's Theory of Harmony. Nevertheless, the example is created in 31 ET (not 12 ET) because this leads to a better enharmonic notation and intonation.
%% 
%% Usage: first feel buffer, then feed solver calls in comments are the end.
%%

%%
%% TODO:
%%
%% - I may notate the chord scale degrees with Roman numerals. Seems this is not predefined in lily. So, I would have to specify that the chord seq is ignored in Lily, and then define a special output for the bass notes which accesses the sim chords, translates their scale degree into a text string and prints that with a text markup.
%%   NOTE: some other Lily users use a \Lyrics context for roman numerals 
%%


declare

%% NOTE: Enharmonic modulation with 31 ET is less strait forward that with 12 ET. However, using 31 ET is more strait forward for enharmonic notation that using enharmonic notes are -- the chord database does not contain accidental information...
%% BTW: 12 ET playback would be simple with 31 ET: just create a tuning table which maps 12 ET pitches on the 31 ET pitches :)  
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Top-level definition
%%



/** %% Top-level script: creates a chord progression with the following score topology

sim(sim(seq(note+)   % soprano 
	seq(note+))  % alto
    sim(seq(note+)   % tenor
	seq(note+))  % bass
    seq(chord+)
    
   )
%%
%% Args are the args given to subscript MakeSchoenbergianProgression.
%% 
%% */
%% NOTE: postpone modulation... if needed, refactor HomophonicChordProgression so that different scale  settings can be used
%% ?? howto express overlapping for neutralising? ?? Use sim container + an easy to use constructor used like seq creation but which allows for negative offsetTimes (no problem for determined offsetTimes..).
%% seq/sim(scale+)
%%
proc {HomophonicChordProgression Args ?MyScore}
   Defaults = unit(%% args for chord creation (see HS.score.makeChords)
		   iargs: unit(n:7
			       duration:2
			       timeUnit:beats)
		   %% args for rules on chords
		   rargs: unit(scale:{MakeScale 'C' 'major'}
			       types: ['major' 'minor'])
		  )
   As = unit(iargs:{Adjoin Defaults.iargs Args.iargs}
	     rargs:{Adjoin Defaults.rargs Args.rargs})
   Chords = {MakeSchoenbergianProgression As}
   fun {MakeNNotes MinPitch MaxPitch}
      {MakeNotes unit(iargs:unit(n:As.iargs.n
				 duration:As.iargs.duration)
		      rargs:unit(minPitch: MinPitch
				 maxPitch: MaxPitch))}
   end
   %% Pitch domain from Schoenberg's Harmonielehre, p. 36
   SopranoNotes = {MakeNNotes 'C'#4 'A'#5}
   AltoNotes = {MakeNNotes 'G'#3 'E'#5}
   TenorNotes = {MakeNNotes 'C'#3 'A'#4}
   BassNotes = {MakeNNotes 'E'#2 'D'#4}
in
   MyScore = {Score.makeScore
	      sim(items:[seq(items:[sim(items:[seq(info:soprano
						   items:SopranoNotes)
					       seq(info:alto
						   items:AltoNotes)])])
			 seq(items:[sim(items:[seq(info:tenor
						   items:TenorNotes)
					       seq(info:bass
						   items:BassNotes)])])
			 seq(info:lily("\\set Staff.instrumentName = \"Analysis\"")
			     items:Chords)
			 %% TODO: add scales to music representation for modulation
			]
		  startTime:0)
	      unit}
   %%
   %% 'wellformedness' constraints
   %%
   %% Constrain 'time slice' of chord and corresponding notes
   {ForAll {LUtils.matTrans [Chords BassNotes TenorNotes AltoNotes SopranoNotes]}
    proc {$ [C BN TN AN SN]}
       {PlayAllChordTones C [BN TN AN SN]}
       {NoVoiceCrossing [BN TN AN SN]}
       {ConstrainUpperVoiceDistance [BN TN AN SN]}
       %% Note: soprano is ignored here, but I need bass for BassChordDegree
       {C getBassPitchClass($)} = {BN getPitchClass($)}
    end}
   %%
   %% melodic constraints
   {ForAll [TenorNotes AltoNotes SopranoNotes]
    proc {$ Notes}
       {RestrictMelodicIntervals_UpperVoices Notes
	unit(minPercent:70
	     maxPercent:100)}
    end}
   {RestrictMelodicIntervals_Bass BassNotes}
   %%
   %% constraints on pairs for chords and notes 
   {Pattern.for2Neighbours {LUtils.matTrans
			    [Chords BassNotes TenorNotes AltoNotes SopranoNotes]}
    proc {$ [C1 BN1 TN1 AN1 SN1] [C2 BN2 TN2 AN2 SN2]}
       NotePairs = [BN1#BN2 TN1#TN2 AN1#AN2 SN1#SN2]
    in
       {CommonPitchesHeldOver C1#C2 NotePairs}
       {NoParallels NotePairs}
    end}
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Music representation and sub-scripts
%%

/** %% Returns a scale object, expects the key and type as atoms, e.g., {MakeScale 'C' 'major'}
%% */
proc {MakeScale Key ScaleType Result}
   Result = {Score.make2 scale(index:{HS.db.getScaleIndex ScaleType}
			       transposition:{ET31.pc Key})
	     unit(scale:HS.score.scale)}
end



/** %% Returns list of notes to which common counterpoint rules are applied: non-harmonic tones are restricted and the first and last tone is constrained to a chord tone.
%%
%% Args.rargs:
%% 'minPitch' and 'maxPitch': domain specification in ET31 pitch notation
%% In addition, all arguments of Score.makeItems_iargs are supported.
%% */
MakeNotes
= {Score.defSubscript
   unit(super:Score.makeItems_iargs
	idefaults: unit(constructor: HS.score.note
			getChords: fun {$ Self}
				      [{Self findSimultaneousItem($ test:HS.score.isChord)}]
				   end
			inChordB:1)
	rdefaults: unit(minPitch:'C'#3
			maxPitch:'C'#6
		       ))
   proc {$ Notes Args} 
      {RestrictPitchDomain Notes Args.rargs.minPitch Args.rargs.maxPitch}
   end}


/** %% Extended script which returns a list of chords following (different versions of) Schoenberg's rule proposals for root progressions. This is a sub-script of HS.score.makeChords, all arguments of HS.score.makeChords are supported as well.
%%
%% Args.rargs:
%% 'progressionSelector': arg (atom or record) given to HS.rules.schoenberg.progressionSelector, see doc there.
%% 'maxPercentSuperstrong' (default false): maximum percentage of the superstrong progressions permitted (false means this constraint is switched off).
%% 'cadenceN' (default 3): how many chords at end form cadence (sound all chord PCs)
%% 'onlyAscendingInCadence' (default true): Boolean whether the cadence consists only of ascending progressions
%%
%% Args.iargs:
%% all HS.score.inversionChord init argument, including dom specifications in the form fd#Dom
%%
%% */
MakeSchoenbergianProgression
= {Score.defSubscript
   unit(super:HS.score.makeChords
	idefaults: unit(%% add support for fd # Dom arg specs 
			constructor: {Score.makeConstructor HS.score.inversionChord
				      unit}
			bassChordDegree: 1)
	rdefaults: unit(progressionSelector:resolveDescendingProgressions
			scale:{MakeScale 'C' 'major'}
			maxPercentSuperstrong: false
			cadenceN: 3
			onlyAscendingInCadence: true
		       ))
   proc {$ Chords Args}
      MyScale = Args.rargs.scale
   in 
      {HS.rules.schoenberg.progressionSelector Chords Args.rargs.progressionSelector}
      if Args.rargs.maxPercentSuperstrong \= false then  
	 %% NOTE: this rule makes the problem harder
	 {Pattern.percentTrue_Range
	  {Pattern.map2Neighbours Chords
	   fun {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2} end}
	  0 Args.rargs.maxPercentSuperstrong}
      end
      %% First and last chords are root in root position
      {HS.rules.distinctR Chords.1 {List.last Chords} 0}
      {Chords.1 getRoot($)} = {MyScale getRoot($)}
      {Chords.1 getBassChordDegree($)} = {{List.last Chords} getBassChordDegree($)} = 1
      %% only diatonic chords
      {ForAll Chords proc {$ C} {HS.rules.diatonicChord C MyScale} end}
      %% last three chords form cadence with only strong progressions
      {HS.rules.cadence MyScale {LUtils.lastN Chords Args.rargs.cadenceN}}
      if Args.rargs.onlyAscendingInCadence then 
	 {Pattern.for2Neighbours {LUtils.lastN Chords Args.rargs.cadenceN}
	  proc {$ C1 C2} {HS.rules.schoenberg.ascendingProgressionR C1 C2 1} end}
      end
   end}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Constraints 
%%


/** %% Expects a list of notes and two ET31 pitches specified like 'C'#4. These set the upper and lower pitch domain of all notes.
%% */
proc {RestrictPitchDomain Notes MaxDom MinDom}   
   Dom = {ET31.pitch MaxDom}#{ET31.pitch MinDom}
in
   {Pattern.mapItems Notes getPitch} ::: Dom
end


/** %% MyChord and Notes are the chord and the notes at a time frame: all notes of the chord are played and no others.
%% */
proc {PlayAllChordTones MyChord Notes}
   {FS.unionN {Map Notes
	       fun {$ N} {GUtils.makeSingletonSet {N getPitchClass($)}} end}
    {MyChord getPitchClasses($)}}
   {ForAll Notes
    proc {$ N} {FS.include {N getPitchClass($)} {MyChord getPitchClasses($)}} end}
end

/** %% Notes are the notes at a time frame and constrained to increasing pitch. NOTE: notes must be given in increasing order, bass first.
%% */
proc {NoVoiceCrossing Notes}
   {Pattern.continuous {Map Notes fun {$ N} {N getPitch($)} end}
    '=<:'}
end


/** %% The upper voices are max an ocatve apart of each other. Notes is same args as for NoVoiceCrossing.
%% */
proc {ConstrainUpperVoiceDistance Notes}
   {Pattern.for2Neighbours Notes.2
    proc {$ N1 N2}
       {GetInterval N1 N2} =<: {HS.db.getPitchesPerOctave}
    end}
end


/** %% [Strict constraint for homophonic chord progression] If two consecutive chords C1 and C2 share common pitches (harmonic band), then these occur in the same voice and octave (Schoenberg: harmonischen Band bleibt liegen). NotePairs is a list of two-note-pairs. Each pair consists of consecutive notes in the same voice and NotePairs together expresses C1 and C2. However, the bass notes are excluded. The voices in NotePairs are ordered increasing, so the bass is the first pair which is ignored. 
%% */
proc {CommonPitchesHeldOver C1#C2 NotePairs}
   HarmonicBandFS = {FS.var.decl}
in
   {FS.intersect {C1 getPitchClasses($)} {C2 getPitchClasses($)} HarmonicBandFS}
   {ForAll NotePairs.2		% skip bass
    proc {$ N1#N2}
       {FD.impl {FS.reified.include {N1 getPitchClass($)} HarmonicBandFS}
	({N1 getPitch($)} =: {N2 getPitch($)})
	1}
    end}
end
/** %% Open and hidden parallel fifths and fourth are not permitted: perfect consonances must not be reached by both voices in the same direction.
%% NotePairs is same are as in HarmonicBandStays.
%% */
proc {NoParallels NotePairs}
   {Pattern.forPairwise NotePairs NoParallel}
end
/** %% Pairs like N1A#N1B are consecutive melodic notes, sim notes are, e.g., N1B and N2B.
%% */
%% TODO: this is reusable -- where to store it?
proc {NoParallel N1A#N1B N2A#N2B}
   Dir1 = {Pattern.direction {N1A getPitch($)} {N1B getPitch($)}}
   Dir2 = {Pattern.direction {N2A getPitch($)} {N2B getPitch($)}}
in
   {FD.impl
    %% interval between sim successor notes
    {IsPerfectConsonanceR {GetInterval N1B N2B}}
    (Dir1 \=: Dir2)
    1}
end

%% 
/** %% Restrict melodic intervals of Notes (list of notes in a single upper voice): only skips up to a fifths and most intervals (Args.minPercent to Args.maxPercent) are steps or unison.
%% ?? no two skips after each other in same dir? 
%% */
proc {RestrictMelodicIntervals_UpperVoices Notes Args}
   Defaults = unit(minPercent:70
		   maxPercent:100)
   As = {Adjoin Defaults Args}
   Intervals = {Pattern.map2Neighbours Notes GetInterval}
in
   {ForAll Intervals proc {$ X} X =<: Fifth end}
   {Pattern.percentTrue_Range {Map Intervals proc {$ X B} B = (X =<: MajSecond) end}
    As.minPercent As.maxPercent}
end
/** %% Restrict melodic intervals of Notes (list of notes in bass): only skips up to a fifth or an octave.
%% */
%% ??  At least sometimes the bass progresses stepwise: min number of steps given
proc {RestrictMelodicIntervals_Bass Notes}
%   Defaults = unit(minSteps:0)
%   As = {Adjoin Defaults Args}
   Intervals = {Pattern.map2Neighbours Notes GetInterval}
in
   {ForAll Intervals
    proc {$ X} {FD.disj (X =<: Fifth) (X =: {HS.db.getPitchesPerOctave}) 1}  end}
%    {Pattern.howManyTrue {Map Intervals proc {$ X B} B = (X =<: MajSecond) end}} >=: As.minSteps
end


%% TODO: unfinished and not used above
%% TODO: make getBassChordDegree FD int
/* %% Root and 2nd inversion can be used freely. However, 2nd inversion is used less often (how often is controlled with args minPercent and maxPercent).
%% 3rd inversion (6/4 chord) is used only as "passing chord"
%% ?? or in a cadence leading into ...
%% */
proc {ConstrainChordInversion Chords Args}
   Defaults = unit(minPercent: 0
		   maxPercent: 30)
   As = {Adjoin Defaults Args}
in 
   {Pattern.percentTrue_Range {Map Chords fun {$ C} ({C getBassChordDegree($)} =: 2) end}
    As.minPercent As.maxPercent}
   %% TODO: constraint on 6/4
%    {Pattern.forNeighbours Chords 3 
%     proc {$ [C1 C2 C3]}
%        %% C2 is triad and 6/4 chord
%        Is_6_4_Chord = ...
%        {FD.impl Is_6_4_Chord
% 	...}
%     end}
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Aux for constraints etc 
%%

%% diatonic interval definition -- independent of 31 ET
Fifth = {FloatToInt {MUtils.ratioToKeynumInterval 3#2
		     {IntToFloat {HS.db.getPitchesPerOctave}}}}
MajSecond = {FloatToInt {MUtils.ratioToKeynumInterval 9#8
			 {IntToFloat {HS.db.getPitchesPerOctave}}}}


/** %% Returns FD int for absolute pitch interval between Note1 and Note2
%% */
%% NOTE: called multiple times: shall I muse memoization?
proc {GetInterval Note1 Note2 Interval}
   Interval = {FD.decl}
   {FD.distance {Note1 getPitch($)} {Note2 getPitch($)} '=:' Interval}
end


local
   PerfectConsonance = {FS.value.make [0 Fifth {HS.db.getPitchesPerOctave}]}
in
   /** %% B=1 <-> Interval (FD int) is perfect consonance (prime, fifths or octave).
   %% */
   proc {IsPerfectConsonanceR Interval B}
      B = {FS.reified.include Interval PerfectConsonance}
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Output
%%

%% Explorer output 
proc {RenderLilypondAndCsound I X}
   if {Score.isScoreObject X}
   then 
      FileName = out#{GUtils.getCounterAndIncr}#'-'#I#'-'#{OS.rand}
   in
      {ET31.out.renderAndShowLilypond X
       unit(file: FileName)}
      {Out.renderAndPlayCsound X
       unit(file: FileName)}
   end
end
{Explorer.object
 add(information RenderLilypondAndCsound
     label: 'to Lily + Csound: Homophonic Chord Progression')}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Solver calls
%%


/*


{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:9)
       rargs:unit(scale:{MakeScale 'D' 'major'}))}
 %% left-to-right strategy with breaking ties by type
 HS.distro.leftToRight_TypewiseTieBreaking}




%% allowing for different inversions: root inversion and sixth chords.
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:9
		  bassChordDegree: fd#(1#2))
       rargs:unit(scale:{MakeScale 'D' 'major'}))}
 HS.distro.leftToRight_TypewiseTieBreaking}


%% TODO: add further solver calls using args of MakeSchoenbergianProgression and cases in Example-Schoenberg-TheoryOfHarmony.muse


%% more chord types 

['major'
 'minor'
 'harmonic diminished'
 'augmented'
]

*/





/* %% compare performance of different distribution startegies

%% TODO: update to new HomophonicChordProgression interface

%% left-to-right strategy with breaking ties by type
{SDistro.exploreOne {GUtils.extendedScriptToScript HomophonicChordProgression
		     unit(key:'C'#'major'
			  n:7)}
 {Adjoin HS.distro.leftToRight_TypewiseTieBreaking
  unit(value:min)}}


%% type-wise distro
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript HomophonicChordProgression
		     unit(key:'C'#'major'
			  n:7)}
 {Adjoin HS.distro.typewise
  unit(value:min)}}



%% left-to-right strategy with breaking ties by type
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript HomophonicChordProgression
		     unit(key:'C'#'major'
			  n:7)}
 {Adjoin HS.distro.leftToRight_TypewiseTieBreaking
  unit(value:random)}}


*/


