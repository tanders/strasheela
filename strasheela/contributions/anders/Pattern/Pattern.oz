
%%% *************************************************************
%%% Copyright (C) 2003-2005 Torsten Anders (t.anders@qub.ac.uk) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% This functor defines constraints on lists which help to express pattern in music. To combine multiple patterns to motifs see the contribution Motifs.
%% */

%% instead of a list I may use a tuplet to represent a pattern?
%%
%% * advantage: indexing is fast (!!?? do I need indexing here?)
%%
%% * disadvantage: length is fixed (for my application this is the
%% case anyway)
%%
%% * disadvantage: I need to change the def of various accessors of
%% the score representation to return tuplets or I always need to
%% transform a list into a tuplet
%%
%% Idea: internally within some pattern constraints I may transform a
%% list to a tuple

%% TODO:
%%
%% * many pattern (e.g. cycle etc.) may just unify their input list in
%%   a certain order, not FD int needed! Alternative def easy: replace
%%   arg of second arg with arg N (length of cycle) and use '='
%%   instead of '=:'...
%%
%% * for all pattern expecting proc/fun as arg: option to handle method as well
%%
%% * for all higher-order procs/funs in native Oz List functor: version in Pattern which handles method as well
%%
%% * ?? split functor into multiple functors: procs/funs processing lists of any values and procs/funs processing lists of kinded vars (i.e. FD ints)
%%

functor
import
   FD FS Combinator
   Select(fd) at 'x-ozlib://duchier/cp/Select.ozf'
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Browser(browse:Browse) % temp for debugging
export
   PlainPattern PlainPattern2
   Continuous AllEqual Increasing Decreasing
   InInterval
   Cycle Cycle2 Rotation Heap Random Palindrome Line Accumulation
   ArithmeticSeries GeometricSeries Max Min ArithmeticMean Range
   MarkovChain MarkovChain_1
   MakeLSystem MakeLSystem2
   OneOverFNoise OneOverFNoiseDeterm 
   %% combining patterns
   MapTail MapTailInd MapTailN ForTail ForTailInd ForTailN
   MapNeighbours MapNeighboursInd ForNeighbours ForNeighboursInd
   Map2Neighbours For2Neighbours
   ApplyToRange ForRanges MapRanges
   ParallelForAll ParallelMap
   ForCartesianProduct MapCartesianProduct
   Sublists
   ForPairwise MapPairwise
   ForSublists MapSublists
   CollectPM ForPM MapPM 
   Zip
   TransformDisj
   SelectList SelectMultiple ApplyToN
   HowManyDistinct
   HowManyAs
   HowMany Once
   ForN ForPercent NDifferences ForNEither
   AllTrue AllTrueR OneTrue OneTrueR SomeTrue SomeTrueR HowManyTrue HowManyTrueR
   WhichTrue
   SymbolToDirection DirectionToSymbol
   Direction DirectionR Contour InverseContour ContourMatrix
   DirectionChangeR
   FdInts FdRanges
   
   MkUniqueSeq MkUniqueIntervalSeq
   ConjAll DisjAll

   ZerosOnlyAtEnd RelevantLength
define
   
   /** % PlainPattern constraints Xs to a plain pattern (ie. no nesting or combination of patterns). The pattern is specified by the procedere Proc given to PlainPattern. Proc constraints a single pattern item and is called recursively. Proc expects two arguments: the current item and its predecessor in the list (i.e. Proc is called for all items except the first, which has no predecessor).
%*/
   %% !! this is in effect the same as For2Neighbours..
   proc {PlainPattern Xs Proc}
      {PlainPattern2 Xs
       proc {$ X Predecessors N}
	  %% ignore N		   
	  if Predecessors \= nil
	  then {Proc X Predecessors.1}
	  end
       end}
   end
    
   /** % PlainPattern2 constraints Xs to a plain pattern (ie. no nesting or combination of patterns) and is a variant of PlainPattern which adds additional control. The pattern is specified by the procedere Proc given to PlainPattern2. Proc constraints a single pattern item and is called recursively. Proc expects three arguments: the current item, a list with all previous pattern items in reverse order -- last is first), the number of generations processed so far (i.e. Proc is called for all items in Xs.
%*/
   proc {PlainPattern2 Xs Proc}      
      proc {Aux ToProcess Processed N}
	 {Proc ToProcess.1 Processed N}
	 if ToProcess.2 \= nil
	 then {Aux ToProcess.2 ToProcess.1|Processed N+1}
	 end
      end
   in
      {Aux Xs nil 1}
   end

   /** %% Constrain all elements in Xs to fulfill the relation: Predecessor A X. For instance, if A is '>:' then the relation Predecessor >: X  constraints all elements in Xs to decrease.
   % */
   %% !! renamed, was ApplyRelation
   %% !! def. changed: I swapped X and Predecessor, because this was more intuitive,
   %%
   %% !! TODO: define reified version of this (needs to extend/add
   %% reified PlainPattern def.)
   proc {Continuous Xs A}
      {PlainPattern Xs
       proc {$ X Predecessor}	
	  case A
	  of '>:' then Predecessor >: X
	  [] '>=:' then Predecessor >=: X 
	  [] '<:' then Predecessor <: X  
	  [] '=<:' then Predecessor =<: X  
	  [] '=:' then Predecessor =: X 
	  [] '\\=:' then Predecessor \=: X 
	  end
       end}
   end
   /** %% Constrain all elements in Xs to be greater then their predecessor in Xs.
   %% */
   proc {Increasing Xs}
      {Continuous Xs '<:'}
   end
   /** %% Constrain all elements in Xs to be less then their predecessor in Xs.
   %% */
   proc {Decreasing Xs}
      {Continuous Xs '>:'}
   end   
   /** % Constrain all elements in the Xs to be equal.
   % */
   proc {AllEqual Xs}
      {Continuous Xs '=:'}
   end

   /** % Constraints all elements in Xs to fall in interval [Min, Max], including.
   */
   proc {InInterval Xs Min Max}
      {ForAll Xs
       proc {$ X}
	  X >=: Min
	  X =<: Max
       end}
   end



   /** % Constrains all elements in the list Xs (FD variables) to form a cycle pattern of the (shorter) list Ys (FD variables). I.e. Xs enumerates the elementes of Ys in sequential order and loops back to the first element of Ys after the last element has been reached.
   % */
   %% !! changed name (was Cycle). Actually, I could remove this def, as the new Cycle allows equal expressivity and is more concise.
   proc {Cycle2 Xs Ys}
      {PlainPattern2 Xs
       proc {$ X Predecessors N}
	  X =: {LUtils.nthWrapped Ys N}
       end}
   end

   /** %% Unifies every element in Xs with its Lth predecessor.
   %% */
   proc {Cycle Xs L}
      {PlainPattern2 Xs
       proc {$ X Predecessors Ignore}
	  if {Length Predecessors} >= L
	  then X = {Nth Predecessors L}
	  end
       end}
   end

   
   /** %% Constrains all elements in the list Xs (FD variables) to form a rotation pattern of the (shorter) list Ys (FD variables).
   %% ?? unfinished doc: I probably should just do an example...
   %% !! TODO: additional args/control, see CM
   % */
   proc {Rotation Xs Ys}
      Offset = {Cell.new ~1}
      L = {Length Ys}
   in
      {PlainPattern2 Xs
       proc {$ X Predecessors N}
	  if {Int.'mod' N L} == 1
	  then {Cell.assign Offset
		{Cell.access Offset}+1}
	  end
	  X =: {LUtils.nthWrapped Ys N+{Cell.access Offset}}
       end}
   end

   
   /** % Constrains all elements in the list Xs (FD variables) to form a palindrome pattern of the (shorter) list Ys (FD variables).
   %% Elide (true | first | last | unit) allows to specify which elements in the pattern are not directly repeated when the pattern reverses direction.
   %% ?? unfinished doc: I probably should just do an example...
   % */
   proc {Palindrome Xs Ys Elide}
      L = {Length Ys}
      Period = case Elide
	       of true then {Append {List.take Ys L-1}
			     {List.take {Reverse Ys} L-1}}
	       [] first then {Append Ys {List.take {Reverse Ys} L-1}}
	       [] last then {Append {List.take Ys L-1} {Reverse Ys}}
	       else {Append Ys {Reverse Ys}}
	       end
   in
      {PlainPattern2 Xs
       proc {$ X Predecessors N}
	  X =: {LUtils.nthWrapped Period N}
       end}
   end

   /** Constrains all elements in the list Xs (FD variables) to form a cycle pattern of the (shorter) list Ys (FD variables). I.e. Xs enumerates the elements of Ys in sequential order and sticks on the last element once it has been reached.
   */
   proc {Line Xs Ys}
      L = {Length Ys}
   in
      {PlainPattern2 Xs
       proc {$ X Predecessors N}
	  I = if N < L
	      then N
	      else L
	      end
       in
	  X =: {Nth Ys I}
       end}
   end

   proc {Accumulation Xs Ys}
      I = {Cell.new 1}
      L = {Cell.new 1}
      TotalL = {Length Ys}
   in
      {ForAll Xs
       proc {$ X}
	  Index =
	  %% Is I still within period
	  if {Cell.access I} =< {Cell.access L}
	  then {Cell.access I}
	  else
	     %% would increased period be still within Ys
	     if  {Cell.access L}+1 =< TotalL
	     then
		%% start new longer period
		{Cell.assign L {Cell.access L}+1}
		{Cell.assign I 1}
		1
	     else
		%% start pattern over again
		{Cell.assign L 1}
		{Cell.assign I 1}
		1
	     end
	  end
       in
	  X =: {Nth Ys Index}
	  {Cell.assign I {Cell.access I}+1}
       end}
   end

%    %% !! This is not general enough, because the order of elements are predetermined. Better reimplement this with selection constraints: X is some element in Ys, I is in domain 
%    proc {Random Xs Ys}
%       L = {Length Ys}
%    in
%       {{PlainPattern2 proc {$ X Predecessors N}
% 			   I = {GUtils.random L}+1
% 			in
% 			   X =: {Nth Ys I}
% 			end}
%        Xs}
%    end
%    %% this suspends until Ys is determined
%    proc {Random Xs Ys}
%       {ForAll Xs proc {$ X}
% 		    X :: Ys
% 		 end}
%    end
   /** %% Constraints the domain of each element in Xs to contain only the elements of Ys.
   %% !! Only a random distribution enforces a random ordering here.
   %% */
   proc {Random Xs Ys}
      {ForAll Xs proc {$ X}
		    {Select.fd Ys _ X}
		 end}
   end



   /** % Constrains all elements in the list/stream Xs (FD variables) to form an arithmetic series, with the difference Difference (a FD variable) between the series members.
   % */
   proc {ArithmeticSeries Xs Difference}
      %% !! could be more propagation on bounds (i.e. max) of Difference
      {PlainPattern Xs
       proc {$ X Predecessor}
	  X =: Predecessor + Difference
       end}
   end
   /** % Constrains all elements in the list/stream Xs (FD variables) to form an geometric series, with the quotient Quotient (a FD variable) between the series members.
   % */
   proc {GeometricSeries Xs Quotient}
      {PlainPattern Xs
       proc {$ X Predecessor}
	  X =: Predecessor * Quotient
       end}
   end

   /** %% Y is constrained to be the maximum element in Xs. Xs is a list of FD integers and Y is (implicitely declared) a FD integer. 
   %% */
   proc {Max Xs Y}
      {LUtils.accum Xs
       fun {$ X1 X2} {FD.max X1 X2} end
       Y}
   end
   /** %% Y is constrained to be the minimum element in Xs. Xs is a list of FD integers and Y is (implicitely declared) a FD integer. 
   %% */
   proc {Min Xs Y}
      {LUtils.accum Xs
       fun {$ X1 X2} {FD.min X1 X2} end
       Y}
   end

   /** %% Constrains EncodedMean/Quotient (two FD int) to be the arithmetic means of ArithmeticMean (a list of FD ints). Encoding the means by the expression EncodedMean/Quotient allows to represent means which are ratios by FD ints. In the following example, the means is constrained to 1.5
   <code>{ArithmeticMean Xs 15 10}</code>
   %% */
   proc {ArithmeticMean Xs EncodedMean Quotient}
      L = {Length Xs}
      Sum = {FD.decl}
   in
      Sum = {FD.sum Xs '=:'}
      L * EncodedMean =: Sum * Quotient
   end

   /** %% Y (a FD int) is the distance between the maximum and the minimum value in Xs (a list of FD ints). A is a relation such as '=:' etc.
   %% NB: this rule poses the Max and Min pattern on Xs. 
   %% */
   proc {Range Xs A Y}
      {FD.distance {Max Xs} {Min Xs} A Y}
   end

   local
      %% Decls is the left-hand expression of the markov chain Decl, which possibly contains the wildcard 'x'
      proc {MatchesR Decls Xs B}
	 B = {ConjAll
	      {Map {LUtils.matTrans [Decls Xs]}
	       proc {$ [Decl X] B}
		  if Decl==x then B=1
		  else B = (Decl =: X)
		  end
	       end}}
      end
   in
      /** %% Constraints Xs (a list of FD ints) to form an nth-order markov chain according to Decl. A Decl clause takes any number of predecessors into account and specifies a single successor. Decl is a list of list pairs in the form <code>PredecessorSeq#PossibleSucessors</code>: after the occurance of PredecessorSeq in a sublist of Xs follows a value in PossibleSucessors. For example, the first order markov chain <code>{MarkovChain_1 Xs unit([1]#[2 3] [2]#[1] [3]#[2])}</code> causes any 1 in Xs to be followed by either 2 or 3 and any 2 by 1 etc.
      %% The list in PredecessorSeq can be of any length to specify any markov chain order. However, in all clauses the length should be equal.
      %% Additionally, the declaration can use the wildcard symbol 'x' which matches every FD int. For example, the clause <code>[x 1]#[2]</code> states that 1 is followed by 2.
      %% NB: The list of declarations in Decl specifies a number of disjunctions without any implicit 'otherwise' clause. An inappropriate Decl can cause no solution.
      %% Markov chains of order N pose constraints only on sublists of length N: a clauses <code>[x x 1]#[2]</code> does not simply constrain 1 to be followed by 2 but does constrain 1 with two predecessors be followed by 2. Workaround: append some aux FD ints in front of the list and remove them later again (this workaround is not automatically integrated in MarkovChain to avoid any undesired side effects -- its no foolproof trick and the user should thus be aware of it).
      %% NB: MarkovChain only specifies that certain elements follow each other. In opposite to the [usual / common] definition of a markov chain, however, MarkovChain does NOT constrain the probability of certain successors.
      %% */
      %% ??? Besides, multiple Decl clauses on the same (sub)-predecessor lists result in multiple alternatives on the same predecessors (i.e. more specific clauses -- clauses with less wildcards -- do NOT match better than less specific clauses).
      proc {MarkovChain Xs Decl}
	 %% the length of the first left hand side of a Decl clause
	 %% determines the markov chain order
	 Order = {Length Decl.1.1}
      in
	 {ForNeighbours Xs (Order + 1)
	  proc {$ SubXs}       	% SubXs is [each] sublist of Xs of length Order + 1
	     {DisjAll	% disj: alternative clauses in Decl
	      {Map Decl
	       fun {$ PreVals#SuccVals}			       
		  %% reified: the predecessor values PreValsVals matches
		  %% butlast of SubXs AND is followed by an element in SuccVals
		  {FD.conj
		   {MatchesR PreVals {LUtils.butLast SubXs}}
		   {FD.reified.int SuccVals {List.last SubXs}}}
	       end}
	      1}
	  end}
      end
   end
   
   /** %% Constraints Xs (a list of FD ints) to form a first order markov chain according to Decl. Decl is a record with only integers as features and lists of integers as fields. MarkovChain_1 poses the constraints that each element in Xs with the value of the Decl feature XVal is followed by an element whose value is one of the elements in the field of XVal. 
   %% For example, <code>{MarkovChain_1 Xs unit(1:[2 3] 2:[1] 3:[2])}</code> causes any 1 in Xs to be followed by either 2 or 3 and any 2 by 1 etc.
   %% NB: MarkovChain_1 only specifies that certain elements follow each other. In opposite to the [usual / common] definition of a markov chain, however, MarkovChain_1 does NOT constrain the probability of certain successors.
   %% */
   proc {MarkovChain_1 Xs Decl}
      {For2Neighbours Xs
       proc {$ X Y}
	  {DisjAll		% disj: alternative clauses in Decl
	   {Record.toList
	    {Record.mapInd Decl fun {$ XVal YVals}
				   %% reified: the predecessor value XVal
				   %% is followed by an element in YVals
				   {FD.conj
				    (X =: XVal)
				    {FD.reified.int YVals Y}}
				end}}
	   1}
       end}
   end
   
   
   /** %% N elements in Xs are pairwise distinct. Xs is a list of FD integers, N is a FD integer.
   %% */
   proc {HowManyDistinct Xs N}
      %% Implementation inspired by Denys Duchier
      %%
      %% Map all elements in Xs into a list of singleton sets. The union
      %% of all these singletons is a Set whose cardiality is the number
      %% of distict elements in Xs.
      Set = {FS.var.decl}
      Set1s = {Map Xs proc {$ X Set1}
			 Set1 = {FS.var.decl}
			 {FS.include X Set1}
			 {FS.card Set1 1}
		      end}
   in
      {FoldL Set1s.2 FS.union Set1s.1 Set}
      {FS.card Set N}
   end

   /** %% N elements in Xs are 'as' Val, i.e. either equal, or greater etc. A states the relation of the N elements to Val (A is one of '=:', '>:', '>=:', '<:', '=<:', '\\=:').
   %% Xs is a list of FD integers, Val and N are FD integers.
   %% */
   proc {HowManyAs Xs Val A N}
      {FD.sum 
       {Map Xs
	proc {$ X B}
	   B = {FD.int 0#1}
	   case A
	   of '>:' then B =: (X >: Val)
	   [] '>=:' then B =: (X >=: Val)
	   [] '<:' then B =: (X <: Val)
	   [] '=:' then B =: (X =: Val)
	   [] '\\=:' then B =: (X \=: Val)
	   end
	end}
       '=:'
       N}
   end
   
   /** %% X {FD int} occures N (FD int) times in Xs (list of FD ints).
   %% NB: weak propagation! In particular, there is NO propagation on X (except that it is explicitly limited to the union of all values in Xs).
   %% */
   proc {HowMany X Xs N}
      {FD.sum
       %% {FD.sumD %% no improvement
       {Map Xs
	proc {$ SomeX B}
	   B = (SomeX =: X)
	end}
       '=:' N}
      %% Additional propagation
      %%
      %% if N > 0 domain of X is union of all values in Xs
      X = {Select.fd Xs {FD.decl}}
   end

   /** %% X {FD int} occures only once in Xs (list of FD ints).
   %% NB: weak propagation! In particular, there is NO propagation on X (except that it is explicitly limited to the union of all values in Xs).
   %% */
   proc {Once X Xs}
      {HowMany X Xs 1}
   end

   

   /*
   /** %% B=1 <-> X = Y
   %% */
   proc {UnifyR X Y B}
      B = {Combinator.'reify' proc {$} X = Y end} 
   end
   /** %% X (any unifiable value) occures N (FD int) times in Xs (list of unifiable values).
   %% */
   proc {HowMany2 X Xs N}
      {FD.sum {Map Xs
	       proc {$ Y B}
		  B = {UnifyR X Y}
	       end}
       '=:' N}
   end
   */


   /** %% Constraint Fn (a unary function returning an 0/1 int) holds for N elements in Xs. N is a FD integer.
   %% */
   proc {ForN Xs Fn N}
      {HowManyTrue {Map Xs Fn} N}
      % {FD.sum {Map Xs Fn} '=:' N}
   end

   /** %% Constraint Fn (a unary function returning an 0/1 int) holds for between Min and Max percent. Min and Max are (determined) integers.
   %% */
   proc {ForPercent Xs Fn Min Max}
      L = {IntToFloat {Length Xs}}
      MinDomain = {FloatToInt L * {IntToFloat Min} / {IntToFloat 100}}
      MaxDomain = {FloatToInt L * {IntToFloat Max} / {IntToFloat 100}}
   in
      {ForN Xs Fn {FD.int MinDomain#MaxDomain}}
   end

   /** %% N elements of Xs hold the constraint Fn1, the rest holds Fn2.  Fn1 and Fn2 are unary functions returning an 0/1 int, N is a FD integer.
   %% */
   proc {ForNEither Xs Fn1 Fn2 N}
      {ForN Xs
       proc {$ X ?B}
	  B = {Fn1 X}
	  {FD.exor B {Fn2 X}
	   1}
       end
       N}
   end

   /** %% Xs and Ys are similar lists of the same length, but N elements differ. Xs and Ys are lists of FD integers, N is a FD integer.
   %% */
   proc {NDifferences Xs Ys N}
      {ForN {LUtils.matTrans [Xs Ys]}
       proc {$ [X Y] ?B}
	  B = {FD.decl}
	  B = (X \=: Y)
       end
       N}
   end

   /** %% Bs is a list of 0/1 integers (not implicitly declared). All elements in Bs are true (i.e. all elements are 1).
   %% */
   proc {AllTrue Bs}
      {FD.sum Bs '=:' {Length Bs}}
   end
   /** %% Reified version of AllTrue.
   %% */
   proc {AllTrueR Bs B}
      B = {FD.reified.sum Bs '=:' {Length Bs}}
   end
   /** %% Bs is a list of 0/1 integers (not implicitly declared). Exactly on element in Bs is true (i.e. one element is 1 and the rest is 0).
   %% */
   proc {OneTrue Bs}
      % {FD.sumD Bs '=:' 1} % should I do more propagation?
      {FD.sum Bs '=:' 1}
   end
   /** %% Reified version of OneTrue.
   %% */
   proc {OneTrueR Bs B}
      B = {FD.reified.sum Bs '=:' 1}
   end
   /** %% Bs is a list of 0/1 integers (not implicitly declared). At least one element in Bs is true (i.e. one element is 1 and the rest is 0).
   %% */
   proc {SomeTrue Bs}
      {FD.sum Bs '=<:' 1}
   end
   /** %% Reified version of SomeTrue.
   %% */
   proc {SomeTrueR Bs B}
      B = {FD.reified.sum Bs '=<:' 1}
   end

   /** %% Bs is a list of 0/1 integers (not implicitly declared) and N is a FD int: N elements in Bs are true (i.e. 1).
   %% */
   proc {HowManyTrue Bs N}
      {FD.sum Bs '=:' N}
   end
   /** %% Reified version of HowManyTrue.
   %% */
   proc {HowManyTrueR Bs N B}
      B = {FD.reified.sum Bs '=:' N}
   end
   
   /** %% WhichTrue constraints the Ith element in Bs to be true. Bs is a list of 0/1 integers and  I is a FD int. Only a single element of Bs is true (i.e. 1).
   %% */
   proc {WhichTrue Bs I}
      {OneTrue Bs}
      %% I is the index of the element which is 1
      {Select.fd Bs I 1}
   end
   
   /** %% Returns 0/1-int in B whether Y is either the maximum or the minimum in [X, Y, Z]. X, Y, Z and B are FD integers. NB: Y must either be greater or smaller than both X and Z (i.e. the values 1 1 2 represent not a direction change). 
   %% */
   %% !!?? Shall I generalise the operators, i.e. allows both <: and =<:
   proc {DirectionChangeR X Y Z ?B}
      {FD.disj
       {FD.conj (X <: Y) (Y >: Z)}
       {FD.conj (X >: Y) (Y <: Z)}
       B}
   end

   
   /** %% Transforms one of the three direction symbols '-', '=' and '+' to the corresponding integer from 0, 1, or 2 representing a direction as used by constraints such as Direction and Contour. 
   %% */
   fun {SymbolToDirection Symbol}
      Dict = unit('-':0 '=':1 '+':2)
   in
      Dict.Symbol
   end
   /** %% Transforms one of the integers 0, 1, and 2 representing a direction to the corresponding symbol from '-', '=' and '+'.
   %% */
   fun {DirectionToSymbol Direction}
      Dict = unit(0:'-' 1:'=' 2:'+')
   in
      Dict.Direction
   end

   %% Dir is constrained to the direction of the interval between X1 and X2. An interval 'upwards' (the predecessor is smaller than the successor) is represented by 2, an 'horizontal' interval (the predecessor and the successor are equal) is represented by 1, and an interval 'downwards' by 0.
   %% X1, X2, and Dir are all FD integers.
   %%
   %% !! Does not propagate well: e.g. Dir = {FD.int [0 1]} propagates, but Dir = {FD.int [1 2]} does not
   %% !! Determined Dir (upwards or downwards) does not propagate (i.e. does not remove domain values in X1 and/or X2 which are not upwards respectively downwards).
   %%
   proc {Direction X1 X2 Dir}
      IsUp = {FD.decl}
      IsEq = {FD.decl}
      % IsDown = {FD.decl}	% for propagation only
   in
      Dir = {FD.int 0#2}	% i.e. IsUp and IsUp exclude each other
      IsUp =: (X1 <: X2)
      IsEq =: (X1 =: X2)
      % IsDown =: (X1 >: X2)	% for propagation only
      % 1 =: IsUp + IsEq + IsDown % for propagation only
      %% IsUp \=: IsEq		% ?? not implicit, but is it helpful -- causes failure?
      %% Represented like binary number:
      %% nothing true: down: 00 = 0
      %% second digit true: horizontal: 01 = 1
      %% first digit true: up: 10 = 2
      % Dir =: (2*IsUp) + IsEq
      Dir = {FD.sumC [2 1] [IsUp IsEq] '=:'}
   end

   
   /** %% DirectionR is the reified version of Direction. B=1 <-> 'Dir represents the direction between X1 and X2'. An interval 'upwards' (the predecessor is smaller than the successor) is represented by 2, an 'horizontal' interval (the predecessor and the successor are equal) is represented by 1, and an interval 'downwards' by 0.
   %% X1, X2, and Dir are all FD integers. Dir is explicitly constrained to be in 0#2.
   %% */
   proc {DirectionR X1 X2 Dir B}
      IsUp = {FD.decl}
      IsEq = {FD.decl}	
   in
      Dir = {FD.int 0#2}	% i.e. IsUp and IsUp exclude each other
      IsUp =: (X1 <: X2)
      IsEq =: (X1 =: X2)
      %% IsUp \=: IsEq		% not implicit
      %% Represented like binary number:
      %% nothing true: down: 00 = 0
      %% second digit true: horizontal: 01 = 1
      %% first digit true: up: 10 = 2
      %% !!??
      % B =: (Dir =: (2*IsUp) + IsEq)
      B = {FD.reified.sumC [2 1] [IsUp IsEq] '=:' Dir}
   end

   /** %% Dirs is constrained to the contour of Xs: each element in Dirs represents the direction of an interval between two neighbouring elements in Xs. An interval 'upwards' (the predecessor is smaller than the successor) is represented by 2, an 'horizontal' interval (the predecessor and the successor are equal) is represented by 1, and an interval 'downwards' by 0. 
   %% Xs and Dirs are both lists of FD integers. The list Xs is one element longer than the list Dirs. 
   %% */
   %% !!?? soll ich zunaechst version fuer nur einzelne Werte def. und pattern fuer List ist damit def.?
   proc {Contour Xs Dirs}
      Dirs = {Map2Neighbours Xs Direction}
   end

   /** %% Xs and Ys are both contours of equal length (i.e. both lists of FD ints with domain 0#2). Ys is the inversion of Xs (and vice versa). 
   %% */
   proc {InverseContour Xs Ys}
      {ForAll {LUtils.matTrans [Xs Ys]}
       proc {$ [X Y]}
	  {ConjAll
	   [{FD.equi (X=:0) (Y=:2)}
	    {FD.equi (X=:1) (Y=:1)}
	    {FD.equi (X=:2) (Y=:0)}]
	   1}
       end}
   end
   
   /** %% ContourMatrix is a constraint similar in concept to Contour, but is more precise (and computationally more expensive). Dirs (FD list, implicitly created) is constrained to the contour matrix of Xs (FD list), unfolded into a list. Each element in Dirs represents the direction of an interval between two elements in Xs, i.e. {Direction {Nth Xs Pos_I} {Nth Xs Pos_J}}. Dir collects the results of Pos_I#Pos_J in the order [1#2 1#3 .. 1#N 2#3 .. 2#N .. N-1#N].
   %% In Dirs, an interval 'upwards' is represented by 2, an 'horizontal' interval is represented by 1, and an interval 'downwards' by 0. 
   %%
   %% ?? This concept stems from [R. Morris, 1987].
   %% */
   proc {ContourMatrix Xs Dirs}
      Positions = {LUtils.mappend {List.number 1 {Length Xs} 1}
		   fun {$ I}
		      {Map {List.number I+1 {Length Xs} 1}
		       fun {$ J} I#J end}
		   end}
   in
      Dirs = {Map Positions fun {$ I#J}
			       X1 = {Nth Xs I}
			       X2 = {Nth Xs J}
			    in
			       {Direction X1 X2}
			    end}
   end
   
   /** %% Constraints the domain bounderies of the elements in Xs (FD integers). Mins specifies the mininum and and Max the maximum domain value for each element in Xs.
   %% */
   proc {FdInts Xs Mins Maxs}
      {ForAll {LUtils.matTrans [Xs Mins Maxs]}
       proc {$ [X Min Max]}
	  %{Browse unit(x:X max:Max min:Min)}
	  {FD.int Min#Max X}
       end}
   end

   /** %% Constraints the domain bounderies of the elements in Xs (FD integers). Mids specifies the middle domain value and Ranges the width between the minimum and maximum domain value for each element in Xs.
   %% */
   proc {FdRanges Xs Mids Ranges}
      {ForAll {LUtils.matTrans [Xs Mids Ranges]}
       proc {$ [X Mid Range]}
	  %% if Range is odd, the half added to Mid for Max is by 1 larger
	  HalveRange = Range div 2
	  Min = Mid - HalveRange
	  Max = Mid + HalveRange + (Range mod 2)
       in
	  {FD.int Min#Max X}
       end}
   end

   
   %%
   %% Combining Patterns:
   %%
   %% ?? shall all these Fns move into LUtils
   %% 

   /** %% Collects the results of applying the unary function Fn (expecting a list) to Xs and recursively to the tail of each list Fn was applied to.
   %% For instance, <code>{MapTail [1 2 3 4] fun {$ Xs} Xs end}</code> returns <code>[[1 2 3 4] [2 3 4] [3 4] [4]]</code>.
   %% */ 
   fun {MapTail Xs Fn}
      case Xs
      of nil then nil
      [] X|Xr
      then {Fn X|Xr} | {MapTail Xr Fn}
      end
   end
   /** %% Similar to MapTail, but Fn is a binary function expecting the index as first argument.
   %% */
   fun {MapTailInd Xs Fn}
      fun {Aux I Xs}
	 case Xs
	 of nil then nil
	 [] X|Xr
	 then {Fn I X|Xr} | {Aux I+1 Xr}
	 end
      end
   in
      {Aux 1 Xs}
   end
   /** %% Similar to MapTail, but Fn is only applied to the first N lists.
   %% In case N > {Length Xs}, an exception is raised.
   %% */
   fun {MapTailN Xs N Fn}
      fun {Aux I Xs}
	 if I > N
	 then nil
	 else X|Xr = Xs in
	    {Fn I X|Xr} | {Aux I+1 Xr}
	 end
      end
   in
      if N > {Length Xs}
      then raise insufficiantArgs(MapTailN Xs N Fn) end
      end
      {Aux 1 Xs}
   end
   /** %% Applies the unary procedure P (expecting a list) to Xs and recursively to the tail of each list P was applied to.
   %% */ 
   proc {ForTail Xs P}
      case Xs
      of nil then skip
      [] X|Xr
      then {P X|Xr}
	 {ForAllTail Xr P}
      end
   end
   /** %% Similar to ForTail, but P is a binary procedure expecting the index as first argument.
   %% */
   proc {ForTailInd Xs P}
      proc {Aux I Xs}
	 case Xs
	 of nil then skip
	 [] X|Xr
	 then {P I X|Xr}
	    {Aux I+1 Xr}
	 end
      end
   in
      {Aux 1 Xs}
   end
   /** %% Similar to ForTail, but P is only applied to the first N lists.
   %% In case N > {Length Xs}, an exception is raised.
   %% */
   proc {ForTailN Xs N P}
      proc {Aux I Xs}
	 if I > N
	 then skip
	 else X|Xr = Xs in
	    {P I X|Xr}
	    {Aux I+1 Xr}
	 end
      end
   in
      {Aux 1 Xs}
   end

   /** %% Chop Xs into overlapping subsequences of length N. For example, {Sublists [a b c d] 2} results in [[a b] [b c] [c d]].
   %% */
   %% !! I can not easily move this into ListUtils: depends on Pattern.mapTailN
   fun {Sublists Xs N}
      SubListNr = {Length Xs} - N + 1
   in
      {MapTailN Xs SubListNr
       fun {$ I SubXs}
	  {List.take SubXs N}
       end}
      
   end
   
   /** %% Traverses through list Xs by mapping the unary function Fn (expecting a list) on each list of N (an int > 0) neighboring elements in Xs. The length of returned list is by N-1 shorter then Xs. 
   %% For instance, <code>{MapNeighbours [1 2 3 4 5] 3 fun {$ Xs} Xs end}</code> returns <code>[[1 2 3] [2 3 4] [3 4 5]]</code>.
   %% NB: MapNeighbours returns nil for N > {Length Xs}
   %% BTW: this pattern substitutes the most common pattern matching rule application mechanism of PWConstraints.
   %% */
   %% Name change: old MapNeighbours is now Map2Neighbours
   fun {MapNeighbours Xs N Fn}
      {Map {Sublists Xs N} Fn}
   end
   /** %% Similar to MapNeighbours, but Fn is a binary function expecting the index as first argument.
   %% */
   fun {MapNeighboursInd Xs N Fn}
      {List.mapInd {Sublists Xs N} Fn}
   end
   /** %% Similar to MapNeighbours, but P is a unary procedure applied to each list of N neighboring elements in Xs without a return value.
   %% */
   %% Name change: old ForNeighbours is now For2Neighbours
   proc {ForNeighbours Xs N P}
      {ForAll {Sublists Xs N} P}
   end
   /** %% Similar to ForNeighbours, but P is a binary procedure expecting the index as first argument.
   %% */
   proc {ForNeighboursInd Xs N P}
      {List.forAllInd {Sublists Xs N} P}
   end

   /** %% Traverses through Xs by mapping the binary function Fn on neighboring elements in Xs. The length of returned list is by one shorter then Xs. 
   */
   %% !!?? move into LUtils
   fun {Map2Neighbours Xs Fn} 
      {List.zip {List.take Xs {Length Xs}-1} Xs.2 Fn}
   end
   /** %% Traverses through Xs by applying the binary procedure Proc on neighboring elements in Xs.
   %% {For2Neighbours [1 2 3] P} -> {P 1 2} {P 2 3}
   */
   %% !!?? move into LUtils
   %% !! name changed, was ForAll2Neighbours
   proc {For2Neighbours Xs Proc}
      for X in {List.take Xs {Length Xs}-1}
	 Y in Xs.2
      do {Proc X Y}
      end
   end

   /** %% Applys P (a unary proc expecting a list) to the sublist of Xs (a list) that consists in the Start-th (and int) to the End-th (and int) elements (including).
   %% */
   %% !!?? worth def?
   proc {ApplyToRange Xs Start#End P}
      {P {LUtils.range Xs Start End}}
   end
   /** %% Applies P (a unary proc expecting a list) to each sublist of Xs (a list) that is declared by a range in Ranges. Ranges is a list consisting in integers and/or pairs of the form Start#End (two integers). 
   %% */
   proc {ForRanges Xs Ranges P}
      {ForAll {LUtils.ranges Xs Ranges} P}
   end
   /** %% Collects the results of applying Fn (a unary function expecting a list) to each sublist of Xs (a list) that is declared by a range in Ranges. Ranges is a list consisting in integers and/or pairs of the form Start#End (two integers). 
   %% */
   fun {MapRanges Xs Ranges Fn}
      {Map {LUtils.ranges Xs Ranges} Fn}
   end




   
   /** %% Traverses all lists in Xss in parallel and sequentially applies the unary procedure Proc (which expects a list as arg) on all first list elements, all second list elements etc. All sublists in Xss must be of same length.
   %% */
   proc {ParallelForAll Xss Proc}
      for Xs in {LUtils.matTrans Xss}
      do {Proc Xs}
      end
   end
   /** %% Traverses all lists in Xss in parallel and sequentially applies the unary function Fn (which expects a list as arg) on all first list elements, all second list elements etc. The results of Fn are bound sequentially to the elements in Ys. All sublists in Xss and Ys must be of same length.
   %% */
   proc {ParallelMap Xss Fn Ys}
      for
	 Xs in {LUtils.matTrans Xss}
	 Y in Ys
      do {Fn Xs Y}
      end
   end
   
   /** %% Applies the binary procedure P on all possible combinations of Xs and Ys. The order of applications is [{P X1 Y1} {P X1 Y2} ... {P X1 Yn} {P X2 Y1} ... {P Xn Yn}].
   %% */
   proc {ForCartesianProduct Xs Ys P}
      {List.forAllInd Xs
       proc {$ I X}
	  {List.forAllInd Ys
	   proc {$ J Y}
	      {P X Y}
	   end}
       end}
   end
   /** %% Collects in Zs the result of applying the binary function Fn on all possible combinations of Xs and Ys. The order in Zs is [{Fn X1 Y1} {Fn X1 Y2} ... {Fn X1 Yn} {Fn X2 Y1} ... {Fn Xn Yn}].
   %% */
   proc {MapCartesianProduct Xs Ys Fn Zs}
      LYs = {Length Ys}
   in
      {List.forAllInd Xs
       proc {$ I X}
	  {List.forAllInd Ys
	   proc {$ J Y}
	      %% !! Nth is unefficient
	      {Fn X Y {Nth Zs ((I-1)*LYs)+J}}
	   end}
       end}
      {List.drop Zs {Length Xs}*LYs} = nil % determine tail
   end
   /** %% Applies the binary function P on all pairwise combinations of Xs, i.e. {P Xs1 Xs2} .. {P Xs1 XsN} {P Xs2 Xs3} .. {P XsN-1 XsN}.
   %% */
   proc {ForPairwise Xs P}
      case Xs of nil then skip
      else
	 X1 = Xs.1
      in
	 {ForAll Xs.2 proc {$ X2} {P X1 X2} end}
	 {ForPairwise Xs.2 P}
      end
   end
   /** %% Collects the result of applying the binary function Fn on all pairwise combinations of Xs, i.e. [{Fn Xs1 Xs2} .. {Fn Xs1 XsN} {Fn Xs2 Xs3} .. {Fn XsN-1 XsN}].
   %% */
   fun {MapPairwise Xs Fn}
      case Xs of nil then nil
      else
	 X1 = Xs.1
      in
	 {Append 
	  {Map Xs.2 fun {$ X2} {Fn X1 X2} end}
	  {MapPairwise Xs.2 Fn}}
      end
   end

   /** %% Applies P (a unary procedure expecting a list) to any sublist in Xs (i.e. any list of succeeding elements in Xs).
   %% */
   proc {ForSublists Xs P}
      {ForAll {List.number 1 {Length Xs} 1}
       proc {$ I}
	  {ForAll {List.number I {Length Xs} 1}
	   proc {$ J}
	      {P {LUtils.sublist Xs I J}}
	   end}
       end}
   end

   /** %% Applies Fn (a unary function expecting a list) to any sublist in Xs (i.e. any list of succeeding elements in Xs) and returns all collected results in a list.
   %% */
   fun {MapSublists Xs Fn}
      {LUtils.mappend {List.number 1 {Length Xs} 1}
       fun {$ I}
	  {Map {List.number I {Length Xs} 1}
	   fun {$ J}
	      {Fn {LUtils.sublist Xs I J}}
	   end}
       end}
   end

   
%    /** %% Applies P (a unary procedure expecting a list) on all sublists of Xs which match the pattern matching expression PatternExpr. See the doc of MapPattern for details.
%    %%
%    %% !! the present implementation of ForPattern is not fully generalised. '*' must only occur as first element of PatternExpr or not at all. 
%    %% */
%    proc {ForPattern Xs PatternExpr P}
%       if PatternExpr.1 == '*'
% 	 %% pattern starts with Kleene star
%       then       
% 	 %% the positions of '?' in PatternExpr are the positions of
% 	 %% the matching variables in each sublist
% 	 Indices = {LUtils.positions '?' PatternExpr.2}
% 	 PatternLength = {Length PatternExpr.2}
%       in
% 	 {ForNeighbours Xs PatternLength
% 	  proc {$ Sublist} {P {Map Indices fun {$ I} {Nth Sublist I} end}} end}
% 	 %% no Kleene star
%       else
% 	 Indices = {LUtils.positions '?' PatternExpr}
%       in
% 	 {P {Map Indices fun {$ I} {Nth Xs I} end}}
%       end
%    end
%    /** %% Applies Fn (a unary function expecting a list) on all sublists of Xs which match the pattern matching expression PatternExpr.
%    %% MapPattern uses a very simple pattern matching language with only three symbols: '?', '_', and '*'. '?' indicates a single element in Xs which is included in the argument list of Fn. '_' indicates a single element in Xs which is excluded from the argument list of Fn. '*' indicates a zero or more elements in Xs which are excluded from the argument list of Fn.
%    %% Thus, the length of the argument list of Fn equals the number of '?' in PatternExpr. Besides, the elements in the argument list of Fn occur in the same order as in Xs.
%    %% For example,
%    %% <code>{MapPattern [a b c d e] ['*' '?' '_' '?'] fun {$ [X1 X2]} [X1 X2] end}</code>
%    %% returns <code>[[a c] [b d] [c e]]</code>
%    %%
%    %% !! the present implementation of MapPattern is not fully generalised. '*' must only occur as first element of PatternExpr or not at all. 
%    %% */
%    fun {MapPattern Xs PatternExpr Fn}
%       if PatternExpr.1 == '*'
% 	 %% pattern starts with Kleene star
%       then       
% 	 %% the positions of '?' in PatternExpr are the positions of
% 	 %% the matching variables in each sublist
% 	 Indices = {LUtils.positions '?' PatternExpr.2}
% 	 PatternLength = {Length PatternExpr.2}
%       in
% 	 {MapNeighbours Xs PatternLength
% 	  fun {$ Sublist} {Fn {Map Indices fun {$ I} {Nth Sublist I} end}} end}
% 	 %% no Kleene star
%       else
% 	 Indices = {LUtils.positions '?' PatternExpr}
%       in
% 	 [{Fn {Map Indices fun {$ I} {Nth Xs I} end}}]
%       end
%    end

   local
      fun {CollectPMAux Xs PatternExpr MatchingXs}
	 if PatternExpr==nil orelse Xs==nil
	 then [{Reverse MatchingXs}]
	 else case  PatternExpr.1
	      of 'x' then {CollectPMAux Xs.2 PatternExpr.2 Xs.1|MatchingXs}
	      [] '?' then {CollectPMAux Xs.2 PatternExpr.2 MatchingXs}
	      [] '*' then
		 %% minimal length: length of pattern without all occurances of '*'
		 MinL = {Length {Filter PatternExpr.2
				 fun {$ X} X \= '*' end}}
	      in
		 {FoldL {MapTail Xs 
			 fun {$ Sublist}
			    if {Length Sublist} >= MinL
			    then {CollectPMAux Sublist PatternExpr.2 MatchingXs}
			    else nil
			    end
			 end}
		  Append nil}
	      end
	 end
      end
   in
      /** %% Implements a pattern matching language very similar to the pattern matching language of PMC from PWConstraints.
      %% CollectPM returns in a list any list of elements from Xs (a list) which match the PatternExpr (a list of pattern symbols).
      %% The pattern matching language of CollectPM introduces three symbols: '*' is a place-holder matching 0 or more elements, '?' is a place-holder matching exactly one element and 'x' represents a pattern matching 'variable' (see Anders PhD thesis: Sec on PMC in survey II). For example, the PatternExpr [? * x x] matches any pair of subsequent elements of Xs except for the first pair: {CollectPM [a b c d] [? * x x]} returns [[b c] [c d]].
      %% */
      fun {CollectPM Xs PatternExpr}
	 {CollectPMAux Xs PatternExpr nil}
      end
   end
   /** %% Applies P (a unary procedure expecting a list) on all lists of elements from Xs (a list) which match the pattern matching expression PatternExpr (a list of pattern symbols). See CollectPM for details.
   %% */
   proc {ForPM Xs PatternExpr P}
      {ForAll {CollectPM Xs PatternExpr}
       P}
   end
   /** %% Applies Fn (a unary function expecting a list) on all lists of elements from Xs (a list) which match the pattern matching expression PatternExpr (a list of pattern symbols) and returns the results in a list. See CollectPM for details.
   %% */
   fun {MapPM Xs PatternExpr Fn}
      {Map {CollectPM Xs PatternExpr}
       Fn}
   end
   
   /** %% 'Zips' the sublists of Xss together in Ys by sequentially alternating between the sublists in Xss. E.g. {Zip [[1 2 3] [10 12 14]]} returns [1 10 2 12 3 14].
   %% NB: there is also List.zip which does something different. 
   %% */
   %%
   %% !! all sublists of Xss must be of same length??
   %%
   %% !!?? unfinished: this will be generalised by specifying OuterIs
   %% and InnerIs from outside... Other, perhaps more easy option:
   %% transform the input Xss before processing
   proc {Zip Xss Ys}
      L1 = {Length Xss}
      %% two parallel patterns of indexes: index in Xss und index
      %% in sublist of Xss. 
      L2 = {Length Xss.1}
      %% !! inefficient: I am generating full lists even if Ys is
      %% rather short and I don't use the whole pattern
      OuterIs = {Flatten
		 {LUtils.collectN L2
		  fun {$}
		     {List.mapInd {MakeList L1}
		      fun {$ I X} X=I end}
		  end}}
      InnerIs = {Flatten
		 {List.mapInd {MakeList L2}
		  fun {$ I X}
		     {LUtils.collectN L1
		      fun {$}
			 I
		      end}
		  end}}
   in
      %% !! Nth / NthWrapped is unefficient
      {List.forAllInd Ys
       proc {$ I Y}
	  OuterI = {LUtils.nthWrapped OuterIs I}
	  InnerI = {LUtils.nthWrapped InnerIs I}
       in
	  {Nth {Nth Xss OuterI} InnerI} = Y
       end}
      skip
   end

   /** %% Ys is some transformation of Xs. Fns is a list of binary procedures (both arguments are lists) which represent possible transformations. I (an argument which may be interesting as an output) is an index into Fns, a decision for I is equivalent with a decision for a certain transformation function. The domain of I is implicitly constrained to 1#{Length Fns}. 
   %% The length of the two arguments of each Fn must correspond with the lengths of Xs and Ys for a success. A mismatch causes the respective Fn to be ruled out in the disjuction.
   %% */
   %% !! I may redefine this proc with the help of GUtils.applySelected
   proc {TransformDisj Xs Fns I Ys}
      FnsL = {Length Fns}
      I :: 1#FnsL		% just to make sure...
%       fun {MakeOrClause I Xs PartYs}
% 	 {Record.mapInd {MakeTuple '#' FnsL}
% 	  fun {$ I X}		% ignore X
% 	     proc {$ Then}
% 		I = I
% 		proc {Then}
% 		   {{Nth Fns I} Xs} = PartYs
% 		end
% 	     end
% 	  end}
%       end
      fun {MakeOrClause Xs PartYs}
	 {Record.mapInd {MakeTuple '#' FnsL}
	  fun {$ FnI X}		% ignore X
	     proc {$}
		I = FnI
		{{Nth Fns I} Xs} = PartYs
	     end
	  end}
      end
   in
      {Combinator.'or' {MakeOrClause Xs Ys}}
   end

   
   /** %% Out of a list of lists of FD ints in Xss the Ith (a FD int) list Ys is selected (a list of FD ints). All lists in Xss and Ys must be of the same length.
   %% */
   proc {SelectList Xss I Ys}
      for Xs in {LUtils.matTrans Xss}
	 Y in Ys
      do
	 {Select.fd Xs I Y}
      end
   end

   /** %% Is (a list of FD ints) are the indices into Xs (a list of FD ints) at whose positions the values are Ys (a list of FD ints).
   %% Is and Ys are of equal length, Xs will often be longer than Ys.
   %% NB: Is are always increasing to reduce symmetries (i.e. multiple solutions with the same Xs).
   %%
   %% BTW: usage example: constrain only specific elements in Xs (i.e. Ys) by a pattern and constrain also the position of the elements to select (e.g. see examples/increasingTendency.oz).
   %% Or: constrain that at the Is values in Xs the direction changes (access predecessor and successor of each Y, e.g., by {Select.fd Xs I-1 Y}).
   %% */
   proc {SelectMultiple Xs Is Ys}
      {ForAll {LUtils.matTrans [Is Ys]}
       proc {$ [I Y]}
	  {Select.fd Xs I Y}
       end}
      {Increasing Is}
   end
   /** %% Applies P (a procedure expecting a list) to a sublist of N (an integer) elements out of Xs (a list of FD ints). Note that the sublist does not need to consist in neighbouring elements of Xs (but sublist elements are in the same order as in Xs). 
   %% NB: Is and Ys is not necessaily fully determined. However, not determining these values also avoids fully exploring multiple symmetric solutions (i.e. solutions with equal Xs).
   %% */
   %% !!?? worth def?
   proc {ApplyToN Xs N P}
      L = {Length Xs}
      Is = {FD.list N 1#L}
      Ys = {FD.list N 0#FD.sup}
   in
      {SelectMultiple Xs Is Ys} 
      {P Ys}
   end

   
   
   
   %%
   %% Unfinished
   %% 
  
   %% !! TODO: This is not general enough, because the order of elements are predetermined. Better reimplement this with selection constraints: in principle like the def of random. But collect also all index values and constraint a period of indexes by FD.distinct.
   proc {Heap Xs Ys}
      Heap = {Cell.new Ys}
   in
      {ForAll Xs
       proc {$ X}
	  CurrHeap = {Cell.access Heap}
	  L = {Length CurrHeap}
	  I = {GUtils.random L}+1
	  NewHeap = (if L==1 
		     then Ys
		     else {Append
			   {List.take CurrHeap I-1} 
			   {List.drop CurrHeap I}}
		     end)
       in		
	  X =: {Nth CurrHeap I}
	  {Cell.assign Heap NewHeap}
       end}
   end

   /** %% Returns a list of determined values sorted according to an L-system. Start is the first pattern period (a list) and N is number of periods (an integer). Rules is unary fun, arg is the last pattern value and output is the next period (a list). Rules can be defined, e.g., by a case expression.  
   %% NB: MakeLSystem works best with determined values and is thus no pattern rule which constraints values in a list as most other definitions in this functor. Nevertheless, symbols of the L-system can be replaced by variables (e.g. using LUtils.replace). See ./testing/Pattern-test.oz for examples.
   %% */
   %%
   %% !! This is not consistent with other pattern defs. I can not
   %% easily use undetermined variables here (instead of
   %% e.g. symbols). Shall I perhaps change the defs of other patterns
   %% accordingly?
   %%
   %% !! CM: arg generations sets number of rewrite generations, after that pattern repeats last generation like a cycle pattern. 
   fun {MakeLSystem Start N Rules}
      fun {Aux Xs N}
	 if N==0 then nil
	 else Next = {LUtils.mappend Xs Rules}
	 in {Append Next {Aux Next N-1}}
	 end
      end
   in
      {Append Start {Aux Start N-1}}
   end

   /** %% Returns a list of determined values sorted according to an L-system. Similar to MakeLSystem, however MakeLSystem2 allows the definition of context sensitive L-systems, systems which look not only at single values, but also at predecessors and/or successors (in the former period/generation). Rules is function of three arguments:  whole pattern so far in reverse order (i.e. a list with direct predecessor first), the current value and the succeeding values (list). Rules may, e.g., define an if or a case statement and can freely access all its arguments (e.g. to define the current element is x and the butfirst is y). The first arg of Rules is list with all predecessors of X in proceeding generation (and in reverse order) including earlier generations. This arg is nil in the vedry first iteration. The third arg of Rules is list with successors of X in proceeding generation (normal order) excluding later generations. This arg is nil at any end of a period. 
   %% NB: MakeLSystem works best with determined values and is thus no pattern rule which constraints values in a list as most other definitions in this functor. Nevertheless, symbols of the L-system can be replaced by variables (e.g. using LUtils.replace). See ./testing/Pattern-test.oz for examples.
   %% */
   fun {MakeLSystem2 Start N Rules}
      Result = {Cell.new nil}
      proc {AddToResult Xs}
	 {Cell.assign Result {Append {Reverse Xs} {Cell.access Result}}} 
      end
      proc {Aux Xs N}		% Xs is previous generation/period
	 if N==0 then skip
	 else Next = {FoldL
		      {List.mapInd Xs
		       fun {$ I X}
			  {Rules
			   {List.drop {Cell.access Result} {Length Xs}+1-I}
			   X
			   {List.drop Xs I}}
		       end}
		      Append nil}
	 in
	    {AddToResult Next}
	    {Aux Next N-1}
	 end
      end
   in
      {AddToResult Start}
      {Aux Start N-1}
      {Reverse {Cell.access Result}}
   end

   
   /** %% Returns a list of determistically created floats according to 1/f noise (i.e. x_n = (x_{n-1} + x_{n-1}^2) mod 1). L is the length of the list and Start is the first list value.
   %% spectrum: 1/f noise falls -3dB per octave.
   %% */
   %% !!?? is the used formula sound, formula from astronomy.swin.edu.au/~pbourke/fractals/1onfnoise/. For more information look at: www.firstpr.com.au/dsp/pink-noise/
   proc {OneOverFNoiseDeterm L Start Xs}
      Xs = {List.make L}
      Xs.1 = Start
      {For2Neighbours Xs
       proc {$ X1 X2}
	  fun {MyMod X}
	     %% defines mod 1 for float, i.e. returned float is in
	     %% interval [0,1]
	     if X > 0.0
	     then X - {Floor X}
	     else X + {Ceil X}
	     end
	  end
       in
	  X2 = {MyMod X1 + X1*X1}
       end}
   end

   /** %% Constraints a list of FD integers to random values according to 1/f noise (i.e. x_n = (x_{n-1} + x_{n-1}^2) mod 1). All Xs are in the domain 0#Max.
   %% This constraint is quasi deterministic -- determining a single variable determines the whole list only by constraint propagation.
   %% !! Currently, Max is fixed to 100
   %% */
   proc {OneOverFNoise Xs} % Max
      Max = 100
      Divisor = Max %(Max div 10 * Max div 10) 
   in
      Xs ::: 0#Max
      {For2Neighbours Xs
       proc {$ X1 X2}
	  X2 = {FD.modI (X1 + {FD.divI X1*X1 Divisor}) Max}
       end}
   end



   /** %% Returns a unary procedure which constraints its argument (a list of FD ints). The returned procedure is applied to multiple FD integer lists; the procedure pairwise 'unifies' the FD integers of each list. MaxDeviation (an integer) determines how far each constrained interval may differ from its restriction.
   %% This pattern can, e.g., be used to define a canon. 
   %% Please note: MkUniqueSeq must be called within the constraint script, otherwise the rule blocks.
   %% */
   fun {MkUniqueSeq MaxN MaxDeviation}
      %% !! RuleInts don't get necessarily determined
      %%
      %% RuleIntervals are the intervals to 'unify' the motifs with
      RuleInts = {FD.list MaxN 0#FD.sup}
   in
      proc {$ Xs}
	 {ParallelForAll [Xs
			  %% Xs may be shorter then Ruleints
			  {List.take RuleInts {Length Xs}}]
	  proc {$ [InX RuleX]}
	     {FD.distance InX RuleX '=<:' MaxDeviation}
	  end}
      end
   end
   /** %% Returns a unary procedure which constraints its argument (a list of FD ints). The returned procedure is applied to multiple FD integer lists; the procedure 'unifies' the interval sequence between the FD integers of each list. MaxDeviation (an integer) determines how far each constrained interval may differ from its restriction.
   %% This pattern can, e.g., be used to define a canon with a free transposition.
   %% Please note: MkUniquePitchSeqFn must be called within the constraint script, otherwise the rule blocks.
   %% */
   %% !! Refactor: this defs uses much of MkUniqueSeq
   fun {MkUniqueIntervalSeq MaxN MaxDeviation}
      %% !! RuleIntervals don't get necessarily determined
      %%
      %% RuleIntervals are the intervals to 'unify' the motifs with
      RuleIntervals = {FD.list MaxN-1 0#FD.sup}
      MaxInterval = FD.sup div 2 % to avoid neg. FD ints
   in
      proc {$ Xs}	 
	 InIntervals = {Map2Neighbours Xs
			proc {$ X1 X2 InInterval}
			   InInterval = {FD.decl}
			   InInterval =: (X2 - X1) + MaxInterval
			end}
      in
	 %{Browse mkUniqueIntervalSeq(xs:Xs intervals:InIntervals)}
	 {ParallelForAll [InIntervals
			  %% InIntervals may be shorter then RuleIntervals
			  {List.take RuleIntervals {Length InIntervals}}]
	  proc {$ [InInterval RuleInterval]}
	     {FD.distance InInterval RuleInterval '=<:' MaxDeviation}
	  end}
      end

   end

   /** %% B is constrained to 1 in case the sum of all elements in Xs equals the length of Xs and B is 0 otherwise. This is a shorthand for multiple nested FD.conj
   %% !! All elements in Xs must be 0#1 integers (i.e. no more than 1), as this constraint computes simply the sum.
   %% */
   proc {ConjAll Xs ?B}
      {FD.reified.sum Xs '=:' {Length Xs} B}
   end
   /** %% B is constrained to 1 in case  the sum of all elements in Xs is >= 1 and B is 0 otherwise. This is a shorthand for multiple nested FD.disj.
   %% */
   proc {DisjAll Xs ?B}
      {FD.reified.sum Xs '>=:' 1 B}
   end
%    /** %% Proc has two arguments and constraints two neighboring cycle periods (I can do transposition this way, but I can not change the cycle length)
%    %% SelectFn has two arguments, Xs (needed?) and N (the period number) and returns a list of FD vars specifying the period. ConstraintProc has three arguments, a list containing the predecessor period, a list containing the current period and the current period number. The proc constraints the period.
%    %% */
%    proc {VariatedCycle Xs Ys SelectFn ConstraintProc}
       
%    end

   
   /** %% Constrains Xs (list of FD ints) such that any zeros only occur at the end of Xs.
   %% Possible usage: when constraining the 'length' of a list, 'non existing' list elements are encoded by zeros. This constraint avoids symmeries in such a CSP: 'non-existing' list elements occur at the end of the list.
   %% */
   proc {ZerosOnlyAtEnd Xs}
      {For2Neighbours Xs
       proc {$ X Y} {FD.impl (X=:0) (Y=:0) 1} end}
   end

   /** %% Constrains N (a FD int, implicitly declared) to the position of the first occurence of a zero in Xs (list of FD ints).
   %% Possible usage: when constraining the 'length' of a list, 'non existing' list elements are encoded by zeros. This constraint returns the effectiv length of the list.
   %% This pattern rule implies the semantics of ZerosOnlyAtEnd.
   %% */
   %% Def by Raphael Collet (?? I added constrain on N)
   proc {RelevantLength Xs N}
      N = {FD.int 0#{Length Xs}}
      {List.forAllInd Xs proc {$ I X} (X >: 0) = (N >=: I) end}
   end
   
end

%% !! Idea: pattern for, e.g., sequence: cycle, but each period is transposed -- how can I generalise this idea? ... VariatedCycle

%% !! idea: for patterns as cycle etc. the period length is controllable (but pre-determined, or pattern suspends), e.g. by a determined list of period lengths.

%% !! TODO: Pattern elements follow list of pairwise relations (specified as a list of procedures) in a cycling fashion. E.g., the contour of the pattern can be constraint to obey the list ['<:' '=<:' '<:' '>:' '>=:'] in a cycling fashion. Additionally, a domain for the interval size may be constrained.
%% -> the idea to use a list of constraint procs can be generalised, does not need to be cycle (other options: walk through and in the end keep the last proc, use as heap...)

%% !! TODO: All integers in the list given to the pattern are equal with the (rounded) value of envelope Env at the position (position is know e.g. by ForAllInd)
%% (Xposition - 1) / (LengthXs - 1)
%% [This pattern just samples an envelope. However, by defining it the same way other patterns are defined -- as a unary procedure with a list as arg -- I can combine this pattern with other patterns]
%% ?? If pattern length is determined, I could also define fenvs as pattern

%% !! TODO:  The upper and lower domain bounds of a pattern are defined by two envelopes

%% !! TODO: markov chain pattern

%% !! idea: make a pattern reified -- then you may, eg., maximise the
%% number of patterns happening in a score

%% special downwards pattern forces the last value of the pattern to be well below the first one, while all others must lie between those two

%% patterns only constrain their input, they don't return
%% anything. Therefore, a nested pattern definition can not watch the
%% output pattern items to detect a nesting (ie. this does not work:
%% observe whether some pattern returns a pattern as item which then
%% gets 'inflated'). For a pattern constraint, a nesting must be
%% detected in the pattern definition.

%% !! CM allows almost all pattern args to be patterns themself
%% (eg. pattern period length) -- I will hardly go that far...
