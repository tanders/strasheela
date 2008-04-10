
/** %% Defines databases for chords, scales and intervals in 22 equal temperament. 
%% Internally, database entries are often defined by ratios (using notation X#Y for X/Y) to make them more comprehensible and portable to other temperaments. Alternatively, chords and scales are notated with conventional symbolic note names (see function PC). In any case, the databases focus on chords, scales and intervals which are close to just intonation in 22 ET.
%%
%% Please visit the source as ../source/DB.oz or browse/inspect the value of ET22.db.fullDB to read the actual databases. 
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
%				dissonanceDegree:2
		     comment:'major')
	       chord(pitchClasses:[1#6 1#5 1#4]
		     roots:[1#6]    
%				dissonanceDegree:2
		     comment:'minor')  
	       chord(pitchClasses:[5#1 6#1 7#1]
		     roots:[5#1]    
%				dissonanceDegree:2
		     comment:'otonal subdiminished')  
	       chord(pitchClasses:[1#5 1#6 1#7]
		     roots:[1#7]    
%				dissonanceDegree:2
		     comment:'utonal subdiminished')  
	       chord(pitchClasses:[4#1 5#1 25#4]
		     roots:[4#1]    
%				dissonanceDegree:2
		     comment:'augmented')
	       %% !!
	       chord(pitchClasses:[6#1 7#1 9#1]
		     roots:[6#1]    
%				dissonanceDegree:2
		     comment:'subminor')  
	       chord(pitchClasses:[1#6 1#7 1#9]
		     roots:[1#9]    
%				dissonanceDegree:2
		     comment:'supermajor')
	       
	       %% alt names:
	       %% 'Italian augmented 6th', 'major subminor 7th no 5th'
	       chord(pitchClasses:[4#1 5#1 7#1]
		     roots:[4#1]    
%				dissonanceDegree:2
		     comment:'harmonic 7th no 5')  


	       %%
	       %% tetrads, pentads...
	       %%

	       
	       chord(pitchClasses:[4#1 5#1 6#1 15#2]
		     roots:[4#1]    
%				dissonanceDegree:2
		     comment:'major 7th')
	       %% same as minor 6th, only root differs
	       chord(pitchClasses:[1#6 1#5 1#4 3#10]
		     roots:[1#6]    
%				dissonanceDegree:2
		     comment:'minor 7th')  
	       %% same as minor 7th, only root differs
	       chord(pitchClasses:[4#1 5#1 6#1 10#3]
		     roots:[4#1]    
%				dissonanceDegree:2
		     comment:'minor 6th')  
	       chord(pitchClasses:[5#1 6#1 7#1 42#5] 
		       roots:[5#1]    
%				dissonanceDegree:2
		       comment:'subdiminished 7th (1)')  
	       chord(pitchClasses:[1#7 1#6 1#5 7#30]
		       roots:[1#7]    
%				dissonanceDegree:2
		     comment:'subdiminished 7th (2)')
	       %% alt name:
	       %% 'French augmented'
	       chord(pitchClasses:[4#1 5#1 40#7 50#7]
		       roots:[4#1]    
%				dissonanceDegree:2
		       comment:'major subdiminished')  
	       chord(pitchClasses:[4#1 5#1 7#1 40#7]
		       roots:[4#1]    
%				dissonanceDegree:2
		     comment:'subminor 7th')
	       %% alt names:
	       %% 'major subminor 7th', 'German augmented 6th'
	       chord(pitchClasses:[4#1 5#1 6#1 7#1]
		       roots:[4#1]    
%				dissonanceDegree:2
		     comment:'harmonic 7th')
	       %% alt names:
	       %% 'minor supermajor 6th', 'minor diminished 7th'
	       chord(pitchClasses:[1#4 1#5 1#6 2#7]
		       roots:[1#6]    
%				dissonanceDegree:2
		       comment:'subharmonic 6th')
	       chord(pitchClasses:[1#4 1#5 1#6 1#7]
		       roots:[1#7]    
%				dissonanceDegree:2
		       comment:'half subdiminished 7th')  
	       chord(pitchClasses:[6#1 7#1 9#1 10#1]
		       roots:[6#1]    
%				dissonanceDegree:2
		       comment:'subminor major 6th')  
	       chord(pitchClasses:[5#1 6#1 7#1 9#1]
		       roots:[1#9]    
%				dissonanceDegree:2
		     comment:'supermajor minor 7th')
	       %% alt name
	       %% 'major subminor 7th 9th' 
	       chord(pitchClasses:[4#1 5#1 6#1 7#1 9#1]
		       roots:[4#1]    
%				dissonanceDegree:2
		     comment:'harmonic 9th')
	       %% alt name
	       %% 'supermajor minor 7th 9th'
	       chord(pitchClasses:[1#4 1#5 1#6 1#7 1#9]
		       roots:[1#9]    
%				dissonanceDegree:2
		       comment:'subharmonic 9th')  
	       chord(pitchClasses:[6#1 7#1 9#1 21#2]
		       roots:[6#1]    
%				dissonanceDegree:2
		       comment:'subminor 7th')  
	       chord(pitchClasses:[1#6 1#7 1#9 2#21]
		       roots:[1#9]    
%				dissonanceDegree:2
		       comment:'supermajor 6th')  
	       chord(pitchClasses:[16#3 4#1 6#1 7#1]
		       roots:[4#1]    
%				dissonanceDegree:2
		       comment:'subminor 7th suspended 4th')  
	       chord(pitchClasses:[1#6 1#4 3#16 2#7]
		       roots:[1#6]    
%				dissonanceDegree:2
		       comment:'supermajor 6th suspended 2nd')
	       chord(pitchClasses:[4#1 6#1 7#1 9#2]
		       roots:[4#1]    
%				dissonanceDegree:2
		     comment:'subminor 7th suspended 2nd')  
	       chord(pitchClasses:[1#4 1#6 2#7 2#9]
		       roots:[1#6]    
%				dissonanceDegree:2
		     comment:'supermajor 6th suspended 4th')

	       
	       chord(pitchClasses:['C' 'E\\' 'G' 'Bb' 'Eb']
		       roots:['C']    
%				dissonanceDegree:2
		       comment:'')  
	       chord(pitchClasses:['C' 'D#\\' 'G' 'A' 'D']
		       roots:['C']    
%				dissonanceDegree:2
		     comment:'')
	       
	       chord(pitchClasses:['C' 'E\\' 'G' 'A' 'D']
		       roots:['C']    
%				dissonanceDegree:2
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

   Intervals = intervals(interval(interval:0 
				  % dissonanceDegree:0
				 )
			 %% quartertone
			 interval(interval:1
				  % dissonanceDegree:0
				 )
			 interval(interval:2 % 16#15 18#17 17#16 15#14
				  % dissonanceDegree:0
				 )
			 interval(interval:3 % 10#9 12#11 11#10
				  % dissonanceDegree:0
				 )
			 interval(interval:4
				  % dissonanceDegree:0
				 )
			 interval(interval:5
				  % dissonanceDegree:0
				 )
			 interval(interval:6
				  % dissonanceDegree:0
				 )
			 interval(interval:7
				  % dissonanceDegree:0
				 )
			 interval(interval:8
				  % dissonanceDegree:0
				 )
			 interval(interval:9
				  % dissonanceDegree:0
				 )
			 interval(interval:10
				  % dissonanceDegree:0
				 )
			 interval(interval:11
				  % dissonanceDegree:0
				 )
			 interval(interval:12
				  % dissonanceDegree:0
				 )
			 interval(interval:13
				  % dissonanceDegree:0
				 )
			 interval(interval:14
				  % dissonanceDegree:0
				 )
			 interval(interval:15
				  % dissonanceDegree:0
				 )
			 interval(interval:16
				  % dissonanceDegree:0
				 )
			 interval(interval:17
				  % dissonanceDegree:0
				 )
			 interval(interval:18
				  % dissonanceDegree:0
				 )
			 interval(interval:19
				  % dissonanceDegree:0
				 )
			 interval(interval:20
				  % dissonanceDegree:0
				 )
			 interval(interval:21
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

