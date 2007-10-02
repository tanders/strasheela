
declare
[HS Pattern]
= {ModuleLink ['x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
		'x-ozlib://anders/strasheela/pattern/Pattern.ozf']}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% chord database
%%

{HS.dB.setChordDB
 chords(chord(pitchClasses:[0 4 7]
	      roots:[0]
	      test:1
	      comment:major)
	chord(pitchClasses:[0 3 6 9]
	      roots:[2 5 8 11]
	      test:7
	      comment:diminished)
	chord(pitchClasses:[0 4 8]
	      roots:[0 4 8]
	      test:0
	      comment:augmented)
       )}

{HS.dB.getPitchesPerOctave}

{HS.dB.getEditChordDB}

{HS.dB.getInternalChordDB}

%% !! I can do arbitrary chordDB accessors (e.g. get name of given chord pitch class set). I only need some standard format in the chord DB features 'comment'.
%%
%% find pitch classes of major chord:
local
   ChordType = major
   I = {LUtils.findPosition
	{Record.toList {HS.dB.getInternalChordDB}.comment}
	fun {$ X}
	   X == ChordType
	end}
in
   {HS.dB.getInternalChordDB}.pitchClasses.I
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% scale database
%%


{HS.dB.getEditScaleDB}

{HS.dB.getInternalScaleDB}

{HS.dB.setScaleDB
 scales(scale(pitchClasses:[0 2 4 5 7 9 11]
	      roots:[0]
	      test:1
	      comment:major)
	scale(pitchClasses:[0 2 3 5 7 8 9 10 11]
	      roots:[0] 
	      test:1
	      comment:minor)
	scale(pitchClasses:[0 2 4 6 8 10]
	      roots:[0 2 4 6 8 10] % !!??
	      test:0
	      comment:wholeTone)
       )}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% chord class
%%

declare
MyChord = {Score.makeScore chord(% index:1
				 % transposition:1
				 % root:1	
				 duration:1
				 startTime:0
				 timeUnit:beats(4))
	   add(chord:HS.score.chord)}

{MyChord toFullRecord($)}

{MyChord getRoot($)} = 3

{FS.include 7 {MyChord getPitchClasses($)}}


declare
Chords = {Score.makeScore sim(items:[chord(index:1 transposition:1 duration:1)
				     chord(index:1 transposition:7)]
			      startTime:0
			      timeUnit:beats(4))
	  add(chord:HS.score.chord)}

{Chords toFullRecord($)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% scale class
%%

declare
MyScale = {Score.makeScore scale(% index:1
				 % transposition:1
				 duration:1
				 startTime:0
				 timeUnit:beats(4))
	   add(scale:HS.score.scale)}

{MyScale toFullRecord($)}

{MyScale getIndex($)} = 2

{MyScale getRoot($)} = 3


declare
Scales = {Score.makeScore sim(items:[scale(index:1 transposition:1 duration:1)
				     scale(index:1 transposition:7)]
			      startTime:0
			      timeUnit:beats(4))
	  add(scale:HS.score.scale)}

{Scales toFullRecord($)}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% note class
%%

declare
MyNote = {Score.makeScore note(duration:1
			       startTime:0
			       timeUnit:beats(4))
	   add(note:HS.score.note)}

{MyNote toFullRecord($)}

{HS.dB.setPitchesPerOctave 72}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% HS.score Script
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
MyNote = {Score.makeScore note
	  add(note:HS.score.note)}

{MyNote toFullRecord($)}

{{MyNote getPitchParameter($)} addInfo(test)}

{{MyNote getPitchParameter($)} hasThisInfo($ test)}


