

functor

import
   HS at '../../HarmonisedScore.ozf'
   
export
   GetIntervals
   
define

   /** %% The Lou Harrison 16 tone Just Intonation scale
   %% */
   Intervals
   = intervals(interval(interval:1#1
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'unison')
	       interval(interval:16#15
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor diatonic semitone')
	       interval(interval:10#9
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor whole tone')
	       interval(interval:8#7
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'septimal whole tone')
	       interval(interval:7#6
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'septimal minor third')
	       interval(interval:6#5
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor third')
	       interval(interval:5#4
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'major third')
	       interval(interval:4#3
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'perfect fourth')
	       interval(interval:17#12
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: '2nd septendecimal tritone')
	       interval(interval:3#2
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'perfect fifth')
	       interval(interval:8#5
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor sixth')
	       interval(interval:5#3
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'major sixth')
	       interval(interval:12#7
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'septimal major sixth')
	       interval(interval:7#4
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'harmonic seventh')
	       interval(interval:9#5
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'just minor seventh')
	       interval(interval:15#8
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'classic major seventh')
	      )	



   /** %% Returns a database with Lou Harrison 16 tone Just Intonation scale (cp. www.microtonal-synthesis.com/scales.html). For usage in HS, the intervals are rounded to the nearest pitch class interval depending on KeysPerOctave (an int).
   %% */
   fun {GetIntervals KeysPerOctave}
      {Record.map Intervals
       fun {$ X} {HS.db.ratiosInDBEntryToPCs X KeysPerOctave} end}
   end
   
end
