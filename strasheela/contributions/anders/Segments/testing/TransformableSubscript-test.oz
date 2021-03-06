
declare
[Fenv Segs] = {ModuleLink ['x-ozlib://anders/strasheela/Fenv/Fenv.ozf'
			   'x-ozlib://anders/strasheela/Segments/Segments.ozf']}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Testing features of motif definitions 
%%

declare
/** %% Test DefSubscript
%%
%% */
MakeTestMotif1
= {Segs.tSC.defSubscript
   unit(motif: unit(%% explicit number of notes to avoid any ambiguity
		    %% (e.g., pitchContour has less elements) 
		    n: 5
		    %% 5 notes specified
		    durations: [2 2 3 1 6]#mapItems(_ getDuration)
		    %% one less element than durations
		    pitchContour: [2 2 0 0]
		    #fun {$ X}
			{Pattern.map2Neighbours {X mapItems($ getPitch)}
			 Pattern.direction}
		     end
		    %% only first offset time specified
		    offsetTimes: [2 '_' '_' '_' '_']#mapItems(_ getOffsetTime)
		   )
	transformers: [Segs.tSC.removeNotesAtEnd]
	idefaults: unit(%% to add DomSpec support
			constructor: {Score.makeConstructor Score.note unit}
			offsetTime: fd#[0 2]
			pitch: fd#(60#72))
% 	rdefaults: unit
       )
   nil				% Body
%    proc {$ MyScore Args}
%        skip
%     end
  }

/*

{SDistro.exploreOne
 proc {$ MyScore}
    MyScore
    = {Score.make
       seq([motif(rargs:unit(removeNotesAtEnd: 0))
	    motif(rargs:unit(removeNotesAtEnd: 1))
	    motif(rargs:unit(removeNotesAtEnd: 2))]
	   startTime:0
	   timeUnit: beats(4))
       add(motif:MakeTestMotif1)}
 end
 unit}
    
*/



declare
/** %% subscript that creates a list of notes instead of a seq and uses counterpoint mixin.
%%
%% */
MakeTestMotif_NoteList
= {Segs.tSC.defSubscript
   unit(super:Score.makeItems_iargs % list of items instead of a container
	mixins: [Segs.makeCounterpoint_Mixin]
	motif: unit(%% explicit number of notes to avoid any ambiguity
		    %% (e.g., pitchContour has less elements) 
		    n: 5
		    %% 5 notes specified
		    durations: [2 2 3 1 6]#fun {$ Ns} {Pattern.mapItems Ns getDuration} end
		   )
	transformers: [Segs.tSC.removeNotesAtEnd]
	idefaults: unit(%% to add DomSpec support
			constructor: {Score.makeConstructor HS.score.note unit}
% 			pitch: fd#(60#72)
		       )
% 	rdefaults: unit
       )
   nil				% Body
  }

/* 

{SDistro.exploreOne
 proc {$ MyScore}
    End
 in
    MyScore
    = {Score.make
       sim([seq([seq(motif(rargs:unit(removeNotesAtEnd: 0
				      maxPitch: 'C'#5 
				      minPitch: 'C'#4)))
		 seq(motif(rargs:unit(removeNotesAtEnd: 1
				      maxPitch: 'G'#5 
				      minPitch: 'G'#4))
		     endTime: End)])
	    chord(index:1
		  transposition:0
		  endTime: End)]
	    startTime:0
	    timeUnit: beats(4))
       add(motif:MakeTestMotif_NoteList
	   chord:HS.score.chord)}
 end
 unit(value:random)}


*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Testing transformers
%%

declare
/** %% Test DefSubscript
%%
%% */
MakeTestMotif2
= {Segs.tSC.defSubscript
   unit(motif: unit(durations: [4 4 6 2 12]#mapItems(_ getDuration))
	transformers: [Segs.tSC.removeShortNotes
		       Segs.tSC.substituteNote
		       Segs.tSC.diminishAdditively
		       Segs.tSC.augmentAdditively
		       Segs.tSC.diminishMultiplicatively
		       Segs.tSC.augmentMultiplicatively]
	idefaults: unit(%% test pitch
			pitch: 60)
% 	rdefaults: unit
       )
   nil}				% Body



/*

{Init.setTempo 90.0}

{SDistro.exploreOne
 proc {$ MyScore}
    MyScore
    = {Score.make
       seq([motif(rargs:unit)
	    motif(rargs:unit(removeShortNotes: 1))
	    motif(rargs:unit(removeShortNotes: 2))
	   ]
	   startTime:0
	   timeUnit: beats(4))
       add(motif:MakeTestMotif2)}
 end
 unit}


*/


/*

{SDistro.exploreOne
 proc {$ MyScore}
    MyScore
    = {Score.make
       seq([motif(rargs:unit)
	    motif(rargs:unit(substituteNote: unit(motif: unit(durations: [4 2])
						  position: 3)))
	    motif(rargs:unit(substituteNote: unit(motif: unit(durations: nil)
						  position: 3)))
	    motif(rargs:unit(substituteNote: unit(motif: unit(durations: [{FD.int 6#10}])
						  position: 3)))
	    motif(rargs:unit(substituteNote: unit(motif: unit(durations: [2 2 1 2])
						  position: 3)))
	   ]
	   startTime:0
	   timeUnit: beats(4))
       add(motif:MakeTestMotif2)}
 end
 unit}

*/



/*

{SDistro.exploreOne
 proc {$ MyScore}
    MyScore
    = {Score.make
       seq([
	    motif(rargs:unit)
 	    motif(rargs:unit(diminishAdditively: 1))
	    motif(rargs:unit(diminishAdditively: 2))
	   ]
	   startTime:0
	   timeUnit: beats(4))
       add(motif:MakeTestMotif2)}
 end
 unit}

*/



/*

{SDistro.exploreOne
 proc {$ MyScore}
    MyScore
    = {Score.make
       seq([motif(rargs:unit)
 	    motif(rargs:unit(augmentAdditively: 1))
	    motif(rargs:unit(augmentAdditively: 2))
	    motif(rargs:unit(augmentAdditively: {Fenv.linearFenv [[0.0 0.0]
								  [1.0 3.0]]}))
	   ]
	   startTime:0
	   timeUnit: beats(4))
       add(motif:MakeTestMotif2)}
 end
 unit}

*/




/*

{SDistro.exploreOne
 proc {$ MyScore}
    MyScore
    = {Score.make
       seq([motif(rargs:unit)
 	    motif(rargs:unit(diminishMultiplicatively: 2))
	    motif(rargs:unit(augmentMultiplicatively: 3
			     diminishMultiplicatively: 2))
	    motif(rargs:unit(augmentMultiplicatively: {Fenv.linearFenv [[0.0 1.0]
									[1.0 3.0]]}
			     diminishMultiplicatively: 2))
	   ]
	   startTime:0
	   timeUnit: beats(4))
       add(motif:MakeTestMotif2)}
 end
 unit}

*/




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Combining with other subscript defs
%%




