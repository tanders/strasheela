
%%% *************************************************************
%%% Copyright (C) 2002-2005 Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% This functor defines means to output MIDI files. To this end, it makes use of csvmidi (see http://www.fourmilab.ch/webtools/midicsv/). A text file in midicsv file format is output which is transformed into a MIDI file by csvmidi.
%%
%% The documentation of the lower-level functions in this functor often quotes the documentation of csvmidi for the csv / MIDI event the function creates.
%%
%% General typing information:
%%
%% Time: an integer representing the absolute time in MIDI clocks
%% Channel: an integer in 0-15 (?)
%% Track: an integer identifying the track to which this record belongs. Tracks of MIDI data are numbered starting at 1. Track 0 is reserved for file header, information, and end of file records.
%% Text: an atom as 'my Text'
%%
%%
%% Information on internals  
%%
%% An intermediate format is used for the transformation process: on the Oz side, each record in the CSV representation is represented by an Oz record with label csv and the features track (an int), time (an int), and type (an atom). For exammple

csv(track:1 time:0 type:'Start_track')

%% Additionally, a record may have feature parameters with a list of type-specific parameters, as in the following example (the note on parameters are [Channel Note Velocity]). 

csv(track:2 time:0 type:'Note_on_c' parameters:[1 79 81])

% or this exammple (the controller parameters are [Channel ControlNum Value])

csv(track:2 time:0 type:'Control_c' parameters:[1 7 64])

%% The feature values track and time and integers (see above). Type is a virtual string corresponding to a type in the CSV file format specification (see the end of http://www.fourmilab.ch/webtools/midicsv/). The parameters are a list of values permitted in a virtual string and follow the CSV specification. For example, a title record has the format (note the explicit double quotes, according to the CSV spec).

csv(track:1 time:0 type:'Title_t' parameters:['\"This is my Title\"'])

%% An CSV score is represented internally by a list of these records.

%% See the CSV documentation (or the MidiOutput.oz source) for details on the various CSV types.

%%
%%
%% */


%% TODO:
%%
%% * BUG: the tempo setting, e.g., {Init.setTempo 150.0} possibly affects the length on equal note length in uneven way. Has this to do with the resolution / division?
%%   -> I fixed a bug in BeatsToTicks: is now this issue completely fixed?  
%%
%%
%%


functor
import
   
   GUtils at 'GeneralUtils.ozf'
   LUtils at 'ListUtils.ozf'
   Out at 'Output.ozf'
   Init at 'Init.ozf'
   Score at 'ScoreCore.ozf'
   
export

   OutputMidiFile
%   play: PlayMidiFile
   PlayMidiFile
   RenderAndPlayMidiFile
   
   MakeCSVScore
   ScoreToEvents_Midi
   OutputCSVScore OutputCSVScore2 CSVScoreToVS
%   render: RenderMidiFile
   RenderMidiFile
   
   MakeComment MakeTitle MakeCopyright MakeInstrumentName MakeMarker MakeCuePoint MakeLyric MakeText MakeSequenceNumber MakeMidiPort MakeChannelPrefix MakeTimeSignature MakeKeySignature MakeTempo BeatsPerMinuteToTempoNumber MakeSMPTEOffset MakeSequencerSpecific MakeUnknownMetaEvent
   MakeNoteOn MakeNoteOff MakePitchBend MakeCC MakeProgramChange MakeChannelAftertouch MakePolyAftertouch
   MakeSystemExclusive MakeSystemExclusivePacket

   IsCSVEvent HasType IsNoteOn IsNoteOff
   HasChannel

%   MakeMidiNote
   BeatsToTicks TicksToBeats

   MidiNoteMixin IsMidiNoteMixin MidiNote
   Note2Midi

   SetDivision

prepare   
   MidiNoteMixinType = {Name.new}
   
define

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%
   %% Generic and structural interface
   %%

   %% Any line with an initial nonblank character of ``#'' or ``;'' is ignored; either delimiter may be used to introduce comments in a CSV file. Only full-line comments are permitted; you cannot use these delimiters to terminate scanning of a regular data record. Completely blank lines are ignored.


   /** %% [aux fun] Generic CSV representation creator
   %% Track (integer) identifies the track to which this record belongs. Tracks of MIDI data are numbered starting at 1. Track 0 is reserved for file header, information, and end of file records. Args is a record of the form csv(track:<Track> time:<Time> type:<Type> [parameters:<Parameters>]).
   %% Time (integer) is the absolute time, in terms of MIDI clocks, at which this event occurs. Meta-events for which time is not meaningful (for example, song title, copyright information, etc.) have an absolute time of 0.
   %% Type (atom) is a name identifying the type of the record. Record types are text consisting of upper and lower case letters and the underscore (``_''), contain no embedded spaces, and are not enclosed in quotes. csvmidi ignores upper/lower case in the Type field; the specifications 'Note_on_c', 'Note_On_C', and 'NOTE_ON_C' are considered identical.
   %% Parameters is a list of type specific additional parameters, possibly nil. 
   %% */
   fun {MakeEvent Args}
      Track = Args.track
      Time = Args.time
      Type = Args.type
      Parameters = if {HasFeature Args parameters}
		   then Args.parameters
		   else nil
		   end
   in
      {Out.listToVS {Append [Track Time Type] Parameters} ", "}#"\n"
   end

   /*
   {MakeEvent csv(track:0 time:0 type:'Start_track')}
   {MakeEvent csv(track:2 time:0 type:'Note_on_c' parameters:[1 79 81])}
   */

   %% [aux fun]
   fun {MakeTrackStart Track}
      csv(track:Track time:0 type:'Start_track')
   end

   %% [aux fun]
   fun {MakeTrackEnd Track Time}
      csv(track:Track time:Time type:'End_track')
   end
   /** %% [aux fun] The first record of a CSV MIDI file is always the Header record. The Track and Time fields are always zero.
   %% */
   fun {MakeFileStart Format NTracks}
      csv(track:0 time:0 type:'Header'
	  parameters:[Format NTracks {GetDivision}])
   end
   /** %% [aux fun] The last record in a CSV MIDI file is always an End_of_file record. Its Track and Time fields are always zero.
   %% */
   fun {MakeFileEnd}
      csv(track:0 time:0 type:'End_of_file')
   end


   /** %% [aux fun] Transforms a list of events (all with the same track number) into a full track spec: the events in the list are sorted by their time and a start and end track event is added at the beginning and end.
   %% */
   fun {MakeTrack Events TrackNo}
      if Events == nil
      then 
	 [{MakeTrackStart TrackNo} {MakeTitle TrackNo 0 'empty track'} {MakeTrackEnd TrackNo 0}]
      else 
	 /** %% Events in the CSV file within a track are sorted by time.
	 %% */
	 fun {MySort Events}
	    {Sort Events fun {$ X Y} X.time =< Y.time end}
	 end
	 SortedEvents = {MySort Events}
	 LastTime = {List.last SortedEvents}.time
      in
	 {MakeTrackStart TrackNo}
	 | {Append SortedEvents
	    [{MakeTrackEnd TrackNo LastTime}]}
      end
   end

   /** %% [aux fun] Expects a flat list of events (each created by one of the low-level MIDI event creators such as MakeNoteOn etc.). MakeTracks returns a pair of two values Xs#NTracks: Xs is a list of events sorted first by the track number, then by time. Additionally, the track start and end events are added to this list. NTracks is the number of tracks output (where empty tracks are not counted).
   %% NB: the track number of all events must be >= 1.
   %% */
   fun {MakeTracks Events}
      fun {Aux Events TrackNo}
	 if Events == nil
	 then nil
	 else TrackEvents RestEvents in
	    {List.partition Events fun {$ X} X.track == TrackNo end TrackEvents RestEvents}
	    {MakeTrack TrackEvents TrackNo} | {Aux RestEvents TrackNo+1}
	 end
      end
      %% start with track 1: track 0 is only Header and End_of_file,
      %% created implicitly in MakeCSVScore
      %%
      %% If MakeTracks is called with events with track 0 (or even less), it causes an infinite loop. Therefore, this loop checks for those events (less efficient than without, but more secure).
      {ForAll Events proc {$ X}
			if X.track == 0
			then {Exception.raiseError
			      strasheela(failedRequirement
					 X
					 "Track number must not be 0.")}
			end
			%% !! only works when type is atom
			if X.type == 'Start_track' orelse X.type == 'End_track' 
			then {Exception.raiseError
			      strasheela(failedRequirement
					 X
					 "Track type must not be header.")}
			end
		     end}
      %%
      %% don't count empty tracks..
      UnfilteredTracks = {Aux Events 1}
      Tracks = {Filter UnfilteredTracks fun {$ X} {Not X==nil} end}
      NTracks = {Length Tracks}
   in
      {Flatten UnfilteredTracks}#NTracks
   end


%     %% Returns a score in CSV format (a VS). Events is a list of MIDI event specs (created by one of the low-level MIDI event creators such as MakeNoteOn etc.).
%    %% 
%    %%
%    fun {MakeCSVScore Events}
%       %% NTracks is the number of tracks in the file
%       SortedEvents#NTracks = {MakeTracks Events}
%       %% the MIDI file type (0, 1, or 2). Format 0 contains a single track and represents a single song performance. Format 1 may contain any number of tracks, enabling preservation of the sequencer track structure, and also represents a single song performance. Format 2 may have any number of tracks, each representing a separate song performance. Format 2 is not commonly supported by sequencers nor commonly found in the wild.
%       Format = if NTracks == 1
% 	       then 0
% 	       else 1
% 	       end
% %   %% Records in the CSV file are sorted first by the track number, then by time.
% %   %% 
% %   fun {MySort Tracks}
% %      {Flatten {Sort Tracks fun {$ X Y} X.1.track =< Y.1.track end}}
% %   end
%       MyScore = {MakeComment "Created by Strasheela on "#{GUtils.timeVString}}
%                  | {Map
% 		    {MakeFileStart Format NTracks}
% 		     | {Append SortedEvents [{MakeFileEnd}]}
% 		    MakeEvent}
%    in
%       {Out.listToVS MyScore ""}
%    end

   /** %% Expects a list of CSV records (e.g., each created by one of the low-level MIDI event creators such as MakeNoteOn etc.) and returns a full CSVScore in the internal CSV format described above.
   %% MakeCSVScore sorts the input events first by the track number, then by time. Also, it sorrounds all tracks by track start and end events, and surrounds the full score by a file header and end of file event. 
   %% NB: In Events, the track number of all events must be >= 1. This means, the direct result of an import from a CSV file can not be used, because it already includes this header events.  
   %% */
   %%
   fun {MakeCSVScore Events}
      %% NTracks is the number of tracks in the file
      SortedEvents#NTracks = {MakeTracks Events}
      %% the MIDI file type (0, 1, or 2). Format 0 contains a single track and represents a single song performance. Format 1 may contain any number of tracks, enabling preservation of the sequencer track structure, and also represents a single song performance. Format 2 may have any number of tracks, each representing a separate song performance. Format 2 is not commonly supported by sequencers nor commonly found in the wild.
      Format = if NTracks == 1
	       then 0
	       else 1
	       end
   in
      {MakeFileStart Format NTracks}
       | {Append SortedEvents [{MakeFileEnd}]}
   end

   /** %% Expects a full CSVScore in the internal CSV format described above (e.g. as created by MakeCSVScore), and transforms it into a score in the textual CSV described by http://www.fourmilab.ch/webtools/midicsv/ (a VS). 
   %% */
   %% The comment is added only here, because a comment is not part of the CSV data structure and is already a VS. 
   fun {CSVScoreToVS Events}
      {Out.listToVS 
       {MakeComment "Created by Strasheela on "#{GUtils.timeVString}}
       | {Map Events MakeEvent}
       ""}
   end
   

   /** %% Outputs a CSV file. OutputCSVScore expects Events, a list of CSV records as expected by MakeCSVScore, and a specification of the output file which has the following defaults.
   unit(file:"test"
	csvDir:{Init.getStrasheelaEnv defaultCSVDir}
	csvExtension:".csv")
   %% */
   proc {OutputCSVScore Events Spec}
      {OutputCSVScore2 {MakeCSVScore Events} Spec}
   end

   /** %% Outputs a CSV file. OutputCSVScore2 expects Events, a list of CSV records representing a full CSV score, including file and track header and end events. OutputCSVScore2 differs from OutputCSVScore in that OutputCSVScore adds those track header and end events. Spec has the following defaults.
   unit(file:"test"
	csvDir:{Init.getStrasheelaEnv defaultCSVDir}
	csvExtension:".csv")
   %% */
   proc {OutputCSVScore2 Events Spec}
      Defaults = unit(file:"test"
		      csvDir:{Init.getStrasheelaEnv defaultCSVDir}
		      csvExtension:".csv")
      Args = {Adjoin Defaults Spec}
   in
      {Out.writeToFile {CSVScoreToVS Events}
       Args.csvDir#Args.file#Args.csvExtension}
   end
   
   /** %% Transforms a CSV file into a Midi file (by calling midicsv). The Spec defaults are the following.
   unit(file:"test"
	csvDir:{Init.getStrasheelaEnv defaultCSVDir}
	midiDir:{Init.getStrasheelaEnv defaultMidiDir}
	csvExtension:".csv"
	midiExtension:".mid"
	csvmidi:{Init.getStrasheelaEnv csvmidi}
	%% !!?? is flags control needed?
	flags:{Init.getStrasheelaEnv defaultCSVFlags})
   %% */
   %% !! Only Midi file with same basename (but different extension) as input CSV file can be created.
   proc {RenderMidiFile Spec}
      Defaults = unit(file:"test"
		      csvDir:{Init.getStrasheelaEnv defaultCSVDir}
		      midiDir:{Init.getStrasheelaEnv defaultMidiDir}
		      csvExtension:".csv"
		      midiExtension:".mid"
		      csvmidi:{Init.getStrasheelaEnv csvmidi}
		      %% !!?? is flags control needed?
		      flags:{Init.getStrasheelaEnv defaultCSVFlags})
      Args = {Adjoin Defaults Spec}
      CsvPath = Args.csvDir#Args.file#Args.csvExtension
      MidiPath = Args.midiDir#Args.file#Args.midiExtension
   in
      {Out.exec Args.csvmidi {Append Args.flags [CsvPath MidiPath]}}
   end


   
   /** %% Variant of Out.scoreToEvents which deletes questionable note off events. Transformation clauses in Specs must return a list of MIDI events.
   %% In principle, multiple notes of the same channel and pitch can overlap in a Midi file. However, there is only a single note ressource and the second note will take over this ressource. What is more problematic, however, is the fact that the first note off event will turn off the note regardless whether the first of the second note was actually longer. ScoreToEvents_Midi avoids this problem by filtering out any note off event which would switch off a note too early. Nevertheless, this function can not change the fact that Midi provides only a single ressource per channel and pitch -- the 'taking over' of this ressource (e.g. restarting of the envelope) by overlapping notes can not be avoided.  
   %% */
   fun {ScoreToEvents_Midi MyScore Specs Args}
      Defaults = unit(test:fun {$ X}
			      {X isEvent($)} andthen {X isDet($)} andthen
			      ({X getDuration($)} > 0)
			   end)
      As = {Adjoin Defaults Args}
      %%
      fun {TimeLessThan Event1 Event2} Event1.time < Event2.time end
      %% returns pair NoteOnEvent#NoteOffEvent or nil
      fun {GetNoteEvent Events}
	 NoteOn = {LUtils.find Events IsNoteOn}
      in
	 if NoteOn \= nil
	 then NoteOn#{LUtils.find Events IsNoteOff}
	 else nil
	 end
      end
      %% GetStart works for subevent lists and NoteOnEvent#NoteOffEvent pairs
      fun {GetStart NoteEvents} NoteEvents.1.time end
      fun {GetEnd NoteEvents} NoteEvents.2.time end
      fun {GetChannel NoteEvents} {Nth NoteEvents.1.parameters 1} end
      fun {GetPitch NoteEvents} {Nth NoteEvents.1.parameters 2} end
      %% Removes noteoff events in subevent list at index I (if there already exists no note off then do nothing). Function removes all noteoffs, but according to doc at max. a single noteoff must occur. 
      proc {RemoveNoteOff I}
	 {Array.put EventListsA I
	  {LUtils.remove {Array.get EventListsA I} IsNoteOff}}
      end
      %% Tuple of event sublists. Events in each sublist are sorted by
      %% time, and the whole tuple of sublist is sorted by time of first
      %% event in sublist.
      EventListsT =    
        {List.toTuple unit
	 {Sort {Map 
		%% Transform objects in MyScore (fulfilling test)
		%% according to Specs. Returns list of lists of midi
		%% event records
		local
		   %% process MyScore as well, if it fits test
		   ScoreObjects = {Append if {As.test MyScore} then [MyScore] else nil end
				   {MyScore collect($ test:As.test)}}
		in
		   {LUtils.mappend ScoreObjects
		    fun {$ X}
		       Matching = {LUtils.find Specs
				   fun {$ Test#_}
				      {{GUtils.toFun Test} X}
				   end}
		    in if Matching == nil then nil
		       else _#Transform = Matching
		       in [{{GUtils.toFun Transform} X}]
		       end
		    end}
		end
% 		   {MyScore map($ fun {$ X}
% 				  Matching = {LUtils.find Specs
% 					      fun {$ Test#_}
% 						 {{GUtils.toFun Test} X}
% 					      end}
% 			       in if Matching == nil then nil
% 				  else _#Transform = Matching
% 				  in {{GUtils.toFun Transform} X}
% 				  end
% 			       end
% 			     test:As.test)}
		fun {$ Events} {Sort Events TimeLessThan} end}
	  fun {$ Events1 Events2} {TimeLessThan Events1.1 Events2.1} end}}
      %% The stateless EventListsT will be used for traversing, and the
      %% statefull EventListsA will be changed during that process
      EventListsA = {Tuple.toArray EventListsT}
   in
      {Record.forAllInd EventListsT
       proc {$ I Events1}
	  NoteEvents1 = {GetNoteEvent Events1}
       in
	  if NoteEvents1 \= nil
	  then
	     End1 = {GetEnd NoteEvents1}
	     Channel1 = {GetChannel NoteEvents1}
	     Pitch1 = {GetPitch NoteEvents1}
	  in
	     %% search forward in time (look at events at higher index
	     %% than Events1)
	     for J in I+1 .. {Width EventListsT}
		%% !! ozh can not handle the break construct
		break:Break
	     do
		Events2 = EventListsT.J
	     in
		%% stop search when encountered subevent list which
		%% starts only after current note event pair finished
		if {GetStart Events2} > End1
		then {Break} 
		else
		   NoteEvents2 = {GetNoteEvent Events2}
		in
		   if NoteEvents2 \= nil andthen
		      {GetChannel NoteEvents2} == Channel1 andthen 
		      {GetPitch NoteEvents2} == Pitch1
		   then
		      %% found note with equal channel and pitch sounding
		      %% at time of NoteEvents1
		      %%
		      %% -> remove the more early note off message (state
		      %% change of array at index of relevant position)
		      if End1 < {GetEnd NoteEvents2}
		      then {RemoveNoteOff I}
		      else {RemoveNoteOff J}
		      end 
		   end
		end
	     end
	  end
       end}
      %% return transformed event list
      {Flatten {Record.toList
		{Array.toRecord unit EventListsA}}}
   end



   /** %% Creates a MIDI file from MyScore as defined in Spec (see below). OutputMidiFile creates a CSV/MIDI file like an event list (i.e. only a single track is supported).
   %% The user can control the transformation process by specifing transformation clauses (cf. doc of Out.scoreToEvents). Each transformation function must return a list of Midi events. There must be only a single noteOn in the list of returned events and it must be coupled with a corresponding noteOff event (at least when removeQuestionableNoteoffs is set of true, which is recommended; see the doc of ScoreToEvents_Midi for the meaning of this option). Nevertheless, additional events (e.g. CC events) can be present in the same list. 
   %% The argument clauses defaults to a transformation where only notes (either instances of Score.note, MidiNote, MidiNoteMixin or any subclasses) are considered for the MIDI file.
   %% The argument scoreToEventsArgs expects a record of arguments for the proc Out.scoreToEvents/ScoreToEvents_Midi called internally. This allows to control which score objects are considered at all for output (see the Out.scoreToEvents doc for details).
   %%
   %% Spec defaults to 
   unit(file:"test"
	csvDir:{Init.getStrasheelaEnv defaultCSVDir}
	midiDir:{Init.getStrasheelaEnv defaultMidiDir}
	csvExtension:".csv"
	midiExtension:".mid"
	flags:{Init.getStrasheelaEnv defaultCSVFlags}
	headerEvents:[local Track=2 in % fixed track
			 {MakeTempo Track 0
			  {BeatsPerMinuteToTempoNumber {FloatToInt {Init.getTempo}}}}
		      end]
	clauses:[isNote#fun {$ MyNote} {Note2Midi MyNote unit} end]
	removeQuestionableNoteoffs: true
	scoreToEventsArgs: unit)

   %% where the following variables are defined and exported by the present functor BeatsToTicks, IsMidiNoteMixin, MakeNoteOn and MakeNoteOff (e.g., they can be accessed as Out.midi.beatsToTicks, if the Output module is bound to Out).
   %% */
   %% !! The present implementation interprests score as an event list (thus only a single track). An alternative definition could interpret the hierarchic structure to deduce tracks. But how should that be done? Shall the score have some fixed hierarchic structure for this purpose (e.g. an obligatory sim container as toplevel)? This can probably be done by a special clauses def which processes the containers instead of the midi notes.. 
   %%
   %% ?? shall I give default channel (for non-midi notes) or track as args? (how to access that arg in funs in arg clauses?)
   proc {OutputMidiFile MyScore Spec}
      DefaultSpec
      = unit(file:"test"
	     csvDir:{Init.getStrasheelaEnv defaultCSVDir}
	     midiDir:{Init.getStrasheelaEnv defaultMidiDir}
	     csvExtension:".csv"
	     midiExtension:".mid"
	     flags:{Init.getStrasheelaEnv defaultCSVFlags}
	     track:0
	     %%
	     headerEvents:[local Track=2 in % fixed track
			      {MakeTempo Track 0
			       {BeatsPerMinuteToTempoNumber {FloatToInt {Init.getTempo}}}}
			   end]
	     %% 
	     clauses:[isNote#fun {$ MyNote} {Note2Midi MyNote unit} end]
	     removeQuestionableNoteoffs: true
	     scoreToEventsArgs: unit)
      MySpec = {Adjoin DefaultSpec Spec}
      CVSEvents = {Append MySpec.headerEvents
		   if MySpec.removeQuestionableNoteoffs
		   then {ScoreToEvents_Midi MyScore MySpec.clauses MySpec.scoreToEventsArgs}
		   else {Out.scoreToEvents MyScore MySpec.clauses MySpec.scoreToEventsArgs}
		   end}
   in
      {OutputCSVScore CVSEvents MySpec}
      {RenderMidiFile MySpec}
   end
   
   /** %% Plays a midi file with the player specified in {Init.getStrasheelaEnv midiPlayer} according Spec which defaults to
   unit(file:"test"
	midiDir:{Init.getStrasheelaEnv defaultMidiDir}
	midiExtension:".mid"
	flags:{Init.getStrasheelaEnv defaultMidiPlayerFlags})
   %% */
   proc {PlayMidiFile Spec}
      Defaults = unit(file:"test"
		      midiDir:{Init.getStrasheelaEnv defaultMidiDir}
		      midiExtension:".mid"
		      flags:{Init.getStrasheelaEnv defaultMidiPlayerFlags})
      Args = {Adjoin Defaults Spec}
      App = {Init.getStrasheelaEnv midiPlayer}
      MidiPath = Args.midiDir#Args.file#Args.midiExtension
   in
      {Out.exec App {Append Args.flags [MidiPath]}}
   end

   /** %% Outputs MyScore into a MIDI file and starts the MIDI file player with this file. See OutputMidiFile and PlayMidiFile for documentation of the arguments expected by Spec.
   %% */ 
   proc {RenderAndPlayMidiFile MyScore Spec}
      {OutputMidiFile MyScore Spec}
      {PlayMidiFile Spec}
   end

   local
      Division = {NewCell 480}
   in
      /** %% Division (int) is the number of clock pulses per quarter note and is set in the MIDI file header. It defaults to 480.
      %% NB: I do not know whether there exists a maximum value for this (e.g. 960 seems not to work properly: it reduces notes of 1 beat to 0 beat!).
      %% */
      %% !! no thread-save definition
      proc {SetDivision X} Division:= X end
      fun {GetDivision} @Division end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%
   %% Lower-level interface
   %%
   %% All low-level creators here output the input format of MakeEvent.
   %%

   %% Def low-level interface: a specific function for each MIDI event for which midicsv defines a textual representation (i.e. for each MIDI message).


   /** %% Expects a VS and returns a CSV comment, ending with a newline (a VS).
   %% */
   fun {MakeComment VS}
      ";;; "#VS#"\n"
   end


   %%
   %% File Meta-Events
   %%

   %% The following events occur within MIDI tracks and specify various kinds of information and actions. They may appear at any time within the track. Those which provide general information for which time is not relevant usually appear at the start of the track with Time zero, but this is not a requirement.

   %% Many of these meta-events include a text string argument. Text strings are output in CSV records enclosed in ASCII double quote (") characters. Quote characters embedded within strings are represented by two consecutive quotes. Non-graphic characters in the ISO 8859/1 Latin 1 set are output as a backslash followed by their three digit octal character code. Two consecutive backslashes denote a literal backslash in the string. Strings in MIDI files can be extremely long, theoretically as many as 228-1 characters; programs which process MIDI CSV files should take care to avoid buffer overflows or truncation resulting from lines containing long string items. All meta-events which take a text argument are identified by a suffix of ``_t''. 


   /** %% Function returns a CSV event spec. The Text (an atom) specifies the title of the track or sequence. The first Title meta-event in a type 0 MIDI file, or in the first track of a type 1 file gives the name of the work. Subsequent Title meta-events in other tracks give the names of those tracks.
   %% */
   fun {MakeTitle Track Time Text}
      csv(track:Track time:Time type:'Title_t' parameters:['\"'#Text#'\"'])
   end

   /** %% Function returns a CSV event spec. The Text specifies copyright information for the sequence. This is usually placed at time 0 of the first track in the sequence.
   %% */
   fun {MakeCopyright Track Time Text}
      csv(track:Track time:Time type:'Copyright_t' parameters:['\"'#Text#'\"'])
   end

   /** %% Function returns a CSV event spec. The Text names the instrument intended to play the contents of this track, This is usually placed at time 0 of the track. Note that this meta-event is simply a description; MIDI synthesisers are not required (and rarely if ever) respond to it. This meta-event is particularly useful in sequences prepared for synthesisers which do not conform to the General MIDI patch set, as it documents the intended instrument for the track when the sequence is used on a synthesiser with a different patch set.
   %% */
   fun {MakeInstrumentName Track Time Text}
      csv(track:Track time:Time type:'Instrument_name_t' parameters:['\"'#Text#'\"'])
   end

   /** %% Function returns a CSV event spec. The Text marks a point in the sequence which occurs at the given Time, for example '"Third Movement"'.
   %% */
   fun {MakeMarker Track Time Text}
      csv(track:Track time:Time type:'Marker_t' parameters:['\"'#Text#'\"'])
   end

   /** %% Function returns a CSV event spec. The Text identifies synchronisation point which occurs at the specified Time, for example, "Door slams".
   %% */
   fun {MakeCuePoint Track Time Text}
      csv(track:Track time:Time type:'Cue_point_t' parameters:['\"'#Text#'\"'])
   end

   /** %% Function returns a CSV event spec. The Text gives a lyric intended to be sung at the given Time. Lyrics are often broken down into separate syllables to time-align them more precisely with the sequence.
   %% */
   fun {MakeLyric Track Time Text}
      csv(track:Track time:Time type:'Lyric_t' parameters:['\"'#Text#'\"'])
   end

   /** %% Function returns a CSV event spec. This meta-event supplies an arbitrary Text string tagged to its Track at Time. It can be used for textual information which doesn't fall into one of the more specific categories given above.
   %% */
   fun {MakeText Track Time Text}
      csv(track:Track time:Time type:'Text_t' parameters:['\"'#Text#'\"'])
   end

   /** %% Function returns a CSV event spec. This meta-event specifies a sequence Number between 0 and 65535, used to arrange multiple tracks in a type 2 MIDI file, or to identify the sequence in which a collection of type 0 or 1 MIDI files should be played.
   %% The SequenceNumber meta-event should occur at the start of the track (at Time zero, implicitly set). 
   %% */
   fun {MakeSequenceNumber Track Number}
      csv(track:Track time:0 type:'Sequence_number' parameters:[Number])
   end

   /** %% Function returns a CSV event spec. This meta-event specifies that subsequent events in the Track should be sent to MIDI port (bus) Number, between 0 and 255. This meta-event usually appears at the start of a track with Time zero, but may appear within a track should the need arise to change the port while the track is being played.
   %% */
   fun {MakeMidiPort Track Time Number}
      csv(track:Track time:Time type:'MIDI_port' parameters:[Number])
   end

   /** %% Function returns a CSV event spec. This meta-event specifies the MIDI channel that subsequent meta-events and system exclusive events pertain to. The channel Number specifies a MIDI channel from 0 to 15. In fact, the Number may be as large as 255, but the consequences of specifying a channel number greater than 15 are undefined.
   %% */
   fun {MakeChannelPrefix Track Time Number}
      csv(track:Track time:Time type:'Channel_prefix' parameters:[Number])
   end

   /** %% Function returns a CSV event spec. The time signature (Num/Denom), metronome click rate, and number of 32nd notes per MIDI quarter note (24 MIDI clock times) are given by the numeric arguments. Num gives the numerator of the time signature as specified on sheet music. Denom specifies the denominator as a negative power of two, for example 2 for a quarter note, 3 for an eighth note, etc. Click gives the number of MIDI clocks per metronome click, and NotesQ the number of 32nd notes in the nominal MIDI quarter note time of 24 clocks (8 for the default MIDI quarter note definition).
   %% */
   fun {MakeTimeSignature Track Time Num Denom Click NotesQ}
      csv(track:Track time:Time type:'Time_signature' parameters:[Num Denom Click NotesQ])
   end

   /** %% Function returns a CSV event spec. The key signature is specified by the numeric Key value, which is 0 for the key of C, a positive value for each sharp above C, or a negative value for each flat below C, thus in the inclusive range -7 to 7. The MajorOrMinor argument is an atom which will be major for a major key and minor for a minor key.
   %% */
   fun {MakeKeySignature Track Time Key MajorOrMinor}
      csv(track:Track time:Time type:'Key_signature' parameters:[Key '"'#MajorOrMinor#'"'])
   end

   /** %% Function returns a CSV event spec. The tempo is specified as the Number of microseconds per quarter note, between 1 and 16777215. A value of 500000 corresponds to 120 quarter notes ("beats") per minute. To convert beats per minute to a Tempo value, take the quotient from dividing 60,000,000 by the beats per minute.
   %% */
   fun {MakeTempo Track Time Number}
      csv(track:Track time:Time type:'Tempo' parameters:[Number])
   end
   /* %% Transforms BeatsPerMinute (an Int) into a tempo spec (an Int) for MakeTempo.
   %% */
   fun {BeatsPerMinuteToTempoNumber BeatsPerMinute}
      60000000 div BeatsPerMinute
   end


   /** %% Function returns a CSV event spec. This meta-event, which must occur at the start of a track (with a zero Time, implicitly set), specifies the SMPTE time code at which it should start playing. The FracFrame field gives the fractional frame time (0 to 99).
   %% */
   fun {MakeSMPTEOffset Track Hour Minute Second Frame FracFrame}
      csv(track:Track time:0 type:'SMPTE_offset' parameters:[Hour Minute Second Frame FracFrame])
   end


   /** %% Function returns a CSV event spec. The SequencerSpecific meta-event is used to store vendor-proprietary data in a MIDI file. Parameters is a list of the form [Length Data ...]. 
   %% The Length can be any value between 0 and (2^28)-1, specifying the number of Data bytes (between 0 and 255) which follow. Sequencer_specific records may be very long; programs which process MIDI CSV files should be careful to protect against buffer overflows and truncation of these records. 
   %% */
   fun {MakeSequencerSpecific Track Time Parameters}
      csv(track:Track time:Time type:'Sequencer_specific' parameters:Parameters)
   end


   /** %% Function returns a CSV event spec. If midicsv encounters a meta-event with a code not defined by the standard MIDI file specification, it outputs an unknown meta-event. Parameters is a list of the form [Type Length Data ...]. 
   %% Type gives the numeric meta-event type code, Length the number of data bytes in the meta-event, which can be any value between 0 and 228-1, followed by the Data bytes. Since meta-events include their own length, it is possible to parse them even if their type and meaning are unknown. csvmidi will reconstruct unknown meta-events with the same type code and content as in the original MIDI file.
   %% */
   fun {MakeUnknownMetaEvent Track Time Parameters}
      csv(track:Track time:Time type:'Unknown_meta_event' parameters:Parameters)
   end



   %%
   %% Channel Events
   %%

   /** %% Function returns a CSV event spec. Creates an event at Time (an int in MIDI clocks) to play the specified Note (an integer in range 0-127) on the given Channel (an int in 0-15 ?) with Velocity (an int in 0-127).
   %% A note on event with velocity zero is equivalent to a note off.
   %% */
   fun {MakeNoteOn Track Time Channel Note Velocity}
      csv(track:Track time:Time type:'Note_on_c' parameters:[Channel Note Velocity])
   end

   /** %% Function returns a CSV event spec. Creates an event at Time to stop playing the specified Note on the given Channel. The Velocity should be zero, but you never know what you'll find in a MIDI file.
   %% */
   fun {MakeNoteOff Track Time Channel Note Velocity}
      csv(track:Track time:Time type:'Note_off_c' parameters:[Channel Note Velocity])
   end

   /** %% Function returns a CSV event spec. The pitch bend Value is a 14 bit unsigned integer and hence must be in the inclusive range from 0 to 16383.
   %% NB: there was is a bug in a former in csvmidi, where pitchbend values must be in [0, 127].
   %% */
   fun {MakePitchBend Track Time Channel Value}
      csv(track:Track time:Time type:'Pitch_bend_c' parameters:[Channel Value])
   end

   /** %% Function returns a CSV event spec. Set the controller ControlNum (an int in 0-127) on the given Channel to the specified Value (an int in 0-127). The assignment of ControlNum values to effects differs from instrument to instrument. The General MIDI specification defines the meaning of controllers 1 (modulation), 7 (volume), 10 (pan), 11 (expression), and 64 (sustain), but not all instruments and patches respond to these controllers. Instruments which support those capabilities usually assign reverberation to controller 91 and chorus to controller 93.
   %% */
   fun {MakeCC Track Time Channel ControlNum Value}
      csv(track:Track time:Time type:'Control_c' parameters:[Channel ControlNum Value])
   end

   /** %% Function returns a CSV event spec. Switch the specified Channel (0-15) to program (patch) ProgramNum (0-127). The program or patch selects which instrument and associated settings that channel will emulate. The General MIDI specification provides a standard set of instruments, but synthesisers are free to implement other sets of instruments and many permit the user to create custom patches and assign them to program numbers. 
   %% Apparently due to instrument manufacturers' skepticism about musicians' ability to cope with the number zero, many instruments number patches from 1 to 128 rather than the 0 to 127 used within MIDI files. When interpreting ProgramNum values, note that they may be one less than the patch numbers given in an instrument's documentation.
   %% */
   fun {MakeProgramChange Track Time Channel ProgramNum}
      csv(track:Track time:Time type:'Program_c' parameters:[Channel ProgramNum])
   end


   /** %% Function returns a CSV event spec. When a key is held down after being pressed, some synthesisers send the pressure, repeatedly if it varies, until the key is released, but do not distinguish pressure on different keys played simultaneously and held down. This is referred to as ``monophonic'' or ``channel'' aftertouch (the latter indicating it applies to the Channel as a whole, not individual note numbers on that channel). The pressure Value (0 to 127) is typically taken to apply to the last note played, but instruments are not guaranteed to behave in this manner.
   %% */
   fun {MakeChannelAftertouch Track Time Channel Value}
      csv(track:Track time:Time type:'Channel_aftertouch_c' parameters:[Channel Value])
   end

   /** %% Function returns a CSV event spec. Polyphonic synthesisers (those capable of playing multiple notes simultaneously on a single channel), often provide independent aftertouch for each note. This event specifies the aftertouch pressure Value (0 to 127) for the specified Note on the given Channel.
   %% */
   fun {MakePolyAftertouch Track Time Channel Note Value}
      csv(track:Track time:Time type:'Poly_aftertouch_c' parameters:[Channel Note Value])
   end


   %%
   %% System Exclusive Events 
   %%


   /** %% Function returns a CSV event spec. System Exclusive events permit storing vendor-specific information to be transmitted to that vendor's products. Parameters is a list of the form [Length Data ...].
   %% The Length bytes of Data (0 to 255) are sent at the specified Time to the MIDI channel defined by the most recent Channel_prefix event on the Track, as a System Exclusive message. Note that Length can be any value between 0 and 228-1. Programs which process MIDI CSV files should be careful to protect against buffer overflows and truncation of these records.
   %% */
   fun {MakeSystemExclusive Track Time Parameters}
      csv(track:Track time:Time type:'System_exclusive' parameters:Parameters)
   end

   /** %% Function returns a CSV event spec. System Exclusive events permit storing vendor-specific information to be transmitted to that vendor's products. Parameters is a list of the form [Length Data ...].
   %% The Length bytes of Data (0 to 255) are sent at the specified Time to the MIDI channel defined by the most recent Channel_prefix event on the Track. The Data bytes are simply blasted out to the MIDI bus without any prefix. This message is used by MIDI devices which break up long system exclusive message into small packets, spaced out in time to avoid overdriving their modest microcontrollers. Note that Length can be any value between 0 and 228-1. Programs which process MIDI CSV files should be careful to protect against buffer overflows and truncation of these records.
   %% */
   fun {MakeSystemExclusivePacket Track Time Parameters}
      csv(track:Track time:Time type:'System_exclusive_packet' parameters:Parameters)
   end


   %%
   %% 'Type' checking  
   %%

   /** %% Returns true if X is a CSV event.
   %% */
   fun {IsCSVEvent X} {IsRecord X} andthen {Label X} == csv end
   /** %% Returns true if X is an CSV event of the given Type (an atom). X must be a CSV event.
   %% */
   fun {HasType X Type} X.type == Type end
   /** %% Returns true if X is an event of type 'Note_on_c'.
   %% */
   fun {IsNoteOn X} X.type == 'Note_on_c' end 
   /** %% Returns true if X is an event of type 'Note_off_c'.
   %% */
   fun {IsNoteOff X} X.type == 'Note_off_c' end
   /** %% Returns true if events of the type X provides a channel as parameter.
   %% */
   fun {HasChannel X}
      {Member X.type
      ['Note_on_c' 'Note_off_c' 'Pitch_bend_c' 'Control_c' 'Program_c' 'Channel_aftertouch_c' 'Poly_aftertouch_c']}
   end
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   %% Higher-level interface: functions which output more than one single MIDI event
/* %% tmp doc: planning..
   (e.g. {MakeMidiNote StrasheelaNote ParameterMappingDef} or {MakCCEnv Fenv ParameterMappingDef})
   
   
   %% Highly user-controlled transformation of Strasheela score to MIDI: transformation spec maps a number of boolean tests (e.g. isNote) to transformation functions. All output MIDI events are collected in a flat list
   */

   
%    %%  Function returns a list with two CSV event specs. Creates an note-on/note-off event pair at Time (an int in MIDI clocks) to play the specified Pitch (an integer in range 0-127) on the given Channel (an int in 0-15 ?) with Velocity (an int in 0-127).
%    %% 
%    fun {MakeMidiNote Track Time Duration Channel Pitch Velocity}
%       [{Out.midi.makeNoteOn Track Time Channel Pitch Velocity}
%        {Out.midi.makeNoteOff Track Time+Duration Channel Pitch 0}]
%    end

   
   /** %% Transforms a temporal value in beats (int or float) into the equivalent in MIDI ticks (int). The division is set by SetDivision.
   %% */
   fun {BeatsToTicks Beats}
      BeatsFloat = if {IsInt Beats}
		   then {IntToFloat Beats}
		   else Beats
		   end
   in
      {FloatToInt BeatsFloat * {IntToFloat {GetDivision}}}
   end

   /** %% Transforms a temporal value in MIDI ticks (int or float) into the equivalent beats (int). The division is set by SetDivision.
   %% */
   fun {TicksToBeats Ticks}
      TicksFloat = if {IsInt Ticks}
		   then {IntToFloat Ticks}
		   else Ticks
		   end
   in
      {FloatToInt TicksFloat / {IntToFloat {GetDivision}}}   
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Extend music representation 
%%%

   /** %% Defines a mixin to extend the Score.note class (or any of its subclasses) to a full MIDI note class.
   %% MidiNoteMixin defines the additional attribute channel.
   %% */
   class MidiNoteMixin
      feat label: midiNoteMixin
	 !MidiNoteMixinType:unit 
      attr channel
      meth initMidiNote(channel:Chan<=0)
	 @channel = {New Score.parameter
		     init(info:channel value:Chan 'unit':midiChannel)}
	 {self bilinkParameters([@channel])}
      end
      meth getChannel(?X) X={@channel getValue($)} end
      meth getChannelParameter(?X) X=@channel end
      meth getMidiNoteMixinAttributes(?X)
	 X = [channel]
      end
   end
   fun {IsMidiNoteMixin X}
      {Object.is X} andthen {HasFeature X MidiNoteMixinType}
   end
   /** %% Extends Score.note by the additional attribute channel.
   %% */
   class MidiNote from Score.note MidiNoteMixin
      feat label:midinote
      meth init(channel:Chan<=0 ...) = M
	 Score.note, {Record.subtractList M [channel]}
	 MidiNoteMixin, initMidiNote(channel:Chan)
      end
      meth getAttributes(?X)
	 X = {Append Score.note, getAttributes($)
	      MidiNoteMixin, getMidiNoteMixinAttributes($)}
      end
      meth toInitRecord(?X exclude:Excluded<=nil)
	 X = {Adjoin
	      Score.note, toInitRecord($ exclude:Excluded)
	      {Record.subtractList
	       {self makeInitRecord($ [channel#getChannel#0])}
	       Excluded}}
      end
   end

   /* %% Expects a note object and returns a list with corresponding MIDI note-on and note-off events. Supported optional args are track, channel (only used when MyNote does not inherit from MidiNoteMixin), and noteOffVelocity. The defaults are
   unit(track:2
	channel:0
	noteOffVelocity:0)
   %% */
   fun {Note2Midi MyNote Args}
      Defaults = unit(track:2
		      channel:0
		      noteOffVelocity:0)
      As = {Adjoin Defaults Args}
      Track = As.track % fixed track
      StartTime = {BeatsToTicks
		   {MyNote getStartTimeInSeconds($)}}
      EndTime = {BeatsToTicks
		 {MyNote getEndTimeInSeconds($)}}
      Channel = if {IsMidiNoteMixin MyNote}
		then {MyNote getChannel($)}
		else As.channel % default for all non-midi notes
		end
      Pitch = {FloatToInt {MyNote getPitchInMidi($)}}
      Velocity = {FloatToInt {MyNote getAmplitudeInVelocity($)}}
   in
      %% output a list of MIDI events 
      [{MakeNoteOn Track StartTime Channel Pitch Velocity}
       {MakeNoteOff Track EndTime Channel Pitch As.noteOffVelocity}]
   end
   

end


   
