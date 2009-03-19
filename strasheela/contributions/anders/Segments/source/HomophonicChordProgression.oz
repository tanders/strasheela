
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
   %% Score topology (chords and scales are optional, see below):
   %%
   %% sim([seq(note+)+
   %%      seq(chord+)
   %%      seq(scale+)])
   %%
   %% The number of chords determines the number of notes per voice, the start time of each chord equals the start times of the sim notes (so the resulting score is truely homophonic), and the sim notes must sound all pitch classes of the chord (i.e. arg voiceNo must be high enough, see below). No voice crossing is permitted, the highest voice is the first and so forth. For inversion chords, the bass plays the bass pitch class of the chord (the soprano pitch class is ignored). The upper voices are at maximum an ocatve apart of each other.  
   %%
   %% Args:
   %% 'isToplevel' (default true): if true, returns fully initialised score where chords and scales are part of score, otherwise score is not fully initialised and chords/scales are left out. 
   %% 'voiceNo' (default 4): number of voices
   %% 'chords' (default {HS.score.makeChords unit}): non-nil list of chords. Remember that neither score objects nor variables can be in the top-level space, so the chords (and scales) to HomophonicChordProgression must be created inside a script.  
   %% 'scales' (default nil): list of scales.
   %% 'restrictMelodicIntervals' (default unit(minPercent:60 maxPercent:100)): if non-false then the intervals between upper voices are a fifths at most, and the bass is a fifths at most or an octave. The args minPercent/maxPercent specify the percentage boudary of the number of steps in the upper voices. Disabled if false.
   %% 'commonPitchesHeldOver' (default true): if true, the notes of the harmonic band stay in the same voice and octave.
   %% 'noParallels' (default true): if true, no parallel perfect consonances are permitted.
   %% 'sliceRule' (default proc {$ Xs} skip end): unary constraint applied to the list MyChords | Notes at each "time slice" (i.e., for each chord and the notes sim to this chord). Notes are the notes in descending order (i.e. Bass last).
   %%
   %% Further Args.iargs, Args.rargs: as for Segs.makeCounterpoint_Seq
   %% Args.iargs.n overwritten (is length of chords)
   %% Further Args: for top-level sim.
   %%
   %% */
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
      Defaults = unit(isToplevel: true
		      voiceNo: 4 % voices
		      iargs: unit()
		      rargs: unit
		      chords: {HS.score.makeChords unit}
		      scales: nil
		      commonPitchesHeldOver: true
		      noParallels: true
		      restrictMelodicIntervals: unit(minPercent:60
						     maxPercent:100)
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
      MyScore
      = if As.isToplevel then
	   {Score.make
	    {Adjoin
	     sim({Append Voices
		  {Append
		   [seq(As.chords
			endTime: End)]
		   case As.scales of nil then nil else
		      [seq(As.scales
			   endTime: End)]
		   end
		  }}
		)
	     {Adjoin {Record.subtractList As {Arity Defaults}}
	      sim(startTime: 0)}}
	    unit}
	else
	   {Score.make2 
	    {Adjoin sim(Voices)
	     {Adjoin {Record.subtractList As {Arity Defaults}}
	      sim}}
	    unit}
	end
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
	     {PlayAllChordTones C VoiceNotes}
	     {NoVoiceCrossing VoiceNotes}
	     {ConstrainUpperVoiceDistance VoiceNotes}
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
   /** %% The upper voices are max an ocatve apart of each other. Notes is same args as for NoVoiceCrossing.
   %% */
   proc {ConstrainUpperVoiceDistance Notes}
      {Pattern.for2Neighbours Notes.2
       proc {$ N1 N2}
	  {HS.rules.getInterval N1 N2} =<: {HS.db.getPitchesPerOctave}
       end}
   end


end


