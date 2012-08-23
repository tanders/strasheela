
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
   MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'   
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   HS at '../HarmonisedScore.ozf'
   HS_Score at 'Score.ozf'
   HS_DB at 'Database.ozf'

%    Browser(browse:Browse)
export
   AddExplorerOut_ChordsToScore

   MakeNoteToFomusClause
   MakeChordToFomusClause
   MakeScaleToFomusClause
   VsToFomusForLilyMarks
   VsToFomusMarks AppendFomusMarks 
   FomusPCs_Default
   MakeCentOffset_FomusMarks
   MakeNonChordTone_FomusMarks
   MakeAdaptiveJI_FomusForLilyMarks MakeAdaptiveJI2_FomusForLilyMarks
   MakeChordComment_FomusForLilyMarks MakeChordRatios_FomusForLilyMarks
   MakeComment_FomusMarks MakeChordRatios_FomusMarks
   MakeScaleComment_FomusForLilyMarks
   
   RenderAndShowLilypond

   
   MakeNonChordTone_LilyMarkup MakeAdaptiveJI_Marker MakeAdaptiveJI2_Marker
   MakeChordComment_LilyMarkup MakeChordRatios_LilyMarkup MakeScaleComment_LilyMarkup
   
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
   %% renderAndShowLilypond (default HS.out.renderAndShowLilypond): binay procedure for outputting the result to Lilypond with the interface {RenderAndShowLilypond MyScore Args}.
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
		      renderAndShowLilypond: RenderAndShowLilypond
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
			     %% Csound output of score
			     {Out.renderAndPlayCsound MyScore
			      unit(file:FileName)}
			     %% Lily
			     {As.renderAndShowLilypond MyScore
			      unit(file:FileName
				   prefix: As.prefix)}
			     %% Archive output
			     {Out.outputScoreConstructor X
			      unit(file:FileName)}
			  end
		       end
	   label: As.outname)}
   end


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Customised Fomus output
%%%

   /** %% [Aux] If GetPitchClass=pc then PC is returned, otherwise PC is translated to closed MIDI pitch class depending on PitchUnit.
   %% */
   %% TODO: better fun name?
   fun {InterpretPC PC GetPitchClass PitchUnit}
      case GetPitchClass of midi then
	 {FloatToInt {MUtils.pitchToMidi PC PitchUnit unit}}
      [] pc then PC
      end
   end
   
   /** %% [Aux] Expects a pitch class (an int) and a tuple mapping pitch classes to enharmonic notation as supported by Fomus, i.e. an Atom that consist of a pitch nominal in A-G and an accidental. Returns a pair of strings Nominal#Accidental.
   %% */
   fun {PcToEnharmonics PC Table}
      Aux1 = Table.PC
      Aux2 = if {IsAtom Aux1}
	     then {AtomToString Aux1}
	     else Aux1
	     end
   in
      [Aux2.1]#Aux2.2
   end
   /** %% MakeNoteToFomusClause adds support for HS notes (instances of class HS.score.pitchClassMixin) to Fomus export with customisable enharmonic notation. More specifically, it returns a clause that can be appended to the given to the argument eventClauses of Out.renderFomus and friends.
   %%
   %% Args:
   %% 'table' (default FomusPCs_Default): a tuplet that maps pitch classes (ints) to Fomus pitch classes (strings or atoms of symbolic note names). A valid Fomus pitch class consists of a nominal and a Fomus accidental (e.g., 'Cn' or 'C#'). Note, if 'getPitchClass' is set to 'midi', then table must have entries for PCs 0-12 (0 and 12 are 'Cn').
   %% 'getSettings': unary function that expects the processed note and returns a record of fomus settings. This function can be used to arbitrarily customise the notation of each note depending on the note itself (only standard note settings like time etc cannot be overwritten).
   %% 'getPitchClass' (either pc or midi, default pc): specification how the pitch class is accessed that is used as index into table. If 'pc' the note's pitch class is used, if 'midi' this value depends on the note's pitchInMidi.
   %% */
   fun {MakeNoteToFomusClause Args}
      Defaults = unit(table: FomusPCs_Default
		      getPitchClass: pc 
		      getSettings: fun {$ _} unit end)
      As = {Adjoin Defaults Args}
   in
      HS_Score.isPitchClassMixin
      # fun {$ MyNote PartId}
	   PC = {InterpretPC {MyNote getPitchClass($)}
		 As.getPitchClass
		 {{MyNote getPitchClassParameter($)} getUnit($)}}
	   Nominal#Acc = {PcToEnharmonics PC As.table}
	   %% "carry over" octave for pitch classes "of next octave"
	   Oct = {MyNote getOctave($)} + if As.getPitchClass==midi andthen PC==12
					 then 1
					 else 0
					 end
	in
	   {Out.record2FomusNote
	    {Adjoin {As.getSettings MyNote}
	     unit(part:PartId
		  time:{MyNote getStartTimeInBeats($)}
		  dur:{MyNote getDurationInBeats($)}
		  dynamic: {MyNote getAmplitudeInVelocity($)} / 127.0
		  pitch:Nominal#Acc#Oct
		  acc:Acc)}
	    MyNote}
	end
   end
   /** %% [Aux] Returns a chord/scale processing function for note-eventClause, which returns the Fomus code for a Strasheela chord/scale object.
   %%
   %% Args:
   %% 'table' (default FomusPCs_Default): a tuplet that maps pitch classes (ints) to Fomus pitch classes (strings or atoms of symbolic note names). A valid Fomus pitch class consists of a nominal and a Fomus accidental (e.g., 'Cn' or 'C#').
   %%
   %% 'getSettings': unary function that expects the processed chord and returns a record of fomus settings. This function can be used to arbitrarily customise the notation of each root note depending on the note itself (only standard settings like time etc cannot be overwritten).
   %%
   %% 'grace': a pair of Fomus grace settings (see http://fomus.sourceforge.net/doc.html/Grace-Notes-_0028File_0029.html#Grace-Notes-_0028File_0029). The first setting is for notating the first pitch class and the second for the remaining pitch classes.
   %% */
   fun {MakePCCollToFomus Args}
      Defaults = unit(table: FomusPCs_Default
		      getPitchClass: pc 
		      getSettings: fun {$ _} unit end
		      grace: 0#0)
      As = {Adjoin Defaults Args}
   in
      fun {$ MyChord PartId}
	 PitchUnit = {{MyChord getRootParameter($)} getUnit($)}
	 RootNominal#RootAcc = {PcToEnharmonics {InterpretPC {MyChord getRoot($)}
						 As.getPitchClass
						 PitchUnit}
				 As.table}
	 Oct = 4
	 Time = {MyChord getStartTimeInBeats($)}
	 fun {PcToFomus I PC}
	    Nominal#Acc = {PcToEnharmonics {InterpretPC PC As.getPitchClass PitchUnit}
			   As.table}
	    Oct = 4
	 in
	    {Out.record2FomusNote unit(part:PartId
				       grace: if I==1 then As.grace.1
					      else As.grace.2
					      end
				       time:Time
				       dur: 1 % a beat
				       pitch: Nominal#Acc#Oct
				       acc: Acc)
	     nil}
	 end
      in
	 %% PC collection pitch classes
	 {Out.listToVS {List.mapInd {HS_Score.pcSetToSequence {MyChord getPitchClasses($)}
				     {MyChord getRoot($)}}
			fun {$ I PC} {PcToFomus I PC} end}
	  "\n"}#"\n"
	 %% PC collection root
	 #{Out.record2FomusNote
	   {Adjoin {As.getSettings MyChord}
	    unit(part:PartId
		 time:Time
		 dur:{MyChord getDurationInBeats($)}
		 pitch: RootNominal#RootAcc#Oct
		 acc: RootAcc
% 		 %% TODO: make textual mark customisable (e.g., chord/scale name or ratios).
% 		 marks: ["x \""#({HS_DB.getName MyChord}.1)#"\""]
		)}
	   MyChord}
      end
   end
   
  /** %% MakeChordToFomusClause adds support for HS chord objects to Fomus export with customisable enharmonic notation. More specifically, it returns a clause that can be appended to the given to the argument eventClauses of Out.renderFomus and friends.
   %% MakeChordToFomusClause expects Table, a tuplet that maps pitch classes (ints) to Fomus pitch classes (strings or atoms of symbolic note names). A valid Fomus pitch class consists of a nominal and a Fomus accidental (e.g., 'Cn' or 'C#'). See functors like ET31.out for table examples.
   %%
   %% Args:
   %% 'table' (default FomusPCs_Default): a tuplet that maps pitch classes (ints) to Fomus pitch classes (strings or atoms of symbolic note names). A valid Fomus pitch class consists of a nominal and a Fomus accidental (e.g., 'Cn' or 'C#').
   %%
   %% 'getSettings': unary function that expects the processed chord and returns a record of fomus settings. This function can be used to arbitrarily customise the notation of each root note depending on the note itself (only standard settings like time etc cannot be overwritten).
   %% */ 
   fun {MakeChordToFomusClause Args}   
      HS_Score.isChord # {MakePCCollToFomus {Adjoin Args unit(grace: 0#0)}}
   end
   /** %% MakeScaleToFomusClause adds support for HS scale objects to Fomus export with customisable enharmonic notation. See MakeChordToFomusClause for more information.
   %% */
   %% TODO: sequence of grace notes with the following approach -- enable if Fomus supports these properly.
/*
   time 0 dur 1/4
    grace 0 pitch 50 ;
    grace + pitch 53 ;
    grace + pitch 56 ;
   time 0 dur 1/2 pitch 59 ;
   */
   fun {MakeScaleToFomusClause Args}   
      HS_Score.isScale # {MakePCCollToFomus {Adjoin Args unit(grace: 0#'+')}}
   end


   /** %% [markup function] Expects a VS and returns a Fomus settings record with this VS as a Lilypond markup.
   %%
   %% Args:
   %% 'where' (default 'below'): atom where to position markup, either 'above' or 'below'.
   %% */
   fun {VsToFomusForLilyMarks VS Args}
      Default = unit(where: below)
      As = {Adjoin Default Args}
      Where = case As.where of
		 above then "^"
	      [] below then "_"
	      end
   in
      if {Not {IsVirtualString VS}}
      then raise noVS(VS) end
	 unit % never returned 
      else unit('lily-insert': {Out.formatVS Where#"\\markup{"#VS#"}"})
      end
   end

   /** %% [markup function] Expects a VS and returns a Fomus markup record.
   %%
   %% Args:
   %% 'where' (default 'x'): atom in Fomus syntax where to position the VS (e.g., 'x', 'x^', 'x_' or 'x!', see http://fomus.sourceforge.net/doc.html/Articulation-Markings-_0028File_0029.html#Articulation-Markings-_0028File_0029). 
   %% */
   fun {VsToFomusMarks VS Args}
      Default = unit(where: 'x')
      As = {Adjoin Default Args}
   in
      if {Not {IsVirtualString VS}}
      then raise noVS(VS) end
	 unit % never returned 
      else unit(marks: [As.where#" \""#VS#"\""])
      end
   end

   /** %% [Note markup function] Expects two Fomus markup records (e.g., unit(marks: ['x "x"']), the value returned by MakeNonChordTone_FomusMarks) and returns a single record with those marks combined.  
   %% */
   fun {AppendFomusMarks Mark1 Mark2}
      Ms1 = {Value.condSelect Mark1 marks nil} 
      Ms2 = {Value.condSelect Mark2 marks nil}
   in
      {Adjoin {Adjoin Mark1 Mark2}
       unit(marks: {Append Ms1 Ms2})}
   end



   
   /** %% Fomus PC table for 12-TET intended, e.g., for MakeNoteToFomusClause as arg table.
   %% */
   FomusPCs_Default = pcs(0:'Cn' 1:'C#'
			  2:'Dn' 3:'Eb'
			  4:'En'
			  5:'Fn' 6:'F#'
			  7:'Gn' 8:'Ab' 
			  9:'An' 10:'Bb' 
			  11:'Bn'
			  %% If InterpretPC rounds to midi, then PC can be 12
			  12:'Cn')

   /** %% [Note markup function] Expects a note and returns a fomus settings record. The different of the pitch of MyNote and the closest 12-TET is annotated in cent.
   %% TODO: make accuracy argument. Currently accuracy is in cent (i.e. integer) to simplify the notation.
   %% */
   fun {MakeCentOffset_FomusMarks MyNote}
      Midi = {MyNote getPitchInMidi($)}
      CentOffset = {FloatToInt (Midi - {Round Midi}) * 100.0}
   in
      %% Note: VirtualString.toAtom: atoms are not GC-ed
      unit(marks: [{VirtualString.toAtom 'x_ "'#CentOffset#'c"'}])
   end
   
   /** %% [Note markup function] Expects a note and returns a fomus settings record. Non-harmonic tones are marked with an x, and for all other score objects unit (no settings) is returned. 
   %% */
   fun {MakeNonChordTone_FomusMarks MyNote}
      if {HS_Score.isInChordMixinForNote MyNote}
	 andthen {MyNote getChords($)} \= nil
	 andthen {MyNote isInChord($)} == 0
      then unit(marks: ['x "x"'])  % mark non-harmonic tones
%       then unit(marks: 'xx "x"')  % mark non-harmonic tones: causes Fomus error
      else unit
      end
   end

   /** %% [Note markup function] Expects a note and returns a fomus settings record with a 'lily-insert' VS that prints the adaptive JI pitch offset of this note in cent. For all other score objects nil is returned.
   %%
   %% Note that Lilypond does not necessarily preserve the order marks for multiple parts per staff. 
   %% */
   fun {MakeAdaptiveJI_FomusForLilyMarks MyNote}
      JIPitch = {HS_Score.getAdaptiveJIPitch MyNote unit}
      ETPitch = {MyNote getPitchInMidi($)}
   in
      if {Abs JIPitch-ETPitch} > 0.001
      then {VsToFomusForLilyMarks {GUtils.roundDigits (JIPitch-ETPitch)*100.0 1}#"c" unit}
      else {VsToFomusForLilyMarks "0c" unit} 
      end
   end

   /** %% [Note markup function] Expects a note and returns a fomus settings record with a 'lily-insert' VS that prints the adaptive JI pitch offset of this note and additionally the absolute pitch in cent. For all other score objects nil is returned.
   %%
   %% Note that Lilypond does not necessarily preserve the order marks for multiple parts per staff.
   %% */
   fun {MakeAdaptiveJI2_FomusForLilyMarks MyNote}
      JIPitch = {HS_Score.getAdaptiveJIPitch MyNote unit}
      ETPitch = {MyNote getPitchInMidi($)}
   in
      if {Abs JIPitch-ETPitch} > 0.001
      then {VsToFomusForLilyMarks "\\column {"#{GUtils.roundDigits (JIPitch-ETPitch)*100.0 1}#"c "#JIPitch#"c}" unit}
      else {VsToFomusForLilyMarks "\\column {"#0#"c "#{MyNote getPitchInMidi($)}#"c}" unit}
      end
   end

                  
   /** %% [Chord markup function] Expects a chord and returns the chord comment (a fomus settings record with a 'lily-insert' VS). For all other score objects nil is returned.
   %% */
   fun {MakeChordComment_FomusForLilyMarks MyChord}
      {VsToFomusForLilyMarks
       "\\column { "#{HS_DB.getName MyChord}.1#" } "
       unit}
   end
   
   /* %% [Chord markup function] Expects a chord and returns the chord as ratio spec (a fomus settings record with a 'lily-insert' VS): Transposition x untransposed PCs (a VS). For all other score objects nil is returned.
   %% */
   fun {MakeChordRatios_FomusForLilyMarks MyChord}
      {VsToFomusForLilyMarks
       "\\column { "
       #{Pc2RatioVS {MyChord getTransposition($)}}
       #" x ("
       #{Out.listToVS {Map {FS.reflect.lowerBoundList
			    {MyChord getUntransposedPitchClasses($)}}
		       Pc2RatioVS}
	 " "}
       #") }"
       unit}
   end
   
   /** %% [Chord markup function] Expects a chord or scale and returns the chord/scale comment in a fomus mark. For all other score objects nil is returned (Is it??).
   %% */
   fun {MakeComment_FomusMarks MyChord}
      ChordName = {HS_DB.getName MyChord}
   in
      if ChordName \= nil then  
	 {VsToFomusMarks ChordName.1
	  unit(where:'*') % Lyric text syllable (for automatic horizontal spacing)
	  % unit(where:'x_') % Text marking in italics below staff
	 }
      else nil
      end
   end

   /* %% [Chord markup function] Expects a chord and returns the chord as ratio spec as a fomus mark (on a single line): Transposition x untransposed PCs (a VS). For all other score objects nil is returned.
   %% */
   fun {MakeChordRatios_FomusMarks MyChord}
      {VsToFomusMarks
       {Pc2RatioVS {MyChord getTransposition($)}}
       #" x ("
       #{Out.listToVS {Map {FS.reflect.lowerBoundList
			    {MyChord getUntransposedPitchClasses($)}}
		       Pc2RatioVS}
	 " "}
       #")"
       unit(where:'x_')}
   end
   
   /** %% [Scale markup function] Expects a scale and returns the scale comment (a fomus settings record with a 'lily-insert' VS). For all other score objects nil is returned. 
   %% */
   fun {MakeScaleComment_FomusForLilyMarks MyScale}
      {VsToFomusForLilyMarks
       "\\column {"
       # {HS_DB.getName MyScale}.1
       # " } "
       unit}
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
   %% 'upperMarkupMakers' (default [MakeNonChordTone_LilyMarkup]): a list of unary functions (markup makers) for creating textual markup placed above the staff over a given score object. Each markup function expects a score object and returns a VS. There exist four cases of score objects for which markup can be applied: note objects in general, note objects in simultaneous containers of notes (notated as a chord in Lilypond), chord objects and scale objects. The definition of each markup function must care for all these cases (e.g., with an if expression test whether the input is a note object and then create some VS or alternatively create the empty VS nil). 
   %% 'lowerMarkupMakers' (default [MakeChordComment_LilyMarkup MakeScaleComment_LilyMarkup]): same as 'upperMarkupMakers', but for markups placed below the staff.
   %% 'codeBeforeNoteMakers' (default nil): list of unary functions for creating Lilypond code placed directly before a note. Each function expects a score object and returns a VS. There exist three cases of score objects for which markup can be applied: note objects in general, notes in simultaneous containers of notes (notated as a chord in Lilypond), and Strasheela chord/scale objects (the resulting Lilypond code is placed before the chord/scale root). The definition of each function must care for these cases.
   %% 'codeBeforePcCollectionMakers' (default nil): list of binary functions for creating Lilypond code placed directly before a Lilypond note that is part of a Lilypond representation of a Strasheela chord/scale pitch class. Each function expects a chord/scale object and a pitch class; it returns a VS.
   %%
   %% In addition, the arguments of Out.renderAndShowLilypond are supported. 
   %%
   %% Please note that HS.out.renderAndShowLilypond is defined by providing Out.renderAndShowLilypond the argument Clauses -- additional clauses are still possible, but adding new note/chord clauses will overwrite the support for defined by this procedure.
   %%
   %% */
   %%
   %% TODO: This def with its various special-case args is rather complex. Can I somehow refactor this def?
   %%
   %% NOTE: grace notes after the root (using \aftergrace) are incompatible with HE notation, so I use plain grace and put the root behind
   %%
   proc {RenderAndShowLilypond MyScore Args}
      Default = unit(pitchUnit: et12 % midi 
		     %%
		     pcsLilyNames: pcs(0:c 1:cis 2:d 3:'dis' 4:e 5:f
				       6:fis 7:g 8:gis 9:a 10:ais 11:b)
		     upperMarkupMakers: [MakeNonChordTone_LilyMarkup]
		     lowerMarkupMakers: [MakeChordComment_LilyMarkup MakeScaleComment_LilyMarkup]
		     codeBeforeNoteMakers: nil
		     codeBeforePcCollectionMakers: nil
		     getClef: fun {$ X}
				 nil % no clef
% 				 if {All {X getItems($)} HS.score.isPitchClassCollection}
% 				 then
% 				 else {Out.averagePitchClef X}
% 				 end
			      end
		    )
      As1 = {Adjoin Default Args}
      PitchesPerOctave = {MUtils.getPitchesPerOctave As1.pitchUnit}
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
      /** %% Expects a VS and returns a VS with " " added at end. If VS is nil then nil is returned. 
      %% */
      fun {TrailingSpace VS}
	 case VS of nil then nil
	 else VS#" "
	 end
      end
   in
      
      %% Expects a Strasheela note object and returns the corresponding
      %% Lilypond code (a VS). 
      %% */
      %% note: no tie-versions of args (as supported by Out.makeNoteToLily2)
      fun {MakeNoteToLily Args}
	 PCsLilyNames = Args.pcsLilyNames
	 PitchesPerOctave = Args.pitchesPerOctave
	 UpperMarkupMakers = Args.upperMarkupMakers
	 LowerMarkupMakers = Args.lowerMarkupMakers
	 CodeBeforeNoteMakers = Args.codeBeforeNoteMakers
      in
	 fun {$ MyNote}
	    {{Out.makeNoteToLily2
	      unit(makePitch: fun {$ N}
				 {TemperamentPitchToLily {N getPitch($)}
				  PCsLilyNames PitchesPerOctave}
			      end
		   makeCodeAfter: fun {$ N}
				     {LowerMarkup {Map LowerMarkupMakers fun {$ F} {F N} end}}
				     #{UpperMarkup {Map UpperMarkupMakers fun {$ F} {F N} end}}
				  end
		   makeCodeBefore: fun {$ N}
				      {Out.listToVS {Map CodeBeforeNoteMakers fun {$ F} {F N} end}
				       " "}
				   end
		  )}
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
      fun {MakeSimToLilyChord  Args}
	 PCsLilyNames = Args.pcsLilyNames
	 PitchesPerOctave = Args.pitchesPerOctave
	 UpperMarkupMakers = Args.upperMarkupMakers
	 LowerMarkupMakers = Args.lowerMarkupMakers
	 CodeBeforeNoteMakers = Args.codeBeforeNoteMakers
      in
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
	    CodeBeforeAndPitches 
	    = {Out.listToVS
	       {Map Notes
		fun {$ N}
		   %% simply call TemperamentPitchToLily again 
		   {TrailingSpace {Out.listToVS
				   {Map CodeBeforeNoteMakers fun {$ F} {F N} end}
				   " "}}
		   #{TemperamentPitchToLily {N getPitch($)}
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
	    FirstChord = {Out.getUserLily Sim}#"\n <"#CodeBeforeAndPitches#">"#Rhythms.1#Markup
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
      fun {MakePcCollectionToLily Args}
	 PCsLilyNames = Args.pcsLilyNames
	 PitchesPerOctave = Args.pitchesPerOctave
	 UpperMarkupMakers = Args.upperMarkupMakers
	 LowerMarkupMakers = Args.lowerMarkupMakers
	 CodeBeforeNoteMakers = Args.codeBeforeNoteMakers
	 CodeBeforePcCollectionMakers = Args.codeBeforePcCollectionMakers
	 ChordOrScale = Args.chordOrScale
      in
	 fun {$ MyPcColl}
	    %% BUG: must not be used for chord root...
	    fun {PcToLily PC}	       
	       %% transpose PC into octave over middle C
	       TranspPC = PC+{HS.pitch 'C'#4} 
	    in
	       {TrailingSpace
		{Out.listToVS {Map CodeBeforePcCollectionMakers fun {$ F} {F MyPcColl PC} end}
		 " "}}
	       #{TemperamentPitchToLily TranspPC PCsLilyNames PitchesPerOctave}
	    end
	    %% code repetition of PcToLily!
	    fun {RootPcToLily PC}	       
	       %% transpose PC into octave over middle C
	       TranspPC = PC+{HS.pitch 'C'#4} 
	    in
	       {Out.listToVS {Map CodeBeforeNoteMakers fun {$ F} {F MyPcColl} end}
		" "}
	       #{TemperamentPitchToLily TranspPC PCsLilyNames PitchesPerOctave}
	    end
	    Rhythms = {Out.lilyMakeRhythms {MyPcColl getDurationParameter($)}}
	    AddedSigns = '#'({LowerMarkup {Map LowerMarkupMakers fun {$ F} {F MyPcColl} end}}
			     #{UpperMarkup {Map UpperMarkupMakers fun {$ F} {F MyPcColl} end}})
	 in
	    %% if MyChord is shorter than 64th then skip it (Out.lilyMakeRhythms
	    %% then returns nil)
	    if Rhythms == nil
	    then ''
	    else
	       %% TODO: root should also get "code before"
	       MyRoot = {PcToLily {MyPcColl getRoot($)}}
	       CodeBeforeAndRoot = {RootPcToLily {MyPcColl getRoot($)}}
	       CodeBeforeAndPitches = 
	       if ChordOrScale == scale then
		  %% scale case
		  "{"#{Out.listToVS {Map {HS_Score.pcSetToSequence
					  {MyPcColl getPitchClasses($)}
					  {MyPcColl getRoot($)}}
				     PcToLily}
		       %% set Lily grace note duration to 2
		       "4 "}#"} "
	       else %% chord case
		  "{ <"#{Out.listToVS {Map {HS_Score.pcSetToSequence
					    {MyPcColl getPitchClasses($)}
					    {MyPcColl getRoot($)}}
				       PcToLily}
			 %% set Lily grace note duration to half notes (2)
			 " "}#">2 }"
	       end
% 	       FirstPcColl = "\n\\grace "#CodeBeforeAndPitches#" "#CodeBeforeAndRoot#Rhythms.1#AddedSigns
	       FirstPcColl = "\n\\grace "#CodeBeforeAndPitches#" "#CodeBeforeAndRoot#Rhythms.1#AddedSigns
	    in
	       if {Length Rhythms} == 1 % is tied scale?
	       then FirstPcColl
		  %% tied scale
	       else FirstPcColl#" ~ "#{Out.listToVS {Map Rhythms.2
						     fun {$ R} MyRoot#R end
						    }
				       " ~ "}
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
   fun {MakeNonChordTone_LilyMarkup MyNote}
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
   %%
   %% Note that Lilypond does not necessarily preserve the order marks for multiple parts per staff. 
   %% */
   fun {MakeAdaptiveJI_Marker MyNote}
      if {MyNote isNote($)}
      then
	 JIPitch = {HS_Score.getAdaptiveJIPitch MyNote unit}
	 ETPitch = {MyNote getPitchInMidi($)}
      in
	 if {Abs JIPitch-ETPitch} > 0.001
	 then {GUtils.roundDigits (JIPitch-ETPitch)*100.0 1}#"c"
	 else "0c"
	 end
      else nil
      end
   end

   /** %% [Note markup function] Expects a note and returns a VS that prints the adaptive JI pitch offset of this note and additionally the absolute pitch in cent. For all other score objects nil is returned.
   %%
   %% Note that Lilypond does not necessarily preserve the order marks for multiple parts per staff.
   %% */
   fun {MakeAdaptiveJI2_Marker MyNote}
      if {MyNote isNote($)}
      then 
	 JIPitch = {HS_Score.getAdaptiveJIPitch MyNote unit}
	 ETPitch = {MyNote getPitchInMidi($)}
      in
	 if {Abs JIPitch-ETPitch} > 0.001
	 then "\\column {"#{GUtils.roundDigits (JIPitch-ETPitch)*100.0 1}#"c "#JIPitch#"c}"
	 else "\\column {"#0#"c "#{MyNote getPitchInMidi($)}#"c}"
	 end
      else nil
      end
   end

               
   /** %% [Chord markup function] Expects a chord and returns the chord comment (a VS). For all other score objects nil is returned.
   %% */
   proc {MakeChordComment_LilyMarkup MyChord ?Result}
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
   proc {MakeChordRatios_LilyMarkup MyChord ?Result}
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
   proc {MakeScaleComment_LilyMarkup MyScale ?Result}
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
