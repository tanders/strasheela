

functor

import
   HS at '../../HarmonisedScore.ozf'
   
export
   GetIntervals
   
define

   /** %% The Ben Johnston 25 note just enharmonic scale.
   %% */
   Intervals
   = intervals(interval(interval:1#1
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'unisono')
	       interval(interval:25#24
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'classic chromatic semitone')
	       interval(interval:135#128
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'major limma, large chroma')
	       interval(interval:16#15
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor diatonic semitone')
	       interval(interval:10#9
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor whole tone')
	       interval(interval:9#8
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'major whole tone')
	       interval(interval:75#64
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'classic augmented second')
	       interval(interval:6#5
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor third')
	       interval(interval:5#4
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'major third')
	       interval(interval:81#64
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'Pythagorean major third')
	       interval(interval:32#25
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'classic diminished fourth')
	       interval(interval:4#3
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'perfect fourth')
	       interval(interval:27#20
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'acute fourth')
	       interval(interval:45#32
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'tritone')
	       interval(interval:36#25
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'classic diminished fifth')
	       interval(interval:3#2
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'perfect fifth')
	       interval(interval:25#16
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'classic augmented fifth')
	       interval(interval:8#5
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor sixth')
	       interval(interval:5#3
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'major sixth')
	       interval(interval:27#16
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'Pythagorean major sixth')
	       interval(interval:225#128
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'augmented sixth')
	       interval(interval:16#9
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'Pythagorean minor seventh')
	       interval(interval:5#9
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'just minor seventh')
	       interval(interval:15#8
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'classic major seventh')
	       interval(interval:48#25
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'classic diminished octave')
	      )	



   /** %% Returns a database with the Ben Johnston 25 note just enharmonic scale (cf. www.microtonal-synthesis.com/scales.html). For usage in HS, the intervals are rounded to the nearest pitch class interval depending on KeysPerOctave (an int).
   %% */
   fun {GetIntervals KeysPerOctave}
      {Record.map Intervals
       fun {$ X} {HS.db.ratiosInDBEntryToPCs X KeysPerOctave} end}
   end
   
end
