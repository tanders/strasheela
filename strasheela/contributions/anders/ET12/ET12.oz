
%%% *************************************************************
%%% Copyright (C) 2005 Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% This functor defines a few procedues for a convenient ET 12 pitch notation.
%% */

functor
import
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
export
   Acc pc:PC pcName:PCName Pitch

define

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% pitch etc. naming 
%%%

   
   local
      AccDecls = unit('bb':~2
		      'b':~1
		      '':0
		      '#':1
		      'x':2)
      PCDecls = unit('C':0 'Dbb':0 % 'B#'
		     'C#':1 'Db':1 % 'Bx'
		     'Cx':2 'D':2 'Ebb':2
		     'D#':3 'Eb':3 'Fbb':3
		     'Dx':4 'E':4 'Fb':4
		     'E#':5 'F':5 'Gbb':5
		     'Ex':6 'F#':6 'Gb':6
		     'Fx':7 'G':7 'Abb':7
		     'G#':8 'Ab':8
		     'Gx':9 'A':9 'Bbb':9
		     'A#':10 'Bb':10 % 'Cbb':10
		     'Ax':11 'B': 11 % 'Cb':11
		     )
   in

      %%
      %% Note: in contrast to my conventions elsewhere, the following
      %% function names are very short. The idea is that these
      %% functions form a kind of mini-language for expressing pitches
      %% etc, which should be as concise as possible. This shouldn't
      %% cause any misunderstandings, as these functions are only
      %% defined for 12 ET.
      %%

      /** %% Transforms symbolic accidental (atom) into the corresponding accidental integer for 12 ET. The following symbolic accidentals are supported: '' is natural (!), '#' is a sharp, and 'b' is a flat.
      %% Note: Returned value depends on {HS.db.getAccidentalOffset}.
      %% */
      %% TODO: umkehroperation..
      fun {Acc SymAcc}
	 AccDecls.SymAcc + {HS.db.getAccidentalOffset} 
      end
      
      /** %% Tranforms a conventional symbolic note names to the corresponding 12 ET pitch class. Notation of the symbolic note names: 'C' is c natural, 'C#' is c sharp, 'Cb' is c flat.
      %% NB: the following pitch class names are undefined (otherwise, the meaning of octave would become inconsistent): any flattened C and any raised B.  
      %% */
      fun {PC SymPC}
	 PCDecls.SymPC
      end
      /** %% Expects a PC (an int) and returns a list of the corresponding 12 ET symbolic note names (a list of atom). Complements function PC.
      %% */
      fun {PCName MyPC}
	 {Map {Filter {Record.toListInd PCDecls}
	       fun {$ _#NotePC} MyPC == NotePC end}
	  fun {$ SymName#_} SymName end}
      end

      /** %% Transforms a symbolic pair SymPC#Octave into the corresponding pitch (an int). SymPC is a pitch class symbol (an atom) as expected by the function PC, octave is an integer. The returned value depends on PitchesPerOctave.
      %% */
      fun {Pitch SymPC#Octave}
	 {HS.score.pitchClassToPitch {PC SymPC}#Octave}
      end

   end

   
end
