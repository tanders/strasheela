
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% This example/test contains a simple CSP (all-distance series) which
%% in defined in different ways to compare memory consumption. The
%% fear is that in a standard Strasheela CSP the score is always
%% copied when a space is copied resulting in much higher memory
%% consumption and some more run time comsumption.
%%
%% The CSP is defined in an inefficient way (using FD.distrinct
%% instead of FD.distinctD) in order to create a larger search
%% tree. The example creates >70000 spaces with a tree depth of 38.
%%
%% MyScriptWithScore is a "normal" Strasheela script where the score
%% is defined in the script. MyScriptWithVarPointers is the same CSP,
%% but the score is defined outside the script. All variables are of
%% course within the script, and the matching between variables and
%% score parameters happens via a new data structure VarPointer, which
%% replaces the variables in the score parameters and introduces an
%% index to match the variable and its
%% parameter. MyScriptWithVarPointersAndPort is a script which
%% additionally introduces a port as a boundary for the communication
%% between spaces (i.e. the script) and the top-level space (defs
%% outside the script). Finally, MyScriptPlain is a comparison CSP
%% without defining a Strasheela score. However, this script is no
%% really fair comparison as it defines less variables and less
%% constrains (e.g. all temporal variables and constrains are
%% omitted.).
%%

%%
%% NOTE: reread http://lists.gforge.info.ucl.ac.be/pipermail/mozart-users/2003/004139.html and its thread
%%

/*

%%
%% General test first: create a space with a score object and copy
%% it. Measure the amount of memory needed by the different cases.
%%
%% USAGE
%%
%%  1 - First start Oz profiler 
%%  2 - then feed top-level defs
%%  3 - reset the profiler, feed an example case, updata the profiler
%%  4 - repeat 3 ...
%%

%% cf. Schulte. Programming Constraint Services, Example 13.4, 
%% http://lists.gforge.info.ucl.ac.be/pipermail/mozart-users/2002/003003.html
%% and http://lists.gforge.info.ucl.ac.be/pipermail/mozart-users/2002/003006.html

%% top-level defs
declare
N = 100
fun {MakeScore}
   {Score.makeScore
    seq(items: {LUtils.collectN N
		fun {$}
		   note(duration: 4
			pitch:60
			amplitude: 80)
		end}
	startTime: 0
	timeUnit:beats(4))
    unit}
end

{Inspect {MakeScore}}


%% Memory usage of a single MakeScore call (it seems the difference
%% between the heap shown for MakeScore and the total heap is caused
%% by threads created implicitly, e.g., in ScoreMapping.oz)
%%
%% MakeScore 664k, total 845k 
{MakeScore _}


%% My usual case: a score object created _inside_ space. Then this
%% space a copied 1000 times. Much more memory is required than a
%% single MakeScore call, although not 1000 times as much (its about
%% 1000 times as much, strange. Actually, copying the space 1 times
%% takes 44k -- much less than creating the score).
%%
%% NOTE: data is copied!
%%
%% 87M total heap (86M ForProc) 
declare
S = {Space.new proc {$ X}
		   X={Score.makeScore
		      seq(items: {LUtils.collectN N
				  fun {$}
				     note(duration: 4
					  pitch:60
					  amplitude: 80)
				  end}
			  startTime: 0
			  timeUnit:beats(4))
		      unit}
		end}
Clones = {List.make 1000}
for C in Clones do C = {Space.clone S} end


%% Example very similar to my usual scripts, but score is created by a
%% function defined at top-level. Again, the space is copied 1000
%% times.
%%
%% NOTE: data is copied!
%%
%% Heap total: 87M (86M ForProc, 664k MakeScore [1 call of MakeScore])
declare
S = {Space.new proc {$ X} X={MakeScore} end}
Clones = {List.make 1000}
for C in Clones do C = {Space.clone S} end


%% In this example, the score is _outside_ the space. I can not use this case directly for music CSPs, because I must not have variables outside the space. However, it seems I don't necessarily need a port. Can I directly process Data in the space?
%%
%% I can not write a global data structure from a space, but I can do call a function defined globally, by sending a message via a port.
%%
%% NOTE: data is NOT copied! 
%%
%% heap total 997k (664m MakeScore, 21k ForProc)
declare
Data = {MakeScore}
S = {Space.new proc {$ X} X=Data end}
Clones = {List.make 1000}
for C in Clones do C = {Space.clone S} end


%% Control case: create a space which contains and copies a single
%% undetermined var. This is similar to the case without copying above
%% (ForProc even needs more memory, why?).
%%
%% heap total 233k, 87k ForProc
declare
Data = _
S = {Space.new proc {$ X} X=Data end}
Clones = {List.make 1000}
for C in Clones do C = {Space.clone S} end


*/


/*


%%
%% USAGE
%%
%% - Start Oz profiler 
%% - Feed buffer
%% - Call solvers (just below) such as {Browse {Search_MyScriptWithScore}}
%% - Update profiler report (update buttom)
%%


%%
%% Solver calls and results
%%

%%
%% It appears there is virtually no difference in the memory
%% consumption whether I am using the Strasheela music representation
%% or just two plain lists. So, it appears it is totally fine to have
%% the music representation inside the script/space with all the
%% convenience this provides..
%%



%% heap: 101M
{Browse {Search_MyScriptWithVarPointers}}

{Explorer.one MyScriptWithVarPointers}

%% heap: 101M 
{Browse {Search_MyScriptWithVarPointersAndPort}}

{Explorer.one MyScriptWithVarPointersAndPort}


%% heap: 103M 
{Browse {Search_MyScriptWithScore}}

{Explorer.one MyScriptWithScore}


%% heap: 101M
{Browse {Search_MyScriptPlain}}

% stat(b:0 c:70801 depth:38 f:70796 s:1 start:1)
{Explorer.one MyScriptPlain}

%%
%% Yes, once a variable is determined in a space S (e.g., a determined
%% FD int or a variable binding a score) then this variable value is
%% not copied when S is cloned (and hence requires no additional
%% memory): child spaces of S can see the value. For details see
%% Schulte. Programming Constraint Services, Sec. 13.2.3 and 13.5.2.
%% Schulte recommends to situate large data in a script's "top-level"
%% space by encapsulating it in a procedure. I already do this in a
%% way using the proc Score.makeScore, but I should compare what
%% difference it makes to create the full score in a proc outside.
%%
%% Also see http://lists.gforge.info.ucl.ac.be/pipermail/mozart-users/2002/002998.html and follow-up posts.
%% Situated data: stateful data structures, free (?) variables, procedues and names. Cloning a situated entity means: if the entity is local the space being cloned, a clone is created. Otherwise, the entity is not cloned (see http://lists.gforge.info.ucl.ac.be/pipermail/mozart-users/2002/003005.html). So, a score object is situated as it is a stateful data structure.
%% If a situated datum has been copied during cloning, is it then again local in the cloned child space and will thus again be copied when then child is cloned?  
%%
%% Ergo, the biggest issue I felt I have with Strasheela simply does
%% not exist :)
%%

*/


/*

%% see
%% http://lists.gforge.info.ucl.ac.be/pipermail/mozart-users/2002/002998.html
%% and follow-up postings.
%%
%% It seems that the issue described in the post is meanwhile solved:
%% I can not see a difference in the cases with data in script and
%% data encapsulated in proc. According to Schulte Programming
%% Constraint Services, 13.5.2. (Example 13.4) there should be a
%% difference.
%%
%% !! However, having the large datastructure _outside_ the script
%% makes indeed a big difference memory-wise.

%%
%% TODO: check the same with a musical CSP where the score is
%% outside. I can not have variables outside the script... 
%%
%%

declare
proc {Script1 Root}
   %% add or take data here to see memory footprint change
   StaticData = {List.number 1 1000000 1}
in
   %% Unless I use StaticData, the compiler outsmarts me.
   Root={FD.list {List.nth StaticData 100} [1#1000]}
   {FD.distribute naive Root}
   %% I don't reach a solution so the search engine does not destroy the search tree
%   {Wait _}
end
fun {MakeData}
   {List.number 1 1000000 1}
end
proc {Script2 Root}
   StaticData = {MakeData}
in
   %% Unless I use StaticData, the compiler outsmarts me.
   Root={FD.list {List.nth StaticData 100} [1#1000]}
   {FD.distribute naive Root}
   %% I don't reach a solution so the search engine does not destroy the search tree
%   {Wait _}
end   
Toplevel_StaticData = {MakeData}
proc {Script3 Root}
   %% Unless I use StaticData, the compiler outsmarts me.
   Root={FD.list {List.nth Toplevel_StaticData 100} [1#1000]}
   {FD.distribute naive Root}
   %% I don't reach a solution so the search engine does not destroy the search tree
%   {Wait _}
end   


%% total heap: 8248k  
{Search.base.one Script1 _}

%% total heap: 8244k 
{Search.base.one Script2 _}

%% total heap: 430k
{Search.base.one Script3 _}


*/



%%
%%
%% As far as I understand it, MyScriptWithScore should consume much
%% more memory than MyScriptWithVarPointersAndPort and the least
%% memory should be consumed by MyScriptPlain.  However, it is hard to
%% see any significant differences between these cases. Possibly, I
%% don't measure correctly.
%%
%%
%% NOTE: how can I find out whether copying a space does copy a score object within (and not just its variables) and thus cause increased memory consumption which I should avoid. In an ideal world, only computational entities involved in speculative computation are copied (e.g. constraint variables or clauses in a choice statement). So, determined data (e.g., determined variables) are not copied. Is Oz perhaps that ideal already??
%%
%%  - carefully proofread/rethink examples below
%%
%%  - check different settings for MyScriptWithScore and MyScriptPlain:
%%
%%    - Check memory consumption of search caller function, but also
%%    the total memory consumption.
%%
%%    - Script variants with determined solution (i.e. a single space)
%%    should considerably differ in their memory consumption (added
%%    memory consumption of score object)
%%
%%    - The memory consumption difference between a search resulting
%%    in two spaces and a search resulting in a single space should be
%%    equal and very small for MyScriptWithScore and MyScriptPlain: if
%%    no score was copied then only the copying of a single variable
%%    is the memory difference.
%%
%%    - ?? Check memory consumption using Explorer instead of
%%    Search.base.one: it probably needs more memory anyway (e.g. for
%%    Tk), but are the differences above the same. Otherwise, the
%%    search implemented by the Explorer differs -- unlikely, as it
%%    very probably uses the same space primitives.
%%
%%
%%  - Double-check your findings using the space primitives (create a
%%  local child space _within_ its parent space): how much memory does
%%  copying a space containing a score object cost?  Compare: what
%%  does it cost memory-wise with no undetermined variable, with a
%%  single undetermined variable, and with two undetermined
%%  variables. Compare with the findings above..
%%
%%  - Look at the other example reporting a different efficiency
%%  (time-wise..) for using a score or just a plain list.
%%
%%  - Test whether using logic programming instead of constraint
%%  programming (using choice with different score objects) changes
%%  matters.
%%
%%
%%
%%  Reading Schulte. PCS, p. 31: iin nested spaces "only determined
%%  toplevel variables are visible in a local space, non-determined
%%  variables are ruled out". Non-speculative computations (e.g., I/O)
%%  are only allowed at top-level.
%%
%%  Reading CMT, e.g., p. 764: a space contains a thread store, a
%%  constraint store and a mutable store. So, there can be speculative
%%  computations involving state (i.e. a local mutable
%%  store). Question: is the mutable store a copy of its parent
%%  space's mutable store from which it is cloned, even if no
%%  speculative computations on stateful values are
%%  involved. Similarily, does the constaint store copy values which
%%  are determined and so no speculative computations can happen on
%%  them?
%%
%%  CMT, p. 764f: a variable belongs to exactly one space. However,
%%  child spaces can see the variable and can introduce new
%%  bindings (basic constraints). When a child space introduced a new variable binding,
%%  itself and its child spaces can see it.
%%
%%  CMT, p. 769: Space.clone creates an exact copy of a given space:
%%  this seems to imply that all stores are fully copied... Is this
%%  so?
%%
%%
%% TODO: measure how the examples differ in the amout of memory (and time) comsumed by copying.
%%
%% Approaches:
%%
%%  - !! Measure total amount of memory and time required by search (e.g. put each script in an application of its own, call plain solver and measure time and memory with UNIX tools such as time and ...)
%%    -> which UNIX tool measures memory consumption of a call?
%%
%%    I want the max amount of memory taken by a program during its runtime
%%    ?? vmmap (heap, leaks)
%%
%%    /Developer/Applications/Performance\ Tools/MallocDebug.app/ -- seems to work only for application bundles
%%    
%%
%%  - !!?? Measure with Oz profiler:
%%    problem: the memory/time comsumption of copying seems not to show if I just compile CSP with profiling information.
%%    Alternative option: temporarily, compile whole Mozart with profiling and check memory consumption of space copying proc (results will be very hard to read in this case!) 
%%


%%
%% TODO: _if_ I found out that memory reduction can be significantly reduced by defining the music representation outside the script/space, then I have to develop abstractions/templates for the following cases (it will be more complex than having the score inside the script, but it shouldn't be too hard..). 
%%
%%  - distribution strategies
%%  - implicit constraints
%%  - expressive rule applications 
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
/** %% Processes a list of VarPointers: returns a list with variable declarations of the VarPointers in the form Domain#dom(InitDomain). As a side-effect, it also determines the indices of the VarPointers (corresponds to the position of the variable decl in the returned list).
%% */
%% NB: if indices must be unique, then this function must either be called only once, or an IndexOffset must be given as additional arg
fun {MakeVarDecls VarPointers}
   {List.mapInd VarPointers
    fun {$ I VarPointer}
       (VarPointer.index) = I
       (VarPointer.domain)#dom(VarPointer.initDomain)
    end}
end
/** %% Expects a variable declaration in the form Domain#dom(InitDomain) and returns a kinded variable with the domain InitDomain.
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
   {FD.distinct {Map {MyExternalScore mapItems($ getPitch)}
		  fun {$ X} {PointerToVar X VarTuple} end}}
   {FD.distinct Intervals}	
   %% Specify search strategy
   {FD.distribute ff VarTuple}
end
fun {Search_MyScriptWithVarPointers} {Search.base.one MyScriptWithVarPointers} end


%% Port interface (from Schulte, Porgramming Constraint Services, p. 24)
local
   /** %% Applies binary procedure {P X Y} to every pair X#Y in the pair stream XYs.  
   %% */
   proc {Serve XYs P} 
      if XYs\=nil
      then XYr X Y in 
	 XYs = (X#Y) | XYr
	 {P X Y}
	 {Serve XYr P} 
      end 
   end
in
   /** %% Establishes a communication via a port. Expects a binary procedure with the interface {P X Y} and returns a binary procedure with the same interface. The returned procedure is a cousin of SendRecv and can be used to send a message via a port and receive an answer. The user-defined P processes all received messages. 
   %% */
   proc {NewService P ServiceP} 
      XYs
      Po = {NewPort XYs}
   in  
      thread {Serve XYs P} end 
      proc {ServiceP X Y} {Port.sendRecv Po X Y} end 
   end 
end
/** %% Defines communication channel between spaces and outside music representation. Usage: send over a binay procedure expecting the external score as argument and returning a result without a reference to the score. Quasi send this result back (no actual back sending, jsut unification..).
%% */
MySendRecv = {NewService proc {$ M Y}			    
			    Y = case M of getPitches
				then {MyExternalScore mapItems($ getPitch)}
				end
			 end}
%% It seems I must not send procedures across space boundaries, causes Error: Space: Situatedness violation  
% MySendRecv = {NewService proc {$ P Y} Y = {P MyExternalScore} end}
%%
%%
%% In this variant, MyExternalScore is never referenced directly. Instead, all communication happens via a port.
proc {MyScriptWithVarPointersAndPort VarTuple}
   Intervals = {FD.list N1 1#N1}
   PitchVarPointers = {MySendRecv getPitches}
   % PitchVarPointers = {MySendRecv fun {$ MyScore} {MyScore mapItems($ getPitch)} end}
   Pitches
in
   VarTuple = {MakeVarTuple VarDecls}
   Pitches = {Map PitchVarPointers
	      fun {$ X} {PointerToVar X VarTuple} end}
   for
      Pitch1 in {List.take Pitches N1} % butlast of Pitches
      Pitch2 in Pitches.2		    % tail of Pitches
      Interval in Intervals
   do
      {FD.distance Pitch1 Pitch2 '=:' Interval}
   end      
   {FD.distinct Pitches}		% no pitch class repetition
   {FD.distinct Intervals}		% no (abs) interval repetition
   %% Specify search strategy
   %% NOTE: How can I score distribution strategy??
   {FD.distribute ff VarTuple}
end
fun {Search_MyScriptWithVarPointersAndPort} {Search.base.one MyScriptWithVarPointersAndPort} end



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
   {FD.distinct Pitches}		% no pitch class repetition
   {FD.distinct Intervals}		% no (abs) interval repetition
   %% Specify search strategy
   {FD.distribute ff Pitches}
end
fun {Search_MyScriptWithScore} {Search.base.one MyScriptWithScore} end



proc {MyScriptPlain Pitches}
   Intervals
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
   {FD.distinct Pitches}		% no pitch class repetition
   {FD.distinct Intervals}		% no (abs) interval repetition
   %% Specify search strategy
   {FD.distribute ff Pitches}
end
fun {Search_MyScriptPlain} {Search.base.one MyScriptPlain} end


