
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
%% In addition, this functor defines constraints (and expressive constraint applicators) that shape musical segments, such as constraints on the texture.
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
   SMapping at 'x-ozlib://anders/strasheela/source/ScoreMapping.ozf'
   Init at 'x-ozlib://anders/strasheela/source/Init.ozf'

   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   Fenv at 'x-ozlib://anders/strasheela/Fenv/Fenv.ozf'
   H at 'x-ozlib://anders/strasheela/Heuristics/Heuristics.ozf'
   
   HCP at 'source/HomophonicChordProgression.ozf'
   TSC at 'source/TransformableSubscript.ozf'
   SegsOut at 'source/Output.ozf'
   
export

   % MakeMotifIndexNote
   % GetMotifIndexOfNote
   MakeParametersAccessor
   PitchContourAccessor

   MakeCounterpoint_Mixin MakeCounterpoint MakeCounterpoint_Seq
   MakeCounterpoint_PatternMotifs
   MakeCounterpoint_PatternMotifs_DurationPitchcontour
   MakeCounterpoint_PatternMotifs_OffsetDuration
   MakeCounterpoint_PatternMotifs_OffsetDurationPitchcontour
   
   %% TMP comment -- fix defs below
%    MkEvenRhythm_

   PitchPattern FenvContour Arpeggio Arch Repetitions Hook Stairs
   
   MakeAkkord_Mixin MakeAkkord
   MakeAkkords_Mixin MakeAkkords MakeAkkords_Seq
   
   MakeChordSlicesForm
   PatternedPhrase
   PatternedSlices

%    TestMotif TestScoreSegment

   Texture TextureProgression_Index TextureProgression_Time
   Homophonic HeuristicHomophonic HierarchicHomophonic HomoDirectional
   
   
   HomophonicChordProgression

   TSC

   out: SegsOut
   
define

   HomophonicChordProgression = HCP.homophonicChordProgression
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Aux defs (defined at beginning, because code feeding depends on them)
%%%

   %% Obsolete, replaced by Pattern.makeMotifIndexClass
   %% 
   % %% Each note belongs to only a single motif (i.e., no isorhythmic music with independend color and talea), but motifs can be compound (e.g., pitch intervals and durations).
   % local
   %    MotifIndexName = multipleParams
   % in
   %    /** %% MakeMotifIndexNote is a constructor for HS.score.note which implicitly creates an index parameter.
   %    %% */
   %    MakeMotifIndexNote = {Pattern.makeIndexConstructor HS.score.note [MotifIndexName]}
   %    /** %% Expects a note that is part of a pattern motif (i.e. a note with a motif index parameter), and returns the motif number of this note (i.e. the index variable value). For example, all notes that are part of an instance of the motif which has been declared first have the motif index value 1 and so forth.
   %    %% */
   %    fun {GetMotifIndexOfNote N} {Pattern.getMotifIndex N MotifIndexName} end
   % end

   

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
%%%
%%% Score segment constructors
%%%

   /** %% Mixin script for a list of notes to which common counterpoint rules are applied: non-harmonic tones are restricted and the first and last tone is constrained to a chord tone.
   %%
   %% NOTE: this mixin script depends on a suitable super script and note constructor that provide information whether a note is non-harmonic or not.
   super: Score.makeItems_iargs
   constructor: {Score.makeConstructor HS.score.note unit(inChordB: fd#(0#1))}
   %% 
   %%
   %% Args.rargs:
   %% 'minPitch' and 'maxPitch' (default false): domain specification is notation supported by HS.pitch. Disabled if one of them is false.
   %% 'maxInterval' (default 3#1): ratio spec for the maximum melodic interval size permitted
   %% 'maxNonharmonicNoteSequence (default false)': Restrict the number of consecutive non-harmonic Notes to given maximum. Disabled if set to false.
   %% 'minPercentSteps' (default false): there are at least the specified percentage steps. Disabled if set to false.
   %% 'clearDissonanceResolution' (default false): If in one voice there occurs a non-chord tone followed by a chord tone (a dissonance resolution), then no other voice should obscure this resolution by a non-chord tone starting together with the tone resolving the dissonance. Disabled if set to false.
   %% 'step' (default 8#7): ratio spec for the maximum step size permitted which counts for 'minPercentSteps' and maximum step size for dissonance resolutions
   %% 'maxRepetitions' (default false): how many pitch repetitions occur at maximum between consecutive Notes. Disabled if set to false.
   %% */
   %% TODO:
   %% - add optional constraint: non-harmonic tone follows and is followed by note at least as long as the non-harmonic tone
   %%
   MakeCounterpoint_Mixin
   = {Score.defMixinSubscript unit(rdefaults: unit(minPitch: false
						   maxPitch: false
						   maxInterval: 3#1
						   maxNonharmonicNoteSequence: false
						   %% BUG: in maxRepetitions
% 					   maxRepetitions:0
						   minPercentSteps: false
						   clearDissonanceResolution: false
						   step:8#7))
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
	 if Args.rargs.clearDissonanceResolution \= false then 
	    {HS.rules.clearDissonanceResolution Notes} % ??
	 end
%       {HS.rules.clearHarmonyAtChordBoundaries SimChords Notes}
      end}

   /** %% Script version of MakeCounterpoint_Mixin. In contrast to MakeCounterpoint_Mixin, MakeCounterpoint uses a suitable super script and note constructor by default.
   %% In addition, all arguments of Score.makeItems_iargs are supported.
   %% */
   MakeCounterpoint
   = {Score.defSubscript unit(super:Score.makeItems_iargs
			      mixins: [MakeCounterpoint_Mixin]
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
      nil}
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
	   idefaults: unit(constructor:{Score.makeConstructor {Pattern.makeMotifIndexClass HS.score.note}
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
	  unit(indices:{Map Notes {GUtils.toFun getMotifIndex}}
	       workOutEven:Args.rargs.workOutEven)}
      end}


   /** %% Like MakeCounterpoint_PatternMotifs, but motif specs are two-element lists of symbolic note durations and pitch contours. Remember that the first contour value in a motif should always be '_'.
   %% Overwrites Args.rargs motifSpecTransformers and motifAccessors..
   %% Notes's offsetTime parameters have their usual default 0. 
   %% */
   MakeCounterpoint_PatternMotifs_DurationPitchcontour 
   = {Score.defSubscript
      unit(super:MakeCounterpoint_PatternMotifs
	   idefaults:unit(offsetTime:0)
	   rdefaults:unit(%% motifSpecs are only example
			  motifSpecs:[[[d4 '_'] [d4 '+'] [d2 '+']]
				      [[d2 '_'] [d2 '-']]]
			  motifSpecTransformers: [Init.symbolicDurToInt Pattern.symbolToDirection] 
			  motifAccessors: [{MakeParametersAccessor getDuration}
					   PitchContourAccessor]))
      GUtils.binarySkip}

   /** %% Like MakeCounterpoint_PatternMotifs, but motif specs are two-element lists of symbolic note offset times and durations.
   %% Leave Args.rargs motifSpecTransformers and motifAccessors untouched..
   %% */
   MakeCounterpoint_PatternMotifs_OffsetDuration 
   = {Score.defSubscript 
      unit(super:MakeCounterpoint_PatternMotifs
	   rdefaults:unit(%% motifSpecs are only example
			  motifSpecs:[[[d4 d8] [0 d8] [0 d2]]
				      [[d4 d4] [0 d2]]]
			  motifSpecTransformers: [Init.symbolicDurToInt Init.symbolicDurToInt] 
			  motifAccessors: [{MakeParametersAccessor getOffsetTime}
					   {MakeParametersAccessor getDuration}]))
      GUtils.binarySkip}


   /** %% Like MakeCounterpoint_PatternMotifs, but motif specs are three-element lists of symbolic note offsets, durations and pitch contours. Remember that the first contour value in a motif should always be '_'.
   %% Leave Args.rargs motifSpecTransformers and motifAccessors untouched..
   %% */
   MakeCounterpoint_PatternMotifs_OffsetDurationPitchcontour 
   = {Score.defSubscript
      unit(super:MakeCounterpoint_PatternMotifs
	   rdefaults:unit(%% motifSpecs are only example
			  motifSpecs:[[[d4 d8 '_'] [0 d8 '+'] [0 d2 '+']]
				      [[d4 d4 '_'] [0 d2 '-']]]
			  motifSpecTransformers: [Init.symbolicDurToInt
						  Init.symbolicDurToInt
						  Pattern.symbolToDirection] 
			  motifAccessors: [{MakeParametersAccessor getOffsetTime}
					   {MakeParametersAccessor getDuration}
					   PitchContourAccessor]))
      GUtils.binarySkip}



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

   /** %% Mixin subscript for a note sequence that applies a given pattern constraint to note pitches.
   %%
   %% Args.rargs
   %% 'pitchPattern' (default: proc {$ Xs} {Pattern.continuous Xs '<:'} end): unary proc constraining list of pitches.
   %%           
   %% */
   PitchPattern
   = {Score.defMixinSubscript unit(rdefaults: unit(pitchPattern: proc {$ Xs} {Pattern.continuous Xs '<:'} end)
				  )
      proc {$ NoteSeq Args}
	 {Args.rargs.pitchPattern {NoteSeq mapItems($ getPitch)}}
      end}


   /** %% Mixin subscript for a note sequence that constraints pitches to follow a contour specified by a fenv.
   %%
   %% Args.rargs
   %% 'pitchFenv' (default: strictly ascending Fenv): Fenv constraining the pitch *contour*.
   %%
   %% */
   FenvContour
   = {Score.defMixinSubscript unit(rdefaults: unit(pitchFenv: {Fenv.linearFenv [[0.0 0.0] [1.0 1.0]]})
				  )
      proc {$ NoteSeq Args}
	 {Pattern.fenvContour {NoteSeq mapItems($ getPitch)}
	  Args.rargs.pitchFenv}
      end}


   /** %% Mixin subscript for a note sequence that constraints pitch contour to a single direction. 
   %%
   %% Args.rargs
   %% 'direction': direction of arpeggio as relation atom.
   %%
   %% Note: can result in search problems when some intervals early in arpeggio are relatively large and then the whole arpeggio does not fit into the pitch domain any more. This can be fixed, e.g., by setting rargs.maxInterval to a smaller value.
   %% */
   Arpeggio
   = {Score.defMixinSubscript unit(rdefaults: unit(direction: '<:')
				  )
      proc {$ NoteSeq Args}
	 {Pattern.continuous {NoteSeq mapItems($ getPitch)}
	  Args.rargs.direction}
      end}


   /** %% Mixin subscript for a note sequence that constraints pitch contour to form an arc.
   %%
   %% Args.rargs
   %% 'firstRel': arg of Pattern.arch
   %% 'tuningPointPos': arg of Pattern.arch
   %%
   %% Note: can make search complex (not much propagation?)
   %% */
   Arch
   = {Score.defMixinSubscript unit(
% 			   rdefaults: unit(maxInterval: 4#3)
				 )
      proc {$ NoteSeq Args}
	 {Pattern.arch {NoteSeq mapItems($ getPitch)}
	  Args.rargs}
      end}

% /** %%
% %% Args.rargs
% %% 'firstRel': arg of Pattern.arch
% %% 'tuningPointPos': arg of Pattern.arch
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

   /** %% Mixin subscript for a note sequence that constraints all notes to equal pitches.
   %% */
   Repetitions
   = {Score.defMixinSubscript unit
      proc {$ NoteSeq Args}
	 {Pattern.allEqual {NoteSeq mapItems($ getPitch)}}
      end}

   /** %%  Mixin subscript for a note sequence that constraints the notes pitches to follow a hook pattern.
   %% Args.rargs: args of Hook
   %% */
   Hook
   = {Score.defMixinSubscript unit(rdefaults: unit
				  )
      proc {$ NoteSeq Args}
	 {Pattern.hook {NoteSeq mapItems($ getPitch)}
	  Args.rargs}
      end}

   /** %%  Mixin subscript for a note sequence that constraints the notes pitches to follow a stairs pattern.
   %% Args.rargs: args of Stairs:
   %% 'n'
   %% 'rel'
   %%
   %% Note: can make search complex (not much propagation?)
   %% */
   Stairs
   = {Score.defMixinSubscript unit(rdefaults: unit
				  )
      proc {$ NoteSeq Args}
	 if {IsOdd Args.iargs.n} then {Browse 'Stairs\' n must be even'} end
	 {Pattern.stairs {NoteSeq mapItems($ getPitch)}
	  Args.rargs}
      end}



   /** %% Extended script mixin for creating an "akkord", i.e., a sim of notes (German term chosen to avoid confusion with analytical and silent chord object).
   %% All note durations in the akkord are equal, and pitches are always decreasing (i.e. the highest note is first).
   %%
   %% Required args that must be specified by script (see source of script version below for suitable idefaults). 
   %% super: Score.makeSim or similar
   %%
   %% Args.iargs:
   %% 'n': number of tones per chord.
   %% any args given to single note of akkord (except arg pitch).
   %%
   %% Args.rargs:
   %% 'minPitch' and 'maxPitch' (default false): domain specification notation supported by HS.pitch. Disabled if one of them is false.
   %% 'minRange' and 'maxRange' (default false): min and max interval between lowest and highest note of each chord, specified as ratio (pair of ints). Disabled if false.
   %% 'minPcCard' (default false): min number of different pitch classes expressed per akkord. Disabled if false. Note: make sure that iargs.n and cardiality of all chords is high enough.
   %% */
   MakeAkkord_Mixin
   = {Score.defMixinSubscript
      unit(rdefaults: unit(minPitch: false
			   maxPitch: false
			   minRange: false
			   maxRange: false
			   minPcCard: false % 3 
			  ))
      proc {$ Akk Args}
	 Ns = {Akk getItems($)}
	 Ps = {Akk mapItems($ getPitch)}
	 Durs = {Akk mapItems($ getDuration)}
      in
	 {Pattern.allEqual Durs}
	 {Akk getDuration($)} = Durs.1 % necessary, strange..
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

   /** %% Script version of MakeAkkord_Mixin. In contrast to MakeAkkord_Mixin, MakeAkkord uses a suitable super script and note constructor by default.
   %% In addition, all arguments of Score.makeSim are supported.
   %% */
   MakeAkkord
   = {Score.defSubscript unit(super:Score.makeSim
			      mixins: [MakeAkkord_Mixin]
			      idefaults: unit(n: 3
					      %% add support for domain spec args
					      constructor: {Score.makeConstructor HS.score.note
							    unit}
					      inChordB:1
% 					      getChords: fun {$ Self}
% 							    [{Self findSimultaneousItem($ test:HS.score.isChord)}]
% 							 end
% 					      getScales: fun {$ Self}
% 							    [{Self findSimultaneousItem($ test:HS.score.isScale)}]
% 							 end
% 					      inScaleB:0
					     ))
      nil}

   /** %% Extended script mixin for a list of akkords.
   %%
   %% Required args that must be specified by script (see source of script version below for suitable idefaults). 
   %% super: something like
   fun {$ Args}
      Defaults = unit(akkN: 1)
      As = {Adjoin Defaults Args}
   in
      {Score.makeItems  {Adjoin {Record.subtract As akkN}
			 %% overwrite args 
			 unit(n: As.akkN
			      constructor: MakeAkkord
			     )}}
   end
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
   MakeAkkords_Mixin
   = {Score.defMixinSubscript
      unit(rdefaults: unit(sopranoPattern: proc {$ Ps} skip end
			   bassPattern: proc {$ Ps} skip end
			   rule: proc {$ Cs} skip end))
      proc {$ Akks Args}
	 {Args.rargs.rule Akks}
	 {Args.rargs.sopranoPattern
	  {Map Akks fun {$ Akk} {Akk mapItems($ getPitch)}.1 end}}
	 {Args.rargs.bassPattern
	  {Map Akks fun {$ Akk} {List.last {Akk mapItems($ getPitch)}} end}}
      end}

   /** %% Script version of MakeAkkords_Mixin.
   %% */
   MakeAkkords
   =  {Score.defSubscript
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
	    mixins: [MakeAkkords_Mixin])
       nil}

	   

   /** %% Same as MakeAkkords, but returns sequential container of akkords.
   %% */
   fun {MakeAkkords_Seq Args}
      {Score.make2 {Adjoin {Record.subtractList Args [akkN iargs rargs]}
		    seq({MakeAkkords {GUtils.keepList Args [akkN iargs rargs]}})}
       unit}
   end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Polyphonic form spec
%%%

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
		 seq([MyChord])])
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
   %% tuple of segment specifications, where each segment specifications is a record of the following arguments. (In principle Args.segments can be a record, but then the temporal order of segments depends on the order of features in the record.)
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


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Texture constraints
%%%

   /** %% Texture constraints restrict the independence between parts/voices. Dependence examples are homorhythm (simultaneous notes have the same start time and duration), heterorhythm (simultaneous notes have similar start times and durations), contrarhythm (simultaneous notes have different same start times or durations), homodirectional texture, various degrees of imitation (dependencies like, e.g., homorhythmic and homodirectional texture with a time offset) and many more possibilities. Texture constraints are inspired by Berry, Wallace (1987). Structural functions in music. Courier Dover Publications.
   
   %% A texture constraint applies a Dependency (a constraint, see below) between certain notes in a LeadingPart (a container) and certain notes in a DependantParts (a container). DependantParts can be either a single container or a list of container; in the latter case a dependency is applied to multiple parts (e.g., for a fully homophonic texture apply the dependency Homophonic to one voice as LeadingPart and a list with the remaining voices as DependantParts).
   
   %% A Dependency is a procedure with the following interface.
   
   {MyDependency Note1 Note2 Args}
   
   %% A Dependency defines a constraint between Note1, a note from the LeadingPart, and Note2, a note from the DependantPart. By default, Note1 and Note2 are simultaneous notes (see the argument offsetTime below for other cases). For example, homophony can be defined by constraining that the start times and durations of Note1 and Note2 are equal. Constraints that require more complex score contexts (e.g., the note succeeding Note1 in LeadingPart) are defined by accessing such contexts from the given notes (e.g., using methods like getTemporalSuccessor). The Dependency argument Args contains values for optional arguments in the Args argument of a texture constraint (see below). Various dependencies are predefined (e.g., Homophonic, and HomoDirectional), and users can freely define their own.
   %%
   %% The argument Args of Texture supports the following optional arguments.
   %%
   %% offsetTime (default 0): Using this argument, various forms of imitation can be defined. The dependency constraint is applied to a note in DependantPart that starts the specified amount of offset later than the respective note in LeadingPart.
   %% Remember that negative offset times are not allowed (if you would need them, simply swap the arguments LeadingPart and DependantPart).
   %% In case DependantParts is a list of containers, then a list of individual offset times can be given.
   %%
   %% timeRange (default nil): Specifies the time frames of the affected notes in LeadingPart. For example, the time frame [0#4 8#12] affects the notes that are in the time frames 0-4 and 8-12 in LeadingPart and their simultaneous notes in DependantPart (if offsetTime is the default). timeRange is based on SMapping.forTimeRange, and supports all its time frame notations. The arguments timeRange and indexRange exclude each other (only one must be given).
   %%
   %% indexRange (default nil): Specifies the positions of the affected notes in LeadingPart. For example, the numeric range [1#3 5#6] affects the notes at position 1-3 and 5-6 in LeadingPart and their simultaneous notes in DependantPart (if offsetTime is the default). indexRange is based on SMapping.forNumericRange, and supports all its index integers notations. The arguments timeRange and indexRange exclude each other (only one must be given).
   %%
   %% Note that further arguments can be provided, which are then forwarded to the dependency constraints. For example, a transposition dependency may use a transposition argument which would then be included in the Args record for Texture. 
   %% In case DependantParts is a list of containers, then a list of individual values can be given to any argument.
   %%
   %%
   %% */
   %% TODO:
   %% * Generalise (or multiple versions?):
   %%  - Add an arg like processNoteLists: true OR false (false is the default). If true, then instead of processing one note of LeadingPart at a time, lists of notes are taken (as specified by indexRange). This is useful for constraining non-overlapping score contexts. For example, a dependency where a sequence of pitches are repeated (or transposed) without retaining their order (as Feldman does), or an imitation that should start with a rest (offsetTime > 0) are best defined that way. By specifying an extra argument for this instead of generalising the whole definition, only specific dependency definitions need to deal with such cases, while others can rely on processing of individual notes. 
   %%  - ?? Sim items is only an option, another is notes at same position
   %%  - ?? Is is correct to only constrain notes? Should that be more general?
   proc {Texture Dependency LeadingPart DependantParts Args}
      Defaults = unit(indexRange: nil 
		      timeRange: nil
		      offsetTime: 0)
      As = {Adjoin Defaults Args}
      proc {ConstrainPart N1 DependantPart Ags}
	 DependantNs
      in
	 thread
	    DependantNs
	    = {N1 getSimultaneousItemsOffset($ Ags.offsetTime
					     toplevel: DependantPart
					     test: isNote)}
	 end
	 thread
	    {ForAll DependantNs
	     proc {$ DependantN} {Dependency N1 DependantN Ags} end}
	 end
      end
      fun {DuplicateArgs Ags Num} 
	 {List.mapInd {List.make Num}
	  fun {$ I _}
	     {Record.map Ags
	      fun {$ X}
		 if {IsList X} then {Nth X I} else X end
	      end}
	  end}
      end
      proc {ProcessDepending N}
	 %% remove not needed args that are potentially nil
	 Ags = {Record.subtractList As [timeRange indexRange]}
      in
	 if {IsList DependantParts}
	 then
	    {ForAll {LUtils.matTrans
		     [DependantParts {DuplicateArgs Ags {Length DependantParts}}]}
	     proc {$ [DependantPart Ags]}
		{ConstrainPart N DependantPart Ags}
	     end}
	 else {ConstrainPart N DependantParts Ags}
	 end
      end
   in
      %% NOTE: in principle I could allow for both As.indexRange and As.timeRange to run concurrently, but that will likely cause confusions
      if As.timeRange \= nil then
	 {SMapping.forTimeRange {LeadingPart collect($ test:isNote)}
	  As.timeRange 
	  ProcessDepending}
      else
	 {SMapping.forNumericRange {LeadingPart collect($ test:isNote)}
	  As.indexRange 
	  ProcessDepending}
      end
   end
    
   /** %% Multiple applications of Texture can be programmed slightly more concisely and better readable with TextureProgression. The following two code examples are equivalent (first a version using Texture then using TextureProgression).
  
   %% Imitation at the beginning (e.g., Voice2 at time 2 imitates 1st 5 notes of Voice1)
   {Texture MyDependency Voice1 [Voice2 Voice3 Voice1]
    unit(indexRange: 1#5
	 offsetTime: [2 4 6])}
   %% Homophonic section
   {Texture Homophonic Voice1 [Voice2 Voice3]
    unit(indexRange: 9#12)}
  
   {TextureProgression_Index
    [%% Imitation at the beginning (e.g., Voice2 at time 2 imitates 1st 5 notes of Voice1)
     (1#5) # unit(MyDependency Voice1 [Voice2 Voice3 Voice1]  
		  offsetTime: [2 4 6])
     %% Homophonic section
     (8#12) # unit(Homophonic Voice1 [Voice2 Voice3])
    ]}
  
   %% */
   proc {TextureProgression_Index Specs}
      {ForAll Specs
       proc {$ IndexRange#Spc}
	  Dependency = Spc.1
	  LeadingPart = Spc.2
	  DependantParts = Spc.3
	  Args = {Record.subtractList Spc [1 2 3]}
       in
	  {Texture Dependency LeadingPart DependantParts {Adjoin unit(indexRange:IndexRange) Args}}
       end}
   end
   /** %% Same as TextureProgression_Index, but with leading time values instead of indices.
   %% */
   proc {TextureProgression_Time Specs}
      {ForAll Specs
       proc {$ TimeRange#Spc}
	  Dependency = Spc.1
	  LeadingPart = Spc.2
	  DependantParts = Spc.3
	  Args = {Record.subtractList Spc [1 2 3]}
       in
	  {Texture Dependency LeadingPart DependantParts {Adjoin unit(timeRange:TimeRange) Args}}
       end}
   end
  
   /** %% [Dependency for Texture] Results in a homophonic texture.
   %% Note that a truely homophonic texture only results for the default offset time 0, otherwise a time-shifted "homophonic" imitation results.
   %% */
   proc {Homophonic N1 N2 Args}
      {N1 getStartTime($)} + Args.offsetTime = {N2 getStartTime($)}
      {N1 getDuration($)} = {N2 getDuration($)}
   end
  
   /* %% [Dependency for Texture] Results in a heterophonic texture.
   %% Note that a truely heterophonic texture only results for the default offset time 0, otherwise a time-shifted "heterophonic" imitation results.
   %% NOTE: Heuristic constraints only affect parameters that are distributed! Works (probably?) best if end times are distributed (and not durations?).
   %% */
   proc {HeuristicHomophonic N1 N2 Args}
      fun {EqualWithTimeOffset X Y}
	 if X + Args.offsetTime == Y
	 then 100 % {GUtils.random 100}
	 else 0   % {GUtils.random 10}
	 end
      end
   in
     % {Score.apply_H H.equal
     %  [{N1 getStartTimeParameter($)} {N2 getStartTimeParameter($)}] 1}
     % {Score.apply_H H.equal
     %  [{N1 getEndTimeParameter($)} {N2 getEndTimeParameter($)}] 1}
      {Score.apply_H EqualWithTimeOffset
       [{N1 getStartTimeParameter($)} {N2 getStartTimeParameter($)}] 1}
      {Score.apply_H EqualWithTimeOffset
       [{N1 getEndTimeParameter($)} {N2 getEndTimeParameter($)}] 1}
      %% just in case (more heuristic constraints do not add computational load :)
      {Score.apply_H H.equal
       [{N1 getDurationParameter($)} {N2 getDurationParameter($)}] 1}
   end
  
  
   /** %% [Dependency for Texture]  Generalised (?) version of "Orjan Sandred's notion of hierarchic rhythm.
   %% If the start time of N1 occurs between start and end of N2 including, then the start time of these notes are equal. In other words, the notes of N2's voice may be shorter than those of N1's voice, but whenever a longer note starts in the latter voice there also starts a note in the former.
   %% */
   %% BUG: can fail, but such minor inconsistencies may actually be good
   %% Problem: overall, rhythm followed too closely -- but I can easily force it otherwise (e.g., more notes in one layer with same overall end time.
   proc {HierarchicHomophonic N1 N2 Args}
      Start1 = {N1 getStartTime($)} + Args.offsetTime
      Start2 = {N2 getStartTime($)}
      End2 = {N2 getEndTime($)}
   in
      {FD.impl {FD.conj
		(Start2 =<: Start1)
		(Start1 =<: End2)}
       (Start1 =: Start2)
       1}
   end
  
   /** %% [Dependency for Texture] Results in a homo-directional texture (i.e. parallel pitch contours).
   %% */
   proc {HomoDirectional N1A N2A Args}
      N1B = {N1A getTemporalSuccessor($)}
      N2B = {N2A getTemporalSuccessor($)}
   in
      if N1B \= nil andthen N2B \= nil
      then
	 {Pattern.direction {N1A getPitch($)} {N1B getPitch($)}}
	 = {Pattern.direction {N2A getPitch($)} {N2B getPitch($)}}
      end
   end

end


