declare
%% feed buffer with C-. b and then solver call below, e.g., with C-. p
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs/AuxDefs.ozf.bin']}

%% see ./harmony-ex01.oz for detailed comments on source 


%% set chord data base to minor chord with added sixth
{HS.db.setDB unit(chordDB:chords(chord(comment:'minor with sixth'
				       pitchClasses:[0 3 7 9]
				       roots:[0])))}

proc {MyScript HarmonisedScore}
   N=8				
   EndTime MyNoteSeq 
in
   HarmonisedScore = {Score.makeScore
		      sim(items:[seq(handle:MyNoteSeq
				     items:{LUtils.collectN N
					    fun {$}
					       note(duration:4
						    pitch:{FD.int 48#72}
						    amplitude:64)
					    end}
				     endTime:EndTime)
				 chord(endTime:EndTime
				       transposition:2)]
			  startTime:0
			  timeUnit:beats(4))
		      Aux.myCreators}
   %% !! Changes here: constrain pitch classes of the notes in NoteSeq
   %% to form a cycle pattern of length 4, but all pitches differ
   {Pattern.cycle {MyNoteSeq mapItems($ getPitchClass)} 4}
   {FD.distinct {MyNoteSeq mapItems($ getPitch)}}
end


/*

declare
File = "harmony-ex03"
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
