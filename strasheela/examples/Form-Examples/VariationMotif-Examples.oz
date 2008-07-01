
%%
%% This file lists a number of small-scale examples involving motifs, all based on the Motif functor. Note that for simplicity the motif constraint is often the only constraint applied (so the result could have been created in a purely deterministic way without constraint programming). However, additional constraints can be add to these examples. 
%%
%% Usage: first feed buffer to feed aux defs etc at the end, then feed commented examples one by one.
%%



%%
%% TODO:
%%
%%
%% * example which demonstrates other musical viewpoints constrained by MotifDescriptionDB and MotifVariationDB. For exampple, the pitch sequence, pitch interval sequence, duration 'intervals' etc.   
%%
%% * polyphonic motif definition..
%%
%% * ?? nested motif definition 
%%
%% * example which uses multiple motifs in context of a musical fragment (possibly together with harmonic constraints..)
%%


declare 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Motif database 
%%


%% Describes the characteristic features of two motifs (say, a and b), namely their pitch contour and their durations 
MotifDescriptionDB = [motif(
			 %% list of interval directions ('+' means
			 %% upwards, '-' downwards)
			 pitchContour:{Map ['+' '-' '-']
				       Pattern.symbolToDirection}
			 %% D4 means quarter note, D2 halve note etc
			 %% (see var defs below)
			 duration:[D4 D4_ D8 D2]
			 offset:[D4 0 0 0 0])
		      motif(pitchContour:{Map ['+' '+' '+']
					  Pattern.symbolToDirection}
			    duration:[D4_ D16 D16 D2]
			    offset:[0 0 0 0 0])]

MotifVariationDB = [%% orig gestalt of the motif
		    {Motif.makeVariation
		     %% Defines for each feature in MotifDescriptionDB, the relation between the motif instance and the values in the description (e.g., the relation between the pitches of the motif instance and the contour defined in the database) 
		     var(pitchContour:
			    %% Relation between motif pitches and database values constrained by Pattern.contour
			    proc {$ MyMotif MyContour}
			       MyPitches = {MyMotif mapItems($ getPitch)}
			    in
			       MyContour = {FD.list {Length MyPitches}-1 0#2}
			       {Pattern.contour MyPitches MyContour}
			    end
			 duration:
			    %% the motif note durations are as in the database
			    fun {$ MyMotif} {MyMotif mapItems($ getDuration)} end
			 offset:
			    fun {$ MyMotif} {MyMotif mapItems($ getOffsetTime)} end
			)} 
		    %% Inverse pitch contour 
		    {Motif.makeVariation 
		     var(pitchContour:
			    proc {$ MyMotif MyContour}
			       MyPitches = {MyMotif mapItems($ getPitch)}
			       MyInverseContour = {FD.list {Length MyPitches}-1 0#2}
			    in
			       MyContour = {FD.list {Length MyPitches}-1 0#2}
			       {Pattern.contour MyPitches MyInverseContour}
			       {Pattern.inverseContour MyInverseContour MyContour} 
			    end
			 duration:
			    fun {$ MyMotif} {MyMotif mapItems($ getDuration)} end
			 offset:
			    fun {$ MyMotif} {MyMotif mapItems($ getOffsetTime)} end
			)}]


%% aux variable for bookkeeping 
MaxMotifNoteNr = 4		% depends on length of lists in MotifDescriptionDB



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Actual examples  
%%


%%
%% First test: single motif instance
%%

/*

%% A single motif description and two variations. Highly restricted pitch domain and thus only few possible solutions.
{SDistro.exploreAll
 proc {$ MyScore}
    MyDB = {New Motif.database
	    %% NOTE: only first motif description selected
	    init(motifDescriptionDB:[MotifDescriptionDB.1]
		 motifVariationDB:MotifVariationDB)}
 in
    %% Score topology: motif containing MaxMotifNoteNr notes
    MyScore = {Score.makeScore
	       motif(items:{LUtils.collectN MaxMotifNoteNr
			    fun {$}
			       note(offsetTime:{FD.decl}
				    duration:{FD.decl}
				    pitch:{FD.int [60 62 64]}
				    amplitude:64)
			    end}
		     %% NOTE: motif database given to the individual motif instance
		     database:MyDB
		     startTime:0
		     timeUnit:TimeUnit)
	       MyConstructors}
 end
 MyDistro}

*/

/*

%% Two motif descriptions and a single variation. Restricted pitch domain and thus only few possible solutions.
{SDistro.exploreAll
 proc {$ MyScore}
    MyDB = {New Motif.database init(motifDescriptionDB:MotifDescriptionDB
				    %% NOTE: only first variation selected
				    motifVariationDB:[MotifVariationDB.1])}
 in
    MyScore = {Score.makeScore
	       motif(items:{LUtils.collectN MaxMotifNoteNr
			    fun {$}
			       note(offsetTime:{FD.decl}
				    duration:{FD.decl}
				    pitch:{FD.int [60 62 64 65]}
				    amplitude:64)
			    end}
		     database:MyDB
		     startTime:0
		     timeUnit:beats(4))
	       MyConstructors}
 end
 MyDistro}

{GUtils.setRandomGeneratorSeed 0}

*/


%%
%% Example with a sequence of different motifs
%%


/*

declare
MotifNo = 6
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    MyDB = {New Motif.database init(motifDescriptionDB:MotifDescriptionDB
				    motifVariationDB:MotifVariationDB)}
 in
    MyScore = {Score.makeScore
	       seq(items:{LUtils.collectN MotifNo
			  fun {$}
			     motif(items:{LUtils.collectN MaxMotifNoteNr
					  fun {$}
					     note(offsetTime:{FD.decl}
						  duration:{FD.decl}
						  pitch:{FD.int 60#72}
						  amplitude:64)
					  end}
				   database:MyDB)
			  end}
		   startTime:0
		   timeUnit:beats(4))
	       MyConstructors}
    %% Additional constraints
    %%
    %% The motif identity sequences forms a cycle pattern, and there occur different indices.
    {Pattern.cycle {MyScore mapItems($ getMotifIdentity)} 3}
    {Pattern.howManyDistinct {MyScore mapItems($ getMotifIdentity)} 2}
    %% the sequences of last tones of each motif forms a chromatic scale
    {AscendingChromaticScale
     {MyScore mapItems($ fun {$ MyMotif}
			    {{List.last {MyMotif getItems($)}} getPitch($)}
			 end)}}
 end
 MyDistro}



*/



%%
%% Make rhythmical structure more flexible (number of motif notes undetermined, motifs with different length, duration variations, motif container can have ofset time > 0...)
%% Then constrain that accented notes of motifs must (in most cases?) occur on an accented beat 
%%


%%
%% Polyphonic example: two sim motif streams (no harmony constraints)
%%


%%
%%
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Aux defs 
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Music representation 
%%

Beat = 4
TimeUnit = beats(Beat)

%% note duration names
D16 = Beat div 4
D8 = Beat div 2
D4 = Beat 
D2 = Beat * 2
D1 = Beat * 4
D8_ = D8+D16
D4_ = D4+D8
D2_ = D2+D4


MyConstructors = unit(seq:Score.sequential
		      motif:Motif.sequential
		      note:Score.note)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Constraints 
%%

/** %% Ps (list of pitch FD ints) form an ascending chromatic scale
%% */
proc {AscendingChromaticScale Ps}
   {Pattern.for2Neighbours Ps
    proc {$ P1 P2} P1 + 1 =: P2 end}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Distribution strategy
%%

%% constraint distribution / search order: first determine parameters motifIdentity and motifVariation. These parameters in turn determine the rhythmic structure which therefore does not need specific consideration in the distribution order.
MyDistro = unit(order:{SDistro.makeSetPreferredOrder
		       [fun {$ X}
			   {X hasThisInfo($ motifIdentity)} orelse
			   {X hasThisInfo($ motifVariation)}
			end]
		       SDistro.dom}
		value:random)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Explorer output 
%%
%%

%% set longest unsplit note dur to dotted halve (full 4/4 bar)
{Init.setMaxLilyRhythm 4.0}

%% Explorer output
proc {RenderLilypondAndCsound_Motif I X}
   if {Score.isScoreObject X}
   then 
      FileName = out#{GUtils.getCounterAndIncr}#'-'#I#'-'#{OS.rand}
   in
      %% !! on Mac with new Lily, pdf is shown automatically after rendering
      {Out.renderAndShowLilypond X
	 % {Out.renderLilypond X 
       unit(file: FileName#'-'#I
	    wrapper:["\\layout { \\context {\\Voice \\remove \"Note_heads_engraver\" \\remove \"Forbid_line_break_engraver\" \\consists \"Completion_heads_engraver\" \\consists \"Horizontal_bracket_engraver\"}}"
		     "\n}"]
	       clauses:[%% marking notes in motifs (?? no motif hierarchy yet)
			fun {$ X}
			   {X isItem($)} andthen % !!?? why not isItem ?
			   {Motif.isInMotif X 
			    fun {$ X MyMotif} {X isFirstItem($ MyMotif)} end}
			end#{Out.makeNoteToLily fun {$ Note} '\\startGroup' end}
			fun {$ X}
			   {X isItem($)} andthen
			   {Motif.isInMotif X
			    fun {$ X MyMotif}
			       %% X is last 'existing' item in MyMotif
			       %%
			       %% NB: CTT.relevantLength not most efficient (is constraint)
			       N = {CTT.relevantLength MyMotif}
			    in
			       N == {X getPosition($ MyMotif)}
			    end}
			end#{Out.makeNoteToLily fun {$ Note} '\\stopGroup' end}
			%isPause#PauseToLily
		       ])}
      {Out.renderAndPlayCsound X
       unit(file: FileName)}
   end
end
{Explorer.object
 add(information RenderLilypondAndCsound_Motif
     label: 'to Lily + Csound: Motif Demos')}

{Init.setTempo 90.0}



