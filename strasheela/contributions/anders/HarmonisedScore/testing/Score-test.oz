
declare
[HS Pattern]
= {ModuleLink ['x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
		'x-ozlib://anders/strasheela/pattern/Pattern.ozf']}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% translating keynums, pitch classes etc.
%%


%% % % % % % % % % % % % % %
%%
%% HS.score.pitchClassToPitch
%%

%% check
{HS.db.getPitchesPerOctave} == 12

declare
Pitch = {FD.decl}
PitchClass = {HS.db.makePitchClassFDInt}
Octave = {FD.int 0#10} % {HS.db.makeOctaveFDInt}

{Browse [Pitch PitchClass Octave]}

{HS.score.pitchClassToPitch PitchClass#Octave Pitch}

%% test 1
Pitch = 60
%% -> PitchClass=0, Octave=5

%% test 2
Pitch = 13
%% -> PitchClass=1, Octave=0

%% NB: Pitch always >= PitchesPerOctave
%% use HS.score.pitchClassToPitch2 for smaller pitches 

%%%%%

{HS.db.setDB unit(pitchesPerOctave:1200)}

declare
Pitch = {FD.decl}
PitchClass = {HS.db.makePitchClassFDInt}
Octave = {HS.db.makeOctaveFDInt}

{Browse [Pitch PitchClass Octave]}

{HS.score.pitchClassToPitch PitchClass#Octave Pitch}

%% test 3
Octave = 5
PitchClass = 1
%% -> Pitch=6001



{HS.db.setDB unit(pitchesPerOctave:12)}

declare
Interval = {FD.decl}
IntervalPC = {FD.decl}
Octave = {FD.int 0#5} %% !! 0 must be in domain

{Browse [Interval IntervalPC Octave]}

{HS.score.intervalPCToInterval IntervalPC#Octave Interval}

%% test 1
Interval = 3
Octave = 0
% IntervalPC = 3

%% test 2
Interval = 14
% Octave = 1
% IntervalPC = 2





%% % % % % % % % % % % % % %
%%
%% HS.score.transposePC
%%

%% check
{HS.db.getPitchesPerOctave} == 12

declare
UnTranspPC = {FD.decl}
Transposition = {FD.decl}
TranspPC = {FD.decl}

{Browse [UnTranspPC Transposition TranspPC]}

{HS.score.transposePC UnTranspPC Transposition TranspPC}

%% test 1
UnTranspPC = 1
Transposition = 2
%% -> TranspPC = 3

%% test 2: 'wrap around of TranspPC'
Transposition = 10
TranspPC = 4
%% -> UnTranspPC = 6

%% test 3
UnTranspPC = 6
TranspPC = 5
%% -> Transposition = 11



%% % % % % % % % % % % % % %
%%
%% HS.score.degreeToPC
%%

%% check
{HS.db.getPitchesPerOctave} == 12
{HS.db.getAccidentalOffset} == 2


declare
CollectionPCs = [0 4 7]		% major
PC = {HS.db.makePitchClassFDInt}
Accidental = {HS.db.makeAccidentalFDInt}
%% after posting HS.score.degreeToPC  propagated nicely: indices into CollectionPCs 
Degree = {FD.decl}		

{Browse [CollectionPCs PC Degree Accidental]}

{HS.score.degreeToPC CollectionPCs Degree#Accidental PC}

%% when def of HS.score.degreeToPC was too simple (no 'wrapping around' of PC, only summing and selection constraint and not FD.mod) propagation was much better.. (e.g. after Accidental was determined (e.g. to neutral) the domain of PC was reduced to the three possiblee values)
%% Now, only determining Accidental does not reduce domain of PC. However, I tried FD.modD to improve things -- propagation took whole system down...

%% test 1:
Accidental={HS.db.getAccidentalOffset} % i.e. accidental is neutral
Degree=2
%% -> PC=4

%% test 2
PC=3 
%% -> Degree=1, Accidental=1 (i.e. {HS.db.getAccidentalOffset}-1)

%% test 3
Degree = 1			% no propagation to PC -- bound propagation..
Accidental = 0 % i.e. bb
%% -> PC=10 

%% test 4
Degree = 2			% of course, better propagation then in test 3
Accidental = 1 % i.e. b
%% -> PC=3



%% % % % % % % % % % % % % % % % % % % % % % %
%%
%% HS.score.transposeDegree
%%

declare
CollectionPCs = [0 2 4 5 7 9 11] %% C-major
UntransposedDegree#UntransposedAccidental#UntransposedPC = {FD.decl}#{HS.db.makeAccidentalFDInt}#{FD.decl}
TranspositionDegree#TranspositionAccidental#TranspositionPC = {FD.decl}#{HS.db.makeAccidentalFDInt}#{FD.decl}
% TranspositionDegree#TranspositionAccidental#TranspositionPC#TranspositionOct#Transposition = {FD.decl}#{HS.db.makeAccidentalFDInt}#{FD.decl}#{FD.decl}#{FD.decl}
TransposedDegree#TransposedAccidental#TransposedPC = {FD.decl}#{HS.db.makeAccidentalFDInt}#{FD.decl}
{Browse
 unit(collectionPCs:CollectionPCs
      untransposed:UntransposedDegree#UntransposedAccidental#UntransposedPC
      transposition:TranspositionDegree#TranspositionAccidental#TranspositionPC
      transposed:TransposedDegree#TransposedAccidental#TransposedPC)}
{HS.score.degreeToPC CollectionPCs UntransposedDegree#UntransposedAccidental UntransposedPC}
{HS.score.degreeToPC CollectionPCs TransposedDegree#TransposedAccidental TransposedPC}
{HS.score.degreeToPC CollectionPCs TranspositionDegree#TranspositionAccidental TranspositionPC}
% {HS.score.intervalPCToInterval TranspositionPC#TranspositionOct Transposition}
{HS.score.transposeDegree CollectionPCs UntransposedDegree#UntransposedPC TranspositionDegree#TranspositionPC TransposedDegree#TransposedPC}


%% I raised by fifth => V 
UntransposedDegree#UntransposedAccidental = 1#{HS.score.absoluteToOffsetAccidental 0}

TranspositionDegree#TranspositionPC = 5#7

%% result: TransposedDegree#TransposedAccidental = 5#{HS.score.absoluteToOffsetAccidental 0}


%% by which interval is I raised to get V => fifth 
UntransposedDegree#UntransposedAccidental = 1#{HS.score.absoluteToOffsetAccidental 0}

TransposedDegree#TransposedAccidental = 5#{HS.score.absoluteToOffsetAccidental 0}

%% result: TranspositionDegree#Transposition = 5#7


%%

%% interval between I and V => fifth
UntransposedDegree#UntransposedAccidental = 1#{HS.score.absoluteToOffsetAccidental 0}

TransposedDegree#TransposedAccidental = 5#{HS.score.absoluteToOffsetAccidental 0}

% TranspositionDegree#TranspositionPC = 5#7..

%%

%% which degree raised by fifth is V => I

TranspositionDegree#TranspositionPC = 5#7

TransposedDegree#TransposedAccidental = 5#{HS.score.absoluteToOffsetAccidental 0}

% UntransposedDegree#UntransposedAccidental = 1#{HS.score.absoluteToOffsetAccidental 0}


%% 

%% II# raised by fifth => VI#
UntransposedDegree#UntransposedAccidental = 2#{HS.score.absoluteToOffsetAccidental 1}

TranspositionDegree#TranspositionPC = 5#7

% TransposedDegree#TransposedAccidental = 6#{HS.score.absoluteToOffsetAccidental 1}


%% II# raised by diminished sixth => VIIb
UntransposedDegree#UntransposedAccidental = 2#{HS.score.absoluteToOffsetAccidental 1}

TranspositionDegree#TranspositionPC = 6#7

% TransposedDegree#TransposedAccidental = 6#{HS.score.absoluteToOffsetAccidental 1}




%% VII + fifth = IV#
UntransposedDegree#UntransposedAccidental = 7#{HS.score.absoluteToOffsetAccidental 0}

TranspositionDegree#TranspositionPC = 5#7

% TransposedDegree#TransposedAccidental = 4#{HS.score.absoluteToOffsetAccidental 1}




%% III raised by fifth => VII
TransposedDegree#TransposedAccidental = 7#{HS.score.absoluteToOffsetAccidental 0}

UntransposedDegree#UntransposedAccidental = 3#{HS.score.absoluteToOffsetAccidental 0}

TranspositionDegree#TranspositionPC = 5#7





%% % % % % % % % % % % % % % % % % % % % % % %
%%
%% HS.score.degreeToPC used to express monzos
%%

%% check
{HS.db.getPitchesPerOctave} == 12
{HS.db.getAccidentalOffset} == 2

%%
%% translating single monzo exponent into pitch class 
%%

declare
%% des:1 as:8 es:3 b:10 f:5 c:0 g:7 d:2 a:9 e:4 h:11 fis:6
SpiralOfFifths = [1 8 3 10 5 0 7 2 9 4 11 6]		% 
PC = {HS.db.makePitchClassFDInt}
Accidental = {HS.db.makeAccidentalFDInt}
FifthExponent = {FD.decl}	% implicit fifth exponent offset of 5

{Browse [SpiralOfFifths FifthExponent Accidental PC]}

{HS.score.degreeToPC SpiralOfFifths FifthExponent#Accidental PC}

Accidental = {HS.db.getAccidentalOffset} % i.e. accidental is neutral
FifthExponent = 3 + 5
%% -> PC = 2

/*
%%
%% ?? how to translate 'monzo array' into pitch class: I have to read an n-dimensional array. First I have to implement my own Select version for an n-dimansional array with Select:
%% I could 'fold' the n-dimensional array into a long 1-dimensional list and express indices into dimensions by factors 
%%

declare
/** %% Array is n-dimensional and uniformly nested list of lists of FD ints, Is is list of FD ints (length of Is equals dimensions of Array), Xs (FD int) is value of Array at position Is.
%% */
proc {ArrayConstraint DimensionsWidths Array Is X}
   %% DimensionWidths is list of 'widths' of each dimension in order of their nesting (starting with outest level). E.g., in case Array is [[11 12 13] [21 22 23]] the DimensionWidths is [2 3]
   %% -> only tmp DimensionsWidths as arg, I can computer that..
   EncodedArray = {List.flatten Array}
   EncodedIs = {FD.decl}
in
   %% how must Is be encoded as an integer to serve as index in the flattened Array -- this soundslike a standard problem, there is probably a solution online...
   EncodedIs = {FD.sumC DimensionsWidths Is '=:'} % wrong
   {Select.fd EncodedArray EncodedIs X}
end

%% DimensionWidths = [2 3]
{ArrayConstraint [2 3] [[11 12 13][21 22 23]] [2 3]}
%% -> 23

%% DimensionWidths = [2 2 3]
{ArrayConstraint [[[111 112 113]
		   [121 122 123]]
		  [[211 212 213]
		   [221 222 223]]]
 [2 1 2]}		  
%% -> 212


Is = [2 3]
EncodedIs = 6 = 1 * 3 + 1 * 3

Is = [1 2]
EncodedIs = 2 = 0 * 3 + 1 * 2

%Is = [2 1 2]
%rew~EncodedIs = 8 = 1 * 2 + 0 * 1 + 1 * 2 % !! wrong


%% "A:array [0..3,0..3] of integer" is
%% 2D case:
%% ElementAddress: position of element in flatted list
%% BaseAddress is position of first element: BaseAddress=1
%% collumn is outer list in my representation, row in inner list
%% RowSize is length of row, indices are 2D address
%% !! all indices are 0 based
ElementAddress = BaseAddress + (Colindex * RowSize + RowIndex)

%% Is = [2 3] <-> [1 2] % (reduce to 0 based index)
ElementAddress = 1 + (1 * 3 + 2) = 6

%% 3D case
%% 
Address = Base + ((depthindex*col_size+colindex) * row_size + rowindex)


 
%% 4D case
%%
%%  A[i] [j] [k] [m];
%% Depth_size is equal to j, col_size is equal to k, and row_size is equal to m.  LeftIndex represents the value of the leftmost index.
Address = 
Base + (((LeftIndex * depth_size + depthindex)*col_size+colindex) * row_size + 
rowindex) 


%%


%% BTW: I could extend a scale and chord database by the monzo exponents. For each base (e.g. fifth, third etc), I would add an database entry feature with a list with the respective value for each pitch class in the database entry. E.g.
%% In this representation, the actual pitchClasses are approximations of the explicitly represented pitch ratios -- if the monzos are accessible in the solution score, various tunings can be used in the output (e.g. with the help of Scale)
chord(pitchClasses:[0 4 7 10]	% pitchesPerOctave=12
      roots:[0]
      %% internally, I would need to introduce some offset to avoid neg ints
      monzo3:[0 0 1 0]		
      monzo5:[0 1 0 0]
      monzo7:[0 0 0 1]
      comment:major)

*/


%%
%% HS.score.degreeToPC used to express note names, i.e. degrees into C-major
%%



%% % % % % % % % % % % % % %
%%
%% HS.score.absoluteToOffsetAccidental / HS.score.offsetToAbsoluteAccidental
%%

%% check
{HS.db.getAccidentalOffset} == 2

{HS.score.absoluteToOffsetAccidental ~1}
%% -> 1

{HS.score.absoluteToOffsetAccidental 2}
%% -> 4

{HS.score.offsetToAbsoluteAccidental 1}
%% -> ~1



{HS.db.setDB unit(accidentalOffset:5)}

{HS.db.getAccidentalOffset}

{HS.score.absoluteToOffsetAccidental ~1}
%% -> 4

{HS.score.absoluteToOffsetAccidental 2}
%% -> 7

{HS.score.offsetToAbsoluteAccidental 1}
%% -> ~4


%% % % % % % % % % % % % % % % % % % % % % % %
%%
%% HS.score.pcSetToSequence
%%


declare
%% E major
Card = 7
PCFS = {FS.var.decl}
{FS.card PCFS Card}
Root = {FD.int 0#11}

%% blocks until PCFS and Root are determined
{Browse {HS.score.pcSetToSequence PCFS Root}}
{Browse hi}

%% args for HS.score.pcSetToSequence must be determined! 
PCFS = {FS.value.make [1 3 4 6 8 9 11]}
Root = 4


%% test: root is greatest number
declare
PCFS = {FS.value.make [0 3 6 9]}
Root = 11

{Browse {HS.score.pcSetToSequence PCFS Root}}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% chord class
%%
 
 
declare
[HS Pattern]
= {Module.link ['x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
		'x-ozlib://anders/strasheela/pattern/Pattern.ozf']}


%% default chord DB entry at index 1: major
{HS.db.getEditChordDB}.1

%% determined chord from default DB: C# major
declare
MyChord = {Score.makeScore chord(index:1
				 transposition:1
				 dbFeatures:[dissonanceDegree]
				 %root:1	
				 duration:1
				 startTime:0
				 timeUnit:beats(4))
	   add(chord:HS.score.chord)}

{Browse {MyChord toFullRecord($)}}

{HS.db.getInternalChordDB}.comment.1
 

%% undetermined chord
declare
MyChord = {Score.makeScore chord(duration:1
				 startTime:0
				 timeUnit:beats(4))
	   add(chord:HS.score.chord)}

{Browse {MyChord toFullRecord($)}}

%% determines index..
{FS.include 4 {MyChord getUntransposedPitchClasses($)}}

%% determines transposition..
{MyChord getRoot($)} = 3


%%%%%%%%%%%%%%%%%%%%%%
%%
%% chord class and changing DB
%%

{HS.db.setDB
 unit(chordDB: chords(chord(pitchClasses:[0 4 8] 
			    roots:[0]
			    comment:'augmented')))}

declare
MyChord = {Score.makeScore chord(index:1
				 transposition:1
				 duration:1
				 startTime:0
				 timeUnit:beats(4))
	   add(chord:HS.score.chord)}

{Browse {MyChord toFullRecord($)}}


{HS.db.setDB
 unit(chordDB: chords(chord(pitchClasses:[0 3 6] 
			    roots:[0]
			    comment:'diminished')))}

{HS.db.setDB
 unit(chordDB: chords(chord(pitchClasses:[0 3 6 9] 
			    roots:[0]
			    comment:'diminished')))}




%%%%%%%%%%%%%%%%%%%%%%
%%
%% InversionMixinForChord
%%

%% default database


%% E major chord, 1st inversion, soprano is fifth
declare
InversionChord = {HS.score.makeInversionChordClass HS.score.chord}
MyChord = {Score.makeScore chord(index:{HS.db.getChordIndex major}
				 transposition:4
				 bassChordDegree:2 % the third of major
				 bassChordAccidental:{HS.score.absoluteToOffsetAccidental 0}
				 sopranoChordDegree:3 % the fifth of major
				 sopranoChordAccidental:{HS.score.absoluteToOffsetAccidental 0}
				 duration:1
				 startTime:0
				 timeUnit:beats(4))
	   unit(chord:InversionChord)}


%% Check: bassPitchClass is 8 (G#) and sopranoPitchClass is 11 (B)
{Inspect MyChord}

{MyChord getPitchClasses($)} 
% -> {4 8 11}

{MyChord getBassPitchClass($)}
% -> 8

{MyChord getSopranoPitchClass($)}
% -> 11




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Note2 class
%%

%% determined note
declare
MyNote = {Score.makeScore note(duration:1
			       startTime:0
			       timeUnit:beats(4)
			       pitch:61
			      )
	   add(note:HS.score.note2)}

{MyNote toFullRecord($)}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Note class
%%

%% test 1: no relation to any chord or scale (default)
%%
%% determined note
declare
MyNote = {Score.makeScore note(duration:1
			       startTime:0
			       timeUnit:beats(4)
			       pitch:61
			      )
	   add(note:HS.score.note)}

{MyNote toFullRecord($)}

%% test 2
%%
%% relation between note and chord/scale determined in CSP: just a sim relation..
declare
MyNote = {Score.makeScore2
	  note(duration:4
	       %% diatonic and chord pitch
	       inChordB:1	
	       inScaleB:1
	       getChords:proc {$ Self Chords}
			    Chords = {Self getSimultaneousItems($ test:HS.score.isChord)}
			 end
	       isRelatedChord:proc {$ Self Chord B}
				 B=1
			      end
	       getScales:proc {$ Self Scales} 
			    Scales = {Self getSimultaneousItems($ test:HS.score.isScale)}
			 end
	       isRelatedScale:proc {$ Self Scale B} 
				 B=1
			      end
	      )
	  unit(note:HS.score.note)}
MyChord = {Score.makeScore2
	   chord(duration:4
		 %index:1
		 %transposition:2
		)
	   unit(chord:HS.score.chord)}
MyScale = {Score.makeScore2
	   scale(duration:4
		 %index:1
		 %transposition:2
		)
	   unit(scale:HS.score.scale)}
MyScore = {Score.makeScore2
	   sim(items:[MyNote
		      MyChord
		      MyScale
		     ]
	       startTime:0
	       % duration:4
	       timeUnit:beats(4))
	   unit}
{Score.initScore MyScore}
{Browse ok}

{MyScore toFullRecord($)}

% {MyNote getPitch($)} = 62

%% all chord PCs are diatonic..
{FS.subset {MyChord getPitchClasses($)}
 {MyScale getPitchClasses($)}}

%% scale is D major
{MyScale getTransposition($)} = 2 % causes little/no propagation..
{MyScale getIndex($)} = 1

%% note is f# 5
{MyNote getPitch($)} = 66	% causes little/no propagation in chord

%% chord is major (in D major with f#)
{MyChord getIndex($)} = 1	%

%% possible major chord with f# is only: D-major (transposition 2) -- this is not propagated.. (transposition/root domain: [1 2 4 6 7 9 11], i.e. the diatonic pitches in D major -- caused by propagator subset with scale)
%%
%% -> can/should I add any further redundant propagators?

%% check inconsisted transposition 1 -- causes failure..
{MyChord getTransposition($)} = 1

%% check consisted transposition 2 
{MyChord getTransposition($)} = 2




%%
%% problem/TODO
%%
%% * how to define relation between chord and scale in manner as generic and concise as the note args (e.g. chord shall be diatonic..) -- add similar (optional) args to chord init? -- variante von Mixin InScale verwenden? Two 0/1-int attributes/params for chord: RootInScaleB, AllPCsInScaleB
%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% CMajorDegreeToPC
%%


declare
Degree = {FD.int 1#7}
Accidental = {FD.int 1#3}
PC = {FD.int 0#11}

{Browse unit(degree:Degree accidental:Accidental pc:PC)}

{HS.score.cMajorDegreeToPC Degree#Accidental PC}


PC = 0

%% does this not determine (or even reduce) Degree,
%% because note could be c neutral or b#
Accidental = {FD.int 2#3}


%% determines 
Accidental = 2


Accidental = 3


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% FullNote class
%%

%% test 1: no relation to any chord or scale (default)
%%
%% determined note
declare
MyNote = {Score.makeScore note(duration:1
			       startTime:0
			       timeUnit:beats(4)
			       pitch:61
			       %% no ## or bb
			       cMajorAccidental:{FD.int 1#3})
	   add(note:HS.score.fullNote)}

{Inspect MyNote}



%% pitch is 61 (c# or db),
%% i.e. CMajorDegree=1 (c) and CMajorAccidental=1 (3 with offset)
%% OR CMajorDegree=2 (d) and CMajorAccidental=~1 (1 with offset)
{MyNote getCMajorDegree($)} = 1

{MyNote getCMajorAccidental($)}
%% -> 3 % i.e. #

%%%%% 

{MyNote getCMajorAccidental($)} = 1 % i.e. b

{MyNote getCMajorDegree($)}
%% -> 2


%% test 1b
%% 
%%
declare
MyNote = {Score.makeScore note(duration:1
			       startTime:0
			       timeUnit:beats(4)
			       pitch:60
			       %% neutral or #
			       cMajorAccidental:{FD.int 2#3})
	   add(note:HS.score.fullNote)}

{Inspect MyNote}

%% !!?? why not determined?
{MyNote getCMajorDegree($)}


%% test 2
%% 
%%
declare
%% D major scale
DMajorScale = {Score.makeScore2
	       scale(startTime:0
		     duration:0
		     index:1
		     transposition:2)
	       unit(scale:HS.score.scale)}
fun {GetDMajorScale Self} [DMajorScale] end
MyNote = {Score.makeScore note(duration:1
			       startTime:0
			       timeUnit:beats(4)
			       pitch:66
			       getScales:GetDMajorScale
			       isRelatedScale:proc {$ Self Scale B} B=1 end)
	  add(note:HS.score.fullNote)}


{Inspect MyNote}

%% pitch is 66, i.e. f#/gb.  
%% if the accidental is neutral, the note is the II degree in the D major scale.
{MyNote getScaleAccidental($)} = 2

{MyNote getScaleDegree($)}
%% -> 3


      

%% test 3
%%
%% relation between note and chord/scale determined in CSP: just a sim relation..
declare
%% D major
MyScale = {Score.makeScore2
	   scale(duration:4
		 index:1
		 transposition:2)
	   unit(scale:HS.score.scale)}
%% !! blocks
MyNote = {Score.makeScore2
	  note(duration:4
	       inScaleB:1
	       getScales:proc {$ Self Scales}
%			    thread 
			       Scales = {Self getSimultaneousItems($ test:HS.score.isScale)}
%			    end
			 end
	       isRelatedScale:proc {$ Self Scale B} B=1 end)
	  unit(note:HS.score.fullNote)}
MyScore = {Score.makeScore2
	   sim(items:[MyNote
		      MyScale]
	       startTime:0
	       % duration:4
	       timeUnit:beats(4))
	   unit}
{Score.initScore MyScore}
{Browse ok}


{Inspect MyScore}


%% note is f# 5
{MyNote getPitch($)} = 66	% causes little/no propagation in chord


{MyNote getScaleAccidental($)} = 2

{MyNote getScaleDegree($)}
%% -> 3







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% old tests
%%


declare
Chords = {Score.makeScore seq(items:[chord(index:1 transposition:1 duration:1)
				     chord(index:1 transposition:7)]
			      startTime:0
			      timeUnit:beats(4))
	  add(chord:HS.score.chord)}

{Chords toFullRecord($)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% scale class
%%

declare
MyScale = {Score.makeScore scale(% index:1
				 % transposition:1
				 duration:1
				 startTime:0
				 timeUnit:beats(4))
	   add(scale:HS.score.scale)}

{MyScale toFullRecord($)}

{MyScale getIndex($)} = 2

{MyScale getRoot($)} = 3


declare
Scales = {Score.makeScore seq(items:[scale(index:1 transposition:1 duration:1)
				     scale(index:1 transposition:7)]
			      startTime:0
			      timeUnit:beats(4))
	  add(scale:HS.score.scale)}

{Scales toFullRecord($)}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% HarmoniseScore
%%
%% .. the lengthy distribution strategy was just inserted by copy and paste, something more simple will probably do as well ;-)
%%

declare
/** %% Suitable distribution strategy: first determine chords etc
%% */
PreferredOrder = {SDistro.makeSetPreferredOrder
		  %% Preference order of distribution strategy
		  [%% !!?? first always timing?
		   fun {$ X} {X isTimeParameter($)} end
		   fun {$ X}
		      {HS.score.isPitchClassCollection {X getItem($)}}
		      %{HS.score.isChord {X getItem($)}} orelse
		      %{HS.score.isScale {X getItem($)}}
		   end
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
MyDistribution = unit(value:random % mid % min % 
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
%%			   
%% every note is a chord note of its simultaneous chordend)
fun {MakeNote}
 %  {Score.makeScore2
    note(duration:4
	 inChordB:1	
	 getChords:proc {$ Self Chords}
		      Chords = {Self getSimultaneousItems($ test:HS.score.isChord)}
		   end
	 handle:_)
%    unit(note:HS.score.note)}
end


%% !! bugged 
%%
%% test script 1: the whole score is harmonised by a single chord
%%
{SDistro.exploreOne
 proc {$ HarmonisedScore}
    ScoreSpec = seq(info:testScore
		    items:{LUtils.collectN 3 MakeNote} 
		    startTime:0
		    timeUnit:beats(16))
    ActualScore = {Score.makeScore2 ScoreSpec unit}
    ItemsStartingWithChord = [ActualScore]
    ChordSeq
 in
    HarmonisedScore = {HS.score.harmoniseScore ActualScore ItemsStartingWithChord
		       unit ChordSeq} 
    %% put constraints on ChordSeq here...
 end
 MyDistribution}

%% !! bugged 
%%
%% test script 2: each note starts a new chord 
%%
{SDistro.exploreOne
 proc {$ HarmonisedScore}
    ScoreSpec = seq(info:testScore
		    items:{LUtils.collectN 3 MakeNote}
		    startTime:0
		    timeUnit:beats(16))
    ActualScore = {Score.makeScore2 ScoreSpec unit}
    ItemsStartingWithChord = {Map ScoreSpec.items fun {$ X} X.handle end}
    ChordSeq
 in
    HarmonisedScore = {HS.score.harmoniseScore ActualScore ItemsStartingWithChord 
		       unit ChordSeq} 
    %% put constraints on ChordSeq here...
 end
 MyDistribution}

%% also see the L-system example in the Strasheela/examples for a further applicaiton example


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% toInitRecord 
%%

%%%%

%% determined chord from default DB: C# major
declare
MyChord = {Score.makeScore chord(index:1
				 transposition:1
				 dbFeatures:[dissonanceDegree]
				 %root:1	
				 duration:1
				 startTime:0
				 timeUnit:beats(4))
	   add(chord:HS.score.chord)}

%% !! additional args: pitchClasses, root, untransposedPitchClasses, untransposedRoots 
{MyChord toInitRecord($)}

%%%%

declare
MyNote = {Score.makeScore note(duration:1
			       startTime:0
			       timeUnit:beats(4)
			       pitch:61
			      )
	   add(note:HS.score.note)}

%% !! additional args inChordB, inScaleB, octave, pitchClass, pitchUnit, timeUnit
{MyNote toInitRecord($)}

%%%%


%% relation between note and chord/scale determined in CSP: just a sim relation..
declare
MyNote = {Score.makeScore2
	  note(duration:4
	       %% diatonic and chord pitch
	       inChordB:1	
	       inScaleB:1
	       getChords:proc {$ Self Chords}
			    Chords = {Self getSimultaneousItems($ test:HS.score.isChord)}
			 end
	       isRelatedChord:proc {$ Self Chord B}
				 B=1
			      end
	       getScales:proc {$ Self Scales} 
			    Scales = {Self getSimultaneousItems($ test:HS.score.isScale)}
			 end
	       isRelatedScale:proc {$ Self Scale B} 
				 B=1
			      end
	      )
	  unit(note:HS.score.note)}
MyChord = {Score.makeScore2
	   chord(duration:4
		 %index:1
		 %transposition:2
		)
	   unit(chord:HS.score.chord)}
MyScale = {Score.makeScore2
	   scale(duration:4
		 %index:1
		 %transposition:2
		)
	   unit(scale:HS.score.scale)}
MyScore = {Score.makeScore
	   sim(items:[MyNote
		      MyChord
		      MyScale
		     ]
	       startTime:0
	       % duration:4
	       timeUnit:beats(4))
	   unit}
{Score.initScore MyScore}
{Browse ok}

{MyScore toInitRecord($)}

%% !! missing args: procedures (getChords, isRelatedChord, getScales, isRelatedScale)

{MyNote toInitRecord($)}

%% !! added args index, transposition, etc.
{MyChord toInitRecord($)}

%% !! added args index, transposition, etc.
{MyScale toInitRecord($)}


%%%

declare
MyChord = {Score.makeScore chord
	   unit(chord:HS.score.chord)}

{Browse {MyChord toInitRecord($)}}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Interval
%%

declare
MyInterval = {New HS.score.interval init(distance:7 direction:2)}
{Score.initScore MyInterval}

%% check, e.g., score hierarchy recursively
{Inspect MyInterval}

%% test check..
{Browse {MyInterval getDB($)}}


declare
MyInterval = {New HS.score.interval init(distance:{FD.int 6#7} direction:2
					 %% feat in default interval DB..
					 dbFeatures:[dissonanceDegree])}
{Score.initScore MyInterval}

{MyInterval getDBFeatures($)}

{MyInterval getDBFeature($ dissonanceDegree)}



declare
MyInterval = {New HS.score.interval init}
{Score.initScore MyInterval}

%% check, e.g., score hierarchy recursively
{Inspect MyInterval}



%%
%% NoteInterval
%%

declare
Note1 = {Score.makeScore note unit}
Note2 = {Score.makeScore note unit}
MyInterval = {HS.score.noteInterval Note1 Note2
	      unit(dbFeatures:[dissonanceDegree])}

%% check score hierarchy recursively..
{Inspect MyInterval}
{Inspect {MyInterval getDBFeature($ dissonanceDegree)}}
{Inspect Note1}
{Inspect Note2}

{Note1 getPitch($)} = 47

{MyInterval getOctave($)} = 2

{MyInterval getDirection($)} = 2

{MyInterval getDBFeature($ dissonanceDegree)} = 3

{MyInterval getPitchClass($)} = 4

%% -> Note2 pitch is 75


%%
%% TransposeNote (without fully initialising the interval!) 
%%
declare
Note1 = {Score.makeScore note unit}
Note2 = {Score.makeScore note unit}
MyInterval = {New HS.score.interval init(dbFeatures:[dissonanceDegree])}
{Score.initScore MyInterval}

{HS.score.transposeNote Note1 MyInterval Note2}

%% check score hierarchy recursively..
{Inspect MyInterval}  
{Inspect {MyInterval getDBFeature($ dissonanceDegree)}}
{Inspect Note1}
{Inspect Note2}

{Note1 getPitch($)} = 47

{MyInterval getOctave($)} = 2

{MyInterval getDirection($)} = 2

{MyInterval getDBFeature($ dissonanceDegree)} = 3

{MyInterval getPitchClass($)} = 4

%% -> Note2 pitch is 75


%%
%% use memoization
%% 

declare
[Memo] = {ModuleLink ['x-ozlib://anders/strasheela/Memoize/Memoize.ozf']}
%%
%% define memo function
NoteInterval_M = {Memo.memoize fun {$ [Note1 Note2]}
				  {HS.score.noteInterval Note1 Note2 unit}
			       end}
Note1 = {Score.makeScore note unit}
Note2 = {Score.makeScore note unit}
Interval1 = {NoteInterval_M [Note1 Note2]}
Interval2 = {NoteInterval_M [Note1 Note2]}

%% check: OK
{Browse Interval1 == Interval2}

%% check score hierarchy recursively..
{Inspect Interval1}
{Inspect Interval2}

%% check whether changing Interval1 does 'change' Interval2 (i.e. whether both are identical). Of course, I must change something which can not be propagated..
{Interval1 addInfo(hello)}

%% .. now re-inspect: OK

