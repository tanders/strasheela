

/** %% Defines databases for chords, scales and intervals in 41 equal temperament.
%% */

%%
%% TODO:
%%
%% - fix/revise chord roots (on tonal plexus)
%% - def intervals as JI intervals: extended version of La Monte Young's The Well-Tuned Piano tuning  
%%

functor 
   
import
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   ET41 at '../ET41.ozf'
   
export   
   fullDB:DB

define

   Chords = chords(

	       %%
	       %% La Monte Young's The Well-Tuned Piano chords
	       %% source: Kyle Gann (1993). La Monte Young's The Well-Tuned Piano. Perspectives of New Music, 31(1), pp. 134-162.
	       %%
	       %% Note: Young's "distribution of the pitches over octaves" is lost in this pitch-class representation
	       %%

	       chord(pitchClasses:[4#1 6#1 7#1 9#1]
		     roots:[4#1]
% 		     essentialPitchClasses:[]
		     comment:'opening') % Full name: "The Opening Chord"
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
	       chord(pitchClasses:[14#1 18#1 24#1 27#1]
		       roots:[14#1] %% TODO:
% 		     essentialPitchClasses:[]
		     comment:'tamiar dream')
	       chord(pitchClasses:[12#1 14#1 18#1 21#1 27#1]
		       roots:[12#1] %% TODO:
% 		     essentialPitchClasses:[]
		       comment:'lost ancestral region')
	       chord(pitchClasses:[12#1 14#1 16#1 18#1 21#1]
		       roots:[12#1] %% TODO:
% 		     essentialPitchClasses:[]
		       comment:'brook')
	       chord(pitchClasses:[128#1 144#1 147#1 192#1 224#1]
		       roots:[128#1] %% TODO:
% 		     essentialPitchClasses:[]
		       comment:'pool')
	       
	       )

   
   %% source: Scala scales with 41 tones
   Scales = scales(
	       scale(pitchClasses:{Pattern.dxsToXs [4 3 3 4 3 4 3 4 3 3 4] 0}
		     roots:[0]
		     comment:'twelve-tone chromatic')
	       scale(pitchClasses:{Pattern.dxsToXs [4 3 4 2 4 3 4 4 2 4 3] 0}
		     roots:[0]
		     comment:'just chromatic')
	       scale(pitchClasses:{Pattern.dxsToXs [7 7 3 7 7 7] 0}
		     roots:[0]
		     comment:'major')
	       scale(pitchClasses:{Pattern.dxsToXs [7 3 7 7 3 7] 0}
		     roots:[0]
		     comment:'minor')
	       scale(pitchClasses:{Pattern.dxsToXs [7 6 4 7 6 7] 0}
		     roots:[0]
		     comment:'just major')
	       scale(pitchClasses:{Pattern.dxsToXs [7 4 6 7 4 6] 0}
		     roots:[0]
		     comment:'natural minor')
	       scale(pitchClasses:{Pattern.dxsToXs [7 4 6 7 6 7] 0}
		     roots:[0]
		     comment:'melodic minor')
	       scale(pitchClasses:{Pattern.dxsToXs [7 4 6 7 4 9] 0}
		     roots:[0]
		     comment:'harmonic minor')
	       scale(pitchClasses:{Pattern.dxsToXs [7 6 4 7 4 9] 0}
		     roots:[0]
		     comment:'harmonic major')
	       scale(pitchClasses:{Pattern.dxsToXs [3 4 3 3 4 3 4 3 3 4 3] 0}
		     roots:[0]
		     comment:'schismic')
	       scale(pitchClasses:{Pattern.dxsToXs [7 2 2 2 7 2 2 2 7 2 2 2] 0}
		     roots:[0]
		     comment:'magic')	       
	       )

   %% TODO, see http://en.wikipedia.org/wiki/41_equal_temperament
%    Intervals = intervals(interval(interval: 1#1
% 				 )
% 			)
   %% TMP def
   Intervals = {List.toTuple intervals
		{List.mapInd {List.make 41}
		 fun {$ I _} interval(interval:I-1) end}}

   
   PitchesPerOctave=41
   AccidentalOffset=8		
   %% corresponds to MIDI pitch range 12-127+ (for pitchesPerOctave=12)
   OctaveDomain=0#9

   
   local
      /** %% Only transform atoms (e.g. 'C#'), but leave integers (PCs) and records (ratios, e.g., 1#1) untouched.
      %% */
      fun {Transform MyPitch}
	 if {GUtils.isAtom MyPitch} then {ET41.pc MyPitch}
	 else MyPitch end
      end
   in
      /** %% [Aux def] Expects a chord or scale declaration, and in case it contains symbolic notes names, these are replaced by their corresponding 41 ET pitch class.  
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
   DB = unit(
	   chordDB:{Record.map Chords
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

