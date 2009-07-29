
%%
%% The following examples demonstrate different approaches for creating
%% microtonal music with Strasheela via MIDI files. The examples don't
%% use constraint programming for simplicity, but you can output the
%% results of your CSPs the same way.
%%
%% Usage: first feed buffer with the global definitions. Then feed
%% examples in block comments, one by one.
%%

%%
%% Note: Fenv.renderAndPlayMidiFile has buildin support for microtonal music, so this example is only to show how you can define such things yourself :)
%%


%% global definitions 
declare 
/** %% MakeChannelCreator returns a nullary function for creating zero-based MIDI channel numebers in a round robin fashion. The minimum channel number is 0 and the maximum number is MaxChan. IgnoreChans is a list of channel numbers to skip (e.g. 9 is often used for rhythm instruments).
%% */
local I = {NewCell 0} in
   proc {MakeChannelCreator MaxChan IgnoreChans ?Fn}
      fun {Fn}
	 X = (I := @I+1) mod MaxChan+1
      in
	 if {Member X IgnoreChans} then {Fn} else X end
      end
   end
end
%% Create channel numbers in 0-15, but skip 9.
NextChan = {MakeChannelCreator 15 [9]}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Mini example: single note output, no microtonal pitch control
%%

/*

declare
MyNote = {Score.makeScore note(duration:4
			       pitch:60
			       startTime:0
			       amplitude:127
			       timeUnit:beats)
	  unit}
{MyNote wait}
{Out.midi.renderAndPlayMidiFile MyNote
 unit(file:singleNote)}

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% WARNING: a score must be fully determined, otherwise MIDI output
%% can block or result in an error message. In the example below, no
%% note amplitude is specified!
%%

/*

declare
MyNote = {Score.makeScore note(duration:4
			       pitch:60
			       startTime:0
			       % amplitude:127
			       timeUnit:beats)
	  unit}
{Out.midi.renderAndPlayMidiFile MyNote
 unit(file:singleNote)}

*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Microtonal output: the following examples use 22 pitches per octave.
%%
%% Monophonic case: all notes played by same MIDI channel with
%% preceeding pitchbend message
%%
%% Example defines a clause for notes which outputs pitchbend and
%% note-on/note-off messages always to the MIDI channel 0 (MIDI
%% channel output is zero-based).
%%
%%

/*

declare
[ET22] = {ModuleLink ['x-ozlib://anders/strasheela/ET22/ET22.ozf']}
{HS.db.setDB ET22.db.fullDB}
%% create chromatic scale with 22 pitches per octave
PCs = {List.number 0 21 1}
MyScore = {Score.makeScore seq(items:{Map PCs
				      fun {$ PC}
					 note(duration:4
					      pitchClass:PC
					      octave:4
					      pitchUnit:et22
					      amplitude:64)
				      end}
			       startTime:0
			       timeUnit:beats(4))
	   add(note:HS.score.note)}
%% NB: wait until constraint propagation determines all parameters in score (e.g. the note start times are not given explicitly but derived by constraint propagation). This explicit waiting is not necessary in a constraint problem (it is always done implicitly by the search process).
{MyScore wait}
{Init.setTempo 60.0}
%% For confirmation: show scale with Lilypond (requires Lilypond 2.11.43 or later)
{ET22.out.renderAndShowLilypond MyScore
 unit(file:noteSeq_22ET)}
%% Create and play Midi file 
{Out.midi.renderAndPlayMidiFile MyScore
 unit(file:noteSeq_22ET
      clauses:[isNote
	       #fun {$ N}
		   Chan = 0
		in
		   {Out.midi.noteToPitchbend N unit(channel:Chan)}
		   | {Out.midi.noteToMidi N unit(channel:Chan)}
		end])}

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Microtonal output: polyphonic case (simple round robin approach):
%% each note is played by different channel (as specified, default is
%% 0-15) and that channel is always tuned by a pitchbend message
%% first. Make sure that your MIDI instrument has the same sound
%% settings for these channels and that the pitchbend resolution set
%% to the standard +/- 2 semitones.  Note: for longer sounding notes
%% it may happen that they are unintentionally retuned with this
%% simple approach!
%%
%% Example defines a clause for notes which outputs pitchbend and
%% note-on/note-off messages to a channel created with the function
%% call {NextChan}, a function defined in the example.
%%
%% Note that this example uses plain note objects (instances of
%% Score.note) which don't specify a MIDI channel themselves (in
%% contrast to instances of, e.g., Out.midi.midiNote) -- using the
%% latter might result in conflicts between the round-robin created
%% MIDI channel numbers and the MIDI channel of the note object.
%%

%%
%% The example plays Erlich's 'standard pentachordal major' scale
%%

/*

declare
%%
[ET22] = {ModuleLink ['x-ozlib://anders/strasheela/ET22/ET22.ozf']}
{HS.db.setDB ET22.db.fullDB}
%%
%% pitch classes of 'standard pentachordal major'
PCs = [0 2 4 7 9 11 13 16 18 20]
Is = {List.number 0 9 1}
fun {GetPC I Offset}
   {Nth PCs (I+Offset) mod 10 + 1}
end
MyScore = {Score.makeScore sim(items:[seq(items:{Map Is 
						fun {$ I}
						   note(duration:4
							pitchClass:{GetPC I 0}
							octave:4
							pitchUnit:et22
							amplitude:64)
						end})
				      seq(items:{Map Is 
						 fun {$ I}
						    note(duration:4
							 pitchClass:{GetPC I 3}
							 octave:4
							 pitchUnit:et22
							 amplitude:64)
						 end})
				      seq(items:{Map Is 
						 fun {$ I}
						    note(duration:4
							 pitchClass:{GetPC I 6}
							 octave:4
							 pitchUnit:et22
							 amplitude:64)
						 end})
				      seq(items:{Map Is 
						 fun {$ I}
						    note(duration:4
							 pitchClass:{GetPC I 8}
							 octave:4
							 pitchUnit:et22
							 amplitude:64)
						 end})]
			       startTime:0
			       timeUnit:beats(4))
	   add(note:HS.score.note)}
{MyScore wait}
{Init.setTempo 60.0}
{Out.midi.renderAndPlayMidiFile MyScore
 unit(file:chordSeq_22ET
      clauses:[isNote
	       #fun {$ N}	% round-robin MIDI channel assignment
		   Chan = {NextChan}
		in
		   {Out.midi.noteToPitchbend N unit(channel:Chan)}
		   | {Out.midi.noteToMidi N unit(channel:Chan)}
		end])}
%% For confirmation: show chord seq with Lilypond
{ET22.out.renderAndShowLilypond MyScore
 unit(file:chordsSeq_22ET)}

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Microtonal output: polyphonic case with one monophonic voice per
%% MIDI channel. Make sure that your MIDI instrument has the same
%% sound settings for the channels 0-3 and that the a pitchbend
%% resolution set to the standard +/- 2 semitones.
%%
%% Note that this example does not depend on the contribution
%% HS. Instead, the pitch is set directly (no pitch class parameter).
%%
%% The example plays a sequence of chords in Erlich's 'standard
%% pentachordal major'.
%%

/*

declare
[ET22] = {ModuleLink ['x-ozlib://anders/strasheela/ET22/ET22.ozf']}
{HS.db.setDB ET22.db.fullDB}
%%
%% pitch classes of Erlich's 'standard pentachordal major'
PCs = [0 2 4 7 9 11 13 16 18 20]
Is = {List.number 0 9 1}
fun {GetPC I Offset}
   {Nth PCs (I+Offset) mod 10 + 1}
end
PitchOffset = 22 * 5
MyScore = {Score.makeScore sim(items:[seq(items:{Map Is 
						fun {$ I}
						   note(duration:4
							pitch:{GetPC I 0}+PitchOffset
							pitchUnit:et22
							channel:0
							amplitude:64)
						end})
				      seq(items:{Map Is 
						 fun {$ I}
						    note(duration:4
							 pitch:{GetPC I 3}+PitchOffset
							 pitchUnit:et22
							channel:1
							 amplitude:64)
						 end})
				      seq(items:{Map Is 
						 fun {$ I}
						    note(duration:4
							 pitch:{GetPC I 6}+PitchOffset
							 pitchUnit:et22
							 channel:2
							 amplitude:64)
						 end})
				      seq(items:{Map Is 
						 fun {$ I}
						    note(duration:4
							 pitch:{GetPC I 8}+PitchOffset
							 pitchUnit:et22
							 channel:3
							 amplitude:64)
						 end})]
			       startTime:0
			       timeUnit:beats(4))
	   add(note:Out.midi.midiNote)}
{MyScore wait}
{Init.setTempo 60.0}
%% For confirmation: show chord sequence with Lilypond
{ET22.out.renderAndShowLilypond MyScore
 unit(file:chordSeq_22ET)}
%% MIDI 
{Out.midi.renderAndPlayMidiFile MyScore
 unit(file:chordSeq_22ET
      clauses:[isNote
	       #fun {$ N}
		   {Out.midi.noteToPitchbend N unit}
		   | {Out.midi.noteToMidi N unit}
		end])}

*/





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Using a tuning table.   
%%
%% The example plays a plain cadence in Meantone temperament.
%%
%% Keep in mind that for tunings with up to 12 pitches per octave it
%% might be fitting easy to tune your MIDI device instead of the MIDI
%% file, so your MIDI file can use more independent MIDI channels.
%%

/*

declare
%% Set the tuning to Meantone temperament. The table contains pitches specified in cent (floats) and just intonation ratios (specified as pair Num#Denom) 
{Init.setTuningTable unit(76.04900
			  193.15686
			  310.26471
			  5#4
			  503.42157
			  579.47057
			  696.57843
			  25#16
			  889.73529
			  1006.84314
			  1082.89214
			  2#1)}
%% create a cadence (12 pitches per octave)
MyScore = {Score.makeScore seq(items:[sim(items:[note(duration:2
						     pitch:67
						     amplitude:64)
						note(duration:2
						     pitch:64
						     amplitude:64)
						note(duration:2
						     pitch:60
						     amplitude:64)])
				    sim(items:[note(duration:2
						     pitch:65
						     amplitude:64)
						note(duration:2
						     pitch:60
						     amplitude:64)
						note(duration:2
						     pitch:56
						     amplitude:64)])
				    sim(items:[note(duration:2
						     pitch:65
						     amplitude:64)
						note(duration:2
						     pitch:62
						     amplitude:64)
						note(duration:2
						     pitch:59
						     amplitude:64)
						note(duration:2
						     pitch:55
						     amplitude:64)])
				      sim(items:[note(duration:2
						     pitch:64
						     amplitude:64)
						note(duration:2
						     pitch:60
						     amplitude:64)
						note(duration:2
						     pitch:55
						     amplitude:64)
						note(duration:2
						     pitch:48
						     amplitude:64)])]
			      startTime:0
			      timeUnit:beats)
	   unit}
{MyScore wait}
{Init.setTempo 50.0}
%% play cadence
{Out.midi.renderAndPlayMidiFile MyScore
 unit(file:cadenceMeantone
      clauses:[isNote
	       #fun {$ N}	% round-robin MIDI channel assignment
		   Chan = {NextChan}
		in
		   {Out.midi.noteToPitchbend N unit(channel:Chan)}
		   | {Out.midi.noteToMidi N unit(channel:Chan)}
		end])}



%% Double-checking ;-) 
%% Set the tuning back to the default equal temperament and play the cadence again
{Init.unsetTuningTable}
%% 
{Init.setTempo 50.0}
{Out.midi.renderAndPlayMidiFile MyScore
 unit(file:cadence12ET
      clauses:[isNote
	       #fun {$ N}	% round-robin MIDI channel assignment
		   Chan = {NextChan}
		in
		   {Out.midi.noteToPitchbend N unit(channel:Chan)}
		   | {Out.midi.noteToMidi N unit(channel:Chan)}
		end])}




*/





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Play chords of 'standard pentachordal major' with a Pajara temperament
%%




/*

declare
[ET22] = {ModuleLink ['x-ozlib://anders/strasheela/ET22/ET22.ozf']}
{HS.db.setDB ET22.db.fullDB}
%% Pajara TOP tuning
{Init.setTuningTable unit(65.60000
			  106.57000
			  172.17000
			  213.14000
			  278.74000
			  319.71000
			  385.31000
			  426.28000
			  491.88000
			  532.85000
			  598.45000
			  664.05000
			  705.02000
			  770.62000
			  811.59000
			  877.19000
			  918.16000
			  983.76000
			  1024.73000
			  1090.33000
			  1131.30000
			  1196.90000)}
%% 
MyScore = {Score.makeScore seq(items:[sim(items:[note(duration:2
						      pitch:{ET22.pitch 'C'#4}
						      pitchUnit:et22
						      channel:0
						      amplitude:64)
						 note(duration:2
						      pitch:{ET22.pitch 'E\\'#4}
						      pitchUnit:et22
						      channel:1
						      amplitude:64)
						 note(duration:2
						      pitch:{ET22.pitch 'G'#4}
						      pitchUnit:et22
						      channel:2
						      amplitude:64)
						 note(duration:2
						      pitch:{ET22.pitch 'Bb'#4}
						      pitchUnit:et22
						      channel:3
						      amplitude:64)])
				      sim(items:[note(duration:2
						      pitch:{ET22.pitch 'F'#4}
						      pitchUnit:et22
						      channel:0
						      amplitude:64)
						note(duration:2
						     pitch:{ET22.pitch 'Ab/'#3}
						      pitchUnit:et22
						      channel:0
						     amplitude:64)
						note(duration:2
						     pitch:{ET22.pitch 'C'#4}
						      pitchUnit:et22
						      channel:0
						     amplitude:64)
						note(duration:2
						     pitch:{ET22.pitch 'D'#4}
						      pitchUnit:et22
						      channel:0
						     amplitude:64)])
				      sim(items:[note(duration:2
						      pitch:{ET22.pitch 'G'#3}
						      pitchUnit:et22
						      channel:0
						      amplitude:64)
						note(duration:2
						     pitch:{ET22.pitch 'B\\'#3}
						      pitchUnit:et22
						      channel:0
						     amplitude:64)
						note(duration:2
						     pitch:{ET22.pitch 'D'#4}
						      pitchUnit:et22
						      channel:0
						     amplitude:64)
						note(duration:2
						     pitch:{ET22.pitch 'F'#4}
						      pitchUnit:et22
						      channel:0
						     amplitude:64)])
				      sim(items:[note(duration:2
						      pitch:{ET22.pitch 'C'#3}
						      pitchUnit:et22
						      channel:0
						      amplitude:64)
						 note(duration:2
						      pitch:{ET22.pitch 'E\\'#4}
						      pitchUnit:et22
						      channel:1
						      amplitude:64)
						 note(duration:2
						      pitch:{ET22.pitch 'G'#3}
						      pitchUnit:et22
						      channel:2
						      amplitude:64)
						 note(duration:2
						      pitch:{ET22.pitch 'Bb'#3}
						      pitchUnit:et22
						      channel:3
						      amplitude:64)])]
			       startTime:0
			       timeUnit:beats)
	   add(note:Out.midi.midiNote)}
{MyScore wait}
%% For confirmation: show chord sequence with Lilypond (enharmonically not correct..)
{ET22.out.renderAndShowLilypond MyScore
 unit(file:chordSeq_22ET)}
%%
{Init.setTempo 60.0}
{Out.midi.renderAndPlayMidiFile MyScore
 unit(file:chords_Pajara
      clauses:[isNote
	       #fun {$ N}
		   {Out.midi.noteToPitchbend N unit}
		   | {Out.midi.noteToMidi N unit}
		end])}


%% Comparison: play in 22-ET

{Init.unsetTuningTable}
{Out.midi.renderAndPlayMidiFile MyScore
 unit(file:chords_22ET
      clauses:[isNote
	       #fun {$ N}
		   {Out.midi.noteToPitchbend N unit}
		   | {Out.midi.noteToMidi N unit}
		end])}

*/



