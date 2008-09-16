
%%
%% This files defines a number of harmonic progression CSPs. All CSPs
%% are defined in 31 ET (meantone temperament). Note that these CSPs
%% focus on the actual chord progression (chord 'type' and root), the
%% voicing the done less carefully. The idea here is that the chord
%% sequences (without the action notes) could be used in other CSPs
%% later.
%% 
%% Several examples provide different options to select (e.g., a
%% different scale to use such as major or minor). These options are
%% marked by a "SELECT" in comments.
%%
%% Usage: first feed buffer, to feed definitions shared by all
%% examples. The feed the respective example in a /* comment block */.
%%

declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}
%%
%% Configure a Explorer output action for 31 ET, which expects only a
%% sequential container with chord objects as solution (i.e. without
%% the actual notes). The Explorer output action itself then creates a
%% CSP with expects a chord sequence and returns a homophonic chord
%% progression. The arguments of the action affect this CSP for the
%% homophonic chord progression. The result is transformed into
%% music notation (with Lilypond), sound (with Csound), and Strasheela
%% code (archived score objects).
{ET31.out.addExplorerOut_ChordsToScore
 unit(outname:"ChordsToScore"
      voices:4
      pitchDomain:{ET31.pitch 'C'#3}#{ET31.pitch 'C'#5}
      value:random
%      value:min
      ignoreSopranoChordDegree:true
%      minIntervalToBass:{ET31.pc 'F'}
     )}

% {Init.setTempo 60.0}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Simple cadence in either major or minor (only diatonic
%% triads). Note that if you search for all solutions, then you find
%% only very few but highly common cadences.
%%

/*

declare
%% SELECT scale. 
MyScale = {Score.makeScore scale(index:{HS.db.getScaleIndex 'major'}
				 % index:{HS.db.getScaleIndex 'natural minor'}
				 %% no solution if no 'harmonic diminished' chords are premitted
				 % index:{HS.db.getScaleIndex 'harmonic minor'}
				 transposition:{ET31.pc 'C'})
           unit(scale:HS.score.scale)}
%%
/** %% CSP with chord sequence solution. Only diatonic chords, follow Schoebergs recommendation on good roor progression, end in cadence. 
%% */
proc {MyScript ChordSeq}
   %% settings
   N = 5			% number of chords
   Dur = 2			% dur of each chord
   %% SELECT chords
   %% only specified chord types are used 
   ChordIndices = {Map ['major'
			'minor'
			'harmonic diminished'
			'augmented'
		       ]
		   HS.db.getChordIndex}
   %% create chord objects
   Chords = {LUtils.collectN N
	     fun {$}
		{Score.makeScore2 chord(index:{FD.int ChordIndices}
					duration:Dur
					%% just to remove symmetries 
					sopranoChordDegree:1
					timeUnit:beats)
		 %% label can be either chord or inversionChord
		 unit(chord:HS.score.inversionChord)}
	     end} 
in
   %% create music representation for solution
   ChordSeq = {Score.makeScore seq(items:Chords
				   startTime:0)
	       unit}
   %% tmp: only ascending progressions
%   {Pattern.for2Neighbours Chords
%    proc {$ C1 C2} {HS.rules.schoenberg.ascendingProgressionR C1 C2 1} end}
   %% Good progression: descending progression only as 'passing chords'
   {HS.rules.schoenberg.resolveDescendingProgressions Chords unit}
   %% no super strong progression in such a simple progression
   {Pattern.for2Neighbours Chords
    proc {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2 0} end}
   %% First and last chords are equal (neither index nor transposition are distinct)
   {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   %% All chords are in root position. 
   {ForAll Chords proc {$ C} {C getBassChordDegree($)} = 1 end}
   %% only diatonic chords
   {ForAll Chords proc {$ C} {HS.rules.diatonicChord C MyScale} end}
   %% last three chords form cadence
   {HS.rules.cadence MyScale {LUtils.lastN Chords 3}}
end
%% sed random seed to date
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreAll MyScript unit(order:startTime
				  value:random
				  % value:mid
				 )}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Diatonic chord progression with chords in root position and 2nd inversion.
%%


/*

declare
%% SELECT: scale
MyScale = {Score.makeScore scale(index:{HS.db.getScaleIndex 'major'}
				 % index:{HS.db.getScaleIndex 'natural minor'}
				 % index:{HS.db.getScaleIndex 'harmonic minor'}
				 transposition:{ET31.pc 'C'})
           unit(scale:HS.score.scale)}
/** %% Constraints the pitch class interval between the bass PCs of the chords C1 and C2 to IntervalPC. IntervalPC is implicitly declared an FD int. 
%% */
proc {TransposeBassPC C1 C2 ?IntervalPC}
   {HS.score.transposePC {C1 getBassPitchClass($)} IntervalPC
    {C2 getBassPitchClass($)}}
end
%%
/** %% CSP with chord sequence solution.
%% */
proc {MyScript ChordSeq}
   %% settings
   N = 9			% number of chords
   Dur = 2			% dur of each chord
   %% SELECT: permitted chord indices
   %% only specified chord types are used 
   ChordIndices = {Map [
			'major'
			'minor'
			'harmonic diminished'
			%% 'subminor 6th'
			%% 'harmonic 7th'
			%% 'minor 7th'
			%% 'subharmonic 6th'
		       ]
		   HS.db.getChordIndex}
   %% create chord objects
   Chords = {LUtils.collectN N
	     fun {$} 
		{Score.makeScore2 chord(index:{FD.int ChordIndices}
					duration:Dur
					%% just to remove symmetries 
					sopranoChordDegree:1
					timeUnit:beats)
		 %% label can be either chord or inversionChord
		 unit(chord:HS.score.inversionChord)}
	     end} 
in
   %% create music representation for solution
   ChordSeq = {Score.makeScore seq(items:Chords
				   startTime:0)
	       unit}
   %% Good progression: ascending or descending progression only as 'passing chords'
   {HS.rules.schoenberg.resolveDescendingProgressions Chords unit}
   %% no super strong progression in such a simple progression
   {Pattern.for2Neighbours Chords
    proc {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2 0} end}
   %% First and last chords are equal (neither index nor transposition are distinct)
   {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   %% last three chords form cadence
   {HS.rules.cadence MyScale {LUtils.lastN Chords 3}}
   %% only diatonic chords
   {ForAll Chords proc {$ C} {HS.rules.diatonicChord C MyScale} end}
%    %% If not root position, then stepwise bass progression (max interval corresponds to pitch class of 'D|')
%    {Pattern.for2Neighbours Chords
%     proc {$ C1 C2}
%        {FD.impl {FD.nega ({C1 getBassChordDegree($)} =: 1)}
% 	({TransposeBassPC C1 C2} =<: {ET31.pc 'D|'})
% 	1}
%     end}
   %% Most chords are in root positon, some are in second inversion
   {Pattern.percentTrue_Range {Map Chords fun {$ C} ({C getBassChordDegree($)} =: 1) end}
    60 85}
   %% Sometimes bass progresses stepwise 
   {Pattern.percentTrue_Range
    {Pattern.map2Neighbours Chords
     fun {$ C1 C2} ({TransposeBassPC C1 C2} =<: {ET31.pc 'D|'}) end}
   10 40}
end
%% sed random seed to date
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript unit(order:startTime
				  value:random
				  % value:mid
				 )}


*/





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Diatonic chord progression which allows for 7-limit chords.
%%

/*

declare
%% SELECT scale. 
MyScale = {Score.makeScore scale(% index:{HS.db.getScaleIndex 'major'}
				 % index:{HS.db.getScaleIndex 'natural minor'}
				 %% no solution if no 'harmonic diminished' chords are premitted
				 % index:{HS.db.getScaleIndex 'harmonic minor'}
				 index:{HS.db.getScaleIndex 'septimal natural minor'}
				 transposition:{ET31.pc 'C'})
           unit(scale:HS.score.scale)}
%%
/** %% CSP with chord sequence solution. Only diatonic chords, follow Schoebergs recommendation on good roor progression, end in cadence. 
%% */
proc {MyScript ChordSeq}
   %% settings
   N = 5			% number of chords
   Dur = 2			% dur of each chord
   %% SELECT chords
   %% only specified chord types are used 
   ChordIndices = {Map [% 'major'
			% 'minor'
			'harmonic diminished'
			% 'augmented'
			'utonal diminished'
			'subminor'
			'supermajor'
		       ]
		   HS.db.getChordIndex}
   %% create chord objects
   Chords = {LUtils.collectN N
	     fun {$}
		{Score.makeScore2 chord(index:{FD.int ChordIndices}
					duration:Dur
					%% just to remove symmetries 
					sopranoChordDegree:1
					timeUnit:beats)
		 %% label can be either chord or inversionChord
		 unit(chord:HS.score.inversionChord)}
	     end} 
in
   %% create music representation for solution
   ChordSeq = {Score.makeScore seq(items:Chords
				   startTime:0)
	       unit}
   %% tmp: only ascending progressions
   {Pattern.for2Neighbours Chords
    proc {$ C1 C2} {HS.rules.schoenberg.ascendingProgressionR C1 C2 1} end}
   %% Good progression: descending progression only as 'passing chords'
   {HS.rules.schoenberg.resolveDescendingProgressions Chords unit}
   %% no super strong progression in such a simple progression
   {Pattern.for2Neighbours Chords
    proc {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2 0} end}
   %% First and last chords are equal (neither index nor transposition are distinct)
   {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   %% All chords are in root position. 
   {ForAll Chords proc {$ C} {C getBassChordDegree($)} = 1 end}
   %% only diatonic chords
   {ForAll Chords proc {$ C} {HS.rules.diatonicChord C MyScale} end}
   %% last three chords form cadence
   {HS.rules.cadence MyScale {LUtils.lastN Chords 3}}
end
%% sed random seed to date
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreAll MyScript unit(order:startTime
				  value:random
				  % value:mid
				 )}

*/






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Chord progression in extended tonality (not simply diatonic),
%% however ending with cadend in C. Progression forms a sequence
%% (cycle pattern of root intervals, chord indicess etc).
%%
%% Uncommon but nice progressions result :) 
%%
%% These progressions use simple triads, the next example is similar but uses more complex tetrads
%%

/*

declare
MyScale = {Score.makeScore scale(index:{HS.db.getScaleIndex 'major'}
				 transposition:{ET31.pc 'C'})
           unit(scale:HS.score.scale)}
/** %% Constraints the pitch class interval between the bass PCs of the chords C1 and C2 to IntervalPC. IntervalPC is implicitly declared an FD int. 
%% */
proc {TransposeBassPC C1 C2 ?IntervalPC}
   {HS.score.transposePC {C1 getBassPitchClass($)} IntervalPC
    {C2 getBassPitchClass($)}}
end
%%
/** %% CSP with chord sequence solution.
%% */
proc {MyScript ChordSeq}
   %% settings
   N = 19			% number of chords
   Dur = 2			% dur of each chord
   %% only specified chord types are used 
   ChordIndices = {Map [
			'major'
			'minor'
		       ]
		   HS.db.getChordIndex}
   %% create chord objects
   Chords = {LUtils.collectN N
	     fun {$} 
		{Score.makeScore2 chord(index:{FD.int ChordIndices}
					duration:Dur
					%% just to remove symmetries 
					sopranoChordDegree:1
					timeUnit:beats)
		 %% label can be either chord or inversionChord
		 unit(chord:HS.score.inversionChord)}
	     end} 
in
   %% create music representation for solution
   ChordSeq = {Score.makeScore seq(items:Chords
				   startTime:0)
	       unit}
   %% Good progression: ascending or descending progression only as 'passing chords'
   {HS.rules.schoenberg.resolveDescendingProgressions Chords unit}
   %% no super strong progression in such a simple progression
   {Pattern.for2Neighbours Chords 
    proc {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2 0} end}
   %% First and last chords are equal (neither index nor transposition are distinct)
   {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   %% no 6/4 chords (no 2nd inversion)
   {ForAll Chords proc {$ C} ({C getBassChordDegree($)} =: 3) = 0 end}
   %% Most chords are in root posiiton, some are in second inversion
   {Pattern.percentTrue_Range {Map Chords fun {$ C} ({C getBassChordDegree($)} =: 1) end}
    60 85}
   %% Sometimes bass progresses stepwise 
   {Pattern.percentTrue_Range
    {Pattern.map2Neighbours Chords
     fun {$ C1 C2} ({TransposeBassPC C1 C2} =<: {ET31.pc 'D|'}) end}
   30 70}
   %% last three chords form cadence
   {HS.rules.cadence MyScale {LUtils.lastN Chords 3}}
   %% The chord root intervals and the absolute indices form a non-overlapping cycle pattern 
   {Pattern.for2Neighbours
    {Map {LUtils.sublists Chords [1#5
				  5#9
				  9#13
				  13#17]}
     %% returns pair of chord root intervals, chord indices plus bass chord degrees (inversion), and interval between the first chords of two neighbouring pattern instances 
     fun {$ Cs}
	{Pattern.map2Neighbours {LUtils.butLast Cs}
	 proc {$ C1 C2 ?RootInterval}
	    {HS.score.transposePC {C1 getRoot($)} RootInterval {C2 getRoot($)}}
	 end}
	# {Map {LUtils.butLast Cs} fun {$ C} {C getIndex($)} # {C getBassChordDegree($)} end}
	# {HS.score.transposePC {Cs.1 getRoot($)} $ {{List.last Cs} getRoot($)}}
     end}
    proc {$ Data1 Data2} Data1 = Data2 end}
    %% sub seq of chord root intervals form cycle pattern
   %% 10 chords, 8 intervals
   %% NOTE: interlocking sequence. I could also unify successive sublists (without overlap) 
%    {Pattern.cycle {Pattern.map2Neighbours {LUtils.sublist Chords 2 11}
% 		   TransposeBassPC}
%     3}
end
%% sed random seed to date
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript unit(order:startTime
				  value:random
				  % value:mid
				 )}


*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Chord progression in extended tonality (not simply diatonic), with only ascending progressions of various tetrads. Ending with cadend in C. 
%%
%% Uncommon but nice progressions result :) 
%%

/*

declare
{ET31.out.addExplorerOut_ChordsToScore
 unit(outname:"ChordsToScore"
      voices:5
      pitchDomain:{ET31.pitch 'C'#3}#{ET31.pitch 'C'#6}
%      value:random
      value: min % mid
      ignoreSopranoChordDegree:true
      minIntervalToBass: {ET31.pc 'F'}
     )}
MyScale = {Score.makeScore scale(index:{HS.db.getScaleIndex 'major'}
				 transposition:{ET31.pc 'C'})
           unit(scale:HS.score.scale)}
/** %% Constraints the pitch class interval between the bass PCs of the chords C1 and C2 to IntervalPC. IntervalPC is implicitly declared an FD int. 
%% */
proc {TransposeBassPC C1 C2 ?IntervalPC}
   {HS.score.transposePC {C1 getBassPitchClass($)} IntervalPC
    {C2 getBassPitchClass($)}}
end
%%
/** %% CSP with chord sequence solution.
%% */
proc {MyScript ChordSeq}
   %% settings
   N = 9			% number of chords
   Dur = 2			% dur of each chord
   %% only specified chord types are used 
   ChordIndices = {Map [
% 			'dominant 7th'
 			'minor 6th'
 			'subminor 6th'
 			'harmonic 7th'
 			'subharmonic 6th'
 			'mix of plain and reversed harmonic dominant 7th'
 			'minor 7th'
 			'sixte ajoutee'
			%% 
			'major 7th'
			'major 9th'
			'minor 9th'
			'harmonic 9th'
			'harmonic half-diminished 7th'
%			'added-2nd'
			'subminor 7th'			
		       ]
		   HS.db.getChordIndex}
   %% create chord objects
   Chords = {LUtils.collectN N
	     fun {$} 
		{Score.makeScore2 chord(index:{FD.int ChordIndices}
					duration:Dur
					%% just to remove symmetries 
					sopranoChordDegree:1
					timeUnit:beats)
		 %% label can be either chord or inversionChord
		 unit(chord:HS.score.inversionChord)}
	     end} 
in
   %% create music representation for solution
   ChordSeq = {Score.makeScore seq(items:Chords
				   startTime:0)
	       unit}
   %% only ascending progressions
   {Pattern.for2Neighbours Chords 
    proc {$ C1 C2} {HS.rules.schoenberg.ascendingProgressionR C1 C2 1} end}
   {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   %% no 6/4 chords (no 2nd inversion)
   {ForAll Chords proc {$ C} ({C getBassChordDegree($)} =: 3) = 0 end}
   %% Most chords are in root positon, some are in second inversion
   {Pattern.percentTrue_Range {Map Chords fun {$ C} ({C getBassChordDegree($)} =: 1) end}
    60 85}
   %% Sometimes bass progresses stepwise 
   {Pattern.percentTrue_Range
    {Pattern.map2Neighbours Chords
     fun {$ C1 C2} ({TransposeBassPC C1 C2} =<: {ET31.pc 'D|'}) end}
   30 70}
   %% last three chords form cadence
   {HS.rules.cadence MyScale {LUtils.lastN Chords 3}}
end
%% sed random seed to date
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript unit(order:startTime
				  value:random
				  % value:mid
				 )}


*/





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Chord progression in extended tonality (not simply diatonic),
%% however ending with cadend in C. Progression forms a sequence
%% (cycle pattern of root intervals, chord indicess etc). Only
%% ascending chord progressions.
%%
%% Uncommon but nice progressions result :) 
%%

/*

declare
{ET31.out.addExplorerOut_ChordsToScore
 unit(outname:"ChordProgressions-withSequences"
      voices:5
      pitchDomain:{ET31.pitch 'C'#3}#{ET31.pitch 'C'#6}
%      value:random
      value: min % mid
      ignoreSopranoChordDegree:true
      minIntervalToBass: {ET31.pc 'F'}
     )}
MyScale = {Score.makeScore scale(index:{HS.db.getScaleIndex 'major'}
				 transposition:{ET31.pc 'C'})
           unit(scale:HS.score.scale)}
/** %% Constraints the pitch class interval between the bass PCs of the chords C1 and C2 to IntervalPC. IntervalPC is implicitly declared an FD int. 
%% */
proc {TransposeBassPC C1 C2 ?IntervalPC}
   {HS.score.transposePC {C1 getBassPitchClass($)} IntervalPC
    {C2 getBassPitchClass($)}}
end
%%
/** %% CSP with chord sequence solution.
%% */
proc {MyScript ChordSeq}
   %% settings
   %% TMP comment
   N = 19			% number of chords
   Dur = 2			% dur of each chord
   %% only specified chord types are used 
   ChordIndices = {Map [
% 			'dominant 7th'
 			'minor 6th'
 			'subminor 6th'
 			'harmonic 7th'
 			'subharmonic 6th'
 			'mix of plain and reversed harmonic dominant 7th'
 			'minor 7th'
 			'sixte ajoutee'
			%% 
			'major 7th'
			'major 9th'
			'minor 9th'
			'harmonic 9th'
			'harmonic half-diminished 7th'
%			'added-2nd'
			'subminor 7th'			
		       ]
		   HS.db.getChordIndex}
   %% create chord objects
   Chords = {LUtils.collectN N
	     fun {$} 
		{Score.makeScore2 chord(index:{FD.int ChordIndices}
					duration:Dur
					%% just to remove symmetries 
					sopranoChordDegree:1
					timeUnit:beats)
		 %% label can be either chord or inversionChord
		 unit(chord:HS.score.inversionChord)}
	     end} 
in
   %% create music representation for solution
   ChordSeq = {Score.makeScore seq(items:Chords
				   startTime:0)
	       unit}
   %% only ascending progressions
   {Pattern.for2Neighbours Chords 
    proc {$ C1 C2} {HS.rules.schoenberg.ascendingProgressionR C1 C2 1} end}
%    %% Good progression: ascending or descending progression only as 'passing chords'
%    {HS.rules.schoenberg.resolveDescendingProgressions Chords unit}
%    %% no super strong progression in such a simple progression
%    {Pattern.for2Neighbours Chords 
%     proc {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2 0} end}
   %% First and last chords are equal (neither index nor transposition are distinct)
   {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   %% no 6/4 chords (no 2nd inversion)
   {ForAll Chords proc {$ C} ({C getBassChordDegree($)} =: 3) = 0 end}
   %% Most chords are in root positon, some are in second inversion
   {Pattern.percentTrue_Range {Map Chords fun {$ C} ({C getBassChordDegree($)} =: 1) end}
    60 85}
   %% Sometimes bass progresses stepwise 
   {Pattern.percentTrue_Range
    {Pattern.map2Neighbours Chords
     fun {$ C1 C2} ({TransposeBassPC C1 C2} =<: {ET31.pc 'D|'}) end}
   30 70}
   %% last three chords form cadence
   {HS.rules.cadence MyScale {LUtils.lastN Chords 3}}
   %% The chord root intervals and the absolute indices form a non-overlapping cycle pattern 
   %% TMP comment
   {Pattern.for2Neighbours
    {Map {LUtils.sublists Chords [1#5
				  5#9
				  9#13
				  13#17]}
     %% returns pair of chord root intervals, chord indices plus bass chord degrees (inversion), and interval between the first chords of two neighbouring pattern instances 
     fun {$ Cs}
	{Pattern.map2Neighbours {LUtils.butLast Cs}
	 proc {$ C1 C2 ?RootInterval}
	    {HS.score.transposePC {C1 getRoot($)} RootInterval {C2 getRoot($)}}
	 end}
	# {Map {LUtils.butLast Cs} fun {$ C} {C getIndex($)} # {C getBassChordDegree($)} end}
	# {HS.score.transposePC {Cs.1 getRoot($)} $ {{List.last Cs} getRoot($)}}
     end}
    proc {$ Data1 Data2} Data1 = Data2 end}
end
%% sed random seed to date
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript unit(order:startTime
				  value:random
				  % value:mid
				 )}


*/




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Variant of previous example with less common chords.
%% No resolution of dissonances..
%%

/*

declare
% MyScale = {Score.makeScore scale(index:{HS.db.getScaleIndex 'major'}
% 				 % index:{HS.db.getScaleIndex 'natural minor'}
% 				 % index:{HS.db.getScaleIndex 'harmonic minor'}
% 				 transposition:{ET31.pc 'C'})
%            unit(scale:HS.score.scale)}
/** %% Constraints the pitch class interval between the bass PCs of the chords C1 and C2 to IntervalPC. IntervalPC is implicitly declared an FD int. 
%% */
proc {TransposeBassPC C1 C2 ?IntervalPC}
   {HS.score.transposePC {C1 getBassPitchClass($)} IntervalPC
    {C2 getBassPitchClass($)}}
end
%%
/** %% CSP with chord sequence solution.
%% */
proc {MyScript ChordSeq}
   %% settings
   N = 19			% number of chords
   Dur = 2			% dur of each chord
   %% only specified chord types are used 
   ChordIndices = {Map [
			% 'major'
			% 'minor'
			'harmonic diminished'
			'subminor 6th'
			'harmonic 7th'
			'minor 7th'
			'subharmonic 6th'
		       ]
		   HS.db.getChordIndex}
   %% create chord objects
   Chords = {LUtils.collectN N
	     fun {$} 
		{Score.makeScore2 chord(index:{FD.int ChordIndices}
					duration:Dur
					%% just to remove symmetries 
					sopranoChordDegree:1
					timeUnit:beats)
		 %% label can be either chord or inversionChord
		 unit(chord:HS.score.inversionChord)}
	     end} 
in
   %% create music representation for solution
   ChordSeq = {Score.makeScore seq(items:Chords
				   startTime:0)
	       unit}
   %% Good progression: ascending or descending progression only as 'passing chords'
   {HS.rules.schoenberg.resolveDescendingProgressions Chords unit}
   %% no super strong progression in such a simple progression
   {Pattern.for2Neighbours Chords 
    proc {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2 0} end}
   %% First and last chords are equal (neither index nor transposition are distinct). Root is C.
   {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   {Chords.1 getRoot($)} = {ET31.pc 'C'}
   %% no 6/4 chords (no 2nd inversion)
   {ForAll Chords proc {$ C} ({C getBassChordDegree($)} =: 3) = 0 end}
   %% Most chords are in root posiiton, some are in second inversion
   {Pattern.percentTrue_Range {Map Chords fun {$ C} ({C getBassChordDegree($)} =: 1) end}
    60 85}
   %% Sometimes bass progresses stepwise 
   {Pattern.percentTrue_Range
    {Pattern.map2Neighbours Chords
     fun {$ C1 C2} ({TransposeBassPC C1 C2} =<: {ET31.pc 'D|'}) end}
   30 70}
   %% last three chords form cadence
%   {HS.rules.cadence MyScale {LUtils.lastN Chords 3}}
   %% The chord root intervals and the absolute indices form a non-overlapping cycle pattern 
   {Pattern.for2Neighbours
    {Map {LUtils.sublists Chords [1#5
				  5#9
				  9#13
				  13#17]}
     %% returns pair of chord root intervals, chord indices plus bass chord degrees (inversion), and interval between the first chords of two neighbouring pattern instances 
     fun {$ Cs}
	{Pattern.map2Neighbours {LUtils.butLast Cs}
	 proc {$ C1 C2 ?RootInterval}
	    {HS.score.transposePC {C1 getRoot($)} RootInterval {C2 getRoot($)}}
	 end}
	# {Map {LUtils.butLast Cs} fun {$ C} {C getIndex($)} # {C getBassChordDegree($)} end}
	# {HS.score.transposePC {Cs.1 getRoot($)} $ {{List.last Cs} getRoot($)}}
     end}
    proc {$ Data1 Data2} Data1 = Data2 end}
end
%% sed random seed to date
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript unit(order:startTime
				  value:random
				  % value:mid
				 )}


*/





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Creates short demo chord progression in 31 ET. Neighbouring chords
%%  are harmonically closely related, but the example does not
%%  necessarily stay in a single key. The example also demonstrates
%%  one of the Schoenberg constraints: all chord progressions are
%%  either ascending, or some decending progression is only a 'passing
%%  chord'. See HS.rules.schoenberg for details on these constraints.
%% 
%% The solution contains a bare chord sequence, use the Explorer
%% action "ChordsToScore" to actually read and hear a solution.
%%

/*

declare
/** %% CSP with chord sequence solution.
%% */
proc {MyScript ChordSeq}
   %% settings
   N = 9			% number of chords
   Dur = 2			% dur of each chord
   %% only specified chord types are used 
   ChordIndices = {Map [% 'harmonic diminished'
			% 'subminor 6th'
			'harmonic 7th'
			% 'minor 7th'
			'subharmonic 6th']
		   HS.db.getChordIndex}
   %% create chord objects
   Chords = {LUtils.collectN N
	     fun {$} 
		{Score.makeScore2 chord(index:{FD.int ChordIndices}
					duration:Dur
					%% just to remove symmetries 
					% sopranoChordDegree:1
					timeUnit:beats)
		 %% label can be either chord or inversionChord
		 unit(chord:HS.score.inversionChord)}
	     end} 
in
   %% create music representation for solution
   ChordSeq = {Score.makeScore seq(items:Chords
				   startTime:0)
	       unit}
   %% Good progression: ascending or descending progression only as 'passing chords'
   {HS.rules.schoenberg.resolveDescendingProgressions Chords unit}
   %% no super strong progression in such a simple progression
   {Pattern.for2Neighbours Chords 
    proc {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2 0} end}
   %% First and last chords are equal (neither index nor transposition are distinct)
   {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   %% roots of all other chords are distinct
   {FD.distinct {Map Chords.2 fun {$ X} {X getRoot($)} end}}
   %% first chord is harmonic dominant seventh in C
   {Chords.1 getIndex($)} = {HS.db.getChordIndex 'harmonic 7th'}
   {Chords.1 getRoot($)} = {ET31.pc 'C'}
   %% 30-70% are minor chords
   {Pattern.percentTrue_Range
    {Map Chords proc {$ C B}
		   B = ({C getIndex($)} =: {HS.db.getChordIndex
					    'subharmonic 6th'})
		end}
    30 70}
   %% chord indices form cycle pattern
   {Pattern.cycle {Map Chords fun {$ C} {C getIndex($)} end} 3}
   %% All chords are in root position. 
   {ForAll Chords proc {$ C} {C getBassChordDegree($)} = 1 end}
end
%% sed random seed to date
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript unit(order:startTime
				  value:random
				  % value:mid
				 )}


*/



