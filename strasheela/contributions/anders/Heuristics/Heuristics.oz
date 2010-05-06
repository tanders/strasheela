
%%% *************************************************************
%%% Copyright (C) 2010 Torsten Anders  
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% This functor defines heuristic constraints, which are constraints that express a mere preference instead of a strict constraint. Heuristic constraints are applied to parameter objects (instead of parameter values) using Score.apply_H. See that definition for further information. 
%% */

%%
%% TODO:
%%
%% - Consider introducing some value that means "constraint strictly met". Is that 100?
%%   Others (e.g., OMClouds) use 0 for this purpose, and larger values mean "not strictly true".
%%


%% TODO:
%%
%% - port Jacopos heuristic constraints from JBS-constraints to Strasheela (avoid too much repetition, though: generalise)
%%   Revision of JBS-constraint done for Multi-PMC: generic rules, interval rules 
%%
%% - OK port OMClouds constraints as heuristics to Strasheela
%% 
%% - Check with Strasheela pattern constraints can be implemented as heuristics
%%


%%
%% TODO: specific constraint defs
%%
%% * Heuristic "global constraints" such as Distinct
%%   Approach: given list of parameters should be in the order these parameters are visited by the variable ordering (usually from-left-to-right, even if certain types are visited before other types). So, they would not work for variable orderings that "wildly jump around".
%%   Implementation of "global constraints" can then rely on this variable ordering. If a different variable ordering is used, constraint would not work properly (but would not cause any fail either).
%%
%%
%%  * {AllowedIntervals Xs Intervals}
%%    Xs (FD ints) is constrained such that intervals between consecutive vars are only values in Intervals (list of FD ints). Intervals are either u/down (neg numbers for downwards) or absolute.
%%
%% * PropagatorHeuristic: transforms a propagator into a heursitic (internally creating additional spaces). Should only be used with FD propagators with relatively low arity (and not "constraints" that internally apply propagators, because such propagators should better be applied directly as heuristic constraints to parameter objects?)
%%
%% * !! Interval up is more likely than down (or the other way round). This requires random. (e.g. up {GUtils.random 100} and down {GUtils.random 10}) and thus special measures for recomputation
%%
%% * Distict (i.e. AllDifferent)
%% Problem: effective implementation depends of variable ordering: for every visited parameter of a certain parameter sequence the constraint always takes all parameters values that are already determined into account.
%% I would need alternative to Score.apply_H in order to do that (should not add heuristic to all params involved, but only to always only the one that is still undetermined when the heuristic is actually used. Also SDistro.heuristicVariableOrdering would require revision, because I should not need to "search" for current parameter then, but have a different format where the current parameter is given extra or its position in params list is stored as well)
%%
%%
%% * ?? Jacopo's no-spaced-repetition: every n-th value is distinct
%%
%% * ?? DistinctN: every sublist of n variables are distinct
%% Should be implemented with Distict constraint (see its problems described above)
%%
%% * BooleanApply (tmp title): function that expects an int (parameter value) and a unary Boolean function: if Boolean function returns true then heuristic constraint returns 100, otherwise 0.
%%   E.g., can be used to implement Jacopo's modulo-x-repetition-rule and not-modulo-x-repetition-rule as follows
%% {BooleanApply DomainVal fun {$ X} (X mod 3) == 0 end}
%%
%% * Variant BooleanApply2: expects list of ints and n-ary Boolean function
%%  
%% ?? Hm, would BooleanApply and BooleanApply2 really reduce code compared with implementing things from scratch?
%% 

%%
%% * MaxInterval: if interval between X and Y is smaller than a given Max interval return 100, otherwise 0. (absolute intervals or distinguish and up down)
%% * MinInterval: the opposite
%%

%%
%% * !! Jacopo's not-consecutive-ascending / not-consecutive-descending / not-consecutive-equal: variant similar to NotContinuous with given number of params to consider (e.g., after 3 intervals in same direction one might prefer a direction change).
%%    Define as single constraint with given direction and number of consecutive params to consider
%%
%% * (Not) AllowedInterval: heuristic Member applied to intervals, either consider absolute intervals, or distingush between up and down
%%
%% * no-consecutive-equal-intervals (absolute or distinguish and up down)
%%
%% * repeat-interval-rule: repeat given interval as often as given if it occurs (absolute or distinguish and up down). An arg allows to set comparison of interval number (>, =, <). E.g., with setting < (>) at max (min) given intervals is required, but arbitrary less (more) are fine as well.  
%% (* (?IF (IF (= LEN (CUR-SLEN)) (IF (= (COUNT (QUOTE 3) (G-ABS (PATCH-WORK:X->DX L))) (QUOTE 3)) 10 0) T)))
%%
%%
%% ???? * repeat-resulting-interval: repeat intervals either to the immediate predecessor, or more early predecessors (how far back to look can be set)
%% .. "a resulting interval is an interval between a note and any other notes" (i.e. not necessarily consecutive intervals?)
%% (:HEURISTIC * (?IF (IF (= LEN (CUR-SLEN)) (IF (= (COUNT (QUOTE 3) (PATCH-WORK:FLAT (JBS-CONSTRAINTS:FIND-ALL-INTERVALS L))) (QUOTE 3)) 10 0) T)))
%%
%%
%% * ??? do-reach-that-interval: n (given) values: intervals should all move in same direction and the interval between 1st and nth value should be given interval 
%%


%%
%% * Heuristic variant of HS.rules.ballistic
%%
%% * InRange: heuristic domain spec: Can be defined with Less and Greater
%%
%% * IntervalMember: Member for intervals
%%
%% * ?? QuotientMember: Member for quotients (for "rhythm intervals" that are computed with multiplication instead of addition)
%% 
%%
%% * MarkovChain (with or without stochastic element?)
%%   Can also def only a single clause  (i.e. not necessary to have a clause for every possible input)
%%
%% * AvoidInterval: given single number (or list of numbers: AvoidInterval): this interval should be avoided between consecutive parameters (either absolute, or taking direction into account)  
%%
%% * Resolve skip: after a skip of at least given size follows a skip (max skip size given) in the opposite direction
%%
%% * Heuristic rotation and palindrome pattern (matching elements constrained with EqualContinuous)
%%

%%
%% * Heuristic interval sequences as in pattern motifs?
%%

%%
%% * ?? FollowIntervals: same as FollowList, but for intervals between elements
%%

functor
   
import
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
 
export
   Nega Conj Disj
   
   Less LessEq
   LessContinuous
   Greater  GreaterEq
   GreaterContinuous
   Equal EqualContinuous

   SmallInterval LargeInterval
   Step

   member: Member_H MemberContinuous
   
   MakeGivenInterval_Abs
   Continuous

   Cycle
   FollowList FollowIntervals FollowFenv FollowFenvIntervals
   
define

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Heuristic constraint combinators
%%%

   %%
   %% Problem: these combinators only work reliably for heuristic constraints that correctly map their results into [0, 100], but many heuristic constraints below do not strictly ensure such an interval.
   %%
   
   /** %% [Heuristic constraint combinator] Logical negation. B (int in [0, 100]) is the result of a heuristic constraint. 
   %% */
   fun {Nega B}
      100 - B
   end

   /** %% [Heuristic constraint combinator] Logical conjunction. Bs (list of ints in [0, 100]) is a list of results of heuristic constraints. 
   %% */
   fun {Conj Bs}
      {LUtils.accum Bs Value.min}
   end

   /** %% [Heuristic constraint combinator] Logical disjunction. Bs (list of ints in [0, 100]) is a list of results of heuristic constraints. 
   %% */
   fun {Disj Bs}
      {LUtils.accum Bs Value.max}
   end


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Heuristic constraint "primitives" (mostly binary functions). 
%%%

   /* %% [Heuristic constraint] X should be smaller than Y (the interval size has no influence). 
   %% */
   fun {Less X Y}
      if X < Y
      then 100
      else 0
      end
   end
   /* %% [Heuristic constraint] X should be smaller than Y or equal (the interval size has no influence). 
   %% */
   fun {LessEq X Y}
      if X =< Y
      then 100
      else 0
      end
   end
   
   /* %% [Heuristic constraint] X should be smaller than Y (the greater the difference the better).
   %% Note: function has discontinuity: from "X equal Y" to "X less than Y by one" the result jumps by 50.
   %% */
   %% TODO: should I instead define true continuous function?
   %% TODO: refine "spacing" of returned values in interval [0, 100] (now step-size 2 and no upper bound)
   fun {LessContinuous X Y}
%
%       {Min 0 Y-X}
%      
      if X<Y
	 %% a value > 50
      then Y-X+50
	 %% a value <= 0
      else Y-X
      end
   end
   
   /* %% [Heuristic constraint] X should be greater than Y (the interval size has no influence). 
   %% */
   fun {Greater X Y}
      if X > Y
      then 100
      else 0
      end
   end
   /* %% [Heuristic constraint] X should be greater than Y or equal (the interval size has no influence). 
   %% */
   fun {GreaterEq X Y}
      if X >= Y
      then 100
      else 0
      end
   end
   
   /* %% [Heuristic constraint] X should be smaller than Y (the greater the difference the better).
   %% Note: function has discontinuity: from "X equal Y" to "X more than Y by one" the result jumps by 50.
   %% */
   %% TODO: refine "spacing" of returned values in interval [0, 100] (now step-size 2 and no upper bound)
   fun {GreaterContinuous X Y}
      if X>Y
	 %% a value > 50
      then X-Y+50
	 %% a value <= 0
      else X-Y
      end
   end
   
%    /* %% [Heuristic constraint] X and Y should be different. 
%    %% */
%    fun {NotEqual X Y}
%       if X \= Y
%       then 100
%       else 0
%       end
%    end
   
   /* %% [Heuristic constraint] X and Y should be equal (small and large intervals are considered equally bad). 
   %% */
% ?? NB: Mikael Laurson added to similar heuristic constraint some random element: if true then return random number is likely larger. However, random does not work with recomputation.
   fun {Equal X Y}
      if X == Y
      then 100 % {GUtils.random 100}
      else 0   % {GUtils.random 10}
      end
   end

    /* %% [Heuristic constraint] X and Y should be equal, but if unequal then small intervals are preferred.
   %% */
   %% TODO: refine "spacing" of returned values in interval [0, 100] (now step-size 2)
   %%   Hm -- when would it actually make a difference? If there is a conflict with another heuristic constraint, and it must be decided which only "halve-way" fulfilled constraint is more important 
   fun {EqualContinuous X Y}
      100 - ({Abs Y-X} * 2)
   end
   
   /* %% [Heuristic constraint] Small intervals between X and Y are preferred (the smaller the interval the better). However, equal X and Y are rated very low.
   %% */
   %% TODO: refine "spacing" of returned values in interval [0, 100] (now step-size 2)
   %%   Hm -- when would it actually make a difference? If there is a conflict with another heuristic constraint, and it must be decided which only "halve-way" fulfilled constraint is more important 
   fun {SmallInterval X Y}
      if X == Y
      then 0
      else 100 - ({Abs Y-X} * 2)
      end
   end

   /* %% [heuristic constraint] Steps (not unison) between X and Y are preferred, but the stepsize is irrelevant.
   %%
   %% Args:
   %% 'maxStep' (default 8#7): maximal step size, specified as ratio (pair of integers).
   %% */
   fun {Step X Y Args}
      Defaults = unit(maxStep: 8#7)
      As = {Adjoin Defaults Args}
      MaxStep = {FloatToInt {MUtils.ratioToKeynumInterval As.maxStep
			     {IntToFloat {HS.db.getPitchesPerOctave}}}}
   in
      if X == Y
      then 0
      elseif {Abs Y-X} < MaxStep
      then 100
      else 0
      end
   end
   
   /* %% [Heuristic constraint] Large intervals are preferred (the larger the interval the better).
   %% */
   %% TODO: refine "spacing" of returned values in interval [0, 100] (now step-size 2 and no upper bound)
   %% E.g., should "spacing" be linear?
   fun {LargeInterval X Y}
      ({Abs Y-X} * 2)
   end
   
   /** %% Returns a binary heuristic constraint: intervals of size Interval (int) up or down are preferred (the closer the better).
   %% */
   %% TODO: refine "spacing" of returned values in interval [0, 100] (now step-size 2)
   fun {MakeGivenInterval_Abs Interval}
      fun {$ X Y}
	 Diff = Y-X
      in
	 %% [~infinity, ~Interval]
	 if Diff < ~Interval then 100 - Interval + Diff
	    %% [~Interval, 0]
	 elseif Diff < 0 then 100 - Interval - Diff
	    %% [Interval, infinity]
	 elseif Diff > Interval then 100 - Interval - Diff
	 % [0, Interval]
	 else 100 - Interval + Diff
	 end
      end
   end

   /* %% [Heuristic constraint] X (int) is in Ys (list of ints). Non-continuous constraint (function returns 100 if true and 0 otherwise.
   %% */
   fun {Member_H X Ys}
      if {Member X Ys}
      then 100 
      else 0   
      end
   end

   /** %% [Heuristic constraint] X (int) is in Xs (list of ints). Continuous constraint (function returns 100 if X is exactly a member and otherwise a number indicating how close X is to some of the elements of Ys (the larger the closer).
   %% */
   fun {MemberContinuous X Ys}
      %% Max of distance between X and any element of Ys
      {LUtils.accum 
       {Map Ys fun {$ Y} {EqualContinuous X Y} end}
       Value.max}
   end
   
   /** %% [Heuristic constraint] The intervals between X, Y and Z move in the same direction (only up and down are considered; for simplicity repetitions are considered upward motion as well).
   %% */
   fun {Continuous X Y Z}
      if (Y-X =< 0) == (Z-Y =< 0)
      then 100
      else 0
      end
   end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Heuristic pattern constraints: applied to a list of parameters and
%%% internally applying heuristic "primitives"
%%%

   /** %% [encapulated heuristic constraint] Every element in Params (list of parameter objects) and its L-th (int) successor are constrained to be equal (EqualContinuous). 
   %% */
   proc {Cycle Params L Weight}
      {Pattern.forNeighbours Params L+1
       proc {$ Ps}
	  {Score.apply_H EqualContinuous [Ps.1 {List.last Ps}] Weight}
       end}
   end
   
   
   /** %% [encapulated heuristic constraint] The values of Params (list of parameter objects) "follow" Xs (list of ints), and the smaller the differences the better. Naturally, Xs can be generated with arbitrary deterministic algorithmic composition techniques. Weight (int) is the constraint's weight, use 1 by default.
   %% FollowList internally applies heuristic constraints to Params. Efficient heuristic: for each domain value decision, only a single parameter is involved.
   %% */
   proc {FollowList Params Xs Weight}
      {ForAll {LUtils.matTrans [Params Xs]}
       proc {$ [Param X]}
	  {Score.apply_H fun {$ ParamVal} {EqualContinuous ParamVal X} end [Param]
	   Weight}
       end}
   end

   /** %% [encapulated heuristic constraint] The intervals between the values of Params (list of parameter objects) "follow" the intervals between Xs (list of ints), and the smaller the differences the better. Variant of FollowList that allows for transposition.
   %% */
   proc {FollowIntervals Params Xs Weight}
      {Pattern.for2Neighbours {LUtils.matTrans [Params Xs]}
       proc {$ [Param1 X1] [Param2 X2]}
	  {Score.apply_H fun {$ P1 P2} {EqualContinuous P2-P1 X2-X1} end [Param1 Param2]
	   Weight}
       end}
   end
   
   /** %% [encapulated heuristic constraint] The values of Params (list of parameter objects) "follow" MyFenv (Fenv instance), and the smaller the differences the better. Weight (int) is the constraint's weight, use 1 by default.
   %% FollowFenv internally applies heuristic constraints to Params. Efficient heuristic: for each domain value decision, only a single parameter is involved.
   %% Remember that fenvs are always defined with floats, there are internally converted to integers.
   %% */
   proc {FollowFenv Params MyFenv Weight}
      {FollowList Params {Map {MyFenv toList($ {Length Params})} FloatToInt} Weight}
   end

   /** %% [encapulated heuristic constraint] The intervals between values of Params (list of parameter objects) "follow" intervals between corresponding MyFenv (Fenv instance) value, and the smaller the differences the better.
   %% */
   proc {FollowFenvIntervals Params MyFenv Weight}
      {FollowIntervals Params {Map {MyFenv toList($ {Length Params})} FloatToInt} Weight}
   end


%% TODO: port this pattern constraint into a heuristic constraint
    /** %% Constraints Xs (a list of FD ints) to form an nth-order markov chain according to Decl. A Decl clause takes any number of predecessors into account and specifies a single successor. Decl is a list of list pairs in the form <code>PredecessorSeq#PossibleSucessors</code>: after the occurance of PredecessorSeq in a sublist of Xs follows a value in PossibleSucessors. For example, the first order markov chain <code>{MarkovChain Xs [[1]#[2 3] [2]#[1] [3]#[2]]}</code> causes any 1 in Xs to be followed by either 2 or 3 and any 2 by 1 etc.
      %% The list in PredecessorSeq can be of any length to specify any markov chain order. However, in all clauses the length should be equal.
      %% Additionally, the declaration can use the wildcard symbol 'x' which matches every FD int. For example, the clause <code>[x 1]#[2]</code> states that 1 is followed by 2.
      %% NB: The list of declarations in Decl specifies a number of disjunctions without any implicit 'otherwise' clause. An inappropriate Decl can cause no solution.
      %% Markov chains of order N pose constraints only on sublists of length N: a clauses <code>[x x 1]#[2]</code> does not simply constrain 1 to be followed by 2 but does constrain 1 with two predecessors be followed by 2. Workaround: append some aux FD ints in front of the list and remove them later again (this workaround is not automatically integrated in MarkovChain to avoid any undesired side effects -- its no foolproof trick and the user should thus be aware of it).
      %% NB: MarkovChain only specifies that certain elements follow each other. In opposite to the [usual / common] definition of a markov chain, however, MarkovChain does NOT constrain the probability of certain successors.
      %% */
   %% ??? Besides, multiple Decl clauses on the same (sub)-predecessor lists result in multiple alternatives on the same predecessors (i.e. more specific clauses -- clauses with less wildcards -- do NOT match better than less specific clauses).
% proc {MarkovChain Xs Decl}
% 	 %% the length of the first left hand side of a Decl clause
% 	 %% determines the markov chain order
% 	 Order = {Length Decl.1.1}
%       in
% 	 {Pattern.forNeighbours Xs (Order + 1)
% 	  proc {$ SubXs}       	% SubXs is [each] sublist of Xs of length Order + 1
% 	     {DisjAll	% disj: alternative clauses in Decl
% 	      {Map Decl
% 	       fun {$ PreVals#SuccVals}			       
% 		  %% reified: the predecessor values PreValsVals matches
% 		  %% butlast of SubXs AND is followed by an element in SuccVals
% 		  {FD.conj
% 		   {MatchesR PreVals {LUtils.butLast SubXs}}
% 		   {FD.reified.int SuccVals {List.last SubXs}}}
% 	       end}
% 	      1}
% 	  end}
% end


   
   
end
