
%%
%% TODO:
%%
%% - NestedScript example blocks: debug
%%
%% - NestedScript: test handing arguments to sub-sub motifs 
%%
%% - Fenv processing: assume that some motif prototype defines some fenvs for various parameters. How can I variate these fenvs in the resulting motif instances?
%%   Erste idee: Fenv in prototype bleibt unveraendert und wird von instances "geerbt". Aber ich fuege in instances weitere info-tags hinzu mit Funktionen, die diese Fenvs mit Fenv-operationen umformen. Problem dabei: ich erhalte immer mehr info-tags -- ich kann nicht beliebig mehr und mehr transformationen definieren. Ausserdem: wenn Fenvs in info record zusammengefasst werden (z.B. mit Label fenvs), wie kann ich dann weitere Fenvs (unabhaengig von den schon bestehenden) hinzufuegen -- sollte ich neue method addInfoToRecord(MyInfo MyLabel) einfuehren, die bestehende info-Records erweitert? Dann kann ich auch gleich stateful transformation von info records definieren: Fenv-transformationen sind dann einfach stateful operations die alte Fenvs durch transformierte fenvs ersetzen. Vielleicht ist das wirklich der einfachste Weg. Aber das funktioniert natuerlich nur innerhalb desselben space...
%%
%% - MakeScript: currently it is possible to either define script arg for constraining instance ('scriptArgs') or to constrain relation between instance and prototype ('prototypeDependencies'). Why no arg defining dependency between prototype and motif instance which can expect script args (e.g. the constraint such as Patter.contour may be expected as script arg)
%%
%% - extend ChoiceScript so that its arg 'choose' can be set to nil which returns an 'empty' score object. This makes it possible to specify the topology of a nested script -- withing string limits of course..  
%%
%% - create easy-to-use abstractions and arguments for common MakeScript calls (i.e. easy to use Args).
%%    - by default, unset all startTime and endTime parameters. Make this an extra Boolean arg whether these are unset or not?   
%%    - E.g., common case: keep durations, and constrain pitches by user-specified constraint (defaults to contour) 
%%
%% - Define nestable prototype defs (motif created functions - extended script - is used when score is transformed back into textual form and then again into score object) 
%%
%% - ?? Make number of score objects in motif instance controllable by arg.
%%   ?? shall I really do this? In many cases, it is more simple to define different prototypes with different note numbers (and then I may control how number affects rhythm etc)
%%    Relatively simple approach: I can statefully change the score hierarchy of AuxScore in MyScript. It would require that I know *where* to add or remove *how many* score objects of *what class and which what init args* 
%%    How can I hand over this information as extended script arg(s)?
%%   ? only allow this for more simple topology (e.g. container with elements and number of elements is user controllable with script arg N). For the latter case, more complex topologies again possible via nesting
%%   !! if I do this, then fix prototypeDependencies processing, it currently requires that score topology of motif prototype and instance are equal 
%%
%% - Some vars are always undetermined (Explorer node of solution is light green)
%%   - Find out which vars are left undetermined
%%   - Make them either determined or document which are left undetermined
%%
%% - Find a more specific name for the older motif model. 
%%
%% - ??  Idea: extended script expects same args as MakeScript: either the MakeScript args are overwritten or MakeScript and MyScript args are appended (e.g., additional constraints can be defined that way..)
%%
%% - define mini language (given as record to score object info) to simplify specific unset, constraint, and prototypeDependency definitions  
%%
%% 
%% DONE:
%%
%% - OK Chord example blocks: debug
%%
%% - ?? shall 'unset' really expect parameter accessor. The present approach looks rather low-level and only works for parameters (internally the method getValue is called).
%%  !! I need to be able to unset any variables, whether parameter or not. E.g., if prototype contains chord objects, then I want to unset FS which are not parameters. How can I do that? 
%%
%% - Finish doc for MakeScript for the optional arguments
%%


/** %% This functor defines abstractions for constraining the musical form. The fundamental idea here is the motif prototype concept. A motif prototype is a Strasheela score object (e.g., a container containing a few notes) which serves as a blueprint for motif instances in the final score. The motif prototype is usually fully determined (although this is not necessary, see MakeScript documentation). From this prototype, an extended script is created using the procedure MakeScript. This extended script expects some arguments and returns a motif instance which is similar to the prototype. For example, the rhythmical structure may be the same in the prototype and all motif instances, the actual pitches differ, but the pitch contour is also the same. In which way the prototype and the motif instances are similar is defined by the user, see the documentation of MakeScript for details. 
%% In general, an extended script is a function which expects some arguments and returns a score object to which constraints are applied. With the help of GUtils.extendedScriptToScript, an extended script can be directly given to the Strasheela solvers exported by SDistro. Alternatively, the exteneded script can be used inside a script to create a part of the final score. See the examples for both such uses.  
%%
%% Strasheela already defines another motif model (contributions/anders/Motif). These are the differences between the two motif models.
%%
%% Advantages of the prototype-based motif model: The charateristic features of motifs are conveniently defined in the model by giving examples (the prototypes). In the [older] motif model, these features are defined in a more abstract way (although an extension of the older model might also allow defining these features by way of examples). Moreover, different motif instances in the same CSP can differ in their score topology in the prototype-based model (e.g., a melodic motif might be expressed as a sequential container with notes, whereas a chordal motif might additionally use simultaneous containers). This is not possible in the [older] motif model. In general, a hierarchically nested score is more easily defined in the prototype-based model. Also, additional score information (e.g., sound synthesis details such as continuos controllers or timing functions, both expressable by fenvs) which are shared by all motif instances are added conveniently in this model. 
%%
%% Advantages of the [older] motif model: Most importantly, the motif identity is constrainable in the older motif model. For example, in the older model it can be specified by constraints which motif identity can follow which identity (e.g., whether A B A is permitted or not). In the prototype-based model, the arrangement of motifs in the score must be determined in the problem definition and cannot be constrained. Also, the older motif model distinguishes between the identity the variation of a motif (the variation can be constrained as well, independently of the motif identity). Multiple variation scripts can be created from a single prototype in the prototype-based model, but formally these variations are indistinguishable from unrelated motif scripts (in practise, you can name them in a way that you recognise which motif scripts are related). Making an distinction between motif identity and variation by distinct FD variables (as in the older model) is unnecessary in this model, as the arrangement of motifs in the score cannot be constrained anyway.
%%
%% In summany, the prototype-based motif model allows more easily for direct control of the resulting musical form (e.g., the form may be composed 'by hand', or created by some deterministic algorithmic composition technique). The [older] motif model, on the other hand, is suited for complex CSPs where also the musical form is constrained besides other musical aspects (e.g., complex forms such as inventios or fugues).
%%
%% */

functor 

import
   
   FD
   Browser(browse:Browse)
   
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   SMapping at 'x-ozlib://anders/strasheela/source/ScoreMapping.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   
export 

   MakeScript

   NestedScript
   
   ChoiceScript

%   ConstrainMotifs

   UnifyDependency
   
   GetFirstNote
   GetHighestPitch
   
define

   /** %% MakeScript returns a (sub)-CSP for creating motif instances similar to a given prototype. MakeScript expects a prototype motif MyProto (a score object, usually a container with other score objects) and some optional arguments. MakeScript returns an extended script, that is a binary procedure with the interface {MyScript Args MyScore} (for details see GUtils.extendedScriptToScript). 
   %% The returned script expects the following optional arguments. 'initScore' (defaults to false) specifies whether the resulting score is fully initialised implicitly. Ignore this argument if the returned motif instance is nested into other containers and that way only a part of a score, but set it to true if the returned motif instance is the full score (e.g., for testing). For further details on score initialisation see Score.initScore.
   %% In addition, the returned script expects all arguments of its top-level score object (e.g., a script for a temporal object expects the optional arguments startTime and timeUnit). Further arguments can be defined explicitly with the MakeScript argument 'scriptArgs' (see below). The optional MakeScript arguments are the following.
   %%
   %% 'unset': this argument specifies which variables in the resulted motif instance are not shared with the prototype. This argument expects a list of pairs TestI#AttributesI, where TestI is a Boolean function or method and AttributesI is either a single atom naming an object attribute or a list of such atoms. The attributes must either bind a parameter or directly a variable (e.g., the note attributes 'pitch' and 'duration' bind parameters). For every score item (e.g., note or container) for which a Test returns true, the corresponding attribute variables (e.g., parameter values) are unset and independent of the prototype. The following example unsets all note pitches.

   unset:[isNote#pitch]
   
   %% The parameters start and end times are always implicitly unset. In case it is required that all motif instances start exactly at the start time of the prototype, constrain the startTime values of the motif instances and the prototype explicitly to the same value (see argument 'prototypeDependencies'). 
   %% Note that only parameter values which are unset are unique to a motif instance. All non-unset variables are shared by the prototype and all motif instances of this prototype.
   %% The prototype can have undetermined variables. In that case the prototype must be defined within the (top-level) script so that all variables are in local spaces (variables in the top-level space, i.e. outside a script, block the solver).
   %%
   %% 'prototypeDependencies': this argument defines constraints between 'unset' variables of the resulting motif instance and the prototype. The argument expects a list of pairs TestI#ConstraintI. TestI is a Boolean function or method. ConstraintI is a procedure with the interface {$ MyPrototype MyInstance} which expects the motif protoype and the motif instance returned by the script as arguments. The following dummy example dependency constrains all motif instance pitches to be higher than their corresponding prototype pitch.

   prototypeDependencies: [isNote#proc {$ Proto Inst}
				     {Proto getPitch($)} = {Inst getPitch($)}
				  end]

   %% NB: 'prototypeDependencies' (currently) requires that the protytype and the motif instance have the same score topology including the same number of score objects. 
   %%
   %%
   %% 'constraints': this argument defines additional constraints applied to the resulting motif instance. It expects a list of pairs TestI # ConstraintI. TestI is a Boolean function or method. ConstraintI is a procedure with the interface {$ MyInstance} which expects the motif instance. The following example constraints the domain of all notes in the motif.

   constraints: [isNote#proc {$ N} {N getPitch($)} = {FD.int 60#72} end]

   
   %% 'scriptArgs': this argument specifies additional arguments of the returned script. It expects a record whose features are the additional script arguments. The values at these features are either a procedure ConstraintI or a pair ConstraintI # DefaultI. ConstraintI is a procedure with the interface {$ MyMotif Argument}. This procedure is applied to the motif instance and the script argument specified at its feature. Optional script arguments are defined by additionally providing DefaultI, a default argument value. The following 'scriptArgs' example specifies a pitch domain for all notes contained in the motif with the default domain 60#72.
   
   scriptArgs: unit(pitchDomain: proc {$ MyMotif Dom}
				    {ForAll {MyMotif collect($ test:isNote)}
				     proc {$ N} {N getPitch($)} = {FD.int Dom.1} end}
				 end # dom(60#72))

   %% NB: Be careful with variables as default script arguments, they would be shared by all motif instances. If you need independent variables as script arguments, then wrap them in a function argument (e.g., fun {$} {FD.decl} end) which would be called inside the procedure ConstraintI.
   %%
   %% 'motifTest': this is an optional output argment. It binds its value to a Boolean function which returns true for motif instances created with MyScript.
   %%
   %% Note that MakeScript internally uses toInitRecord. Therefore, all present restrictions of toInitRecord apply: getInitInfo must be defined correctly for all classes and only tree-form score topologies are supported.
   %% */
   proc {MakeScript MyProto Args ?MyScript}
      Defaults = unit(unset:nil
		      %% arg prototypeDependencies is in principle more general than arg constraints, but I may run into problems with prototypeDependencies if prototype and motif instance topologies are not equal whereas arg constraint does not pose such problems
		      constraints:nil
		      scriptArgs:unit
		      prototypeDependencies:nil
		      motifTest:_)
      As = {Adjoin Defaults Args}      
      fun {CopyScore2 Orig Args}
	 OrigR = {Orig toInitRecord($)}
      in
	 {Score.makeScore2
	  %% Add Args for top-level given directly to script 
	  %% possibly overwrite features of orig, but keep Orig's label
	  {Adjoin {Adjoin OrigR Args} {Label OrigR}}
	  {MyProto getInitClasses($)}}
      end
      MotifName = {NewName}
   in
      fun {As.motifTest X}
	 {Object.is X}
	 andthen {MyProto getClass($)} == {X getClass($)}
	 andthen {X hasFlag($ MotifName)}
      end
      proc {MyScript ScriptArgs MyScore}
	 %% Defaults for all scripts. Additional script args and defaults are defined with MakeScript arg scriptArgs
	 Defaults = unit(initScore:false
			 %% arg nestedArgs ignored by script, only
			 %% here to remove it from ScoreCreationArgs
			 nestedArgs:nil)
	 ScriptAs = {Adjoin Defaults ScriptArgs}
	 %% Any arg which was not explicitly declared to MakeScript is used as top-level score object arg during the final motif instance creation
	 TopLevelScoreObjArgs = {Record.subtractList ScriptAs 
				 {Append {Arity As.scriptArgs} {Arity Defaults}}}
	 %% Aux funs
	 %% 
	 %% Expects score object X and an attribute for either a parameter or variable of X. The variable or param value is unset to _
	 proc {UnbindVar X Attribute}
	    Val = {X getAttr($ Attribute)}
	 in
	    if {Score.isScoreObject Val} andthen {Val isParameter($)} 
	    then {Val setAttribute(value _)}
	    elseif {FD.is Val} orelse {GUtils.isFS Val}
	    then {X setAttribute(Attribute _)}
	    else {Exception.raiseError
		  strasheela(failedRequirement Val
			     "Neither parameter nor variable to unset")}
	    end
	 end
	 %% Create copy of MyProto, so changing the copy does not effect MyProto. 
	 AuxScore = {CopyScore2 MyProto unit}
	 {Score.initScore AuxScore}
      in
	 %% Unbind AuxScore param values
	 {ForAll
	  %% always unset all start and end times
	  (Score.isTemporalItem#[startTime endTime]) | As.unset
	  proc {$ Test#Attributes}
	     {AuxScore forAll(proc {$ X}
				 %% Attributes is either list or single attr
				 if {IsList Attributes}
				 then {ForAll Attributes
				       proc {$ A} {UnbindVar X A} end}
				 else {UnbindVar X Attributes}
				 end
			      end
			      excludeSelf:false
			      test:Test)}
	  end}
	 %% Create a copy of AuxScore, so all implicit constraints are applied by Score.makeScore
	 MyScore = {CopyScore2 AuxScore TopLevelScoreObjArgs}
	 %% add info tag for type checking
	 {MyScore addFlag(MotifName)}
	 
	 if ScriptAs.initScore then {Score.initScore MyScore} end
	 %%
	 thread 		% concurrent in case MyScore is not initialised
	    %% scriptArgs processing
	    {Record.forAllInd As.scriptArgs
	     proc {$ Feat ConstraintArg}
		Arg
	     in
		%% Efficiency: this case statement could be executed only once for all motif instances, but then I must define it outside the script..
		case ConstraintArg
		   %% optional arg
		of Constraint#Default then 
		   Arg = if {HasFeature ScriptAs Feat}
			 then ScriptAs.Feat
			 else Default
			 end
		   {Constraint MyScore Arg}
		   %% obligatory arg
		[] Constraint then
		   Arg = ScriptAs.Feat
		   {Constraint MyScore Arg}
		end
	     end}
	    %% prototypeDependencies processing
	    {ForAll As.prototypeDependencies
	     proc {$ Test#Constraint}
		%% !!! NOTE: [vorlaeufig] def: problem: MyProtoObjs and MyScoreObjs must correspond, prototype and motif instance must have same topolgy
		MyProtoObjs = {MyProto collect($ test:Test excludeSelf:false)}
		MyScoreObjs = {MyScore collect($ test:Test excludeSelf:false)}
	     in
		{ForAll {LUtils.matTrans [MyProtoObjs MyScoreObjs]}
		 proc {$ [MyProtoObj MyScoreObj]} {Constraint MyProtoObj MyScoreObj} end}
	     end}
	    %% constraints processing 
	    {ForAll As.constraints
	     proc {$ Test#Constraint}
		MyScoreObjs = {MyScore collect($ test:Test excludeSelf:false)}
	     in
		{ForAll MyScoreObjs Constraint}
	     end}
	 end
      end
   end


   /** %% [Aux for MakeScript and NestedScript] Expects a textual score MyTextScore and the list of arguments given to script arg NestedArgs. Returns the textual score with the arguments added. For every object of which some info tag matches an id in the NestedArgs, the corresponding args of NestedArgs are added.
   %% MakeScript created-scripts just ignore arg nestedArgs (??)
   %% */
   fun {AddArgsToScore MyTextScore NestedArgs Constructors}
      /** %% Expects a single info datum and traverses nested NestedArgs to find args matching Info
      %% */
      fun {FindArgs Info}
	 Match = {LUtils.find NestedArgs
		  fun {$ ArgInfo#_ /* Args */}
		     if {IsList ArgInfo} 
		     then {Member Info ArgInfo}
		     else Info == ArgInfo
		     end
		  end}
      in
	 if Match \= nil then [ Match.2 ] else nil end
      end
      %% Expects score object spec: if it matches an arg spec, then the arg is returned
      fun {GetArgs X}
	 if {HasFeature X info}
	 then if {IsList X.info}
	      then {LUtils.mappend X.info FindArgs}
	      else {FindArgs X.info}
	      end
	 else nil
	 end
      end
      fun {AsList X}
	 if {IsList X} then X else [X] end
      end
      /** %% Returns true if X is motif or other explictily given constructor 
      %% */
      fun {InConstructors X}
	 {HasFeature Constructors {Label X}}
      end
      /** %% Add arg nestedArgs is suitable
      %% */
      fun {AdjoinNestedArgs X}
	 if {InConstructors X}
	 then {Adjoin unit(nestedArgs:NestedArgs) X}
	 else X
	 end
      end
      fun {AdjoinMatchingArgs X}
	 Args = {GetArgs X}
      in
	 if Args \= nil
	 then As = Args.1 in
	    if {HasFeature As info}
	    then
	       Info = {Append {AsList X.info} {AsList As.info}}
	    in
	       {AdjoinNestedArgs
		{Adjoin {Adjoin {Adjoin X As}
			 unit(info:Info)}
		 {Label X}}}
	    else
	       {AdjoinNestedArgs {Adjoin X As}}
	    end
	 else {AdjoinNestedArgs X}
	 end
      end
   in
      {SMapping.mapScore MyTextScore
       AdjoinMatchingArgs}
   end

   
   
   /** %% NestedScript returns a (sub)-CSP for creating nested motif instances which consist in multiple sub-motifs. NestedScript expects a score MyTextScore and some optional arguments. MyTextScore is a textual score (a record) which specifies the motif score topology. MyTextScore typically contains motif instance declations created with MakeScript or other NestedScript calls. Note that NestedScript expects a score in textual format, in contrast to MakeScript which expects a score object. MakeScript returns an extended script, that is a binary procedure with the interface {MyScript Args MyScore} (for details see GUtils.extendedScriptToScript).
   %% The returned script expects the following optional arguments. The argument 'initScore' (defaults to false) specifies whether the resulting score is fully initialised implicitly. Ignore this argument if the returned motif instance is nested into other containers and that way only a part of a score, but set it to true if the returned motif instance is the full score (e.g., for testing). For further details on score initialisation see Score.initScore.
   %% Arbitrary arguments can be handed directly to the creation of nested score objects, including to nested motifs by the argument 'nestedArgs'. The intended score objects are identified by info tags. 'nestedArgs' expects a list of pairs ID#Args where ID is a complete info tag (i.e. a record, not just its label) and Args is the record of arguments for this score object. ID can also be a list of info tags, which allows to specify multiple score objects for the same arguments. Handing over arguments this way does not only work for score objects explicitly contained in MyTextScore, but also for deeper nested sub-sub-motifs. For non-motif score objects, however, it only works if they are explicitly contained in MyTextScore. Note that 'nestedArgs' arguments overwrite the respective arguments of the matching score objects. The exception are info tags, which are appended. In case of complex score with several info tags consider using a record like id(ID) in order to avoid clashes of info record labels.
   %% In addition, the returned script expects all arguments of its top-level score object (e.g., a script for a temporal object expects the optional arguments startTime and timeUnit). Further arguments can be defined explicitly with the MakeScript argument 'scriptArgs' (see below). The optional MakeScript arguments are the following.
   %%
   %% 'constructors': a record of score constructors (unary functions or classes). These constructors are very much like the second argument of Score.makeScore. However, they must expect the additional (init method) argument 'nestedArgs', which is used to recursively pass arguments to inner score objects and motifs (see above).
   %%
   %% 'constraints': this argument defines additional constraints applied to the resulting nested motif instance. It expects a list of pairs TestI # ConstraintI. TestI is a Boolean function or method. ConstraintI is a procedure with the interface {$ MyInstance} which expects the motif instance. The following example constraints the domain of all notes in the nested motif.

   constraints: [isNote#proc {$ N} {N getPitch($)} = {FD.int 60#72} end]

   
   %% 'scriptArgs': this argument specifies additional arguments of the returned script. It expects a record whose features are the additional script arguments. The values at these features are either a procedure ConstraintI or a pair ConstraintI # DefaultI. ConstraintI is a procedure with the interface {$ MyMotif Argument}. This procedure is applied to the motif instance and the script argument specified at its feature. Optional script arguments are defined by additionally providing DefaultI, a default argument value. The following 'scriptArgs' example specifies a pitch domain for all notes contained in the nested motif with the default domain 60#72.
   
   pitchDomain: proc {$ MyMotif Dom}
		   {ForAll {MyMotif collect($ test:isNote)}
		    proc {$ N} {N getPitch($)} = {FD.int Dom.1} end}
		end # dom(60#72)

   %% NB: Be careful with variables as default script arguments, they would be shared by all motif instances. If you need independent variables as script arguments, then wrap them in a function argument (e.g., fun {$} {FD.decl} end) which would be called inside the procedure ConstraintI.
   %%
   %% 'motifTest': this is an optional output argment. It binds its value to a Boolean function which returns true for motif instances created with MyScript.
   
   %% */
   %%
   %% Ideas:
   %%
   %% If MyTextScore contains vars, then it must be part of the top-level script. But if additionally I allow that MyTextScore is a nullary fun returning the textual score, then this fun can be defined anywhere (e.g. some functor). All I would need to add to NestedScript is a test whether MyTextScore is a fun/proc and in that case call fun to create score.
   %% If I do that here, that I should do the same to MakeScript: score could be function returning score object
   proc {NestedScript MyTextScore Args ?MyScript}
      Defaults = unit(constructors:unit
		      constraints:nil
		      scriptArgs:unit
		      motifTest:_)
      As = {Adjoin Defaults Args}
      MotifName = {NewName}
   in
      fun {As.motifTest X}
	 {Object.is X}
	 %% NOTE: I assume nested motifs are always containers, should I do isItems insteaad?
	 andthen {X isContainer($)} 
	 andthen {X hasFlag($ MotifName)}
      end
      proc {MyScript ScriptArgs ?MyScore}
	 Defaults = unit(initScore:false
			 nestedArgs:unit)
	 ScriptAs = {Adjoin Defaults ScriptArgs}
	 TopLevelScoreObjArgs = {Record.subtractList ScriptAs
				 {Append {Arity Defaults} {Arity As.scriptArgs}}}
      in

	 %% Add nestedArgs and args for top-level given directly to script to MyTextScore. 
	 %% Args possibly overwrite features of orig
	 MyScore = {Score.makeScore2 {Adjoin {Adjoin {AddArgsToScore MyTextScore
						      ScriptAs.nestedArgs
						      As.constructors}
					      TopLevelScoreObjArgs}
				      {Label MyTextScore}}
		    As.constructors}
	 if ScriptAs.initScore then {Score.initScore MyScore} end

	 %% NOTE: code doubling: copied from MakeScore
	 thread 		% concurrent in case MyScore is not initialised
	    %% scriptArgs processing
	    {Record.forAllInd As.scriptArgs
	     proc {$ Feat ConstraintArg}
		Arg
	     in
		%% Efficiency: this case statement could be executed only once for all motif instances, but then I must define it outside the script..
		case ConstraintArg
		   %% optional arg
		of Constraint#Default then 
		   Arg = if {HasFeature ScriptAs Feat}
			 then ScriptAs.Feat
			 else Default
			 end
		   {Constraint MyScore Arg}
		   %% obligatory arg
		[] Constraint then
		   Arg = ScriptAs.Feat
		   {Constraint MyScore Arg}
		end
	     end}
	    %% constraints processing 
	    {ForAll As.constraints
	     proc {$ Test#Constraint}
		MyScoreObjs = {MyScore collect($ test:Test excludeSelf:false)}
	     in
		{ForAll MyScoreObjs Constraint}
	     end}
	 end
		    
      end
   end

   
   /** %% Expects Scripts, a record of extended scripts, and returns a new extended script by which one of the scripts in Scripts can be selected. The new script expects all arguments of the scripts in Scripts and an additional optional argument 'choose' expecting a feature of Scripts. The corresponding script will then be selected. The arg 'choose' defaults to the first script in Scripts (first of its arity).
   %% It is recommended that all scripts in Scripts expect the same arguments, so that the arguments of the returned script don't depend on the value of its arg 'choose'.
   %% */
   proc {ChoiceScript Scripts ?MyScript}
      proc {MyScript Args ?MyScore}
	 Default = unit(choose:{Arity Args}.1)
	 As = {Adjoin Default Args}
      in
	 MyScore = {Scripts.(As.choose) {Record.subtractList Args {Arity Default}}}
      end
   end


   
   %%
   %% Convenience functions 
   %%
   
   /** %% [convenience definition] Function for defining a dependency between a motif instance and a prototype. The unary function Fn is applied to the prototype and the motif instance and the results are unified. The following example is a pair given to the MakeScript argument prototypeDependencies which constrains that the prototype and the motif instance feature the same pitch contour. 

   prototypeDependencies:
      [isContainer#{PM.unifyDependency
		    fun {$ X} {Pattern.contour {X map($ getPitch test:isNote)}} end}]
   %% */
   fun {UnifyDependency Fn}
      proc {$ Proto Instance}
	 {Fn Proto} = {Fn Instance}
      end
   end

   /** %% [convenience definition] Expects a motif instance and returns the first note contained, regardless of nesting depth (returns the first note returned by the collect method).  
   %% */
   fun {GetFirstNote MyMotif}
      {MyMotif collect($ test:isNote)}.1
   end
   /** %% [convenience definition] Expects a motif instance and returns the pitch of the highest motif note (regardless of nesting depth).
   %% */
   proc {GetHighestPitch MyMotif ?MaxPitch}
      Ps = {MyMotif map($ getPitch test:isNote)}
   in
      {Pattern.max Ps MaxPitch}
   end
%    fun {GetLongestNote MyMotif}
%    end

   
end

