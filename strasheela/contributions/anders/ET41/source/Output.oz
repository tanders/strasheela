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

%%
%% TODO:
%%
%% - finish updating ET41_PCDecls
%% - remove "upper markup" (upperMarkupMakers) and insert codeBeforeNoteMakers and codeBeforePcCollectionMakers
%%
%%
%% - all accidental markups at the same height? Otherwise for chords one cannot see to which note in chord accidental belongs. Or I do for chords something like neutral sign for chord tones without extra accidental over staff.
%%  ?? property baseline-skip
%% ?? at what position is markup drawn? Depends on note: can I change that??
%%
%% - If the enharmonic notation should be adaptable, then make ET41_PCDecls user-definable (function SetET41_PCDecls).
%%
%% - ?? replace accidentals  '7' and 'L' by some better markup?
%%

/** %% This functor defines Lilypond output and Explorer output actions for 41 ET.
%%
%% */ 
functor
import
   Explorer
   Resolve
   
   %% !! tmp functor until next release with debugged Path of stdlib
   Path at 'x-ozlib://anders/tmp/Path/Path.ozf'

   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
%    DB at 'DB.ozf'

export

%    AddExplorerOut_ChordsToScore
   AddExplorerOuts_ArchiveInitRecord

   pcDecls: ET41_PCDecls
   
   RenderAndShowLilypond

   ji_TuningTable: JI_TuningTable
   
define


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Explorer Actions
%%%

   %% Uncomment after defining ET41.score.chordsToScore
   %%
%    /** %% Creates an Explorer action for outputting a pure sequence of chords. This is a version of HS.out.addExplorerOut_ChordsToScore, customised for 41 ET. Please see the documentation of HS.out.addExplorerOut_ChordsToScore for further details such as supported arguments.
%    %% */
%    proc {AddExplorerOut_ChordsToScore Args}
%       Defaults = unit(outname:out
% % 		      value:random
% % 		      ignoreSopranoChordDegree:true		      
% 		      renderAndShowLilypond: RenderAndShowLilypond
% 		      chordsToScore: ET41.score.chordsToScore
% 		      prefix:"declare \n [ET41] = {ModuleLink ['x-ozlib://anders/strasheela/ET41/ET41.ozf']} \n {HS.db.setDB ET41.db.fullDB}\n ChordSeq \n = {Score.makeScore\n")
%       As = {Adjoin Defaults Args}
%    in
%       {HS.out.addExplorerOut_ChordsToScore As}
%    end

   proc {ArchiveInitRecord I X}
      if {Score.isScoreObject X}
      then 
	 FileName = out#{GUtils.timeForFileName}
      in
	 {Out.outputScoreConstructor X
	  unit(file: FileName
	       prefix:"declare \n [ET41] = {ModuleLink ['x-ozlib://anders/strasheela/ET41/ET41.ozf']} \n {HS.db.setDB ET41.db.fullDB} \n MyScore \n = ")}
      end
   end
   /** %% Adds ET22 declaration on top of *.ssco file and calls {HS.db.setDB ET22.db.fullDB}
   %% */
   proc {AddExplorerOuts_ArchiveInitRecord}   
      {Explorer.object
       add(information ArchiveInitRecord
	   label: 'Archive initRecord (ET41)')}
   end


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Customised Lilypond output
%%%




   /** %% Record that maps 41-TET pitch classes to HE notation spec. Each entry is a pair Nominal#Accidental, where nominal is a symbol in {a, b, c, d, e, f, g, b} and Accidental is a symbol in {natural, flat, sharp, natural7, naturalL, sharp7, flatL, natural77}.
   %% This specification is used by the Lilypond output for the mapping of pitch classes to HE notation, and also for creating the tuning table ET41.out.ji_TuningTable.
   %% */
   ET41_PCDecls = unit(0:  c#natural 
		       1:  c#natural7
		       2:  d#flatL %  'C77':2  
		       3:  d#flat  %              'C#L':3 
		       4:  c#sharp  % 'Db7':4
		       5:  c#sharp7 %           'DLL':5
		       6:  d#naturalL   % 'C#77':6 
		       7:  d#natural
		       8:  d#natural7  %'Cx': 8   'EbLL':8
		       9:  e#flatL % 'Fbb': 9     'D77':9
		       10: e#flat    %           'D#L':10
		       11: d#sharp % 'Eb7':11
		       12: d#sharp7 %      'ELL':12 
		       13: e#naturalL % f#flat  'D#77':13
		       14: e#natural
		       15: e#natural7 % 'Dx': 15   'FLL':15 
		       16: f#naturalL %'Gbb': 16    'E77':16  
		       17: f#natural
		       18: f#natural7 % 'E#': 18  % 'GbLL':18
		       19: g#flatL % 'F77':19
		       20: g#flat   %          'F#L':20
		       21: f#sharp  %     'Gb7':21
		       22: f#sharp7 %'Ex': 22 'GLL':22 
		       23: g#naturalL % 'Abb': 23    'F#77':23
		       24: g#natural    
		       25: g#natural7 % 'Fx': 25  'AbLL':25 
		       26: a#flatL % 'G77':26 
		       27: a#flat    %   'G#L':27
		       28: g#sharp   %    'Ab7':28
		       29: g#sharp7 %  'ALL':29 
		       30: a#naturalL % 'Bbb': 30    'G#77':30
		       31: a#natural
		       32: a#natural7 % 'Gx': 32     'BbLL':32   
		       33: b#flatL % 'A77':33
		       34: b#flat %               'A#L':34
		       35: a#sharp %     'Bb7':35
		       36: a#sharp7 % 'BLL':36 
		       37: b#naturalL %'A#77':37
		       38: b#natural
		       39: b#natural7 % 'Ax': 39
		       40: b#natural77 % c#'L' would result in octave problems..
		      )
   ET41_PC_HE_Strings = {Record.map ET41_PCDecls
			 fun {$ Nominal#Acc}
			    HE_String = case Acc of 
					   natural then "" % "n"
					[] natural7 then ">"
					[] natural77 then "."  
					[] naturalL then "<" 
					[] sharp then "v" 
					[] sharp7 then ">v" 
% 					[] SharpL then "<v" 
					[] flat then "e" 
% 					[] flat7 then ">e" 
					[] flatL then "<e"
					end
			    in
			       Nominal#HE_String
			    end}


   LilyEt41PCs = {Record.map ET41_PC_HE_Strings
		  %% access LilyPC from X
		  fun {$ X} {CondSelect X 1 X} end}
   
   /** %%
   %% */
   fun {MakeET41Accidental X}      
      %% access Lily markup 
      fun {GetAccStringForPC PC}
	 ET41_PCDecl = ET41_PC_HE_Strings.PC
      in
	 {CondSelect ET41_PCDecl 2 nil}
      end
   in
      if {Out.isLilyChord {X getTemporalContainer($)}} then
	 %% X is a note in a Lilypond chord
	 Acc = {GetAccStringForPC {X getPitchClass($)}}
      in
	 if Acc == nil then nil else 	 
	    "\\chordHE \""#Acc#"\""
	 end
      elseif {X isNote($)} then
	 %% X is a note in general
	 Acc = {GetAccStringForPC {X getPitchClass($)}}
      in
	 if Acc == nil then nil else
	    "\\HE \""#Acc#"\""
	 end
      elseif {HS.score.isPitchClassCollection X} then
	 %% X is a chord/scale
	 Acc = {GetAccStringForPC {X getRoot($)}}
      in
	 if Acc == nil then nil else
	    "\\HE \""#Acc#"\""
	 end
	 %% this clause should never apply..
      else nil
      end
   end


   LilyHeader = {Out.readFromFile
		 {{Path.make
		   {Resolve.localize
		    'x-ozlib://anders/strasheela/ET41/source/Lilyheader.ly.data'}.1}
		  toString($)}}
   LilyFooter = "\n}"
      
   
   /** %% Lilypond output for 41 ET. The output uses the accidental font HE, which is available at http://music.calarts.edu/~msabat/ms/pdfs/HE-font-2009.zip. First install the HE font before using ET41.out.renderAndShowLilypond.
   %%
   %% ET41.out.renderAndShowLilypond is a customised version of HS.out.renderAndShowLilypond, which in turn customises Out.renderAndShowLilypond.
   %%
   %%
   %%
   %% Args:
   %%
   %% 'upperMarkupMakers' (default ??): a list of unary functions for creating textual markup placed above the staff over a given score object. Each markup function expects a score object and returns a VS. There exist four cases of score objects for which markup can be applied: note objects, simultaneous containers of notes (notated as a chord in Lilypond), chord objects and scale objects. The definition of each markup function must care for all these cases (e.g., with an if expression test whether the input is a note object and then create some VS or alternatively create the empty VS nil). 
   %% 'lowerMarkupMakers' (default ??): same as 'upperMarkupMakers', but for markups placed below the staff.
   %%
   %% In addition, the arguments of Out.renderAndShowLilypond are supported.
   %% 
   %% Please note that RenderAndShowLilypond is defined by providing Out.renderAndShowLilypond the argument Clauses (via HS.out.renderAndShowLilypond) -- additional clauses are still possible, but adding new note/chord clauses will overwrite the support for defined by this procedure.
   %%
   %% Note that accidentals beyond # and b are defined by the markup function MakeET41Accidentals_Markup given to upperMarkupMakers. If you set this argument, you should include MakeET41Accidentals_Markup in the list of markup functions. 
   %%
   %% */
   proc {RenderAndShowLilypond MyScore Args}
      Defaults = unit(codeBeforeNoteMakers: [MakeET41Accidental]
		      codeBeforePcCollectionMakers:
			 [fun {$ X PC}
			     fun {GetAccStringForPC}
				ET41_PCDecl = ET41_PC_HE_Strings.PC
			     in
				{CondSelect ET41_PCDecl 2 nil}
			     end
			     %% X is a note in general
			     Acc = {GetAccStringForPC}
			  in
			     if Acc == nil then nil else
				if {HS.score.isChord X} then
				   %% chord case
				   "\\chordHE \""#Acc#"\""
				   %% scale case
				else "\\HE \""#Acc#"\""
				end
			     end
			  end])
      As1 = {Adjoin Defaults Args}
      ET22Wrapper = [LilyHeader LilyFooter]
      AddedArgs = unit(wrapper:if {HasFeature Args wrapper}
			       then [H T] = Args.wrapper in 
				  [H#ET22Wrapper.1 T]
			       else ET22Wrapper
			       end)
      As2 = {Adjoin As1 AddedArgs}
   in
      {HS.out.renderAndShowLilypond MyScore
       {Adjoin As2
	unit(pitchUnit: et41
	     pcsLilyNames: LilyEt41PCs)}}
   end


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Tuning tables
%%%

   /** %% Tuning table with JI interpretation of 41 ET: intervals correspond to the JI interpretation of the HE accidentals used by Lilypond output.
   %% */
   JI_TuningTable = {Adjoin {Record.map
			     %% leave out PC 0, PC 41 added at end below
			     {Record.subtract ET41_PCDecls 0}
			     fun {$ Nominal#Acc}
				%% ratios of Phythagorean nominals
				NominalRatio = case Nominal of
						  c then 1#1
					       [] d then 9#8
					       [] e then 81#64
					       [] f then 4#3
					       [] g then 3#2
					       [] a then 27#16
					       [] b then 243#128
					       end
				%% ratios of the 3 and 7-limit accidentals used in the notation
				AccRatio = case Acc of
					      natural then 1#1
					   [] natural7 then 64#63
					   [] natural77 then 4096#3969 % 64#63 * 64#63 
					   [] naturalL then 63#64 
					   [] sharp then 2187#2048
					   [] sharp7 then 243#224 % 2187#2048 * 64#63
					   [] flat then 2048#2187
					   [] flatL then 224#243   % 2048#2187 * 63#64
					   end
			     in
				%% translate ratios to cents and add them
				{MUtils.ratioToKeynumInterval NominalRatio 1200.0}
				+ {MUtils.ratioToKeynumInterval AccRatio 1200.0}
			     end}
		     %% add octave (necessary?)
		     unit(41: 1200.0)}

end