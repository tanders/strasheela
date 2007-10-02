
{SDistro.makeFDDistribution ff}

{SDistro.makeFDDistribution startTime}

{SDistro.makeFDDistribution firstTimingFF}

{SDistro.makeFDDistribution generic(filter: undet
				   order: size
				   select: value
				   value: min
				   procedure: proc {$} skip end)}


{SDistro.makeFDDistribution 
 generic(filter: fun {$ X}
		    {FD.reflect.size {X getValue($)}} > 1
		 end
	 order: fun {$ X Y}
		   {FD.reflect.size {X getValue($)}}
		   <
		   {FD.reflect.size {Y getValue($)}}
		end
	 select: fun {$ X} {X value($)} end
	 value: FD.reflect.min
	 procedure: proc {$} skip end)}


%% test exception
{SDistro.makeFDDistribution generic(order: blabla)}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
%% simple script to compare and study distribution strategies 
%%
declare
fun {MakeSearchScript Distribution}
   proc {$ PPScore}
      MyScore = {Score.makeScore seq(items:[note note note]) unit}
      proc {InitScore S}
	 {S getStartTime($)}=0 
	 {S getOffsetTime($)}=0	% aritrary
	 {S forAll(test:isNote proc {$ X} {X getOffsetTime($)}=0 end)}
	 {S forAll(test:isNote proc {$ X} {X getAmplitude($)}=1 end)} % arbitrary
	 {S forAll(test:isParameter initFD)}
	 {ForAll S|{S collect($ test:isTimeMixin)}
	  {GUtils.toProc constrainTiming}}
      end
   in
      PPScore = {MyScore toPPrintRecord($)}
      {InitScore MyScore}
      %% actual Constraints:
      %% all note durations >: 0
      {MyScore applyRuleIf(unit(test:isNote
				accessObject: getDuration)
			   proc {$ D} D >: 0 end)}
      %% all note durations distinct
      {FD.distinct {Map {MyScore getItems($)}
		    fun {$ X} {X getDuration($)} end}}
      %% all note pitches >=: 48
      {MyScore applyRuleIf(unit(test:isNote
				accessObject: getPitch)
			   proc {$ D} D >=: 48 end)}
      %% all note pitches <: than pitch of successor note
      {MyScore applyRuleIf(
		  unit(test: fun {$ X} {X isItem($)} andthen 
				{X hasPredecessor($ {X getTemporalAspect($)})}
			     end
		       accessList: 
			  fun {$ X} 
			     [{X getPredecessor($ {X getTemporalAspect($)})} X]
			  end
		       accessObject: getPitch) 
		  proc {$ Pre Succ} Pre <: Succ end)}
      %% Distribute
      {FD.distribute Distribution
       {MyScore collect($ test:isParameter)}}
   end
end

{ExploreOne {MakeSearchScript {SDistro.makeFDDistribution ff}}}

{ExploreOne {MakeSearchScript {SDistro.makeFDDistribution firstTimingFF}}}

{ExploreOne {MakeSearchScript {SDistro.makeFDDistribution startTime}}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% 'random distribution' for recomputation -- does not work as required
%%

declare
%% avoiding the non-determinism introduced above with approach proposed by Raphael Collet (email Wed, 02 Feb 2005 to users@mozart-oz.org)
%%
%% both RandomNumbers and MakeRandomGenerator must be re-evaluated to get different random numbers
fun lazy {RandomStream} {OS.rand}|{RandomStream} end
RandomNumbers={RandomStream}
fun {MakeRandomGenerator}
   Str={NewCell RandomNumbers}
in
   proc {$ ?X} T in X|T=Str:=T end
end

declare
proc {DummyScript Sol}   
   % RandGen = {GUtils.makeRandomGenerator}
   RandGen = {MakeRandomGenerator}
in
   %% dummy example without constraints: 
   %% distribution decides randomly for variable domain values
   Sol = {FD.list 5 1#10}
   %%
   {FD.distribute
    generic(value:{SDistro.makeRandomDistributionValue RandGen})
    Sol}
end

{ExploreOne DummyScript}

%% always finds the same solution
{SearchOne DummyScript}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% this solution does not work:
%%
%% reimplement using Service, see http://www.mozart-oz.org/pipermail/mozart-users/2004/012230.html (google Service.synchronous site:www.mozart-oz.org)
%%

declare
%% avoiding the non-determinism introduced above with approach proposed by Raphael Collet (email Wed, 02 Feb 2005 to users@mozart-oz.org)
%%
%% both RandomNumbers and MakeRandomGenerator must be re-evaluated to get different random numbers
fun lazy {RandomStream} {OS.rand}|{RandomStream} end
RandomNumbers={RandomStream}
fun {MakeRandomGenerator}
   Str={NewCell RandomNumbers}
in
   proc {$ ?X} T in X|T=Str:=T end
end
RandGen = {MakeRandomGenerator}
%% ?? do I need synchronous or asynchronous
%%
%% -> providing RandGen as service works like plain rand (i.e. every call creates a NEW random number)
RandGenService = {Service.synchronous.newFun RandGen}
%%
%% -> providing MakeRandomGenerator as a service still causes global state change from local space
% MakeRandomGeneratorService = {Service.synchronous.newFun MakeRandomGenerator}


declare
proc {DummyScript Sol}   
   %% dummy example without constraints: 
   %% distribution decides randomly for variable domain values
   Sol = {FD.list 5 1#10}
   %%
   {FD.distribute
    generic(value:{SDistro.makeRandomDistributionValue RandGenService})
    Sol}
end

%% !! explorer does not work with this anymore, why?
{ExploreOne DummyScript}

%% !!?? calling search script multiple times causes different results
{SearchOne DummyScript}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% this solution does not work:
%%
%% test: reimplement using Port.sendRecv
%%

declare
local
   %% avoiding the non-determinism introduced above with approach proposed by Raphael Collet (email Wed, 02 Feb 2005 to users@mozart-oz.org)
   %%
   %% both RandomNumbers and MakeRandomGenerator must be re-evaluated to get different random numbers
   RandomNumbers
   MyPort={NewPort RandomNumbers}
   thread
      for unit#X in RandomNumbers do
	 X = {OS.rand}
      end
   end
% fun lazy {RandomStream} {OS.rand}|{RandomStream} end
% RandomNumbers={RandomStream}
   %%
in
%    proc {RandGen X}
%       {Send MyPort X}
%    end
   %% NB: Port.send does not work (that would send a free variable that belongs to a computation space outside that computation space which is forbidden), but in Port.sendRecv works. Yet, the 'message' send by Port.sendRecv must be determined (here to unit).
   proc {RandGen X}
      {Port.sendRecv MyPort unit X}
   end
   %% alternative.. 
%   RandGen = {Service.synchronous.newFun proc {$ X} <call old RandGen> end}
end

% fun {MakeRandomGenerator}
%    Str={NewCell RandomNumbers}
% in
%    proc {$ ?X} T in X|T=Str:=T end
% end
% RandGen = {MakeRandomGenerator}


declare
proc {DummyScript Sol}   
   %% dummy example without constraints: 
   %% distribution decides randomly for variable domain values
   Sol = {FD.list 5 1#10}
   %%
   {FD.distribute
    generic(value:{SDistro.makeRandomDistributionValue RandGen})
    Sol}
end

{ExploreOne DummyScript}

{RandGen}







