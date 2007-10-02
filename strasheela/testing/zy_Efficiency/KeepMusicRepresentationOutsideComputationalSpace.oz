
%%
%% NB: retry this with strict separation of outside music representation and script: only communication via port (?) and no object may pass boundary (bidirectional links would otherwise make the whole music representation part of script). Only plain data without links to score objects may pass boundary: numbers, atoms, records..
%%
%% Besides, the code below does not use a secure means to create a boundary such as a port! E.g., cf. Schulte thesis p. 40 "Sending Messages Across Spaces"
%% 
%%

%%
%% It seems to work: profiling the CSP which defines the score outside the script/space and the one with the data structure inside exhibit a large difference in the amount of heap needed
%%
%% Yet, by far most of the memory is in fact consumed by the propagators. It is thus questionable whether this proposal is worth the effort 
%%
%%


%% see Discussion in EfficientRedesign

declare
%%
%% Datastructure for variable pointer 
%%
/** %% Substitute for a constrained variable in a data structure which remains outside the script (i.e. remains in the top-level space).
%% Features:
%% index: binds an integer and is the index to the actual variable in the tuple of variables in the script
%% domain: the domain (quasi type) of the variable: either fd, fs, xri, ... NB: term 'domain' is ambiguous: it is the same term as for the set of possible domain values.
%% initDomain: domain spec for the creation of the actual variable
%% */
%% !!?? shall I replace this OOP approach by a record-based data structure + interface of procs? 
VarPointerType = {Name.new}
class VarPointer
   feat !VarPointerType: unit
      index domain initDomain
      %% !! default of initDomain should depend on domain (or I define a subclass for each domain)
      %%
      %% !! how is initDomain spec for fs?
   meth init(domain:Domain<=fd initDomain:InitDomain<=0#FD.sup)
      self.domain = Domain
      self.initDomain = InitDomain
   end
end
fun {IsVarPointer X}
   {Object.is X} andthen {HasFeature X VarPointerType}
end
/** %% Processes a list of VarPointers: returns a list with variable declarations and determines the indices of the VarPointers (corresponds to the position of the variable decl in the returned list).
%% */
fun {MakeVarDecls VarPointers}
   {List.mapInd VarPointers
    fun {$ I VarPointer}
       (VarPointer.index) = I
       (VarPointer.domain)#dom(VarPointer.initDomain)
    end}
end
/** %% Expects a variable declaration in the form Domain#dom(InitDomain) and returns a constrained variable of this domain and 'init domain' or basic constraint.
%% For example {MakeVariable fd#dom(1#10)} results in {FD.int 1#10}. 
%% */
fun {MakeVariable Domain#dom(InitDomain)}
   case Domain
   of fd then {FD.int InitDomain}
      %% [] fs then ...
   end
end
/** %% Creates the variable tuple from list of var declarations (as expected by MakeVariable).
%% */
fun {MakeVarTuple VarDecls}
   {List.toTuple unit {Map VarDecls MakeVariable}}
end
/** %% Expects a single VarPointer and the VarTuple and returns the variable to which the VarPointer is pointing
%% */ 
fun {PointerToVar VarPointer VarTuple}
   VarTuple.(VarPointer.index)
end
/** %% Apply procedure P to the variables represented by VarPointers (a list). Elements of VarPointers can be VarPointers or any other data (e.g. constrained variables or determined values). VarTuple is the tuple of variables substituted by the VarPointers.
%% It is necessary that {Procedure.arity P} == {Length VarPointers}
%% */
proc {ApplyToVars P VarPointers VarTuple}
   Vars = {Map VarPointers fun {$ VarPointer}
			      if {IsDet VarPointer} andthen {IsVarPointer VarPointer}
				 %% access actual var
			      then {PointerToVar VarPointer VarTuple}
			      else VarPointer
			      end
			   end}
in
   {Procedure.apply P Vars}
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Test all-distance series with var pointers (below orig without)
%%

%% Do test CSP without implicit temporal constraints: all-interval series where notes are contained in plain container. 
%% Intervals are represented by plain list of vars

declare
%% put this later in surround fun returning the script and expecting N as arg
N = 12
N1 = N-1
MyExternalScore = {Score.makeScore
	   seq(items: {LUtils.collectN N
		       fun {$}
			  note(duration: 4
			       pitch:{New VarPointer
				      init(domain:fd initDomain:60#60+N1)}
			       amplitude: 80)
		       end}
	       startTime: 0
	       timeUnit:beats(4))
	   unit}
VarPointers = {MyExternalScore map($ fun {$ X} {X getPitch($)} end test:isNote)}
VarDecls = {MakeVarDecls VarPointers}


%% !! start profiler here, the evaluate the two scripts


declare
%% !!?? unsufficient boundary: I do stuff like {MyExternalScore getItems($)} within script, so the whole score ends up in script because of the bidirectional links! 
proc {MyScriptWithVarPointers VarTuple}
   Intervals = {FD.list N1 1#N1}
in
   VarTuple = {MakeVarTuple VarDecls}
   %% constraint relations between pitches (VarPointers) and Intervals
   {ForAll {LUtils.matTrans [{MyExternalScore getItems($)}.2 %% all but first notes
			     Intervals]}
    proc {$ [Note2 Interval]}
       Note1 = {Note2 getTemporalPredecessor($)}
    in
       {ApplyToVars FD.distance
	[{Note1 getPitch($)} {Note2 getPitch($)} '=:' Interval]
	VarTuple}
    end}   
   {FD.distinctD {Map {MyExternalScore mapItems($ getPitch)}
		  fun {$ X} {PointerToVar X VarTuple} end}}
   {FD.distinctD Intervals}	
   %% Specify search strategy
   {FD.distribute ff VarTuple}
end


declare
proc {MyScriptWithScore Pitches}
   Intervals MyScore
in
   MyScore = {Score.makeScore
	      seq(items: {LUtils.collectN N
			  fun {$}
			     note(duration: 4
				  pitch: {FD.int 60#60+N1}
				  amplitude: 80)
			  end}
		  startTime: 0
		  timeUnit:beats(4))
	      unit}
   %% explicit param units (for output): all timing param units are
   %% unified with each other.
   Pitches = {MyScore map($ getPitch test:isNote)}
   Intervals = {FD.list N1 1#N1}
   for
      Pitch1 in {List.take Pitches N1} % butlast of Pitches
      Pitch2 in Pitches.2		    % tail of Pitches
      Interval in Intervals
   do
      {FD.distance Pitch1 Pitch2 '=:' Interval}
   end      
   {FD.distinctD Pitches}		% no pitch class repetition
   {FD.distinctD Intervals}		% no (abs) interval repetition
   %% Specify search strategy
   {FD.distribute ff Pitches}
end



declare
proc {MyScriptPlain Pitches}
   Intervals
   Pitches
in
   %% explicit param units (for output): all timing param units are
   %% unified with each other.
   Pitches = {FD.list N 1#N}
   Intervals = {FD.list N1 1#N1}
   for
      Pitch1 in {List.take Pitches N1} % butlast of Pitches
      Pitch2 in Pitches.2		    % tail of Pitches
      Interval in Intervals
   do
      {FD.distance Pitch1 Pitch2 '=:' Interval}
   end      
   {FD.distinctD Pitches}		% no pitch class repetition
   {FD.distinctD Intervals}		% no (abs) interval repetition
   %% Specify search strategy
   {FD.distribute ff Pitches}
end




/*

%% first solution: heap: 5088b
%% second solution: heap: 5088b ??
%% emulator.e after second solution: 37.9M
{Explorer.one MyScriptWithVarPointers}

%% first solution: heap: 189k (more memory required by MyScriptWithScore than fdp_distance: 10k)
%% second solution: heap: 189k (fdp_distance: 10M)
%% emulator.e after second solution: 43.4M / 37.9M
{Explorer.one MyScriptWithScore}

%% first solution: heap: 1696b
%% second solution: heap: 1696b ??
%% emulator.e after second solution: 38.4M
{Explorer.one MyScriptPlain}

*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Second CSP: two sequences of N notes (start/duration pairs). Both sequences start at the same time. All note start times (except the two first) are different.
%%
%% This very simple rhythmical problem is formulated three times, once with with a
%% Strasheela score inside the script, once outside, and once with a plain list representation. The second
%% is much faster (because copying is more cheap??)
%%
%%


declare
fun {MakeVoice N}
   {Score.makeScore2 seq(items: {LUtils.collectN N 
				 fun {$} 
				    note(duration: {FD.int 1#8} 
					 pitch: 60%{FD.int 60#72} 
					 amplitude: 80) 
				 end}
			 info:voice)
    unit}
end
proc {ScriptWithScoreDataInside MyScore} 
   N = 100
   Voice1 Voice2
in
   Voice1 = {MakeVoice N}
   Voice2 = {MakeVoice N}	     
   MyScore = {Score.makeScore 
	      sim(items: [Voice1 Voice2] 
		  startTime: 0 
		  timeUnit:beats(4)) 
	      unit}
   {FD.distinctB {Append
		  {Voice1 mapItems($ getStartTime)}.2
		  {Voice2 mapItems($ getStartTime)}.2}}
   %% search strategy 
   {FD.distribute 
    {SDistro.makeFDDistribution unit(order:size value:min)}
    {LUtils.accum [{Voice1 mapItems($ getDurationParameter)}
		   {Voice2 mapItems($ getDurationParameter)}
		   {Voice1 mapItems($ getStartTimeParameter)}
		   {Voice2 mapItems($ getStartTimeParameter)}]
     Append}}
end 




/*

{{Score.makeScore
  container(items: {LUtils.collectN 3
		    fun {$}
		       element(addParameters:[{New Score.parameter init(info:startTime)}
					      {New Score.parameter init(info:duration)}])
		    end})
  unit(container:Score.container
       element:Score.element)}
 toInitRecord($)}

*/

/*
%% unfinished
declare
fun {MakeVoice2 N}
   {Score.makeScore2
    container(items: {LUtils.collectN N
		      fun {$}
			 element(addParameters:[{New Score.parameter
						 init(value:{FD.int 1#FD.sup}
						      info:startTime)}
						{New Score.parameter
						 init(value:{FD.int 1#8}
						      info:duration)}])
		      end}
	      info:voice)
    unit(container:Score.container
	 element:Score.element)}
end
fun {GetStartTimePar X}
   {LUtils.find {X getParameters($)}
    fun {$ Par} {Par hasThisInfo($ startTime)} end}
end
fun {GetDurationPar X}
   {LUtils.find {X getParameters($)}
    fun {$ Par} {Par hasThisInfo($ duration)} end}
end
fun {GetStartTime X}
   {{GetStartTimePar X} getValue($)}
end
fun {GetDuration X}
   {{GetDurationPar X} getValue($)}
end
proc {ConstraintTiming X Y}
   {GetStartTime X} + {GetDuration X} =: {GetStartTime Y}
end
proc {ScriptWithScoreDataInside2 MyScore} 
   N = 100
   Voice1 Voice2
in
   Voice1 = {MakeVoice2 N}
   Voice2 = {MakeVoice2 N}	     
   MyScore = {Score.makeScore
	      container(items: [Voice1 Voice2]) 
	      unit(container:Score.container)}
   %% usually implicit timing constraints 
   {Pattern.for2Neighbours {Voice1 getItems($)} ConstraintTiming}
   {Pattern.for2Neighbours {Voice2 getItems($)} ConstraintTiming}
   %% !! these constraints cause fail!
   {GetStartTime {Voice1 getItems($)}.1} = 0 
   {GetStartTime {Voice2 getItems($)}.1} = 0
   %% actual constraint
   {FD.distinctB {Append
		  {Voice1 mapItems($ GetStartTime)}.2
		  {Voice2 mapItems($ GetStartTime)}.2}}
   %% search strategy 
   {FD.distribute 
    {SDistro.makeFDDistribution unit(order:size value:min)}
    {LUtils.accum [{Voice1 mapItems($ GetDurationPar)}
		   {Voice2 mapItems($ GetDurationPar)}
		   {Voice1 mapItems($ GetStartTimePar)}
		   {Voice2 mapItems($ GetStartTimePar)}]
     Append}}
end 

*/


declare
proc {ConstrainStarts Starts Durs}
   for
      S1 in {LUtils.butLast Starts}
      S2 in Starts.2
      D1 in {LUtils.butLast Durs}
   do
      S1 + D1 =: S2
   end
end
proc {PlainScript Sol}   
   N = 100
   Durs1 = {FD.list N 1#8}
   Durs2 = {FD.list N 1#8}
   Starts1 = {FD.list N 0#FD.sup}
   Starts2 = {FD.list N 0#FD.sup}
in
   Sol = {LUtils.matTrans [Durs1 Starts1]}#{LUtils.matTrans [Durs2 Starts2]}
   Starts1.1 = 0
   Starts2.1 = 0
   {ConstrainStarts Starts1 Durs1}
   {ConstrainStarts Starts2 Durs2}
   {FD.distinctB {Append Starts1.2 Starts2.2}}
   %% search strategy
   {FD.distribute ff
    {LUtils.accum [Durs1 Durs2 Starts1 Starts2] Append}}
end


/*


%% time: 2.89 secs
%% 1#stat(b:0 c:0 depth:1 f:0 s:1 start:201)
%% ScriptWithScore heap: 3757k
%% MakeVoice heap: 1870k  
{ExploreOne ScriptWithScoreDataInside}

%% time: 3.14
%% 1#stat(b:0 c:0 depth:1 f:0 s:1 start:401)
{ExploreOne ScriptWithScoreDataInside2}


{ExploreOne ScriptWithScoreDataOutside}


%% time: 500ms
%% 1#stat(b:0 c:0 depth:1 f:0 s:1 start:201)
%% PlainScript heap: 66k 
%% ConstrainStarts heap: 6560b
{ExploreOne PlainScript}


*/




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 
/* %% testing the data structure 

declare
VarPointers VarDecls VarTuple

%% create a few var pointers for testing
VarPointers = [{New VarPointer init(domain:fd initDomain:1#10)}
	       {New VarPointer init(domain:fd initDomain:2#10)}
	       {New VarPointer init(domain:fd initDomain:3#10)}
	       {New VarPointer init(domain:fd initDomain:4#10)}]


%% test type checking
{IsVarPointer VarPointers.1}
{IsVarPointer bla}


%% Given a list of varpointers create corresponding variable declarations. As a side effect, this operation determines the indices of the varpointers.
%% !! This operation should still be performed OUTSIDE the script, so the list of actually required variables can be reduced (e.g. the script may only constrain the note pitches and leave all other note parameters out..) 
VarDecls = {MakeVarDecls VarPointers}


%% !! the variables are always created INSIDE the script
VarTuple = {MakeVarTuple VarDecls}


%% apply constraint to first two VarPointers: this is correctly reflected by vars i VarTuple

{ApplyToVars proc {$ X Y} X <: Y end
 [{Nth VarPointers 2} {Nth VarPointers 1}]
 VarTuple}

*/



/*

%% start profiler only here (check heap usage of these procs)

declare
SpaceWithVarPointers = {Space.new MyScriptWithVarPointers}
SpaceWithScore = {Space.new MyScriptWithScore}
proc {CloneSpaceWithVarPointers _}
  _ = {Space.clone SpaceWithVarPointers}
end
proc {CloneSpaceWithScore _}
  _ = {Space.clone SpaceWithScore}
end
proc {MakeMyScore _}
   _ = {Score.makeScore
	seq(items: {LUtils.collectN N
		    fun {$}
		       note(duration: 4
			    pitch: {FD.int 60#60+N1}
			    amplitude: 80)
		    end}
	    startTime: 0
	    timeUnit:beats(4))
	unit}
end


{For 1 100 1 CloneSpaceWithVarPointers} %% needs 224k

{For 1 100 1 CloneSpaceWithScore} %% needs 256k

{For 1 100 1 MakeMyScore} %% needs 8390k

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
%% Result: it seems that the idea to keep the data of the music representaiton outside of the script (i.e. space) does not make any significant difference to the memory needs
%%
%% astonishingly, creating the music representation needs much more memory than cloning the space with a CSP 'containing' the music representation. How clever is the cloning of the space done: does it only clone the variables of the problem, i.e. the constraint store, propagators etc.?? 
%%
%% 
%% .. on 7 march 2006 I got a reply by R. Collet: Re: What is actually copied when a space is cloned? on a question about this..
%%

%%
%% I may communicate over space boundaries (via a port? See Text of Christina p. 40), but I can not communicate chunks (??) -- see email by R. Collet: Re: memoization + search script, 4. Mai 2006 12:53:05 MESZ
%% I.e. I can wrap data into procedures??
%%


