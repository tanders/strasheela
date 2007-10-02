
/** %% This functor provides constraint solvers which support timeout, and are thus fit for realtime constraint programming. A solver with timeout is very similar to a normal constraint solver. It expects a constraint script, and returns a solution. Additionally, however, a default solution and a maximum search time are specified as input arguments. In case the solver found no solution in the specified maximum search time, or in case the search failed, then the default solution is returned. 
%% In a real-time situation, a solver with timeout can be called repeatedly, for example with new real-time input arriving. Examples are provided in the folder ../examples. Please refer to the file ../testing/RealTime-test.oz for further examples. 
%% */

%%
%% NB: this is work in progress. Only after stabilising (and after
%% realtime input/output is supported in some platform independend
%% way) may this functor move as Realtime.oz into the Strasheela core.
%%

functor
import
   Search System
   SDistro at 'x-ozlib://anders/strasheela/source/ScoreDistribution.ozf'
   Browser(browse:Browse) % temp for debugging
   
export
   ExtendedScriptToScript
   SearchWithTimeout
   ScoreSearcherWithTimeout
   
define

   /** %% Convenience function for parameterised CSP scripts. An extended script is a binary procedure, i.e., a script where the first argument is the usual root, and further arguments to the script are handed over in the second argument (e.g., a record). 
   %% ExtendedScriptToScript expects an extended script plus its Args, and returns a plain script (i.e. a unary procedure).
   %% */
   %% !!?? put into ScoreDistro.oz?
   fun {ExtendedScriptToScript MyExtendedScript Args}
      proc {$ Sol}
	 Sol = {MyExtendedScript $ Args}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Search
%%%

   /** %% SearchWithTimeout is a 'meta search engine' with a timeout: in case a user-specified maximum search time is elapsed, a user-specified default solution is returned (defaults to nil).
   %% MyScript is a unary procedure defining the CSP plus a distribution strategy. Args is a record of the following optional arguments (feature-value pairs). The argument 'maxSearchTime' specifies the maximum search time in msecs (default: 1000). The default solution is given at the argument 'defaultSolution'. The argument 'solver' specifies the solver to use. The solver must be a procedure with the following interface {MySolver MyScript KillP MyScore}, and it must return a list with solution(s), or nil in case of no solution (only the first solution is ever used). The default solver is the following (KillP is a nullary procedure with stops the search when called, cf. the documentation of Search.one.depth).

   proc {$ MyScript KillP ?MyScore}
      MyScore = {Search.one.depth MyScript 1 KillP}
   end

   %% In case of a timeout or a fail, a warning is printed at stdout, together with Args (e.g., additional Arg features can be handed over for a more informative warning). 
   %%
   %% NB: only searching is terminated after timeout: a script with keeps computing forever without search (e.g., because it contains an infinite loop) can not be killed.
   %% */
   proc {SearchWithTimeout MyScript Args ?Result}
      Defaults = unit(maxSearchTime:1000
		      defaultSolution:nil
		      solver:proc {$ MyScript KillP ?MyScore}
				MyScore = {Search.one.depth MyScript 1 KillP}
			     end)
      As = {Adjoin Defaults Args}
      KillSearchP
      %% Result is either Solution or As.defaultSolution (in case of timeout or failure)
      Solution
      MyLock = {NewLock}
       
   in
      %% Output solution as soon as it is found. However, stop search
      %% if no solution is found after As.maxSearchTime msecs and
      %% return As.defaultSolution instead.
      %%
      %% These two threads terminate each other as soon as there
      %% respective condition is fulfilled. The lock ensures that only
      %% a single thread can be first (i.e. both threads can not kill
      %% each other, even if Solution is found exactly after
      %% As.maxSearchTime).
      %%

%      local DoneFlag in
%       %% more simple variant without thread access etc -- more easy to
%       %% communicate in paper ;-)
%       thread
% 	 Solution = {As.solver MyScript KillSearchP}
% 	 %% wait for solution
% 	 {Wait Solution}	% !!?? needed?
% 	 %% never enter lock at same time (but always both threads
% 	 %% will visit their locked code)
% 	 lock MyLock then 	
% 	    if {IsFree DoneFlag} % is this thread first? 
% 	    then
% 	       {Browse solverFinishedFirst}
% 	       DoneFlag = unit
% 	       if Solution \= nil
% 	       then Result = Solution.1
% 	       else
% 		  Result = As.defaultSolution
% 		  {System.showInfo 
% 		   "SearchWithTimeout: no solution! args:\n"
% 		   #{Value.toVirtualString As 3 1000}}
% 	       end
% 	    end
% 	 end
%       end
%       thread
% 	 %% always wait for max waiting time (thread never killed) --
% 	 %% slightly less efficient variant than variant killing
% 	 %% threads below
% 	 {Delay As.maxSearchTime}
% 	 lock MyLock then 
% 	    if {IsFree DoneFlag} % is this thread first? 
% 	    then
% 	       {Browse timeoutFirst}
% 	       DoneFlag = unit
% 	       {KillSearchP}
% 	       Result = As.defaultSolution
% 	       {System.showInfo
% 		"SearchWithTimeout: search timeout! args:\n"
% 		#{Value.toVirtualString As 3 1000}}
% 	    end
% 	 end
%       end
%	 end

      %% using explicit thread access
      local
	 Thread1 Thread2
      in
	 thread
	    Thread1 = {Thread.this}
	    Solution = {As.solver MyScript KillSearchP}
	    {Wait Solution}	% !!?? needed?
	    %% stop other thread. raises an exception kernel(terminate ...)
	    lock MyLock then 
	       {Thread.terminate Thread2}
	       if Solution == nil
	       then
		  Result = As.defaultSolution
		  {System.showInfo 
		   "SearchWithTimeout: no solution! args:\n"
		   #{Value.toVirtualString As 3 1000}}
	       else Result = Solution.1
	       end
	    end
	 end	 
	 thread 
	    Thread2 = {Thread.this}
	    %% max waiting time
	    {Delay As.maxSearchTime}	    
	    lock MyLock then 
	       {KillSearchP}
	       %% stop other thread
	       {Thread.terminate Thread1}
	       Result = As.defaultSolution
	       {System.showInfo
		"SearchWithTimeout: search timeout! args:\n"
		#{Value.toVirtualString As 3 1000}}
	    end
	 end
      end
      
   end



   /** %% ScoreSearcherWithTimeout provides a 'meta-search object' with a timeout, specialised in searching for Strasheela score objects. Create a search object with the method init, and obtain new solutions with the method next. The next method supports a number of arguments. For example, input data (including real-time input) can be handed over and previous output is accessible. See ../testing/Realtime-test.oz for simple examples.
   %% */
   %%
   %% TODO
   %%
   %% - integrate all functionality and todo items of obsolete ScoreSearchWithTimeout
   %%
   %%  put this external?
%   {CollectRealtimeInput}
   class ScoreSearcherWithTimeout

      attr
	 inputScores
	 outputScores
      feat initArgs extendedScript inputLength outputLength

	 /** %% Initialises object. All arguments are optional.
	 %% MyExtendedScript is an extended script, i.e., a binary procedure (see ExtendedScriptToScript). The argument distroArgs expects a record which specifies score distribution arguments as expected by SDistro.makeSearchScript (default: unit). The arguments inputScores and outputScores allow to initialise the previous input or output (defaults to nil): setting these can ensure, e.g., that there is always a previous output and that way can slightly simplify the CSP definition. The arguments inputLength and outputLength (defaults to 1) allow to optimise the memory required. For example, if outputLength is set to 1, then only the direct predecessor solution is accessible in the script, but other solutions are also not stored (both arguments can also be set to 'all').
	 %% All arguments supported by the SearchWithTimeout argument Args (i.e., maxSearchTime, defaultSolution, and solver) are supported as well, see the documentation there for details.  
	 %% */
      meth init(MyExtendedScript
		%% ?? replace by individual args
		distroArgs:DArgs <= unit
		inputScores:InScores <= nil
		inputLength:InLength <= 1
		outputScores:OutScores <= nil  
		outputLength:OutLength <= 1
		...) = M
	 %% unspecified default args are not part of M ...
	 self.initArgs = {Adjoin unit(distroArgs:unit)
			  %% remove MyExtendedScript
			  {Record.subtractList M [1 inputScores outputScores]}}
	 self.extendedScript = MyExtendedScript
	 inputScores := InScores
	 outputScores := OutScores
	 self.inputLength = InLength
	 self.outputLength = OutLength
      end

      /** %% Calls a solver supporting a timeout with the script MyExtendedScript and the score distribution args (all specified with the init method), and returns the solution Result (a score object).  All other arguments of the method next are optional.          
      %% The script MyExtendedScript is given in a record Args all the arguments given to the method next (except Result) and also all arguments of the method init. That way, arbitrary script arguments can be handed over to MyExtendedScript simply as arguments to next. In addition, a few arguments are computed by next and always given to MyExtendedScript: next provides the script arguments inputScore, inputScores, and outputScores -- via these arguments, the script can access and impose constrains on its solution with respect to its previous input and output. The next argument inputScore expects a Strasheela score object (e.g., created from realtime input). next implicitly adds the arguments inputScores (a list of all previous input scores in reverse order -- the current input is not yet part of it), and outputScores (a list of all previous output in reverse order). 
      %% All arguments specified at init (and default init arguments) can be overwritten with arguments given to this method (except for the script itself). For example, a different distribution strategy can be specified by handing an argument distroArgs to next.
      %% */
      meth next(?Result
		inputScore:InScore <= nil 
		...) = M
	 Args = {Adjoin {Adjoin self.initArgs
			 %% possibly unspecified default args..
			 {Adjoin unit(inputScore:nil)
			  {Record.subtract M 1}}}
		 unit(inputScores:@inputScores
		      outputScores:@outputScores)}
	 MyScript
	 fun {ReduceList Xs L}
	    case L
	    of all then Xs
	    else {List.take Xs L}
	    end
	 end
      in
	 %% store input (max inputLength)
	 inputScores := {ReduceList InScore | @inputScores self.inputLength}
	 %% call solver
	 MyScript = {SDistro.makeSearchScript {ExtendedScriptToScript self.extendedScript Args}
		     Args.distroArgs}	 
	 Result = {SearchWithTimeout MyScript Args}
	 %% store output (max outputLength)
	 outputScores := {ReduceList Result | @outputScores self.outputLength}
      end

      /** %% Resets the inputScores and outputScores to nil.
      %% */
      meth reset
	 inputScores := nil
	 outputScores := nil
      end
      
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% old stuff
%%%
   
%    /** %% This procedure is called whenever the search scheduler asks for the next score object (i.e. , following score object in time).
%    %% Returns score object.
%    %% After MaxSearchTime (Int in msecs) the search is stopped and the default result returned.
%    %%
%    %% NB: In contrast to Oz' search engines (like SearchOne), this 'meta engine' always returns a single solution (or the default solution), but not a list.
%    %%
%    %% In case of an error in script, defaultSolution is returned, the error message is shown at stout, and the warning about no solution is shown as well.
%    %% */
%    %% this is no scheduler, this is top-level proc called by scheduler
%    %%
%    %% !!?? distributionArgs extra?
%    %% !!?? ExtendedScriptArgs are partly created automatically, and partly given here

%    %%
%    %% !!! TODO
%    %%
%    %% - add realtime input processing (should I leave this outside: just optional input to Args??) 
%    %%
%    proc {ScoreSearchWithTimeout MyExtendedScript Args Result}
%       Defaults = unit(maxSearchTime:1000
% 		      defaultSolution:nil
% 		      %% proc with interface {MySolver MyScript KillP MyScore}
% 		      %% must return a list with solution, or nil in case of no solution
% 		      %% NB: only first solution is ever used
% 		      solver:proc {$ MyScript KillP ?MyScore}
% 				MyScore = {Search.one.depth MyScript 1 KillP}
% 			     end
% 		      %% score distribution args
% 		      distroArgs:unit
% 		     )
%       As = {Adjoin Defaults Args}
%       MyScript KillSearchP
%       %% Result is either Solution or As.defaultSolution (in case of timeout or failure)
%       Solution 			
%    in    
%       MyScript = {SDistro.makeSearchScript {ExtendedScriptToScript MyExtendedScript Args}
% 		  As.distroArgs}

%       thread Solution = {As.solver MyScript KillSearchP} end
      
%       %% Output solution as soon as it is found. However, stop search
%       %% if no solution is found after As.maxSearchTime msecs and
%       %% return As.defaultSolution.
%       %%
%       %% NB: these two threads terminate each other as soon as there
%       %% respective condition is fulfilled.
%       local
% 	 Thread1 Thread2
%       in
% 	 thread
% 	    Thread1 = {Thread.this}
% 	    {Wait Solution}
% 	    %% stop other thread. raises an exception kernel(terminate ...)
% 	    {Thread.terminate Thread2}
% 	    %% !!?? should I just output nil in case of no solution? I
% 	    %% can set defaultSolution to nil anyway, but return value
% 	    %% is no list otherwise
% 	    if Solution == nil
% 	    then
% 	       Result = As.defaultSolution
% 	       {System.showInfo 
% 		"ScoreSearchWithTimeout: no solution! args:\n"
% 		#{Value.toVirtualString As 3 100}}
% 	    else Result = Solution.1
% 	    end
% 	 end	 
% 	 thread 
% 	    Thread2 = {Thread.this}
% 	    %% max waiting time
% 	    {Delay As.maxSearchTime}
% 	    %% !!?? can I kill script which takes too long for
% 	    %% creating score etc (i.e. before the actual search)?
% 	    {KillSearchP}
% 	    %% stop other thread 
% 	    {Thread.terminate Thread1}
% 	    Result = As.defaultSolution
% 	    {System.showInfo
% 	     "ScoreSearchWithTimeout: search timeout! args:\n"
% 	     #{Value.toVirtualString As 3 100}}
% 	 end
%       end
%    end

   
end
