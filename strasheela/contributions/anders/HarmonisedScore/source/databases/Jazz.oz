
/** %% This database contains a chord database as defined by \cite{Burbat:HarmonikJazz:1988}.
%%
%% All databases here are for 12 pitches per octave.
%%
%% */ 


functor
import
   Default at 'Default.ozf'
   
export
   Vierklaenge
   Scales
   PitchesPerOctave
   AccidentalOffset
   BurbatVierklaenge
   
define

   /** %% [Vierklaenge] cited from \cite[p. 172f]{Burbat:HarmonikJazz:1988},
   %% Use German term [Vierklaenge], because English term SeventhChords is not fully suitable (chord with 6, e.g., [0 4 7 9] is no seventh chord in case 0 is understood as root).
   %% */
   Vierklaenge = chords(chord(pitchClasses:[0 4 7 11]
			      roots:[0]
			      % comment:'with major 7'
			      comment:'"maj 7"')
			%% same as minor with 7 ..
%			chord(pitchClasses:[0 4 7 9]
%			      roots:[0]
%			      % comment:'with 6'
%			      comment:'6')
			chord(pitchClasses:[0 4 7 10]
			      roots:[0]
			      % comment:'with 7'
			      comment:'7')
			chord(pitchClasses:[0 3 7 10]
			      roots:[0 3]
			      % comment:'minor with 7'
			      comment:'"min 7"')
			chord(pitchClasses:[0 3 6 10]
			      roots:[0]
			      % comment:'diminished with 7'
			      comment:'"min 7" "(b5)"')
			chord(pitchClasses:[0 6 3 9]
			      roots:[0]
			      % comment:'diminished seventh'
			      comment:'o')
			chord(pitchClasses:[0 4 8 11]
			      roots:[0]
			      % comment:'augmented with major 7'
			      comment:'"maj 7" "(#5)"')
			chord(pitchClasses:[0 4 8 10]
			      roots:[0]
			      % comment:'augmented with 7'
			      comment:'7 "(#5)"')
			chord(pitchClasses:[0 4 6 10]
			      roots:[0]
			      comment:'7 "(b5)"')
			chord(pitchClasses:[0 5 7 10]
			      roots:[0]
			      comment:'7 "(sus 4)"'))

   /** %% 
   %% */
   Scales = scales(scale(pitchClasses:[0 2 4 5 7 9 11]
			    roots:[0 2 4 5 7 9] % !!?? (root 11 very rare)
			    comment:'major and its modi')
/*
		      scale(pitchClasses:[0 2 4 7 9]
			    roots:[0] % !!??
			    comment:'pentatonic')
		      */
		     )

   PitchesPerOctave=12
   AccidentalOffset=2
   
   /** %% !! DB contains only [Vierklaenge]
   %% */
   BurbatVierklaenge = unit(chordDB: Vierklaenge
			    scaleDB: Scales
			    intervalDB: Default.intervals
			    pitchesPerOctave: PitchesPerOctave
			    accidentalOffset: AccidentalOffset
			    %% octaveDomain: OctaveDomain
			   )
   
end
