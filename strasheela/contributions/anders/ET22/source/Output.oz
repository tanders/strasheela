
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

/** %% This functor defines Lilypond output and Explorer output actions for 22 ET.
%%
%% */ 
functor
import
   Explorer
   Resolve
%   Browser(browse:Browse)
   
   %% !! tmp functor until next release with debugged Path of stdlib
   Path at 'x-ozlib://anders/tmp/Path/Path.ozf'

   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   DB at 'DB.ozf'
   ET22 at '../ET22.ozf'
%   DB at 'DB.ozf'
   
export
   RenderAndShowLilypond SetEnharmonicNotationTable
   AddExplorerOut_ChordsToScore
   AddExplorerOuts_ArchiveInitRecord

   PajaraRMS_TuningTable
   ji_TuningTable: JI_TuningTable
   
define


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Explorer Actions
%%%

      /** %% Creates an Explorer action for outputting a pure sequence of chords. This is a version of HS.out.addExplorerOut_ChordsToScore, customised for 31 ET. Please see the documentation of HS.out.addExplorerOut_ChordsToScore for further details such as supported arguments.
   %% */
   proc {AddExplorerOut_ChordsToScore Args}
      Defaults = unit(outname:out
% 		      value:random
% 		      ignoreSopranoChordDegree:true
		      renderAndShowLilypond: RenderAndShowLilypond
		      chordsToScore: ET22.score.chordsToScore
		      prefix:"declare \n [ET22] = {ModuleLink ['x-ozlib://anders/strasheela/ET22/ET22.ozf']} \n {HS.db.setDB ET22.db.fullDB}\n ChordSeq \n = {Score.makeScore\n")
      As = {Adjoin Defaults Args}
   in
      {HS.out.addExplorerOut_ChordsToScore As}
   end

   proc {ArchiveInitRecord I X}
      if {Score.isScoreObject X}
      then 
	 FileName = out#{GUtils.getCounterAndIncr}
      in
	 {Out.outputScoreConstructor X
	  unit(file: FileName
	       prefix:"declare \n [ET22] = {ModuleLink ['x-ozlib://anders/strasheela/ET22/ET22.ozf']} \n {HS.db.setDB ET22.db.fullDB} \n MyScore \n = ")}
      end
   end
   /** %% Adds ET22 declaration on top of *.ssco file and calls {HS.db.setDB ET22.db.fullDB}
   %% */
   proc {AddExplorerOuts_ArchiveInitRecord}   
      {Explorer.object
       add(information ArchiveInitRecord
	   label: 'Archive initRecord (ET22)')}
   end


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Customised Lilypond output
%%%

   
   local
      EnharmonicNotationTable = {NewCell unit}
      %% Using my user-def note names. 
      %%  C = c, C/ = ccu (comma up), C#\ = cscd (c sharp, comma down),  C# = cs, C\ = ccd, Cb/ = cfcu, Cb = cf
      TranslationTable = unit('C':c
			      'C/':ccu   'Db':df
			      'C#\\':cscd 'Db/':dfcu
			      'C#':cs   'D\\':dcd
			      'D':d
			      'D/':dcu   'Eb':ef
			      'D#\\':dscd 'Eb/':efcu
			      'D#':ds   'E\\':ecd
			      'E':e
			      'F':f
			      'F/':fcu   'Gb':gf
			      'F#\\':fscd 'Gb/':gfcu
			      'F#':fs   'G\\':gcd
			      'G':g
			      'G/':gcu   'Ab':af
			      'G#\\':gscd 'Ab/':afcu
			      'G#':gs   'A\\':acd
			      'A':a
			      'A/':acu   'Bb':bf
			      'A#\\':ascd 'Bb/':bfcu
			      'A#':as   'B\\':bcd
			      'B':b)
      fun {PitchnameToLily PitchName}
	 TranslationTable.PitchName
      end
   in
      /** %% The enharmonic notation for 22 ET can be customised by specifying for each numeric 22 ET pitch class how it is notated. Note that this setting will be fixed throughout the score though (e.g., pitch class 7 may be notated as 'E\\', but then it is never 'D#'). The enharmonic notation is specified by a record which maps pitch class integers to pitch names. See ET22.pc and friends for an explanation of the pitch names. The default are the default pitch names in Scala for 22 ET (using E22 notation system).
      %% Note that the lowest feature in the table is 0 (i.e., 'C') and not 1 (i.e. Table is not a tuple if all pitch classes are specified, a tuple has no feature 0).
      %% NB: an error will occur if you fail to specify a notation for a 22 ET pitch class in your scores, so Table should specify a notation for every 22 ET pitch class.
      %% */
      %% NOTE: shall I define a better default table.
      proc {SetEnharmonicNotationTable Table}
	 EnharmonicNotationTable := {Record.map Table PitchnameToLily}
      end
      fun {GetEnharmonicNotationTable}
	 @EnharmonicNotationTable
      end
      {SetEnharmonicNotationTable
       unit(0: 'C' 
	    1:'Db' 
	    2:'C#\\' 
	    3:'C#' 
	    4:'D' 
	    5:'Eb'
	    6:'D#\\'
	    7:'E\\'  
	    8:'E' 
	    9:'F' 
	    10:'Gb' 
	    11:'F#\\' 
	    12:'F#' 
	    13:'G'
	    14:'Ab' 
	    15:'G#\\' 
	    16:'G#' 
	    17:'A'
	    18:'Bb'  
	    19:'A#\\' 
	    20:'B\\' 
	    21:'B'  )}
   end

   
   %% code to insert at beginning and end of Lilypond score, defines ET notation 
   LilyHeader = {Out.readFromFile
		 {{Path.make
		   {Resolve.localize
		    'x-ozlib://anders/strasheela/ET22/source/Lilyheader.ly.data'}.1}
		  toString($)}}
   LilyFooter = "\n}"
      
   
   /** %% Lilypond output for 22 ET.
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
      ET22Wrapper = [LilyHeader LilyFooter]
      AddedArgs = unit(wrapper:if {HasFeature Args wrapper}
			       then [H T] = Args.wrapper in 
				  [H#ET22Wrapper.1 T]
			       else ET22Wrapper
			       end)
      As = {Adjoin Args AddedArgs}
   in
      {HS.out.renderAndShowLilypond MyScore
       {Adjoin As
	unit(pitchUnit: et22
	     pcsLilyNames: {GetEnharmonicNotationTable})}}
   end
   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Tuning tables
%%%

   
   /** %% Tuning table for Pajara with RMS optimal generator.
   %% */
   PajaraRMS_TuningTable
   = unit(1: 52.886
	  2: 108.814
	  3: 161.700
	  4: 217.629
	  5: 270.515
	  6: 326.443
	  7: 379.329
	  8: 435.257
	  9: 488.143
	  10: 544.072
	  11: 600.000
	  12: 652.886
	  13: 708.814
	  14: 761.700
	  15: 817.629
	  16: 870.515
	  17: 926.443
	  18: 979.329
	  19: 1035.257
	  20: 1088.143
	  21: 1144.072
	  22: 1200.000)

   /** %% Tuning table with JI interpretation of 22 ET: intervals correspond to default values of ET22 interval DB ratios.
   %% */
   JI_TuningTable
   = {List.toTuple unit
      {Append
       {Map {List.number 1 21 1}
	fun {$ I}
	   {HS.db.pc2Ratios I DB.fullDB.intervalDB}.1
	end}
       [2#1]}}
%    = unit(32#31
% 	  16#15
% 	  10#9
% 	  8#7
% 	  7#6
% 	  6#5
% 	  5#4
% 	  9#7
% 	  4#3
% 	  11#8
% 	  7#5
% 	  16#11
% 	  3#2
% 	  14#9
% 	  8#5
% 	  5#3
% 	  12#7
% 	  7#4
% 	  9#5
% 	  15#8
% 	  31#16
% 	  2#1)
   
end
