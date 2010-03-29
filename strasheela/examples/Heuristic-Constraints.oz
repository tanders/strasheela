
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Heuristic constraint definition
%%

/* %% [Heuristic constraint] X should be smaller than Y (the interval size has no influence). 
%% */
fun {Less_H X Y}
   if Y - X < 0
   then 100
   else 0
   end
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% 
%%

%%
%% Example 1: demonstrate how heuristic constraint (defined above) and strict constraint can be combined. In this case, an optimal solution is found, because the two constraints do not contradict each other. 
%%

/* 

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




%%
%% Example 2: unfinished
%%

/* 

{SDistro.exploreOne
 proc {$ MyScore}
    PPs
 in
    MyScore = {Score.make
	       seq({LUtils.collectN 7
		    fun {$} note(pitch: {FD.int 36#84}
				 duration: 2) end}
		   startTime: 0
		   timeUnit: beats)
	       unit}
    PPs = {MyScore map($ getPitchParameter test:isNote)}
    %% hard constraint
%     {Pattern.for2Neighbours Ns
%      proc {$ N1 N2}
% 	{FD.distance {N1 getPitch($)} {N2 getPitch($)} '=<:' 2}
%      end}
    %% heuristic constraint application
    {Pattern.for2Neighbours PPs
     proc {$ PP1 PP2}
% 	{Score.apply_H H.less [PP1 PP2] 1}
	{Score.apply_H H.more [PP1 PP2] 1}
	{Score.apply_H H.smallInterval [PP1 PP2] 1}
% 	{Score.apply_H H.largeInterval [PP1 PP2] 1}
% 	{Score.apply_H {H.makeGivenInterval 4} [PP1 PP2] 1}
% 	{Score.apply_H H.notEqual [PP1 PP2] 1}
     end}
 end
 unit(value: heuristic)}


*/


%%
%%
