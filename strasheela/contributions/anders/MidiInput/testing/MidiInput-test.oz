%%
%% set directory of this file to current dir but starting Oz in this file.
%%

declare
[MidiIn] = {ModuleLink ['x-ozlib://anders/strasheela/MidiInput/MidiInput.ozf']}


%% first test: parse existing csv file
{Browse {MidiIn.parseCSVFile 'Test.csv'}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Transform a MIDI file into a CSV file, parse the CSV file into a list of corresponding Oz values and browse this list
%%

{MidiIn.renderCSVFile unit(file:"bach"
			   midiExtension:".midi"
			   midiDir:{OS.getCWD}#"/"
			   csvDir:{OS.getCWD}#"/")}

{Browse {MidiIn.parseCSVFile 'bach.csv'}}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Input Midifile -> Strasheela score
%%


%%
%% test transformation to score of 'Test.csv'
%%

declare
InCSVs = {MidiIn.parseCSVFile 'Test.csv'}
%% Extract the number of clock pulses per quarter note and make it available for TicksToBeats
{Out.midi.setDivision {List.last InCSVs.1.parameters}}
%%
%% Optional: extract note-on and note-off events (note that also NestedEventsToScore performs some implicit filtering)
NoteEvents = {Filter InCSVs
	      fun {$ X} {Out.midi.isNoteOn X} orelse {Out.midi.isNoteOff X} end}
%%
{Browse {MidiIn.nestedEventsToScore {MidiIn.eventsToNestedEvents NoteEvents} unit}}


%%
%% test transformation to score of 'Bach.midi'
%%

declare
{MidiIn.renderCSVFile unit(file:"bach"
			   midiExtension:".midi"
			   midiDir:{OS.getCWD}#"/"
			   csvDir:{OS.getCWD}#"/")}
InCSVs = {MidiIn.parseCSVFile 'bach.csv'}
{Out.midi.setDivision {List.last InCSVs.1.parameters}}
{Browse {MidiIn.nestedEventsToScore {MidiIn.eventsToNestedEvents InCSVs} unit}}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Input Midifile in current directory, and output a new MIDI file
%% with the same content but transposed pitches in this directory.
%% This example does not create a Strasheela score, but demonstrates
%% how the event list can be processed directly.
%%

declare
%% Aux defs
%%
%% replace N-th element in list Xs by result of Fun application
fun {ReplaceInList Xs N Fun}
   %% tuple transformation is perhaps not efficient, but resulting code is easy to read
   T = {List.toTuple unit Xs} in
   {Record.toList {Adjoin T unit(N: {Fun T.N})}}
end
%% In record R, replace value at feature LI with Fun application
fun {ReplaceInRecord R LI Fun}
   {Adjoin R unit(LI: {Fun R.LI})}
end
%% transpose pitch of note-on or note-off event by I
fun {TransposeNote Event I}
   %% MIDI note on/off message format
   %% csv(track:Tr time:Ti type:'Note_on_c' parameters:[Channel Pitch Velocity])
   %% TransposeNote replaces Pitch in this message
   {ReplaceInRecord Event parameters
    fun {$ Xs}
       {ReplaceInList Xs 2 fun {$ X} X+I end}
    end}
end
%% The current working directory: is directory of this file if Oz was
%% started from this buffer
CWD = {OS.getCWD}#"/"
%% create CSV from MIDI file "bach.midi" in directory of this file
{MidiIn.renderCSVFile unit(file:"bach"
			   midiExtension:".midi"
			   midiDir:CWD
			   csvDir:CWD)}
%% Parse CSV into Oz value (list of midi event specs, see doc of
%% functor Out.midi for the format)
InCSV = {MidiIn.parseCSVFile 'bach.csv'}
%% Extract the number of clock pulses per quarter note
Division = {List.last InCSV.1.parameters}
%% Process the CSV list: transpose all note-on and note-off events and
%% keep the remaining events as they are
TransposedCSV = {Map InCSV
		 fun {$ Event}
		    if {Out.midi.isNoteOn Event} orelse {Out.midi.isNoteOff Event}
		       %% in case of either a note-on or note-off
		       %% event, transpose its pitch by a whole note
		       %% upwards
		    then {TransposeNote Event 2}
		    else Event 
		    end
		 end}
%% output transposed CSV file
{Out.midi.outputCSVScore2 TransposedCSV
 unit(file:'bach-transposed'
      csvDir:CWD)}
%% create MIDI file from the transposed CSV file
{Out.midi.renderMidiFile unit(file:'bach-transposed'
			      csvDir:CWD
			      midiDir:CWD
			      midiExtension:'.midi'
			      division:Division)}






