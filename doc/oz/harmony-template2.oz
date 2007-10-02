
declare
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs/AuxDefs.ozf.bin']}


%% major and minor chord
{HS.db.setDB unit(chordDB:chords(chord(comment:'maj'
				       pitchClasses:[0 4 7]
				       roots:[0])
				 chord(comment:'min'
				       pitchClasses:[0 3 7]
				       roots:[0])))}


proc {MyScript HarmonisedScore}
   VoiceNo = 1
   NoteNo = 16 % corresponds with chord no
   NoteDur = 4 % same as chord dur
   ChordNo = 4
   ChordDur = 4*4
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
		 [seq(items:{LUtils.collectN ChordNo
			     fun {$} chord(duration:ChordDur) end})]}
	  startTime:0
	  timeUnit:beats(4))
      Aux.myCreators}    
   %% list of note-seqs
   Voices = {HarmonisedScore filterItems($ fun {$ X} {X hasThisInfo($ myVoice)} end)}
   %% ..

   %% harmonic rule

   %% constraining the form: a canon

   %% constraining pitch contour etc ..
end


/*

declare
File = "harmony-template2"
OutDir = {OS.getCWD}#"/../sound/"
%% solver call
MySolution = {SDistro.searchOne MyScript Aux.myDistribution}.1
%%
%% output
{Aux.toMidi MySolution OutDir File}
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}

{SDistro.exploreOne MyScript Aux.myDistribution}

*/


