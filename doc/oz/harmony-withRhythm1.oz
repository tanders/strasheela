declare
%% feed buffer with C-. b and then solver call below, e.g., with C-. p
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs/AuxDefs.ozf.bin']}

%% see ./harmony-ex01.oz and ./harmony-ex04.oz for detailed comments on source 

{HS.db.setDB unit(chordDB:chords(chord(comment:'minor'
				       pitchClasses:[0 3 7]
				       roots:[0]))
		  scaleDB:scales(scale(comment:'minor'
				       pitchClasses:[0 2 3 5 7 8 10]
				       roots:[0])))}

proc {MyScript HarmonisedScore}
   N=12
   Transposition = 2
   MyScale = {Score.makeScore2 scale(index:1 transposition:Transposition)
	      Aux.myCreators}
   EndTime MyNoteSeq 
in
   HarmonisedScore
   = {Score.makeScore
      sim(items:[seq(handle:MyNoteSeq
		     items:{LUtils.collectN N
			    fun {$}
			       note(duration:{FD.int [1 2 3 4 6 8]} % 8 
				    pitch:{FD.int 60#72}
				    %% possibly non-harmonic but
				    %% always diatonic pitch class
				    inChordB:{FD.int 0#1}
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
   %% non-harmonic pitches may be passing notes and auxiliaries
    {MyNoteSeq forAllItems(proc {$ MyNote}
 			     {MyNote nonChordPCConditions([Aux.isPassingNoteR])} 
 			  end)}
   %% constrain the pitch contour to follow cycle pattern
   {Pattern.cycle {Pattern.contour {MyNoteSeq mapItems($ getPitch)}}
    4}
   %% only short notes are non-harmonic notes
   {MyNoteSeq forAllItems(proc {$ MyNote}
			     {FD.equi ({MyNote getDuration($)} >: 2)
			      {MyNote getInChordB($)}
			      1}
			  end)}
end


/*

declare
File = "harmony-withRhythm1"
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

