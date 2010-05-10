

/** %% Defines databases for chords, scales and intervals in arbitrary octave-repeating regular temperaments.
%% NOTE: recomemndation: reduce the domain of all pitch classes (e.g., of notes, chord/scale roots and transpositions) to the tones of the current temperament. 
%% */

%%
%% TODO:
%%
%% - procedure that expects full score and reduces the domain of all PCs in score (e.g., of notes, chord/scale roots and transpositions) to the tones of the current temperament. 
%%
%% - temporarily, all chords/scales/intervals are defined for JI only: generalise!
%%   see [[file:~/oz/music/Strasheela/strasheela/trunk/strasheela/others/TODO/Strasheela-TODO.org::*%20Function%20mapping%20of%20ratios%20to%20corresponding%20cent%20values%20for%20a%20given%20regular%20temperament][!! Function/mapping of ratios to corresponding cent values for a given regular temperament]]
%%
%% - make PitchesPerOctave controllable by arg (so cent or millicent are possible)
%%

functor 
   
import
   Browser(browse:Browse) % for debugging
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
%    LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
%    MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
%    Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   RegT at '../RegT.ozf'
   
export   
%    fullDB:DB
   
   MakeFullDB

define
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Chord, Scale and Interval Database Definition 
%%%

   Chords = chords(
	       chord(pitchClasses:[4#1 5#1 6#1]
		     roots:[4#1]
% 		     essentialPitchClasses:[]
		     comment:'major')	       
	       chord(pitchClasses:[6#6 6#5 6#4] % 'C' 'Es' 'G'
		     roots:[6#6]
		     essentialPitchClasses:[6#6 6#5]
%				dissonanceDegree:2
		     comment:'minor')
	       )

   Scales = scales(
	       scale(pitchClasses:[1#1 9#8 5#4 4#3 3#2 5#3 15#8]
		     roots:[1#1]
		     comment:'major')

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
      /** %% Only transform atoms (e.g. 'C#'), but leave integers (PCs) and records (ratios, e.g., 1#1) untouched.
      %% */
      fun {Transform MyPitch}
	 if {GUtils.isAtom MyPitch} then {RegT.pc MyPitch}
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


   /** %% Expects a chord/scale/interval database (tuple of records) and removes all those entries from the database in which the error of some JI pitch class exceeds MaxError (an int).
   %% */
   fun {FilterDB DB MaxError}
      %% Returns true is errors OK
      fun {CheckError X}
	 if {IsRecord X} andthen {HasFeature X ji_error}
	 then {Abs X.ji_error.1} < MaxError
	 else true
	 end
      end
   in
      {Record.filter DB
       fun {$ Entry}
	  if {HasFeature Entry comment}
	  then
	     %% true of OK entry
	     B = {Record.all Entry.comment
		  fun {$ X}
		     if {IsList X} then {All X CheckError}
		     else {CheckError X}
		     end
		  end}
	  in
	     %% TMP?
	     if {Not B} then {Browse removeDbEntry(Entry)} end
	     B
	  else true
	  end
       end}
   end


   %% TODO:
   %% - def
   %% - doc
   fun {MakeFullDB Args}
      %% TODO: revise defaults: should generators and generatorFactors be required args?
      Default = unit(generators:[702 386] % 5-limit JI
		     %% paris of min/max to define full PC set of temperament
		     generatorFactors:[~10#10 ~2#2]
		     generatorFactorsOffset:0
		     pitchesPerOctave:1200 % 120000
		     accidentalOffset:2*100 % TODO: revise	
		     %% corresponds to MIDI pitch range 12-127+ (for pitchesPerOctave=12)
		     octaveDomain:0#9
		     maxError:30 % unit depends on pitchesPerOctave
		    )
      As = {Adjoin Default Args}
      Temperament = {List.toTuple unit
		     {HS.db.makeRegularTemperament As.generators As.generatorFactors
		      unit(pitchesPerOctave:As.pitchesPerOctave)}}
   in
      unit(
	 chordDB:{FilterDB {Record.map Chords
			    fun {$ X}
			       {HS.db.ratiosInDBEntryToPCs2 {ToStandardDeclaration X}
				As.pitchesPerOctave Temperament}
			    end}
		  As.maxError}
	 scaleDB:{FilterDB {Record.map Scales
			    fun {$ X}
			       {HS.db.ratiosInDBEntryToPCs2 {ToStandardDeclaration X}
				As.pitchesPerOctave Temperament}
			    end}
		  As.maxError}
	 intervalDB:{FilterDB {Record.map Intervals
			       fun {$ X} {HS.db.ratiosInDBEntryToPCs2 X As.pitchesPerOctave
					  Temperament} end}
		     As.maxError}
	 pitchesPerOctave: As.pitchesPerOctave
	 accidentalOffset: As.accidentalOffset
	 octaveDomain: As.octaveDomain
	 )
   end

%    %% TMP remove this def
%    %% TODO: replace by function
%    /** %% Full database declaration defined in this functor. 
%    %% */
%    DB = unit(
% 	   chordDB:{Record.map Chords
% 		    fun {$ X}
% 		       {HS.db.ratiosInDBEntryToPCs {ToStandardDeclaration X}
% 			PitchesPerOctave}
% 		    end}
% 	   scaleDB:{Record.map Scales
% 		    fun {$ X}
% 		       {HS.db.ratiosInDBEntryToPCs {ToStandardDeclaration X}
% 			  PitchesPerOctave}
% 		    end}
% 	   intervalDB:{Record.map Intervals
% 		       fun {$ X} {HS.db.ratiosInDBEntryToPCs X PitchesPerOctave} end}
% 	   pitchesPerOctave: PitchesPerOctave
% 	   accidentalOffset: AccidentalOffset
% 	   octaveDomain: OctaveDomain)
   
end

