
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

%% TODO:
%%
%% * Define comprehensive set of temporal relations
%%   Allen's Interval Algebra (e.g., see http://en.wikipedia.org/wiki/Allen%27s_Interval_Algebra)
%%   -> would be easy to do, but do I actually need that? 
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
   SMapping at 'ScoreMapping.ozf'
   Out at 'Output.ozf'
   % Pattern at 'Pattern.ozf'
   % Applicator at 'RuleApplicator.ozf'
   Browser(browse:Browse) % temp for debugging
   %Ozcar % temp for debugging
   %% NOTE: dependency on contribution
   Fenv at 'x-ozlib://anders/strasheela/Fenv/Fenv.ozf'
export
   % classes: 
   ScoreObject Parameter TimeParameter TimePoint TimeInterval Amplitude Pitch
   LeaveUninitialisedParameterMixin IsLeaveUninitialisedParameter
   Item Container Modifier Aspect TemporalAspect Sequential Simultaneous 
   Element AbstractElement TemporalElement Pause Event Note2
   MakeArticulationClass IsArticulationMixin MakeAmplitudeClass IsAmplitudeMixin
   Note
   % funcs/procs
   IsScoreObject IsTemporalItem IsTemporalContainer
%  IsET GetPitchesPerOctave
   MakeScore MakeScore2 InitScore
   make: MakeScore
   make2: MakeScore2
   CopyScore CopyScore2
   copy: CopyScore
   copy2: CopyScore2
   init: InitScore
   TransformScore TransformScore2
   transform: TransformScore
   transform2: TransformScore2
   GetDefaults
   MakeConstructor
   MakeItems MakeItems_iargs MakeContainer MakeSim MakeSeq
   DefSubscript DefMixinSubscript ItemslistToContainerSubscript
   % ResolveRepeats
   MakeClass

   apply_H: Apply_Heuristic

   AtTimeR AtTimeR2
   InTimeframe InTimeframeOffset InTimeframeOffset2
   InTimeframeR InTimeframeOffsetR InTimeframeOffset2R
   GetItemsInTimeframe GetItemsInTimeframeOffset GetItemsInTimeframeOffset2
   
prepare
   /** marker of score object type checking */
   %% Defined in 'prepare' to avoid re-evaluation.
   ScoreObjectType = {Name.new}
   ArticulationMixinType = {Name.new}
   AmplitudeMixinType = {Name.new}
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

   
   /** %% [abstract class] Defines reflection capabilities for objects. Please note: this class uses undocumented Oz features, which are possibly not intended for Oz end users ;-) 
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
      %% TODO: I cannot get method arguments
      meth getMethNames($)
	 {Dictionary.keys {self getClass($)}.{Boot_Name.newUnique 'ooMeth'}}
      end
%       /* %% Alias for getMethNames.
%       %% */
%       meth getMethods($) {self getMethNames($)} end
      /* %% [TODO] Get the default arguments of the initialisation method... 
      %% */
%      meth getInitArgs($) 
%      end
      
      /** %% Returns a record where the features are all supported arguments of the init method of self with their default as value ('_' indicates that no default exist). This method is useful, e.g., for automatic documentation of all the arguments supported by the init method of a certain class (but the method must be send to a class instance).
      %%
      %% NB: this method relies on the correct implementation of the method getInitArgs for its class and all its superclasses. 
      %% */
      meth getInitArgDefaults($)
	 Excluded = nil
	 fun {TransformArgs Args}
	    {Map Args fun {$ Arg#_#Init}
	 		 if Init==noMatch
	 		 then Arg#'_'
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
		{TransformArgs Args}
	       }
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
% 	     {System.showInfo "Warning: setting "#{Value.toVirtualString self 100 100}#"'s attribute "#Attr#" directly to "#{Value.toVirtualString X 100 100}#". Possibly, this attribute does not exist in this object!"}
	     {System.showInfo "Warning: method init for creating an object with label "#self.label#": ignored arg "#Attr#" with value "#{Value.toVirtualString X 100 100}}
	     %% Note: removed direct setting of attributes
% 	     @Attr = X
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
      /** %% [destructive method, for experts only] Statefully sets the value of parameter Param to value X (there must be an attribute Param). Remember that the search itself is indented to be fully stateless.
      %% */
      meth setParameterValue(Param X)
	 {@Param setAttribute(value X)}
      end
      /** %% [destructive method] Adds X to list in attribute info. The tail of the list at attribute info is the info that was specified before with addInfo and was give at the init method (default is nil).
      %% */
      meth addInfo(X)
	 info <- X | @info
      end
      /** %% [destructive method] Adds every element in list Xs to list in attribute info. 
      %% */
      meth addInfos(Xs)
	 {ForAll Xs proc {$ X} {self addInfo(X)} end}
      end  
      /** %% Returns boolean whether the list at the attr info of self contains Info. In case some info value is a record, then it is checked whether its label is Info.
      %% */
      meth hasThisInfo(?B Info)
	 B = ({List.some {self getInfo($)}
	       fun {$ X}
		  if {GUtils.isRecord X}
		  then {Label X} == Info
		  else X == Info
		  end
	       end})
      end
      /** %% Returns first record with label L in the list in attribute info.
      %% */
      meth getInfoRecord($ L)
	 {LUtils.find {self getInfo($)}
	  fun {$ X} {GUtils.isRecord X} andthen {Label X} == L end}
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
      %% !!?? should this method be turned into a local proc: it should only be called by toInitRecord... No, some subclasses make use of it in their toInitRecord def
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
% % 	    elseif {GUtils.isRecord Val}
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
      %% Clauses is a list of pairs TestI#FunI which can be used to overwrite the default init record creation (defined by the class' method getInitInfo) of specific score objects. TestI is a Boolean function or method, and FunI is a unary function expecting a score object and returning a record. For each object for which some TestI returns true, the corresponding FunI will be used for creating the init records for this object.
      %%
      %% NB: toInitRecord depends on correct definitions of the method getInitInfo for all subclasses with specific inialisiation arguments.
      %%
      %% NB: toInitRecord presently only works properly for tree-form score topologys (e.g. score graphs are not supported yet).
      %% **/
      %% !!?? should this method (and everything related) move into Item?
      meth toInitRecord($ exclude:Excluded<=DefaultInitRecordExcluded
			clauses:Clauses<=nil)
	 fun {Aux unit(superclass:Super args:Args)}
	    if Super == nil
	    then {Record.subtractList {self makeInitRecord($ Args)}
		  Excluded}
	    else
	       {Adjoin
		{Aux (Super, getInitInfo($ exclude:Excluded clauses:Clauses))}
		{Record.subtractList {self makeInitRecord($ Args)}
		 Excluded}}
	    end
	 end
	 Clause = {LUtils.find Clauses fun {$ Test#_} {{GUtils.toFun Test} self} end}
      in
	 %% 
	 if Clause == nil then
	    {Aux {self getInitInfo($ exclude:Excluded clauses:Clauses)}}
	 else _#Fun = Clause in {Fun self}
	 end
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
      %% The information returned by getInitInfo has the following form:
      
      unit(superclass:Super
	   args:[Argument1#Accessor1#Default1
		 ...
		 ArgumentN#AccessorN#DefaultN])
      
      %% Super is a single superclass of self which defines/inherits a method getInitInfo extending the present method definition (can be nil in case of no superclass). Argument is an init method argument (an atom), Accessor is a unary accessor function or method returning the value of the object corresponding with Argument, and Default is the default value or 'noMatch' if no default value was given. Excluded is the same arg as for toInitRecord: this argument is only required if getInitInfo recursively calls toInitRecord. A typical getInitInfo definition follows
      %%
      %% Args: getInitInfo($ excluded: Excluded clauses: Clauses)
      %% The defaults of both arguments should be nil, but this can be overwritting in principle in subclasses.
      %% 
      %% Excluded is a list of arguments (atoms) which must be excluded concurrently.
      %% Clauses is a list of pairs TestI#FunI which can be used to overwrite the default init record creation (defined by the class' method getInitInfo) of specific score objects. TestI is a Boolean function or method, and FunI is a unary function expecting a score object and returning a record. For each object for which some TestI returns true, the corresponding FunI will be used for creating the init records for this object.
      %%
      meth getInitInfo($ ...)
	 unit(superclass:MySuperClass
	      args:[myParameter#getMyParameter#noMatch])
      end
      
      %% */
      %% !!?? should this method (and everything related) move into Item?
      meth getInitInfo($ ...)
	 unit(superclass:nil
	      args:[info#fun {$ X}
			    %% @info binds a list so it can contain multiple information. Nevertheless, a single info is given to the init method without surrounding list..
			    MyInfo = {X getInfo($)}
			 in
			    if {IsList MyInfo} andthen {Length MyInfo} == 1
			    then MyInfo.1
			    else MyInfo
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
			 orelse {GUtils.isRecord Val}
		      end}}
		fun {$ Feat#Val}
		   if {GUtils.isRecord Val}
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
	 {Out.recordToVS_simple
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
      %%
      %% Args: 
      %% 'exclude' (default nil): list of attribute names (list of atoms) recursively excluded in the output.
      %% 'unbind' (default nil): list of attribute names (list of atoms) which are output, but whose value is set to a free variable.
      %%
      %% !! Temp: The attributes 'item' and 'containers' are always excluded to avoid endless loops. Therefore, score graphs with items having more then a single container can not be shown.
      %% */
      meth toFullRecord(?X exclude:Exclude<=nil unbind:Unbind<=nil)
	 fun {GetProperVal Val}
	    if {Not {IsDet Val}}
	    then Val
	    elseif {IsScoreObject Val}
	    then {Val toFullRecord($ exclude:Exclude unbind:Unbind)}
	    elseif {LUtils.isExtendableList Val}
	    then {Map Val.list fun {$ X}
				  {X toFullRecord($ exclude:Exclude unbind:Unbind)}
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
	       fun {$ I A} 
		  if {Not {Member I Unbind}} then
		     {GetProperVal @I}
		  else _
		  end
	       end}
	      {Record.mapInd Feats
	       fun {$ I A} 
		  if {Not {Member I Unbind}} then
		     {GetProperVal self.I}
		  else _
		  end
	       end}}
      end
%       %% Outputs the object as a record with the the object lable as record label  and with all its attributes as record features. 
%       
%       meth toFullRecord(?X exclude:Exclude<=nil)
% 	 X = {self toFullRecordAux($ exclude:Exclude)}
%       end

      /** %% Effectively unifies self and ScoreObject. This method is useful for constraining various forms of repetitions. Stateful data (including class instances) can not be unified in Oz. So, unify transforms self and ScoreObject to records (using toFullRecord) and unifies those records. 
      %%
      %% Args:
      %% 'exclude' (default [startTime endTime]): list of attribute names (list of atoms) to ignore, see arg 'exclude' for toFullRecord. (The internal attributes 'parameters' and 'flags' are always excluded.)
      %% 'overwrite' (default nil): list of attribute names (list of atoms) to keep as declared in self (i.e. the setting in ScoreObject is quasi overwritten).
      %% 'derive' (default nil): for unifying derived score information (e.g., exclude the pitches, but unify pitch intervals, see example below). List of unary functions expecting the full score (self or ScoreObject) and returning a data structure to unify.
      %%
      %% Example:
      {Score1 unify(Score2
		    exclude:[pitch]
		    derive:[proc {$ MyScore Intervals}
			       Ps = {MyScore mapItems($ getPitch)}
			    in
			       Intervals = {Pattern.map2Neighbours Ps
					    proc {$ P1 P2 ?Interval}
					       Interval = {FD.decl}
					       P2 - P1 + 100000 =: Interval
					    end}
			    end])}
      %% NB: only works properly for tree-form score topologys (because of limitation of toFullRecord). 
      %% */ 
      meth unify(ScoreObject
		 overwrite:Overwrite<=nil
		 exclude:Exclude<=[startTime endTime]
		 derive:Derive<=nil)
	 % the flags attribute is only for internal use and is bound to some stateful data structure..
	 {self toFullRecord($ exclude:flags|parameters|Exclude)}
	 = {ScoreObject toFullRecord($ exclude:flags|parameters|Exclude
				     unbind: Overwrite)}
	 {ForAll Derive proc {$ P} {P self} = {P ScoreObject} end}
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
      meth getPerformanceEndTimeInSeconds(?X)
	 if {IsArticulationMixin self} 
	 then X = {self getStartTimeInSeconds($)} + {self getPerformanceDurationInSeconds($)}
	 else X={@endTime getValueInSeconds($)}
	 end
      end
      meth getDurationInSeconds($) {self getEndTimeInSeconds($)} - {self getStartTimeInSeconds($)} end
      /** %% The performance duration takes articulation (duration percentage) into account.
      %% */
      meth getPerformanceDurationInSeconds($)
	 if {IsArticulationMixin self} 
	 then 
	    ({self getEndTimeInSeconds($)} - {self getStartTimeInSeconds($)})
	    * {IntToFloat {self getArticulation($)}} / 100.0
	 else {self getEndTimeInSeconds($)} - {self getStartTimeInSeconds($)}
	 end
      end
%       meth getDurationInSeconds(?X) X={@duration getValueInSeconds($)} end
      meth getOffsetTimeInSeconds(?X)
	 %% BUG: no dependency to tempo curve or time shift function defined yet, depends on type of container, cf def for getDurationInSeconds
	 {Browse warning(getOffsetTimeInSeconds self possibly incorrect)}
	 X={@offsetTime getValueInSeconds($)}
      end
      meth getStartTimeInBeats(?X) X={@startTime getValueInBeats($)} end
      meth getEndTimeInBeats(?X) X={@endTime getValueInBeats($)} end
      meth getPerformanceEndTimeInBeats(?X)
	 if {IsArticulationMixin self} 
	 then X = {self getStartTimeInBeats($)} + {self getPerformanceDurationInBeats($)}
	 else X={@endTime getValueInBeats($)}
	 end
      end
      meth getDurationInBeats(?X) X={@duration getValueInBeats($)} end
      /** %% The performance duration takes articulation (duration percentage) into account.
      %% */
      meth getPerformanceDurationInBeats($)
	 if {IsArticulationMixin self} 
	 then 
	    ({self getEndTimeInBeats($)} - {self getStartTimeInBeats($)})
	    * {IntToFloat {self getArticulation($)}} / 100.0
	 else {self getEndTimeInBeats($)} - {self getStartTimeInBeats($)}
	 end
      end
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
      %% This relation defines a conjunction of the following Allen's Interval Algebra relations: overlaps, starts, during, finishes and equal; only meets and before/after are excluded.
      %%*/  
      %% @1=?B
      meth isSimultaneousItem(?B X)
	 B = {InTimeframe X {self getStartTime($)} {self getEndTime($)}}
      end
      /** %% [Deterministic method] Generalised version of isSimultaneousItem where the offset time Offset is taken into account (see InTimeframeOffset).
      %% */
      meth isSimultaneousItemOffset(?B X Offset)
	 B = {InTimeframeOffset X {self getStartTime($)} {self getEndTime($)} Offset}
      end
      /** % [0/1 Constraint] Returns 0/1-integer whether self and X are simultaneous in time (i.e. somehow overlap in time).
      %% This relation defines a conjunction of the following Allen's Interval Algebra relations: overlaps, starts, during, finishes and equal; only meets and before/after are excluded.
      %% */
      %% @1=?B
      meth isSimultaneousItemR(?B X)
	 B = {InTimeframeR X {self getStartTime($)} {self getEndTime($)}}
      end
      /** %% [0/1 Constraint] Generalised version of isSimultaneousItemR where the offset time Offset is taken into account.
      %% */
      meth isSimultaneousItemOffsetR(?B X Offset)	% ?? method name
	 B = {InTimeframeOffsetR X {self getStartTime($)} {self getEndTime($)} Offset}
      end			
      /** % [0/1 Constraint] Returns 0/1-integer whether self and X are exactly simultaneous in time (i.e. start and end at the same time).
      %% This relation defines the Allen's Interval Algebra relation equal.
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
      /** % [Deterministic method] Returns list of score items simultaneous to self and fulfilling the optional Boolean function or method test.
      %% If a toplevel Top (a temporal container) is given, then only within that container is searched for simultaneous items to self. Otherwise the temporal top-level of self is searched (i.e. usually the whole score).
      %% See the documentation of GetItemsInTimeframe for further details (e.g., on the argument cTest).
      %%*/
      %% @1=?Xs	
      meth getSimultaneousItems(?Xs test:Test<=fun {$ X} true end
				cTest: CTest<=fun {$ X} true end
				toplevel: Top<=false)
	 TopLevel = if Top \= false
		    then Top
		    else {self getTopLevels($ test:fun {$ X} {X isTimeMixin($)} end)}.1
		    end
	 ScoreObjects = {TopLevel collect($ test: fun {$ X}
						     X \= self andthen
						     %% only test items further
						     {X isItem($)} andthen
						     {{GUtils.toFun Test} X}
						  end)}
      in
	 Xs = {GetItemsInTimeframe ScoreObjects
	       {self getStartTime($)} {self getEndTime($)}
	       unit(cTest: {GUtils.toFun CTest})}
      end
      /** %% [Deterministic method] Generalised version of getSimultaneousItems where the offset time of self is taken into account. See the doc of InTimeframeOffsetR for the meaning of the Offset.
      %% */
      meth getSimultaneousItemsOffset(?Xs 
				      test:Test<=fun {$ X} true end
				      cTest: CTest<=fun {$ X} true end
				      toplevel: Top<=false)
	 TopLevel = if Top \= false
		    then Top
		    else {self getTopLevels($ test:fun {$ X} {X isTimeMixin($)} end)}.1
		    end
	 ScoreObjects = {TopLevel collect($ test: fun {$ X}
						     X \= self andthen
						     %% only test items further
						     {X isItem($)} andthen
						     {{GUtils.toFun Test} X}
						  end)}
      in
	 Xs = {GetItemsInTimeframeOffset ScoreObjects
	       {self getStartTime($)} {self getEndTime($)} {self getOffsetTime($)}
	       unit(cTest: {GUtils.toFun CTest})}
      end
      
      /** %% [Deterministic method] Generalised version of getSimultaneousItems where the offset time of self and also of the returned items are taken into account. See the doc of InTimeframeOffset2R.
      %% */
      meth getSimultaneousItemsOffset2(?Xs 
				      test:Test<=fun {$ X} true end
				      cTest: CTest<=fun {$ X} true end
				      toplevel: Top<=false)
	 TopLevel = if Top \= false
		    then Top
		    else {self getTopLevels($ test:fun {$ X} {X isTimeMixin($)} end)}.1
		    end
	 ScoreObjects = {TopLevel collect($ test: fun {$ X}
						     X \= self andthen
						     %% only test items further
						     {X isItem($)} andthen
						     {{GUtils.toFun Test} X}
						  end)}
      in
	 Xs = {GetItemsInTimeframeOffset2 ScoreObjects
	       {self getStartTime($)} {self getEndTime($)} {self getOffsetTime($)}
	       unit(cTest: {GUtils.toFun CTest})}
      end

      /** %% [Deterministic method] Returns the first score object found which is simultaneous to self and fulfilling the optional boolean function or method test.
      %% If a toplevel Top (a temporal container) is given, then only within that container is searched for simultaneous items to self. Otherwise the temporal top-level of self is searched (i.e. usually the whole score).
      %% The implementation uses LUtils.cFind and the reified constraints method isSimultaneousItemR. X is return as soon as the score contains enough information to tell for any score object that it is simultaneous to self (i.e. rhythmic structure of the whole score must not necessarily be fully determined). 
      %% NB: Test must be a deterministic function/method which does not block (e.g., checks on score object types or their position in the score topology are OK) and which is used for pre-filtering score objects. The argument cTest has the same format (optional Boolean function or method), but it is applied within the concurrent filtering of LUtils.cFilter, together with isSimultaneousItemR. Computationally very expensive tests and in particular tests which can block are better handed to cTest. 
      %% */
      %% TODO:
      %% - Revise by finishing and exporting the definition of FindItemInTimeframe below
      %% - ?? Add definitions FindItemInTimeframeOffset and findSimultaneousItemOffset
      meth findSimultaneousItem(?X test:Test<=fun {$ X} true end
				cTest: CTest<=fun {$ X} true end
				toplevel: Top<=false)
	 thread 		% ?? NOTE: thread needed?
	    TopLevels = if Top \= false
		       then [Top]
		       else {self getTopLevels($ test:fun {$ X} {X isTimeMixin($)} end)}
		       end
	 in
	    if TopLevels == nil
	    then X = nil
	    else 
	       TopLevel = TopLevels.1
	       ScoreObjects = {TopLevel collect($ test:Test)}
	    in
	       X = {LUtils.cFind ScoreObjects
		    fun {$ X}
		       X \= self andthen
		       {X isItem($)} andthen
		       ({self isSimultaneousItemR($ X)} == 1) andthen
		       {{GUtils.toFun CTest} X}
		    end}
	    end
	 end
      end

      
   end			% class
   
      
   /** %% [semi abstract class] Musical parameters are the basic magnitudes in a music representation; examples are the parameters duration, amplitude and pitch, which add information to a note. A parameter is represented by an own class (i.e. not just as a feature/attribute of a score item, as in most other composition environments) to allow the expression of additional information on the parameter besides the actual parameter value. For instance, a single numeric value for a pitch is ambitious, it could express a frequency, a MIDI-keynumber, MIDI-cents, a scale degree etc. Therefore, a parameter allows to specify the unit of measurement explicitly.
   %% The parameter attributes value and 'unit' specify the parameter setting and the unit of measurement. The attribute item points to the score item the parameter belongs to.
   %% PS: The attribute 'unit' is mainly used for output.
   %%*/
   %% Was doc: Because of limitations of the FD constraints in Oz, the parameter value is limited to integer values (planned: fractions). However, these values can be mapped to arbitrary other data (e.g. midicent integer to frequency float).
   class Parameter from ScoreObject % SMapping.flagsMixin
      feat %'class': Parameter
	 label: parameter
      attr item value 'unit' heuristics
      meth init(value:Value<=_ 'unit':Unit<=_ ...)=M
	 ScoreObject, {Record.subtractList M [value 'unit']}
	 @'unit' = Unit
	 @value = Value
	 @heuristics = nil
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
      /** %% Returns true if parameter value is determined, false otherwise.
      %% */
      meth isDet($) {IsDet @value} end

      /** %% Return the list of heuristic constraints applied to the parameter. A heuristic is a record of the following form (see the doc of getHeuristics for the meaning of the variables). 
      heuristic(constraint:Constraint parameters: Params weight:Weight)
      %% Note: Instead of calling this method directly, better use Score.apply_H instead.
      %% */
      meth getHeuristics(?X) X=@heuristics end
      /** %% [destructive method] Adds a heuristic constraint to the parameter. Constraint is a heuristic constraint (a function expecting n integers and returning an integer), Params is the list of parameter objects to which the constraint is applied (including self), and Weight (int) is the weight of the constraint (the factor applied to it). 
      %% Note: Instead of calling this method directly, better use Score.apply_H instead.
      % */ 
      meth addHeuristic(constraint:Constraint parameters:Params weight:Weight<=1)
	 heuristics <- heuristic(parameters: Params constraint:Constraint weight:Weight) | @heuristics
      end


      /** %% Individual parameters cannot be created with Score.make and friends, so the notion of their init record is somewhat missleading. Nevertheless, it is useful to translate the essential parameter data into a concise "textual" representation.
      %% */
      meth getInitInfo($ ...)       
	 unit(superclass:ScoreObject
	      %% NOTE: skipped args heuristics (and item)
	      args:[value#getValue#noMatch
		    'unit'#getUnit#noMatch]) 
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


   /** %% Collect all temporal containers in which MyItem is contained, and which have a time shift function.
   %% */
   %% Possible efficiency issue:  the same search for time shift fenvs is done over and over. I may consider memoizing the found time shift functions for an item 
   fun {GetTimingFenvContainers MyItem}
      if MyItem == nil then nil
      elseif {IsTemporalContainer MyItem} andthen
% 	 (
	 {MyItem hasThisInfo($ timeshift)} % orelse {MyItem hasThisInfo($ tempo)})
      then MyItem | {GetTimingFenvContainers {MyItem getTemporalContainer($)}}
      else {GetTimingFenvContainers {MyItem getTemporalContainer($)}}
      end
   end
   %%
   /** %% Computes a transformation of MyTime which takes hierarchically nested time shift functions into account. MyItem is the score object to which MyTime belongs (e.g., MyItem is a note and MyTime is its start or end time). GetShiftedTime searches through all temporal containers of MyItem and applies all time shift functions found.
   %% MyTime is a float specified in seconds, and a time in second is return (a float). Nevertheless, the timeshift fenvs y-values are specified in the present timeUnit, and GetShiftedTime converts them to seconds.  
   %% */
   %%
   fun {GetShiftedTime MyTime MyItem MyParam}
%       IntegrationStep = 0.1  % approximation accuracy
      Cs = {GetTimingFenvContainers MyItem}
   in
      if Cs == nil then MyTime
      else
	 %%
	 %% Possible TODO -- add tempo curves (then uncomment code in GetTimingFenvContainers and below)
	 %%
% 	 %% multiply all tempo curves and integrate them to get performance time
% 	 %%
% 	 %% BUG - I cannot multiply the tempo curves directly -- they stem from different containers, and thus range over different time spans
% 	 %% 
% 	 %% So, find "top-level" container with tempo curve, and process the remaining tempo curves accordingly: I may specify that tempo curves are 1 for any time outside their range..x
% 	 %% Possible special case: if tempo curve belongs to a container situationed in a sequential container, then all tempo curves of the preceeding containers in the sequential container are also taken into account.
% 	 %% Otherwise a container with (only) a tempo curve (and no higher-level tempo curves) starts at score time (!)
% 	 TempoProcessedTime
% 	 = {Fenv.itemFenvY
% 	    {Fenv.integrate
% 	     %% TODO - access the actual fenvs
% 	     {Fenv.combineFenvs fun {$ Xs} {LUtils.accum Xs Number.'*'} end
% 	      {Filter Cs fun {$ C} {C hasThisInfo($ tempo)} end}}
% 	     IntegrationStep}
% 	    C MyTime}
% 	 %% sum all time shift values 
% 	 TimeShiftSum = {LUtils.accum
% 			 {Map {Filter Cs fun {$ C} {C hasThisInfo($ timeshift)} end}
% 			  fun {$ C}
% 			     {Fenv.itemFenvY {C getInfoRecord($ timeshift)}.1 C MyTime}
% 			  end}
% 			 Number.'+'}
%       in
% 	 TempoProcessedTime + TimeShiftSum
	 %%
	 %% Sum all time shift values and add them to MyTime
	 MyTime 
	 + {LUtils.accum
	    {Map Cs
	     fun {$ C} {Fenv.itemFenvY {C getInfoRecord($ timeshift)}.1 C MyTime} end}
	    Number.'+'}
      end
   end
   

   class TimeParameter from Parameter
      feat label: timeParameter
      meth isTimeParameter(?B) B=true end
      
      /** %% Returns the parameter value translated to a float representing seconds. The translation uses the parameter unit which must be bound (otherwise the method suspends). Supported units are (represented by these atoms): seconds/secs, milliseconds/msecs, and beats (a relative duration, e.g., a quarter note). The unit specification beats(N) means the parameter value of N is a single beat. beats(N) may be used to express tuplets, e.g., for beat(3) the value 1 means a third beat i.e. a triplet. N must be an integer and defaults to 1. The translation between seconds and beats uses Init.getBeatDuration.
      %%
      %% Additionally, hierachic tempo curves and time shift functions are taken into account.
      %% */
      meth getValueInSeconds(?X)
	 Unit = {self getUnit($)}
	 Value_Shifted
      in
	 %% NOTE: IsDet does not wait for binding -- quasi side effect. But most
	 %% often this is called for output and timeUnit is sometimes
	 %% forgotten by user...
	 if {Not {IsDet Unit}}
	 then {GUtils.warnGUI "unit of temporal parameter(s) unbound -- computation blocks!"}
	 end
	 Value_Shifted = if {IsInt {self getValue($)}}
			 then {GetShiftedTime {IntToFloat {self getValue($)}}
			       {self getItem($)}
			       self}
			    %% otherwise float
			 else {GetShiftedTime {self getValue($)} {self getItem($)} self}
			 end
	 X = case Unit
	     of beats then Value_Shifted * {Init.getBeatDuration}
	     [] beats(N) then Value_Shifted * {Init.getBeatDuration} / {IntToFloat N}
	     [] seconds then Value_Shifted
	     [] secs then Value_Shifted
	     [] milliseconds then Value_Shifted / 1000.0
	     [] msecs then Value_Shifted / 1000.0
	     [] secsF then Value_Shifted
	     [] msecsF then Value_Shifted / 1000.0
	     else
		{Exception.raiseError
		 strasheela(illParameterUnit Unit self
			    "Supported units are seconds (or secs), millisecond (or msecs), beats, and beats(N) (where N is an integer).")}
		unit		% never returned
	     end
      end

%       /** %% Returns the parameter value translated to a float representing seconds. The translation uses the parameter unit which must be bound (otherwise the method suspends). Supported units are (represented by these atoms): seconds/secs, milliseconds/msecs, and beats (a relative duration, e.g., a quarter note). The unit specification beats(N) means the parameter value of N is a single beat. beats(N) may be used to express tuplets, e.g., for beat(3) the value 1 means a third beat i.e. a triplet. N must be an integer and defaults to 1. The translation between seconds and beats uses Init.getBeatDuration.
%       %% */
%       meth getValueInSeconds(?X)
% 	 Unit = {self getUnit($)}
%       in
% 	 %% NOTE: IsDet does not wait for binding -- quasi side effect. But most
% 	 %% often this is called for output and timeUnit is sometimes
% 	 %% forgotten by user...
% 	 if {Not {IsDet Unit}}
% 	 then {GUtils.warnGUI "unit of temporal parameter(s) unbound -- computation blocks!"}
% 	 end
% 	 %% parameter value is float
% 	 %% NOTE: inefficient to always check there two cases first,
% 	 %% as they are particualy rare
% 	 X = case Unit
% 	     of secsF then {self getValue($)} 
% 	     [] msecsF then {self getValue($)} / 1000.0
% 	     else
% 		%% parameter value is integer
% 		Value = {IntToFloat {self getValue($)}}
% 	     in
% 		case Unit
% 		of seconds then Value
% 		[] secs then Value
% 		[] milliseconds then Value / 1000.0
% 		[] msecs then Value / 1000.0
% 		[] beats then Value * {Init.getBeatDuration}
% 		[] beats(N) then Value * {Init.getBeatDuration} / {IntToFloat N}
% 		else
% 		   {Exception.raiseError
% 		    strasheela(illParameterUnit Unit self
% 			       "Supported units are seconds (or secs), millisecond (or msecs), beats, and beats(N) (where N is an integer).")}
% 		   unit		% never returned
% 		end
% 	     end
%       end
      
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

   
   /** %% [concrete class] 
   %%*/
   class Pitch from Parameter
      feat %'class': Pitch
	 label: pitch
      meth isPitch(?B) B=true end
%       meth getValue(?X unit:Unit<=midicents)
% 	 X={self convertTo($ Unit)}
%       end
      /** %% Returns the parameter value translated to a float representing a Midi keynumber (i.e. 60.5 is a quarternote above middle c). The translation uses the parameter unit which must be bound (otherwise the method suspends, but warns also). Supported units are (represented by these atoms): midi, midicent/midic, frequency/freq/hz, mHz and and arbitrary equal temperaments.
      %% A tuning table is used if such a table was either defined with Init.setTuningTable or was specified as optional argument table. 
      %% */
      meth getValueInMidi($ table:Table<=nil)
	 {MUtils.pitchToMidi {self getValue($)} {self getUnit($)}
	  unit(table:Table)}
      end
   end
   
   /**
   %% [abstract class] An item is a generalization of score containers and elements. An item can be contained in one or more containers, the feature containers points to them.
   %%*/
   class Item from ScoreObject SMapping.mappingMixin % Applicator.applicatorMixin
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

      /** %% Returns all direct and indirect containers of self. 
      %% */
      meth getContainersRecursively($) 
	 Cs = @containers.list
      in
	 {Append Cs
	  {LUtils.mappend Cs fun {$ C} {C getContainersRecursively($)} end}}
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
      /** %% Returns the first direct or indirect container of self, which fulfils the boolean function or method Test.
      %%*/
      meth findContainerRecursively(?X Test) 
	 X={LUtils.find {self getContainersRecursively($)} {GUtils.toFun Test}}
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
      %% See also SMapping.patternMatchingApply.
      %% */ 
      meth pmApply(Xs PatternMatchingExpr P)
	 {SMapping.patternMatchingApply self Xs PatternMatchingExpr P}
      end
      /** %% Generalised variant of pmApply: in case no sublist in Xs matches PatternMatchingExpr, PatternMatchingApply2 does _not_ reduce to skip (as pmApply) but instead applies the null-ary procedure ElseP.
      %% See also SMapping.patternMatchingApply2.
      %% */ 
      meth pmApply2(Xs PatternMatchingExpr P ElseP)
	 {SMapping.patternMatchingApply2 self Xs PatternMatchingExpr P ElseP}
      end

      /** %% Variant of pmApply: applies P to the sublist of the elements of the temporal aspect of self which match PatternMatchingExpr.
      %% */
      meth pmApplyTemporalAspect(PatternMatchingExpr P)
	 {SMapping.patternMatchingApply self {{self getTemporalAspect($)}
					      getItems($)}
	  PatternMatchingExpr P}
      end
      /** %% Generalised variant of pmApplyTemporalAspect2: in case no sublist in Xs matches PatternMatchingExpr, PatternMatchingApply2 does _not_ reduce to skip (as pmApplyTemporalAspect2) but instead applies the null-ary procedure ElseP.
      %% */ 
      meth pmApplyTemporalAspect2(PatternMatchingExpr P ElseP)
	 {SMapping.patternMatchingApply2 self {{self getTemporalAspect($)}
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
      
      /** %% Returns the index of self in its temporal container (temporal aspect).
      %%*/
      %% @1=?Pos
      meth getTemporalPosition(?Pos)
	 Pos = {self getPosition($ {self findContainer($ {GUtils.toFun isTemporalAspect})})}
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
      /** %% Returns a list of the N items that precede self in Container, the item closes to self first. If N goes beyond the number of items available then on the available items are returned (i.e. the returned list is shorter than N).
      %% */
      meth getPredecessors(?X N Container) 
	 X = {LUtils.mappend {List.number ~1 (N*~1) ~1}
	      fun {$ Index}
		 Y = {self getPosRelatedItem($ Index Container)}
	      in
		 case Y of nil then nil else [Y] end
	      end}
      end
      /** %% Returns successor item of self in Container.
      %%*/
      %% @1=?X
      meth getSuccessor(?X Container) 
	 X={self getPosRelatedItem($ 1 Container)} 
      end
      /** %% Returns a list of the N items that succeed self in Container. If N goes beyond the number of items available then on the available items are returned (i.e. the returned list is shorter than N).
      %% */
      meth getSuccessors(?X N Container) 
	 X = {LUtils.mappend {List.number 1 N 1}
	      fun {$ Index}
		 Y = {self getPosRelatedItem($ Index Container)}
	      in
		 case Y of nil then nil else [Y] end
	      end}
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

      /** %% Returns a float how many percent parameters of self and its contained items are determined. The Boolean function/method Exclude can be used to exclude parameters from considering. By default, time point parameters are excluded.
      %% */
      meth percentageIsDet($ exclude:Exclude<=isTimePoint)
	 Params = {self collect($ test:fun {$ X} {X isParameter($)} andthen {Not {{GUtils.toFun Exclude} X}} end)}
	 L = {Length Params}
	 DetParamsNo = {Length {Filter Params fun {$ P} {IsDet {P getValue($)}} end}}
      in
	 {IntToFloat DetParamsNo} / {IntToFloat L} * 100.0
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
      %% */ 
      meth getTemporalPredecessor(?X)
	 X = {self getPredecessor($ {self getTemporalAspect($)})}
      end
      /** %% Returns a list of the N items that precede self in its TemporalAspect, the item closes to self first. If N goes beyond the number of items available then on the available items are returned (i.e. the returned list is shorter than N).
      %% */
      meth getTemporalPredecessors(?X N)
	 X = {self getPredecessors($ N {self getTemporalAspect($)})}
      end
      /** %% Returns the successor of object in its TemporalAspect. NB: method returns positional and not a temporal successor. 
      %% */ 
      meth getTemporalSuccessor(?X)
	 X = {self getSuccessor($ {self getTemporalAspect($)})}
      end
      /** %% Returns a list of the N items that succeed self in its TemporalAspect. If N goes beyond the number of items available then on the available items are returned (i.e. the returned list is shorter than N).
      %% */
      meth getTemporalSuccessors(?X N)
	 X = {self getSuccessors($ N {self getTemporalAspect($)})}
      end

      /** %% Returns a list of the items that precede self in its TemporalAspect up to any rest (i.e. a pause object or an item with an offset time > 0). A pause object would be excluded, but an item with an offset time > 0 would be included.
      %% Note: method delayed until offset times are sufficienly determined.
      %% */
      meth getPredecessorsUpToRest($)
	 fun {Aux X}
	    if X == nil orelse {X isPause($)}
	    then nil
	    elseif ({X getOffsetTime($)} >:0) == 1
	    then [X]
	    else X | {Aux {X getTemporalPredecessor($)}}
	    end
	 end
      in
	 {Aux {self getTemporalPredecessor($)}}
      end
      /** %% Returns a list of the items that succeed self in its TemporalAspect up to any rest (i.e. a pause object or an item with an offset time > 0). A pause object would be excluded, and so would be an item with an offset time > 0.
      %% Note: method delayed until offset times are sufficienly determined.
      %% */
      meth getSuccessorsUpToRest($)
	 fun {Aux X}
	    if X == nil orelse {X isPause($)} orelse ({X getOffsetTime($)} >:0) == 1
	    then nil
	    else X | {Aux {X getTemporalSuccessor($)}}
	    end
	 end
      in
	 {Aux {self getTemporalSuccessor($)}}
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

      
      /** %% Unifies the percentage Percent of the parameter values of self with the corresponding parameter values of ScoreObject. This is useful, for example, for manually controlling the search process by saying that a given percentage of the solution of a CSP is the same as in a given previous solution (e.g., from a pickled score), and then -- given suitable continuations of this solutions -- by and by increasing this percentage. 
      %% Blocks if self or ScoreObject are not fully determined.
      %%
      %% Args:
      %% test (default fun {$ X} true end): a Boolean function or method which parameters to include in unification and the percentage count.
      %% */
      meth partiallyUnify(ScoreObject Percent test:Test<=fun {$ X} true end)
	 fun {FullTest X}
	    {X isParameter($)} andthen {{GUtils.toFun Test} X}
	 end
	 SelfPs = {self collect($ test: FullTest)}
	 L = {Length {self collect($ test: FullTest)}}
	 N = L * Percent div 100
      in
	 {ForAll {LUtils.matTrans [{List.take SelfPs N}
				   {List.take {ScoreObject collect($ test: FullTest)} N}]}
	  proc {$ [SelfP ScoreObjectP]}
	     {SelfP getValue($)} = {ScoreObjectP getValue($)}
	  end}
      end

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
	 /** % The optional argument 'items' expects a list of items which are contained in the container instance. (Additionally, items can be given by calling the method bilinkItems.) A convenient shorthand notation for 'items' is the init method argument at record position 1.
	 %% Example: init(MyItems ...)
	 % */
      meth init(1:Items1<=nil items:Items2<=nil ...) = M
	 Items = if Items2 \= nil then Items2
		 elseif Items1 \= nil then Items1
		 else nil
		 end
      in	 
	 Item, {Record.subtractList M [1 items]}
	 @items = {New LUtils.extendableList init}
	 {self bilinkItems(Items)}
      end 
%       meth init(items:Items<=nil ...) = M
% 	 Item, {Record.subtract M items}
% 	 @items = {New LUtils.extendableList init}
% 	 {self bilinkItems(Items)}
%       end 
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
      %% See also SMapping.forNumericRange 
      %% */ 
      meth forNumericRangeTemporalAspect(Decl P)
	 {SMapping.forNumericRange {self getItems($)}
	  Decl P}
      end
      /** %% Generalised variant of forNumericRangeTemporalAspect: to every item in self to which P is not applied, ElseP (a unary procedure) is applied instead.
      %% See also SMapping.forNumericRange2 
      %% */ 
      meth forNumericRangeTemporalAspect2(Decl P ElseP)
	 {SMapping.forNumericRange2 {self getItems($)}
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

      meth getInitInfo($ exclude:Excluded<=nil clauses:Clauses<=nil)
	 unit(superclass:Item
	      args:[items#fun {$ X}
			     {X mapItems($ fun {$ X}
					      {X toInitRecord($ exclude:Excluded clauses:Clauses)}
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
   %% NOTE: the Modifier class was never used so far (even many years after its definition). So, consider removing it.
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

      %% Note how this getInitInfo handles the mixin class: only a single superclass returned, and mixin init args are added to args.
      meth getInitInfo($ ...)
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

   /** %% [abstract class] An element is a score item which does not contain items. For instance, a note and a pause (rest) are both elements.
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

      meth getInitInfo($ ...)
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

   /** %% [concrete class] A pause (a better name would be rest!) is a score element to produce silence of a given duration. It can, e.g., be used within a sequential to produce an offset between two items in the sequential. However, in such situation a pause (rest) could be replaced by the use of the parameter offsetTime of the item after the pause. Nevertheless, a pause in an explicite representation.
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
	 /** %% The parameter unit of pitch is specified by pitchUnit (default midi). 
	 %% */
      meth init(%addParameters:AddParams<=nil 
		pitch:P<=_ pitchUnit:PU<=midi ...) = M 
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
      
      meth getInitInfo($ ...)
	 unit(superclass:Event
	      args:[pitch#getPitch#{FD.decl}
		    pitchUnit#getPitchUnit#midi])
      end
      
   end

   /** %% [abstract mixin class] ArticulationMixin extends note classes with an articulation parameter, which expresses how long the note is hold. For example, staccato and legato articulations can be expressed with this parameter. The actual mapping of articulation values to notated articulations is defined by Init.setArticulationMap (see the documentation of that procedure of the defaults). For sound synthesis output (MIDI and Csound) the articulation is a duration percentage (e.g., if articulation is 105, then notes are slightly overlapping resulting in a legato).
   %%
   %% Only the parameter is defined, no further constraints are applied.
   %% NOTE: unlike most other parameters, the articulation parameter defaults to a determined integer (meaning non-legato). 
   %%
   %% NB: the articulationUnit is currently only a placeholder (this unit is ignoed).
   %% */
   class ArticulationMixin
      feat !ArticulationMixinType:unit
      attr articulation
      meth initArticulationMixin(articulation:A<=100 articulationUnit:AU<=percent ...) = M 
	 @articulation = {New Parameter init(value:A info:articulation 'unit':AU)}
	 {self bilinkParameters([@articulation])} 
      end
      meth getArticulation(X) X = {@articulation getValue($)} end
      meth getArticulationParameter(X) X= @articulation end
   end
   fun {IsArticulationMixin X}
      {IsScoreObject X} andthen {HasFeature X ArticulationMixinType}
   end

   /** %% [concrete class constructor] Expects a note class, and returns this class extended by an articulation parameter (see ArticulationMixin).
   %% */
   fun {MakeArticulationClass SuperClass}
      class $ from SuperClass ArticulationMixin
	 meth init(articulation:A<=100 articulationUnit:AU<=percent ...) = M
	    SuperClass, {Record.subtractList M [articulation articulationUnit]}
	    ArticulationMixin, {Adjoin M initArticulationMixin}
	 end
	 meth getInitInfo($ ...)       
	    unit(superclass:SuperClass
		 args:[articulation#getArticulation#100]) 
	 end
      end
   end
   
   
   /** %% [abstract mixin class] AmplitudeMixin extends note classes with an amplitude parameter.
   %% NOTE: unlike most other parameters, the amplitude parameter defaults to a determined integer (meaning mezzoforte).
   %% Note: Music notation output via Fomus takes amplitude values into account (changes in amplitude are even expressed with hairpins). However, Fomus must be instructed to do so (e.g., with the global setting dyns = yes in the ~/.fomus file).
   %% Sound synthesis output (e.g., MIDI and Csound) also output amplitude values (of course).
   %% No further constraints are applied.
   %% */
   class AmplitudeMixin
      feat !AmplitudeMixinType:unit
      attr amplitude
      meth initAmplitudeMixin(amplitude:A<=64 amplitudeUnit:AU<=velocity ...) = M 
	 @amplitude = {New Amplitude init(value:A info:amplitude 'unit':AU)}
	 {self bilinkParameters([@amplitude])} 
      end
      meth getAmplitude(X) X = {@amplitude getValue($)} end
      meth getAmplitudeInNormalized(?X) X={@amplitude getValueInNormalized($)} end
      meth getAmplitudeInVelocity(?X) X={@amplitude getValueInVelocity($)} end
      meth getAmplitudeParameter(?X) X=@amplitude end
      meth getAmplitudeUnit(?X) X={@amplitude getUnit($)} end
   end
   fun {IsAmplitudeMixin X}
      {IsScoreObject X} andthen {HasFeature X AmplitudeMixinType}
   end

   /** %% [concrete class constructor] Expects a note class, and returns this class extended by an amplitude parameter (see AmplitudeMixin).
   %% */
   fun {MakeAmplitudeClass SuperClass}
      class $ from SuperClass AmplitudeMixin
	 meth init(amplitude:A<=64 amplitudeUnit:AU<=velocity ...) = M
	    SuperClass, {Record.subtractList M [amplitude amplitudeUnit]}
	    AmplitudeMixin, {Adjoin M initAmplitudeMixin}
	 end
	 meth getInitInfo($ ...)       
	    unit(superclass:SuperClass
		 args:[amplitude#getAmplitude#64
		       amplitudeUnit#getAmplitudeUnit#velocity]) 
	 end
      end
   end
   

   /** %% [concrete class] The class Note extends class Note2 by the parameters articulation and amplitude. See the documentation of the classes ArticulationMixin and AmplitudeMixin.
   %% */
   Note = {MakeArticulationClass {MakeAmplitudeClass Note2}}

   
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
				 pause: Pause
				 items: MakeItems)
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
						[items containers 1]}
					init}}
	       else X={Constructor {Record.subtractList ScoreSpec
				    [items containers 1]}}
	       end
	       if HasID
	       then {Dictionary.put MyItemIDs ScoreSpec.id X}
	       end
	    end
	 end
      end
      fun {MakeExplicitScoreAux ScoreSpec Constructors MyItemIDs}
	 X = {MakeExplicitObject ScoreSpec Constructors MyItemIDs}
	 proc {ProcessNested Feat}
	    if {HasFeature ScoreSpec Feat} then
	       Ys = if {IsList ScoreSpec.Feat} then 
		       {LUtils.mappend ScoreSpec.Feat
			fun {$ S} {MakeExplicitScoreAux S Constructors MyItemIDs} end}
		    else
		       %% take first: no list for mappend required.. 
		       {MakeExplicitScoreAux ScoreSpec.Feat Constructors MyItemIDs}.1 
		    end
	    in
	       {X bilinkItems(Ys)}
	    end
	 end
      in
	 %% create contained items and surrounding containers
	 {ForAll [containers items 1] ProcessNested}
	 [X] % list for mappend
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
	    {Record.forAllInd {Record.subtractList ScoreSpec [containers items 1]}
	     proc {$ Feat _} {GetFeat X Feat} = ScoreSpec.Feat end}
	    %% NOTE: unification of IDs only for textual score, if list of containers/items is created by constructor, these are skipped..
	    local 
	       proc {ProcessNested Feat}
		  if {HasFeature ScoreSpec Feat} then
		     if {IsList ScoreSpec.Feat} then 
			{GetFeat X Feat} = {Map ScoreSpec.Feat
					    fun {$ X} {UnifyIDsAux X MyUnifyIDs} end}
		     else {GetFeat X Feat} = {UnifyIDsAux ScoreSpec.Feat MyUnifyIDs} 
		     end
		  end
	       end
	    in {ForAll [containers items 1] ProcessNested}
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
      %% As a shorthand notation, the feature 1 can be used instead of items, e.g., 
      %%<code>{Score.makeScore seq([note note] startTime:0) unit}}</code>
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
	 elseif {GUtils.isRecord R}
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
      %% CopyScore blocks if MyScore is not fully initialised.
      %%
      %% NB: CopyScore internally uses toInitRecord. Therefore, all present restrictions of toInitRecord apply: getInitInfo must be defined correctly for all classes and only tree-form score topologies are supported.
      %% !!! NB: if the output of toInitRecord contains stateful data, then this data is not copied but used as is (i.e. such stateful data is shared between the copies). 
      %% */
      %% !! could I use copying functionality defined for spaces instead to make implementation more stable without dependency on getInitInfo?
      proc {CopyScore MyScore ?MyCopy}
	 {CopyScore2 MyScore MyCopy}
	 {InitScore MyCopy}
      end
   end

   /** %% Like TransformScore, but the resulting score is not fully initialised (cf. MakeScore2 vs. MakeScore).
   %% */
   fun {TransformScore2 MyScore Args}
      Defaults = unit(clauses:nil
		      constructors:{Adjoin {MyScore getInitClasses($)} add})
      As = {Adjoin Defaults Args}
   in
      {MakeScore2 {{CopyScore MyScore} toInitRecord($ clauses:As.clauses)}
       As.constructors}
   end
   /** %% TransformScore returns a transformed copy of MyScore. TransformScore blocks if MyScore is not fully initialised. 
   %%
   %% The following optional arguments are supported via Args.
   %% 'clauses': a list of pairs TestI#FunI. TestI is a Boolean function or method, and FunI is a unary function expecting a score object and returning either a textual score object specification (a record), or a score object (which must not be fully initialised). For each object for which some TestI returns true, the corresponding FunI will be used for creating a score object which will replace the original object. 
   %% 'constructors': the contructors used for creating the transformed score from a textual score (cf. MakeScore). Default are the classes of MyScore: {MyScore getInitClasses($)}, plus the default constructors.
   %%
   %% Note that TransformScore does not support recursive transformations. For example, if you change the content of a container during a transformation, this new content will not be recursively processed. Nevertheless, you could explicitly call TransformScore again with the resulting score (you would need to call Score.init on that "inner" score first). 
   %%
   %% NB: TransformScore internally uses toInitRecord. Therefore, all present restrictions of toInitRecord apply: getInitInfo must be defined correctly for all classes and only tree-form score topologies are supported.
   %% */
   proc {TransformScore MyScore Args ?TransformedScore}
      {TransformScore2 MyScore Args TransformedScore}
      {InitScore TransformedScore}
   end



   /** %% Auto-documentation definition: For constructor functions defined with Score.makeConstructor, Score.defSubscript and friends but also classes: return a (possibly nested) record with all arguments and their default values.
   %% */
   fun {GetDefaults X}
      if {IsProcedure X} andthen {ProcedureArity X} == 2
      then {X 'getDefaults'}
      elseif {IsClass X}
      then {Record.map {{MakeScore x unit(x:X)} getInitArgDefaults($)}
	    %% Avoid free variables for doc (avoid blocking elsewhere)
	    fun {$ X} if {IsFree X} then '_' else X end end}
      else {Exception.raiseError
	    strasheela(failedRequirement X "Not an auto-documented value")}
	 unit % never returned
      end
   end
   
   /** %% Returns a score item constructor function with interface {F Args} which creates essentially the same item as Constructor (unary function or class), but uses the default arguments Defaults (record of init arguments). Defaults and Args can be nested records, in which case nested default specs are not overwritten if Args specifies same higher-level arg (i.e. Default and Arg are combined with GUtils.recursiveAdjoin instead of just Adjoin). The item returned by the constructor is not fully initialised. 
   %% In addition, the resulting constructor function supports convenience notations for certain values. The following notations are supported (both as default arguments and as actual arguments). 
   %% fn # MyFun: the actual value is returned by the function MyFun (remember that handing undetermined variables to constructors is only possible if the constructor call is wrapped in the script or some other procedure; otherwise the search blocks).   
   %% fd # DomSpec: DomSpec is the specification expected by FD.int.
   %%
   %% Returned functions support the auto-documentation with GetDefaults.
   %%
   %% Example
   {Score.makeConstructor Score.note
    unit(pitch: fd#(60#72)
	 duration: fn#fun {$} {FD.int 1#10} end)}
   %% */
   %% TODO: add support for fs # DomSpec : what format should DomSpec be in that case?
   fun {MakeConstructor Constructor Defaults}
      fun {$ Args}
	 %% auto-documentation
	 case Args of 'getDefaults' then
	    {Adjoin {GetDefaults Constructor}
	     Defaults}
	 else  			% normal use case
	    {MakeScore2 {Record.map {GUtils.recursiveAdjoin Defaults
				     {Adjoin Args unit}}
			 fun {$ X}
			    case X of fd # DomSpec then {FD.int DomSpec}
			    [] fn # F then {F}
			    else X
			    end
			 end}
	     unit(unit:Constructor)}
	 end
      end
   end

   local
      /** %% Creates a list of score object parameter values from a specification. Format of Spec is either each#Xs, fd#Spec, fenv#MyFenv, or MyVal, see MakeItems doc for details.  
      %% */
      fun {MakeParameterValues Spec N}
	 case Spec of
	    each#Xs then 
	    if {Length Xs} \= N then
	       {Exception.raiseError
		strasheela(failedRequirement Xs "List must be of length n: "#N)}
	    end
	    Xs
	 [] fd#Spec then
	    {LUtils.collectN N fun {$} {FD.int Spec} end}
	 [] fenv#MyFenv then 
	    {Map {MyFenv toList($ N)} FloatToInt}
	 else {LUtils.collectN N fun {$} Spec end}
	 end    
      end
      /** %% Expects a record who's feature values are lists and returns a list of records with single element features. 
      %% */
      fun {RecordMatTrans R}
	 {List.mapInd {MakeList {Length R.({Arity R}.1)}}
	  fun {$ I X}
	     %% !! NOTE: implementation using Nth not efficient, list is multiple
	     %% times traversed
	     X = {Record.map R fun {$ Xs} {Nth Xs I} end}
	  end}
      end
   in
      /** %% Extended script which returns a list of 'n' score items (e.g., notes), where many parameters can be still undetermined, and the objects are not fully initialised. 
      %%
      %% Args: 
      %% 'n': number of items
      %% 'constructor': creator class or function for items
      %% 'handle': argument to access the resulting list of items (convenient when MakeItems is used in a nested data structure, cf. ScoreObject init method arg handle)
      %% 'rule': constraint (unary proc) applied to list of all items
      %%
      %% In addition, all item arguments expected by 'constructor' are supported. If not specially marked, these arguments are shared by all parameters.
      %%
      %% For specifying individual arguments for the elements, the following special cases are supported. These cases are notated as a pair Label # ArgValue. The following labels are supported.
      %% fd#Spec: each parameter value has the given domain specification Spec. Example:
      unit(pitch: fd#(60#72)) 
      %% each#Xs: Xs is a list of length 'n' and specifies argument values for the individual elements. Example for specifying individual note pitches:
      unit(pitch: each#[60 62 64]) 
      %% fenv#MyFenv: MyFenv is a Fenv. Argument values for the individual elements are obtained by sampling the Fenv (method toList), and converting the results to integers.

      %%
      %% Default Args:
      unit(n: 1
	   constructor: Score.note)
      %%
      %%
      %%
      %% !! TODO: The args depend on constructor -- I should somehow allow for handing over different constructor
      %%
      %% NB: constructor must not expect any of the args expected by MakeItems (n, constructor, handle, rule), as these are affected by MakeItems. This fact limits the recursive use of MakeItems (where the constructor is created by MakeItems).
      %%
      %%*/
      %% - !!?? TODO: should arg constructor be generalised to additionally support case each#Constructors, where Constructors is list of length n with individual constructor for each returned item? Users should likely better use Score.make for that purpose..
      %% TODO: alternative arg format based on indices, so that for specific indices (and index ranges) I can specify specific args
      proc {MakeItems Args ?Elements}
	 proc {Skip Xs} skip end
	 Defaults = unit(n: 1
			 constructor: Note
			 handle:_
			 rule: Skip
			)
      in
	 %% auto-documentation
	 case Args of 'getDefaults' then
	    Elements =  {Adjoin Defaults
			 {Adjoin unit(handle:'_') % avoid blocking
			  {GetDefaults Defaults.constructor}}}
	 else			% usual use
	    As = {Adjoin Defaults Args}
	    L = element			% element label
	    RawSpec = {Record.subtractList As {Arity Defaults}}
	    Specs = if {IsLiteral RawSpec} then
		       {LUtils.collectN As.n fun {$} L end}
		    else 
		       SpecWithLists = {Record.map RawSpec
					fun {$ Param} {MakeParameterValues Param As.n} end}
		    in
		       {RecordMatTrans SpecWithLists}
		    end
	 in 
	    Elements = {Map Specs
			fun {$ Spec}
			   {MakeScore2 {Adjoin Spec L} % overwrite label
			    unit(L:As.constructor)}
			end}
	    As.handle = Elements 
	    thread			% rule may block until Elements are determined
	       {As.rule Elements}
	    end
	 end
      end

      /** %% Same as Score.makeItems, but all Score.makeItems arguments are wrapped in arg iargs for compatibility with DefSubscript.
      %%
      %%
      %% Note: arg processing (each-args etc) only supported for iargs, but not rarg, and also not for iargs.n. The reason is that only a single value of these args is needed for items creation (e.g., only one iargs.n is needed). 
      %% */
      fun {MakeItems_iargs Args}	 
	 Default = unit(iargs:unit)
      in
	 %% auto-documentation
	 case Args of 'getDefaults' then
	    %% TODO: refactor so that returned iargs depend on given constructor
	    unit(iargs: {GetDefaults MakeItems})
	 else			% usual use
	    As = {Adjoin Default Args}
	 in
	    {MakeItems As.iargs}
	 end
      end

      %% Some attempt to add arg processing (each-args etc) for rargs, but this approach was not a good idea. Kept here just in case...
%       /** %% Same as Score.makeItems, but all Score.makeItems arguments are wrapped in arg iargs for compatibility with DefSubscript.
%       %% Arg processing (each-args etc) is supported for iargs and rargs.
%       %% */
%       %% NOTE: some code doublication from MakeItems
%       proc {MakeItems_iargs Args ?Items}	 
% 	 Defaults = unit(iargs: unit(n: 1
% 				     constructor: Note
% 				     handle:_
% 				     rule: proc {$ Xs} skip end)
% 			 rargs:unit)
% 	 As = {GUtils.recursiveAdjoin Defaults Args}
% 	 MyLabel = {NewName}
% 	 %%
% 	 fun {MakeSpecs N Args IgnoredFeats}
% 	    RawSpec = {Record.subtractList Args IgnoredFeats}
% 	 in
% 	    if {IsLiteral RawSpec} then
% 	       {LUtils.collectN N fun {$} MyLabel end}
% 	    else 
% 	       SpecWithLists = {Record.map RawSpec
% 				fun {$ Param} {MakeParameterValues Param N} end}
% 	    in
% 	       {RecordMatTrans SpecWithLists}
% 	    end
% 	 end
% 	 Rargs_Specs = {MakeSpecs As.iargs.n As.rargs nil}
% 	 Iargs_Specs = {MakeSpecs As.iargs.n As.iargs {Arity Defaults.iargs}}
%       in 
% 	 Items = {Map {LUtils.matTrans [Rargs_Specs Iargs_Specs]}
% 		  fun {$ [Rargs_Spec Iargs_Spec]}
% 		     FullSpec = unit(iargs: Iargs_Spec
% 				     rargs: Rargs_Spec)
% 		  in
% 		     {MakeScore2 {Adjoin FullSpec MyLabel} % overwrite label
% 		      unit(MyLabel:As.iargs.constructor)}
% 		  end}
% 	 As.iargs.handle = Items 
% 	 thread			% rule may block until Elements are determined
% 	    {As.iargs.rule Items}
% 	 end	 
%       end

   end
   

   

   /** %% Extended script which returns a container with items, not fully initialised and where many parameters can be still undetermined. The contained elements are created with Score.makeItems.
   %%
   %% Args:
   %% 'constructor': the container constructor (class or function)
   %% 'iargs': arguments for the creation of container items, a record of args in the format expected by Score.makeItems  
   %% Any other container argument is supported as well.
   %%
   %%
   %% Default Args:
   unit(iargs:unit
	constructor: Sequential)
   %% */
   proc {MakeContainer Args ?MyScore}
      Default = unit(iargs:unit
		     %% TODO: revise why I need this arg here -- if needed improve next comment line 
		     %%
		     %% arg ignored, but filtered out of container args
		     rargs:unit
		     constructor: Sequential
		    )
   in 
      %% auto-documentation
      case Args of 'getDefaults'(...) % MakeSim / MakeSeq would call with getDefaults(constructor:Val)
      then
	 MyScore = {Adjoin unit(%% TODO: refactor so that iargs depend on constructor
				iargs: {GetDefaults MakeItems}
				%% arg ignored, but filtered out of container args
				rargs:unit#ignored)
		    %% TODO: refactor so that outer args depend on given constructor
		    {{MakeScore x unit(x:Default.constructor)}
		     getInitArgDefaults($)}}
      else			% usual use
	 As = {Adjoin Default Args}
	 %% just caution in case I later change Default.iargs
	 ItemAs = {Adjoin Default.iargs Args.iargs} 
	 MyNotes = {MakeItems ItemAs}
      in 
	 MyScore = {MakeScore2 {Adjoin {Record.subtractList As {Arity Default}}
				{Adjoin seq(items:MyNotes) container}}
		    unit(container:As.constructor)}
      end
   end
   /** %% Extended script which returns a simultaneous container with items, not fully initialised and where many parameters can be still undetermined. Specialisation of MakeContainer where the constructor is Simultaneous. See MakeContainer for further information.
   %% */
   fun {MakeSim Args}
      %% Args can be 'getDefaults', so I do not want to overwrite that...
      {MakeContainer {Adjoin unit(constructor:Simultaneous) {Record.subtract Args constructor}}}
   end
   /** %% Extended script which returns a sequential container with items, not fully initialised and where many parameters can be still undetermined. Specialisation of MakeContainer where the constructor is Sequential. See MakeContainer for further information.
   %% */
   fun {MakeSeq Args}
      {MakeContainer {Adjoin unit(constructor:Sequential) {Record.subtract Args constructor}}}
   end


   /** %% Extended script creator for reusable (and hierarchical) sub-CSP definition: returns an extended script (a procedure with the interface {Script Args ?MyScore}), which specialises a "super" extended script. The super-script returns either an item (typically a container with items) or a list of items. Possible super-scripts are, e.g., Score.makeItems_iargs, MakeContainer or any user-defined extended script, possibly also created with DefSubscript. The resulting score object(s) are not fully initialised, and can thus be integrated withing a higher-level container.
   %% 
   %% DefArgs is a record of optional arguments for declaring the super-script and the default arguments of the resulting script.
   %%
   %% DefArgs:
   %% 'super': the super-script: a procedure with the interface {Script Args ?MyScore} where Args must support the argument 'iargs', and can support any other argument as well. 'iargs' is a record of args in the format expected by Score.makeItems.
   %% 'mixins': a list of mixins defined with DefMixinSubscript. 
   %% 'defaults': record of default top-level argument values for resulting script. 
   %% 'idefaults': record of default argument values for args feature 'iargs' of resulting script (idefaults = itemsDefaults). 
   %% 'rdefaults': record of default argument values for args feature 'rargs' of resulting script (rdefaults = rulesDefaults).
   %%
   %% Default DefArgs:
   unit(super:MakeContainer
	mixins: nil
	defaults: unit
	idefaults: unit
	rdefaults: unit)
   %%
   %% Body is a procedure with the interface {Body MyScore Args}, where MyScore is the item(s) created by the super-script, and Args is the record of the arguments specified for the resulting script. Body can also be nil (e.g. for combining a super script and a mixin without adding any further constraints). The features of Args are both the arguments supported by the resulting extended script, and the Args expected by body.  
   %% 
   %% Args always has the features 'iargs' and 'rargs'. 
   %% 'iargs': a record of arguments given to contained items in the format expected by Score.makeItems (iargs = itemsArgs)
   %% 'rargs': record of arguments for constraints (rargs = rulesArgs)
   %%
   %% The variable Args of the body only contains the following arguments when they where specified with the extended script application.  
   %% 'super': same as for DefArgs
   %% 'mixins': same as for DefArgs
   %% In addition, Args can contain any init argument expected by the MyScore's top-level ("super" CSP creates a container). 
   %% 
   %% More specifically, Args contains the arguments provided when calling the resulting script plus the default values of omitted arguments specified with 'defaults', 'idefaults' and 'rdefaults' for this specific script. Default arguments specified for any super-script are absent from Args, if you need the defaults of the super-script in Body, declare them again for this script.
   %%
   %% NOTE: Returned functions support the auto-documentation of their arguments with GetDefaults. Example (using MakeRun defined below):
   {Score.getDefaults MakeRun}
   %%
   %% Problem: The defaults of init arguments for constructors can be reported wrongly, as the defaults of the class are reported, which could have been overwritten, e.g., by Score.makeConstructor. 
   %%
   %% Example:
   %% Motif definition: creates CSP with sequential container of notes (MakeContainer is super CSP), default are 3 notes (idefaults.n is 3, i.e., the default value for iargs.n is 3). Note pitches are constrained with Pattern.continuous, the direction of this pattern is controlled with the argument rargs.direction, default is '<:'. 
   MakeRun
   = {Score.defSubscript unit(rdefaults: unit(direction: '<:')
			      idefaults: unit(n:3))
      proc {$ MyScore Args} % body
	 {Pattern.continuous {MyScore mapItems($ getPitch)}
	  Args.rargs.direction}
      end}
   %% Motif application (MyScore is not fully initialised, see MakeContainer)
   MyScore
   = {MakeRun
      unit(iargs:unit(%% number of notes (overwrites default 3)
		      n: 2
		      %% all notes of same duration 2 (see Score.makeItems for other format options)
		      duration:2)
	   %% decreasing pitches (overwrites default '<:')
	   rargs:unit(direction:'>:')
	   %% argument to top-level container 
	   startTime:0)}

   %% For testing purposes, you can call these definitions outside any top-level script and look at the result with the following lines
   {Score.init MyScore}
   {Browse {MyScore toInitRecord($)}}
   %%
   %% */
   fun {DefSubscript DefArgs Body}
      Default = unit(super:MakeContainer
		     mixins: nil
		     defaults: unit
		     idefaults: unit
		     rdefaults: unit)
      DefAs = {Adjoin Default DefArgs}
   in
      %% Note: interface of body {$ MyScore Args} but returned subscript reversed order {$ Args ?MyScore}. Not a principle problem, but can be confusing. Changing this to the uniform order {$ Args ?MyScore} would require changing all calls to DefSubscript.
      proc {$ Args ?MyScore}
	 %% auto-documentation
	 %% BTW: no support for accessing where args have been defined (no additional arg 'getSources'), because instead of the actual definition I would always get this proc returned by DefSubscript
	 case Args of 'getDefaults' then
	    MyScore = {GUtils.recursiveAdjoin
		       {GUtils.recursiveAdjoin
			{GetDefaults DefAs.super}			
			{LUtils.accum {Map DefAs.mixins fun {$ F} {GetDefaults F} end}
			 GUtils.recursiveAdjoin}}
		       {Adjoin
			if {HasFeature DefAs constructor}
			then {Adjoin {GetDefaults DefAs.constructor} DefAs.defaults}
			else DefAs.defaults
			end
			unit(iargs: if {HasFeature DefAs.idefaults constructor}
				    then {Adjoin {GetDefaults DefAs.idefaults.constructor} DefAs.idefaults}
				    else DefAs.idefaults
				    end
			     rargs: DefAs.rdefaults)}}
	 else			% usual use
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
	 in
	    MyScore = {Super As}
	    if Body \= nil then 
	       thread {Body MyScore As} end
	    end
	    {ForAll Mixins
	     %% threads created already in Mixin (if defined with DefMixinSubscript)
	     proc {$ Mixin} {Mixin As MyScore} end}
	    %%
	    %% BUG: blocks
	    %% Doc, if this is sometimes working...
	    %% 'isMotif': return value argument. If present, this argument is bound to a unary Boolean function that only returns true for score objects returned by the defined script. Note: using this argument requires that this defined script does actually return a score object (instead of, e.g., a list of score objects).
	    %% 
% 	 %% 'isMotif'
% 	 if {HasFeature DefAs isMotif} then
% 	    MotifType = testAtom
% % 	    MotifType = {NewName}
% 	 in
% 	    {MyScore addInfo(MotifType)}
% 	    DefAs.isMotif
% 	    = fun {$ X}
% 		 {IsScoreObject X} andthen {X hasThisInfo($ MotifType)}
% 	      end
% 	 end
	 end
      end
   end


   /** %% [Complements DefSubscript]: defines further arguments and applies further constraints to a script defined by DefSubscript. 
   %%
   %% Args:
   %% 'super' (default is equivalent of GUtils.unarySkip): an optional super-mixin.  
   %% 'rdefaults': same as for DefSubscript.
   %%
   %% NOTE: 'idefaults' and 'defaults' are ignored: Defining default values for score object initialisation arguments is not supported for mixin scripts (defined values are ignored by the score object initialisation). 
   %%
   %% Body: A procedure with the interface {Body MyScore Args}, where MyScore is the item(s) created by the super-script, and Args is the record of the arguments specified for the resulting script. Body can also be nil.   
   %%
   %% Example:
   %% Motif definition where the pitch structure is defined with DefSubscript, and the rythmic structure by a mixin subscipt.
   MakeDottedRhythm
   = {DefMixinSubscript unit(rdefaults: unit(shortDur: 1))
      proc {$ MyScore Args} % mixin body
	 Durs = {MyScore mapItems($ getDuration)}
	 %% Durs length must be at least 2
	 [Dur1 Dur2] = {List.take Durs 2}
      in
	 Dur1 =: Dur2 * 3
	 Dur2 = Args.rargs.shortDur
	 {Pattern.cycle Durs 2}
      end}
   MakeContinuousNotes
   = {DefSubscript unit(super:MakeContainer
			rdefaults: unit(direction: '<:')
			idefaults: unit(n:3))
      proc {$ MyScore Args} % subscript body
	 {Pattern.continuous {MyScore mapItems($ getPitch)}
	  Args.rargs.direction}
      end}
   MakeMyMotif
   =  {DefSubscript unit(super: MakeContinuousNotes
			 mixins: [MakeDottedRhythm])
       nil}
   %% Motif application (MyScore is not fully initialised, see MakeContainer)
   MyScore
   = {MakeMyMotif
      unit(iargs:unit(%% number of notes (overwrites default 3)
		      n: 4)
	   %% decreasing pitches (overwrites default '<:')
	   rargs:unit(direction:'>:'
		      shortDur: 2)
	   %% argument to top-level container 
	   startTime:0)}

   %% For testing purposes, you can call these definitions outside any top-level script and look at the result with the following lines
   {Score.init MyScore}
   {Browse {MyScore toInitRecord($)}}
   %% */
   fun {DefMixinSubscript DefArgs Body}
      Default = unit(super: proc {$ Args MyScore}
			       case Args of 'getDefaults'
			       then MyScore = unit 
			       else skip
			       end
			    end
		     defaults: unit
		     idefaults: unit % ignored! 
		     rdefaults: unit)
      DefAs = {Adjoin Default DefArgs}
   in
      proc {$ Args MyScore}
	 %% auto-documentation
	 case Args of 'getDefaults' then
	    MyScore = {GUtils.recursiveAdjoin {GetDefaults DefAs.super}
		       unit(rargs: DefAs.rdefaults)}
	 else			% usual use
	    ItemAs = if {HasFeature Args iargs} then
			{Adjoin DefAs.idefaults Args.iargs}
		     else DefAs.idefaults
		     end
	    RuleAs = if {HasFeature Args rargs} then
			{Adjoin DefAs.rdefaults Args.rargs}
		     else DefAs.rdefaults
		     end
	    As = {Adjoin {Adjoin DefAs.defaults Args}
		  unit(iargs: ItemAs
		       rargs: RuleAs)}
	 in
	    %% thread created already in DefAs.super (if defined with DefMixinSubscript)
	    {DefAs.super As MyScore}
	    if Body \= nil then 
	       thread {Body MyScore As} end
	    end
	 end
      end
   end

   
   /** %% Expects a subscript which returns a list of items, and returns a variant of this subscript which wraps a container around this items list. The subscript arguments iargs and rargs are handed to the Subscript (usually created with Score.defSubscript), all other subscript arguments are given to the container. ContainerLabel is a label such as seq or sim.
   %% Purpose of this function: simplifies creation (& avoids code doubling) of two variants of a subscript, e.g., one returning plain list of notes (defined with DefSubscript), and one wrapping these notes in a container (defined with ItemslistToContainerSubscript from existing script).  
   %% */
   fun {ItemslistToContainerSubscript Subscript ContainerLabel}
      fun {$ Args}
	 %% auto-documentation
	 case Args of 'getDefaults' then
	    {GUtils.recursiveAdjoin 
	     {GetDefaults unit(seq:MakeSeq sim:MakeSim).ContainerLabel}
	     {GetDefaults Subscript}}
	 else			% usual use	    
	    %% make sure some value for iargs and rargs is there..
	    FullArgs = {Adjoin unit(iargs:unit
				    rargs:unit)
			Args}
	 in
	    {MakeScore2
	     {Adjoin {Record.subtractList Args [iargs rargs]}
	      ContainerLabel({Subscript unit(iargs:FullArgs.iargs
					     rargs:FullArgs.rargs)})}
	     unit}
	 end
      end
   end


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
		 Self.fooParameter = {New Parameter init(value:Args.foo info:foo)}
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
	 
	 meth getInitInfo($ ...)
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

   
   %%
   %% Heuristic constraints
   %%

   /** %% Applies a heuristic constraint (H_Constraint) to a list of parameter objects (Params) with a cetain weight Weight.
   %%
   %% Heuristic constraints restrict the result of a CSP (as strict constraints do), but the expressed constraint is only used as a guidance during the search process that can be violated if it contradicts some strict constraint. More specifically, heuristic constraints are used to quasi sort the domain values of variables before deciding which domain value to try out first (dynamic value ordering).
   %%
   %% Heuristic constraints are functions that expect n integers (*not* FD variables; FD int domain values) and return an integer. The result indicates how well the constraint is met by the input integers: the larger the number the better. A heuristic constraint is used to judge the quality of individual domain values. In a heuristic search (i.e. heuristic value ordering) the domain value with the highest quality according to all its applied heuristic constraints is selected.
   %% The returned qualities should cover the interval [0, 100], so that the importance of all heuristic constraints is considered equally. Nevertheless, larger or even negative results are possible as well.
   %% The weight of a constraint is a factor (int) that is applied to its returned quality and thus affects its importance.
   %%
   %% The application of heuristic constraints is strait forward and very similar to the application of strict constraints except for a formal difference. Strict constraints are applied directly to parameter values (i.e. variables). For example, The constraint C is applied to the pitch parameter value of the note N with the following code.
   {C {N getPitch($)}}
   %% Instead, heuristic constraints are applied to the score object parameters using Score.apply_H. The heuristic constraint HC is applied to the pitch parameter of the note N with the following code.
   {Score.apply_H HC {N getPitchParameter($)} 1}
   %% More generally, parameter objects are accessed with methods like getFooParameter, where Foo is the name of the parameter.
   %%
   %% NOTE: When heuristic constraints have been applied, the value ordering of the solver (distribution feature 'value') must be set to 'heuristic'.
   %%
   %% NOTE: Heuristic only used if all but last variables involved are already bound. So, for heuristics with more than 2 variables involved there could additionally be "partial heuristics" that define related heuristics for less variables.
   %%
   %% For an example, see strasheela/examples/Heuristic-Constraints.oz.
   %% */
   %%
   %% NB: only integer input and output supported because (a) domain values are integers anyway and (b) integer processing is more efficient. Nevertheleess, in principle it is possible to use float computations within a heuristic constraint (but all floats must be transformed to integers before returning). 
   %%
   %% NB: the heuristic is added to all Params involved: only the parameter visited last during search process makes use of the constraint.
   %%
   proc {Apply_Heuristic H_Constraint Params Weight}
      {ForAll Params
       proc {$ Param}
	  {Param addHeuristic(parameters: Params 
			      constraint: H_Constraint
			      weight: Weight)}
       end}
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Temporal constraints etc.
%%%
   
   /** % [0/1 Constraint] Returns 0/1-integer whether Time (FD int) is between the start and end time of X (an temporal item), including its start but note the end time.
   %% */
   proc {AtTimeR X Time ?B}   
      {FD.conj ({X getStartTime($)} =<: Time) (Time <: {X getEndTime($)}) B}
   end
  
   /** % [0/1 Constraint] Same as AtTimeR, but the time frame of X takes also the potential rest introduced by its offset time into account.
   %% */
   proc {AtTimeR2 X Time ?B}        
      StartX = {FD.decl}
   in
      StartX =: {X getStartTime($)} - {X getOffsetTime($)} 
      {FD.conj (StartX =<: Time) (Time <: {X getEndTime($)}) B}
   end


   /** %% [Deterministic function] Returns boolean whether (some part of) the item X is in the time frame specified by Start and End (ints).
   %% This relation defines a conjunction of the following Allen's Interval Algebra relations: overlaps, starts, during, finishes and equal; only meets and before/after are excluded.
   %% */  
   fun {InTimeframe X Start End}
      StartX = {X getStartTime($)}
      EndX = {X getEndTime($)}
   in
      (Start < EndX) andthen (StartX < End)
   end

   /** %% [Deterministic function] Varian of InTimeframe where the offset time Offset (an int) is taken into account. It returns true if the item X would be in the time frame specified by Start and End, if these times would be moved by this offset time.
   %% */
   fun {InTimeframeOffset X Start End Offset}
      StartX = {X getStartTime($)}
      EndX = {X getEndTime($)}
   in
      ((Start+Offset) < EndX) andthen (StartX < (End+Offset))
   end

   /** %% [Deterministic function] It returns true if the item X -- including its offset time -- would be in the time frame specified by Start and End, if these times would be moved by this offset time.
   %% */
   fun {InTimeframeOffset2 X Start End Offset}
      StartX = {FD.decl} 
      EndX = {X getEndTime($)}
   in
      StartX =: {X getStartTime($)} - {X getOffsetTime($)}
      ((Start+Offset) < EndX) andthen (StartX < (End+Offset))
   end

   /** % [0/1 Constraint] Returns 0/1-integer whether (some part of) the item X is in the time frame specified by Start and End (FD ints).
   %% This relation defines a conjunction of the following Allen's Interval Algebra relations: overlaps, starts, during, finishes and equal; only meets and before/after are excluded.
   %% */
   fun {InTimeframeR X Start End}
      StartX = {X getStartTime($)}
      EndX = {X getEndTime($)}
   in
      {FD.conj (Start <: EndX) (StartX <: End)}
   end

  /** %% [0/1 Constraint] Variant of InTimeframeR where the offset time Offset (FD int) is taken into account. It returns true (1) if the item X would be in the time frame specified by Start and End, if these times would be moved by this offset time.
   %% */
   fun {InTimeframeOffsetR X Start End Offset}
      StartX = {X getStartTime($)}
      EndX = {X getEndTime($)}
   in
      {FD.conj (Start+Offset <: EndX) (StartX <: End+Offset)}
   end

   /** %% [0/1 Constraint] It returns true (1) if the item X would be in the time frame specified by Start and End, if these times would be moved by this offset time.
   %% */
   fun {InTimeframeOffset2R X Start End Offset}
      StartX = {FD.decl}
      EndX = {X getEndTime($)}
   in
      StartX =: {X getStartTime($)} - {X getOffsetTime($)}
      {FD.conj (Start+Offset <: EndX) (StartX <: End+Offset)}
   end

   /** % [Deterministic function] Returns list of score items in Xs (a list of items) in the time frame specified by Start and End (FD ints) -- see doc of InTimeframe -- and fulfilling the optional Boolean function or method test.
   %% The implementation uses LUtils.cFilter and the reified constraint InTimeframeR. Items are returned as soon as the score contains enough information for all score objects in the score to tell whether or not they are simultaneous to self (i.e. rhythmic structure of the whole score must not necessarily be fully determined).
   %%
   %% Args:
   %% test (unary Boolean function or method): Only items for which this test returns true are collected. This function must be a deterministic function/method which does not block (e.g., checks on score object types or their position in the score topology are OK) and which is used for pre-filtering score objects.
   %% cTest (unary Boolean function or method):  Only items for which this test returns true are collected. The argument cTest is applied within the concurrent filtering of LUtils.cFilter, together with InTimeframeR. Computationally very expensive tests and in particular tests which can block are better handed to cTest.
   %%*/
   proc {GetItemsInTimeframe Xs Start End Args ?Result}
      Defaults = unit(test:fun {$ X} true end
		      cTest: fun {$ X} true end)
      As = {Adjoin Defaults Args}
   in
      thread
	 Result = {LUtils.cFilter {Filter Xs {GUtils.toFun As.test}}
		   fun {$ X}
		      ({InTimeframeR X Start End} == 1) andthen
		      {{GUtils.toFun As.cTest} X}
		   end}
      end
   end

   local
      fun {MakeGetItemsInTimeframe Constraint}
	 proc {$  Xs Start End Offset Args ?Result}
	    Defaults = unit(test:fun {$ X} true end
			    cTest: fun {$ X} true end)
	    As = {Adjoin Defaults Args}
	 in
	    thread 	
	       Result = {LUtils.cFilter {Filter Xs {GUtils.toFun As.test}}
			 fun {$ X}
			    ({Constraint X Start End Offset} == 1) andthen
			    {{GUtils.toFun As.cTest} X}
			 end}
	    end
	 end
      end
   in
      /** %% [Deterministic function] variant of GetItemsInTimeframe where the offset time Offset (FD int) is taken into account. See the doc of InTimeframeOffsetR for the meaning of the Offset.
      %% */
      GetItemsInTimeframeOffset = {MakeGetItemsInTimeframe InTimeframeOffsetR}      
      /** %% [Deterministic function] variant of GetItemsInTimeframe where the offset time Offset (FD int) and the offset times of items in Xs are taken into account. See the doc of InTimeframeOffset2R.
      %% */
      GetItemsInTimeframeOffset2 = {MakeGetItemsInTimeframe InTimeframeOffset2R}
   end


   
   % %% TODO: defs to define, then revise the method findSimultaneousItem accordingly 
   % fun {FindItemInTimeframe MyScore Start End Offset Args}
   % end
   %% ?? Needed
   % fun {FindItemInTimeframeOffset MyScore Start End Offset Args}
   % end
   
end

