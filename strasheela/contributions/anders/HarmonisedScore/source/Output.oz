
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

/** %% This functor defines output for score objects and concepts introduced by HS, e.g., Lilypond output for chord and scale objects and means to define Lilypond output for different temperaments.
%% */


functor

import
   FS Explorer
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'   
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   HS_Score at 'Score.ozf'
   HS_DB at 'Database.ozf'

%    Browser(browse:Browse)
export
   AddExplorerOut_ChordsToScore

   RenderAndShowLilypond

   
   MakeNonChordTone_Markup MakeAdaptiveJI_Marker MakeAdaptiveJI2_Marker
   MakeChordComment_Markup MakeChordRatios_Markup MakeScaleComment_Markup
   
   MakeNoteToLily MakeSimToLilyChord MakePcCollectionToLily

   Pc2RatioVS
   
define

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Explorer Actions
%%%

   /** %% Creates an Explorer action for outputting a pure sequence of chords. The solution of the script for which this explorer action is used must be a sequential container with chord objects (i.e. without the actual notes). The Explorer output action creates a CSP with expects a chord sequence and returns a homophonic chord progression. The result is transformed into music notation (with Lilypond), sound (with Csound), and Strasheela code (archived score objects).
   %%
   %% Args:
   %% outname (default out): name under which this action appears in the Explorer menu; and beginning of resulting file names (which get added the space number in the Explorer and then the current time).
   %% renderAndShowLilypond (default Out.renderAndShowLilypond): binay procedure for outputting the result to Lilypond with the interface {RenderAndShowLilypond MyScore Args}.
   %% prefix (default "declare \nChordSeq \n= {Score.makeScore\n"): VS added at the beginning of the resulting Lilypond file. 
   %% chordsToScore (default HS.score.chordsToScore): ternary procedure implementing the CSP used internally for creating the notes for the given chords. Interface: {ChordsToScore ChordSpecs Args ?ScoreWithNotes}. 
   %% Further, all args of chordsToScore are supported.
   %% 
   %%
   %% IMPORTANT: Args.chordsToScore typically conducts a search which potentially can fail (e.g., if insufficient arguments are provided)!
   %%
   %% */
   proc {AddExplorerOut_ChordsToScore Args}
      Defaults = unit(outname:out
% 		      value:random
		      chordsToScore: HS_Score.chordsToScore
		      %% ?? TMP: replace with RenderAndShowLilypond?
		      renderAndShowLilypond: Out.renderAndShowLilypond
		      prefix: "declare \nChordSeq \n= {Score.makeScore\n")
      As = {Adjoin Defaults Args}
   in
      {Explorer.object
       add(information proc {$ I X}
			  FileName = As.outname#"-"#I#"-"#{GUtils.timeForFileName}
		       in
			  if {Score.isScoreObject X}
			  then
			     MyScore = {As.chordsToScore
					{Map {X collect($ test:HS_Score.isChord)}
					 fun {$ C}
					    %% timeUnit is not exported by toInitRecord,
					    %% and ignore sopranoChordDegree
					    {Adjoin {Record.subtract {C toInitRecord($)}
						     sopranoChordDegree}
					     chord(timeUnit:{C getTimeUnit($)})}
					 end}
					As}
			  in
			     %% Lily
			     {As.renderAndShowLilypond MyScore
			      unit(file:FileName
				   prefix: As.prefix)}
			     %% Csound output of score
			     {Out.renderAndPlayCsound MyScore
			      unit(file:FileName)}
			     %% Archive output
			     {Out.outputScoreConstructor X
			      unit(file:FileName)}
			  end
		       end
	   label: As.outname)}
   end
   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Customised Lilypond output
%%%

%%%
%%% Top-level def
%%%
      
   /** %% HS.out.renderAndShowLilypond is a variant of Out.renderAndShowLilypond that additionally notates chord and scale objects and also supports different temperaments beyond 12 ET.
   %%
   %% Args:
   %%
   %% 'pitchUnit': a pitch unit atom for which the Lilypond output is defined.
   %% 'pcsLilyNames' (default pcs(0:c 1:cis 2:d 3:'dis' 4:e 5:f 6:fis 7:g 8:gis 9:a 10:ais 11:b)): tuple of atomes that assigns to each pitch class of the temperament a Lilypond pitch name. The width of the tuple should correspond to the pitch unit.
   %% 'upperMarkupMakers' (default [MakeNonChordTone_Markup]): a list of unary functions for creating textual markup placed above the staff over a given score object. Each markup function expects a score object and returns a VS. There exist four cases of score objects for which markup can be applied: note objects, simultaneous containers of notes (notated as a chord in Lilypond), chord objects and scale objects. The definition of each markup function must care for all these cases (e.g., with an if expression test whether the input is a note object and then create some VS or alternatively create the empty VS nil). 
   %% 'lowerMarkupMakers' (default [MakeChordComment_Markup MakeScaleComment_Markup]): same as 'upperMarkupMakers', but for markups placed below the staff.
   %%
   %% In addition, the arguments of Out.renderAndShowLilypond are supported. 
   %%
   %% Please note that HS.out.renderAndShowLilypond is defined by providing Out.renderAndShowLilypond the argument Clauses -- additional clauses are still possible, but adding new note/chord clauses will overwrite the support for defined by this procedure.
   %%
   %% */
   %%
   %% TODO: Revise: put grace notes after root, see ~/lilypond/ReviseET31/HarmonicProgression-Lilytest.ly
   %%
   proc {RenderAndShowLilypond MyScore Args}
      Default = unit(pitchUnit: et12
		     %%
		     pcsLilyNames: pcs(0:c 1:cis 2:d 3:'dis' 4:e 5:f
				       6:fis 7:g 8:gis 9:a 10:ais 11:b)
		     upperMarkupMakers: [MakeNonChordTone_Markup]
		     lowerMarkupMakers: [MakeChordComment_Markup MakeScaleComment_Markup])
      As1 = {Adjoin Default Args}
      PitchesPerOctave = {Score.getPitchesPerOctave As1.pitchUnit}
      fun {IsNote X}
	 {X isNote($)} andthen 
	 {X getPitchUnit($)} == As1.pitchUnit
      end
      fun {IsChord X}
	 {HS_Score.isChord X} andthen 
	 {{X getRootParameter($)} getUnit($)} == As1.pitchUnit
      end
      fun {IsScale X}
	 {HS_Score.isScale X} andthen 
	 {{X getRootParameter($)} getUnit($)} == As1.pitchUnit
      end
      AddedClauses = [Out.isLilyChord#{MakeSimToLilyChord
				       {Adjoin As1
					unit(pitchesPerOctave: PitchesPerOctave)}}
		      IsNote#{MakeNoteToLily
			      {Adjoin As1
			       unit(pitchesPerOctave: PitchesPerOctave)}}
		      IsChord#{MakePcCollectionToLily
			       {Adjoin As1
				unit(pitchesPerOctave: PitchesPerOctave
				     chordOrScale: chord)}}
		      IsScale#{MakePcCollectionToLily
			       {Adjoin As1
				unit(pitchesPerOctave: PitchesPerOctave
				     chordOrScale: scale)}}]
      AddedArgs = unit(clauses:if {HasFeature Args clauses}
			       then {Append Args.clauses AddedClauses}
			       else AddedClauses
			       end
		      )
      As2 = {Adjoin As1 AddedArgs}
   in
      {Out.renderAndShowLilypond MyScore As2}
   end

   
   local
      %% Markups is a list of VS 
      fun {CombineMarkups Markups Lilycode}
	 ReducedMarkups = {LUtils.remove Markups fun {$ X} X==nil end}
      in
	 case ReducedMarkups of nil then nil
	 else 
	    {Out.listToVS [Lilycode {Out.listToVS ReducedMarkups " "} "}"]
	     ""}
	 end
      end
      fun {LowerMarkup Markups} {CombineMarkups Markups "_\\markup{"} end
      fun {UpperMarkup Markups} {CombineMarkups Markups "^\\markup{"} end
      fun {ColumnMarkup Markups} {CombineMarkups Markups "\\column{"} end
      fun {LineMarkup Markups} {CombineMarkups Markups "\\line{"} end
   in
      /** %% Expects a Strasheela note object and returns the corresponding
      %% Lilypond code (a VS). 
      %% */
      fun {MakeNoteToLily unit(pcsLilyNames: PCsLilyNames
			       pitchesPerOctave: PitchesPerOctave
			       upperMarkupMakers: UpperMarkupMakers
			       lowerMarkupMakers: LowerMarkupMakers
			       ...)}
	 fun {$ MyNote}
	    {{Out.makeNoteToLily2
	      fun {$ N}
		 {TemperamentPitchToLily {N getPitch($)}
		  PCsLilyNames PitchesPerOctave}
	      end
	      fun {$ N}
		 {LowerMarkup {Map LowerMarkupMakers fun {$ F} {F N} end}}
		 #{UpperMarkup {Map UpperMarkupMakers fun {$ F} {F N} end}}
	      end}
	     MyNote}
	 end
      end
      
      /** %% Outputs Sim (for which IsLilyChord must return true) as a Lilypond chord VS. 
      %%
      %% */
      %%
      %% Note: multiple markups for multiple notes might cause cluttered notation... Also, in case of optional markup that is only shown for some notes it is impossible to see to which note the markup was added. Nevertheless, markups can show valueable information...
      %% How can I organise markups quasi like in a table in order to avoid clutter: using markup \line, \column, and \null?
      %%
      %% TODO: test whether adding an " " results in a space in columns, so the note to which the sign was added can be identified.
      %% Alternative: lily empty markup \null
      fun {MakeSimToLilyChord unit(pcsLilyNames: PCsLilyNames
				   pitchesPerOctave: PitchesPerOctave
				   upperMarkupMakers: UpperMarkupMakers
				   lowerMarkupMakers: LowerMarkupMakers
				   ...)}
	 fun {$ Sim}
	    Notes = {Sim getItems($)}
	    Pitches = {Out.listToVS
		       {Map Notes
			fun {$ N}
			   {TemperamentPitchToLily {N getPitch($)}
			    PCsLilyNames
			    PitchesPerOctave}
			end}
		       " "}
	    Rhythms = {Out.lilyMakeRhythms
		       {Notes.1 getDurationParameter($)}}
	    Markup = '#'({LowerMarkup
			  [{ColumnMarkup
			    {Map Notes
			     fun {$ N}
				{LineMarkup 
				 {Map LowerMarkupMakers fun {$ F} {F N} end}}
			     end}}]}
			 {UpperMarkup
			  [{ColumnMarkup
			    {Map Notes
			     fun {$ N}
				{LineMarkup 
				 {Map UpperMarkupMakers fun {$ F} {F N} end}}
			     end}}]})
	    FirstChord = {Out.getUserLily Sim}#"\n <"#Pitches#">"#Rhythms.1#Markup
	 in
	    if {Length Rhythms} == 1
	    then FirstChord
	    else FirstChord#{Out.listToVS
			     {Map Rhythms.2
			      fun {$ R} " ~ <"#Pitches#">"#R#Markup end}
			     " "}
	    end
	 end
      end

      /** %% Creates Lilypond output (VS) for a PC collection (chord or scale). The PC collection's duration and root is notated by a single a note, all pitch classes as grace notes are following.
      %% */
      %%
      fun {MakePcCollectionToLily unit(pcsLilyNames: PCsLilyNames
				       pitchesPerOctave: PitchesPerOctave
				       upperMarkupMakers: UpperMarkupMakers
				       lowerMarkupMakers: LowerMarkupMakers
				       chordOrScale: ChordOrScale
				       ...)}
	 fun {PitchToLily P}
	    {TemperamentPitchToLily P PCsLilyNames PitchesPerOctave}
	 end
      in
	 fun {$ MyPcColl}
	    Rhythms = {Out.lilyMakeRhythms {MyPcColl getDurationParameter($)}}
	    AddedSigns = '#'({LowerMarkup {Map LowerMarkupMakers fun {$ F} {F MyPcColl} end}}
			     #{UpperMarkup {Map UpperMarkupMakers fun {$ F} {F MyPcColl} end}})
	 in
%       {Browse rhythms#Rhythms}
	    %% if MyChord is shorter than 64th then skip it (Out.lilyMakeRhythms
	    %% then returns nil)
	    if Rhythms == nil
	    then ''
	    else
	       MyRoot = {PitchToLily {MyPcColl getRoot($)}}
	       MyPitches = 
	       if ChordOrScale == scale then
		  "{"#{Out.listToVS {Map {HS_Score.pcSetToSequence
					  {MyPcColl getPitchClasses($)}
					  {MyPcColl getRoot($)}}
				     PitchToLily}
		       %% set Lily grace note duration to 4
		       "4 "}#"} "
	       else %% chord case
		  "{ <"#{Out.listToVS {Map {HS_Score.pcSetToSequence
					    {MyPcColl getPitchClasses($)}
					    {MyPcColl getRoot($)}}
				       PitchToLily}
			 %% set Lily grace note duration to quarter notes (4)
			 " "}#">4 }"
	       end
	       FirstPcColl = "\\afterGrace "#MyRoot#Rhythms.1#AddedSigns#MyPitches
	    in
	       if {Length Rhythms} == 1 % is tied scale?
	       then FirstPcColl
		  %% tied scale
	       else FirstPcColl#{Out.listToVS {Map Rhythms.2
					       %% TMP: tie did not work out of the box with \\afterGrace, simply removed for now
					       fun {$ R} MyRoot#R end
% 					 fun {$ R} " ~ "#MyRoot#R end
					      }
				 " "}
	       end
	    end
	 end
      end
   end

   
%%%
%%% Utils
%%%

   /** %% Transforms the pitch class MyPC into a ratio VS. Alternative ratio transformations are given (written like 1/2|1/3). If no transformation existists, 'n/a' is output.
   %% NOTE: transformation uses the current interval database, so it only works for interval databases defined with rations. Also,  because just intonation interval interpretations for intervals of a temperament are ambiguous the returned ratio may be missleading.. 
   %% */
   fun {Pc2RatioVS MyPC}
      fun {PrettyRatios Rs}
	 %% alternative ratio transformations written as 1/2|1/3
	 {Out.listToVS
	  {Map Rs fun {$ Nom#Den} Nom#'/'#Den end}
	  '|'}
      end
      Ratios = {HS_DB.pc2Ratios MyPC {HS_DB.getEditIntervalDB}}
   in
      if Ratios == nil
      then 'n/a'
      else {PrettyRatios Ratios}
      end
   end


   LilyOctaves = octs(",,,," ",,," ",," "," "" "'" "''" "'''" "''''")
   /** %% Given a tuple of Lilypond note nates (PCsLilyNames) and an integer pitch, returns the corresponding Lilypond pitch code (a VS).
   %% */
   fun {TemperamentPitchToLily MyPitch PCsLilyNames PitchesPerOctave}
      MyPC = {Int.'mod' MyPitch PitchesPerOctave}
      Oct = {Int.'div' MyPitch PitchesPerOctave} + 1
   in
      PCsLilyNames.MyPC # LilyOctaves.Oct
   end




%%%
%%% Markup definitions 
%%%

   
   /** %% [Note markup function] Expects a note and returns a VS. For harmonic tones the VS is " " and for non-harmonic tones "x". For all other score objects nil is returned.
   %% */
   fun {MakeNonChordTone_Markup MyNote}
      if {MyNote isNote($)}
      then if {HS_Score.isInChordMixinForNote MyNote}
	      andthen {MyNote getChords($)} \= nil
	      andthen {MyNote isInChord($)} == 0
	   then "x"
	   else nil %% alternative empty Lily markup: \null
	   end
      else nil
      end
   end

   /** %% [Note markup function] Expects a note and returns a VS that prints the adaptive JI pitch offset of this note in cent. For all other score objects nil is returned.
   %% */
   fun {MakeAdaptiveJI_Marker MyNote}
      if {MyNote isNote($)}
      then
	 JIPitch = {HS_Score.getAdaptiveJIPitch MyNote unit}
	 ETPitch = {MyNote getPitchInMidi($)}
      in
	 if {Abs JIPitch-ETPitch} > 0.001
	 then {GUtils.roundDigits (JIPitch-ETPitch)*100.0 1}#" c"
	 else "0 c"
	 end
      else nil
      end
   end

   /** %% [Note markup function] Expects a note and returns a VS that prints the adaptive JI pitch offset of this note and additionally the absolute pitch in cent. For all other score objects nil is returned.
   %% */
   fun {MakeAdaptiveJI2_Marker MyNote}
      if {MyNote isNote($)}
      then 
	 JIPitch = {HS_Score.getAdaptiveJIPitch MyNote unit}
	 ETPitch = {MyNote getPitchInMidi($)}
      in
	 if {Abs JIPitch-ETPitch} > 0.001
	 then "\\column {"#{GUtils.roundDigits (JIPitch-ETPitch)*100.0 1}#" c"#JIPitch#"}"
	 else "\\column {"#0#"c "#{MyNote getPitchInMidi($)}#"}"
	 end
      else nil
      end
   end

               
   /** %% [Chord markup function] Expects a chord and returns the chord comment (a VS). For all other score objects nil is returned.
   %% */
   proc {MakeChordComment_Markup MyChord ?Result}
      if {HS_Score.isChord MyChord}
      then Result = '#'('\\column { '
			{HS_DB.getName MyChord}.1
% 		   {Out.listToVS {HS.db.getName MyChord} '; '}
			' } ')
	 if {Not {IsVirtualString Result}}
	 then raise noVS(Result) end
	 end
      else Result = nil
      end
   end
   /* %% [Chord markup function] Expects a chord and returns the chord as ratio spec: Transposition x untransposed PCs (a VS). For all other score objects nil is returned.
   %% */
   proc {MakeChordRatios_Markup MyChord ?Result}
      if {HS_Score.isChord MyChord}
      then Result = '#'('\\column { '
			{Pc2RatioVS {MyChord getTransposition($)}}
			' x ('
			{Out.listToVS {Map {FS.reflect.lowerBoundList
					    {MyChord getUntransposedPitchClasses($)}}
				       Pc2RatioVS}
			 ' '}
			') }')
	 if {Not {IsVirtualString Result}}
	 then raise noVS(Result) end
	 end
      else Result = nil
      end
   end
            
   /** %% [Scale markup function] Expects a scale and returns the scale comment (a VS). For all other score objects nil is returned. 
   %% */
   proc {MakeScaleComment_Markup MyScale ?Result}
      if {HS_Score.isScale MyScale}
      then
% 	 ScaleComment = {HS_DB.getInternalScaleDB}.comment.{MyScale getIndex($)}
%       in
	 Result = '#'('\\column {'
		      {HS_DB.getName MyScale}.1
% 		   if {IsRecord ScaleComment} andthen {HasFeature ScaleComment comment}
% 		   then ScaleComment.comment
% 		   else ScaleComment
% 		   end
		      ' } ')
	 %% 
	 if {Not {IsVirtualString Result}}
	 then raise noVS(Result) end
	 end
      else Result = nil
      end
   end


   

end
