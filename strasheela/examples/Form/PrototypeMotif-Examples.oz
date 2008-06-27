
%%
%% This file lists some small-scale examples which use the prototype motif model. Note that for simplicity many examples only apply motif-related constraints (so the result could have been created in a purely deterministic way without constraint programming). However, additional constraints can be add to these examples. 
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
Motif_A_P = {Score.makeScore seq(items:[note(duration:6
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

/*

%% motif instance follows pitch intervals of orig motifs, but motifs may be transposed

declare
%% aux var to avoid negative interval variables
IntervalOffset = 100
/** %% Returns the intervals between notes in MyMotif (list of implicitly declared FD ints).
%% */
fun {GetPitchIntervals MyMotif}
   {Pattern.map2Neighbours {X mapItems($ getPitch test:isNote)}
    proc {$ Pitch1 Pitch2 ?Interval}
       Interval = {FD.decl}
       Pitch1 + Interval =: Pitch2 + IntervalOffset
    end}
end
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
%% CSP consisting of two different motifs with no other constraints 
%%




%%
%% add simple harmony constraint
%%



%%
%% constrain relation between motifs
%% see /Users/t/oz/music/Strasheela/private/CompositionPlans/MicrotonalCounterpoint/MotifCollection.oz
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
%% nested motifs
%%



	   

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

