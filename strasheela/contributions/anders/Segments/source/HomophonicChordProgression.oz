
%%
%% This functor defines a subscript that creates homphonic chord progressions. 
%%

functor 

import
   FD FS

   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
%    MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   Segs at '../Segments.ozf'
   
export
   HomophonicChordProgression
   
define
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Top-level definition
%%%

   /** %% Top-level script or subscript for creating homophonic chord progressions. The individual voices are created with Segs.makeCounterpoint_Seq, the underlying chords (and optionally scales) are given as arguments.
   %%
   %% The number of chords determines the number of notes per voice, the start time of each chord equals the start times of the sim notes (so the resulting score is truely homophonic), and the sim notes must sound all pitch classes of the chord (i.e. arg voiceNo must be high enough, see below). By default, no voice crossing is permitted, the highest voice is the first and so forth. For inversion chords, the bass plays the bass pitch class of the chord (the soprano pitch class is ignored). The upper voices are at maximum an octave apart of each other by default.  
   %%
   %% Args:
   %% 'chords' (default {HS.score.makeChords unit}): non-nil list of chords. Remember that neither score objects nor variables can be in the top-level space, so the chords (and scales) to HomophonicChordProgression must be created inside a script.  
   %% 'scales' (default nil): list of scales.
   %% 'restrictMelodicIntervals' (default as follow)
   unit(bassIntervals: unit('=<:': 3#2
			    '=:': [2#1])
	upperVoiceIntervals: unit('=<:': 3#2
				  '=:': nil)
	step: 8#7
	minPercent:50
	maxPercent:100)
   %% If non-false, then the melodic intervals are constrained as specified by the "sub arguments". The melodic intervals allowed for the bass are given by the arg 'bassIntervals', where the feature '=<:' specifies a ratio for an interval up to which all intervals are permitted and the feature '=:' specifies a list of ratios that are additionally permitted.
   %% For example, the default setting constrains all bass intervals to up to a fifth at maximum and additionally the octave is allowed. The melodic intervals for the upper voices are specified the same way with the argument 'upperVoiceIntervals'.
   %% The remaining arguments of the settings control the required number of steps between upper voices. The maximum interval considered a step is given as a ratio to the argument 'step'. The args 'minPercent'/'maxPercent' specify the percentage boudary of the number of steps in the upper voices. 
   %% If 'restrictMelodicIntervals' is set to false, then all these constraints are disabled.
   %% 'commonPitchesHeldOver' (default false): if true, the notes of the harmonic band stay in the same voice and octave. [this constraint can be problematic]
   %% 'noParallels' (default true): if true, no parallel perfect consonances are permitted.
   %% 'playAllChordTones' (default true): if true, all chord tones are played.
   %% 'noVoiceCrossing' (possible settings: false, true or strict. default true): if true, no voice crossings are permitted. If strict, not even unisons are permitted (tone doublication in octaves is still fine).
   %% 'maxUpperVoiceDistance' (default {HS.db.getPitchesPerOctave}): maximum interval between upper voices (interval to bass can be larger). Disabled if false.
   %% 'sliceRule' (default false): unary constraint applied to the list MyChord | Notes at each "time slice" (i.e., for each chord and the notes sim to this chord). Notes are the notes in descending order (i.e. Bass last). Disabled if false.
   %% 'sopranoRule' (default false): unary constraint applied to the list of soprano notes, i.e. the notes of the first voice. NB: the first voice is only guaranteed to be the highest voice if 'noVoiceCrossing' is true. Disabled if false.
   %% 'bassRule' (default false): unary constraint applied to the list of bass notes, i.e. the notes of the last voice. NB: the last voice is only guaranteed to be the lowest voice if 'noVoiceCrossing' is true. Disabled if false.
   %% 'makeTopLevel' (a function with the interface {$ Voices End Args}, returning a container): By default, HomophonicChordProgression returns a fully initialised score object with the following topology (chords and scales are optional).
   %%
   %% sim([seq(note+)+
   %%      seq(chord+)
   %%      seq(scale+)])
   %%
   %% This score topology can be overwritting with the argument 'makeTopLevel', which expects a function with the following arguments: Voices is a list of sequential containers containing notes that represent the individual voices; End (an FD int) is the end time that is shared by all voices (can be used to constrain, e.g., the end time of the chord sequence); and Args is the record of arguments expected by HomophonicChordProgression. For example, if you do not want HomophonicChordProgression to return a fully initialised score object and if chords/scales should be left out, then you can set the argument makeTopLevel to the following function.
   
   fun {$ Voices End Args}
      {Score.make2 sim(Voices) 
       unit}
   end

   %% The following second example of a makeTopLevel function changes the score topology such that the default Strasheela Lilypond export will export the first 2 voices in the first staff and the rest in the second staff.

   fun {$ Voices End Args}
      UpperStaffVoices LowerStaffVoices
   in
      %% attach first 2 voices to UpperStaffVoices and rest to LowerStaffVoices
      {List.takeDrop Voices 2 UpperStaffVoices LowerStaffVoices}
      %%
      {Score.make
       sim([%% surrounding seq for default Lily output
	    %% (which can be customised with Out.toLilypond arg 'hasImplicitStaff')
	    seq([sim(UpperStaffVoices)])
	    seq(%% Set to bass clef.
		%% Invisible grace note necessary to put clef at the very beginning 
		info:lily("\\clef bass \\grace s")
		[sim(LowerStaffVoices)])
	    seq(info:lily("\\set Staff.instrumentName = \"Anal.\"")
		Args.chords
		endTime: End)
	    %% uncomment if scale should be included
% 	    seq(Args.scales
% 		endTime: End)
	   ]
	   startTime: 0)
       unit}
   end

   %% 'voiceArgs' (default unit): arbitrary arguments given to the constructure Score.makeItems, which creates the list of all voices.
   %%
   %% Further Args.iargs, Args.rargs: as for Segs.makeCounterpoint_Seq
   %% Args.iargs.n overwritten (is length of chords)
   %% Further Args: for top-level sim.
   %%
   %% */
   %% !!?? BUG:
   %% - Segs.homophonicChordProgression does not work for chord sequence of length 1
   %% - Fomus inst defs ignored, although this feature works fine in the Fomus examples file
   %%   (tmp fix: defined these two defs in ~/.fomus)
   %%
   %% Note: arg isTopLevel has been substituted by the more general argument makeTopLevel. 
   %%
   %% TODO:
   %%
   %% - To think: is arg isToplevel a good idea?
   %% OK - finish doc
   %% - do a few examples demonstrating args
   %% OK - reduce source in this file to what is required for HomophonicChordProgression
   %% OK - add this def to Segements functor
   %% OK - add args for many constraints 
   %% OK - all notes chord tones
   %% OK - express all chord tones (if number of sim notes is sufficient)
   %% OK - constraint: harmonic band in same voice and octave
   %% OK - reduce number of skips and/or size of max interval (Segs.makeCounterpoint_Seq constraint)
   %% OK - unify end of chords and scales
   %% OK - if inversion chord, bass is chord bass
   %% OK - no voice crossing
   %% ?? - split HomophonicChordProgression: this subscript only creates notes, chords and scales are extra
   %%
   proc {HomophonicChordProgression Args ?MyScore}
      Defaults = unit(makeTopLevel:
			 fun {$ Voices End Args}
			    {Score.make
			     {Adjoin sim(info:fomus("inst <id: harm template: soprano name: \"Underlying Harmony\" abbr: \"harm\">"
						    "inst <id: scale template: soprano name: \"Underlying Scale\" abbr: \"scale\">")
					{Append Voices
					  {Append
					   [seq(info:[lily("\\set Staff.instrumentName = \"Anal.\"")
						      fomus(inst: harm)]
						Args.chords
						endTime: End)]
					   case As.scales of nil then nil else
					      [seq(info: fomus(inst: scale)
						   Args.scales
						   endTime: End)]
					   end}}
					 startTime: 0)
			      {Record.subtractList
			       {Adjoin Args sim} % keep toplevel label
			       [makeTopLevel voiceNo iargs rargs chords scales
				commonPitchesHeldOver noParallels restrictMelodicIntervals
				playAllChordTones noVoiceCrossing maxUpperVoiceDistance
				sliceRule]}}
			     unit}
			 end 
		      voiceNo: 4 % voices
		      iargs: unit()
		      rargs: unit
		      voiceArgs: unit
		      chords: {HS.score.makeChords unit}
		      scales: nil
		      commonPitchesHeldOver: false
		      noParallels: true
		      %% restrictMelodicIntervals default args are given in constraint def below, so not all args must be necessarily specified by user
		      restrictMelodicIntervals: unit
% 		      restrictMelodicIntervals_bass: 
		      playAllChordTones: true
		      noVoiceCrossing: true
		      maxUpperVoiceDistance: {HS.db.getPitchesPerOctave}
		      sliceRule: false
		      sopranoRule: false
		      bassRule: false
		     )
      As = {GUtils.recursiveAdjoin Defaults Args}
      End = {FD.decl}
      Voices = {Score.makeItems {Adjoin unit(n: As.voiceNo
					     %% ?? hard-coded constructor?
					     constructor: Segs.makeCounterpoint_Seq
					     iargs: {Adjoin As.iargs
						     unit(n: {Length As.chords})}
					     rargs: As.rargs
					     endTime: End)
				 As. voiceArgs}}
      Nss
      ChordAndNotesSlices
      UpperVoices LowerVoices
   in
      MyScore = {As.makeTopLevel Voices End As}
      %%
      %% constraints on individual "note slices"
      %%
      thread % if MyScore is not top-level
	 Nss = {Pattern.mapItems Voices getItems}
	 ChordAndNotesSlices = {LUtils.matTrans As.chords | Nss}
	 %% melodic constraints
	 if As.restrictMelodicIntervals \= false then 
	    {ForAll {LUtils.butLast Nss}
	     proc {$ Notes}
		{RestrictMelodicIntervals_UpperVoices Notes
		 As.restrictMelodicIntervals}
	     end}
	    {RestrictMelodicIntervals_Bass {List.last Nss}
	     As.restrictMelodicIntervals}
	 end
	 %% Constrain 'time slice' of chord and corresponding notes
	 {ForAll ChordAndNotesSlices
	  proc {$ C|VoiceNotes}
	     {Pattern.allEqual {Pattern.mapItems C|VoiceNotes getStartTime}}
	     if As.playAllChordTones \= false then 
		{PlayAllChordTones C VoiceNotes}
	     end
	     if As.noVoiceCrossing == true then 
		{NoVoiceCrossing VoiceNotes}
	     end
	     if As.noVoiceCrossing == strict then 
		{NoVoiceCrossing_Strict VoiceNotes}
	     end
	     if As.maxUpperVoiceDistance \= false then 
		{ConstrainUpperVoiceDistance VoiceNotes As.maxUpperVoiceDistance}
	     end
	     if {HS.score.isInversionMixinForChord C} then 
		%% Note: soprano is ignored here
		{C getBassPitchClass($)} = {{List.last VoiceNotes} getPitchClass($)}
	     end
	     if As.sliceRule \= false then 
		{As.sliceRule C|VoiceNotes}
	     end
	  end}
	 %% constraints on pairs for chords and notes 
	 {Pattern.for2Neighbours ChordAndNotesSlices
	  proc {$ C1|VoiceNotes1 C2|VoiceNotes2}
	     NotePairs = {Map {LUtils.matTrans [VoiceNotes1 VoiceNotes2]}
			  fun {$ [N1 N2]} N1#N2 end}
	  in
	     if As.commonPitchesHeldOver then 
		{CommonPitchesHeldOver C1#C2 NotePairs}
	     end
	     if As.noParallels then
		{HS.rules.noParallels NotePairs}
	     end
	  end}
	 %% Hack...
	 %% fine-tune notation with fomus
	 {List.takeDrop Voices (As.voiceNo div 2) UpperVoices LowerVoices}
	 {ForAll LowerVoices
	  proc {$ MyVoice}
	     %% notate all voices on only two staffs. Problem with that: Lilypond possibly swaps order of textual annotations of notes in a single staff
% 	     {MyVoice addInfo(fomusPart(lower))}
	     {MyVoice addInfo(fomus(inst:bass))}
	  end}
	 {ForAll UpperVoices
	  proc {$ MyVoice}
% 	     {MyVoice addInfo(fomusPart(upper))}
	     {MyVoice addInfo(fomus(inst:soprano))}
	  end}
	 if As.sopranoRule \= false then 
	    {As.sopranoRule Nss.1}
	 end
	 if As.bassRule \= false then 
	    {As.bassRule {List.last Nss}}
	 end
      end
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Constraints 
%%%
   

   /** %% MyChord and Notes are the chord and the notes at a time frame: all notes of the chord are played and no others.
   %% */
   proc {PlayAllChordTones MyChord Notes}
      {FS.unionN {Map Notes
		  fun {$ N} {GUtils.makeSingletonSet {N getPitchClass($)}} end}
       {MyChord getPitchClasses($)}}
      {ForAll Notes
       proc {$ N} {FS.include {N getPitchClass($)} {MyChord getPitchClasses($)}} end}
   end

   /** %% Notes are the notes at a time frame and constrained to increasing pitch. NOTE: notes must be given in decreasing order, soprano first, bass last.
   %% */
   proc {NoVoiceCrossing Notes}
      {Pattern.continuous {Pattern.mapItems Notes getPitch}
       '>=:'}
   end
   /** %% Variant of NoVoiceCrossing where not even unisons are allowed.
   %% */
   proc {NoVoiceCrossing_Strict Notes}
      {Pattern.continuous {Pattern.mapItems Notes getPitch}
       '>:'}
   end
   /** %% [strict onstraint for homophonic chord progression] If two consecutive chords C1 and C2 share common pitches (harmonic band), then these occur in the same voice and octave (Schoenberg: harmonischen Band bleibt liegen). NotePairs is a list of two-note-pairs. Each pair consists of consecutive notes in the same voice and NotePairs together expresses C1 and C2. However, the bass notes are excluded. The voices in NotePairs are ordered increasing, so the bass is the first pair which is ignored. 
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
   /** %% Restrict melodic intervals of Notes (list of notes in a single upper voice): by default only skips up to a fifths and most intervals (Args.minPercent to Args.maxPercent) are steps or unison.
   %% ?? no two skips after each other in same dir? 
   %% */
   proc {RestrictMelodicIntervals_UpperVoices Notes Args}
      %% def defaults from HomophonicChordProgression here, so not all args must be given
      Defaults = unit(%% percentage of steps
		      minPercent:50
		      maxPercent:100
		      %% max size of a step (ratio)
		      step: 8#7
		      %% 
		      upperVoiceIntervals: unit('=<:': 3#2
						'=:': nil))
      As = {Adjoin Defaults Args}
      Intervals = {Pattern.map2Neighbours Notes HS.rules.getInterval}
   in
      {ForAll Intervals
       proc {$ X}
	  {Pattern.disjAll
	   (X =<: {HS.score.ratioToInterval As.upperVoiceIntervals.'=<:'})
	   | {Map As.upperVoiceIntervals.'=:' fun {$ Ratio} (X =: {HS.score.ratioToInterval Ratio}) end}
	   1}
       end}
      {Pattern.percentTrue_Range {Map Intervals
				  proc {$ X B} B = (X =<: {HS.score.ratioToInterval As.step}) end}
       As.minPercent As.maxPercent}
   end
   /** %% Restrict melodic intervals of Notes (list of notes in bass): by default only skips up to a fifth or an octave.
   %% */
   %% ??  At least sometimes the bass progresses stepwise: min number of steps given
   proc {RestrictMelodicIntervals_Bass Notes Args}
      %% def defaults from HomophonicChordProgression here, so not all args must be given
      Defaults = unit(bassIntervals: unit('=<:': 3#2
					  '=:': [2#1]))
      As = {Adjoin Defaults Args}
      Intervals = {Pattern.map2Neighbours Notes HS.rules.getInterval}
   in
      {ForAll Intervals
       proc {$ X}
	  {Pattern.disjAll
	   (X =<: {HS.score.ratioToInterval As.bassIntervals.'=<:'})
	   | {Map As.bassIntervals.'=:' fun {$ Ratio} (X =: {HS.score.ratioToInterval Ratio}) end}
	   1}
       end}
   end
   /** %% The upper voices are at max MaxDistance apart of each other. Notes is same args as for NoVoiceCrossing.
   %% */
   proc {ConstrainUpperVoiceDistance Notes MaxDistance}
      {Pattern.for2Neighbours
       {LUtils.butLast Notes} % all notes excerpt the bass
       proc {$ N1 N2}
	  {HS.rules.getInterval N1 N2} =<: MaxDistance
       end}
   end


end


