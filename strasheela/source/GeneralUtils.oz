
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

/** %% This functor defines some general utilities
%% */

functor
import
   Module OS Combinator Property QTk at 'x-oz://system/wp/QTk.ozf' % Tk
   FD FS
   LUtils at 'ListUtils.ozf'
%    Browser(browse:Browse) % temp for debugging
export
   Pi
   XOr Cases
   IsFS MakeSingletonSet IntsToFS
   Percent
   
   Identity
   Random RandIntoRange
   MakeRandomGenerator SetRandomGeneratorSeed
   Log Mod_Float IsDivisible
   % MakeConcurrentFn
   ToProc ToFun Procs2Proc
   ExtendedScriptToScript
   ApplySelected EncodeRatio
   SelectArg
   TimeVString
   GetCounterAndIncr ResetCounter
   UnarySkip BinarySkip
   TakeFeatures

   ModuleLink ModuleApply
   TimeSpend

   Assert

   WarnGUI InfoGUI ErrorGUI

define

   /** %% The mathematical constant pi.
   %% */
   %% this is as much precision as Oz allows
   Pi = 3.141592653589793

   
   /** %% Defines exclusive or: XOr returns true if only B1 or B2 are true. XOr returns false if B1 and B2 are both false or both true.
   %%*/
   fun {XOr B1 B2}
   % NOTE: !!?? could this be more efficient?
      {And
       {Or B1 B2}
       {Not {And B1 B2}}}
   end

   /** %% Cases defines a general conditional similar to an 'if then elseif ...' statement. X is some datum to process dependent on boolean tests. Clauses is a list of test and action functions/methods in the form [Test1#Process1 Test2#Process2 ...]. The first test returning true for X 'fires' its Process and Cases returns the result of {Process X}. If no test returns true for X Cases returns nil.
   %% */
   fun {Cases X Clauses}
      SucceededClause = {LUtils.find Clauses
			 fun {$ Test#_} {{ToFun Test} X} end}
   in
      if SucceededClause==nil then nil
      else
	 _#Process = SucceededClause
      in
	 {{ToFun Process} X}
      end
   end

   /** %% IsFS returns true if X is a FS variable (determined or not) and false otherwise. This function is necessary, because the primitive Oz functions FS.var.is and FS.value.is behave differently for determined and undetermined FS variables.
   %% */ 
   fun {IsFS X}
      if {IsDet X}
	 %% returns true for determined FS and blocks otherwise
      then {FS.value.is X}
	 %% !! returns false for determined FS
      else {FS.var.is X}
      end
   end

   
   /** %% Expects D (a FD int) and returns a singleton FS which contains only D.
   %% */
   proc {MakeSingletonSet D ?MyFS}
      MyFS = {FS.var.decl}
      {FS.include D MyFS}
      {FS.card MyFS 1}
   end
   
   /** %% Constraints that Ds (a list of FD ints) are all contained in MyFS (a FS, implicitly declared), but no other integer. This definition is similar to FS.int.match, but Ds must not be in increasing order.
   %% */
   proc {IntsToFS Ds MyFS}
      MyFS = {FS.var.decl}
      %% not necessary, already derived anyway
%   {FS.card MyFS} =<: {Length Ds}
      {FS.unionN {Map Ds fun {$ D} {MakeSingletonSet D} end}
       MyFS}
   end

   %% FS.int.match is better than this..
%    /** %% Expects MyFS (a FS) and returns Ds, a list of FD ints which are all contained in MyFS.
%    %% This definition is similar to FS.int.match, but Ds must not be in increasing order. This definiiton is also similar to IntsToFS, but Ds are created by FsToInts. The length of Ds is the cardiality of MyFS, and all elements in Ds are constrained to be pairwise distinct.
%    %%
%    %% Note: blocks until cardiality of MyFS is determined
%    %% */
%    proc {FsToInts MyFS ?Ds}
%       Ds = {FD.list {FS.card MyFS} 0#FD.sup}
%    in
%       {FS.unionN {Map Ds fun {$ D} {MakeSingletonSet D} end}
%        MyFS}
%       {FD.distinct Ds}
%    end

   
   /** %% Constrains percentage of N (FD int) if NoAll (FD int) indicates 100 percent. Result is implicitly declared a FD int.
   %% Example:  {Percent 4 6} = 66  
   %% Note the rounding to 66 percent (better do not rely on exact value of Result but constraint it, e.g., by a comparison such as Result >: 50).
   %% */
   proc {Percent N NoAll Result}
      Aux = {FD.decl}
   in
      Result = {FD.int 0#100}
      Aux =: N * 100
      Result = {FD.divI Aux NoAll}
   end

   /** %% The Identity function returns its argument.
   %% */
   fun {Identity X} X end
   
   %% 
   %% Numeric Utils
   %%
   
   /** %% Returns a random integer in interval [0, Max-1]. 
   %% */
   fun {Random Max}
   % MinOS is ignored but needs to be 0
      MinOS=0 MaxOS		
   in
      {OS.randLimits MinOS MaxOS}
      {Int.'div' ({OS.rand}*Max) MaxOS}
   end
   /** %% Expects a random integer generated by {OS.rand} and returns a random integer in Min - Max (Min and Max are integers).
   %% */
   fun {RandIntoRange Rand Min Max}   
      MaxRand = {OS.randLimits 0}
   in 
      (Rand * (Max - Min + 1)) div MaxRand + Min
   end

   local
      fun lazy {RandomStream} {OS.rand}|{RandomStream} end   
      RandomNumbers={NewCell {RandomStream}}
   in
      /** %% Returns a random number generator (a null-ary function) which returns a pseudo-random integer whenever it is called. Every returned random number generator will always produce the same number sequence: all random values are 'recorded' behind the scene in the top-level space. In other words, the random number generator is deterministic. Such a random generator can be used for a randomised value ordering, and the resulting distribution strategy can still apply recomputation (see SDistro.makeRandomDistributionValue). In such as case, MakeRandomGenerator must be called inside script. The convenient Strasheela solvers in SDistro do that implicitly. 
      %% MakeRandomGenerator can be (re)-initialised with SetRandomGeneratorSeed.
      %% */
      %%
      %% This implementation is based on a suggestion by Raphael Collet (emails Wed, 02 Feb 2005 to users@mozart-oz.org). 
      %% If MakeRandomGenerator is called inside a script, then the cell Str (see below) is local to that script and can thus be statefully changed in the script by the proc returned by MakeRandomGenerator. 
      fun {MakeRandomGenerator}
	 Str={NewCell @RandomNumbers}
      in
	 proc {$ ?X} T in X|T=Str:=T end
      end
      /** %% Sets the seed for the random number generator used by MakeRandomGenerator (which internally uses OS.rand). If Seed is 0, the seed will be generated from the current time.
      %% NOTE: calling SetRandomGeneratorSeed will corrupt any random number generator previously created with MakeRandomGenerator. Either call {SetRandomGeneratorSeed 0} only once after starting Mozart (so a 'random' seed is used), or re-feed your code calling MakeRandomGenerator after using SetRandomGeneratorSeed (e.g., re-call your solver).
      %% */
      proc {SetRandomGeneratorSeed Seed}
	 {OS.srand Seed}
	 RandomNumbers:={RandomStream}
      end
   end
   
   /** %% Returns the logarithm to the base Base of X. X and Base must be floats and a float is returned.
   %% */
   fun {Log X Base}
      %% ? more efficient would be to define, e.g., Log2 which
      %% evaluates {Float.log 2} only once. But I prefered this more
      %% general and clean definition.
      {Float.log X} / {Float.log Base}
   end
   /** %% Similar to the mod operation, but arguments and return value are floats.
   %% */
   fun {Mod_Float X1 X2}
      Result = X1 - X2 * {IntToFloat ({FloatToInt X1} div {FloatToInt X2})}
   in
      %% Result be neg
      if Result < 0.0
      then Result + X2
      else Result
      end
   end

   /** %% Returns a Boolean value whether X is divisible by Y. X and Y are ints.
   %% */
   fun {IsDivisible X Y}
      %% Implementation is approximated using floats for simplicity
%       {Abs {IntToFloat X}/{IntToFloat Y} - {IntToFloat X div Y}} < 0.5 / {IntToFloat Y}
      X div Y * Y == X
   end


   %%
   %% Constraint programming utils
   %%
   
   /** %% Q encodes X/Y by an integer as X/Y * Factor. Possible values for X/Y depend on Factor, e.g., 1/3 can not truely be represented if Factor=2. Factor should be an determined integer. For example, if Factor=12 then Q can represent 1/6 (Q=2), 1/4 (Q=3) etc.
   %% */
   proc {EncodeRatio X Y Factor Q}	
      X * Factor =: Y * Q
   end

%    proc {EncodeInteger X Y Summand Z}
%    end
  
   /** %% The Ith element in Procs is applied. Procs is list of null-ary procedures. I is a FD integer, the domain of I is implicitly reduced to 1#{Length Procs}.
   %% This is quasi a selection constraint, however, there are no constraint propagators created by ApplySelected. Instead, ApplySelected uses the deep-guard combinator Combinator.'or', i.e. a backtracking-free disjunction. ApplySelected suspends until a decision is made elsewhere (e.g. by determining I or by ruling out the cause of the application of all but one procedure in Procs).
   %%
   %% See also Pattern.transformDisj
   %% */
   %% !!?? shall this go into extra Constraints functor?
   proc {ApplySelected Procs I}
      ProcsTuple = {List.toTuple '#' Procs}
      I :: 1#{Length Procs}	% just to make sure...
   in
      {Combinator.'or' {Record.mapInd ProcsTuple
			fun {$ ProcI Proc} 
			   proc {$}
			      I = ProcI
			      {Proc} 
			   end
			end}}
   end
   
   %%
   %% Concurrent Utils
   %%
%    /* %% Returns a concurrent version of the unary function Fn.
%    %%*/
%    fun {MakeConcurrentFn Fn}
%       fun {$ X} thread {Fn X} end end
%    end

   
   %%
   %% OOP Utils
   %%
   
   /** %% Function ToProc transforms a method to a procedure. The argument X represents the method and its interface. X may be an atom (representing a method with no argument), or a record (e.g. representing a method with multiple arguments). For convenience, X may also be a procedure, which will be returned unchanged.
   %%
   %% The returned procedure expects one, two or three arguments. The first argument is always the object to which the method is passed. If X is an atom, this is the only argument. E.g. <code> {ToProc test}</code> returns the procedure <code> proc {$ O} {O test} end</code>.
   %%
   %% If the returned procedure expects more than only one argument, the last argument of the procedure is always the value at feature 1 of the method record. In the score description language, the first method feature is usually defined as the return value of the method. If the method expects only that argument, the procedure returned expects two arguments. E.g. <code> {ToProc isTest(x)} </code> results in the procedure <code> proc {$ O Result} {O test(Result)} end</code>.
   %%
   %% If the method defines multiple arguments, all other arguments are collected in a record in the second argument of the procedure. E.g. <code> {ToProc isTest(x test:x)} </code> results in the procedure <code> proc {$ O Args Result} {O test(Result test:Args.test)} end</code>.
   %%*/
   proc {ToProc X ?Res}
      %% !! resulting procedures are less efficient then methods
      %% (need to construct method record for each proc call)
      Res = 
      if {IsProcedure X} 	% !! do I need this option ?
      then X
      elseif {IsAtom X}
      then proc {$ O} {O X} end	% method with no arg
      elseif {IsRecord X}
      then
	 %% first feature of method is always result
	 if {Arity X} == [1]
	 then
	    proc {$ O Result} % method with single arg
	       M = {MakeRecord {Label X} [1]}
	    in
	       M.1 = Result
	       {O M} 
	    end 
	 else
	    proc {$ O Args Result} % method with multiple args
	       M = {MakeRecord {Label X} 1|{Arity Args}} 
	    in 
	       M.1 = Result
	       {Record.forAllInd Args proc {$ I X} M.I=X end}
	       {O M}
	    end
	 end
      else
	 {Exception.raiseError
	  kernel(type
		 ToProc [X Res]		% args
		 'procedure, atom, or record' % type
		 1 % arg position
		 "Either a procedure, atom, or a record required."
		)}
	 unit			% never returned
      end
   end
   /** %% Transforms an atom -- representing the label of a unary method -- into a unary function which expects as argument the object the method shall be send to. For convenience, X may also be a procedure, which will be returned unchanged.
   %%*/
   proc {ToFun X ?Res}
      Res = 
      if {IsProcedure X} 	% !! do I need this option ?
      then X
      elseif {IsAtom X}
      then {ToProc {MakeRecord X [1]}}
	 % raise type error: neither procedure nor atom
      else
	 {Exception.raiseError
	  kernel(type
		 ToFun [X Res]		% args
		 'procedure or atom' % type
		 1 % arg position
		 "Either a procedure or an atom required."
		)}
	 unit			% never returned
      end
   end

   /** %% Returns a single unary procedure which applies all elements in Procs -- a list of unary procedures -- to its argument (example application: transforms a list of unary compositional rules into a single rule).
   % */
   fun {Procs2Proc Procs}
      proc {$ X}
	 proc {Aux Procs X}
	    if Procs==nil
	    then skip
	    else {Procs.1 X} {Aux Procs.2 X} 
	    end
	 end
      in
	 {Aux Procs X}
      end
   end
   
   /* %% Unary procedure which does nothing.
   %% */
   proc {UnarySkip X} skip end
   /* %% Binary procedure which does nothing.
   %% */
   proc {BinarySkip X Y} skip end


   /** %% Convenience function for parameterised CSP scripts. An extended script is a binary procedure, i.e., a script where the first argument is a record of arguments expected by the script and the second argument is the script root variable. 
   %% ExtendedScriptToScript expects an extended script plus its Args, and returns a plain script (i.e. a unary procedure).
   %% */
   %% !!?? put into ScoreDistro.oz?
   fun {ExtendedScriptToScript MyExtendedScript Args}
      proc {$ Sol} Sol = {MyExtendedScript Args} end
   end
   
   
   /** % SelectArg is a tool, e.g., to define functions with quasi optional values. SelectArg returns the value at Feature in record Spec, if Spec has this feature. Otherwise the value at Feature in the record Defaults is returned. Defaults must have this record.
   %% !! Often the buildin Adjoin is a better solution: {Adjoin Defaults Args} = EffectiveArgs
   %% */
   %% !!?? Shall I remove this?
   fun {SelectArg Feature Spec Defaults} 
      if {HasFeature Spec Feature}
      then Spec.Feature
      else Defaults.Feature
      end
   end



   
   /** % Returns a VS of the current time in the form
   %% 'hour:min:sec, day-month-year'.
   %% */
   %% !!?? Do I need this defined here (local def in Output.oz enough)?
   fun {TimeVString}
      Time = {OS.localTime}
   in
      Time.hour#':'#Time.min#':'#Time.sec#', '#Time.mDay#'-'#Time.mon+1#'-'#Time.year+1900
   end

 

   local
      Counter = {Cell.new 1}
   in
      /** %% Return an integer and as a side effect increment the integer for the next access.
      %% */
      proc {GetCounterAndIncr ?X}
	 X = {Cell.access Counter}
	 {Cell.assign Counter X+1}
      end
      /** %% Resets the counter for GetCounterAndIncr.
      %% */
      proc {ResetCounter}
	 Counter := 1
      end
   end

   /** %% Fun R (a record) and MyFeats (a list of symbols -- potential features in R). TakeFeatures returns a record which consists in all features and their values of MyFeats contained in R. 
   %% */
   fun {TakeFeatures R MyFeats}
      {Record.filterInd R
       fun {$ Feat X}
	  {Member Feat MyFeats}
       end}
   end
   
   local
      ModMan = {New Module.manager init}
   in
      /** %% ModuleLink is like Module.link except that multiple calls of ModuleLink share the same module manager (and don't create new managers as Module.link does). For instance, when ModuleLink links multiple functors which refer to a stateful datum in some functor, then all refer to the same datum instance. By constrast, linking with Module.link results into multiple stateful datum instances.
      %% !! On second though, ModuleLink seems to solve a non-existing problem. ModuleLink is an attempt to avoids problems in case some functor is linked more then once in the OPI. Actually, this should happen only in two cases: either you want to create two module instances (with independent stateful data) or you want to reload a functor (e.g. after compilation) without restarting the whole program. In both cases, Module.link does the right thing. So, why did I ever need ModuleLink???
      %% -> A buffer with this ModuleLink can be re-fed multiple times without problems. A call to Module.link should not be re-fed... 
      %% */
      fun {ModuleLink  UrlVs}
	 {Map UrlVs fun {$ Url}
		       {ModMan link(url:Url $)}
		    end}
      end
      /** %% ModuleApply is like Moduel.apply expect that it always uses the same module manager (cf. ModuleLink). 
      %% */ 
      fun {ModuleApply UFs}
	 {Map UFs fun {$ UF}
		     case UF of U#F then 
			{ModMan apply(url:U F $)}
		     else 
			{ModMan apply(UF $)}
		     end 
		  end}
      end
   end
 
   /** %% Returns the time (in msecs) the application of P (a null-ary procedure) took.
   %% */
   fun {TimeSpend P}
      Start End
   in
      Start = {Property.get 'time.total'}
      {P}
      End = {Property.get 'time.total'}
      End - Start
   end

   /** %% If B is false, then MyException is raised.
   %% */
   %% !!?? Could calling Assert be inefficient so that I would like to turn it of globally?
   %% Possible implemementation: B is either a boolean or a 0-ary boolean fun. When Assert is switched of globally (e.g. using some Strasheela env var), then the tests executed by all the functions are not executed (when the test is not wrapped in a function, but excuted directly then it is always executed). That way, expensive tests could be avoided globally.
   %% Anyway, for now this is overkill. If I realise that things are too inefficient and much time is spend in Assert I could add this feature later.
   proc {Assert B MyException}
      if {Not B}
      then {Exception.raiseError MyException}
      end
   end
   

   %%
   %% GUI messages
   %%
   %% see http://aspn.activestate.com/ASPN/docs/ActiveTcl/8.4/tcl/TkCmd/messageBox.htm for additional args of tk_messageBox
   %%
   
   /** %% Opens a warning dialog which displays VS.
   %% */
   proc {WarnGUI VS}
      Window = {QTk.build td(text(init:"WARNING: "#VS
				  height:5
				  width:50
				  wrap:word
				  background:yellow)
			     button(text:"OK" 
				    action:toplevel#close))}
   in
      {Window show}
      %%
      %% NB: blocks, until OK buttom is pressed, and a surrounding thread does not help against this.
% 	 %% returns ok if ok button is pressed..
% 	 _ = {Tk.return tk_messageBox(icon:warning
% 				      type:ok
% 				      message:VS)}
   end   
   /** %% Opens a warning dialog which displays VS. 
   %% */
   proc {InfoGUI VS}
      Window = {QTk.build td(text(init:"INFO: "#VS
				  height:5
				  width:50
				  wrap:word)
			     button(text:"OK" 
				    action:toplevel#close))}
   in
      {Window show}
%       %% NB: blocks, until OK buttom is pressed, and a surrounding thread does not help against this.
% 	 %% returns ok if ok button is pressed..
% 	 _ = {Tk.return tk_messageBox(icon:info
% 				      type:ok
% 				      message:VS)}
   end
      
   /** %% Opens an error dialog which displays VS. 
   %% */
   proc {ErrorGUI VS}
      Window = {QTk.build td(text(init:"ERROR: "#VS
				  height:5
				  width:50
				  wrap:word
				  %% light red color
				  background:c(255 150 150))
			     button(text:"OK" 
				    action:toplevel#close))}
   in
      {Window show}
%       %% NB: blocks, until OK buttom is pressed, and a surrounding thread does not help against this.
% 	 _ = {Tk.return tk_messageBox(icon:error
% 				      type:ok
% 				      message:VS)}
   end

end
