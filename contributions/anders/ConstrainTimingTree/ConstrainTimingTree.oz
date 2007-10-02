
/** %% This functor introduces means which allow to constrain the shape of a timing tree. The duration of temporal items (e.g. notes or sequentials) may be 0 (zero). A temporal item with duration 0 is considered 'not existing' (e.g. its Lilypond output is skipped). Obviously, such an approach only allows to reduce the size of a tree (by 'removing' branches). Nevertheless, not only notes but also temporal aspects can be 'removed' -- in an extreme case the whole score may be effectively 'empty'.
%% This functor mainly defines AvoidSymmetries, a rule on the score which avoids symmetries in CSPs (i.e. irrelevant additional solutions). 
%%
%% NB: Every constraint on any temporal item -- which potentially shall be of duration=0 -- must be formulated not to conflict with AvoidSymmetries. For instance, AvoidSymmetries constraints the pitch of a note with duration=0 to its minimal domain value (by reflection!). A rule constraining all notes to have distict pitches will conflict in case multiple notes have duration=0 and thus potentially equal pitch. A rule on a single item is reformulated, e.g., by a reified rule as <code>{FD.impl ({MyItem getDuration($)} \=: 0) {MyRuleR MyItem} 1}</code>. Rules on multiple items (e.g. pattern rules or FD.distinct) require more drastic reformulation (e.g. sum the number of items with duration=0 and apply Pattern.howManyDistinct accordingly).
%%
%% NB: the memory needed for a score with constrained timing tree is always the memory needed the full score. Consequently, allowing for great flexibility in the effective size of the timing tree results in increases memory usage with more copying time etc (until Mozart supports recomputation).
%%
%% BTW: constraining the size/shape of the timing tree increases the size of the search tree no more then increasing the domain of any variable in the score (to which essentially it comes down to). Still, the size of the search tree may increase significantly.
%% */

functor
import
   FD % FS
   Combinator
   Browser(browse:Browse) % temp for debugging
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
export
   AvoidSymmetries
   IsExisting
   RelevantLength
   IsLastExistingItem
   AccessLastItem
   GetExistingItems
define

   local

      /** %% Returns the values of all parameters in TemporalItem, except for the start time, duration and end time.
      %% */
      fun {GetParameterValues TemporalItem}
	 Params = {Filter {TemporalItem getParameters($)}
		   fun {$ Param}
		      {Not 
		       ({Param hasThisInfo($ startTime)} orelse
			{Param hasThisInfo($ endTime)} orelse
			{Param hasThisInfo($ duration)})}
		   end}
      in
	 {Map Params fun {$ X} {X getValue($)} end}
      end
      
      /** %% Determine all elements in the list of constrained vars returned by {ParamValueAccessor MyItem} to their smallest domain value.
      %% */
      %%
      %% !! only def for FD ints and FS. Further domains can be added easily, though.
      %%
      proc {AvoidSymmetries_TimeMixin MyItem}
	 proc {MyConstraint}
	     ParamValues = {GetParameterValues MyItem}
	 in
	    %% determines all vars in ParamValues dependent on their domain
	    {ForAll ParamValues
	     proc {$ X}
		if {FD.is X} then X = {FD.reflect.min X}
		   %% !!! BUG: FS.value.is returns false for determined FS -- use {GUtils.isFS  X}
% 		elseif {GUtils.isFS X}
% 		elseif {FS.var.is X}
% 		then {FS.var.decl {FS.reflect.lowerBound X} X}
		end
	     end}
	 end
      in
	 %% MyConstraint applied if duration of MyItem = 0
	 {FD.impl
	  %{FD.nega {IsExisting MyItem}}
	  ({MyItem getDuration($)} =: 0)
	  {Combinator.'reify' MyConstraint}
	  1}
      end
	  
      proc {AvoidSymmetries_TemporalAspect MyAspect}
	 Durs = {MyAspect mapItems($ getDuration)}
      in
	 {Pattern.zerosOnlyAtEnd Durs}
      end
   in 
      /** %% AvoidSymmetries applies constrains on all temporal items in MyScore to avoid symmeries in case the duration of some temporal items is 0.
      %% Two rules are applied to the score: (i) for all temporal items, all parameter values are determined to their minimal domain value (execept the values of the parameters start time, duration and end time). (ii) for all temporal items in temporal aspects, 'non-existing' items are only 'collected' at the end of a temporal aspect.
      %% NB: Constraints are only aplied to the tree of temporal items whose root is MyScore. That is, AvoidSymmetries can be applied to a sub-score only.
      %% NB: this scheme only determines variables in temporal items which are parameter values of the item. As Strasheela is designed for distribution strategies over parameters, this should be sufficient (i.e. further variables which are no parameter values would not have been distributed neither).
      %%
      %% NB: Think about: AvoidSymmetries can cause problems, because it determines variables to a reflected min domain value which can be inconsistent with some other constraints on these variables. For example, perhaps the variable would be bound anyway by propagation before the next distribution, but AvoidSymmetries interferes and causes a fail.
      %% Idea: would AvoidSymmetries work more securely if optionally added to the distribution strategy?
      %% */
      %% !!?? filter out parameters according to test (i.e. params certainly determined by propagation: e.g. a note pitch is determined by AvoidSymmetries then its pitch class and octave will be determined by propagation)
      %%
      %% 
      proc {AvoidSymmetries MyScore}
	 {MyScore forAll(AvoidSymmetries_TimeMixin test:isTimeMixin)}
	 {MyScore forAll(AvoidSymmetries_TemporalAspect test:isTemporalAspect)}
	 %% forAll does not apply to self:
	 {AvoidSymmetries_TimeMixin MyScore}
	 if {MyScore isTemporalAspect($)}
	 then {AvoidSymmetries_TemporalAspect MyScore}
	 end
      end
   end

   /** %% B=1 <-> TemporalItem is existing (i.e. its duration \= 0).
   %%
   %% !! TODO: this constraint is possibly applied very often: consider memoizing. 
   %% */
   proc {IsExisting TemporalItem B}
      B = ({TemporalItem getDuration($)} \=: 0)
   end

   /** %% Returns the number of temporal items in TemporalAspect which are relevant (i.e. whose duration is NOT 0).
   %% NB (efficiency notice): This constraint implicitly constrains that all non-existing' items in TemporalAspect are only 'collected' at the end of the aspect. That is, this constrain makes AvoidSymmetries _partly_ redundant.
   %% */
   proc {RelevantLength TemporalAspect ?N}
      Durs = {TemporalAspect mapItems($ getDuration)}
   in
      {Pattern.relevantLength Durs N}
   end

   /** %%  B=1 <-> TemporalItem is an existing item which is either the last in its temporal container or is followed by a non-existing item.
   %% */
   proc {IsLastExistingItem TemporalItem B}
      IsExistingB = {IsExisting TemporalItem}
   in
      B = if {TemporalItem hasTemporalSuccessor($)}
	  then {FD.conj IsExistingB
		{FD.nega {IsExisting {TemporalItem getTemporalSuccessor($)}}}}
	  else IsExistingB
	  end
   end

   /** %% Accesses a value from the last "existing" item in TemporalAspect. Fn is a unary function or method: the result of Fn -- applied to the last existing item -- is returned in X.
   %% NB: AccessLastItem does not block, but Result remains undetermined until the last existing item in TemporalAspect is known (i.e. the durations of the items are sufficiently known). 
   %% */
   proc {AccessLastItem TemporalAspect Fn ?Result}
      {TemporalAspect
       forAllItems(proc {$ X}
		      {FD.impl {IsLastExistingItem X}
		       {Combinator.reify
			proc {$} Result = {{GUtils.toFun Fn} X} end}
		       1}
		   end)}
   end

   /** %% Returns the list of existing items in TemporalAspect.
   %% NB: blocks until for all items in TemporalAspect it is known whether they exist (i.e. the durations of the items are sufficiently known).
   %% */
   %% !! Why does filter block and not return a stream of items already known instead 
   proc {GetExistingItems TemporalAspect ?Items}
      Items = {Filter {TemporalAspect getItems($)}
	       fun {$ X} {IsExisting X} == 1 end}
   end
   
end
