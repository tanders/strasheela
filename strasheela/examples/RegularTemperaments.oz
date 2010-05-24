
%%
%% 
%%

declare
[HS RegT]
= {ModuleLink ['x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
	       'x-ozlib://anders/strasheela/RegularTemperament/RegularTemperament.ozf']}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Creating a few different regular temperaments (list of integers
%% measured in cent or millicent)
%%
%%


%% 5-limit JI
{HS.db.makeRegularTemperament [702 386] % generators for 3/2 and 5/4 in cent
 %% Pitch class 0 is always C
 %% Generate 6 fifths from C downwards (i.e. up to Gb) and 6 fifths upwards (i.e. up to F#)
 %% In addition, from each tone in the chain of fifths generate a major third up and down.
 %% So, there will be 13*3 = 39 pitches in total
 [~6#6 ~1#1]
 %% measure in cent
 unit(pitchesPerOctave:1200)}

%% 12-TET: starting from 0 (C) generate 12 semitones of 100 cent each
{HS.db.makeRegularTemperament [100] [0#11] unit(pitchesPerOctave:1200)}


%% 31-TET: generator 38.71 cent (see http://en.wikipedia.org/wiki/31_equal_temperament)
%% Adding a rounded generator accumulates an error.
%% This example creates 32 tones with the generator of 31-TET, so ideally the last pitch class should be 0 again. Instead, when measured in cent the last pitch class is 9 cent (the second pitch class in the resulting list). In other words, there is an error accumulating. 
{HS.db.makeRegularTemperament [39] [0#31] unit(pitchesPerOctave:1200)}

%% When generating 32 tones with the generator of 31-TET but now measured in millicent, the accumulating error is only 1 millicent.
{HS.db.makeRegularTemperament [3871] [0#31] unit(pitchesPerOctave:120000)}


%% NOTE: Regular temperaments are usually not circular (the exception are equal temperaments discussed above). Therefore, the accumulating error is less a problem: pitch class operations like transpositions also work if there is an error due to the rounding.


%% A chain of 14 fifths of 1/4 comma meantone, measured in millicent 
{HS.db.makeRegularTemperament [69659] [~6#7] unit(pitchesPerOctave:120000)}





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Finding a temperament pitch class that best approximates a certain ratio
%%

%% How great is the error of, e.g., 7/4 in a chain of 21 1/4 comma meantone fifths (measured in millisend)? The interval C-A# closely approximates 7/4, the error reported here (second value of the returned pair) is 2.93 cent.
%% BUG: ??
local
   PitchesPerOctave = 120000
in
   {HS.db.ratioToRegularTemperamentPC 7#4 % 3#2 5#1 7#4    
    %% ratioToRegularTemperamentPC expects a tuple, by default
    %% HS.db.makeRegularTemperament returns a list
    unit(pitchesPerOctave:PitchesPerOctave
	 temperament: {List.toTuple unit
		       {HS.db.makeRegularTemperament [69659] [~10#10]
			unit(pitchesPerOctave:PitchesPerOctave)}}
	 %% also show how much the JI ratio and the PC differ 
	 showError:true)}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Gobally setting a temperament, including adjusting a database of chords, scales etc to this temperament 
%%

%% Globally set temperament to 1/4-comma meantone (millicent resolution)
{HS.db.setDB {RegT.db.makeFullDB
	      unit(generators: [69659]
		   generatorFactors: [90#110] % 21 tones
		   generatorFactorsOffset: 100
		   pitchesPerOctave:120000
		   %% chords/scale/interval databases where the difference between their original definition (currently only JI) and the tempered version exceeds this error (3000 millicent) are automatically excluded
		   %% Note: excluded database entries are listed at standard out (*Oz Emulator* buffer)
		   maxError:3000)}}

%% watch the chord database
{Browse
 {HS.db.getEditChordDB}}

%% access the index for certain chords
{HS.db.getChordIndex major}
{HS.db.getChordIndex 'harmonic 7th'}

%% watch a single chord: note how the pitch classes of the chord are rounded to the temperament.
%% the 5 millicent error of 5#1 is caused by an accumulated error of a rounded generator, but an error of 5 millicent should be ignorable in all practical situations...
{Browse
 {HS.db.getEditChordDB}.{HS.db.getChordIndex major}}

%% example for excluded chord with maxError=3000. The error of 21#2 is 3263#millicent.
%% This chord is likely included with longer chain of meantone fifths (i.e. larger range of generatorFactors). 
/* 
chord(comment:chord(comment:'subminor 7th'
		    essentialPitchClasses:[unit(ji_error:~537#millicent pc:69659 ratio:6#1)
					   unit(ji_error:~293#millicent pc:96590 ratio:7#1)
					   unit(ji_error:~1073#millicent pc:19318 ratio:9#1)
					   unit(ji_error:3263#millicent pc:50341 ratio:21#2)]
		    pitchClasses:[unit(ji_error:~537#millicent pc:69659 ratio:6#1)
				  unit(ji_error:~293#millicent pc:96590 ratio:7#1)
				  unit(ji_error:~1073#millicent pc:19318 ratio:9#1)
				  unit(ji_error:3263#millicent pc:50341 ratio:21#2)]
		    roots:[unit(ji_error:~537#millicent pc:69659 ratio:6#1)])
      essentialPitchClasses:[69659 96590 19318 50341]
      pitchClasses:[69659 96590 19318 50341]
      roots:[69659])
*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Gobally setting a high-limit JI, and then examine the chord/scale database
%%

%% NOTE: very large number of pitch classes (26244 PCs) -- loading this database takes time!
%% NOTE: with millicent there are dublicate pitch classes!
declare
PitchesPerOctave = 12000000
PitchesPerOctave_F = {IntToFloat PitchesPerOctave}
fun {RatioToPC Ratio}
   {FloatToInt {MUtils.ratioToKeynumInterval Ratio PitchesPerOctave_F}} mod PitchesPerOctave
end
{HS.db.setDB {RegT.db.makeFullDB
	      unit(generators: [{RatioToPC 3#1}
				{RatioToPC 5#1}
				{RatioToPC 7#1}
				{RatioToPC 11#1}
				{RatioToPC 13#1}
				{RatioToPC 17#1}
				{RatioToPC 19#1}
				{RatioToPC 23#1}]
		   generatorFactors: [~5#6
				      ~1#1
				      ~1#1
				      ~1#1
				      ~1#1
				      ~1#1
				      ~1#1
				      ~1#1] 
		   pitchesPerOctave:120000
		   %% small error: 1 cent
		   maxError:100)}}


{Width {HS.db.getTemperament}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Homophonic chord progression in 1/4-comma meantone with only major and minor chords. This example is primarily intended to show how to do things technically and to check whether it results in expected solutions. More interesting things below, which could not be easily approximated by some equal temperament already supported by Strasheela.
%%
%%


%%
%% TODO:
%%
%% - use RegularTemperament notes. However, this should not even be necessary if I don't use the params generators or generatorFactors
%% - reduce all pitch classes to pitch classes of temperament. Not necessary if PCs are reduced to underlying scale
%% - simple notation output: 12-TET with cent annotations.
%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% First simplistic example, result is a sequence of chord objects 
%%


declare
%% 1/4-comma meantone
%% NOTE: in the temperament examples above, the generatorFoctorsOffset was always 0 (the default) for simplicity so that negative numbers in generatorFactors correspond to donward transpositions of the respective generator.
%% In constraint problems were generatorFactors are represented FD ints, negative numbers must be avoided and so generatorFoctorsOffset must be greater than 0. For example, 100 is a useful settig: a generatorFactor of, say 98 then corresponds to ~2.
{HS.db.setDB {RegT.db.makeFullDB
	      unit(generators: [69659]
% 		   generatorFactors: [94#106] % 13 tones
		   %% Note: with 21 fifths there is another PC closer to 81/64 than 5/4
		   %% 8 fifths down (Fb, 427.28 cent) is closer to 81/64 than 5/4 
		   generatorFactors: [90#110] % 21 tones
		   generatorFactorsOffset: 100
		   pitchesPerOctave:120000
		   maxError:3000)}}
MyScale = {Score.makeScore scale(index:{HS.db.getScaleIndex 'major'}
% 				 transposition:{RegT.jiPC 'C'#''}
				 transposition:0
				)
	   unit(scale:HS.score.scale)}
%%
/** %% CSP with chord sequence solution. Only diatonic chords, follow Schoebergs recommendation on good root progression, end in cadence. 
%% */
proc {MyScript ChordSeq}
   %% settings
   N = 5			% number of chords
   Dur = 2			% dur of each chord
   %% SELECT chords
   %% only specified chord types are used 
   ChordIndices = {Map ['major'
			'minor'
% 			'harmonic diminished'
% 			'augmented'
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
   {HS.rules.distinctNeighbours Chords}
   {HS.rules.neighboursWithCommonPCs Chords}
   %% First and last chords are equal (neither index nor transposition are distinct)
   {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   %% All chords are in root position. 
   {ForAll Chords proc {$ C} {C getBassChordDegree($)} = 1 end}
   %% only diatonic chords
   {ForAll Chords proc {$ C} {HS.rules.diatonicChord C MyScale} end}
   %% last three chords form cadence
   {HS.rules.cadence MyScale {LUtils.lastN Chords 3}}
end
{GUtils.setRandomGeneratorSeed 0}
[MyScore] = {SDistro.searchOne MyScript unit(order:startTime
					     value:random
				  % value:mid
					    )}
{Browse {MyScore toInitRecord($)}}

{MyScale toInitRecord($)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Simple cadence in either major or minor (only diatonic
%% triads). Note that if you search for all solutions, then you find
%% only very few but highly common cadences.
%%


declare
%% 1/4-comma meantone
{HS.db.setDB {RegT.db.makeFullDB
	      unit(generators: [69659]
% 		   generatorFactors: [94#106] % 13 tones
		   %% Note: with 21 fifths there is another PC closer to 81/64 than 5/4
		   %% 8 fifths down (Fb, 427.28 cent) is closer to 81/64 than 5/4 
		   generatorFactors: [90#110] % 21 tones
		   generatorFactorsOffset: 100
		   pitchesPerOctave:120000
		   maxError:3000)}}
{GUtils.setRandomGeneratorSeed 0}
%% Schoenberg rules
proc {MyScript MyScore}
   Chords = {HS.score.makeChords
	     unit(iargs: unit(n:5
% 					     constructor:HS.score.inversionChord
			      constructor:HS.score.fullChord
			      duration: 2
			      bassChordDegree: 1)
		  rargs: unit(types: ['major'
				      'minor'
% 				      'geometric diminished'
				     ]))}
in
   MyScore = {Segs.homophonicChordProgression
	      unit(voiceNo: 4
		   iargs: unit(inChordB: 1
			       inScaleB: 1
			      )
		   %% one pitch dom spec for each voice
		   rargs: each # [unit(minPitch: {RegT.jiPitch 'C'#''#4}
				       maxPitch: {RegT.jiPitch 'A'#''#5})
				  unit(minPitch: {RegT.jiPitch 'G'#''#3} 
				       maxPitch: {RegT.jiPitch 'E'#''#5})
				  unit(minPitch: {RegT.jiPitch 'C'#''#3} 
				       maxPitch: {RegT.jiPitch 'A'#''#4})
				  unit(minPitch: {RegT.jiPitch 'E'#''#2} 
				       maxPitch: {RegT.jiPitch 'D'#''#4})]
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
% {SDistro.exploreOne MyScript
%  %% left-to-right strategy with breaking ties by type
%  HS.distro.leftToRight_TypewiseTieBreaking}
[MyScore] = {SDistro.searchOne MyScript
	     %% left-to-right strategy with breaking ties by type
	     HS.distro.leftToRight_TypewiseTieBreaking}
%% Output
{Out.renderFomus MyScore
 unit(file: "Meantone-RegularTemperament"
      eventClauses: [{HS.out.makeNoteToFomusClause
		      unit(getPitchClass: midi
			   getSettings: HS.out.makeCentOffset_FomusMarks)}
		     {HS.out.makeChordToFomusClause unit(getPitchClass: midi
							 getSettings:HS.out.makeChordComment_FomusForLilyMarks)}
		     {HS.out.makeScaleToFomusClause unit(getPitchClass: midi
							 getSettings:HS.out.makeScaleComment_FomusForLilyMarks)}])}
{Out.renderAndPlayCsound MyScore
 unit(file: "Meantone-RegularTemperament")}









