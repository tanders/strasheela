
%% TODO: implement transformation ideas from
%[[file:Strasheela-TODO.org::*%5B#A%5D%20Define%20Strasheela%20score%20transformations%20(instead%20of%20plain%20generation%20as%20so%20far)][Define Strasheela score transformations (instead of plain generation as so far)]]

%%
%% Transformations of some given musical snippet -- evaluate this snippet first
%%
declare
Beat = 6720
MySnippet = {Score.make seq([note(duration:8064
				pitch:67)
			   note(duration:1344
				pitch:63)
			   note(duration:1344
				pitch:65)
			   note(duration:1344
				pitch:67)
			   note(duration:1344
				pitch:68)
			   note(duration:3360
				pitch:70)
			   note(duration:3360
				pitch:72)
			   note(duration:3360
				pitch:62)
			   note(duration:6720+3360
				pitch:68)]
			  startTime:0
			  timeUnit:beats(Beat))
	   unit}

{Out.renderFomus MySnippet unit}
{Out.midi.renderAndPlayMidiFile MySnippet unit}



%%
%% Transpose all notes by a constant interval 
%%
declare
Transposed = {Score.transformScore MyScore
	      unit(clauses:[isNote#fun {$ N}
				      {Adjoin {N toInitRecord($)}
				       note(pitch:{N getPitch($)}+2)}
				   end])}
{Transposed wait}
{Out.renderFomus Transposed unit}

