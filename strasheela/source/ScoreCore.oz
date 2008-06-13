
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

/**
%% The functor defines the core for a music score data structure of Strasheela.
%%
%% Certain classes in the hierarchy are marked as [abstract class]. These classes should not be instantiated. Other classes are marked as [semi abstract class]. These classes are generic data types which may be instantiated. However, the user is encouraged to define more specific subclasses of these. Classes marked as [concrete class] may be freely instantiated, of course the user may define subclasses of them too.
%%
%% Syntactic conventions:
%% If a method returns a value, the return value is the first argument.
%%
%% Simple methods to access class attributes and for type checking are only documented here in a generic way.
%%
%% <code>{New &lt;Class&gt; init(&lt;Arguments&gt;)}</code> is the constructor method for the class Class with certain initial arguments. In practice, New is hardly used and MakeScore is applied instead.
%% <code>{O is&lt;Class&gt;(?B)}</code> is a type checking method. Is the object O an instance of class Class (respectively of a subclass of Class) or not? B is bound to a boolean.
%% <code>{O get&lt;AttributeOrFeature&gt;(X)}</code> is an access method which binds X to the logic variable bound to AttributeOrFeature of object O. Special getter methods are defined for parameters and parameter values. <code>{O get&lt;ParameterName&gt;(X)}</code> returns the parameter value of ParameterName, <code>{O get&lt;ParameterName&gt;Parameter(X)}</code> (i.e. with a 'Parameter' after the actual parameter name) returns the parameter data object itself, and <code>{O get&lt;ParameterName&gt;Unit(X)}</code> returns the parameter data object unit.
%% <code>{O set&lt;AttributeOrFeature&gt;(X)}</code> is a writer method which binds the AttributeOrFeature of object O destructively to a fresh logic variable and initializes it with X.
*/

%% Todo: 
%% 
%% * refactor or remove toPPrintRecord (use toFullRecord only?)
%%
%% * Introducing MakeScore2 and InitScore is not a clean design, only
%% MakeScore should be sufficient. The problem are accessor methods
%% like collect which block if the score hierarchy is not
%% 'closed'. Ergo, I need to somehow redesign the collect method and
%% friends to something concurrent which returns a stream of score
%% objects, not just a list. But whoever non-concurrent calls collect
%% will then block as well...
%%
%% * TimeUnit is a single variable local to the functor (not an attribute for each temporal item -- jsut a waste of memory..)
%%
%%

functor 
import
   System
   FD FS RecordC % Space
   Boot_Object at 'x-oz://boot/Object'
   Boot_Name at 'x-oz://boot/Name'
   Init at 'Init.ozf'
   GUtils at 'GeneralUtils.ozf'
   LUtils at 'ListUtils.ozf'
   MUtils at 'MusicUtils.ozf'
   ScoreMapping at 'ScoreMapping.ozf'
   Out at 'Output.ozf'
   % Pattern at 'Pattern.ozf'
   % Applicator at 'RuleApplicator.ozf'
   Browser(browse:Browse) % temp for debugging
   %Ozcar % temp for debugging
export
   % classes: 
   ScoreObject Parameter TimeParameter TimePoint TimeInterval Amplitude Pitch
   LeaveUninitialisedParameterMixin IsLeaveUninitialisedParameter
   Item Container Modifier Aspect TemporalAspect Sequential Simultaneous 
   Element AbstractElement TemporalElement Pause Event Note2 Note
   % funcs/procs
   IsScoreObject IsTemporalItem IsTemporalContainer
   MakeScore MakeScore2 InitScore
   make: MakeScore
   CopyScore CopyScore2
   MakeContainer MakeSim MakeSeq 
   % ResolveRepeats
   MakeClass
prepare
   /** marker of score object type checking */
   %% Defined in 'prepare' to avoid re-evaluation.
   ScoreObjectType = {Name.new}
   LeaveUninitialisedParameterMixinType = {Name.new}
   
define
   %
   % aux definitions 
   %
   /** %% Default features printed by methods makePPrintRecord resp. toPPrintRecord
   %% */
   DefaultPPrintFeatures = [items parameters value info 'unit']

   /** %% Default features excluded by method toInitRecord
   %% */
%   DefaultInitRecordExcluded = [startTime endTime]
   DefaultInitRecordExcluded = [endTime
				%% HS.score.note args
				getChords isRelatedChord getScales isRelatedScale]
   %
   %  aux mixin classes 
   %
   /**
   %% [abstract class] An auxiliary top level class of the score data type hierarchy to inherit all typ-checking methods to all subclasses.
   %%*/
   class NonType
      meth isScoreObject(?B) B=false end
      meth isParameter(?B) B=false end
      meth isTimeMixin(?B) B=false end
      meth isTimeParameter(?B) B=false end
      meth isTimePoint(?B) B=false end
      meth isTimeInterval(?B) B=false end
      meth isAmplitude(?B) B=false end
      meth isPitch(?B) B=false end
      meth isItem(?B) B=false end
      meth isContainer(?B) B=false end
      meth isModifier(?B) B=false end
      meth isAspect(?B) B=false end
      meth isTemporalAspect(?B) B=false end
      meth isSequential(?B) B=false end
      meth isSimultaneous(?B) B=false end
      meth isElement(?B) B=false end
      meth isAbstractElement(?B) B=false end
      meth isTemporalElement(?B) B=false end
      meth isPause(?B) B=false end
      meth isEvent(?B) B=false end
      meth isNote(?B) B=false end
   end
   
   %
   % The Score Class Hierarchy
   %

   %% [aux for class ScoreObject] a collection of functions to
   %% recursively generate PPrintRecord -- no local def because ozh
   %% can not handle that
   PPrintRecordFns = 
   fns(containers:fun {$ Self Features Excluded}
		     {Map {Self getContainers($)}
		      fun {$ X} 
			 {X toPPrintRecord($ features:Features 
					   excluded:Excluded)} 
		      end} 
		  end
       item:fun {$ Self Features Excluded} 
	       {{Self getItem($)} toPPrintRecord($ features:Features 
						 excluded:Excluded)}
	    end
       items:fun {$ Self Features Excluded}
		{Map {Self getItems($)}
		 fun {$ X} 
		    {X toPPrintRecord($ features:Features 
				      excluded:Excluded)} 
		 end} 
	     end
       parameters:fun {$ Self Features Excluded}
		     {Map {Self getParameters($)}
		      fun {$ X}
			 {X toPPrintRecord($ features:Features 
					   excluded:Excluded)} 
		      end}
		  end)

   
   /** %% [abstract class] Defines reflection capabilities for objects. Please note: this class uses undocumented Oz features, which are possibly not intended for end users ;-) 
   %% */
   class Reflection
      meth getClass($)
	 {Boot_Object.getClass self}
      end

      /** %% Returns the print name of the class of self as specified in its definition. The name is an atom derived from a variable and thus starting with a capital letter, e.g., 'ScoreObject'.
      %% */
      meth getClassName($)
	 {self getClass($)}.{Boot_Name.newUnique 'ooPrintName'}
      end
      
      /** %% Returns a list of all attributes (atoms) defined for self. 
      %% */
      meth getAttrNames($)
	 {Arity {self getClass($)}.{Boot_Name.newUnique 'ooAttr'}}
      end
%       /** %% Alias for getAttrNames.
%       %% */
%       meth getAttributes($) {self getAttrNames($)} end
      /** %% Returns a record where the features are the attributes defined for self and the values are the classes which define these attributes. 
      %% */
      meth getAttrSources($)
	 {Dictionary.toRecord {self getClassName($)}
	  {self getClass($)}.{Boot_Name.newUnique 'ooAttrSrc'}}
      end
      /** %% Returns a list of all features (atoms) defined for self. 
      %% */
      meth getFeatNames($)
	 {Arity {self getClass($)}.{Boot_Name.newUnique 'ooFeat'}}
      end      
      /** %% Alias for getFeatNames.
      %% */
      meth getFeatures($) {self getFeatNames($)} end
      /** %% Returns a record where the features are the features defined for self and the values are the classes which define these features. 
      %% */
      meth getFeatSources($)
	 {Dictionary.toRecord {self getClassName($)}
	  {self getClass($)}.{Boot_Name.newUnique 'ooFeatSrc'}}
      end
      /** %% Returns a list of all methods (atoms) defined for self. 
      %% */
      meth getMethNames($)
	 {Dictionary.keys {self getClass($)}.{Boot_Name.newUnique 'ooMeth'}}
      end
%       /** %% Alias for getMethNames.
%       %% */
%       meth getMethods($) {self getMethNames($)} end
      /* %% [TODO] Get the default arguments of the initialisation method... 
      %% */
%      meth getInitArgs($) 
%      end
      /* %% Returns a record where the features are all supported arguments of the init method of self with their default as value (_ indicates that no default exist).
      %% NB: this method relies on the correct implementation of the method getInitArgs for its class and all its superclasses. 
      %% */
      meth getInitArgDefaults($)
	 Excluded = nil
	 fun {TransformArgs Args}
	    {Map Args fun {$ Arg#_#Init}
			 if Init==noMatch
			 then Arg#_
			 else Arg#Init
			 end
		      end}
	 end
	 fun {AppendArgs unit(superclass:Super args:Args)}
	    if Super == nil
	    then {TransformArgs Args}
	    else
	       {Append
		{AppendArgs (Super, getInitInfo($ exclude:Excluded))}
		{TransformArgs Args}}
	    end
	 end
      in
	 {List.toRecord {self getClassName($)}
	  {AppendArgs {self getInitInfo($ exclude:Excluded)}}}
      end
      
      /* %% Returns a record where the features are all supported arguments of the init method of self and the values are the classes which define these init arguments.
      %% NB: this method relies on the correct implementation of the method getInitArgs for its class and all its superclasses. 
      %% */
      meth getInitArgSources($)
	 Excluded = nil
	 fun {TransformArgs Class Args}
	    {Map Args fun {$ Arg#_#_}
			 Arg#Class
		      end}
	 end
	 fun {AppendArgs Class unit(superclass:Super args:Args)}
	    if Super == nil
	    then {TransformArgs Class Args}
	    else
	       {Append
		{AppendArgs Super (Super, getInitInfo($ exclude:Excluded))}
		{TransformArgs Class Args}}
	    end
	 end
      in
	 {List.toRecord {self getClassName($)}
	  {AppendArgs {self getClass($)} {self getInitInfo($ exclude:Excluded)}}}
      end
      /** %% Returns a record where the features are the methods defined for self and the values are the classes which define these methods. 
      %% */
      meth getMethSources($)
	 {Dictionary.toRecord {self getClassName($)}
	  {self getClass($)}.{Boot_Name.newUnique 'ooMethSrc'}}
      end
      
      /** %% Returns the value at attribute A.
      %% */
      meth getAttr($ A) @A end
      /** %% Returns the value at feature F.
      %% */ 
      meth getFeat($ F) self.F end
      
   end
   
   /** %% [abstract class] The most general data type for score data is a ScoreObject.
   %%
   %% The feature label binds an atom naming the class. The attribute info can be used for arbitrary user information.
   %% */
   class ScoreObject from NonType Reflection
      feat 
	 !ScoreObjectType: unit 
	 %'class': ScoreObject
	 label: scoreObject
      attr id info
	 /** %% The argument handle is bound to the score object itself (cf. the handle in QTk). The argument info is either a list of infos or a single info (arbitrary value, usually is each info an atom)
	 %% */
      meth init(handle:?H<=_ info:Info<=nil id:ID<=_ ...) = M
	 %{self initFlags}
	 H = self
	 @info = if {IsList Info}
		 then Info
		 else Info|nil
		 end
	 @id = ID
	 
	 %% hands arbitrary init arguments to instance attributes
	 {Record.forAllInd {Record.subtractList M [info handle id]}
	  proc {$ Attr X}
	     %% Note: GUI causes space hierarchy from within local space
	     % {GUtils.warnGUI "Setting "#{Value.toVirtualString self 100 100}#"'s attribute '"#Attr#"' directly to "#{Value.toVirtualString X 100 100}#". Possibly, this attribute does not exist in this object!"}
	     {System.showInfo "Warning: setting "#{Value.toVirtualString self 100 100}#"'s attribute "#Attr#" directly to "#{Value.toVirtualString X 100 100}#". Possibly, this attribute does not exist in this object!"}
	     @Attr = X
	  end}
	 
      end
      meth isScoreObject(?B) B=true end
      meth getID(?X) X=@id end
      meth getInfo(?X) X=@info end
%      meth getAttributes(?X)
%	 X = [id info]
%      end
%      meth getFeatures(?X)
%	 X = [label]
%      end
      /** %% [destructive method] Statefully sets attribute A to value X. The method is indented for editing a score after search, the search itself is indented to be fully stateless.
      %% */
      meth setAttribute(A X)
	 A <- X
      end
      /** %% [destructive method] Adds X to list in attribute info. The tail of the list at attribute info is the info specified at the init method which defaults to nil.
      %% */
      meth addInfo(X)
	 info <- X | @info
      end  
      /** %% Returns boolean whether the list at the attr info of self contains Info. In case some info value is a record, then it is checked whether its label is Info.
      %% */
      meth hasThisInfo(?B Info)
	 B = ({List.some {self getInfo($)}
	       fun {$ X}
		  if {IsRecord X}
		  then {Label X} == Info
		  else X == Info
		  end
	       end})
      end
      /** %% Returns first record with label L in the list in attribute info.
      %% */
      meth getInfoRecord($ L)
	 {LUtils.find {self getInfo($)}
	  fun {$ X} {IsRecord X} andthen {Label X} == L end}
      end

      
      /** %% [aux method for toPPrintRecord] Returns a record with the label of self (the value at the feature label of self) and the values of selected features/attributes of self at record labels. All atoms in the list Features which are member in the list Slots are features of the returned record. 
      %% Usually, the record feature is just bound to the value at the features/attributes of self. However, for certain features/attributes there are special access functions defined. The return value of these functions will be bound to the record features. These features and their functions are either given in a record to the optional method feature functions. Other features and their functions are predefined in the variable PPrintRecordFns.
      %% */
      meth makePPrintRecord(?X Features Slots Excluded 
			    functions:Fns<=PPrintRecordFns)
	 if {Some Excluded fun {$ Test} {{GUtils.toFun Test} self} end}
	    %% no simple and consistent solution to totally remove Excluded
	    %% unwanted feature gets bound to name -- this feature is later removed
	    %% unwanted object from list is bound to nil and removed by Append
	 then X=beep		% !! quick hack -- better totally skip X
	 else X={MakeRecord self.label
		 {LUtils.mappend Features 
		  fun {$ Feature} 
		     if {Member Feature Slots}
		     then [Feature]
		     else nil
		     end
		  end}}
	    %% bind features in X
	    {Record.forAllInd X 
	     proc {$ Feature X}  
		X= if {HasFeature Fns Feature}
		   then {Fns.Feature self Features Excluded}
		   elseif {HasFeature self Feature}
		   then self.Feature
		   else @Feature
		   end		
	     end}
	 end
      end
      /** %% Method returns a record with essential data of self. The method is intended to view self uncluttered. The method feature <code>features</code> allows to freely select a list of score object features/attributes to include. 
      %% */
      %% @1=?X
      %% additional feature/argument
      % excluded -- a list boolean functions or methods: all objects fulfilled one of it are not included in PPrintRecord
      %% !! TODO: toPPrintRecord uses getAttrNames (was: getAttributes...)
      meth toPPrintRecord(?X features:Features<=DefaultPPrintFeatures
			  excluded:Excluded<=nil)
	 {self makePPrintRecord(X Features [info] Excluded)}
      end

      /** %% [aux method for toInitRecord]: returns a record intended to facilitate the init method creation of an object for archive purposes. Attrs has the form [Key1#Accessor1#Default1 ...], keys are the record features of the init record, accessors the respective accessor for some object attributes (unary function or method), defaults are the respective attribute default values (the special default value noMatch matches nothing). 
      */
      %% !!?? should this method (and everything related) move into Item?
      %% !!?? should this method be turned into a local proc: it should only be called by toInitRecord...
      meth makeInitRecord(?X Attrs)
	 /** %% Returns true if Val equals default (or default is NOT noMatch) and false otherwise. If true, the output is skipped. Default must not be _.
	 %% */ 
	 fun {ValueIsSkipped Val Default}
	    if {IsFree Val} %% free variables are skipped
	    then true
	       %% Default should never be free, but making it free is like noMatch...
	    elseif {IsFree Default}
	    then false
	    elseif {IsDet Val}
	    then {IsDet Default} andthen Val==Default
	    elseif {FD.is Val} 
	    then {FD.is Default} andthen 
	       {FD.reflect.dom Val} == {FD.reflect.dom Default}
	    elseif {GUtils.isFS Val}
	    then {GUtils.isFS Default} andthen
	       {FS.reflect.lowerBound Val} == {FS.reflect.lowerBound Default} andthen
	       {FS.reflect.upperBound Val} == {FS.reflect.upperBound Default}
	    elseif Default==noMatch
	    then false
%   else false
	    end
	 end
% 	 fun {Domain2VS X}
% 	    if {IsList X}
% 	    then "["#{Out.listToVS {Map X Domain2VS} ' '}#"]"
% 	    else case X of A#B
% 		 then A#"#"#B
% 		 else X
% 		 end
% 	    end
% 	 end
% 	 fun {Transform Val}
% 	    %% free vars are skipped (must be tested explicitly here again to avoid blocking)
% 	    if {IsFree Val}
% 	    then nil
% % 	    elseif {IsKinded Val} then Val
% % %	    %% ints must be processed before FD ints
% % %	    if {IsDet Val} andthen {IsInt Val} 
% % %	    then Val
% % %	    elseif {FD.is Val}
% % %	    then {VirtualString.toString
% % %		  '{FD.int '#{Domain2VS {FD.reflect.dom Val}}#'}'}
% % %	    elseif {GUtils.isFS Val} % {FS.var.is Val}
% % %	    then {VirtualString.toString
% % %		  '{FS.var.bounds '
% % %		  #{Domain2VS {FS.reflect.lowerBound Val}}#' '
% % %		  #{Domain2VS {FS.reflect.upperBound Val}}#'}'}
% % 	       %% VS are transformed into strings to avoid problems
% % 	       %% with List.toRecord below
% % 	    elseif {IsVirtualString Val}
% % 	    then {VirtualString.toString Val}
% % 	       %% Lists and records are processed recursively 
% % 	       %% BTW: containers process their contained items explicitly in Container, toInitRecord
% % 	    elseif {IsList Val}
% % 	    then  {VirtualString.toString
% % 		   '['#{Out.listToVS {Map Val Transform} ' '}#']'}
% % 	       %% I skip record->VS: this (as the list transformation) is only conmetically, e.g., to avoid textual representation of strings as lists of integers (which is semantically the same) 
% % 	    elseif {IsRecord Val}
% % 	    then {VirtualString.toString
% % 		  {Out.recordToVS {Record.map Val Transform}}}
% % 	       %%
% % %	       %% all other values are simply returned with their textual representation
% % %	       %% !! as this can also be, e.g., procs or classes, the resulting textual representation can not always be evaluated 'as is'
% % %	    else {Value.toVirtualString Val 10 1000}
%  	    else Val
% 	    end
% 	 end
	 Ts = {LUtils.mappend Attrs
	       fun {$ Key#Accessor#Default}
		  Val = {{GUtils.toFun Accessor} self}
% 		  Transformed = if {ValueIsSkipped Val Default}
% 				   %% i.e. value is default and thus entry is skipped
% 				then nil
% 				else {Transform Val}
% 				end
 	       in
%		  if Transformed==nil
		  if {ValueIsSkipped Val Default}
		  then nil
%		  else [Key#Transformed]
		  else [Key#Val]
		  end
	       end}
      in
	 X = {List.toRecord self.label Ts}
      end

      /* % test cases
      
      %% 
      {ValueIsSkipped {FD.decl} noMatch}
% false

      %% 
      {ValueIsSkipped {FD.int 1#30} {FD.int 1#30}}
% true

      %% 
      {ValueIsSkipped {FD.int 10#15} {FD.int 1#30}}
% false 

      %% ... impossible situation...
      {ValueIsSkipped {FD.int 10#15} 50}
% false

      %% 
      {ValueIsSkipped 50 {FD.int 10#15}}
% false 

      %%  
      {ValueIsSkipped 50 50}
% true

      %%  
      {ValueIsSkipped 10 50}
% false


      {ValueIsSkipped _ 50}
% false

      %% !! blocks..
      {ValueIsSkipped 50 _}
% false

      %% !! blocks..
      {ValueIsSkipped _ _}
% false

      */

      /** %% Outputs the full init record for self which allows to re-create the score.
      %% Excluded is a list of arguments (atoms) which must be excluded concurrently.
      %%
      %% NB: toInitRecord depends on correct definitions of the method getInitInfo for all subclasses with specific inialisiation arguments.
      %%
      %% NB: toInitRecord presently only works properly for tree-form score topologys (e.g. score graphs are not supported yet).
      %% **/
      %% !!?? should this method (and everything related) move into Item?
      meth toInitRecord($ exclude:Excluded<=DefaultInitRecordExcluded)
	 fun {Aux unit(superclass:Super args:Args)}
	    if Super == nil
	    then {Record.subtractList {self makeInitRecord($ Args)}
		  Excluded}
	    else
	       {Adjoin
		{Aux (Super, getInitInfo($ exclude:Excluded))}
		{Record.subtractList {self makeInitRecord($ Args)}
		 Excluded}}
	    end
	 end
      in
	 {Aux {self getInitInfo($ exclude:Excluded)}}
      end

%      meth toInitRecord(?X exclude:Excluded<=DefaultInitRecordExcluded)
% 	 %X=self.label
% 	 X = {Record.subtractList
% 	      {self makeInitRecord($ [info#fun {$ X}
% 					      %% @info binds a list so it can contain multiple information. Nevertheless, a single info is given to the init method without surrounding list..
% 					      Aux = {X getInfo($)}
% 					   in
% 					      if {IsList Aux} andthen {Length Aux} == 1
% 					      then Aux.1
% 					      else Aux
% 					      end
% 					   end
% 				      #noMatch
% 				      id#getID#noMatch])}
% 	      Excluded}
%       end

      /** %% Returns information required to reconstruct the init method. Every newly defined ScoreObject subclass which introduces new init arguments should define its own getInitInfo. This documentation therefore explains also implementational details for this method.
      %%
      %% The returned information hase the following form:
      
      unit(superclass:Super
	   args:[Argument1#Accessor1#Default1
		 ...
		 ArgumentN#AccessorN#DefaultN])
      
      %% Super is a single superclass of self which defines/inherits a method getInitInfo extending the present method definition (can be nil in case of no superclass). Argument is an init method argument (an atom), Accessor is a unary accessor function or method returning the value of the object corresponding with Argument, and Default is the default value or 'noMatch' if no default value was given. Excluded is the same arg as for toInitRecord: this argument is only required if getInitInfo recuresively calls toInitRecord. A typical getInitInfo definition follows
      %%

      meth getInitInfo($ exclude:Excluded)
	 unit(superclass:MySuperClass
	      args:[myParameter#getMyParameter#noMatch])
      end
      
      %% */
      %% !!?? should this method (and everything related) move into Item?
      meth getInitInfo($ exclude:Excluded)
	 unit(superclass:nil
	      args:[info#fun {$ X}
			    %% @info binds a list so it can contain multiple information. Nevertheless, a single info is given to the init method without surrounding list..
			    Aux = {X getInfo($)}
			 in
			    if {IsList Aux} andthen {Length Aux} == 1
			    then Aux.1
			    else Aux
			    end
			 end#nil
		    id#getID#noMatch])
      end

      /** %% Collects all classes of the objects in self in the format expected by the second argument of Score.makeScore, i.e., a record of the form unit(label1:Class1 ... labelN:ClassN)
      %% */
      %% !!?? should this method (and everything related) move into Item?
      meth getInitClasses(?Classes)
	 Items = self | {self collect($ test:isItem)}
      in
	 Classes = unit(...)
	 {ForAll Items
	  proc {$ MyItem}
	     Classes ^ (MyItem.label) = {MyItem getClass($)}
	  end}
	 %% close record
	 {RecordC.width Classes} = {Length {RecordC.reflectArity Classes}}
      end

      
      /** %% Like getInitClasses, getInitClassesVS collects all classes of the objects in self in the format expected by the second argument of Score.makeScore. However, the result record is returned as a VS (e.g., for outputting into Oz source text files). The Strasheela classes are specified by accessing them in Strasheela functors (e.g., Strasheeala.score.note). The toplevel Strasheela functors are taken from {Init.getStrasheelaEnv strasheelaFunctors}.
      %% NB: getInitClassesVS examines every class in these functors (and their subfunctors) and requires that whenever a class defines an init method, all init method arguments must be optional.
      %% */
      %% !!?? should this method (and everything related) move into Item?
      meth getInitClassesVS($)
	 /** %% [Aux] Returns true if MyClass defines the method init and false otherwise.
	 %% */
	 fun {DefinesInitMethod MyClass}
	    {Dictionary.member MyClass.{Boot_Name.newUnique 'ooMeth'}
	     init}
	 end
	 /** %% Returns a list of all Strasheela score classes as a list of pairs of the form [Class1#Spec1 ... ClassN#SpecN]. Each spec is a VS expressing the accessor to the class in its functor, where the functor names are the ones usually used in Strasheela (e.g., "Strasheela.score.note"). Functors expects a list of pairs with Strasheela functors together with the print representation of Oz variables which bind these functors (e.g., [Strasheela#"Strasheela"]).
	 %% */
	 fun {GetClassSpecsFromFunctors Functors}
	    fun {Aux MyFunctor InitPath}
	       {Map {Record.toListInd
		     %% filter out item score object classes and functors (records)
		     {Record.filter MyFunctor
		      fun {$ Val}
			 ({IsClass Val} andthen {DefinesInitMethod Val} andthen
			  local X = {New Val init}
			  in {IsScoreObject X} andthen
			     {X isItem($)}
			  end)
			 orelse {IsRecord Val}
		      end}}
		fun {$ Feat#Val}
		   if {IsRecord Val}
		   then {Aux Val InitPath#Feat#"."}
		   else
		      %% Val is item class
		      Val#{VirtualString.toString InitPath#Feat}
		   end
		end}
	    end
	 in
	    {Flatten {Map {Record.toListInd Functors}
		      fun {$ InitPath#MyFunctor} {Aux MyFunctor InitPath#"."} end}}
	 end
	 Classes = {self getInitClasses($)}
	 Specs = {GetClassSpecsFromFunctors {Init.getStrasheelaEnv strasheelaFunctors}}
      in
	 {Out.recordToVS
	  {Record.map Classes
	   fun {$ MyClass}
	      %% take 'path spec' from matching class
	      MySpec = {LUtils.find Specs fun {$ TheClass#_} TheClass == MyClass end}
	   in
	      if MySpec==nil
	      then
		 {Exception.raiseError
		  strasheela(initError "The functors set in the Strasheela environment variable strasheelaFunctors do not define the class "#{Value.toVirtualString MyClass 1 1})}
		 unit		% never returned
	      else MySpec.2
	      end
	   end}}
      end
      
      
      /** %% Outputs the whole score object tree as a record with the the object label as record label and with all the object attributes and object features as record features. All attributes/features containing score objects themself are called recursively, dictionaries and extendable lists (see LUtils) are transformed to records resp. lists.
      %% The argument exclude allows to recursively exclude object attributes in the output.
      %% !! Temp: The attributes 'item' and 'containers' are always excluded to avoid endless loops. Therefore, score graphs with items having more then a single container can not be shown.
      %% */
      meth toFullRecord(?X exclude:Exclude<=nil)
	 fun {GetProperVal Val}
	    if {Not {IsDet Val}}
	    then Val
	    elseif {IsScoreObject Val}
	    then {Val toFullRecord($ exclude:Exclude)}
	    elseif {LUtils.isExtendableList Val}
	    then {Map Val.list fun {$ X}
				  {X toFullRecord($ exclude:Exclude)}
			       end}
	    elseif {IsDictionary Val}
	    then {Dictionary.toRecord dict Val}
	    else Val
	    end
	 end
	 %% exclude attributes causes endless loops
	 AlwaysExcludeAttrs = [item containers]
	 AlwaysExcludeFeats = [label]
	 Attrs = {Record.subtractList {Record.make self.label {self getAttrNames($)}}
		  {Append AlwaysExcludeAttrs Exclude}}
	 Feats = {Record.subtractList {Record.make self.label {self getFeatNames($)}}
		  {Append AlwaysExcludeFeats Exclude}}
% 	 Attrs = {Record.subtractList {Record.make self.label {self getAttributes($)}}
% 		  {Append AlwaysExcludeAttrs Exclude}}
% 	 Feats = {Record.subtractList {Record.make self.label {self getFeatures($)}}
% 		  {Append AlwaysExcludeFeats Exclude}}
      in
	 X = {Adjoin
	      {Record.mapInd Attrs
	       fun {$ I A} {GetProperVal @I} end}
	      {Record.mapInd Feats
	       fun {$ I A} {GetProperVal self.I} end}}
      end
%       %% Outputs the object as a record with the the object lable as record label  and with all its attributes as record features. 
%       
%       meth toFullRecord(?X exclude:Exclude<=nil)
% 	 X = {self toFullRecordAux($ exclude:Exclude)}
%       end

      /** %% Effectively unifies self and ScoreObject. Stateful data (including class instances) can not be unified in Oz. So, unify transforms self and ScoreObject to records (using toFullRecord) and unifies those.
      %% !! Temp: NB: toFullRecord (and thus unify) only works properly on score trees (see doc of toFullRecord). Besides, the score topology of both objects must be determined and equal. 
      %% */ 
      meth unify(ScoreObject)
	 % the flags attribute is only for internal use and is bound to some stateful data structure..
	 {self toFullRecord($ exclude:[flags])} = {ScoreObject toFullRecord($ exclude:[flags])} 
      end

      %% removed method: operator == does work for objects, it returns true for identical objects. The method '==' instead tested not identity but equality based on parameter etc. values, but this definition is too unsure and hasn't been really needed so far...
%       %% Effectively tests whether self and ScoreObject are equal. The operator == returns always false when comparing stateful data (including class instances). So, '==' transforms self and ScoreObject to records (using toFullRecord) and unifies those.
%       %% !! Temp: NB: toFullRecord (and thus '==') only works properly on score trees (see doc of toFullRecord).Besides, the score topology of both objects must be determined and equal. 
%       %%        
%       meth '=='(?B ScoreObject)
% 	 % the flags attribute is only for internal use and is bound to some stateful data structure..
% 	 B = {self toFullRecord($ exclude:[flags])} == {ScoreObject toFullRecord($ exclude:[flags])} 
%       end
      
   end			% class
      
   %%
   %% [Aux defs for class TimeMixin] -- no local def because ozh
   %% can not handle that (??)
   %%
%    fun {IsTemporalAspect X} 
%       {IsScoreObject X} andthen
%       {X isTemporalAspect($)} 
%    end
   proc {ConstrainDuration X}
      %% !! own thread needed ?
      %%
      %% ?? I don't differ between (CM terms) duration and rhythm
      %% duration is duration in CM, rhythm is CM is here
      %% e.g. duration + offset time of successor (in thread) etc.
      {X getDuration($)} =: {X getEndTime($)} - {X getStartTime($)} 
   end
   %% Unify all timing units
%    proc {ConstrainTimingUnits X}
%       %% !! own thread needed ?
%       %% temporal (?) simplification: all timing units are equal
%       %%
%       %% (all timing parameters of a single score object are already
%       %% unified by a single init arg for timeUnit)
%       Container = {LUtils.find {X getContainers($)} IsTemporalAspect}
%    in
%       %% !! recall of IsTemporalAspect -- just test whether nil ??
%       %% if {IsTemporalAspect Container} 	% i.e. not nil
%       if Container \= nil
% %      then {Container getStartTimeUnit($)} = {X getStartTimeUnit($)}
%       then
% 	 {Browse constrainTimingUnits#Container#X}
% 	 {Container getTimeUnit($)} = {X getTimeUnit($)}
%       end
%       %% this is already implicit in initTiming:
% %      {X getDurationUnit($)} = {X getEndTimeUnit($)} = 
% %      {X getStartTimeUnit($)} = {X getOffsetTimeUnit($)}
%    end
   
   /** %% [abstract class] The TimeMixin adds several timing attributes and methods to its subclasses.
   %%
   %% The attributes startTime and endTime are absolute TimePoints. The attribute offsetTime is a relative TimeInterval to the startTime of the TemporalAspect an Item is contained in. The attribute duration is the TimeInterval difference of startTime and endTime.
   %%
   %% The TimeUnit specifies what the numeric values for the TimeMixin attributes actually mean. The TimeUnit either specifies an absolute value (e.g. seconds) or a relative value (e.g. beats). The meaning of beat depends on the output definition, for instance, for the Lilypond output a beat is a quarter note. Currently, possible values are 'seconds' (or 'secs'), 'milliseconds' (or 'msecs'), 'beats', or beats(N), where  N means number of ticks (i.e. the integer range) within a beat. For example, if the TimeUnit = beats(4) and a beat corresponds to a quarter note, then a note of duration 1 corresponds to a sixteenth note. beats is equivalent with beats(1). The meaning of a beat for sound output can be specified by the tempo (see Init.setBeatDuration, Init.setTempo etc.)
   %% NB: to avoid confusion, the time units of all temporal items in the score are unified when a Strasheela score is initialised.   
   %% NB: A negative offsetTime value is not possible if the offsetTime is a FD integer (which presently is the only option). For the other temporal parameters, a negative value does not make sense anyway.
   %% */
   class TimeMixin
      feat 
	 %'class': TimeMixin
	 label: timeMixin
      attr startTime endTime offsetTime duration
	 /** %%[aux method] Method must not be called by user.
	 %%*/
      meth initTiming(startTime:StartTime<=_ endTime:EndTime<=_ 
		      offsetTime:OffsetTime<=_ duration:Duration<=_
		      timeUnit:TimeUnit<=_)
	 @startTime = {New TimePoint
		       init(info: startTime value:StartTime 'unit':TimeUnit)}
	 @endTime = {New TimePoint
		     init(info: endTime value:EndTime 'unit':TimeUnit)}
	 @duration = {New TimeInterval
		      init(info: duration value:Duration 'unit':TimeUnit)}
	 @offsetTime = {New TimeInterval
			init(info: offsetTime value:OffsetTime 'unit':TimeUnit)}
	 %%
	 {self bilinkParameters([@startTime @endTime @duration @offsetTime])}
	 %
	 %{self getStartTime(StartTime)}
	 %{self getEndTime(EndTime)}
	 %{self getOffsetTime(OffsetTime)}
	 %{self getDuration(Duration)}
      end
      /** %% After full creation of score hierarchy, method must be called with every TimeMixin subclass instance in score to init the timing attributes/features 
      %%*/
      %%
      %% !! ?? I should define this method (and the constrainTiming in
      %% sim and seq...) as a function (testing for type) to make it
      %% unaccessible form outside.
      meth constrainTiming
	 {ConstrainDuration self}
	 %{ConstrainTimingUnits self}
      end
      meth getStartTime(?X) X={@startTime getValue($)} end
      meth getEndTime(?X) X={@endTime getValue($)} end
      meth getDuration(?X) X={@duration getValue($)} end
      meth getOffsetTime(?X) X={@offsetTime getValue($)} end
      meth getStartTimeInSeconds(?X) X={@startTime getValueInSeconds($)} end
      meth getEndTimeInSeconds(?X) X={@endTime getValueInSeconds($)} end
      meth getDurationInSeconds(?X) X={@duration getValueInSeconds($)} end
      meth getOffsetTimeInSeconds(?X) X={@offsetTime getValueInSeconds($)} end
      meth getStartTimeInBeats(?X) X={@startTime getValueInBeats($)} end
      meth getEndTimeInBeats(?X) X={@endTime getValueInBeats($)} end
      meth getDurationInBeats(?X) X={@duration getValueInBeats($)} end
      meth getOffsetTimeInBeats(?X) X={@offsetTime getValueInBeats($)} end
      meth getStartTimeParameter(?X) X=@startTime end
      meth getEndTimeParameter(?X) X=@endTime end
      meth getDurationParameter(?X) X=@duration end
      meth getOffsetTimeParameter(?X) X=@offsetTime end
      %% time param units are unified
      meth getTimeUnit(?X) X={@startTime getUnit($)} end
      /** %% Returns true if the timeUnit is either seconds or milliseconds, and false otherwise. 
      %% */
      meth hasAbsoluteTimeUnit(?B)
	 B = case {self getTimeUnit($)}
	     of seconds then true
	     [] secs then true
	     [] milliseconds then true
	     [] msecs then true
	     else false
	     end
      end
      %% !! change: remove these methods: always replace with getTimeUnit
      %meth getStartTimeUnit(?X) X={@startTime getUnit($)} end
      %meth getEndTimeUnit(?X) X={@endTime getUnit($)} end
      %meth getDurationUnit(?X) X={@duration getUnit($)} end
      %meth getOffsetTimeUnit(?X) X={@offsetTime getUnit($)} end
      /** %% [Deterministic method] Returns boolean whether self and X are simultaneous in time. 
      %%*/  
      %% @1=?B
      meth isSimultaneousItem(?B X)
	 Start1 = {self getStartTime($)} 
	 Start2 = {X getStartTime($)}
	 End1 = {self getEndTime($)} 
	 End2 = {X getEndTime($)}
      in
% 	 B = ((Start1 =< Start2 andthen End1 > Start2) 
% 	      orelse 
% 	      (Start2 =< Start1 andthen End2 > Start1))
	 B = (Start1 < End2) andthen (Start2 < End1)
      end			
      /** % [0/1 Constraint] Returns 0/1-integer whether self and X are simultaneous in time (i.e. somehow overlap in time).
      %% */
      %% @1=?B
      meth isSimultaneousItemR(?B X)	% ?? method name
	 Start1 = {self getStartTime($)} 
	 Start2 = {X getStartTime($)}
	 End1 = {self getEndTime($)} 
	 End2 = {X getEndTime($)}
	    %B :: 0#1
      in
% 	 B = {FD.exor
% 	      {FD.conj (Start1 =<: Start2) (End1 >: Start2)}
% 	      {FD.conj (Start2 =<: Start1) (End2 >: Start1)}}
	 {FD.conj (Start1 <: End2) (Start2 <: End1) B}
      end			
      /** % [0/1 Constraint] Returns 0/1-integer whether self and X are exactly simultaneous in time (i.e. start and end at the same time).
      %% */
      %% @1=?B
      meth isExactlySimultaneousItemR(?B X)
	 Start1 = {self getStartTime($)} 
	 Start2 = {X getStartTime($)}
	 End1 = {self getEndTime($)} 
	 End2 = {X getEndTime($)}
      in
	 {FD.conj (Start1 =: Start2) (End1 =: End2) B}
      end
      /** % [Deterministic method] Returns list of score objects simultaneous to self and fulfilling the optional boolean function or method test.
      %% The implementation uses LUtils.cFilter and the reified constraints method isSimultaneousItemR. Items are returned as soon as the score contains enough information for all score objects in the score to tell whether or not their are simultaneous to self (i.e. rhythmic structure of the whole score must not necessarily be fully determined). 
      %%*/
      %% @1=?Xs	
      meth getSimultaneousItems(?Xs test:Test<=fun {$ X} true end)
	 thread 		% ?? NOTE: thread needed?
	    TopLevel = {self getTopLevels($ test:fun {$ X} {X isTimeMixin($)} end)}.1
	    ScoreObjects = {TopLevel collect($ test:Test)}
	 in
	    Xs = {LUtils.cFilter ScoreObjects
		  fun {$ X}
		     X \= self andthen
		     {X isItem($)} andthen
		     ({self isSimultaneousItemR($ X)} == 1)
		  end}
% 	    Xs = {TopLevel filter($ fun {$ X} 
% 				       X \= self andthen
% 				       {X isItem($)} andthen
% 				       {X isSimultaneousItem($ self)} andthen
% 				       {{GUtils.toFun Test} X}
% 				    end)}
	 end
      end

      /** %% [Deterministic method] Returns the first score object found which is simultaneous to self and fulfilling the optional boolean function or method test.
      %% The implementation uses LUtils.cFind and the reified constraints method isSimultaneousItemR. X is return as soon as the score contains enough information to tell for any score object that it is simultaneous to self (i.e. rhythmic structure of the whole score must not necessarily be fully determined). 
      %% */
      meth findSimultaneousItem(?X test:Test<=fun {$ X} true end)
	 thread 		% ?? NOTE: thread needed?
	    TopLevel = {self getTopLevels($ test:fun {$ X} {X isTimeMixin($)} end)}.1
	    ScoreObjects = {TopLevel collect($ test:Test)}
	 in
	    X = {LUtils.cFind ScoreObjects
		  fun {$ X}
		     X \= self andthen
		     {X isItem($)} andthen
		     ({self isSimultaneousItemR($ X)} == 1)
		  end}
	 end
      end

      
   end			% class
   
      
   /** %% [semi abstract class] Musical parameters are the basic magnitudes in a music representation; examples are the parameters duration, amplitude and pitch, which add information to a note. A parameter is represented by an own class (i.e. not just as a feature/attribute of a score item, as in most other composition environments) to allow the expression of additional information on the parameter besides the actual parameter value. For instance, a single numeric value for a pitch is ambitious, it could express a frequency, a MIDI-keynumber, MIDI-cents, a scale degree etc. Therefore, a parameter allows to specify the unit of measurement explicitly.
   %% The parameter attributes value and 'unit' specify the parameter setting and the unit of measurement. The attribute item points to the score item the parameter belongs to.
   %% PS: The attribute 'unit' is mainly used for output.
   %%*/
   %% Was doc: Because of limitations of the FD constraints in Oz, the parameter value is limited to integer values (planned: fractions). However, these values can be mapped to arbitrary other data (e.g. midicent integer to frequency float).
   class Parameter from ScoreObject
      feat %'class': Parameter
	 label: parameter
      attr item value 'unit'
      meth init(value:Value<=_ 'unit':Unit<=_ ...)=M
	 ScoreObject, {Record.subtractList M [value 'unit']}
	 @'unit' = Unit
	 @value = Value
      end
      meth isParameter(?B) B=true end
      meth getItem(?X) X=@item end
      meth getValue(?X) X=@value end
      meth getUnit(?X) X=@'unit' end
%      meth getAttributes(?X)
%	 X = {Append
%	      [item value 'unit']
%	      ScoreObject, getAttributes($)}
%      end
      /** % Bind the parameter value to a FD variable */
      meth initFD(Spec<=0#FD.sup)
	 if {IsFree @value} andthen {Not {IsLeaveUninitialisedParameter self}}
	 then @value :: Spec
	 end
      end
      /** % Bind the parameter value to a FS variable */
      meth initFS(Spec<=0#FS.sup)
	 if {IsFree @value}
	 then @value = {FS.var.upperBound Spec}
	 end
      end
%       /** % Is the parameter value determined?
%       % */
%       meth isValDet(?B) B={IsDet @value} end
      /** %% Method returns a record with essential data of self. The method is intended to view self uncluttered. The method feature <code>features</code> allows to freely select a list of score object features/attributes to include. 
      %% */
      %% @1=?X
      meth toPPrintRecord(?X features:Features<=DefaultPPrintFeatures
			  excluded:Excluded<=nil)
	 {self makePPrintRecord(X Features
				[value 'unit' info id item]
				Excluded)}
      end

%       meth toFullRecord(?X exclude:Exclude<=nil)
% 	 %% attr item is always skipped
% 	 X = {self toFullRecordAux($ exclude:item|Exclude)}
%       end
   end

   /** %% Free parameter values are by default turned into FD ints during the score initialisation (with InitScore). In contrast, parameters which inherit from this mixin are left untouched (i.e. if their value is a free variable, it remains free during initialisation). This can be useful, for example, if parameter values are potentially non-integers (e.g., floats).
   %%
   %% NOTE: uninitialised parameters will cause problems for the score distribution -- better exclude them from the distribution.  
   %% */
   class LeaveUninitialisedParameterMixin
      feat !LeaveUninitialisedParameterMixinType:unit
   end
   /** %% Returns true if X inherits from LeaveUninitialisedParameterMixin (or is an instance of LeaveUninitialisedParameterMixin), and false otherwise. 
   %% */
   fun {IsLeaveUninitialisedParameter X}
      {IsScoreObject X} andthen {HasFeature X LeaveUninitialisedParameterMixinType}
   end

   class TimeParameter from Parameter
      feat label: timeParameter
      meth isTimeParameter(?B) B=true end
      /** %% Returns the parameter value translated to a float representing seconds. The translation uses the parameter unit which must be bound (otherwise the method suspends). Supported units are (represented by these atoms): seconds/secs, milliseconds/msecs, and beats (a relative duration, e.g., a quarter note). The unit specification beats(N) means the parameter value of N is a single beat. beats(N) may be used to express tuplets, e.g., for beat(3) the value 1 means a third beat i.e. a triplet. N must be an integer and defaults to 1. The translation between seconds and beats uses Init.getBeatDuration.
      %% */
      meth getValueInSeconds(?X)
	 Unit = {self getUnit($)}
      in
	 %% NOTE: IsDet does not wait for binding -- quasi side effect. But most
	 %% often this is called for output and timeUnit is sometimes
	 %% forgotten by user...
	 if {Not {IsDet Unit}}
	 then {GUtils.warnGUI "unit of temporal parameter(s) unbound -- computation blocks!"}
	 end
	 %% parameter value is float
	 %% NOTE: inefficient to always check there two cases first,
	 %% as they are particualy rare
	 X = case Unit
	     of secsF then {self getValue($)} 
	     [] msecsF then {self getValue($)} / 1000.0
	     else
		%% parameter value is integer
		Value = {IntToFloat {self getValue($)}}
	     in
		case Unit
		of seconds then Value
		[] secs then Value
		[] milliseconds then Value / 1000.0
		[] msecs then Value / 1000.0
		[] beats then Value * {Init.getBeatDuration}
		[] beats(N) then Value * {Init.getBeatDuration} / {IntToFloat N}
		else
		   {Exception.raiseError
		    strasheela(illParameterUnit Unit self
			       "Supported units are seconds (or secs), millisecond (or msecs), beats, and beats(N) (where N is an integer).")}
		   unit		% never returned
		end
	     end
      end
      /** %% Returns the parameter value translated to a float representing beats. The translation uses the parameter unit which must be bound (otherwise the method suspends). Supported units are (represented by these atoms): seconds/secs, milliseconds/msecs, and beats. The unit specification beats(N) means the parameter value of N is a single beat. N must be an integer and defaults to 1. The translation between seconds and beats uses Init.getBeatDuration.
      %% */
      meth getValueInBeats(?X)
	 Unit = {self getUnit($)}
	 Value = {IntToFloat {self getValue($)}}
      in
	 %% !! IsDet does not wait for binding -- quasi side effect. But most
	 %% often this is called for output and timeUnit is sometimes
	 %% forgotten by user...
	 if {Not {IsDet Unit}}
	 then {GUtils.warnGUI "warn: timeUnit unbound"}
	 end
	 X = case Unit
	     of seconds then Value / {Init.getBeatDuration}
	     [] secs then Value / {Init.getBeatDuration}
	     [] milliseconds then Value / 1000.0 / {Init.getBeatDuration}
	     [] msecs then Value / 1000.0 / {Init.getBeatDuration}
	     [] beats then Value 
	     [] beats(N) then Value / {IntToFloat N}
	     else 
		{Exception.raiseError
		 strasheela(illParameterUnit Unit self
			    "Supported units are seconds (or secs), millisecond (or msecs), beats, and beats(N) (where N is an integer).")}
		unit		% never returned
	     end
      end
   end
   %%
   %%
   /** %% [concrete class] 
   %%*/
   class TimePoint from TimeParameter
      feat %'class': TimePoint
	 label: timePoint
      meth isTimePoint(?B) B=true end
   end
   /** %% [concrete class]
   %% */
   class TimeInterval from TimeParameter
      feat %'class': TimeInterval
	 label: timeInterval
      meth isTimeInterval(?B) B=true end
   end
   /** %% [concrete class]
   %%*/
   %% ?? supported units for the value attribute: milliMidi (milli midi velocity, temporary solution?)
   %% ?? 
   class Amplitude from Parameter
      feat %'class': Amplitude
	 label: amplitude
      meth isAmplitude(?B) B=true end

      %% supported units for output: absolute (0.0-1.0), dB (40-90), velocity/velo (0-127), milliVelocity/mvelo (0-12,700), csound (0-30,000)
      /** Converts the amplitude into a value in the range 0.0 (no sound) to 1.0 (full scale). Outputs a float. The translation uses the parameter unit which must be bound (otherwise the method suspends). Supported units are (represented by these atoms): velocity/velo (MIDI velocity, range 0-127), milliVelocity/mvelo (MIDI velocity derivate, range 0-12,700), dB (decibel values relative to full scale 1.0, range ~inf-0 -- the positive parameter values are implicitly negated. E.g., param value 60 corresponds to 0.001), mdB (milli-decibel, derivate from dB values) */
      meth getValueInNormalized(?X)
	 Unit = {self getUnit($)}
	 Value = {IntToFloat {self getValue($)}}
      in
	 %% !! IsDet does not wait for binding -- quasi side effect. 
	 if {Not {IsDet Unit}}
	 then {GUtils.warnGUI "warn: amplitude unit unbound"}
	 end
	 X = case Unit
	     of velocity then Value / 127.0
	     [] velo then Value / 127.0
	     [] millivelocity then Value / 127000.0
	     [] mvelo then Value / 127000.0
	     [] dB then {MUtils.dBToLevel ~Value 1.0}
	     [] mdB then {MUtils.dBToLevel (~Value / 1000.0) 1.0}
	     else
		{Exception.raiseError
		 strasheela(illParameterUnit Unit self
			    "Supported units are velocity (or velo), millivelocity (or mvelo), dB and mdB.")}
		unit		% never returned
	     end
      end
      /** %% Converts the amplitude into a value in the range 0.0 (no sound) to 127.0 (full scale). Outputs a Float.
      %% See getValueInNormalized for more information.
      %% */
      meth getValueInVelocity(?X)
	 X = {self getValueInNormalized($)} * 127.0
      end
   end

   local
      /** %% Returns true if PitchUnit is an atom which matches the pattern et<Digit>+ such as et31 or et72.
      %% */
      fun {IsET PitchUnit}
	 S = {AtomToString PitchUnit}
	 H T
      in
	 {List.takeDrop S 2 H T}
	 %% 
	 H == "et" andthen T \= nil andthen
	 {All T fun {$ C} {Char.isDigit C} end} 
      end
      /** %% Returns the pitches per octave expressed by an ET pitch unit, e.g., for et31 it returns 31. 
      %% */
      fun {GetPitchesPerOctave EtPitchUnit}
	 {StringToInt {List.drop {AtomToString EtPitchUnit} 2}}
      end

      LastNonmatchingPitchunit = {NewCell midi}
   in
      /** %% [concrete class] 
      %%*/
      class Pitch from Parameter
	 feat %'class': Pitch
	    label: pitch
	 meth isPitch(?B) B=true end
%       meth getValue(?X unit:Unit<=midicents)
% 	 X={self convertTo($ Unit)}
%       end
	 /** %% Returns the parameter value translated to a float representing a Midi keynumber (i.e. 60.5 is a quarternote above middle c). The translation uses the parameter unit which must be bound (otherwise the method suspends, but warns also). Supported units are (represented by these atoms): midi/keynumber, midicent/midic, frequency/freq/hz and et72 (equal temperament with 72 steps per octave).
	 %% A tuning table is used if such a table was either defined with Init.setTuningTable or was specified as optional argument table. 
	 %% */
	 meth getValueInMidi(?X table:Table<=nil)
	    Unit = {self getUnit($)}
	    Value = {IntToFloat {self getValue($)}}
	    FullTable = if Table==nil
			then {Init.getTuningTable}
			else {MUtils.fullTuningTable Table}
			end
	 in
	    if FullTable == nil 
	    then 
	       %% !! IsDet does not wait for binding -- quasi side effect. 
	       if {Not {IsDet Unit}}
	       then {GUtils.warnGUI 'pitch unit unbound'}
	       end
	       %% !!?? remove redundancy for e.g. midi or keynumber
	       X = case Unit
		   of midi then Value
		   [] keynumber then Value
% 		[] et72 then Value / 6.0 % * 12.0 / 72.0
% 		[] et31 then Value * 12.0 / 31.0 
% 		[] et22 then Value * 12.0 / 22.0 
		   [] midicent then Value / 100.0
		   [] midic then Value / 100.0
		   [] millimidicent then Value / 10000.0
		   [] frequency then {MUtils.freqToKeynum Value 12.0}
		   [] freq then {MUtils.freqToKeynum Value 12.0}
		   [] hz then {MUtils.freqToKeynum Value 12.0}
		   else
		      if {IsET Unit}
		      then Value * 12.0 / {IntToFloat {GetPitchesPerOctave Unit}}
		      else 
			 {Exception.raiseError
			  strasheela(illParameterUnit Unit self
				     "Supported units are midi, keynumber, et22, et31, et72, midicent (or midic), frequency (or freq), and hz."
			    % "Unsupported pitch unit."
				    )}
			 unit		% never returned
		      end
		   end
	    else 
	       PC = {self getValue($)} mod FullTable.size
	       Octave = {self getValue($)} div FullTable.size
	    in
	       %% warn if pitch unit and tuning table size don't
	       %% match, but only once until a new pitch unit was
	       %% found.
	       if Unit \= @LastNonmatchingPitchunit andthen 
		  {IsET Unit} andthen 
		  FullTable.size \= {GetPitchesPerOctave Unit}
	       then LastNonmatchingPitchunit := Unit
		  {GUtils.warnGUI
		   "Conflict between size of tuning table ("#FullTable.size#") and pitch unit ("#Unit#")!"}
	       end
	       X = (FullTable.period * {IntToFloat Octave} + FullTable.(PC + 1)) / 100.0
	    end
	 end
      end
   end
   
   /**
   %% [abstract class] An item is a generalization of score containers and elements. An item can be contained in one or more containers, the feature containers points to them.
   %%*/
   class Item from ScoreObject ScoreMapping.mappingMixin % Applicator.applicatorMixin
      prop locking		% !!?? locking needed? Everythink is stateless now
      feat %'class': Item
	 label: item
      attr
	 %% parameters binds the (extendable) list of containers the
	 %% item is contained in
	 containers
	 %% parameters binds the (extendable) list of all parameters
	 %% (e.g. needed for search)
	 parameters 
	 /** % The optional parameter containers expects a list of containers the item instance is contained in. (Additionally, containers can be given by calling the method bilinkContainers.)
	 %%
	 %% NB: the init args containers and addParameters are yet not supported by methods like toInitRecord.
	 % */
	 %% The number and types of parameters is specified by the subclasses of Item. Therefore, parameters is not an argument to Item, init.
	 %% !! change: moved arg addParameters here (before it was only defined for Event) 
      meth init(containers:Containers<=nil addParameters:AddParams<=nil ...)=M
	 %% to avoid misuse of init argument parameters...
	 ScoreObject, {Record.subtract M addParameters} 
	 %% for the attributes parameters and containers (and the
	 %% container attribute items) ExtendableLists are used. a)
	 %% That way subclasses of Item can add new parameters
	 %% independently and 'statelessly' (by calling addParameters).
	 %% b) Score items are instantiated before they are possibly
	 %% included (bidirectional bound) in one or more containers
	 %% -- the attribute containers/items is therefore bound only
	 %% later. Because the score can form a graph (i.e. items can
	 %% be contained in more than one container), the attribute
	 %% containers should be extendable multiple times.
	 %%
	 %% The ExtendableLists must be explicitely closed (by calling
	 %% closeExtendableLists for a single item or
	 %% closeScoreHierarchy for a score)
	 @parameters = {New LUtils.extendableList init}
	 @containers = {New LUtils.extendableList init}
	 {self bilinkContainers(Containers)}
	 {self bilinkParameters(AddParams)}
	 {self initFlags}
      end
      meth isItem(?B) B=true end
%      meth getAttributes(?X)
%	 X = {Append
%	      [containers parameters]
%	      %% !! single attr of MappingMixin added by hand to avoid
%	      %% message name conflict in mixin class
%	      flags|ScoreObject, getAttributes($)}
%      end
      /** % Initialises all parameters of item to FD variables (if still free). This method is called by MakeScore. For item subclasses it should be overwritten as necessary. 
      % */
      meth initDomains(Spec<=0#FD.sup) % !! Spec unused in calls
	 {ForAll {self getParameters($)}
	  proc {$ X} {X initFD(Spec)} end}
      end
      /** % After instantiating and initialising score objects to form a score hierarchy, the hierarchy is still extendable (i.e. the user can add items to containers and containers to items). The method closeScoreHierarchy makes a score hierarchy unextendable, which is necessary to prevent various procedures/methods from blocking.
      % */
      meth closeScoreHierarchy(mode:Mode<=tree)	 
	 {self closeExtendableLists} 
	 {self forAllThreaded(closeExtendableLists test:isItem mode:Mode)}
      end
      /** % [aux method]
      % */
      meth closeExtendableLists
	 {@parameters close}
	 {@containers close}
      end
      /** %% [aux method] Method must not be called by user.
      %% */
      %% !! method removed
%       meth addParameters(Parameters)
% 	 {@parameters addList(Parameters)}
%       end
      /** %% [aux method] Parameters and self are bidirectional linked. Method must not be called by user (only by class designer).
      % */
      meth bilinkParameters(Parameters) 
	 %% !! test locking (stateless: do I need a lock?)
	 lock
	    {@parameters addList(Parameters)} 
	    {ForAll Parameters proc {$ P} {P getItem($)}=self end} 
	 end
      end
      meth getParameters(?X) 
	 X = @parameters.list
      end
      /** %% Applies Proc (unary procedure or method) on all direct parameters in self.
      %% */
      meth forAllParameters(Proc)
	 {ForAll {self getParameters($)} {GUtils.toProc Proc}}
      end 
      /** %% Maps Fn (unary function or method) over all direct parameters in self.
      %% */
      meth mapParameters(?Xs Fn)
	 Xs = {Map {self getParameters($)} {GUtils.toFun Fn}}
      end 
      /** %% Return a list of all direct parameters of self for which Fn (unary function or method) returns true.
      %% */
      meth filterParameters(?Xs Fn)
	 Xs = {Filter {self getParameters($)} {GUtils.toFun Fn}}
      end 
      /** %% Returns the first direct parameter of self which fulfils the boolean function or method Test.
      %%*/
      meth findParameter(?X Test) 
	 X={LUtils.find {self getParameters($)} {GUtils.toFun Test}}
      end
      meth getContainers(?X) 
	 %X=@containers
	 X = @containers.list
      end
      /** %% Applies Proc (unary procedure or method) on all direct containers in self.
      %% */
      meth forAllContainers(Proc)
	 {ForAll {self getContainers($)} {GUtils.toProc Proc}}
      end 
      /** %% Maps Fn (unary function or method) over all direct containers in self.
      %% */
      meth mapContainers(?Xs Fn)
	 Xs = {Map {self getContainers($)} {GUtils.toFun Fn}}
      end 
      /** %% Return a list of all direct containers of self for which Fn (unary function or method) returns true.
      %% */
      meth filterContainers(?Xs Fn)
	 Xs = {Filter {self getContainers($)} {GUtils.toFun Fn}}
      end 
      /** %% Returns the first direct container self is contained in which fulfils the boolean function or method Test.
      %%*/
      meth findContainer(?X Test) 
	 X={LUtils.find {self getContainers($)} {GUtils.toFun Test}}
      end
      /** %% Returns the TemporalAspect self is contained in. A score object must be contained in only a single temporal aspect.  
      %%*/
      meth getTemporalAspect(?X) 
	 %% ?? memorization: I perhaps don't need this often
	 X={self findContainer($ {GUtils.toFun isTemporalAspect})}
      end
      /** %% Alias for getTemporalAspect.
      %% */
      meth getTemporalContainer($)
	 {self getTemporalAspect($)}
      end
      meth hasTemporalContainer($)
	 {self getTemporalContainer($)} \= nil
      end

      /** %% Apply unary procedure P (expecting a list) to the sublist from Xs (a list) matching PatternMatchingExpr (a list of atoms: a single 'x' and any number of 'o' in any order). PatternMatchingExpr expresses a sublist of Xs positionally related to self (an element of Xs). The atom 'x' in PatternMatchingExpr reprents self and one or more 'o' atoms around 'x' express predecessors or successors of self in Xs. For instance, <code>{Self patternMatchingApply([o o x] Xs P)</code> applies P to the list consisting in the two predecessors of Self in Xs and Self itself (in that order). 
      %% PatternMatchingApply reduces to skip in case there is no matching sublist in Xs (e.g. the PatternMatchingExpr = [o x] and self is already the first element in Xs).
      %% An exeception is raised in case self is not contained in Xs or there is no 'x' in PatternMatchingExpr.
      %%
      %% BTW: pmApply allows to easily apply rules across container bounderies. For instance, <code>local MyNotes={Flatten {MyMotifSeq mapItems($ getItems)}} in {ForAll MyNotes proc {$ N} {N pmApply(MyNotes [o x] MyRule)} end} end</code> applies MyRule to all neighbouring notes nested in a sequence of motifs.
      %% See also ScoreMapping.patternMatchingApply.
      %% */ 
      meth pmApply(Xs PatternMatchingExpr P)
	 {ScoreMapping.patternMatchingApply self Xs PatternMatchingExpr P}
      end
      /** %% Generalised variant of pmApply: in case no sublist in Xs matches PatternMatchingExpr, PatternMatchingApply2 does _not_ reduce to skip (as pmApply) but instead applies the null-ary procedure ElseP.
      %% See also ScoreMapping.patternMatchingApply2.
      %% */ 
      meth pmApply2(Xs PatternMatchingExpr P ElseP)
	 {ScoreMapping.patternMatchingApply2 self Xs PatternMatchingExpr P ElseP}
      end

      /** %% Variant of pmApply: applies P to the sublist of the elements of the temporal aspect of self which match PatternMatchingExpr.
      %% */
      meth pmApplyTemporalAspect(PatternMatchingExpr P)
	 {ScoreMapping.patternMatchingApply self {{self getTemporalAspect($)}
						  getItems($)}
	  PatternMatchingExpr P}
      end
      /** %% Generalised variant of pmApplyTemporalAspect2: in case no sublist in Xs matches PatternMatchingExpr, PatternMatchingApply2 does _not_ reduce to skip (as pmApplyTemporalAspect2) but instead applies the null-ary procedure ElseP.
      %% */ 
      meth pmApplyTemporalAspect2(PatternMatchingExpr P ElseP)
	 {ScoreMapping.patternMatchingApply2 self {{self getTemporalAspect($)}
						   getItems($)}
	  PatternMatchingExpr P ElseP}
      end

      /** % Calling the method bilinkItems with Containers expresses that self is contained in all Containers. The method establishes bidirectional links between both self and all Containers. Method must not be called by user (only by class designer).
      % */
      meth bilinkContainers(Containers)
	 %% !! test locking (stateless: do I need a lock?)
	 lock	
	    {@containers addList(Containers)} 
	    {ForAll Containers proc {$ X} {X addItem(self)} end} 
	 end
      end
      /** %% [aux method] Method adds Container to list of containers self is contained in. However, method does not establish bidirectional links. Method should not be called by user.
      %%*/
      meth addContainer(Container)
	 {@containers add(Container)}
      end
      /** %% Returns boolean whether self is a top level item in the score hierarchy graph.
      %%*/
      %% @1=?B
      meth isTopLevel(?B) ({self getContainers($)} == nil) = B end
      /** %% Returns list of all top level items in score hierarchy graph of self which fulfil the optional boolean function or method test.
      %% NB: This method even collects top-levels which are not (indirect) container of self but only of some of its (indirect) contained items. 
      %%*/
      %% @1=?Xs
      meth getTopLevels(?Xs test:Test<=fun {$ X} true end)
	 Xs = {self collect($ mode:graph 
			    test:fun {$ X} 
				    % parameter, e.g., can not be top level 
				    {X isItem($)} andthen 
				    {X isTopLevel($)} andthen 
				    {{GUtils.toFun Test} X} 
				 end)}
      end
      /** %% Returns the first top level of self which is a temporal item 
      %% (cf. doc to getTopLevels).
      %% */
      meth getTemporalToplevel(?Xs test:Test<=fun {$ X} true end)
	 Xs = {self getTopLevels($ test:fun {$ X}
					   {X isTimeMixin($)} andthen
					   {{GUtils.toFun Test} X}
					end)}.1
      end
      /** %% Returns the index of self in Container.
      %%*/
      %% @1=?Pos	
      meth getPosition(?Pos Container)
	 %% !!!! should I memorise position of self in Container?
	 %% !!?? should I make position constrainable ?
	 Pos={LUtils.position self {Container getItems($)}}
      end
      /** %%Returns the item in Container which is the Nth in relation to self (i.e. self too is an item in Container). N may be a negative integer (returns an item before self) or a positive integer (returns an item after self). For example, {X positionOffset($ 1 C)} returns the item just after self in C.
      %%*/
      %% @1=?X
      %%
      %% !! name change, was posRelatedItem
      meth getPosRelatedItem(?X N Container) 
	 Items = {Container getItems($)}
	 % XPos = {LUtils.position self Items} + N
	 XPos = {self getPosition($ Container)} + N
      in
	 if XPos < 1 orelse XPos > {List.length Items} 
	 then X=nil
	 else X={List.nth Items XPos}
	 end
      end
      /** % !! doc missing
      %% */
      %% 
      meth hasPosRelatedItem(?B N Container)
	 Items = {Container getItems($)}
	 % XPos = {LUtils.position self Items} + N
	 XPos = {self getPosition($ Container)} + N
      in
	 if XPos < 1 orelse XPos > {List.length Items} 
	 then B = false
	 else B = true
	 end
      end
      /** %% Returns predecessor item of self in Container.
      %%*/
      %% @1=?X
      meth getPredecessor(?X Container) 
	 X={self getPosRelatedItem($ ~1 Container)} 
      end
      /** %% Returns successor item of self in Container.
      %%*/
      %% @1=?X
      meth getSuccessor(?X Container) 
	 X={self getPosRelatedItem($ 1 Container)} 
      end
      /** %% Returns a boolean whether self is the first item in Container.
      %%*/
      %% @1=?B
      meth isFirstItem(?B Container) 
	 B = {Value.'==' {self getPredecessor($ Container)} nil} 
      end
      /** %% Returns a boolean whether self has a predecessor in Container.
      %%*/
      %% @1=?B
      meth hasPredecessor(?B Container)
	 B = {Not {self isFirstItem($ Container)}}
      end
      /** %% Returns a boolean whether self is the last item in Container.
      %%*/
      %% @1=?B
      meth isLastItem(?B Container) 
	 B = {Value.'==' {self getSuccessor($ Container)} nil} 
      end
      /** %% Returns a boolean whether self has a successor in Container.
      %%*/
      %% @1=?B
      meth hasSuccessor(?B Container)
	 B = {Not {self isLastItem($ Container)}}
      end
      /** % Are all parameter values determined? NB: isDet can return false simply because constraint propagation did not finish to determine some parameter. You may want to use the method wait instead.
      % */
      meth isDet($)
	 {All {self getParameters($)}
	  fun {$ X} {IsDet {X getValue($)}} end}
      end
      /** %% Wait (blocks) until all parameter values of self are determined. The only exception are parameters for which the optional arg Unless -- a boolean unary function -- returns true (per default, Unless always returns false).
      %% */
      meth wait(unless:Unless<=fun {$ _} false end)
	 {ForAll {self getParameters($)}
	  proc {$ X}
	     if {Not {Unless X}}
	     then {Wait {X getValue($)}}
	     end
	  end}
      end

      meth hasTemporalPredecessor(?B)
	 MyAspect = {self getTemporalAspect($)}
      in
	 if MyAspect==nil
	 then B=false
	 else B= {self hasPredecessor($ MyAspect)}
	 end
      end
      /** %% Checks whether object has a successor in its TemporalAspect. NB: method checks for a positional and not a temporal successor.
      %% !!?? Rename to hasSuccessorInTemporalAspect ?
      %% */ 
      meth hasTemporalSuccessor(?B)
	 MyAspect = {self getTemporalAspect($)}
      in
	 if MyAspect==nil
	 then B=false
	 else B={self hasSuccessor($ MyAspect)}
	 end
      end
      /** %% Returns the predecessor of object in its TemporalAspect. NB: method returns positional and not a temporal predecessor. 
      %% !!?? Rename to getPredecessorInTemporalAspect ?
      %% */ 
      meth getTemporalPredecessor(?B)
	 B= {self getPredecessor($ {self getTemporalAspect($)})}
      end
      /** %% Returns the successor of object in its TemporalAspect. NB: method returns positional and not a temporal successor. 
      %% !!?? Rename to getSuccessorInTemporalAspect ?
      %% */ 
      meth getTemporalSuccessor(?B)
	 B= {self getSuccessor($ {self getTemporalAspect($)})}
      end


      /** %% For all score objects in self (including self itself) which fulfil Test (a function or method name), the method sets the parameter unit accessible by ParameterAccessor (a function or method name) to Unit. Test defaults to isItem.
      %% NB: ParameterAccessor must return the parameter, not the parameter value (e.g. use getPitchParameter instead of getPitch)
      %% */
      meth setAllParameterUnits(ParameterAccessor Unit test:Test<=isItem)
	 MyTest = {GUtils.toFun Test}
	 proc {SetUnit X}
	    %% how to check whether X understands method
	    Unit = {{{GUtils.toFun ParameterAccessor} X}
		    getUnit($)} 
	 end
      in
	 if {MyTest self} then {SetUnit self} end
	 {self forAll(test:MyTest
		      mode:graph
		      SetUnit)}
      end

      %% !! yet undefined
      % meth getInitInfo(?X)
      % ?? how to handle score graphs, i.e. multiple containers?
      % end

      %% !! simplified definition: does not handle score graphs,
      %% i.e. multiple containers?
%       meth toFullRecord(?X exclude:Exclude<=nil)
% 	 %% !! attr containers is always skipped
% 	 X = {self toFullRecordAux($ exclude:containers|Exclude)}
%       end
      
   end
   
   /** %% [abstract class] A container contains one or more score items. A container is a generalization of a score aspect and a score modifier. The attribute items points to the items contained in a container. Because containers themself are items as well, a container can contain other containers to form a score hierarchy of containers and elements. However, a container must not contain itself.
   %%*/ 
   class Container from Item
      feat %'class': Container
	 label: container
      attr
	 %% items binds the (extendable) list of items contained in
	 %% the container
	 items
	 /** % The optional parameter items expects a list of items which are contained in the container instance. (Additionally, items can be given by calling the method bilinkItems.)
	 % */
      meth init(items:Items<=nil ...) = M
	 Item, {Record.subtract M items}
	 @items = {New LUtils.extendableList init}
	 {self bilinkItems(Items)}
      end 
      /** % [aux method]
      % */
      meth closeExtendableLists
	 Item, closeExtendableLists
	 {@items close}
      end
      meth isContainer(?B) B=true end
      %% !! getItems _must_ return a list
      meth getItems(?X) 
	 X=@items.list
      end
      /** %% Applies Proc (unary procedure or method) on all direct items in self which fulfill Test (a boolean function or method).
      %% */
      %% !! rename: forItems
      meth forAllItems(Proc test:Test<=fun {$ X} true end)
	 {ForAll {self filterItems($ Test)} {GUtils.toProc Proc}}
      end 
      /** %% Maps Fn (unary function or method) over all direct items in self which fulfill Test (a boolean function or method).
      %% */
      meth mapItems(?Xs Fn test:Test<=fun {$ X} true end)
	 Xs = {Map {self filterItems($ Test)} {GUtils.toFun Fn}}
      end
      /** %% N (an integer) is the number of all direct items in self which fulfill Test (a boolean function or method).
      %% */
      meth countItems(?N test:Test<=fun {$ X} true end)
	 N = {Length {self filterItems($ Test)}}
      end
      /** %% Return a list of all direct items of self for which Fn (unary function or method) returns true.
      %% */
      meth filterItems(?Xs Fn)
	 Xs = {Filter {self getItems($)} {GUtils.toFun Fn}}
      end 
      /** %% Returns the first direct item of self which fulfils the boolean function or method Test.
      %%*/
      meth findItem(?X Test) 	
	 X={LUtils.find {self getItems($)} {GUtils.toFun Test}}
      end

      /** %% Applies unary procedure P to each item in self which index is expressed by Decl. Decl is a list which contains single index integers or index ranges of the form Min#Max (Min and Max are integers).
      %% BTW: ForNumericRange corresponds roughly to rule application mechanism of Situation.
      %%
      %% See also ScoreMapping.forNumericRange 
      %% */ 
      meth forNumericRangeTemporalAspect(Decl P)
	 {ScoreMapping.forNumericRange {self getItems($)}
	  Decl P}
      end
      /** %% Generalised variant of forNumericRangeTemporalAspect: to every item in self to which P is not applied, ElseP (a unary procedure) is applied instead.
      %% See also ScoreMapping.forNumericRange2 
      %% */ 
      meth forNumericRangeTemporalAspect2(Decl P ElseP)
	 {ScoreMapping.forNumericRange2 {self getItems($)}
	  Decl P ElseP}
      end

      
      /** % Are all parameter values determined, including nested score objects? NB: isDet can return false simply because constraint propagation did not finish to determine some parameter. You may want to use the method wait instead.
      % */
      meth isDet($)
	 {All {Append
	       {Map {self getParameters($)} fun {$ X} {IsDet {X getValue($)}} end}	 
	       {self mapItems($ fun {$ O} {O isDet($)} end)}}
	  fun {$ B} B==true end}
      end
      /** %% Wait until all parameter values of self and of its (directly and indirectly) contained items are determined. The only exception are parameters for which the optional arg Unless -- a boolean unary function -- returns true (per default, Unless always returns false).
      %% */
      meth wait(unless:Unless<=fun {$ _} false end)
	 {ForAll {self getParameters($)}
	  proc {$ X}
	     if {Not {Unless X}}
	     then {Wait {X getValue($)}}
	     end
	  end}
	 {self forAllItems(proc {$ O} {O wait(unless:Unless)} end)}
      end
      
      /** % Calling the method bilinkItems with Items expresses that Items are contained in the container itself. The method establishes bidirectional links between both self and all Items. Method must not be called by user (only by class designer).
      % */
      meth bilinkItems(Items)
	 %% !! test locking (stateless: do I need a lock?)
	 lock	
	    {@items addList(Items)} 
	    {ForAll Items proc {$ X} {X addContainer(self)} end} 
	 end
      end
      /** % [aux method] Method adds Item to list of items contained in self. However, method does not establish bidirectional links. Method should not be called by user.
      % */
      meth addItem(Item)
	 {@items add(Item)}
      end
      /** %% Method returns a record with essential data of self. The method is intended to view self uncluttered. The method feature <code>features</code> allows to freely select a list of score object features/attributes to include. 
      %% */
      %% @1=?X
      meth toPPrintRecord(?X features:Features<=DefaultPPrintFeatures
			  excluded:Excluded<=nil)
	 {self makePPrintRecord(X Features
				[containers flags info id items parameters]
				Excluded)}
      end

%      meth getAttributes(?X)
%	 X = items | Item, getAttributes($)
%      end
%       meth toInitRecord(?X exclude:Excluded<=DefaultInitRecordExcluded)
% 	 X = {Adjoin
% 	      Item, toInitRecord($ exclude:Excluded)
% 	      {Record.subtractList
% 	       {Record.map {self makeInitRecord($ [items#getItems#nil])}
% 		fun {$ Items}
% 		   %% there is only the single feat items, if any
% 		   {Map Items
% 		    fun {$ X} {X toInitRecord($ exclude:Excluded)} end}
% 		end}
% 	       Excluded}}
%       end
%       meth toInitRecord(?X exclude:Excluded<=DefaultInitRecordExcluded)
% 	 X = {Adjoin
% 	      %% process 'items'
% 	      unit(items:{self mapItems($ fun {$ X}
% 					     {X toInitRecord($ exclude:Excluded)}
% 					  end)})
% 	      %% process all feats of self except 'items'
% 	      Item, toInitRecord($ exclude: items#getItems#nil | Excluded)}
%       end

      meth getInitInfo($ exclude:Excluded)
	 unit(superclass:Item
	      args:[items#fun {$ X}
			     {X mapItems($ fun {$ X}
					      {X toInitRecord($ exclude:Excluded)}
					   end)}
			  end#noMatch])
      end

%       %% !! simplified definition: does not handle score graphs,
%       %% i.e. multiple containers?
%       meth toFullRecord(?X exclude:Exclude<=nil)
% 	 %% !! attr containers is always skipped
% 	 X = {self toFullRecordAux($ exclude:containers|Exclude)}
%       end
      
   end
   
   /** %% [semi abstract class] A Modifier contains one or more items and modifies them [their meaning? / modifies them when the score is output?] in some way. Conventional examples for modifiers in common music notation are the repetition sign, staccato sign, trill sign etc., which modify the music they belong to. Subclasses of Modifier can define all these signs of common music notation. The attribute items points to the music the modifier belong to. 
   %%
   %% However, even the modification itself the modifier applies to music (i.e. the meaning of the modifier) can be expressed directly in an instance of the class Modifier. The actual modification is defined as a unary function. When the score is output, the function will be called with the value bound to the attribute items. That way, arbitrary modifications can be defined. Examples include modifications of contained temporal attributes or other parameters by envelopes: ritardando, crescendo etc.
   %%
   %% The attribute modifier binds the modification function.
   %%
   %% !! NB: currently, the score output functions (see ./Output.oz) ignore the Modifier which is therefore without effect!
   %%*/
   class Modifier from Container
      feat %'class': Modifier
	 label: modifier
      attr modifier
      meth isModifier(?B) B=true end
      meth getModifier(?X) X=@modifier end
%      meth getAttributes(?X)
%	 X = modifier | Container, getAttributes($)
%      end
   end

   /** %% [semi abstract class] An aspect contains one or more score items to group them and to provide additional information to its items. For instance, a sequential groups items and imposes them in a sequential order in time.
   %%*/
   class Aspect from Container
      feat %'class': Aspect
	 label: aspect
      meth isAspect(?B) B=true end
   end  

   /** %% [abstract class] A TemporalAspect is an aspect which contains timing related attributes and understands timing related methods. A TemporalAspect is a generalisation of a Sequential and a Simultaneous, which both impose timing information to the items they contain.
   %% For a documentation of the time related attributes/parameters see doc of TimeMixin.
   %%*/
   class TemporalAspect from Aspect TimeMixin
      feat %'class': TemporalAspect
	 label: temporalAspect
	 /** %% The timing parameter units are specified by timeUnit.
	 %% */
      meth init(startTime:StartTime<=_ endTime:EndTime<=_ 
		offsetTime:OffsetTime<=0 duration:Duration<=_
		timeUnit:TimeUnit<=_ ...) = M 
	 Aspect, {Record.subtractList M
		  [startTime endTime offsetTime duration timeUnit]}
	 {self initTiming(startTime:StartTime endTime:EndTime 
			  offsetTime:OffsetTime duration:Duration
			  timeUnit:TimeUnit)}
      end
      meth isTemporalAspect(?B) B=true end
      meth isTimeMixin(?B) B=true end
%      meth getAttributes(?X)
%	 X = {Append
%	      Aspect, getAttributes($)
%	      %% TimeMixin attr. added by hand to avoid mixin message conflicts
%	      [startTime endTime offsetTime duration]}
%      end
%       meth toInitRecord(?X exclude:Excluded<=[startTime duration endTime timeUnit])
% 	 X = {Adjoin
% 	      Aspect, toInitRecord($ exclude:Excluded)
% 	      {Record.subtractList
% 	       {self makeInitRecord($ [offsetTime#getOffsetTime#0
% 				       startTime#getStartTime#noMatch
% 				       endTime#getEndTime#noMatch
% 				       %% !!?? TemporalAspect duration fully disabled because I have yet no control to enable it for TemporalElement and to disable it for TemporalAspect
% 				       %% duration#getDuration#noMatch
% 				       %%
% 				       %% ?? no default for timeUnit,  
% 				       %% !!?? timeUnit never included
% 				       %% timeUnit#getTimeUnit#noMatch
% 				      ])}
% 	       Excluded}}
%       end

      meth getInitInfo($ exclude:Excluded)
	 unit(superclass:Aspect
	      %% general guideline: better specify too much information, than removing information
	      args:{FoldL
		    [%% specify timeUnit only for toplevel
		     if {self isTopLevel($)}
		     then [timeUnit#getTimeUnit#noMatch]
		     else nil
		     end
		     if {self isDet($)}
		     then
			%% duration is redundant for TemporalAspect, if temporal structure is determined
			{Append
			 if {self isTopLevel($)}
			    %% if temporal structure is determined, startTime is only required for top-level container
			 then [startTime#getStartTime#{FD.decl}]
			 else nil
			 end
			 [offsetTime#getOffsetTime#0
			  endTime#getEndTime#{FD.decl}]}
		     else [offsetTime#getOffsetTime#0
			   startTime#getStartTime#{FD.decl}
			   duration#getDuration#{FD.decl}
			   endTime#getEndTime#{FD.decl}]
		     end]
		    Append nil}
% 		 {FoldL
% 		  [%% specify timeUnit and startTime only for toplevel
% 		   %% !! can be problematic for undetermined temporal structure
% 		   if {self isTopLevel($)}
% 		   then [timeUnit#getTimeUnit#noMatch
% 			 startTime#getStartTime#{FD.decl}]
% 		   else nil
% 		   end
% 		   %% duration is redundant for TemporalAspect, if duration of its contained items is determined
% 		   %% !! can be problematic for undetermined temporal structure
% 		   [offsetTime#getOffsetTime#0
% 		    endTime#getEndTime#{FD.decl}]]
% 		  Append nil}
	     )
      end
   end   

   /** %% [concrete class] A Sequential expresses that the items contained in it follow each other in a sequential manner in time. Usually, the parameter endTime of a proceeding item equals the parameter startTime of the following item. However, setting the parameter offsetTime of an item to a value greater zero causes a gap (i.e. a pause) before the item and a negative offsetTime causes an overlap with the proceeding item.
   %% For a documentation of the time unit see doc of TimeMixin.
   %% NB: A negative offsetTime value is not possible if the offsetTime is a FD integer (which presently is the only option).
   %%*/
   class Sequential from TemporalAspect
      feat %'class': Sequential
%	 label: sequential
	 label: seq
      meth isSequential(?B) B=true end
      /** %% After full creation of score hierarchy, method must be called with every TimeMixin subclass instance in score to init the timing attributes/features 
      %% */
      meth constrainTiming	% in extra thread? 
	 Items = {self getItems($)}
      in
	 if {Not Items==nil}
	 then 
	    %% constrain startTime of first item
	    {Items.1 getStartTime($)} =: 
	    {self getStartTime($)} + {Items.1 getOffsetTime($)}
	    %% constrain startTime of succeeding items
	    {ForAll {List.zip 			% !! inefficient: extra zip needed?
		     {List.take Items {Length Items}-1}
		     {List.drop Items 1}
		     fun {$ Pre Suc} Pre#Suc end}
	     proc {$ Pre#Suc} 
		{Suc getStartTime($)} =: 
		{Pre getEndTime($)} + {Suc getOffsetTime($)}
	     end}
	    %% constrain endTime 
	    {self getEndTime($)} = {{List.last Items} getEndTime($)}
	 end
	 TimeMixin, constrainTiming
      end

%       meth toInitRecord(?X exclude:Excluded<=DefaultInitRecordExcluded)
% 	 X = {Adjoin
% 	      TemporalAspect, toInitRecord($ exclude:Excluded)
% 	      %% short label
% 	      seq}
%       end
      
   end  
   /** %% [concrete class] A Simultaneous expresses that the items contained in it start at the same time.  However, setting the parameter offsetTime of an item to a value greater zero causes this item to delay its startTime the amount of offsetTime.
   %% For a documentation of the time unit see doc of TimeMixin.
   %%*/
   class Simultaneous from TemporalAspect
      feat %'class': Simultaneous
%	 label: simultaneous
	 label: sim
      meth isSimultaneous(?B) B=true end
      /** %% [temp method ??] After full creation of score hierarchy, method must be called with every TimeMixin subclass instance in score to init the timing attributes/features 
      %%*/
      meth constrainTiming	% in extra thread? 
	 Items = {self getItems($)} 
      in
	 if {Not Items==nil}
	 then 
	    %% constrain startTime of items
	    {ForAll Items
	     proc {$ X} 
		{X getStartTime($)} =: 
		{self getStartTime($)} + {X getOffsetTime($)}
	     end}
	    %% constrain endTime 
	    %% !! tmp. Must be max of endTimes, but there is some problem...
	    %% this is same as in seq
	    %{self getEndTime($)} = {{List.last Items} getEndTime($)}
	    %%
	    %% !!?? this causes problems (easy CSP become seemingly
	    %% unsolvable). Why??
% 	    {self getEndTime($)} = {Pattern.max
% 				     {Map Items
% 				      fun {$ X } {X getEndTime($)} end}}
	    {self getEndTime($)}
	    = {LUtils.accum {Map Items fun {$ X } {X getEndTime($)} end}
	       fun {$ X1 X2} {FD.max X1 X2} end}
	 end
	 TimeMixin, constrainTiming
      end

%       meth toInitRecord(?X exclude:Excluded<=DefaultInitRecordExcluded)
% 	 X = {Adjoin
% 	      TemporalAspect, toInitRecord($ exclude:Excluded)
% 	      %% short label
% 	      sim}
%       end

   end  

   /** %% [abstract class] An element is a score item which does not contain items. For instance, a note and a pause are both elements.
   %%*/
   class Element from Item
      feat %'class': Element
	 label: element
      meth isElement(?B) B=true end
      /** %% Method returns a record with essential data of self. The method is intended to view self uncluttered. The method feature <code>features</code> allows to freely select a list of score object features/attributes to include. 
      %% */
      %% @1=?X
      meth toPPrintRecord(?X features:Features<=DefaultPPrintFeatures
			  excluded:Excluded<=nil)
	 {self makePPrintRecord(X Features 
				[containers flags info id parameters]
				Excluded)}
      end

   end
    
   /** %% [semi abstract class] An AbstractElement is an element without timing information. For instance, an instrument definition for a sound synthesis language such as Csound could be represented by an instance of a subclass of AbstractElement.
   %%*/
   % extra 'class' AbstractElement, ie. an element without timing info needed? Example: sound synthesis instrument -- do I really need this extra data type??
   class AbstractElement from Element
      feat %'class': AbstractElement
	 label: abstractElement
      meth isAbstractElement(?B) B=true end
   end   

   /** %% [abstract class] A TemporalElement is an element with timing information. For instance, any action of a performer is a TemporalElement -- whether the action is heard or not. An unheard action can a change of the instrument (as muting it) is a TemporalElement, a heard action the performance of a note. 
   %%*/
   class TemporalElement from Element TimeMixin
      feat %'class': TemporalElement
	 label: temporalElement
	 /** The timing parameter units are specified by timeUnit. */
      meth init(startTime:StartTime<=_ endTime:EndTime<=_ 
		offsetTime:OffsetTime<=0 duration:Duration<=_
		timeUnit:TimeUnit<=_ ...) = M
	 Element, {Record.subtractList M 
		   [startTime endTime offsetTime duration timeUnit]}
	 {self initTiming(startTime:StartTime endTime:EndTime 
			  offsetTime:OffsetTime duration:Duration
			  timeUnit:TimeUnit)}
      end
      meth isTemporalElement(?B) B=true end
      meth isTimeMixin(?B) B=true end
%      meth getAttributes(?X)
%	 X = {Append
%	      Element, getAttributes($)
%	      %% TimeMixin attr. added by hand to avoid mixin message conflicts
%	      [startTime endTime offsetTime duration]}
%      end
%       meth toInitRecord(?X exclude:Excluded<=DefaultInitRecordExcluded)
% 	 X = {Adjoin
% 	      Element, toInitRecord($ exclude:Excluded)
% 	      {Record.subtractList
% 	       %% !!?? overexplicit: duration implicit in startTime + endTime
% 	       {self makeInitRecord($ [offsetTime#getOffsetTime#0
% 				       startTime#getStartTime#noMatch
% 				       endTime#getEndTime#noMatch
% 				       duration#getDuration#noMatch
% 				       %% !!?? timeUNit never included
% 				       % timeUnit#getTimeUnit#noMatch
% 				      ])}
% 	       Excluded}}
%       end

      meth getInitInfo($ exclude:Excluded)
	 unit(superclass:Element
	      args:{Append if {self getTemporalAspect($)} == nil
			      %% timeUnit and startTime only for top level
			   then [timeUnit#getTimeUnit#noMatch
				 startTime#getStartTime#{FD.decl}]
			   else nil
			   end
		    [offsetTime#getOffsetTime#0
		     %% time params startTime, endTime, and duration
		     %% only required in case of undetermined values...
		     endTime#getEndTime#{FD.decl}
		     duration#getDuration#{FD.decl}]})
      end
      
   end   

   /** %% [concrete class] A pause is a score element to produce silence of a given duration. It can, e.g., be used within a sequential to produce an offset between two items in the sequential. However, in such situation a pause could be replaced by the use of the parameter offsetTime of the item after the pause. Nevertheless, a pause in an explicite representation.
   %% For a documentation of the time unit see doc of TimeMixin.
   %%*/
   class Pause from TemporalElement
      feat %'class': Pause
	 label: pause
      meth isPause(?B) B=true end
   end   

   /** %% [semi abstract class or concrete class?] An event is a score element which produces sound when the score is played. An event is a very general representation for something producing sound. For instance, a note played on a piano (with a specific pitch, loudness etc.), a hand clapping (no pitch, but maybe a specific loudness), or an arbitrary sound synthesis language event (possibly with dozends of parameters) are all representable be an event. 
   %% 
   %% To provide such generality, an event has the attribute parameters which points to a collection [better term?] of all parameters of the event. The parameters themself contain information about their purpose (e.g. parameters are of a certain class as pitch, or amplitude). However, as a convenience, certain parameters are additionally referenced by an extra feature  (e.g. all timing related parameters have their own feature, as startTime, offsetTime, endTime or duration). Subclasses of the event class may define additional features. Nevertheless, all parameters can be accessed via the parameters feature
   %%
   %% An event always has the timing parameters startTime, duration, endTime, and offsetTime. However, additional parameters can be specified optionally (e.g. by the feature addParameters of the init method).
   %% For a documentation of the time unit see doc of TimeMixin.
   %%*/
   class Event from TemporalElement 
      feat %'class': Event
	 label: event
	 %% !! change: moved arg addParameters into Item, init
%       meth init(addParameters:AddParams<=nil ...) = M
% 	 TemporalElement, {Record.subtract M addParameters}
% 	 {self bilinkParameters(AddParams)}
%       end
      meth isEvent(?B) B=true end

      %% !! yet undefined
      %% meth toInitRecord(?X)
      %% ??!! how to access AddParams
      %% end
   end   

   /** %% [concrete class] A note is an score event with explicit attributes for the parameter pitch.
   %% A note inherits various timing parameters from the event class. The full set of non-optional note parameters (i.e. parameters which are not only bound to the attribute parameters, but which have extra attributes) is startTime, duration, endTime, offsetTime}, and pitch. Additional parameters can be specified optionally (e.g. by the feature addParameters of the init method).
   %%*/
   class Note2 from Event
      feat %'class': Note
	 label: note
      attr pitch 
	 /** %% The parameter unit of pitch is specified by pitchUnit (default keynumber). 
	 %% */
      meth init(%addParameters:AddParams<=nil 
		pitch:P<=_ pitchUnit:PU<=keynumber ...) = M 
	 Event, {Record.subtractList M 
		 [pitch pitchUnit]}
	 %% !! tmp commment
	 @pitch = {New Pitch init(value:P 'unit':PU)}
	 {self bilinkParameters([@pitch])}
      end	
      meth isNote(?B) B=true end
      meth getPitch(?X) X={@pitch getValue($)} end
      /** %% Returns the pitch of self measured as a MIDI float (e.g., for 12 pitches per octave, 60.5 is a quartertone above the equally tempered middle C). The pitch value depends on the pitchUnit. Additionally, it can be affected by a tuning table. A tuning table is either defined globally with Init.setTuningTable or with the optional Table argument, which expects a table in the same format as Init.setTuningTable.   
      %% */
      %% NOTE: default of Table set again here
      meth getPitchInMidi(?X table:Table<=nil)
	 X={@pitch getValueInMidi($ table:Table)}
      end 
      meth getPitchParameter(?X) X=@pitch end 
      meth getPitchUnit(?X) X={@pitch getUnit($)} end 
%      meth getAttributes(?X)
%	 X = {Append [pitch]
%	      Event, getAttributes($)}
%      end
%       meth toInitRecord(?X exclude:Excluded<=DefaultInitRecordExcluded)
% 	 X = {Adjoin
% 	      Event, toInitRecord($ exclude:Excluded)
% 	      {Record.subtractList
% 	       {self makeInitRecord($ [pitch#getPitch#noMatch
% 				       pitchUnit#getPitchUnit#keynumber])}
% 	       Excluded}}
%       end
      
      meth getInitInfo($ exclude:Excluded)
	 unit(superclass:Event
	      args:[pitch#getPitch#{FD.decl}
		    pitchUnit#getPitchUnit#keynumber])
      end
      
   end


   /** %% [concrete class] Extends class Note2 by parameter amplitude. These two classes exist because an amplitude is usually needed if a sound synthesis format is output but may not be needed if only a music notation format is output.
   %% */
   class Note from Note2
      feat %'class': Note
	 label: note
      attr amplitude
      meth init(%addParameters:AddParams<=nil 
		amplitude:A<=_ amplitudeUnit:AU<=velocity 
		...) = M 
	 Note2, {Record.subtractList M
		 [amplitude amplitudeUnit]}
	 @amplitude = {New Amplitude init(value:A 'unit':AU)}
	 %{self getAmplitude(A)} {self getAmplitudeUnit(AU)}
	 {self bilinkParameters([@amplitude])}
      end	
      meth isNote(?B) B=true end
      meth getAmplitude(?X) X={@amplitude getValue($)} end
      meth getAmplitudeInNormalized(?X) X={@amplitude getValueInNormalized($)} end
      meth getAmplitudeInVelocity(?X) X={@amplitude getValueInVelocity($)} end
      meth getAmplitudeParameter(?X) X=@amplitude end
      meth getAmplitudeUnit(?X) X={@amplitude getUnit($)} end
%      meth getAttributes(?X)
%	 X = {Append
%	      [amplitude]
%	      Note2, getAttributes($)}
%      end
%       meth toInitRecord(?X exclude:Excluded<=DefaultInitRecordExcluded)
% 	 X = {Adjoin
% 	      Note2, toInitRecord($ exclude:Excluded)
% 	      {Record.subtractList
% 	       {self
% 		makeInitRecord($ [amplitude#getAmplitude#noMatch
% 				  amplitudeUnit#getAmplitudeUnit#velocity])}
% 	       Excluded}}
%       end
      
      meth getInitInfo($ exclude:Excluded)
	 unit(superclass:Note2
	      args:[amplitude#getAmplitude#{FD.decl}
		    amplitudeUnit#getAmplitudeUnit#velocity])
      end
      
   end


   
   %
   % functions
   %
   /** %% Returns a boolean whether X is an Object with the class/superclass ScoreObject. 
   %%*/
   fun {IsScoreObject X}
      {Not {GUtils.isFS X}} andthen % undetermined FS vars block on Object.is
      {Object.is X} andthen {HasFeature X ScoreObjectType}
   end
   /** %% Returns a boolean whether X is an item which inherits from TimeMixin (i.e. X is either a TemporalElement or a TemporalAspect). 
   */ 
   fun {IsTemporalItem X}
      {IsScoreObject X} andthen {X isItem($)} andthen {X isTimeMixin($)}
   end
   /** %% Returns a boolean whether X is a container which inherits from TimeMixin. This is an alias type check whether X is a TemporalAspect.
   */ 
   fun {IsTemporalContainer X}
      % {IsScoreObject X} andthen {X isContainer($)} andthen {X isTimeMixin($)}
      {IsScoreObject X} andthen {X isTemporalAspect($)}
   end

   
   local
      DefaultConstructors = unit(seq: Sequential
				 sim: Simultaneous
				 sequential: Sequential
				 simultaneous: Simultaneous
				 aspect: Aspect
				 modifier: Modifier
				 note: Note
				 note2: Note2
				 event: Event
				 pause: Pause)
      %%
      proc {MakeExplicitObject ScoreSpec Constructors MyItemIDs ?X}
	 %% Creates single object. Prevents recreation if ID already
	 %% occured: first object of ID created will be returned
	 %% instead. Therefore, only initialisation arguments of first
	 %% object are used (!).
	 if {IsScoreObject ScoreSpec} % !! new: needs testing
	 then X=ScoreSpec
	 else 
	    HasID = {HasFeature ScoreSpec id}
	    IsCreated = HasID andthen {Dictionary.member MyItemIDs ScoreSpec.id}
	 in
	    if IsCreated
	    then X={Dictionary.get MyItemIDs ScoreSpec.id}
	    else Constructor=Constructors.{Label ScoreSpec}
	    in
	       if {IsClass Constructor}
	       then X={New Constructor {Adjoin {Record.subtractList ScoreSpec
						[items containers]}
					init}}
	       else X={Constructor {Record.subtractList ScoreSpec
				    [items containers]}}
	       end
	       if HasID
	       then {Dictionary.put MyItemIDs ScoreSpec.id X}
	       end
	    end
	 end
      end
      fun {MakeExplicitScoreAux ScoreSpec Constructors MyItemIDs}
	 X = {MakeExplicitObject ScoreSpec Constructors MyItemIDs}
      in
	 %% create contained items
	 if {HasFeature ScoreSpec items}
	 then
	    Items = {LUtils.mappend ScoreSpec.items
		     fun {$ S} {MakeExplicitScoreAux S Constructors MyItemIDs} end}
	 in
	    {X bilinkItems(Items)} 
	 end
	 %% created surrounding containers
	 if {HasFeature ScoreSpec containers}
	 then
	    Containers = {LUtils.mappend ScoreSpec.containers
			  fun {$ S} {MakeExplicitScoreAux S Constructors MyItemIDs} end}
	 in
	    {X bilinkContainers(Containers)} 
	 end
	 [X]
      end
      fun {MakeExplicitScore ScoreSpec Constructors MyItemIDs} 
	 ConstructorsUsed 
      in
	 %% bind Constructors
	 case Constructors
	 of unit then ConstructorsUsed=DefaultConstructors
	 [] add(...) then ConstructorsUsed={Adjoin DefaultConstructors Constructors}
	 else ConstructorsUsed=Constructors
	 end
	 {MakeExplicitScoreAux ScoreSpec ConstructorsUsed MyItemIDs}.1
      end
      proc {UnifyIDsAux ScoreSpec MyUnifyIDs ?X}      
	 if {IsScoreObject ScoreSpec} % !! new: needs testing
	 then X=ScoreSpec
	 else 
	    HasID = {HasFeature ScoreSpec id}
	    IsCreated = HasID andthen {Dictionary.member MyUnifyIDs ScoreSpec.id}
	    GetFeat
	 in
	    if HasID
	    then
	       if {Not IsCreated}
	       then 
		  {Dictionary.put MyUnifyIDs ScoreSpec.id
		   {RecordC.tell {Label ScoreSpec}}}
	       end
	       X = {Dictionary.get MyUnifyIDs ScoreSpec.id}
	       GetFeat = fun {$ X Feat} X ^ Feat end
	    else
	       X = {Record.clone ScoreSpec}
	       GetFeat = fun {$ X Feat} X.Feat end
	    end
	    %% X equals ScoreSpec except features containers and items
	    {Record.forAllInd {Record.subtractList ScoreSpec [containers items]}
	     proc {$ Feat _} {GetFeat X Feat} = ScoreSpec.Feat end}
	    if {HasFeature ScoreSpec containers}
	    then {GetFeat X containers} = {Map ScoreSpec.containers
					   fun {$ X} {UnifyIDsAux X MyUnifyIDs} end}
	    end
	    if {HasFeature ScoreSpec items}
	    then {GetFeat X items} = {Map ScoreSpec.items 
				      fun {$ X} {UnifyIDsAux X MyUnifyIDs} end}
	    end
	 end
      end
      proc {UnifyIDs ScoreSpec MyUnifyIDs ?X}
	 %% Traverse ScoreSpec, collect all Score items with equal IDs
	 %% and unify their init args
	 case ScoreSpec of Y|Ys
	 then X = {UnifyIDs Y MyUnifyIDs}|{UnifyIDs Ys MyUnifyIDs}
	 else X = {UnifyIDsAux ScoreSpec MyUnifyIDs}
	 end
	 {ForAll {Dictionary.items MyUnifyIDs} CloseFC}
      end
      %% in   
      %%
      proc {CloseFC R}
	 {Length {RecordC.reflectArity R}} = {RecordC.width R}
      end
      fun {MakeScoreAux ScoreSpec Constructors MyItemIDs}
	 case ScoreSpec of Y|nil
	 then {MakeScoreAux Y Constructors MyItemIDs}|nil
	 [] Y|Ys
	 then {MakeScoreAux Y Constructors MyItemIDs}
	    | {MakeScoreAux Ys Constructors MyItemIDs}
	 else {MakeExplicitScore ScoreSpec Constructors MyItemIDs}
	 end
      end
      proc {CloseScoreHierarchy Score}      
	 case Score of X|nil
	 then {CloseScoreHierarchy X}
	 [] X|Xs
	    %% !! score must only be close once, but in case list contains
	    %% non-linked scores we traverse list anyway
	 then {CloseScoreHierarchy X} {CloseScoreHierarchy Xs}
	 else {Score closeScoreHierarchy(mode:graph)}
	 end
      end
      proc {InitDomains Score}
   %{Inspect initDomains#1}
	 case Score of X|nil
	 then {InitDomains X}
	 [] X|Xs
	    %% !! score traversing possibly overdone
	 then {InitDomains X} {InitDomains Xs}
	 else
	    {Score initDomains}	% ?? I only create items by MakeScore 
	    if {Score isTimeMixin($)}
	    then thread {Score constrainTiming} end
	    end
	    %% forAllThreaded, because score hierarchy becomes closed
	    %% only later
	    {Score forAll(mode:graph test:isItem
			  proc {$ X}
			     {X initDomains} 
			     if {X isTimeMixin($)}
			     then thread {X constrainTiming} end
			     end
			  end)}
	 end
      end
      proc {UnifyAllTimeUnits MyScore}
	 case MyScore of X|nil
	 then {UnifyAllTimeUnits X}
	 [] X|Xs
	 then {UnifyAllTimeUnits X} {UnifyAllTimeUnits Xs}
	 else
	    TimeMixins = {Append
			  if {MyScore isTimeMixin($)}
			  then [MyScore]
			  else nil
			  end
			  {MyScore collect($ mode:graph test:isTimeMixin)}}
	    Unit
	 in
	    if TimeMixins\=nil
	    then 
	       Unit = {TimeMixins.1 getTimeUnit($)}
	       {ForAll TimeMixins.2
		proc {$ X}
		   {X getTimeUnit($)} = Unit
		end}
	    end
	 end
      end
   in
      /** %% InitScore is an auxilary procedure to finish the initialisation of score hierarchies created by MakeScore2 and combined by the method bilinkItems or bilinkContainers. Using InitScore directly on the result of MakeScore2 is the same as generating a score by MakeScore.
      %% */
      proc {InitScore X}
	 {CloseScoreHierarchy X}
	 {InitDomains X}
	 {UnifyAllTimeUnits X}
      end
      /** %% MakeScore2 is a variant of MakeScore with the same arguments and the same functionality. However, the implicit initialisation of MakeScore2 is unfinished, such that the returned score hierarchy can still be extended (use the method bilinkItems or bilinkContainers to combine multiple score hierarchy parts created with MakeScore2). After the extention of the score, the score must be fully initialised (using InitScore). See strasheela/testing/ScoreCore-test.oz for an example.
      %% */
      proc {MakeScore2 ScoreSpec Constructors ?X}
	 MyItemIDs = {Dictionary.new}
	 MyUnifyIDs = {Dictionary.new}
      in
	 X = {MakeScoreAux {UnifyIDs ScoreSpec MyUnifyIDs} Constructors MyItemIDs}
      end
      /** %% MakeScore returns an object-oriented hierarchic score representation according to a record-based score representation in ScoreSpec. In general, MakeScore transforms (possibly nested) class init records into (nested) class instances with bi-directional links (e.g. links from the container to the contained item and vice-versa). The label of each init record specifies its class, e.g.,
      %%<code>{Score.makeScore note(startTime:0) unit}}</code>
      %%
      %% The argument Constructors allows to specify additional or alternative classes or arbitrary unary constructor functions. Constructors is a record with either the label unit or add, where the label unit means overwrite all defaults and add allows you to add classes/constructures to the defaults. Features of Constructors correspond to the labels of score object specifications in ScoreSpec. For example, the following expression returns an instance of the class MyNote.
      %%<code>{Score.makeScore note(startTime:0) unit(note:MyNote)}}</code>
      %%
      %% A nested score hierarchy is expressed by specifying further init record lists at the feature items or containers, e.g.,
      %%<code>{Score.makeScore seq(items:[note note] startTime:0) unit}}</code>
      %%
      %% Score objects can be marked with an id. Score graphs can be formulated by referring to the same score object with the same id multiple times 
      <code>{Score.makeScore sim(items:[note(containers:[aspect(id:1 info:test)]
					     duration:1)
					note(containers:[aspect(id:1)]
					     duration:2)])
	     unit}</code>
      %%
      %% To express a more complex graph, ScoreSpec can also be a list of nested init records with shared ids, e.g.,
      <code>{Score.makeScore [aspect(id:1 info:bla)
			      aspect(items:[note(info:x containers:[aspect(id:1)])
					    note(info:y)])]
	     unit}</code>
      %%
      %% However, references using ids must not be recursive (e.g. within the declaration of a container with an id must be not references to that id).
      %%
      %% A recommended alternative to formulate score graphs is to use multiple MakeScore2 calls which are combined (using bilinkItems or bilinkContainers) and only then fully initialised using InitScore). 
      %%
      %% Internally, MakeScore uses the init method of each class and all arguments the respective init method understands are supported by MakeScore. However, MakeScore performs also additional initialisation. This initialisation includes establishing inter-class instance relations correctly, closing the score hierarchy (which binds the tails of all slots items, containers and parameters for all items to nil), initialising all parameter values to FD variables, imposing timing constraints on all time mixings, and unifying all time units.
      %%
      %% An already instatiated score object (created with Score.makeScore2, i.e. with an unclosed hierarchy) can be specified at any place an score object record (label representing object class and features init method arguments) is possible.
      %%
      %% It is strongly recommended to use MakeScore to create a score instead of using the init method of the score classes directly, because MakeScore encapulates all necessary low-level details of the score representation.
      %% */
      proc {MakeScore ScoreSpec Constructors ?X}
	 {MakeScore2 ScoreSpec Constructors ?X}
	 {InitScore X}
      end
   end


 
   local
      fun {CopyVars R}
	 if {IsFree R}
	 then _
	 elseif {FD.is R}
	 then {FD.int {FD.reflect.dom R}}
	 elseif {GUtils.isFS R}
	 then {FS.var.bounds
	       {FS.reflect.lowerBound R} {FS.reflect.lowerBound R}}
% 	 elseif {IsCell}
% 	 then
% 	 elseif {IsObject}
% 	 then
% 	 elseif {IsDirectionary}
% 	 then
	 elseif {IsRecord R}
	 then {Record.map R CopyVars}
	 else R
	 end
      end
   in
      /** %% Like CopyScore, but MyScore is not fully initialised (cf. MakeScore2 vs. MakeScore).
      %% */ 
      fun {CopyScore2 MyScore}
	 {MakeScore2 {CopyVars {MyScore toInitRecord($ exclude:nil)}}
	  {MyScore getInitClasses($)}}
      end
      /** %% CopyScore returns a deep copy of MyScore. The resulting MyCopy has the same score topology and its objects are created from the same classes as MyScore. However, undetermined variables in MyScore are replaced by fresh variables with the same domain. 
      %% NB: CopyScore internally uses toInitRecord. Therefore, all present restrictions of toInitRecord apply: getInitInfo must be defined correctly for all classes and only tree-form score topologies are supported.
      %% !!! NB: if the output of toInitRecord contains stateful data, then this data is not copied but used as is (i.e. such stateful data is shared between the copies). 
      %% */
      %% !! could I use copying functionality defined for spaces instead to make implementation more stable without dependency on getInitInfo?
      proc {CopyScore MyScore ?MyCopy}
	 {CopyScore2 MyScore MyCopy}
	 {InitScore MyCopy}
      end
   end
   
   /** %% Returns a container of ContainerClass containing Items. Args is a record of optional container init arguments.
   %% A MakeContainer call may specify more container init-arguments than specified as default arguments.
   %% The Items must still combinable with other score items, i.e. they must not be fully initialised (e.g. created by MakeScore2). Also the container returned by MakeContainer is  still combinable with other score items, i.e. in the end the score must be initialised by InitScore.
   %% */
   proc {MakeContainer ContainerClass Items Args ?MyScore}
      Defaults = unit(%info:bla	% platzhalter
		      %offsetTime:0
		      %startTime:{FD.decl}
		      %duration:{FD.decl}
		      %endTime:{FD.decl}
		      %% !! was bug, but now it probably breaks some
		      %% example outs
		      %timeUnit:_ %beats(8)
		      %chordStartMarker:0 % no marker
		      %numChannels:2
		      %effect:nil
		      %effectArgs:nil
		      %% list of unary procs
		      rules:[proc {$ X} skip end]
		      containerClass:Sequential)
      ActualArgs = {Adjoin Defaults Args}
   in
      MyScore = {New ContainerClass
		 {Adjoin {Record.subtractList ActualArgs
			  [rules containerClass]}
		  init}}
      {MyScore bilinkItems(Items)}
      thread			% unclosed hierarchy...
	 {{GUtils.procs2Proc ActualArgs.rules} MyScore}
      end
   end
   %%  For Args see Defaults in MkContainer.
   %% The Items must still combinable with other score items, i.e. they must not be fully initialised (e.g. created by MakeScore2). Also the container returned by MakeContainer is  still combinable with other score items, i.e. in the end the score must be initialised by InitScore.
   fun {MakeSim Items Args} {MakeContainer Simultaneous Items Args} end
   %%  For Args see Defaults in MkContainer.
   %% The Items must still combinable with other score items, i.e. they must not be fully initialised (e.g. created by MakeScore2). Also the container returned by MakeContainer is  still combinable with other score items, i.e. in the end the score must be initialised by InitScore.
   fun {MakeSeq Items Args} {MakeContainer Sequential Items Args} end
   

%    local
%       proc {ResolveRepeatsAux ScoreSpec ?X}
% 	 ScoreSpec1 X1 
%       in
% 	 case ScoreSpec 
% 	 of Y#N then
% 	    ScoreSpec1 = Y
% 	    X = {LUtils.collectN N fun {$} X1 end}
% 	 else
% 	    ScoreSpec1 = ScoreSpec
% 	    X = [X1]
% 	 end   
% 	 X1 = {Record.clone ScoreSpec1}
% 	 {Record.forAllInd {Record.subtractList ScoreSpec1 [containers items]}
% 	  proc {$ Feat _} X1.Feat = ScoreSpec1.Feat end}
% 	 if {HasFeature ScoreSpec1 containers}
% 	 then X1.containers = {LUtils.mappend ScoreSpec1.containers ResolveRepeatsAux}
% 	 end
% 	 if {HasFeature ScoreSpec1 items}
% 	 then X1.items = {LUtils.mappend ScoreSpec1.items ResolveRepeatsAux}
% 	 end
%       end
%    in
%       % [!! ?? unfinished conceptually] Util for MakeScore. Transforms a short hand score representation with repeat signs into the full representation for MakeScore. A repeat sign (<code>#</code>) may appear after any ScoreSpec denoting an item using the form <code>ScoreSpec#N</code>.
%       %% Restriction:
%       %% Items are literally repeated. Therefore, items with ID are literally copied and all repeatitions result in 'unified' objects.
%       % 
%       fun {ResolveRepeats ScoreSpec}
% 	 {ResolveRepeatsAux ScoreSpec}.1
%       end
%    end

   
   /** %% MakeClass returns a subclass of the (score object) class Super. FeatT is a tuple with the additional subclass features, the label of FeatT defines the value at the feature 'label' of the new class. Args supports optional arguments, the defaults are:
   unit(initRecord:init
	init:proc {$ Self Args} skip end)
   %% Args.initRecord specifies additional arguments for the init method of the class and optionally their default value. For instance, <code> init(x:1 y) </code> defines the two additional arguments x and y and the default value 1 for x.
   %% Args.init defines a binary procedure which is called at the end of the initialisation of a class instance. The two arguments Self and Args are the initialised object and the record of initialisation arguments (i.e. for each Args feature either the specified default or the value handed the the init method).
   %%
   %% NB: MakeClass allows only to define additional features (i.e. no attributes) [NB: this behaviour is inconsistent with other class definitions in Strasheela. Nonetheless, that way feature accessors are defined implicitly].
   %%
   %% NB: Classes generated by MakeClass will not be documented automatically by ozh.
   %%
   %% Example: define a note subclass with an additional parameter foo (init method arg foo defaults to 0):
   {MakeClass Score.note
    newNote(foo fooParameter)
    unit(initRecord:newNote(foo:0)
	 init:proc {$ Self Args}
		 Self.fooParameter = {New Score.parameter init(value:Args.foo info:foo)}
		 Self.foo = {Self.fooParameter getValue($)}
		 {Self bilinkParameters([Self.fooParameter])}
	      end)}
   %% */
   %% !!?? Super is only a single class, i.e., no mixins: otherwise the mixin inits must be called explicitly, the init args for the mixins must be filtered out from the init method for Super...
   fun {MakeClass Super FeatT Args}
      Defaults = unit(initRecord:init
		      init:proc {$ Self Args} skip end)
      As = {Adjoin Defaults Args}
%      Feats = {Record.toList FeatT}
      InitFeats = {Map {Record.toListInd As.initRecord}
		   fun {$ I#X}
		      if {IsNumber I}
		      then X
		      else I
		      end
		   end}
      InitDefaults = {Record.filterInd As.initRecord
		      fun {$ I X}
			 {Not {IsNumber I}}
		      end}
   in
      %% !!?? is there no way to define in a single def (a) more features and (b) adjust the defs of methods
      class $ from {Class.new [Super] nil FeatT nil} 
	 feat label:{Label FeatT}
	 meth init(...) = M
	    FullM = {Adjoin InitDefaults M} 
	 in
	    Super, {Record.subtractList FullM InitFeats} % ?? Feats
	    {ForAll InitFeats
	     proc {$ Feat}
		if {HasFeature FullM Feat}
		then self.Feat = FullM.Feat
		end
	     end}
	    {As.init self FullM}
	 end
%	 meth getFeatures(?X)
%	    X = {Append
%		 Super, getFeatures($)
%		 Feats}
%	 end
% 	 meth toInitRecord(?X exclude:Excluded<=nil)
% 	    X = {Adjoin
% 		 Super, toInitRecord($ exclude:Excluded)
% 		 {Record.subtractList
% 		  {self makeInitRecord($ {Map InitFeats
% 					  fun {$ Feat}
% 					     InitVal = if {HasFeature InitDefaults Feat}
% 						       then InitDefaults.Feat
% 						       else noMatch
% 						       end
% 					  in
% 					     Feat#fun {$ X} X.Feat end#InitVal
% 					  end})}
% 		  Excluded}}
% 	 end
	 
	 meth getInitInfo($ exclude:Excluded)
	    unit(superclass:Super
		 args:{Map InitFeats
		       fun {$ Feat}
			  InitVal = if {HasFeature InitDefaults Feat}
				    then InitDefaults.Feat
				    else noMatch
				    end
		       in
			  Feat#fun {$ X} X.Feat end#InitVal
		       end})
	 end
      end
   end

end

