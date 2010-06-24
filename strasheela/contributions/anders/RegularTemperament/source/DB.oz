

/** %% Defines databases for chords, scales and intervals in arbitrary octave-repeating regular temperaments.
%%
%% NOTE: recommendation when using a regular temperament: reduce the domain of all pitch classes (e.g., of notes, chord/scale roots and transpositions) to the tones of the current temperament using ReduceToTemperament. This is of course not necessary if all pitch classes are already reduced to some determined scale that only consists of temperament PC (which is not automatically the case with all scales and transpositions!).
%% */

%%
%% TODO:
%%
%% - procedure that expects full score and reduces the domain of all PCs in score (e.g., of notes, chord/scale roots and transpositions) to the tones of the current temperament. 
%%
%% - alternatively to using JI ratios, it would be useful to use a symbolic notation of JI pitch classes (RegT.jiPC). However, tempered pitch classes (RegT.pc) are probably no option within this database, because the database entries should be usable for a wide range of temperaments, and the meaning of tempered pitch classes can differ greatly in different temperaments (e.g., in meantone C-A# is the harmonic 7th, but something very different in Pythagorean tuning, so better notate the intended JI interval).
%%
%% - translate chards/scales from et31 with symbolic pitches into JI pitches (RegT.jiPC format) and copy them here
%%
%% - ???? temporarily, all chords/scales/intervals are defined for JI only: generalise!
%%   see [[file:~/oz/music/Strasheela/strasheela/trunk/strasheela/others/TODO/Strasheela-TODO.org::*%20Function%20mapping%20of%20ratios%20to%20corresponding%20cent%20values%20for%20a%20given%20regular%20temperament][!! Function/mapping of ratios to corresponding cent values for a given regular temperament]]
%%
%% - make PitchesPerOctave controllable by arg (so cent or millicent are possible)
%%
%% - add those chords of ET31 DB that are still missing
%%
%% - !! Change RegT.db.makeFullDB so that it allows to specify additional features (e.g., essentialPitchClasses) and to automatically filter out those database entries that do not have these features.
%%
%% - after pitch classes can be specified with symbolic notation then go through all existing databases for material to add
%%
%% - create interval database
%%

functor 
   
import
   FS
%    Browser(browse:Browse) % for debugging
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
%    MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
%    Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   RegT at '../RegularTemperament.ozf'
   
export   

   ReduceToTemperament
   MakeFullDB

   %% TMP
   % FilterDB

define
   

   /** %% Reduces all chord/scale pitch class sets and roots as well as all note pitch classes to the pitch classes of the current temperament.
   %% */
   proc {ReduceToTemperament MyScore}MinOctave#MaxOctave = {HS.db.getOctaveDomain}
      TemperamentPCs = {Record.toList {HS.db.getTemperament}}
      TemperamentPC_FS = {GUtils.intsToFS TemperamentPCs}
      MinOctave#MaxOctave = {HS.db.getOctaveDomain}
      TemperamentPitch_FS = {GUtils.intsToFS
			     {LUtils.mappend {List.number MinOctave MaxOctave 1}
			      fun {$ Octave}
				 {Map TemperamentPCs
				  fun {$ TemperamentPC}
				     TemperamentPC + ({HS.db.getPitchesPerOctave} * (Octave+1))
				  end}
			      end}}
   in
      {ForAll {MyScore collect($ test:HS.score.isPitchClassCollection)}
       proc {$ X}
	  {FS.subset {X getPitchClasses($)} TemperamentPC_FS}
	  {FS.include {X getRoot($)} TemperamentPC_FS}
	  {FS.include {X getTransposition($)} TemperamentPC_FS}
       end}
      {ForAll {MyScore collect($ test:HS.score.isPitchClassMixin)}
       proc {$ X}
	  {FS.include {X getPitchClass($)} TemperamentPC_FS}
	  {FS.include {X getPitch($)} TemperamentPitch_FS}
       end}
   end


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Chord, Scale and Interval Database Definition 
%%%

   %%
   %% NOTE: 'comment' is required feature for any chord/scale/interval database entry
   %%

   Chords = chords(
   
	       %%
	       %% triads
	       %%
   
	       chord(pitchClasses:[4#1 5#1 6#1]
		     roots:[4#1]
		     essentialPitchClasses:[4#1 5#1]
%				dissonanceDegree:2
		     comment:'major')
	       chord(pitchClasses:[1#6 1#5 1#4]
		     roots:[1#6]    
%				dissonanceDegree:2
		     essentialPitchClasses:[1#6 1#5]
		     comment:'minor')

	       %% three different diminished triads
		   
	       %% !! nice :) 
	       chord(pitchClasses:[5#1 6#1 7#1]
		     roots:[5#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[5#1 6#1 7#1]
		     comment:unit(name:['otonal subdiminished'
					'harmonic diminished']))  
	       chord(pitchClasses:[1#5 1#6 1#7]
		     roots:[1#7]    
%				dissonanceDegree:2
		     essentialPitchClasses:[1#5 1#6 1#7]
		     comment:unit(name:['utonal subdiminished'
					'utonal diminished']))
	       chord(pitchClasses:[1#1 6#5 36#25] % 'C' 'Eb' 'Gb'
			 roots:[1#1]  % ??
			 essentialPitchClasses:[1#1 6#5 36#25]
%				dissonanceDegree:2
		     comment:'geometric diminished')
	       
	       chord(pitchClasses:[4#1 5#1 25#4]
		     roots:[4#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[4#1 5#1 25#4]
		     comment:'augmented')
	       %% !!
	       chord(pitchClasses:[6#1 7#1 9#1]
		     roots:[6#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[6#1 7#1]
		     comment:'subminor')

	       %% rather dissonant -- is this characteristic enough?
% 	       chord(pitchClasses:['C' 'E;' 'G']
% 		     roots:['C']  % ??
% 		     essentialPitchClasses:['C' 'E;']
% %				dissonanceDegree:2
% 		     comment:'neutral triad')
	       
	       chord(pitchClasses:[1#6 1#7 1#9]
		     roots:[1#9]    
%				dissonanceDegree:2
		     essentialPitchClasses:[1#6 1#7 1#9]
		     comment:'supermajor')
	       
	       %% alt names:
	       %% 'Italian augmented 6th', 'major subminor 7th no 5th'
	       chord(pitchClasses:[4#1 5#1 7#1]
		     roots:[4#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[4#1 5#1 7#1]
		     comment:'harmonic 7th no 5')  

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
	       %% tetrads, pentads...
	       %%

	       chord(pitchClasses:[3#1 9#1 11#1 33#1] % C G B; F|
		     roots:[3#1] %% 
		     essentialPitchClasses:[3#1 9#1 11#1 33#1]
%				dissonanceDegree:2
		     comment:'11-limit ASS')
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
% 		   chord(pitchClasses:['C' 'Eb' 'Gb' 'Bb'] 
% 			 roots:['C'] %% 
% 			 essentialPitchClasses:['C' 'Eb' 'Gb' 'Bb']
% %				dissonanceDegree:2
% 			 comment:'halve-diminished 7th')
		   chord(pitchClasses:[44#1 56#1 66#1 77#1] % C Fb G A#
			 roots:[44#1] %% 
			 essentialPitchClasses:[44#1 56#1 66#1 77#1]
%				dissonanceDegree:2
			 comment:unit(name:['focal 7th' 'NM rebounding 7th']))

	       
		   %% same as minor with minor seventh, but different root
		   chord(pitchClasses:[12#1 15#1 18#1 20#1] % 'C' 'E' 'G' 'A'
			 roots:[12#1]
			 essentialPitchClasses:[12#1 15#1 18#1 20#1]
%				dissonanceDegree:2
			 comment:unit(name:['sixte ajoutee' 'added 6th']))
	       
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

	       chord(pitchClasses:[1#1 3#1 5#1 15#1 9#1]
			 roots:[1#1]
			 essentialPitchClasses:[1#1 5#1 15#1 9#1]
%				dissonanceDegree:2
			 comment:'major 9th')

		   %% 'major 7th added 6th' and 'minor 9th' have same PC set, but differ in their root
		   chord(pitchClasses:[1#1 3#1 5#1 15#1 5#3]
			 roots:[1#1]
			 essentialPitchClasses:[1#1 5#1 15#1 5#3]
%				dissonanceDegree:2
			 comment:'major 7th added 6th')

	       chord(pitchClasses:[3#1 5#1 7#1 15#1 21#1 35#1] % C A D# E A# G;
			 roots:[3#1] %% 
			 essentialPitchClasses:[3#1 5#1 7#1 15#1 21#1 35#1]
%				dissonanceDegree:2
		     comment:unit(name:'Hexany 1 3 5 7'))

	       chord(pitchClasses:[4#1 5#1 6#1 7#1 9#1 11#1] % C E G A# D F|
			 roots:[4#1] %% 
			 essentialPitchClasses:[4#1 9#1 5#1 11#1 7#1]
%				dissonanceDegree:2
			 comment:unit(name:'harmonic 11th'))

	       

	       %% same as minor 6th, only root differs
	       chord(pitchClasses:[1#6 1#5 1#4 3#10]
		     roots:[1#6]    
%				dissonanceDegree:2
		     essentialPitchClasses:[1#6 1#5 3#10]
		     comment:'minor 7th')  
	       %% same as minor 7th, only root differs
	       chord(pitchClasses:[4#1 5#1 6#1 10#3]
		     roots:[4#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[4#1 5#1 6#1 10#3]
		     comment:'major 6th')
	       %% NOTE: chord to add?
% 	       chord(pitchClasses:['C' 'Eb/' 'G' 'A/'] 
% 		     roots:['C']  % ??
% 		     essentialPitchClasses:['C' 'Eb/' 'A/']
% %				dissonanceDegree:2
% 			 % comment:'reversed dominant seventh'
% 		     comment:unit(name:['minor 6th' 'minor added 6th'])
% 		    )
	       %% same as 'subdiminished 7th (2)', only root differs
	       chord(pitchClasses:[5#1 6#1 7#1 42#5]
		     roots:[5#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[5#1 6#1 7#1 42#5]
		     comment:'subdiminished 7th (1)')  
	       chord(pitchClasses:[1#7 1#6 1#5 7#30]
		     roots:[1#7]    
%				dissonanceDegree:2
		     essentialPitchClasses:[1#7 1#6 1#5 7#30]
		     comment:'subdiminished 7th (2)')
	       %% alt name:
	       %% 'major subdiminished subminor 7th'
	       %% NOTE: in 22 ET, this chord equals to 'subminor 7th', even the root equals
% 	       chord(pitchClasses:[4#1 5#1 40#7 50#7]
% 		     roots:[4#1]   
% 		     essentialPitchClasses:[4#1 5#1 40#7 50#7]
% 		     comment:'')  
	       chord(pitchClasses:[4#1 5#1 7#1 40#7]
		     roots:[4#1]    
		     essentialPitchClasses:[4#1 5#1 7#1 40#7]
		     comment:'French augmented 6th')
	       %% alt names:
	       %% 'major subminor 7th', 'German augmented 6th'
	       chord(pitchClasses:[4#1 5#1 6#1 7#1]
		     roots:[4#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[4#1 5#1 7#1]
		     comment:'harmonic 7th')
	       %% alt names:
	       %% 'minor supermajor 6th', 'minor diminished 7th'
	       %% same as 'half subdiminished 7th', only root differs
	       chord(pitchClasses:[1#4 1#5 1#6 2#7]
		     roots:[1#6]    
%				dissonanceDegree:2
		     essentialPitchClasses:[1#4 1#5 2#7]
		     comment:'subharmonic 6th')
	       chord(pitchClasses:[5#1 6#1 7#1 9#1]
		     roots:[9#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[5#1 6#1 7#1 9#1]
		     comment:'supermajor minor 7th')
	       %% alt name
	       %% 'major subminor 7th 9th' 
	       chord(pitchClasses:[4#1 5#1 6#1 7#1 9#1]
		     roots:[4#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[4#1 5#1 7#1 9#1]
		     comment:'harmonic 9th')
	       %% alt name
	       %% 'supermajor minor 7th 9th'
	       chord(pitchClasses:[1#4 1#5 1#6 1#7 1#9]
		     roots:[1#9]    
%				dissonanceDegree:2
		     essentialPitchClasses:[1#4 1#5 1#6 1#7 1#9]
		     comment:'subharmonic 9th')  
	       chord(pitchClasses:[6#1 7#1 9#1 21#2]
		     roots:[6#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[6#1 7#1 9#1 21#2]
		     comment:'subminor 7th')  
	       chord(pitchClasses:[1#6 1#7 1#9 2#21]
		     roots:[1#9]    
%				dissonanceDegree:2
		     essentialPitchClasses:[1#6 1#7 1#9 2#21]
		     comment:'supermajor 6th')  
	       chord(pitchClasses:[16#3 4#1 6#1 7#1]
		     roots:[4#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[16#3 4#1 6#1 7#1]
		     comment:'subminor 7th suspended 4th')
	       %% following is same as above
% 	       chord(pitchClasses:[4#1 6#1 7#1 21#4]
% 		     roots:[4#1]    
% %				dissonanceDegree:2
% 		     essentialPitchClasses:[4#1 6#1 7#1 21#4]
% 		     comment:'subminor 7th suspended 4th (2)')  
	       chord(pitchClasses:[1#6 1#4 3#16 2#7]
		     roots:[1#6]    
%				dissonanceDegree:2
		     essentialPitchClasses:[1#6 1#4 3#16 2#7]
		     comment:'supermajor 6th suspended 2nd')
	       %% same as Young's opening chord
	       %% subset of 'lost ancestral lake region' (without subminor third)
	       chord(pitchClasses:[4#1 6#1 7#1 9#2]
		     roots:[4#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[4#1 6#1 7#1 9#2]
		     comment:unit(name:['subminor 7th suspended 2nd'
					'opening']))  
	       chord(pitchClasses:[1#4 1#6 2#7 2#9]
		     roots:[1#6]    
%				dissonanceDegree:2
		     essentialPitchClasses:[1#4 1#6 2#7 2#9]
		     comment:'supermajor 6th suspended 4th')

	       %% chords proposed as (quasi) consonant in Paul Erlich's
	       %% "Tuning, Tonality, and Twenty-Two-Tone Temperament"
% 	       chord(pitchClasses:['C' 'E\\' 'G' 'A']
% 		     roots:['C']    
% %				dissonanceDegree:2
% 		     essentialPitchClasses:['C' 'E\\' 'A']
% 		     comment:'major-minor')
% 	       chord(pitchClasses:['C' 'Eb/' 'G' 'B']
% 		     roots:['C']    
% %				dissonanceDegree:2
% 		     essentialPitchClasses:['C' 'Eb/' 'B']
% 		     comment:'minor-major')
	       
	       
% 	       chord(pitchClasses:['C' 'E\\' 'G' 'Bb' 'Eb']
% 		     roots:['C']    
% %				dissonanceDegree:2
% 		     essentialPitchClasses:['C' 'E\\' 'G' 'Bb' 'Eb']
% 		     comment:'')  
% 	       chord(pitchClasses:['C' 'D#\\' 'G' 'A' 'D']
% 		     roots:['C']    
% %				dissonanceDegree:2
% 		     essentialPitchClasses:['C' 'D#\\' 'G' 'A' 'D']
% 		     comment:'')
	       
% 	       chord(pitchClasses:['C' 'E\\' 'G' 'A' 'D']
% 		     roots:['C']    
% %				dissonanceDegree:2
% 		     essentialPitchClasses:['C' 'E\\' 'G' 'A' 'D']
% 		     comment:'')


	       %%
	       %%
	       %%
	       
	       %%
	       %% La Monte Young's The Well-Tuned Piano chords
	       %% source: Kyle Gann (1993). La Monte Young's The Well-Tuned Piano. Perspectives of New Music, 31(1), pp. 134-162.
	       %%
	       %% Note: Young's "distribution of the pitches over octaves" is lost in this pitch-class representation
	       %%

	       %% NOTE: 'opening' chord is subset of 'lost ancestral lake region' (without subminor third)
	       %% same as 'subminor 7th suspended 2nd'
% 	       chord(pitchClasses:[4#1 6#1 7#1 9#1]
% 		     roots:[4#1]
% % 		     essentialPitchClasses:[]
% 		     comment:'opening') % Full name: "The Opening Chord"
	       chord(pitchClasses:[81#1 84#1 108#1 112#1 144#1 192#1]
		     roots:[192#1] %% TODO:
% 		     essentialPitchClasses:[]
		     comment:'magic')
	       chord(pitchClasses:[48#1 54#1 56#1 64#1 72#1 81#1 84#1]
		     roots:[48#1] %% TODO:
% 		     essentialPitchClasses:[]
		     comment:'romantic')
	       chord(pitchClasses:[42#1 54#1 64#1 81#1]
		     roots:[42#1] %% TODO:
% 		     essentialPitchClasses:[]
		     comment:'gamelan')
	       %% NOTE: 'tamiar dream' is subset of 'lost ancestral lake region' (21/1 missing)
	       chord(pitchClasses:[14#1 18#1 24#1 27#1]
		     roots:[14#1] %% TODO:
% 		     essentialPitchClasses:[]
		     comment:'tamiar dream')
	       chord(pitchClasses:[12#1 14#1 18#1 21#1 27#1]
		     roots:[12#1] %% TODO:
% 		     essentialPitchClasses:[]
		     comment:'lost ancestral lake region')
	       chord(pitchClasses:[12#1 14#1 16#1 18#1 21#1]
		     roots:[12#1] %% TODO:
% 		     essentialPitchClasses:[]
		     comment:'brook')
	       chord(pitchClasses:[128#1 144#1 147#1 192#1 224#1]
		     roots:[128#1] %% TODO:
% 		     essentialPitchClasses:[]
		     comment:'pool')
	       
	       )

   Scales = scales(
	       scale(pitchClasses:[1#1 9#8 5#4 4#3 3#2 5#3 15#8]
		     roots:[1#1]
		     comment:'major')

	       %% adds minor wholetone 10/9, the there is also the fifths D-A available
	       %% Note: meaning of things like getRootDegree gets rather different :)
	       scale(pitchClasses:[1#1 10#9 9#8 5#4 4#3 3#2 5#3 15#8]
		     roots:[1#1]
		     comment:'major (8 tones)')

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

	       
	       %%
	       %% other scales 
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

	       
	       )

   Intervals = intervals(
		  interval(interval:1#1
%				  dissonanceDegree:0
			   comment:'unison')
		  )

   %% TMP def
%    Intervals = {List.toTuple intervals
% 		{List.mapInd {List.make 41}
% 		 fun {$ I _} interval(interval:I-1) end}}



   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Database transformation
%%%
   
   
   local
      %% TODO: revise
      /** %% Only transform pairs (e.g. 'C'#'/'), but leave integers (PCs) and records (ratios, e.g., 1#1) untouched.
      %% */
      fun {Transform MyPitch}
	 if {IsRecord MyPitch} andthen {Record.all MyPitch GUtils.isAtom}
	 then {RegT.jiPC MyPitch}
	 else MyPitch end
      end
   in
      /** %% [Aux def] Expects a chord or scale declaration, and in case it contains symbolic notes names, these are replaced by their corresponding pitch class.  
      %% */
      fun {ToStandardDeclaration Decl}
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
   end

   proc {ReportRemovedEntry Why Entry}
      {Out.show removeDbEntry(Why Entry)}
%       {Out.show removeDbEntry({Out.recordToVS Entry})}
   end

   /** %% Removes any element in database Entries which occured already more early in X (i.e. there is an element for which the values at all ComparisonFeats are the same).
   %% */
   fun {RemoveDuplicateEntries Entries ComparisonFeats}
      fun {Aux Xs Accum}
	 case Xs of nil then {Reverse Accum}
	 else
	    EqualEntry = {LUtils.find Accum
			  fun {$ Previous}
			     {All ComparisonFeats
			      fun {$ Feat}
				 {GUtils.isEqual (Xs.1).Feat Previous.Feat}
			      end}
			  end}
	 in
	    if EqualEntry \= nil
	    then
	       {ReportRemovedEntry dublicateEntry equal(Xs.1 EqualEntry)}
	       {Aux Xs.2 Accum}
	    else {Aux Xs.2 Xs.1|Accum}
	    end
	 end
      end
   in
      {Aux Entries nil}
   end

   /** %% Expects a chord/scale/interval database DB (tuple of records) and removes all those entries from the database in which the error of some JI pitch class exceeds MaxError (an int). Also, entries that do not contain all feats in RequiredFeats are removed (feats not listed in RequiredFeats are removed as well). Further, any entry for which ComparisonFeats are the same in a previous entry are removed.
   %% */
   fun {FilterDB DB MaxError RequiredFeats ComparisonFeats}
      %% Returns true is errors OK
      fun {CheckError X}
	 if {IsRecord X} andthen {HasFeature X ji_error}
	 then {Abs X.ji_error.1} < MaxError
	 else true
	 end
      end
      fun {CheckFeats X}
	 %% all required feats are there
	 {All RequiredFeats fun {$ Feat} {HasFeature X Feat} end}
      end
   in
      %% translate DB to list and then back to tuplet in order to avoid "empty" indices
      {List.toTuple {Label DB}
       {RemoveDuplicateEntries
	{Map {Filter {Record.toList DB} 
	      fun {$ Entry}
		 %% NOTE: 'comment' is required feat
		 %% true of OK entry
		 B1 = {Record.all Entry.comment
		       fun {$ X}
			  if {IsList X} then {All X CheckError}
			  else {CheckError X}
			  end
		       end}
		 B2 = {CheckFeats Entry}
	      in
		 if {Not B1} then {ReportRemovedEntry exceedingError Entry} end
		 if {Not B2} then {ReportRemovedEntry requiredFeatsMissing Entry} end
		 B1 andthen B2
	      end}
	 fun {$ R}
	    %% remove any non-required feats
	    {Record.subtractList R
	     {LUtils.remove {Arity R}
	      fun {$ Feat} {Member Feat RequiredFeats} end}}
	 end}
	ComparisonFeats}}
   end


   /** %% Returns a full database specification that can be given as argument to HS.db.setDB. MakeFullDB internally generates a regular temperament (using HS.db.makeRegularTemperament), and "matches" the chord/scale/interval databases defined in this functor so that they are approximated to (i.e. can be played by) this regular temperament. Dublicate database entries (e.g., if the approximation results in the same pitch classes) are removed (reported at standard out).
   %%
   %% Args:
   %% 'generators': list of generators (ints). See HS.db.makeRegularTemperament for details.
   %% 'generatorFactors': list of generator factor specifications (pairs of ints). See HS.db.makeRegularTemperament for details.
   %% 'generatorFactorsOffset' (default 0): See HS.db.makeRegularTemperament for details.
   %% 'pitchesPerOctave' (default 1200): See HS.db.makeRegularTemperament for details.
   %% 'removeFromTemperament' (default nil): list of pitch classes (ints, or ratios i.e. floats or pairs of ints) that would be part of the temperament as defined by 'generators' and 'generatorFactors' but that nevertheless should be excluded from the resulting temperament. 
   %% 'maxError' (int): maximum error of any original JI pitch classes in a tempered chord/scale/interval. The error's unit of measurement depends on pitchesPerOctave. Any database entry with an approximation error that exceeds maxError is removed (reported at standard out).
   %% 'minOccurrences': the minimum number an interval needs to occur in order to be taken into account. 
   %%
   %% 'chords'/'scales'/'intervals' (each tuple of records, default of each is unit): additional chord/scale/interval database entries that are appended before the entries defined internally in this functor.
   %% 'chordFeatures'/'scaleFeatures'/'intervalFeatures' (each list of atoms, default of each is nil): additional features required in database entries (example: essentialPitchClasses). Database entries that do not contain all the required features are removed from the output (reported at standard out).
   %%
   %% 'accidentalOffset'
   %% 'octaveDomain'
   %% 
   %% See examples/RegularTemperaments.oz for usage examples.
   %%
   %% Note: in current implementation chord and scale database may contain entries where all the chord/scale intervals are available in the temperament, but not in the arrangement of the chord/scale -- so some chord/scale database entries are actually impossible in the temperament.
   %% 
   %%
   %% */
   fun {MakeFullDB Args}
      %% TODO: revise defaults: should generators and generatorFactors be required args?
      Default = unit(generators:[702 386] % 5-limit JI
		     %% paris of min/max to define full PC set of temperament
		     generatorFactors:[~10#10 ~2#2]
		     generatorFactorsOffset:0
		     pitchesPerOctave:1200 % 120000
		     removeFromTemperament: nil
		     accidentalOffset:2*100 % TODO: revise	
		     %% corresponds to MIDI pitch range 12-127+ (for pitchesPerOctave=12)
		     octaveDomain:0#9
		     %% TODO: if not given, but pitchesPerOctave are given adjust automatically
		     maxError:30 % unit depends on pitchesPerOctave
		     minOccurrences: 4
		     chords:unit
		     scales:unit
		     intervals:unit
		     chordFeatures: nil
		     scaleFeatures: nil
		     intervalFeatures: nil
		    )
      As = {Adjoin Default Args}
      %% list
      FullTemperament_L = {HS.db.makeRegularTemperament As.generators As.generatorFactors
			   unit(generatorFactorsOffset: As.generatorFactorsOffset
				pitchesPerOctave: As.pitchesPerOctave)}
      %% tuple
      FullTemperament_T = {List.toTuple unit FullTemperament_L}
      RemoveFromTemperament_Ints = {Map As.removeFromTemperament
				    fun {$ X}
				       if {IsInt X} then X
				       else {HS.db.ratioToRegularTemperamentPC X
					     unit(temperament: FullTemperament_T
						  pitchesPerOctave:As.pitchesPerOctave
						  minOccurrences: As.minOccurrences)}
				       end
				    end}
      Temperament = {List.toTuple unit
		     {LUtils.remove FullTemperament_L
		      fun {$ X} {Member X RemoveFromTemperament_Ints} end}}
   in
      unit(
	 chordDB:{FilterDB {Record.map {Tuple.append As.chords Chords}
			    fun {$ X}
			       {HS.db.ratiosInDBEntryToPCs2 {ToStandardDeclaration X}
				As.pitchesPerOctave Temperament unit(minOccurrences: As.minOccurrences)}
			    end}
		  As.maxError
		  {Append [pitchClasses roots comment] As.chordFeatures}
		  [pitchClasses roots]}
	 scaleDB:{FilterDB {Record.map {Tuple.append As.scales Scales} 
			    fun {$ X}
			       {HS.db.ratiosInDBEntryToPCs2 {ToStandardDeclaration X}
				As.pitchesPerOctave Temperament unit(minOccurrences: As.minOccurrences)}
			    end}
		  As.maxError
		  {Append [pitchClasses roots comment] As.scaleFeatures}
		  [pitchClasses roots]}
	 intervalDB:{FilterDB {Record.map {Tuple.append As.intervals Intervals} 
			       fun {$ X}
				  {HS.db.ratiosInDBEntryToPCs2 X
				   As.pitchesPerOctave Temperament unit(minOccurrences: As.minOccurrences)}
			       end}
		     As.maxError
		     {Append [interval comment] As.intervalFeatures}
		     [interval]}
	 pitchesPerOctave: As.pitchesPerOctave
	 accidentalOffset: As.accidentalOffset
	 octaveDomain: As.octaveDomain
	 generators: As.generators
	 generatorFactors: As.generatorFactors
	 generatorFactorsOffset: As.generatorFactorsOffset
	 temperament: Temperament
	 )
   end

   
end

