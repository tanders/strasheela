
%% To link the functor with auxiliary definition of this file: within OPI (i.e. emacs) start Oz from within this buffer (e.g. by C-. r). This sets the current working directory to the directory of the buffer.  
declare
[Aux] = {ModuleLink [{OS.getCWD}#'/ExampleAuxDefs.ozf']}

%% ?? melodic dissonances: how to deal with note repetitions (e.g. passing note repeated) -- this is already simple form of ornamental dissonance treatment..

%% ?? many melodies modulate into dominant: shall I exclude that?



declare
%% setting the chord database (the scale database defaults to major and minor scale as required).
{HS.db.setDB
 unit(chordDB: chords(chord(pitchClasses:[0 4 7] 
			    roots:[0]
			    comment:'major')
		      chord(pitchClasses:[0 4 7 10] % seventh added  10
			    roots:[0]
			    comment:'"major with minor 7"')
		      chord(pitchClasses:[0 3 7]
			    roots:[0] % according to Schoenberg root is 0, other authors propose [7] (but then I need to change other rules as well)
			    comment:minor)))}
%%
%% Rule definitions
%%
local
   /** %% Index of a major chord with minor seventh is 2 in the chord DB above.
   %% */
   MajorWithMajorSeventhIndex = 2
in
   /** %% Simplified case: in this example, the only possible seventh chord is a major chord with minor seventh, which is recognised by its index.
   %% */
   proc {IsSeventhChord MyChord B}
      B = ({MyChord getIndex($)} =: MajorWithMajorSeventhIndex)
   end
   /** %% Redundant rule to enforce propagation: in C major, a major chord with minor seventh can only be G7 (i.e. transposition=7).
   %% */
   proc {RedundantV7Constraint MyChord}
      {FD.impl ({MyChord getIndex($)} =: MajorWithMajorSeventhIndex)
       ({MyChord getTransposition($)} =: 7)
       1}
   end
end
/** %% B=1 <-> in case Chord1 is a seventh chord, then adequately resolve (fourth skip upwards) into Chord2. (Rule by Schoenberg's Theory of Harmony, in more simple rule set for beginner)
%% */
proc {ResolvedSeventhR Chord1 Chord2 B}
   RootsInterval = {HS.db.makePitchClassFDInt}
in
   {HS.score.transposePC {Chord1 getRoot($)} RootsInterval {Chord2 getRoot($)}}
   B = {FD.int 0#1}
   B = {FD.impl {IsSeventhChord Chord1}
	 (RootsInterval =: 5)}
end
/** %% The passing note (defined by HS.rules.isPassingNoteR) is situated between chord pitches.
%% */
proc {IsPassingNoteR Note B}
   B = {FD.conj 
	{HS.rules.isPassingNoteR Note unit}
	{HS.rules.isBetweenChordNotesR Note unit}}
end
/** %% The auxiliary (defined by HS.rules.isAuxiliaryR) is situated between chord pitches.
%% */
proc {IsAuxiliaryR Note B}
   B = {FD.conj 
	{HS.rules.isAuxiliaryR Note unit}
	{HS.rules.isBetweenChordNotesR Note unit}}
end
%%
%%
/** %% Main definition: Returns the a script of a automatic harmonisation CSP for a purely diatonic melody (in C major, start and end with tonique -- in most cases OK for full melody..).
%% CSP defines a purely diatonic chord progression with a single chord per ChordDur. Chords may be repeated.
%% A few simple additional rules (inspired by the simplified rule set at the beginning of Schoenberg's Theory of Harmony) on chord progression prefer 'reasonable' solutions: (i) start and end with the same chord (i.e. tonique). (ii) only chord neighbours with 'harmonic band' (which also allows for repetitions). (iii) seventh chords are resolved (the root skips a fourth upwards).
%% MelodyNoteDurPitchPairs introduces a very simple textual music representation. MelodyNoteDurPitchPairs specifies the melody as a list of the form [Dur1#Pitch1 .. DurN#PitchN]. ChordDur (an integer) defines the Duration of each chord (which must remain constant throughout the piece but chord repetitions are permitted).
%% Only very few and simple cases for non-harmonic pitches in the melody are permitted: auxiliary notes and passing notes with are preceeded and followed by chord pitches.
%% NB: This simple example rule set only produces results for suitable melodies. For example, the rule enforcing a 'harmonic band' band may be too strict for certain cases (i.e. no solution may be possible) but this rule is an important device to improve the solution quality in many cases.
%% */
fun {AutomaticHarmonisation MelodyNoteDurPitchPairs ChordDur}
   proc {$ MyScore}
      FullDur = {LUtils.accum {Map MelodyNoteDurPitchPairs
			       fun {$ Dur#Ignore} Dur end}
		 Number.'+'}
      ChordNr = FullDur div ChordDur
      %% default scale DB: C major scale
      MyScale = {Score.makeScore2 scale(index:1 transposition:0
					startTime:0
					duration:0 %% !!??
				       )
		 Aux.myCreators}
      proc {GetMyScale Self Scales} Scales = [MyScale] end
      MyChordSeq = {Score.makeScore2
		  seq(items:{LUtils.collectN ChordNr
			     fun {$}
				diatonicChord(duration:ChordDur
					      inScaleB:1
					      getScales:GetMyScale)
			     end})
		  Aux.myCreators}
      MyVoice = {Score.makeScore2 
		 seq(items:{Map MelodyNoteDurPitchPairs
			    fun {$ Dur#Pitch}
			       note(duration:Dur
				    pitch:Pitch
				    inChordB:{FD.int 0#1}
				    inScaleB:1
				    getScales:GetMyScale) 
			    end})
		 Aux.myCreators}
      MyChords 
   in
      MyScore = {Score.makeScore
		 sim(items:[MyVoice
			    MyChordSeq]
		     startTime:0
		     timeUnit:beats(1))
		 Aux.myCreators}
      MyChords = {MyChordSeq getItems($)}
      %%
      %% Rules applications
      %%
      %% non-harmonic pitches may be  passing notes and auxiliaries
      {MyVoice
       forAllItems(proc {$ MyNote}
		      %% Test different non-harmonic pitch rules:
		      %% (Aux.resolveStepwiseR is very simple alternative)
		      {MyNote nonChordPCConditions([IsPassingNoteR
						    IsAuxiliaryR])} 
		   end)}
      %%
      %% constrain chord progression
      {HS.rules.neighboursWithCommonPCs MyChords}
      %% chord progression starts and ends with tonique
      {MyChords.1 getRoot($)} = {{List.last MyChords} getRoot($)}
      {Pattern.for2Neighbours MyChords
       proc {$ Chord1 Chord2}
	  %% in case Chord1 are Chord2 distinct (i.e. no chord
	  %% repretition occurs), then apply additional constraint to
	  %% resolve seventh chord
	  {FD.impl {HS.rules.distinctR Chord1 Chord2}
	   {ResolvedSeventhR Chord1 Chord2}
	   1}
       end}
      %% redundant constraint for C major (for all solutions of first example below number of fails halved)
      {ForAll MyChords RedundantV7Constraint}
   end
end


%% simple melody with two solution chord progressions (with determined scale and no seventh chord)
%% ?? 4 solutions, in case V7 is permitted (V either with or without seventh)
{SDistro.exploreOne
 {AutomaticHarmonisation [3#60 1#62   2#64 1#62 1#60   3#59 1#62   4#60] 4}
 {Adjoin Aux.myDistribution
 unit(value:mid)}}


%% 'Horch was kommt von draussen rein' (first four measures): there
%% are solutions in total
{SDistro.exploreOne
 {AutomaticHarmonisation
  %% line per measure
  [1#60 1#62 1#64 1#65
   1#67 1#69 2#67
   1#65 1#62 2#71
   1#67 1#64 2#72]
  4}
 Aux.myDistribution}


%% 'Horch was kommt von draussen rein' (full melody)
%% (more than 80 solutions -- I stopped after a while..)
%% melody in major
{SDistro.exploreOne
 {AutomaticHarmonisation
  %% line per measure
  [1#60 1#62 1#64 1#65
   1#67 1#69 2#67
   1#65 1#62 2#71
   1#67 1#64 2#72
   %% repetition of four measures skipped..
   1#60 1#62 1#64 1#65
   1#67 1#69 2#67
   1#65 1#62 1#71 1#74
   4#72
   %%
   2#69 2#69			% geht vor-
   2#72 1#71 1#69		% bei und 
   2#67 2#64			% schaut nicht
   4#67				% rein
   2#65 2#62			% hola
   4#71				% hi
   2#67 2#64			% hola
   4#72				% ho
   %% repetition skipped
   2#69 2#69			% wirds wohl
   2#72 1#71 1#69		% nicht ge-
   2#67 2#64			% wesen
   4#67				% sein
   2#65 2#62			% hola 
   2#71 2#74			% hia
   4#72				% ho   
  ]
  4}
 Aux.myDistribution}


%% 'Schlaf mein Buebchen'
%% melody in minor
%%
%% Problem: in minor, V7 is not G7 but non-diatonic H7
%% I certainly could extend CSP accordingly, but does it pay of? Besides, introducing two raised pitches requires special treatment of these pitches
%%
%% jeweils erste und zweite Haelfte des Liedes gut loesbar (Zeilen 1-8 oder 8-14), aber fuer gesamtes Lied keine [schnelle] Loesung gefunden
{SDistro.exploreOne
 {AutomaticHarmonisation
  %% line per measure
  {Map %% to transpose e minor to a minor
   [
    2#64 2#67			% schlaf mein
    2#66 2#59			% Bub ich
    2#64 2#67			% will dir
    2#66 2#59			% singen
    2#67 2#67			% bajusch
    2#69 1#74 1#72		% kiba
    4#71			% ju
    2#71 2#71			% sachte
    %% !! problematic line: 2 chords needed (search decides for dissonance on strong beat instead)
    2#69 1#71 1#69		% fliesst auf
    2#67 2#67			% Silber 
    2#66 2#59			% schwingen
    1#64 1#66 1#67 1#69		% dir das 
    2#71 1#71 1#67		% Mondlicht
    4#64
   ]			% zu
   fun {$ Dur#Pitch} Dur#Pitch+5 end}
  %% !!?? no solution for chordDur=2? without propagation
  4}				
 Aux.myDistribution}


%% doric melody



%% Restrictions/limitations caused be the simplification:
%%
%% * The melody must not use any accidential: the melody is in C-major or a-minor and does not include any modulation
%%
%% * The melody must start and end in the tonique
%%
%% * 'beat' of harmonic rhythm must be specified and all chords are of this lengths (chord repetitions are permitted)
%%
%% * Only two simple non-harmonic note cases are permitted: passing note and auxiliary. Non-harmonic notes can not follow each other.
%%
%% * Similarily, repetition of non-harmonic notes (e.g. repetition of passing note) not possible
%%






%% two dissonances following each other causes trouble!

%% F and G7 have common pitch.. but that is indeed a reasonable progression!

%% ?? best solution: maximise number of distinct chords?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% old debugging
%%


{SDistro.exploreOne
 {AutomaticHarmonisation
  [%% this line causes fail: verminderter: sollte mit D7 OK sein!
  % 1#65 1#62 2#71 %% PCs: [2 5 11]
   % 1#65 1#71 %% PCs: [5 11]
   1#60 1#62 1#64 1#65
  ]
  2}
 Aux.myDistribution}

%% line 1#65 1#62 2#71 %% PCs: [2 5 11]
%% 
%% chordPCsInScale and pitchClasses by plain propagation determined to FS {2 5 11}#3 
%% Why?
%%
%% this set should be lower bound, but full determination is too much 
%%
%% all note inChordB=1 (no nonChordCondition applies)

%% line 1#65 1#71 
%% 
%% again fail
%%
%% chordPCsInScale and pitchClasses not determined but cardiality determined to 3
%% i.e. determination to FS {2 5 11}#3 above because of cardiality
%%
%% check: also for other note pitches which allow solution: cardiality determined to 3 in first space

%% set chord DB to two chord with 4 notes and still in first search space chordPCsInScale and pitchClasses of chord: cardiality determined to 3
%%
%% !! solution is found: index 1 and transposition 5: chord PCs FS {0 5 9}#3 (F Dur): does chord really use changed DB?? Can I at all change DB later? Do I get the same problem here I had when setting changes in init file??

%% according to test in Score-test.oz, changing chord DB seems to work fine

{HS.db.setDB
 unit(chordDB: chords(chord(pitchClasses:[0 3 6 9] 
			    roots:[0]
			    comment:'diminished'))
      scaleDB: scales(scale(pitchClasses:[0 1 3 4 6 7 9 10]
			    roots:[0] % !!??
			    comment:'"messiaen II"')))}


declare
MyChord = {Score.makeScore chord(index:1
				 transposition:1
				 duration:1
				 startTime:0
				 timeUnit:beats(4))
	   add(chord:HS.score.chord)}
MyScale = {Score.makeScore scale(index:1 transposition:0
				  startTime:0
				  duration:0 %% !!??
				 )
	   add(scale:HS.score.scale)}


{Browse {MyChord toFullRecord($)}}

{Browse {MyScale toFullRecord($)}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Problem found:
%%
%% accessors in functor don't return changed values after database is changed. Thus, accessors called within functor behave differently than accessors called in OPI
declare
MyChord = {Score.makeScore chord(index:1
				 transposition:1
				 duration:1
				 startTime:0
				 timeUnit:beats(4))
	   Aux.myCreators}
MyScale = {Score.makeScore scale(index:1 transposition:0
				  startTime:0
				  duration:0 %% !!??
				 )
	   Aux.myCreators}


{Browse {MyChord toFullRecord($)}}

{Browse {MyScale toFullRecord($)}}


%% situation: cell with setter and accessor defined in functor A, accessor called in functor B in function X, setter called in OPI to change cell in functor A, function X called in OPI which calls accessor: should return updated value but returns only value

%% possible solution: hand DB to every chord init method 'directly'. But that makes score creation more clumpsy

%% Problem solved by replacing Module.link with own variant

%% !! -> this also solves my problem with init settings in ~/.ozrc

%%
%% no 'fail' with messian II and diminished seventh.
%%
%% However, wrong (too small) PC set of scale and chord
%%
%% !!?? scale still c major scale and diatonic chord still c major chord
%%

declare
MyScale = {Score.makeScore scale(index:1 transposition:0
				  startTime:0
				  duration:0 %% !!??
				 )
	   Aux.myCreators}
proc {GetMyScale Self Scales} Scales = [MyScale] end
MyChord = {Score.makeScore
	   diatonicChord(index:1
			 transposition:0
			 duration:1
			 startTime:0
			 timeUnit:beats(4)
			 getScales:GetMyScale)
	   Aux.myCreators}

{Browse {MyScale toFullRecord($)}}

{Browse {MyChord toFullRecord($)}}


%% why chord chordPCsInScale determined to FS {5}#1
%%
%% why chord pitchClasses determined to FS {1 5 8}#3 (i.e. c# major) -- no relation to chord DB

%% besides: fail is correct: there is no diatonic diminished chord in major scale


%***************************** failure **************************
%**
%** In statement: {<P/0 INTERNAL.propagate>}
%** In statement: {fsp_equalR {5}#1 {1 5 8}#3 1}



/*
%% D major (does not work with predef C-major scale)
{SDistro.exploreOne
 {MakeScript [1#62 1#64 1#66 1#67
	      % 1#68 1#71 2#68	% obere Nebennote (no passing note!)
	      %% !! tmp: edit line 
	      1#69 1#66 2#69	% obere Nebennote (no passing note!) 
	      1#67 1#64 2#73
	      1#69 1#66 2#74]
  4}
 Aux.myDistribution}
*/ 




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% old debugging
%% 

%% !!?? also without additional chord prog rules only two solutions? E.g., last chord chord be IV.. Why is this??

%% why only single solution a-minor? Could be any chord note in major
%% or minor chord more solutions without seventh?? but still only a
%% subset..
{SDistro.exploreOne
 {AutomaticHarmonisation [4#60] 4}
 Aux.myDistribution}



%% simplified CSP: single determined note, chord and determined scale
%% same problem: c only third of a-minor
%% Problem is chord 'inScale'
{SDistro.exploreOne
 proc {$ MyScore}
      %% default scale DB: C major scale
      MyScale = {Score.makeScore2 scale(index:1 transposition:0
					startTime:0
					duration:0 %% !!??
				       )
		 Aux.myCreators}
    proc {GetMyScale Self Scales} Scales = [MyScale] end
    MyChord = {Score.makeScore2
	       diatonicChord(duration:4
			     inScaleB:1
			     getScales:GetMyScale)
	       Aux.myCreators}
    MyNote = {Score.makeScore2 
	      note(duration:4
		   pitch:60
		   inChordB:1 %{FD.int 0#1}
		   inScaleB:1
		   getScales:GetMyScale)
	     Aux.myCreators} 
 in
    MyScore = {Score.makeScore
	       sim(items:[MyNote MyChord]
		   startTime:0
		   timeUnit:beats(4))
	       Aux.myCreators}
 end
 Aux.myDistribution}


%% !! ist dies nicht korrekt??



%% new chord DB (see above with major seventh): only solution note c as third of a minor.

%% index 1 (dur) transposition/root PC=0 (i.e. C dur 7): caused fail -- correct (kein b flat in C dur)

%% index 1 (dur) transposition/root PC=2 (i.e. D dur): caused fail -- correct

%% index 1 (dur) transposition/root PC=4, PC=5, PC=11 (i.e. E and F and H dur): caused fail -- why are three excluded in one step?

%% index 1 (dur) transposition/root PC=6 and PC=9 (i.e. G and A dur): caused fail -- why are two excluded in one step?


%% reducing transposition/root during distribution is not propagated to pitchClasses or chordPCsInScale (dies OK) -- kann sein dass problem immer dann erst auftritt wenn Entscheidung fuer index + transposition faellt


%%
%% OK for G7 in C-Dur
declare
MyScale = {Score.makeScore2 scale(index:1 transposition:0
				  startTime:0
				  duration:0 %% !!??
				 )
	   Aux.myCreators}
proc {GetMyScale Self Scales} Scales = [MyScale] end
MyChord = {Score.makeScore
	   diatonicChord(duration:4
			 inScaleB:1
			 getScales:GetMyScale)
	   Aux.myCreators}


{MyChord toFullRecord($)}

{MyChord getIndex($)} = 1

{MyChord getTransposition($)} = 7 %% OK



