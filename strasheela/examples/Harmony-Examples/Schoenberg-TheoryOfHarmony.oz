
%%
%% This example implements a significant subset of Schoenberg's Theory of Harmony. Nevertheless, the example is created in 31 ET (not 12 ET) because this leads to a better enharmonic notation and intonation.
%% 
%% Usage: first feed buffer, then feed the actual examples (solver calls) in block comments are the end.
%%

%%
%% TODO:
%%
%% - Modulation already defined in HS.rules.modulation. For an example see 
%% file:~/oz/music/Strasheela/strasheela/trunk/strasheela/contributions/anders/HarmonisedScore/testing/Rules-test.oz::%% HS.rules.modulation
%%
%%
%% - I may notate the chord scale degrees with Roman numerals. Seems this is not predefined in lily. So, I would have to specify that the chord seq is ignored in Lily, and then define a special output for the bass notes which accesses the sim chords, translates their scale degree into a text string and prints that with a text markup.
%%   NOTE: some other Lily users use a \Lyrics context for roman numerals 
%%


declare

%% NOTE: Enharmonic modulation with 31 ET is less strait forward that with 12 ET. However, using 31 ET is more strait forward for enharmonic notation that using enharmonic notes are -- the chord database does not contain accidental information...
%% BTW: 12 ET playback would be simple with 31 ET: just create a tuning table which maps 12 ET pitches on the 31 ET pitches :)  
[ET31 Fenv] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf'
			   'x-ozlib://anders/strasheela/Fenv/Fenv.ozf']}
{HS.db.setDB ET31.db.fullDB}



/* % you can set the 31 note tuning table to 12 ET for comparison...

{Init.setTuningTable
 ET31.out.et31AsEt12_TuningTable}

{Init.setTuningTable
 ET31.out.meantone_TuningTable}

{Init.unsetTuningTable}

*/




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Top-level definition
%%



/** %% [TODO: update doc] Top-level script: creates a chord progression with the following score topology

sim(sim(seq(note+)   % soprano 
	seq(note+))  % alto
    sim(seq(note+)   % tenor
	seq(note+))  % bass
    seq(chord+)
    
   )
%%
%% Args:
%% iargs and rargs: args given to subscript MakeSchoenbergianProgression.
%% noteArgs: args given to MakeNNotes
%% lilyKey: Lilypond string for notating the key.
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
		   rargs: unit(makeScale: {MakeScaleConstructor 'C' 'major'} 
			       types: ['major' 'minor'])
		   lilyKey: "c \\major"
		   noteArgs: unit
		  )
   As = {GUtils.recursiveAdjoin Defaults Args}
   Chords = {MakeSchoenbergianProgression As}
   fun {MakeNNotes MinPitch MaxPitch}
      {MakeNotes {GUtils.recursiveAdjoin unit(iargs:unit(n:As.iargs.n
							 duration:As.iargs.duration)
					      rargs:unit(minPitch: MinPitch
							 maxPitch: MaxPitch))
		  As.noteArgs}}
   end
   %% Pitch domain from Schoenberg's Harmonielehre, p. 36
   SopranoNotes = {MakeNNotes 'C'#4 'A'#5}
   AltoNotes = {MakeNNotes 'G'#3 'E'#5}
   TenorNotes = {MakeNNotes 'C'#3 'A'#4}
   BassNotes = {MakeNNotes 'E'#2 'D'#4}
   End				% aux for unifying end times
in
   MyScore = {Score.makeScore
	      sim(items:[seq(info:lily("\\key " As.lilyKey)
			     [sim(items:[seq(info:soprano
					     items:SopranoNotes)
					 seq(info:alto
					     items:AltoNotes)])])
			 seq(info:lily("\\key " As.lilyKey)
			     [sim(items:[seq(info:tenor
					     items:TenorNotes)
					 seq(info:basso
					     items:BassNotes)])])
			 seq(info:[chords
				   lily("\\key " As.lilyKey
					"\\set Staff.instrumentName = \"Analysis\"")]
			     Chords
			     endTime:End)
			 seq(info:[scales]
			     [{As.rargs.makeScale}]
			     endTime:End)
			]
		  startTime:0)
	      unit}
   {WellformednessEtcConstraints MyScore}
end


% fun {MakeVoices Args ?MyScore}
%    Defaults = unit(chords:nil
% 		   lilyKey: "c \\major"
% 		  )
%    As = {GUtils.recursiveAdjoin Defaults Args}
%    Chords = As.chords
%    fun {MakeNNotes MinPitch MaxPitch}
%       {MakeNotes unit(iargs:unit(n:As.iargs.n
% 				 duration:As.iargs.duration)
% 		      rargs:unit(minPitch: MinPitch
% 				 maxPitch: MaxPitch))}
%    end
%    %% Pitch domain from Schoenberg's Harmonielehre, p. 36
%    SopranoNotes = {MakeNNotes 'C'#4 'A'#5}
%    AltoNotes = {MakeNNotes 'G'#3 'E'#5}
%    TenorNotes = {MakeNNotes 'C'#3 'A'#4}
%    BassNotes = {MakeNNotes 'E'#2 'D'#4}
%    End				% aux for unifying end times
% in
%    MyScore = {Score.make2
% 	      sim(items:[seq(info:lily("\\key " As.lilyKey)
% 			     [sim(items:[seq(info:soprano
% 						   items:SopranoNotes)
% 					       seq(info:alto
% 						   items:AltoNotes)])])
% 			 seq(info:lily("\\key " As.lilyKey)
% 			     [sim(items:[seq(info:tenor
% 						   items:TenorNotes)
% 					       seq(info:bass
% 						   items:BassNotes)])])
% 			 seq(info:lily("\\key " As.lilyKey
% 				       "\\set Staff.instrumentName = \"Analysis\"")
% 			     Chords
% 			     endTime:End)
% 			 %% ?? TMP
% 			 seq([As.rargs.scale]
% 			     endTime:End)
% 			]
% 		  startTime:0)
% 	      unit}
%    %% add scale to chord infos
%    {ForAll Chords proc {$ C} {C addInfo(scale(As.rargs.scale))} end}
%    %%
%    %% 'wellformedness' constraints
%    %%
%    %% Constrain 'time slice' of chord and corresponding notes
%    {ForAll {LUtils.matTrans [Chords BassNotes TenorNotes AltoNotes SopranoNotes]}
%     proc {$ [C BN TN AN SN]}
%        {PlayAllChordTones C [BN TN AN SN]}
%        {NoVoiceCrossing [BN TN AN SN]}
%        {ConstrainUpperVoiceDistance [BN TN AN SN]}
%        %% Note: soprano is ignored here, but I need bass for BassChordDegree
%        {C getBassPitchClass($)} = {BN getPitchClass($)}
%     end}
%    %%
%    %% melodic constraints
%    {ForAll [TenorNotes AltoNotes SopranoNotes]
%     proc {$ Notes}
%        {RestrictMelodicIntervals_UpperVoices Notes
% 	unit(minPercent:70
% 	     maxPercent:100)}
%     end}
%    {RestrictMelodicIntervals_Bass BassNotes}
%    %%
%    %% constraints on pairs for chords and notes 
%    {Pattern.for2Neighbours {LUtils.matTrans
% 			    [Chords BassNotes TenorNotes AltoNotes SopranoNotes]}
%     proc {$ [C1 BN1 TN1 AN1 SN1] [C2 BN2 TN2 AN2 SN2]}
%        NotePairs = [BN1#BN2 TN1#TN2 AN1#AN2 SN1#SN2]
%     in
%        {CommonPitchesHeldOver C1#C2 NotePairs}
%        {NoParallels NotePairs}
%     end}
% end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Music representation and sub-scripts
%%

/** %% Returns a scale object, expects the key and type as atoms, e.g., {MakeScale 'C' 'major'}
%% */
fun {MakeScaleConstructor Key ScaleType}
   fun {$}
      {Score.make2 scale(index:{HS.db.getScaleIndex ScaleType}
			 transposition:{ET31.pc Key})
       unit(scale:HS.score.scale)}
   end
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
	idefaults: unit(%% add support for fd # Dom arg specs with Score.makeConstructor
			constructor: {Score.makeConstructor
% 				      HS.score.inversionChord
% 				      HS.score.scaleDegreeNote
				      HS.score.fullNote
				      unit}
			getChords: fun {$ Self}
				      [{Self findSimultaneousItem($ test:HS.score.isChord)}]
				   end
			inChordB:1
			getScales:fun {$ Self} [{Self findSimultaneousItem($ test:HS.score.isScale)}] end
			inScaleB:1
			scaleAccidental:Natural
			chordAccidental: Natural)
	rdefaults: unit(minPitch:'C'#3
			maxPitch:'C'#6
		       ))
   proc {$ Notes Args} 
      {HS.rules.restrictPitchDomain Notes Args.rargs.minPitch Args.rargs.maxPitch}
   end}


/** %% Extended script which returns a list of chords following (different versions of) Schoenberg's rule proposals for root progressions. This is a sub-script of HS.score.makeChords, all arguments of HS.score.makeChords are supported as well.
%%
%% Args.rargs:
%% 'progressionSelector': arg (atom or record) given to HS.rules.schoenberg.progressionSelector, see doc there. If false, this constraint is skipped.
%% 'maxPercentSuperstrong' (default false): maximum percentage of the superstrong progressions permitted (false means this constraint is switched off).
%% 'cadenceN' (default 3): how many chords at end form cadence (sound all chord PCs) (false means this constraint is switched off)
%% 'onlyAscendingInCadence' (default true): Boolean whether the cadence consists only of ascending progressions
%%
%% Args.iargs:
%% all HS.score.inversionChord init argument, including dom specifications in the form fd#Dom
%%
%% Note: the scale to which chords are related is simultaneous scale, so there can be multiple scales involved.
%% */
MakeSchoenbergianProgression
= {Score.defSubscript
   unit(super:HS.score.makeChords
	idefaults: unit(%% add support for fd # Dom arg specs with Score.makeConstructor
			constructor: {Score.makeConstructor
% 				      HS.score.inversionChord
				      HS.score.fullChord
				      unit}
			bassChordDegree: 1
			getScales:fun {$ Self} [{Self findSimultaneousItem($ test:HS.score.isScale)}] end
			inScaleB:1)
	rdefaults: unit(progressionSelector:resolveDescendingProgressions
			maxPercentSuperstrong: false
			cadenceN: 3
			onlyAscendingInCadence: true
		       ))
   proc {$ Chords Args}
      if Args.rargs.progressionSelector \= false then
	 {HS.rules.schoenberg.progressionSelector Chords Args.rargs.progressionSelector}
      end
      if Args.rargs.maxPercentSuperstrong \= false then  
	 %% NOTE: this rule makes the problem harder
	 {Pattern.percentTrue_Range
	  {Pattern.map2Neighbours Chords
	   fun {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2} end}
	  0 Args.rargs.maxPercentSuperstrong}
      end
      %% First and last chords are root in root position
      {HS.rules.distinctR Chords.1 {List.last Chords} 0}
      {Chords.1 getRoot($)} = {{Chords.1 getScales($)}.1 getRoot($)}
      {Chords.1 getBassChordDegree($)} = {{List.last Chords} getBassChordDegree($)} = 1
      %% only diatonic chords
%       {ForAll Chords proc {$ C} {HS.rules.diatonicChord C MyScale} end}
      if Args.rargs.cadenceN \= false then
	 LastChords = {LUtils.lastN Chords Args.rargs.cadenceN}
      in
	 %% last chords form cadence with only strong progressions
	 %% We assume all last cadenceN chords have same scale
	 {HS.rules.cadence {LastChords.1 getScales($)}.1 LastChords}
	 if Args.rargs.onlyAscendingInCadence then 
	    {Pattern.for2Neighbours LastChords
	     proc {$ C1 C2} {HS.rules.schoenberg.ascendingProgressionR C1 C2 1} end}
	 end
      end
   end}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Constraints 
%%


/** %% Constraint for wrapping a number of constraints.
%% Note: the containers for the voices and chords/scales must be marked with an info tag as soprano, alto, tenor, basso and chords.
%% */
proc {WellformednessEtcConstraints MyScore}
   fun {MakeIsThisSeq Info}
      fun {$ X} {X isSequential($)} andthen {X hasThisInfo($ Info)} end
   end
   SopranoNotes = {{MyScore find($ {MakeIsThisSeq soprano})} getItems($)}
   AltoNotes = {{MyScore find($ {MakeIsThisSeq alto})} getItems($)}
   TenorNotes = {{MyScore find($ {MakeIsThisSeq tenor})} getItems($)}
   BassNotes = {{MyScore find($ {MakeIsThisSeq basso})} getItems($)}
   Chords = {{MyScore find($ {MakeIsThisSeq chords})} getItems($)}
in 
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
       %% TMP: testing ResolveDissonances_ChordDegree
       {ResolveDissonances_ChordDegree Notes unit}
    end}
   {RestrictMelodicIntervals_Bass BassNotes}
   %% TMP: testing ResolveDissonances_ChordDegree
   {ResolveDissonances_ChordDegree BassNotes unit}
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
       {HS.rules.getInterval N1 N2} =<: {HS.db.getPitchesPerOctave}
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
%% NotePairs is same are as in CommonPitchesHeldOver.
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
    {HS.rules.isPerfectConsonanceR {HS.rules.getInterval N1B N2B}}
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
   Intervals = {Pattern.map2Neighbours Notes HS.rules.getInterval}
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
   Intervals = {Pattern.map2Neighbours Notes HS.rules.getInterval}
in
   {ForAll Intervals
    proc {$ X}
       {Pattern.disjAll [(X =<: Fourth) (X =: Fifth) (X =: Octave)] 1}  end}
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



/** %% Constraints that every chord in Chords which is not a consonant chord is resolved by a root progression a fourth upwards. The last chord is implicitly constrained to be a consonant chord.
%%
%% Args:
%% 'consonantChords' (default ['major' 'minor']): list of chord types (atoms of chord names) specifying which chords are considered consonant.
%%
%% */
%% TODO: unfinished
proc {ResolveDissonancesByFourth Chords Args}
   Default = unit(consonantChords:['major' 'minor'])
   As = {Adjoin Args Default}
   ConsonantChordIndices = {Map As.consonantChords HS.db.getChordIndex}
   %% TMP put scale in for testing
   MyScale = {{MakeScaleConstructor 'C' 'major'}}
   %% boolean constraint whether chord C is consonant
   fun {IsConsonantR C}
      {Pattern.disjAll
       {Map ConsonantChordIndices
	fun {$ ConsIndex} {C getIndex($)} =: ConsIndex end}}
   end
   proc {FourthProcession C1 C2}
      %% TMP comment
%       MyScale = {C1 getInfoRecord($ scale)}.1
      RootDegree1 = {HS.score.getDegree {C1 getRoot($)} MyScale unit}
      RootDegree2 = {HS.score.getDegree {C2 getRoot($)} MyScale unit}
   in
      {HS.score.transposeDegree {MyScale getPitchClasses($)}
       RootDegree1#{C1 getRoot($)}
       4#{FD.decl}
       RootDegree2#{C2 getRoot($)}}
   end
in
   {Pattern.for2Neighbours Chords
    proc {$ C1 C2}
       {FD.impl {FD.nega {IsConsonantR C1}}
	{Combinator.reify
	 proc {$} {FourthProcession C1 C2} end}
	1}
    end}
   {IsConsonantR {List.last Chords} 1}
end


/** %% Constraints that
%%
%% Notes is list of notes of a voice
%%
%% NOTE: this solution is not generic, it only works for chords where dissonances are at the highest chord degrees (e.g., seventh chords, diminished chords). Counter example: ninth chord, where 2nd chord degree is already a dissonance (chord degrees are position of tone in untransposed PC sequence ordered by size, and always starting with the root, cf. HS.db.ratiosInDBEntryToPCs).
%% Generalisation: in chord DB entry explicitly list the dissonant PCs etc..
%% 
%% */
%%
%%
%% NB: this constraint only works for homophonic music
%% NB: for this constraint to work, chord database must be defined such that dissonances are higher chord degrees -- are PCs of chord DB entries sorted automatically, then this constraint does not necessarily work.
%%
%% simplified for conventional theory: if note's chord degree > 3, then it is 7th, 9th .. i.e. a dissonance. Treatment, e.g., by stepwise resolution. Schoenberg: note decends by step, or stays 
%%
% NB: no preparation possible with this approach, but I could do without that anyway 
%%
%% For chords like diminished triad, approach must be extended: extended def depending on note's chord index/type besides note's chord degree
%%
%% Can I access chord itself from note for this constraint instead of adding params to note object -- there is always only a single related chord...
%%
%% TODO:
%% - OK care for diminished ect: need to access chord to access chord index
%% - Generalise with args for reuse
%%   - make resolution controllable by arg (e.g. is step up allowed too?)
%% - !! documentation
%% - !! generalise such that it constraints chords not only notes, so it can be used for non-homophonic music too (resolution in "wrong" octave OK, but that should actually happen more rarely?)
%%   -> check whether chord's cardinality > corresponding minDissonanceDegree, and if so then access all PCs of dissonant chord degrees. Constrain that next chord contains PCs that resolve these dissonances   
%%
proc {ResolveDissonances_ChordDegree Notes Args /* Args unused */}
   Default = unit(step: 8#7
		  %% format:
		  %% integer feat (denoting min dissonance degree) with list of corresponding chords. Also index integers supported.
		  %% feat default: default min diss degree
		  dissonantChordDegrees: unit(3: ['geometric diminished'
						  'halve-diminished 7th'
						  'augmented']
					      default: 4)
		  lastConsonant: true
		 )
   As = {Adjoin Args Default}
   MaxStep = {HS.score.ratioToInterval As.step}
   /** %% Expects a chord index and returns the corresponding min chord degree that is dissonant for this index.
   %% */
   fun {GetMinDissChordDegree Index}
      IndexTable = {List.toRecord unit
		    {LUtils.mappend {Record.toListInd
				     {Record.subtract As.dissonantChordDegrees default}}
		     fun {$ MaxDiss#ChordNames}
			{Map ChordNames
			 fun {$ ChordName}
			    Index = if {IsInt ChordName} then ChordName
				    else {HS.db.getChordIndex ChordName}
				    end
			 in
			    Index#MaxDiss end}
		     end}}
   in
      if {HasFeature IndexTable Index} then 
	 IndexTable.Index
      else As.dissonantChordDegrees.default 
      end
   end
in
   {Pattern.for2Neighbours Notes
    proc {$ N1 N2}
       thread  % wait until sim chord accessible
	  MinDissDegree = {GetMinDissChordDegree {{N1 getChords($)}.1 getIndex($)}}
       in
	  {FD.impl
	   %% if dissonance
	   ({N1 getChordDegree($)} >=: MinDissDegree)
	   {FD.conj
	    %% then proceed at max by MaxStep down or repeat pitch 
	    {FD.reified.distance {N1 getPitch($)} {N2 getPitch($)} '=<:' MaxStep}
	    ({N1 getPitch($)} >=: {N2 getPitch($)})}
	1}
       end
    end}
   if As.lastConsonant then 
      thread  % wait until sim chord accessible
	 %% last note consonant
	 LastMinDissDegree = {GetMinDissChordDegree
			      {{{List.last Notes} getChords($)}.1 getIndex($)}}
      in
	 {{List.last Notes} getChordDegree($)} <: LastMinDissDegree
      end
   end
end



/** %% [TODO: doc]
%% */
%% Constraint on chords: if chord contains raised VI (VII degree) of minor scale, then consecutive chord contains raised VII (I) degree.
%% Only raised VI and VII are permitted, all other scale degrees must be natural (note: latter restriction only applied to Chord1)
proc {ResolveTurnpointsInMinor Chord1 Chord2}
   MyScale = {Chord1 getScales($)}.1
   RaisedVI_PC = {FD.decl}
   RaisedVII_PC = {FD.decl}
   I_PC = {FD.decl}
   FullPCsDomain =  {FS.var.decl}
in
   RaisedVI_PC = {MyScale degreeToPC(6 Sharp $)}
   RaisedVII_PC = {MyScale degreeToPC(7 Sharp $)}
   I_PC = {MyScale degreeToPC(1 Natural $)}
   %% PCs of scale plus raised VI and VII 
   FullPCsDomain = {FS.unionN [{MyScale getPitchClasses($)}
			    {GUtils.makeSingletonSet RaisedVI_PC}
			    {GUtils.makeSingletonSet RaisedVII_PC}]}
   %%
   {FD.impl {FS.reified.include RaisedVI_PC {Chord1 getPitchClasses($)}}
    {FD.disj
     {FS.reified.include RaisedVI_PC {Chord2 getPitchClasses($)}}
     {FS.reified.include RaisedVII_PC {Chord2 getPitchClasses($)}}}
    1}
   {FD.impl {FS.reified.include RaisedVII_PC {Chord1 getPitchClasses($)}}
    {FD.disj
     {FS.reified.include RaisedVII_PC {Chord2 getPitchClasses($)}}
     {FS.reified.include I_PC {Chord2 getPitchClasses($)}}}
    1}
   {FS.subset {Chord1 getPitchClasses($)} FullPCsDomain}
end


/* %% TMP test

declare
C_Major = {Score.make scale(index:{HS.db.getScaleIndex major}
			    transposition:0)
	   unit(scale:HS.score.scale)}
D_Major = {Score.make scale(index:{HS.db.getScaleIndex major}
			    transposition:{ET31.pc 'D'})
	   unit(scale:HS.score.scale)}

declare
RaisedVI_PC = {FD.decl}
RaisedVI_PC = {C_Major degreeToPC(7 Sharp $)}




declare
PCDomain = 0#{HS.db.getPitchesPerOctave}-1
Transposition = {C_Major getTransposition($)}
UntranspPCsFS = {C_Major getUntransposedPitchClasses($)}
N = {FS.card UntranspPCsFS}
%% !! blocks until N is determined (i.e. @index is determined or all chords/scales in database or index domain are of equal length)
UntranspPCsList = {FD.list N PCDomain} 
TranspPCsList = {FD.list N PCDomain}
%%
%% !!?? is matching a good idea: shall PCs always be in
%% increasing order in UntranspPCsList
{FS.int.match UntranspPCsFS UntranspPCsList}
{ForAll {LUtils.matTrans [UntranspPCsList TranspPCsList]}
 proc {$ [UntranspPC TranspPC]}
    {HS.score.transposePC UntranspPC Transposition TranspPC}
 end}




declare
PCDomain = 0#{HS.db.getPitchesPerOctave}-1
Transposition = {D_Major getTransposition($)}
UntranspPCsFS = {D_Major getUntransposedPitchClasses($)}
N = {FS.card UntranspPCsFS}
%% !! blocks until N is determined (i.e. @index is determined or all chords/scales in database or index domain are of equal length)
UntranspPCsList = {FD.list N PCDomain} 
TranspPCsList = {FD.list N PCDomain}


%% !!?? is matching a good idea: shall PCs always be in
%% increasing order in UntranspPCsList
{FS.int.match UntranspPCsFS UntranspPCsList}

{ForAll {LUtils.matTrans [UntranspPCsList TranspPCsList]}
 proc {$ [UntranspPC TranspPC]}
    {HS.score.transposePC UntranspPC Transposition TranspPC}
 end}


RaisedVI_PC = {DegreeToPC TranspPCsList 6#Sharp}


{DegreeToPC TranspPCsList Degree#Accidental PC}


*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Aux for constraints etc 
%%

%%
%% TODO:
%%
%% - add constraints Is3LimitR, Is5LimitR, Is7LimitR, constraining a PC interval
%% - move these constaints and IsPerfectConsonanceR to HS.rules
%% - move NoParallels to HS.rules
%%

%% diatonic interval definition -- independent of 31 ET
Octave = {HS.score.ratioToInterval 2#1}
Fifth = {HS.score.ratioToInterval 3#2}
Fourth = {HS.score.ratioToInterval 4#3}
MajSecond = {HS.score.ratioToInterval 9#8}


Natural = {HS.score.absoluteToOffsetAccidental 0}
Sharp = {HS.score.absoluteToOffsetAccidental 2}
Flat = {HS.score.absoluteToOffsetAccidental ~2}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Output
%%

/** %% Expects an integer (in 1-7) and returns the corresponding Roman numeral (a VS).
%% */
fun {IntToRoman I}
   unit("I"
	"II"
	"III"
	"IV"
	"V"
	"VI"
	"VII").I
end
/* %% Expects a chord and returns the chord's scale degree (Roman numeral). The scale of a chord must be accessible via the chords info tag chord. (if MyChord is no chord then nil is retured)
%% */
fun {MakeChordDegree MyChord}
   if {HS.score.isChord MyChord}
   then 
%    MyScale = {MyChord getInfoRecord($ scale)}.1
      MyScale = {MyChord getScales($)}.1
   in
      {IntToRoman
       {HS.score.getDegree {MyChord getRoot($)} MyScale unit}}
   else nil
   end
end
/** %% Expects soundfile with full path but without extension and renders mp3 file.
%% */
proc {EncodeMP3 SoundFile}
   %% notlame 
%       {Out.exec notlame ["-h" SoundFile#".aiff" SoundFile#".mp3"]}
   %% lame
   {Out.exec "lame" ["-V2" SoundFile#".aiff" SoundFile#".mp3"]}
end

LilyHeader 
= "\\paper {
  indent=0\\mm
  line-width=180\\mm 
  oddFooterMarkup=##f
  oddHeaderMarkup=##f
  bookTitleMarkup=#ff
  scoreTitleMarkup=##f
}\n\n\\score{"


/** %% X is a scale containing one (or more) scales.
%% */
fun {IsScaleSeq X}
   {X isSequential($)} andthen {HS.score.isScale {X getItems($)}.1}
end

EventToCsound_adaptiveJI 
= {Out.makeEvent2CsoundFn 1
   [getStartTimeParameter#getValueInSeconds
    fun {$ X} X end#getDurationInSeconds
    getAmplitudeParameter#getValueInNormalized
    %% max 127 velo results in max 90 dB (Csound amp value 31622.764)
%     getAmplitudeParameter#fun {$ X} {MUtils.levelToDB {X getValueInNormalized($)} 1.0} + 90.0 end
    fun {$ X} X end#fun {$ MyNote}
		       JIPitch = {HS.score.getAdaptiveJIPitch MyNote unit}
		       ETPitch = {MyNote getPitchInMidi($)}
		    in
		       %% if JI pitch is at least a syntonic comma off, then show it
		       if {Abs JIPitch-ETPitch} >= 0.2151 
		       then
			  {Browse
			   large_JI_offset(ji:{HS.score.getAdaptiveJIPitch MyNote unit}
					   midi: {MyNote getPitchInMidi($)}
					   note:{MyNote toInitRecord($)}
					   chordIndex: {{MyNote getChords($)}.1 getIndex($)}
					   chordTransposition: {{MyNote getChords($)}.1 getTransposition($)}
					   chordPCs: {{MyNote getChords($)}.1 getPitchClasses($)}
					   chordRatios: {HS.db.getUntransposedRatios {MyNote getChords($)}.1}
					   noteDegreeInChord: {HS.score.getDegree {MyNote getPitchClass($)} {MyNote getChords($)}.1 unit(accidentalRange: 0)}
					  )}
		       end
		       JIPitch
		    end
   ]}

	     
%% Explorer output 
proc {RenderLilypondAndCsound I X}
   if {Score.isScoreObject X}
   then 
      FileName = "Schoenberg-"#I#"-"#{GUtils.getCounterAndIncr}
   in
      {Fenv.renderAndPlayMidiFile X
       unit(file: FileName
	    %% max 8 microtonal voices distributed over 8 MIDI chans
	    channelDistributions: unit(0:[0 1 2 3 4 5 6 7]))} 
      {ET31.out.renderAndShowLilypond X
       unit(file: FileName
% 	    flags:["--preview"]  % does not work with newer Lily versions?
	    flags:["-dbackend=eps" "-dno-gs-load-fonts" "-dinclude-eps-fonts"]
	    wrapper: [LilyHeader 
		      "\n}"]
	    %% Skip notating scales
	    clauses:[IsScaleSeq#fun {$ _} "" end]
	    lowerMarkupMakers: [MakeChordDegree]
	   )}
      {Out.renderAndPlayCsound X
       unit(file: FileName)} 
      {EncodeMP3 {Init.getStrasheelaEnv defaultSoundDir}#FileName}
   end
end
proc {RenderLilypondAndCsound_AdaptiveJI I X}
   if {Score.isScoreObject X}
   then 
      FileName = "Schoenberg-"#I#"-"#{GUtils.getCounterAndIncr}#"-adaptiveJI"
   in
      {ET31.out.renderAndShowLilypond X
       unit(file: FileName
% 	    flags:["--preview"]  % does not work with newer Lily versions?
	    flags:["-dbackend=eps" "-dno-gs-load-fonts" "-dinclude-eps-fonts"]
	    wrapper: [LilyHeader 
		      "\n}"]
	    %% Skip notating scales
	    clauses:[IsScaleSeq#fun {$ _} "" end]
	    lowerMarkupMakers: [MakeChordDegree
				HS.out.makeAdaptiveJI_Marker
				%% default marking
% 				HS.out.makeChordComment_Markup
% 				HS.out.makeScaleComment_Markup
			       ]
	   )}
      {Out.renderAndPlayCsound X
       unit(file: FileName
	    event2CsoundFn: EventToCsound_adaptiveJI
% 	    orc: 'pluck.orc'
	   )}
      {EncodeMP3 {Init.getStrasheelaEnv defaultSoundDir}#FileName}
   end
end
{Explorer.object
 add(information RenderLilypondAndCsound_AdaptiveJI
     label: 'to Lily + Csound: Schoenberg (adaptive JI)')}
{Explorer.object
 add(information RenderLilypondAndCsound
     label: 'to MIDI, Lily + Csound: Schoenberg')}


/* % Explorer output which shows ratios of chord pitches instead of degrees

declare	     
%% Explorer output 
proc {RenderLilypondAndCsound I X}
   if {Score.isScoreObject X}
   then 
      FileName = "Schoenberg-"#I#"-"#{GUtils.getCounterAndIncr}
   in
      {Browse ok1}
      {ET31.out.renderAndShowLilypond X
       unit(file: FileName
	    chordDescription:ET31.out.makeChordRatios
	    flags:["-dbackend=eps" "-dno-gs-load-fonts" "-dinclude-eps-fonts"]
	    wrapper: [LilyHeader 
		      "\n}"]
	    %% Skip notating scales
	    clauses:[IsScaleSeq#fun {$ _} "" end]
	   )}
      {Browse ok2}
      {Out.renderAndPlayCsound X
       unit(file: FileName)}
      {EncodeMP3 {Init.getStrasheelaEnv defaultSoundDir}#FileName}
   end
end
{Explorer.object
 add(information RenderLilypondAndCsound
     label: 'to Lily + Csound: Schoenberg 2')}


*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Solver calls
%%


/*


%% NOTE: no solution -- check HomophonicChordProgression def why it is overconstraint (has this to do with new diss treatment?)
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:4)
       rargs:unit(makeScale:{MakeScaleConstructor 'D' 'major'})
       lilyKey: "d \\major")}
 %% left-to-right strategy with breaking ties by type
 HS.distro.leftToRight_TypewiseTieBreaking}



{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:9)
       rargs:unit(makeScale:{MakeScaleConstructor 'D' 'major'})
       lilyKey: "d \\major")}
 %% left-to-right strategy with breaking ties by type
 HS.distro.leftToRight_TypewiseTieBreaking}




%% allowing for different inversions: root inversion and sixth chords.
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:9
		  bassChordDegree: fd#(1#2))
       rargs:unit(makeScale:{MakeScaleConstructor 'D' 'major'}))}
 HS.distro.leftToRight_TypewiseTieBreaking}


%% TODO: add further solver calls using args of MakeSchoenbergianProgression and cases in Example-Schoenberg-TheoryOfHarmony.muse



%% Allow for diminished (no dissonance treatment!)
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:9)
       rargs:unit(makeScale:{MakeScaleConstructor 'C' 'major'}
		  types: ['major' 'minor' 'geometric diminished'])
%        lilyKey: "d \\major"
      )}
 %% left-to-right strategy with breaking ties by type
 HS.distro.leftToRight_TypewiseTieBreaking}




*/


/* % Examples for Muse/HTML file 

%% Harmonic band, only root inversion, only consonances, no cadence  
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:5
		  bassChordDegree: 1)
       rargs:unit(progressionSelector:harmonicBand
		  cadenceN:false))}
 HS.distro.leftToRight_TypewiseTieBreaking}


%% Harmonic band, only root inversion, only consonances, but now cadence  
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:6
		  bassChordDegree: 1)
       rargs:unit(progressionSelector:harmonicBand
		  cadenceN:3
		  onlyAscendingInCadence:false
		 ))}
 HS.distro.leftToRight_TypewiseTieBreaking}

%% Cadence in different key 
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:5
		  bassChordDegree: 1)
       rargs:unit(makeScale:{MakeScaleConstructor 'Bb' 'major'}
		  progressionSelector:harmonicBand
		  cadenceN:3
		  onlyAscendingInCadence:false
		 )
       lilyKey: "bes \\major")}
 HS.distro.leftToRight_TypewiseTieBreaking}



%% Harmonic band, root inversion and second inversion
%%
%% Option: add constraints which improves melodic "shape" of bass
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:5
		  bassChordDegree: fd#(1#2))
       rargs:unit(progressionSelector:harmonicBand))}
 HS.distro.leftToRight_TypewiseTieBreaking}


%% revised root progression rules (ascending progressions etc)
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:9
		  bassChordDegree: fd#(1#2))
       rargs:unit)}
 HS.distro.leftToRight_TypewiseTieBreaking}


%% same as before, but now limit number of super strong progressions
%% TODO: also reduce number of superstrong progressions
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:11
		  bassChordDegree: fd#(1#2))
       rargs:unit(maxPercentSuperstrong:20))}
 HS.distro.leftToRight_TypewiseTieBreaking}


%% often too strict, but interesting alternative: only allow for ascending progressions 
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:9
		  bassChordDegree: fd#(1#2))
       rargs:unit(progressionSelector:ascending))}
 HS.distro.leftToRight_TypewiseTieBreaking}


%% allow for seventh and diminished chords.
%% resolve every dissonance by a root progression fourth upwards the fundament
%% TODO: unfinished
% {GUtils.setRandomGeneratorSeed 0}
% {SDistro.exploreOne
%  {GUtils.extendedScriptToScript HomophonicChordProgression
%   unit(iargs:unit(n:7
% 		  bassChordDegree: fd#(1#2)
% 		  rule: proc {$ Chords}
% 			   {ResolveDissonancesByFourth Chords unit}
% 			end)
%        rargs:unit(types: ['major' 'minor' 'geometric diminished'
% 			  'dominant 7th' 'major 7th' 'minor 7th' 'halve-diminished 7th'
% 			 ]))}
%  HS.distro.leftToRight_TypewiseTieBreaking}



%% NEW: voice-wise dissonance treatment
%% Allow for seventh and diminished chords. Dissonance treatment by ResolveDissonances_ChordDegree applied in WellformednessEtcConstraints.   
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:9
		  bassChordDegree: fd#(1#2))
       rargs:unit(types: ['major' 'minor' 'geometric diminished' % 'augmented' 
			  'dominant 7th' 'major 7th' 'minor 7th' 'halve-diminished 7th'
			 ]
		  maxPercentSuperstrong:20))}
 HS.distro.leftToRight_TypewiseTieBreaking}


%% NOTE: OLD
%% allow for seventh and diminished chords.
%% Note: poor mans diss resolution so far
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:9
		  bassChordDegree: fd#(1#2)
		  rule: proc {$ Chords}
			   {HS.rules.resolveDissonances Chords unit}
			end)
       rargs:unit(types: ['major' 'minor' 'geometric diminished' 
			  'dominant 7th' 'major 7th' 'minor 7th' 'halve-diminished 7th'
			 ]
		  maxPercentSuperstrong:20))}
 HS.distro.leftToRight_TypewiseTieBreaking}



%% natural minor 
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:9
		  bassChordDegree: fd#(1#2)
		  rule: proc {$ Chords}
			   {HS.rules.resolveDissonances Chords unit}
			end)
       rargs:unit(makeScale:{MakeScaleConstructor 'C' 'natural minor'}
		  types: ['major' 'minor' 'geometric diminished' 'augmented']
		  maxPercentSuperstrong:20)
       lilyKey: "c \\minor"
      )}
 %% left-to-right strategy with breaking ties by type
 HS.distro.leftToRight_TypewiseTieBreaking}


%% minor with turning points: use note params scaleDegree and scaleAccidental
%% allow for accidental Natural and Sharp. if VI or VII is sharp then, next note is following degree -- this is relaxed version of Schoenberg's rule
%% TODO: make butlast chord use raised VII
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:13
		  bassChordDegree: fd#(1#2)
		  inScaleB: fd#(0#1)
		  rule: proc {$ Chords}
			   {HS.rules.resolveDissonances Chords unit}
			   {Pattern.for2Neighbours Chords ResolveTurnpointsInMinor}
			end
		 )
       rargs:unit(
		cadenceN: false	
		makeScale:{MakeScaleConstructor 'C' 'natural minor'}
% 		types: ['major' 'minor' 'geometric diminished' 'augmented']
		types: ['major' 'minor' 'geometric diminished' 'augmented'
			  'dominant 7th' 'major 7th' 'minor 7th' 'halve-diminished 7th'
			 ]
% 		  maxPercentSuperstrong:20
		 )
       noteArgs:unit(iargs:unit(inScaleB:fd#(0#1)
				scaleAccidental:fd#[Natural Sharp]))
       lilyKey: "c \\minor"
      )}
 %% left-to-right strategy with breaking ties by type
 HS.distro.leftToRight_TypewiseTieBreaking}




%% using non-conventional scales and chords: septimal minor
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:9
% 		  bassChordDegree: fd#(1#2)
		  inScaleB:1
% 		  inScaleB: fd#(0#1)
% 		  rule: proc {$ Chords}
% 			   {HS.rules.resolveDissonances Chords
% 			    unit(consonantChords:['subminor' '4-6-7' 'subminor 7th'])}
% % 			   {Pattern.for2Neighbours Chords ResolveTurnpointsInMinor}
% 			end
		 )
       rargs:unit(
		makeScale:{MakeScaleConstructor 'C' 'septimal natural minor'}
		cadenceN: 4
% 		onlyAscendingInCadence: false
% 		progressionSelector: false
		progressionSelector: harmonicBand
% 		progressionSelector:resolveDescendingProgressions
% 		types: false
		types: ['subminor' '4-6-7' 'subminor 7th'
			'harmonic diminished' '5-7-9'
			'supermajor' 'subharmonic 4-6-7'
			'Pepper\'s Square']
% 		  maxPercentSuperstrong:20
		 )
       noteArgs:unit(iargs:unit(inScaleB:1))
       lilyKey: "c \\major"
      )}
 %% left-to-right strategy with breaking ties by type
 HS.distro.leftToRight_TypewiseTieBreaking}




%% using non-conventional scales and chords: 
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 {GUtils.extendedScriptToScript HomophonicChordProgression
  unit(iargs:unit(n:13
		  bassChordDegree: fd#(1#2)
		  inScaleB:1
		 )
       rargs:unit(
		makeScale:{MakeScaleConstructor 'C' 'Hahn pentachordal'}
		cadenceN: 4
% 		onlyAscendingInCadence: false
% 		progressionSelector: false
% 		progressionSelector: harmonicBand
% 		progressionSelector:resolveDescendingProgressions
		progressionSelector:ascending
% 		types: false
		types: ['major 7th' 'harmonic 7th' 'subminor' 'subminor 7th' 'Hendrix chord'
			'Tristan chord' 'french 6th' '15-limit ASS 2' '11-limit ASS' 'subharmonic 4-6-7'
		       'harmonic diminished' 'Pepper\'s Square' 'augmented' 'augmented major 7th']
% 		  maxPercentSuperstrong:20
		 )
       noteArgs:unit(iargs:unit(inScaleB:1))
       lilyKey: "c \\major"
      )}
 %% left-to-right strategy with breaking ties by type
 HS.distro.leftToRight_TypewiseTieBreaking}


*/

/* % TMP test


*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/* %% compare performance of different distribution startegies

%% TODO: update all these calls to new HomophonicChordProgression interface

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


