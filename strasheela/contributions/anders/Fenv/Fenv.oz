
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
   Browser(browse:Browse) % temp for debugging
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   GPlot(plot:Plot) at 'x-ozlib://anders/strasheela/Gnuplot/Gnuplot.ozf'
   
export
   Fenv
   IsFenv
   FenvSeq FuncsToFenv Osciallator

   PointsToFenv LinearFenv SinFenv SinFenv2

   ConstantFenv
   SinOsc Saw Triangle Square Pulse
   
   ReverseFenv InvertFenv

   %% !! to test
   CombineFenvs ScaleFenv RescaleFenv
   Waveshape
   FenvSection

   Fenv2MidiCC
   
prepare
   FenvType = {Name.new}
   
define

   /** %% Defines a data structure for envelopes based on the notion of numeric functions (a function envelope or "fenv").
   %% */
   class Fenv
      feat !FenvType:unit
      attr env

	 /** %% Builds a env from a given numeric function. Env is a unary numeric function which expects and returns a float. If RangeIsForArgumentFun is true, then the interval [0,1] of the resulting fenv is mapped to [min, max] of the argument function. Otherwise, the interval [min,max] of the resulting fenv is mapped to [0,1] of the argument function.
	 %% */
	 %% !! accessing an envelope value outside its range is explicitly disabled here. Is that too strict? Is that too costly (done for every embedded env!)?
      meth init(env:Env min:Mn<=0.0 max:Mx<=1.0
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

      /** %% Samples the fenv from 0.0 to 1.0 (including) and collects samples in a list. N is the number of samples (an integer). If N=1, only the last env value is returned. 
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


   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Fenv output transformations 
%%%

   /* %% Transforms a Fenv into a list of continuous MIDI controller events. N events are output between StartTime and EndTime at Channel. 
   %% Controller denotes which controller is output. Possible values are one of the atoms pitchbend, and channelAftertouch, or one of the pairs cc#Number (Number is the controller number) and polyAftertouch#Note (Note denotes the note pitch). 
   %% */
   fun {Fenv2MidiCC MyFenv N Track StartTime EndTime Channel Controller}
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
	  end	  
       end}
end

   
end

