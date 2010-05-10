
/** %% Top-level functor for definitions related to regular temperaments, such as chord/scale/interval databases and notation output.
%% */

functor
import
%    HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   DB at 'source/DB.ozf'
%    Out at 'source/Output.ozf' 
   
export
   db:DB
%    Out
   
%    Acc pc:PC pcName:PCName Pitch
   
define

   skip
   
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%
% %%% pitch etc. naming 
% %%%

   %%
   %% TODO: ASCII notation for Extended Helmholtz Notation or Sagittal, which mean their JI interpretation and which are then "rounded" into temperament with DB.ratioToRegularTemperamentPC
   %%

%    %%
%    %% #, b: Phythagorean semitone sharp/flat (4 steps = 117.07 cent)
%    %% x, bb: two Phythagorean semitones sharp/flat (8 steps)
%    %% ), (: diesis sharp/flat (2 steps = 58.54)   
%    %% 7, L: septimal comma sharp/flat (1 step = 29.27); just 27.3 cents.
%    %% 77. LL: two septimal comma sharp/flat (2 steps = 58.54).


%    local
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

%    in

      
%       /** %% Transforms symbolic accidental (atom) into the corresponding accidental integer. The following symbolic accidentals are supported: the empty atom '' is natural (!), '7' and 'L' are a septimal comma sharp and flat, '77' and 'LL' are two septimal commas sharp and flat, '#' and 'b' are a semitone sharp and flat, and finally 'x' and 'bb' are two semitones sharp and flat. 
%       %% Note: Returned value depends on {HS.db.getAccidentalOffset}, set the HS database to ET41.db.fullDB.
%       %% */
%       %% TODO: umkehroperation..
%       fun {Acc SymAcc}
% 	 AccDecls.SymAcc + {HS.db.getAccidentalOffset} 
%       end
      
%       /** %% Tranforms a conventional symbolic note names to the corresponding 31 ET pitch class. Notation of the symbolic note names: 'C' is c natural, 'C7' is c septimal comma sharp etc. See Acc for other accidentals supported.
%       %% NB: the following pitch class names are undefined (otherwise, the meaning of octave would become inconsistent): any flattened C and any raised B.  
%       %% */
%       fun {PC SymPC}
% 	 PCDecls.SymPC
%       end
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
