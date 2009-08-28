
%%
%% This functor provides the facilities to define transformabel subscripts. Transformable subscripts are extended scripts (as defined with Score.defSubscript) that additionally provides means for defining and transforming motif features applied to the resulting subscript. 
%%

%%
%% TODO:
%%
%% !! - for only partical value lists of motif features (see offset time example in test file) introduce something like '_' to indicate dummy values (cf. pattern motifs..)
%%   It is important that these are not variables, because variables on the toplevel would cause blocking
%%
%% - def further motif variation functions
%%
%% - ?? generalise rhythmic values independent of timeUnit 
%%
%% - ??  Prototype-based motif def: create a motif description for DefExtendedSubscript from existing motif instance
%%
%%

functor 

import
   FD % FS

   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
%    Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
%    HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   Fenv at 'x-ozlib://anders/strasheela/Fenv/Fenv.ozf'
%   Segs at '../Segments.ozf'
   
export
   DefSubscript

   RemoveNotesAtEnd RemoveShortNotes
   SubstituteNote
   DiminishAdditively AugmentAdditively DiminishMultiplicatively AugmentMultiplicatively

   TransformMotifLength
   TransformMotifList
   FenvMapMotifList

   GetMotifLength
   GetMotifList
   
define

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% DefSubscript with transformation support
%%%
   
   /** %% DefSubscript is an entended variant of Score.defSubscript that additionally provides means for defining and transforming motif features applied to the resulting subscript.
   %% Strasheela supports a number of motif models and several also provide some support for variation. Special about the variation support of DefSubscript is the fact that a description of the motif itself is varied, and the motif instance is created only afterwards using this varied description. This design as advantages and disadvantages.
   %% Advantages are the following. Variation definitions are more flexible. In particular, the length of the motif can be changed easily. For example, some short not can be inserted somewhere in the middle or the motif can be condensed (e.g., the first n notes can be dropped). Even if the number of motif notes is varied, there are no "non-existing" note objects of duration 0, which simplifies constraint application.
   %% The disadvantage is that variations that change the structure of the motif (e.g. change the note number of the note order) must be determined before the search starts (otherwise the search blocks). Nevertheless, this only determines the motif description (e.g., only the pitch contour or intervals, but the actual pitches are found during search). Also, the motif identity of a motif instance is determined in the CSP definition (the limitation is shared by other motif models, e.g., the prototype model and subscripts in general). Variation that could be expressed by constrained variables (e.g., motif transposition) can in principle be left undetermined in the problem definition (e.g., the amount of transposition is found during the search). However, if some arguments to the subscript require search decisions (distribution) then they must be encapsulated in item parameters (e.g., new parameters added to the notes of a motif). Another disadvantage is that this motif model is best suited for sequences of notes (a limitation shared by the motif models pattern motif and variation motif, but not by the protoype motif model and subscripts in general).
   %%
   %% Like Score.defSubscript, DefSubscript expects arguments in DefArgs (a nested record of arguments) a Body that applies constraints, possibly using subscript arguments (a binary procedure or nil). It returns an extended script (a binary procedure). See the documentation of Score.defSubscript for further details.
   %%
   %% DefSubscript adds two arguments to Score.defSubscript as features of DefArgs.
   %%
   %% 'motif' (default unit): a record that describes arbitrary motif features. These features are potentially varied. Each motif feature is specified by its own record feature/value of the following format: FeatureName: ValueList#Accessor. FeatureName is some arbitrary atom to denote the motif feature, ValueList is a list (usually of FD ints) and Accessor is a unary function or an n-ary method applied to the motif (the container). If it is a method, then all method arguments (except the container) must be specified. Accessor must return a list of variables and this list is unified with ValueList. In the following example, the note durations of the motif are set to the ValueList [2 2 4]. FeatureName is 'durations' and the accessor is a function that returns the list of note durations contained the the motif.

   unit(durations: [2 2 4]#fun {$ X} {X mapItems($ getDuration)} end)

   %% Using a method instead of a function results in a more concise specification. (Methods are automatically translated to functions with GUtils.toProc, aditional args given the function resulting from n-ary methods are always only unit) 

   unit(durations: [2 2 4]#mapItems(_ getDuration))

   %% For a specification like the one above the resulting note number of the motif can be deduced automatically (the length of ValueList). If the number of notes does not equal the length of the specified value lists, then the note number must be specified as an integer given to the  optional argument 'n'. Example:

   unit(n: 5
	durations: [2 2 4]#mapItems(_ getDuration)
	pitchContour: [2 0]#fun {$ X} {Pattern.direction {Pattern.map2Neighbours {X getItems($)}}} end)

   %%
   %% 'transformers' (default nil): a list of binary functions that define motif variations. Each function expects a full motif specification and the full argument record of the subscript (i.e. args given to the subscript call and default values for all other args) and returns a somehow transformed full motif specification. A transformer function typically defines its arguments as rarg features. The transformer function Foo below expects the argument 'foo', whose default is 'bar'.

   fun {Foo MotifSpec Args}
      Default = unit(rargs: unit(foo: bar)) 
      As = {GUtils.recursiveAdjoin Default Args}
   in
      <body>
   end
   
   %% Arbitrary transformations of the motif specification are allowed, but typically the value lists of the motif features are somehow changed. Convenience functions simplify such transformations (see the source of the transformations below for examples).
   %%
   %% Note that the transformer functions are accumulatively processing the motif specification: the second function processes the output of the first and so forth.
   %%
   %%
   %% NB: as the number of items in the resulting motif is specified otherwise, DefSubscript does not support the Score.defSubscript DefArgs argument unit(idefaults: unit(n:N)) nor unit(iargs(n:N)). 
   %%
   %% */
   fun {DefSubscript DefArgs Body}
      Default = unit(super:Score.makeContainer
		     mixins: nil
		     defaults: unit
		     idefaults: unit
		     rdefaults: unit)
      DefAs = {Adjoin Default DefArgs}
      MotifSpec = {CondSelect DefArgs motif unit}
      Transformers = {CondSelect DefArgs transformers nil}
   in
      proc {$ Args ?MyScore}
	 ItemAs = if {HasFeature Args iargs} then
		     {Adjoin DefAs.idefaults Args.iargs}
		  else DefAs.idefaults
		  end
	 RuleAs = if {HasFeature Args rargs} then
		     {Adjoin DefAs.rdefaults Args.rargs}
		  else DefAs.rdefaults
		  end
	 Super = if {HasFeature Args super} then
		    Args.super
		 else DefAs.super
		 end
	 Mixins = if {HasFeature Args mixins} then
		     Args.mixins
		  else DefAs.mixins
		  end
	 As = {Adjoin  {Adjoin DefAs.defaults Args}
	       unit(iargs: ItemAs
		    rargs: RuleAs)}
	 /** %% RhythmTransformers is list of functions. TransformRhythm recursively calls these functions on Rhythm.
	 %% */
	 fun {Transform Transformers MotifSpec}
	    case Transformers of nil then MotifSpec
	    else {Transform Transformers.2 {Transformers.1 MotifSpec As}}
	    end
	 end
	 TrueSpec = {Transform Transformers MotifSpec}
	 TrueAs = {GUtils.recursiveAdjoin As
		   unit(iargs: unit(n: {GetMotifLength TrueSpec}))}
	 proc {TrueBody MyScore Args}
	    thread
	       {Record.forAll {Record.subtract TrueSpec n}
		proc {$ Xs#Accessor}
		   AcessorProc = {GUtils.toProc Accessor}
		in
		   Xs = if {ProcedureArity AcessorProc} == 2 then {AcessorProc MyScore}
			   %% NB: always use only default args specified for method
			else {AcessorProc MyScore unit}
			end
		end}
	    end
	    if Body \= nil then
	       %% NB: Body can be nil, but in that case TrueBody is never called
	       thread {Body MyScore Args} end
	    end
	 end
      in
	 MyScore = {Super TrueAs}
	 {TrueBody MyScore TrueAs}
	 {ForAll Mixins
	  %% threads created already in Mixin (if defined with DefMixinSubscript)
	  proc {$ Mixin} {Mixin MyScore TrueAs} end}
      end
   end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Transformers 
%%%

   /** %% Motif transformer that removes the specified number of items at the end of the motif, reducing all value lists of the motif and n.
   %%
   %% Args.rargs:
   %% unit(removeNotesAtEnd: N) (default 0): number of items to remove.
   %% */
   fun {RemoveNotesAtEnd MotifSpec Args}
      Default = unit(rargs: unit(removeNotesAtEnd: 0)) 
      As = {GUtils.recursiveAdjoin Default Args}
   in
      {TransformMotifLength MotifSpec 
       fun {$ _ Xs}
	  {List.take Xs {Length Xs}-As.rargs.removeNotesAtEnd}
       end
       fun {$ N} N-As.rargs.removeNotesAtEnd end}
   end


   /** %% Motif transformer that removes short notes in MotifSpec. Constraint requires a feature 'durations' in MotifSpec with determined durations.
   %%
   %% Args.rargs:
   %% removeShortNotes (default 0): number of items to remove.
   %%
   %% */
   fun {RemoveShortNotes MotifSpec Args}
      Default = unit(rargs: unit(removeShortNotes: 0)) 
      As = {GUtils.recursiveAdjoin Default Args}
      /** %% Get positions of N smallest values in Xs
      %% */
      %% combine value#pos, sort by value, take first n, take only positions
      fun {GetNSmallest Xs N}
	 {Map {List.take {Sort {List.mapInd Xs fun {$ I X} I#X end}
			  fun {$ _#X1 _#X2} X1 < X2 end}
	       N}
	  fun {$ I#_} I end}
      end
      /** %% Returns Xs variant without the elements at Positions
      %% */
      fun {RemoveAtPosition Xs Positions}
	 {LUtils.accum {List.mapInd Xs
			fun {$ I X}
			   if {Member I Positions}
			   then nil
			   else [X]
			   end
			end}
	  Append}
      end
      PositionsToRemove = {GetNSmallest {GetMotifList MotifSpec durations}
			   As.rargs.removeShortNotes}
   in
      {TransformMotifLength MotifSpec 
       fun {$ _ Xs}
	  {RemoveAtPosition Xs PositionsToRemove}
       end
       fun {$ N} N-As.rargs.removeShortNotes end}
   end


   /** %% Motif transformer that replaces the note at given position by notes of given motif spec. The features of MotifSpec and Args.rargs.substituteNote.motif should match. What varies are typically the lists of the motif features.
   %%
   %% Args.rargs:
   %% substituteNote.motif (default unit): motif spec that is inserted. The format is the same as expected by DefSubscript, only accessors are not required. Example: unit(durations: [2 1]). An "empty" motif (e.g., unit(durations: nil)) results in a removal of the substituted note.
   %%
   %% substituteNote.position (default nil): position of the note to substitute. If position is nil then no note is substituted.
   %%
   %% */
   %%
   %% TODO:
   %% - use this transformer to def further transformers: replace long dur, replace dur by notes of equal dur, ..
   fun {SubstituteNote MotifSpec Args}
      Default = unit(rargs: unit(substituteNote: unit(motif:unit
						      position:nil))) 
      As = {GUtils.recursiveAdjoin Default Args}
      MotifSpec2 = As.rargs.substituteNote.motif
      Pos = As.rargs.substituteNote.position
      /** %% Substitute the Ith value in Xs by Ys.
      %% */
      fun {InsertAtPosition Xs I Ys}
	 Begin End
      in
	 {List.takeDrop Xs I-1 Begin End}
	 {LUtils.accum [Begin Ys End.2] Append}
      end
   in
      if Pos == nil
      then MotifSpec		% don't transform
      else				% transform 
	 if {Arity MotifSpec} \= {Arity MotifSpec2}
	 then {Exception.raiseError
	       strasheela(failedRequirement MotifSpec2
			  "Arity of substituting motif spec unequal the arity of the motif to transform")}
	    unit % never returned
	 else {TransformMotifLength MotifSpec 
	       fun {$ Feat Xs} {InsertAtPosition Xs Pos MotifSpec2.Feat} end
	       fun {$ N} N + {GetMotifLength Pos} end}
	 end
      end
   end


   /** %% Motif transformer that subtracts from the duration of each note in MotifSpec a specific value. Constraint requires a feature 'durations' in MotifSpec.
   %%
   %% Args.rargs:
   %% diminishAdditively (FD int or fenv, default 0): amount subtracted from each duration. If arg is a fenv, then the fenv value at the note position is used (resulting in what Messian calls "inexact diminishing" if the fenv is not a constant function).
   %%
   %% */
   fun {DiminishAdditively MotifSpec Args}
      Default = unit(rargs: unit(diminishAdditively: 0)) 
      As = {GUtils.recursiveAdjoin Default Args}
   in
      {FenvMapMotifList MotifSpec durations As.rargs.diminishAdditively
       proc {$ X Arg Y} Y =: X - Arg end}
   end
   /** %% Motif transformer that adds to the duration of each note in MotifSpec a specific value. Constraint requires a feature 'durations' in MotifSpec.
   %%
   %% Args.rargs:
   %% augmentAdditively (FD int or fenv, default 0): amount added to each duration. If arg is a fenv, then the fenv value at the note position is used (resulting in what Messian calls "inexact diminishing" if the fenv is not a constant function).
   %%
   %% */
   %% diminishing and augmenting defined by separate transformers to avoid negative FD ints
   fun {AugmentAdditively MotifSpec Args}
      Default = unit(rargs: unit(augmentAdditively: 0)) 
      As = {GUtils.recursiveAdjoin Default Args}
   in
      {FenvMapMotifList MotifSpec durations As.rargs.augmentAdditively
       proc {$ X Arg Y} Y =: X + Arg end}
   end

   /** %% Motif transformer that divides the duration of each note in MotifSpec by a specific value. Constraint requires a feature 'durations' in MotifSpec.
   %%
   %% Args.rargs:
   %% diminishMultiplicatively (int or fenv, default 1): amount by which each duration is divided. If arg is a fenv, then the fenv value at the note position is used (resulting in what Messian calls "inexact diminishing" if the fenv is not a constant function).
   %%
   %% */
   fun {DiminishMultiplicatively MotifSpec Args}
      Default = unit(rargs: unit(diminishMultiplicatively: 1)) 
      As = {GUtils.recursiveAdjoin Default Args}
   in
      {FenvMapMotifList MotifSpec durations As.rargs.diminishMultiplicatively
       proc {$ X Arg Y} {FD.divI X Arg Y} end}
   end
   /** %% Motif transformer that multiplies the duration of each note in MotifSpec by a specific value. Constraint requires a feature 'durations' in MotifSpec.
   %%
   %% Args.rargs:
   %% augmentAdditively (FD int or fenv, default 1): amount by which each duration is multiplied. If arg is a fenv, then the fenv value at the note position is used (resulting in what Messian calls "inexact diminishing" if the fenv is not a constant function).
   %%
   %% */
   %% diminishing and augmenting defined by separate transformers to avoid fraction FD ints
   fun {AugmentMultiplicatively MotifSpec Args}
      Default = unit(rargs: unit(augmentMultiplicatively: 1)) 
      As = {GUtils.recursiveAdjoin Default Args}
   in
      {FenvMapMotifList MotifSpec durations As.rargs.augmentMultiplicatively
       proc {$ X Arg Y} Y =: X * Arg end}
   end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Convenience functions for defining transformers 
%%%

   /** %% Convenience function for defining motif spec transformations that affect the number of notes in the motif. MotifSpec is the motif spec expected as first argument of a motif transformer, TransformMotifLength returns the transformed motif spec. TransformLists is a binary and TransformN a unary function. TransformLists is used to transform each value list (e.g., the list of durations): it expects the feature name of a value list and this list and returns the transformed list. TransformN is used for transforming the optional argument n (i.e. unit(iargs(n:N))): it expects and integer and returns the transformed integer. Note that if no arg n was specified in the input MotifSpec, then there will also be no arg n in the output.
   %% */
   fun {TransformMotifLength MotifSpec TransformLists TransformN}
      {Adjoin {Record.mapInd {Record.subtract MotifSpec n}
	       fun {$ Feat Xs#Accessor}
		  {TransformLists Feat Xs}#Accessor
	       end}
       if {HasFeature MotifSpec n}
       then unit(n: {TransformN MotifSpec.n})
       else unit
       end}
   end

   /** %% Convenience function for defining motif spec transformations that transform a single value list (e.g., rotate the sequence of pitches). MotifSpec is the motif spec expected as first argument of a motif transformer, TransformMotifList returns the transformed motif spec. Feat is the feature in MotifSpec that holds the list to transform. Fn defines the transformation; it is a unary function that expects a list and returns the transformed list.
   %% */
   fun {TransformMotifList MotifSpec Feat Fn}
      MotifFeature = MotifSpec.Feat
   in
      {GUtils.recursiveAdjoin MotifSpec 
       unit(Feat: {Fn MotifFeature.1}#MotifFeature.2)}
   end

   /** %% Convenience function for defining motif spec transformations that transform a single value list given a transformation Arg that is either a FD int or a fenv. For example, FenvMapMotifList can be used to add a constant value to all durations of MotifSpec.
   %% MotifSpec is the motif spec expected as first argument of a motif transformer. Feat is the feature in MotifSpec that holds the list to transform. Arg is an FD int or a fenv. P defines the transformation, and is used quasi for mapping over the value list. P is a ternary proc with the interface {$ X Arg2 Y}, where X a value from the value list, Arg2 is either an FD int given with as Arg to FenvMapMotifList or, if Arg is a fenv, Arg2 is the fenv value at the position corresponding to X. Finally, Y is the transformed value. Y is implicitly declared a FD int. See the definition of DiminishAdditively for an example. Note that fenv values are rounded to integers.
   %% */
   fun {FenvMapMotifList MotifSpec Feat Arg P}
      %% only checking for Fenv.isFenv would block..
      if {Not {FD.is Arg}} andthen {Fenv.isFenv Arg}
      then
	 %% Arg is fenv
	 {TransformMotifList MotifSpec Feat
	  fun {$ Xs}
	     {Map {LUtils.matTrans [Xs {Arg toList_Int($ {Length Xs})}]}
	      proc {$ [X Val] Y} 
		 Y = {FD.decl}
		 {P X Val Y}
	      end}
	  end}
      elseif (Arg \=: 0) == 1 then      
	 %% Arg is FD int
	 {TransformMotifList MotifSpec Feat
	  fun {$ Xs}
	     {Map Xs
	      proc {$ X Y}
		 Y = {FD.decl}
		 {P X Arg Y}
	      end}
	  end}
      else MotifSpec		% don't transform
      end
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Utils
%%%

   /** %% [Util] Returns number of notes in motif. 
   %% */
   fun {GetMotifLength MotifSpec}
      %% if explicit n, then use this n; otherwise use length of arbitrary first spec
      {CondSelect MotifSpec n
       {Length {GetMotifList MotifSpec {Arity MotifSpec}.1}}}
   end

   /** %% [Util] Returns the value list at Feat of MotifSpec without the corresponding accessor.
   %% */
   fun {GetMotifList MotifSpec Feat}
      MotifSpec.Feat.1
   end


end
