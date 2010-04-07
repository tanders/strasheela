
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% ** HOW TO USE THIS EXAMPLE? **
%%
%% First feed the whole buffer. Then feed the individual examples
%% (wrapped in a block comment to prevent unintended feeding).
%%


%%
%% Examples that use heuristic constraints
%%

%%
%% For further information see the documentation of Score.apply_H.
%%



declare

[H] = {ModuleLink ['x-ozlib://anders/strasheela/Heuristics/Heuristics.ozf']}
[Fenv] = {ModuleLink ['x-ozlib://anders/strasheela/Fenv/Fenv.ozf']}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Heuristic constraint definition example
%%
%% For further examples see the functor strasheela/contributions/anders/Heuristics/Heuristics.oz
%%

/* %% [Heuristic constraint] X should be smaller than Y (the interval size has no influence). 
%% */
fun {Less_H X Y}
   if Y - X < 0
   then 100
   else 0
   end
end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Example 1: demonstrates how heuristic constraints (e.g., Less_H defined above) and strict constraints can be combined. In this case, an optimal solution is found, because the heuristic and strict constraints do not contradict each other. Nevertheless, multiple searches result in different solutions as the search process in randomised.
%%

/* 

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {Score.make
	       seq({LUtils.collectN 7
		    fun {$} note(pitch: {FD.int 36#84}
				 duration: 2) end}
		   startTime: 0
		   timeUnit: beats)
	       unit}
    %% hard constraint: max interval is major second
    {Pattern.for2Neighbours {MyScore map($ getPitch test:isNote)}
     proc {$ P1 P2}
	{FD.distance P1 P2 '=<:' 2}
     end}
    %% heuristic constraint application: pitches are descending
    {Pattern.for2Neighbours {MyScore map($ getPitchParameter test:isNote)}
     proc {$ PP1 PP2}
	{Score.apply_H Less_H [PP1 PP2] 1}
     end}
 end
 unit(value: heuristic)}


*/




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Example 2: multiple heuristic constraints are applied. Also, the use of a heuristic pattern constraint (H.cycle) is shown.
%%

/* 

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    PPs
 in
    MyScore = {Score.make
	       seq({LUtils.collectN 12
		    fun {$} note(pitch: {FD.int 36#84}
				 duration: 2) end}
		   startTime: 0
		   timeUnit: beats)
	       unit}
    PPs = {MyScore map($ getPitchParameter test:isNote)}
    %%
    %% Strict constraint
    %%
    {FD.distinct {MyScore map($ getPitch test:isNote)}}
    %%
    %% Heuristic constraint application
    %%
    %% Heuristic cycle pattern constraint (cycle length 4)
    {H.cycle PPs 4 1} 
    %% Heuristic domain restriction
    {ForAll PPs
     proc {$ Param}
	DomH = [60 62 64 65 67 69 71 72]
     in
	{Score.apply_H fun {$ X} {H.memberContinuous X DomH} end [Param]
	 1}
     end}
 end
 unit(value: heuristic)}

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Example 3: a different combination of heuristic pattern constraints, this time the result "follows" and envelope (a fenv). 
%%

/* 

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    PPs
 in
    MyScore = {Score.make
	       seq({LUtils.collectN 12
		    fun {$} note(pitch: {FD.int 36#84}
				 duration: 2) end}
		   startTime: 0
		   timeUnit: beats)
	       unit}
    PPs = {MyScore map($ getPitchParameter test:isNote)}
    %%
    %% Heuristic constraint application
    %%
    %% Heuristic pattern constraint: "follow" given fenv 
    {H.followFenv PPs {Fenv.linearFenv [[0.0 57.0] [0.75 72.0] [1.0 60.0]]}
     1}
    %% Heuristic cycle pattern constraint (cycle length 4)
    {H.cycle PPs 4 1} 
 end
 unit(value: heuristic)}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Example 4: shows how heuristic constraint combinators (e.g., H.nega) are used.
%%

/* 

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    PPs
 in
    MyScore = {Score.make
	       seq({LUtils.collectN 12
		    fun {$} note(pitch: {FD.int 36#84}
				 duration: 2) end}
		   startTime: 0
		   timeUnit: beats)
	       unit}
    PPs = {MyScore map($ getPitchParameter test:isNote)}
    %%
    %%
    %% Pitches should not be repeated (negation of equality) 
    {Pattern.for2Neighbours PPs
     proc {$ PP1 PP2}
	{Score.apply_H fun {$ P1 P2} {H.nega {H.equal P1 P2}} end
	 [PP1 PP2] 1}
     end}
 end
 unit(value: heuristic)}

*/