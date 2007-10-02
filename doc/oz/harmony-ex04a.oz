
%% same as example ./harmony-ex04.oz, but the non-chord condition ResolveStepwiseR replace the passing note rule, and ResolveStepwiseR is defined in this file as a demonstration.

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
   %% non-harmonic pitches are passing or neighbour tones (defined by ResolveStepwiseR)
   {MyNoteSeq
    forAllItems(proc {$ MyNote}
		   {MyNote nonChordPCConditions([ResolveStepwiseR])} 
		end)}  
   %% Constrain the pitch contour such that it first
   %% raises and then falls (number of directions given to
   %% Pattern.contour must be one less then notes in NoteSeq)
   {Pattern.contour {MyNoteSeq mapItems($ getPitch)}
    {Map ['+' '+' '+' '+' '-' '-' '-'] Pattern.symbolToDirection}}
end


%% A simple non-harmonic condition example. ResolveStepwiseR is a
%% generalisation of a passing tone and a [[http://en.wikipedia.org/wiki/Nonchord_tone#Neighbour_tone][neighbour tone]] (or auxiliary
%% tone), where multiple non-chord tone can also follow each other.
%% If B=1, then Note1 can be a non-chord tone or a chord tone,
%% otherwise it must be a chord tone (this restriction is cause by the
%% method nonChordPCConditions, see above).
proc {ResolveStepwiseR Note1 B}
   MaxStep = 2
   Container = {Note1 getTemporalAspect($)}
in
   if {Note1 isFirstItem($ Container)}
      orelse {Not {Note1 hasSuccessor($ Container)}}
      %% the first note and the last note must be chord tones
   then B=0
      %% the interval to the following note is MaxStep at maximum
   else Note2 = {Note1 getSuccessor($ Container)} in
      B = {FD.reified.distance
	   {Note1 getPitch($)} {Note2 getPitch($)} '=<:' MaxStep}
   end
end


/*

declare
File = "harmony-ex04a"
OutDir = {OS.getCWD}#"/../sound/"
%% solver call
MySolution = {SDistro.searchOne MyScript Aux.myDistribution}.1
%%
{Init.setTempo 100.0}
%% output
{Aux.toMidi MySolution OutDir File}
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}

*/
