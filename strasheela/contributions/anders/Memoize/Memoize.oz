
%%% *************************************************************
%%% Copyright (C) 2006 Torsten Anders (t.anders@qub.ac.uk) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% This functor provides memoization of functions.
%%
%% NOTE: Memoize2: accessing memoized values is slow -- it can be far
%% slower than recomputing the memoized values!  Efficiency of
%% memo-functions lookup is only linear time (!) and depends on the
%% number of results already cached (i.e. lookup is not performed in
%% constant time as perhaps expected, because currently there exists
%% no constant time implementation of RecordC.reflectHasFeature).  It
%% may still be sufficiently efficient in a CSP when used for avoiding
%% redundant propagators, but you may want to compare the performance
%% with and without memoization...
%%
%% */

%%
%% TODO:
%%
%% * !! Problem: I can not store variables of a CSP outside the script -- what was I thinking?
%%
%% * rethink this with stateful dictionaries and a port: see Christians book (p. 40) or Moz mailing list: raph@info.ucl.ac.be: Re: memoization + search script. 4. Mai 2006 12:53:05 MESZ 
%%
%%

functor
import
%   Browser(browse:Browse) % temp for debugging
   MRecord at 'x-ozlib://anders/strasheela/MultiRecord/MultiRecord.ozf'
   MDict at 'x-ozlib://anders/strasheela/MultiDict/MultiDict.ozf'
   
export
   Memoize ClearAll
   Memoize2
   SetGetID
   SetMinID
   
define
   
   GetIDFn = {NewCell fun {$ X} {X getID($)} end}
   fun {GetID X}
      {@GetIDFn X}
   end
   /** %% Sets the function which accesses the unique ID of an argument to a memoization function. This must be a name, atom or an integer. Alternatively, the value returned by Fn may be a free variable. In that case, this variable gets implicitly bound to a unique integer (see SetMinID).
   %% The default GetIdFn is fun {$ X} {X getID($)} end.
   %% NOTE: the use of SetGetID is not thread-safe. SetGetID performs a stateful operation and may overwrite the key expected by a concurrent computation. Workaround: create a unique Memo module with Module.link for each key needed.
   %% */
   proc {SetGetID Fn}
      GetIDFn := Fn
   end
   
   local
      I = {NewCell 0}
   in
      /** %% A memo-function created by Memoize recognises values by their ID. In case this ID is a free variable, it is determined to a unique integer.
      %% SetMinId sets the minimum ID. This allows to avoid conflicts of automatically created IDs with IDs created by hand. The default min ID is 0.
      %% Please note that SetMinID should only be called once before calling any memoized function (otherwise ID conflicts may happen and multiple objects may be assigned the same ID). If it is called multiple times, the new setting is ignored in case it is less than the next automatic ID in order to avoid conflicts.
      %% */
      proc {SetMinID Min}
	 if Min > @I
	 then I := Min
	 end
      end
      /** %% Returns a unique integer. */
      %% BUG: can not be called from within space: is stateful operation.
      fun {MakeID} I:=@I+1 end
   end

   
   /** %% Returns the key of X (a value which uniquely identifies X to store the result of a memo-function). 
   %% */
   %% NB: not thread-save (ID access and setting not atomic, but locking this operation causes problems in CSPs..)
   proc {GetKey X ID}
      ID = {GetID X}
      %% !! for concurrency, these two operations must be one! (locking?)
      if {IsFree ID}
      then ID = {MakeID}
      end
   end

   
   ClearPs = {NewCell nil}

   /** %% Expects a unary function Fn (expecting a list of values and returning a value) and returns the corresponding memoized function MemoFn (ie. a function which caches the result for specific arguments and returns this pre-computed value again when called with the same arguments instead of computing the value again, see 'Norvig. Paradigms of Aritificial Intelligence Programming, 1992' for details). Additionally, the nullary proc ClearP is returned: calling ClearP clears the cache for MemoFn.
   %%
   %% The identity of the memoized function arguments is checked with a function GetID. This function can be set with SetGetID, and must return a unique key (a name, atom or an integer) for every unique function argument. Also, the memoized function arguments must be values for which their unique key can be computed. GetID defaults to fun {$ X} {X getID($)} end, that is, per default a memoized function must expect a list of score objects with a unique determined ID or a free ID.
   %% In case the ID retured by GetID is a free variable, then this variable is set to a unique integer. The minimum integer ID can be specified with SetMinID.
   %%
   %% The definition of the original function is not changed (in contrast to the Lisp implementation of Norvig) and thus recursive functions are not well memoized. Only the top-level call of the recursive function would get memoized but internally the function would call the original unmemoized version. Note that memoization is usually most effectful at recursive functions, whereas the present Memoize is useful only under very specific circumstances. 
   %%
   %% Memoize performs stateful operations and is therefore not applicable in a CSP. For CSP use Memoize2 instead.
   %%
   %% Memo-functions are not thread save. In case the result for a particular set of arguments is not yet cached and the function is called with the same args (args with the same keys) in parallel, the cache will be set twice (in case of inconsistent values, an exception will be raised). Similarily, setting the ID of a value is not thread-save either.
   %% TODO: these operations could be made thread-save by locking multiple sub-operations within the functor MultiDict. 
   %%
   %% Lookup with Memoize is far more efficient than Memoize2. Still, you better check whether memoization is really more efficient than recomputing...
   %% 
   %% */
   %% NOTE: changed interface: old interface was {Memoize Fn ?MemoFn}
   %%
   proc {Memoize Fn ?ClearP ?MemoFn}
      Table = {MDict.new}	% !! stateful: i.e. can not be used within CSP 
   in
      proc {ClearP} {MDict.removeAll Table} end
      ClearPs := ClearP|@ClearPs  % stateful
      fun {MemoFn Xs}	 
	 Keys = {Map Xs GetKey}
      in
	 {MDict.condGetPutting Table Keys
	  {Procedure.apply Fn [Xs $]}}
      end
   end

   /** %% Clears the cache of all memoized functions. 
   %% */ 
   proc {ClearAll}
      %% stateful
      {ForAll @ClearPs proc {$ P} {P} end}
   end

%    proc {Memoize Fn ?ClearP ?MemoFn}
%       Table = {MRecord.new}
%    in
%       proc {ClearP} {MRecord.clear Table} end
%       %% !! changes global state and can thus not be done within CSP script
%       ClearPs := ClearP|@ClearPs
%       fun {MemoFn Xs}	 
% 	 Keys = {Map Xs GetKey}
%       in
% 	 {MRecord.condGetPutting Table Keys
% 	  proc {$ Y} {Procedure.apply Fn [Xs Y]} end}
%       end
%    end

%    /* %% Clears the cache of all memoized functions. 
%    %% */ 
%    proc {ClearAll}
%       {ForAll @ClearPs proc {$ P} {P} end}
%    end


   /** %% Like Memoize, but completely stateless. Functions memoized with Memoize2 are not cleared with ClearAll (in contrast to functions created with Memoize), but for functions local to CSPs this is not necessary.
   %% Memoize2 is intended for locally use in CSP where its use can avoid re-applying redundant propagators. 
   %% Efficiency of memo-functions lookup is only linear time (!) and depends on the number of results already cached (i.e. lookup is not performed in constant time as perhaps expected, because currently there exists no constant time implementation of RecordC.reflectHasFeature).
   %%
   %% BUG: setting IDs automatically does presently _not_ work from inside a local space (i.e. during search): implicitly called function MakeID is stateful operation.
   %% Workaround for now: set IDs of score objects manually (the method getID returns the ID of an object, which is free, by default).
   %% */
   %% Idea to resolve bug: simply set ID to a name. Problem: I can not export the result to textual representation.
   %% Alternative idea: traverse a lazily created unlimited list of integers.
   proc {Memoize2 Fn ?MemoFn}
      Table = {MRecord.new}
   in
      fun {MemoFn Xs}	 
	 Keys = {Map Xs GetKey}
      in
	 {MRecord.condGetPutting Table Keys
	  proc {$ Y} {Procedure.apply Fn [Xs Y]} end}
      end
   end
   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% old comments
%%
   
   %% .. its always a function memorised (always a single return value memorised), so I could return a function expecting a list and returning a value..
   %%
   %% replace temp local dict defs (use functor, which is still to define)
   %%
   %% Does not work for recursive functions, for that I would need to overwrite the binding of the orig func 'name' (as does Norvig (1992)). Besides, the function must only rely on its arguments (ie. not on any lexically visible bindings definde outside the function)
   %%
   %% !!?? The implementation of memoization here isn't thread-safe yet,  since calling a memoized function can modify the table of  memoized results, which needs to be synchronized.
   %%
   %% Using memoization in CSP: dict is stateful and thus memo fun must be created IN script! That's not the modularity I need :=/ 
   %% No alternative: using RecordC instead of dicts: drawback: no constant-time reflection whether record R already has feature X (instead, I need to traverse growing list of feats)
   %% Bottom line, memoization is not really an alternative for creating complex data structures (e.g. additional attribute somewhere for interval (between some note pair) object)
   %%
   %% ?? Hm, my traversing, e.g., to access sim events is much more demanding -- so just traverse all known features of a record to learn whether there is already some feature X
   %% -> Special purpose memoization for CSP def.. Intended to simplify Strasheela data-representation and avoiding redundant variables/propagators (e.g. to access the interval variable between to pitches without introducing a special variable in the data structure)
   %%
   %% nochmal zsfassen:
   %% stateless memoizing by RecordC, so memo-function can be created in top-level space and is used in CSP. BUT, for each CSP evaluation I need to clear the cache of all memo-functions. Therefore, each memo-function stores its cache (nested records) in a (single) cell which allows to globally wipe all caches (must not be called within script, but thats OK).
   %%
   %% !! MemoFun blocks if accessing key for an arg blocks (i.e. if some arg is a FD int -- but FD int in Strasheela parameter is fine).

   %% ?? Do I need to clear memo funs individually, or is it sufficient to always clear all memo funs together.
