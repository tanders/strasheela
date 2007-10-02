
%% sequence of notes constrained to given chord

declare
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs/AuxDefs.ozf.bin']}


%% major and minor chord
{HS.db.setDB unit(chordDB:chords(chord(comment:'maj'
				       pitchClasses:[0 4 7]
				       roots:[0])
				 chord(comment:'min'
				       pitchClasses:[0 3 7]
				       roots:[0]))
		  scaleDB:scales(scale(comment:'maj'
				       pitchClasses:[0 2 4 5 7 9 11]
				       roots:[0])))}


proc {MyScript HarmonisedScore}
   VoiceNo = 3
   NoteNo = 16 % corresponds with chord no
   NoteDur = 4 % same as chord dur
   ChordNo = 4
   ChordDur = 4*4
   Voices
   ChordSeq Chords
   MyScale = {Score.makeScore2 scale(index:1 transposition:FundamentalPC)
	      Aux.myCreators}
   FundamentalPC = 2
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
					%% possibly non-harmonic but
					%% always diatonic pitch class
					inChordB:{FD.int 0#1}
					inScaleB:1
					getScales:fun {$ X} [MyScale] end
					amplitude:64)
				end})
		  end}
		 %% chord indices and transpositions specified explicitly
		 [seq(handle:ChordSeq
		      items:{LUtils.collectN ChordNo
			     fun {$}
				diatonicChord(duration:ChordDur
					      inScaleB:1
					      %% !!?? not defined init arg for chord?
					      getScales:fun {$ X} [MyScale] end)
			     end})]}
	  startTime:0
	  timeUnit:beats(4))
      Aux.myCreators}    
   %% list of note-seqs
   Voices = {HarmonisedScore filterItems($ fun {$ X} {X hasThisInfo($ myVoice)} end)}
   Chords = {ChordSeq getItems($)}
   %%
   %% Rules
   %%
   %% non-harmonic pitches may be passing notes and auxiliaries
   {ForAll Voices
    proc {$ MyVoice}
       {MyVoice forAllItems(proc {$ MyNote}
			       {MyNote nonChordPCConditions([Aux.isPassingNoteR])} 
			    end)}
    end}
   %%
   %% harmonic rules
   %%
   %% different root neighbours
   {Pattern.for2Neighbours Chords
    proc {$ Chord1 Chord2} {Chord1 getRoot($)} \=: {Chord2 getRoot($)} end}
   %% harmonic band
   {HS.rules.neighboursWithCommonPCs Chords}
   %% start and end with c
   FundamentalPC = {Chords.1 getRoot($)} = {{List.last Chords} getRoot($)}
end


/*

declare
File = "harmony-ex31"
OutDir = {OS.getCWD}#"/../sound/"
%% solver call
MySolution = {SDistro.searchOne MyScript Aux.myDistribution}.1
%%
{Init.setTempo 85.0}
%% output
{Aux.toMidi MySolution OutDir File}
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}


{SDistro.exploreOne MyScript Aux.myDistribution}

*/


