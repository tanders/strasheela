
/** %% Defines the 12-ET chord and scale database entries that are found in the Scala software database.
%% Sources: Scala files chordnam.par and modenam.par

%% The chord databases also contain a few features on the consonance/dissonance degree (sonance) and harmonic complexity with respect to the harmonic series over the root of the chord. For details see the documentation of the functions with the same names as these features in the source code file Scala.oz.
%% */

%%
%% BUG:
%% - OK Some chords missing, e.g., 'Undertone'
%%   -> chord removed as dublicate entry (same as minor)
%% - OK? Some chords with strangely formatted comment feature (comment double-nested), e.g., 'Tristan Chord' and other chords named with symbolic note names --
%%     -> caused by calling HS.db.ratiosInDBEntryToPCs -- problem temporarily solved by not supporting ratios
%%

%%
%%  TODO:
%% - !! Add missing 12-TET scales from Scala file (modes in Scala terminology)
%% - !! Revise removal of dublicate entries
%%   - if order of PCs is different then entries are not removed -- sort PCs at least for comparing
%%   - if entries only differ in root (e.g., difference between major chord and sixth chord) then entries not removed
%% - fix warning in ReduceToSingleOctave (some chord names from which PCs are removed are left out)
%% - complete functor documentation:
%%   - document analytical features concerning sonance and harmonic complexity
%%
%% - ?? JI chords in Scala database
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
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   
export
   % Chords
   % Scales
   % Intervals
   % PitchesPerOctave
   % AccidentalOffset
   % OctaveDomain
   db:DB

   % OneFootedBridgeChordSonance
   
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
	       chord(pitchClasses:{Pattern.dxsToXs [3 3 3 3] 0} % NOTE: repeated PC!
	       	     roots:[0]
	       	     comment:'Strawinsky\'s Sacre-chord')
	       chord(pitchClasses:{Pattern.dxsToXs [3 3 3 3 2 3 3 3] 0} % NOTE: PCs outside octave
	       	     roots:[0]
	       	     comment:'Alpha Chord')
	       chord(pitchClasses:{Pattern.dxsToXs [3 3 4] 0}
		     roots:[0]
		     comment:unit(name:['Half-diminished Seventh' 'm7b5' 'Eulenspiegel Chord']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 3 5] 0}
		     roots:[0]
		     comment:unit(name:['Diminished-Major Seventh' 'mmaj7b5']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 4] 0}
		     roots:[0]
		     comment:unit(name:['Minor Triad' 'Minor' 'm']))
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
		     comment:unit(name:['Major Triad' 'Major' 'maj']))
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
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 4 3] 0} % NOTE: PCs outside octave
	       	     roots:[0]
	       	     comment:unit(name:['Dominant Eleventh' '11']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 4 3 4] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Dominant Thirteenth' '13']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 4 4] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Dominant Ninth Augmented Eleventh' '9#11']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 4 4 3] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Augmented Thirteenth' '13#11' '7#11' 'Lydian Dominant']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 4 4 3 4] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Augmented Fifteenth' '#15']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 5] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Dominant Augmented Ninth' '7#9' 'Altered Dominant']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 7] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Dominant Seventh Added Eleventh' '7/11']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 7 4] 0}
	       	     roots:[0]
	       	     comment:unit(name:['11/7/6']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 3 11] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Dominant Seventh Added Thirteenth' '7/13']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 4] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Major Seventh' 'maj7' '*']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 4 3] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Major Ninth' 'maj9']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 4 3 3] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Major Eleventh' 'maj11']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 4 3 3 4] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Major Thirteenth' 'maj13']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 4 3 4] 0}
	       	     roots:[0]
		     comment:unit(name:['Lydian' '*#11']))
	       %% NOTE: name Lydian and '*#11' for multiple chord (one above and below this line)
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 4 7] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Lydian' '*#11']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 3 7] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Added Ninth' 'add9']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 4] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Augmented' 'aug' '#5' 'Major Trine']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 4 2] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Augmented Dominant Seventh' '7+' '7#5']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 4 2 3] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Augmented Dominant Seventh Minor Ninth' '7#5b9']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 4 2 4] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Augmented Dominant Ninth' '9#5']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 4 2 5] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Augmented Dominant Seventh Augmented Ninth' '7#5#9']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 4 3] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Augmented Major Seventh' 'maj7#5']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 4 6] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Augmented Added Ninth' '#5add9']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 5] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Minor Triad 1st inversion']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 5 2] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Sixth-Seventh Chord' '7/6']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 5 5] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Sixth-Ninth Chord' '9/6']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 6] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Augmented Sixth' 'aug6' 'Italian Sixth']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 7] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Major Quintal Triad']))
	       chord(pitchClasses:{Pattern.dxsToXs [4 7 3] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Seventh-Ninth Chord' '9/7']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 1] 0}
	       	     roots:[0]
	       	     comment:unit(name:['Viennese Trichord']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 1 1] 0}
	       	     roots:[0]
		     comment:unit(name:['Dream Chord']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 2] 0}
	       	     roots:[0]
		     comment:unit(name:['Suspended Fourth' 'sus4']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 2 2] 0}
	       	     roots:[0]
		     comment:unit(name:['Sixth Suspended Fourth' '6sus4']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 2 3] 0}
	       	     roots:[0]
		     comment:unit(name:['Dominant Seventh Suspended Fourth' '7sus4']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 2 3 4] 0}
	       	     roots:[0]
		     comment:unit(name:['Dominant Ninth Suspended Fourth' '9sus4']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 2 3 4 7] 0}
	       	     roots:[0]
		     comment:unit(name:['Thirteenth Suspended Fourth' '13sus4']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 2 4] 0}
	       	     roots:[0]
		     comment:unit(name:['Major Seventh Suspended Fourth' 'maj7sus4']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 2 7] 0}
	       	     roots:[0]
		     comment:unit(name:['Fourth-Ninth Chord' '9/4' 'sus4add9']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 3] 0}
	       	     roots:[0]
		     comment:unit(name:['Minor Triad 2nd inversion']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 4] 0}
	       	     roots:[0]
		     comment:unit(name:['Fourth-Sixth Chord' 'Major Triad 2nd inversion' '6/4']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 5] 0}
	       	     roots:[0]
		     comment:unit(name:['Quartal Triad']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 5 5] 0}
	       	     roots:[0]
		     comment:unit(name:['Quartal Tetrad']))
	       chord(pitchClasses:{Pattern.dxsToXs [5 6] 0}
	       	     roots:[0]
		     comment:unit(name:['Fourth-Seventh Chord' '7/4']))
	       chord(pitchClasses:{Pattern.dxsToXs [6 2] 0}
	       	     roots:[0]
		     comment:unit(name:['Augmented Sixth 1st inversion']))
	       chord(pitchClasses:{Pattern.dxsToXs [6 3] 0}
	       	     roots:[0]
		     comment:unit(name:['Minor Trine 2nd inversion']))
	       chord(pitchClasses:{Pattern.dxsToXs [7 3] 0}
	       	     roots:[0]
		     comment:unit(name:['Minor Quintal Triad']))
	       chord(pitchClasses:{Pattern.dxsToXs [7 4] 0}
	       	     roots:[0]
		     comment:unit(name:['Major Quintal Triad']))
	       chord(pitchClasses:{Pattern.dxsToXs [7 7] 0}
	       	     roots:[0]
		     comment:unit(name:['Quintal Triad']))
	       chord(pitchClasses:{Pattern.dxsToXs [7 7 7 7] 0}
	       	     roots:[0]
		     comment:unit(name:['Fifths Chord']))
	       chord(pitchClasses:{Pattern.dxsToXs [7 7 10] 0}
	       	     roots:[0]
		     comment:unit(name:['Quintal Tetrad']))
	       chord(pitchClasses:{Pattern.dxsToXs [12 7 5 4 3] 0}
	       	     roots:[0]
		     comment:unit(name:['Overtone']))
	       chord(pitchClasses:{Pattern.dxsToXs [3 4 5 7 12] 0}
	       	     roots:[0]
		     comment:unit(name:['Undertone']))
	       
	       chord(pitchClasses:['F' 'B' 'D#'#1 'G#'#1]
	       	     roots:['F']
		     comment:unit(name:['Tristan Chord']))
	       chord(pitchClasses:['C' 'F#' 'Bb' 'E'#1 'A'#1 'D'#2]
	       	     roots:['C']
	       	     comment:unit(name:['Scriabin''s Mystic Chord' 'Prometheus Chord']))
	       chord(pitchClasses:['E' 'B' 'Db'#1 'F'#1 'Ab'#1]
	       	     roots:['E']
	       	     comment:unit(name:['Elektra Chord']))
	       chord(pitchClasses:['C' 'E' 'F#' 'G' 'A#' 'C#'#1]
	       	     roots:['C']
		     comment:unit(name:['Petrushka Chord']))
	       %% 'Psalms Chord' only significant in harmony model that supports voicing/pitch class octaves in addition to the current pitch classes
	       % chord(pitchClasses:['E' 'G' 'B' 'G'#1 'G'#2 'E'#3 'G'#3 'B'#3]
	       % 	     roots:['E'] % 'G' ?
	       % 	     comment:unit(name:['Psalms Chord']))
	       chord(pitchClasses:['C' 'Bb' 'E'#1 'D'#2 'G#'#3 'F#'#3]
	       	     roots:['C']
	       	     comment:unit(name:['Whole-Tone Chord']))
	       chord(pitchClasses:['C' 'G#' 'B' 'E'#1 'A'#1]
	       	     roots:['C']
	       	     comment:unit(name:['Farben Chord']))
	       chord(pitchClasses:['E' 'D'#1 'G'#1 'C'#2]
	       	     roots:['E']
		     comment:unit(name:['Steely Dan Chord']))
	       %%
	       %%  Messiaen's chords
	       %%
	       chord(pitchClasses:['B' 'E'#1 'Gb'#1 'G'#1 'Bb'#1 'Eb'#2 'F'#2 'A'#2]
	       	     roots:['B'] % TODO: revise
	       	     comment:unit(name:['orange'])) % 'orangé'
	       chord(pitchClasses:['A' 'D'#1 'F'#1 'G'#1 'Ab'#1 'Eb'#2 'Gb'#2 'Bb'#2]
	       	     roots:['A'] % TODO: revise
	       	     comment:unit(name:['gris et or']))
	       chord(pitchClasses:['Bb' 'Eb'#1 'F'#1 'G'#1 'B'#1 'C'#2 'Gb'#2 'Ab'#2]
	       	     roots:['Bb'] % TODO: revise
	       	     comment:unit(name:['rouge']))
	       chord(pitchClasses:['D' 'E'#1 'C#'#2 'A'#2]
	       	     roots:['D'] % TODO: revise
	       	     comment:unit(name:['bleu']))
	       chord(pitchClasses:['C#' 'C'#1 'G#'#1 'D'#2]
	       	     roots:['C#']
	       	     comment:unit(name:['vert pale et argent'])) % 'vert pâle et argent'
	       chord(pitchClasses:['G' 'A' 'C'#1 'D'#1 'F'#1 'B'#1 'E'#2]
	       	     roots:['G'] % TODO: revise
	       	     comment:unit(name:['Accord sur dominante']))
	       chord(pitchClasses:['C' 'E' 'G' 'Bb' 'D'#1 'F#'#1 'G#'#1 'B'#1]
	       	     roots:['C']
	       	     comment:unit(name:['Accord de la resonance'])) % 'Accord de la résonance'
	       chord(pitchClasses:['Db' 'G' 'C'#1 'F#'#1 'B'#1 'F'#2]
	       	     roots:['Db'] % TODO: revise
	       	     comment:unit(name:['Accord en quartes']))
	       
	       )
   
   
   Scales = scales(scale(pitchClasses:{Pattern.dxsToXs [5 7] 0}
			 roots:[0]
			 comment:unit(name:['Honchoshi: Japan']))
		   scale(pitchClasses:{Pattern.dxsToXs [7 5] 0}
			 roots:[0]
			 comment:unit(name:['Niagari: Japan']))
		   scale(pitchClasses:{Pattern.dxsToXs [10 2] 0}
			 roots:[0]
			 comment:unit(name:['Warao ditonic: South America']))
		   scale(pitchClasses:{Pattern.dxsToXs [3 4 5] 0}
2			 roots:[0]
			 comment:unit(name:['Ute tritonic' 'Peruvian tritonic 2']))
		   scale(pitchClasses:{Pattern.dxsToXs [4 3 5] 0}
			 roots:[0]
			 comment:unit(name:['Raga Malasri' 'Peruvian tritonic 1']))
		   scale(pitchClasses:{Pattern.dxsToXs [4 5 3] 0}
			 roots:[0]
			 comment:unit(name:['Raga Bilwadala']))
		   scale(pitchClasses:{Pattern.dxsToXs [5 2 5] 0}
			 roots:[0]
			 comment:unit(name:['Raga Sarvasri' 'Warao tritonic: South America']))
		   scale(pitchClasses:{Pattern.dxsToXs [5 5 2] 0}
			 roots:[0]
			 comment:unit(name:['Sansagari: Japan']))
		   scale(pitchClasses:{Pattern.dxsToXs [6 1 5] 0}
			 roots:[0]
			 comment:unit(name:['Raga Ongkari']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 5 1 5] 0}
			 roots:[0]
			 comment:unit(name:['Messiaen truncated mode 5']))
		   scale(pitchClasses:{Pattern.dxsToXs [5 1 5 1] 0}
			 roots:[0]
			 comment:unit(name:['Messiaen truncated mode 5 inverse']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 4 2 4] 0}
			 roots:[0]
			 comment:unit(name:['Messiaen truncated mode 6']))
		   scale(pitchClasses:{Pattern.dxsToXs [4 2 4 2] 0}
			 roots:[0]
			 comment:unit(name:['Messiaen truncated mode 6 inverse']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 4 3 4] 0}
			 roots:[0]
			 comment:unit(name:['Raga Lavangi' 'Gowleeswari']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 7 2] 0}
			 roots:[0]
			 comment:unit(name:['Warao tetratonic: South America']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 2 3 5] 0}
			 roots:[0]
			 comment:unit(name:['Eskimo tetratonic (Alaska: Bethel)']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 3 2 5] 0}
			 roots:[0]
			 comment:unit(name:['Genus primum']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 3 3 4] 0}
			 roots:[0]
			 comment:unit(name:['Raga Haripriya']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 3 4 3] 0}
			 roots:[0]
			 comment:unit(name:['Raga Bhavani']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 4 5 1] 0}
			 roots:[0]
			 comment:unit(name:['Raga Sumukam']))
		   scale(pitchClasses:{Pattern.dxsToXs [4 2 5 1] 0}
			 roots:[0]
			 comment:unit(name:['Raga Nigamagamini']))
		   scale(pitchClasses:{Pattern.dxsToXs [4 3 3 2] 0}
			 roots:[0]
			 comment:unit(name:['Raga Mahathi' 'Antara Kaishiaki']))
		   scale(pitchClasses:{Pattern.dxsToXs [3 4 3 2] 0}
			 roots:[0]
			 comment:unit(name:['Bi Yu: China']))
		   scale(pitchClasses:{Pattern.dxsToXs [5 2 3 2] 0}
			 roots:[0]
			 comment:unit(name:['Genus primum inverse']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 3 2 1 4] 0}
			 roots:[0]
			 comment:unit(name:['Han-kumoi: Japan' 'Raga Shobhavari' 'Sutradhari']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 4 1 4] 0}
			 roots:[0]
			 comment:unit(name:['Hira-joshi' 'Kata-kumoi' 'Yona Nuki Minor: Japan' 'Aeolian Pentatonic']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 4 2 1 4] 0}
			 roots:[0]
			 comment:unit(name:['Hon-kumoi-joshi' 'Sakura' 'Akebono II: Japan' 'Olympos Enharmonic' 'Raga Salanganata' 'Saveri' 'Gunakri (Gunakali)' 'Latantapriya' 'Ambassel: Ethiopia']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 4 2 3 2] 0}
			 roots:[0]
			 comment:unit(name:['Kokin-joshi' 'Miyakobushi' 'Han-Iwato' 'In Sen: Japan' 'Raga Vibhavari (Revati)' 'Bairagi' 'Lasaki']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 4 1 4 2] 0}
			 roots:[0]
			 comment:unit(name:['Iwato: Japan']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 3 2 2 3] 0}
			 roots:[0]
			 comment:unit(name:['Ritusen' 'Ritsu (Gagaku): Japan' 'Zhi' 'Zheng: China' 'Raga Devakriya' 'Durga' 'Suddha Saveri' 'Arabhi' 'Scottish Pentatonic' 'Ujo' 'P\'yongjo: Korea' 'Blues Major' 'Major complement']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 2 3 2 3] 0}
			 roots:[0]
			 comment:unit(name:['Major Pentatonic' 'Ryosen' 'Yona Nuki Major: Japan' 'Man Jue' 'Gong: China' 'Raga Bhopali (Bhup)' 'Mohanam' 'Deskar' 'Bilahari' 'Kokila' 'Jait Kalyan' 'Peruvian Pentatonic 1' 'Ghana pent.2' 'Tezeta Major (Tizita): Ethiopia']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 3 2 3 2] 0}
			 roots:[0]
			 comment:unit(name:['Yo: Japan' 'Suspended Pentatonic' 'Raga Madhyamavati' 'Madhmat Sarang' 'Megh' 'Egyptian' 'Shang' 'Rui Bin' 'Jin Yu' 'Qing Yu: China']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 3 3 2 2] 0}
			 roots:[0]
			 comment:unit(name:['Chaio: China']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 2 2 3 3] 0}
			 roots:[0]
			 comment:unit(name:['Kung: China']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 4 2 2 3] 0}
			 roots:[0]
			 comment:unit(name:['Altered Pentatonic' 'Raga Manaranjani II']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 2 4 3] 0}
			 roots:[0]
			 comment:unit(name:['Raga Abhogi']))
		   scale(pitchClasses:{Pattern.dxsToXs [4 2 1 4 1] 0}
			 roots:[0]
			 comment:unit(name:['Raga Amritavarshini' 'Malashri' 'Shilangi' 'Lydian Pentatonic']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 2 3 4] 0}
			 roots:[0]
			 comment:unit(name:['Raga Audav Tukhari']))
		   scale(pitchClasses:{Pattern.dxsToXs [4 1 4 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Raga Bhinna Shadja' 'Kaushikdhvani' 'Hindolita']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 4 1 4] 0}
			 roots:[0]
			 comment:unit(name:['Balinese Pelog' 'Madenda Modern' 'Phrygian Pentatonic' 'Raga Bhupalam' 'Bhupala Todi' 'Bibhas' 'Tezeta Minor: Ethiopia']))

		   %%
		   %% TODO: add many missing scales
		   %%
		   
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))


		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		   % scale(pitchClasses:{Pattern.dxsToXs [] 0}
		   % 	 roots:[0]
		   % 	 comment:unit(name:['' '']))
		  
		   
		   
		   scale(pitchClasses:{Pattern.dxsToXs [1 3 1 1 1 2 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Raga Bhatiyar']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 3 1 1 1 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Raga Cintamani']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 2 2 2 1 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Raga Mian Ki Malhar' 'Bahar' 'Sindhura']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 2 2 1 1 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Raga Mukhari' 'Anandabhairavi' 'Deshi' 'Manji' 'Gregorian nr.1' 'Dorian/Aeolian mixed']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 3 1 1 1 1 3 1] 0}
			 roots:[0]
			 comment:unit(name:['Raga Ramkali (Ramakri)']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 3 1 2 1 1 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Raga Saurashtra']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 1 1 2 2 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Minor Bebop' 'Dorian Bebop' 'Raga Zilla' 'Mixolydian/Dorian mixed']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 2 1 2 2 1 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Genus diatonicum' 'Dominant Bebop' 'Raga Khamaj' 'Desh Malhar' 'Alhaiya Bilaval' 'Devagandhari' 'Maqam Shawq Awir' 'Gregorian nr.6' 'Major/Mixolydian mixed' 'Chinese Eight-Tone' 'Rast: Greece']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 2 1 2 1 1 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Major Bebop' 'Altered Mixolydian']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 2 1 1 2 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Blues scale II']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 2 1 1 1 3 1] 0}
			 roots:[0]
			 comment:unit(name:['Algerian']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 1 1 2 1 2 2] 0}
			 roots:[0]
			 comment:unit(name:['Spanish Phrygian']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 1 1 1 2 2 2] 0}
			 roots:[0]
			 comment:unit(name:['Espla\'s scale' 'Eight-tone Spanish']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 2 1 1 1 3 1] 0}
			 roots:[0]
			 comment:unit(name:['Half-diminished Bebop']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 2 2 1 1 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Neapolitan Major and Minor mixed']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 3 1 1 2 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Neveseri: Greece']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 2 1 2 1 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Diminished' 'Modus conjunctus' 'Messiaen mode 2 inverse' 'Whole-Half step scale']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 2 1 1 1 2 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Ishikotsucho: Japan' 'Raga Yaman Kalyan' 'Chayanat' 'Bihag' 'Hamir Kalyani' 'Kedar' 'Gaud Sarang' 'Genus diatonicum veterum correctum' 'Gregorian nr.5' 'Kubilai\'s Mongol scale' 'Major/Lydian mixed']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 3 1 1 2 2 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Verdi\'s Scala enigmatica']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 2 2 1 1 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Zirafkend: Arabic' 'Melodic Minor Bebop']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 1 1 2 2 2 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Adonai Malakh: Jewish']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 1 2 2 1 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Magen Abot: Jewish']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 2 2 1 2 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Maqam Nahawand' 'Farahfaza' 'Raga Suha (Suha Kanada)' 'Gregorian nr.4' 'Utility Minor']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 1 1 2 2 1 3 1] 0}
			 roots:[0]
			 comment:unit(name:['Harmonic and Neapolitan Minor mixed']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 3 1 2 1 2 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Maqam Hijaz (Hedjaz)']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 1 1 1 3 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Maqam Shadd\'araban']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 1 2 1 2 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Octatonic' 'Messiaen mode 2' 'Dominant Diminished' 'Diminished Blues' 'Half-Whole step scale']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 1 1 3 1 1 1 3] 0}
			 roots:[0]
			 comment:unit(name:['Messiaen mode 4']))
		   scale(pitchClasses:{Pattern.dxsToXs [3 1 1 1 3 1 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Messiaen mode 4 inverse']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 1 2 2 1 1 2 2] 0}
			 roots:[0]
			 comment:unit(name:['Messiaen mode 6']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 2 1 1 2 2 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Messiaen mode 6 inverse']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 1 1 2 2 1 2 2] 0}
			 roots:[0]
			 comment:unit(name:['Phrygian/Aeolian mixed']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 2 1 1 1 2 2] 0}
			 roots:[0]
			 comment:unit(name:['Phrygian/Locrian mixed']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 2 2 1 2 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Hamel']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 2 1 1 2 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Van der Horst Octatonic']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 2 1 2 2 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Prokofiev']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 1 2 1 2 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Shostakovich']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 1 1 2 2 1 2] 0}
			 roots:[0]
			 comment:unit(name:['JG Octatonic']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 1 2 1 1 2 1 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Messiaen mode 3' 'Tsjerepnin mode 3']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 1 2 1 1 2 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Messiaen mode 3 inverse' 'Tsjerepnin mode 2']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 2 2 1 1 1 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Raga Pilu' 'Full Minor']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 1 1 2 2 1 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Raga Malgunji' 'Ramdasi Malhar' 'Major/Dorian mixed']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 2 1 2 1 1 1 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Raga Pahadi']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 1 1 1 1 2 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Blues Enneatonic']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 2 1 1 1 1 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Kiourdi: Greece']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 2 1 1 1 2 1 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Taishikicho: Japan' 'Ryo: Japan' 'Raga Chayanat' 'Lydian/Mixolydian mixed']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 1 1 2 1 1 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Genus chromaticum' 'Tsjerepnin mode 1']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 1 1 2 1 2 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Moorish Phrygian']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 1 2 1 1 1 2 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Youlan scale: China']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 1 1 2 2 1 1 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Chromatic and Diatonic Dorian mixed']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 1 2 1 2 1 1 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Chromatic and Permuted Diatonic Dorian mixed']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 1 1 2 1 1 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Houseini: Greece' 'Modes of Major Pentatonic mixed']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 1 1 1 2 1 1 1 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Messiaen mode 7']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 1 1 1 2 1 1 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Messiaen mode 7 inverse']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 1 1 2 1 1 1 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Major/Minor mixed']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 1 1 1 1 2 1 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Minor Pentatonic with leading tones']))
		   scale(pitchClasses:{Pattern.dxsToXs [2 1 1 1 1 1 1 1 2 1] 0}
			 roots:[0]
			 comment:unit(name:['Maqam Shawq Afza']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 1 1 1 1 2 1 2 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Raga Sindhi-Bhairavi']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 2 1 1 1 1 1 1 1 2] 0}
			 roots:[0]
			 comment:unit(name:['Maqam Tarzanuyn']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 1 2 1 1 1 1 2 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Symmetrical Decatonic']))
		   scale(pitchClasses:{Pattern.dxsToXs [1 1 1 1 1 1 1 1 1 1 1 1] 0}
			 roots:[0]
			 comment:unit(name:['Twelve-tone Chromatic']))
		  )

   
   Intervals = intervals(interval(interval:0
				  dissonanceDegree:0
				  comment: unit(name:['Unison' 'unison']))
			 interval(interval:1
				  dissonanceDegree:6
				  comment: unit(name:['Minor Second' 'minorSecond']))
			 interval(interval:2
				  dissonanceDegree:5
				  comment: unit(name:['Major Second' 'majorSecond']))
			 interval(interval:3
				  dissonanceDegree:4
				  comment: unit(name:['Minor Third' 'minorThird']))
			 interval(interval:4
				  dissonanceDegree:3
				  comment: unit(name:['Major Third' 'majorThird']))
			 interval(interval:5
				  dissonanceDegree:2
				  comment: unit(name:['Fourth' 'fourth']))
			 interval(interval:6
				  dissonanceDegree:6
				  comment: unit(name:['Tritone' 'tritone']))
			 interval(interval:7
				  dissonanceDegree:1
				  comment: unit(name:['Fifth' 'fifth']))
			 interval(interval:8
				  dissonanceDegree:3
				  comment: unit(name:['Minor Sixth' 'minorSixth']))
			 interval(interval:9
				  dissonanceDegree:4
				  comment: unit(name:['Major Sixth' 'majorSixth']))
			 interval(interval:10
				  dissonanceDegree:5
				  comment: unit(name:['Minor Seventh' 'minorSeventh']))
			 interval(interval:11
				  dissonanceDegree:6
				  comment: unit(name:['Major Seventh' 'majorSeventh'])))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Local chord spec processing defs
%%%

   local
   
      /** %% Expects a chord or scale declaration, and in case it contains symbolic notes names, then these are replaced by their corresponding ET pitch class.  
      %% */
      %% Varied copied from contributions/anders/HarmonisedScore/source/Database.oz
      fun {SymbolicNoteNamesToPCsInDBEntry Decl SymbolToPc PitchesPerOctave}
	 /** %% Only transform atoms (e.g. 'C#' and 'C#'#1), but leave integers (PCs) and records (ratios, e.g., 1#1) untouched.
	 %% */
	 fun {Transform MyPitch}
	    case MyPitch of SymbolPC#Octave
	    then if {GUtils.isAtom SymbolPC} andthen {IsInt Octave}
		 then {SymbolToPc SymbolPC}+Octave*PitchesPerOctave
		    %% leave ratio untouched
		 else MyPitch
		 end
	    else
	       if {GUtils.isAtom MyPitch} then {SymbolToPc MyPitch}	 
	       else MyPitch end
	    end
	 end
      in
	 {Record.mapInd Decl
	  fun {$ Feat X}
	     case Feat
	     of pitchClasses then {Map X Transform}
	     [] essentialPitchClasses then {Map X Transform}
	     [] roots then {Map X Transform}
	     else X
	     end
	  end}
      end
    
      /** %% Reduces the pitch classes of the given chord DB entry (which can exceed an octave) into "true" pitch classes within 0-11. If doublicate pitch classes occur that way, then these are removed (and a warning is printed).
      %%
      %% NOTE: ChordSpec must already be preprocessed by HS.db.ratiosInDBEntryToPCs.
      %% */
      fun {ReduceToSingleOctave ChordSpec}
	 fun {GetName}
	    if {HasFeature ChordSpec comment}
	    then 
	       Comment = ChordSpec.comment
	       NameAux
	       = if {GUtils.isRecord Comment} then
		    if {HasFeature Comment comment} andthen {IsVirtualString Comment.comment}
		    then Comment.comment
		    elseif {HasFeature Comment name}
		    then Comment.name
		    else nil
		    end
		 else nil
		 end
	    in
	       case NameAux of nil then nil 
	       else if {IsList NameAux} then NameAux.1 else NameAux end
	       end
	    else nil
	    end
	 end
	 PCs = {LUtils.removeDuplicates2
		{Map ChordSpec.pitchClasses fun {$ PC} PC mod 12 end}
		proc {$ PC} % print warning
		   {Out.show 'Removed duplicate PC '#PC#' from chord '#{GetName}}
		end}
      in
	 {Adjoin unit(pitchClasses:PCs
		      pitchClassesOriginallyOutsideOctave:
			 if {Some ChordSpec.pitchClasses
			     fun {$ PC} PC > 11 end}
			 then 1 else 0 end)
	  {Record.subtract ChordSpec pitchClasses}}
      end
      
      /** %% Transposes all PCs (which must be within 0-11) in a chord (or scale) spec such that its (first) root is 0. All PCs in ChordSpec's features pitchClasses, essentialPitchClasses and roots must be integers. 
      %% */
      fun {TransposeSpecTo0 ChordSpec PitchesPerOctave}
	 %% if (first) root is already 0 then leave ChordSpec untouched
	 if ChordSpec.roots.1 == 0 then ChordSpec
	 else
	    TranspositionInterval = PitchesPerOctave - (ChordSpec.roots.1 mod PitchesPerOctave)
	    fun {TransposePC MyPC}
	       (MyPC + TranspositionInterval) mod PitchesPerOctave
	    end
	 in 
	    {Record.mapInd ChordSpec
	     fun {$ Feat X}
		case Feat
		of pitchClasses then {Map X TransposePC}
		[] essentialPitchClasses then {Map X TransposePC}
		[] roots then {Map X TransposePC}
		else X
		end
	     end}
	 end
      end
   
      local
   
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
      in
	 /** %% Expects a chord DB entry and returns this entry extended by the feature oneFootedBridgeChordSonance, which specifies a sonance value (dissonance degree) for this chord. The returned sonance is a distorted arithmetric mean of the one-footed bridge distances of all intervals in the given chord, where chords with more pitch classes are rated slightly lower than the actual mean, the more pitch classes there are in a chord the more this distortion is taken into account (an int). 
	 %%
	 %% Note: Sonance is a consonance degree. Lower measures mean a *more* dissonant chord and vice versa. For PartialChordComplexity it is the other way round.
	 %% Obviously, only pitch classes 0-11 are supported.
	 %% */
	 fun {OneFootedBridgeChordSonance ChordSpec}
	    %% Chords with more pitch classes are automatically rated to be more dissonant, and ArityCurve specifies how much so. The higher ArityCurve, the more this is taken into account (at 1.0 it has no effect).
	    ArityCurve = 1.25
	    %% list of sonances for all intervals in chord (all PC combinations)
	    Sonances = {Pattern.mapPairwise ChordSpec.pitchClasses
			fun {$ PC1 PC2}
			   PcInterval = {Abs PC1 - PC2} mod 12
			in
			   OneFootedBridgeData.PcInterval
			end}
	    %% arithmetic mean, weighted by PC cardiality
	    Sonance =  {FloatToInt {IntToFloat {LUtils.accum Sonances Number.'+'}}
			/ {Pow {IntToFloat {Length Sonances}} ArityCurve}}
	 in
	    {Adjoin unit(oneFootedBridgeChordSonance:Sonance)
	     ChordSpec}
	 end
   
      end

      local
   
	 /** %% Edited values of Partch's one-footed bridge (distinguishing between major and minor third etc)
	 %% Higher sonance values mean higher degree of consonance.
	 %% */
	 %% TODO: refine this e.g. using harmonic entropy data (e.g., a fifth is more consonant than a fourth)
	 SonanceData = unit(0: 38
			    1: 5
			    2: 10
			    3: 17
			    4: 22
			    5: 27
			    6: 5
			    7: 27
			    8: 22
			    9: 17
			    10: 10
			    11: 5)
      in
	 /** %% Expects a chord DB entry and returns this entry extended by the feature oneFootedBridgeChordSonance, which specifies a sonance value (dissonance degree) for this chord. The returned sonance is a distorted arithmetric mean of the one-footed bridge distances of all intervals in the given chord, where chords with more pitch classes are rated slightly lower than the actual mean, the more pitch classes there are in a chord the more this distortion is taken into account (an int). 
	 %%
	 %% Note: Sonance is a consonance degree. Lower measures mean a *more* dissonant chord and vice versa. For PartialChordComplexity it is the other way round.
	 %% Obviously, only pitch classes 0-11 are supported.
	 %% */
	 %%
	 %% TODO:
	 %% - Revise function name 
	 fun {TorstensChordSonance ChordSpec}
	    %% Chords with more pitch classes are automatically rated to be more dissonant, and ArityCurve specifies how much so. The higher ArityCurve, the more this is taken into account (at 1.0 it has no effect).
	    ArityCurve = 1.25
	    %% list of sonances for all intervals in chord (all PC combinations)
	    Sonances = {Pattern.mapPairwise ChordSpec.pitchClasses
			fun {$ PC1 PC2}
			   PcInterval = {Abs PC1 - PC2} mod 12
			in
			   SonanceData.PcInterval
			end}
	    %% arithmetic mean, weighted by PC cardiality
	    Sonance =  {FloatToInt {IntToFloat {LUtils.accum Sonances Number.'+'}}
			/ {Pow {IntToFloat {Length Sonances}} ArityCurve}}
	 in
	    {Adjoin unit(torstensChordSonance:Sonance)
	     ChordSpec}
	 end
   
      end

      local
	 /** %% Indices of partials in the harmonic series that are close to the pitch class in question. For example, the pitch class 7 very closely approximates the partial 3.
	 %%
	 %% Data problematic, because certain intervals (e.g., pitch class interval 3, minor third) corresponds to interval that does not involve fundamental of series, namely 6/5, where there is no 1/1 involved. Instead, all data in this record are specifed as interval over 1/1, and so the minor third becomes 19/16, which is of course too complex in a minor triad. Similarly, the fourth becomes 21/16. Nevertheless these data are hopefully suitable for a measure of harmonic stability of chords over the given root. For example, if the lower tone of a fourth would be the root, then that root is harmonically highly unstable. 
	 %% */
	 PC_Partials = unit(0: 1
			    1: 17
			    2: 9
			    3: 19  % 297.51 cent
			    4: 5
			    5: 21  % 470.78 cent
			    6: 11  % 551.32 cent
			    7: 3
			    8: 13  % 840.53 cebt
			    9: 27  % 905.87 cent
			    10: 7
			    11: 15)
      in
	 /** %% A measure of the harmonic stability of a chord: the lower the partial complexity the more the chord consists of pitch classes approximating lower partials of the harmonic series over the root of the chord. For example, the major seventh triad results in a clearly lower measure than the minor triad. Note that PartialChordComplexity does not measure the dissonance degree, use a chord sonance measure for that.
	 %%
	 %% Note: Lower measures mean a *less* complex chord and vice versa. For chord sonance measures it is the other way round.
	 %% Obviously, only pitch classes 0-11 are supported.
	 %%
	 %% The implementation assumes that 0 is the root of the chord (and that this pitch class is present in the chord's pitch classes).
	 %% */
	 %%
	 fun {PartialChordComplexity ChordSpec}
	    Partials = {Map
			%% harmonic mean tends to its lowers values -- PC 0 has therefore been removed
			{LUtils.remove ChordSpec.pitchClasses
			 fun {$ X} X==0 end}
			fun {$ PC} PC_Partials.PC end}
	 % %% arithmetic mean, weighted by PC cardiality
	 % Complexity =  {FloatToInt {IntToFloat {LUtils.accum Partials Number.'+'}}
	 % 		/ {Pow {IntToFloat {Length Partials}} ArityCurve}}
	    %% Harmonic mean mitigates large outliers -- I do not really want that...
	    Complexity = {FloatToInt {GUtils.harmonicMean Partials}*10.0}
	 in
	    {Adjoin unit(partialChordComplexity:Complexity)
	     ChordSpec}
	 end
      end


      PitchesPerOctave = 12
      AccidentalOffset = 2
      %% corresponds to MIDI pitch range 12-127+ (for pitchesPerOctave=12)
      OctaveDomain = 0#9

   in
      
      /** %% Full database declaration defined in this functor. 
      %% */
      DB = {HS.db.makeFullDB
	    unit(pitchesPerOctave: PitchesPerOctave
		 accidentalOffset: AccidentalOffset
		 octaveDomain: OctaveDomain
		 %% TODO:
		 %% OK - translate note name notation of chords into PCs
		 %%   take octavation into account (but for now these all all then reduced to a single octave)
		 %% - transpose chords so that root PC is 0
		 %%
		 %% computing these values takes only a couple of msecs, which can be neclegted (otherwise I would need to move all interval specs and this computation at the compile time of the functor..)
		 chords: {Record.map Chords
			  fun {$ C}
			     {PartialChordComplexity
			      {TorstensChordSonance
			       {OneFootedBridgeChordSonance
				{TransposeSpecTo0 
				 {ReduceToSingleOctave
				  % {HS.db.ratiosInDBEntryToPCs
				   {SymbolicNoteNamesToPCsInDBEntry C HS.pc PitchesPerOctave}
				  % PitchesPerOctave}
				 }
				 PitchesPerOctave}}}}
			  end}
		 scales: Scales
		 intervals: Intervals
		 chordFeatures: [oneFootedBridgeChordSonance
				 torstensChordSonance
				 partialChordComplexity]
		 scaleFeatures: nil
		 intervalFeatures: nil)}

   end

end
