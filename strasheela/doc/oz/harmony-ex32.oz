
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
   fun {MakeVoice NoteNo Offset}
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
		 end}
	  offsetTime:Offset)
   end
   NoteDur = 4
   ChordDurFactor = 4		% ChordDur = ChordDurFactor * NoteDur
   MinNoteNo = 16		% note number for shortest voice 
   VoiceOffset = 4 % how many note after the first does the second start
   CanonNo = 12 			% how many notes form the canon
   Voices
   ChordSeq Chords
   MyScale = {Score.makeScore2 scale(index:1 transposition:FundamentalPC)
	      Aux.myCreators}
   FundamentalPC = 2
in
   HarmonisedScore
   = {Score.makeScore
      sim(items:{Append
		 [{MakeVoice MinNoteNo+2*VoiceOffset 0}
		 {MakeVoice MinNoteNo+VoiceOffset VoiceOffset*NoteDur}
		 {MakeVoice MinNoteNo 2*VoiceOffset*NoteDur}]
		 %% chord indices and transpositions specified explicitly
		 [seq(handle:ChordSeq
		      % number and duration of chords depends on note
		      % number and note dur of voice with most notes..
		      items:{LUtils.collectN ((MinNoteNo+2*VoiceOffset) div ChordDurFactor) 
			     fun {$}
				diatonicChord(duration: NoteDur*ChordDurFactor
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
   %%
   %% voices form contour-canon
   {Pattern.parallelForAll {Map Voices
			    fun {$ MyVoice}
			       {Pattern.contour
				{List.take {MyVoice mapItems($ getPitch)}
				 CanonNo}}
			    end}
    proc {$ ContoursAtSamePos} {Pattern.allEqual ContoursAtSamePos} end}
end


/*

declare
File = "harmony-ex32"
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


