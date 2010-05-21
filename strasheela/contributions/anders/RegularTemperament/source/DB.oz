

/** %% Defines databases for chords, scales and intervals in arbitrary octave-repeating regular temperaments.
%% NOTE: recommendation: reduce the domain of all pitch classes (e.g., of notes, chord/scale roots and transpositions) to the tones of the current temperament. (this is not necessary if all pitch classes are already reduced to some determined scale :)
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
%% - add those chords of ET31 DB that are still missing
%%
%% - !! Change RegT.db.makeFullDB so that it allows to specify additional features (e.g., essentialPitchClasses) and to automatically filter out those database entries that do not have these features.
%%
%% - ?? add essential PCs to La Monte Young chords? 
%%
%% - after pitch classes can be specified with symbolic notation then go through all existing databases for material to add
%%
%% - create interval database
%%

functor 
   
import
%    Browser(browse:Browse) % for debugging
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
%    MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
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
   %% 'maxError' (int): maximum error of any original JI pitch classes in a tempered chord/scale/interval. The error's unit of measurement depends on pitchesPerOctave. Any database entry with an approximation error that exceeds maxError is removed (reported at standard out).
   %%
   %% 'chords'/'scales'/'intervals' (each tuple of records, default of each is unit): additional chord/scale/interval database entries that are appended before the entries defined internally in this functor.
   %% 'chordFeatures'/'scaleFeatures'/'intervalFeatures' (each list of atoms, default of each is nil): additional features required in database entries (example: essentialPitchClasses). Database entries that do not contain all the required features are removed from the output (reported at standard out).
   %%
   %% 'accidentalOffset'
   %% 'octaveDomain'
   %% 
   %% See examples/RegularTemperaments.oz for usage examples.
   %% */
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
		     %% TODO: if not given, but pitchesPerOctave are given adjust automatically
		     maxError:30 % unit depends on pitchesPerOctave
		     chords:unit
		     scales:unit
		     intervals:unit
		     chordFeatures: nil
		     scaleFeatures: nil
		     intervalFeatures: nil
		    )
      As = {Adjoin Default Args}
      Temperament = {List.toTuple unit
		     {HS.db.makeRegularTemperament As.generators As.generatorFactors
		      unit(generatorFactorsOffset: As.generatorFactorsOffset
			   pitchesPerOctave: As.pitchesPerOctave)}}
   in
      unit(
	 chordDB:{FilterDB {Record.map {Tuple.append As.chords Chords}
			    fun {$ X}
			       {HS.db.ratiosInDBEntryToPCs2 {ToStandardDeclaration X}
				As.pitchesPerOctave Temperament}
			    end}
		  As.maxError
		  {Append [pitchClasses roots comment] As.chordFeatures}
		  [pitchClasses roots]}
	 scaleDB:{FilterDB {Record.map {Tuple.append As.scales Scales} 
			    fun {$ X}
			       {HS.db.ratiosInDBEntryToPCs2 {ToStandardDeclaration X}
				As.pitchesPerOctave Temperament}
			    end}
		  As.maxError
		  {Append [pitchClasses roots comment] As.scaleFeatures}
		  [pitchClasses roots]}
	 intervalDB:{FilterDB {Record.map {Tuple.append As.intervals Intervals} 
			       fun {$ X} {HS.db.ratiosInDBEntryToPCs2 X As.pitchesPerOctave
					  Temperament} end}
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

