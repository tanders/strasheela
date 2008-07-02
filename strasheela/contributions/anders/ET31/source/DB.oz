
/** %% This functor defines databases for chords, scales and intervals in 31 equal temperament. It is the core of the functor ET31. See the documentation of HS.db.setDB for the meaning of the exported database features. 
%% Internally, database entries are partly defined by ratios (using notation X#Y for X/Y) to make them more comprehensible and portable to other temperaments. Alternatively, chords and scales are notated with conventional symbolic note names (see function ET31.pc). In any case, the databases focus on chords, scales and intervals which are close to just intonation in 31 ET.
%%
%% The naming of of chords can be debatable. Some of the chords I found myself and so their might be no standard name for it. Some terminology I used for naming the chords is introduced below. Note that this terminology is not always used consistently (e.g., the augmented chord [1#1 6#5 36#25] is simply chord 'augmented', not 'augmented triad' or 'geometric augmented').
%%
%% 'otonal' and 'utonal': as established by Partch. However, ratios can be left out, i.e.,  [4/4 4/5 4/7] is utonal even if 4/6 is missing.
%%
%% 'harmonic' is 'otonal', due to convention I sometimes use the term 'harmonic' instead. E.g., 'harmonic dominant seventh'.
%%
%% 'geometric': frequency ratios based on geometric series (e.g., [1#1 6#5 36#25], the augmented chord). A geometric chord is also alway 'otonal' in the sense defined above, but a more complex chord.
%%
%% 'reversed': an chord which exactly reverses some chord (e.g., the utonal equivalent of some otonal chord). A better term might be 'inversed', but that is already used differently..
%%
%% 
%% Please visit the source at ../source/DB.oz or browse/inspect the value of ET31.db.fullDB to read the actual databases. 
%%
%% */

functor 
   
import
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   ET31 at '../ET31.ozf'
   
export   
%    Chords
%    Scales
%    Intervals
%    PitchesPerOctave
%    AccidentalOffset
%    OctaveDomain
   fullDB:DB

%   ToStandardDeclaration
  
define

   %%
   %% TODO:
   %%
   %%  - go through chords list in Scala of just chords: pick chords which you like when they are approximated to 31 ET
   %%  - ?? create chords with more pitches and make some pitches as optional 
   %%  - try whether you like utonal of these chords
   %%  - ?? try combinations for otonal and utonal..
   %%
   %%  - other approaches: create new chords in Scala with the chromatic clavier or the lattrice player
   %%
   %%  - !! proofread all chord roots
   %%
   %%  - !! add chord feature 'gender' (term??), e.g., 1 for otonal, 2 for utonal, 3 for geometric, and 4 for mixed or other
   %%
   %%  - !! root of utonal chords: this is either the common root (e.g. C is root of C minor chord) or 1/1. Should I add an extra feature of the second root -- I would have to add this feature to every chord!  
   %%  

   Chords = chords(%%
		   %% triads
		   %%

		   %% 
		   %% classical triads
		   %%

		   chord(pitchClasses:[6#6 6#5 6#4] % 'C' 'Es' 'G'
			 roots:[6#6] 
%				dissonanceDegree:2
			 comment:'minor')
		   chord(pitchClasses:[4#4 5#4 6#4] % 'C' 'E' 'G'
			 roots:[4#4]
%				dissonanceDegree:2
			 comment:'major')
		   
		   chord(pitchClasses:[1#1 5#4 25#16] % 'C' 'E' 'G#'
			 roots:[1#1]   % ??
%				dissonanceDegree:2
			 comment:'augmented')

		   %% three different diminished triads
		   
		   %% !! nice :) 
		   chord(pitchClasses:[5#5 6#5 7#5] % 'C' 'Eb' 'F#'
			 roots:[5#5]
			 % silentRoots:[4#5]  % 'As'
%				dissonanceDegree:2
			 comment:'harmonic diminished')		   
		   chord(pitchClasses:[7#7 7#6 7#5] % ['C' 'D#' 'F#']
			 roots:[7#7] 
%				dissonanceDegree:2
			 comment:'utonal diminished') % reversed harmonic diminished
		   %% relatively high tuning error of 'tritone'
		   %% (almost 12 cent), but sounds good enough
		   chord(pitchClasses:[1#1 6#5 36#25] % 'C' 'Eb' 'Gb'
			 roots:[1#1]  % ??
%				dissonanceDegree:2
			 comment:'geometric diminished')
		   
		   %%
		   %% less conventional triads
		   %%

		   %% !!
		   chord(pitchClasses:[6#1 7#1 9#1] % 'C' 'Eb;' 'G'
			 roots:[6#1]
			 % silentRoots:[4#1]   % ?? 'F'
%				dissonanceDegree:2
			 comment:'subminor')
		   
		   
% 		   %% same as 'C' 'G' 'Bb;', therefore left out
		   %% !!		   
% 		   chord(pitchClasses:[6#1 7#1 8#1]  % 'C' 'D#' 'F'
% 			 roots:[4#1]   % 'F'
% %				dissonanceDegree:2
% 			 comment:'subminor quartal')
		   
		   %% rather dissonant -- is this characteristic enough?
		   chord(pitchClasses:['C' 'E;' 'G']
			 roots:['C']  % ??
%				dissonanceDegree:2
			 comment:'neutral triad')
		   %% ?? very harsh -- only suitable with more chord tones...
		   %% utonal
		   chord(pitchClasses:['C' 'E|' 'G']  % ?? 1#9 1#7 1#6 
			 roots:['C']
%				dissonanceDegree:2
			 comment:'supermajor')


		   %%
		   %% seventh chords and other tetrads 
		   %% 
		   
		   %% ?? sevenths chords: all these with (i) major seventh, (ii) otonal seventh, (iii) 9#5
		   %% (iv) other third combinations


		   chord(pitchClasses:['C' 'E' 'G' 'Bb']
			 roots:['C']  
%				dissonanceDegree:2
			 comment:'dominant 7th')
		   chord(% pitchClasses:['C' 'Eb' 'Gb' 'Bb']
			 pitchClasses:['C' 'Eb' 'G' 'A']
			 roots:['C']  % ??
%				dissonanceDegree:2
			 % comment:'reversed dominant seventh'
			 comment:'minor 6th')
		   %% !!
		   %% mind tiny difference to reversed dominant seventh
		   %% reversed form of this chord is 'C' 'Fb' 'G' 'Bb' -- un-usable
		   chord(% pitchClasses:['C' 'Eb' 'F#' 'Bb'] % 5:6:7:9
			 pitchClasses:['C' 'D#' 'G' 'A'] % 5:6:7:9
			 roots:['C']
			 % silentRoots:['F']  
%				dissonanceDegree:2
%			 comment:'harmonic halve-diminished seventh'
			 comment:'subminor 6th')
		   %% !!
		   chord(pitchClasses:['C' 'E' 'G' 'Bb;']
			 roots:['C']  
%				dissonanceDegree:2
			 comment:'harmonic 7th')
		   %% !!!
		   chord(pitchClasses:['C' 'D#' 'F#' 'A#']
			 roots:['D#'] % 'C'
			 % silentRoots:['G#']
%				dissonanceDegree:2
%			 comment:'reversed harmonic dominant seventh'
			 comment:'subharmonic 6th'
			)
		   %% !!!!
		   %% non-reversable chord (reversed chord is same chord)
		   chord(pitchClasses:['C' 'E' 'F#' 'A#'] % [1#1 5#4 7#5 7#4] 
			 roots:['C']  % ??
%				dissonanceDegree:2
			 comment:'mix of plain and reversed harmonic dominant 7th')
		   
		   
		   %% same as minor with minor seventh, but different root
		   chord(pitchClasses:['C' 'E' 'G' 'A']
			 roots:['C']  
%				dissonanceDegree:2
			 comment:'sixte ajoutee')
		   %% same as sixte ajoutee, but different root
		   %% non-reversable chord
		   chord(pitchClasses:['C' 'Eb' 'G' 'Bb']
			 roots:['C']  
%				dissonanceDegree:2
			 comment:'minor 7th')

		   
		   chord(pitchClasses:[1#1 3#1 5#1 15#1]
			 roots:[1#1]  
%				dissonanceDegree:2
			 comment:'major 7th')

		   chord(pitchClasses:[1#1 3#1 5#1 15#1 9#1]
			 roots:[1#1]  
%				dissonanceDegree:2
			 comment:'major 9th')
		   chord(pitchClasses:[1#1 3#1 5#1 15#1 5#3]
			 roots:[1#1]  
%				dissonanceDegree:2
			 comment:'minor 9th')


		   
		   %%
		   %% added after Doty: TODO: double-check that there are no doublicates here to the above
		   %%
		   
		   chord(pitchClasses:[1#1 3#1 5#1 7#1 9#1]
			 roots:[1#1]  
%				dissonanceDegree:2
			 comment:'harmonic 9th')

		   chord(pitchClasses:[3#1 5#1 7#1 9#1]
			 roots:[3#1]  
%				dissonanceDegree:2
			 comment:'harmonic half-diminished 7th')
		   %% !! 
		   chord(pitchClasses:[1#1 3#1 7#1]
			 roots:[1#1]  
%				dissonanceDegree:2
			 comment:'4-6-7')
		   chord(pitchClasses:[5#1 7#1 9#1]
			 roots:[5#1]  
%				dissonanceDegree:2
			 comment:'5-7-9')
		   chord(pitchClasses:[1#1 3#1 5#1 9#1]
			 roots:[1#1]  
%				dissonanceDegree:2
			 comment:'added-2nd')


		   chord(pitchClasses:[2#1 4#3 8#7]
			 roots:[4#3]  
%				dissonanceDegree:2
			 comment:'subharmonic 4-6-7')

		   
		   chord(pitchClasses:[3#1 7#1 9#1 21#1]
			 roots:[3#1]  
%				dissonanceDegree:2
			 comment:'subminor 7th')
		   
		   chord(pitchClasses:[9#1 7#1 27#1 21#1]
			 roots:[7#1] %% ??  
%				dissonanceDegree:2
			 comment:'submajor 7th')
		   
		   %%
		   %% more chords (not all of these are really suitable) 
		   %% http://en.wikipedia.org/wiki/Septimal_meantone_temperament#Chords_of_septimal_meantone
		   %%
		   %% tristan chord: 
		   %%

		   %% NOTE: the orig version (transposed) is 'Bbb' 'Eb' 'G' 'C', which is much better than the [enge Lage] of this pitch class set 
		   chord(pitchClasses:['C' 'Eb' 'G' 'Bbb']
			 roots:['C']  
%				dissonanceDegree:2
			   comment:'Tristan chord')
% 		   chord(pitchClasses:[]
% 			 roots:['C']  
% %				dissonanceDegree:2
% 			   comment:'')
% 		   chord(pitchClasses:[]
% 			 roots:['C']  
% %				dissonanceDegree:2
% 			   comment:'')


		  )

   %% 
   Scales = scales(scale(pitchClasses:[1#1 9#8 5#4 4#3 3#2 5#3 15#8]
			 roots:[1#1]
			 comment:'major')

		   %% see Scale mode list of 31 ET for more minor variants
		   %% also, scales like "intense diatonic dorian"
		   scale(pitchClasses:['C' 'D' 'Eb' 'F' 'G' 'Ab' 'Bb']
			 roots:['C']
			 comment:'natural minor')
		   scale(pitchClasses:['C' 'D' 'Eb' 'F' 'G' 'Ab' 'B']
			 roots:['C']
			 comment:'harmonic minor')

		   %% !!
		   %% Similar scales in Scale, e.g., "soft diatonic dorian"
		   %%
		   %% Scale consists of 2 sets of 3-limit intervals which are related by a 7/4. Together, they approximate minor.
		   scale(pitchClasses:['C' 'D' 'D#' 'F' 'G' 'G#' 'A#']
			 roots:['C']
			 comment:'septimal natural minor')  %% name from Scale (where septimal is is double quotes..)

		   %% TODO: there are other chromatic scale variants possible
		   scale(pitchClasses:['C' 'C#' 'D' 'Eb' 'E' 'F' 'F#' 'G' 'G#' 'A' 'Bb' 'B']
% 			 roots:['C' 'C#' 'D' 'Eb' 'E' 'F' 'F#' 'G' 'G#' 'A' 'Bb' 'B'] % TODO: ??
			 roots:['C'] % TODO: ??
			 comment:'Meantone Chromatic')

		   
		   %% !!??
		   %% Hm, interesting. Not sure yet, what to make of it..
		   scale(pitchClasses:['C' 'Db' 'Eb' 'E' 'F#' 'G' 'A' 'Bb']
			 roots:['C'] %% ??
			 comment:'octatonic' % NOTE: name nicht eindeutig, aber fuer 31 ET vielleicht schon..
			)

		   %% 
		   scale(pitchClasses:['C' 'Db' 'D#' 'E' 'F' 'G' 'Ab' 'A#' 'B']
			 roots:['C'] %% ??
			 comment:'Hahn pentachordal')
		   %% !!!! septimal scale o-tonal and u-tonal
		   scale(pitchClasses:['C' 'Db' 'D|' 'E' 'F' 'G' 'Ab' 'A#' 'B']
			 roots:['C'] %% ??
			 comment:'Hahn symmetric pentachordal')

		   
		   %% high tuning errors of 11#8 (9.4 cent) and 13#8 (11 cent!)
		   %% is this good enough anyway? 11#8 tuning error in 12ET is ~50 cent!
		   chord(pitchClasses:[8#8 9#8 10#8 11#8 12#8 13#8 14#8 15#8]
			 roots:['C']  
%				dissonanceDegree:2
			   comment:'harmonic series') % name nicht eindeutig


		   %% Decatonic scale with all 6 commas
		   %% NOTE: 4#3 is a comma away from 21#16, so I may have the latter instead! 
		   scale(pitchClasses:[1#1 21#20 15#14 7#6 25#21 5#4 21#16 4#3
				       7#5 10#7 3#2 5#3 7#4 25#14 15#8 40#21]
			 roots:[1#1] 
			   comment:'full dynamic symmetrical major')
		   
		  )

   %%
   %% TODO:
   %%
   %% - additional interval features like their dissonance degree, harmonic distance etc. -- use figures you can get from Scala..
   %%

   %% Interval specs are given as ratios which are relatively simple
   %% and close to the pitch class in question. Alternative ratios are
   %% in comments. These are ordered: progressing to the right means
   %% greater accuracy of approximation and greater complexity.
   %% Source: http://www.tonalsoft.com/enc/number/31edo.aspx (?? and Scala?)
   Intervals = intervals(interval(interval:1#1
%				  dissonanceDegree:0
				  comment:'unison')
			 %% !! highly complex interval
			 interval(interval:42#41 % 43:42 , 44:43 , 45:44 , 181:177
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:25#24 % (~6-7 cent larger than 25:25), 22:21 , 23:22 , 160:153
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:16#15 % (~4-5 cent larger than 16#15), 15:14 , 31:29 , 77:72 , 185:173 , 262:245
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:11#10 % 12:11 , 35:32 , 152:139 , 187:171
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:9#8 % 19:17 , 85:76 , 104:93
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:8#7 % 223:195 , 231:202
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:7#6 % 69:59 , 283:242 , 352:301
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:6#5 % 55:46 , 116:97
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:11#9 % 192:157
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:5#4
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:9#7 % 23:18 , 55:43 , 78:61 , 133:104
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:17#13
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:4#3 % 111:83
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:11#8 % 15:11 , 26:19 , 67:49 , 93:68 , 253:185
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:7#5 % 186:133
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:10#7 % 123:86 , 133:93
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:19#13 % 117:80 , 253:173 , 370:253
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:3#2 % 166:111
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:26#17
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 %% NOTE: better use 25:16??
			 interval(interval:11#7 % 25:16 , 61:39 , 208:133
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:8#5 % 435:272 , 443:277
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:18#11 % 157:96
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:5#3 % 97:58
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:12#7 % 53:31 , 65:38, 118:69 , 183:107 , 301:176
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:7#4 % 397:227, 128:225 (2^7 : 3^2*5^2)
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:9#5 % 25:14 , 34:19 , 59:33 , 93:52
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:11#6 % 64:35 , 139:76 , 342:187 , 481:263
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:15#8 % 43:23 , 101:54 , 245:131
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 interval(interval:21#11 % 44:23 , 153:80
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			 %% !! highly complex interval
			 interval(interval:43#22 % 45:23 , 88:45 , 133:68 , 221:113 , 575:294
%				  dissonanceDegree:0
%				  comment:'unison'
				 )
			)

   
   PitchesPerOctave=31
   AccidentalOffset=4
   %% corresponds to MIDI pitch range 12-127+ (for pitchesPerOctave=12)
   OctaveDomain=0#9

   
   local
      /** %% Only transform atoms (e.g. 'C#'), but leave integers (PCs) and records (ratios, e.g., 1#1) untouched.
      %% */
      fun {Transform MyPitch}
	 if {IsAtom MyPitch} then {ET31.pc MyPitch} else MyPitch end
      end
   in
      /** %% [Aux def] Expects a chord or scale declaration, and in case it contains symbolic notes names, these are replaced by their corresponding 31 ET pitch class.  
      %% */
      fun {ToStandardDeclaration Decl}
	 {Record.mapInd Decl
	  fun {$ Feat X}
	     case Feat of pitchClasses then
		{Map X Transform}
	     [] roots then
		{Map X Transform}
	     else X
	     end
	  end}
      end
   end

  

   /** %% Full database declaration defined in this functor. 
   %% */
   DB = unit(chordDB:{Record.map Chords
		      fun {$ X}
			 {HS.db.ratiosInDBEntryToPCs {ToStandardDeclaration X}
			  PitchesPerOctave}
		      end}
	     scaleDB:{Record.map Scales
		      fun {$ X}
			 {HS.db.ratiosInDBEntryToPCs {ToStandardDeclaration X}
			  PitchesPerOctave}
		      end}
	     intervalDB:{Record.map Intervals
			 fun {$ X} {HS.db.ratiosInDBEntryToPCs X PitchesPerOctave} end}
	     pitchesPerOctave: PitchesPerOctave
	     accidentalOffset: AccidentalOffset
	     octaveDomain: OctaveDomain)
   
end

