
%%% *************************************************************
%%% Copyright (C) 2002-2005 Torsten Anders (www.torsten-anders.de)
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.  This program is
%%% distributed in the hope that it will be useful, but WITHOUT ANY
%%% WARRANTY; without even the implied warranty of MERCHANTABILITY or
%%% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
%%% License for more details.
%%% *************************************************************

/** %% This functor defines some general list utilities
%% */

functor 
import
   System
export
   Mappend
   CollectN RepeatN
   Contains
   Position Positions FindPosition FindPositions
   Remove
   Find
   CFilter CFind 
   Substitute Substitute1
   Count
   Accum
   SubtractList Split Sublist Sublists
   MatTrans NthWrapped
   EveryNth % OddPositions EvenPositions
   Replace
   ButLast LastN
   ArithmeticSeries ReciprocalArithmeticSeries
   %ArithmeticSeries GeometricSeries
   ExtendableList IsExtendableList
prepare
   /** %% marker for type checking
   %% */
   %% Defined in 'prepare' to avoid re-evaluation.
   ExtendableListType = {Name.new}
define
   %
   % List processing
   %
   /** %% Map function Fn (which must return a list) over all elements of list Xs and append all resulting lists. 
   %% */
   fun {Mappend Xs Fn}
      {List.foldR {List.map Xs Fn} Append nil}
   end
   /**  %% Return a list of N elements, each element is bound to the result of calling the unary procedure Fn.
   %% */
   fun {CollectN N Fn} 
      {Map {MakeList N} fun {$ X} X={Fn} end}
   end
   /** %% Return a list of N elements, each element is bound to the same X.
   %% */ 
   fun {RepeatN N X}
      {Map {MakeList N} fun {$ Y} Y=X end}
   end

   /** %% Returns true if Ys contains X and false otherwise.
   %% */
   %% !! Args should be swapped for consistency
   fun {Contains X Ys}
      CompareFn=System.eq	% shall I make this an arg?
   in
      case Ys
      of nil then false
      [] Y|Yr  
      then if {CompareFn X Y}
	   then true
	   else {Contains X Yr}
	   end
      end
   end
   
   /** %% Returns position of the first occurence of X in list Ys. 
   %%*/	
   %% !! Args should be swapped for consistency
   fun {Position X Ys}
      CompareFn=System.eq	% shall I make this an arg?
      fun {Aux X Ys I} 
	 case Ys
	 of nil then nil
	 [] Y|Yr  
	 then if {CompareFn X Y}
	      then I
	      else {Aux X Yr I+1}
	      end
	 end
      end
   in
      {Aux X Ys 1}
   end   
   /** %% Returns the positions of all occurences of X in list Ys. 
   %%*/	
   %% !! Args should be swapped for consistency
   fun {Positions X Ys}
      CompareFn=System.eq	% shall I make this an arg?
      fun {Aux X Ys I Result} 
	 case Ys
	 of nil then {Reverse Result}
	 [] Y|Yr  
	 then if {CompareFn X Y}
	      then {Aux X Yr I+1 I|Result}
	      else {Aux X Yr I+1 Result}
	      end
	 end
      end
   in
      {Aux X Ys 1 nil}
   end 
   /** %% Returns position of the first element in X for which Fn returns true. 
   %%*/	
   fun {FindPosition Xs Fn}
      fun {Aux Xs I} 
	 case Xs
	 of nil then nil
	 [] X|Xr  
	 then if {Fn X}
	      then I
	      else {Aux Xr I+1}
	      end
	 end
      end
   in
      {Aux Xs 1}
   end
   /** %% Returns position of the first element in X for which Fn returns true. 
   %%*/	
   fun {FindPositions Xs Fn}
      fun {Aux Xs I Result} 
	 case Xs
	 of nil then {Reverse Result}
	 [] X|Xr  
	 then if {Fn X}
	      then {Aux Xr I+1 I|Result}
	      else {Aux Xr I+1 Result}
	      end
	 end
      end
   in
      {Aux Xs 1 nil}
   end
   /** %% Remove returns a list of the elements in Xs for which the application of the unary boolean function Fn yields false. In the output, the ordering in Xs is preserved. 
   %% */
   fun {Remove Xs Fn} 
      {Filter Xs fun {$ X} {Not {Fn X}} end}
   end
   /** %% Find returns the first element in Xs for which the application of the unary boolean function Fn yields true. 
   %% */
   fun {Find Xs Fn}
      % {List.takeWhile Xs Fn}.1 % does not work for nil.1
      case Xs
      of nil then nil
      [] X|Xr
      then if {Fn X} then X 
	   else {Find Xr Fn}
	   end
      end 
   end

   /** %% Concurrent variant of Filter. Like Filter, CFilter returns a stream/list of elements in Xs for which F (a Boolean function) returns true. However, CFilter does not necessarily completely block on free variables in Xs. Instead, it returns/skips elements of Xs as soon as enough information is provided to decided either way, possibly changing the order of list elements. If it is known that no elements will be added, then the stream Result will be closed.
   %% Less efficient than Filter (e.g., many threads are created).
   %% */ 
   proc {CFilter Xs F ?Result}
      Result_XL = {New ExtendableList init}
      %% Stream for notifying that F returned for an element of Xs
      Finished_L
      Finished_P = {NewPort Finished_L}
      L = {Length Xs}
   in
      Result = Result_XL.list
      {ForAll Xs proc {$ X}
		    thread
		       if {F X}
		       then
			  {Result_XL add(X)}
			  {Send Finished_P unit}
		       else {Send Finished_P unit}
		       end
		    end
		 end}
      %% Wait until F returned a value for all elements of Xs, then close list
      thread
	 proc {Aux Xs I}
	    {Wait Xs.1}
	    if I==L then {Result_XL close}
	    else {Aux Xs.2 I+1}
	    end
	 end
      in
	 {Aux Finished_L 1} 
      end
   end

   /** %% Concurrent variant of Find. Like Find, CFind returns one element in Xs for which F returns true. However, the Result is not necessarily the first 'matching' element in Xs. CFind returns a result as soon as enough information is available to decide for any element -- even if free variables are in Xs before that element.
   %% Less efficient than Find (e.g., many threads are created).
   %% */
   proc {CFind Xs F ?Result}
      %% use a port for collecting results to avoid race conditions and locks
      S P={NewPort S}
      Threads = {Map Xs proc {$ X T}
			   thread
			      T={Thread.this}
			      if {F X} then {Send P X} end
			      %% keep all threads running, so they can
			      %% all be terminated without errors
			      %% (catching the exception would not work
			      %% from other threads..)
			      {Wait _}
			   end
			end}
   in
      Result = S.1     % wait for first value sent
      {ForAll Threads Thread.terminate}
   end

   
   /** %% Replaces all occurances of Old in Xs by New. 
   %% */
   fun {Substitute Xs Old New}   
      CompareFn=System.eq	% shall I make this an arg?
   in
      case Xs
      of nil then nil
      [] X|Xr
      then if {CompareFn X Old} then New | {Substitute Xr Old New}
	   else X | {Substitute Xr Old New}
	   end
      end 
   end
   /** %% Replaces the first occurance of Old in Xs by New. 
   %% */
   fun {Substitute1 Xs Old New}   
      CompareFn=System.eq	% shall I make this an arg?
   in
      case Xs
      of nil then nil
      [] X|Xr
      then if {CompareFn X Old} then New | Xr
	   else X | {Substitute1 Xr Old New}
	   end
      end 
   end

   /** %% Returns the number of elements in Xs for which the unary boolean function Fn returns true.
   %% */
   fun {Count Xs Fn}
      fun {Aux Xs I} 
	 case Xs
	 of nil then I
	 [] X|Xr  
	 then if {Fn X}
	      then {Aux Xr I+1}
	      else {Aux Xr I}
	      end
	 end
      end
   in
      {Aux Xs 0}
   end
   
   /** %% Binds the accumulation of the binary function Fn on all neighbors in Xs to Y. E.g., Accum returns the sum in Xs if Fn is Number.'+'.
   % */
   proc {Accum Xs Fn Y}
      {List.foldL Xs.2 Fn Xs.1 Y}
   end
   
   /** %% SubtractList returns a list which contains all elements of Xs except the (leftmost occurrences of) elements in Ys if they are in Xs. 
   %%*/
   fun {SubtractList Xs Ys}
      {FoldL Ys fun {$ Xs Y} {List.subtract Xs Y} end Xs}
   end

   /** %% Splits Xs at all occurences of Y. Split returns a list of sublists between (possibly multiple) Y and skips Y itself.
   %% NB: String.tokens does the same..
   %% NB: if last element of list is Y, then it is simply omitted.
   %% */
   fun {Split Xs Y}
      Pos = {Position Y Xs}
   in
      if Pos==nil
      then if Xs==nil then nil else [Xs] end
      else 
	 XsHead XsTail in
	 {List.takeDrop Xs Pos-1 XsHead XsTail}
	 XsHead | {Split XsTail.2 Y}
      end
   end



   
   /** %% Returns the sublist of Xs that consists in the Start-th to End-th elements (including). If End > {Length Xs}, sublist returns a sublist up to the last element of Xs.
   %% */
   fun {Sublist Xs Start End}
      {List.drop {List.take Xs End}
       Start-1}
   end
   /** %% Returns the list of sublists of Xs (a list) such that each sublist is declared by a range in Decls. Decls is a list consisting in integers and/or pairs of the form Start#End (two integers). 
   %% */
   fun {Sublists Xs Decls}
      {Map Decls
       fun {$ Decl}
	  case Decl
	  of Start#End
	  then {Sublist Xs Start End}
	  else if {IsInt Decl}
	       then [{Nth Xs Decl}]
	       else
		  {Exception.raiseError
		   kernel(type
			  Sublists
			  [Xs Decls _]		% args
			  'int or range' % type
			  2 % arg position
			  "A range spec must be either an integer or a pair of two integers Start#End."
			 )}
		  unit % never returned
	       end
	  end
       end}
   end

   /** %% Quasi a matrix transformations: transforms a list of form [[a1 a2 ... an] [b1 b2 ... bn] ... [n1 n2 ... nn]] into [[a1 b1 ... n1] [a2 b2 ... n2] ... [an bn ... nn]].
   %% */
   fun {MatTrans Xss}
      {List.mapInd {MakeList {Length Xss.1}}
       fun {$ I X}
	  %% !! implementation using Nth not efficient, list is multiple
	  %% times traversed
	  X = {Map Xss fun {$ Xs} {Nth Xs I} end}
       end} 
   end

   /** %% Returns element of Xs at index N. However, if N is outside the interval [1, {Length Xs}] NthWrapped 'wraps' N back into this interval. I.e. if N={Length Xs}+1 NthWrapped returns Xs.1
   */
   fun {NthWrapped Xs N}
      {Nth Xs {Int.'mod' N-1 {Length Xs}}+1}
   end

   /** %% Returns a list with every N-th element of Xs (by preserving the order).
   %% NB: causes infinite loop if N=0.
   %% */ 
   fun {EveryNth Xs N}
      %% transform into tuple to allow for constant time access (is this really more efficient?)
      XR = {List.toTuple unit Xs}
   in
      for I in 1..{Width XR};N
	 collect:C
      do {C XR.I}
      end 
   end   
   
   /*
   %% generalised version of EveryNth, but buggy -- arithm series outputs 0-based positions (not 1-based as required for Oz) and influence Offset is ignored for length of arithm series
   
   %% Returns a list which contains every Nth element in Xs starting at offset.
   %% 
   fun {EveryNth Xs N Offset}
      %% transform into tuple to allow for constant time access (is this really more efficient?)
      {Map {ArithmeticSeries {IntToFloat Offset} {IntToFloat N}
	    {FloatToInt {Ceil {IntToFloat {Length Xs}} / {IntToFloat N}}}}
       fun {$ I} {Nth Xs {FloatToInt I}} end}
   end

    %% Returns every element in Xs at an odd position.
   %% 
   fun {OddPositions Xs} {EveryNth Xs 2 1} end
    %% Returns every element in Xs at an even position.
   %%
   fun {EvenPositions Xs} {EveryNth Xs 2 0} end
   */
   
   /** %% Replaces all elements in Xs (a list of atoms) by the value in the record R at the feature equal to the list element. If R has no such feature the list element remains.
   %% */
   fun {Replace Xs R}
      case Xs
      of nil then nil
      [] X|Ys then {CondSelect R X X}|{Replace Ys R}
      end
   end

   /** %% Returns all but the last elements of Xs
   %% */
   fun {ButLast Xs}
      {List.take Xs {Length Xs}-1}
   end

   /** %% Returns the last N elements of Xs (quasi the opposite of List.take).
   %% */
   fun {LastN Xs N} {Reverse {List.take {Reverse Xs} N}} end
   
   

   
   /** %% Returns an arithmetic series with N elements, starting from start and with difference Difference between the elements.
   %% Start and Difference must be floats, N must be an integer. A list of floats is returned.
   %% */
   %% !!?? do I need this in core of Strasheela? List.number only works for integers...   
   fun {ArithmeticSeries Start Difference N}
%       for I in Start .. (Start+Difference*N); Difference
% 	 collect:C
%       do {C I}
%       end
      {List.mapInd {MakeList N}
       fun {$ I X}		% ignore X
	  Start+Difference*({Int.toFloat I}-1.0) 
       end}
   end
   
   /** %% Returns the reciprocals of an arithmetic series with N elements. The arithmetic series starts from start and has difference Difference between its elements. Start and Difference must be floats, N must be an integer. A list of floats is returned.
   %% The  reciprocal series is not transposed, i.e. for Difference>0 seach series element is smaller than its predecessor and all but the first series elements are < Start.
   %% */   
   %% !!?? do I need this in core of Strasheela?
%    fun {ReciprocalArithmeticSeries Start Difference N}
%       Xs = {ArithmeticSeries Start Difference N}
%       %% !! if Difference>0 MaxX  is always last of Xs, otherwise first
%       MaxX = {FoldL Xs.2 Max Xs.1}
%       Transposition = MaxX * Start
%    in
%       {Map Xs fun {$ X} 1.0/X * Transposition end}
%    end
   fun {ReciprocalArithmeticSeries Start Difference N}
      {Map {ArithmeticSeries Start Difference N}
       fun {$ X} 1.0 / X end}
   end

   
%     %% 
%    %% 
%    fun {ArithmeticSeries N Start Summand}
%       {List.number Start ((N-1)*Summand+Start) Summand}
%    end
%    %% 
%    %% 
%    %% N!! wrong def
%    fun {GeometricSeries N Start Factor}
%       {Map {List.number 0 N-1 1}
%        fun {$ I}
% 	  {Pow Factor I} 
%        end}
%    end

   /** %% An ExtendableList instance provides the feature list, which is a list whose tail is unbound. The list is a stateless data structure. However, new list elements can be added at the tail of the list.
   %% This datastructure is similar to a Port. The difference is that (i) the tail is not protected (no read-only variable) and (ii) the resulting stream can be closed, thus transforming the stream into a proper list. 
   %% NB: adding new list elements is a stateful operation (the binding of the internal attribute tail is changed), but the state is completely encapsulated in this data structure.
   % */
   class ExtendableList
      prop locking
      feat list !ExtendableListType:unit
      attr tail
      meth init
	 @tail = self.list
      end      
      /** % Adds X to an extendable list in constant time. X becomes an element at the tail of List. 
      %% */
      meth add(X)
	 Y
      in
	 lock
	    @tail = X|Y
	    tail <- Y
	 end
      end
      /** %% Alias for method add (Oz types like Dictionary define put instead of add).
      %% */
      meth put(X)
	 {self add(X)}
      end
      meth addList(L)
	 {ForAll L proc {$ X} {self add(X)} end}
      end
      /** % Binds the tail of an extendable list to nil and that way 'closing' the list.
      %%*/
      meth close @tail = nil end
   end
   /** %% Returns a boolean whether X is an ExtendableList
   %%*/
   fun {IsExtendableList X}
      {Object.is X} andthen {HasFeature X ExtendableListType}
   end
end

