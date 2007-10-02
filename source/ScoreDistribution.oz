
%%% *************************************************************
%%% Copyright (C) 2002-2005 Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

										    
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
/*
fun {Order Xs Fn}
   {Sort Xs Fn}
end
*/


/** %% The functor defines means to generate distribution strategies particularily tailored for a score search.
% */

	
functor 
import 
   FD Search Explorer
   GUtils at 'GeneralUtils.ozf'
   LUtils at 'ListUtils.ozf'
   % Score at 'ScoreCore.ozf'
   % Browser(browse:Browse) % temp for debugging
export 
   MakeFDDistribution
   MakeSearchScript
   SearchOne SearchAll SearchBest
   ExploreOne ExploreAll ExploreBest
   MakeRandomDistributionValue
   MakeSetPreferredOrder MakeSetPreferredOrder2
define
   %%
   %% General means to define score distribution strategies
   %%
   local
      fun {IsTimeParameter X}
	 %% ?? shall I test only for TimeInterval or for time point too?
	 {X isTimeInterval($)} orelse {X isTimePoint($)}
      end
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
	   fns(naive: naive
	       size: fun {$ X Y}
			{FD.reflect.size {X getValue($)}}
			=<
			{FD.reflect.size {Y getValue($)}}
		     end
	       width: fun {$ X Y}
			 {FD.reflect.width {X getValue($)}}
			 =<
			 {FD.reflect.width {Y getValue($)}}
		      end
	       nbSusps: fun {$ X Y}
			   L1 = {FD.reflect.nbSusps {X getValue($)}}
			   L2 = {FD.reflect.nbSusps {Y getValue($)}}
			in
			   L1>L2 orelse
			   (L1==L2 andthen
			    {FD.reflect.size {X getValue($)}}
			    =<
			    {FD.reflect.size {Y getValue($)}})
			end
	       min: fun {$ X Y}
		       {FD.reflect.min {X getValue($)}}
		       =<
		       {FD.reflect.min {Y getValue($)}}
		    end
	       max: fun {$ X Y}
		       {FD.reflect.max {X getValue($)}}
		       >=
		       {FD.reflect.max {Y getValue($)}}
		    end
	       timeParams: fun {$ X _} 
			      {IsTimeParameter X}
			   end
	       %% If only one of X or Y is timing parameters, then
	       %% return boolean such that timing parameter is put 
	       %% first. If both or non of X and Y are timing 
	       %% parameters, then return boolean such that parameter
	       %% with smaller domain size is preferred.
	       timeParamsAndSize: fun {$ X Y}
				     B =  {IsTimeParameter X}
				  in
				     if {GUtils.xOr B {IsTimeParameter Y}}
				     then B
				     else
					{FD.reflect.size {X getValue($)}}
					=<
					{FD.reflect.size {Y getValue($)}}
				     end
				  end
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
	       startTime: fun {$ X Y}
			     S1 = {{X getItem($)} getStartTime($)}
			     S2 = {{Y getItem($)} getStartTime($)}
			     IsS1Bound = ({FD.reflect.size S1}==1)
			  in
			     %% if start time of both elements are bound
			     %%
			     %% !! ?? andthen is not enough
			     %%if {And IsS1Bound ({FD.reflect.size S2}==1)}
			     if IsS1Bound andthen ({FD.reflect.size S2}==1)
			     then
				%% if start times are equal prefer
				%% timing params, otherwise prefer
				%% param whose item has smaller start
				%% time
				if S1==S2
				then {X isTimeParameter($)}
				   %% old:
%				   {X isTimePoint($)} orelse
%				   {X isTimeInterval($)} 
				else S1 =< S2	
				end
			     else IsS1Bound
			     end
			  end)
	   select: 
	      %% !! value feature to document 
	   fns(value: fun {$ X} {X getValue($)} end)
	   value: 
	      fns(min: min %FD.reflect.min
		  max: max %FD.reflect.max
		  mid: mid %FD.reflect.mid
		  splitMin: splitMin
		  splitMax: splitMax
		  %% Function returns a random value out of the
		  %% FD int X.
		  %%
		  %% !! This function must not be used in case of
		  %% recomputations during search -- see
		  %% MakeRandomDistributionValue below for an
		  %% alternative.
		  %%
		  %% 
%% * I can not change state in the global space directly from within a local space. But I can do this with a port!
%% see Christians book (p. 40) or Moz mailing list: raph@info.ucl.ac.be: Re: memoization + search script. 4. Mai 2006 12:53:05 MESZ 
%%.
		  %%
		  %% !!!! Does Min ever occur?? 
		  random:fun {$ X}
			    Min = {FD.reflect.min X}
			    Max = {FD.reflect.max X}
			    Range = Max - Min
			 in
			    {FD.reflect.nextLarger
			     X
			     {GUtils.random Range} + Min - 1}
			 end
% 		  %% -- this is unfinished work: requires to redefine script generator such that distributor is given as proc expecting parameters to propagate
		  %% TMP: this now even works for recomputation (but MakeFDDistribution must be called within script)
% 		  random:local RandGen = {GUtils.makeRandomGenerator}
% 			 in {SDistro.makeRandomDistributionValue RandGen}
% 			 end
% 		    randomOld: fun {$ X}
% 				  %% !! highly inefficient, especially
% 				  %% for for large domains
% 				  XL = {FD.reflect.domList X}
% 				  N = {GUtils.random {Length XL}-1}+1
% 			       in
% 				  {Nth XL N}
% 			       end
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
      /** %% Function returns a specification of a distribution strategy (i.e. an argument for FD.distribute) for parameter score objects. The reader is asked to first read the documentation for FD.distribute.
      %%
      %% The result of MakeFDDistribution is a record with the functions specifying a FD distribution strategy (i.e. a record with the features filter, order, etc.). The specified distribution strategies differ slightly from the default distribution strategies of FD.distribute: the functions at the features filter, order and select handle parameter score objects. 
      %%
      %% The user can access some predefined distribution strategies by giving an atom to the argument Spec: 
      %% 
      %% <code>ff</code>: Specifies a first fail distribution for score parameters, i.e. parameters with smallest domain size are determined first.
      %% <code>firstTimingFF</code>: Timing parameters are determined first. Parameters with smaller value domain size are preferred.
      %% <code>startTime</code>: Parameters are determined in the order of the stratTime of the item the parameter belong to. Parameters with smaller value domain size are preferred. 
      %%
      %% The user may specify new score distribution strategies by specifying a subset of the functions at the features filter, order, select, value, and procedure to the argument Spec of MakeFDDistribution. However, some functions are already predefined for each feature and can be specified by an atom.
      %%
      %% filter: undet
      %% order: size timeParams timeParamsAndSize startTime
      %% select: value
      %% value: min random
      %% <!! unfinished doc -- see code>
      %%
      %% Features missing in Spec are taken form the default specification, which is a first fail distribution strategy for parameter score objects.
      %% <!! add defaults> 
      %%
      %% */
      %% !! unfinished comment
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

   /** %% Returns a search script (a unary procedure) whose solution is a score.  ScoreScript is a unary proc expressing whole search problem involving a score as its solution, however without specifying any distribution strategy. Args is a record specifying the score distribution strategy with the usual features for a distribution strategy (filter, order, select, value, and procedure) and the additional feature test. The distribution strategy features have the same meaning and usage as in MakeFDDistribution. The feature test expects a unary boolean function: all score parameters fulfilling the test are distributed. Test defaults to the following (NB: for this case, the offsetTime of temporal items must be determined).
   fun {Test X}
      {Not {X isTimePoint($)}} andthen
      {Not {{X getItem($)} isContainer($)}}
   end
   %% */
   fun {MakeSearchScript ScoreScript Args}
      Defaults = unit(test: fun {$ X}
			       %% offsets are determined: only look
			       %% at durations (then startTime and
			       %% endTime get determined as well)
			       {Not {X isTimePoint($)}} andthen
			       {Not {{X getItem($)} isContainer($)}}
			    end)
      ActualArgs = {Adjoin Defaults Args}
      DistributionArgs = {Record.subtract ActualArgs test}
      Test = ActualArgs.test
   in
      proc {$ MyScore}
	 MyScore = {ScoreScript}
	 {FD.distribute
	  {MakeFDDistribution DistributionArgs}
	  {MyScore collect($ test:fun {$ X}
				     {X isParameter($)} andthen
				     {Test X}
				  end)}}
      end
   end
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

   /** %% Defines a means for a 'random distribution', i.e., for a FD distribution strategy which randomly decides for a domain value of a variable in a deterministic (i.e. recomputable) way. 
   %% MakeRandomDistributionValue returns a binary procedure for the argument 'value' of FD.distribute. The argument RandGen is a nullary function generated by GUtils.makeRandomGenerator.
   %% */
   fun {MakeRandomDistributionValue RandGen}
      fun {$ X}
	 Rand = {GUtils.randIntoRange  {RandGen} % pseudo-random number generated here
		 {FD.reflect.min X} {FD.reflect.max X}}
      in
	 {FD.reflect.nextSmaller X Rand+1}
      end
   end

   
   local
      fun {GetTestIndex Param Tests}
	 {LUtils.findPosition Tests fun {$ Test} {Test Param} end}
      end
   in
      /** %% Returns a score distribution strategy 'order' procedure. Tests is a list of unary boolean funcs which expect a parameter. The distribution 'prefers' parameters for which a test with smaller index in Tests returns true. In case of two parameters with equal 'test index' the strategy decides for the first param.
      %% */
      fun {MakeSetPreferredOrder2 Tests}
	 %% append default (always returning true) at end
	 AllTests = {Append Tests [fun {$ X} true end]}
      in
	 fun {$ X Y}
	    XI = {GetTestIndex X AllTests}
	    YI = {GetTestIndex Y AllTests}
	 in
% 	    if XI =< YI
% 	    then true
% 	    else false
% 	    end
	    XI =< YI
	 end
      end
      /** %% Returns a score distribution strategy 'order' procedure. Tests is a list of unary boolean funcs which expect a parameter. The distribution 'prefers' parameters for which a test with smaller index in Tests returns true. IfEqual is a binary boolean function which 'decides' in case for two parameters with equal 'test index'.
      %% More general Variation of MakeSetPreferredOrder2. Which strategy variant is more efficient depends on the problem.. 
      %% */
      fun {MakeSetPreferredOrder Tests IfEqual}
	 %% append default (always returning true) at end
	 AllTests = {Append Tests [fun {$ X} true end]}
      in
	 fun {$ X Y}
	    XI = {GetTestIndex X AllTests}
	    YI = {GetTestIndex Y AllTests}
	 in
	    if XI < YI
	    then true
	    elseif YI == XI
	    then {IfEqual X Y}
	    else false
% 	    elseif YI < XI
% 	    then false
% 	    else {IfEqual X Y}
	    end
	 end
      end
   end
end				



