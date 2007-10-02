
%%
%% TODO
%%
%%

declare

[RT] = {ModuleLink ['x-ozlib://anders/strasheela/Realtime/Realtime.ozf']}


%%  A simple extended script (e.g., the script supports additional arguments besides the score as root variable). Moreover, for all arguments, defaults are defined.
%% A sequential container with Args.n notes, each note with the pitch domain Args.pitchDomain, where the interval between the max and min pitch is Args.range. Also, the first and last seq note are neither max nor min pitch.
proc {TestExtendedScript MyScore Args}
   Defaults = unit(n:11
		   pitchDomain:55#79
		   range:11)
   As = {Adjoin Defaults Args}
   Pitches = {FD.list As.n As.pitchDomain}
   MaxPitch = {Pattern.max Pitches}
   MinPitch = {Pattern.min Pitches}
in
   %% create score: NoteNo notes in sequence 
   MyScore = {Score.makeScore 
	      seq(items:{Map Pitches
			 fun {$ Pitch}
			    note(duration:2
				 pitch:Pitch
				 amplitude:64)
			 end}
		  startTime:0
		  timeUnit:beats(4))
	      unit}
   %% Interval between max and min pitch is major seventh
   {FD.distance MaxPitch MinPitch '=:' As.range}
%    %% Melodic intervals are minor/major second, minor/major third, or tritone
%    for Pitch1 in Pitches
%       Pitch2 in Pitches.2
%    do       
%       Interval = {FD.int [1 2 3 4 6]}
%    in
%       {FD.distance Pitch1 Pitch2 '=:' Interval}
%    end
   %% neither the first nor the last pitch are the max or min
   Pitches.1 \=: MaxPitch
   Pitches.1 \=: MinPitch
   {List.last Pitches} \=: MaxPitch
   {List.last Pitches} \=: MinPitch
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% ExtendedScriptToScript
%%

/*
%% a simple CSP solving an extended script (i.e., a script with additional args), which makes use of ExtendedScriptToScript

declare
ScriptArgs = unit(n:5
		  pitchDomain:48#60
		  range:10)
MyScript = {SDistro.makeSearchScript
	    {RT.extendedScriptToScript TestExtendedScript ScriptArgs}
	    unit}

declare
%% singleton list or nil 
SolScores = {Search.base.one MyScript}
{Browse {SolScores.1 toInitRecord($)}}

{Explorer.one MyScript}


*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% SearchWithTimeout
%%

/*

%% finding a solution within 100 msecs
declare
proc {MyScript Xs}
   Xs = {FD.list 3 60#72}
   {FD.distinct Xs}
   {FD.distribute ff Xs}
end
{Browse {RT.searchWithTimeout MyScript
	 unit(maxSearchTime:100)}}


%% timeout: 1 msec search time is usually not enough (sometimes it works..)
%% default solution returned, and message printed at stdout. 
%% NB: Oz scheduling probably not to 1 msec exact anyway, max precision 10 msecs??
declare
proc {MyScript Xs}
   Xs = {FD.list 3 60#72}
   {FD.distinct Xs}
   {FD.distribute ff Xs}
end
SolScore = {RT.searchWithTimeout MyScript
	    unit(maxSearchTime:1
		 defaultSolution:nil)}
{Browse SolScore}


%% script failure. defaultSolution returned and message printed at stdout.
declare
proc {MyScript Xs}
   Xs = {FD.list 3 1#10}
   %% contradiction
   {FD.distinct Xs}
   {Nth Xs 1} = {Nth Xs 3}
   %%
   {FD.distribute ff Xs}
end
SolScore = {RT.searchWithTimeout MyScript
	    unit(defaultSolution:failure
		 comment:'script with contradiction')}
{Browse SolScore}



%% constraining a score..
declare
MyScript = {SDistro.makeSearchScript {RT.extendedScriptToScript TestExtendedScript
				      unit(n:5
					   range:10)}
	    unit}
{Browse {{RT.searchWithTimeout MyScript unit(maxSearchTime:20
					     %% empty sim
					     defaultSolution:{Score.makeScore sim unit})}
	 toInitRecord($)}}



%% def own solver with KillP (simply depth first exploration)
%% based on defs in MOZART/share/lib/cp/Search.oz
declare
fun {DepthFirstExploration MyScript ?KillP}
   KillFlag
   MySpace={Space.new MyScript}
   %% very similar to DFE on cover of Programming Constraint Services
   fun {DFE S}		
      if {IsFree KillFlag} then	% only continue search if KillFlag is free
	 case {Space.ask S}
	 of failed then nil
	 [] succeeded then S
	 [] alternatives(N) then C={Space.clone S} in
	    {Space.commit1 S 1}
	    case {DFE S}
	    of nil then {Space.commit2 C 2 N} {DFE C}
	    elseof O then O
	    end
	 end
      else nil
      end
   end
in
   proc {KillP} KillFlag=unit end
   case {DFE MySpace}
   of nil then nil
   elseof S then [{Space.merge S}]
   end
end
proc {MyScript Xs}
   Xs = {FD.list 3 60#72}
   {FD.distinct Xs}
   {FD.distribute ff Xs}
end
{Browse {RT.searchWithTimeout MyScript
	 unit(maxSearchTime:100 	% change to 1..
	      defaultSolution:nix
	      solver:DepthFirstExploration)}}


*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% ScoreSearcherWithTimeout 
%%

/*


%% extended script (additional arg n, without default) and 100 msecs max search time 
declare
proc {MyScript MyScore Args}
   Pitches = {FD.list Args.n 60#72}
in
   MyScore = {Score.makeScore 
	      seq(items:{Map Pitches
			 fun {$ Pitch}
			    note(duration:2
				 pitch:Pitch
				 amplitude:64)
			 end}
		  startTime:0
		  timeUnit:beats(4))
	      unit}
   {FD.distinct Pitches}
end
MySearcher = {New RT.scoreSearcherWithTimeout
	      init(MyScript
		   n:5		% script arg: number of notes
		   maxSearchTime:100
		   distroArgs:unit(value:random))}

{Browse {{MySearcher next($)} toInitRecord($)}}


%%%%%%%%%%%%%%%%

%% again, find a solution in max 100 msecs (it takes about 20 msecs!)
declare
MySearcher = {New RT.scoreSearcherWithTimeout
	      init(TestExtendedScript
		   n:5		% TestExtendedScript arg
		   distroArgs:unit(value:random))}

{Inspect {{MySearcher next($ maxSearchTime: 100)} toInitRecord($)}}


%%%%%%%%%%%%%%%%

%% script failure: returns nil and message printed at stout
declare
proc {MyScript MyScore _ /* ignored args */}
   Pitches = {FD.list 3 60#72}
in
   MyScore = {Score.makeScore 
	      seq(items:{Map Pitches
			 fun {$ Pitch}
			    note(duration:2
				 pitch:Pitch
				 amplitude:64)
			 end}
		  startTime:0
		  timeUnit:beats(4))
	      unit}
   %% contradiction
   {FD.distinct Pitches}
   {Nth Pitches 1} = {Nth Pitches 3}
end
MySearcher = {New RT.scoreSearcherWithTimeout
	      init(MyScript)}
{Browse {MySearcher next($)}}


%%%%%%%%%%%%%%%%

%% timeout: 1 msec search time is usually not enough (sometimes it works..)
%% NB: Oz scheduling probably not to 1 msec exact anyway, max precision 10 msecs??
declare
proc {MyScript MyScore _ /* ignored args */}
   Pitches = {FD.list 3 60#72}
in
   MyScore = {Score.makeScore 
	      seq(items:{Map Pitches
			 fun {$ Pitch}
			    note(duration:2
				 pitch:Pitch
				 amplitude:64)
			 end}
		  startTime:0
		  timeUnit:beats(4))
	      unit}
end
MySearcher = {New RT.scoreSearcherWithTimeout
	      init(MyScript
		  maxSearchTime:1)}
{Browse {MySearcher next($)}}

%%%%%%%%%%%%%%%%

%% constrain output with respect to previous output
%% Script outputs note seq with increasing pitches, where the interval between the first pitch of the new and the previous output is a minor or a major second
declare
proc {MyScript MyScore Args}
   N = Args.n
   Predecessor = Args.outputScores.1
   PredecessorPitch1 = {{Predecessor getItems($)}.1 getPitch($)}
   PitchDomain = Args.pitchDomain
   Pitches = {FD.list N PitchDomain}
in
   MyScore = {Score.makeScore 
	      seq(items:{Map Pitches
			 fun {$ Pitch}
			    note(duration:2
				 pitch:Pitch
				 amplitude:64)
			 end}
		  startTime:0
		  timeUnit:beats(4))
	      unit}
   {Pattern.increasing Pitches}
   Pitches.1 \=: PredecessorPitch1
   {FD.distance Pitches.1 PredecessorPitch1 '<:' 3}
end
MySearcher = {New RT.scoreSearcherWithTimeout
	      init(MyScript
		   n:5		% script arg: number of notes
		   pitchDomain: 48#72
		   maxSearchTime:100
		   %% init outputScores, so there is always a Predecessor
		   outputScores:[{Score.makeScore 
				  seq(items:[note(duration:2
						  pitch:60
						  amplitude:64)]
				      startTime:0
				      timeUnit:beats(4))
				  unit}]
		   distroArgs:unit(value:random))}

%% call several times..
{Browse {{MySearcher next($)} toInitRecord($)}}

%%%%%%%%%%%%%%%%

%% same as before, but this time with scheduler: output simply in Browser for now
%% Every second, the solver is called and has 10 msecs max to output solution (the repeater action proc browses bang when solver is called to show this delay)
declare
proc {MyScript MyScore Args}
   N = Args.n
   Predecessor = Args.outputScores.1
   PredecessorPitch1 = {{Predecessor getItems($)}.1 getPitch($)}
   PitchDomain = Args.pitchDomain
   Pitches = {FD.list N PitchDomain}
in
   MyScore = {Score.makeScore 
	      seq(items:{Map Pitches
			 fun {$ Pitch}
			    note(duration:2
				 pitch:Pitch
				 amplitude:64)
			 end}
		  startTime:0
		  timeUnit:beats(4))
	      unit}
   {Pattern.increasing Pitches}
   Pitches.1 \=: PredecessorPitch1
   {FD.distance Pitches.1 PredecessorPitch1 '<:' 3}
end
MySearcher = {New RT.scoreSearcherWithTimeout
	      init(MyScript
		   n:5		% script arg: number of notes
		   pitchDomain: 48#72
		   maxSearchTime:100
		   %% init outputScores, so there is always a Predecessor
		   outputScores:[{Score.makeScore 
				  seq(items:[note(duration:2
						  pitch:60
						  amplitude:64)]
				      startTime:0
				      timeUnit:beats(4))
				  unit}]
		   distroArgs:unit(value:random))}
%% see http://www.mozart-oz.org/documentation/base/time.html#section.control.time
%% for further options using Time.repeat
MyRepeater = {New Time.repeat
	      setRepAll(action: proc {$}
				   {Browse bang}
				   {Browse {{MySearcher next($)} toInitRecord($)}}
				end
			delay: 1000   % output every second 
			)}

{MyRepeater go}

{MyRepeater stop}

%%%%%%%%%%%%%%%%



%% !! TODO
%%
%% test script timeout with script where the score creation (or something else) before the actual search process takes too long
%%
%%
%% test script with score input (non-realtime first)
%%
%% test script with previous input
%%
%% hand over to script start time (depends on present time?)
%%
%% hand over to script score fragments (e.g., harmonic structure?) 
%%
%% test with realtime output 
%%
%% test script with (realtime) input 
%%
%% do profiling and test whether memory usage increases..
%%
%%

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% OpenSound Control
%%

/*

declare
MySendOSC = {New RT.sendOSC init(port:1234)}


%% !! no reaction at SC, even after I changed Main..
%% .. on the commandline it works..
{MySendOSC send("/test 2.0 3.14159")}


{MySendOSC quit}

*/

/*

%% blocks?
declare
SendOSCPath = "/Users/t/Download/send+dumpOSC-OSX/sendOSC"
Pipe
%% somehow blocks 
thread Pipe = {New Open.pipe init(cmd:SendOSCPath args:['-h' localhost 1234])} end

{System.showInfo {Pipe read(list:$ size:all)}}


{Pipe write(vs:"/test 2.0 3.14159")}


%% do a test with some command expecting input at STDIN: bash
declare
Pipe = {New Open.pipe init(cmd:"sh" args:["-s"])} 
{System.showInfo {Pipe read(list:$ size:all)}}

%% no reaction..
{Pipe write(vs:"ls /Users")}


%% !!?? if I get the shel example running, then I may simply call sendOSC in this shell and send it input via the shell stdin?



%% easy case
declare
Pipe = {New Open.pipe init(cmd:"ls" args:["-l" "/Users"])} 
{System.showInfo {Pipe read(list:$ size:all)}}


%% sending off a single message works fine -- would that be sufficient for my purposes, or should I prefer the interactive mode?
%% seems this 'command-line mode' does not support time tags!
declare
SendOSCPath = "/Users/t/Download/send+dumpOSC-OSX/sendOSC"
Pipe = {New Open.pipe init(cmd:SendOSCPath args:['-h' localhost 1234 "/voices/0/tp/timbre_index,0" "/voices/0/tm/rate,1.0" "/voices/0/tm/goto,0.0"])}
{System.showInfo {Pipe read(list:$ size:all)}}


%% sending off a single message works fine -- would that be sufficient for my purposes, or should I prefer the interactive mode?
%% Did I now include a time tag successfully -- test with SuperCollider?
%% -> there is this special 1 time tag in the top-level bundle..
%% also, dumpOSC seems not to 'evaluate' the Hex code (leading 0x is not removed and not transformed into lower-case digits) 
declare
SendOSCPath = "/Users/t/Download/send+dumpOSC-OSX/sendOSC"
%% !! def in OSC.oz
TimeTag = {VirtualString.toAtom {FormatHex {FormatTimeTag {OS.time}+2}}}
Pipe = {New Open.pipe init(cmd:SendOSCPath args:['-h' localhost 1234 "[ 0x"#TimeTag "/voices/0/tp/timbre_index,0" "/voices/0/tm/rate,1.0" "/voices/0/tm/goto,0.0" "]"])}
{System.showInfo {Pipe read(list:$ size:all)}}



*/





/*==================================================*/ 
%%%
%%% Search Scheduler 
%%%
/*==================================================*/ 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% (1) call scheduler simply by hand in OPI
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% (2) tmp search scheduler: quasi metro
%%

%% van Roy. CTM. p. 311f [pdf file]
fun {NewTicker} 
   fun {Loop} 
      X={OS.localTime} 
   in 
      {Delay 1000} 
      X|{Loop} 
   end 
in 
   thread {Loop} end 
end 


/*
thread for X in {NewTicker} do {Browse X} end end 
*/


/** %% Outputs a stream and every 1/TicksPerMinute minute a new unit is added to the streams tail. TicksPerSecond is a float.
%% */
%% TODO: turn into object, which can be started, stopped, and whose frequency can be changed 
fun {Metro TicksPerMinute}
   %% in msecs
   DelayTime = {Float.toInt 1.0 / TicksPerMinute * 60000.0}
   proc {Aux ?Out}
      Out = unit | _
      {Delay DelayTime}
      Out.2 = {Aux}
   end
in
   %% !!! 
   %% for more precise timing in case of many concurrent threads, give thread high priority
   %% another problem is GC: put scheduler in its own site to avoid much active data?
   thread {Aux} end
end

/*
%% testing

{Inspect {Metro 120.0}}

*/

 
/*
%% use repeater class instead of plain Metro
%% see http://www.mozart-oz.org/documentation/base/time.html#section.control.time

declare
MyRepeater = {New Time.repeat
	      setRepAll(action: proc {$} {Inspect bang} end
			%% delayFun yields delay between iterations in msecs
			delayFun: fun {$} {GUtils.random 2000} end 
			number: 100)}

{MyRepeater go}

{MyRepeater stop}

*/


