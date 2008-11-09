
%%
%% This example implements a simple realtime counterpoint CSP.
%%
%% USAGE: Open corresponding Max patch. Then, start Oz and feed
%% Strasheela code in this file: feed the buffer (C-. C-b). The Max
%% patch expects MIDI input (e.g., from a keyboard) and sends MIDI
%% output. Please set the ports for the MIDI in and out as required in
%% the Max patch using the provided menus. Note that the two voices
%% are out at different MII channels (chan 1 and 2), so you can use
%% different sound settings.
%%
%% The CSP expects realtime input of a monophonic voice. This voice is
%% considered the cantus firmus, and the CSP adds a second voice to
%% it. The CSP quasi implements first species counterpoint: the new
%% second voice is homophonic to the first voice. However, this first
%% voice is free rhythmically.
%%
%% Note that notes will hang if you play more than one input note at a
%% time (also if you play legato with overlapping notes).
%%
%% Rules implemented:
%%
%% - Harmonic rule: simultaneous notes must be consonant (perfect or imperfect consonance).
%%
%% - Melodic rule on generated voice: only specific intervals are
%%   allowed, and a larger skip is 'resolved' by a step in the
%%   opposite direction.
%%
%% - The generated melody stays in a specific mode (C major)
%%
%% - Voice-leading rule: no open nor hidden parallels 
%%
%% - ?? In the generated melody, no pitch repetition is allowed within N notes? 
%%

%% 
%% Strasheela's music representation is not required for this example,
%% using simply the OSC representation (defined/documented in the OSC
%% functor) would be sufficient. Nevertheless, this example does use
%% the Strasheela music representation for two reasons. Firstly, that
%% way Strasheela's score distribution strategies are available which
%% allow for a randomised variable value selection. Secondly, the
%% example demonstrates how the OSC representation is easily
%% transformed into Strasheela music representation and back: the
%% expressive interface of Strasheela's music representation will come
%% in handy for more complex CSPs.
%%

%%
%% Possible improvement:
%%
%% Because this example implements two-voice counterpoint, it expects only monophonic input. Currently, it can happen that when multiple voices are input then some notes are cut off before time. Currently, the cell CurrentPitches2 stores all currently playing pitches, and when a note off is input, then all notes are turned off. 
%% A more stable version would result if the internal data representation is slightly changed. This extended data representation would store the currently sounding notes are pairs P1#P2 where P1 and P2 are two pitches. In case of a polyphonic input, multiple such pairs are stored in the list CurrentPitches2 (instead of a plain list of pitches). When a note off occurs, then the matching pair is searched for and only these two notes are turned off, while other notes continue playing.
%%

declare

[OSC RT] = {ModuleLink ['x-ozlib://anders/strasheela/OSC/OSC.ozf'
			'x-ozlib://anders/strasheela/Realtime/Realtime.ozf']}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% OSC interface
%%

OutPort = 8888			% to Max, port set in [udpreceive]
InPort = 7777
MySendOSC = {New OSC.sendOSC init(port:OutPort)}
MyDumpOSC = {New OSC.dumpOSC init(port:InPort)}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Solver calls
%%

MaxSearchTime = 20		% in msecs


%% OSC responder definition, in a sense the top-level definition (defines what to do when receiving events from Max)
local
   %% List of notes started but not stopped yet, required for generating note offs
   %% TODO: use a lock, so only one event is accessing at a time 
   CurrentPitches2 = {NewCell nil}
in
   %% Msg send in Max' vst~ MIDI event format: ["midievent" Statusbyte Databyte1 OptionalDatabyte2]
   %% Example: noteon and noteoff on chan 1 is Statusbyte 144, so a middle C on chan 1 with velo 90 is ["midievent" 144 60 90]
   %%
   %% In this example I only receive MIDI notes on chan 1 (but I send on chans 1 and 2)
   {MyDumpOSC
    setResponder('/event'
		 proc {$ Start '/event'(_ _ Pitch1 Velo1)}
		    Chan1 = 0
		    Chan2 = 1
		 in
		    %% debugging
		    {Browse event(p:Pitch1 v:Velo1)}
		    case Velo1 of 0 then
		       %% noteoff case: output received noteoff and
		       %% noteoff of CurrentPitch2
		       {MySendOSC send({MakeOSCNote
					{Score.makeScore note(startTime:0
							      duration:1
							      pitch:Pitch1
							      amplitude:Velo1
							      timeUnit:msecs)
					 unit}
					Chan1})}
		       {ForAll {Cell.exchange CurrentPitches2 $ nil}
			proc {$ CurrentPitch2}
			   {MySendOSC send({MakeOSCNote
					    {Score.makeScore note(startTime:0
								  duration:1
								  pitch:CurrentPitch2
								  amplitude:Velo1
								  timeUnit:msecs)
					     unit}
					    Chan2})}
			end}
		    else
		       %% noteon case: compute 2nd note, output both notes
		       Note1 = {Score.makeScore note(startTime:0
						     duration:1
						     pitch:Pitch1
						     amplitude:Velo1
						     timeUnit:msecs)
				unit}
		       %% call solver
		       Note2 = {MySearcher next($ inputScore:Note1)}
		    in
		       if Note2 \= nil
		       then
			  %% remember note
			  CurrentPitches2 := {Note2 getPitch($)} | @CurrentPitches2
			  %% play received note
			  {MySendOSC send({MakeOSCNote Note1 Chan1})}
			  %% play newly generated note
			  {MySendOSC send({MakeOSCNote Note2 Chan2})}
		       else
			  %% No solution
			  {Browse 'no solution found'}
		       end
		    end
		 end)}
end


%% search object
MySearcher = {New RT.scoreSearcherWithTimeout
	      init(MyScript
		   maxSearchTime:MaxSearchTime
		   defaultSolution:nil 
		   distroArgs:unit(value:random)
		   outputScores:[nil]
%		   %% only pitch of first note is relevant
%		   outputScores:[{Score.makeScore note(pitch:60) unit}
%				 {Score.makeScore note(pitch:60) unit}]
		   %% if RestrictMelodicIntervals processes two notes
		   % outputLength:2
		  )}


%% extended script for score search: top-level of CSP definition
proc {MyScript Args NewNote}
   SimNote = Args.inputScore
   %% NOTE: in case of no solution, the next PrevNote1 is defaultSolution (nil)
   PrevNote1 = Args.outputScores.1 % immediate predecessor of NewNote
%   PrevNote2 = Args.outputScores.2.1
in
   NewNote = {Score.makeScore note(startTime:{SimNote getStartTime($)}
				   duration:{SimNote getDuration($)}
				   pitch:{FD.int 48#72}
				   amplitude:{SimNote getAmplitude($)}
				   timeUnit:msecs)
	      unit}
   %% three simple rules
   {IsDiatonic NewNote}
   {IsConsonance {GetInterval SimNote NewNote}}
   if PrevNote1 \= nil 
   then PrevSimNote1 = Args.inputScores.1 in 
      {RestrictMelodicInterval {GetInterval NewNote PrevNote1}}
      {NoDirectMotionIntoPerfectConsonance PrevNote1#PrevSimNote1 NewNote#SimNote}
   end
%   {RestrictMelodicIntervals NewNote PrevNote1 PrevNote2}
end


%% Transforms Strasheela note object into OSC message at given MIDI channel (zero-based). OSC message format '/event'(StatusByte Pitch Amplitude). StatusByte is MIDI status byte (e.g., 144 is note on on channel 1), Pitch is MIDI key-number, and Amplitude is MIDI velocity. 
NoteStatusByteOffset = 144
fun {MakeOSCNote MyNote Chan}
   '/event'(NoteStatusByteOffset+Chan
	    {MyNote getPitch($)}
	    {MyNote getAmplitude($)})
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Rule Definitions
%%


%% Constrains Interval to the absolute distance between the pitches of
%% Note1 and Note2.
proc {GetInterval Note1 Note2 Interval}
   Interval = {FD.decl}
   {FD.distance {Note1 getPitch($)} {Note2 getPitch($)} '=:' Interval}
end

%% Constrains Interval to a consonance.
proc {IsConsonance Interval}
   %% NOTE: no prime (i.e. Interval \=: 0)
   Interval :: [3 4 7 8 9 12 15 16]
end

%% MyNote constrained to a diatonic pitch (here simply pitches in the
%% C-major scale).
local 
   ScalePCs = [0 2 4 5 7 9 11] % list of pitch classes in c-major scale
in
   proc {IsDiatonic MyNote}
      {FD.modI {MyNote getPitch($)} 12} :: ScalePCs
   end
end

%% Only the specified melodic intervals are allowed
proc {RestrictMelodicInterval Interval}
   Interval :: [1#5 7 12]
end


%% Open and hidden parallels are forbidden: perfect consonances must
%% not be reached by both voices in the same direction. Arguments are two pairs of simultaneous notes
proc {NoDirectMotionIntoPerfectConsonance Note1#SimNote1 Note2#SimNote2}
   %% direction of interval of voice1
   %% NB: Pattern.direction does not propagate well (see doc)
   Dir1 = {Pattern.direction
	   {Note1 getPitch($)} {Note2 getPitch($)}}
   Dir2 = {Pattern.direction
	   {SimNote1 getPitch($)}
	   {SimNote2 getPitch($)}}
in
   {FD.impl
    %% interval between sim successor notes
    {IsPerfectConsonanceR {GetInterval Note2 SimNote2}}
    (Dir1 \=: Dir2)
    1}
end
 
%% Constrains Interval to a perfect consonance.
local
   PerfectConsonance = {FS.value.make [0 7 12]}
in
   proc {IsPerfectConsonanceR Interval B}
      B = {FS.reified.include Interval PerfectConsonance}
   end
end


% %% B=1 if Interval is > 5: an interval larger than a fourth is considered a large skip and requires resolution.
% proc {IsLargeSkip Interval B}
%    B = (Interval >: 5)
% end
% %% B=1 if Interval is either 1 or 2.
% proc {IsStep Interval B}
%    B = {FD.disj (Interval =: 1) (Interval =: 2)}
% end
% %% Note1, Note2, and Note3 are successive melodic notes (reverse
% %% order, Note1 is the latest etc.): only specific intervals are
% %% allowed, and a larger skip is 'resolved' by a step in the opposite
% %% direction.
% %%
% %% NOTE: Note3 is ignored so far...
% proc {RestrictMelodicIntervals Note1 Note2 Note3}
%    Interval1 = {GetInterval Note1 Note2}
%    Interval2 = {GetInterval Note2 Note3}
% in
%    {RestrictMelodicInterval Interval1}
%    {FD.impl {IsLargeSkip Interval}
%     {FD.conj
%      {IsStep Interval}
%      %% opposite direction ...
%     }
%     1}
% end

