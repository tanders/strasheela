declare
%% feed buffer with C-. b and then solver call below, e.g., with C-. p
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs/AuxDefs.ozf.bin']}


{HS.db.setDB unit(chordDB:chords(chord(comment:major
				       pitchClasses:[0 4 7]
				       roots:[0])
				 chord(comment:minor
				       pitchClasses:[0 3 7]
				       roots:[0])))}


proc {MyScript HarmonisedScore}
   VoiceNo = 3
   NoteNo = 4 % corresponds with chord no
   NoteDur = 8 % same as chord dur
   Voices
in
   HarmonisedScore
   = {Score.makeScore
      sim(items:{Append
		 {LUtils.collectN VoiceNo
		  fun {$}
		     seq(info:myVoice % mark voice containers
			 items:{LUtils.collectN NoteNo
				fun {$}
				   note(duration:NoteDur
					pitch:{FD.int 48#72}
					amplitude:64)
				end})
		  end}
		 %% chord indices and transpositions specified explicitly
		 [seq(items:[chord(duration:NoteDur
				   index:1
				   transposition:0)
			     chord(duration:NoteDur
				   index:2
				   transposition:2)
			     chord(duration:NoteDur
				   index:1
				   transposition:7)
			     chord(duration:NoteDur
				   index:1
				   transposition:0)])]}
	  startTime:0
	  timeUnit:beats(4))
      Aux.myCreators}   
   %% list of note-seqs
   Voices = {HarmonisedScore filterItems($ fun {$ X} {X hasThisInfo($ myVoice)} end)}
   %% No voices-crossing and distinct pitch classes of simultaneous note of
   %% Voices (i.e. of notes at the same position)
   {Pattern.parallelForAll {Map Voices fun {$ X} {X getItems($)} end}
    proc {$ Notes}
       {Pattern.decreasing {Map Notes fun {$ X} {X getPitch($)} end}}
       {FD.distinct {Map Notes fun {$ X} {X getPitchClass($)} end}}
    end}   
end


/*

declare
File = "harmony-ex20"
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% old stuff
%%

/*

declare
proc {MyScript HarmonisedScore}
   VoiceNo = 3
   NoteNo = 4 
   NoteDur = 8 
   ActualScore = {Score.makeScore2
		  sim(info:testScore
		      items:{LUtils.collectN VoiceNo
			     fun {$}
				seq(info:myVoice % mark voice containers
				    items:{LUtils.collectN NoteNo
					   fun {$}
					      note(duration:NoteDur
						   pitch:{FD.int 48#72}
						   amplitude:64)
					   end})
			     end}
		      startTime:0
		      timeUnit:beats(4))
		  Aux.myCreators}
   %% every note of first voice starts with a new chord (and ActualScore is homophonic chord progression)
   ItemsStartingWithChord = {{ActualScore getItems($)}.1 getItems($)}
   ChordSeq
 in
    HarmonisedScore = {HS.score.harmoniseScore ActualScore ItemsStartingWithChord
		       Aux.myCreators ChordSeq} 
    %% put constraints on ChordSeq here...
 end

*/

% {SDistro.exploreOne MyScript Aux.myDistribution}

