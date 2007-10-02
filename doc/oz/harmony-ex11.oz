
%% feed buffer with C-. b and then solver call below, e.g., with C-. p
declare
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs/AuxDefs.ozf.bin']}

%% see ./harmony-ex01.oz for detailed comments on source

{HS.db.setDB unit(chordDB:chords(chord(comment:'minor'
				       pitchClasses:[0 3 7]
				       roots:[0]))
		  scaleDB:scales(scale(comment:'minor'
				       pitchClasses:[0 2 3 5 7 8 10]
				       roots:[0])))}

proc {MyScript HarmonisedScore}
   VoiceNr = 3
   NoteNr = 16
   Transposition = 2
   MyScale = {Score.makeScore2 scale(index:1 transposition:Transposition)
	      Aux.myCreators}
   EndTime Voices
in
   HarmonisedScore
   = {Score.makeScore
      sim(items:{Append
		 {LUtils.collectN VoiceNr
		  fun {$}
		     seq(info:myVoice % mark voice containers
			 items:{LUtils.collectN NoteNr
				fun {$}
				   note(duration:4
					pitch:{FD.int 50#76}
					inChordB:{FD.int 0#1}
					inScaleB:1
					getScales:fun {$ X} [MyScale] end
					amplitude:64)
				end}
			 endTime:EndTime)
		  end}
		 [chord(endTime:EndTime
			transposition:Transposition)]}
	  startTime:0
	  timeUnit:beats(4))
      Aux.myCreators}
   %% list of note-seqs
   Voices = {HarmonisedScore filterItems($ fun {$ X} {X hasThisInfo($ myVoice)} end)}
   %% non-harmonic pitches may be passing notes (see harmony-ex04.oz)
   {HarmonisedScore forAll(proc {$ MyNote}
			      {MyNote nonChordPCConditions([Aux.isPassingNoteR])} 
			   end
			   test:isNote)}
   %% No voices-crossing and distinct pitch classes of simultaneous note of
   %% Voices (i.e. of notes at the same position)
   {Pattern.parallelForAll {Map Voices fun {$ X} {X getItems($)} end}
    proc {$ Notes}
       {Pattern.decreasing {Map Notes fun {$ X} {X getPitch($)} end}}
       {FD.distinct {Map Notes fun {$ X} {X getPitchClass($)} end}}
    end}
   %% The pitch contour of each voice follows cycle pattern and the
   %% pitches forming this pattern are by and by increasing
    {ForAll Voices
     proc {$ MyVoice}
	Pitches = {MyVoice mapItems($ getPitch)}
	PatternLength = 4
     in
	{Pattern.cycle {Pattern.contour Pitches} PatternLength}
	%% every fourth note (i.e. every first pattern note) is
	%% increasing
	{Pattern.increasing {Pattern.everyNth Pitches PatternLength}}
     end}   
   
end



/*

declare
File = "harmony-ex11"
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

