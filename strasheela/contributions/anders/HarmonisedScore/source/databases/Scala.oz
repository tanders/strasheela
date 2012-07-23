
/** %% Defines the 12-ET chord and scale database entries that are found in the Scala software database.
%% Sources: Scala files chordnam.par and modenam.par

%% The chord databases also contain the feature oneFootedBridgeChordSonance, see the documentation of OneFootedBridgeChordSonance.
%% */

%%
%%  TODO:
%% - ?? JI chords in Scala database
%% - Complete 12-TET database chords
%% - Add 12-TET database scales (modes in Scala terminology)
%%

%%
%% TODO:
%%
%% - revise specs for required PC and dissonances PC 
%%
%% - dissonance degree: incorporate some standard measurements
%%

functor
import
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   
export
   Chords
   Scales
   Intervals
   PitchesPerOctave
   AccidentalOffset
   OctaveDomain
   db:DB

   OneFootedBridgeChordSonance
   
define

   Chords = chords(
	       	       
	       chord(pitchClasses:{Pattern.dxsToXs [1 1] 0}
		     roots:[0]
		     comment:'Semitone Trichord')
	       chord(pitchClasses:{Pattern.dxsToXs [1 1 2 3 1] 0}
		     roots:[0]
		     comment:'All-interval Hexachord')
	       chord(pitchClasses:{Pattern.dxsToXs [1 1 3 1 3] 0}
		     roots:[0]
		     comment:'Schoenberg Anagram Hexachord')
	       chord(pitchClasses:{Pattern.dxsToXs [1 1 4 2] 0}
		     roots:[0]
		     comment:'Bardos Chord')
	       chord(pitchClasses:{Pattern.dxsToXs [1 2] 0}
		     roots:[0]
		     comment:'Phrygian Trichord')
	       chord(pitchClasses:{Pattern.dxsToXs [1 2 2] 0}
		     roots:[0]
		     comment:'Dorian Tetrachord')
	       chord(pitchClasses:{Pattern.dxsToXs [1 2 2 1 2] 0}
		     roots:[0]
		     comment:'Locrian Hexachord')
	       chord(pitchClasses:{Pattern.dxsToXs [1 2 4] 0}
		     roots:[0]
		     comment:'All-interval Tetrachord 2')
	       chord(pitchClasses:{Pattern.dxsToXs [1 3] 0}
		     roots:[0]
		     comment:'Major-Minor Trichord I')
	       chord(pitchClasses:{Pattern.dxsToXs [1 3 1] 0}
		     roots:[0]
		     comment:'Chromatic Mezotetrachord')
	       chord(pitchClasses:{Pattern.dxsToXs [1 3 2] 0}
		     roots:[0]
		     comment:'All-interval Tetrachord 1')
	       chord(pitchClasses:{Pattern.dxsToXs [1 4 3] 0}
		     roots:[0]
		     comment:'Major Seventh 3rd inversion')
	       chord(pitchClasses:{Pattern.dxsToXs [2 1] 0}
		     roots:[0]
		     comment:'Minor Trichord')
	       chord(pitchClasses:{Pattern.dxsToXs [2 1 2] 0}
		     roots:[0]
		     comment:unit(name:['Minor Tetrachord' 'Phrygian Tetrachord']))
	       chord(pitchClasses:{Pattern.dxsToXs [2 1 2 2] 0}
		     roots:[0]
		     comment:'Minor Pentachord')
	       chord(pitchClasses:{Pattern.dxsToXs [2 1 2 2 2] 0}
		     roots:[0]
		     comment:'Minor Hexachord')
	       chord(pitchClasses:{Pattern.dxsToXs [2 2] 0}
		     roots:[0]
		     comment:'Whole-Tone Trichord')
	       chord(pitchClasses:{Pattern.dxsToXs [2 2 1] 0}
		     roots:[0]
		     comment: unit(name:['Major Tetrachord' 'Lydian Tetrachord']))
	       chord(pitchClasses:{Pattern.dxsToXs [2 2 1 2] 0}
		     roots:[0]
		     comment:'Major Pentachord')
	       chord(pitchClasses:{Pattern.dxsToXs [2 2 1 2 2] 0}
		     roots:[0]
		     comment:'Major Hexachord')
	       chord(pitchClasses:{Pattern.dxsToXs [2 2 2] 0}
		     roots:[0]
		     comment:'Secundal Tetrachord')
	       chord(pitchClasses:{Pattern.dxsToXs [2 2 3] 0}
		     roots:[0]
		     comment:unit(name:['Added Second' 'Mu Major' 'add2' '2']))
	       chord(pitchClasses:{Pattern.dxsToXs [2 2 3 2] 0}
		     roots:[0]
		     comment:unit(name:['Added Second & Sixth' '6/2']))
	       chord(pitchClasses:{Pattern.dxsToXs [2 3] 0}
		     roots:[0]
		     comment:unit(name:['Second-Fourth Chord' '4/2']))
	       chord(pitchClasses:{Pattern.dxsToXs [2 3 2] 0}
		     roots:[0]
		     comment:unit(name:['Second-Fourth-Fifth Chord' 'sus2,4' '5/4/2']))
	       chord(pitchClasses:{Pattern.dxsToXs [2 3 3] 0}
		     roots:[0]
		     comment:'Half-diminished Seventh 3rd inversion')
	       chord(pitchClasses:{Pattern.dxsToXs [2 3 4] 0}
		     roots:[0]
		     comment:unit(name:['Second-Fourth-Sixth Chord' '6/4/2' 'Minor Seventh 3rd inversion']))
	       chord(pitchClasses:{Pattern.dxsToXs [2 4] 0}
		     roots:[0]
		     comment:unit(name:['Double Diminished' 'Augmented Sixth 2nd inversion']))
	       chord(pitchClasses:{Pattern.dxsToXs [2 4 3] 0}
		     roots:[0]
		     comment:unit(name:['Double Diminished Seventh' 'Dominant Seventh 3rd inversion']))
	       chord(pitchClasses:{Pattern.dxsToXs [2 5] 0}
		     roots:[0]
		     comment:unit(name:['Suspended Second' 'sus2' 'Second-Fifth Chord' '5/2']))
	       chord(pitchClasses:{Pattern.dxsToXs [2 5 2] 0}
		     roots:[0]
		     comment:unit(name:['Sixth Suspended Second' '6sus2']))
	       chord(pitchClasses:{Pattern.dxsToXs [2 5 3] 0}
		     roots:[0]
		     comment:unit(name:['Dominant Seventh Suspended Second' '7sus2']))
	       chord(pitchClasses:{Pattern.dxsToXs [2 5 4] 0}
		     roots:[0]
		     comment:unit(name:['Major Seventh Suspended Second' 'maj7sus2']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 1] 0}
		     roots:[0]
		     comment:'Major-Minor Trichord II')
	       chord(pitchClasses:{Pattern.dxsToXs [3 1 3] 0}
		     roots:[0]
		     comment:unit(name:['Major-Minor Tetrachord' 'Bimodal Chord']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 1 4] 0}
		     roots:[0]
		     comment:'Augmented-Major Tetrachord')
	       chord(pitchClasses:{Pattern.dxsToXs [3 2] 0}
		     roots:[0]
		     comment:'Minor Quartal Triad')
	       chord(pitchClasses:{Pattern.dxsToXs [3 2 3] 0}
		     roots:[0]
		     comment:unit(name:['Third-Fourth Chord' '4/3' 'Minor Seventh 2nd inversion']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 2 4] 0}
		     roots:[0]
		     comment:'Dominant Seventh 2nd inversion')
	       chord(pitchClasses:{Pattern.dxsToXs [3 3] 0}
		     roots:[0]
		     comment:unit(name:['Diminished' 'mb5' 'Minor Trine']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 3 2] 0}
		     roots:[0]
		     comment:'Dominant Seventh 1st inversion')
	       chord(pitchClasses:{Pattern.dxsToXs [3 3 3] 0}
		     roots:[0]
		     comment:unit(name:['Diminished Seventh' 'dim']))
	       % chord(pitchClasses:{Pattern.dxsToXs [3 3 3 3] 0} % NOTE: repeated PC!
	       % 	     roots:[0]
	       % 	     comment:'Strawinsky\'s Sacre-chord')
	       % chord(pitchClasses:{Pattern.dxsToXs [3 3 3 3 2 3 3 3] 0} % NOTE: PCs outside octave
	       % 	     roots:[0]
	       % 	     comment:'Alpha Chord')
	       chord(pitchClasses:{Pattern.dxsToXs [3 3 4] 0}
		     roots:[0]
		     comment:unit(name:['Half-diminished Seventh' 'm7b5' 'Eulenspiegel Chord']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 3 5] 0}
		     roots:[0]
		     comment:unit(name:['Diminished-Major Seventh' 'mmaj7b5']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 4] 0}
		     roots:[0]
		     comment:unit(name:['Major Triad' 'm']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 4 1] 0}
		     roots:[0]
		     comment:'Major Seventh 1st inversion')
	       chord(pitchClasses:{Pattern.dxsToXs [3 4 2] 0}
		     roots:[0]
		     comment:unit(name:['Minor Sixth' 'm6']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 4 2 5] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Minor Sixth Added Ninth' 'm6/9']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 4 3] 0}
		     roots:[0]
		     comment:unit(name:['Minor Seventh' 'm7']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 4 3 4] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Minor Ninth' 'm9']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 4 3 4 3] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Minor Eleventh' 'm11']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 4 3 4 3 4] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Minor Thirteenth' 'm13'])) 
	       chord(pitchClasses:{Pattern.dxsToXs [3 4 4] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Minor-Major Seventh' 'mmaj7'])) 
	       chord(pitchClasses:{Pattern.dxsToXs [3 4 4 3] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Minor-Major Ninth' 'mmaj9'])) 
	       chord(pitchClasses:{Pattern.dxsToXs [3 4 4 3 7] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:[' Minor-Major Thirteenth' 'mmaj13']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 4 7] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Minor Added Ninth' 'madd9']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 5] 0}
		     roots:[0]
		     comment:unit(name:['Neapolitan Sixth' 'Major Triad 1st inversion']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 5 3] 0}
		     roots:[0]
		     comment:unit(name:['Major Seventh Augmented Fifth' 'maj7#5']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 6] 0}
		     roots:[0]
		     comment:unit(name:['Minor Trine 1st inversion']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 6 3] 0}
		     roots:[0]
		     comment:unit(name:['Sixths Chord']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 7] 0}
		     roots:[0]
		     comment:unit(name:['Minor Quintal Triad']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 1 2] 0}
		     roots:[0]
		     comment:unit(name:['Added Fourth' 'add4']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 1 4] 0}
		     roots:[0]
		     comment:unit(name:['Major Seventh 2nd inversion']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 2] 0}
		     roots:[0]
		     comment:unit(name:['Hard-diminished' 'b5']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 2 2 5] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Enigmatic Pentachord'])) 
	       chord(pitchClasses:{Pattern.dxsToXs [4 2 2 7] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Augmented-diminished Ninth']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 2 3] 0}
		     roots:[0]
		     comment:unit(name:['Half-diminished Seventh 2nd inversion']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 2 4] 0}
		     roots:[0]
		     comment:unit(name:['Hard-diminished Seventh' '7b5' 'French Sixth']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 2 4 3] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Hard-diminished Minor Ninth' 'b9b5']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 2 4 3 8] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Hard-diminished Minor Ninth Added Thirteenth' '13b9b5']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 2 4 4] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Hard-diminished Ninth' '9b5']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 2 4 5] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Hard-diminished Seventh & Augmented Ninth' '#9b5']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 2 8] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Hard-diminished Added Ninth' 'b5add9']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3] 0}
		     roots:[0]
		     comment:unit(name:['Major Triad' 'maj']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 2] 0} 
		     roots:[0]
		     comment:unit(name:['Sixte Ajoutee' '6' 'Minor Seventh 1st inversion']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 2 5] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Added Sixth & Ninth' '6/9']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 2 5 4] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Added Sixth & Ninth & Augmented Eleventh' '6/9#11']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3] 0}
		     roots:[0]
		     comment:unit(name:['Dominant Seventh' '7' 'German Sixth']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 3] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Dominant Ninth Minor' '7b9']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 3 4] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Dominant Ninth Minor Added Eleventh' '11b9']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 3 5 3] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Augmented Thirteenth Minor Ninth' '13b9#11']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 3 8] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Dominant Ninth Minor Added Thirteenth' '13b9']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 4] 0} % NOTE: PCs outside octave
		     roots:[0]
		     comment:unit(name:['Dominant Ninth' '9']))

	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))
	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     comment:unit(name:['' '']))

	       % chord(pitchClasses:{Pattern.dxsToXs [] 0}
	       % 	     roots:[0]
	       % 	     % required:[]
	       % 	     % dissonances:nil
	       % 	     % dissonanceDegree:nil
	       % 	     comment:'')
	       
	       )
   
   Scales = scales(scale(pitchClasses:[0 2 4 5 7 9 11]
			 roots:[0]
			 comment:'major')

		   
		  )

   Intervals = intervals(interval(interval:0
				  dissonanceDegree:0
				  comment:'unison')
			 interval(interval:1
				  dissonanceDegree:6
				  comment:'minorSecond')
			 interval(interval:2
				  dissonanceDegree:5
				  comment:'majorSecond')
			 interval(interval:3
				  dissonanceDegree:4
				  comment:'minorThird')
			 interval(interval:4
				  dissonanceDegree:3
				  comment:'majorThird')
			 interval(interval:5
				  dissonanceDegree:2
				  comment:'fourth')
			 interval(interval:6
				  dissonanceDegree:6
				  comment:'tritone')
			 interval(interval:7
				  dissonanceDegree:1
				  comment:'fifth')
			 interval(interval:8
				  dissonanceDegree:3
				  comment:'minorSixth')
			 interval(interval:9
				  dissonanceDegree:4
				  comment:'majorSixth')
			 interval(interval:10
				  dissonanceDegree:5
				  comment:'minorSeventh')
			 interval(interval:11
				  dissonanceDegree:6
				  comment:'majorSeventh'))

   
   /** %% Values of Partch's one-footed bridge of JI intervals of which 12-TET intervals are often considered to be approximations. Source: Genesis of a Music, p. 155. Values measued simply in mm (graph does not specify any unit). Higher sonance values mean higher degree of consonance.
   %% */
   % 1/1   | no data
   % 16/15 | 5
   % 9/8   | 10
   % 6/5   | 19
   % 5/4   | 19 (20?)
   % 4/3   | 27
   % 45/32 | ? (0 in graph?)
   % 3/2   | 27
   % 8/5   | 19
   % 5/3   | 19
   % 16/9  | 10
   % 15/8  | 5 
   % 2/1   | 38
   %% TODO: refine this e.g. using harmonic entropy data
   OneFootedBridgeData = unit(0: 38
			      1: 5
			      2: 10
			      3: 19
			      4: 19
			      5: 27
			      6: 5
			      7: 27
			      8: 19
			      9: 19
			      10: 10
			      11: 5) 
   /** %% Expects a chord DB entry and returns this entry extended by the feature oneFootedBridgeChordSonance, which specifies a sonance value (dissonance degree) for this chord. The returned sonance is a distorted arithmetric mean of the one-footed bridge distances of all intervals in the given chord, where chords with more pitch classes are rated slightly lower than the actual mean, the more pitch classes there are in a chord the more this distortion is taken into account (an int). 
   %% */
   fun {OneFootedBridgeChordSonance Chord}
      %% Chords with more pitch classes are automatically rated to be more dissonant, and ArityCurve specifies how much so. The higher ArityCurve, the more this is taken into account (at 1.0 it has no effect).
      ArityCurve = 1.25
      %% list of sonances for all intervals in chord (all PC combinations)
      Sonances = {Pattern.mapPairwise Chord.pitchClasses
		  fun {$ PC1 PC2}
		     PcInterval = {Abs PC1 - PC2} mod 12
		  in
		     OneFootedBridgeData.PcInterval
		  end}
      %% arithmetic mean
      Sonance =  {FloatToInt {IntToFloat {LUtils.accum Sonances Number.'+'}}
		  / {Pow {IntToFloat {Length Sonances}} ArityCurve}}
   in
      {Adjoin unit(oneFootedBridgeChordSonance:Sonance)
       Chord}
   end
   
   

   PitchesPerOctave = 12
   AccidentalOffset = 2
   %% corresponds to MIDI pitch range 12-127+ (for pitchesPerOctave=12)
   OctaveDomain = 0#9
   
   /** %% Full database declaration defined in this functor. 
   %% */
   DB = {HS.db.makeFullDB
	 unit(pitchesPerOctave: PitchesPerOctave
	      accidentalOffset: AccidentalOffset
	      octaveDomain: OctaveDomain
	      %% computing these values takes only a couple of msecs, which can be neclegted (otherwise I would need to move all interval specs and this computation at the compile time of the functor..)
	      chords: {Record.map Chords OneFootedBridgeChordSonance}
	      scales: Scales
	      intervals: Intervals
	      chordFeatures: [oneFootedBridgeChordSonance]
	      scaleFeatures: nil
	      intervalFeatures: nil)}

end
