

%%
%% This file lists a number of small-scale examples involving motifs, all based on Pattern.useMotifs. Note that for simplicity the motif constraint is often the only constraint applied (so the result could have been created in a purely deterministic way without constraint programming). However, additional constraints can be add to these examples. 
%%
%% Usage: first feed buffer to feed aux defs etc at the end, then feed commented examples one by one.
%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Actual examples 
%%

%% The first examples are all purely rhythmic

/* 

%% Rhythm-motifs: similar in effect to "Orjan Sandreds motif domains
%% No pitch constraints


{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    %% NOTE: the actual duration motif defs (D2 is halve note, D4 quarter note, D2_ dotted halve, see def of these variables below)
    Motifs = [[D2 D2]
	      [D8 D8 D4]
	      [D2_ D4 D4 D4]]
    NoteNo = 20
 in
    %% A sequence of NoteNo notes created with the makeNote function
    MyScore = {MakeNoteSeq unit(n:NoteNo
				makeNote:fun {$}
					    %% constant pitch
					    note(pitch:{ET12.pitch 'C'#4}
						 duration:{FD.int 1#16}
						 amplitude:64)
					 end)}
    %% Constrain note durations to form motifs
    {Pattern.useMotifs {MyScore mapItems($ getDuration test:isNote)}
     Motifs
     unit}
 end
 unit(order:leftToRight
      value:random)}


%% More efficient variant of example above which introduces additional note parameter for motif index (see def of MakeMotifIndexNote and GetMotifIndex below). Search space is greatly reduced by searching for the motif index instead of the actual durations. Besides, this variant is more secure (motifs which are like the beginning of other motifs otherwise cause problems, see Pattern.useMotifs doc).
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    %% NOTE: the actual motif defs:
    Motifs = [[D2 D2]
	      [D8 D8 D4]
	      [D2_ D4 D4 D4]]
    NoteNo = 20
 in
    MyScore = {MakeNoteSeq unit(n:NoteNo
				makeNote:fun {$}
					    {Adjoin {MakeMotifIndexNote}
					     %% constant pitch
					     note(pitch:{ET12.pitch 'C'#4})}
					 end)}
    {Pattern.useMotifs {MyScore mapItems($ getDuration test:isNote)}
     Motifs
     %% Bind the new motif index parameter of all notes to the motif index value with the optional arg indices 
     unit(indices:{MyScore mapItems($ GetMotifIndex test:isNote)})}
 end
 %% left to right distro which first determines motif indices (see MyDistro def below)
 MyDistro}

*/



/* 

%% Rhythm-motifs: same as above, but the example must now end with a full motif (Pattern.useMotifs arg is set to true)

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    Motifs = [[D2 D2]
	      [D8 D8 D4]
	      [D2_ D4 D4 D4]]
    NoteNo = 20
 in
    MyScore = {MakeNoteSeq unit(n:NoteNo
				makeNote:fun {$}
					    {Adjoin {MakeMotifIndexNote}
					     note(pitch:{ET12.pitch 'C'#4})}
					 end)}
    %% UseMotifs hides the binding of the motif indices for convenience 
    {UseMotifs {MyScore mapItems($ getDuration test:isNote)}
     %% NOTE: set optional arg workOutEven to true: there must be no partial motif at the end
     Motifs MyScore unit(workOutEven:true)}
 end
 MyDistro}

*/


/*

%% Motif defs are constraints and other constraints can be added.
%% Same example as above, but additionally no syncopation across measures is allowed.

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    X = {FD.decl}
    Motifs = [[D4]
	      [D8 D8 D4]]
    NoteNo = 20
    %% Create music representation for 4/4 bars (see doc of Measure.uniformMeasures)
    %% Note: changing the time signature here does not change the time signature in Lilypond -- such a customisation has been left out here for simplicity
    MyMeasures = {Score.makeScore measure(beatNumber:4 
					  beatDuration:Beat
					  startTime:0)
		  unit(measure:Measure.uniformMeasures)}
 in
    MyScore = {MakeNoteSeq unit(n:NoteNo
				makeNote:MakeMotifIndexNote)}
    %% 
    {UseMotifs {MyScore mapItems($ getDuration test:isNote)}
     Motifs MyScore unit(workOutEven:true)}
    %% Constrain that no note overlaps any bar line (see doc of Measure.uniformMeasures)
    {MyScore forAll(test:isNote
		    proc {$ N}
		       0 = {MyMeasures overlapsBarlineR($ {N getStartTime($)}
							{N getEndTime($)})} 
		    end)}
    %% MyMeasures last as long as note seq
    {MyMeasures getEndTime($)} = {MyScore getEndTime($)}
 end
 MyDistro}

*/


/* 

%% This example allows for non-motific notes. The special motif spec element '_' results in no motif constraints for that element.

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    X = {FD.decl}
    Motifs = [[D2_ D4]
	      [D8 D8 D4]
	      ['_']]
    NoteNo = 20
    MyMeasures = {Score.makeScore measure(beatNumber:4 
					  beatDuration:Beat
					  startTime:0)
		  unit(measure:Measure.uniformMeasures)}
 in
    MyScore = {MakeNoteSeq unit(n:NoteNo
				makeNote:MakeMotifIndexNote)}
    %% 
    {UseMotifs {MyScore mapItems($ getDuration test:isNote)}
     Motifs MyScore unit(workOutEven:true)}
    {MyScore forAll(test:isNote
		    proc {$ N}
		       0 = {MyMeasures overlapsBarlineR($ {N getStartTime($)}
							{N getEndTime($)})} 
		    end)}
    {MyMeasures getEndTime($)} = {MyScore getEndTime($)}
 end
 MyDistro}


*/


/*

%% Previous examples constrained note durations. However, any variable sequence in the CSP can be constrained to form motifs. This example specifies motifs for "duration intervals" (quotient between two neighbouring note durations).

%% NOTE: only very few solutions, why? For example, swapping the motifs in a bar seems not be be possible.
%%

declare
{GUtils.setRandomGeneratorSeed 0}
{Init.setTempo 90.0}
/** %% [aux] Expects a list of duration motifs expressed by ratios in the form Num#Denom and returns a list of duration motifs expressed by integers. 
%% */
fun {RatioToInternalMotifs Motifs Offset}   
   fun {RatioToDur Ratio}
      case Ratio of Num#Denom then 
	 Num * Offset div Denom
      [] '_' then '_'
      end
   end
in
   {Map Motifs
    fun {$ Motif} {Map Motif RatioToDur} end}
end
{SDistro.exploreOne
 proc {$ MyScore}
    NoteNo = 12
    %% [Aux var] Motifs must only consist of integers, but "duration interval" can be ratios like 1/2 (i.e. the duration of the next note is halve its predecessor). Offset must be chosen such that each duration ratio multiplied by Offset results in an integer without rounding 
    Offset = 3			% allows for 1/3
    %% Motif specs defined by ratios (see RatioToInternalMotifs above). 
    %% Motif specs start with the special valued '_'.. This means that the first duration of the motif can be chosen freely, otherwise the "duration interval" motifs would be overlapping. 
    Motifs = {RatioToInternalMotifs
	      [
	       ['_' 1#1 2#1]	 % e.g., D4 D4 D2
	       ['_' 1#3 2#1]	 % e.g., D2_ D4 D2 
	      ]
	      Offset}
    DurIntervals = {FD.list NoteNo 0#FD.sup}
    MotifIndices
    MyMeasures = {Score.makeScore measure(beatNumber:4 % 4/4 bar
					  beatDuration:Beat
					  startTime:0)
		  unit(measure:Measure.uniformMeasures)}
 in
    MyScore = {MakeNoteSeq
	       unit(n:NoteNo
		    makeNote:fun {$}
				{Adjoin {MakeMotifIndexNote}
				 note(pitch:{ET12.pitch 'C'#4}
				      duration:{FD.int [D16 D8 D8_ D4 D4_ D2 D2_ D1]})}
			     end)}
    %% Access "duration intervals" using Offset (see above). Put a dummy value 0 in front (for the first ignored interval expressed by '_').
    DurIntervals
    = 0 | {Pattern.map2Neighbours {MyScore mapItems($ getDuration test:isNote)}
	   proc {$ Dur1 Dur2 DurInt}
	      Dur1 * DurInt =: Dur2 * Offset % offset to avoid DurInt<1
	   end}
    %% Constrain "duration interval" motifs
    {Pattern.useMotifs DurIntervals
     Motifs
     unit(workOutEven:false
	  indices:{MyScore mapItems($ GetMotifIndex test:isNote)}
	 )}
%     %% no syncopations (the start and end of each note are not in different measures)
%     {MyScore forAll(test:isNote
% 		    proc {$ N}
% 		       0 = {MyMeasures overlapsBarlineR($ {N getStartTime($)}
% 							{N getEndTime($)})} 
% 		    end)}
%     %% MyMeasures lasts as long as note seq
%     {MyMeasures getEndTime($)} = {MyScore getEndTime($)}
 end
 MyDistro}

*/


/*


%% All previous motif specs where determined. However, motif specs can also contain variables or be completely undetermined. In that case, parameters are constrained to form motifs, but the actual motif description is searched for as well.

%% This example uses two rhythm motifs, but these are undetermined in the CSP (only their length is fixed).
%% Interesting: it is often hard to see/hear motif boundaries, because motifs often express no grouping
%% Additional constraints: longer notes must start on an specific beats in the measure (enhances metric clarity)
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    %% NOTE: undetermined motifs of specified length 
    Motifs = [{FD.list 3 0#FD.sup}
	      {FD.list 2 0#FD.sup}
	     ]
    NoteNo = 20
    MyMeasures = {Score.makeScore measure(beatNumber:4 % 4/4 bar
					  beatDuration:Beat
					  startTime:0)
		  unit(measure:Measure.uniformMeasures)}
 in
    MyScore = {MakeNoteSeq unit(n:NoteNo
				makeNote:fun {$}
					    {Adjoin {MakeMotifIndexNote}
					     note(pitch:{ET12.pitch 'C'#4}
						  duration:{FD.int [D16 D8 D8_ D4 D4_ D2 D2_ D1]})}
					 end)}
    {UseMotifs {MyScore mapItems($ getDuration test:isNote)}
     Motifs MyScore unit(workOutEven:true)}
    %%
    %% Longer notes must start on an important beat
    {MyScore forAll(test:isNote
		    proc {$ N}
		       %% quarternote and longer start on beat
		       {FD.impl ({N getDuration($)} >=: D4)
			{MyMeasures onBeatR($ {N getStartTime($)})}
			1}
		       %% halve and longer start on accented beat
		       {FD.impl ({N getDuration($)} >=: D2)
			{MyMeasures onAccentR($ {N getStartTime($)})}
			1}
		    end)}
    %% MyMeasures lasts as long as note seq
    {MyMeasures getEndTime($)} = {MyScore getEndTime($)}
 end
 MyDistro}


%% only selected motif elements are vars
%% 
%% TODO: unfinished -- the actual variables are still missing
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    X = {FD.decl}
    Motifs = [[D2 D2]
	      [D8 D8 D4]
	      [D2_ D4 D4 D4]]
    NoteNo = 20
 in
    MyScore = {MakeNoteSeq unit(n:NoteNo
				makeNote:MakeMotifIndexNote)}
    {UseMotifs {MyScore mapItems($ getDuration test:isNote)}
     Motifs MyScore unit(workOutEven:false)}
 end
 MyDistro}


*/


%% All examples so far purely rhythmic, only note durations were constrained. All these techniques could be applied for note pitches and other parameters as well. Next examples instead constrain multiple parameters. 


/*

%% This example constraints the note durations and pitches by motifs. However, the motifs for different parameters are independent here, motif boundaries for different parameters can overlap.
%% This example applies two independend motif patterns. For efficiency, two motif index parameters are added to notes (one for durations and one for pitches).

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    %% NOTE: the actual motif defs:
    DurMotifs = [[D2 D2]
		 [D8 D8 D4]
		 [D2_ D4 D4 D4]]
    PitchMotifs = [[74 73]
		  [64 66 68]]
    NoteNo = 20
 in
    MyScore = {MakeNoteSeq unit(n:NoteNo
				makeNote:MakeMotifIndexNote_DurAndPitch)}
    {Pattern.useMotifs {MyScore mapItems($ getDuration test:isNote)}
     DurMotifs
     unit(workOutEven:false
	  indices:{MyScore mapItems($ GetMotifIndex_Duration test:isNote)})}
    {Pattern.useMotifs {MyScore mapItems($ getPitch test:isNote)}
     PitchMotifs
     unit(workOutEven:false
	  indices:{MyScore mapItems($ GetMotifIndex_Pitch test:isNote)})}
 end
 MyDistro}

*/



/*

%% Like the previous example, this example also constrains note durations and pitches by motifs. However, this example features compound motif specs in which each motif defines multiple parameters, namely note durations and pitch intervals (rather than absolute pitches, in contrast to the previous example). So, these parameters are not independent as in the example before but instead coupled in a single definition.

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    Offset = 10
    %% NOTE: the actual motif defs: an Offset is added to all pitch intervals, so the result in positive values
    Motifs = [[[D2 '_'] [D2 ~1+Offset]]
	      [[D8 '_'] [D8 2+Offset] [D4 2+Offset]]]
    NoteNo = 20
 in
    MyScore = {MakeNoteSeq unit(n:NoteNo
				makeNote:fun {$}
					    {Adjoin {MakeMotifIndexNote}
					     note(pitch:{FD.int {ET12.pitch 'C'#3}#{ET12.pitch 'C'#5}})}
					 end)}
    {Pattern.useMotifs {LUtils.matTrans [{MyScore mapItems($ getDuration test:isNote)}
				 %% list of pitch intervals is by one shorter, so a dummy is added at the start
				 0 | {Pattern.map2Neighbours
				      {MyScore mapItems($ getPitch test:isNote)}
				      proc {$ Pitch1 Pitch2 ?Interval}
					 Interval = {FD.decl}
					 Pitch1 + Interval =: Pitch2 + Offset
				      end}]}
     Motifs
     unit(workOutEven:false
	  indices:{MyScore mapItems($ GetMotifIndex test:isNote)})}
 end
 MyDistro}

*/



/*

%% !!?? Constrain order of motifs directly by constraining note's motif index and new 1/0 parameter startsMotif

%% Example: constrain motif sequence by cycle pattern or constrain Morphology analysis of motif sequence 

%% TODO:
%% Given the motif index and the new param startsMotif for every note, can I access/filter out the motif indices of those notes which start a new motif (i.e. the 'actual' motif index sequence)? I could process these lists as a stream and return a stream of the 'actual' motif indices.  

*/ 

/*

%% "Orjan used motifs also in hierarchical setting: in multiple parallel voices, voices with longer notes (or analytical objects, like chord objects) lasted for several shorter notes in another voice, but their start times (and end times) matched exactly (he calls it metrical hierarchicy).

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% The rest are aux defs
%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Music representation
%% 

declare
[ET12] = {ModuleLink ['x-ozlib://anders/strasheela/ET12/ET12.ozf']}

Beat = 4
%% note duration names
D16 = Beat div 4
D8 = Beat div 2
D4 = Beat 
D2 = Beat * 2
D1 = Beat * 4
D8_ = D8+D16
D4_ = D4+D8
D2_ = D2+D4

 % DurDomain = [D16 D8 D4 D2 D2_]

/** %% Returns default arguments for textual note objects. Defined as function, because some params are variables. 
%% */
fun {MakeDefaultNote}
   note(pitch:{FD.int {ET12.pitch 'C'#3}#{ET12.pitch 'C'#5}}
	duration:{FD.int 1#16}
% 	duration:{FD.int DurDomain}
	amplitude:64
	amplitudeUnit:velo)
end


/** %% Returns a note with an added parameter for the motif index. 
%% */
fun {MakeMotifIndexNote}
   MyParam = {New Score.parameter
	      init(info:motifIndex
		   value:{FD.decl})}
in
   {Adjoin {MakeDefaultNote}
    %% constant pitch
    note(pitch:{ET12.pitch 'C'#4}
	 addParameters:[MyParam])}
end
/** %% Returns a note with an two added parameters for the motif index for durations and pitches. 
%% */
fun {MakeMotifIndexNote_DurAndPitch}
   MyParam1 = {New Score.parameter
	       init(info:motifIndex(duration)
		    value:{FD.decl})}
   
   MyParam2 = {New Score.parameter
	       init(info:motifIndex(pitch)
		    value:{FD.decl})}
in
   {Adjoin {MakeDefaultNote}
    %% constant pitch
    note(pitch:{FD.int {ET12.pitch 'C'#3}#{ET12.pitch 'C'#6}}
	 addParameters:[MyParam1 MyParam2])}
end
/** %% Expects a note object and returns its note index variable.
%% */
fun {GetMotifIndex N}
   {{LUtils.find {N getParameters($)}
     fun {$ X} {X hasThisInfo($ motifIndex)} end}
    getValue($)}
end
/** %% Expects a note object and returns its note index variable for the pitch.
%% */
fun {GetMotifIndex_Pitch N}
   {{LUtils.find {N getParameters($)}
     fun {$ X}
	{X hasThisInfo($ motifIndex)} andthen
	{X getInfoRecord($ motifIndex)}.1 == pitch
     end}
    getValue($)}
end
/** %% Expects a note object and returns its note index variable for the duration.
%% */
fun {GetMotifIndex_Duration N}
   {{LUtils.find {N getParameters($)}
     fun {$ X} 
	{X hasThisInfo($ motifIndex)} andthen
	{X getInfoRecord($ motifIndex)}.1 == duration
     end}
    getValue($)}
end


/* %% This "motif definition" outputs a sequential container with Args.n notes. No extra constraints are applied, except for the implicit constraints of the music representation.
%% */
proc {MakeNoteSeq Args ?MyScore}
   Defaults = unit(n:1		 % number of contained notes
		   %% note constructor, can output textual representation. If an object is returned, the default note class (and the effect of the argument noteClass) is overwritten
		   makeNote:MakeMotifIndexNote
		   notesRule: proc {$ Notes} skip end
		   %% Note class
		   noteClass: Score.note
		   timeUnit:beats(4)
		   startTime:0
		   initScore:true
		  )
   As = {Adjoin Defaults Args}
in
   MyScore = {Score.makeScore2 seq(items:{LUtils.collectN As.n As.makeNote}
				   timeUnit:As.timeUnit
				   startTime:As.startTime)
	      add(note: As.noteClass)}
   if As.initScore then
      {Score.initScore MyScore}
   end
   %% user-defined constraints 
   thread			% apply constraints only after score is initialised
      {As.notesRule {MyScore getItems($)}}
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Constraints
%%
%%


/** %% Simplifies use of Pattern.useMotifs here: the notes' motif index parameter value is implicitly accessed.
%% */
proc {UseMotifs Xs Motifs MyScore Args}
   {Pattern.useMotifs Xs
    Motifs {Adjoin unit(indices:{MyScore mapItems($ GetMotifIndex test:isNote)})
	    Args}}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Explorer output 
%%
%%

%% set longest unsplit note dur to dotted halve (full 4/4 bar)
{Init.setMaxLilyRhythm 4.0}

%% Explorer output 
proc {RenderLilypondAndCsound I X}
   if {Score.isScoreObject X}
   then 
      FileName = out#{GUtils.getCounterAndIncr}#'-'#I#'-'#{OS.rand}
   in
      {Out.renderAndShowLilypond X
       unit(file: FileName
	    %% ignore measure objects
	    clauses:[Measure.isUniformMeasures#fun {$ _} nil end]
	    %% See http://lilypond.org/doc/v2.11/Documentation/user/lilypond/Automatic-note-splitting#Automatic-note-splitting
	    %% Note: automatic note splitting ignores explicit ties
	    wrapper:["\\layout { \\context {\\Voice \\remove \"Note_heads_engraver\" \\remove \"Forbid_line_break_engraver\" \\consists \"Completion_heads_engraver\" }}"
		     "\n}"]
	   )}
      {Out.renderAndPlayCsound X
       unit(file: FileName)}
   end
end
{Explorer.object
 add(information RenderLilypondAndCsound
     label: 'to Lily + Csound: Motif Demos')}

{Init.setTempo 90.0}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Distribution strategy
%%
%%

MyDistro = unit(order:{SDistro.makeLeftToRight
		       %% NOTE: time params are determined after motif index
		       {SDistro.makeSetPreferredOrder
			[fun {$ Par} {Par hasThisInfo($ motifIndex)} end
			 fun {$ Par} {Par isTimeParameter($)} end
			]
			SDistro.dom}}
		value:random)


