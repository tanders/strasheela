
/** %% Top-level functor for definitions related to regular temperaments, such as chord/scale/interval databases and notation output.
%% */

%%
%% Nachdenken:
%% !! I specify pitch names directly as ratios and then approximate to temperament. So, the accumulating error of adding generators which approximate JI intervals are not there. E.g., in meantone C-Fb is closer to 81/64 than C-E.
%% Should I keep it that way? What about A# vs BbL in meantone? Also, different PCs!
%%
%% However, if I change the JI meanting of stagged fifths, then also the JI meanting of the accidentals is lost. So, I may consider having multiple mappings.
%% - JI symbolic PC to approximated PC in temperament
%% - tempered symbolic PC, i.e. based on tempered fifths (and accidentals ??). There should be no mapping necessary, should be the same value..
%%
%% TODO: complement JiPC by a function PC that takes the tempering of fifths and accidentals into account. How to do that? Should these be given explicitly as arg or computed from temperament? Size of fifth can be computed from given temperament, but what about accidentals. Should at least a list of accidental atoms that are taking into acount be given as arg. 
%%

functor
import
   Browser(browse:Browse) % tmp for debugging
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
%    MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   DB at 'source/DB.ozf'
%    Out at 'source/Output.ozf' 
   
export
   db:DB
%    Out
   
%    Acc 
   JiPC JiPitch
   pc:PC Pitch % pcName:PCName
   
define

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% pitch etc. naming 
%%%

   %%
   %% TODO: ASCII notation for Extended Helmholtz Notation or Sagittal, which mean their JI interpretation and which are then "rounded" into temperament with DB.ratioToRegularTemperamentPC
   %%

   /** %% Note name nominals with associated Pythagorean ratios.
   %% */
   JiNominals = unit('C': 1#1
		     'D': 9#8
		     'E': 81#64
		     'F': 4#3 
		     'G': 3#2
		     'A': 27#16
		     'B': 243#128)

   /* %% Number of repeated fifths transpositions that lead to note name nominals. Accidentals # and b and included, quasi as special nominals.
   %% */
   Nominals_FifthsTranpositions = unit('C': 0
				       'D': 2
				       'E': 4
				       'F': ~1
				       'G': 1
				       'A': 3
				       'B': 5
				       %% accidentals
				       'b': ~7
				       '#': 7)

   /** %% Accidentals with their corresponding ratios.
   %% */
   %% !! TODO: ASCII represdentation for higher prime level commas etc
   JiAccidentals = unit('': 1#1
			%% prime limit-3``; Phythagorean semitone sharp/flat (Pythagorean apotome)
% 		      'x'
			'#': 2187#2048
			'b': 2048#2187 
% 		      'bb'
			%% limit-5
			%% lowers Pythagorean third 81#64 by Syntonic comma into 5#4
			'/':81#80  % alternative sign: +
			'\\':80#81 % alt sign: -
			%% limit-7
			%% lowers Pythagorean minor seventh 16#9 by Septimal comma into 7#4
			'7':64#63
			'L':63#64
			%% limit-11
			%% raises fourth 4#3 by 11-limit quartertone into 11#8
			'^':33#32
			'v':32#33
% 		      %% limit 13
% 		      %% lowers Pythagorean major sixth 27#16 by 13-limit 1/3-tone into 13#8
% 		      27#26
% 		      26#27
% 		      %% limit 17
% 		      %% lowers diatonic semitone 16#15 by 17-limit Schisma into 17#16
% 		      %% NOTE: accidental reference that is lowered is *not* Pythagorean interval
% 		      %% Better use some other reference??
% 		      256#255  % 17#16
% 		      255#256  % 16#17
% 		      %% limit 19
% 		      %% raises Pythagorean minor third 32#27 by 19-limit Schisma into 19#16 small minor third
% 		      513#512
% 		      512#513
% 		      %% limit 23
% 		      %% raises the Pythagorean tritone 729#512 by 23-limit comma into augmented tritone 23#16
% 		      736#729
% 		      729#736
		       )

%  ]
   
  
      
%       /** %% Transforms symbolic accidental (atom) into the corresponding accidental integer. The following symbolic accidentals are supported: the empty atom '' is natural (!), '7' and 'L' are a septimal comma sharp and flat, '77' and 'LL' are two septimal commas sharp and flat, '#' and 'b' are a semitone sharp and flat, and finally 'x' and 'bb' are two semitones sharp and flat. 
%       %% Note: Returned value depends on {HS.db.getAccidentalOffset}, set the HS database to ET41.db.fullDB.
%       %% */
%       %% TODO: umkehroperation..
%       fun {Acc SymAcc}
% 	 AccDecls.SymAcc + {HS.db.getAccidentalOffset} 
%       end


   /** %% Tranforms a symbolic note name for a JI pitch class into the corresponding regular temperament pitch class (an int). SymPC is a pair of the form Nominal#Acc or  Nominal#Acc1# ... #AccN. Nominal is one of the 7 neminals 'C', 'D', .. 'B', which express a chain of Pythagorean fifths. The following accidentals are supported.
   %% '#' and 'b': a Pythagorean apotome up/down
   %% '/' and '\\': a Syntonic comma up/down
   %% '7' and 'L': a Septimal comma 64/63 up/down
   %% '^' and 'v': a 11-limit quartertone 33/32 up/down
   %%
   %% Note that the mapping of JI notation to regular temperament PCs may not correspond to the common notation for the temperament in question. For example, using common notation for 1/4-comma meantone the interval C-Fb is closer to the Pythagorean third 81/64 than C-E. Therefore for this temperament, if SymPC is 'E' (i.e. the Pythagorean third 81/64) then JiPC returns the pitch class that correspond to the tone usually notated Fb (given a high-enough generatorFactors).
   %% */
   fun {JiPC SymPC}      
      Nominal = {GUtils.ratioToFloat JiNominals.(SymPC.1)}
      Accs = {Map {List.number 2 {Width SymPC} 1}
	      fun {$ I} {GUtils.ratioToFloat JiAccidentals.(SymPC.I)} end}
      Ratio = {LUtils.accum Nominal|Accs Number.'*'}
   in
%       {Browse pc(nominal:Nominal#JiNominals.(SymPC.1)
% 		 accs:Accs#{Map {List.number 2 {Width SymPC} 1}
% 			    fun {$ I} JiAccidentals.(SymPC.I) end}
% 		 ratio:Ratio
% 		 %% if PitchesPerOctave=1200, then unit is cent...
% 		 ji_pc:{MUtils.ratioToKeynumInterval Ratio
% 			{IntToFloat {HS.db.getPitchesPerOctave}}})}
      {HS.db.ratioToRegularTemperamentPC Ratio unit}
   end

   /** %% Tranforms a symbolic note name for a JI pitch into the corresponding regular temperament pitch (an int). Spec is pair of the form Nominal#Acc#Octave or  Nominal#Acc1# ... #AccN#Octave. See JiPitch for the meaning of nominal and accidentals. Octave is an integer. The returned value depends on PitchesPerOctave.
   %% */
   fun {JiPitch Spec}
      L = {Width Spec}
   in
      {HS.score.pitchClassToPitch {JiPC {Record.subtract Spec L}}#Spec.L}
   end

   
   /** %% Tranforms a symbolic note name for a tempered pitch class into the corresponding regular temperament pitch class (an int). PC is used exactly like JiPC, see there for details.
   %% The difference to JiPC is that PC internally uses tempered intervals. For example, in  1/4-comma meantone the Pythagorean third 81/64 is mapped to the PC of the interval 'C'-'E', because it takes tempered fifths into account.
   %% */
   %%
   %% TODO: problems
   %% - the resulting pitch class is possibly not within the temperament: round again to temperament?
   %% - no error checking: e.g. error of fifth should not be too large, nor any error of an accidental, nor the error of a final "rounding to temperament"
   %%   so, should I compute JI pitch in PitchesPerOctave?? At least for the individual ratios 3#2 and of accidentals
   fun {PC SymPC}
      PitchesPerOctave = {HS.db.getPitchesPerOctave}
      FifthPC = {HS.db.ratioToRegularTemperamentPC 3#2 unit}
      fun {FifthsTranpositionsToPC N}
	 Nominals_FifthsTranpositions.N * FifthPC
      end
      NominalPC = {FifthsTranpositionsToPC (SymPC.1)} 
      AccPCs = {Map {List.number 2 {Width SymPC} 1}
	      fun {$ Acc}
		 if Acc == '#' orelse Acc == 'b' then 
		    {FifthsTranpositionsToPC Acc}
		    %% no accumulated error: transform each accidental ratio individually
		 else {HS.db.ratioToRegularTemperamentPC JiAccidentals.(SymPC.Acc) unit}
		 end
	      end}
   in
      {Browse pc(nominal:NominalPC#Nominals_FifthsTranpositions.(SymPC.1)
		 accs:AccPCs#{Map {List.number 2 {Width SymPC} 1}
			      fun {$ I} JiAccidentals.(SymPC.I) end}
		 ji_pc:{JiPC SymPC})}
      ({LUtils.accum NominalPC | AccPCs
       Number.'+'}
       + (10 * PitchesPerOctave)) % avoid negative number
      mod PitchesPerOctave
   end

   /** %% Tranforms a symbolic note name for a tempered pitch into the corresponding regular temperament pitch (an int). Pitch is used exactly like JiPitch, and the different between Pitch and JiPitch is the same as the difference between PC and JiPC.
   %% */
   fun {Pitch Spec}
      L = {Width Spec}
   in
      {HS.score.pitchClassToPitch {PC {Record.subtract Spec L}}#Spec.L}
   end
      
%       /** %% Expects a PC (an int) and returns a list of the corresponding symbolic note names (a list of atom). Complements function PC.
%       %% */
%       fun {PCName MyPC}
% 	 {Map {Filter {Record.toListInd PCDecls}
% 	       fun {$ _#NotePC} MyPC == NotePC end}
% 	  fun {$ SymName#_} SymName end}
%       end

%       /** %% Transforms a symbolic pair SymPC#Octave into the corresponding pitch (an int). SymPC is a pitch class symbol (an atom) as expected by the function PC, octave is an integer. The returned value depends on PitchesPerOctave.
%       %% */
%       fun {Pitch SymPC#Octave}
% 	 {HS.score.pitchClassToPitch {PC SymPC}#Octave}
%       end

%    end

   
end
