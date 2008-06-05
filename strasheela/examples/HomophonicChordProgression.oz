
%%
%% This example implements a significant subset of Schoenberg's Theory of Harmony
%%
%%
%%
%% see also 
%% file:~/oz/music/Strasheela/private/examples/Schoenberg/PlanningAndThinking/SchoenbergHarmony.oz
%% 

%%
%% TODO:
%%
%% - I may notate the chord scale degrees with Roman numerals. Seems this is not predefined in lily. So, I would have to specify that the chord seq is ignored in Lily, and then define a special output for the bass notes which accesses the sim chords, translates their scale degree into a text string and prints that with a text markup.
%%

declare

%% 31 ET for enharmonic notation
%% NOTE: Enharmonic modulation with 31 ET is less strait forward that with 12 ET. However, using 31 ET is more strait forward for enharmonic notation that using enharmonic notes are -- the chord database does not contain accidental information...
%% BTW: 12 ET playback would be simple with 31 ET: just create a tuning table which maps 12 ET pitches on the 31 ET pitches :)  
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Preparation
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



%%
%% NOTE: TMP Distribution strategy
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
MyDistribution = unit(
		    value:min
		    % value:random % mid % min % 
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Chord database
%%


%% TODO: extend
ChordIndices = {Map ['major'
		     'minor'
		     'harmonic diminished'
		     'augmented'
		    ]
		HS.db.getChordIndex}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Top-level definition
%%

/*

%% Doc: Score topology

sim(sim(seq(note+)   % soprano 
	seq(note+))  % alto
    sim(seq(note+)   % tenor
	seq(note+))  % bass
    seq(chord+)
    %% NOTE: postpone modulation... if needed, refactor MyScript so that different scale  settings can be used
    %% ?? howto express overlapping for neutralising? ?? Use sim container + an easy to use constructor used like seq creation but which allows for negative offsetTimes (no problem for determined offsetTimes..).
    % seq/sim(scale+)
   )

*/

%% TODO: make some of the constraints controllable by args for flexibility
proc {MyScript Args ?MyScore}
   Defaults = unit(n:7		% number of chords
		   duration:2	% duration of each note and chord
		   timeUnit:beats
		   %% pair TranspositionName#IndexName
		   key:'C'#'major'
		  )
   As = {Adjoin Defaults Args}
   MyScale = {Score.makeScore scale(index:{HS.db.getScaleIndex As.key.2}
				    transposition:{ET31.pc As.key.1})
	      unit(scale:HS.score.scale)}
   fun {MakeVoiceNotes PitchDom}
      {LUtils.collectN As.n
       fun {$}
	  {Score.makeScore2
	   note(duration:As.duration
		pitch:{FD.int PitchDom}
		inChordB:1
		getChords: fun {$ Self}
			      {Self getSimultaneousItems($ test:HS.score.isChord)}
			   end
		isRelatedChord:proc {$ Self Chord B} B=1 end
		amplitude:64
		amplitudeUnit:velo
	       )
	   unit(note:HS.score.note)}
       end}
   end
   Chords = {LUtils.collectN As.n
	     fun {$}
		{Score.makeScore2 chord(duration:As.duration
					index:{FD.int ChordIndices}
					%% unused, just to remove symmetries 
					sopranoChordDegree:1)
		 unit(chord:HS.score.inversionChord)}
	     end}
   %% Pitch domain from Schoenberg's Harmonielehre, p. 36
   SopranoNotes = {MakeVoiceNotes {ET31.pitch 'C'#4}#{ET31.pitch 'A'#5}}
   AltoNotes = {MakeVoiceNotes {ET31.pitch 'G'#3}#{ET31.pitch 'E'#5}}
   TenorNotes = {MakeVoiceNotes {ET31.pitch 'C'#3}#{ET31.pitch 'A'#4}}
   BassNotes = {MakeVoiceNotes {ET31.pitch 'E'#2}#{ET31.pitch 'D'#4}}
in
   MyScore = {Score.makeScore
	      sim(items:[seq(items:[sim(items:[seq(items:SopranoNotes)
					       seq(items:AltoNotes)])])
			 seq(items:[sim(items:[seq(items:TenorNotes)
					       seq(items:BassNotes)])])
			 seq(info:lily("\\set Staff.instrumentName = \"Analysis\"")
			     items:Chords)]
		  startTime:0
		  timeUnit:As.timeUnit)
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
   %% Chord progression constraints
   %%
   %% Good progression: descending progression only as 'passing chords'
   {HS.rules.schoenberg.resolveDescendingProgressions Chords unit}
%    %% no super strong progression in such a simple progression
%    {Pattern.for2Neighbours Chords
%     proc {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2 0} end}
   %% First and last chords are root in root position
   {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   {Chords.1 getRoot($)} = {MyScale getRoot($)}
   {Chords.1 getBassChordDegree($)} = {{List.last Chords} getBassChordDegree($)} = 1
   %% TODO: TMP: allow for more inversions, but then constrain them accordingly
   {ForAll Chords proc {$ C} {C getBassChordDegree($)} = {FD.int 1#2} end}
   %% only diatonic chords
   {ForAll Chords proc {$ C} {HS.rules.diatonicChord C MyScale} end}
   %% last three chords form cadence with only strong progressions
   {HS.rules.cadence MyScale {LUtils.lastN Chords 3}}
   {Pattern.for2Neighbours {LUtils.lastN Chords 3}
    proc {$ C1 C2} {HS.rules.schoenberg.ascendingProgressionR C1 C2 1} end}
   %% 
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
%% Constraints 
%%


local
   /** %% Expects D (a FD int) and returns a singleton FS which contains only D.
   %% */
   proc {MakeSingletonSet D ?MyFS}
      MyFS = {FS.var.decl}
      {FS.include D MyFS}
      {FS.card MyFS 1}
   end
in
   /** %% MyChord and Notes are the chord and the notes at a time frame: all notes of the chord are played and no others.
   %% */
   proc {PlayAllChordTones MyChord Notes}
      {FS.unionN {Map Notes fun {$ N} {MakeSingletonSet {N getPitchClass($)}} end}
       {MyChord getPitchClasses($)}}
      {ForAll Notes
       proc {$ N} {FS.include {N getPitchClass($)} {MyChord getPitchClasses($)}} end}
   end
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


/** %% [Strict constraint for homophonic chord progression] If the two consecutive chords C1 and C2 share common pitches (harmonic band), then these occur occur in the same voice and octave (Schoenberg: harmonischen Band bleibt liegen). NotePairs is a list of two-note-pairs. Each pair consists of consecutive notes in the same voice and NotePairs together expresses C1 and C2. However, the bass notes are excluded. The voices in NotePairs are ordered increasing, so the bass is the first pair which is ignored. 
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Solver calls
%%

/*

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript MyScript
		     unit(key:'D'#'major'
			  n:7)}
 {Adjoin MyDistribution
  unit(value:random)}}

*/


