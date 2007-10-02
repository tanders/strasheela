declare
%% feed buffer with C-. b and then solver call below, e.g., with C-. p
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs/AuxDefs.ozf.bin']}

%% see ./harmony-ex01.oz for detailed comments on source 

{HS.db.setDB unit(chordDB:chords(chord(comment:'minor'
				       pitchClasses:[0 3 7]
				       roots:[0]))
		  scaleDB:scales(scale(comment:'minor'
				       pitchClasses:[0 2 3 5 7 8 10]
				       roots:[0])))}

proc {MyScript HarmonisedScore}
   N=8
   Transposition = 2
   %% create minor scale 
   MyScale = {Score.makeScore2 scale(index:1 transposition:Transposition)
	      Aux.myCreators}
   EndTime MyNoteSeq 
in
   HarmonisedScore
   = {Score.makeScore
      sim(items:[seq(handle:MyNoteSeq
		     items:{LUtils.collectN N
			    fun {$}
			       note(duration:4
				    pitch:{FD.int 60#72}
				    %% note's pitch class is possibly
				    %% not a chord note (was always 1
				    %% in previous examples)
				    inChordB:{FD.int 0#1}
				    %% note's pitch class is always in
				    %% MyScale (i.e. diatonic)
				    inScaleB:1
				    getScales:fun {$ X} [MyScale] end
				    amplitude:64)
			    end}
		     endTime:EndTime)
		 chord(endTime:EndTime
		       transposition:Transposition)]
	  startTime:0
	  timeUnit:beats(4))
      Aux.myCreators} 
   %% non-harmonic pitches may be passing notes
   {MyNoteSeq
    forAllItems(proc {$ MyNote}
		   %% The note method nonChordPCConditions expects a
		   %% list of reified rules (i.e. rules returning
		   %% boolean variable, where 0 means false and 1
		   %% means true) which define allowed non-harmonic
		   %% note cases (see
		   %% ../contributions/anders/HarmonisedScore/doc/class2.html).
		   %% Aux.isPassingNoteR is predefined for convenience
		   %% (see ../contributions/anders/HarmonisedScore/doc/node4.html#entity146)
		   {MyNote nonChordPCConditions([Aux.isPassingNoteR])}
		end)}  
   %% Constrain the pitch contour such that it first
   %% raises and then falls (number of directions given to
   %% Pattern.contour must be one less then notes in NoteSeq)
   {Pattern.contour {MyNoteSeq mapItems($ getPitch)}
    {Map ['+' '+' '+' '+' '-' '-' '-'] Pattern.symbolToDirection}}
end


/*

declare
File = "harmony-ex04"
OutDir = {OS.getCWD}#"/../sound/"
%% solver call
MySolution = {SDistro.searchOne MyScript Aux.myDistribution}.1
%%
{Init.setTempo 100.0}
%% output
{Aux.toMidi MySolution OutDir File}
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}

{SDistro.exploreOne MyScript Aux.myDistribution}

*/
