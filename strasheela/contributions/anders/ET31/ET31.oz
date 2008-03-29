
/** %% This functor extends the contribution HS, and provides abstractions for composing music in 31-tone equal temperament. For more information on this interesting temperament visit http://www.tonalsoft.com/enc/number/31edo.aspx or http://en.wikipedia.org/wiki/31_equal_temperament. 
%% This functor defines a few procedues for a convenient 31 ET notation and exports several subfunctors. 
%% */

functor
import
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   DB at 'source/DB.ozf'
   Out at 'source/Output.ozf'
   C at 'source/Convenience.ozf'
   Score at 'source/Score.ozf'
   
export
   db:DB
   Out
   C
   Score
   
   Acc pc:PC pcName:PCName Pitch
   
define
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% pitch etc. naming 
%%%
   
      local
      AccDecls = unit('bb':~4 
		      'b;':~3
		      'b':~2
		      ';':~1
		      '':0
		      '|':1
		      '#':2
		      '#|':3
		      'x':4)
      
      PCDecls = unit(%%'Cbb':27
		     %%'Cb;':28
		     %%'Cb':29
		     'C;':30
		     'C':0
		     'C|':1
		     'C#':2
		     'C#|':3
		     'Cx':4
	   
		     'Dbb':1
		     'Db;':2
		     'Db':3
		     'D;':4
		     'D':5
		     'D|':6
		     'D#':7
		     'D#|':8
		     'Dx':9
	   
		     'Ebb':6
		     'Eb;':7
		     'Eb':8
		     'E;':9
		     'E':10
		     'E|':11
		     'E#':12
		     'E#|':13
		     'Ex':14
	   
		     'Fbb':9
		     'Fb;':10
		     'Fb':11
		     'F;':12
		     'F':13
		     'F|':14
		     'F#':15
		     'F#|':16
		     'Fx':17
	   
		     'Gbb':14
		     'Gb;':15
		     'Gb':16
		     'G;':17
		     'G':18
		     'G|':19
		     'G#':20
		     'G#|':21
		     'Gx':22
	   
		     'Abb':19
		     'Ab;':20
		     'Ab':21
		     'A;':22
		     'A':23
		     'A|':24
		     'A#':25
		     'A#|':26
		     'Ax':27
	   
		     'Bbb':24
		     'Bb;':25
		     'Bb':26
		     'B;':27
		     'B':28
		     'B|':29
		     'B#':30
		     %%   'B#|':0
		     %% 'Bx':1
		    )
   in

      %%
      %% Note: in contrast to my conventions elsewhere, the following
      %% function names are very short. The idea is that these
      %% functions form a kind of mini-language for expressing pitches
      %% etc, which should be as concise as possible. This shouldn't
      %% cause any misunderstandings, as these functions are only
      %% defined for 31 ET.
      %%

      /** %% Transforms symbolic accidental (atom) into the corresponding accidental integer. The following symbolic accidentals are supported: '' is natural (!), '|' is 'half sharp',  '#' is sharp, '#|' is 1 1/2 sharp, 'x' is double sharp, ';' is half flat, 'b' is flat, 'b;' is 1 1/2 flat, 'bb' is double flat. 
      %% Note: Returned value depends on {HS.db.getAccidentalOffset}, using the database defined by ET31.db.fullDB is recommended. 
      %% This accidental notation stems from the Scala software, see the Scala documentation for details (hexample.html, or set HELP SET NOTATION).
      %% */
      %% TODO: umkehroperation..
      fun {Acc SymAcc}
	 AccDecls.SymAcc + {HS.db.getAccidentalOffset} 
      end
      
      /** %% Tranforms a conventional symbolic note names to the corresponding 31 ET pitch class. Notation of the symbolic note names: 'C' is c natural, 'C|' is c 'half sharp',  'C#' is c sharp, 'C#|' is c 1 1/2 sharp, 'Cx' is c double sharp, 'C;' is c half flat, 'Cb' is c flat, 'Cb;' is c 1 1/2 flat, 'Cbb' is c double flat.
      %% NB: the following pitch class names are undefined (otherwise, the meaning of octave would become inconsistent): any flattened C and any B raised higher than B#.  
      %% */
      fun {PC SymPC}
	 PCDecls.SymPC
      end
      /** %% Expects a PC (an int) and returns a list of the corresponding symbolic note names (a list of atom). Complements function PC.
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
