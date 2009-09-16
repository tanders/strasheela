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
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'

export

%    AddExplorerOut_ChordsToScore
   AddExplorerOuts_ArchiveInitRecord

   RenderAndShowLilypond
   
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


%    Natural = "n"
   Natural7 = ">"
   Natural77 = "."  
   NaturalL = "<" 
   Sharp = "v" 
   Sharp7 = ">v" 
%    SharpL = "<v" 
   Flat = "e" 
%    Flat7 = ">e" 
   FlatL = "<e" 

   /** %% Format of each entry: LilyPC or LilyPC#AccidentalMarkup. LilyPC (a VS) is a Lily pitch name (e.g., c or cis). AccidentalMarkup (a VS) is a Lilypond markup used above the note to indicate its accidental. 
   %% */
   ET41_PCDecls = unit(0:  c 
		       1:  c#Natural7
		       2:  d#FlatL %  'C77':2  
		       3:  d#Flat  %              'C#L':3 
		       4:  c#Sharp  % 'Db7':4
		       5:  c#Sharp7 %           'DLL':5
		       6:  d#NaturalL   % 'C#77':6 
		       7:  d
		       8:  d#Natural7  %'Cx': 8   'EbLL':8
		       %% TODO: only updated until here
		       9:  e#FlatL % 'Fbb': 9     'D77':9
		       10: e#Flat    %           'D#L':10
		       11: d#Sharp % 'Eb7':11
		       12: d#Sharp7 %      'ELL':12 
		       13: e#NaturalL % f#Flat  'D#77':13
		       14: e
		       15: e#Natural7 % 'Dx': 15   'FLL':15 
		       16: f#NaturalL %'Gbb': 16    'E77':16  
		       17: f
		       18: f#Natural7 % 'E#': 18  % 'GbLL':18
		       19: g#FlatL % 'F77':19
		       20: g#Flat   %          'F#L':20
		       21: f#Sharp  %     'Gb7':21
		       22: f#Sharp7 %'Ex': 22 'GLL':22 
		       23: g#NaturalL % 'Abb': 23    'F#77':23
		       24: g    
		       25: g#Natural7 % 'Fx': 25  'AbLL':25 
		       26: a#FlatL % 'G77':26 
		       27: a#Flat    %   'G#L':27
		       28: g#Sharp   %    'Ab7':28
		       29: g#Sharp7 %  'ALL':29 
		       30: a#NaturalL % 'Bbb': 30    'G#77':30
		       31: a
		       32: a#Natural7 % 'Gx': 32     'BbLL':32   
		       33: b#FlatL % 'A77':33
		       34: b#Flat %               'A#L':34
		       35: a#Sharp %     'Bb7':35
		       36: a#Sharp7 % 'BLL':36 
		       37: b#NaturalL %'A#77':37
		       38: b
		       39: b#Natural7 % 'Ax': 39
		       40: b#Natural77 % c#'L' would result in octave problems..
		      )


   LilyEt41PCs = {Record.map ET41_PCDecls
		  %% access LilyPC from X
		  fun {$ X} {CondSelect X 1 X} end}
   
   /** %%
   %% */
   fun {MakeET41Accidental X}      
      %% access Lily markup 
      fun {GetAccStringForNote N}
	 ET41_PCDecl = ET41_PCDecls.{N getPitchClass($)}
      in
	 {CondSelect ET41_PCDecl 2 nil}
      end
   in
      if {Out.isLilyChord {X getTemporalContainer($)}} then
	 %% X is a note in a Lilypond chord
	 Acc = {GetAccStringForNote X}
      in
	 if Acc == nil then nil else 	 
	    "\\chordHE \""#Acc#"\""
	 end
      elseif {X isNote($)} then
	 %% X is a note in general
	 Acc = {GetAccStringForNote X}
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
      
   
   /** %% Lilypond output for 41 ET.
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
			 [fun {$ MyChord PC}
			     fun {GetAccStringForPC}
				ET41_PCDecl = ET41_PCDecls.PC
			     in
				{CondSelect ET41_PCDecl 2 nil}
			     end
			     %% X is a note in general
			     Acc = {GetAccStringForPC}
			  in
			     if Acc == nil then nil else
				"\\chordHE \""#Acc#"\""
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

%% TODO: tuning table for extended version of La Monte Young's Well-tuned piano JI tuning 

   

end