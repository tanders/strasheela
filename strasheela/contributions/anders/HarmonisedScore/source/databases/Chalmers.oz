

functor

import
   HS at '../../HarmonisedScore.ozf'
   
export
   GetIntervals
   
define

   /** %% The John Chalmers 19 tone Just Intonation scale
   %% */
   Intervals
   = intervals(interval(interval:1#1
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'unison')
	       interval(interval:21#20
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor semitone')
	       interval(interval:16#15
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor diatonic semitone')
	       interval(interval:9#8
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'major whole tone')
	       interval(interval:7#6
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'septimal minor third')
	       interval(interval:6#5
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor third ')
	       interval(interval:5#4
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'major third')
	       interval(interval:21#16
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'narrow fourth')
	       interval(interval:4#3
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'perfect fourth')
	       interval(interval:7#5
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'septimal tritone')
	       interval(interval:35#24
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'septimal diminished fifth')
	       interval(interval:3#2
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'perfect fifth')
	       interval(interval:63#40
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: '')
	       interval(interval:8#5
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor sixth')
	       interval(interval:5#3
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'major sixth')
	       interval(interval:7#4
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'harmonic seventh')
	       interval(interval:9#5
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'just minor seventh')
	       interval(interval:28#15
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'grave major seventh')
	       interval(interval:63#32
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'octave - septimal comma')
	      )	



   /** %% Returns a database with John Chalmers 19 tone Just Intonation scale (cp. www.microtonal-synthesis.com/scales.html). For usage in HS, the intervals are rounded to the nearest pitch class interval depending on KeysPerOctave (an int).
   %% */
   fun {GetIntervals KeysPerOctave}
      {Record.map Intervals
       fun {$ X} {HS.db.ratiosInDBEntryToPCs X KeysPerOctave} end}
   end
   
end
