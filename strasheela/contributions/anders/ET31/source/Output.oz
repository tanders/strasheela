%%% *************************************************************
%%% Copyright (C) 2005-2009 Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% This functor defines Lilypond output (using semitone and quartertone accidentals) and Explorer output actions for 31 ET.
%% */

functor
import
   Explorer
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
%    ET31 at '../ET31.ozf'
   DB at 'DB.ozf'
   ET31_Score at 'Score.ozf'

%    Browser(browse:Browse)
   
export
   RenderAndShowLilypond
   AddExplorerOut_ChordsToScore
   AddExplorerOuts_ArchiveInitRecord

   FomusPCs_Quartertones FomusPCs_DoubleAccs

   Et31AsEt12_TuningTable
   Meantone_TuningTable
   JI_TuningTable
   
define

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Explorer Actions
%%%
   
   /** %% Creates an Explorer action for outputting a pure sequence of chords. This is a version of HS.out.addExplorerOut_ChordsToScore, customised for 31 ET. Please see the documentation of HS.out.addExplorerOut_ChordsToScore for further details such as supported arguments.
   %% */
   proc {AddExplorerOut_ChordsToScore Args}
      Defaults = unit(outname:out
		      value:random
		      ignoreSopranoChordDegree:true
		      renderAndShowLilypond: RenderAndShowLilypond
		      chordsToScore: ET31_Score.chordsToScore
		      prefix:"declare \n [ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']} \n {HS.db.setDB ET31.db.fullDB}\n ChordSeq \n = {Score.makeScore\n")
      As = {Adjoin Defaults Args}
   in
      {HS.out.addExplorerOut_ChordsToScore As}
   end

   proc {ArchiveInitRecord I X}
      if {Score.isScoreObject X}
      then 
	 FileName = out#{GUtils.timeForFileName}
      in
	 {Out.outputScoreConstructor X
	  unit(file: FileName
	       prefix:"declare \n [ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']} \n {HS.db.setDB ET31.db.fullDB} \n MyScore \n = ")}
      end
   end
   /** %% Adds ET31 declaration on top of *.ssco file and calls {HS.db.setDB ET31.db.fullDB}
   %% */
   proc {AddExplorerOuts_ArchiveInitRecord}   
      {Explorer.object
       add(information ArchiveInitRecord
	   label: 'Archive initRecord (ET31)')}
   end
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Customised Fomus output
%%%
   
   
   /** %% Table (tuple) that maps 31-TET pitch classes (ints) to Fomus pitch classes (atoms of symbolic note names). ET31_FomusPCs is intended as an argument for HS.out.makeNoteToFomusClause. 
   %% ET31_FomusPCs_Quartertones uses quarter tone accidentals for notating certain 31-TET pitch classes. 
   %%
   %% NB: ET31_FomusPCs_Quartertones uses the characters v and ^ to denote quarter-tone accidentals down and up. Fomus currently does not define any special quartertone accidentals, but these can be customised with the following setting (e.g., in your ~/.fomus file). 
   %%
   %% note-microtones = (v -1/2, ^ 1/2)
   %% */
   FomusPCs_Quartertones
   = pcs(0:'Cn' 1:'C^' 2:'C#' 3:'Db' 4:'Dv' 
	 5:'Dn' 6:'D^' 7:'D#' 8:'Eb' 9:'Ev'
	 10:'En' 11:'E^' 12:'Fv' % 'E#'
	 13:'Fn' 14:'F^' 15:'F#' 16:'Gb' 17:'Gv'
	 18:'Gn' 19:'G^' 20:'G#' 21:'Ab' 22:'Av'
	 23:'An' 24:'A^' 25:'A#' 26:'Bb' 27:'Bv'
	 28:'Bn' 29:'B^' 30:'B#')
   /** %% Table (tuple) that maps 31-TET pitch classes (ints) to Fomus pitch classes (atoms of symbolic note names). ET31_FomusPCs is intended as an argument for HS.out.makeNoteToFomusClause. 
   %% ET31_FomusPCs_DoubleAccs uses double accidentals for notating certain 31-TET pitch classes. 
   %%
   %% NB: ET31_FomusPCs_DoubleAccs uses the characters bb and x to denote double accidentals down and up. Fomus currently does not define any special double accidentals, but these can be customised with the following setting (e.g., in your ~/.fomus file), which adds these accidentals at the end of the accidentals already supported by Fomus. 
   %%
   %% note-accs = (- -1, b -1, f -1, F -1, + 1, # 1, s 1, S 1, n 0, N 0, _ 0,  x 2, bb -2) 
   %% */
   FomusPCs_DoubleAccs
   = pcs(0:'Cn' 1:'Dbb' 2:'C#' 3:'Db' 4:'Cx' 
	 5:'Dn' 6:'Ebb' 7:'D#' 8:'Eb' 9:'Dx'
	 10:'En' 11:'Fb' 12:'E#'
	 13:'Fn' 14:'Gbb' 15:'F#' 16:'Gb' 17:'Fx'
	 18:'Gn' 19:'Abb' 20:'G#' 21:'Ab' 22:'Gx'
	 23:'An' 24:'Bbb' 25:'A#' 26:'Bb' 27:'Ax'
	 %% NB: quarter tone for B^!
	 28:'Bn' 29:'B^' 30:'B#')   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Customised Lilypond output
%%%

 
   %%
   %%
   %% BUG: 'Ab' is shown as 1/1 and 'C' as 5/4
   %% Anyway, better show chord names...
   %% ?? Really bug? Some chords have silent root below pitches, but ratio factor should not be root in that case.
   %%

   %% using semitone and quartertone accidentals 
   LilyEt31PCs = pcs(0:c 1:cih 2:cis 3:des 4:deh 
		     5:d 6:dih 7:'dis' 8:es 9:eeh
		     10:e 11:eih 12:eis
		     13:f 14:fih 15:fis 16:ges 17:geh
		     18:g 19:gih 20:gis 21:aes 22:aeh
		     23:a 24:aih 25:ais 26:bes 27:beh
		     28:b 29:bih 30:bis)
   %% using semitone and double accidental
   %% This 31-tone equal temperament pitch class mapping follows
   %% http://www.tonalsoft.com/enc/number/31edo.aspx
   %%
%       LilyEt31PCs = pcs(c deses cis des cisis
% 			d eses 'dis' es disis
% 			e fes eis
% 			f geses fis ges fisis
% 			g aeses gis aes gisis
% 			a beses ais bes aisis
% 			b ces bis)

   

   /** %% Lilypond output for 31 ET.
   %%
   %% Args:
   %%
   %% 'upperMarkupMakers': a list of unary functions for creating textual markup placed above the staff over a given score object. Each markup function expects a score object and returns a VS. There exist four cases of score objects for which markup can be applied: note objects, simultaneous containers of notes (notated as a chord in Lilypond), chord objects and scale objects. The definition of each markup function must care for all these cases (e.g., with an if expression test whether the input is a note object and then create some VS or alternatively create the empty VS nil). 
   %% 'lowerMarkupMakers': same as 'upperMarkupMakers', but for markups placed below the staff.
   %%
   %% In addition, the arguments of Out.renderAndShowLilypond are supported.
   %% 
   %% Please note that RenderAndShowLilypond is defined by providing Out.renderAndShowLilypond the argument Clauses (via HS.out.renderAndShowLilypond) -- additional clauses are still possible, but adding new note/chord clauses will overwrite the support for defined by this procedure.
   %% */
   proc {RenderAndShowLilypond MyScore Args}
      {HS.out.renderAndShowLilypond MyScore
       {Adjoin Args
	unit(pitchUnit: et31
	     pcsLilyNames: LilyEt31PCs)}}
   end
   

   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Tuning tables
%%%


   /** %% Tuning table that assigns 12 ET tuning to the 31 ET pitch classes. Can be useful for comparison.. 
   %% */
   %% TODO: seems to be buggy
   Et31AsEt12_TuningTable
   = unit(1: 0.0			% C
      2: 0.0			% C|
      3: 100.0			% C#
      4: 100.0			% Db
      5: 200.0			% D!
      6: 200.0			% D
      7: 200.0
      8: 300.0
      9: 300.0
      10: 400.0
      11: 400.0
      12: 400.0
      13: 500.0
      14: 500.0
      15: 500.0
      16: 600.0
      17: 600.0
      18: 700.0 
      19: 700.0
      20: 700.0
      21: 800.0
      22: 800.0
      23: 900.0
      24: 900.0
      25: 900.0
      26: 1000.0
      27: 1000.0
      28: 1100.0
      29: 1100.0
      30: 1100.0
      31: 1200.0
	 )

   /** %% Tuning table for 1/4 comma meantone for 31 tones.
   %% */
   Meantone_TuningTable
   = unit(1:         34.990 
	  2:         76.049 
	  3:        111.039 
	  4:        152.098 
	  5:        193.157 
	  6:        228.147 
	  7:        269.206 
	  8:        310.265 
	  9:        345.255 
	  10:        386.314 
	  11:        421.304 
	  12:        462.363 
	  13:        503.422 
	  14:        538.412 
	  15:        579.471 
	  16:        614.461 
	  17:        655.520 
	  18:        696.578 
	  19:        731.569 
	  20:        772.627 
	  21:        807.618 
	  22:        848.676 
	  23:        889.735 
	  24:        924.725 
	  25:        965.784 
	  26:       1006.843 
	  27:       1041.833 
	  28:       1082.892 
	  29:       1117.882 
	  30:       1158.941 
	  31:       1200.000)

   /** %% Tuning table with JI interpretation of 31 ET: intervals correspond to default values of ET31 interval DB ratios.
   %% */
   JI_TuningTable
   = {List.toTuple unit
      {Append
       {Map {List.number 1 30 1}
	fun {$ I}
	   {HS.db.pc2Ratios I DB.fullDB.intervalDB}.1
	end}
       [2#1]}}

   
end
