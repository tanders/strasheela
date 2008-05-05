
/** %%
%% The functor demonstrates how a subclass of some Strasheela class is defined such that all Strasheela functionality (e.g. transformation of score object 'back' into textual representation) is preserved for the new class. The code of this class definition is extensively documented. 
%%
%% The functor defines and exports the class TestClass, which is a subclass of Score.temporalElement subclass with the additional parameter foo.
%% */
 
functor

import
   FD
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'

export
   TestClass
   IsTestClass
   
prepare
   %% A name used for type checking (see beginning of class definition and IsTestClass below). The name is created in the prepare section of the functor to create the name only once at compile time. 
   TestClassType = {Name.new}
   
define

   /** %% Our demonstration class extends Score.temporalElement by the single parameter 'foo'.
   %% */ 
   class TestClass from Score.temporalElement
      feat
	 %% A class specific label (here testClass) is used for the transformation back into the textual form 
	 label:testClass
	 %% The feature for TestClassType is used for typechecking (see IsTestClass below). The exclamation mark prevents creating a new variable. Instead the name bound to the existing variable TestClassType is used.
	 !TestClassType:unit

	 %% The attribute 'foo' stores the new parameter
      attr foo

	 /** %% The init method expects the arguments of Score.temporalElement plus the additional argument foo. Default of Foo is {FD.decl}.
	 %% Every standard Strasheela class must define a method called init. Mixin classes, on the other hand, can not define a method init (that would cause a conflict). For examples, see existing Strasheela extensions (e.g., contribution/anders/Motif/Motif.oz).
	 %% Also, all init method arguments should be optional.
	 %% */
	 %% !! TODO : check init value...
      meth init(foo:Foo<=_ ...) = M
	 %% call superclass with all init args but foo
	 Score.temporalElement, {Record.subtractList M
				 [foo]}
	 %% Create new foo parameter object and bind it to attribute foo.
	 %% NB: a parameter object is always used for storing constrained variables, and in the present implementation only FD ints are supported (true?).
	 %% Background information: All parameter values are initialised to a FD int by Score.initScore (called by Score.makeScore).
	 @foo = {New Score.parameter init(value:Foo info:foo)}
	 %% Create links be self and parameter at foo (extends self attribute parameters and foo attribute item)
	 {self bilinkParameters([@foo])}
	 %% Add more stuff here (e.g. post some class specific constraints)
	 %% ... 
      end

      /** %% Accessor for foo parameter value (i.e. a FD int).
      %% */
      meth getFoo($) {@foo getValue($)} end
      /** %% Accessor for foo parameter object
      %% */
      meth getFooParameter($) @foo end

      /** %% For creating the textual representation from self: add reflective information about the init method.
      %% */
      meth getInitInfo($ exclude:Excluded)
	 unit(%% Specifies superclass of TestClass
	      superclass:Score.temporalElement
	      %% Specifies additional init args defined by TestClass (here only foo), its accessor method (can be a method or a function), and its default value (can be noMatch for init args which are mandatory and have no default).   
	      args:[foo#getFoo#{FD.decl}])
      end
   
   end
   /** %% Type checker.
   %% */
   fun {IsTestClass X}
      {Score.isScoreObject X} andthen {HasFeature X TestClassType}
   end

end
