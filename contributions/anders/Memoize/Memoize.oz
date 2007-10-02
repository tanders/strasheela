
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
   
export
   Memoize ClearAll
   SetGetID
   SetMinID
   
define
   
   GetIDFn = {NewCell fun {$ X} {X getID($)} end}
   fun {GetID X}
      {@GetIDFn X}
   end
   /** %% Sets the function which accesses the unique ID of an argument to a memoization function. This must be a name, atom or an integer. Alternatively, the value returned by Fn my be a free variable. In that case, this variable gets implicitly bound to a unique integer (see SetMinID).
   %% The default GetIdFn is fun {$ X} {X getID($)} end.
   %% */
   proc {SetGetID Fn}
      GetIDFn := Fn
   end
   
   local
      I = {NewCell 0}
   in
      /** %% A memo-function created by Memoize recognises values by their ID. In case this ID is a free variable, it is determined to a unique integer.
      %% SetMinId sets the minimum ID. This allows to avaid conflicts of automatically created IDs with IDs created by hand. The default min ID is 0.
      %% */
      proc {SetMinID Min}
	 if Min > @I
	 then I := Min
	 end
      end
      /** %% Returns a unique integer. */
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

   /** %% Expects a unary function Fn (expecting a list of values and returning a value) and returns the corresponding memoized function MemoFn (ie. a function which caches the result for specific arguments and returns this pre-computed value again when called with the same arguments instead of computing the value again, see 'Norvig. Paradigms of Aritificial Intelligence Programming, 1992' for details).
   %% Function attributes must be values for which a key can be computed. The function returning this key can be set by SetGetID.
   %%
   %% NB: The definition of the original function is not changed (in contrast to the Lisp implementation of Norvig) and thus recursive functions are not well memoized. Only the top-level call of the recursive function would get memoized but internally the function would call the original unmemoized version.
   %%
   %% NB: Memoize itself (and clearing the cache of a memoized function) performs a stateful operation. Still, calling the memo-function (and caching results) is stateless. Thus, memo-functions can be used freely in CSP, even if they are defined in the top-level space.
   %%
   %% NB: Memoize determines the ID of any value given as argument to a memo-function to an integer (as long as that ID is not already determined). The minimal ID can be set by SetMinID.
   %%
   %% NB: Memo-functions are not thread save. In case the result for a particular set of arguments is not yet cached and the function is called with the same args (args with the same keys) in parallel, the cache will be set twice (in case of inconsistent values, an exception will be raised).
   %% Similarily, setting the ID of a value is not thread-save either.
   %%
   %% Reason: these operations could be made thread-save by locking multiple sub-operations. Problem: locks in a top-level space not not be 'entered' by statements in other spaces (i.e. during search). 
   %%
   %% NB: Efficiency of memo-functions lookup is only linear time (!) depending on the number of results already cached (i.e. not constant time as perhaps expected, because currently there is no constant time RecordC.reflectHasFeature).
   %% */
   proc {Memoize Fn MemoFn}
      Table = {MRecord.new}
      proc {ClearP} {MRecord.clear Table} end
   in
      %% !! changes global state and can thus not be done within CSP script
      ClearPs := ClearP|@ClearPs
      fun {MemoFn Xs}	 
	 Keys = {Map Xs GetKey}
      in
	 {MRecord.condGetPutting Table Keys
	  proc {$ Y} {Procedure.apply Fn [Xs Y]} end}
      end
   end

   /** %% Clears the cache of all memoized functions. 
   %% */ 
   proc {ClearAll}
      {ForAll @ClearPs proc {$ P} {P} end}
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
