
%%
%% This is a toy example demonstrating realtime search with realtime output.
%%
%% USAGE: first start SuperCollider and evaluate the code in
%% Simple-RealTimeOut.sc. Then, feed this buffer (C-. C-b). Finally,
%% go to the section labelled "Solver calls" and feed one example or
%% another.
%%
%% An Oz scheduler (using Time.repeat) starts some search in regular
%% time intervals. The search script is started and after finishing
%% the output is send to SuperCollider. The search script computes an
%% all-interval series of N notes. The output consists of events of
%% OSC messages representing notes in the following format:
%%
%% Oz syntax:
%%
%%   [StartTime '\note'(Duration Pitch Amplitude)]
%%
%% SuperCollider Syntax TODO: fix this syntax
%%
%%   [startTime ['\note', duration, pitch, amplitude]]
%%
%% StartTime is a UNIX time in msecs, duration is measured in msecs as
%% well (both are ints), Pitch is a Midi notes (an integer or float),
%% and Amplitude is a float in the interval [0,1].
%%
%% TODO: [correct] Please note that this example does not make use of Strasheela's
%% music representation. Instead, the OSC music representation
%% documented in the functor OSC is used.
%%

%%
%% NOTE: for randomized distribution, I have to generate score...
%%

declare

[OSC RT] = {ModuleLink ['x-ozlib://anders/strasheela/OSC/OSC.ozf'
			'x-ozlib://anders/strasheela/Realtime/Realtime.ozf']}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Solver calls
%%


/*

%%
%% using OSC music representation directly (in this specific case,
%% always the same solution is output, because the constraints
%% distribution is not randomized).
%%
%% USAGE: See above for initialisation. Then feed the paragraph after
%% declare. Finally, start the process (see below).
%%

declare
%% parameters shared by all notes
NoteDur = 1000			% in msecs
NoteAmp = 0.9
%% length of all-interval series
N = 12
MaxSearchTime = 50		% in msecs
/** %% Top-level definition of a single search pass/run and sound output. This procedure is called repeatedly by MyScheduler.
%% */
proc {CallSolverAndOutputNotes}
   {OutputOSC {RT.searchWithTimeout MyScript
	       unit(maxSearchTime:MaxSearchTime
		    defaultSolution:nil)}}
end
/** %% Defines the CSP.
%% */
proc {MyScript Xs}
   %% NB: the distribution strategy is defined in AllIntervalSeries
   {AllIntervalSeries N _/*Intervals*/ Xs}
   %% Search strategy
   {FD.distribute ff Xs}
end
/** %% Expects a list of pitch classes, transforms them into OSC notes, and outputs these notes as OSC bundles with a timestamp.
%% */
%% NOTE: add latency to StartTime for accurateness
proc {OutputOSC PCs}
   %%
   %% NB: computing Now multiple time creates a precisision risk. Alternative would be to have a single startTime 0 which is {OSC.timeNow}, and everything is is computed with offsets
   Now = {OSC.timeNow}
in
   {List.forAllInd PCs
    proc {$ I PC}
       %% all notes have the same duration (see above). the first note starts Now,
       %% the following exactly after their predecessor stopped
       StartTime = (I-1) * NoteDur + Now 
       Pitch = 60 + PC
    in
       {MySendOSC send([StartTime '/note'(NoteDur Pitch NoteAmp)])}
       %% debugging: also browse
       {Browse send([StartTime '/note'(NoteDur Pitch NoteAmp)])}
    end}
end
%% start OSC communication
OutPort = 57120   % SuperCollider port
MySendOSC = {New OSC.sendOSC init(port:OutPort)}
%% Instantiate a scheduler which will call the top-level definition repeatedly
%% see http://www.mozart-oz.org/documentation/base/time.html#section.control.time
MyScheduler = {New Time.repeat
	       setRepAll(action: CallSolverAndOutputNotes
			 %% always leave time for all notes plus a gap of NoteDur
			 delay: (N+1) * NoteDur % in msecs
			 %% delayFun yields delay between iterations in msecs
			 % delayFun: fun {$} 1000 end 
			 % number: 100
			)}


%% start realtime constraint programming process
{MyScheduler go}

%% stop search process 
{MyScheduler stop}

%% stop OSC
{MySendOSC close}

*/


/*

%%
%% using Strasheela music representation: more convenient for complex
%% CSPs, but less efficient due to larger memory footprint in
%% computation spaces, and added conversions
%%

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Shared Definitions
%%

%% The following two procs are copied from the example
%% 01-AllIntervalSeries.oz
%%
%% Constraints Interval to be an inversional equivalent interval
%% between the two pitch classes Pitch1 and Pitch2 (i.e. a fifth
%% upwards and a fourth downwards count as the same interval).
proc {InversionalEquivalentInterval Pitch1 Pitch2 L Interval}
   Aux = {FD.decl}
in
   %% add 12, because the FD int Aux must be positive
   Aux =: Pitch2-Pitch1+L
   {FD.modI Aux L Interval}
end
%% Returns an all-interval series. Xs is the solution, a list of pitch
%% classes (list of FD ints) and Dxs is the list of inversional
%% equivalent intervals between them (list of FD
%% ints). AllIntervalSeries expects L (an integer specifying the
%% length of the series).
proc {AllIntervalSeries L ?Dxs ?Xs}
   Xs = {FD.list L 0#L-1} % Xs is list of L FD ints in {0, ..., L-1}
   Dxs = {FD.list L-1 1#L-1}
   %% Loop constraints intervals
   for I in 1..L-1
   do
       X1 = {Nth Xs I}
       X2 = {Nth Xs I+1}
       Dx = {Nth Dxs I}
    in
      {InversionalEquivalentInterval X1 X2 L Dx}
   end 
   {FD.distinctD Xs}		% no PC repetition
   {FD.distinctD Dxs}	% no interval repetition
   %% add knowledge from the literature: first series note is 0 and last is L/2
   Xs.1 = 0
   {List.last Xs} = L div 2
end

%% Expects a list of pitches and returns a score (a sequence of notes with these pitches).
fun {MakeSeriesScore Pitches}
   {Score.makeScore seq(items:{Map Pitches fun {$ MyPitch}
					      note(pitch:MyPitch
						   duration:1
						   amplitude:64)
					   end}
			startTime:0
			timeUnit:beats)
    unit(seq:Score.sequential
	 note:Score.note)}
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Tests:
%%

/*

%% Result just a list 
%% finding a solution within 100 msecs 
declare
proc {MyScript Xs}
   %% NB: the distribution strategy is defined in AllIntervalSeries
   {AllIntervalSeries 12 _/*Intervals*/ Xs}
   %% Search strategy
   {FD.distribute ff Xs}
end

{Browse {RT.searchWithTimeout MyScript
	 unit(maxSearchTime:100
	      defaultSolution:nil)}}


%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Result is a score, created inside script. This allows for random
%% distribution.
declare
proc {MyScript _ /* Args */ MyScore}
   PitchClasses in
   {AllIntervalSeries 12 _ /* Intervals */ PitchClasses}
   MyScore = {MakeSeriesScore {Map PitchClasses
			       proc {$ PC Pitch}
				  Pitch = {FD.decl}
				  Pitch =: PC + 60
			       end}}
end
MySearcher = {New RT.scoreSearcherWithTimeout
	      init(MyScript
		   maxSearchTime:50
		   defaultSolution:{MakeSeriesScore nil}
		   distroArgs:unit(value:random))}


%% !!?? blocks? {MySearcher next($)} returns _ ...
{Browse {{MySearcher next($)} toInitRecord($)}}


*/ 





