
%%
%% NB: Chord comments were made for ET72.
%%

functor

import
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   HS at '../../HarmonisedScore.ozf'
   
export
   GetSelectedChords GetChords
   
define

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%
   %% Aux defs to transfer edit format into format for HS.db.ratiosInDBEntryToPCs
   %%
   
   fun {GetDenom Frac}
      Frac.2
   end
% fun {ArithmeticSeriesChordPCs Start Difference N}
%    {LUtils.arithmeticSeries Start Difference N}
% end 
% fun {ReciprocalArithmeticSeriesChordPCs Start Difference N}
%    {LUtils.reciprocalArithmeticSeries Start Difference N}
% end
   fun {MakeRootRatio MyChord}
      Denominator = {GetDenom MyChord.difference}
   in
      case MyChord.gender
      of arithmeticSeries 
      then 1#Denominator
      [] reciprocalArithmeticSeries
      then Denominator#1
      end
   end
   fun {MakeChordRatios MyChord}
      Number = MyChord.number
      Nom#Denom = MyChord.difference
      Difference = ({IntToFloat Nom} / {IntToFloat Denom})
   in
      case MyChord.gender
      of arithmeticSeries
      then {LUtils.arithmeticSeries 1.0 Difference Number}
      [] reciprocalArithmeticSeries
      then {LUtils.reciprocalArithmeticSeries 1.0 Difference Number}
      end
   end
   fun {MakeGender MyChord}
      case MyChord.gender
      of arithmeticSeries then 1
      [] reciprocalArithmeticSeries then 2
      end
   end
   fun {ToFullChordDBEntry MyChord}
      {Adjoin
       MyChord
       chord(pitchClasses:{MakeChordRatios MyChord}
	     roots:[{MakeRootRatio MyChord}]
	     gender:{MakeGender MyChord}
	     %% !! update as required
	     comment:{GUtils.takeFeatures MyChord [comment gender]})}
   end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%
   %% the databases
   %%

   %%
   %% Mini chord database (approved chords)
   %% 
   SelectedChordsEdit = chords(chord(gender:arithmeticSeries
				difference:1#4
				number:4		% kann auch 11 sein...
				dissonanceDegree:3
				clearnessOfColour:10
				resemblanceWithTradition:10
				comment:'Dominant 7 (Natursept)')
			  chord(gender:arithmeticSeries
				difference:1#5
				number:5	
				dissonanceDegree:4
				clearnessOfColour:10
				resemblanceWithTradition:8
				comment:'halb vermindert 7 akkord mit gr sext ?, aber ohne schwebung')
			  chord(gender:arithmeticSeries
				difference:1#6
				number:6		
				dissonanceDegree:5
				clearnessOfColour:9
				resemblanceWithTradition:6
				comment:'weich')
			  chord(gender:arithmeticSeries
				difference:1#8
				number:8		
				dissonanceDegree:6
				clearnessOfColour:8
				resemblanceWithTradition:8
				comment:'sehr deutlicher tiefer Kombinationston')
			  chord(gender:arithmeticSeries
				difference:2#7
				number: 4 %% 11		
				dissonanceDegree:5	
				clearnessOfColour:9
				resemblanceWithTradition:7
				comment:'aehnlich uebermaessiger mit grosser sept, aber schwebungsfrei -- andere Welt')
			  chord(gender:arithmeticSeries
				difference:3#10
				number:4		
				dissonanceDegree:4
				clearnessOfColour:7
				resemblanceWithTradition:7
				comment:'uebermaessig mit grosser sept, merkwuerdigerweise mit einem gefuehl von moll')
			  chord(gender:arithmeticSeries
				difference:5#18
				number:4
				dissonanceDegree:4
				clearnessOfColour:7
				resemblanceWithTradition:5
				comment:'Ein bischen Geruch von D7')
			  %%
			  chord(gender:reciprocalArithmeticSeries
				difference:1#4
				number:4
				dissonanceDegree:3 % ??
				clearnessOfColour:9
				resemblanceWithTradition:7 % ??
				comment:'rein halbvermindert, aber klingt ungewohnt')
			  chord(gender:reciprocalArithmeticSeries
				difference:1#5
				number:5
				dissonanceDegree:5
				clearnessOfColour:7
				resemblanceWithTradition:6
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:2#7
				number:4
				dissonanceDegree:5
				clearnessOfColour:8
				resemblanceWithTradition:1
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:3#10
				number:4
				dissonanceDegree:5
				clearnessOfColour:7
				resemblanceWithTradition:3
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:7#24
				number:4
				dissonanceDegree:4
				clearnessOfColour:7
				resemblanceWithTradition:5
				comment:'')
			 )

   
   %%
   %% Full chord database
   %% 
   ChordsEdit = chords(chord(gender:arithmeticSeries
				difference:1#4
				number:3		
				dissonanceDegree:2
				clearnessOfColour:10
				resemblanceWithTradition:10
				comment:'Dur')
			  chord(gender:arithmeticSeries
				difference:1#4
				number:4		% kann auch 11 sein...
				dissonanceDegree:3
				clearnessOfColour:10
				resemblanceWithTradition:10
				comment:'Dominant 7 (Natursept)')
			  /* chord(gender:arithmeticSeries
				   difference:1#3
				   number: 3 %% 8		
				   dissonanceDegree:2	% ?? quart in bass
				   clearnessOfColour:10
				   resemblanceWithTradition:10
				   disable:true
				   comment:'reiner quart sex') */
			  chord(gender:arithmeticSeries
				difference:1#5
				number:5	
				dissonanceDegree:4
				clearnessOfColour:10
				resemblanceWithTradition:8
				comment:'halb vermindert 7 akkord mit gr sext ?, aber ohne schwebung')
			  chord(gender:arithmeticSeries
				difference:1#6
				number:6		
				dissonanceDegree:5
				clearnessOfColour:9
				resemblanceWithTradition:6
				comment:'weich')
			  chord(gender:arithmeticSeries
				difference:1#7
				number:7		
				dissonanceDegree:6
				clearnessOfColour:6
				resemblanceWithTradition:5
				comment:'weicher cluster')
			  chord(gender:arithmeticSeries
				difference:1#8
				number:8		
				dissonanceDegree:6
				clearnessOfColour:8
				resemblanceWithTradition:8
				comment:'sehr deutlicher tiefer Kombinationston')
			  %%
			  /* %% !! spanning two octaves
			  chord(gender:arithmeticSeries
				difference:2#3
				number: 5
				dissonanceDegree:3
				clearnessOfColour:8
				resemblanceWithTradition:7 
				comment:'') */
			  chord(gender:arithmeticSeries
				difference:2#5
				number: 3 %% 8		
				dissonanceDegree:3
				clearnessOfColour:8
				resemblanceWithTradition:7 
				comment:'')
			  chord(gender:arithmeticSeries
				difference:2#7
				number: 4 %% 11		
				dissonanceDegree:5	
				clearnessOfColour:9
				resemblanceWithTradition:7
				comment:'aehnlich uebermaessiger mit grosser sept, aber schwebungsfrei -- andere Welt')
			  /* chord(gender:arithmeticSeries
				   difference:2#9
				   number: 5		
				   dissonanceDegree:6	% ??
				   clearnessOfColour:7
				   resemblanceWithTradition:7
				   comment:'etwas rauh, rollende Schwebung. Kann als unsauberer D7 missverstanden werden.') */
			  %% perhaps these clusters turn into something more characteristisch if voicing spans them over larger ambitus, i.e. avoids seconds etc.
			  chord(gender:arithmeticSeries
				difference:2#11
				number:6		
				dissonanceDegree:7
				clearnessOfColour:4
				resemblanceWithTradition:4	% if not cluster is tradition ;-)
				comment:'farbiger cluser, aufloesung in arppegio zeigt allerdings non-traditional intervals')
			  chord(gender:arithmeticSeries
				difference:2#13
				number:7		
				dissonanceDegree:7
				clearnessOfColour:4
				resemblanceWithTradition: 5 %%
				comment:'farbiger cluser, aufloesung in arppegio zeigt allerdings non-traditional intervals')
			  chord(gender:arithmeticSeries
				difference:2#15
				number:8		
				dissonanceDegree:7
				clearnessOfColour:4
				resemblanceWithTradition:4
				comment:'farbiger cluser')
			  %%
			  %% !! spanning two octaves
			  /* chord(gender:arithmeticSeries
				   difference:3#5
				   number:5		
				   dissonanceDegree:4
				   clearnessOfColour:8
				   resemblanceWithTradition:3
				   comment:'') */
			  chord(gender:arithmeticSeries
				difference:3#7
				number:3		
				dissonanceDegree:5
				clearnessOfColour:8
				resemblanceWithTradition:3
				comment:'almost identical to 2/5')
			  chord(gender:arithmeticSeries
				difference:3#8
				number:3		
				dissonanceDegree:4
				clearnessOfColour:8
				resemblanceWithTradition:8
				comment:'halbvermindeter ohne terz')
			  chord(gender:arithmeticSeries
				difference:3#10
				number:4		
				dissonanceDegree:4
				clearnessOfColour:7
				resemblanceWithTradition:7
				comment:'uebermaessig mit grosser sept, merkwuerdigerweise mit einem gefuehl von moll')
			  /* chord(gender:arithmeticSeries
				   difference:3#11
				   number:4		
				   dissonanceDegree:5
				   clearnessOfColour:8
				   resemblanceWithTradition:9
				   comment:'Ein geruch von D7 ;-), aber runden zu ET12 ergibt uebermaessigen mit kl. sept') */
			  /* chord(gender:arithmeticSeries
				   difference:3#13
				   number:5		
				   dissonanceDegree:6
				   clearnessOfColour:7
				   resemblanceWithTradition:8
				   comment:'noch ein entfernt D7 aehnlicher, klingt verstimmt') */
			  chord(gender:arithmeticSeries
				difference:3#14
				number:5		
				dissonanceDegree:6
				clearnessOfColour:6
				resemblanceWithTradition:7
				comment:'noch ein bisschen Geruch D7 ?')
			  chord(gender:arithmeticSeries
				difference:3#16
				number:6		
				dissonanceDegree:6
				clearnessOfColour:5
				resemblanceWithTradition:4
				comment:'')
			  %% not three notes in a single octave: 4/5 4/7
			  chord(gender:arithmeticSeries
				difference:4#9
				number:3		
				dissonanceDegree:5
				clearnessOfColour:7
				resemblanceWithTradition:4
				comment:'Vorhalt?')
			  /* chord(gender:arithmeticSeries
				   difference:4#11
				   number:3		
				   dissonanceDegree:4
				   clearnessOfColour:3
				   resemblanceWithTradition:9
				   disable:true
				   comment:'stark verstimmtes Dur') */
			  chord(gender:arithmeticSeries
				difference:4#13
				number:4
				dissonanceDegree:7
				clearnessOfColour:5
				resemblanceWithTradition:7
				comment:'wieder irgendsoein Uebermaessiger')
			  /* chord(gender:arithmeticSeries
				   difference:4#15
				   number:4		
				   dissonanceDegree:4
				   clearnessOfColour:8
				   resemblanceWithTradition:9
				   comment:'D7?') */
			  %% three notes of 5/9 out of octave
			  chord(gender:arithmeticSeries
				difference:5#11
				number:3
				dissonanceDegree:5
				clearnessOfColour:8
				resemblanceWithTradition:3
				comment:'Schoenes Rollen von Schwebungen')
			  chord(gender:arithmeticSeries
				difference:5#12
				number:3
				dissonanceDegree:4
				clearnessOfColour:8
				resemblanceWithTradition:7
				comment:'Uebermaessig ? same as 3/7?')
			  chord(gender:arithmeticSeries
				difference:5#13
				number:3
				dissonanceDegree:5
				clearnessOfColour:7
				resemblanceWithTradition:7
				comment:'zwischen Uebermaessig und Dur')
			  /* chord(gender:arithmeticSeries
				   difference:5#14
				   number:3
				   dissonanceDegree:4
				   clearnessOfColour:7
				   resemblanceWithTradition:9
				   comment:'verstimmt Dur, aber mit eigener Qualitaet') 
			  chord(gender:arithmeticSeries
				difference:5#16
				number:4
				dissonanceDegree:6
				clearnessOfColour:7
				resemblanceWithTradition:3
				comment:'Rollende Schwebung. Klingt unsauber. In et72 same as 3/10') */
			  chord(gender:arithmeticSeries
				difference:5#18
				number:4
				dissonanceDegree:4
				clearnessOfColour:7
				resemblanceWithTradition:5
				comment:'Ein bischen Geruch von D7')
			  %% 
			  chord(gender:arithmeticSeries
				difference:6#13
				number:3
				dissonanceDegree:6
				clearnessOfColour:6
				resemblanceWithTradition:4
				comment:'Schoenes Rollen')
			  /* chord(gender:arithmeticSeries
				   difference:6#17
				   number:3
				   dissonanceDegree:4
				   clearnessOfColour:5
				   resemblanceWithTradition:9
				   disable:true
				   comment:'verstimmtes Dur') */
			  /* chord(gender:arithmeticSeries
				   difference:7#15
				   number:3
				   dissonanceDegree:6
				   clearnessOfColour:7
				   resemblanceWithTradition:4
				   comment:'same as 6/13?') */
			  chord(gender:arithmeticSeries
				difference:7#16
				number:3
				dissonanceDegree:5
				clearnessOfColour:7
				resemblanceWithTradition:4
				comment:'')
			  chord(gender:arithmeticSeries
				difference:7#18
				number:3
				dissonanceDegree:5
				clearnessOfColour:5
				resemblanceWithTradition:6
				comment:'Uebermaessig?')
			  /* chord(gender:arithmeticSeries
				   difference:7#20
				   number:3
				   dissonanceDegree:4
				   clearnessOfColour:8
				   resemblanceWithTradition:9
				   disable:true
				   comment:'verstimmt Dur') */
			  /* 
			  chord(gender:arithmeticSeries
				difference:7#22
				number:4
				dissonanceDegree:6
				clearnessOfColour:7
				resemblanceWithTradition:4
				comment:'verstimmt Dur, verstimmte oktave?')
			  chord(gender:arithmeticSeries
				difference:7#24
				number:4
				dissonanceDegree:5
				clearnessOfColour:8
				resemblanceWithTradition:5
				comment:'In et72 same as 5/18') */
			  %%
			  %% reciprocal
			  %%
			  chord(gender:reciprocalArithmeticSeries
				difference:1#4
				number:3		
				dissonanceDegree:2
				clearnessOfColour:10
				resemblanceWithTradition:10
				comment:'Moll')
			  chord(gender:reciprocalArithmeticSeries
				difference:1#4
				number:4
				dissonanceDegree:3 % ??
				clearnessOfColour:9
				resemblanceWithTradition:7 % ??
				comment:'rein halbvermindert, aber klingt ungewohnt')
			  chord(gender:reciprocalArithmeticSeries
				difference:1#5
				number:5
				dissonanceDegree:5
				clearnessOfColour:7
				resemblanceWithTradition:6
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:1#6
				number:6
				dissonanceDegree:6
				clearnessOfColour:4
				resemblanceWithTradition:4
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:1#7
				number:7
				dissonanceDegree:7
				clearnessOfColour:4
				resemblanceWithTradition:4
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:1#8
				number:8
				dissonanceDegree:7
				clearnessOfColour:4
				resemblanceWithTradition:4
				comment:'')
			  /* %% !! spanning two octaves
			  chord(gender:reciprocalArithmeticSeries
				difference:2#3
				number:5
				dissonanceDegree:'?'
				clearnessOfColour:'?'
				resemblanceWithTradition:'?'
				comment:'') */
			  chord(gender:reciprocalArithmeticSeries
				difference:2#5
				number:3
				dissonanceDegree:4
				clearnessOfColour:8
				resemblanceWithTradition:3
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:2#7
				number:4
				dissonanceDegree:5
				clearnessOfColour:8
				resemblanceWithTradition:1
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:2#9
				number:5
				dissonanceDegree:5
				clearnessOfColour:6
				resemblanceWithTradition:4
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:2#11
				number:6
				dissonanceDegree:6
				clearnessOfColour:5
				resemblanceWithTradition:4
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:2#13
				number:7
				dissonanceDegree:6
				clearnessOfColour:4
				resemblanceWithTradition:4
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:2#15
				number:8
				dissonanceDegree:7
				clearnessOfColour:4
				resemblanceWithTradition:4
				comment:'')
			  /* %% !! spanning two octaves
			  chord(gender:reciprocalArithmeticSeries
				difference:3#5
				number:5
				dissonanceDegree:'?'
				clearnessOfColour:'?'
				resemblanceWithTradition:'?'
				comment:'') */
			  chord(gender:reciprocalArithmeticSeries
				difference:3#7
				number:3
				dissonanceDegree:3 % ??
				clearnessOfColour:8
				resemblanceWithTradition:3
				comment:'almost identical to 2/5')
			  chord(gender:reciprocalArithmeticSeries
				difference:3#8
				number:3
				dissonanceDegree:4
				clearnessOfColour:7
				resemblanceWithTradition:3
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:3#10
				number:4
				dissonanceDegree:5
				clearnessOfColour:7
				resemblanceWithTradition:3
				comment:'')
			  /* chord(gender:reciprocalArithmeticSeries
				   difference:3#11
				   number:4
				   dissonanceDegree:4
				   clearnessOfColour:7
				   resemblanceWithTradition:9
				   comment:'erinnert an halbvermindert') */
			  /* chord(gender:reciprocalArithmeticSeries
				   difference:3#13
				   number:4
				   dissonanceDegree:'?'
				   clearnessOfColour:'?'
				   resemblanceWithTradition:'?'
				   comment:'erinnert an halbvermindert, verstimmt') */
			  chord(gender:reciprocalArithmeticSeries
				difference:3#14
				number:5
				dissonanceDegree:5
				clearnessOfColour:6
				resemblanceWithTradition:8
				comment:'erinnert an halbvermindert ?')
			  chord(gender:reciprocalArithmeticSeries
				difference:3#16
				number:6
				dissonanceDegree:6
				clearnessOfColour:5
				resemblanceWithTradition:5
				comment:'')
			  %% not three notes in a single octave: 4/5 4/7
			  chord(gender:reciprocalArithmeticSeries
				difference:4#9
				number:3
				dissonanceDegree:5
				clearnessOfColour:7
				resemblanceWithTradition:4
				comment:'')
			  /* chord(gender:reciprocalArithmeticSeries
				   difference:4#13
				   number:4
				   dissonanceDegree:'?'
				   clearnessOfColour:'?'
				   resemblanceWithTradition:'?'
				   comment:'klingt verstimmt') */
			  /* chord(gender:reciprocalArithmeticSeries
				   difference:4#15
				   number:4
				   dissonanceDegree:'?'
				   clearnessOfColour:'?'
				   resemblanceWithTradition:'?'
				   comment:'') */
			  %% three notes of 5/9 out of octave
			  chord(gender:reciprocalArithmeticSeries
				difference:5#11
				number:3
				dissonanceDegree:5
				clearnessOfColour:8
				resemblanceWithTradition:3
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:5#12
				number:3
				dissonanceDegree:4 % ??
				clearnessOfColour:8
				resemblanceWithTradition:3
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:5#13
				number:3
				dissonanceDegree:4
				clearnessOfColour:7
				resemblanceWithTradition:8
				comment:'Dominant?')
			  /* chord(gender:reciprocalArithmeticSeries
				   difference:5#14
				   number:3
				   dissonanceDegree:'?'
				   clearnessOfColour:'?'
				   resemblanceWithTradition:'?'
				   comment:'verstimmt moll?') */
			  /* chord(gender:reciprocalArithmeticSeries
				   difference:5#16
				   number:4
				   dissonanceDegree:'?'
				   clearnessOfColour:'?'
				   resemblanceWithTradition:'?'
				   comment:'klingt verstimmt') */
			  chord(gender:reciprocalArithmeticSeries
				difference:5#18
				number:4
				dissonanceDegree:5
				clearnessOfColour:6
				resemblanceWithTradition:5
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:6#13
				number:3
				dissonanceDegree:5
				clearnessOfColour:7
				resemblanceWithTradition:3
				comment:'')
			  /* chord(gender:reciprocalArithmeticSeries
				   difference:7#15
				   number:3
				   dissonanceDegree:'?'
				   clearnessOfColour:'?'
				   resemblanceWithTradition:'?'
				   comment:'same a 6/13?') */
			  chord(gender:reciprocalArithmeticSeries
				difference:7#16
				number:3
				dissonanceDegree:5 %% ?? 4
				clearnessOfColour:7
				resemblanceWithTradition:3
				comment:'')
			  chord(gender:reciprocalArithmeticSeries
				difference:7#18
				number:3
				dissonanceDegree:4
				clearnessOfColour:6
				resemblanceWithTradition:7
				comment:'')
			  /* chord(gender:reciprocalArithmeticSeries
				   difference:7#22
				   number:4
				   dissonanceDegree:'?'
				   clearnessOfColour:'?'
				   resemblanceWithTradition:'?'
				   comment:'') */
			  chord(gender:reciprocalArithmeticSeries
				difference:7#24
				number:4
				dissonanceDegree:4
				clearnessOfColour:7
				resemblanceWithTradition:5
				comment:'')
		      )


   %% ?? shall I put this into prepare (and SelectedChordsEdit + ChordsEdit in aux functor) to avoid re-evaluation
   SelectedChords = {Record.map SelectedChordsEdit ToFullChordDBEntry}
   Chords = {Record.map ChordsEdit ToFullChordDBEntry}

   /** %% Returns a database with chords whose pitch ratios are created by means of arithmetic series (this database presents a selection). For usage in HS, the intervals are rounded to the nearest pitch class interval depending on KeysPerOctave (an int).
   %% */
   fun {GetSelectedChords KeysPerOctave}
      {Record.map SelectedChords
       fun {$ X}
	  {HS.db.ratiosInDBEntryToPCs X KeysPerOctave}
       end}
   end
   /** %% Returns a database with chords whose pitch ratios are created by means of arithmetic series. For usage in HS, the intervals are rounded to the nearest pitch class interval depending on KeysPerOctave (an int).
   %% */
   fun {GetChords KeysPerOctave}
      {Record.map Chords
       fun {$ X}
	  {HS.db.ratiosInDBEntryToPCs X KeysPerOctave}
       end}
   end


end

