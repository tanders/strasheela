

functor

import
   HS at '../../HarmonisedScore.ozf'
   
export
   GetIntervals
   Get11LimitDiamondChords Get7LimitDiamondChords Get5LimitDiamondChords
   
define

   /** %% The two chords which constitute the 11-limit tonality diamond. All other <code>6*6-2=34</code> chords of this diamond are transpositions of these two by the proportions of the other.
   %% */
   DiamondChords_11Limit = chords(chord(pitchClasses:[1#1 9#8 5#4 11#8 3#2 7#4]
					roots:[1#1]
					comment:"Otonality")
				  chord(pitchClasses:[1#1 16#9 8#5 16#11 4#3 8#7]
					roots:[1#1 4#3]  % !! roots
					comment:"Utonality"))
   
   DiamondChords_7Limit = chords(chord(pitchClasses:[1#1 5#4 3#2 7#4]
					roots:[1#1]
					comment:"Otonality")
				  chord(pitchClasses:[1#1 8#5 4#3 8#7]
					roots:[1#1 4#3]  % !! roots
					comment:"Utonality"))
   
   DiamondChords_5Limit = chords(chord(pitchClasses:[1#1 5#4 3#2]
					roots:[1#1]
					comment:"Otonality")
				  chord(pitchClasses:[1#1 8#5 4#3]
					roots:[1#1 4#3]  % !! roots
					comment:"Utonality"))

   
   /** %% Returns a database with the two chords which constitute the 11-limit tonality diamond. All other <code>6*6-2=34</code> chords of this diamond are transpositions of these two by the proportions of the other.
   %% For usage in HS, each chord's pitchclasses and root are rounded to the nearest pitch class depending on KeysPerOctave (an int).
   %%
   %% NB: two possible roots are specified for the Utonality chords: 1/1 (the 'mirror-root') and 4/3 (following convention and Hindemiths root definition). For example, in C-minor 1/1 is g and 4/3 is c. 
   %% */
   fun {Get11LimitDiamondChords KeysPerOctave}
      {Record.map DiamondChords_11Limit
       fun {$ X}
	  {HS.db.ratiosInDBEntryToPCs X KeysPerOctave}
       end}
   end
   fun {Get7LimitDiamondChords KeysPerOctave}
      {Record.map DiamondChords_7Limit
       fun {$ X}
	  {HS.db.ratiosInDBEntryToPCs X KeysPerOctave}
       end}
   end
   fun {Get5LimitDiamondChords KeysPerOctave}
      {Record.map DiamondChords_5Limit
       fun {$ X}
	  {HS.db.ratiosInDBEntryToPCs X KeysPerOctave}
       end}
   end

   /** %% The Partch intervals. The dissonance degrees are set (approximately) according to the one-footed bridge (cf. Partch [1974]).
   %% */
   Intervals
   = intervals(interval(interval:1#1
			dissonanceDegree:0
			limit:1
			%% resemblanceWithTradition
			comment: 'unison')
	       interval(interval:81#80
			dissonanceDegree:8
			limit:5
			%% resemblanceWithTradition
			comment: 'syntonic (didymic) comma')
	       interval(interval:33#32
			dissonanceDegree:8
			limit:11
			%% resemblanceWithTradition
			comment:'undecimal comma')
	       interval(interval:21#20
			dissonanceDegree:8
			limit:7
			%% resemblanceWithTradition
			comment:'minor semitone')
	       interval(interval:16#15
			dissonanceDegree:8
			limit:5
			%% resemblanceWithTradition
			comment:'minor diatonic semitone')
	       interval(interval:12#11
			dissonanceDegree:7
			limit:11
			%% resemblanceWithTradition
			comment:'3/4-tone, undecimal neutral second')
	       interval(interval:11#10
			dissonanceDegree:7
			limit:11
			%% resemblanceWithTradition
			comment:'4/5-tone')
	       interval(interval:10#9
			dissonanceDegree:6
			limit:5
			%% resemblanceWithTradition
			comment:'minor whole tone')
	       interval(interval:9#8
			dissonanceDegree:6
			limit:3
			%% resemblanceWithTradition
			comment:'major whole tone')
	       interval(interval:8#7
			dissonanceDegree:4
			limit:7
			%% resemblanceWithTradition
			comment:'septimal whole tone')
	       interval(interval:7#6
			dissonanceDegree:4
			limit:7
			%% resemblanceWithTradition
			comment:'septimal minor third')
	       interval(interval:32#27
			dissonanceDegree:8
			limit:3
			%% resemblanceWithTradition
			comment:'Pythagorean minor third')
	       interval(interval:6#5
			dissonanceDegree:2 % same as 5/4
			limit:5
			%% resemblanceWithTradition
			comment:'minor third')
	       interval(interval:11#9
			dissonanceDegree:6
			limit:11
			%% resemblanceWithTradition
			comment:'undecimal neutral third')
	       interval(interval:5#4
			dissonanceDegree:2
			limit:5
			%% resemblanceWithTradition
			comment:'major third')
	       interval(interval:14#11
			dissonanceDegree:6
			limit:11
			%% resemblanceWithTradition
			comment:'')
	       interval(interval:9#7
			dissonanceDegree:5
			limit:7
			%% resemblanceWithTradition
			comment:'septimal major third')
	       interval(interval:21#16
			dissonanceDegree:8
			limit:7
			%% resemblanceWithTradition
			comment:'narrow fourth')
	       interval(interval:4#3
			dissonanceDegree:1 % always as complementary interval (is this OK?)
			limit:3
			%% resemblanceWithTradition
			comment:'perfect forth')
	       interval(interval:27#20
			dissonanceDegree:8
			limit:5
			%% resemblanceWithTradition
			comment:'acute fourth')
	       interval(interval:11#8
			dissonanceDegree:6
			limit:11
			%% resemblanceWithTradition
			comment:'harmonic augmented fourth')
	       interval(interval:7#5
			dissonanceDegree:4
			limit:7
			%% resemblanceWithTradition
			comment:'septimal tritone')
	       interval(interval:10#7
			dissonanceDegree:4
			limit:7
			%% resemblanceWithTradition
			comment:'Euler\'s tritone')
	       interval(interval:16#11
			dissonanceDegree:6
			limit:11
			%% resemblanceWithTradition
			comment:'harmonic diminished fifth')
	       interval(interval:40#27
			dissonanceDegree:8
			limit:5
			%% resemblanceWithTradition
			comment:'narrow fifth')
	       interval(interval:3#2
			dissonanceDegree:1
			limit:3
			%% resemblanceWithTradition
			comment:'perfect fifth')
	       interval(interval:32#21
			dissonanceDegree:8
			limit:7
			%% resemblanceWithTradition
			comment:'wide fifth')
	       interval(interval:14#9
			dissonanceDegree:5
			limit:7
			%% resemblanceWithTradition
			comment:'septimal minor sixth')
	       interval(interval:11#7
			dissonanceDegree:6
			limit:11
			%% resemblanceWithTradition
			comment:'')
	       interval(interval:8#5
			dissonanceDegree:3
			limit:5
			%% resemblanceWithTradition
			comment:'minor sixth')
	       interval(interval:18#11
			dissonanceDegree:6
			limit:11
			%% resemblanceWithTradition
			comment:'undecimal neutral sixth')
	       interval(interval:5#3
			dissonanceDegree:3
			limit:5
			%% resemblanceWithTradition
			comment:'major sixth')
	       interval(interval:27#16
			dissonanceDegree:8
			limit:3
			%% resemblanceWithTradition
			comment:'Pythagorean major sixth')
	       interval(interval:12#7
			dissonanceDegree:4
			limit:7
			%% resemblanceWithTradition
			comment:'septimal major sixth')
	       interval(interval:7#4
			dissonanceDegree:4
			limit:7
			%% resemblanceWithTradition
			comment:'harmonic seventh')
	       interval(interval:16#9
			dissonanceDegree:6
			limit:3
			%% resemblanceWithTradition
			comment:'Pythagorean minor seventh')
	       interval(interval:9#5
			dissonanceDegree:6
			limit:5
			%% resemblanceWithTradition
			comment:'just minor seventh')
	       interval(interval:20#11
			dissonanceDegree:7
			limit:11
			%% resemblanceWithTradition
			comment:'')
	       interval(interval:11#6
			dissonanceDegree:7
			limit:11
			%% resemblanceWithTradition
			comment:'21/4-tone, undecimal neutral seventh')
	       interval(interval:15#8
			dissonanceDegree:8
			limit:5
			%% resemblanceWithTradition
			comment:'classic major seventh')
	       interval(interval:40#21
			dissonanceDegree:8
			limit:7
			%% resemblanceWithTradition
			comment:'')
	       interval(interval:64#33
			dissonanceDegree:8
			limit:11
			%% resemblanceWithTradition
			comment:'')
	       interval(interval:160#81
			dissonanceDegree:8
			limit:5
			%% resemblanceWithTradition
			comment:'octave - syntonic (didymic) comma')
	      )

   /** %% Returns a database with the Partch intervals. For usage in HS, the intervals are rounded to the nearest pitch class interval depending on KeysPerOctave (an int).
   %% */
   fun {GetIntervals KeysPerOctave}
      {Record.map Intervals
       fun {$ X}
	  {HS.db.ratiosInDBEntryToPCs X KeysPerOctave}
       end}
   end
   
end
