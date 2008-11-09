
/** %% This functor defines an abstraction for using numerical functions as envelopes (function envelopes, or "fenvs"), and provides a rich set of functions/methods to generate, combine and transform these envelopes.
%%
%% See testing/Fenv-test.oz for examples (using a Gnuplot interface for envelope visualisation).
%%
%% NB: This functor aims for a high degree of flexilibity in envelope creation and manipulation instead of efficiency. But nowadays, machines are rather fast... 
%% */

%%
%% Status: almost all of the original func-env Lisp library has been ported to Oz here.
%% Missing:
%%
%%  - transformation of fenv into a Common Music pattern, which can be nested with other CM patterns etc (that is not possible to port to Oz, as CM is a Lisp library)
%%  - use of fenvs for creating random distribution
%% 
%%
%%

functor
   
import
%    System
%    Browser(browse:Browse) % temp for debugging
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   GPlot(plot:Plot) at 'x-ozlib://anders/strasheela/Gnuplot/Gnuplot.ozf'
   
export
   Fenv
   IsFenv
   FenvSeq FuncsToFenv Osciallator

   PointsToFenv LinearFenv SinFenv SinFenv2

   ConstantFenv
   SinOsc Saw Triangle Square Pulse
   
   ReverseFenv InvertFenv Reciprocal

   %% !! to test
   CombineFenvs ScaleFenv RescaleFenv
   Waveshape
   FenvSection

   Integrate
   TempoCurveToTimeMap TempoCurveToTimeShift
   TimeShiftToTimeMap TimeMapToTimeShift
   ConcatenateTempoCurves
   
   TemporalFenvY ItemFenvY
   
   FenvToMidiCC ItemFenvToMidiCC
   ItemFenvsToMidiCC ItemTempoCurveToMidi
   RenderAndPlayMidiFile
   
prepare
   FenvType = {Name.new}
   
define

   /** %% Defines a data structure for envelopes based on the notion of numeric functions (a function envelope or "fenv").
   %% */
   class Fenv
      feat !FenvType:unit
      attr env

	 /** %% Builds a env from a given numeric function. Env is a unary numeric function which expects and returns a float. If RangeIsForArgumentFun is true, then the interval [0,1] of the resulting fenv is mapped to [min, max] of the argument function. Otherwise, the interval [min,max] of the resulting fenv is mapped to [0,1] of the argument function.
	 %% NB: init blocks as long as Env is undetermined (Env is only an optional argument because the Score.scoreObject method getInitClassesVS requires this for score archiving).
	 %% */
	 %% !! accessing an envelope value outside its range is explicitly disabled here. Is that too strict? Is that too costly (done for every embedded env!)?
      meth init(env:Env<=_ min:Mn<=0.0 max:Mx<=1.0
		rangeIsForArgumentFun:RangeIsForArgumentFun<=true)
	 if RangeIsForArgumentFun
	 then 
	    @env = fun {$ X}
		      if {Not (0.0 =< X andthen X =< 1.0)}
		      then
			 {Exception.raiseError
			  strasheela(failedRequirement X
				     "Must be in [0.0, 1.0]")}
		      end
		      {Env Mn + (X * (Mx - Mn))}
		   end
	 else
	    @env = fun {$ X}
		      if {Not (Mn =< X andthen X =< Mx)}
		      then {Exception.raiseError
			    strasheela(failedRequirement X
				       "Must be in ["#Mn#", "#Mx#"]")}
		      end
		      {Env (X - Mn) / (Mx - Mn)}
		   end
	 end
      end

      /** %% Returns the unary numeric function of self.
      %% */
      meth getEnv($) @env end
      
      /** %% Access the y value (a float) of fenv at X (a float). 
      %% */
      meth y($ X) {@env X} end

      /** %% Samples the fenv from 0.0 to 1.0 (including) and collects samples in a list. N is the number of samples (an integer). If N=1, only the last env value is returned. Returns a list of floats.
      %% */
      meth toList($ N<=100)
	 if N==1 then {self y($ 1)}
	    %% tmp: for i from 0 to 1 by (/ 1 (1- n))
	 else N1 = {IntToFloat N-1} in
	    for I in 0..N-1  collect:C do
	       {C {self y($ {IntToFloat I}/N1)}}
	    end 
	 end
      end
      /** %% Same as toList, but rounds the results to integers. The output can be scaled (before the rounding) with the summand Add and factor Mul (both floats). 
      %% */
      meth toList_Int($ N<=100 add:Add<=0.0 mul:Mul<=1.0)
	 {Map {self toList($ N)} fun {$ X} {FloatToInt X*Mul+Add} end}
      end
      /** %% Samples the fenv from 0.0 to 1.0 (including) and collects the x-y-pairs as sublists in a list: [[X1 Y1] ... [Xn Yn]]. N is the number of samples (an integer). If N=1, only the last env value is returned. 
      %% */
      meth toPairs($ N<=100)
	 if N==1 then {self y($ 1)}
	    %% tmp: for i from 0 to 1 by (/ 1 (1- n))
	 else N1 = {IntToFloat N-1} in
	    for I in 0..N-1  collect:C do
	       X = {IntToFloat I}/N1
	    in
	       {C [X {self y($ X)}]}
	    end 
	 end
      end

      /** %% Plots the fenv by calling gnuplot in the background. N (an integer) is the number of fenv samples (see method toList). See the documentation of the procedure Gnuplot.plot for further arguments supported (the Gnuplot.plot args x and z are not supported).
      %% */
      %% !!?? is it more efficient to create xs values again (additional loop, IntoToFloat, and float division) or to LUtils.matTrans the output of toPairs?
      meth plot(n:N<=100 ...) = Args
	 {Plot {self toList($ N)}
	  {Adjoin {Record.subtractList Args [n z]}
	   unit(x:local N1 = {IntToFloat N-1} in
		     for I in 0..N-1  collect:C do
			{C {IntToFloat I}/N1}
		     end
		  end)}}
      end
      
   end

   /** %% Returns true if X is a Fenv instance and false otherwise.
   %% */
   fun {IsFenv X}
      {Not {GUtils.isFS X}} andthen % undetermined FS vars block on Object.is
      {Object.is X} andthen {HasFeature X FenvType}
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Fenv Generators
%%%

   
   local
      fun {Aux Fenvs Points}	% points: [0 ... 1]
	 %% !! inefficient: for every fenv value access, a fenv is created
	 {New Fenv
	  init(env:fun {$ X}
		      %% (position x points :test #'<)
		      %% !!?? < or >
		      Pos = {LUtils.findPosition Points fun {$ P} X < P end}
		      MyFenv = if Pos \= nil
			       then 
				  {New Fenv init(env:{{Nth Fenvs Pos-1} getEnv($)}
						 min:{Nth Points Pos-1}
						 max:{Nth Points Pos}
						 rangeIsForArgumentFun:false)}
			       else {List.last Fenvs}
			       end
		   in
		      {MyFenv y($ X)}
		   end)}
% 	 %% !!?? refactored above into the following -- OK??
% 	 Pos = {LUtils.findPosition Points fun {$ P} X < P end}
% 	 Fenv = if Pos \= nil
% 		then 
% 		   {New Fenv init(env:{{Nth Fenvs Pos-1} getEnv($)}
% 				  min:{Nth Points Pos-1}
% 				  max:{Nth Points Pos}
% 				  rangeIsForArgumentFun:false)}
% 		else {List.last Fenvs}
% 		end
%       in
% 	 Fenv
      end
   in
      /** %% Combines an arbitrary number of fenvs to a single fenv. Expects its args as a list in the form [fenv num fenv num ... fenv]. The numbers between the fenvs specify the start resp. end point of a certain fenv. All numbers should be between 0--1 (exclusive).
      %% */
      fun {FenvSeq FenvsAndPoints}
	 Points = {Append 0.0|{LUtils.everyNth FenvsAndPoints.2 2} [1.0]} % 0, <vals>, 1
	 Fenvs = {LUtils.everyNth FenvsAndPoints 2}
      in
	 {Aux Fenvs Points}
      end

      /** %% Converts a list of unary numeric functions to a single fenv. The arguments min and max a given for all functions and the functions are equally spaced in the fenv.
      %% */
      fun {FuncsToFenv Funcs Args}
	 Defaults = unit(min:0.0
			 max:1.0)
	 As = {Adjoin Defaults Args}
	 L = {IntToFloat {Length Funcs}}
	 Points = for I in 0..{FloatToInt L}  collect:C do
		     {C {IntToFloat I}/L}
		  end 
	 Fenvs = {Map Funcs fun {$ F}
			       {New Fenv init(env:F min:As.min max:As.max)}
			    end}
      in
	 {Aux Fenvs Points}
      end

      /** %% Defines a new fenv by repeating givenm fenv n times. 
      %% */
      fun {Osciallator MyFenv N}
	 Fenvs = {Map {MakeList N} fun {$ _} MyFenv end}
	 Nf = {IntToFloat N}
	 Points = for I in 0..N  collect:C do
		     {C {IntToFloat I}/Nf}
		  end
      in
	 {Aux Fenvs Points}
      end
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Segment fenvs
%%%

   /** %% Converts a list of points into a single env. A point is an x-y-pair as [Xi Yi]. X values of the points range from 0--i (including), e.g., [[0.0 Y1] [X2 Y2] ... [1.0 Yn]]. The function Func defines the shape of the fenv segments and must return a fenv. It expects a list of four numeric arguments, which describe the start and end points of the segment in the form [X1 Y1 X2 Y2].
   %% */
   fun {PointsToFenv Func Points}
      Xs = {Map Points fun {$ [X _]} X end}
      Ys = {Map Points fun {$ [_ Y]} Y end}
      Fenvs = {Map {LUtils.matTrans [{LUtils.butLast Xs}
				     {LUtils.butLast Ys}
				     Xs.2
				     Ys.2]}
	       Func}
   in
      {New Fenv init(env:fun {$ X}
			    Pos = {LUtils.findPosition Xs.2
				   fun {$ MyX} X =< MyX end}
			 in
			    {{Nth Fenvs Pos} y($ X)}
			 end)}
   end

   /** %% Defines a fenv which interpolates the given points by a linear function. Expects a list of x-y-pairs as [[0.0 Y1] ... [1.0 Yn]].
   %% */
   fun {LinearFenv Points}
      {PointsToFenv fun {$ [X1 Y1 X2 Y2]}
		       {New Fenv init(env:fun {$ X} (Y2-Y1) * X + Y1 end
				      min: X1
				      max: X2
				      rangeIsForArgumentFun:false)}
		    end
       Points}
   end

   /** %% Defines a fenv which interpolates the given points by a sin function, using a full wave length. This results in a fenv without edges, however, this fenv is rather 'curvy'. Expects a list of x-y-pairs as [[0.0 Y1] ... [1.0 Yn]].
   %% NB: in the lisp library, this was macro sin-env1.
   %% */
   fun {SinFenv Points}
      {PointsToFenv fun {$ [X1 Y1 X2 Y2]}
		       {New Fenv init(env:fun {$ X}
					     ({Sin X*GUtils.pi - 0.5*GUtils.pi}
					      * 0.5 + 0.5)
					     * (Y2-Y1)
					     + Y1
					  end
				      min: X1
				      max: X2
				      rangeIsForArgumentFun:false)}
		    end
       Points}
   end
   
   /** %% Defines a fenv which interpolates the given points by a sin function. Using only the intervals [0,pi/2] and [pi, 3pi/4], which results in edges but is less 'curvy' than SinFenv. Expects a list of x-y-pairs as [[0.0 Y1] ... [1.0 Yn]].
   %% NB: in the lisp library, this was macro sin-env.
   %% */
   fun {SinFenv2 Points}
      {PointsToFenv fun {$ [X1 Y1 X2 Y2]}
		       {New Fenv init(env:fun {$ X}
					     {Sin (X * GUtils.pi * 0.5)}
					     * (Y2-Y1)
					     + Y1
					  end
				      min: X1
				      max: X2
				      rangeIsForArgumentFun:false)}
		    end
       Points}
   end

   /*
%    ;; !!! noch voellig falsch: die Steilheit stimmt nicht !!!
%    (defun expon-env-fn (points)
%     (points->env #'(lambda (x1 x2 y1 y2)
% 			(make-env1 #'(lambda (x)
% 					    (+ (expt (/ y2 y1) x) y1 -1))
% 					:min x1 :max x2))
% 		    points))   
   */

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% 
%%%
    
   
   /*
   %% expects list values (which will be the result of sampling [i.e. transforming to a list] the returned Fenv by as many values as there are samples. Samples are interpolated by InterpolationFenv.
   %% Implementation uses tuple of samples for efficient access of the sample values relevant for given X.
   fun {SamplesToFenv Samples InterpolationFenv} end

   */

   /** %% Returns Fenv which outputs Y (a float) for any X.
   %% */ 
   fun {ConstantFenv Y}
      {New Fenv init(env:fun {$ _} Y end)}
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% A few oscillators
%%% !! Implementation not necessarily most efficient...
%%% !! no phase defined...
%%%

   /** %% Defines a fenv of sin shape with n periods. Args are mul and add, as for ScaleFenv.
   %% */
   fun {SinOsc N Args}
      Defaults = unit(mul:1.0
		      add:0.0)
      As = {Adjoin Defaults Args}
   in
      {ScaleFenv
       {New Fenv init(env:fun {$ X} {Sin X} end
		      min:0.0
		      max:GUtils.pi*2.0*{IntToFloat N})}
       unit(mul:As.mul
	    add:As.add)}
   end
   
   /** %% Defines a fenv of saw shape (ascending) with n periods. Args are mul and add, as for ScaleFenv.
   %% */
   fun {Saw N Args}
      Defaults = unit(mul:1.0
		      add:0.0)
      As = {Adjoin Defaults Args}
   in
      {ScaleFenv
       {Osciallator {New Fenv init(env:fun {$ X} 2.0*X - 1.0 end)}
	N}
       unit(mul:As.mul
	    add:As.add)}
   end

   /** %% Defines a fenv of triangle shape with n periods. Args are mul and add, as for ScaleFenv.
   %% */
   fun {Triangle N Args}
      Defaults = unit(mul:1.0
		      add:0.0)
      As = {Adjoin Defaults Args}
   in
      {ScaleFenv
       {Osciallator {LinearFenv [[0.0 ~1.0] [0.5 1.0] [1.0 ~1.0]]}
	N}
       unit(mul:As.mul
	    add:As.add)}
   end

   /** %% Defines a fenv of square shape with n periods. Args are mul and add, as for ScaleFenv.
   %% */
   fun {Square N Args}
      Defaults = unit(mul:1.0
		      add:0.0)
      As = {Adjoin Defaults Args}
   in
      {ScaleFenv
       {Osciallator {New Fenv init(env:fun {$ X}
					  if X < 0.5
					  then ~1.0
					  else 1.0
					  end
				       end)}
	N}
       unit(mul:As.mul
	    add:As.add)}
   end
   
   /** %% Defines a fenv of pulse shape with n periods. Args are min (lowest value), max (highest value), and width (pulse width between 0.0 and 1.0). The oscillator starts with the highest value. 
   %% */
   fun {Pulse N Args}
      Defaults = unit(min:~1.0
		      max:1.0
		      width:0.5)
      As = {Adjoin Defaults Args}
   in
      {Osciallator {FenvSeq [{ConstantFenv As.max}
			     As.width
			     {ConstantFenv As.min}]}
       N}
   end

   /*
   %% Outputs a fenv composed of (evenly distributed) constant functions defined by numbers.
   %% 
   fun {Steps Numbers}
      {FuncsToFenv {Map Numbers fun {$ Num} fun {$ _} Num end end}}
   end

   fun {RandomSteps N Args}      
      Defaults = unit(min:~1.0
		      max:1.0)
      As = {Adjoin Defaults Args}
   in
      {Steps
       for _ in 1..N  collect:C do
	  %% create random number between As.min and As.max
	  %%
	  %% {GUtils.random Max} returns integer  in interval [0, Max-1]...
	  {C }
       end

       for N do }
   end
   */
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Fenv transformations
%%%

   

   /** %% Reverses MyFenv (i.e. flips it at x=0.5).
   %% NB: ReverseFenv is defined only for the valid Fenv domain 0.0 .. 1.0.
   %% */
   fun {ReverseFenv MyFenv}
      {New Fenv init(env:fun {$ X} {MyFenv y($ 1.0-X)} end)}
   end

   /** %% Inverses MyFenv (i.e. flips it at y=0.0).
   %% */
   fun {InvertFenv MyFenv}
      {New Fenv init(env:fun {$ X} {MyFenv y($ X)} * ~1.0 end)}
   end
   
   /** %% Returns a Fenv which is the reciprocal of the given Fenv, i.e., 1/fenv.
   %% */
   fun {Reciprocal MyFenv}
      {New Fenv init(env:fun {$ X} 1.0 / {MyFenv y($ X)} end)}
   end
   

   /** %% Returns a fenv which combines the given fenvs with an n-ary numeric function. Fenvs is a list which consists of fenvs and floats (representing constant fenvs) in any order. The combine-func expects a list with as many floats as correspond to Fenv values (in their order and at the same x), and returns a float.
   %% */
   fun {CombineFenvs CombiFunc Fenvs}
      {New Fenv init(env:fun {$ X}
			    {CombiFunc
			     {Map Fenvs
			      fun {$ MyFenv}
				 if {IsFloat MyFenv} then MyFenv
				 elseif {IsFenv MyFenv}
				 then {MyFenv y($ X)}
				 else
				    {Exception.raiseError
				     strasheela(failedRequirement MyFenv
						"Must be either float or fenv")}
				    unit % never returned
				 end
			      end}}
			 end)}
   end
   

   /** %% Scale MyFenv with Args: arg mul is factor and arg add is summand (addend). 
   %% */
   fun {ScaleFenv MyFenv Args}
      Defaults = unit(mul:1.0
		      add:0.0)
      As = {Adjoin Defaults Args}
   in
      %% !! CombineFenvs calls buggy: enter fun expecting list
      {CombineFenvs fun {$ [X Y]} X + Y end 
       [As.add
	{CombineFenvs fun {$ [X Y]} X * Y end [As.mul MyFenv]}]}
   end

   /** %% Returns a new Fenv which rescales the given y-range of MyFenv (defaults: oldmin:~1.0, oldmax:1.0) into a new range (defaults: newmin:0.0, newmax:1.0).
   %% All these four arguments can be fenvs as well.
   %%
   %% !! NB: RescaleFenv is buggy. Problems with neg. numbers (see examples). 
   %% */
   %% see CM 2.3.4 definition of rescale
   fun {RescaleFenv MyFenv Args}
      Defaults = unit(oldmin:~1.0
		      oldmax:1.0
		      newmin:0.0
		      newmax:1.0)
      As = {Adjoin Defaults Args}
   in
      {CombineFenvs fun {$ [X Y]} X + Y end 
       [{CombineFenvs fun {$ [X Y]} X * Y end 
	 [{CombineFenvs fun {$ [X Y]} X / Y end 
	   [{CombineFenvs fun {$ [X Y]} X - Y end [As.newmax As.newmin]}
	    {CombineFenvs fun {$ [X Y]} X - Y end [As.oldmax As.oldmin]}]}
	  {CombineFenvs fun {$ [X Y]} X + Y end [MyFenv As.oldmin]}]}
	As.newmin]}
   end

   /** %% Returns a fenv which reads Fenv1 'through' Fenv2: the y value of Fenv2 (at a given x value) is used as x for Fenv1. to access the y of Fenv1 (the y of Fenv1 is returned). Compared with waveshaping in signal processing, Fenv1 is the "transfer function" and Fenv2 is the "input signal". 
   %% NB: Take care to keep the output of fenv2 in interval [0,1].
   %%
   %% NB: for more simple use, I should think about more complex def which allows for Fenv2 values going beyond the interval [0,1] (or be automatically scaled into that interval). I could use a plain function as transfer function, but using the tools for generating fenvs can be helpful. Alternatively, I can simply remove the condition which restricts fenvs to [0,1].  
   %% */
   %% !! TODO: rethink this approach...
   fun {Waveshape Fenv1 Fenv2}
      {New Fenv init(env:fun {$ X} {Fenv1 y($ {Fenv2 y($ X)})} end)}
   end
   

   /** %% Returns fenv which is a section of given fenv. y value at 0/1 of returned fenv is y value of given fenv at min/max. Both min and max must be in the interval [0, 1].
   %% */
   fun {FenvSection MyFenv Args}      
      Defaults = unit(max:1.0
		      min:0.0)
      As = {Adjoin Defaults Args}
   in
      if {Not ((0.0 =< As.min andthen As.min =< 1.0) andthen
	       (0.0 =< As.max andthen As.max =< 1.0))}
      then
	 {Exception.raiseError
	  strasheela(failedRequirement [As.min As.max]
		     "Must be both in [0.0, 1.0]")}
      end
      {New Fenv init(env: {MyFenv getEnv($)}
		     min:As.min
		     max:As.max)}
   end

   /*

   ;; noise...

   ;; hp-filter (env)
   ;; lp-filter (env)
   */


   /** %% Returns the integral fenv of fenv. 
   %% Performs numerical integration internally whenever a value of the returned fenv is accessed, which can be computationally expensive.
   %% Step (a float in [0.0 0.5]) specifies the resolution of the numeric integration: the smaller Step, the more accurate the integration and the more expensive the computation. Step=0.01 results in 100 "function slices".
   %%
   %% Note: implementation currently always uses Simpson's rule rule for the approximation (based on a polynomial of order 2, pretty good :), it case this is too computationally expensive, could be made user-controllable if necessary (see implementation).
   %% */
   %% Note: I tried to improve the efficiency by memoization, but without success. Memoizing the integration of a single "function slice" is less efficient than recomputing it, and memoizing the integration of an inceasing function interval does not work, because my memoization does not work for recursive functions (I can not overwrite the definition of a function, and recursively calling the memoized function had no effect -- I really tried this for hours!).
   %% NOTE: instead of 'simply' memoizing the function CompositeIntegral, I may do the internal caching manually. I would redefine CompositeIntegral to expect to integers, and change various details accrodingly: e.g., in the call to CompositeIntegral, X would be transformed into an integer {FloatToInt X/Step}. For the call to MyDefIntegral I then need floats again..
   %% However, after the many attempts with memoization so far I am not sure whether this is worth the effort
   fun {Integrate MyFenv Step}
      %%  select approximation
%       MyDefIntegral = DefiniteIntegral_Trapezoidal
      MyDefIntegral = DefiniteIntegral_Simpson
      F = {MyFenv getEnv($)}
      /** %% Returns the definite integral of function F in [A, B] (two floats), approximation uses Step (a float) size between A and B.
      %% */
      %% memoize CompositeIntegral: A and B must be computed into 'grid' of Step for memoization to work -- outside this function. So, I should convert A and B to integers for the memoized function, and back to a float for calling MyDefIntegral
      %% However, Memo.memoize does not work recursively (I really tried!). 
      fun {CompositeIntegral A B}
	 B2 = B-Step 
      in
	 if B2 =< 0.0
	 then {MyDefIntegral F A B}
	 else 
	    {MyDefIntegral F B2 B} + {CompositeIntegral A B2}
	 end
      end
   in
      {New Fenv
       init(env:fun {$ X} {CompositeIntegral 0.0 X} end)}
   end
% proc {IntegrateFenv MyFenv Step ?Result}
%    MyDefIntegral = DefiniteIntegral_Trapezoidal % select approximation
% %   ClearMemoFun 
%    DefIntegral_Memo = {Memo.memoize
% 		       fun {$ [A B]} {MyDefIntegral {MyFenv getEnv($)} A B} end
% %		       ClearMemoFun
% 		       _}
%    %% test: no memoization
% %   DefIntegral_Memo = fun {$ [A B]} {MyDefIntegral {MyFenv getEnv($)} A B} end
%    /** %% Returns the definite integral of function F in [A, B] (two floats), approximation uses Step (a float) size between A and B.
%    %% */ 
%    fun {CompositeIntegral A B}
%       %% from A to B with Step-size 
%       Xs = for X in A;X=<B;X+Step
% 	      collect:C
% 	   do
% 	      {C X}
% 	   end
%    in
%       %% If A==B then Pattern.map2Neighbours returns nil, because {Length Xs}==1
%       if A < B
%       then
%  	 {LUtils.accum {Pattern.map2Neighbours Xs
% 			fun {$ A_i B_i} {DefIntegral_Memo [A_i B_i]} end}
% 	  Number.'+'}
%       else A 			% TODO: tmp solution (seems OK so far..)
%       end
%    end 
% in
%   Result = {New Fenv.fenv
% 	    init(env:fun {$ X} {CompositeIntegral 0.0 X} end)}
% end
   /** %% [Aux] Returns the definite integral of function F in [A, B] (two floats). Implemented with Trapezium rule, http://en.wikipedia.org/wiki/Trapezoidal_rule.
   %% Alternative options, e.g., Quadratic interpolation Simpson's rule, http://en.wikipedia.org/wiki/Simpson%27s_rule. Wikipedia 'http://en.wikipedia.org/wiki/Numerical_integration' points to even more.  
   %% */
%    fun {DefiniteIntegral_Trapezoidal F A B}
%       (B-A) * ({F A} + {F B}) / 2.0
%    end
   %% [Aux] Returns the definite integral of function F in [A, B] (two floats), implements Simpson's rule, based on a polynomial of order 2 
   fun {DefiniteIntegral_Simpson F A B}
      (B-A) / 6.0 * ({F A} + (4.0 * {F (A + B)/2.0}) + {F B})
   end


   
   /** %% Transforms a fenv expressing a normalised tempo curve into a fenv expressing a normalised time map. Step (a float) specifies the precision (and efficiency!) of the transformation, see Integrate's doc for details. A tempo curve expresses a tempo factor, i.e., f(x) = 1 results in no tempo change. A normalised time map maps score time to performance time. 
   %% Private Terminology: normalised time shift functions, time map functions and tempo curves: fenvs where x values denote the score time (usually of a temporal container) which is mapped into [0,1]: 0 corresponds to the container's start time, and 1 corresponds to the container's end time. See ContainerFenvY.
   %% NB: normalised time map fenvs cannot be combined by function combination (x values for fenvs are always in [0,1]). Instead, either combine tempo curve and time shift fenvs, or combine plain and un-normalised time map functions (i.e. no fenvs).
   %% */
   fun {TempoCurveToTimeMap MyFenv Step}
      {Integrate {Reciprocal MyFenv}
       Step}
   end
   /** %% ... this is probably not a good idea, but works for certain cases.
   %% */
   fun {TempoCurveToTimeShift MyFenv Step}
      {TimeMapToTimeShift {TempoCurveToTimeMap MyFenv Step}}
   end

   /** %% Expects a fenv representing a normalised time shift function and returns a fenv representing a normalised time map function. A time shift function expresses how much is added to a score time to yield a performance time, i.e., f(x) = 0 causes performance time to be score time. A normalised time map maps score time to performance time.
   %% Private Terminology: normalised time shift functions, time map functions and tempo curves: fenvs where x values denote the score time (usually of a temporal container) which is mapped into [0,1]: 0 corresponds to the container's start time, and 1 corresponds to the container's end time. See ContainerFenvY.
   %% NB: normalised time map fenvs cannot be combined by function combination (x values for fenvs are always in [0,1]). Instead, either combine tempo curve and time shift fenvs, or combine plain and un-normalised time map functions (i.e. no fenvs).  
   %% */
   fun {TimeShiftToTimeMap TS}
      {ScaleFenv TS unit(add:{New Fenv init(env:fun {$ X} X end)})}
   end
   /** %% ... this is perhaps not a good idea, but works for certain cases.
   %% */
   fun {TimeMapToTimeShift MyFenv}
      {ScaleFenv MyFenv unit(add:{New Fenv init(env:fun {$ X} ~X end)})}
   end

   
   /** %% Concatenates a sequence of successive tempo curve fenvs. Specs is a list of pairs and has the form [Fenv1#Dur1 Fenv2#Dur2 ... FenvN#DurN], where FenvI is a tempo curve fenv and DurI (a float) is the score time duration of this tempo curve. Returned is a single tempo curve fenv.
   %% NB: in most use-cases the sequence of successive tempo curve fenvs should start at score time 0 and span over the entire score so that the global tempo curve fenv is the result. If you concatenate a tempo curve sequence which does not start at score time 0, you should decide whether the resulting tempo curve fenv starts at the performance or score start time of its first sub-tempo curve (i.e., whether a smooth continuation of previous tempo changes is intended or not). 
   %% */
   fun {ConcatenateTempoCurves Specs}
      %% for each point, add all durations up to point 
      fun {DursToPoints Specs Acc}
	 case Specs of nil then nil
	 else Fenv Dur X in
	    Fenv#Dur = Specs.1 
	    X = Acc + (Dur / TotalDur) 
	    [Fenv X] | {DursToPoints Specs.2 X}
	 end
      end
      TotalDur = {LUtils.accum {Map Specs fun {$ _#Dur} Dur end}
		  Number.'+'}
      FenvsAndPoints = {Append
			{LUtils.accum {DursToPoints Specs 0.0} Append}
			%% skip the last duration
			[{List.last Specs}.1]}
   in
      {FenvSeq FenvsAndPoints}
   end
   
   
   /** %% Accesses the y-value of MyFenv which starts at time point Start (a float) for time interval Duration (a float). The fenv x-value 0.0 corresponds to the start time and the fenv x-value 1.0 coresponds to the resulting end time. MyTime (a float) is any time between the start and end time. All times are score times measured in the same time unit.
   %% */
   fun {TemporalFenvY MyFenv Start Duration MyTime}
      FenvX = (MyTime-Start) / Duration
   in
      {MyFenv y($ FenvX)}
   end
   
   /** %% Accesses the y-value of MyFenv which is associated with a temporal item MyItem. The fenv x-value 0.0 corresponds to the item's start time and the fenv x-value 1.0 coresponds to the item's end time. MyTime (a float) is any time between MyItem's start and end time. MyTime is a score time measured in the time unit of MyItem.
   %% */
   fun {ItemFenvY MyFenv MyItem MyTime}
      {TemporalFenvY MyFenv
       {IntToFloat {MyItem getStartTime($)}}
       {IntToFloat {MyItem getDuration($)}}
       MyTime}
   end
   

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Fenv output transformations 
%%%
   
   /** %% Transforms a Fenv into a list of continuous MIDI controller events. N events are output between StartTime and EndTime (two ints, given in MIDI ticks) at Channel (an int). 
   %% Controller denotes which controller is output. Possible values are one of the atoms pitchbend, and channelAftertouch, or one of the pairs cc#Number (Number is the controller number) and polyAftertouch#Note (Note denotes the note pitch). 
   %% Finally, Controller can be a function expecting 4 arguments and returning a MIDI event. For example, the volume Controller can be defined as follows
   fun {$ Track Time Channel Value}
      {Out.midi.makeCC Track Time Channel 7 Value}
   end
   %% NOTE: no implicit support for any tempo curves etc. Instead, adapt StartTime and EndTime (and possibly transform MyFenv) outside FenvToMidiCC.
   %% */
   fun {FenvToMidiCC MyFenv N Track StartTime EndTime Channel Controller}
      Times = {Map {LUtils.arithmeticSeries {IntToFloat StartTime}
		    ({IntToFloat EndTime-StartTime} / {IntToFloat N})
		    N}
	       FloatToInt}
   in
      {Map {LUtils.matTrans [Times
			     {Map {MyFenv toList($ N)} FloatToInt}]}
       fun {$ [Time Value]}
	  case Controller
	  of pitchbend then {Out.midi.makePitchBend Track Time Channel Value}
	  [] channelAftertouch then {Out.midi.makeChannelAftertouch Track Time Channel Value}
	  [] cc#Number then {Out.midi.makeCC Track Time Channel Number Value}
	  [] polyAftertouch#Note then {Out.midi.makePolyAftertouch Track Time Channel Note Value}
	  else %% Controller is function
	     {Controller Track Time Channel Value}
	  end	  
       end}
   end

   /** %% Like FenvToMidiCC, but here the Fenv is associated with a temporal item MyItem, whose start and end times are taken. 
   %% NOTE: no support for any tempo curves etc. 
   %% */ 
   fun {ItemFenvToMidiCC MyFenv N Track MyItem Channel Controller}
      StartTime = {Out.midi.beatsToTicks {MyItem getStartTimeInSeconds($)}}
      EndTime = {Out.midi.beatsToTicks {MyItem getEndTimeInSeconds($)}}
   in
      {FenvToMidiCC MyFenv N Track StartTime EndTime Channel Controller}
   end

   
   /** %% Expects a temporal item which defines fenvs in a info-tag 'fenvs', and returns a list of continuous MIDI controller events for all its fenvs. Each fenvs is defined by a pair Controller#Fenv, where Controller can take all values defined for FenvToMidiCC. Fenvs directly specify the controller values (e.g., if Controller is pitchBend, then the Fenv range is 0.0 to 16383.0, and the value 8192.0 means no pitchbend). Note that for any controller only a single Fenv should be defined at any time (otherwise they conflict with each other).
   %% Example: fenvs((cc#1)#{Fenv.linearFenv [[0.0 0.0] [1.0 127.0]]}) 
   %%
   %% Args:
   %% ccsPerSecond: how many CC events are created per second.
   %% track: MIDI track to output, default 2 (suitable for more cases)
   %% channel: midi channel to output, default nil (if nil, MIDI note object CCs are output to its channel and all other to channel 0) 
   %%
   %% Timeshift fenvs affect the start and end of the continuous MIDI controller events, but not their "spacing".
   %% */
   fun {ItemFenvsToMidiCC MyItem Args}
      Defaults = unit(track:2
		      channel:nil
		      ccsPerSecond: 10)
      As = {Adjoin Defaults Args}
      DefaultMidiChan = 0
      Channel = if  As.channel \= nil
		then As.channel
		elseif {Out.midi.isMidiNoteMixin MyItem}
		then {MyItem getChannel($)}
		else DefaultMidiChan
		end
      Fenvs = {MyItem getInfoRecord($ fenvs)}
      N = {FloatToInt {MyItem getDurationInSeconds($)} * {IntToFloat As.ccsPerSecond}}
   in
      {LUtils.mappend {Record.toList Fenvs}
       fun {$ Controller#MyFenv}
	  StartTime = {Out.midi.beatsToTicks {MyItem getStartTimeInSeconds($)}}
	  EndTime = {Out.midi.beatsToTicks {MyItem getEndTimeInSeconds($)}}
       in
	  {FenvToMidiCC MyFenv N As.track StartTime EndTime Channel Controller}
       end}
   end
      
   /** %% Expects a temporal item which defines a tempo curve Fenv in a info-tag 'globaltempo', and returns a list of MIDI tempo events. Returns nil in case MyItem defines no tempo curve. The tempo fenv values are in beats per minute. Due to restrictions of the MIDI protocoll, only a single global tempo is supported (note that sequencers may restrict the import of such data in a MIDI files). If multiple tempi are defined "in parallel" or nested, then "conflicting" MIDI tempo events are output.
   %% Example: globaltempo({Fenv.linearFenv [[0.0 30.0] [1.0 240.0]]})
   %%
   %% Args:
   %% ccsPerSecond: how many tempo events are created per second.
   %% track: MIDI track to output, default 2 (suitable for more cases)
   %%
   %% Time shift fenvs affect the start and end of the tempo events, but not their "spacing".
   %% */
   fun {ItemTempoCurveToMidi MyItem Args}
      Defaults = unit(track:2
		      ccsPerSecond: 10)
      As = {Adjoin Defaults Args}
      TempoInfo = {MyItem getInfoRecord($ globaltempo)} 
   in
      if TempoInfo \= nil then
	 Tempo = TempoInfo.1
	 N = {FloatToInt {MyItem getDurationInSeconds($)} * {IntToFloat As.ccsPerSecond}}
	 StartTime = {Out.midi.beatsToTicks {MyItem getStartTimeInSeconds($)}}
	 EndTime = {Out.midi.beatsToTicks {MyItem getEndTimeInSeconds($)}}
      in
	 {FenvToMidiCC Tempo N As.track StartTime EndTime _/*Channel*/
	  fun {$ Track Time _/*Channel*/ Value}
	     %% implicitly, transform beats per minute to MIDI tempo value
	     {Out.midi.makeTempo Track Time
	      {Out.midi.beatsPerMinuteToTempoNumber Value}}
	  end}
      else nil
      end
   end


   
   /** %% This procedure is like Out.midi.renderAndPlayMidiFile, but it additional supports continuous controllers and a global tempo curve, expressed in the score by fenvs. 
   %%
   %% Supported score format:
   %% 
   %% The info-tag 'channel', given to a temporal item, sets the MIDI channel for this item and all contained items. Example: channel(0). If a channel is defined multiple times, then a setting in a lower hierarchical level overwrites higher-level settings.
   %%
   %% The info-tag 'program', given to a temporal item, results in a program change message with the specified program number at the beginning of the item. Example. program(64). Many instruments number patches from 1 to 128 rather than the 0 to 127 used within MIDI files. When interpreting ProgramNum values, note that they may be one less than the patch numbers given in an instrument's documentation.
   %%
   %% The info-tag 'fenvs', given to a note or temporal container, specifies a tuple of continuous controllers for the duration this item. Each Fenv spec is a pair Controller#Fenv, where Controller is defined as for Fenv.fenvToMidiCC. Example: (cc#1)#MyFenv. Fenvs directly specify the controller values (e.g., if Controller is pitchBend, then the Fenv range is 0.0 to 16383.0, and the value 8192.0 means no pitchbend). Note that for any controller only a single Fenv should be defined at any time (otherwise they conflict with each other).
   %%
   %% The info-tag 'timeshift', given to a temporal container, specifies a time shift function (a fenv). Example: timeshift(MyTimeshiftFenv). Time shift values are specified as time value offsets in the present timeUnit. For example, if a note has the start time 42 and its container specifies a time shift fenv with the y-value -1.0 corresponding to the start time of this note, then the MIDI note on happens at time 41. Hierarchical nesting of time shift functions is supported: if in the example above this note is recursively contained in other containers which also specify a time shift fenv, then their y-values for the note are added to the note's start time as well. Time shift fenvs also affect the timing of CC fenvs.
   %%
   %% The info-tag 'globaltempo', given to a temporal container, specifies a tempo curve (a fenv) and is output as MIDI tempo events. Example: globaltempo(MyTempoFenv). Tempo values are specified in BPM. Due to restrictions of the MIDI protocoll, only a single global tempo is supported (note that sequencers may restrict the import of such data in a MIDI files). If multiple tempi are defined "in parallel" or nested, then "conflicting" MIDI tempo events are output.
   %%
   %% All arguments of Out.midi.renderAndPlayMidiFile are supported. RenderAndPlayMidiFile is defined by calling Out.midi.renderAndPlayMidiFile with special clauses (namely for the tests isNote, and Score.isTemporalContainer). Clauses given to RenderAndPlayMidiFile are again appended at the beginning of the list of clauses (and so potentially overwrite the clauses defined by this procedure).
   %%
   %% Additional arguments.
   %% ccsPerSecond: how many continuous controller events are created per second for every Fenv (the spacing of CC events may be affected).
   %%
   %% NOTE: timing/spacing of continuous controller events and tempo curves etc. are _not_ affected by timeshift fenvs (but their start and end are). 
   %% */
   %% Probably, it is a good thing that CC etc are not affected by timeshift functions, as it is more efficient.
   proc {RenderAndPlayMidiFile MyScore Args}
      Defaults = unit(%% Process containers for output as well
		      scoreToEventsArgs:unit(test:fun {$ X}
						     {X isItem($)} andthen {X isDet($)}
						     andthen {X getDuration($)} > 0
						  end)
		      clauses:nil
		      track:2
		      %% new arg
		      ccsPerSecond:10)
      As = {Adjoin Defaults Args}
   in
      {Out.midi.renderAndPlayMidiFile MyScore
       {Adjoin
	%% remove args not supported by Out.midi.renderAndPlayMidiFile
	{Record.subtractList As [ccsPerSecond]}
	unit(clauses:
		{Append As.clauses 
		 [%% Note output: output Micro-CC message, note on/off, and all its fenvs (if defined)
		  isNote
		  #fun {$ N}
		      ChanAux = {Out.midi.getChannel N}
		      Chan = if ChanAux==nil then 0 else ChanAux end  
		      Progam = {N getInfoRecord($ program)}
		   in
		      {LUtils.accum
		       [if Progam==nil then nil
			else 
			   [{Out.midi.makeProgramChange As.track
			     {Out.midi.beatsToTicks {N getStartTimeInSeconds($)}}
			     Chan Progam.1}]
			end
			{Out.midi.noteToMidi N unit(channel:Chan
						    round:Round)}
			{ItemFenvsToMidiCC N unit(channel:Chan
						  ccsPerSecond:As.ccsPerSecond)}]
		       Append}
		   end
		  %% Container with fenv(s) output: output all its fenvs, and tempo curve (if defined)
		  Score.isTemporalContainer
		  #fun {$ C}
		      ChanAux = {Out.midi.getChannel C}
		      Chan = if ChanAux==nil then 0 else ChanAux end
		      Progam = {C getInfoRecord($ program)}
		   in
		      {LUtils.accum
		       [if Progam==nil then nil
			else 
			   [{Out.midi.makeProgramChange As.track
			     {Out.midi.beatsToTicks {C getStartTimeInSeconds($)}}
			     Chan Progam.1}]
			end
		       {ItemFenvsToMidiCC C
			unit(channel:Chan
			     ccsPerSecond:As.ccsPerSecond)}
		       {ItemTempoCurveToMidi C
			unit(ccsPerSecond:As.ccsPerSecond)}]
		       Append}
		   end
		 ]}
	    )}}
   end

   
end

