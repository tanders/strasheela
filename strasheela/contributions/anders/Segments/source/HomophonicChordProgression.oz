
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
   %% The number of chords determines the number of notes per voice, the start time of each chord equals the start times of the sim notes (so the resulting score is truely homophonic), and the sim notes must sound all pitch classes of the chord (i.e. arg voiceNo must be high enough, see below). No voice crossing is permitted, the highest voice is the first and so forth. For inversion chords, the bass plays the bass pitch class of the chord (the soprano pitch class is ignored). The upper voices are at maximum an octave apart of each other.  
   %%
   %% Args:
   %% 'chords' (default {HS.score.makeChords unit}): non-nil list of chords. Remember that neither score objects nor variables can be in the top-level space, so the chords (and scales) to HomophonicChordProgression must be created inside a script.  
   %% 'scales' (default nil): list of scales.
   %% 'restrictMelodicIntervals' (default unit(minPercent:60 maxPercent:100)): if non-false then the intervals between upper voices are a fifths at most, and the bass is a fifths at most or an octave. The args minPercent/maxPercent specify the percentage boudary of the number of steps in the upper voices. Disabled if false.
   %% 'commonPitchesHeldOver' (default true): if true, the notes of the harmonic band stay in the same voice and octave.
   %% 'noParallels' (default true): if true, no parallel perfect consonances are permitted.
   %% 'playAllChordTones' (default true): if true, all chord tones are played.
   %% 'noVoiceCrossing' (default true): if true, no voice crossings are permitted.
   %% 'maxUpperVoiceDistance' (default {HS.db.getPitchesPerOctave}): maximum interval between upper voices (interval to bass can be larger).
   %% 'sliceRule' (default proc {$ Xs} skip end): unary constraint applied to the list MyChord | Notes at each "time slice" (i.e., for each chord and the notes sim to this chord). Notes are the notes in descending order (i.e. Bass last).
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
   
   %%
   %% Further Args.iargs, Args.rargs: as for Segs.makeCounterpoint_Seq
   %% Args.iargs.n overwritten (is length of chords)
   %% Further Args: for top-level sim.
   %%
   %% */
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
			     {Adjoin sim({Append Voices
					  {Append
					   [seq(info:lily("\\set Staff.instrumentName = \"Anal.\"")
						Args.chords
						endTime: End)]
					   case As.scales of nil then nil else
					      [seq(Args.scales
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
		      chords: {HS.score.makeChords unit}
		      scales: nil
		      commonPitchesHeldOver: true
		      noParallels: true
		      restrictMelodicIntervals: unit(minPercent:60
						     maxPercent:100)
% 		      restrictMelodicIntervals_bass: 
		      playAllChordTones: true
		      noVoiceCrossing: true
		      maxUpperVoiceDistance: {HS.db.getPitchesPerOctave}
		      sliceRule: proc {$ Xs} skip end
		     )
      As = {GUtils.recursiveAdjoin Defaults Args}
      End = {FD.decl}
      Voices = {Score.makeItems unit(n: As.voiceNo
				     %% ?? hard-coded constructor?
				     constructor: Segs.makeCounterpoint_Seq
				     iargs: {Adjoin As.iargs
					     unit(n: {Length As.chords})}
				     rargs: As.rargs
				     endTime: End)}
      Nss
      ChordAndNotesSlices
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
	    {RestrictMelodicIntervals_Bass {List.last Nss}}
	 end
	 %% Constrain 'time slice' of chord and corresponding notes
	 {ForAll ChordAndNotesSlices
	  proc {$ C|VoiceNotes}
	     {Pattern.allEqual {Pattern.mapItems C|VoiceNotes getStartTime}}
	     if As.playAllChordTones \= false then 
		{PlayAllChordTones C VoiceNotes}
	     end
	     if As.noVoiceCrossing \= false then 
		{NoVoiceCrossing VoiceNotes}
	     end
	     {ConstrainUpperVoiceDistance VoiceNotes As.maxUpperVoiceDistance}
	     if {HS.score.isInversionMixinForChord C} then 
		%% Note: soprano is ignored here
		{C getBassPitchClass($)} = {{List.last VoiceNotes} getPitchClass($)}
	     end
	     {As.sliceRule C|VoiceNotes}
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
   /** %% Restrict melodic intervals of Notes (list of notes in a single upper voice): only skips up to a fifths and most intervals (Args.minPercent to Args.maxPercent) are steps or unison.
   %% ?? no two skips after each other in same dir? 
   %% */
   proc {RestrictMelodicIntervals_UpperVoices Notes Args}
      Defaults = unit(minPercent:70
		      maxPercent:100)
      As = {Adjoin Defaults Args}
      Intervals = {Pattern.map2Neighbours Notes HS.rules.getInterval}
   in
      {ForAll Intervals proc {$ X} X =<: {HS.score.ratioToInterval 3#2} end}
      {Pattern.percentTrue_Range {Map Intervals
				  proc {$ X B} B = (X =<: {HS.score.ratioToInterval 9#8}) end}
       As.minPercent As.maxPercent}
   end
   /** %% Restrict melodic intervals of Notes (list of notes in bass): only skips up to a fifth or an octave.
   %% */
   %% ??  At least sometimes the bass progresses stepwise: min number of steps given
   proc {RestrictMelodicIntervals_Bass Notes}
      Intervals = {Pattern.map2Neighbours Notes HS.rules.getInterval}
   in
      {ForAll Intervals
       proc {$ X}
	  {Pattern.disjAll [(X =<: {HS.score.ratioToInterval 4#3})
			    (X =: {HS.score.ratioToInterval 3#2})
			    (X =: {HS.score.ratioToInterval 2#1})]
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


