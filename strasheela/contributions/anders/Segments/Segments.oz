
%%% *************************************************************
%%% Copyright (C) 2004-2009 Torsten Anders (t.anders@qub.ac.uk) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% This functor defines re-usable musical segments. These segments are defined as sub-CSPs (extended scripts). They implement relatively specific musical ideas (e.g., a contrapuntual line, a specific motif, or a homophonic chord progression), but they support a number of arguments in order to make them flexible enough that they are interesting for re-use.
%%
%% Unfortunately, the documentation for many of the definitions here are not automatically extracted in the the HTML reference. Please check the source at ../Segments.oz for the documentation of these definitions. 
%%
%% */

%% TODO:
%%
%% OK - MakeCounterpoint_PatternMotifs and friends are broken (block)
%%
%% - MakeCounterpoint: add optional constraint: non-harmonic tone follows and is followed by note at least as long as the non-harmonic tone
%%
%% - revise MkEvenRhythm_ as subscript mixing
%%
%% - ?? for naming consistincy change all names starting with Mk into Make ?
%%
%% - add other rhythm subscript mixins
%%
%% - add doc to all motifs (things like MkArpeggio are still undetermined)
%%
%% - test polyphonic form spec MakeChordSlicesForm, PatternedPhrase, PatternedSlices
%%
%% - add other constraints for pitch contour, e.g., 
%%   - !! further Fenv patterns
%%   - Pattern.cycle
%%   - EveryNthPatterns
%%   - Fan
%%


functor
import
   FD FS
   Browser(browse:Browse)
   
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'

   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   Fenv at 'x-ozlib://anders/strasheela/Fenv/Fenv.ozf'

   HCP at 'source/HomophonicChordProgression.ozf'
   
export
   
   GetNoteIndex
   MakeParametersAccessor
   PitchContourAccessor

   MakeCounterpoint MakeCounterpoint_Seq
   MakeCounterpoint_PatternMotifs
   %% TMP comment -- fix defs below
%    MakeCounterpoint_PatternMotifs_DurationPitchcontour
%    MakeCounterpoint_PatternMotifs_OffsetDuration
%    MakeCounterpoint_PatternMotifs_OffsetDurationPitchcontour
   
   %% TMP comment -- fix defs below
%    MkEvenRhythm_

   MkPitchPattern MkFenvContour MkArpeggio MkArc MkRepetitions MkHook MkStairs
   
   MakeAkkord MakeAkkords MakeAkkords_Seq
   
   MakeChordSlicesForm
   PatternedPhrase
   PatternedSlices

%    TestMotif TestScoreSegment

   HomophonicChordProgression 
   
define

   HomophonicChordProgression = HCP.homophonicChordProgression

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Aux defs (defined at beginning, because code feeding depends on them)
%%%

   %% Each note belongs to only a single motif (i.e., no isorhythmic music with independend color and talea), but motifs can be compound (e.g., pitch intervals and durations).
   local
      MotifIndexName = multipleParams
   in
      /** %% MakeIndexNote is a constructor for HS.score.note which implicitly creates an index parameter.
      %% */
      MakeIndexNote = {Pattern.makeIndexConstructor HS.score.note [MotifIndexName]}
      /** %% Expects a note with index parameter and returns the index variable value.  
      %% */
      fun {GetNoteIndex N} {Pattern.getMotifIndex N MotifIndexName} end
   end

   /** %% Returns accessor function expecting a list of items (notes) and returning list of variables returned by Accessor (unary function or method). Example
   {MakeParametersAccessor getPitch}
   %% */
   fun {MakeParametersAccessor Accessor}
      fun {$ Ns} {Pattern.mapItems Ns Accessor} end
   end

   /** %% 
   %% */
   fun {PitchContourAccessor Ns}
      %% list of pitch contours is by one shorter, so a dummy is added at the start
      0 | {Pattern.contour {Pattern.mapItems Ns getPitch}}
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%
   %% Score segment constructors
   %%

   /** %% Returns list of notes to which common counterpoint rules are applied: non-harmonic tones are restricted and the first and last tone is constrained to a chord tone.
   %%
   %% Args.rargs:
   %% 'minPitch' and 'maxPitch' (default false): domain specification is notation supported by HS.pitch. Disabled if one of them is false.
   %% 'maxInterval' (default 3#1): ratio spec for the maximum melodic interval size permitted
   %% 'maxNonharmonicNoteSequence (default false)': Restrict the number of consecutive non-harmonic Notes to given maximum. Disabled if set to false.
   %% 'minPercentSteps' (default false): there are at least the specified percentage steps. Disabled if set to false.
   %% 'step' (default 8#7): ratio spec for the maximum step size permitted which counts for 'minPercentSteps' and maximum step size for dissonance resolutions
   %% 'maxRepetitions' (default false): how many pitch repetitions occur at maximum between consecutive Notes. Disabled if set to false.
   %% In addition, all arguments of Score.makeItems_iargs are supported.
   %% */
   %% TODO:
   %% - add optional constraint: non-harmonic tone follows and is followed by note at least as long as the non-harmonic tone
   %%
   MakeCounterpoint
   = {Score.defSubscript unit(super:Score.makeItems_iargs
			      rdefaults: unit(minPitch: false
					      maxPitch: false
					      maxInterval: 3#1
					      maxNonharmonicNoteSequence: false
					      %% BUG: in maxRepetitions
% 					   maxRepetitions:0
					      minPercentSteps: false
					      step:8#7)
			      idefaults: unit(
% 					 getChords: fun {$ Self}
% 						       [{Self findSimultaneousItem($ test:HS.score.isChord)}]
% 						    end
% 					 getScales: fun {$ Self}
% 						       [{Self findSimultaneousItem($ test:HS.score.isScale)}]
% 						    end
					    %% HS.score.note default for inChordB
					    constructor: {Score.makeConstructor HS.score.note
							  unit(inChordB: fd#(0#1))}
% 					 inScaleB:0
					    ))
      proc {$ Notes Args} % body
	 if Args.rargs.minPitch \= false andthen Args.rargs.maxPitch \= false then 
	    {HS.rules.restrictPitchDomain Notes Args.rargs.minPitch Args.rargs.maxPitch}
	 end
	 %%
	 %% counterpoint constraints
	 {HS.rules.maxInterval Notes
	  {FloatToInt {MUtils.ratioToKeynumInterval Args.rargs.maxInterval
		       {IntToFloat {HS.db.getPitchesPerOctave}}}}}
	 if Args.rargs.maxNonharmonicNoteSequence \= false then 
	    {HS.rules.maxNonharmonicNoteSequence Notes Args.rargs.maxNonharmonicNoteSequence}
	 end
%       {HS.rules.maxNonharmonicNotePercent Notes 10}
	 if Args.rargs.minPercentSteps \= false then 
	    {HS.rules.minPercentSteps Notes Args.rargs.minPercentSteps unit(step:Args.rargs.step)}
	 end
	 %% BUG: in HS.rules.maxRepetitions
%       {HS.rules.maxRepetitions Notes Args.rargs.maxRepetitions}
	 {HS.rules.resolveNonharmonicNotesStepwise Notes unit(maxInterval:Args.rargs.step)}
	 {HS.rules.clearDissonanceResolution Notes} % ??
%       {HS.rules.clearHarmonyAtChordBoundaries SimChords Notes}
      end}
   /** %% Same as MakeCounterpoint, but returns seq of notes and supports seq args.
   %% */
   MakeCounterpoint_Seq = {Score.itemslistToContainerSubscript MakeCounterpoint seq}


   /** %% Extended script returning a list of notes following user-specified pattern motifs (and also some counterpoint constraints, see super script MakeCounterpoint).   
   %%
   %% Args:
   %% 'motifSpecs' (required arg): list of motif specs (lists) of parameter/variable specs (lists). Parameter/variable specs can be symbolic if a corresponding motifSpecTransformers is provided. The order of parameter/variable specs must correspond to the order of motifAccessors and motifSpecTransformers.
   %% 'motifSpecTransformers' : list of unary functions translating symbolic parameter/variable specs into the corresponding FD integers. Note that parameter/variable specs which are already FD ints or the special pattern motif value '_' are used as is (i.e. application of the motifSpecTransformer is skipped). 'motifSpecTransformers' default is [GUtils.identity], i.e. only motifs with single param supported by default.
   %% 'motifAccessors' (required arg): list of unary functions expecting a list of notes and returning a list of variables of the same length as the list of notes. The motifs will be applied to these variables. 
   %% 'workOutEven' (default false): same arg as for Pattern.useMotifs
   %% In addition, all arguments of MakeCounterpoint are supported.
   %%
   %% See def of subscript MakeCounterpoint_PatternMotifs_DurationPitchcontour and friends for usage examples. These subscripts are also more convenient to use, whereas MakeCounterpoint_PatternMotifs is more general.
   %%
   %% NOTE: Arg.iargs.constructor must stay its default value, the note constructor must not be overwritten (the default constructor implicitly adds motif index parameters to the notes).
   %% Also, this constructor defines uncommon default values for the notes' parameters offsetTime (usual default is 0, new default is undetermined variable) and inChordB (usual default is 0, new default is 0/1 variable).
   %%
   %% */
   %% Idea of making Arg.iargs.constructor an argument again: create constructor on the fly with Pattern.makeIndexConstructor. However, this cannot be done with Score.defSubscript or Score.makeItems, as I cannot process the constructor argument before it is used. So, I would have to define MakeCounterpoint_PatternMotifs from scratch, or change def of Score.makeItems to allow for processing of constructor arg (the latter is not a good idea, I may then later need to process the processed arg etc). 
   %%
   %% TODO: consider higher-level constructor for multiple parallel voices with shared settings. Necessary?
   MakeCounterpoint_PatternMotifs
   = {Score.defSubscript
      unit(super:MakeCounterpoint
	   rdefaults: unit(motifSpecs:requiredArg % special value to cause somewhat meaningful error..
			   %% Note: only single transformer defined
			   motifSpecTransformers: [GUtils.identity]
			   %% required argument
			   motifAccessors: requiredArg
			   workOutEven:false
			  )
	   idefaults: unit(constructor:{Score.makeConstructor MakeIndexNote
					unit(offsetTime: fd#(0#FD.sup)
					     inChordB: fd#(0#1))}))
      proc {$ Notes Args}
	 {Pattern.useMotifs {LUtils.matTrans
			     {Map Args.rargs.motifAccessors fun {$ F} {F Notes} end}}
	  {Map Args.rargs.motifSpecs
	   fun {$ MotifSpec}
	      {Map MotifSpec
	       fun {$ ParamsSpec}
		  {Map {LUtils.matTrans
			[Args.rargs.motifSpecTransformers ParamsSpec]}
		   fun {$ [Transformer ParamSpec]}
		      if {FD.is ParamSpec} orelse ParamSpec == '_' then ParamSpec
		      else {Transformer ParamSpec}
		      end
		   end}
	       end}
	   end}
	  unit(indices:{Map Notes GetNoteIndex}
	       workOutEven:Args.rargs.workOutEven)}
      end}

% %%
% %% TODO: add SymbolicDurToInt, D etc in a modular/redefinable way
% %%

% /** %% Like MakeCounterpoint_PatternMotifs, but motif specs are two-element lists of symbolic note durations and pitch contours. Remember that the first contour value in a motif should always be '_'.
% %% Overwrites Args.rargs motifSpecTransformers and motifAccessors..
% %% Notes's offsetTime parameters have their usual default 0. 
% %% */
% MakeCounterpoint_PatternMotifs_DurationPitchcontour 
% = {Score.defSubscript
%    unit(super:MakeCounterpoint_PatternMotifs
% 	idefaults:unit(offsetTime:0)
% 	rdefaults:unit(%% motifSpecs are only example
% 		       motifSpecs:[[[d4 '_'] [d4 '+'] [d2 '+']]
% 				   [[d2 '_'] [d2 '-']]]
% 		       motifSpecTransformers: [SymbolicDurToInt Pattern.symbolToDirection] 
% 		       motifAccessors: [{MakeParametersAccessor getDuration}
% 					PitchContourAccessor]))
%    GUtils.binarySkip}

% /** %% Like MakeCounterpoint_PatternMotifs, but motif specs are two-element lists of symbolic note offset times and durations.
% %% Leave Args.rargs motifSpecTransformers and motifAccessors untouched..
% %% */
% MakeCounterpoint_PatternMotifs_OffsetDuration 
% = {Score.defSubscript 
%    unit(super:MakeCounterpoint_PatternMotifs
% 	rdefaults:unit(%% motifSpecs are only example
% 		       motifSpecs:[[[d4 d8] [0 d8] [0 d2]]
% 				   [[d4 d4] [0 d2]]]
% 		       motifSpecTransformers: [SymbolicDurToInt SymbolicDurToInt] 
% 		       motifAccessors: [{MakeParametersAccessor getOffsetTime}
% 					{MakeParametersAccessor getDuration}]))
%    GUtils.binarySkip}


% /** %% Like MakeCounterpoint_PatternMotifs, but motif specs are three-element lists of symbolic note offsets, durations and pitch contours. Remember that the first contour value in a motif should always be '_'.
% %% Leave Args.rargs motifSpecTransformers and motifAccessors untouched..
% %% */
% MakeCounterpoint_PatternMotifs_OffsetDurationPitchcontour 
% = {Score.defSubscript
%    unit(super:MakeCounterpoint_PatternMotifs
% 	rdefaults:unit(%% motifSpecs are only example
% 		       motifSpecs:[[[d4 d8 '_'] [0 d8 '+'] [0 d2 '+']]
% 				   [[d4 d4 '_'] [0 d2 '-']]]
% 		       motifSpecTransformers: [SymbolicDurToInt
% 					       SymbolicDurToInt
% 					       Pattern.symbolToDirection] 
% 		       motifAccessors: [{MakeParametersAccessor getOffsetTime}
% 					{MakeParametersAccessor getDuration}
% 					PitchContourAccessor]))
%    GUtils.binarySkip}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%
   %% Motif defs
   %%
   %% - form segments should be clearly perceivable as segments
   %%
   %%


% %%
% %% TODO: add SymbolicDurToInt, D etc in a modular/redefinable way
% %%

% /** %% Extended script for sequence of notes. By default, all notes are of same duration, except the first/last note, which is (usually) longer. By default, all note duration domains are restricted to the durations in D (can be overwritten with arg Args.iarg.duration). 
% %%
% %% Args.rargs
% %% longNote (default last): either 'first', 'last' or 'none'. If 'none', then all notes are of the same duration.
% %% mostDurs: duration of all notes except the long one. If there is only a single note (iargs.n is 1) then mostDurs specifies its duration.
% %% longDur (default false): duration of long note. If false, then this duration is not further constrained. 
% %% rhythmRule (default): unary proc applied to the list of note durations. Switched of if false. Setting this argument to a procedure *disables* the above Args.rargs.
% %% */
% MkEvenRhythm_
% = {Score.defSubscript unit(super:MakeCounterpoint_Seq
% 			   idefaults: unit(inChordB: 1 
% 					   inScaleB: 0
% % 					   getScales: fun {$ _} nil end
% 					   %% all explicitly declared durs
% 					   duration: fd # {Record.toList D}
% % 					   amplitude: fenv#{Fenv.linearFenv [[0.0 100.0] [1.0 30.0]]}
% 					  )
% 			   rdefaults: unit(rhythmRule: false
% 					   mostDurs: D.d16
% 					   longNote: last
% 					   longDur: D.d8
% 					  )
% 			  )
%    proc {$ NoteSeq Args}
%       if Args.rargs.rhythmRule \= false then
% 	 {Args.rargs.rhythmRule {NoteSeq mapItems($ getDuration)}}
%       else
% 	 %% (potentially) first of Durs is always long note
% 	 Durs = 
% 	 if Args.rargs.longNote == first then 
% 	    {NoteSeq mapItems($ getDuration)}
% 	 elseif Args.rargs.longNote == last then 
% 	    {Reverse {NoteSeq mapItems($ getDuration)}}
% 	 else {Reverse {NoteSeq mapItems($ getDuration)}}
% 	 end
%       in
% 	 if {Length Durs} == 1
% 	 then Durs.1 = Args.rargs.mostDurs
% 	 else 
% 	    if Args.rargs.longNote == 'none'  
% 	    then Durs.1 =: Durs.2.1
% 	    else Durs.1 >: Durs.2.1 
% 	    end
% 	    {Pattern.allEqual Durs.2}
% 	    Durs.2.1 = Args.rargs.mostDurs
% 	    %% NOTE: hack -- how to deal properly with this rhythm constraint?
% 	    if Args.rargs.longDur \= false andthen
% 	       Args.rargs.longDur > Args.rargs.mostDurs andthen
% 	       Args.rargs.longNote \= none
% 	    then Durs.1 = Args.rargs.longDur
% 	    end
% 	 end
%       end
%    end}

   /** %%
   %% Args.rargs
   %% 'pitchPattern': unary proc constraining list of pitches.
   %% */
   MkPitchPattern
   = {Score.defSubscript unit(super:MakeCounterpoint_Seq
			      rdefaults: unit(pitchPattern: proc {$ Xs}
							       {Pattern.continuous Xs '<:'}
							    end)
			     )
      proc {$ NoteSeq Args}
	 {Args.rargs.pitchPattern {NoteSeq mapItems($ getPitch)}}
      end}


   /** %%
   %% Args.rargs
   %% 'pitchFenv' (default: strictly ascending Fenv): Fenv constraining the pitch *contour*.
   %%
   %% */
   MkFenvContour
   = {Score.defSubscript unit(super:MakeCounterpoint_Seq
			      rdefaults: unit(pitchFenv: {Fenv.linearFenv [[0.0 0.0] [1.0 1.0]]})
			     )
      proc {$ NoteSeq Args}
	 {Pattern.fenvContour {NoteSeq mapItems($ getPitch)}
	  Args.rargs.direction}
      end}


   /** %%
   %% Args.rargs
   %% 'direction': direction of arpeggio as relation atom.
   %%
   %% Note: can result in search problems when some intervals early in arpeggio are relatively large and then the whole arpeggio does not fit into the pitch domain any more. This can be fixed, e.g., by setting rargs.maxInterval to a smaller value.
   %% */
   MkArpeggio
   = {Score.defSubscript unit(super:MakeCounterpoint_Seq
			      rdefaults: unit(direction: '<:')
			     )
      proc {$ NoteSeq Args}
	 {Pattern.continuous {NoteSeq mapItems($ getPitch)}
	  Args.rargs.direction}
      end}


   /** %%
   %% Args.rargs
   %% 'firstRel': arg of Pattern.arc
   %% 'tuningPointPos': arg of Pattern.arc
   %%
   %% Note: can make search complex (not much propagation?)
   %% */
   MkArc
   = {Score.defSubscript unit(super:MakeCounterpoint_Seq
% 			   rdefaults: unit(maxInterval: 4#3)
			     )
      proc {$ NoteSeq Args}
	 {Pattern.arc {NoteSeq mapItems($ getPitch)}
	  Args.rargs}
      end}

% /** %%
% %% Args.rargs
% %% 'firstRel': arg of Pattern.arc
% %% 'tuningPointPos': arg of Pattern.arc
% %%
% %% Note: can make search complex (not much propagation?)
% %% */
% MkCompositeContour_CombinedArcs
% = {Score.defSubscript unit(super:MakeCounterpoint_Seq
% 			  )
%    proc {$ NoteSeq Args}
%       {CompositeContour_CombinedArgs {NoteSeq mapItems($ getPitch)}
%        Args.rargs}
%    end}

   /** %%
   %% */
   MkRepetitions
   = {Score.defSubscript unit(super:MakeCounterpoint_Seq
			     )
      proc {$ NoteSeq Args}
	 {Pattern.allEqual {NoteSeq mapItems($ getPitch)}}
      end}

   /** %%
   %% Args.rargs: args of Hook
   %% */
   MkHook
   = {Score.defSubscript unit(super:MakeCounterpoint_Seq
			      rdefaults: unit
			     )
      proc {$ NoteSeq Args}
	 {Pattern.hook {NoteSeq mapItems($ getPitch)}
	  Args.rargs}
      end}

   /** %%
   %% Args.rargs: args of Stairs:
   %% 'n'
   %% 'rel'
   %%
   %% Note: can make search complex (not much propagation?)
   %% */
   MkStairs
   = {Score.defSubscript unit(super:MakeCounterpoint_Seq
			      rdefaults: unit
			     )
      proc {$ NoteSeq Args}
	 if {IsOdd Args.iargs.n} then {Browse 'Stairs\' n must be even'} end
	 {Pattern.stairs {NoteSeq mapItems($ getPitch)}
	  Args.rargs}
      end}



   /** %% Extended script creating an "akkord", i.e., a sim of notes (German term chosen to avoid confusion with analytical and silent chord object).
   %% All note durations in the akkord are equal, and pitches are always decreasing (i.e. the highest note is first).
   %%
   %% Args.iargs:
   %% 'n': number of tones per chord.
   %% any args given to single note of akkord (except arg pitch).
   %%
   %% Args.rargs:
   %% 'minPitch' and 'maxPitch' (default false): domain specification notation supported by HS.pitch. Disabled if one of them is false.
   %% 'minRange' and 'maxRange' (default false): min and max interval between lowest and highest note of each chord, specified as ratio (pair of ints). Disabled if false.
   %% 'minPcCard' (default 3): min number of different pitch classes expressed per akkord. Disabled if false. Note: make sure that iargs.n and cardiality of all chords is high enough.
   %% */
   MakeAkkord
   = {Score.defSubscript
      unit(super: Score.makeSim
	   idefaults: unit(n: 3
			   %% add support for domain spec args
			   constructor: {Score.makeConstructor HS.score.note
					 unit}
			   inChordB:1
% 			getChords: fun {$ Self}
% 				      [{Self findSimultaneousItem($ test:HS.score.isChord)}]
% 				   end
% 			getScales: fun {$ Self}
% 				      [{Self findSimultaneousItem($ test:HS.score.isScale)}]
% 				   end
% 			inScaleB:0
			  )
	   rdefaults: unit(minPitch: false
			   maxPitch: false
			   minRange: false
			   maxRange: false
			   minPcCard: 3 % false
			  ))
      proc {$ Akk Args}
	 Ns = {Akk getItems($)}
	 Ps = {Akk mapItems($ getPitch)}
      in
	 {Pattern.allEqual {Akk mapItems($ getDuration)}}
	 {Pattern.decreasing {Akk mapItems($ getPitch)}}
	 if Args.rargs.minPitch \= false andthen Args.rargs.maxPitch \= false then 
	    {HS.rules.restrictPitchDomain Ns Args.rargs.minPitch Args.rargs.maxPitch}
	 end
	 if Args.rargs.minRange \= false then
	    Ps.1 - {List.last Ps} >=: {HS.score.ratioToInterval Args.rargs.minRange}
% 	 {FloatToInt {MUtils.ratioToKeynumInterval Args.rargs.minRange
% 		      {IntToFloat {HS.db.getPitchesPerOctave}}}}
	 end
	 if Args.rargs.maxRange \= false then
	    Ps.1 - {List.last Ps} =<: {HS.score.ratioToInterval Args.rargs.maxRange}
% 	 {FloatToInt {MUtils.ratioToKeynumInterval Args.rargs.maxRange
% 		      {IntToFloat {HS.db.getPitchesPerOctave}}}}
	 end
	 if Args.rargs.minPcCard \= false then
	    PC_FS = {GUtils.intsToFS {Akk mapItems($ getPitchClass)}}
	    MyCard = {FD.decl}
	 in
	    MyCard = {FS.card PC_FS}
	    MyCard >=: Args.rargs.minPcCard
	 end
      end}



   /** %% Extended script creating a list of akkords.
   %%
   %% Args:
   %% 'akkN': number of akkords.
   %%
   %% Args.rargs:
   %% 'rule': unary proc applied list of all akkords.
   %% 'sopranoPattern' / 'bassPattern': unary proc: pattern applied to soprano/bass pitches of all akkords.
   %%
   %% See MakeAkkord for further args.
   %%
   %% */
   %%
   MakeAkkords
   = {Score.defSubscript
      unit(super: fun {$ Args}
		     Defaults = unit(akkN: 1)
		     As = {Adjoin Defaults Args}
		  in
		     {Score.makeItems  {Adjoin {Record.subtract As akkN}
					%% overwrite args 
					unit(n: As.akkN
					     constructor: MakeAkkord
					    )}}
		  end
	   idefaults: unit
	   rdefaults: unit(sopranoPattern: proc {$ Ps} skip end
			   bassPattern: proc {$ Ps} skip end
			   rule: proc {$ Cs} skip end))
      proc {$ Akks Args}
	 {Args.rargs.rule Akks}
	 {Args.rargs.sopranoPattern
	  {Map Akks fun {$ Akk} {Akk mapItems($ getPitch)}.1 end}}
	 {Args.rargs.bassPattern
	  {Map Akks fun {$ Akk} {List.last {Akk mapItems($ getPitch)}} end}}
      end}

   /** %% Same as MakeAkkords, but returns sequential container of akkords.
   %% */
   fun {MakeAkkords_Seq Args}
      {Score.make2 {Adjoin {Record.subtractList Args [akkN iargs rargs]}
		    seq({MakeAkkords {GUtils.keepList Args [akkN iargs rargs]}})}
       unit}
   end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%
   %% Polyphonic form spec
   %%

   /** %% Returns extended script for musical section where each segment in the section expresses a single chord. 
   %%
   %% Args:
   %% 'segments' (required): list of textual score specs: each spec which "express" one chord. 
   %% 'chords' (required): function returning list of chord objects (wrapped in function to protect variables).
   %% 'constructors' (required): constructors as expected by Score.make.
   %% further args: handed to top-level sequential.
   %%
   %% NB: Each segment must be sim, and sim items are specified at feat 1.
   %% NB: List of segments and list of chords must be of the same length (shorter list of chords causes fail).
   %%
   %% Note: this def is rather restricted in generality.. Alternatives are, e.g., HS.score.harmoniseScore.
   %% */
   %% TODO: if necessary allow for other arg forms (e.g. segments and chords may expect a null-ary fun which returns list of score specs).
   %% NOTE: wrapping in fun not necessary, if called within top-level script 
   proc {MakeChordSlicesForm Args ?MyScore}
      unit(segments:Segs chords:Chords constructors:Constrs ...) = Args
      FullSegments
      = {Map {LUtils.matTrans [Segs Chords]}
	 fun {$ [sim(_ ...)=Sim MyChord]}
	    End = {MyChord getEndTime($)}
	 in
	    sim([{Adjoin Sim
		  sim(endTime: End)} 
		 MyChord])
	 end}
   in
      MyScore
      = {Score.make2 {Adjoin {Record.subtractList Args [segments chords constructors]}
		      seq(FullSegments)}
	 {Adjoin Constrs add}}
   end

 
   /** %% Generates extended script for creating a phrase consisting of multiple segments, and for applying pattern constraints on these segments.  The resulting score topology is as follows, where the segmenents are form segments created by other extended scripts. 
   %%
   %% seq(segment+)
   %%
   %% Args:
   %% 'constructors': constructor spec for the top-level sims and seq, format as expected by Score.make. Features should be 'sim' and 'seq'. 
   %% 'pAccessor' (default GUtils.identity): unary function applied to each segment, returning a value for the argument pattern, e.g, a parameter value (FD int) or a score object (see below). 
   %% 'pattern' (default proc {$ Xs} skip end): unary procedure expecting/constraining the list of values returned by 'pAccessor' for all segments. 
   %% All other top-level arguments are given to the top-level seq.
   %%
   %% Args.segments:
   %% tuple of segment specifications, where each segment specifications is a record of the following arguments. (In principle it can be a record, but then the temporal order of segments depends on the order of features in the record)
   %% 'constructor': extended script (binary procedure) for creating the layer, commonly created with Score.defSubscript. Should return a score object (not a list of score objects).
   %% All other arguments in Args.segments are given to this constructor.
   %%
   %% The arguments of the returned extended script correspond to Args.
   %% */
   fun {PatternedPhrase Args}
      proc {$ InnerArgs ?MyScore}
	 Defaults = unit(
		       %% only for surrounding containers
		       constructors: unit
		       pAccessor: GUtils.identity
		       pattern: proc {$ Xs} skip end
		       )
	 As = {GUtils.recursiveAdjoin {GUtils.recursiveAdjoin Defaults Args} InnerArgs}
	 Segments = {Map {Record.toList As.segments}
		     fun {$ Spec}
			{Score.make2 {Adjoin {Record.subtractList Spec [constructor]} unit}
			 unit(unit: Spec.constructor)}
		     end}
      in
	 MyScore = {Score.make2 {Adjoin {Record.subtractList As
					 [constructors segments pAccessor pattern]}
				 seq(Segments)}
		    As.constructors}
	 thread
	    {As.pattern {MyScore mapItems($ As.pAccessor)}}
	 end
      end
   end



   /** %% Extended script for creating a sequence of polyphonic form segments, resulting score topology, where the segmenents are form segments created by other extended scripts. 
   %%
   %% seq(sim(segment+)+)
   %%
   %% The simultaneous containers can be though of as formal "slices", consisting of layers (the segmenents). Note that all slices are uniform in the sense that each slices consists of the same layers (i.e. the layers of each slices are created with the same constructors). However, depending on the flexibility of these layer constructors (e.g., their set of arguments) corresponding layers can also considerably differ across slices. Also, pattern constraints can be applied conveniently to lists of corresponding layers accross slices.
   %%
   %% PatternedSlices can be used, for example, to create the score with the actual notes for a harmonic CSP. For example, each slices could express its own harmony (e.g., sim chord object).
   %%
   %% Args:
   %% 'n': number of sims in the top-level seq (number of slices).
   %% 'constructors': constructor spec for the top-level sims and seq, format as expected by Score.make. Features should be 'sim' and 'seq'. 
   %%
   %% Args.layer:
   %% record/tuple of layer specifications, where each layer specifications is a record of the following arguments. Each layer specification is used for creating all instances of this layer accross the slices. 
   %% iargs.constructor: extended script (binary procedure) for creating the layer, commonly created with Score.defSubscript. Should return a score object (not a list of score objects).
   %% 'pAccessor' (default GUtils.identity): unary function applied to each layer instance, returning a value for the argument pattern, e.g, a parameter value (FD int) or a score object (see below). 
   %% 'pattern' (default proc {$ Xs} skip end): unary procedure expecting/constraining the list of values returned by 'pAccessor' for all instances of the present layer across slices. 
   %% In addition, (almost) all other constructor arguments are supported. These constructor arguments are supported in all formats introduced by Score.makeItems, such as each-args. However, it may be necessary to specify composite argument as each-args. For example, in order to specify an "rargs argument", the whole rargs record must be specified as each-args such as
   unit(rargs: each # [unit(<args1>) unit(<args2>) ...] ...)
   %%
   %% NB: arguments expected by Score.makeItems (n, constructor, handle, rule) *cannot* be handed to the layer constructors! 
   %% */
   %% ?? recursive use possible: segments created by PatternedSlices?
   %%
   %% Nachdenken: spec format is shorter than plain textual format of resulting score
   %% - textual format must be "mat-transed" so I have seq of sims (this def looks like sim of seqs def. I want resulting "blocks" of the other format, but this def format is more convenient because I can use Score.makeItems)
   %% - pattern spec more concise
   %%
   %% ?? TODO: allow that Specs is not only args for some specified constructor, but may also be nested score spec
   %% Alternatively, I can do this nested score spec in the specified constructor...
   %%
   %% TODO: index-based args for Score.makeItems -- makes this def more flexible as well..
   %%
   %% TODO: if Score.makeItems allows each-arg for constructor then I can insert "empty motifs" or other variants. Would this cause problems with pattern constraint -- I just have to filter empty motifs out (e.g., with LUtils.mappend)?
   %%
   %% TODO: return list of motifs or seq of motifs?
   %% NOTE: PatternedSlices is extended script but it is commonly used for *generating* extended scripts with default args. So, should PatternedSlices actually return proc, like PatternedPhrase?
   proc {PatternedSlices Args ?MyScore}
      Defaults = unit(n: 1
		      layers: unit
		      %% TODO: arg unused, remove?
% 		   sliceLayersEndTogether: false
		      %% only for surrounding containers
		      constructors: unit)
      As = {Adjoin Defaults Args}
      %% List of list of segments, inner list are corresponding consecutive motifs
      LayerSegmentss = {Map {Record.toList As.layers}
			proc {$ LSpec Segments}
			   LSpec_Defaults
			   = unit(pAccessor: GUtils.identity
				  pattern: proc {$ Xs} skip end
				 )
			   FullLSpec = {Adjoin LSpec_Defaults LSpec}
			in
			   Segments = {Score.makeItems {Adjoin {Record.subtractList FullLSpec
								[pAccessor pattern]}
							unit(n: As.n)}}
			   thread 
			      {FullLSpec.pattern {Map Segments FullLSpec.pAccessor}}
			   end
			end}
   in
      MyScore
      = {Score.make2
	 {Adjoin {Record.subtractList As {Arity Defaults}}
	  seq({Map {LUtils.matTrans LayerSegmentss}
	       fun {$ Segments} sim(Segments) end})}
	 {Adjoin As.constructors add}}
   end

   
end


