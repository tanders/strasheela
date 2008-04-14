
%% csv file: no empty lines are permitted

declare
MyScore = {Score.make seq(items:[note(pitch:60
				      duration:1
				      amplitude:30)
				note(pitch:62
				      duration:2
				     amplitude:64)
				 note(pitch:65
				      duration:4
				      amplitude:90)
				 note(pitch:67
				      duration:1
				      amplitude:70)
				note(pitch:64
				     duration:2
				     amplitude:64)]
			  startTime:0
			  timeUnit:beats)
	   unit}

{MyScore toInitRecord($)}

%% this is default..
{Out.midi.setDivision 480}

{Init.setTempo 60.0}

{Out.midi.outputMidiFile MyScore unit(file:'myTest')}

{Out.midi.playMidiFile unit(file:'myTest')}





declare
MyScore = {Score.make seq(items:[note(pitch:60
				      duration:1
				      amplitude:64
				      channel:0)
				 note(pitch:62
				      duration:1
				      amplitude:64
				      channel:0)
				 note(pitch:64
				      duration:2
				      amplitude:64
				      channel:0)]
			  startTime:0
			  timeUnit:beats)
	   add(note:Out.midi.midiNote)}

{MyScore toInitRecord($)}

{Out.midi.outputMidiFile MyScore unit(file:'myTest')}

{Out.midi.playMidiFile unit(file:'myTest')}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

{Out.writeToFile
 {Out.midi.cSVScoreToVS
  {Out.midi.makeCSVScore
   [%% Header track
    {Out.midi.makeTitle 1 0 "Close Encounters"}
    {Out.midi.makeText 1 0 'Sample for MIDIcsv Distribution'}
    {Out.midi.makeCopyright 1 0 "This file is in the public domain"}
    {Out.midi.makeTimeSignature 1 0 4 2 24 8}
    {Out.midi.makeTempo 1 0 500000}
    %% data track
    {Out.midi.makeTitle 3 0 "test title"}
    {Out.midi.makeInstrumentName 3 0 'Church Organ'}
    {Out.midi.makeProgramChange 3 0 1 19}
    %% notes 
    {Out.midi.makeNoteOn 3 0 1 79 81} 
    {Out.midi.makeNoteOff 3 960 1 79 0}
    {Out.midi.makeNoteOn 3 960 1 81 81}
    {Out.midi.makeNoteOff 3 1920 1 81 0}
    {Out.midi.makeNoteOn 3 1920 1 77 81}
    {Out.midi.makeNoteOff 3 2880 1 77 0}
    {Out.midi.makeNoteOn 3 2880 1 65 81}
    {Out.midi.makeNoteOff 3 3840 1 65 0}
    {Out.midi.makeNoteOn 3 3840 1 72 81}
    {Out.midi.makeNoteOff 3 4800 1 72 0}]}}
 "/tmp/test.csv"}


{Out.midi.outputCSVScore [%% Header track
			  {Out.midi.makeTitle 1 0 "Close Encounters"}
			  {Out.midi.makeText 1 0 'Sample for MIDIcsv Distribution'}
			  {Out.midi.makeCopyright 1 0 "This file is in the public domain"}
			  {Out.midi.makeTimeSignature 1 0 4 2 24 8}
			  {Out.midi.makeTempo 1 0 500000}
			  %% data track
			  {Out.midi.makeTitle 3 0 "test title"}
			  {Out.midi.makeInstrumentName 3 0 'Church Organ'}
			  {Out.midi.makeProgramChange 3 0 1 19}
			  %% notes 
			  {Out.midi.makeNoteOn 3 0 1 79 81} 
			  {Out.midi.makeNoteOff 3 960 1 79 0}
			  {Out.midi.makeNoteOn 3 960 1 81 81}
			  {Out.midi.makeNoteOff 3 1920 1 81 0}
			  {Out.midi.makeNoteOn 3 1920 1 77 81}
			  {Out.midi.makeNoteOff 3 2880 1 77 0}
			  {Out.midi.makeNoteOn 3 2880 1 65 81}
			  {Out.midi.makeNoteOff 3 3840 1 65 0}
			  {Out.midi.makeNoteOn 3 3840 1 72 81}
			  {Out.midi.makeNoteOff 3 4800 1 72 0}]
 unit(file:'test2'
      csvDir:{Init.getStrasheelaEnv defaultCSVDir}
      extension:'.csv')}

 
{Out.midi.renderMidiFile unit(csvFile:'test2'
			      file:'test2'
			      csvDir:{Init.getStrasheelaEnv defaultCSVDir}
			      midiDir:{Init.getStrasheelaEnv defaultMidiDir}
			      csvExtension:'.csv'
			      midiExtension:'.mid'
			      division:480
			      flags:{Init.getStrasheelaEnv defaultCSVFlags})}



/* 
%% Expected result similar to:
'0, 0, Header, 1, 2, 480
1, 0, Start_track
1, 0, Title_t, "Close Encounters"
1, 0, Text_t, "Sample for MIDIcsv Distribution"
1, 0, Copyright_t, "This file is in the public domain"
1, 0, Time_signature, 4, 2, 24, 8
1, 0, Tempo, 500000
1, 0, End_track
2, 0, Start_track
2, 0, Instrument_name_t, "Church Organ"
2, 0, Program_c, 1, 19
2, 0, Note_on_c, 1, 79, 81
2, 960, Note_off_c, 1, 79, 0
2, 960, Note_on_c, 1, 81, 81
2, 1920, Note_off_c, 1, 81, 0
2, 1920, Note_on_c, 1, 77, 81
2, 2880, Note_off_c, 1, 77, 0
2, 2880, Note_on_c, 1, 65, 81
2, 3840, Note_off_c, 1, 65, 0
2, 3840, Note_on_c, 1, 72, 81
2, 4800, Note_off_c, 1, 72, 0
2, 4800, End_track
0, 0, End_of_file'
*/



%% last: output *.csv file and call csvmidi


%% optionally: call MIDI file player (e.g pmidi on Linux)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Out.midi.scoreToEvents_Midi fixes MIDIout problem/bug
%%
%% Play note, repeat this note before first note has ended and finish
%% first note after second note:
%%
%% First case:first note is started, second note is started (with
%% same channel and pitch) before first note is stopped, but lasts
%% longer than first note. Out.midi.scoreToEvents_Midi takes out note
%% off event from first note.
%%
%% Second case: a second note with same pitch+channel starts before
%% some note ends, but the first note lasts longer than the
%% second. Out.midi.scoreToEvents_Midi takes out note off event from
%% second note.


declare
MyScore1 = {Score.make sim(items:[note(pitch:60
				      duration:2
				      amplitude:64)
				 note(offsetTime:1
				      pitch:60
				      duration:2
				      amplitude:64)]
			  startTime:0
			  timeUnit:beats)
	   unit}
MyScore2 = {Score.make sim(items:[note(pitch:60
				      duration:4
				      amplitude:64)
				 note(offsetTime:1
				      pitch:60
				      duration:2
				      amplitude:64)]
			  startTime:0
			  timeUnit:beats)
	   unit}
Clauses = [isNote#fun {$ MyNote}
	    Track = 2 % fixed track
	    StartTime = {Out.midi.beatsToTicks
			 {MyNote getStartTimeInSeconds($)}}
	    EndTime = {Out.midi.beatsToTicks
		       {MyNote getEndTimeInSeconds($)}}
	    Channel = if {Out.midi.isMidiNoteMixin MyNote}
		      then {MyNote getChannel($)}
			 %% default for all other notes
		      else 0
		      end
	    Pitch = {FloatToInt {MyNote getPitchInMidi($)}}
	    Velocity = {FloatToInt {MyNote getAmplitudeInVelocity($)}}
	 in
	    [{Out.midi.makeNoteOn Track StartTime Channel Pitch Velocity}
	     {Out.midi.makeNoteOff Track EndTime Channel Pitch 0}]
	 end]


{Out.scoreToEvents MyScore1 Clauses unit}
% vs
{Out.midi.scoreToEvents_Midi MyScore1 Clauses unit}

{Out.scoreToEvents MyScore2 Clauses unit}
%% vs
{Out.midi.scoreToEvents_Midi MyScore2 Clauses unit}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% CentToPitchbend
%%

{Out.midi.centToPitchbend ~100.0 1}
% 0

{Out.midi.centToPitchbend ~100.0 2}
% 4095

{Out.midi.centToPitchbend ~100.0 4}

{Out.midi.centToPitchbend 0.0 1}
% 8191

{Out.midi.centToPitchbend 0.0 4}
% 8191

%% rounding error of 1!
{Out.midi.centToPitchbend 100.0 1}
% 16382 % instead of 16383

{Out.midi.centToPitchbend 100.0 2}

{Out.midi.centToPitchbend ~100.0 4}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% internal stuff
%%

%% create internal CSV format score 
{Out.midi.makeCSVScore
 [%% Header track
  {Out.midi.makeTitle 1 0 "Close Encounters"}
  {Out.midi.makeText 1 0 'Sample for MIDIcsv Distribution'}
  {Out.midi.makeCopyright 1 0 "This file is in the public domain"}
  {Out.midi.makeTimeSignature 1 0 4 2 24 8}
  {Out.midi.makeTempo 1 0 500000}
  %% data track
  {Out.midi.makeTitle 3 0 "test title"}
  {Out.midi.makeInstrumentName 3 0 'Church Organ'}
  {Out.midi.makeProgramChange 3 0 1 19}
  %% notes 
  {Out.midi.makeNoteOn 3 0 1 79 81} 
  {Out.midi.makeNoteOff 3 960 1 79 0}
  {Out.midi.makeNoteOn 3 960 1 81 81}
  {Out.midi.makeNoteOff 3 1920 1 81 0}
  {Out.midi.makeNoteOn 3 1920 1 77 81}
  {Out.midi.makeNoteOff 3 2880 1 77 0}
  {Out.midi.makeNoteOn 3 2880 1 65 81}
  {Out.midi.makeNoteOff 3 3840 1 65 0}
  {Out.midi.makeNoteOn 3 3840 1 72 81}
  {Out.midi.makeNoteOff 3 4800 1 72 0}]}


%% output list of CSV records into MIDI file
{Out.midi.outputCSVScore
 [%% Header track
  {Out.midi.makeTitle 1 0 "Close Encounters"}
  {Out.midi.makeText 1 0 'Sample for MIDIcsv Distribution'}
  {Out.midi.makeCopyright 1 0 "This file is in the public domain"}
  {Out.midi.makeTimeSignature 1 0 4 2 24 8}
  {Out.midi.makeTempo 1 0 500000}
  %% data track
  {Out.midi.makeTitle 3 0 "test title"}
  {Out.midi.makeInstrumentName 3 0 'Church Organ'}
  {Out.midi.makeProgramChange 3 0 1 19}
  %% notes 
  {Out.midi.makeNoteOn 3 0 1 79 81} 
  {Out.midi.makeNoteOff 3 960 1 79 0}
  {Out.midi.makeNoteOn 3 960 1 81 81}
  {Out.midi.makeNoteOff 3 1920 1 81 0}
  {Out.midi.makeNoteOn 3 1920 1 77 81}
  {Out.midi.makeNoteOff 3 2880 1 77 0}
  {Out.midi.makeNoteOn 3 2880 1 65 81}
  {Out.midi.makeNoteOff 3 3840 1 65 0}
  {Out.midi.makeNoteOn 3 3840 1 72 81}
  {Out.midi.makeNoteOff 3 4800 1 72 0}]
 unit(file:"test"
      csvDir:{Init.getStrasheelaEnv defaultCSVDir})}
%% transform csv file into midi file
{Out.midi.renderMidiFile unit(file:"test"
			      csvDir:{Init.getStrasheelaEnv defaultCSVDir}
			      midiDir:{Init.getStrasheelaEnv defaultMidiDir})}
%% play midi file
{Out.midi.playMidiFile unit(file:"test"
			    midiDir:{Init.getStrasheelaEnv defaultMidiDir}
			    flags:{Init.getStrasheelaEnv defaultMidiPlayerFlags})}

