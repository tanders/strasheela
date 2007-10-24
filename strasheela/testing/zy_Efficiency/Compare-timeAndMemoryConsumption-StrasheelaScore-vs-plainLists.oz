
%%
%% A very simple rhythmical problem is formulated twice, once with with a
%% Strasheela score and once with a plain list representation. The second
%% is much faster (because copying is more cheap??)
%%
%% CSP: two sequences of N notes (start/duration pairs). Both sequences start at the same time. All note start times (except the two first) are different.
%%

%% !! start profiler

declare
fun {MakeVoice N}
   {Score.makeScore2 seq(items: {LUtils.collectN N 
				 fun {$} 
				    note(duration: {FD.int 1#8} 
					 pitch: 60%{FD.int 60#72} 
					 amplitude: 80) 
				 end}
			 info:voice)
    unit}
end
proc {ScriptWithScore MyScore} 
   N = 100
   Voice1 Voice2
in
   Voice1 = {MakeVoice N}
   Voice2 = {MakeVoice N}	     
   MyScore = {Score.makeScore 
	      sim(items: [Voice1 Voice2] 
		  startTime: 0 
		  timeUnit:beats(4)) 
	      unit}
   {FD.distinctB {Append
		  {Voice1 mapItems($ getStartTime)}.2
		  {Voice2 mapItems($ getStartTime)}.2}}
   %% search strategy 
   {FD.distribute 
    {SDistro.makeFDDistribution unit(order:size value:min)}
    {LUtils.accum [{Voice1 mapItems($ getDurationParameter)}
		   {Voice2 mapItems($ getDurationParameter)}
		   {Voice1 mapItems($ getStartTimeParameter)}
		   {Voice2 mapItems($ getStartTimeParameter)}]
     Append}}
end 
fun {SearchScriptWithScore} {Search.base.one ScriptWithScore} end

%% time: 2.89 secs
%% 1#stat(b:0 c:0 depth:1 f:0 s:1 start:201)
%% ScriptWithScore heap: 3757k (two calls)
%% MakeVoice heap: 1870k  (for calls)
{ExploreOne ScriptWithScore}




declare
proc {ConstrainStarts Starts Durs}
   for
      S1 in {LUtils.butLast Starts}
      S2 in Starts.2
      D1 in {LUtils.butLast Durs}
   do
      S1 + D1 =: S2
   end
end
proc {PlainScript Sol}   
   N = 100
   Durs1 = {FD.list N 1#8}
   Durs2 = {FD.list N 1#8}
   Starts1 = {FD.list N 0#FD.sup}
   Starts2 = {FD.list N 0#FD.sup}
in
   Sol = {LUtils.matTrans [Durs1 Starts1]}#{LUtils.matTrans [Durs2 Starts2]}
   Starts1.1 = 0
   Starts2.1 = 0
   {ConstrainStarts Starts1 Durs1}
   {ConstrainStarts Starts2 Durs2}
   {FD.distinctB {Append Starts1.2 Starts2.2}}
   %% search strategy
   {FD.distribute ff
    {LUtils.accum [Durs1 Durs2 Starts1 Starts2] Append}}
end
fun {SearchPlainScript} {Search.base.one PlainScript} end

%% time: 500ms
%% 1#stat(b:0 c:0 depth:1 f:0 s:1 start:201)
%% PlainScript heap: 66k (2 calls)
%% ConstrainStarts heap: 6560b (4 calls)
{ExploreOne PlainScript}



