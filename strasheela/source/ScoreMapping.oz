
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

/**
%% The functor defines higher-order means to traverse a score and/or apply procedures (e.g. rules) on a score.
%% 
%% For instance, the functor exports a mixin class which understands various higher-order mapping methods. The methods recursively traverse an hierarchic score data structure. Mapping here means applying a given function/procedure to all elements of a specified set of items in the score, collecting or counting all items fulfilling a given predicate etc.
*/

%%
%% TODO
%%
%% (1) redefine find quasi as findThreaded -- a variant of forAllThreaded which traverses score hierarchy and immediately returns as soon as it finds a single objects which fulfills some test function/method
%%   -> use a port to cummunicate between branches of the find score traversal: everyone reports a result to the common port, and as soon port got a result this is returned and all other traversal branches stop.
%%
%%  -> this can be used, for example, to efficiently find the only chord or measure which is simultaneous to a given note. 
%%  e.g. I can then define getFirstSimultaneousItem($ test:Test)
%%  This method does not need to wait until the whole temporal structure is determined. Together with a smart distribution strategy (e.g. left-to-right with preference for chord and measure objects..) it can considerably simplify the definition of harmonic/metric CSPs -- I can delay rule application instead of using logical connectives..
%%  NB: this only works for plain sequences of chords, measures, scales.. If I want to model modulation by overlapping scales then this will not work as I may need access to BOTH scales. 
%%    
%% -> for generality I may also define a collectThreaded which returns a stream. The subcomputations in collectThreaded can deliver their output via a common port.  
%%
%%
%% (2) There seems to be some bug in the 'flagging' of score objects: there remain flages after collect returns.. 
%%

functor 
import
   FD
   LUtils at 'ListUtils.ozf' %at 'x-ozlib://anders/music/sdl/Utils.ozf'
   GUtils at 'GeneralUtils.ozf'
   %% !! functor of Strasheela core depending on extension
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   Browser(browse:Browse) % temp for debugging
export
   
   MappingMixin
   
   ApplyToContext ApplyToContext2 ApplyToContextR
   ForContexts MapContexts ForContextsR
   PatternMatchingApply PatternMatchingApply2
   ForNumericRange ForNumericRange2 ForNumericRangeArgs
   
define

   
   /** %% [auxiliary class] adds flag support to all score objects. 
   %% */
   %% !!?? Bug: are all flags always cleanly removed?
   class FlagsMixin
      attr flags 
	 /** %% [aux method] Method must not be called by user. 
        % */
      meth initFlags @flags = {Dictionary.new} end
      /** %% Adds an arbitrary flag F to self. A flag must be a literal. 
      %*/
      meth addFlag(F)
	 {Dictionary.put @flags F true}
      end
      /** %% Tests whether self has flag F. Method returns a boolean. 
      %*/
      %% @1=?B	
      meth hasFlag(?B F)
	 {Dictionary.condGet @flags F false B}
      end
      /** %% Removes flag F from self. 
	 %*/
      meth removeFlag(F)
	 {Dictionary.remove @flags F}
      end
      /** %% [aux method] Method should not be called by user (method removes all flags from self).  
      %*/
      meth removeAllFlags
	 {Dictionary.removeAll @flags}
      end
   end

   local
      %% a number of aux functions for the collect method of class MappingMixin
      %% (def outside to avoid redef)
      fun {RemoveFlaggedItems Xs Flag}
	 {Filter Xs fun {$ X} {Not {X hasFlag($ Flag)}} end}
      end
      proc {FlagAll Xs Flag}  
	 {ForAll Xs proc {$ X} {X addFlag(Flag)} end}
      end
      proc {UnFlagAll Xs Flag} 
	 {ForAll Xs proc {$ X} {X removeFlag(Flag)} end} 
      end
      proc {GetContainers X Mode Level Flag ?Containers}
	    % bind Containers with containers of X to traverse
	 if Mode==graph andthen 
	    (Level==all orelse ({IsInt Level} andthen Level>0))
	 then 
	    Containers = {RemoveFlaggedItems {X getContainers($)} Flag}
	    {FlagAll Containers Flag}
	 elseif Mode==tree orelse {X isTopLevel($)}
	 then Containers = nil
	 end
      end
      proc {GetItems X Mode Level Flag ?Items}
	    % bind Items with items of X to traverse
	 if {X isContainer($)} andthen 
	    (Level==all orelse ({IsInt Level} andthen Level>0))
	 then 
	    Items = {RemoveFlaggedItems {X getItems($)} Flag}
	    {FlagAll Items Flag}
	 else Items = nil 
	 end
      end
      fun {DecrLevel Level}
	 if {IsInt Level}
	 then Level-1
	 else Level=all 	% 'tests' and returns level 
	 end
      end
      fun {CollectAux X Mode Level Test Flag} 
	 Containers = {GetContainers X Mode Level Flag}
	 Items = {GetItems X Mode Level Flag}	 
	 %% !! Append needs determined sublists (I thought about
	 %% streams bound to container attr items
	 %% Xs={Append Containers Items} 
	 AllItems = {Append Containers Items}
	 AllObjects = {Append AllItems
		       {Append 
			{LUtils.mappend Containers 
			 fun {$ X} {X getParameters($)} end}
			{LUtils.mappend Items 
			 fun {$ X} {X getParameters($)} end}}}
      in  
% 	 Xs={FoldL [Containers Items 
% 		    {LUtils.mappend Containers fun {$ X} {X getParameters($)} end}
% 		    {LUtils.mappend Items fun {$ X} {X getParameters($)} end}]
% 	     Append nil}
	 %% traverse and return
	 {Append {Filter AllObjects Test} % only collect objects fulfilling test
	  {LUtils.mappend AllItems
	   fun {$ X} {CollectAux X Mode {DecrLevel Level} Test Flag} end}}
      end
      %%
      proc {ForAllThreadedAux X Proc Test Mode Level Flag}
	 %% traverses X and all objects related to X (i.e. containers,
	 %% items and parameters) and applies Proc on every object which
	 %% returns true for Test. Traversing happens concurrently, thus
	 %% ForAllTreeAux does not suspend if result of getContainers,
	 %% getItems or getParameters is not yet fully bound.
	 {ForAllContainersThreaded X Proc Test Mode Level Flag}
	 {ForAllItemsThreaded X  Proc Test Mode Level Flag}
      end
      proc {ProcessThreaded X Proc Test Mode Level Flag}
	 %% apply Proc on X and its params, if they fulfill Test and
	 %% are unflagged. 
	 if {Test X} andthen {Not {X hasFlag($ Flag)}}
	 then
	    {Proc X}
	    thread		% process params of X
	       {ForAll {X getParameters($)}
		proc {$ X} if {Test X} then {Proc X} end end}
	    end
	    {X addFlag(Flag)}
	    %% recursive call
	    {ForAllThreadedAux X Proc Test Mode {DecrLevel Level} Flag}
	 end
      end
      proc {ForAllContainersThreaded X Proc Test Mode Level Flag}
	 if Mode==graph andthen 
	    (Level==all orelse ({IsInt Level} andthen Level>0)) 
	 then
	    thread 
	       {ForAll {X getContainers($)}
		proc {$ X}
		   {ProcessThreaded X Proc Test Mode Level Flag}
		end}
	    end
	 end
      end
      proc {ForAllItemsThreaded X  Proc Test Mode Level Flag}
	 if {X isContainer($)} andthen 
	    (Level==all orelse ({IsInt Level} andthen Level>0))
	 then
	    thread
	       {ForAll {X getItems($)}
		proc {$ X}
		   {ProcessThreaded X Proc Test Mode Level Flag}
		end}
	    end
	 end
      end
%       proc {ForAllThreadedAux X Proc Test}
% 	 thread
% 	    {ForAll X|{X getParameters($)} 
% 	     proc {$ X} if {Test X} then {Proc X} end end}
% 	 end
% 	 if {X isContainer($)}
% 	 then 
% 	    thread
% 	       {ForAll {X getItems($)} 
% 		proc {$ X} {ForAllThreadedAux X Proc Test} end}
% 	    end
% 	 end
%       end
   in
      /** %% [abstract class] A mixin class for various traversing and mapping methods on the whole score hierarchy.
      */
      class MappingMixin from FlagsMixin
	 /** %% The collect methods collects (possibly all) score objects in a list to make them accessible for, e.g., various list mapping functions. The method collects objects related to self (an item) by the value of the item attributes containers, parameters and the container attribute items. However, collect never collects self itself (self can easily be added, but removing self requires traversing the full result list). The methods supports a few features to control the collecting. 
	 %%
	 %% If feature <code> mode </code> is set to <code> tree </code> (the default), collect recursively collects the score objects and subobjects contained in self (i.e. both the attributes items and parameters are traversed). If <code> mode </code> is set to <code> graph</code>, both objects contained in self and containers self is contained in are collected (i.e. all three attributes items, parameters, and containers are traversed).
	 %%
	 %% If feature <code> level </code> is set to <code> all </code> (the default), collect collects score objects recursively into arbitrary depth. However, the depth can be controlled by specifying an integer value for <code> level</code>.
	 %%
	 %% The feature <code> test </code> expects a unary function returning a boolean or an atom representing a boolean unary method understood by all objects in self. The method collect only collects score objects fulfilling the test function/method.
	 %%
	 %% collect visits containers in depth-first fashion from left to right which affects the order of the objects in the returned list. E.g., collecting all events in a few nested sequentials in tree mode returns a list with all events ordered by start time.
	 %%
	 %% NB: collect blocks if self is not fully initialised (e.g. created by Score.makeScore2) or if Test blocks at some object in self (e.g. because the object is only partially determined).
	 %%*/
	 %% @1=?Xs	
	 meth collect(?Xs mode:Mode<=tree level:Level<=all
		      test:Test<=fun {$ X} true end)
	    Flag = {Name.new}
	    TestFn = {GUtils.toFun Test}
	 in
	    %% !! unefficient: performs checks for Test, Level etc. even
	    %% if they are not given/needed. Also order of test may be
	    %% unefficient
	    %% TODO: select appropriate function depending to args
	    %% (e.g. mode) for efficiency
	    %% !! return of parameters added later: cluttered code
	    {self addFlag(Flag)} % exclude self, ...
	    Xs = {Append 
		  %% ..., but collect params of self
		  {Filter {self getParameters($)} TestFn} 
		  {CollectAux self Mode Level TestFn Flag}}
	    %% BUG: only unflags object in result Xs, but not other flagged items.. (instead, I would need to fully traverse hierarchic structure again).
	    %% Trick for reducing flags: only flag at all if Mode==graph.
	    {UnFlagAll 
	     %% params are never flagged 
	     self | {Filter Xs fun {$ X} {Not {X isParameter($)}} end} 
	     Flag}   
	 end
	 /** %% The method forAll maps the procedure Proc to a number of collected score objects. Proc may also be an atom representing a method of no arguments and understood by all objects in self fulfilling Test. The method supports the features <code> mode</code>, <code> level</code>, and <code> test</code>. These features have the same meaning as in the method collect.
	 % */
	 % !! ?? rewrite all collect code -- calling collect may suspend, but a 'threaded' forAll can reach (every ?) score object anyway... 
	 meth forAll(Proc mode:Mode<=tree level:Level<=all
		     test:Test<=fun {$ X} true end)
	    {ForAll {self collect($ mode:Mode level:Level test:Test)}
	     {GUtils.toProc Proc}}
	 end
	 /** %% The method traverses all score objects in self (i.e. items and parameters) and applies unary procedure (or null-ary method) Proc on every object returning true for the unary function (or unary method) Test. However, the method does not effect the object self itself -- only the parameters and (if self is a container) items of self are effected recursively. Traversing happens concurrently -- the method does not suspend even if the result of getItems or getParameters is not yet fully determined.
	 %% */
	 %% !! shall I do more fine grained 'threadening' (e.g. not only processing of all parameters/items of an item/container in an own thread, but instead the processing of each object in a thread) ?? shall the degree of threadening be user-controllable
	 %% I can do the process of each object in a thread by defining a thread in Proc
	 meth forAllThreaded(Proc mode:Mode<=tree level:Level<=all
			     test:Test<=fun {$ X} true end)
	    Proc1 = {GUtils.toProc Proc}
	    Test1 = {GUtils.toFun Test}
	    Flag = {Name.new}
	 in
	    %% !! code doubling (see ProcessThreaded) to avoid
	    %% processing self (if necessary, self can easily
	    %% processed directly)
	    thread 		% process self parameters
	       {ForAll {self getParameters($)} 
		proc {$ X} if {Test1 X} then {Proc1 X} end end}	       
	    end
	    {self addFlag(Flag)}
	    {ForAllThreadedAux self Proc1 Test1 Mode Level Flag}
	    %% BUG: Flags are never removed from objects? Trick: only
	    %% flag at all if Mode==graph.  see method collect for
	    %% more discussion..
	 end
	 /** %% The method map maps the function Fn to a number of collected score objects and returns a list with all results. Fn may also be an atom representing a unary method understood by all objects in self fulfilling Test. The method supports the features <code> mode</code>, <code> level</code>, and <code> test</code>. These features have the same meaning as in the method collect.
	 %*/
	 %% @1=?Xs
	 meth map(?Xs Fn mode:Mode<=tree level:Level<=all
		  test:Test<=fun {$ X} true end)
	    Xs = {Map {self collect($ mode:Mode level:Level test:Test)}
		  {GUtils.toFun Fn}}
	 end
	 /** %% The method map maps the function Fn (which must return a list) to a number of collected score objects and returns a list with all results appended. Fn may also be an atom representing a unary method understood by all objects in self fulfilling Test. The method supports the features <code> mode</code>, <code> level</code>, and <code> test</code>. These features have the same meaning as in the method collect.
	 %*/
	 %% @1=?Xs
	 meth mappend(?Xs Fn mode:Mode<=tree level:Level<=all
		      test:Test<=fun {$ X} true end)
	    Xs = {LUtils.mappend {self collect($ mode:Mode level:Level test:Test)}
		  {GUtils.toFun Fn}}
	 end
	 /** %% The method count counts a number of collected score objects. The method supports the features <code> mode</code>, <code> level</code>, and <code> test</code>. These features have the same meaning as in the method collect.
	 %*/
	 %% @1=?N
	 meth count(?N  mode:Mode<=tree level:Level<=all
		    test:Test<=fun {$ X} true end)
	    N = {Length {self collect($ mode:Mode level:Level test:Test)}}
	 end
	 /** %% The method filter collects a number of score objects fulfilling Fn, a the unary function returning a boolean. The method supports the features <code> mode</code>, and <code> level</code>. These features have the same meaning as in the method collect.
	 %*/
	 %% NB: filter must traverse all objects, therefore using collect in the definition is OK.
	 %% ?? order of args
	 %% @1=?Xs
	 meth filter(?Xs Fn mode:Mode<=tree level:Level<=all)
	    Xs = {self collect($ mode:Mode level:Level test:Fn)}
	 end
	 /** %% The method find returns the first score object in self fulfilling Fn, a the unary function returning a boolean. The method supports the features <code> mode</code>, and <code> level</code>. These features have the same meaning as in the method collect.
	 %%
	 %% NB: this implementation is inefficient (first collects all score objects).
	 %*/
	 %% ?? order of args
	 %% @1=?Xs
	 %%
	 %% !! implementation inefficient: I first collect all...
	 meth find(?X Fn mode:Mode<=tree level:Level<=all)
	    Temp = {self collect($ mode:Mode level:Level test:Fn)}
	 in
	    if Temp==nil
	    then X = nil
	    else X = Temp.1
	    end
	 end

	 /*
	 %% The method findThreaded was intended as better means
	 %% accessing score contexts undetermined in the problem
	 %% definition for delayed constraint application. Meanwhile,
	 %% I realised that plain filtering with a more suitable test
	 %% is a better approach. The more suitable test is a reified
	 %% constraint together with an equality test, for example,
	 
	 {ForAll {MyScore filter($ fun {$ X}
			     {X isNote($)} andthen
			     X \= MyNote andthen % ignore Note
			     {MyNote isSimultaneousItemR($ X)} == 1
			  end)}
	  MyConstraint}

	 %% Because this approach is far better than using
	 %% findThreaded I just remove the definition of findThreaded
	 %% in order to avoid confusion. I just keep the definition
	 %% in a comment just in case..
	 %%
	 %%
	 %% The method find returns the first score object in self for which Fn -- a unary function returning a boolean -- returns true. The search is conducted concurrently: the result score object naturally must be determined enough that Fn does not block on it, but other objects in the score can even be partially bound only and cause Fn to block.
	 %% If Fn would return true for multiple objects in self, it is undetermined which object is returned. 
	 %% The method supports the features <code>mode</code>, <code>level</code>, and  <code>test</code>. These features have the same meaning as in the method collect.
	 %% 
	 meth findThreaded(?X Fn mode:Mode<=tree level:Level<=all test:Test<=fun {$ X} true end)
	    ObjectFound
	    MyLock = {NewLock}
	    %% As soon as ObjectFound is bound and if DontKillMe is unbound, then
	    %% KillIfFound terminates MyThread.
	    proc {KillIfFound MyThread DontKillMe}
	       thread
		  {Wait ObjectFound}
		  if {Not {IsDet DontKillMe}}
		  then {Thread.terminate MyThread}
		  end
	       end
	    end
	 in
	    {self forAllThreaded(proc {$ Y}
				    thread DontKillMe in
				       {KillIfFound {Thread.this} DontKillMe}
				       if {Fn Y} % may block
				       then
					  lock MyLock then
					     DontKillMe = unit
					     %% kills all other "spawned" procs
					     ObjectFound = unit
					     %% bind result
					     X = Y
					  end
				       end
				    end
				 end
				 mode:Mode level:Level test:Test)}
	 end
	 */
	 
	 %% ?? method name
	 %% ?? order of args
	 %% @2=?Xs
%       meth filterScore(?Xs Fn mode:Mode<=tree level:Level<=all)
% 	 Xs = {self collect($ mode:Mode level:Level
% 			    test:fun {$ X} {Not Fn} end)}
%       end
      
	 /*
	 meth transform(test:TestFn action:ActionProc
			mode:Mode<=tree reprocess:Reprocess<=false)
	    %% with Reprocess=false this is same as method forAll
	    fun {GetItems X}
	       if {X isContainer($)} 
	       then {X getItems($)}
	       else nil
	       end
	    end
	    fun {Aux Xs P}
	       case Xs of nil then nil %skip
	       [] X|Xr
	       then
		  Tail = if Reprocess
			 then {Filter
			       {Append {Append if Mode==graph
					       then {X getContainers($)}
					       else nil
					       end
					{GetItems X}}
				TestFn}
			       Xr}
			 else Xr end
	       in
		  {P X} 	%  Fun or Proc??
	       
		  {Aux Tail P}
	       end
	    end
	 in
	    {Aux {self collect($ mode:Mode level:all test:TestFn)}
	     ActionProc}
	 end			% end method def
	 */
      end  			% end class def
   end				% local end


   
   /** %% P (a unary proc or method) is applied to Context (any data structure), if this context is not empty. An empty context is represented by nil -- for such a context the application of P is skipped.
   %% NB: Application of P blocks until the context is determined.
   %% */
   %% !!?? where to put ApplyToContext and friends?
   proc {ApplyToContext Context P}
      if Context==nil
      then skip
      else {{GUtils.toProc P} Context}
      end
   end
   /** %% Variant of ApplyToContext: Fn (a unary function or method) is applied to Context and the result is returned. For an empty context, nil is returned
   %% */
   fun {ApplyToContext2 Context Fn}
      if Context==nil
      then nil
      else {{GUtils.toFun Fn} Context}
      end
   end
   /** %% B=1 <-> Rule holds for N non-empty context Candidates which pass the test IsContext.
   %% Args is a record with the five feats 'candidates', 'isContext', 'rule', 'n' and 'b'. Candidates is a list of context candidates (any data). IsContext (a unary function or method) expects such a context candidate and returns a 0/1-int reflecting whether the context is a valid or not. Rule (a unary function or method) is a reified constraint applied to any context candidate returning a 0/1-int. N (the atom 'any' or a FD int) specifies for how many contexts IsContext holds (i.e. returns 1). B=1 constrains that Rule holds for all these contexts. Nevertheless, Rule may hold for more candidates.
   %% Candidates, IsContext, and Rule are required arguments. N is optional (default is 'any') and B is optional (default is 1).
   %%
   %% NB: some internal FD ints (in IsContextBs and RuleBs) possibly remain undetermined.
   %% */
   %%
   %% Arguments given by record to make call of ApplyToContextR with its 5 args better read-able
   proc {ApplyToContextR Args}
      Defaults = unit(%% list of context candidates or null-ary fun/method returning list of candidates 
		      %% * candidates:nil
		      %% reified fun/method checking context
		      %% * isContext:proc {$ MyContext B} skip end
		      %% reified fun/method applied to context
		      %% * rule:proc {$ MyContext B} skip end
		      %% atom 'any' or FD int
		      n:any
		      %% 0/1 int
		      b:1)
      As = {Adjoin Defaults Args}
      IsContextBs		% list of 0/1-int
      RuleBs 
   in
      %% IsContextBs and RuleBs accessible as optional Args features
%       if {HasFeature Args isContextBs}
%       then IsContextBs = Args.isContextBs
%       end
%       if {HasFeature Args ruleBs}
%       then RuleBs = Args.ruleBs
%       end
      IsContextBs = {Map As.candidates     
		     fun {$ ContextC}
			if ContextC==nil
			then 0	% never enforce rule on empty context
			else {{GUtils.toFun As.isContext} ContextC}
			end
		     end}
      RuleBs = {Map As.candidates     
		fun {$ ContextC}
		   {{GUtils.toFun As.rule} ContextC}
% 		   if ContextC==nil
% 		   then 0	% never enforce rule on empty context
% 		   else {{GUtils.toFun As.rule} ContextC}
% 		   end
		end}
      if As.n \= any
      then As.n = {Pattern.howManyTrue IsContextBs}
      end
      As.b = {Pattern.allTrueR
	      {Map {LUtils.matTrans [IsContextBs RuleBs]}
	       fun {$ [IsContextB RuleB]} 
		  {FD.impl IsContextB RuleB}
	       end}}
   end

   %% old doc:
% %% B=1 <-> P holds for N non-empty context candidates of X which pass a user specified test.
% %% GetContextCandidates (a unary function or method) expects X (any data structure) and returns a list of contexts (any data structure) of X. IsContext (a unary function or method) expects such a context candidate and returns a 0/1-int reflecting whether the context is a context of X or not. To this end, GetContextCandidates is usually defined such that X is part of the returned context. For instance, each context candidate may be represented by a record of the form <code>unit(x:X simObjects:Sims ...)</code>.
% %% P (a unary function or method) is a reified constraint applied to any context candidate returning a 0/1-int. N (a FD int) specifies for how many contexts IsContext holds (i.e. returns 1). B=1 constrains that P holds for all these contexts.
% %%
   
% %% existing: objects in context
% proc {ApplyToContextR X GetContextCandidates IsContext N P B}
%    ContextCs = {{GUtils.toFun GetContextCandidates} X}
%    IsContextBs = {Map ContextCs     % list of 0/1-int 
% 		  fun {$ ContextC}
% 		     if ContextC==nil
% 		     then 0	% never apply P on empty context
% 		     else {{GUtils.toFun IsContext} ContextC}
% 		     end
% 		  end}
% in
%    N = {Pattern.howManyTrue IsContextBs}
%    B = {Pattern.allTrueR
% 	{Map {LUtils.matTrans [ContextCs IsContextBs]}
% 	 fun {$ [ContextC IsContextB]} 
% 	    {FD.impl IsContextB
% 	     {{GUtils.toFun P} ContextC}}
% 	 end}}
% end

   
   /** %% P (a unary proc) is applied to the context of every element in Xs (a list) for which the context is not empty.
   %% GetContext (a unary function) returns the context of an element in Xs. A context may be any data structure (e.g. a list or record of Strasheela objects). An empty context is reprented by nil, for such contexts the application is skipped.
   %% NB: Application of P blocks until the context is determined (i.e. until GetContext returns value).
   %% */
   proc {ForContexts Xs GetContext P}
      {ForAll Xs proc {$ X} {ApplyToContext {GetContext X} P} end}
   end
   /** %% Fn (a unary function) is applied to the context of every element in Xs (a list) for which the context is not empty. The results are collected and returned.
   %% GetContext (a unary function) returns the context of an element in Xs. A context may be any data structure (e.g. a list or record of Strasheela objects). An empty context is reprented by nil. For an empty context the application is skipped and nothing is collected in the result.
   %% NB: Application of P blocks until the context is determined (i.e. until GetContext returns value).
   %% */
   fun {MapContexts Xs GetContext Fn}
      {LUtils.mappend Xs
       fun {$ X}
	  Context = {GetContext X}
       in
	  if Context==nil then nil
	  else [{Fn Context}]
	  end
       end}
   end
   /** %% N=every <-> Rule holds for the context of every element in Xs (context candidates of each element returned by GetCandidates) which passes the test IsContext.
   %% Args is a record with the five feats 'xs', 'getCandidates', 'isContext', 'rule', and 'n'.  GetCandidates (a unary function) returns a list of context candidates (any data) of an element in Xs (a list). IsContext (a unary function or method) expects such a context candidate and returns a 0/1-int reflecting whether the context is a valid or not. Rule (a unary function or method) is a reified constraint applied to any context candidate returning a 0/1-int. N (the atom 'every' or a FD int) specifies for how many elements of Xs at least one non-empty context candidate complies both IsContext and Rule.
   %% Xs, GetCandidates, IsContext, and Rule are required arguments. N is optional (default is 'every').
   %%
   %% NB: some internal FD ints (in IsContextBs and RuleBs) possibly remain undetermined.
   %% */
   %%
   %% I figure, I don't need an arg B and therefore substituted it with arg N for pragmatic reasons. Nevertheless, with some proc-name ending in 'R' (as ForContextsR) I expect an 0/1-int as last arg..
   %% Arguments given by record to make call of ForContextsR with its 5 args better read-able
   %%
   %% ??!! do I need to be careful not to apply popagators IsContext multiple times? E.g., I may apply multiple rules on same context 'sim notes' with different number of violations (N):
   %%
   proc {ForContextsR Args}
      Defaults = unit(%% list of values
		      %% * xs:nil
		      %% unary fun/method returning list of candidates 
		      %% * getCandidates:fun {$ X} nil end
		      %% reified fun/method checking context
		      %% * isContext:proc {$ MyContext B} skip end
		      %% reified fun/method applied to context
		      %% * rule:proc {$ MyContext B} skip end
		      %% atom 'every' or FD int
		      n:every)
      As = {Adjoin Defaults Args}
      N
   in
      N = {FD.decl}
      if As.n == every
      then N = {Length As.xs}
      else N = As.n
      end
      N = {FD.sum {Map As.xs
		   proc {$ X B}
		      {ApplyToContextR
		       unit(candidates:{As.getCandidates X}
			    isContext:As.isContext
			    rule:As.rule
			    n:any	% explicit default
			    b:B)}
		   end}
	   '=:'}
   end

   
% %% Applies P (a unary procedure) to the context returned by GetContext (a unary fun) of every sublist of Xs as specified by Ranges.
% %% 
% proc {ForContextOfRanges Xs Ranges GetContext P}
%    {ForContext {LUtils.ranges Xs Ranges}
%     GetContext P}
% end

% %% [old doc]
% %% B=1 <-> P holds for every sublist of Xs as specified by Ranges and the context of each sublist.
% %% 
% proc {ForContextOfRangesR Xs Ranges GetContextCandidates IsContext P N}
%    {ForContextR {LUtils.ranges Xs Ranges}
%     GetContextCandidates IsContext P N}
% end
   
   /** %% Apply unary procedure P (expecting a list) to the sublist from Xs (a list) matching PatternMatchingExpr (a list of atoms: a single 'x' and any number of 'o' in any order). PatternMatchingExpr expresses a sublist of Xs positionally related to Self (an element of Xs). The atom 'x' in PatternMatchingExpr reprents Self and one or more 'o' atoms around 'x' express predecessors or successors of Self in Xs. For instance, <code>{PatternMatchingApply Self Xs [o o x] P}</code> applies P to the list consisting in the two predecessors of Self in Xs and Self (in that order). 
   %% PatternMatchingApply reduces to skip in case there is no matching sublist in Xs (e.g. the PatternMatchingExpr = [o x] and X is already the first element in Xs).
   %% An exeception is raised in case Self is not contained in Xs or there is no 'x' in PatternMatchingExpr.
   %%
   %% BTW: PatternMatchingApply corresponds roughly to the rule application mechanism of PWConstraints. However, PWConstraints always applies a rule to all object sets matching the pattern whereas PatternMatchingApply applies the rule only to a single set (or score context). That way, the user controls to which matching sets the rule is applied.
   %% PWConstraints introduces also pattern vars denoting numeric indices which can not be mixed with the other pattern variables.  ForNumericRange (see below) defines a similar alternative rule application mechanism.
   %% BTW: PatternMatchingApply allows to apply a procedure to non-uniform context (e.g. a single chord and multiple notes related by their position): a part of the context (e.g. the single note) is not contained in Xs but in the lexical scope of P.
   %% */ 
   proc {PatternMatchingApply Self Xs PatternMatchingExpr P}
      {PatternMatchingApply2 Self Xs PatternMatchingExpr P
       proc {$} skip end}
   end

   /** %% Generalised variant of PatternMatchingApply: in case no sublist in Xs matches PatternMatchingExpr, PatternMatchingApply2 does _not_ reduce to skip (as PatternMatchingApply) but instead applies the null-ary procedure ElseP.
   %% */
   proc {PatternMatchingApply2 Self Xs PatternMatchingExpr P ElseP}
      PosSelfInXs = {LUtils.position Self Xs}
      %% only single 'x' in PatternMatchingExpr allowed and every
      %% other element must be 'o'. In case of multiple 'x' use first,
      %% and all other elements in PatternMatchingExpr are also
      %% interpreted as non-x. 
      PosSelfInPattern = {LUtils.position 'x' PatternMatchingExpr}
      StartPatternInXs EndPatternInXs
   in
      %% !!?? these exceptions really needed?
      if PosSelfInXs==nil then raise noSelfIn(Xs) end end
      if PosSelfInPattern==nil then raise noXIn(PatternMatchingExpr) end end
      %%
      StartPatternInXs = PosSelfInXs - PosSelfInPattern + 1
      EndPatternInXs = StartPatternInXs + {Length PatternMatchingExpr} - 1
      if StartPatternInXs < 1 then {ElseP} %% ?? < 1
      elseif EndPatternInXs > {Length Xs} then {ElseP}
      else {P {LUtils.sublist Xs StartPatternInXs EndPatternInXs}}
      end
   end


   /** %% Applies unary procedure P to each element in Xs which index is expressed by Decl. Decl is a list which contains single index integers, or index ranges of the form Min#Max (Min and Max are integers).
   %% BTW: ForNumericRange corresponds roughly to one of the rule application mechanisms of Situation. The rule applicator `mapIndex' in Strasheela publications is the function equivalent.
   %% */
   proc {ForNumericRange Xs Decl P}
      {ForNumericRange2 Xs Decl P proc {$ X} skip end}
   end

   /** %% Generalised variant of ForNumericRange: to every element in Xs to which P is not applied, ElseP (a unary procedure) is applied instead.
   %% */ 
   proc {ForNumericRange2 Xs Decl P ElseP}
      XsLength = {Length Xs}
      %% instead, I could use LUtils.ranges and then flatten
      AllIs = {LUtils.mappend Decl fun {$ X}
				      case X
				      of Min#Max then {List.number Min Max 1}
				      [] Val then [Val]
				      else {Exception.raiseError
						 strasheela(failedRequirement X
							    "format of declaration must be either Min#Max (integer pair) or I (single int).")}
					 unit   % never returned
				      end
				   end}
      %% create tuple which contains P at all positions contained in
      %% AllIs and ElseP at all other positions.
      MatchingPs = {MakeTuple unit XsLength}
   in
      {ForAll AllIs  proc {$ X} MatchingPs.X = P end}
      {Record.forAll MatchingPs proc {$ X} if {IsFree X} then X = ElseP end end}
      %% apply respective proc to each element in Xs
      {List.forAllInd Xs proc {$ I X} {MatchingPs.I X} end}
   end

   /** %% Applies binary procedure P to each element in Xs which index is expressed by Decl -- together with additional arguments for that index. To all other elements of Xs the unary procedure ElseP is applied instead.
   %% Decl is a list which contains single index integers plus constraint arguments in the form Ind#Args, or index ranges plus constraint arguments in the form (Min#Max)#Args. The index Ind and the range boundaries Min and Max are integers, Args is a list of arbitrary values (and can be nil).
   %%  ForNumericRangeArgs implements a generalised variant of ForNumericRange (and ForNumericRange2) which implements an extended syntax for Decl.
   %% The rule applicator `mapIndexArgs' in Strasheela publications is the function equivalent.
   %% */ 
   proc {ForNumericRangeArgs Xs Decl P ElseP}
      XsLength = {Length Xs}
      %% instead, I could use LUtils.ranges and then flatten
      IsWithArgs = {LUtils.mappend Decl fun {$ X}
					   case X
					   of (Min#Max)#Args % andthen {IsList Args} % and Min and Max are both ints and Min < Max
					   then
					      {Map {List.number Min Max 1}
					       fun {$ I} I#Args end}
					   [] I#Args % andthen {IsInt I} andthen I =< XsLength andthen {IsList Args}
					   then [I#Args]
					   else {Exception.raiseError
						 strasheela(failedRequirement X
							    "format of declaration must be either (Min#Max)#Args or I#Args.")}
					      unit   % never returned
					   end
					end}
      %% create tuple which contains P at all positions contained in
      %% AllIs and ElseP at all other positions.
      MatchingPs = {MakeTuple unit XsLength}
   in
      {ForAll IsWithArgs  proc {$ I#Args} MatchingPs.I = Args end}
      %% apply respective proc to each element in Xs
      {List.forAllInd Xs
       proc {$ I X}
	  Args = MatchingPs.I in
	  if {IsFree Args} % is their an index for X in Decl?
	  then {ElseP X}
	  else {P X Args}
	  end
       end}
   end
   
end
