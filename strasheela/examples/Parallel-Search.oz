

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Multi-core processing test: solve (longer) all-interval series with
%% parallel search running in two processes on localhost. For more
%% details, see the Oz documentation at
%% http://www.mozart-oz.org/documentation/system/node13.html
%%
%%
%% first feed buffer (defines definitions shared by multiple
%% examples), then feed the examples in comments
%%

%%
%% CSP definition: all-interval series
%%
declare
%% Constraints Interval to be an inversional equivalent interval
%% between the two pitch classes Pitch1 and Pitch2 (i.e. a fifth
%% upwards and a fourth downwards count as the same interval).
proc {InversionalEquivalentInterval Pitch1 Pitch2 L Interval}
   Aux = {FD.decl}
in
   %% add 12, because the FD int Aux must be positive
   Aux =: Pitch2-Pitch1+L
   {FD.modI Aux L Interval}
end
%% Returns an all-interval series. Xs is the solution, a list of pitch
%% classes (list of FD ints) and Dxs is the list of inversional
%% equivalent intervals between them (list of FD
%% ints). AllIntervalSeries expects L (an integer specifying the
%% length of the series).
proc {AllIntervalSeries L ?Dxs ?Xs}
   Xs = {FD.list L 0#L-1} % Xs is list of L FD ints in {0, ..., L-1}
   Dxs = {FD.list L-1 1#L-1}
   %% Loop constraints intervals
   for I in 1..L-1
   do
      X1 = {Nth Xs I}
      X2 = {Nth Xs I+1}
      Dx = {Nth Dxs I}
   in
      {InversionalEquivalentInterval X1 X2 L Dx}
   end 
   {FD.distinctD Xs}		% no PC repetition
   {FD.distinctD Dxs}	% no interval repetition
   %% add knowledge from the literature: first series note is 0 and last is L/2
   Xs.1 = 0
   {List.last Xs} = L div 2
   %% Search strategy
   {FD.distribute ff Xs}
end


%%
%% plain search test
%%

/*

declare
L = 24				% all-interval series length
%% first single processor + explorer: how long does it take
%% NB: using the explorer, two processes are used already (search + GUI)
{Explorer.one proc {$ Sol}
		 PitchClasses Intervals in
		 Sol = PitchClasses#Intervals
		 {AllIntervalSeries L Intervals PitchClasses}
	      end}

*/

/*

%% When using SearchOne (instead of explorer), only a single processor is used.
%% Browses required computation time in msecs.
declare
L = 24				% all-interval series length
Sol
TimeSpend = {GUtils.timeSpend 	% measure runtime
	     proc {$}
		Sol = {SearchOne proc {$ Sol}
				    Xs Dxs in
				    Sol =  Xs#Dxs
				    {AllIntervalSeries L Dxs Xs}
				 end}
	     end}
{Browse timeSpend#TimeSpend}	% +/- 3840 msecs
{Browse solution#Sol}

*/


%%
%% parallel search test
%%

/*

%% Search.parallel creates two processes and makes use of two CPUs on localhost
declare
%% All-interval series length
L = 24
%% parallel search engine is defined in functor exporting the feature
%% script
%%
%% Procedures like AllIntervalSeries etc must be defined inside
%% functor or imported from other functors -- they can not be defined
%% outside of the functor in the OPI
functor ScriptF
import FD
export Script
define
   %% Main: the script definition
   proc {Script Sol}
      Xs Dxs in
      Sol =  Xs#Dxs
      {AllIntervalSeries L Dxs Xs}
   end
   %% Constraints Interval to be an inversional equivalent interval
   %% between the two pitch classes Pitch1 and Pitch2 (i.e. a fifth
   %% upwards and a fourth downwards count as the same interval).
   proc {InversionalEquivalentInterval Pitch1 Pitch2 L Interval}
      Aux = {FD.decl}
   in
      %% add 12, because the FD int Aux must be positive
      Aux =: Pitch2-Pitch1+L
      {FD.modI Aux L Interval}
   end
   %% Returns an all-interval series. Xs is the solution, a list of pitch
   %% classes (list of FD ints) and Dxs is the list of inversional
   %% equivalent intervals between them (list of FD
   %% ints). AllIntervalSeries expects L (an integer specifying the
   %% length of the series).
   proc {AllIntervalSeries L ?Dxs ?Xs}
      Xs = {FD.list L 0#L-1} % Xs is list of L FD ints in {0, ..., L-1}
      Dxs = {FD.list L-1 1#L-1}
      %% Loop constraints intervals
      for I in 1..L-1
      do
	 X1 = {Nth Xs I}
	 X2 = {Nth Xs I+1}
	 Dx = {Nth Dxs I}
      in
	 {InversionalEquivalentInterval X1 X2 L Dx}
      end 
      {FD.distinctD Xs}		% no PC repetition
      {FD.distinctD Dxs}	% no interval repetition
      %% add knowledge from the literature: first series note is 0 and last is L/2
      Xs.1 = 0
      {List.last Xs} = L div 2
      %% Search strategy
      {FD.distribute ff Xs}
   end
end
Sol
%% create search engine for two processes on localhost
SearchEngine = {New Search.parallel init(localhost:2)}
TimeSpend
%% now call solver
TimeSpend = {GUtils.timeSpend  	% measure runtime
	     %% NB: SearchEngine uses functor (possibly a compiled
	     %% functor), but not a module
	     proc {$} Sol={SearchEngine one(ScriptF $)} end}
%% greatly reduced search time +/- 800 msces instead of 3800 msecs
%% This time I probably just go lucky, realistic is search time of
%% single CPU divided my number of notes..
{Browse timeSpend#TimeSpend}	
{Browse solution#Sol}

{SearchEngine close}

{SearchEngine stop}


{SearchEngine trace(true)}


*/



