
%declare 
%[Score] = {ModuleLink ['x-ozlib://anders/music/sdl/ScoreCore.ozf']}

%% 
%% checking single score objects
%%

declare
E = {New Score.event init}
P = {New Score.pause init(duration:3)}
P1 = {New Score.parameter init(info:x)}
P2 = {New Score.amplitude init}
N = {New Score.note init(addParameters: [{New Score.parameter init(info:fmIndex)}])}
% without finishing init process by closeScoreHierarchyTree, toPPrintRecord suspends
{E closeScoreHierarchy(mode:tree)} 		
{N closeScoreHierarchy(mode:tree)} 
{P closeScoreHierarchy(mode:tree)} 

{E toPPrintRecord($)}

{N toPPrintRecord($)}

{P toPPrintRecord($)}

{E toPPrintRecord($ features:[info parameters]
		 excluded:[isTimePoint])}

{P1 toPPrintRecord($)}
{P2 toPPrintRecord($)}


{Score.isScoreObject E} == true
{Score.isScoreObject test} == false
{Score.isScoreObject {New class $ meth init skip end end init}} == false

{E isScoreObject($)} == true 
{E isElement($)} == true
{E isContainer($)} == false

{E getStartTime($)} = 1
{E getDuration($)} = 3
{{E getDurationParameter($)} getUnit($)} = secs

{{E getStartTimeParameter($)} toPPrintRecord($)}

% {E addFlag(test)}
% {E hasFlag(test $)}
% {E hasFlag(bla $)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% checking a simple score hierarchy
%%

declare
N1 = {New Score.note init(info: n1)}
N2 = {New Score.note init(info: n2)}
P1 = {New Score.pause init(info: p1)}
P2 = {New Score.pause init(info: p2)}
Sim = {New Score.simultaneous init(items: [N2 P2]
			       info: sim)}
Seq = {New Score.sequential init(items:[P1 N1 Sim]
			     info: seq)}
%% finalise init
{Seq closeScoreHierarchy(mode:tree)}


{Seq getItems($)}
{Seq getParameters($)}
{Seq getContainers($)}

{Seq forAll(test:isItem mode:tree Browse)}

{Map {Seq getItems($)} 
 fun {$ X} if {X isContainer($)} then {X getItems($)} else nil end end}

% reaches many parameters
%{Seq forAll(mode:tree Browse)}

{All
 [
  {N1 getPosition($ Seq)} == 2
  {N2 getPosition($ Seq)} == nil
  %
  {N1 getPosRelatedItem($ ~1 Seq)} == P1
  {N1 getPosRelatedItem($ 1 Seq)} == Sim
  %
  {N1 getPredecessor($ Seq)} == P1
  {N1 getSuccessor($ Seq)} == Sim
  %
  {N1 isFirstItem($ Seq)} == false
  {P1 isFirstItem($ Seq)} == true
  {N1 isLastItem($ Seq)} == false
  {Sim isLastItem($ Seq)} == true
 ]
fun {$ X} X==true end}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
Note = {New Score.note init(info: n1)}
Seq = {New Score.sequential init(info:seq items:[Note])}
{Seq closeScoreHierarchy(mode:tree)}

%% reference noteParam -> item
{{Note getDurationParameter($)} getItem($)}

%% reference item -> container
{{Seq getItems($)}.1 getContainers($)}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% test timing related init constraints
%%


%% simple seq: calc all timing params with given toplevel startTime
%% and duration + offsetTime of all elements
%%
declare
N1 = {New Score.note init(info: n1 duration:2 offsetTime:0)}
N2 = {New Score.note init(info: n2 duration:3 offsetTime:2)}
Seq = {New Score.sequential init(items:[N1 N2] info: seq 
			     % toplevel offsetTime not used/need
			     startTime:1)} 
{Seq closeScoreHierarchy(mode:tree)}

{Browse {Seq toPPrintRecord($ features:[info items parameters value])}}


%  initDomains for all Parameters
{Seq forAll(proc {$ X} {X initFD} end
	    test:fun{$ X} {X isParameter($)} end)}

% constrain all timing
{ForAll 
 Seq|{Seq collect($ test:fun{$ X} {X isTimeMixin($)} end)}
 proc {$ X} {X constrainTiming} end}


%% simple sim: calc all timing params with given toplevel startTime
%% and duration + offsetTime of all elements
%%
declare
N1 = {New Score.note init(info: n1 duration:2 offsetTime:0)}
N2 = {New Score.note init(info: n2 duration:3 offsetTime:2)}
Sim = {New Score.simultaneous init(items:[N1 N2] info: sim
			     % toplevel offsetTime not used/need
			     startTime:1)} 
{Sim closeScoreHierarchy(mode:tree)}

{Browse {Sim toPPrintRecord($ features:[info items parameters value])}}

% initDomains for all Parameters
{Sim forAll(proc {$ X} {X initFD} end
	    test:fun{$ X} {X isParameter($)} end)}

{ForAll 
 Sim|{Sim collect($ test:fun{$ X} {X isTimeMixin($)} end)}
 proc {$ X} {X constrainTiming} end}





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% MakeScore
%%

%% more flexible input format for MakeScore
%%
%% * object creation: give single object name (atom) or record 
%%
%% * arbitrary object features/attributes can be initialised (args as
%% to init method)
%%

{Score.makeScore note unit}

{{Score.makeScore note(startTime:0) unit} toPPrintRecord($)}

%% * contained objects and containers for object can be specified by
%% using the respective object attribute (items or containers). Their
%% values must be a list 

{{Score.makeScore seq(items:[note(duration:1 offsetTime:0)
		       note(duration:2 offsetTime:0)]
		startTime:0)
  unit} toPPrintRecord($)}

{{{Score.makeScore note(pitch:31 containers:[seq]) unit}
  getTopLevels($)}.1
 toPPrintRecord($)}



% * subparts of the score are accessible via the handle argument
declare
Note1 Note2
MyScore = {Score.makeScore seq(items:[note(handle:Note1 duration:1 offsetTime:0)
				      note(handle:Note2 duration:2 offsetTime:0)]
			       startTime:0)
	   unit}

{Note1 toInitRecord($)}
{Note2 toInitRecord($)}
{MyScore toInitRecord($)}


%% object already accessible via handle before score is fully initialised
declare
MySpec = note(handle:_ duration:1 offsetTime:0)
MyScore = {Score.makeScore2 MySpec unit}

{Browse MySpec.handle} 


%% * Different classes or constructors
%%
%% !! TODO: define simple mkMotif here

{{Score.makeScore seq(items:[motif(n:2) motif(n:1)]
		      startTime:0)
  add(motif:ScoreAdd.mkMotif)}
 toPPrintRecord($)}



%% * to reference the same object multiple times, each object can be
%% marked by an unique symbolic ID. Using an id inside the
%% repetition construct object#N refers to the same object multiple
%% times.
%%
%% Objects with the same ID are unified, hence attributes and features
%% of the object need to be given only once.
%%
%% The example creates a sim containing 2 notes. Each note is also
%% contained in chord(id:1)
%%
%% No use of logic variables: that way the record score representation
%% can even be created by another non-Oz application.
%%
%% If no ID is specified, then Strasheela automatically assigns a unique integer as ID. To avoid any incidental doublications of the same ID for multiple objects, it is strongly advised only to use atoms/names when assigning IDs by hand.

{{Score.makeScore note(id:1) unit}
 toPPrintRecord($)}

declare
MyScore = {Score.makeScore sim(items:[note(containers:[aspect(id:1 info:test)]
				     duration:1)
				note(containers:[aspect(id:1)]
				     duration:2)])
	   unit}

{{MyScore collect($ test:isContainer mode:graph)}.1
 toPPrintRecord($)}

{MyScore toPPrintRecord($)}

declare
ID = {Name.new}
MyScores = {Score.makeScore [seq(id:ID)
			     note(containers:[seq(id:ID)])
			     note(containers:[seq(id:ID)])]
	    unit}

{MyScores.1 toPPrintRecord($ features:[items id])}

%% !! problems with recursive def: loops infinite
declare
ID = {Name.new}
MyScores = {Score.makeScore
	    seq(id:ID items:[note(containers:[seq(id:ID)])
			     note(containers:[seq(id:ID)])])
	    unit}


%% * The whole score hierarchy and their different aspects can be
%% expressed separately. The whole expression can be put in a list:
%%

{Map {Score.makeScore [note note] unit}
 fun {$ X} {X toPPrintRecord($)} end}


declare
MyScores = {Score.makeScore [aspect(id:1 info:bla)
		       aspect(items:[note(info:x containers:[aspect(id:1)])
				     note(info:y)])]
	    unit}

{Map MyScores
 fun {$ X} {X toPPrintRecord($)} end}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% using id within Score.makeScore within a search script
%% 


declare
%% define search script 
proc {SearchScript MyScore}
   %% create score representation
   MyScore = {Score.makeScore
	      {Append [seq(id:1 startTime:0 offsetTime:0 timeUnit:beats(4))]
		{LUtils.collectN 4
		 fun {$}
		    note(containers:[seq(id:1)]
			 offsetTime:0 
			 amplitude:1
			 duration:{FD.int 1#10} 
			 pitch:{FD.int 48#72})
		 end}}
	      unit}.1	
   %% add some Constraints:
   %%
   %% all note durations distinct
   {FD.distinctD {Map {MyScore getItems($)}
		 fun {$ X} {X getDuration($)} end}}
   %% all note pitches <: than pitch of successor note
   {ForAll 
    {MyScore collect($ test:fun{$ X}
			       {X isItem($)} andthen 
			       {X hasPredecessor($ {X getTemporalAspect($)})}
			    end)}
    proc {$ X}
       Pre = {X getPredecessor($ {X getTemporalAspect($)})}
       PrePitch = {Pre getPitch($)}
       XPitch = {X getPitch($)}
    in
       PrePitch <: XPitch
    end}
   %% Distribution
   {FD.distribute
    {SDistro.makeFDDistribution startTime}
    {MyScore collect($ test:isParameter)}}
end


{ExploreOne SearchScript}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% using MakeScore2, InitScore and bilinkItems in a search script

declare
%% define search script 
proc {SearchScript MyScore}
   %% create score representation
   MySeq = {Score.makeScore2 seq(id:1 startTime:0 offsetTime:0 timeUnit:beats(4))
	    unit}
   MyNotes = {Score.makeScore2 {LUtils.collectN 4
				fun {$}
				   note(containers:[seq(id:1)]
					offsetTime:0 
					amplitude:1
					duration:{FD.int 1#10} 
					pitch:{FD.int 48#72})
				end}
	      unit}
in
   {MySeq bilinkItems(MyNotes)}
   {Score.initScore MySeq}
   MyScore = MySeq
   %% add some Constraints:
   %%
   %% all note durations distinct
   {FD.distinctD {Map {MyScore getItems($)}
		 fun {$ X} {X getDuration($)} end}}
   %% all note pitches <: than pitch of successor note
   {ForAll 
    {MyScore collect($ test:fun{$ X}
			       {X isItem($)} andthen 
			       {X hasPredecessor($ {X getTemporalAspect($)})}
			    end)}
    proc {$ X}
       Pre = {X getPredecessor($ {X getTemporalAspect($)})}
       PrePitch = {Pre getPitch($)}
       XPitch = {X getPitch($)}
    in
       PrePitch <: XPitch
    end}
   %% Distribution
   {FD.distribute
    {SDistro.makeFDDistribution startTime}
    {MyScore collect($ test:isParameter)}}
end


{ExploreOne SearchScript}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% MakeConstructor
%%

declare
MakeNote = {Score.makeConstructor Score.note
	    unit(offsetTime:{FD.int 0#10})} % buildin default is 0
N = {MakeNote unit(pitch:60)}
{Score.init N}

{N toInitRecord($)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% MakeItems 
%% 

%%
%% MakeItems used directly with arg shorthand 
%%

declare
MyNotes = {Score.makeItems unit(n:3
% 				constructor:Score.note % default
				amplitude:fenv#{Fenv.linearFenv [[0.0 64.0]
								 [1.0 127.0]]}
				pitch:each#[60 62 64]
				duration:2)}
{ForAll MyNotes Score.initScore}

{Browse {Map MyNotes fun {$ X} {X toInitRecord($)} end}}


%%
%% MakeItems_iargs
%%

declare
Ns = {Score.makeItems_iargs unit(iargs: unit(n: 3
					     info: test
% 				constructor:Score.note % default
					     amplitude:fenv#{Fenv.linearFenv [[0.0 64.0]
									      [1.0 127.0]]}
					     pitch:each#[60 62 64])
				 %% 
				 rargs: unit)}
{ForAll Ns Score.init}		

{Pattern.mapItems Ns toInitRecord}

%%
%% MakeItems_iargs used directly with arg shorthand
%% each-args supported for rargs
%%
%% ... feature removed again 
%%
% %% NOTE: problem: Args.iargs.n is used for specifying number of runs, but I now cannot set number of notes in the run anymore, not can I overwrite the constructor of note items 
% declare
% MakeRun			
% = {Score.defSubscript unit(rdefaults: unit(direction: '<:')
% 			   idefaults: unit(n:5))
%    proc {$ MyMotif Args} % body
%       {Pattern.continuous {MyMotif mapItems($ getPitch)}
%        Args.rargs.direction}
%    end}
% MyNotes = {Score.makeItems_iargs
% 	   unit(iargs: unit(n: 2
% 			    constructor:MakeRun
% 			    duration:2)
% 		rargs: unit(direction: each # ['>:' '<:']))}
% {ForAll MyNotes Score.initScore}

% {Browse {Map MyNotes fun {$ X} {X toInitRecord($)} end}}



%%
%% MakeItems used within Score.make
%%

declare
MyScore 
= {Score.make sim({Score.makeItems unit(n:3
					pitch:each#[60 62 64]
					offsetTime:each#[0 500 1500]
					duration:100)}
		  startTime:0
		  timeUnit:milliseconds)
   unit}
{Score.initScore MyScore}

{Browse {MyScore toInitRecord($)}}

%%
%% using Fenvs
%%

declare
MyScore = {Score.make
	   seq({Score.makeItems unit(n:3
				     info:[test value]
				     amplitude:fenv#{Fenv.linearFenv [[0.0 60.0]
								      [1.0 127.0]]}
				     pitch:each#[60 62 64]
				     duration:2)}
	       startTime:0
	       timeUnit:beats)
	   unit}
{Score.initScore MyScore}

{Browse {MyScore toInitRecord($)}}


%%
%% MakeItems as constructor in Score.make (for label items) 
%%

declare
MyScore = {Score.make seq(items(n:3
				duration:2))
	   unit}

%% equivalent to
declare
MyScore = {Score.make seq([note(duration:2)
			   note(duration:2)
			   note(duration:2)])
	   unit}

{Browse {MyScore toInitRecord($)}}



%%
%% items are containers already 
%%

declare
MakeRun			
= {Score.defSubscript unit(rdefaults: unit(direction: '<:')
			   idefaults: unit(n:5))
   proc {$ MyMotif Args} % body
      {Pattern.continuous {MyMotif mapItems($ getPitch)}
       Args.rargs.direction}
   end}
MyScore = {Score.make seq(items:{Score.makeItems items(n:3
						 constructor:MakeRun
% 						 iargs:unit(n:2
% 							    constructor:Score.note
% 							    duration:3)
						)}
			  startTime:0
			  timeUnit:beats)
	   unit}

{Browse {MyScore toInitRecord($)}}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% MakeContainer
%%

declare
MyScore = {Score.makeSeq unit(iargs:unit(n:3
					duration:2)
			      startTime:0
			      timeUnit:beats)}
{Score.init MyScore}

{MyScore toInitRecord($)}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Score.defSubscript 
%%


declare
%% def scripts
%%
%% seq of 'n' notes, pitches constrained by Pattern.continuous with 'direction' 
MakeRun			
= {Score.defSubscript unit(rdefaults: unit(direction: '<:')
			   idefaults: unit(n:5))
   proc {$ MyMotif Args} % body
      {Pattern.continuous {MyMotif mapItems($ getPitch)}
       Args.rargs.direction}
   end}
%% extends MakeRun: all note pitch domains constrained to 'pitchDom'
MakeRun_PitchDom
= {Score.defSubscript unit(super: MakeRun
			   rdefaults: unit(pitchDom: 60#72))
   proc {$ MyMotif Args}
      %% TODO: define pattern constraint Pattern.domains (or similar name)
      {ForAll {MyMotif mapItems($ getPitch)}
       proc {$ P} P = {FD.int Args.rargs.pitchDom} end}
   end}
%%
%% use scripts for creating scores, overwriting a few args 
MyRun = {MakeRun
	 unit(iargs:unit(n: 2
			 duration:2)
	      rargs:unit(direction:'>:')
	      startTime:0)}
{Score.init MyRun}
%%
MyRun2 = {MakeRun_PitchDom
	  unit(iargs:unit
% 		rargs:unit(direction:'<:')
	       startTime:0)}
{Score.init MyRun2}


{MyRun toInitRecord($)}

{MyRun2 toInitRecord($)}


{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {MakeRun unit}
    {Score.init MyScore}
 end
 unit}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% DefMixinSubscript
%%


declare
MakeDottedRhythm
= {Score.defMixinSubscript unit(rdefaults: unit(shortDur: 1))
   proc {$ MyScore Args} % mixin body
      Durs = {MyScore mapItems($ getDuration)}
      %% Durs length must be at least 2
      [Dur1 Dur2] = {List.take Durs 2}
   in
      Dur1 =: Dur2 * 3
      Dur2 = Args.rargs.shortDur
      {Pattern.cycle Durs 2}
   end}
MakeContinuousNotes
= {Score.defSubscript unit(super:Score.makeContainer
			   rdefaults: unit(direction: '<:')
			   idefaults: unit(n:3))
   proc {$ MyScore Args} % subscript body
      {Pattern.continuous {MyScore mapItems($ getPitch)}
       Args.rargs.direction}
   end}
MakeMyMotif
=  {Score.defSubscript unit(super: MakeContinuousNotes
			    mixins: [MakeDottedRhythm])
    GUtils.binarySkip}
declare
%% Motif application (MyScore is not fully initialised, see MakeContainer)
MyScore
= {MakeMyMotif
   unit(iargs:unit(%% number of notes (overwrites default 3)
		   n: 4)
	%% decreasing pitches (overwrites default '<:')
	rargs:unit(direction:'>:'
		   shortDur: 2
		  )
	%% argument to top-level container 
	startTime:0)}
{Score.init MyScore}

{Browse {MyScore toInitRecord($)}}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% ItemslistToContainerSubscript
%%

declare
MakeRun_Notes			
= {Score.defSubscript unit(super:Score.makeItems_iargs
			   rdefaults: unit(direction: '<:')
			   idefaults: unit(n:5))
   proc {$ Notes Args} % body
      {Pattern.continuous {Pattern.mapItems Notes getPitch}
       Args.rargs.direction}
   end}
MakeRun_Seq = {Score.itemslistToContainerSubscript MakeRun_Notes seq}
%%
MyRun = {MakeRun_Seq
	 unit(iargs:unit
	      startTime:0)}
{Score.init MyRun}

{MyRun toInitRecord($)}


%%
{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {MakeRun_Seq unit(startTime:0
				iargs:unit(n: 3
					   duration:2))}
    {Score.init MyScore}
 end
 unit}


%%
{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {Score.make seq({MakeRun_Notes unit(iargs:unit(n: 3
							     duration:2))}
			      startTime:0)
	       unit}
 end
 unit}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
%% getSimultaneousItems [unfinished test]
%%

declare
MyScore = {Score.makeScore sim(items:[seq(items:[note]) seq(items:[note])]) unit}
%% determine score startTime and all offsetTimes
{MyScore getStartTime($)}=0 
{ForAll MyScore|{MyScore collect($ test:isTimeMixin)}
 proc {$ X} {X getOffsetTime($)}=0 end}
{MyScore forAll(test:isNote
		proc {$ Note}
		   {Note getOffsetTime($)}=0 
		   {Note getAmplitude($)}=1
		   {Note getDuration($)}=2
		   {Note getPitch($)}=3
		end)}
fun {ToPPrintRecord MyScore}
   {MyScore toPPrintRecord($ features:[info items parameters value]
			   excluded:[isAmplitude
				     fun {$ X} 
					Info = {X getInfo($)}
				     in
					{IsDet Info} andthen
					(Info==endTime
					 orelse Info==offsetTime)
				     end])}
end

{ToPPrintRecord MyScore}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% isSimultaneousItemR [unfinished test]
%%

{Browse {ToPPrintRecord MyScore}}

declare
MyScore = {Score.makeScore sim(items:[seq(items:[note]) seq(items:[note])]) unit}
%% determine score startTime and all offsetTimes
{MyScore getStartTime($)}=0 
{ForAll MyScore|{MyScore collect($ test:isTimeMixin)}
 proc {$ X} {X getOffsetTime($)}=0 end}
{MyScore forAll(test:isNote
		proc {$ Note}
		   %{Note getOffsetTime($)}=0 
		   {Note getAmplitude($)}=amp
		   {Note getDuration($)}=2
		   {Note getPitch($)}=pitch
		end)}
fun {ToPPrintRecord MyScore}
   {MyScore toPPrintRecord($ features:[info items parameters value]
			   excluded:[isAmplitude
				     fun {$ X} 
					Info = {X getInfo($)}
				     in
					{IsDet Info} andthen
					(Info==endTime
					 orelse Info==offsetTime)
				     end])}
end

declare 
Seqs = {MyScore collect($ test:isSequential)}
N1 = {Seqs.1 getItems($)}.1
N2 = {Seqs.2.1 getItems($)}.1

%% notes with equal startTime

{Browse {N1 isSimultaneousItemR($ N2)}} 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% timing constraints of nested seq and sim: sim is more expensive
%% (seq of seqs has no fail, seq of sims has a few), but seems to be
%% OK in principle
{ExploreOne
 proc {$ MyScore}
    MyScore = {Score.makeScore
	       seq(items:{LUtils.collectN 3
			  fun {$}
			     %% interchange 'seq' and 'sim'
			     sim(items:{LUtils.collectN 3
					fun {$}
					   note(offsetTime:{FD.int 0#2}
						amplitude:1
						duration:{FD.int 1#3}
						pitch:60)
					end}
				 offsetTime:{FD.int 0#2})
			  end}
		   startTime:0
		   offsetTime:0)
	       unit}
    {FD.distribute
     {SDistro.makeFDDistribution
      unit(order:startTime
	   value:mid)}
     {MyScore collect($ test:isParameter)}}
 end}


%% test sim timing constraints (max...)
{ExploreOne
 proc {$ MyScore}
    MyScore = {Score.makeScore
	       seq(items:{LUtils.collectN 3
			  fun {$}
			     sim(items:{LUtils.collectN 3
					fun {$}
					   note(offsetTime:{FD.int 0#2}
						amplitude:1
						duration:{FD.int 1#3}
						pitch:60)
					end}
				 offsetTime:{FD.int 0#2})
			  end}
		   startTime:0
		   offsetTime:0)
	       unit}
    %% ensure note end smaller then predecessor to test sim timing constraints
    {MyScore forAll(test:fun {$ X}
			    {X isNote($)} andthen {X hasTemporalPredecessor($)}
			 end
		    proc {$ Note2}
		       Note1 = {Note2 getTemporalPredecessor($)}
		    in
		       {Note1 getEndTime($)} >: {Note2 getEndTime($)}
		    end)}
    {FD.distribute
     {SDistro.makeFDDistribution
      unit(order:startTime
	   value:mid)}
     {MyScore collect($ test:isParameter)}}
 end}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%
%% toInitRecord
%%

%%
%% NB: per default, no endTime params are shown exclude:[endTime] -- can be changed by setting exclude to nil
%%
%% NB: startTime is only shown for top-level score objects (temporal aspects and also temporal elements)
%%
%%

%% default exclude
{{Score.makeScore note(info:test
		       startTime:50
		       duration:{FD.int 10#13})
  unit}
 toInitRecord($)}

%% exclude: nil: shows endTime, but only if score creation has enough time for propagation
declare
MyScore = {Score.makeScore note(startTime:50
				duration:1)
	   unit}

{MyScore toInitRecord($ exclude:nil)}


%% items list is string...
{{Score.makeScore
  seq(items:[note(duration:1
		  amplitude:{FD.int 10#64})
	     note(duration:2)]
      offsetTime:2
      startTime:0)
  unit}
 toInitRecord($)}

%% not all params shown sometimes: probably the constraint propagation
%% did not bind these params before toInitRecord was called
{{Score.makeScore
  seq(items:[note(duration:1)
	     note(duration:2)]
      offsetTime:2
      startTime:0)
  unit}
 toInitRecord($ exclude:nil)}

%% It's always OK if toInitRecord is shortly delayed...
declare
MyScore = {Score.makeScore
	   seq(items:[note(duration:{FD.int 1#3})
		      note(duration:2)]
	       offsetTime:2
	       startTime:0)
	   unit}

{MyScore toInitRecord($ exclude:nil)}

{Out.recordToVS
 {MyScore toInitRecord($)}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%
%% getInitClasses
%%

declare
MyNote = {Score.makeScore note(info:fun {$ X} X end) unit}
MyScore = {Score.makeScore seq(items:[note(duration:1
					   pitch:60
					   amplitude:64
					   info:[fun {$ X} X end
						 class $ end])
				      note(duration:1
					   pitch:60
					   amplitude:64)
				      note(duration:1
					   pitch:60
					   amplitude:64)]
			       startTime:0
			       timeUnit:(beats))
	   unit}
MyHSScore = {Score.makeScore sim(items:[seq(items:[note
						   note])
					seq(items:[chord])]
				 startTime:0
				 timeUnit:(beats))
	     unit(note:HS.score.note
		  chord:HS.score.chord
		  sim:Score.simultaneous
		  seq:Score.sequential)}
%% see comments below
MyScore2 = {Score.makeScore seqFoo(items:[noteBar
					  noteBar])
	    unit(noteBar:Score.note
		 seqFoo:Score.sequential)}


{MyNote getInitClasses($)}

{MyScore getInitClasses($)}
{MyScore getInitClassesVS($)}

{MyHSScore getInitClasses($)}
{MyHSScore getInitClassesVS($)}

%% NB: toInitRecord does not preseve some special label used in the textual score for some class. Instead, it always uses the label defined by the class. Equally, also getInitClasses and getInitClassesVS always use the label defined by the class. Hence, these methods are consistent and can be used together.
%% NB: Because these methods always use the labels defined by the classes, classes with the same label can not be mixed in the score (e.g., one can not directly use Score.note and HS.score.note in the same score). Using these classes together can easily lead to a hard to comprehend CSP anyway. Nethertheless, if you want to mix such classes, simply subclass them with a different label.
{MyScore2 toInitRecord($)}
{MyScore2 getInitClasses($)}
{MyScore2 getInitClassesVS($)}


%% what happens if strasheelaFunctors is set insufficiently -- it should through an exception
%%
declare
% {Init.putStrasheelaEnv strasheelaFunctors env('Strasheela':Strasheela)}
{Init.putStrasheelaEnv strasheelaFunctors env}
MyScore = {Score.makeScore seq(items:[note(duration:1
					   pitch:60
					   amplitude:64)
				      note(duration:1
					   pitch:60
					   amplitude:64)
				      note(duration:1
					   pitch:60
					   amplitude:64)]
			       startTime:0
			       timeUnit:(beats))
	   unit}

{MyScore getInitClassesVS($)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%
%% copyScore
%%

declare
MyScore = {Score.makeScore sim(items:[seq(items:[note
						 note])
				      seq(items:[chord])]
			       startTime:0
			       timeUnit:beats)
	   unit(note:HS.score.note
		chord:HS.score.chord
		sim:Score.simultaneous
		seq:Score.sequential)}


{{Score.copyScore MyScore} toInitRecord($)}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%
%% Score.transformScore
%%

declare
MyScore = {Score.makeScore seq(items:[note(duration:1
					   pitch:60)
				      note(duration:1
					   pitch:62)
				      note(duration:1
					   pitch:63)]
			       startTime:0
			       timeUnit:(beats))
	   unit}

%% Transpose score by 2 semitones
{{Score.transformScore MyScore
  unit(clauses:[isNote#fun {$ N}
			  {Adjoin {N toInitRecord($)}
			   note(pitch:{N getPitch($)}+2)}
		       end])}
 toInitRecord($)}


%% Reverse notes in container
{{Score.transformScore MyScore
  unit(clauses:[isSequential#fun {$ C}
				{Adjoin {C toInitRecord($)}
				 %% NOTE: explicitly create textual versions of the contained score objects
				 seq(items:{Reverse {C mapItems($ toInitRecord)}})}
			     end])}
 toInitRecord($)}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%
%% toFullRecord
%%

declare
MyScore = {Score.makeScore note(duration:1 startTime:50) unit}

{MyScore toFullRecord($)}


declare
MyScore = {Score.makeScore seq(items:[sim(items:[note(duration:1)
						 note(duration:1)])
				      note(duration:1)])
	   unit}

{MyScore toFullRecord($)}

{MyScore toFullRecord($ exclude:[parameters id flags startTime endTime])}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%
%% Score.makeClass
%%

declare
MyNoteClass = {Score.makeClass Score.note
	       newNote(foo bar)
	       unit(initRecord:newNote(foo:green bar:blue))}

declare
MyNote = {Score.makeScore note(foo:white) unit(note:MyNoteClass)}

{MyNote toFullRecord($)}	

{MyNote getFeatures($)}

{MyNote toInitRecord($)}

%%
%% def. subclass with parameter: 
%%

declare
MyNoteClass = {Score.makeClass Score.note
	       newNote(foo fooParam)
	       unit(initRecord:newNote(foo:10)
		    init:proc {$ Self Args}
			    Self.fooParam = {New Score.parameter
						   init(value:Args.foo
							info:foo)}
			    Self.foo = {Self.fooParam getValue($)}
			    {Self bilinkParameters([Self.fooParam])}
			 end)}

declare
MyNote = {Score.makeScore note(foo:17) unit(note:MyNoteClass)}

{MyNote toFullRecord($)}	

MyNote.foo

MyNote.fooParam

{MyNote getFeatures($)}

{MyNote toInitRecord($)}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%
%% unifying objects 
%%

declare
Note1 = {Score.makeScore note(duration:1
			      pitch:60
			      amplitude:64)
	 unit}
Note2 = {Score.makeScore note
	 unit}

%% some parameter values in Note2 are undetermined
{Browse {Note2 toFullRecord($ exclude:[flags])}}

%% unification determines those variables 
{Note1 unify(Note2)}

{Browse Note1 == Note2}
% -> false 

{Browse {Note1 '=='($ Note2)}}
% -> true 




%%%%%

declare
Score1 = {Score.makeScore seq(items:[note(duration:1
					  pitch:60
					  amplitude:64)
				     note(duration:1
					  pitch:60
					  amplitude:64)
				     note(duration:1
					  pitch:60
					  amplitude:64)]
			      startTime:0
			      timeUnit:(beats))
	  unit}
Score2 = {Score.makeScore seq(items:[note note note])
	  unit}

%% some parameter values in Note2 are undetermined
{Browse {Score2 toFullRecord($ exclude:[flags])}}

%% unification determines those variables 
{Score1 unify(Score2)}

{Browse Score1 == Score2}
% -> false 

{Browse {Score1 '=='($ Score2)}}
% -> true 


%%%%%

%%
%% using arg overwrite
%%

declare
N1 = {Score.make note(duration: 1 amplitude: 100) unit}
N2 = {Score.make note(duration: 2 pitch: 60) unit}

%% keep duration of N1 but get pitch of N2.
%% note: amplitude and offset default to determined values, so if different they must be excluded or overwritten as well 
{N1 unify(N2 overwrite: [duration amplitude])}

{N1 toInitRecord($)}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%
%% unify
%%



declare
Score1 Score2
MyScore = {Score.make seq([seq(handle:Score1
			       [note(duration:2)
				note(duration:2)]
			       startTime:0
			       timeUnit:beats)
			   seq(handle:Score2
			       [note(pitch:60)
				note(pitch:62)])]
			  startTime:0
			  timeUnit:beats)
	   unit}

{Browse {MyScore toInitRecord($)}}

%% startTime and endTime implicitly excluded
{Score1 unify(Score2)}

{Browse {MyScore toInitRecord($)}}

%% create a fresh score first..
{Score1 unify(Score2
	      exclude:[startTime endTime pitch])}

%% create a fresh score first..
{Score1 unify(Score2
	      exclude:[startTime endTime pitch]
	      derive:[proc {$ MyScore Intervals}
			 Ps = {MyScore mapItems($ getPitch)}
		      in
			 Intervals = {Pattern.map2Neighbours Ps
				      proc {$ P1 P2 ?Interval}
					 Interval = {FD.decl}
					 P2 - P1 + 100000 =: Interval
				      end}
		      end])}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%
%% object reflection 
%%


declare
MyNote = {Score.makeScore note unit}


{MyNote getClass($)} == Score.note

{MyNote getAttrNames($)}

{MyNote getFeatNames($)}

{MyNote getMethNames($)}

{MyNote getAttrSources($)}

{MyNote getFeatSources($)}

{MyNote getMethSources($)}

{Map {MyNote getAttrNames($)}
 fun {$ Attr} {MyNote getAttr($ Attr)} end}

{Map {MyNote getFeatNames($)}
 fun {$ Feat} {MyNote getFeat($ Feat)} end}


%%
declare
MyNote = {Score.makeScore note unit(note:HS.score.note)}

%% same class name, but different class
{MyNote getClass($)} == Score.note


{MyNote getInitArgDefaults($)}

{MyNote getInitArgSources($)}



