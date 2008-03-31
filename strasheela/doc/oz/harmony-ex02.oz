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
   EndTime MyNoteSeq MyChord
in
   HarmonisedScore = {Score.makeScore
		      sim(items:[seq(%% feature handle binds variable
                                     %% MyNoteSeq to seq score object
                                     %% created by Score.makeScore 
				     handle:MyNoteSeq
				     items:{LUtils.collectN N
					    fun {$}
					       note(duration:4
						    pitch:{FD.int 48#72}
						    amplitude:64)
					    end}
				     endTime:EndTime)
				 chord(handle:MyChord
				       endTime:EndTime
				       transposition:2)]
			  startTime:0
			  timeUnit:beats(4))
		      Aux.myCreators}
   %% !! added constraint:
   %% constrain pitches of the note in NoteSeq to raise continuously 
   {Pattern.increasing {MyNoteSeq mapItems($ getPitch)}}
   %% pitch class of first note is chord root
   {{MyNoteSeq getItems($)}.1 getPitchClass($)} = {MyChord getRoot($)}
end


/*

declare
File = "harmony-ex02"
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

