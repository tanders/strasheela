
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

/** %% This functor defines a multi-dimensional extendable record data structure (quasi a stateless dictionary, implemented by RecordC). The key to a value in a multi-dimensional record is a list Keys whose values are any combination of integers, atoms and names.
%% This is a stateless data structure (and can therefore be used, e.g., in a CSP such that it is defined globally and 'changed' in the CSP). There is only one stateful operation: Clear (changes binding of cell created by New).
%%
%% NOTE: This implementation is not thread-save: checking whether a key is valid and putting a value at the key is not atomic. Using locks would limit the use of this data structure in a CSP..
%%
%% NOTE: efficiency only linear time in worst case (depending on number of features of Rec), but thats the best I can do (currently, there is not RecordC.reflectHasFeature, only RecordC.reflectArity and thus the list of all currently stored keys must be searched in a tmp def of ReflectHasFeature defined here).
%% */

%% TODO:
%%
%% !!?? * Do constant time ReflectHasFeat1 (would require changing/extending RecordC)
%%

functor
import
%   Browser(browse:Browse) % temp for debugging
   RecordC
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   
export
   new:NewR
   Clear
   Is
   ReflectHasFeat
   Get CondGet CondGetPutting
   Put
   Entries

   %% tmp export
   % ReflectHasFeat1 Entries1 % MyType MyArity
   
prepare
   /** %% marker for type checking */
   %% Defined in 'prepare' to avoid re-evaluation.
   MyType = {Name.new}
define

   /** %% Returns a new empty multi-dimensional record.
   %% */
   proc {NewR X}
      X = {NewCell MyType(...)}
   end

   /** %% Completely empties the record X.
   %% */
   proc {Clear X}
      X := MyType(...)
   end

   fun {IsAux X}
       {RecordC.is X} andthen {Label X}==MyType
   end
   /** %% Tests whether X is a multi-dimensional record.
   %% */
   fun {Is X}
      {Cell.is X} andthen {IsAux @X}
   end

   /** %% Returns the item in Rec at Keys.
   %% */
   fun {Get Rec Keys}
      fun {Aux Rec Keys}
	 case Keys of nil then Rec
	 else {Aux Rec.(Keys.1) Keys.2}
	 end
      end
   in
      {Aux @Rec Keys}
   end

   /** %% Tests whether Rec has the non-compositional feature Feat (i.e. this is a non-recursive check, in contrast to ReflectHasFeat).
   %% NB: efficiency only linear time in worst case (depending on number of features of Rec), but thats the best I can do (with current interface of RecordC).
   %% */
   fun {ReflectHasFeat1 Rec Feat}
      {LUtils.contains Feat {RecordC.reflectArity Rec}}
   end
   
   /** %% Tests whether Rec has the multi-dimensional feature Keys.
   %% NB: no thread-save definition.
   %% */
   fun {ReflectHasFeat Rec Keys}
      fun {Aux Rec Keys}
	 case Keys of nil then true
	 else if {ReflectHasFeat1 Rec Keys.1}
	      then {Aux Rec.(Keys.1) Keys.2}
	      else false
	      end
	 end
      end
   in
      {Aux @Rec Keys}
   end
   /** %% Returns the item in Rec at Keys if Keys is valid, otherwise DefVal is retured.
   %% NB: no thread-save definition.
   %% */ 
   fun {CondGet Rec Keys DefVal}
      fun {Aux Rec Keys DefVal}
	 case Keys of nil then Rec
	 else
	    if {ReflectHasFeat1 Rec Keys.1}
	    then {Aux Rec.(Keys.1) Keys.2 DefVal}
	    else DefVal
	    end
	 end
      end
   in
      {Aux @Rec Keys DefVal}
   end
   
   proc {PutAux Rec Keys X}
      case Keys of [Key] then Rec^Key=X
      else {PutAux if {ReflectHasFeat1 Rec Keys.1}
		   then Rec.(Keys.1)
		   else NewRec = MyType(...) in
		      Rec^(Keys.1)=NewRec
		      NewRec
		   end
	    Keys.2 X}
      end
   end
   /** %% Sets the item in Rec under Keys to X.
   %% NB: no thread-save definition.
   %% */
   proc {Put Rec Keys X}
      {PutAux @Rec Keys X}
   end

   /** %% Returns the item in Rec at Keys if Keys is valid, otherwise put result of nullary Fn at Keys and return that.
   %% NB: no thread-save definition.
   %% */ 
   fun {CondGetPutting Rec Keys Fn}
      fun {Aux Rec Keys Fn}
	 case Keys of nil then Rec
	 else
	    %% !! not thread save
	    if {ReflectHasFeat1 Rec Keys.1}
	    then {Aux Rec.(Keys.1) Keys.2 Fn}
	       %% {Fn} can block, but value should be put at Keys immediately
	    else X in
	       {PutAux Rec Keys X}
	       X = {Fn}
	       X
	    end
	 end
      end
   in
      {Aux @Rec Keys Fn}
   end
   
   /** %% Returns entries of as list of pairs in form Feat#Val Rec (non-recursive).
   %% */
   fun {Entries1 Rec}
      {Map {RecordC.reflectArity Rec} fun {$ Feat} Feat#(Rec.Feat) end}
   end

   local
      fun {Aux Keys#Val}
	 if {IsAux Val}
	 then {LUtils.mappend {Entries1 Val}
	       fun {$ Key#Val} {Aux (Key|Keys)#Val} end}
	 else [{Reverse Keys}#Val]
	 end
      end
   in
      /** %% Returns the list of current entries of Rec. An entry is a pair Keys#X, where Keys is a list and X the corresponding item.
      %% */
      fun {Entries Rec}
	 {LUtils.mappend {Entries1 @Rec}
	  fun {$ Key#Val} {Aux [Key]#Val} end}
      end
   end
end
