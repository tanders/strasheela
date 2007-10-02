
%% All distance series with own distributor

declare
%% Is is list of variables
%%
%% Order sorts a list of values according to given comparison function, but only first element is important (i.e. Order does not perform full sorting)
%% !! tmp def with Sort
% fun {Order Xs Fn}
%    {Sort Xs Fn}
% endproc
% {MyDistributor unit(order:Ord value:Val) Xs}
%     {Space.waitStable}
%     local
%         Vars={Filter Xs fun {$ X} {FD.reflect.size X} > 1 end}
%     in
%         if Vars \= nil
%         then
%              Var = {Order Vars Ord}.1
%              Dom={Val Var}
%         in
%              choice {FD.int Dom Var} [] {FD.int compl(Dom) Var} end
%              {MyDistributor unit(order:Ord value:Val) Vars}
%         end
%     end
% end
%%
%% Choose is from Oz source FD.oz 
%%
%% Returns choosen variable (first element) and filtered list (tail). In case of an empty list, first element is unit.
fun {ChooseAndRetFiltVars Vars Order Filter}
   NewVars
   fun {Loop Vars Accu NewTail}
      case Vars
      of nil then NewTail=nil
	 Accu|NewVars
      [] H|T then if {Filter H}
		  then LL
		  in
		     NewTail=(H|LL)
		     {Loop T
		      if Accu==unit orelse {Order H Accu}
		      then H
		      else Accu
		      end
		      LL}
		  else {Loop T Accu NewTail}
		  end
      end
   end
in
   {Loop Vars unit NewVars}
end
proc {MyDistributor unit(order:Ord value:Val) Xs}
   {Space.waitStable}
   local
      Var|Vars = {ChooseAndRetFiltVars Xs
		  Ord fun {$ X} {FD.reflect.size X} > 1 end}
   in 
      if Var\=unit
      then Dom = {Val Var} 
      in
	 choice {FD.int Dom Var}
	 [] {FD.int compl(Dom) Var}
	 end 
	 {MyDistributor unit(order:Ord value:Val) Vars}
      end 
   end 
end
%%
proc {AllDistanceSeries Solution}
   N = 4			% Solution series length
   N1 = N-1
   Pitches Intervals		% Vars for series and intervals
in
   Solution = unit(pitches:Pitches intervals:Intervals)
   Pitches = {FD.list N 0#N1}	% List of FD vars in [0,N-1]
   Intervals = {FD.list N1 1#N1}
   for
      Pitch1 in {List.take Pitches N1} % butlast of Pitches
      Pitch2 in Pitches.2		    % tail of Pitches
      Interval in Intervals
   do
      {FD.distance Pitch1 Pitch2 '=:' Interval}
   end
   {FD.distinctD Pitches}		% no pitch class repetition
   {FD.distinctD Intervals}		% no (abs) interval repetition
   %% Specify search strategy
%   {FD.distribute ff {Append Pitches Intervals}}
%   {FD.distribute naive {Append Pitches Intervals}}
   %% first fail distribution
   {MyDistributor 
    unit(order: fun {$ X Y}
		   {FD.reflect.size X} =< {FD.reflect.size Y}
		end
	 value: fun {$ X} {FD.reflect.min X} end)
    {Append Pitches Intervals}}
   %% naive distribution
%    {MyDistributor 
%     unit(order: fun {$ X Y} true end
% 	 value: fun {$ X} {FD.reflect.min X} end)
%     {Append Pitches Intervals}}
end




/*

{Browse {Search.base.one AllDistanceSeries}}

{Explorer.one AllDistanceSeries}

{Explorer.all AllDistanceSeries}

*/

