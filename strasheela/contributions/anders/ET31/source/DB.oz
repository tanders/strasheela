
/** %% This functor defines databases for chords, scales and intervals in 31 equal temperament. It is the core of the functor ET31. See the documentation of HS.db.setDB for the meaning of the exported database features. 
%% Internally, database entries are partly defined by ratios (using notation X#Y for X/Y) to make them more comprehensible and portable to other temperaments. Alternatively, chords and scales are notated with conventional symbolic note names (see function ET31.pc). In any case, the databases focus on chords, scales and intervals which are close to just intonation in 31 ET.
%%
%% (Most of) The database entries can be read in common music notation at
%% http://cmr.soc.plymouth.ac.uk/tanders/StrasheelaExample/ET31/ET31-allIntervals.pdf
%% http://cmr.soc.plymouth.ac.uk/tanders/StrasheelaExample/ET31/ET31-all-chords.pdf
%% http://cmr.soc.plymouth.ac.uk/tanders/StrasheelaExample/ET31/ET31-all-scales.pdf
%% Please visit the source at ../source/DB.oz or browse/inspect the value of ET31.db.fullDB to read the actual databases. 
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
%%

%%
%% Chord name abbrevations adopted from Scala (see Scala file chordnam.par, which has been used for creating this database)  
%%
%% ASS stands for Anomalous Saturated Suspension.
%% BP stands for Bohlen-Pierce.
%% NM stands for Neo-Medieval; they were provided by Margo Schulter. This
%% chord notation was inspired by the "partitions" of Jacobus of Liège, 
%% specifying first the outer interval of the sonority, and then the adjacent
%% intervals in ascending order, cf.
%% outer|lower-upper or outer|lower-middle-upper
%%
%%
%% Note: in the chord DB, the following entries only differ in their root:
%% - 'sixte ajoutee' and 'minor 7th'
%% - 'minor 9th' and 'major 7th added 6th'
%% - 'subminor 7th' and 'supermajor added 6th'
%%
%% */


functor 
   
import
%    GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
%    LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
%    Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
%    MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   ET31 at '../ET31.ozf'
   
export   
%    Chords
%    Scales
%    Intervals
%    PitchesPerOctave
%    AccidentalOffset
%    OctaveDomain
   MakeFullDB
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
			 essentialPitchClasses:[6#6 6#5]
%				dissonanceDegree:2
			 comment:'minor')
		   chord(pitchClasses:[4#4 5#4 6#4] % 'C' 'E' 'G'
			 roots:[4#4]
			 essentialPitchClasses:[4#1 5#1]
%				dissonanceDegree:2
			 comment:'major')
		   
		   chord(pitchClasses:[1#1 5#4 25#16] % 'C' 'E' 'G#'
			 roots:[1#1]   % ??
			 essentialPitchClasses:[1#1 5#4 25#16]
%				dissonanceDegree:2
% 			 comment:'augmented'
% 			 comment:unit(name:'augmented')
			 comment:unit(name:['augmented' 'augmented triad'])
			)

		   %% three different diminished triads
		   
		   %% !! nice :) 
		   chord(pitchClasses:[5#5 6#5 7#5] % 'C' 'Eb' 'F#'
			 roots:[5#5]
			 essentialPitchClasses:[5#5 6#5 7#5]
			 % silentRoots:[4#5]  % 'As'
%				dissonanceDegree:2
			 comment:'harmonic diminished')		   
		   chord(pitchClasses:[7#7 7#6 7#5] % ['C' 'D#' 'F#']
			 roots:[7#7] 
			 essentialPitchClasses:[7#7 7#6 7#5]
%				dissonanceDegree:2
			 comment:'utonal diminished') % reversed harmonic diminished
		   %% relatively high tuning error of 'tritone'
		   %% (almost 12 cent), but sounds good enough
		   chord(pitchClasses:[1#1 6#5 36#25] % 'C' 'Eb' 'Gb'
			 roots:[1#1]  % ??
			 essentialPitchClasses:[1#1 6#5 36#25]
%				dissonanceDegree:2
			 comment:'geometric diminished')
		   
		   %%
		   %% less conventional triads
		   %%

		   %% !!
		   chord(pitchClasses:[6#1 7#1 9#1] % 'C' 'Eb;' 'G'
			 roots:[6#1]
			 essentialPitchClasses:[6#1 7#1]
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
			 essentialPitchClasses:['C' 'E;']
%				dissonanceDegree:2
			 comment:'neutral triad')
		   %% ?? very harsh -- only suitable with more chord tones...
		   %% utonal
		   chord(pitchClasses:['C' 'E|' 'G']  % ?? 1#9 1#7 1#6 
			 roots:['C']
			 essentialPitchClasses:['C' 'E|']
%				dissonanceDegree:2
			 comment:'supermajor')


		   %%
		   %% seventh chords and other tetrads 
		   %% 
		   
		   %% ?? sevenths chords: all these with (i) major seventh, (ii) otonal seventh, (iii) 9#5
		   %% (iv) other third combinations


		   
		   %%
		   %% added after Doty: TODO: double-check that there are no doublicates here to the chords above and below
		   %%

		   %% !! 
		   chord(pitchClasses:[1#1 3#1 7#1]
			 roots:[1#1]
			 essentialPitchClasses:[1#1 3#1 7#1]
%				dissonanceDegree:2
			 comment:'4-6-7')
		   chord(pitchClasses:[5#1 7#1 9#1]
			 roots:[5#1]
			 essentialPitchClasses:[5#1 7#1 9#1]
%				dissonanceDegree:2
			 comment:'5-7-9')
		   chord(pitchClasses:[1#1 3#1 5#1 9#1]
			 roots:[1#1]
			 essentialPitchClasses:[1#1 3#1 5#1 9#1]
%				dissonanceDegree:2
			 comment:'added-2nd')


		   chord(pitchClasses:[2#1 4#3 8#7]
			 roots:[4#3]
			 essentialPitchClasses:[2#1 4#3 8#7]
%				dissonanceDegree:2
			 comment:'subharmonic 4-6-7')

		
		   chord(pitchClasses:[9#1 7#1 27#1 21#1]
			 roots:[7#1] %% ??
			 essentialPitchClasses:[9#1 7#1 27#1 21#1]
%				dissonanceDegree:2
			 comment:'submajor 7th')
		   


		   %%
		   %% From Scala chord database
		   %%

		   %%
		   %% tetrads 
		   %%
		   
		   chord(pitchClasses:[3#1 9#1 11#1 33#1] % C G B; F|
			 roots:[3#1] %% 
			 essentialPitchClasses:[3#1 9#1 11#1 33#1]
%				dissonanceDegree:2
			 comment:'11-limit ASS')
		   chord(pitchClasses:[4#1 5#1 6#1 7#1] % C E G Bb;
			 roots:[4#1] %% ??
			 essentialPitchClasses:[4#1 5#1 7#1] %% ??
%				dissonanceDegree:2
			   comment:unit(name:['harmonic 7th']))
		   %% TODO: add pitches
		   chord(pitchClasses:[5#1 7#1 15#1 35#1] % C F# G A#
			 roots:[5#1] %% ??
			 essentialPitchClasses:[5#1 7#1 15#1 35#1]
%				dissonanceDegree:2
			 comment:'15-limit ASS 2')
		   %% !! 
		   %% harmonic 9th without root (F)
		   %%
		   %% mind tiny difference to reversed dominant seventh
		   %% reversed form of this chord is 'C' 'Fb' 'G' 'Bb' -- un-usable
		   %%
		   %% also [3#1 5#1 7#1 9#1]
		   chord(pitchClasses:[6#1 7#1 9#1 10#1] % C D# G A, same as 'C' 'Eb' 'F#' 'Bb' 
			 roots:[6#1] %% 
			 % silentRoots:['F']  
			 essentialPitchClasses:[6#1 7#1 10#1]
%				dissonanceDegree:2
			 comment:unit(name:['subminor 6th' 'harmonic half-diminished 7th'])
			    )
		   %% harmonic 11 without root (F)
		   chord(pitchClasses:[6#1 7#1 9#1 11#1] % C D# G B;
			 roots:[6#1] %% 
			 essentialPitchClasses:[6#1 7#1 9#1 11#1]
%				dissonanceDegree:2
			 comment:'undecimal subminor 7th')
		   %% 12:15:21:28 Hendrix Chord (Erlich)
		   %% Contrast: 4:10:14:19  Hendrix Chord (Monzo)
		   %%
		   %% 12#1 15#1 21#1 28#1 Hendrix Chord is same as 3#1 7#1 15#1 21#1 '15-limit ASS 1'
		   chord(pitchClasses:[12#1 15#1 21#1 28#1] % C E A# D#
			 roots:[12#1] %% 
			 essentialPitchClasses:[12#1 15#1 21#1 28#1]
%				dissonanceDegree:2
			 comment:unit(name:['Hendrix chord' '15-limit ASS 1']))
		   chord(pitchClasses:[8#1 10#1 12#1 15#1] % C E G B
			 roots:[8#1] %% 
			 essentialPitchClasses:[8#1 10#1 12#1 15#1]
%				dissonanceDegree:2
			 comment:'major 7th')
		   %% Vogel's Tristan Chord
		   %% Contrast: 5:7:9:12  Tristan Chord, Harmonic Half-diminished Seventh
		   %%
		   %% [1#3 1#4 1#5 1#7] is same as [1#4 1#5 1#6 1#7]
		   chord(pitchClasses:[1#3 1#4 1#5 1#7] % C F# A# D#, same as C Eb G A|
			 %% ?? C (1/7) or F# (1/5)
			 roots:[1#7] 
			 essentialPitchClasses:[1#3 1#4 1#5 1#7]
%				dissonanceDegree:2
			 comment:unit(name:['subharmonic 6th' 'Tristan chord' 'subharmonic half-diminished 7th' 'minor septimal 6th']))
		   %% !!!
% 		   chord(pitchClasses:['C' 'D#' 'F#' 'A#'] % same as C Eb G A|
% 			 roots:['D#'] % 'C'
% 			 % silentRoots:['G#']
% 			 essentialPitchClasses:['C' 'D#' 'F#' 'A#']
% %				dissonanceDegree:2
% %			 comment:'reversed harmonic dominant seventh'
% 			 comment:unit(name:['subharmonic 6th' 'minor septimal 6th']) 
% 			)
		   chord(pitchClasses:[12#1 14#1 18#1 21#1] % C D# G A#
			 roots:[12#1] %% 
			 essentialPitchClasses:[12#1 14#1 21#1]
%				dissonanceDegree:2
			 comment:'subminor 7th')
		   chord(pitchClasses:[14#1 18#1 21#1 24#1] % C E| G A|
			 roots:[14#1] %% 
			 essentialPitchClasses:[14#1 18#1 21#1 24#1] %% ??
%				dissonanceDegree:2
			 comment:'supermajor added 6th')
		   chord(pitchClasses:[16#1 20#1 25#1 28#1] % C E G# A#
			 roots:[16#1] %% 
			 essentialPitchClasses:[16#1 20#1 25#1 28#1]
%				dissonanceDegree:2
			 comment:'augmented dominant 7th')
		   chord(pitchClasses:[16#1 20#1 25#1 30#1] % C E G# B
			 roots:[16#1] %% 
			 essentialPitchClasses:[16#1 20#1 25#1 30#1]
%				dissonanceDegree:2
			 comment:'augmented major 7th')
		   chord(pitchClasses:[16#1 21#1 24#1 28#1] % C E# G A#
			 roots:[16#1] %% 
			 essentialPitchClasses:[16#1 21#1 24#1 28#1]
%				dissonanceDegree:2
			 comment:'Pepper\'s Square')
		   chord(pitchClasses:[18#1 22#1 27#1 33#1] % C E; G B;
			 roots:[18#1] %% 
			 essentialPitchClasses:[18#1 22#1 27#1 33#1]
%				dissonanceDegree:2
			 comment:'neutral 7th')
		   %% !!!!
		   %% non-reversable chord (reversed chord is same chord in ET31)
		   chord(pitchClasses:[20#1 25#1 28#1 35#1] % C E F# A#  [1#1 5#4 7#5 7#4] 
			 roots:[20#1] %% 
			 essentialPitchClasses:[20#1 25#1 28#1 35#1]
%				dissonanceDegree:2
			 comment:'french 6th')
		   chord(pitchClasses:[25#1 30#1 35#1 42#1] % C Eb F# A
			 roots:[25#1] %% 
			 essentialPitchClasses:[25#1 30#1 35#1 42#1]
%				dissonanceDegree:2
			 comment:'diminished 7th')
		   chord(pitchClasses:['C' 'Eb' 'Gb' 'Bb'] 
			 roots:['C'] %% 
			 essentialPitchClasses:['C' 'Eb' 'Gb' 'Bb']
%				dissonanceDegree:2
			 comment:'halve-diminished 7th')
		   chord(pitchClasses:[44#1 56#1 66#1 77#1] % C Fb G A#
			 roots:[44#1] %% 
			 essentialPitchClasses:[44#1 56#1 66#1 77#1]
%				dissonanceDegree:2
			 comment:unit(name:['focal 7th' 'NM rebounding 7th']))
		   
		   %% same as sixte ajoutee, but different root
		   %% non-reversable chord
		   chord(pitchClasses:['C' 'Eb' 'G' 'Bb'] % 
			 roots:['C'] %% 
			 essentialPitchClasses:['C' 'Eb' 'G' 'Bb']
%				dissonanceDegree:2
			 comment:unit(name:['m7' 'minor 7th']))
		   %% same as minor with minor seventh, but different root
		   chord(pitchClasses:[12#1 15#1 18#1 20#1] % 'C' 'E' 'G' 'A'
			 roots:[12#1]
			 essentialPitchClasses:[12#1 15#1 18#1 20#1]
%				dissonanceDegree:2
			 comment:unit(name:['sixte ajoutee' 'added 6th']))
		   chord(pitchClasses:['C' 'Eb' 'G' 'A'] % same as ['C' 'Eb' 'Gb' 'Bb']
			 roots:['C']  % ??
			 essentialPitchClasses:['C' 'Eb' 'A']
%				dissonanceDegree:2
			 % comment:'reversed dominant seventh'
			 comment:unit(name:['minor 6th' 'minor added 6th'])
			)
		   chord(pitchClasses:['C' 'Eb' 'G' 'D'] % 
			 roots:['C'] %% 
			 essentialPitchClasses:['C' 'Eb' 'G' 'D']
%				dissonanceDegree:2
			 comment:unit(name:['minor added 9th' 'madd9']))
		   %% 'quartal tetrad' is inversion of 'fourth-ninth chord'
		   chord(pitchClasses:['C' 'F' 'G' 'D'] % 
			 roots:['C'] %% 
			 essentialPitchClasses:['C' 'F' 'G' 'D']
%				dissonanceDegree:2
			 comment:unit(name:['quartal tetrad' 'fourth-ninth chord' '9/4' 'sus4add9' '2nd-4th-5th']))
% 		   chord(pitchClasses:['C' 'F' 'Bb' 'Eb'] % 
% 			 roots:['C'] %% 
% 			 essentialPitchClasses:['C' 'F' 'Bb' 'Eb']
% %				dissonanceDegree:2
% 			 comment:'quartal tetrad')
		   %% 'NM minor 7th quad' and 'NM major 6th quad' are simply transpositions of each other, even their root is the same
		   chord(pitchClasses:['C' 'D#' 'G|' 'Bb'] % 
			 roots:['C'] %% 
			 essentialPitchClasses:['C' 'D#' 'G|' 'Bb']
%				dissonanceDegree:2
			 comment:unit(name:['NM minor 7th quad' 'NM major 6th quad']))
% 		   chord(pitchClasses:['C' 'E#' 'G|' 'A|'] % 
% 			 roots:['A|'] %% ????
% 			 essentialPitchClasses:['C' 'E#' 'G|' 'A|']
% %				dissonanceDegree:2
% 			 comment:'NM major 6th quad')
		   chord(pitchClasses:['C' 'E' 'G' 'Bb'] % 
			 roots:['C'] %% 
			 essentialPitchClasses:['C' 'E' 'Bb']
%				dissonanceDegree:2
			 comment:'dominant 7th')
		   chord(pitchClasses:['C' 'E|' 'G' 'Bb'] % 
			 roots:['C'] %% 
			 essentialPitchClasses:['C' 'E|' 'G' 'Bb']
%				dissonanceDegree:2
			 comment:'NM larger rebounding 7th')


		   %%
		   %% chords of 5 and more tones
		   %%


		   %% ??!! less clear than Tristan as well as Hendrix chord, wesser in weiter Lage
		   chord(pitchClasses:['C' 'E' 'F#' 'A#' 'D#'] % 
			 roots:['C'] %% 
			 essentialPitchClasses:['C' 'E' 'F#' 'A#' 'D#']
%				dissonanceDegree:2
			 %% TMP name
			 comment:unit(name:'Tristan + Hendrix chord'))
		   %% harmonic 11ths without 9th
		   chord(pitchClasses:[8#1 10#1 11#1 12#1 14#1] % C E F| G A#
			 roots:[8#1] %% 
			 essentialPitchClasses:[8#1 10#1 11#1 14#1]
%				dissonanceDegree:2
			 comment:unit(name:'11-limit major prime chord'))
		   chord(pitchClasses:[660#1 770#1 840#1 924#1 1155#1] % C D# Fb F# A#
			 roots:[660#1] %% ??
			 essentialPitchClasses:[660#1 770#1 840#1 924#1 1155#1]
%				dissonanceDegree:2
			 comment:unit(name:'11-limit minor prime chord'))
		   chord(pitchClasses:['C' 'F' 'G' 'Bb' 'D'] % 
			 roots:['C'] %% 
			 essentialPitchClasses:['C' 'F' 'G' 'Bb' 'D']
%				dissonanceDegree:2
			 comment:unit(name:'dominant 9th suspended 4th' '9sus4'))
		   chord(pitchClasses:[1#1 3#1 5#1 15#1 9#1]
			 roots:[1#1]
			 essentialPitchClasses:[1#1 5#1 15#1 9#1]
%				dissonanceDegree:2
			 comment:'major 9th')
		   chord(pitchClasses:[1#1 3#1 5#1 7#1 9#1] % C E G A# D
			 roots:[1#1] %% 
			 essentialPitchClasses:[1#1 5#1 7#1 9#1]
%				dissonanceDegree:2
			 comment:unit(name:'harmonic 9th'))
		   %% 'major 7th added 6th' and 'minor 9th' have same PC set, but differ in their root
		   chord(pitchClasses:[1#1 3#1 5#1 15#1 5#3]
			 roots:[1#1]
			 essentialPitchClasses:[1#1 5#1 15#1 5#3]
%				dissonanceDegree:2
			 comment:'major 7th added 6th')
		   chord(pitchClasses:['C' 'Eb' 'G' 'Bb' 'D'] % 
			 roots:['C'] %% 
			 essentialPitchClasses:['C' 'Eb' 'Bb' 'D'] % ??
%				dissonanceDegree:2
			 comment:unit(name:'minor 9th' 'm9' 'major 7th added 6th'))
		   chord(pitchClasses:[3#1 5#1 7#1 15#1 21#1 35#1] % C A D# E A# G;
			 roots:[3#1] %% 
			 essentialPitchClasses:[3#1 5#1 7#1 15#1 21#1 35#1]
%				dissonanceDegree:2
			 comment:unit(name:'Hexany 1 3 5 7')) 
		   chord(pitchClasses:['C' 'Eb' 'G' 'Bb' 'D' 'F'] % 
			 roots:['C'] %% 
			 essentialPitchClasses:['C' 'Eb' 'G' 'Bb' 'D' 'F'] %% ??
%				dissonanceDegree:2
			 comment:unit(name:'minor 11th' 'm11'))
		   chord(pitchClasses:[4#1 5#1 6#1 7#1 9#1 11#1] % C E G A# D F|
			 roots:[4#1] %% 
			 essentialPitchClasses:[4#1 9#1 5#1 11#1 7#1]
%				dissonanceDegree:2
			 comment:unit(name:'harmonic 11th'))

		   %% all 31-tone PCs (e.g., for test CPS where all tones should be harmonic)
		   chord(pitchClasses:[0 1 2 3 4 5 6 7 8 9
				       10 11 12 13 14 15 16 17 18 19
				       20 21 22 23 24 25 26 27 28 29
				       30]
			 roots:[0]
			 comment:'31-tone')
		  )

   %% 
   Scales = scales(

	       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	       %%
	       %% all 31 ET scales listed in Scala (modes of size 31)
	       %%

	       %%
	       %% the common scales 
	       %%
	       
	       %% other chromatic scale variants possible which are not listed here?
	       scale(pitchClasses:['C' 'C#' 'D' 'Eb' 'E' 'F' 'F#' 'G' 'G#' 'A' 'Bb' 'B']
% 			 roots:['C' 'C#' 'D' 'Eb' 'E' 'F' 'F#' 'G' 'G#' 'A' 'Bb' 'B'] % 
		     roots:['C'] % TODO: ??
		     comment:'meantone chromatic')
% 	       scale(pitchClasses:['C' 'D' 'E' 'F' 'G' 'A' 'B']
% 			 roots:['C'] 
% 		     comment:'major')
	       scale(pitchClasses:[1#1 9#8 5#4 4#3 3#2 5#3 15#8]
		     roots:[1#1]
		     comment:'major')
	       scale(pitchClasses:['C' 'D' 'Eb' 'F' 'G' 'Ab' 'Bb']
		     roots:['C'] 
		     comment:'natural minor')
	       scale(pitchClasses:['C' 'D' 'Eb' 'F' 'G' 'A' 'B']
		     roots:['C'] 
		     comment:'melodic minor')
	       scale(pitchClasses:['C' 'D' 'Eb' 'F' 'G' 'Ab' 'B']
		     roots:['C'] 
		     comment:'harmonic minor')
	       scale(pitchClasses:['C' 'D' 'E' 'F' 'G' 'Ab' 'B']
		     roots:['C'] 
		     comment:'harmonic major')
	       scale(pitchClasses:['C' 'D' 'E' 'F' 'G' 'Ab' 'Bb']
		     roots:['C'] 
		     comment:'major-minor')
	       %% Scale consists of 2 sets of 3-limit intervals which are related by a 7/4. Together, they approximate minor.
	       scale(pitchClasses:['C' 'D' 'D#' 'F' 'G' 'G#' 'A#']
		     roots:['C'] 
		     comment:unit(name:['septimal minor' 'septimal natural minor']))

	       %%
	       %% Euler-Fokker genera
	       %% Boxy shapes from the [3,5,7] lattice
	       %%
	       
	       scale(pitchClasses:['C' 'D' 'F' 'G']
		     roots:['C'] 
		     comment:'genus primum')
	       scale(pitchClasses:['C' 'E' 'F' 'G' 'A' 'B']
		     roots:['C'] 
		     comment:'genus secundum')
	       scale(pitchClasses:['C' 'Eb' 'E' 'G' 'Ab' 'B']
		     roots:['C'] 
		     comment:'genus tertium')
	       scale(pitchClasses:['C' 'E' 'G#' 'B#']
		     roots:['C'] 
		     comment:'genus quartum')
	       scale(pitchClasses:['C' 'D' 'E#' 'G' 'A#' 'B#']
		     roots:['C'] 
		     comment:'genus quintum')
	       scale(pitchClasses:['C' 'D;' 'E' 'E#' 'G' 'A;' 'A#' 'B']
		     roots:['C'] 
		     comment:'genus sextum')
	       scale(pitchClasses:['C' 'D;' 'E' 'F#' 'Ab' 'A#']
		     roots:['C'] 
		     comment:'genus septimum')
	       scale(pitchClasses:['C' 'D|' 'E#' 'G' 'G|' 'A#']
		     roots:['C'] 
		     comment:'genus octavum')
	       scale(pitchClasses:['C' 'D;' 'E' 'G|' 'A#' 'B|']
		     roots:['C'] 
		     comment:'genus nonum')
	       scale(pitchClasses:['C' 'F' 'G|' 'A#']
		     roots:['C'] 
		     comment:'genus decimum')
	       scale(pitchClasses:['C' 'D' 'E' 'F' 'G' 'A' 'Bb' 'B']
		     roots:['C'] 
		     comment:'genus diatonicum')
	       scale(pitchClasses:['C' 'Db' 'Eb' 'E' 'F' 'G' 'Ab' 'A' 'B']
		     roots:['C'] 
		     comment:'genus chromaticum')
	       scale(pitchClasses:['C' 'D' 'E' 'E#' 'F' 'G' 'A' 'A#' 'B']
		     roots:['C'] 
		     comment:'genus diatonicum cum septimis')
	       scale(pitchClasses:['C' 'Db' 'D#' 'E' 'F' 'F#' 'Gb' 'G#' 'Ab' 'A#' 'Bb' 'B']
		     roots:['C'] 
		     comment:'genus enharmonicum vocale')
	       scale(pitchClasses:['C' 'C#' 'D;' 'Eb' 'E' 'E#' 'F#' 'G' 'Ab' 'A;' 'A#' 'B']
		     roots:['C'] 
		     comment:'genus enharmonicum instrumentale')
	       scale(pitchClasses:['C' 'Db' 'D' 'Eb' 'E' 'F' 'F#' 'G' 'Ab' 'A' 'Bb' 'B']
		     roots:['C'] 
		     comment:'genus diatonico-chromaticum')
	       scale(pitchClasses:['C' 'D' 'D#' 'Eb' 'E' 'F#' 'G' 'G#' 'Ab' 'A#' 'Bb' 'B']
		     roots:['C'] 
		     comment:'genus bichromaticum')
	       %% Note: last interval implicit (left out interval back to 'C')
	       scale(pitchClasses:{Pattern.dxsToXs [3 1 2 4 2 4 2 4 2 1 3] 0}
		     roots:['C'] 
		     comment:'genus [3577]')  % Joel Mandelbaum Andante cantabile

	       %%
	       %% Greek/tetrachord modes
	       %%
	       
	       scale(pitchClasses:['C' 'D;' 'Eb' 'F' 'G;' 'Ab' 'Bb']
			 roots:['C'] 
			 comment:'neutral diatonic mixolydian')
	       scale(pitchClasses:['C' 'D;' 'E;' 'F' 'G;' 'A;' 'B;']
			 roots:['C'] 
			 comment:'neutral diatonic lydian')
	       scale(pitchClasses:['C' 'D' 'E;' 'F' 'G' 'A' 'B;']
			 roots:['C'] 
			 comment:'neutral diatonic phrygian')
	       scale(pitchClasses:['C' 'D;' 'Eb' 'F' 'G' 'A;' 'Bb']
			 roots:['C'] 
			 comment:'neutral diatonic dorian')
	       scale(pitchClasses:['C' 'D;' 'E;' 'F|' 'G' 'A;' 'B;']
			 roots:['C'] 
			 comment:'neutral diatonic hypolydian')
	       scale(pitchClasses:['C' 'D' 'E' 'F|' 'G' 'A' 'B;']
			 roots:['C'] 
			 comment:'neutral diatonic hypophrygian')
	       scale(pitchClasses:['C' 'D' 'E;' 'F' 'G' 'A;' 'Bb']
			 roots:['C'] 
			 comment:'neutral diatonic hypodorian')
	       scale(pitchClasses:['C' 'D;' 'E;' 'F' 'G;' 'A;' 'Bb']
			 roots:['C'] 
			 comment:'neutral mixolydian')
	       scale(pitchClasses:['C' 'D' 'E;' 'F' 'G' 'A;' 'B;']
			 roots:['C'] 
			 comment:'neutral lydian')
	       scale(pitchClasses:['C' 'D;' 'Eb' 'F' 'G;' 'A;' 'Bb']
			 roots:['C'] 
			 comment:'neutral phrygian')
	       scale(pitchClasses:['C' 'D;' 'E;' 'F' 'G' 'A;' 'B;']
			 roots:['C'] 
			 comment:'neutral dorian')
	       scale(pitchClasses:['C' 'D' 'E;' 'F|' 'G' 'A' 'B;']
			 roots:['C'] 
			 comment:'neutral hypolydian')
	       scale(pitchClasses:['C' 'D;' 'E;' 'F' 'G' 'A;' 'Bb']
			 roots:['C'] 
			 comment:'neutral hypophrygian')
	       scale(pitchClasses:['C' 'D' 'E;' 'F|' 'G' 'A;' 'B;']
			 roots:['C'] 
			 comment:'neutral hypodorian')
	       scale(pitchClasses:['C' 'C#' 'D;' 'F' 'F#' 'G;' 'Bb']
			 roots:['C'] 
			 comment:'hemiolic chromatic mixolydian')
	       scale(pitchClasses:['C' 'C#' 'Fb' 'F' 'F#' 'A|' 'B|']
			 roots:['C'] 
			 comment:'hemiolic chromatic lydian')
	       scale(pitchClasses:['C' 'E;' 'Fb' 'F' 'A;' 'B;' 'B|']
			 roots:['C'] 
			 comment:'hemiolic chromatic phrygian')
	       scale(pitchClasses:['C' 'C#' 'D;' 'F' 'G' 'G#' 'A;'] 
			 roots:['C'] 
			 comment:'hemiolic chromatic dorian')
	       scale(pitchClasses:['C' 'C#' 'Fb' 'Gb' 'G' 'G#' 'B|']
			 roots:['C'] 
			 comment:'hemiolic chromatic hypolydian')
	       scale(pitchClasses:['C' 'E;' 'F|' 'Gb' 'G' 'B;' 'B|']
			 roots:['C'] 
			 comment:'hemiolic chromatic hypophrygian')
	       scale(pitchClasses:['C' 'D' 'D#' 'E;' 'G' 'G#' 'A;']
			 roots:['C'] 
			 comment:'hemiolic chromatic hypodorian')
	       scale(pitchClasses:['C' 'C#' 'D' 'F' 'F#' 'G' 'Bb']
			 roots:['C'] 
			 comment:'ratio 2:3 chromatic mixolydian')
	       scale(pitchClasses:['C' 'Db' 'Fb' 'F' 'Gb' 'A|' 'B|']
			 roots:['C'] 
			 comment:'ratio 2:3 chromatic lydian')
	       scale(pitchClasses:['C' 'Eb' 'E' 'F' 'Ab' 'Bb' 'B']
			 roots:['C'] 
			 comment:'ratio 2:3 chromatic phrygian')
	       scale(pitchClasses:['C' 'C#' 'D' 'F' 'G' 'G#' 'A']
			 roots:['C'] 
			 comment:'ratio 2:3 chromatic dorian')
	       scale(pitchClasses:['C' 'Db' 'Fb' 'Gb' 'G' 'Ab' 'B|']
			 roots:['C'] 
			 comment:'ratio 2:3 chromatic hypolydian')
	       scale(pitchClasses:['C' 'Eb' 'F' 'F#' 'G' 'Bb' 'B']
			 roots:['C'] 
			 comment:'ratio 2:3 chromatic hypophrygian')
	       scale(pitchClasses:['C' 'D' 'D#' 'E' 'G' 'G#' 'A']
			 roots:['C'] 
			 comment:'ratio 2:3 chromatic hypodorian')
	       scale(pitchClasses:['C' 'Db' 'Eb' 'F' 'Gb' 'Ab' 'Bb']
			 roots:['C'] 
			 comment:'intense diatonic mixolydian')
	       scale(pitchClasses:['C' 'D' 'Eb' 'F' 'G' 'A' 'Bb']
			 roots:['C'] 
			 comment:'intense diatonic phrygian')
	       scale(pitchClasses:['C' 'Db' 'Eb' 'F' 'G' 'Ab' 'Bb']
			 roots:['C'] 
			 comment:'intense diatonic dorian')
	       scale(pitchClasses:['C' 'D' 'E' 'F#' 'G' 'A' 'B']
			 roots:['C'] 
			 comment:'intense diatonic hypolydian')
	       scale(pitchClasses:['C' 'D' 'E' 'F' 'G' 'A' 'Bb']
			 roots:['C'] 
			 comment:'intense diatonic hypophrygian')
	       scale(pitchClasses:['C' 'C#' 'D#' 'F' 'F#' 'G#' 'Bb']
			 roots:['C'] 
			 comment:'soft diatonic mixolydian')
	       scale(pitchClasses:['C' 'D' 'Fb' 'F' 'G' 'A|' 'B|'] 
			 roots:['C'] 
			 comment:'soft diatonic lydian')
	       scale(pitchClasses:['C' 'D|' 'Eb' 'F' 'G|' 'A|' 'Bb']
			 roots:['C'] 
			 comment:'soft diatonic phrygian')
	       scale(pitchClasses:['C' 'C#' 'D#' 'F' 'G' 'G#' 'A#']
			 roots:['C'] 
			 comment:'soft diatonic dorian')
	       scale(pitchClasses:['C' 'D' 'Fb' 'Gb' 'G' 'A' 'B|']
			 roots:['C'] 
			 comment:'soft diatonic hypolydian')
	       scale(pitchClasses:['C' 'D|' 'Fb' 'F' 'G' 'A|' 'Bb']
			 roots:['C'] 
			 comment:'soft diatonic hypophrygian')
	       scale(pitchClasses:['C' 'D' 'D#' 'E#' 'G' 'G#' 'A#']
			 roots:['C'] 
			 comment:'soft diatonic hypodorian')
	       scale(pitchClasses:['C' 'C|' 'Db' 'F' 'F|' 'Gb' 'Bb']
			 roots:['C'] 
			 comment:'enharmonic mixolydian')
	       scale(pitchClasses:['C' 'C#' 'E#' 'F' 'F#' 'A#' 'B#']
			 roots:['C'] 
			 comment:'enharmonic lydian')
	       scale(pitchClasses:['C' 'E' 'Fb' 'F' 'A' 'B' 'B|']
			 roots:['C'] 
			 comment:'enharmonic phrygian')
	       scale(pitchClasses:['C' 'C|' 'Db' 'F' 'G' 'G|' 'Ab']
			 roots:['C'] 
			 comment:'enharmonic dorian')
	       scale(pitchClasses:['C' 'C#' 'E#' 'G;' 'G' 'G#' 'B#']
			 roots:['C'] 
			 comment:'enharmonic hypolydian')
	       scale(pitchClasses:['C' 'E' 'F#' 'Gb' 'G' 'B' 'B|']
			 roots:['C'] 
			 comment:'enharmonic hypophrygian')
	       scale(pitchClasses:['C' 'D' 'D|' 'Eb' 'G' 'G|' 'Ab']
			 roots:['C'] 
		     comment:'enharmonic hypodorian')

	       %%
	       %% Interscalar
	       %%
	       
	       scale(pitchClasses:['C' 'D|' 'E#' 'G|' 'A#']
		     roots:['C'] 
		     comment:'quasi-equal pentatonic')
	       scale(pitchClasses:{Pattern.dxsToXs [3 3 2 3 3 3 3 3 2 3] 0}
		     roots:['C'] 
		     comment:'near 11 edo')	       

	       %%
	       %% Miscellaneous
	       %%
	       
	       scale(pitchClasses:['C' 'Db' 'D' 'D#' 'E' 'F' 'F#' 'G' 'Ab' 'A' 'A#' 'B']
		     roots:['C'] 
		     comment:'Fokker 12-tone')
	       scale(pitchClasses:['C' 'D' 'Eb' 'F' 'Gb' 'Ab' 'A' 'B']
		     roots:['C'] 
		     comment:'modus conjunctus')
	       %% Hm, interesting. Not sure yet, what to make of it..
	       scale(pitchClasses:['C' 'Db' 'Eb' 'E' 'F#' 'G' 'A' 'Bb']
		     roots:['C'] 
		     comment:'octatonic') % name nicht eindeutig, aber fuer 31 ET vielleicht schon..
	       %% !!!! septimal scale o-tonal and u-tonal
	       scale(pitchClasses:['C' 'Db' 'D|' 'E' 'F' 'G' 'Ab' 'A#' 'B']
		     roots:['C'] 
		     comment:'Hahn symmetric pentachordal')
	       scale(pitchClasses:['C' 'Db' 'D#' 'E' 'F' 'G' 'Ab' 'A#' 'B']
		     roots:['C'] 
		     comment:'Hahn pentachordal')
	       scale(pitchClasses:{Pattern.dxsToXs [4 4 2 5 3 3 4 3] 0}
		     roots:['C'] 
		     comment:'Hahn nonatonic')
	       scale(pitchClasses:['C' 'D' 'Eb' 'Fb' 'F|' 'G;' 'A;' 'A#' 'B']
		     roots:['C'] 
		     comment:'Rothenberg generalised diatonic')
	       scale(pitchClasses:{Pattern.dxsToXs [2 3 3 6 4 4 2 2] 0}
		     roots:['C'] 
		     comment:'Michael Sheiman 9-note')

	       
	       %%
	       %% MOS and Cradle MOS
	       %%
	       
	       scale(pitchClasses:{Pattern.dxsToXs [4 5 4 5 4 5] 0}
		     roots:['C'] 
		     comment:'Neutral scale 7-note')
	       scale(pitchClasses:{Pattern.dxsToXs [4 1 4 4 1 4 4 4 1] 0}
		     roots:['C'] 
		     comment:'Neutral scale 10-note')
	       scale(pitchClasses:['C' 'D;' 'D' 'E;' 'F' 'G;' 'G' 'A;' 'Bb' 'B;']
		     roots:['C'] 
		     comment:'Breed 10-tone')
	       scale(pitchClasses:['C' 'D;' 'D#' 'Fb' 'F|' 'G' 'Ab' 'A#' 'B']
		     roots:['C'] 
		     comment:'Orwell')
	       scale(pitchClasses:['C' 'D' 'D|' 'Fb' 'E#' 'G;' 'G' 'A' 'A|' 'B|' 'B#']
		     roots:['C'] 
		     comment:'de Vries 11-tone')
	       scale(pitchClasses:{Pattern.dxsToXs [3 1 3 1 3 1 3 1 3 1 3 1 3 1] 0}
		     roots:['C'] 
		     comment:'pseudo-Porcupine 15-note')	
	       scale(pitchClasses:{Pattern.dxsToXs [1 7 1 2 1 7 1 2 1 7] 0}
		     roots:['C'] 
		     comment:'nested bees')
	       scale(pitchClasses:['C' 'D;' 'D|' 'E' 'E#' 'Gb' 'G' 'A;' 'A#' 'B']
		     roots:['C'] 
		     comment:'Lumma decatonic')
	       scale(pitchClasses:['C' 'C#' 'D#' 'E;' 'Fb' 'Gb' 'G' 'G#' 'A;' 'B;' 'B|']
		     roots:['C'] 
		     comment:'Secor/Barton no-fives')

	       %%
	       %% Date: Sat, 19 Dec 1998 14:05:02 -0600 (CST)
	       %% From: Paul Hahn <manynote@...>
	       %% To: tuning@...
	       %% Subject: Re: All, then best, 7-limit scales with 31 consonances
	       %%On Mon, 30 Nov 1998, Paul Hahn wrote:
% > There are only three [31-consonance 7-limit JI scales] whose
% > smallest scale degree is not smaller than 25:24; they approximate 12TET
% > reasonably well. This is the (IMHO) best one:
% >
% > 42:25------21:20-------21:16
% > \'-. .-'/ \'-. .-'/ \'-.
% > \ 6:5--/---\--3:2--/---\-15:8
% > \ /|\ / \ /|\ / \ /|
% > \ | / \ | / \ |
% > / \|/ \ / \|/ \ / \|
% > / 7:5---------7:4--------35:32
% > /.-' '-.\ /.-' '-.\ /.-'
% > 8:5---------1:1---------5:4

% Incidentally, I just noticed that this scale differs by just one pitch
% from a just version of Fokker's 12-pitch 7-limit scale that Dave Keenan
% recently rediscovered. The one pitch that differs is 35:32, which needs
% to be changed to 9:8. This reduces the number of 7-limit consonances in
% the JI version to 30 again, but the 31TET or 1/4-comma meantone versions
% have 38.

	       %% Summary: the following three scales have no 1 step interval, and all contain very many 7-limit consonances
	       
	       scale(%% pcs unsorted
		     pitchClasses:[42#25 21#20 21#16
				   6#5 3#2 15#8
				   7#5 7#4 35#32
				   8#5 1#1 5#4]
		     roots:[1#1] 
		     comment:'Hahn 12-pitch 7-limit 1')
	       scale(pitchClasses:[42#25 21#20 21#16
				   6#5 3#2 15#8
				   7#5 7#4
				   9#8
				   8#5 1#1 5#4]
		     roots:[1#1] 
		     comment:'Fokker 12-pitch 7-limit')

% http://sonic-arts.org/td/1592.htm

% From: Paul Hahn
% To: Tuning Forum
% Subject: Most 7-limit consonances with 12 pitches
	       
% 	           35:24-------35:16------105:64
% 	         .-'/ \'-.   .-'/ \'-.   .-'/
% 	      5:3--/---\--5:4--/---\-15:8  /
% 	      /|\ /     \ /|\ /     \ /|  /
% 	     / | /       \ | /       \ | /
% 	    /  |/ \     / \|/ \     / \|/
% 	   /  7:6---------7:4--------21:16
% 	  /.-'   '-.\ /.-'   '-.\ /.-'
% 	4:3---------1:1---------3:2

	       scale(pitchClasses:[35#24 35#16 105#64
				   5#3 5#4 15#8
				   7#6 7#4 21#16
				   4#3 1#1 3#2]
		     roots:[1#1] 
		     comment:'Hahn 12-pitch 7-limit 2')

	       

	       %% many 1 step intervals
	       scale(pitchClasses:[1#1 21#20 15#14 35#32 9#8 5#4 21#16 35#24 3#2 49#32 25#16 105#64 7#4 15#8]
		     roots:[1#1] 
		     comment:'stellated hexany')
	       
	       
	       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	       %%
	       %% other scales (not from Scala list of 31 ET scales)
	       %%

	       %% high tuning errors of 11#8 (9.4 cent) and 13#8 (11 cent!)
	       %% is this good enough anyway? 11#8 tuning error in 12ET is ~50 cent!
	       scale(pitchClasses:[8#8 9#8 10#8 11#8 12#8 13#8 14#8 15#8]
		     roots:[8#8]  
%				dissonanceDegree:2
		     comment:'harmonic series') % name nicht eindeutig


	       %% Decatonic scale with all 6 commas
	       %% NOTE: 4#3 is a comma away from 21#16, so I may have the latter instead! 
	       scale(pitchClasses:[1#1 21#20 15#14 7#6 25#21 5#4 21#16 4#3
				   7#5 10#7 3#2 5#3 7#4 25#14 15#8 40#21]
		     roots:[1#1] 
		     comment:'full dynamic symmetrical major')

	       %% http://x31eq.com/miracle.htm
	       scale(pitchClasses:{Pattern.dxsToXs [3 3 3 3 3 3 3 3 3] 0}
		     roots:[0]
		     comment:'miracle')	  
	       scale(pitchClasses:{Pattern.dxsToXs [1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2] 0}
		     roots:[0]
		     comment:'blackjack')
	       
	       %% Erlich; see http://launch.groups.yahoo.com/group/tuning/message/22532
	       local
		  %% blackjack PCs
		  BJ = {Pattern.dxsToXs [1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2] 0}
		  %% degrees of BJ; zero-based
		  Degrees = [1 3 4 6 8 10 11 13 15 17 18 20]
	       in 
		  scale(pitchClasses: {Map Degrees
				       fun {$ Degree}
					  %% access the respective blackjack PC;
					  %% and transpose whole scale down to 0
					  {Nth BJ Degree+1} - 1
				       end}
			roots:[0] 
			comment:'12-out-of-BlackJack')
	       end

	       %% all 31-tone PCs (e.g., for test CPS where all tones should be harmonic)
	       scale(pitchClasses:[0 1 2 3 4 5 6 7 8 9
				   10 11 12 13 14 15 16 17 18 19
				   20 21 22 23 24 25 26 27 28 29
				   30]
		     roots:[0]
		     comment:'31-tone')
	       )

   %%
   %% TODO:
   %%
   %% !! - revise JI intervals in interval DB (e.g., currently they are not symmetric, see {HS.db.getEditIntervalDB})
   %%
   %% - additional interval features like their dissonance degree, harmonic distance etc. -- use figures you can get from Scala..
   %%
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

  

   /** %% Variant of HS.db.makeFullDB with a large number of implicitly defined chords and scales, as well as all intervals for 31-TET. 
   %% */
   fun {MakeFullDB Args}
      Defaults = unit(accidentalOffset: 4
		      %% corresponds to MIDI pitch range 12-127+ (for pitchesPerOctave=12)
% 		      octaveDomain: 0#9
		      chords:unit
		      scales:unit
		      intervals:unit)
      As = {Adjoin Defaults Args}
   in
      {HS.db.makeFullDB
       {Adjoin As unit(pitchesPerOctave: 31
		       symbolToPc: ET31.pc
		       chords: {Tuple.append As.chords Chords}
		       scales: {Tuple.append As.scales Scales}
		       intervals: {Tuple.append As.intervals Intervals})}}
   end

   /** %% Full database declaration defined in this functor. 
   %% */
   DB = {MakeFullDB unit}
   
end

