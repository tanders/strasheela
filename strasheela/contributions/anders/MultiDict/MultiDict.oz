

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

/** %% This functor defines a multi-dimensional dictionary data structure, implemented by Oz' plain dictionaries. The key to a value in a multi-dimensional dictionary is a list Keys whose values are any combination of integers, atoms and names. 
%% */

%%
%% NB: this functor is not used in Strasheela and can be put elsewhere..
%%

functor
import
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   
export
   New Is Put Get CondGet CondGetPutting RemoveAll Entries
   
prepare
   /** marker for type checking */
   %% Defined in 'prepare' to avoid re-evaluation.
   MyType = {Name.new}
define

   /** %% Returns a new empty multi-dimensional dictionary.
   %% */
   proc {New X}
      X = {Dictionary.new}
      {Dictionary.put X MyType unit}
   end

   /** %% Tests whether X is a multi-dimensional dictionary.
   %% */
   fun {Is X}
      {Dictionary.is X} andthen {Dictionary.member X MyType} 
   end

   local
      /** %% Value used to check for non-valid dict keys.
      %% */
      NullToken = {NewName}
   in
      /** %% Sets the item in Dict under Keys to X.
      %% */
      proc {Put Dict Keys X}
	 case Keys of [Key] then {Dictionary.put Dict Key X}
	 else Aux = {Dictionary.condGet Dict Keys.1 NullToken}
	 in {Put if Aux==NullToken
		 then NewDict = {Dictionary.new}
		 in {Dictionary.put Dict Keys.1 NewDict}
		    NewDict
		 else Aux
		 end
	     Keys.2 X}
	 end
      end
   end

   /** %% Returns the item in Dict at Keys.
   %% */
   fun {Get Dict Keys}
      case Keys of nil then Dict
      else {Get {Dictionary.get Dict Keys.1} Keys.2}
      end
   end

   /** %% Returns the item in Dict at Keys if Keys is valid, otherwise DefVal is retured.
   %% NOTE: not thread-save.
   %% */
   fun {CondGet Dict Keys DefVal}
      case Keys of nil then Dict
      else
	 if {Dictionary.member Dict Keys.1}
	 then {CondGet {Dictionary.get Dict Keys.1} Keys.2 DefVal}
	 else DefVal
	 end
      end
   end
   

   /** %% Returns the item in Dict at Keys if Keys is valid, otherwise otherwise put X at Keys and return that.
   %% NOTE: not thread-save.
   %% */ 
   fun {CondGetPutting Dict Keys X}
      case Keys of nil then Dict
      else
	 if {Dictionary.member Dict Keys.1}
	 then {CondGetPutting {Dictionary.get Dict Keys.1} Keys.2 X}
	    %% {Fn} can block, but value should be put at Keys immediately
	 else {Put Dict Keys X} X
	 end
      end
   end

   
   /** %% Removes all entries currently in Dict.
   %% */
   proc {RemoveAll Dict}
      %% !!?? does GC claim all dicts etc?
      {ForAll {Filter {Dictionary.entries Dict} fun {$ X#_} X \= MyType end}
       proc {$ X#_} {Dictionary.remove Dict X} end}
   end

   /** %% Returns the list of current entries of Dictionary. An entry is a pair Keys#X, where Keys is a list and X the corresponding item.
   %% */
   fun {Entries Dict}
      fun {Aux Keys#Val}
	 if {Dictionary.is Val}
	 then {LUtils.mappend {Dictionary.entries Val}
	       fun {$ Key#Val} {Aux (Key|Keys)#Val} end}
	 else {Filter [{Reverse Keys}#Val] fun {$ Xs#_} Xs.1 \= MyType end}
	 end
      end
   in
      {LUtils.mappend {Dictionary.entries Dict}
       fun {$ Key#Val} {Aux [Key]#Val} end}
   end

end

