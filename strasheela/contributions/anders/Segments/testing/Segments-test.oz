
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
	   chord(index:{HS.db.getChordIndex 'harmonic 7th'}
		 transposition:0
		 endTime:End)]
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
		    unit(iargs: unit(n:2
				     duration: D.d2
				    )
			rargs: unit(maxPitch: 'G'#4 % pitch unit and notation is et31
				    minPitch: 'D'#4
				  ))})}
 end
 unit
}

*/


/*

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {TestMotif
	       unit(iargs: unit(n:2
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

declare
Ns = {Segs.makeCounterpoint_PatternMotifs
      unit(iargs:unit(n:8)
	   rargs:unit(motifSpecs:[[[0 d4] [0 d4] [0 d2]]
				  [[d4 d4] [0 d2]]]
		      motifSpecTransformers: [SymbolicDurToInt SymbolicDurToInt] 
		      motifAccessors: [fun {$ Ns} {Pattern.mapItems Ns getOffsetTime} end
				       fun {$ Ns} {Pattern.mapItems Ns getDuration} end]))}
{ForAll Ns Score.init}

{Pattern.mapItems Ns toInitRecord}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% specific motifs 
%%

/* % test motif

{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {TestMotif
	       a(iargs:unit(n:5
			    duration: D.d2
			    inChordB: 1)
		 offsetTime:D.d4)
	       Segs.mkArpeggio}
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
	       Segs.mkArc}
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
	       Segs.mkRepetitions}
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
	       Segs.mkHook}
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
	       Segs.mkStairs}
 end
 unit
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

declare
MkPhrase = {PatternedPhrase
	    unit(segments: unit(unit(constructor: MkRepetitions
				     iargs: unit(n: 2))
				unit(constructor: MkRepetitions
				     iargs: unit(n: 3)))
		 pAccessor: GUtils.identity
		 pattern: proc {$ Xs} skip end)}
%%
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 fun {$}
    {TestMotif
     %% overwrite some arg of second segment
     unit(segments: unit(2: unit(rargs: unit(longDur: D.d4))))
     MkPhrase}
 end
 TypewiseWithPatternMotifs_LeftToRightTieBreaking_NoChordDurs_Distro}   

*/



/* % testing 


{SDistro.exploreOne
 proc {$ MyScore}
    End
 in
    MyScore
    = {Score.make
       sim([{PatternedSlices
	     unit(n: 3
		  layers:unit(
			    unit(constructor: MkArpeggio
				 iargs: unit(n: 6)
				 rargs: unit(mostDurs: D.d16)
				 pAccessor: fun {$ Motif}
					       {Pattern.max {Motif mapItems($ getPitch)}}
					    end
				 pattern: proc {$ Xs} {Pattern.continuous Xs '<:'} end
				)
			    unit(constructor: MkArpeggio
				 offsetTime: D.d8 
				 iargs: unit(n: 8)
				 rargs: unit(mostDurs: D.t3d8
					     direction: '>:')
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
 TypewiseWithPatternMotifs_LeftToRightTieBreaking_NoChordDurs_Distro}



%%%

declare
MyScore
= {PatternedSlices
   unit(n: 3
	layers: unit(
		   unit(constructor: Score.makeSeq
			iargs: each # [unit(n: 2 
					    pitch: each # [60 62] % 60 % fenv
					    duration: 2)
				       %% NOTE: different end time of layers in this slice
				       unit(n: 3 
					    pitch: each # [60 62 64] % 60 % fenv
					    duration: 3)
				       unit(n: 3 
					    pitch: each # [60 62 64] % 60 % fenv
					    offsetTime: 2
					    duration: 3)
				      ]
			pAccessor: GUtils.identity
			%% TODO:
			pattern: proc {$ Xs} skip end)
		   unit(constructor:
			   {Score.makeConstructor Score.makeSeq
			    unit(iargs: unit(pitch: 48
					     duration: 2))}
			iargs: each # [unit(n: 2)
				       unit(n: 3)
				       unit(n: 4)
				      ]
			pAccessor: GUtils.identity
			%% TODO:
			pattern: proc {$ Xs} skip end)
		   unit(constructor: Score.makeSeq
			iargs: unit(n: 2
				    pitch: each # [71 72] 
				    duration: 4)
			pAccessor: GUtils.identity
			%% TODO:
			pattern: proc {$ Xs} skip end)
		   )
	%% args for top-level seq
	startTime:0
	timeUnit:beats
	sliceLayersEndTogether: false)}
{Score.init MyScore}

{MyScore toInitRecord($)}


%%%%


declare
MySeqs = {Score.makeItems unit(n: 3
			       constructor: Score.makeSeq
			       iargs: each # [unit(n: 2 
						   pitch: each # [60 62] % 60 % fenv
						   duration: 2)
					      unit(n: 3 
						  pitch: each # [60 62 64] % 60 % fenv
						   duration: 2)
					      unit(n: 4 
						   pitch: each # [60 62 64 65] % 60 % fenv
						   duration: 2)
					     ])}
{ForAll MySeqs Score.init}

{Pattern.mapItems MySeqs toInitRecord}


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



