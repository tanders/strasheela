
%%
%% This example defines a smaller-scale harmonic problem using only the Strasheela core (i.e. not the HS contribution). Also, this example demonstrates a number of constraint applicators. 
%%

%%
%% Usage: feed buffer, then feed solver calls at the end of the file
%%

%%
%% Music theory of this example: a sequence of plain chords, all with the same number of notes (arg noteNoPerChord). Consecutive chords always share common pitches. The soprano is shaped like an arc. The user can restrict the intervals allowed in a chord, and this set of intervals can change over time (specified explicitly). 
%%
%% Music representation: seq(sim(note+)+)
%% The notes in a sim (a chord) are always sorted by decending pitch
%%
%% The following constraint applicators are used: ForAll, Pattern.for2Neighbours, Pattern.forPairwise, SMapping.forNumericRangeArgs
%%
%%

declare
proc {SimpleHarmony Args MyScore}
   Defaults As Chords
in
   thread 			% concurrency because Defaults depends on As
      Defaults = unit(chordNo: 10
		      noteNoPerChord: 3
		      makeNote: fun {$}
				   note(duration:4
					pitch:{FD.int 48#72}
					amplitude:64)
				end
		      %% default: the first ten chords consist only of consonances
		      chordIntervals: [(1#As.chordNo)#[3 4 5 7 8 9 12 15 16]])
   end
   thread As = {Adjoin Defaults Args} end 
   MyScore = {Score.makeScore
	      seq(items:{LUtils.collectN As.chordNo
			 fun {$}
			    sim(items:{LUtils.collectN As.noteNoPerChord
				       As.makeNote})
			 end}
		  startTime:0
		  timeUnit:beats(4))
	      unit}
   Chords = {MyScore getItems($)}
   %% Constraint application
   {ForAll Chords NoVoiceCrossing}
   {Pattern.for2Neighbours Chords HarmonicBand}
   {SopranoFormsArc Chords As.chordNo-(As.chordNo div 3)} 
   %% Constrain specific chords to specific intervals. These are given by a mini language as an arg
   {SMapping.forNumericRangeArgs Chords As.chordIntervals
    RestrictHarmonicIntervals
    proc {$ X} skip end}	% ignore chords not in the spec As.chordIntervals
end


%%
%% Constraint defs
%%

%% chords (sims of notes) share common pitches (not pitch classes but actual pitches)
proc {HarmonicBand C1 C2}
   FS1 = {GUtils.intsToFS {C1 mapItems($ getPitch test:isNote)}}
   FS2 = {GUtils.intsToFS {C2 mapItems($ getPitch test:isNote)}}
   Intersect
in
   {FS.intersect FS1 FS2 Intersect}
   {FS.card Intersect} >: 0  
end

%% Avoid symmetries: all notes in a chord are sorted (first is always highest)
proc {NoVoiceCrossing C}
   {Pattern.decreasing {C mapItems($ getPitch test:isNote)}}
end

%% Highest chord notes form arg: first increasing and then decreasing, turning point is at HighestNoteIndex (an integer). NOTE: constraint has only any effect if HighestNoteIndex < {Length Chords}.  
proc {SopranoFormsArc Chords HighestNoteIndex}
   if HighestNoteIndex < {Length Chords} 
   then 
      SopranoPitches = {Map Chords fun {$ C} {{C getItems($)}.1 getPitch($)} end}
   in
      {Pattern.increasing {List.take SopranoPitches HighestNoteIndex}}
      {Pattern.decreasing {List.drop SopranoPitches HighestNoteIndex}}
   end
end

%% Only the given Intervals (an FD int spec, e.g., a list of integers) are allowed between chord pitches. Note that all pairwise note combinations are constrained, not just notes of neighbouring voices 
proc {RestrictHarmonicIntervals C Intervals}
   {Pattern.forPairwise {C map($ getPitch test:isNote)}
    proc {$ P1 P2} P1 - P2 =: {FD.int Intervals} end}
end


/*

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript SimpleHarmony
		     unit}
 unit(order:leftToRight
      value:random)}

%% change number of chords and notes per chord
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript SimpleHarmony
		     unit(chordNo: 12
			  noteNoPerChord: 4)}
 unit(order:leftToRight
      value:random)}

%% use different intervals in different chords 
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript SimpleHarmony
		     unit(chordNo: 12
			  noteNoPerChord: 3
			  %% start consonant, then get increasingly dissonant etc
			  chordIntervals: [(1#3)#[3 4 5 7 8 9 12 15 16]
					   (4#6)#[2 3 4 6 8 9 10 14 15 16]
					   (7#9)#[1 2 3 6 8 10 11 13 14 15]
					   (10#12)#[2 3 4 8 9 10 14 15 16]
					  ]
			 )}
 unit(order:leftToRight
      value:random)}

%% use different intervals in different chords
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript SimpleHarmony
		     unit(chordNo: 9
			  noteNoPerChord: 4
			  %% change between only even-numbered, and then (almost) only odd-numbers intervals
			 chordIntervals: [(1#3)#[2 4 6 8 10 14 16]
					  (4#6)#[1 3 5 6 7 9 11 13 15]
					  (7#9)#[2 4 6 8 10 14 16]
					 ]
			 )}
 unit(order:leftToRight
      value:random)}


%% test specific intervals explicitly
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript SimpleHarmony
		     unit(chordNo: 4
			  noteNoPerChord: 4
			  chordIntervals: [(1#4)#[1 3 5 6 7 9 11 13 15]
% 					   (1#4)#[1 2 3 6 8 10 11 13 14 15]
					 ]
			 )}
 unit(order:leftToRight
      value:random)}


*/


   
