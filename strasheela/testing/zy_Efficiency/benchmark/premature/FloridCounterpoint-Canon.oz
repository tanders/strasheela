
%%% *************************************************************
%%% Copyright (C) Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

%%
%% TODO:
%%
%% - revise and simplify example
%% - revise performance measurement -- only first steps below...
%%

/*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% performance testing 
%%

%%
%% Two techniques
%%
%% 1) first open profiler, then feed buffer, then call solvers, then check heap consumption
%%
%% 2) first open panel, then feed buffer, then call solvers, then check how memory consumption was affected
%%

%%
%% first feed code below to set profile flag, then feed buffer, then procs UseIOzSeF etc, then call solvers, then inspect profiler measurements
%%

%%
%% Results
%%
%% Memory consumption is high and does not exactly get lower with
%% recomputation. What am I missing here??
%%
%% NB: always full recomputation of failed search trees -- so depth of
%% search tree (47) has larges effect on memory consumption?
%%
%% Explorer: both computation time and memory use increase?
/*
{SDistro.exploreOne Canon
    unit(order:startTime
	 value:mid)}
*/
%% without recomputation: > 340 MB
%% fixed recomputation, MRD 5/25: > 295 MB
%% fixed recomputation, MRD 25/full: > 338 MB
%%
%% IOzSeF explorer: setting recomputation seems to have no effect at all
/* 
{SDistro.iozsefExploreOne Canon
 unit(order:startTime
      value:mid)}
*/
%% without recomputation: > 320 MB
%% adaptive recomputation, MRD 25: > 320 MB
%% adaptive recomputation, MRD 100: > 320 MB
%%


% \switch +profile
declare
% [Profile] = {ModuleLink ['x-oz://boot/Profile']}
[IOzSeF] = {ModuleLink ['x-ozlib://tack/iozsef/iozsef.ozf']}


%% recomputation settings
{IOzSeF.setOption recompStrat adaptive}
{IOzSeF.setOption mrd 25}


%% 
declare
proc {UseIOzSeF1}
   {SDistro.iozsefExploreOne Canon
    unit(order:startTime
	 value:mid)}
end
proc {UseIOzSeF2}
   {SDistro.iozsefSearchOne Canon
    unit(order:startTime
	 value:mid)}
end
proc {UseExplorer1}
   {SDistro.exploreOne Canon
    unit(order:startTime
	 value:mid)}
end
fun {UseSearch RecomputationDist}
   {SDistro.searchOneDepth Canon RecomputationDist
    unit(order:startTime
	 value:mid)
    _}
end


{UseIOzSeF1}
{UseIOzSeF2}

{UseExplorer1}

declare
Sol
{Browse Sol}			% see when it is determined

Sol = {UseSearch 0}

%% Profiler: > 380 MB
%% Panel: max heap: < 30 MB (several gc occur)

Sol = {UseSearch 5}

%% Profiler: > 280 MB
%% Panel: max heap: ~ 20 MB (gc occur)

Sol = {UseSearch 25}

%% Profiler: > 330 MB
%% Panel: max heap: ~ 25 MB (gc occur)

Sol = {UseSearch 100}

%% Profiler: > 380 MB
%% Panel: max heap: ~ 20 MB (gc occur)



{Inspect {Profile.getInfo}}

%% sort by heap size
{Inspect
 {Sort {Profile.getInfo}
  fun {$ profileStats(heap:H1 ...) profileStats(heap:H2 ...)} H1 > H2 end}}


{Inspect {LUtils.find {Profile.getInfo}
	  fun {$ profileStats(name:'UseIOzSeF' ...)} end}}


*/



declare

%%
%% Top-level definition (defines constraint script) 
%%

proc {Canon MyScore}
   EndTime Voice1 Voice2
 in
   MyScore =
   %% Score.makeScore transforms textual music representation into
   %% nested score object
   {Score.makeScore
    sim(items: [seq(%% when MyScore is created from this textual
                    %% representation, then Voice1 is bound to the
                    %% sequential object to which this arg handle
                    %% belongs
		    handle:Voice1  
		    items: {LUtils.collectN 17
			    %% LUtils.collectN returns a list of 17
			    %% note specs with individual variables at the
			    %% parameters duration and pitch
			    fun {$}
			       note(duration: {FD.int Durations}
				    pitch: {FD.int 53#67}
				    amplitude: 80)
			    end}
		    offsetTime:0
		    %% Voice1 and Voice2 end at the same time (unified end times)
		    endTime:EndTime)
		seq(handle:Voice2
		    items: {LUtils.collectN 15
			    fun {$}
			       note(duration: {FD.int Durations}
				    pitch: {FD.int 53#72}
				    amplitude: 80)
			    end}
		    %% start of Voice2 is delayed by {List.last
		    %% Durations}*2 (i.e. a semibreve)
		    offsetTime:{List.last Durations}*2
		    endTime:EndTime)]
	startTime: 0 
	timeUnit:beats(4))  % a beat has length 4 (i.e. 1 denotes a sixteenth note)
    %% use default score constructors (i.e. the constructor for seq,
    %% sim, and note are not overwritten by user)
    unit}
   %%
   %% Apply compositional rules:
   %%
   %% rules for al notes
   {MyScore forAll(test: isNote
		   proc {$ Note}
		      {InCMajor Note}
		      {NoBigJump Note}
		      {StartAndEndWithLongest Note}
		      {EndOnFullBar Note}
		      {SlowRhythmChanges Note}
		   end)}
   %% rules for notes of first voice
   {Voice1 forAll(test: isNote
		  proc {$ Note}
		     {StartAndEndWithFundamental Note}
		  end)}
   {MaxAndMinPitchOnlyOnce Voice1} {MaxAndMinPitchOnlyOnce Voice2}
   {ConstraintDissonance Voice1 Voice2}
   {NoParallels Voice1 Voice2}
   {IsCanon Voice1 Voice2}
end

%%
%% Rule definitions
%%

Durations = [2 4 8]
proc {StartAndEndWithLongest Note}
   C = {Note getTemporalAspect($)}
in
   if {Note isFirstItem($ C)} orelse
      {Note isLastItem($ C)}
   then
      {Note getDuration($)} = {List.last Durations}
   end
end
proc {EndOnFullBar Note}
   C = {Note getTemporalAspect($)}
in
   if {Note isLastItem($ C)}
   then
      {FD.modI {Note getStartTime($)} {List.last Durations}} = 0
   end
end
proc {SlowRhythmChanges Note}
   C = {Note getTemporalAspect($)}
in
   if {Note hasPredecessor($ C)}
   then
      Dur1 = {{Note getPredecessor($ C)} getDuration($)}
      Dur2 = {Note getDuration($)}
      HalveDur1 
   in
      {FD.times HalveDur1 2 Dur1}
      {FD.times HalveDur1 {FD.int [1 2 4]} Dur2}
   end
end
%% MIDI pitch domain reduction: only 'white keys' (c major)
proc {InCMajor Note}
   PitchClass = {FD.modI {Note getPitch($)} 12}
in
   {List.forAll [1 3 6 8 10]	% list of 'black key' pitch classes (c=0)
    proc {$ BlackKey} PitchClass \=: BlackKey end}
end
proc {StartAndEndWithFundamental Note}
   C = {Note getTemporalAspect($)}
in
   if {Note isFirstItem($ C)} orelse
      {Note isLastItem($ C)}
   then
      {Note getPitch($)} = 60
   end
end
%% voice leading: only intervals up to a fifth, no pitch repetition
%% (context dependent constraint -- getPredecessor -- but this
%% context is predetermined by predetermined hierarchic structure)
proc {NoBigJump Note}
   C = {Note getTemporalAspect($)}
in
   if {Note hasPredecessor($ C)}
   then
      Pitch1 = {{Note getPredecessor($ C)} getPitch($)}
      Pitch2 = {Note getPitch($)}
   in
      %% all intervals between minor second and minor third are allowed
      {FD.distance Pitch1 Pitch2 '>:' 0}
      {FD.distance Pitch1 Pitch2 '<:' 4}
   end
end
proc {MaxAndMinPitchOnlyOnce Voice}
   proc {Aux Pitches}
      Max = {Pattern.max Pitches}
      Min = {Pattern.min Pitches}
   in
      %% the max/min pitch value occurs exactly once
      {FD.sum {Map Pitches
	       proc {$ X B}
		  B = (X =: Max)
	       end}
       '=:' 1}
      {FD.sum {Map Pitches
	       proc {$ X B}
		  B = (X =: Min)
	       end}
       '=:' 1}
      %% the first and last pitches are not max/min
      Pitches.1 \=: Max
      {List.last Pitches} \=: Max	 
      Pitches.1 \=: Min
      {List.last Pitches} \=: Min
   end
   Pitches = {Voice map($ getPitch test:isNote)}
   FirstHalfPitches
   SecondhalfPitches
in
   {List.takeDrop Pitches ({Length Pitches} div 2)
    FirstHalfPitches SecondhalfPitches}
   %% Aux applied to whole pitch sequence, but also to first and
   %% second subpart (this is a bit arbitrary, however...)
   %% NB: inefficient nesting: 'higher-level' application only needs
   %% to constraint max values of lower level
   {Aux Pitches} {Aux FirstHalfPitches} {Aux SecondhalfPitches} 
end
proc {ConstraintDissonance Voice1 Voice2}
   FirstVoiceNotes = {Voice1 getItems($)}
   SecondVoiceNotes = {Voice2 getItems($)}
in
   {List.forAllInd FirstVoiceNotes
    proc {$ I Note1}
       {List.forAllInd SecondVoiceNotes
	proc {$ J Note2}
	   IsSimultaneous = {Note1 isSimultaneousItemR($ Note2)}
	   IsConsonant = {IsConsonanceR Note1 Note2}
	in
	   %% for all notes with pre- and successor
	   if {Note1 hasPredecessor($ {Note1 getTemporalAspect($)})} andthen
	      {Note1 hasSuccessor($ {Note1 getTemporalAspect($)})} andthen
	      {Note2 hasPredecessor($ {Note2 getTemporalAspect($)})} andthen
	      {Note2 hasSuccessor($ {Note2 getTemporalAspect($)})}
	      %% if not passing note then consonant  
	   then 
	      {FD.impl IsSimultaneous
	       {Pattern.disjAll
		%% note1 is passing note, simultaneous note2 started
		%% more early, and note2 is consonant to predecessor of
		%% note1 (or the other way round)
		[{Pattern.conjAll
		  [{IsPassingNoteR Note1}
		   ({Note1 getStartTime($)} >: {Note2 getStartTime($)})
		   {IsConsonanceR {Note1 getTemporalPredecessor($)} Note2}]}
		 {Pattern.conjAll
		  [{IsPassingNoteR Note2}
		   ({Note2 getStartTime($)} >: {Note1 getStartTime($)})
		   {IsConsonanceR {Note2 getTemporalPredecessor($)} Note1}]}
		 IsConsonant]}
	       1}
	   else 
	      {FD.impl IsSimultaneous IsConsonant 1}
	   end
	end}
    end}
end
%%
proc {IsConsonanceR Note1 Note2 B}
   Pitch1 = {Note1 getPitch($)}
   Pitch2 = {Note2 getPitch($)}
   Consonances = {FS.value.make [0 3 4 7 8 9 12 15 16]}
      %Consonances = {FS.value.make [0 3 4 7 8 9 15 16]}	% alternative: no octave
   Interval = {FD.decl}
in   
   {FD.distance Pitch1 Pitch2 '=:' Interval}
   {FS.reified.include Interval Consonances B}
end
proc {IsPassingNoteR Note2 B}
   Pitch1 = {{Note2 getPredecessor($ {Note2 getTemporalAspect($)})}
	     getPitch($)}
   Pitch2 = {Note2 getPitch($)}
   Pitch3 = {{Note2 getSuccessor($ {Note2 getTemporalAspect($)})}
	     getPitch($)}
   proc {IsStepR Pitch1 Pitch2 B}
      {FD.disj
       %% ?? FD.reified.distance has problems? -- I use it elsewhere here...
       {FD.conj (Pitch1 - Pitch2 >: 0) (Pitch1 - Pitch2 =<: 2)}
       {FD.conj (Pitch2 - Pitch1 >: 0)(Pitch2 - Pitch1 =<: 2)}
       B}
   end
   proc {IsContinuousDirection Pitch1 Pitch2 Pitch3 B}
      %% all pitches either lead up or down
      B = {FD.disj
	   {FD.conj (Pitch1<:Pitch2) (Pitch2<:Pitch3)}
	   {FD.conj (Pitch1>:Pitch2) (Pitch2>:Pitch3)}}
   end
in
   {Pattern.conjAll    
    %% unused: Note2 is on an easy beat (startTime is odd)
    [%% all intervals between successive pitches must be steps in same direction
     {IsStepR Pitch1 Pitch2}
     {IsStepR Pitch2 Pitch3}
     {IsContinuousDirection Pitch1 Pitch2 Pitch3}]
    B}
end
%% two notes starting at the same time (ie. simultaneous),
%% interval is perfect consonance and interval between
%% predecessors has also been that very perfect consonance
proc {OpenParallelsR Note1 Note2 B}
   %% only two voices, i.e. only one simultaneous note
        %Note2 = {Note1 getSimultaneousItems($ test:isNote)}.1
   Pitch1 = {Note1 getPitch($)}
   Pitch2 = {Note2 getPitch($)}
   PrePitch1 = {{Note1 getPredecessor($ {Note1 getTemporalAspect($)})} getPitch($)}
   PrePitch2 = {{Note2 getPredecessor($ {Note2 getTemporalAspect($)})} getPitch($)}
   %% Do note1 and note2 start at the same time?
   B1 = ({Note1 getStartTime($)} =: {Note2 getStartTime($)})
   %% Is pitch1 and pitch2 interval fifth?
   B2 = {FD.reified.distance Pitch1 Pitch2 '=:' 7}
   %% Is pitch1 predecessor and pitch2 predecessor interval fifth?
   B3 = {FD.reified.distance PrePitch1 PrePitch2 '=:' 7}
   B4 = {FD.reified.distance Pitch1 Pitch2 '=:' 0}
   B5 = {FD.reified.distance PrePitch1 PrePitch2 '=:' 0}
   B6 = {FD.reified.distance Pitch1 Pitch2 '=:' 12}
   B7 = {FD.reified.distance PrePitch1 PrePitch2 '=:' 12}
in
   %% Conjunction of all three truth values must be false
   {FD.conj B1
    {FD.disj
     {FD.conj B2 B3}
     {FD.disj
      {FD.conj B4 B5}
      {FD.conj B6 B7}}}
    B}
end
proc {NoParallels Voice1 Voice2}
   FirstVoiceNotes = {Voice1 getItems($)}
   SecondVoiceNotes = {Voice2 getItems($)}
in
   {List.forAllInd FirstVoiceNotes
    proc {$ I Note1}
       {List.forAllInd SecondVoiceNotes
	proc {$ J Note2}
	   if {Note1 hasPredecessor($ {Note1 getTemporalAspect($)})} andthen
	      {Note2 hasPredecessor($ {Note2 getTemporalAspect($)})}
	   then {OpenParallelsR Note1 Note2 0}
	   end
	end}
    end}
end
proc {IsCanon Voice1 Voice2}
   %% The first CanonNo notes of each voice form a canon in a fifth
   CanonNo = 10
in
   for
      Note1 in {List.take {Voice1 getItems($)} CanonNo}
      Note2 in {List.take {Voice2 getItems($)} CanonNo}
   do
      {Note1 getPitch($)} + 7 =: {Note2 getPitch($)}
      {Note1 getDuration($)} =: {Note2 getDuration($)}
   end
end


%%
%% Call solver (A few different distribution strategies are proposed
%% to solve this CSP).
%%

/*

{Init.setTempo 100.0}

%% This special score distribution strategy takes about 4 secs on my machine (Pentium 4, 3.2 GHz machine with 512 MB RAM running Mozart 1.3.1 on Fedora Core 3) to find a solution
%% (slighly less than 2 secs without rule MaxAndMinPitchOnlyOnce).
{SDistro.exploreOne Canon
 unit(order:startTime
      value:mid)}


%% For full CSP, this standard distribution strategy (i.e. no special
%% score search) finds NO solution within 1 h of search! (about 14
%% secs without MaxAndMinPitchOnlyOnce)
{SDistro.exploreOne Canon
 unit(order:size
      value:mid)}


%% Randomised solution
{SDistro.exploreOne Canon
 unit(order:startTime
      value:random)}

%% change random seed
{GUtils.setRandomGeneratorSeed 0}


*/

