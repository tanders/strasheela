
%%
%% The following examples demonstrates how Strasheela fenvs can be
%% used as continuous controllers. Fenvs (function envelope) provide a
%% highly flexible means for expressing envelopes with numeric
%% functions (see the fenv documentation for details and its test file
%% for examples). The examples below show how score values are
%% generated from fenvs, how fenvs can be stored in the score
%% directly, and how MIDI output can use these fenvs in the score in
%% various ways.
%%
%% These examples define special MIDI output procedures, which
%% overwrite the default MIDI output behaviour. The music
%% representation and its output definition are separated. That way,
%% users can customise the meaning of their music representation and
%% specify how their particular representation is output. For example,
%% users may once define a suitable output for their purposes, and
%% then create multiple scores which use this output either manually,
%% by constraint programming, by manually editing the solution of
%% their constraint problem etc.
%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Global definitions
%%
%% These definitions are used by multiple examples below -- always
%% feed these definitions first, then feed the examples paragraph-wise. 
%%


declare
[Fenv] = {ModuleLink ['x-ozlib://anders/strasheela/Fenv/Fenv.ozf']}
%% fixed track for MIDI output
Track = 2
ProcessEventsAndContainers = unit(test:fun {$ X}
					  {X isItem($)} andthen {X isDet($)}
					  andthen {X getDuration($)} > 0
				       end)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Example 1: use a fenv for expressing a crescendo over several
%% notes. The fenv is then used for creating the score (i.e., the
%% resulting score does not contain the fenv itself).
%%

declare
%% A sequence of 8 pitches (C major scale)
Pitches = [60 62 64 65 67 69 71 72]
%% A list of 7 quarter notes and a halve note (time unit is beat)
Durs = [1 1 1 1 1 1 1 2]
%% A linear fenv from 27.0 to 127.0 (MIDI velocity values)
AmpsF = {New Fenv.fenv init(env:fun {$ X} X * 100.0 + 27.0 end)}
%% Sampling the fenv (8 values) 
Amps = {AmpsF toList_Int($ 8)}
%% Create score 
Test1 = {Score.makeScore
	 seq(items:{Map {LUtils.matTrans [Durs Pitches Amps]}
		    fun {$ [MyDur MyPitch MyAmp]}
		       note(duration:MyDur
			    pitch:MyPitch
			    amplitude:MyAmp)
		    end}
	     startTime:0
	     timeUnit:beats)
	 unit}


/*

%% Show fenv as graph (needs gnuplot installation)
{AmpsF plot}

%% Show resulting full score in textual format -- mind the notes' amplitude values! 
{Browse {Test1 toInitRecord($)}}

*/


%% Output MIDI file with the default output settings. 
{Init.setTempo 70.0}
{Out.midi.renderAndPlayMidiFile Test1
 unit(file:"Test1")}


%% Again output MIDI file, but this time the output is customised. A
%% random MIDI program change is output additionally for each note
%% (assumes GM).
{Out.midi.renderAndPlayMidiFile Test1
 unit(file:"Test1-randomChans"
      %% We overwrite the default output for every object for which
      %% the method isNote returns true.
      clauses:[isNote#fun {$ MyNote}
			 %% Channels are in [0, 15], see midicsv doc
			 Channel = 0
			 %% Create a program change event with
			 %% random program number at the start
			 %% time of MyNote
			 Time = {Out.midi.beatsToTicks
				 {MyNote getStartTimeInSeconds($)}}
			 ProgNumber = {GUtils.random 127}
			 ProgChange = {Out.midi.makeProgramChange Track Time Channel ProgNumber}
			 %% Create list of note-on and note-off events for MyNote 
			 NoteEvents = {Out.midi.noteToMidi MyNote unit(track:Track
								      channel:Channel)}
		      in
			 %% output a list of MIDI events
			 ProgChange | NoteEvents
		      end])}


 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Example 2: associate multiple fenvs with each note. The example
%% represents the note volume (MDI CC 7) and pitchbend with fenvs.
%% Note: use a recent version of midicsv (there was a bug in a
%% previous version concerning the pitchbend range).
%%
%% Remember that due to the definition of the MIDI format, MIDI CC
%% events and pitchbend events affect all notes of one channel at
%% (after) the time the event occurs. Also, remember that the range
%% for MIDI CC values is [0,127] whereas for pitchbend values it is
%% [0, 16,383].
%%

%%
%% This example simply adds a record of fenvs to the info attribute of
%% notes. A more elaborated approach may define a new note class which
%% introduces a special attribute for the fenvs.
%%


declare
Chan = 0
%% Note volume fenv: sine segment x=[0, pi], specified by that args
%% min and max. The range of the resulting values is 27.0 and 127.0.
VolumeF = {New Fenv.fenv init(env:fun {$ X} {Sin X} * 100.0 + 27.0  end
			      min:0.0
			      max:GUtils.pi)}
%% Linear pitchbend fenv
PitchBendF1 = {New Fenv.fenv init(env:fun {$ X} X * 16383.0 end)}
%% Complex pitchbend fenv: sin LFO with 3 cycles, modulated by two
%% BPFs (linear envelops for which [x,y] breakpoints are specified),
%% one used for scaling (mul) and one for offset (add).
PitchBendF2 = {Fenv.sinOsc 3 unit(mul:{Fenv.linearFenv [[0.0 0.0] [0.7 5000.0] [1.0 0.0]]}
				  add:{Fenv.linearFenv [[0.0 16383.0] [1.0 5.0]]})}
%% My score with a record of fenvs in the notes' info attributes
Test2 = {Score.makeScore
	   seq(items:[note(info:fenvs(pitchBend:PitchBendF1 volume:VolumeF)
			   duration:10 % secs
			   pitch:60
			   amplitude:64
			   channel:Chan)
		      note(info:fenvs(pitchBend:PitchBendF2 volume:VolumeF)
			   duration:10
			   pitch:60
			   amplitude:64
			   channel:Chan)
		      note(info:fenvs(pitchBend:PitchBendF1 volume:VolumeF)
			   duration:3
			   pitch:60
			   amplitude:64
			   channel:Chan)]
	       startTime:0
	       timeUnit:secs)
	 %% for note objects use MIDI note class 
	 add(note:Out.midi.midiNote)}


/*

%% Output MIDI file without effect of fenvs
{Out.midi.renderAndPlayMidiFile Test2
 unit(file:"Test2-plain")}

*/


/*

%% Show fenvs as graph (n specifies number of values shown)
{VolumeF plot(n:10)}
{PitchBendF1 plot(n:100)}
{PitchBendF2 plot(n:100)}

*/


%% Output MIDI file with CC 7 controller messages (volume) and pitchbend 
{Out.midi.renderAndPlayMidiFile Test2
 unit(file:"Test2-withCCMessages"
      %$ The following header events are put at the beginning of the resulting MIDI file
      headerEvents:[%% Set instrument on Chan 
		    {Out.midi.makeProgramChange Track 0 Chan 64}
		    %% initial tempo
		    {Out.midi.makeTempo Track 0
		     {Out.midi.beatsPerMinuteToTempoNumber {FloatToInt {Init.getTempo}}}}]
      %% Overwrite note output
      clauses:[isNote#fun {$ MyNote}
			 %% MyNote is MIDI note, so I can access its channel
			 Channel = {MyNote getChannel($)}
 			 %% Extract record with label fenv from note's info
			 Fenvs = {MyNote getInfoRecord($ fenvs)}
			 %% volume output as list of CC 7 events: 
			 %% 10 values between start and end time of MyNote
			 VolEvents = {Fenv.itemFenvToMidiCC Fenvs.volume 10 Track MyNote Channel
				      cc#7}
			 %% 100 pitchbend values are output.
			 PBEvents = {Fenv.itemFenvToMidiCC Fenvs.pitchBend 100 Track MyNote Channel
				     pitchbend}
			 %% Create list of note-on and note-off events for MyNote 
			 NoteEvents = {Out.midi.noteToMidi MyNote unit(track:Track)}
		      in
			 %% append all given sublists 
			 {LUtils.accum [VolEvents PBEvents NoteEvents]
			  Append}
		      end])}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Example 3: like example 1, this example also uses a fenv for
%% expressing a crescendo over several notes. However, this time
%% volume fenvs are stored in the music representation, namely in the
%% info attribute of the sequential container which groups the
%% notes. The MIDI output defined below makes use of these fenvs.
%%

declare
Pitches = [60 62 64 65 67 69 71 72]
Durs = [1 1 1 1 1 1 1 2]
VolumeF = {New Fenv.fenv init(env:fun {$ X} X * 80.0 + 47.0 end)}
Chan = 0
Test3 = {Score.makeScore
	 seq(items:[seq(info: [voice fenvs(volume:VolumeF
					   channel:Chan)]
			items:{Map {LUtils.matTrans [Durs Pitches]}
			       fun {$ [MyDur MyPitch]}
				  note(duration:MyDur
				       pitch:MyPitch
				       amplitude:64
				       channel:Chan)
			       end})
		    seq(info: [voice fenvs(volume:{Fenv.reverseFenv VolumeF}
					   channel:Chan)]
			items:{Map {LUtils.matTrans [Durs {Reverse Pitches}]}
			       fun {$ [MyDur MyPitch]}
				  note(duration:MyDur
				       pitch:MyPitch
				       amplitude:64
				       channel:Chan)
			       end})]
	     startTime:0
	     timeUnit:beats)
	 add(note:Out.midi.midiNote)}


%% output 
{Out.midi.renderAndPlayMidiFile Test3
 unit(file:"Test3"
      %% By default, only events (e.g., MIDI notes) are considered for
      %% output, but we want to process containers as well. We now
      %% consider all fully determined items with duration > 0 for
      %% output.
      scoreToEventsArgs:unit(test:fun {$ X}
				     {X isItem($)} andthen {X isDet($)}
				     andthen {X getDuration($)} > 0
				  end)
      %% clauses
      clauses:[%% Default note output
	       isNote#fun {$ MyNote} {Out.midi.noteToMidi MyNote unit} end
	       %% Defines output for sequential containers which are
	       %% marked with info 'voice'
	       fun {$ X}
		  {X isSequential($)} andthen {X hasThisInfo($ voice)}
	       end#fun {$ MySeq}
		      %% Extract fenv record from info
		      Fenvs = {MySeq getInfoRecord($ fenvs)}
		   in
		      {Fenv.itemFenvToMidiCC Fenvs.volume 10 Track MySeq Fenvs.channel
		       cc#7}
		   end])}






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Example 4: with time shift fenv stored in container. The time shift
%% fenv is used from within the note output.
%%
%%

declare
Pitches = [60 62 64 65 67 69 71 72]
Durs = [1 1 1 1 1 1 1 2]
%% Time shift curve: simple give and take rubato: full sine period,
%% y in [~0.2, 0.2]
TimeShiftF = {New Fenv.fenv init(env:fun {$ X} {Sin X} * 0.2 end
			     min:0.0
			     max:2.0*GUtils.pi)}
Chan = 0
Test4 = {Score.makeScore
	 seq(items:[seq(info: [voice fenvs(timeShift:TimeShiftF)]
			items:{Map {LUtils.matTrans [Durs Pitches]}
			       fun {$ [MyDur MyPitch]}
				  note(duration:MyDur
				       pitch:MyPitch
				       amplitude:64
				       channel:Chan)
			       end})
		    seq(info: [voice fenvs(timeShift:TimeShiftF)] % {Fenv.reverseFenv TimeShiftF}
			items:{Map {LUtils.matTrans [Durs {Reverse Pitches}]}
			       fun {$ [MyDur MyPitch]}
				  note(duration:MyDur
				       pitch:MyPitch
				       amplitude:64
				       channel:Chan)
			       end})]
	     startTime:0
	     timeUnit:beats)
	 add(note:Out.midi.midiNote)}

/*
{TimeShiftF plot}
*/


%% output 
{Out.midi.renderAndPlayMidiFile Test4
 unit(file:"Test4"
      %% By default, only events (e.g., MIDI notes) are considered for
      %% output, but we want to process containers as well. We now
      %% consider all fully determined items with duration > 0 for
      %% output.
      scoreToEventsArgs:ProcessEventsAndContainers
      %% clauses
      clauses:[isNote#fun {$ MyNote}
			 MySeq = {MyNote getTemporalContainer($)}
			 TimeShiftF = {MySeq getInfoRecord($ fenvs)}.timeShift
			 NoteStart = {MyNote getStartTimeInSeconds($)}
			 NoteEnd = {MyNote getEndTimeInSeconds($)}
			 Channel = {MyNote getChannel($)}
			 Pitch = {FloatToInt {MyNote getPitchInMidi($)}}
			 Velocity = {FloatToInt {MyNote getAmplitudeInVelocity($)}}
			 StartOffset = {Fenv.itemFenvY TimeShiftF MySeq {MyNote getStartTime($)}}
			 EndOffset = {Fenv.itemFenvY TimeShiftF MySeq {MyNote getEndTime($)}}
			 %% compute note start and end times 
			 StartTime = {Out.midi.beatsToTicks NoteStart + StartOffset}
			 EndTime = {Out.midi.beatsToTicks NoteEnd + EndOffset}
		      in
			 [{Out.midi.makeNoteOn Track StartTime Channel Pitch Velocity}
			  {Out.midi.makeNoteOff Track EndTime Channel Pitch 0}]
		      end])}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Example 5: with global tempo curve fenv stored in top-level 
%%
%%

declare
Pitches = 60|62|64|59|{List.make 13}
{Pattern.cycle Pitches 4}	% determines pitches
Durs = 2|2|3|1|{List.make 13}
{Pattern.cycle Durs 4}
%% Tempo curve: y values in beats per minute 
TempoF = {Fenv.linearFenv [[0.0 30.0] [1.0 120.0]]}
Chan = 0
Test5a = {Score.makeScore
	 seq(info:[topLevel fenvs(tempo:TempoF channel:Chan)]
	     items:{Map {LUtils.matTrans [Durs Pitches]}
		    fun {$ [Dur Pitch]}
		       note(duration:Dur
			    pitch:Pitch
			    amplitude:64
			    channel:Chan)
		    end}
	     startTime:0
	     timeUnit:beats(2))
	 add(note:Out.midi.midiNote)}



/*
%% plot tempo curve
{TempoF plot}
*/



%% Outputting the global tempo curve as MIDI tempo values.
%% 
%% NOTE: MIDI tempo values are stored globally in a MIDI file, some
%% players/sequencers ignore them or load them only under specific
%% circumstances.  For example, the Quicktime Player ignores them and
%% Logic only loads them when a MIDI file is opened and not imported.
{Out.midi.renderAndPlayMidiFile Test5a
 unit(file:"Test5a"
      %% process containers as well. 
      scoreToEventsArgs:ProcessEventsAndContainers
      %% clauses
      clauses:[%% Default note output
	       isNote#fun {$ MyNote} {Out.midi.noteToMidi MyNote unit} end
	       fun {$ X}
		  {X isSequential($)} andthen {X hasThisInfo($ topLevel)}
	       end#fun {$ MySeq}
		      Fenvs = {MySeq getInfoRecord($ fenvs)}
		   in
		      {Fenv.itemFenvToMidiCC Fenvs.tempo 10 Track MySeq Fenvs.channel
		       fun {$ Track Time _/*Channel*/ Value}
			  %% implicitly, transform beats per minute to MIDI tempo value
			  {Out.midi.makeTempo Track Time
			   {Out.midi.beatsPerMinuteToTempoNumber Value}}
		       end}
		   end])}


%%%%%%%%%%%%%%%%%%%%%
%%
%% Example 5b
%% 

declare
Pitches = 60|62|64|59|{List.make 13}
{Pattern.cycle Pitches 4}	% determines pitches
Durs = 2|2|3|1|{List.make 13}
{Pattern.cycle Durs 4}
%% Tempo curve: y value 1 means score tempo (60 BPM), 0.5 means halve score tempo (30 BPM) etc.
% TempoF = {Fenv.linearFenv [[0.0 0.5] [1.0 0.5]]}
TempoF = {Fenv.linearFenv [[0.0 1.0] [1.0 1.0]]}
% TempoF = {Fenv.linearFenv [[0.0 2.0] [1.0 0.5]]}
%% transform the tempo curve into a time map
%% (internally, this uses numeric integration)
TimeMapF = {Fenv.tempoCurveToTimeMap TempoF 0.01}
Chan = 0
Test5b = {Score.makeScore
	 seq(info:[topLevel fenvs(timeMap:TimeMapF channel:Chan)]
	     items:{Map {LUtils.matTrans [Durs Pitches]}
		    fun {$ [Dur Pitch]}
		       note(duration:Dur
			    pitch:Pitch
			    amplitude:64
			    channel:Chan)
		    end}
	     startTime:0
	     timeUnit:beats(2))
	 add(note:Out.midi.midiNote)}


/*
%% plot tempo curve
{TempoF plot}
%% plot resulting time map function
{TimeMapF plot}
*/




%% Outputting the global tempo curve by adjusting the MIDI event times. 
%%
declare
/** %%
%% */
%% NOTE: timing information is not 100% exact. For example,
%% NormScoreTime \= NormPerformanceTime, as it should be for tempo=1
%% ??? However, these deviations are caused by my poor mans integration (increasing arg Step in Fenv.tempoCurveToTimeMap improves precision).
fun {PerformanceTime TimeMapFenv Start Duration MyScoreTime}
   %% NormScoreTime is in [0, 1]
   NormScoreTime = (MyScoreTime-Start) / Duration
   NormPerformanceTime = {TimeMapFenv y($ NormScoreTime)}
   PerformanceTime = NormPerformanceTime * Duration + Start
in
   {Browse unit(scoreTime:MyScoreTime
		normScoreTime:NormScoreTime
		normPerformanceTime:NormPerformanceTime
		performance:PerformanceTime
		%% midi:{Out.midi.beatsToTicks PerformanceTime}
	       )}
   {Out.midi.beatsToTicks PerformanceTime}
end
{Out.midi.renderAndPlayMidiFile Test5b
 unit(file:"Test5b"
      scoreToEventsArgs:ProcessEventsAndContainers
      %% clauses
      clauses:[isNote#fun {$ MyNote}
			 MySeq = {MyNote getTemporalContainer($)}
			 SeqStart = {MySeq getStartTimeInSeconds($)}
			 SeqDur = {MySeq getDurationInSeconds($)}
			 {Browse unit(seqStart:SeqStart seqDur:SeqDur)}
			 TimeMapF = {MySeq getInfoRecord($ fenvs)}.timeMap
			 %% 
			 Start = {PerformanceTime TimeMapF SeqStart SeqDur
				  {MyNote getStartTimeInSeconds($)}}
			 End = {PerformanceTime TimeMapF SeqStart SeqDur
				{MyNote getEndTimeInSeconds($)}} 
			 Channel = {MyNote getChannel($)}
			 Pitch = {FloatToInt {MyNote getPitchInMidi($)}}
			 Velocity = {FloatToInt {MyNote getAmplitudeInVelocity($)}}
		      in
			 [{Out.midi.makeNoteOn Track Start Channel Pitch Velocity}
			  {Out.midi.makeNoteOff Track End Channel Pitch 0}]
		      end])}



%% some bug when transforming score time to performance time: tempo to high
%% 


