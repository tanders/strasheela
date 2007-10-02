

declare
[Memo] = {ModuleLink ['x-ozlib://anders/strasheela/Memoize/Memoize.ozf']}


%%
%% General test
%%


{Memo.setGetID fun {$ X} X end}

declare
%% dumy test: memoized version always returns the same result with the same args
fun {MyRand Xs}
   {OS.rand}
end


declare
MyRandM = {Memo.memoize MyRand}

{MyRandM [100 100]}

{MyRandM [100 100]}

{MyRandM [100 101]}


{Memo.clearAll}

{MyRandM [100 100]}



%%
%% Test with my score data structure
%%

{Memo.setGetID fun {$ X} {X getID($)} end}

{Memo.setMinID 1000}

declare
proc {GetInterval [Note1 Note2] Interval}
   Interval :: 0#FD.sup
   {FD.distance {Note1 getPitch($)} {Note2 getPitch($)} '=:' Interval}
end
Note1 = {Score.makeScore note unit}
Note2 = {Score.makeScore note unit}
GetIntervalM = {Memo.memoize GetInterval}

%% return some FD int
{Browse {GetIntervalM [Note1 Note2]}}

%% determine the FD int returned before (see Browser)
{GetIntervalM [Note1 Note2]} = 3

{GetIntervalC}

{Memo.clearAll}

%% at least what was specified by Memo.setMinID
{Note1 getID($)}




