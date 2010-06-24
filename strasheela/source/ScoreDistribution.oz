
%%% *************************************************************
%%% Copyright (C) 2002-2008 Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************


/** %% This functor defines solvers and distribution strategies for a score search. The search process in Strasheela is highly customisable and the present functor makes such customisations concise and convenient. Score distribution strategies are discussed in my thesis "Composing Music by Composing Rules", chapter 7. For information on constraint solvers and distribution strategies in general see the Oz documentation (e.g., the "Finite Domain Constraint Programming" tutorial, http://www.mozart-oz.org/documentation/fdt/index.html), and for detailed background information C. Schulte's book "Programming Constraint Services".
%%
%% The solvers exported by this function are solvers customised for musical CSPs. Such score solvers (e.g., SearchOne or ExploreOne) expect a musical CSP (a script returning a solution score as its only argument), and optional arguments which define the distribution strategy. Note that this approach differs from the common solvers in Oz. Remember that in Oz the distribution strategy is part of the script, not an argument to the solver. Strasheela's approach separates script and distribution strategy, which is more convenient for complex distributions and in particular for scripts which contain of subscripts (CSP where subdefinitions, e.g., musical sections or the bare harmonic progression without the actual notes, can be solved on their own). 
%% 
%% The distribution strategy arguments of all score solvers are documented with the function MakeSearchScript (this function also helps you defining new solvers, see the solver definitions in the source). Particularly important aspects of a distribution strategy are its variable and value ordering (the optional arguments 'order' and 'value'). 
%% 
%% Several orderings (and other distribution args) are predefined and easily specified with an atom as distribution argument (e.g., by setting the distribution argument 'order' to 'size' or 'leftToRight', see the MakeSearchScript documentation for details). More complex variable orderings can be defined conveniently with the variable ordering constructors and plain variable orderings provided (e.g., a variable ordering which first visits time parameters but breaks ties -- where both its arguments are (are not) time parameters -- by visiting the parameter with the largest domain size first, such a variable ordering is concisely defined as follows: {MakeTimeParams Dom}. 
%%
%%
%% */

										    
%% TODO: 
%%
%% !!?? * debug startTime distribution strategy (already OK?)
%%
%% * extensively testing, e.g. of order preferring timing parameters
%%
%% 
%%

%%
%% Nachdenken: I want more efficient distributions: the computations performed at each distribution step should be as little as possible and the list of distributable data should be as short as possible:
%%
%% * !! Can I use multiple sequential distribution calls to define specific distribution strategies. E.g., in case I first want to determine all timing parameters and only after that all the rest: I may apply a first FD.distribute with all needed timing parameters and a second distribution application with the further parameters.
%%
%% * !! Or has the order of distributable data (i.e. parameters) any influence on the distribution.
%%
%% -> E.g. example in FD toot, Sec. 6.1 defines two distributions. Here, the first distribution defines the size of the problem before additional constraints are added to the problem. I don't want to add constraints, but simply split the effort for FD.distribute into two calls -- should work! The first FD.distribute should simply block until all its distributable data is determined..
%%
%% NB: \cite[p. 35f]{Schulte:Book:2002}: multiple distributors introduce hard to find programming errors
%%
%%

%% MINI version of FD.distribute which I may use instead..
%% NB: def seems not to be quite correct: see examples/private/distribution-test.oz
%%
%%
%% Is is list of variables
%%
%% Order sorts a list of values according to given comparison function, but only first element is important (i.e. Order does not perform full sorting)
%% !! tmp def with Sort
%
% fun {Order Xs Fn}
%    {Sort Xs Fn}
% end

	
functor 
import 
   FD Search Explorer
   GUtils at 'GeneralUtils.ozf'
   LUtils at 'ListUtils.ozf'

   FD_edited(fdDistribute: FdDistribute)
   
   % Score at 'ScoreCore.ozf'
%    Browser(browse:Browse) % temp for debugging
   
export

   FdDistribute
   
   %% solver defs
   SearchOne SearchAll SearchBest SearchBest_Timeout
   SearchOneDepth 
   ExploreOne ExploreAll ExploreBest

   %% variable ordering defs
   Naive Dom Width Deg DomDivDeg MakeDom MakeDeg MakeLeftToRight MakeRightToLeft TimeParams MakeTimeParams
   min: ReflectMin
   max: ReflectMax
   MakeSetPreferredOrder MakeSetPreferredOrder2
   MakeMarkNextParam MakeVisitMarkedParamsFirst 
   %% value ordering defs 
   MakeRandomDistributionValue
   MakeHeuristicValueOrder
   
   %% score distro defs   
   MakeSearchScript
   MakeFDDistribution % better use MakeSearchScript
   
define


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Distribution strategy defs: variable ordering defs  
%%%
   
   /** %% [variable ordering (a score distribution strategy 'order' procedure)] naive variable ordering: visit first parameter first.
   %% */
   fun {Naive _ _} 
      false
   end
   
   /** %% [variable ordering] 'dom' score variable ordering: first visits score parameters with smallest domain size. In case of a tie (i.e. both domain sizes are equal), X is preferred.
   %% */
   fun {Dom X Y}
      {FD.reflect.size {X getValue($)}}
      <
      {FD.reflect.size {Y getValue($)}}
   end
   /** %% [variable ordering] 'width' score variable ordering: first visits score parameters with smallest domain width (the smallest difference between the domain bounds). In case of a tie, X is preferred.
   %% */
   fun {Width X Y}
      {FD.reflect.width {X getValue($)}}
      <
      {FD.reflect.width {Y getValue($)}}
   end
   /** %% [variable ordering] 'deg' score variable ordering: first visits score parameters with most constraints applied (i.e. most threads suspending on its variable). In case of a tie, X is preferred.
   %% */
   fun {Deg X Y}
      {FD.reflect.nbSusps {X getValue($)}}
      <
      {FD.reflect.nbSusps {Y getValue($)}}
   end

   /** %% [variable ordering] first visits score parameters with minimal lower domain boundary. In case of a tie, X is preferred.
   %% */
   fun {ReflectMin X Y}
      {FD.reflect.min {X getValue($)}}
      <
      {FD.reflect.min {Y getValue($)}}
   end
   /** %% [variable ordering] first visits score parameters with maximal upper domain boundary. In case of a tie, X is preferred.
   %% */
   fun {ReflectMax X Y}
      {FD.reflect.max {X getValue($)}}
      >
      {FD.reflect.max {Y getValue($)}}
   end

   local Factor = 1000000 in
      /** %% [variable ordering] 'dom/deg' score variable ordering: first visits score parameters with the smallest quotient of domain size and number of constraints applied. In case of a tie, X is preferred.
      %% */
      fun {DomDivDeg X Y}
	 %% factor added in order to avoid that integer quotient is often 0
	 {FD.reflect.size {X getValue($)}} * Factor div {FD.reflect.nbSusps {X getValue($)}}
	 <
	 {FD.reflect.size {Y getValue($)}} * Factor div {FD.reflect.nbSusps {Y getValue($)}}
      end
   end

   /** %% [variable ordering constructor] Returns a 'dom' score variable ordering (a binary function expecting two parameter objects and returning a boolean value, a score distribution strategy 'order' procedure), i.e. an ordering which first visits score parameters with smallest domain size. It breaks ties (i.e. both domain sizes are equal) with the score variable ordering P.
   %% */
   fun {MakeDom P}
      fun {$ X Y}
	 L1 = {FD.reflect.size {X getValue($)}}
	 L2 = {FD.reflect.size {Y getValue($)}}
      in
	 L1>L2 orelse
	 %% if equal, break ties with P, otherwise false (prefer Y)
	 (L1==L2 andthen {P X Y})
      end
   end

   /** %% [variable ordering constructor] Returns a 'deg' score variable ordering (a binary function expecting two parameter objects and returning a boolean value), i.e. an ordering which first visits score parameters with the most constraints applied (i.e. most threads suspending on its variable). It breaks ties with the score variable ordering P.
   %% */
   fun {MakeDeg P}
      fun {$ X Y}
	 L1 = {FD.reflect.nbSusps {X getValue($)}}
	 L2 = {FD.reflect.nbSusps {Y getValue($)}}
      in
	 L1>L2 orelse
	 %% if equal, break ties with P, otherwise false (prefer Y)
	 (L1==L2 andthen {P X Y})
	 %% same meaning, but always needs two computation steps:
%       if L1 == L2
%       then {P X Y}
%       else L1>L2
%       end
      end
   end

   /** %% [variable ordering constructor] Returns a left-to-right score variable ordering (a binary function expecting two parameter objects and returning a boolean value), i.e. an ordering which visits score parameters in the order of the start time of their associated score object. If only one start time is bound, then prefer the corresponding param (if none is bound prefer Y). In case of equal start times, temporal parameters are visited first. It breaks ties (equal start times and both X and Y are/are not time parameters) with the score variable ordering P.
   %%
   %% NB: it is important for this variable ordering that time parameters are determined early so that other start times are determined. So, typically P is defined by {MakeTimeParams Q}, where Q is your actual tie-breaking ordering. The default leftToRight ordering is {MakeLeftToRight TimeParams}.
   %%
   %% NB: P is only called if both start times are determined and equal. So, the overhead added should not be too high.
   %% */
   fun {MakeLeftToRight P}
      fun {$ X Y}
	 S1 = {{X getItem($)} getStartTime($)}
	 S2 = {{Y getItem($)} getStartTime($)}
	 IsS1Bound = ({FD.reflect.size S1}==1)
      in
	 %% if start time of both elements are bound
	 if IsS1Bound andthen ({FD.reflect.size S2}==1)
	 then
	    S1 < S2 orelse
	    %% if start times are equal, break ties with P, otherwise false (prefer Y)
	    (S1 == S2 andthen {P X Y})
	    %% same meaning, but always needs two computation steps:
% 	 if S1==S2
% 	 then {P X Y}
% 	 else S1 =< S2	
% 	 end
	    %%
	    %% if only one start time is bound, then prefer corresponding
	    %% param (if none is bound the decision is arbitrary)
	 else IsS1Bound
	 end
      end
   end



   /** %% [variable ordering constructor] Returns a right-to-left score variable ordering, i.e. an ordering which visits score parameters in the decreasing order of the end time of their associated score object. If only one end time is bound, then prefer the corresponding param (if none is bound prefer Y). In case of equal end times, temporal parameters are visited first. It breaks ties (equal start times and both X and Y are/are not time parameters) with the score variable ordering P.
   %%
   %% NB: this variable ordering only works if the last end time (and thus usually the full score duration) is determined in the problem definition! It can be hard to reliably find a value (total duration) which works? Nevertheless, for some CSPs it is beneficial to work backwards (e.g., the final cadence may pose special problems).
   %%
   %% NB: it is important for this variable ordering that time parameters are determined early so that other end times are determined. So, typically P is defined by {MakeTimeParams Q}, where Q is your actual tie-breaking ordering.
   %%
   %% NB: P is only called if both end times are determined and equal. So, the overhead added should not be too high.
   %% */
   fun {MakeRightToLeft P}
      fun {$ X Y}
	 E1 = {{X getItem($)} getEndTime($)}
	 E2 = {{Y getItem($)} getEndTime($)}
	 IsE1Bound = ({FD.reflect.size E1}==1)
      in
	 %% if end time of both elements are bound
	 if IsE1Bound andthen ({FD.reflect.size E2}==1)
	 then
	    E1 > E2 orelse
	    %% if end times are equal, break ties with P, otherwise false (prefer Y)
	    (E1 == E2 andthen {P X Y})
	    %% if only one end time is bound, then prefer corresponding
	    %% param (if none is bound the decision is arbitrary)
	 else IsE1Bound
	 end
      end
   end

   
   /** %% [variable ordering] first visits time parameters. In case of a tie, Y is preferred.
   %% */
   fun {TimeParams X _} 
      {X isTimeParameter($)}
   end
   
   /** %% [variable ordering constructor] Returns a score variable ordering (a binary function expecting two parameter objects and returning a boolean value) which first visits time parameters. It breaks ties with the score variable ordering P.
   %% */
   fun {MakeTimeParams P}
      fun {$ X Y}
	 B =  {X isTimeParameter($)}
      in
	 if {GUtils.xOr B {Y isTimeParameter($)}}
	 then B
	 else {P X Y}
	 end
      end
   end

   local
      fun {GetTestIndex Param Tests}
	 {LUtils.findPosition Tests fun {$ Test} {Test Param} end}
      end
   in
      /** %% [variable ordering constructor] Returns a variable ordering which visits parameters in an order specified by test functions. Tests is a list of unary Boolean funcs which expect a parameter. Implicitly, a last Boolean function is added which always returns true (so parameters not matching any test are always rated lower). The variable ordering first visits the parameter for which a test with smaller index in Tests returns true. In case of a tie (two parameters with equal 'test index'), the first argument of the variable ordering is preferred (naive tie breaking).
      %% */
      fun {MakeSetPreferredOrder2 Tests}
	 %% append default (always returning true) at end
	 AllTests = {Append Tests [fun {$ X} true end]}
      in
	 fun {$ X Y}
	    XI = {GetTestIndex X AllTests}
	    YI = {GetTestIndex Y AllTests}
	 in
	    XI < YI
	 end
      end
      /** %% [variable ordering constructor] More general variant of MakeSetPreferredOrder2. Returns a variable ordering which visits parameters in an order specified by test functions. Tests is a list of unary boolean funcs which expect a parameter. Implicitly, a last Boolean function is added which always returns true (so parameters not matching any test are always rated lower). The variable ordering first visits the parameter for which a test with smaller index in Tests returns true. MakeSetPreferredOrder breaks ties with the score variable ordering P.
      %% */
      fun {MakeSetPreferredOrder Tests P}
	 %% append default (always returning true) at end
	 AllTests = {Append Tests [fun {$ X} true end]}
      in
	 fun {$ X Y}
	    XI = {GetTestIndex X AllTests}
	    YI = {GetTestIndex Y AllTests}
	 in
	    XI < YI orelse
	    (YI == XI andthen {P X Y})
	    %% same meaning, but needs more computation steps:
% 	    if XI < YI
% 	    then true
% 	    elseif YI == XI
% 	    then {IfEqual X Y}
% 	    else false
% % 	    elseif YI < XI
% % 	    then false
% % 	    else {IfEqual X Y}
%	    end
	 end
      end
   end

   
   /** %% [variable ordering and selection constructor] Allows to mark one or more parameter objects which should be visited directly after specific parameters. For example, after a note's pitch class parameter one may want to visit directly afterwards its octave parameter. 
   %% Clauses is a list of pairs in the form [Test1#ItemAccessors1 ...]. TestI is a Boolean function or method expecting a parameter object. If a test function returns true then that means that specific parameters somehow related to the present parameter object are visited directly afterwards. These parameters are accessed with ItemAccessorsI, which is a list of unary functions or methods returning a parameter object to be visited next. Each function/method of ItemAccessorsI expects the item of the present parameter for convenience (so {X getItem($)} must not be called every time). Note that multiple params can be marked with multiple ItemAccessorsI, but the order in which these are visited is not specified.
   %%
   %% MakeMarkNextParam returns a unary function for the distribution strategy argument 'select'. 
   %% Note: use MarkNextParam always together with MakeVisitMarkedParamsFirst.
   %% */
   fun {MakeMarkNextParam Clauses}
      fun {$ X}
	 Params = {LUtils.mappend Clauses
		   fun {$ Test#ItemAccessors}
		      if {{GUtils.toFun Test} X}
		      then {Map ItemAccessors
			    fun {$ Acc} {{GUtils.toFun Acc} {X getItem($)}} end}
		      else nil
		      end
		   end}
      in
	 %% NOTE: using info tags is relatively inefficient (hasThisInfo traverses list), but using flags instead seems to block (?? because of stateful operations on directory and directory is in parent space?)
	 {ForAll Params proc {$ P} {P addInfo(distributeNext)} end}
	 % proc {$ P} {P addFlag(distributeNext)} end}
	 %% the ususal parameter value select
	 {X getValue($)}
      end
   end
   /** %% [variable ordering constructor]: Returns a variable ordering which visits parameters marked by MakeMarkNextParam first. MakeVisitMarkedParamsFirst returns a binary function for the distribution strategy argument 'order'. MakeVisitMarkedParamsFirst should be the outmost variable ordering constructor (i.e. it should not be used as argument to another variable ordering constructor).
   %% If neither variable is marked, use the score variable ordering P.
   %%
   %% Note: use MakeVisitMarkedParamsFirst always together with MakeMarkNextParam.
   %% */
   fun {MakeVisitMarkedParamsFirst P}
      fun {$ X Y}
	 if {X hasThisInfo($ distributeNext)} % {X hasFlag($ distributeNext)}
	 then true
	 elseif {Y hasThisInfo($ distributeNext)} % {Y hasFlag($ distributeNext)}
	 then false
	    %% else do the given distribution
	 else {P X Y}
	 end
	 %% not more efficient, but less easy to comprehend
% 	 {X hasThisInfo($ distributeNext)} orelse 
% 	 (if {Y hasThisInfo($ distributeNext)} then false
% 	  else {P X Y}
% 	  end)
      end
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Distribution strategy defs: value ordering defs  
%%%

   /** %% Returns randomised value ordering, that is, a binary function for the argument 'value' of FD.distribute. The argument RandGen is a nullary function. If RandGen is created by GUtils.makeRandomGenerator, then the value ordering is randomised but still deterministic: re-executing the distribution will allways yield the same results. Consequently, such a randomised value ordering can be used for recomputation.
   %% NOTE: this value ordering is conveniently applied by setting the distribution argument 'value' of any solver to 'random'.
   %% */
   fun {MakeRandomDistributionValue RandGen}
      fun {$ X_Param SelectFn}
	 X = {SelectFn X_Param}
	 Rand = {GUtils.randIntoRange  {RandGen} % pseudo-random number generated here
		 {FD.reflect.min X} {FD.reflect.max X}}
      in
	 {FD.reflect.nextSmaller X Rand+1}
      end
   end

   
   local
      %% BestsSoFar is list of values with their quality figures, stored as a list of pairs
      %% [X1#Quality1 ...]
      fun {FilterBest_Aux Xs Fn BestsSoFar}
	 case Xs of nil then {Map BestsSoFar fun {$ X#_} X end}
	 else
	    X = Xs.1
	    CurrQuality = {Fn X}
	    BestSoFarQuality = BestsSoFar.1.2 
	 in
	    if CurrQuality > BestSoFarQuality
	    then {FilterBest_Aux Xs.2 Fn [X#CurrQuality]}
	    elseif CurrQuality == BestSoFarQuality
	    then {FilterBest_Aux Xs.2 Fn X#CurrQuality | BestsSoFar}
	    else {FilterBest_Aux Xs.2 Fn BestsSoFar}
	    end
	 end
      end
      /** %% Returns the list of members of Xs that performs best according to the unary evaluation function Fn. Fn returns an integer that denotes the quality of its argument; the higher the returned integer the better the corresponding member of Xs.
      %% */
      fun {FilterBest Xs Fn}
	 case Xs of nil then nil
	 else {FilterBest_Aux Xs.2 Fn [Xs.1#{Fn Xs.1}]}
	 end
      end
   in
      /** %% Returns a value ordering, i.e. a binary be given to distribution arg 'value'. This value ordering takes heuristic constraints applied with Score.apply_H into account. In addition, it randomises the decision making. RandGen is a nullary function created by GUtils.makeRandomGenerator.
      %%
      %% Naturally, any value ordering heuristics is only effective for parameters that are actually distributed. For example, if the pitch classes and octaves of notes are distributed and the note pitches are determined by propagation, then any heuristic constraint applied to the pitches has no effect.
      %%
      %% NOTE:  this value ordering is conveniently applied by setting the distribution argument 'value' of any solver to 'heuristic'.
      %% */
      %% To decide: should this be default value ordering, together with randomised value ordering?
      %%
      %% !! TODO:
      %% Problem: how to randomise heuristic constraints (i.e. use random within the heuristic constraint definition): they would need to also use an deterministic RandGen
      %% Just try creating further Gutils.makeRandomGenerator instances, one for each "random heursitic" and see how this works...
      %% Or can I create a single instance and then use that within the CSP and in the value ordering? No, that is not possible: the instance for the value ordering must optionally be created automatically for convenience. 
      %%
      fun {MakeHeuristicValueOrder RandGen}
	 fun {$ Param SelectFn}
	    Var = {SelectFn Param} % getValue...
	    Dom = {FD.reflect.domList Var}
	    %% Heuristics are only applied if current param is only undetermined param involved in heuristic constraint
	    Heuristics   % list of heuristic decls
	    = {Filter {Param getHeuristics($)}
	       fun {$ MyHeuristic} 
		  %% !! TODO: efficiency: ParamPos accessed multiple times (below accessed again, somehow store this info instead)
		  %% position of Param in params of heuristic
		  ParamPos = {LUtils.position Param MyHeuristic.parameters}
	       in
		  {All {LUtils.removePosition MyHeuristic.parameters ParamPos}
		   fun {$ P} {IsDet {SelectFn P}} end}
	       end}
	    /** %% Returns a number that indicates the quality of DomVal (int) with respect to Heuristic (record with feats params and heuristic).
	    %% */
	    fun {EvaluateDomValue DomVal Heuristic}
	       %% !! TODO: efficiency: ParamPos accessed again
	       %% position of Param in params of heuristic
	       ParamPos = {LUtils.position Param Heuristic.parameters}
	       Aux
	    in
	       %% get quality of DomVal with respect to Heuristic.heuristic
	       {Procedure.apply Heuristic.constraint
		{Append {LUtils.replacePosition {Map Heuristic.parameters fun {$ P} {SelectFn P} end}
			 ParamPos DomVal}
		 [Aux]}}
	       %% multiply quality with weight
	       Aux * Heuristic.weight
	    end
	 in
	    if Heuristics \= nil
	    then
	       BestDomValues = {FilterBest Dom
				fun {$ DomVal}
				   {LUtils.accum %% Question: any more efficient summing?
				    {Map Heuristics
				     fun {$ H} {EvaluateDomValue DomVal H} end}
				    Number.'+'}
				end}
	       SelectedDomValue = {Nth BestDomValues
				   %% pseudo-random number generated here
				   {GUtils.randIntoRange {RandGen} 
				    1 {Length BestDomValues}}}
	    in
% 	       %% TMP
% 	       {Browse heuristic(Param#{Param getInfo($)}
% 				 notePosition:{{Param getItem($)}
% 					       getPosition($ {{Param getItem($)} getTemporalAspect($)})}
% 				 dom:Dom
% 				 bestDomValues: BestDomValues
% 				 selectedDomValue: SelectedDomValue
% 				 heuristics: Heuristics
% 				 allHeuristics: {Param getHeuristics($)}
% 				)}
	       SelectedDomValue
	    else
	       %% Heuristics is nil
	       Rand = {GUtils.randIntoRange {RandGen} % pseudo-random number generated here
		       {FD.reflect.min Var} {FD.reflect.max Var}}
	    in
% 	       %% TMP
% 	       {Browse default(Param#{Param getInfo($)}
% 			       notePosition:{{Param getItem($)}
% 					     getPosition($ {{Param getItem($)} getTemporalAspect($)})}
% 			       dom:Dom
% 			       selectedDomValue: {FD.reflect.nextSmaller Var Rand+1}
% 			       rand:Rand
% 			       heuristics: Heuristics
% 			       allHeuristics: {Param getHeuristics($)}
% 			      )}
	       {FD.reflect.nextSmaller Var Rand+1}
	       %%
% 	    {FD.reflect.mid Var}
	    end
	 end
      end
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  Score distribution strategy def 
%%%

   local
      %% A number of predefined functions for FD.distribute -- the
      %% functions can be accessed by atoms to MakeFDDistribution.
      PredefinedFns =
      unit(filter: 
	      fns(undet: fun {$ X}
			      %{Browse undet}
			    {FD.reflect.size {X getValue($)}} > 1
			 end)
	   
	   order: 
	      %% order function return boolean for sorting. 
	   fns(naive: Naive
	       size: Dom
	       dom: Dom
	       width: Width
	       %% Choose the variable on which most propagators are suspended (i.e. constraints are applied), an in case this is equal then take the variable with the smallest domain. 
	       %% This mirrors the default nbSusps implementation in Mozart.
	       nbSusps: {MakeDeg Dom}
	       'deg+dom': {MakeDeg Dom}
	       %% First fail variant: choose variable with smallest domain and in case of ties the variable to which most constraints are applied
	       'dom+deg': {MakeDom Deg}
	       %% First fail variant: quotient of domain size and number of constraints applied
	       'dom/deg': DomDivDeg
	       min: ReflectMin
	       max: ReflectMax
	       timeParams: TimeParams
	       %% If only one of X or Y is timing parameters, then
	       %% return boolean such that timing parameter is put 
	       %% first. If both or non of X and Y are timing 
	       %% parameters, then return boolean such that parameter
	       %% with smaller domain size is preferred.
	       timeParamsAndSize: {MakeTimeParams Dom}
	       %% select parameter with smalles startTime (and smallest domain) 
	       %% (startTime parameters get bound by propagation)
	       %%
	       %% timing params of timingAspects (especially
	       %% sequential) gets bound soon -- they have a smaller
	       %% startTime then most of there contained items.
	       %%
	       %% Important: for this distribution
	       %% strategy, the outmost timing container needs a
	       %% startTime predefined.
	       startTime: {MakeLeftToRight TimeParams}
	       leftToRight: {MakeLeftToRight TimeParams}
	      )
	   
	   select: fns(value: fun {$ X} {X getValue($)} end)
	   
	   value: 
	      fns(min: min %FD.reflect.min
		  max: max %FD.reflect.max
		  mid: mid %FD.reflect.mid
		  splitMin: splitMin
		  splitMax: splitMax
		  %% NOTE: 'random' and 'heuristic' value orderings defined directly in
		  %% MakeSearchScript

		  %%
		  %% OLD stuff below, for information only 
		  %%
		  %% Function returns a random value out of the
		  %% FD int X.
		  %%
		  %% !! This function must not be used in case of
		  %% recomputations during search -- see
		  %% MakeRandomDistributionValue below for an
		  %% alternative.
		  %%
		  %% !!!! Does Min ever occur?? 
% 		  random:fun {$ X}
% 			    Min = {FD.reflect.min X}
% 			    Max = {FD.reflect.max X}
% 			    Range = Max - Min
% 			 in
% 			    {FD.reflect.nextLarger
% 			     X
% 			     {GUtils.random Range} + Min - 1}
% 			 end
% 		    splitRandom:fun {$ X}
% 				   Min = {FD.reflect.min X}
% 				   Max = {FD.reflect.max X}
% 				   Rand1 = {GUtils.random Max-Min+1} + Min
% 				   Rand2 = {GUtils.random Max-Min+1} + Min
% 				in
% 				   {Min Rand1 Rand2}#{Max Rand1 Rand2}
% 				end
% 		    %% this is conceptially not clean (e.g. it finds always the same solution anyway)
% 		    splitMinRandom:fun {$ X}
% 				      Min = {FD.reflect.min X}
% 				      Max = {FD.reflect.max X}
% 				      Rand = {GUtils.random Max-Min+1} + Min
% 				   in
% 				      0#Rand
% 				   end
% 		    splitMaxRandom:fun {$ X}
% 				      Min = {FD.reflect.min X}
% 				      Max = {FD.reflect.max X}
% 				      Rand = {GUtils.random Max-Min+1} + Min
% 				   in
% 				      Rand#FD.sup
% 				   end
		 ))
      fun {PreProcessSpec Spec}
	 {Adjoin generic(filter: undet %% defaults
			 order: size
			 select: value
			 value: min)
	  case Spec
	     %% specs predefined by a single atom
	  of ff then generic
	  [] firstTimingFF then generic(order: timeParamsAndSize)
	  [] startTime then generic(order: startTime)
	     %% spec defined by record
	  else Spec
	  end}
      end
      fun {SelectFn Feature Spec}
	 Input=Spec.Feature 
      in
	 if {IsProcedure Input}
	    %% user gave procedure at feature 
	 then Input		
	    %% user gave atom for predefined procedure at feature
	 elseif {IsAtom Input} andthen 
	    {HasFeature PredefinedFns.Feature Input}
	 then PredefinedFns.Feature.Input
	 else {Exception.raiseError
	       strasheela(failedRequirement
			  Input
			  "Value must be procedure, or is one element from the following list of atoms: "#{Value.toVirtualString {Arity PredefinedFns.Feature} 1000 1000})}
	    unit		% never returned
	 end
      end
   in
      /** %% [obsolete function] Function returns a specification of a distribution strategy (i.e. an argument for FD.distribute) for parameter score objects. The result of MakeFDDistribution is a FD distribution strategy specification as expected by FD.distribute (see http://www.mozart-oz.org/documentation/system/node26.html). However, the distribution defined by MakeFDDistribution always distributes score parameter objects, not plain variables.
      %%
      %% NOTE: Using MakeFDDistribution is discouraged, better use MakeSearchScript. 
      %% */
      fun {MakeFDDistribution Spec}
	 FullSpec = {PreProcessSpec Spec}
      in
	 {Adjoin
	  generic(filter: {SelectFn filter FullSpec}
		  order: {SelectFn order FullSpec}
		  select: {SelectFn select FullSpec}
		  value: {SelectFn value FullSpec})	    
	  if {HasFeature Spec procedure}
	  then generic(procedure: Spec.procedure)
	  else generic
	  end}
      end

   end				

   /** %% Returns a search script (a unary procedure) whose solution is a score. ScoreScript is a unary proc expressing a whole search problem involving a score as its solution, however without specifying any distribution strategy. Args is a record specifying the score distribution strategy with the same features as expected by FD.distribute for a distribution strategy (filter, order, select, value, and procedure) and the additional feature test. The distribution strategy features have mostly the same meaning and usage as in FD.distribute, for example, all these arguments support procedures as values (for details, see http://www.mozart-oz.org/documentation/system/node26.html). However, the distribution defined by MakeSearchScript always distributes score parameter objects, not plain variables. For example, the predefined select-procedure 'value' is defined as follows

   fun {$ X} {X getValue($)} end

   %%
   %%
   %% MakeSearchScript extends the set of predefined values for filter, order, select, value, and procedure already defined by FD.distribute. The following values are supported. 
   %%
   %% filter:
%     undet: Considers only parameter objects with undetermined value.
%     unary Boolean function P: Considers only the parameter objects X, for which {P X} yields true. 
   %%
   %% order:
%    'naive': Selects the first parameter object.
%    'size' or 'dom': Selects the first parameter, whose value domain has the smallest size.
%    'width': Select the first parameter with the smallest difference between the domain bounds of its value. 
%    'nbSusps' or 'deg+dom': Selects a parameter with the largest number of suspensions on its value, i.e., with the larges number of constraint propagators applied to it. In in case of ties (i.e. this is equal for several parameters), then take the first parameter with the smallest value domain.
%    'dom+deg': Selects the first parameter, whose value domain has the smallest size. In case of ties take the first parameter with the larges number of constraints applied to it.
%    'dom/deg': Selects the first parameter for which the quotient of domain size and number of suspended propagators is maximum. 
%    'min': Selects the first parameter, whose value's lower bound is minimal.
%    'max': Selects the first parameter, whose value's lower bound is maximal.
%    'timeParams': Selects the first temporal parameter object.
%    'timeParamsAndSize': Selects the first parameter, whose value domain has the smallest size, but always selects temporal parameter objects first.
%    'startTime' or 'leftToRight': Left-to-right distribution: Selects a parameter object whose associated temporal item has the smallest start time. Temporal parameters are preferred over other parameters. Note: the outmost temporal container msut have a determined startTime.
%    binary Boolean function P: Selects the first parameter objects which is minimal with respect to the order relation P.   
   %%
   %% select: 
%    value: selects the parameter value (a variable).
%    unary function P: accesses a variable from the parameter object selected by order and filter.   
   %%
   %% value:  
%    min: Selects the lower bound of the domain.
%    max: Selects the upper bound of the domain.
%    mid: Selects the value, which is closest to the middle of the domain (the arithmetical means between the lower and upper bound of the domain). In case of ties, the smaller element is selected.
%    splitMin: Selects the interval from the lower bound to the middle of the domain (see mid).
%    splitMax: Selects the interval from the element following the middle to the upper bound of the domain (see mid).
%    random: Selects a domain value at random. This value ordering is deterministic, i.e., recomputation is supported.
%    ternary procedure {P X SelectFn ?Dom}: where X is the parameter object selected by order and filter, SelectFn is the function given to the select argument, and Dom is the resulting domain specification. Dom serves as the restriction on the parameter value to be used in a binary distribution step (Dom in one branch, compl(Dom) in the other).
   %% NB: the interface of this function is changed compared to FD.distribute.
   %%
   %% The feature test expects a unary boolean function: all score parameters fulfilling the test are distributed.
   %%
   %% The following are the defaults for Args. Note the argument test, which specifies that by default container parameters are ignored by the distribution. 
   unit(filter: undet 
	order: size
	select: value
	value: min
	test:fun {Test X}
		{Not {{X getItem($)} isContainer($)}}
	     end)
   %% */
   %%
   fun {MakeSearchScript ScoreScript Args}
      Defaults = unit(test: fun {$ X}
			       {Not {{X getItem($)} isContainer($)}}
			       %% offsets are determined: only look
			       %% at durations (then startTime and
			       %% endTime get determined as well)
%			       {Not {X isTimePoint($)}} andthen
			    end)
      ActualArgs = {Adjoin Defaults Args}
      DistributionArgs = {Record.subtract ActualArgs test}
      Test = ActualArgs.test
   in
      proc {$ MyScore}
	 %% TODO: add value:splitRandom
	 MyDistro
	 = case DistributionArgs of unit(value:random ...)
	   then {Adjoin {MakeFDDistribution {Record.subtract DistributionArgs value}}
		 generic(value:{MakeRandomDistributionValue
				{GUtils.makeRandomGenerator}})}
	   [] unit(value:heuristic ...)
	   then {Adjoin {MakeFDDistribution {Record.subtract DistributionArgs value}}
		 generic(value:{MakeHeuristicValueOrder
				{GUtils.makeRandomGenerator}})}
	   else {MakeFDDistribution DistributionArgs}
	   end      
      in
	 MyScore = {ScoreScript}
	 {FdDistribute MyDistro
	  {MyScore collect($ test:fun {$ X}
				     {X isParameter($)} andthen
				     {Test X}
				  end)}}
      end
   end
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Solver defs
%%%

   
   /** %% Calls Search.base.one with a script created by MakeSearchScript. The meaning of the arguments ScoreScript and Args are the same as for MakeSearchScript.
   %% */
   fun {SearchOne ScoreScript Args}
      {Search.base.one {MakeSearchScript ScoreScript Args}}
   end
   /** %% Calls Search.base.all with a script created by MakeSearchScript. The meaning of the arguments ScoreScript and Args are the same as for MakeSearchScript.
   %% */
   fun {SearchAll ScoreScript Args}
      {Search.base.all {MakeSearchScript ScoreScript Args}}
   end
   /** %% Calls Search.base.best with a script created by MakeSearchScript. The meaning of the arguments ScoreScript and Args are the same as for MakeSearchScript. Best solution is performed with respect to OrderP (a binary procedure). 
   %% */
   fun {SearchBest ScoreScript OrderP Args}
      {Search.base.best {MakeSearchScript ScoreScript Args}
       OrderP}
   end


   local
      %% Returns the best solution found within MaxTime milliseconds.
      %% By Raphael Collet (mail to users@mozart-oz.org on 5 Januar 2010).

      %% Drives the search engine by using an object of the class
      %% Search.object.  Here is an implementation of SearchBest, with
      %% an extra argument (MaxTime).  It is guaranteed to return the
      %% best solution found after MaxTime milliseconds.

      proc {SearchBaseBest_Timeout ScriptP OrderP MaxTime ?Xs}
	 %% the search engine
	 Engine={New Search.object script(ScriptP OrderP rcd:5)}
	 
	 %% iterate through solutions, and return the best solution found
	 fun {Iterate CurrentSol}
	    case {Engine next($)} of [X] then
	       {Iterate [X]}
	    else
	       CurrentSol
	    end
	 end
      in
	 %% stop the engine after MaxTime
	 thread
	    {Time.delay MaxTime} {Engine stop}
	 end
	 
	 Xs={Iterate nil}
      end
   in
      /** %% Similar to SearchBest, but after MaxTime milliseconds have passed SearchBestWithTimeout returns the best solution found so far.
      %% */
      fun {SearchBest_Timeout ScoreScript OrderP MaxTime Args}
	 {SearchBaseBest_Timeout {MakeSearchScript ScoreScript Args}
	  OrderP MaxTime}
      end
   end

   
   /** %% Calls Search.one.depth with a script created by MakeSearchScript. The meaning of the arguments ScoreScript and Args are the same as for MakeSearchScript.
   %% RcdI (an int) is the recomputation distance, and KillP (a nullary procedure) kills the search engine, for details see http://www.mozart-oz.org/documentation/system/node11.html.  
   %% */
   fun {SearchOneDepth ScoreScript RcdI Args ?KillP}
      {Search.one.depth {MakeSearchScript ScoreScript Args} RcdI KillP}
   end
   
   /** %% Calls Explorer.one with a script created by MakeSearchScript. The meaning of the arguments are the same as for MakeSearchScript.
   %% */
   proc {ExploreOne ScoreScript Args}
      {Explorer.one {MakeSearchScript ScoreScript Args}}
   end
   /** %% Calls Explorer.all with a script created by MakeSearchScript. The meaning of the arguments are the same as for MakeSearchScript.
   %% */
   proc {ExploreAll ScoreScript Args}
      {Explorer.all {MakeSearchScript ScoreScript Args}}
   end
   /** %% Calls Explorer.best with a script created by MakeSearchScript. The meaning of the arguments ScoreScript and Args are the same as for MakeSearchScript. Best solution is performed with respect to OrderP (a binary procedure). 
   %% */
   proc {ExploreBest ScoreScript OrderP Args}
      {Explorer.best {MakeSearchScript ScoreScript Args}
       OrderP}
   end

   
   
end				



