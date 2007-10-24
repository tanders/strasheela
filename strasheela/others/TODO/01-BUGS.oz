
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/*
%% Bug in MIDI output: TODO: filter out note off events for those note on pitches which are followed by a note on with the same pitch BEFORE the note off event of the first note!
%%
%% is this still the case?							  
*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ScoreMapping collect: flags are only partially removed..


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% debug: toInitRecord 
%%
%%  e.g. in example 04-AutomaticMelodyHarmonsation archive to init record does not work: the creators (functions/classes) are not defaults, but this is not reflected in output *.ssco file. Moreover, the scale of the chords is undefined (set to some default?), but chord pitches are constrained to be scale pitches. Finally, even if all the above is set by hand, the *.ssco solution results in failure ??

%***************************** failure **************************
%**
%** In statement: {SelectFS.select chords({0 4 7}#3 {0 3 7}#3) 2 {0 4 7 10}#4}
%**


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% !! BUG:
%%
%% undetermined temporal params, but the params are not shown in init record
declare
MyScore = {Score.makeScore seq(endTime:10 timeUnit:beats) unit}
{Inspect MyScore}
{Inspect {MyScore toInitRecord($)}}

declare
MyScore = {Score.makeScore sim(endTime:10 timeUnit:beats) unit}
{Inspect MyScore}
{Inspect {MyScore toInitRecord($)}}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% Fixed stuff (kann weg)
%%


%% MIDI output does not work: csvmidi error
%% csvmidi: Missing End_of_file record.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% FIXED
%%
%% Transforming a note object back to its init record: no start time parameter etc and timeUnit only OK if note is contained in temporal container! 

declare
MyNote = {Score.makeScore note(startTime:0
			       duration:4
			       timeUnit:beats
			       pitch:61
			       pitchUnit:midi
			       amplitude:64
			       amplitudeUnit:midi)
	  unit}

{Browse {MyNote toInitRecord($)}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% FIXED
%%
%% Bug: an undetermined HS chord can not be transformed to initRecord..

declare
MyChord = {Score.makeScore chord
	   unit(chord:HS.score.chord)}

%% !! suspends
{Browse {MyChord toInitRecord($)}}
{Browse ok}


