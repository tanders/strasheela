
%%
%% This example implements a simple realtime counterpoint CSP.
%%
%% USAGE: First, start Oz and feed Strasheela code in this file: feed the
%% buffer (C-. C-b). Then, evaluate the corresponding
%% SuperCollider code in Simple-Counterpoint.oz (see USAGE there).  
%%
%% The CSP expects realtime input of a monophonic voice. This voice is
%% considered the cantus firmus, and the CSP adds a second voice to
%% it. The CSP quasi implements first species counterpoint: the new
%% second voice is homophonic to the first voice. However, this first
%% voice is free rhythmically.  Alternatively, you may create the
%% realtime input voice by diifferent means (e.g. inputting it by hand
%% via a keyboard).
%%
%% Rules implemented:
%%
%% - Harmonic rule: simultaneous notes must be consonant (perfect or imperfect consonance).
%%
%% - Melodic rule on generated voice: only specific intervals are
%%   allowed, and a larger skip is 'resolved' by a step in the
%%   opposite direction.
%%
%% - ?? The generated melody stays in a specific mode? 
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
%% The SuperCollider side provides for a latency compensation: the
%% latency introduced by Strasheela is added to every note of both
%% voices (the voice input to Strasheela and the newly generated
%% voice), so that the two voices play synchronously.
%%
%% Please note that even though the example is not implemented in a
%% most efficient way (e. g., it uses the more costly Strasheela music
%% representation, and also implementing the CSP purely declaratively
%% and that way creating lots of "garbage" to be collected later), it
%% is efficient enough given a great enough latency (50 msecs were
%% more than sufficient on the testing machine Macbook Pro 2.2 GHz).
%%
%%
%% Oz's CPU and memory usage is low when compared with sclang (both
%% don't do much..). I just watch emulator.exe in the MacOS' Activity
%% Monitor. When inputLength/outputLength are set to low values, the
%% memory consumption remains relatively constant (even if it is
%% falling and raising all the time).  As already mentioned, I create
%% much 'garbage data' in the program, and the garbage collection
%% really gets some work to do.. As the GC increases the heapsize
%% whenever called, the max memory usage increases slowly.
%%
%% NOTE: checking in the Oz panel it turns out the the Active Size
%% (i.e. the heap size after the GC) is > 0 and slowly increasing --
%% is there some memory leak?
%% 
%%
%%

declare

[OSC RT] = {ModuleLink ['x-ozlib://anders/strasheela/OSC/OSC.ozf'
			'x-ozlib://anders/strasheela/Realtime/Realtime.ozf']}


%% The time 'now' in msecs (integer) when buffer is fed is the
%% reference score time 0 (subtracted respectively added to start
%% time, see below)
Now = {OSC.timeNow}		



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% OSC interface
%%

OutPort = 57120			% to SuperCollider
InPort = 7777
MySendOSC = {New OSC.sendOSC init(port:OutPort)}
MyDumpOSC = {New OSC.dumpOSC init(port:InPort)}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Solver calls
%%

%%
%% Using Strasheela music representation. This is not actually required for a simple realtime CSP like this and inefficient. It servers to show by a simple example how it can be done. Moreover, it provides and easy to use randomised ditribution strategy. 
%% 
%%
%% TODO: example with plain OSC representation
%% !!?? Needs variant of RT.scoreSearcherWithTimeout without score.. Or can I use it as-is? 
%%

declare
%%
NoteAmplitude = 64		% MIDI velocity
MaxSearchTime = 10		% in msecs
%% !! extra block for easy redefinition
% declare
%%
%% Transforms an OSC message '\note'(Duration Pitch Amplitude) and its
%% Start time into a Strasheela note object. Start and Duration are
%% integers, measured in msecs. Pitch is MIDI key-number, and
%% Amplitude is MIDI velocity.
%% Start is too large for score, so Now is subtracted.
fun {MakeScoreNote Start '/note'(Duration Pitch Amplitude)}
   {Score.makeScore note(startTime:Start-Now 
			 duration:Duration
			 pitch:Pitch
			 %% NOTE: Amplitude is irrelevant
			 amplitude:Amplitude
			 timeUnit:msecs)
    unit}
end
%% Transforms Strasheela note object into OSC message of format  [Start '\note'(Duration Pitch Amplitude)]. Start is measured in msecs, duration is secs, Pitch is MIDI key-number, and
%% Amplitude is MIDI velocity.
%% Variable Now is added back to note's start time.
fun {MakeOSCNote MyNote}
   [{MyNote getStartTime($)} + Now 
    '/note'({MyNote getDurationInSeconds($)}
	    {MyNote getPitch($)}
	    {MyNote getAmplitude($)})]
end
%%
%% extended script for score search
proc {MyScript NewNote Args}
   SimNote = Args.inputScore
   %% NOTE: in case of no solution, the next PrevNote1 is defaultSolution (nil)
   PrevNote1 = Args.outputScores.1 % immediate predecessor of NewNote
%   PrevNote2 = Args.outputScores.2.1
in
   NewNote = {Score.makeScore note(startTime:{SimNote getStartTime($)}
				   duration:{SimNote getDuration($)}
				   pitch:{FD.int 48#72}
				   amplitude:NoteAmplitude
				   timeUnit:msecs)
	      unit}
   %% three simple rules
   {IsDiatonic NewNote}
   {IsConsonance {GetInterval SimNote NewNote}}
   if PrevNote1 \= nil
   then {RestrictMelodicInterval {GetInterval NewNote PrevNote1}}
   end
%   {RestrictMelodicIntervals NewNote PrevNote1 PrevNote2}
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
%%
%%
{MyDumpOSC setResponder('/note' proc {$ Start Msg}
				   %% degugging
				   %% {Browse input#Start#Msg}
				   %% OSC to Strasheela note
				   SimNote = {MakeScoreNote Start Msg}
				   %% call solver
				   NewNote = {MySearcher next($ inputScore:SimNote)}
				   NewNoteOSC
				in
				   if NewNote \= nil
				   then 
				      %% transformation to OSC
				      NewNoteOSC = {MakeOSCNote NewNote}
				      %% send note on new voice back
				      {MySendOSC send(NewNoteOSC)}
				      %% degugging
				      % {Browse output#NewNoteOSC}
				      %% after every note output call GC manually to keep overall garbage low and make sure GC is not called just when a note is received.
				      %% NB: doing this is probably not a good idea, asany call {System.gcDo} also increases the max heap size
				      % {System.gcDo}
				   else
				      %% No solution
				      {Browse 'no solution found'}
				   end
				end)}



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

