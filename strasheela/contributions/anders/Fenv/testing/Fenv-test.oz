
declare 
[GPlot Fenv] = {ModuleLink ['x-ozlib://anders/strasheela/Gnuplot/Gnuplot.ozf'
			    'x-ozlib://anders/strasheela/Fenv/Fenv.ozf']}


{Browse {{New Fenv.fenv init(env:fun {$ X} X end)} toList($ 10)}}

%% NB: the last value is actually slighly larger than 1.0, due to the impreciseness of floats.
{Browse 
 {List.last {{New Fenv.fenv init(env:fun {$ X} X end)} toList($ 10)}} - 1.0}


%% rangeIsForArgumentFun=false: input 2.0--5.0 mapped only 0.0--1.0
{{New Fenv.fenv init(env:fun {$ X} X end
		     min:2.0
		     max:5.0
		     rangeIsForArgumentFun:false
		    )}
 y($ 2.0)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% plotting a fenv (no value returned)
%%

{GPlot.plot {{New Fenv.fenv init(env:fun {$ X} X end)} toList($ 10)} unit}

{{New Fenv.fenv init(env:fun {$ X} {Sin X} end
		     min:0.0
		     max:GUtils.pi)}
 plot}






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% concatenating fenvs
%%

%% this is still just f(x)=x
{{Fenv.fenvSeq
  [{New Fenv.fenv init(env:fun {$ X} X end
		       min:0.0
		       max:GUtils.pi)}]}
 toList($ 10)}


%% !! NB: local max of first segment is never reached: at that position the second segment already started. 
{{Fenv.fenvSeq
  [{New Fenv.fenv init(env:fun {$ X} X end)}
   0.3
   {New Fenv.fenv init(env:fun {$ X} {Sin X} end
		       min:0.0
		       max:GUtils.pi)}]}
 plot}



{{Fenv.funcsToFenv
  [fun {$ X} X end
   fun {$ X} {Sin X} end
   fun {$ X} ~X end]
  unit(min:0.0
       max:GUtils.pi)}
 plot}



{{Fenv.osciallator
  {New Fenv.fenv init(env:fun {$ X} X end)}
  7}
 plot(n:1000)}



   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Segment fenvs
%%%

{{Fenv.linearFenv [[0.0 0.0] [0.7 1.0] [1.0 0.0]]}
 plot}

{{Fenv.sinFenv [[0.0 0.0] [0.7 1.0] [1.0 0.0]]}
 plot}

{{Fenv.sinFenv2 [[0.0 0.0] [0.7 1.0] [1.0 0.0]]}
 plot}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Oscillators
%%

{{Fenv.sinOsc 5 unit(mul:{Fenv.linearFenv [[0.0 0.0] [0.7 1.0] [1.0 0.0]]}
		     add:{Fenv.linearFenv [[0.0 1.0] [1.0 ~1.0]]})}
 plot}

{{Fenv.saw 5 unit}
 plot}

{{Fenv.saw 5 unit(mul:{Fenv.linearFenv [[0.0 0.0] [0.7 1.0] [1.0 0.0]]}
		  add:2.0)}
 plot}

{{Fenv.triangle 5 unit}
 plot(n:1000)}

{{Fenv.square 5 unit}
 plot}

{{Fenv.square 5 unit(mul:{Fenv.linearFenv [[0.0 0.0] [0.7 1.0] [1.0 0.0]]}
		     add:{Fenv.linearFenv [[0.0 1.0] [1.0 ~1.0]]})}
 plot}


{{Fenv.pulse 5 unit(min:1 max:5 width:0.15)}
 plot(n:1000)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% transforming fenvs
%%

% orig
{{New Fenv.fenv init(env:fun {$ X} X end)}
 plot}

% reverse
{{Fenv.reverseFenv
  {New Fenv.fenv init(env:fun {$ X} X end)}}
 plot}

% invert
{{Fenv.invertFenv
  {New Fenv.fenv init(env:fun {$ X} X end)}}
 plot}


%% output linear fun going up from 1 to 3 (offset 1 and distance 2)
{{Fenv.scaleFenv {New Fenv.fenv init(env:fun {$ X} X end)}
  unit(mul:2.0 add:1.0)}
 plot}

{{Fenv.scaleFenv
  {New Fenv.fenv init(env:fun {$ X} {Sin X} end
		      min:0.0
		      max:GUtils.pi * 2.0)}
  unit(mul:0.5 add:0.5)}
 plot}

%% same as previous: output linear fun going up from 1 to 3 (offset 1 and distance 2)
{{Fenv.rescaleFenv {New Fenv.fenv init(env:fun {$ X} X end)}
  unit(oldmin:0.0
       oldmax:1.0
       newmin:1.0
       newmax:3.0)}
 plot}


%% !! Fenv.rescaleFenv buggy: does not work for neg numbers??
{{Fenv.rescaleFenv
  {New Fenv.fenv init(env:fun {$ X} {Sin X} end
		      min:0.0
		      max:GUtils.pi * 2.0)}
  unit(oldmin:~1.0
       oldmax:1.0
       newmin:0.0
       newmax:1.0)}
 plot}



%% !! problem: Fenv2 (here Sin) must only output values in interval [0.0 1.0]
%% Therefore, fenvs are scaled before and after waveshaping
%% Still, the def of Fenv1 (the transfer function, here the linear fenv) shows that this approach is somewhat unnatural (one has to form the transfer function for the scaled input..)
{{Fenv.scaleFenv
 {Fenv.waveshape
  {Fenv.linearFenv [[0.0 0.0] [0.2 0.05] [0.8 0.95] [1.0 1.0]]}
  {Fenv.scaleFenv
   {New Fenv.fenv init(env:Sin
		       min:0.0
		       max:GUtils.pi * 2.0)}
   unit(mul:0.5 add:0.5)}}
  unit(mul:2.0 add:~1.0)}
 plot}


{{Fenv.waveshape
  {Fenv.fenvSeq
   [{New Fenv.fenv init(env:fun {$ X} X end)}
    0.8
    {New Fenv.fenv init(env:fun {$ X} X * 0.5 end)}]}
  {New Fenv.fenv init(env:fun {$ X} {Sin X} end
		      min:0.0
		      max:GUtils.pi * 2.0)}
 }
 plot}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% examples ported from Lisp version
%%

{{New Fenv.fenv init(env:Sin 
		     min:~GUtils.pi
		     max:GUtils.pi)}
 plot}

{{Fenv.funcsToFenv [GUtils.identity
		    GUtils.identity
		    GUtils.identity]
  unit(min:1.0 max:5.0)}
  plot}

{{Fenv.fenvSeq [{New Fenv.fenv init(env:Sin max:GUtils.pi)}
	   0.1
	   {New Fenv.fenv init(env:Sin max:GUtils.pi)}
	   0.4
	   {New Fenv.fenv init(env:Sin max:GUtils.pi)}]}
 plot}

{{Fenv.osciallator {New Fenv.fenv init(env:GUtils.identity)}
  5}
 plot}

{{Fenv.linearFenv [[0.0 1.0] [0.2 3.0] [0.7 2.0] [1.0 ~1.0]]}
 plot}


{{Fenv.combineFenvs fun {$ Xs} {LUtils.accum Xs Number.'+'} end
 [10.0
  {Fenv.linearFenv [[0.0 0.0] [1.0 2.0]]}
  {New Fenv.fenv init(env:Sin max:GUtils.pi)}
  {New Fenv.fenv init(env:Sin max:GUtils.pi*2.0)}]}
 plot}

{{Fenv.combineFenvs fun {$ Xs} {LUtils.accum Xs Number.'*'} end
 [{Fenv.linearFenv [[0.0 0.0] [1.0 1.0]]}
  {New Fenv.fenv init(env:Sin max:GUtils.pi)}]}
 plot}

{{Fenv.combineFenvs fun {$ Xs} {LUtils.accum Xs Number.'*'} end
 [{Fenv.linearFenv [[0.0 0.0] [0.3 1.0] [1.0 0.0]]}
  {Fenv.triangle 7 unit}]}
 plot}

{{Fenv.rescaleFenv {Fenv.triangle 3 unit}
  unit(newmin:{Fenv.linearFenv [[0.0 0.1] [0.3 0.0] [1.0 0.6]]}
       newmax:{Fenv.linearFenv [[0.0 0.1] [0.3 1.0] [1.0 0.6]]})}
 plot}

{{Fenv.scaleFenv {New Fenv.fenv
		  init(env:fun {$ X}
			      Exp = 1000.0
			   in
			      {Pow Exp X} / Exp
			   end)}
  unit(mul:0.2
       add:0.1)}
 plot}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% tempo curve related 
%%


%%
%% Integrate a few different fenvs. Note: if the function for the input fenv is mapped from a different domain to [0,1] -- that is, if the fenv arguments min or max are used -- the integrated function of course depends on the _transformed_ input fenv. For example, the integral of cos(x) in [0, 2pi] mapped to [0,1] is a sine mapped to [0,1] -- but with a maximum value of about 0.15 and not 1 (see below). 
%%

{{Fenv.integrate {New Fenv.fenv init(env:fun {$ X} {Cos X} end
				    min:0.0
				    max:2.0*GUtils.pi)}
  0.01} plot}


{{Fenv.integrate {New Fenv.fenv init(env:fun {$ X} 1.0 end)}
  0.01} plot}

{{Fenv.integrate {New Fenv.fenv init(env:fun {$ X} X end)}
  0.01} plot}

{{Fenv.integrate {New Fenv.fenv init(env:fun {$ X} X*X end
				    min:~1.0
				    max:1.0)}
  0.01} plot}



%% integrate a given and take rubato tempo curve, cf. Henkjan's paper
{{Fenv.integrate {Fenv.linearFenv [[0.0 0.5] [0.5 2.0] [1.0 0.5]]}
  0.01} plot}


%% intergrate a tempo curve with a sudden tempo change, cf. Henkjan's paper
{{Fenv.integrate {Fenv.linearFenv [[0.0 3.0] [0.5 3.0] [0.5 0.3] [1.0 0.3]]}
  0.01} plot}



%% Fenv.integrate is thread-save
%% However, the gnuplot interface uses always the same file names per default...
thread
{{Fenv.tempoCurve2TimeMap {Fenv.linearFenv [[0.0 0.3] [0.5 3.0] [1.0 0.3]]}
  0.01}
 plot(commandFile: "/tmp/gnuplot_command"#{GUtils.getCounterAndIncr}
      dataFile:"/tmp/gnuplot_daten"#{GUtils.getCounterAndIncr})}
end
{{Fenv.tempoCurve2TimeMap {Fenv.linearFenv [[0.0 3.0] [0.5 3.0] [0.5 0.5] [1.0 0.5]]}
  0.01}
 plot(commandFile: "/tmp/gnuplot_command"#{GUtils.getCounterAndIncr}
      dataFile:"/tmp/gnuplot_daten"#{GUtils.getCounterAndIncr})}


/*

%%
%% old
%%

%% integration for Step=0.001
%% no memoization: ~300 msecs
%% with stateless memoization: ~7700 mecs
%% improved/stateful memoization: > 400 msecs
{Browse 
 time#{GUtils.timeSpend 
       proc {$}
	  {{Fenv.integrate {Fenv.linearFenv [[0.0 0.3] [0.5 3.0] [1.0 0.3]]}
	    0.001}
	   plot}
       end}}
 
   
*/


%%
%% ConcatenateTempoCurves
%%

declare
MyTempoCurve = {Fenv.concatenateTempoCurves
		[{Fenv.linearFenv [[0.0 0.5] [1.0 1.0]]}#1.0
		 {Fenv.sinFenv [[0.0 1.0] [0.8 1.5] [1.0 1.0]]}#5.0
		 {Fenv.linearFenv [[0.0 1.0] [1.0 1.0]]}#1.0
		 {Fenv.sinFenv [[0.0 1.0] [1.0 0.5]]}#3.0]}


{MyTempoCurve plot}

{{Fenv.tempoCurveToTimeMap MyTempoCurve 0.01}
 plot}


