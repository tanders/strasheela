
%%
%% This file lists some small-scale examples which use the prototype motif model. Note that for simplicity many examples only apply motif-related constraints (so the result could have been created in a purely deterministic way without constraint programming). However, additional constraints can be added to these examples. 
%%
%% Usage: first feed buffer to feed aux defs etc at the end, then feed commented examples one by one.
%%

%%
%% In the prototype-based motif model, a CSP is composed from sub-CSPs for the individual motifs. These sub-CSPs are created from solution examples.  
%% In contrast to Pattern.useMotifs (see examples/MotifPatternExamples), the prototype motif model has some advantages
%%
%% - Convenient control over order of motifs
%% - Indivudual motifs can be polyphone (any score topology)
%% - Hierarchical form description
%%
%% Disadvantage: the motif identity itself is not constrainable (i.e. the order of motifs is fixed)
%%


declare

[PMotif] = {ModuleLink ['x-ozlib://anders/strasheela/PrototypeMotif/PrototypeMotif.ozf']}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Basic use of PMotif.makeScript
%%

%% A motif prototype is simply a ready-made score object. Motif instances copy or variate a motif protoype. 
Motif_A_P = {Score.makeScore seq(items:[%% add lilypond articulations to note
					note(info:lily("\\downbow")
					     duration:6
					     pitch:60
					     amplitude:64)
					note(duration:2
					     pitch:62
					     amplitude:64)
					note(duration:8
					     pitch:64
					     amplitude:64)]
				 startTime:0
				 timeUnit:beats(4))
	     unit}


/* % show Motif_A_P
{Out.renderAndShowLilypond Motif_A_P unit}
*/


%%
%% First case: motif instances are unvaried copies of prototype (only start and end time differs) 
%%

/*

%% PMotif.makeScript expects a motif prototype (a score object) and returns an extended script (see doc GUtils.extendedScriptToScript) which creates a variation of the prototype.
%% This Motif_A creates an almost exact copy of Motif_A_P (start and end times are implicitly unset in Motif_A)

declare
Motif_A = {PMotif.makeScript Motif_A_P
	   unit}
%% Motif_A can be used like a script by itself (there is only a single solution). 
{SDistro.exploreOne {GUtils.extendedScriptToScript Motif_A
		     unit(initScore:true % necessary if Motif_A is top-level 
			  startTime:0)}
 unit(value:random)}

%% More importantly, Motif_A can be used as constructor for motifs in a nested score (again, there is only a single solution in this case). 
{SDistro.exploreOne fun {$}
		       {Score.makeScore seq(items:[motif motif]
					    startTime:0
					    timeUnit:beats(4)
					   )
			add(motif:Motif_A)}
		    end 
 unit}

*/



%%
%% keep the note durations, but ignore the pitches
%%

/*

declare
Motif_A = {PMotif.makeScript Motif_A_P
	   unit(
	      %% unset all note pitches (for every object in Motif_A_P which returns true for isNote, unset its attribute or parameter value pitch). 
	      unset: [isNote#pitch]
	      %% specify an optional argument pitchDomain for the returned script. A proc specifies what the argument does to the motif, also a default value can be specified.
	      scriptArgs:
		 unit(
		     %% arg pitchDomain expects the domain of all
		     %% motif notes, wrapped in a record. Default is
		     %% dom(60#72).
		     pitchDomain: proc {$ MyMotif Dom}
				     {ForAll {MyMotif collect($ test:isNote)}
				      proc {$ N} {N getPitch($)} = {FD.int Dom.1} end}
				  end # dom(60#72)
		    )
	      )}
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 fun {$}
    {Score.makeScore seq(items:[%% NOTE: the motifs' pitch domain is specified
				motif(pitchDomain:dom(60#65))
				motif(pitchDomain:dom(64#68))]
			 startTime:0
			 timeUnit:beats(4)
			)
     add(motif:Motif_A)}
 end 
 unit(value:random)}

*/



%%
%% keep the note durations, unset the pitches, but constrain relation of motif instance pitches to prototype
%%

/** %% Returns the intervals between notes in MyMotif (list of implicitly declared FD ints).
%% */
%% aux var to avoid negative interval variables
IntervalOffset = 100
fun {GetPitchIntervals MyMotif}
   {Pattern.map2Neighbours {MyMotif mapItems($ getPitch test:isNote)}
    proc {$ Pitch1 Pitch2 ?Interval}
       Interval = {FD.decl}
       Pitch1 + Interval =: Pitch2 + IntervalOffset
    end}
end

/*

%% motif instance follows pitch intervals of orig motifs, but motifs may be transposed

declare
Motif_A = {PMotif.makeScript Motif_A_P
	   unit(
	      unset: [isNote#pitch]
	      scriptArgs:
		 unit(pitchDomain: proc {$ MyMotif Dom}
				     {ForAll {MyMotif collect($ test:isNote)}
				      proc {$ N} {N getPitch($)} = {FD.int Dom.1} end}
				   end # dom(60#72))
	      prototypeDependencies:
		 [%% For every container in motif (there is only one top-level container), constrain the relation between prototype and the motif instance with given proc. This proc unifies the note pitch intervals of the prototype with the intervals of the motif instance
		  isContainer#proc {$ Proto Instance}
				 {GetPitchIntervals Proto}
				 = {GetPitchIntervals Instance}
			      end
		 ]
	      )}
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 fun {$}
    {Score.makeScore seq(items:[motif
				motif]
			 startTime:0
			 timeUnit:beats(4)
			)
     add(motif:Motif_A)}
 end 
 unit(value:random)}


*/


/*

%% Same example as before, but now motif prototype follows pitch contour of prototype (the actual intervals can differ)

declare
Motif_A = {PMotif.makeScript Motif_A_P
	   unit(
	      unset: [isNote#pitch]
	      scriptArgs:
		 unit(pitchDomain: proc {$ MyMotif Dom}
				     {ForAll {MyMotif collect($ test:isNote)}
				      proc {$ N} {N getPitch($)} = {FD.int Dom.1} end}
				   end # dom(60#72))
	      prototypeDependencies:
		 [%% unifies the pitch contour of prototype and motif instance
		  isContainer#{PMotif.unifyDependency
			       fun {$ X}
				  {Pattern.contour {X map($ getPitch test:isNote)}}
			       end}
		 ]
	      )}
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 fun {$}
    {Score.makeScore seq(items:[motif
				motif]
			 startTime:0
			 timeUnit:beats(4)
			)
     add(motif:Motif_A)}
 end 
 unit(value:random)}

*/ 


%%
%% constrain relation between motifs
%%


/*

%% Four motifs in sequence: constrain that the highest pitches of different motifs are never more than a major second apart, but is no repetition 

declare
Motif_A = {PMotif.makeScript Motif_A_P
	   unit(
	      unset: [isNote#pitch]
	      scriptArgs:
		 unit(pitchDomain: proc {$ MyMotif Dom}
				     {ForAll {MyMotif collect($ test:isNote)}
				      proc {$ N} {N getPitch($)} = {FD.int Dom.1} end}
				   end # dom(60#72))
	      prototypeDependencies:
		 [isContainer#proc {$ Proto Instance}
				 {GetPitchIntervals Proto}
				 = {GetPitchIntervals Instance}
			      end]
	      )}
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {Score.makeScore seq(items:[motif
					  motif
					  motif
					  motif]
				   startTime:0
				   timeUnit:beats(4)
				  )
     add(motif:Motif_A)}
    %% additional constraint
    {Pattern.for2Neighbours {Map {MyScore getItems($)} PMotif.getHighestPitch}
     proc {$ P1 P2}
	{FD.distance P1 P2 '=<:' 2}
	P1 \=: P2
     end}
 end 
 unit(value:random)}

*/ 



%%
%% CSP consisting of two different motifs with no other constraints 
%%

%% Motif prototypes and instances can be polyphone 
Motif_B_P = {Score.makeScore
	     seq(items:[sim(items:[note(duration:4
					pitch:67
					amplitude:64)
				   note(duration:4
					pitch:59
					amplitude:64)])
			sim(items:[note(duration:8
					pitch:67
					amplitude:64)
				   note(duration:8
					pitch:60
					amplitude:64)])]
		 startTime:0
		 timeUnit:beats(4))
	     unit}


/* % show Motif_B_P
{Out.renderAndShowLilypond Motif_B_P unit}
*/


/*

%% 

declare
%% Script creation for two prototypes with mapping
[Motif_A Motif_B]
= {Map [Motif_A_P Motif_B_P]
   fun {$ Proto}
      {PMotif.makeScript Proto
       unit(unset: [isNote#pitch]
	    scriptArgs:
	       unit(pitchDomain: proc {$ MyMotif Dom}
				    {ForAll {MyMotif collect($ test:isNote)}
				     proc {$ N} {N getPitch($)} = {FD.int Dom.1} end}
				 end # dom(60#72))
	    prototypeDependencies:
	       [%% NOTE: contour matrix instead of contour (equal pitches remain equal)
		isContainer#{PMotif.unifyDependency
			     fun {$ X}
				{Pattern.contourMatrix {X map($ getPitch test:isNote)}}
			     end}
	       ])}
   end}
%% these two motifs in a sequence
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 fun {$}
    {Score.makeScore seq(items:[motif_A(pitchDomain:dom(60#65))
				motif_A(pitchDomain:dom(62#67))
				motif_B(%% NOTE: implicitly defined arg
					offsetTime:4 
					pitchDomain:dom(57#72))
				%% another score object..
				pause(duration:8)
				%%
				motif_A(pitchDomain:dom(60#65))
				motif_A(pitchDomain:dom(62#67))
				motif_B(%% NOTE: implicitly defined arg
					offsetTime:4
					pitchDomain:dom(57#72))]
			 startTime:0
			 timeUnit:beats(4)
			)
     add(motif_A:Motif_A
	 motif_B:Motif_B)}
 end 
 unit(value:random)}

%% two motifs in a polyphonic setting
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 fun {$}
    {Score.makeScore
     sim(items:[%% voice 1
		seq(items:[motif_A(pitchDomain:dom(60#72))
			   motif_A(pitchDomain:dom(60#72))]
		   )
		%% voice 2
		seq(items:[motif_B(offsetTime:4
				   pitchDomain:dom(48#60))
			   motif_B(offsetTime:4
				   pitchDomain:dom(48#60))])
	       ]
	 startTime:0
	 timeUnit:beats(4)
	)
     add(motif_A:Motif_A
	 motif_B:Motif_B)}
 end 
 unit(value:random)}


*/


%%
%% add simple harmony constraint
%%


%%
%% Re-define Motif_A_P and Motif_B_P with different note classes for harmonic CSP. Only the note constructor changed, everything else is as before.
%%

%% Returns a note object whose pitch class is implicitly constrained to express a pitch class of a simultaneous chord object
fun {MakeChordNote Args}
   {Score.makeScore2
    {Adjoin note(inChordB:1	% only chord-tones permitted
% 		 inChordB:{FD.int 0#1}
		 getChords:
		    fun {$ MyNote}
		       %% note is related to simultaneous chord
		       [{MyNote findSimultaneousItem($ test:HS.score.isChord)}]
		    end)
     Args}
    unit(note:HS.score.note)}
end
Motif_A_P_HS = {Score.makeScore seq(items:[note(duration:6
						pitch:60
						amplitude:64)
					   note(duration:2
						pitch:62
						amplitude:64)
					   %% add lilypond articulations to note
					   note(info:lily("\\downbow")
						duration:8
						pitch:64
						amplitude:64)]
				    startTime:0
				    timeUnit:beats(4))
		add(note:MakeChordNote)}
Motif_B_P_HS = {Score.makeScore
		seq(items:[sim(items:[note(duration:4
					   pitch:67
					   amplitude:64)
				      note(duration:4
					   pitch:59
					   amplitude:64)])
			   sim(items:[note(duration:8
					   pitch:67
					   amplitude:64)
				      note(duration:8
					   pitch:60
					   amplitude:64)])]
		    startTime:0
		    timeUnit:beats(4))
		add(note:MakeChordNote)}

/*

%% same example as before, but now the resulting harmony is controlled.
%% Underlying chord progression is determined (G-7 C). Notes must be chord tones, but no further constraints for simplicity (e.g., no special constraints for bass notes or that chord is fully expressed) 

%% TODO:
%%
%% ?? show chords in lily output

declare
% {HS.db.setDB HS.dbs.default.db}
[Motif_A Motif_B]
= {Map [Motif_A_P_HS Motif_B_P_HS]
   fun {$ Proto}
      {PMotif.makeScript Proto
       unit(%% NOTE: besides the pitches, also the parameters pitchClass and octave are unset 
	    unset: [isNote#[pitch pitchClass octave]]
	    scriptArgs:
	       unit(pitchDomain:
		       proc {$ MyMotif Dom}
			  {ForAll {MyMotif collect($ test:isNote)}
			   proc {$ N} {N getPitch($)} = {FD.int Dom.1} end}
		       end # dom(60#72))
	    prototypeDependencies:
	       [isContainer#{PMotif.unifyDependency
			     fun {$ X}
				{Pattern.contourMatrix {X map($ getPitch test:isNote)}}
			     end}
	       ])}
   end}
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 fun {$}
    {Score.makeScore
     sim(items:[%% voice 1
		seq(items:[motif_A(pitchDomain:dom(60#72))
			   motif_A(pitchDomain:dom(60#72))]
		   )
		%% voice 2
		seq(items:[motif_B(offsetTime:4
				   pitchDomain:dom(48#60))
			   motif_B(offsetTime:4
				   pitchDomain:dom(48#60))])
		%% chord objects
		%% (note: showing chords in Lilypond output requires special customisation, left out here fore simplicity)
		seq(items:[chord(duration:4*4
				 index:{HS.db.getChordIndex 'dominant seventh'}
				 root:7)
			   chord(duration:4*4
				 index:{HS.db.getChordIndex 'major'}
				 root:0)])]
	 startTime:0
	 timeUnit:beats(4)
	)
     add(motif_A:Motif_A
	 motif_B:Motif_B
	 chord:HS.score.chord)}
 end 
 unit(value:random)}

*/




%%
%% motif affecting chord progression
%%



%%
%% motif variations with motif arguments
%% - show other arg defs
%% - demonstrate PMotif.choiceScript
%%



%%
%% ?? Form created algorithmically
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% ?? present abstraction for creating motif scripts
%% see /Users/t/oz/music/Strasheela/private/CompositionPlans/MicrotonalCounterpoint/MotifCollection.oz
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% nested motifs with NestedScript
%%



Motif_C_P = {Score.makeScore seq(items:[note(duration:12
					     pitch:64
					     amplitude:64)
					note(duration:4
					     pitch:62
					     amplitude:64)
					note(duration:8
					     pitch:60
					     amplitude:64)
					%% any object can be part of the motif
					pause(duration:8)
% 					note(duration:2
% 					     pitch:59
% 					     amplitude:64)
				       ]
				 startTime:0
				 timeUnit:beats(4))
	     unit}


/* % show Motif_C_P
{Out.renderAndShowLilypond Motif_C_P unit}
*/

/*

declare
[Motif_A Motif_B Motif_C]
= {Map [Motif_A_P Motif_B_P Motif_C_P]
   fun {$ Proto}
      {PMotif.makeScript Proto
       unit(unset: [isNote#pitch]
	    scriptArgs:
	       unit(pitchDomain: proc {$ MyMotif Dom}
				    {ForAll {MyMotif collect($ test:isNote)}
				     proc {$ N} {N getPitch($)} = {FD.int Dom.1} end}
				 end # dom(60#72))
	    prototypeDependencies:
	       [isContainer#{PMotif.unifyDependency
			     fun {$ X}
				{Pattern.contourMatrix
				 {X map($ getPitch test:isNote)}}
			     end}])}
   end}
%% Create a nested motif (also an extended script)
NestedMotif
= {PMotif.nestedScript
   %% the nested motif is a sequence of two Motif_A instances
   seq(info:nestedMotif
       items:[motif_A(info:id(1))
	      motif_A(info:id(2))
 	      motif_C(info:id(3))
	     ]
      )
   unit(
      % NOTE: TMP comment
      %% Argument: set contour between the highest pitches of each motif
      scriptArgs:unit(
		    contour:proc {$ MyNestedMotif Default}
			       skip
			       {Pattern.contour
				{MyNestedMotif
				 map($ PMotif.getHighestPitch
				     %% PMotif.isMotif returns true for any motif created with a Prototype motif script
				     test:PMotif.isMotif)}}
			       = Default
			    end # {Map ['+' '+'] Pattern.symbolToDirection}
		    )
      %% Use Motif_A as constructor for motif_A records etc.
      constructors:add(motif_A:Motif_A
		       motif_C:Motif_C)
      )}
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 fun {$}
    {Score.makeScore
     seq(items:[nestedMotif
		nestedMotif
		motif_C
	       ]
	 startTime:0
	 timeUnit:beats(4)
	)
     add(nestedMotif:NestedMotif
	 motif_A:Motif_A
	 motif_C:Motif_C)}
 end 
 unit(value:random)}


%% hand arguments to nested motif and inner motifs, and used in a nested context
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 fun {$}
    {Score.makeScore
     seq(items:[nestedMotif(
			      contour:{Map ['-' '-'] Pattern.symbolToDirection}
			      nestedArgs:[%% for first motif, switch to alto clef
					  id(1)#unit(info:lily("\\clef alto"))
					  %% insert rest before second inner motif 
					  id(2)#unit(offsetTime:8)])
			   nestedMotif(
			      contour:{Map ['-' '-'] Pattern.symbolToDirection}
			      nestedArgs:[id(1)#unit(info:lily("\\clef tenor"))])]
	 startTime:0
	 timeUnit:beats(4)
	)
     add(nestedMotif:NestedMotif)}
 end 
  unit(value:random)}



%% nested motif in a further nested context
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 fun {$}
    {Score.makeScore
     sim(items:[seq(items:[nestedMotif(contour:{Map ['-' '-']
						Pattern.symbolToDirection})])
		seq(items:[motif_C
			   motif_B(offsetTime:4)
			   motif_B(offsetTime:4)
			   ])]
	 startTime:0
	 timeUnit:beats(4)
	)
     add(nestedMotif:NestedMotif
	 motif_B:Motif_B
	 motif_C:Motif_C)}
 end 
  unit(value:random)}


*/





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Aux defs
%% 


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
	    clauses:[%% ignore measure objects
		     Measure.isUniformMeasures#fun {$ _} nil end
		     %% ignore chord sequences
		     fun {$ X}
			{X isContainer($)} andthen
			{HS.score.isChord {X getItems($)}.1}
		     end#fun {$ _} nil end
		     %% Mark motifs with brackets
		     %% Motif start
		     fun {$ X}
			{X isNote($)} andthen
			{PMotif.isInMotif X
			 fun {$ X MyMotif}
			    %% X is first note in motif
			    X == {MyMotif collect($ test:isNote)}.1 
			 end}
		     end # {Out.makeNoteToLily
			     fun {$ Note} '\\startGroup' end}
		     %% Motif end
		     fun {$ X}
			{X isNote($)} andthen
			{PMotif.isInMotif X
			 fun {$ X MyMotif}
			    %% X is last note in motif
			    X == {List.last {MyMotif collect($ test:isNote)}}
			 end}
		     end # {Out.makeNoteToLily
			     fun {$ Note} '\\stopGroup' end}
		    ]
	    %% See http://lilypond.org/doc/v2.11/Documentation/user/lilypond/Automatic-note-splitting#Automatic-note-splitting
	    %% Note: automatic note splitting ignores explicit ties
	    wrapper:["\\layout { \\context {\\Voice \\remove \"Note_heads_engraver\" \\remove \"Forbid_line_break_engraver\" \\consists \"Completion_heads_engraver\" \\consists \"Horizontal_bracket_engraver\"}}"
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

