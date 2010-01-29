
/** %% Top-level functor for 22 ET and related tunings with 22 pitches per octave (e.g., Paul Erlich's Pajara). 
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
   
   %% syntonic comma sharp, flat (1 step = 54.55 cent): /, \
   %%   with escape char comma flat is \\
   %% diatonic semitone (2 steps = 109.09 cent): #\\ b/ 
   %% minor whole tone (3 steps = 163.63 cent): #, b

   %%
   %% Remember that a "Phythagorean third" (i.e. 4 stacked 3:2, 8
   %% steps in 22 ET) is 436.36 cent wide (i.e. is is very close to
   %% 9:7). For correting this wide "Phythagorean third", the wide
   %% syntonic comma of 54.55 cent (1 step) arrives at 381.82 cent (7
   %% steps in 22 ET), which is only 4.49 cent smaller than 5:4.
   %%

   local
      AccDecls = unit('b':~3
		      'b/':~2
		      '\\':~1
		      '':0
		      '/':1
		      '#\\':2
		      '#':3)

      %% Note: I could/should add more enharmonic equivalents, e.g. 'E|' -- when needed
      PCDecls = unit('C':0
		     'C/':1   'Db':1
		     'C#\\':2 'Db/':2 % 'D!':2 'C|':2 
		     'C#':3   'D\\':3
		     'D':4
		     'D/':5   'Eb':5
		     'D#\\':6 'Eb/':6 % 'D|':6  'E!':6
		     'D#':7   'E\\':7
		     'E':8
		     'F':9
		     'F/':10   'Gb':10
		     'F#\\':11 'Gb/':11 % 'F|':11 'G!':11
		     'F#':12   'G\\':12
		     'G':13
		     'G/':14   'Ab':14
		     'G#\\':15 'Ab/':15 % 'G|':15  'A!':15
		     'G#':16   'A\\':16
		     'A':17
		     'A/':18   'Bb':18
		     'A#\\':19 'Bb/':19 % 'A|':19 'B!':19
		     'A#':20   'B\\':20
		     'B':21)
   in

      %%
      %% Note: in contrast to my conventions elsewhere, the following
      %% function names are very short. The idea is that these
      %% functions form a kind of mini-language for expressing pitches
      %% etc, which should be as concise as possible. This shouldn't
      %% cause any misunderstandings, as these functions are only
      %% defined for 22 ET.
      %%

      /** %% Transforms symbolic accidental (atom) into the corresponding accidental integer. The following symbolic accidentals are supported: the empty atom '' is natural (!), '/' is a comma sharp, '\\' is a comma flat (two slash because of an escape character), '#\\' is a semitone minus a comma sharp, 'b/' is a semitone minus a comma flat, '#' is a semitone sharp and 'b' is a semitone flat. 
      %% Note: Returned value depends on {HS.db.getAccidentalOffset}, set the HS database to ET22.db.fullDB.
      %% This accidental notation stems from the Scala software, see the Scala documentation (hexample.html or set HELP SET NOTATION).
      %% */
      %% TODO: umkehroperation..
      fun {Acc SymAcc}
	 AccDecls.SymAcc + {HS.db.getAccidentalOffset} 
      end
      
      /** %% Tranforms a conventional symbolic note names to the corresponding 31 ET pitch class. Notation of the symbolic note names: 'C' is c natural, 'C/' is c 'comma sharp',  'C#\\' is c sharp flattened by a comma, 'C#' is c sharp, 'C//' is c comma flat, 'Cb\' is c flat raised by a comma, 'Cb' is c flat.
      %% NB: the following pitch class names are undefined (otherwise, the meaning of octave would become inconsistent): any flattened C and any raised B.  
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
