
/** %% Defines a few 'standard' database entries for 12 pitches per octave..
%% */ 

functor
export
   Chords
   Scales
   Intervals
   PitchesPerOctave
   AccidentalOffset
   OctaveDomain
   db:DB
define

   Chords = chords(chord(pitchClasses:[0 4 7]
				roots:[0]
				dissonanceDegree:2
				comment:'major')
			  chord(pitchClasses:[0 3 7]
				roots:[0] % ? [7]
				dissonanceDegree:3
				comment:'minor'))
   
   Scales = scales(scale(pitchClasses:[0 2 4 5 7 9 11]
			 roots:[0]
			 comment:'major')
		   scale(pitchClasses:[0 2 3 5 7 8 10]
			 roots:[0] 
			 comment:'minorPure')
		   %% !! such extended scale def with 'alternative' scale degrees as 10 or 11 makes correct recognition of scale degree impossible -- better introduce 'alternatives' by explicit accidentals 
% 				    scale(pitchClasses:[0 2 3 5 7 8 9 10 11]
% 					  roots:[0] 
% 					  comment:minor)
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
   
   PitchesPerOctave=12
   AccidentalOffset=2
   %% corresponds to MIDI pitch range 12-127+ (for pitchesPerOctave=12)
   OctaveDomain=0#9

   DB = unit(chordDB:Chords
	     scaleDB:Scales
	     intervalDB:Intervals
	     pitchesPerOctave: PitchesPerOctave
	     accidentalOffset: AccidentalOffset
	     octaveDomain: OctaveDomain)
   
end
