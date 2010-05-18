
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
%    Browser(browse:Browse) % tmp for debugging
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
%    MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   DB at 'source/DB.ozf'
%    Out at 'source/Output.ozf' 
   
export
   db:DB
%    Out
   
%    Acc pc:PC pcName:PCName Pitch
   JiPC JiPitch
   
define

   skip
   
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%
% %%% pitch etc. naming 
% %%%

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
		   'B': 243#128 )

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
   
   
%       AccDecls = unit('bb':~8
% 		      'b':~4
% 		      'LL':~2	% ??
% 		      'L':~1
% 		      '':0
% 		      '7':1
% 		      '77':2   % ??
% 		      '#':4
% 		      'x':8)

%       %% Note: all 5-limit equivalents left of for now
%       PCDecls = unit('C':0 
% % 		     'B#': 1  % undefined to avoid inconsistent octaves
% 		                  'C7':1    % 'DbLL':1 
% 		                  'C77':2   'DbL':2
% 		     'Db': 3                'C#L':3 
% 		     'C#': 4      'Db7':4
% % 		     'Bx': 5
% 		                  'C#7':5   'DLL':5
% 		                  'C#77':6  'DL': 6  
% 		     'D': 7
% 		     'Cx': 8      'D7':8    'EbLL':8
% 		     'Fbb': 9     'D77':9   'EbL':9
% 		     'Eb': 10               'D#L':10
% 		     'D#': 11     'Eb7':11
% 		                  'D#7':12  'ELL':12 
% 		     'Fb': 13               'EL': 13 % 'D#77':13
% 		     'E': 14
% 		     'Dx': 15     'E7':15   'FLL':15 
% 		     'Gbb': 16    'E77':16  'FL': 16
% 		     'F': 17
% 		     'E#': 18     'F7':18   % 'GbLL':18
% 		                  'F77':19  'GbL':19
% 		     'Gb': 20               'F#L':20
% 		     'F#': 21     'Gb7':21
% 		     'Ex': 22     'F#7':22  'GLL':22 
% 		     'Abb': 23    'F#77':23 'GL':23
% 		     'G': 24    
% 		     'Fx': 25     'G7':25   'AbLL':25 
% 		                  'G77':26  'AbL':26
% 		     'Ab': 27               'G#L':27
% 		     'G#': 28     'Ab7':28
% 		                  'G#7':29  'ALL':29 
% 		     'Bbb': 30    'G#77':30 'AL':30
% 		     'A': 31
% 		     'Gx': 32      'A7':32  'BbLL':32   
% 		                   'A77':33 'BbL':33
% 		     'Bb': 34               'A#L':34
% 		     'A#': 35      'Bb7':35
% 		                   'A#7':36 'BLL':36 
% % 		     'Cb': 37  % undefined to avoid inconsistent octaves
% 		                   'A#77':37 'BL':37
% 		     'B': 38
% 		     'Ax': 39      'B7':39
% 		                   'B77':40
% % 		     'Dbb': 40  % undefined to avoid inconsistent octaves
% 		    )


      
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
%       {Browse pc(nominal:Nominal#Nominals.(SymPC.1)
% 		 accs:Accs#{Map {List.number 2 {Width SymPC} 1}
% 			    fun {$ I} Accidentals.(SymPC.I) end}
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
