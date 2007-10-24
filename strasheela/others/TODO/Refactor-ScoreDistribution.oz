
/*

* ?? rename Strasheela/ScoreDistribution.oz into ScoreSearch (kurz SSearch)

* replace SDistro.exploreOne and friends by a single ScoreSearch (see below)


*/

%%
%% * I can not change state in the global space directly from within a local space. But I can do this with a port!
%% see Christians book (p. 40) or Moz mailing list: raph@info.ucl.ac.be: Re: memoization + search script. 4. Mai 2006 12:53:05 MESZ 
%%


declare
%% avoiding the non-determinism introduced above with approach proposed by Raphael Collet (email Wed, 02 Feb 2005 to users@mozart-oz.org)
%%
%%
%% !! This goes into GUtilts (including SetSeed)
%%
local
   fun lazy {RandomStream} {OS.rand}|{RandomStream} end   
   RandomNumbers={NewCell {RandomStream}}
in
   /** %% Return null-ary function which returns pseudo-random number whenever called. 
   %% */
   fun {MakeRandomGenerator}
      Str={NewCell @RandomNumbers}
   in
      proc {$ ?X} T in X|T=Str:=T end
   end
   /** %% Sets the seed for the random number generator used by MakeRandomGenerator (which internally uses OS.rand). If Seed is 0, the seed will be generated from the current time. 
   %% */
   proc {SetSeed Seed}
      {OS.srand Seed}
      RandomNumbers:={RandomStream}
   end
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% !! This goes into ScoreDistribution.oz and replaces various procs there
%%
%%
fun {MakeSearchScript ScoreScript Distributor Test}
   proc {$ MyScore}
      MyScore = {ScoreScript}
      {Distributor {MyScore collect($ test:fun {$ X}
					      {X isParameter($)} andthen
					      {Test X}
					   end)}}
   end
end
/** %% Calls search engine with script...
%% SearchEngine, ScoreScript and Distributor are all unary procedures. SearchEngine expects a script, examples are Search.base.one or Explorer.all. ScoreScript is the script of the CSP, argument (and root of the script) is a score. Distributor is a score distributor, argument is a list of parameters to distribute.
%% Test is a unary function expecting a score parameter and returning a boolean. Only the parameters which pass the Test are distributed. 
%% */
proc {ScoreSearch2 ScoreScript SearchEngine Distributor Test}
   {SearchEngine {MakeSearchScript ScoreScript Distributor Test}}
end
/** %% Variant of ScoreSearch2 with support for optional args
%%
%% In case the argument distributor is not provided, then the distributor defaults to a call to FD.distribute with filtered params and the arguments for FD.distribute are created by SDistro.makeFDDistribution. The arguments of SDistro.makeFDDistribution in turn can in that case be provided in Args.
%%
%% Args to SDistro.makeFDDistribution: value 'random' makes problems: either ScoreSearch expects full Distributor or I need to wrap random value proc in functions. This means for consistency I must wrap all value procs (and all order procs?)
%%
%% !!?? Frage: Besseres Design vielleicht moegl: single distributor erhaelt proc, und diese wird mit NEUER abstraction erzeugt (aehnlich zu SDistro.makeFDDistribution). Kann ich Problem umgehen, wenn die random value proc (zusammen mit allen anderen entsprechenden order und value procs) lokal in dieser neuen Abstraktion erzeugt/gespeicher wird? 
%%
%% */
proc {ScoreSearch ScoreScript Args}
   Defaults = unit(searchEngine: Explorer.one
		   distributor: proc {$ Params}
				   {FD.distribute
				    {SDistro.makeFDDistribution
				     {Record.map
				      %% !! tmp: each subarg in its own proc (in case it is not an atom..) -- Dies muss spaeter geaendert werden: dies muesste ich mit ERGEBNIS von SDistro.makeFDDistribution machen...
				      {Record.subtractList Args
				       [searchEngine distributor test]}
				      fun {$ X} {X} end}
				    }
				    Params}
				end
		   test:fun {$ X}
			   %% offsets are determined: only look
			   %% at durations (then startTime and
			   %% endTime get determined as well)
			   {Not {X isTimePoint($)}} andthen
			   {Not {{X getItem($)} isContainer($)}}
			end)
   As = {Adjoin Defaults Args}
in
   {ScoreSearch2 ScoreScript As.searchEngine As.distributor As.test}
end


%% this way, random distro works with recomputation and is specified in a modular way
%% 
{ScoreSearch proc {$ MyScore}
		MyScore = {Score.makeScore seq(items: {LUtils.collectN 7
						       fun {$}
							  note(duration: 4
							       pitch: {FD.int 60#72}
							       amplitude: 80)
						       end}
					       startTime: 0
					       timeUnit:beats(4))
			   unit}
	     end
 unit(distributor:proc {$ Params}
		     {FD.distribute
		      {SDistro.makeFDDistribution
		       unit(value:local RandGen = {MakeRandomGenerator}
				  in {SDistro.makeRandomDistributionValue RandGen}
				  end)}
		      Params}
		  end)}

%% verwende andere Zufallszahlen:
{SetSeed 10}


%%
%% Ich wuerde gern nach wie vor auch die einzelnen Aspekte der Distro unabhaengig voneinander setzen koennen, so dass die ungesetzten Aspekte default values bleiben.
%% Ausserdem will ich eine 'Bibliothek' von typischen Aspekten haben, von denen ich dann einfach welche mit Atom auswaehlen kann, z.B. unit(order:startTime value:random) 
%% 
%% Fuer Random Distro (ValueSelection) muss die entsprechende Berechnung (value function) aber unbedingt nochmal in einer Funktion verpackt sein (d.h. eine Funktion, die dann die eigentliche Funktion zurueckgibt). D.h. die 'Bibliothek' muss enthalten (verkuerzt) -- anders kann ich die random distro nicht in meiner 'Bibliothek' unterkriegen und muesste die komplette Distro sonst immer von Hand def...
%%
/* unit(value: value(random:fun {$}
			    local RandGen = {MakeRandomGenerator}
			    in {SDistro.makeRandomDistributionValue RandGen}
			    end
			 end)) */
%%
%% Wenn ich dies aber fuer die random value func so mache, muss ich das natuerlich fuer alle values machen..
%%
%% Und konsequenterweise sollte ich das eigentlich auch fuer alle andere Distro-Aspekte (order etc) dies so machen...
%% Fuer welche Faelle koennte ich das aber sonst noch brauchen??
%%
%% for single args, however, I need to wrap each in its own to ensure it is local in the script
{ScoreSearch proc {$ MyScore}
		MyScore = {Score.makeScore seq(items: {LUtils.collectN 7
						       fun {$}
							  note(duration: 4
							       pitch: {FD.int 60#72}
							       amplitude: 80)
						       end}
					       startTime: 0
					       timeUnit:beats(4))
			   unit}
	     end
 unit(value:fun {$}
	       local RandGen = {MakeRandomGenerator}
	       in {SDistro.makeRandomDistributionValue RandGen}
	       end
	    end)}



%% nochmal ne andere Variante waere, die Zufallszahlen nacheinander ohne stateful operation auszulesen
%% ... aber daran hatte ich mir schon frueher die Zaehne ausgebissen...
%%
%% 

%%
%% andererseits: koennte ich fuer eine 'unabhaengige' Order proc auch mal eine lokale Cell brauchen (z.B. fuer eine zufaellige Entscheidung?)
%%


