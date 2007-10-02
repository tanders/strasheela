
%% feed buffer with C-. b and then solver call below, e.g., with C-. p
declare
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs/AuxDefs.ozf.bin']}

%% see ./harmony-ex01.oz for detailed comments on source


{HS.db.setDB unit(chordDB:chords(chord(comment:'minor'
				       pitchClasses:[0 3 7]
				       roots:[0])))}

proc {MyScript HarmonisedScore}
   VoiceNr = 3
   NoteNr = 8
   %% variables bound later
   EndTime LongNote MyChord
in
   HarmonisedScore = {Score.makeScore
		      sim(items:{Append
				 %% create list of VoiceNr seqs with
				 %% NoteNr notes each
				 {LUtils.collectN VoiceNr
				  fun {$}
				     seq(items:{LUtils.collectN NoteNr
						fun {$}
						   note(duration:4 
							pitch:{FD.int 60#72}
							amplitude:64)
						end}
					 endTime:EndTime)
				  end}
				 %% create an additional long note
				 %% (starts at 0 and ends at EndTime)
				 %% and the chord
				 [note(handle:LongNote
				       pitch:{FD.int 48#60}
				       endTime:EndTime)
				  chord(handle:MyChord
					endTime:EndTime
					transposition:2)]}
			  startTime:0
			  timeUnit:beats(4))
		      Aux.myCreators} 
   %% pitch class of long bass note constrained to root of harmony
   {LongNote getPitchClass($)} = {MyChord getRoot($)}
end



/*

declare
File = "harmony-ex10"
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

