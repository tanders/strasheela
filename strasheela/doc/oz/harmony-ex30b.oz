
%% sequence of notes constrained to given chord

declare
%% To link the functor with auxiliary definition of this file: within
%% OPI (i.e. emacs) start Oz from within this buffer (e.g. by
%% C-. b). This sets the current working directory to the directory of
%% the buffer.
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
   NoteNo = 16 % corresponds with chord no
   NoteDur = 4 % same as chord dur
   ChordNo = 4
   ChordDur = 4*4
   MyVoice ChordSeq Chords   
   MyScale = {Score.makeScore2 scale(index:1 transposition:FundamentalPC)
	      Aux.myCreators}
   FundamentalPC = 2
in
   HarmonisedScore
   = {Score.makeScore
      sim(items:[seq(handle:MyVoice 
		     items:{LUtils.collectN NoteNo
			    fun {$}
			       note(duration:NoteDur
				    pitch:{FD.int 60#72}
				    amplitude:64)
			    end})
		 %% chord indices and transpositions specified explicitly
		 seq(handle:ChordSeq
		     items:{LUtils.collectN ChordNo
			    fun {$}
			       diatonicChord(duration:ChordDur
					     inScaleB:1
					     %% !!?? not defined init arg for chord?
					     getScales:fun {$ X} [MyScale] end)
			    end})]
	  startTime:0
	  timeUnit:beats(4))
      Aux.myCreators}
   %%
   Chords = {ChordSeq getItems($)}
   %%
   %% Rules
   %%
   %% different root neighbours
   {Pattern.for2Neighbours Chords
    proc {$ Chord1 Chord2} {Chord1 getRoot($)} \=: {Chord2 getRoot($)} end}
   %% harmonic band
   {HS.rules.neighboursWithCommonPCs Chords}
   %% start and end with c
   FundamentalPC = {Chords.1 getRoot($)} = {{List.last Chords} getRoot($)}
   %%
   %% constrain the pitch contour to follow cycle pattern 
   {Pattern.cycle {Pattern.contour {MyVoice mapItems($ getPitch)}}
    4}
   %% the first three pitches are distinct
   {FD.distinct {List.take {MyVoice mapItems($ getPitch)} 3}}
   
end


/*

declare
File = "harmony-ex30b"
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


