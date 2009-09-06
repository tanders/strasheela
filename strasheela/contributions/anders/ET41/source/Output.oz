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

%    /** %% Creates an Explorer action for outputting a pure sequence of chords. This is a version of HS.out.addExplorerOut_ChordsToScore, customised for 31 ET. Please see the documentation of HS.out.addExplorerOut_ChordsToScore for further details such as supported arguments.
%    %% */
%    proc {AddExplorerOut_ChordsToScore Args}
%       Defaults = unit(outname:out
% % 		      value:random
% % 		      ignoreSopranoChordDegree:true
% 		      chordsToScore: ET41.score.chordsToScore
% 		      prefix:"declare \n [ET41] = {ModuleLink ['x-ozlib://anders/strasheela/ET41/ET41.ozf']} \n {HS.db.setDB ET41.db.fullDB}\n ChordSeq \n = {Score.makeScore\n")
%       As = {Adjoin Defaults Args}
%    in
%       {HS.out.addExplorerOut_ChordsToScore As}
%    end

   proc {ArchiveInitRecord I X}
      if {Score.isScoreObject X}
      then 
	 FileName = out#{GUtils.getCounterAndIncr}
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

   /** %% Format of each entry: LilyPC or LilyPC#AccidentalMarkup. LilyPC (a VS) is a Lily pitch name (e.g., c or cis). AccidentalMarkup (a VS) is a Lilypond markup used above the note to indicate its accidental. 
   %% */
   ET41_PCDecls = unit(0:  c 
		       1:  c#'7'
		       2:  des#'L' %  'C77':2  
		       3:  des  %              'C#L':3 
		       4:  cis  % 'Db7':4
		       5:  cis#'7' %           'DLL':5
		       6:  d#'L'   % 'C#77':6 
		       7:  d
		       8:  d#'7'  %'Cx': 8   'EbLL':8
		       9:  es#'L' % 'Fbb': 9     'D77':9
		       10: es    %           'D#L':10
		       11: 'dis' % 'Eb7':11
		       12: 'dis'#'7' %      'ELL':12 
		       13: fes   %           'EL': 13 % 'D#77':13
		       14: e
		       15: e#'7' % 'Dx': 15   'FLL':15 
		       16: f#'L' %'Gbb': 16    'E77':16  
		       17: f
		       18: f#'7' % 'E#': 18  % 'GbLL':18
		       19: ges#'L' % 'F77':19
		       20: ges   %          'F#L':20
		       21: fis  %     'Gb7':21
		       22: fis#'7' %'Ex': 22 'GLL':22 
		       23: g#'L' % 'Abb': 23    'F#77':23
		       24: g    
		       25: g#'7' % 'Fx': 25  'AbLL':25 
		       26: as#'L' % 'G77':26 
		       27: as    %   'G#L':27
		       28: gis   %    'Ab7':28
		       29: gis#'7' %  'ALL':29 
		       30: a#'L' % 'Bbb': 30    'G#77':30
		       31: a
		       32: a#'7' % 'Gx': 32     'BbLL':32   
		       33: bes#'L' % 'A77':33
		       34: bes %               'A#L':34
		       35: ais %     'Bb7':35
		       36: ais#'7' % 'BLL':36 
		       37: b#'L' %'A#77':37
		       38: b
		       39: b#'7' % 'Ax': 39
		       40: b#'77' % c#'L' would result in octave problems..
		      )

   LilyEt41PCs = {Record.map ET41_PCDecls
		  %% access LilyPC from X
		  fun {$ X} {CondSelect X 1 X} end}
   

   %% TODO: finish other cases
   fun {MakeET41Accidentals_Markup X}                 
      %% for note
      if {X isNote($)} then
	 ET41_PCDecl = ET41_PCDecls.{X getPitchClass($)}
      in
	 %% access Lily markup from X
	 {CondSelect ET41_PCDecl 2 nil}
	 %% TMP: no accidental within lily chord or Strasheela chord/scale object
      else nil
      end
      %% for sim of notes
      %% for notes without extra accidental in a chord come up with some default sign meaning untransposed..
      %%
      %% for chord and scale root and their pitch classes (oh -- their pitch classes will even be harder...)
      %% NOTE: do this later. For now put in some note into score or browse warning saying that accidentals for analytical objects are not supported yet.
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
      Defaults = unit(upperMarkupMakers: [MakeET41Accidentals_Markup HS.out.makeNonChordTone_Markup])
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