
/** %% Defines databases for chords, scales and intervals in 22 equal temperament. 
%% Internally, database entries are often defined by ratios (using notation X#Y for X/Y) to make them more comprehensible and portable to other temperaments. Alternatively, chords and scales are notated with conventional symbolic note names (see function PC). In any case, the databases focus on chords, scales and intervals which are close to just intonation in 22 ET.
%%
%% The entries of these databases are show in common music notation in PDF files in the folder <a href="../doc-DB">../doc-DB</a>. For further details,please visit the source at ../source/DB.oz or browse/inspect the value of ET22.db.fullDB to read the actual databases.
%%
%% Note: some chords share the same pitch classes, but differ in their root. Nevertheless, these have different database entries, as they can also differ in other respects (e.g., different names, different set of 'essentialPitchClasses' or different set of 'dissonances'). The following chord pairs only differ in their root: 'minor 7th'/'minor 6th', 'subdiminished 7th (1)'/'subdiminished 7th (2)', 'subharmonic 6th'/'half subdiminished 7th', 'subminor 7th'/'supermajor 6th', 'subminor 7th suspended 4th'/'supermajor 6th suspended 2nd'
%%
%% Note: some chords are subsets of others. These are listed in the following, using < to denote subset relations.
%% 'major' < 'harmonic 7th no 5' < 'harmonic 7th' < 'harmonic 9th', ....
%% [there are more, which are not yet listed here]
%%
%% Note: most chords have names, and their index can be generated with {HS.db.getChordIndex 'my name'}. Yet, some are without names and can only be referred to via their index.
%%
%% */


%%
%% TODO:
%%
%% - NOTE: chords in DB often given such that root is \= 0. Is that OK?
%% - add feature: otonal or utonal (some are a mix.., stuff like 4:5:25 is otonal)
%% - add chords from hexard in bottom left corner of Dave Keenan's pict
%% - check whether chord pairs in graph, e.g., chords with same name (e.g., 'subdiminished 7th (2)') differ in root and nothing else.
%%    use names to confirm whether I put in correct chords
%% - decide: shall I combine those siblings into single chord: constraining chord index, e.g., with Morphology constraints may make more sense then.  
%%
%% - add harmonicity measurements to chords
%% - ?? mark dissonant chord tones (e.g., in 4:5:25 the 25 is dissonant)
%% - ?? add 'silent' roots (e.g., 5:6:7 and 6:7:9 both have silent root 4) 
%%
%% - revise chord feature essentialPitchClasses: I simply removed the fifth in common chords. But some may be wrong, and many chords I left as they are for now. 
%%
%% 
%% Howto get harmonicity measurements from Scala
%%
%        create scale (chord/intervals are also scales) from ratios in Scale (e.g., with new or edit scale), then do 
%        SHOW DATA
%
%        extract the interesting numbers from the printout, e.g., 
%        Euler's gradus suavitatis, Vogel's harmonic complexity, Sum of Tenney's harmonic distance, Wilson's harmonic complexity, Sum of Mann's harmonic distance
%
%        alternative for single intervals:
%        SHOW/ATTRIBUTE pitch <pitch>
%        Show the value of all attributes for the given pitch (regardless of scale context)
%
%        for single intervals I also wrote a litte script for showing a few measurements
%        /Applications/Scala/T_Harmonicity.cmd
%       
%        NOTE: these values can only be computed from ratios! 
%
%%
%%

functor 
   
import
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   ET22 at '../ET22.ozf'
   
export   
   fullDB:DB

%   ToStandardDeclaration
  
define

   %%
   %% source for many chords below: Dave Keenan, gif file "Approximate 9-limit chords availalbe in Paul Erlich's decatonic scales"
   %%
   %% Note: these chords are given as ratios, because in the context
   %% of a chord the ratio perception is less ambiguous. Consequently,
   %% harmonicity measurements can be taken.
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
	       chord(pitchClasses:[5#1 6#1 7#1]
		     roots:[5#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[5#1 6#1 7#1]
		     comment:'otonal subdiminished')  
	       chord(pitchClasses:[1#5 1#6 1#7]
		     roots:[1#7]    
%				dissonanceDegree:2
		     essentialPitchClasses:[1#5 1#6 1#7]
		     comment:'utonal subdiminished')  
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


	       %%
	       %% tetrads, pentads...
	       %%

	       
	       chord(pitchClasses:[4#1 5#1 6#1 15#2]
		     roots:[4#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[4#1 5#1 15#2]
		     comment:'major 7th')
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
		     comment:'minor 6th')
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
	       chord(pitchClasses:[1#4 1#5 1#6 1#7]
		     roots:[1#7]    
%				dissonanceDegree:2
		     essentialPitchClasses:[1#4 1#5 1#6 1#7]
		     comment:'half subdiminished 7th')  
	       chord(pitchClasses:[6#1 7#1 9#1 10#1]
		     roots:[6#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[6#1 7#1 9#1 10#1]
		     comment:'subminor major 6th')  
	       chord(pitchClasses:[5#1 6#1 7#1 9#1]
		     roots:[1#9]    
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
	       chord(pitchClasses:[4#1 6#1 7#1 9#2]
		     roots:[4#1]    
%				dissonanceDegree:2
		     essentialPitchClasses:[4#1 6#1 7#1 9#2]
		     comment:'subminor 7th suspended 2nd')  
	       chord(pitchClasses:[1#4 1#6 2#7 2#9]
		     roots:[1#6]    
%				dissonanceDegree:2
		     essentialPitchClasses:[1#4 1#6 2#7 2#9]
		     comment:'supermajor 6th suspended 4th')

	       
	       chord(pitchClasses:['C' 'E\\' 'G' 'Bb' 'Eb']
		     roots:['C']    
%				dissonanceDegree:2
		     essentialPitchClasses:['C' 'E\\' 'G' 'Bb' 'Eb']
		     comment:'')  
	       chord(pitchClasses:['C' 'D#\\' 'G' 'A' 'D']
		     roots:['C']    
%				dissonanceDegree:2
		     essentialPitchClasses:['C' 'D#\\' 'G' 'A' 'D']
		     comment:'')
	       
	       chord(pitchClasses:['C' 'E\\' 'G' 'A' 'D']
		     roots:['C']    
%				dissonanceDegree:2
		     essentialPitchClasses:['C' 'E\\' 'G' 'A' 'D']
		     comment:'')  
	       )
   
   %%
   %% Source of these scales: Paul Erlich (1998). Tuning, Tonality,
   %% and Twenty-Two-Tone Temperament. Xenharmonikon 17.
   %% 
   
   Scales = scales(
	       
	       scale(pitchClasses:[0 2 4 7 9 11 13 16 18 20]
		     roots:[0]
		     comment:'standard pentachordal major')
	       scale(pitchClasses:[0 2 4 7 9 11 13 15 18 20]
		     roots:[0]
		     comment:'static symmetrical major')
	       scale(pitchClasses:[0 2 5 7 9 11 13 15 18 20]
		     roots:[0]
		     comment:'alternate pentachordal major')
	       scale(pitchClasses:[0 2 5 7 9 11 13 16 18 20]
		     roots:[0]
		     comment:'dynamic symmetrical major')
	       
	       scale(pitchClasses:[0 2 4 6 9 11 13 15 17 19]
		     roots:[0]
		     comment:'standard pentachordal minor')
	       scale(pitchClasses:[0 2 4 6 9 11 13 15 17 20]
		     roots:[0]
		     comment:'static symmetrical minor')
	       scale(pitchClasses:[0 2 4 6 8 11 13 15 17 20]
		     roots:[0]
		     comment:'alternate pentachordal minor')
	       scale(pitchClasses:[0 2 4 6 8 11 13 15 17 19]
		     roots:[0]
		     comment:'dynamic symmetrical minor')
	       )


   %% For ratios corresponding to these intervals see Erlich (1998,
   %% rev. 2002). "Tuning, Tonality, and Twenty-Two-Tone Temperament".
   %% I did not add the ratios to the interval specs, because the
   %% mapping is too much 'overloaded' in decatonic music. Some
   %% interval mappings are unambiguous, but many are not.
   %%
   %% Note: as the ratios corresponding to these intervals are
   %% ambiguous, no (ratio-based) harmonicity measurements were taken.

   %% for ratios see Erlich "Tuning, Tonality, and Twenty-Two-Tone Temperament"
   Intervals = intervals(interval(interval:0 % 1#1
				  % dissonanceDegree:0
				 )
			 %% quartertone
			 interval(interval:1 % 32#31
				  % dissonanceDegree:0
				 )
			 interval(interval:2 % 16#15 18#17 17#16 15#14
				  % dissonanceDegree:0
				 )
			 interval(interval:3 % 10#9 12#11 11#10
				  % dissonanceDegree:0
				 )
			 interval(interval:4 % 8#7 9#8 17#15 
				  % dissonanceDegree:0
				 )
			 interval(interval:5 % 7#6 20#17
				  % dissonanceDegree:0
				 )
			 interval(interval:6 % 6#5 17#14 11#9
				  % dissonanceDegree:0
				 )
			 interval(interval:7 % 5#4 
				  % dissonanceDegree:0
				 )
			 interval(interval:8 % 9#7 14#11 22#17
				  % dissonanceDegree:0
				 )
			 interval(interval:9 % 4#3 
				  % dissonanceDegree:0
				 )
			 interval(interval:10 % 11#8 15#11 
				  % dissonanceDegree:0
				 )
			 interval(interval:11 % 7#5 10#7 24#17 17#12 
				  % dissonanceDegree:0
				 )
			 interval(interval:12 % 16#11 22#15
				  % dissonanceDegree:0
				 )
			 interval(interval:13 % 3#2 
				  % dissonanceDegree:0
				 )
			 interval(interval:14 % 17#11 14#9 11#7
				  % dissonanceDegree:0
				 )
			 interval(interval:15 % 8#5
				  % dissonanceDegree:0
				 )
			 interval(interval:16 % 5#3 18#11 28#17
				  % dissonanceDegree:0
				 )
			 interval(interval:17 % 12#7 17#10
				  % dissonanceDegree:0
				 )
			 interval(interval:18 % 7#4 30#17 16#9
				  % dissonanceDegree:0
				 )
			 interval(interval:19 % 9#5 20#11 11#6
				  % dissonanceDegree:0
				 )
			 interval(interval:20 % 15#8 28#15 32#17 17#9 
				  % dissonanceDegree:0
				 )
			 interval(interval:21 %
				  % dissonanceDegree:0
				 )
			)

   
   PitchesPerOctave=22
   AccidentalOffset=3		% NOTE: no double accidental
   %% corresponds to MIDI pitch range 12-127+ (for pitchesPerOctave=12)
   OctaveDomain=0#9

   
   local
      /** %% Only transform atoms (e.g. 'C#'), but leave integers (PCs) and records (ratios, e.g., 1#1) untouched.
      %% */
      fun {Transform MyPitch}
	 if {IsAtom MyPitch} then {ET22.pc MyPitch} else MyPitch end
      end
   in
      /** %% [Aux def] Expects a chord or scale declaration, and in case it contains symbolic notes names, these are replaced by their corresponding 31 ET pitch class.  
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

