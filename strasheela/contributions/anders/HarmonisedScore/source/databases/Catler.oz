

functor

import
   HS at '../../HarmonisedScore.ozf'
   
export
   GetIntervals
   
define

   /** %% The Jon Catler 24 tone Just Intonation Scale "over and under the 13 limit".
   %% */
   Intervals
   = intervals(interval(interval:1#1
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'unisono')
	       interval(interval:33#32
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'undecimal comma')
	       interval(interval:16#15
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor diatonic semitone')
	       interval(interval:9#8
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'major whole tone')
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
	       interval(interval:128#105
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'septimal neutral third')
	       interval(interval:16#13
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'tridecimal neutral third')
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
	       interval(interval:11#8
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'harmonic augmented fourth')
	       interval(interval:45#32
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'tritone')
	       interval(interval:16#11
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'harmonic diminished fifth')
	       interval(interval:3#2
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'perfect fifth')
	       interval(interval:8#5
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'minor sixth')
	       interval(interval:13#8
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'tridecimal neutral sixth')
	       interval(interval:5#3
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'major sixth')
	       interval(interval:27#16
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'Pythagorean major sixth')
	       interval(interval:7#4
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'harmonic seventh')
	       interval(interval:16#9
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'Pythagorean minor seventh')
	       interval(interval:24#13
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: '')
	       interval(interval:15#8
			%% dissonanceDegree:_
			%% resemblanceWithTradition:_
			comment: 'classic major seventh')
	      )	



   /** %% Returns a database with the Jon Catler 24 tone Just Intonation Scale "over and under the 13 limit" (cp. www.microtonal-synthesis.com/scales.html). For usage in HS, the intervals are rounded to the nearest pitch class interval depending on KeysPerOctave (an int).
   %% */
   fun {GetIntervals KeysPerOctave}
      {Record.map Intervals
       fun {$ X} {HS.db.ratiosInDBEntryToPCs X KeysPerOctave} end}
   end
   
end
