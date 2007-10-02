
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
   NoteNo = 16 % corresponds with chord no
   NoteDur = 4 % same as chord dur
   ChordNo = 4
   ChordDur = 4*4
   MyVoice ChordSeq Chords 
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
			       chord(duration:ChordDur)
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
   0 = {Chords.1 getRoot($)} = {{List.last Chords} getRoot($)}
   %%
   %% constrain the pitch contour to follow cycle pattern
   {Pattern.cycle {Pattern.contour {MyVoice mapItems($ getPitch)}}
    4}
   %% the first three pitches are distinct
   {FD.distinct {List.take {MyVoice mapItems($ getPitch)} 3}}
   
%    %% Pitches constrained by rotation pattern: rotation pattern of length three of arbitraty ints
%    local Xs = {FD.list 3 0#100000}
%    in
%       {Pattern.rotation {MyVoice mapItems($ getPitch)} Xs}
%       {FD.distinct Xs}
%    end
end


/*

declare
File = "harmony-ex30"
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


