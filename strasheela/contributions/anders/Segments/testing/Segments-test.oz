
%%
%% Usage: first feed whole buffer to make aux defs available, then feed individual tests in blocks comments
%%

declare 
[Segs] = {ModuleLink ['x-ozlib://anders/strasheela/Segments/Segments.ozf']}
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Motif Testing defs
%%%

%%
%% TODO:
%%
%% - ?? revise: make these more general 
%%

/** %% For testing single motif instances:  returns score of motif expressing single harm 7th chord.
%% */
proc {TestMotif MotifSpec Constructor ?MyScore}
    MyScore
    = {Segs.makeChordSlicesForm
       unit(segments:[sim([{Adjoin MotifSpec unit}])]
	    chords:{HS.score.makeChords
		    unit(iargs: unit(n:1
				     index: {HS.db.getChordIndex 'harmonic 7th'}
				     transposition:0))}
	    constructors:add(unit:Constructor)
	    %% top-level args
	    startTime:0
	    timeUnit:beats(Beat))}
    {Score.init MyScore} 
end

/** %% For testing uninitialised score segments: returns this score segment expressing single harm 7th chord.
%% ScoreSpec is either a score object or a textual score.
%% */
proc {TestScoreSegment ScoreSpec ?MyScore}
   End
   MyScoreSegment = {Score.make2 ScoreSpec unit}
in
   MyScore
   = {Score.make
      sim([MyScoreSegment
	   seq([chord(index:{HS.db.getChordIndex 'harmonic 7th'}
		      transposition:0
		      endTime:End)])]
	  startTime:0
	  timeUnit:beats(Beat))
      add(chord:HS.score.chord)}
   End = {MyScoreSegment getEndTime($)}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Rhythm representation
%%

%% Symbolic duration names: Note durations are then written as
%% follows: D.d16 (16th note), D.d8 (eighth note) and so forth, D.d8_
%% (dotted eighth note). See doc of MUtils.makeNoteLengthsTable for
%% more details.
Beat = 4 * 3 * 5 * 7 * 16
D = {MUtils.makeNoteLengthsRecord Beat [3 5]}
/** %% Function expecting a symbolic duration name and returning the corresponding numeric duration.
%% */
fun {SymbolicDurToInt Spec} D.Spec end

F = IntToFloat



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Output
%%

fun {TimeForFileName}
   MyTime = {OS.localTime}
in
   "day_"#MyTime.mDay#'-'#MyTime.mon+1#'-'#MyTime.year+1900#'_time_'#MyTime.hour#'-'#MyTime.min#'-'#MyTime.sec 
end
proc {RenderLilypondAndCsound MyScore Args}
   Default = unit(file: out#'_'#{TimeForFileName}
		  orc: "pluck.orc")
   As = {Adjoin Default Args}
in
   {Out.renderAndPlayCsound MyScore As}
%    {Out.outputScoreConstructor MyScore unit(file: As.file)}
   {ET31.out.renderAndShowLilypond MyScore As}
end
{Explorer.object
 add(information proc {$ I MyScore}
		    if {Score.isScoreObject MyScore}
		    then {RenderLilypondAndCsound MyScore unit}
		    end
		 end
     label: 'to Lily + Csound: notes, chords and scales (31 ET)')}






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Distro
%%

fun {ParameterFilterTest X}
   %% Filter out container parameters, measure parameters, time points and note pitches. 
   {Not {{X getItem($)} isContainer($)}} andthen
%    {Not {Measure.isUniformMeasures {X getItem($)}}} andthen
   {Not {X isTimePoint($)}} andthen
   {Not
    {X isPitch($)} andthen
    (%% root can be smaller domain than transposition (restricted to pitch classes), so FF would determine that.
     %% However, determining root results in poor propagation for index (because it determined transposed root, not root)
     {X hasThisInfo($ root)} orelse
%      {X hasThisInfo($ transposition)} orelse 
     {X hasThisInfo($ untransposedRoot)} orelse
     {X hasThisInfo($ notePitch)})}
end

TypewiseWithPatternMotifs_LeftToRightTieBreaking_Distro
= unit(
     value:random 
     select: {SDistro.makeMarkNextParam
	      [fun {$ X}
		  {HS.score.isPitchClass X} andthen
		  {{X getItem($)} isNote($)}
	       end
	       # [getOctaveParameter]
	      ]}
     order: {SDistro.makeVisitMarkedParamsFirst
	     %% edited version of HS.distro.makeOrder_TimeScaleChordPitchclass
	     {SDistro.makeSetPreferredOrder
	      %% first visit motif index, then rhythmic structure etc
	      [fun {$ X} {X hasThisInfo($ motifIndex)} end 
	       fun {$ X} {X isTimeParameter($)} end
	       fun {$ X} {HS.score.isScale {X getItem($)}} end
	       fun {$ X} {HS.score.isChord {X getItem($)}} end
	       fun {$ X} {HS.score.isPitchClass X} end]
	      {SDistro.makeLeftToRight SDistro.dom}}}
     test: ParameterFilterTest)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Segs.makeCounterpoint
%%

/*

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {TestScoreSegment
	       seq({Segs.makeCounterpoint
		    unit(iargs: unit(n:10
				     duration: D.d2
				    )
			rargs: unit(maxPitch: 'G'#4 % pitch unit and notation is et31
				    minPitch: 'D'#4
				  ))})}
 end
 unit(value:random)}

*/


/*

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {TestMotif
	       unit(iargs: unit(n:5
				duration: D.d2))
	       Segs.makeCounterpoint_Seq}
 end
 unit
}

*/



%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Segs.makeCounterpoint: more complex example
%%

/*

%%
%% TODO:
%%
%% currently depends on various defs only defined in my private defs, not in any functor
%%

% %%
% %% Use 1 simple chord "motif", a scale for each chord, and four voices of several note motif instances for each part/voice
% %%
% %% create list of note motifs, each motif goes with one chord 
% %% this approach is OK for a test, shows flexibility. perhaps too much code for complex case, but works also for polyphonic note motifs

% declare
% MakeChordsMotif_Test
% = {Score.defSubscript unit(super:MakeSchoenbergianProgression)
%    proc {$ Chords Args}
%       {SetBoundaryRoots Chords Args.rargs}
%       {DistinctRoots Chords}
%       {SmallIntervalsInProgression_BsPercent Chords Args.rargs}
%    end}
% %%
% {GUtils.setRandomGeneratorSeed 0}
% {SDistro.exploreOne
%  proc {$ MyScore}
%     N = 4
%     Chords = {MakeChordsMotif_Test
% 	      unit(iargs:unit(n:N)
% 		   rargs:unit(firstToLastRootInterval:'G'
% 			      minProgressionsPercent:0))}
%     Scales = {HS.score.makeScales
% 	      unit(iargs:unit(n:N)
% 		   rargs:unit(types:['harmonic series']))}
%     %% list of note seqs
%     %% NOTE: code doublication, just to make explicit how to write different voices explicitly
%     Motifs1 = {Score.makeItems
% 	       unit(n:4
% 		    constructor: fun {$ Args}
% 				    {Score.make2 seq({MakeCounterpoint Args}) unit}
% 				 end
% 		    iargs:unit(n:5
% 			       duration: each#[D.d2 D.d4 D.d4 D.d2 D.d2_]))}
%     Motifs2 = {Score.makeItems
% 	       unit(n:N
% 		    constructor: fun {$ Args}
% 				    {Score.make2 seq({MakeCounterpoint Args}) unit}
% 				 end
% 		    iargs:unit(n:5
% 			       duration: each#[D.d2 D.d4 D.d4 D.d2 D.d2_]))}
%     Motifs3 = {Score.makeItems
% 	       unit(n:N
% 		    constructor: fun {$ Args}
% 				    {Score.make2 seq({MakeCounterpoint Args}) unit}
% 				 end
% 		    iargs:unit(n:5
% 			       duration: each#[D.d2 D.d4 D.d4 D.d2 D.d2_]))}
%     Motifs4 = {Score.makeItems
% 	       unit(n:N
% 		    constructor: fun {$ Args}
% 				    {Score.make2 seq({MakeCounterpoint Args}) unit}
% 				 end
% 		    iargs:unit(n:5
% 			       duration: each#[D.d2 D.d4 D.d4 D.d2 D.d2_]))}
%     AllNotes
%  in
%     MyScore
%     = {Score.make
%        sim([seq(Motifs1)
% 	    seq(Motifs2)
% 	    seq(Motifs3)
% 	    seq(Motifs4)
% 	    seq(Chords)
% 	    seq(Scales)]
% 	   startTime:0
% 	   timeUnit:beats(Beat))
%        unit}
%     AllNotes = {MyScore collect($ test:isNote)}
%     %%
%     %% TODO: can I move some of these constraints elsewhere?
%     %%
%     %% Note: you may want to equalize start time for specific notes and chords...
%     {Pattern.equalizeParam Chords Scales getDuration}
%     {Pattern.equalizeParam Chords Motifs1 getDuration}
%     {ForAll {LUtils.matTrans [Chords Scales]}
%      proc {$ [MyChord MyScale]} {TonicChordInScale MyChord MyScale} end}
%     %% BUG: in HS.rules.expressEssentialPCs: HS.rules.expressEssentialPCs_AtChordStart causes fail
% %     {ForAll Chords HS.rules.expressEssentialPCs_AtChordStart}
%     {ForAll Chords HS.rules.expressAllChordPCs_AtChordStart}
% %     {ForAll Chords HS.rules.expressAllChordPCs_AtChordEnd}
%     %%
%     %% NOTE: ?? move threads into constraint defs themselves?
%     thread 			% make search problem more complex..
%        {HS.rules.intervalBetweenNonharmonicTonesIsConsonant AllNotes
% 	Consonances_twoOctaves}
%     end
%     %% Separate thread statements?? Constraints may block on different score contexts..
%     thread {NoParallels AllNotes IsAnyForbiddenIntervalR} end
%  end
%  TypewiseWithPatternMotifs_LeftToRightTieBreaking_Distro
% }


*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Segs.makeCounterpoint_PatternMotifs
%%

/*

{SDistro.exploreOne
 proc {$ MyScore}
    End
 in
    MyScore = {Score.make
	       sim([seq({Segs.makeCounterpoint_PatternMotifs
			 unit(iargs:unit(n:8
					inChordB: 1)
			      rargs:unit(motifSpecs:[[[0 d4] [0 d4] [0 d2]]
						     [[d4 d4] [0 d2]]]
					 motifSpecTransformers: [SymbolicDurToInt SymbolicDurToInt] 
					 motifAccessors: [fun {$ Ns} {Pattern.mapItems Ns getOffsetTime} end
							  fun {$ Ns} {Pattern.mapItems Ns getDuration} end]))}
			endTime: End)
		    seq([chord(index: {HS.db.getChordIndex major}
			       transposition: 0)]
			endTime: End)]
		   startTime:0
		   timeUnit:beats(Beat))
	       add(chord:HS.score.chord)}
 end
 TypewiseWithPatternMotifs_LeftToRightTieBreaking_Distro
}


*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% specific motifs 
%%

MkArpeggio
= {Score.defSubscript unit(super:Segs.makeCounterpoint_Seq
			   mixins: [Segs.arpeggio])
   nil}

/* % test motif

{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {TestMotif
	       a(iargs:unit(n:5
			    duration: D.d2
			    inChordB: 1)
		 offsetTime:D.d4)
	       MkArpeggio}
 end
 unit
%  TypewiseWithPatternMotifs_LeftToRightTieBreaking_NoChordDurs_Distro
}

{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {TestMotif
	       a(iargs:unit(n:10
			    duration: D.d2
			    inChordB: 1)
		 offsetTime:D.d4)
	       {Score.defSubscript unit(super:Segs.makeCounterpoint_Seq
					mixins: [Segs.arc])
		nil}}
 end
 unit
}

{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {TestMotif
	       a(iargs:unit(n:10
			    duration: D.d2
			    inChordB: 1)
		 offsetTime:D.d4)
	       {Score.defSubscript unit(super:Segs.makeCounterpoint_Seq
					mixins: [Segs.repetitions])
		nil}}
 end
 unit
}

{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {TestMotif
	       a(iargs:unit(n:4
			    duration: D.d2
			    inChordB: 1
			   )
		 rargs: unit(maxPitch: 'D'#5 % pitch unit and notation is et31
			     minPitch: 'D'#3
			    )
		 offsetTime:D.d4)
	       {Score.defSubscript unit(super:Segs.makeCounterpoint_Seq
					mixins: [Segs.hook])
		nil}}
 end
 unit
}


{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {TestMotif
	       a(iargs:unit(n:6
			    duration: D.d2
			    inChordB: 1
			   )
		 rargs: unit(maxPitch: 'D'#5 % pitch unit and notation is et31
			     minPitch: 'D'#3
			    )
		 offsetTime:D.d4)
	       {Score.defSubscript unit(super:Segs.makeCounterpoint_Seq
					mixins: [Segs.stairs])
		nil}}
 end
 unit
}

*/


%%
%% Segs.fenvContour
%%

/*

{SDistro.exploreOne
 fun {$}
    {TestMotif a(iargs: unit(n: 5 % 10
			     duration: Beat
			     pitch: fd#({HS.pitch 'C'#4}#{HS.pitch 'C'#5})
			     inChordB: 1)
		 rargs: unit(pitchFenv: {Fenv.linearFenv [[0.0 0.0] [0.7 1.0] [1.0 0.0]]})
		)
     {Score.defSubscript unit(super:Segs.makeCounterpoint_Seq
			      mixins: [Segs.fenvContour])
      nil}}
 end
 unit
%  HS.distro.typewise_LeftToRightTieBreaking
}



*/




%%
%% MakeAkkords
%%


/* % test

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}   
    End
 in 
    MyScore
    = {Score.make
       sim([seq({Segs.makeAkkords unit(akkN:3
				       iargs: unit(n: 4
						   duration: D.d2)
				       rargs: unit(minPcCard: 4
						   bassPattern: Pattern.decreasing))}
		endTime:End)
	    chord(index: {HS.db.getChordIndex 'harmonic 7th'}
		  transposition:0
		  endTime: End)]
	    %% args for top-level seq
	   startTime:0
	   timeUnit:beats(Beat))
       add(chord:HS.score.chord)}
 end
 unit
}

%% 

%% MakeAkkords_Seq
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}   
    End
 in 
    MyScore
    = {Score.make
       sim([{Segs.makeAkkords_Seq unit(akkN:3
% 				  offsetTime: D.d2
				       iargs: unit(n: 4
						   duration: D.d2)
				       rargs: unit(minPcCard: 4
						   bassPattern: Pattern.decreasing)
				       endTime:End)}
	    chord(index: {HS.db.getChordIndex 'harmonic 7th'}
		  transposition:0
		  endTime: End)]
	   %% args for top-level seq
	   startTime:0
	   timeUnit:beats(Beat))
       add(chord:HS.score.chord)}
 end
 unit}


*/






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% 
%%


/* % test

%% NOTE: in notation output actual notes and analytical chord objects on same staff...
declare
MkPhrase = {Segs.patternedPhrase
	    unit(segments: unit(unit(constructor:
					{Score.defSubscript
						   unit(super: Segs.makeCounterpoint_Seq
							mixins: [Segs.hook])
					 nil}
				     iargs: unit(n: 4
						 duration: D.d2)
				     rargs: unit(minPitch: 'C'#3
						 maxPitch: 'C'#4))
				unit(constructor: Segs.makeCounterpoint_Seq
				     iargs: unit(n: 5
						 duration: D.d2)
				     rargs: unit(minPitch: 'C'#3
						 maxPitch: 'C'#4)))
		 %% first segment pitch is always the same
		 pAccessor: fun {$ X} {X mapItems($ getPitch)}.1 end
		 pattern: proc {$ Xs} {Pattern.allEqual Xs} end)}
%%
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 fun {$}
    {TestMotif
     %% overwrite some arg of second segment
     unit(segments: unit(2: unit(iargs: unit(duration: D.d4))))
     MkPhrase}
 end
%  TypewiseWithPatternMotifs_LeftToRightTieBreaking_NoChordDurs_Distro
 TypewiseWithPatternMotifs_LeftToRightTieBreaking_Distro
%  HS.distro.typewise_LeftToRightTieBreaking
}   

*/




/* % testing 

declare
Arpeggio = {Score.defSubscript
	    unit(super: Segs.makeCounterpoint_Seq
		 mixins: [Segs.arpeggio]
		 rdefaults: unit(maxNonharmonicNoteSequence: 1))
	    nil}
{SDistro.exploreOne
 proc {$ MyScore}
    End
 in
    MyScore
    = {Score.make
       sim([{Segs.patternedSlices
	     unit(n: 3
		  layers:unit(
			    unit(constructor: Arpeggio
				 iargs: unit(n: 6
					    duration: D.d8)
				 rargs: unit(maxPitch: 'C'#5
					     minPitch: 'C'#3)
				 pAccessor: fun {$ Motif}
					       {Pattern.max {Motif mapItems($ getPitch)}}
					    end
				 pattern: proc {$ Xs} {Pattern.continuous Xs '<:'} end
				)
			    unit(constructor: Arpeggio
				 offsetTime: D.d8 
				 iargs: unit(n: 8
					     duration: D.d8)
				 rargs: unit(direction: '>:'
					     maxPitch: 'C'#5
					     minPitch: 'C'#3)
				 pAccessor: fun {$ Motif}
					       {Motif mapItems($ getPitch)}.1
% 					     {Pattern.min {Motif mapItems($ getPitch)}}
					    end
				 pattern: proc {$ Xs} {Pattern.continuous Xs '<:'} end
				)
			    )
		  endTime: End)}
	    chord(index: {HS.db.getChordIndex 'harmonic 7th'}
		  transposition:0
		  endTime: End)]
	    %% args for top-level seq
	   startTime:0
	   timeUnit:beats(Beat))
       add(chord:HS.score.chord)}
 end
 TypewiseWithPatternMotifs_LeftToRightTieBreaking_Distro
}

*/




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Segs.homophonicChordProgression
%%%

/* % test


declare
MyScore = {Segs.homophonicChordProgression
	   unit(chords: {HS.score.makeChords unit(iargs: unit(n:5
							      duration: 2))}
		scales: nil)}

{MyScore toInitRecord($)}

*/

/*

%%
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
   MyScore = {Segs.homophonicChordProgression
	      unit(voiceNo: 4
		   iargs: unit(inChordB: 1
			       inScaleB: 1
			      )
		   %% one pitch dom spec for each voice
		   rargs: each # [unit(minPitch: 'C'#4 
				       maxPitch: 'A'#5)
				  unit(minPitch: 'G'#3 
				       maxPitch: 'E'#5)
				  unit(minPitch: 'C'#3 
				       maxPitch: 'A'#4)
				  unit(minPitch: 'E'#2 
				       maxPitch: 'D'#4)]
		   chords: {HS.score.makeChords
			    unit(iargs: unit(n:5
% 					     constructor:HS.score.inversionChord
					     constructor:HS.score.fullChord
					     duration: 2
					     bassChordDegree: 1)
				 rargs: unit(types: ['major'
						     'minor']))}
		   scales: {HS.score.makeScales
			    unit(iargs: unit(n:1
					     transposition: 0)
				 rargs: unit(types: ['major']))}
		   startTime: 0
		   timeUnit: beats)}
 end
 %% left-to-right strategy with breaking ties by type
 HS.distro.leftToRight_TypewiseTieBreaking
}

*/

/*

%% Schoenberg rules
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    Chords = {HS.score.makeChords
	      unit(iargs: unit(n:5
% 					     constructor:HS.score.inversionChord
			       constructor:HS.score.fullChord
			       duration: 2
			       bassChordDegree: 1)
		   rargs: unit(types: ['major'
				       'minor'
				       'geometric diminished'
				      ]))}
 in
   MyScore = {Segs.homophonicChordProgression
	      unit(voiceNo: 4
		   iargs: unit(inChordB: 1
			       inScaleB: 1
			      )
		   %% one pitch dom spec for each voice
		   rargs: each # [unit(minPitch: 'C'#4 
				       maxPitch: 'A'#5)
				  unit(minPitch: 'G'#3 
				       maxPitch: 'E'#5)
				  unit(minPitch: 'C'#3 
				       maxPitch: 'A'#4)
				  unit(minPitch: 'E'#2 
				       maxPitch: 'D'#4)]
		   chords: Chords
		   scales: {HS.score.makeScales
			    unit(iargs: unit(n:1
					     transposition: 0)
				 rargs: unit(types: ['major']))}
		   startTime: 0
		   timeUnit: beats)}
    {HS.rules.schoenberg.progressionSelector Chords
     resolveDescendingProgressions}
    {HS.rules.distinctR Chords.1 {List.last Chords} 0}
    {Chords.1 getRoot($)} = {{Chords.1 getScales($)}.1 getRoot($)}
 end
 %% left-to-right strategy with breaking ties by type
 HS.distro.leftToRight_TypewiseTieBreaking
}

*/



