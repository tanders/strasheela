
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Module linking: link all Strasheela modules are loaded as
%% demonstrated in the template init file ../_ozrc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Rhythmic patterns: how to find an optimal solution for an
%% over-contrained problem.
%%

%% The CSP was proposed by Mauro Lanza and formalised by Chalotte Truchet 
%% (cf. http://www.epos.uni-osnabrueck.de/music/templates/buch.php?id=48&page=/music/books/m/ma_nl004/pages/245.htm, where the CSP is called Asynchronous Rhythms)

%%
%% The CSP 
%%
%% (i) A rhythmic pattern consists in notes of distinct durations. (ii) Each
%% voice literally repeats a pattern. (iii) Common note onsets
%% are forbidden (except at the start of the music).
%%

%%
%% In case the number of voices or the length of the example exceeds some upper
%% boundary, there is no solution for this CSP. Therefore, Chalotte
%% Truchet used this CSP to motivate her heuristic solver
%% OMClouds. Still, OMClouds can not find an optimal solution -- in
%% contrast to the present example. 
%%
%% The present example applies branch-and-bound (BAB) search to find
%% an optimal solution without fully exploring the search space. The
%% BAB solver expects a constraint comparing two full solutions
%% (CompareSolutions in the present example, which makes use of
%% HowManyDistinctStartTimes). The next solution is then _constrained_
%% to be better with respect to this comparison. Because the
%% comparison is done with a constraint, propagation reduces the
%% search space (see the Oz documentation/literature for further
%% details on this search technique).
%%

%%
%% NB: this example can be implemented without the Strasheela music
%% representation to save RAM (cf. the all-interval series example in
%% the present folder).
%%

declare

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Top-level definition: create score and apply rules.
%%
%% NB: One crucial rule (constraining that all start times are
%% distinct) is not yet applied here but is used to compare solutions
%% (in best-solution search, the next solution is constrained to be
%% better wrt some user-defined criterion, cf. Oz doc).
%%

/** %% Parameterised script (RhythmicalPatterns returns script). Os and Ps give information on the number of notes per pattern, the number of voices and the number of patterns per voice. 
%% Os is a list of integers which specify the number of onsets per pattern (i.e. the length of Os specifies the number of voices). Ps is a list of integers which specify the total number of patterns per voice (again, the length of Ps specifies the number of voices).   */
fun {RhythmicalPatterns Os Ps}
   proc {$ MyScore}
      MyScore = {Score.makeScore {MakeMyScore Os Ps} unit}
      %%
      %% application of strict rules
      {ForAll {MyScore getItems($)}
       proc {$ Voice}
	  FirstPattern = {Voice getItems($)}.1
       in
	  {EqualPatterns Voice}
	  {DistinctPatternDurations FirstPattern}
       end}
      %%
      {EndTimesOfLastNotesInVoiceClose MyScore 8}
   end
end

/** %% Create music representation from specification Os and Ps
%% */
fun {MakeMyScore Os Ps}
   fun {MakePattern O I}
      seq(items:{LUtils.collectN O 
		 fun {$} 
		    note(duration: {FD.int 1#11}
			 offsetTime: 0
			 timeUnit:beats(4)
			 %% Pitches are arbitrary for the present
			 %% CSP. Still, to be better comprehensibly
			 %% aurally each voice is transposed by 13
			 %% (starting from 48)
			 pitch: 47 + (I*12) + I
			 amplitude: 80)
		 end}
	  info:pattern)
   end
   fun {MakeVoice D O I}	
      seq(items:{LUtils.collectN D fun {$} {MakePattern O I} end}
	  info:voice)
   end
in
   sim(items:for O in Os
		P in Ps
		I in 1 .. {Length Os}
		collect:C
	     do {C {MakeVoice P O I}}
	     end
       startTime:0)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Strict rule definitions
%%

proc {EqualPatterns Voice}
   %% all patterns within each voice are equal (i.e. the durations of
   %% notes at same index are equal)
   Patterns = {Voice getItems($)}
   AllPatternDurs = {Map Patterns
		     fun {$ Pattern}
			{Map {Pattern getItems($)} GetDuration}
		     end}
   FirstPatternDurs = AllPatternDurs.1
in
   {ForAll AllPatternDurs.2 proc {$ Durs} Durs = FirstPatternDurs end}
end
proc {DistinctPatternDurations Pattern}
   %% all durations of Pattern are pairwise distinct (applied to each
   %% first pattern of a voice)
   {FD.distinctD {List.map {Pattern getItems($)} GetDuration}}
end
proc {EndTimesOfLastNotesInVoiceClose MyScore MaxDistance}
   LastEndTimes = {Map {MyScore getItems($)}
		   fun {$ Voice}
		      LastPattern = {List.last {Voice getItems($)}}
		      LastNote = {List.last {LastPattern getItems($)}}
		   in
		      {LastNote getEndTime($)}
		   end}
   MinEnd = {FD.decl}
   MaxEnd = {FD.decl}
in
   %% !! MaxDistance is not necessarily determined
   {Pattern.inInterval LastEndTimes MinEnd MaxEnd}
   {FD.distance MinEnd MaxEnd '=<:' MaxDistance}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Comparison of solutions
%%

proc {HowManyDistinct Xs N}
   %% Map all elements in Xs into a list of singleton sets. The union
   %% of all these singletons is a Set whose cardiality is the number
   %% of distict elements in Xs.
   Set = {FS.var.decl}
   Set1s = {Map Xs proc {$ X Set1}
		      Set1 = {FS.var.decl}
		      {FS.include X Set1}
		      {FS.card Set1 1}
		   end}
in
   {FD.decl N}
   {FoldL Set1s.2 FS.union Set1s.1 Set}
   {FS.card Set N}
end
proc {HowManyDistinctStartTimes MyScore N}
   StartTimes = {MyScore map($ getStartTime test:isNote)}
in
   {HowManyDistinct StartTimes N}
end
proc {CompareSolutions Old New}
   %% maximise the number of distict startTimes
   OldSatisfaction = {HowManyDistinctStartTimes Old}
   NewSatisfaction = {HowManyDistinctStartTimes New}
in
   OldSatisfaction <: NewSatisfaction
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Aux definitions
%%

fun {GetDuration Note} {Note getDuration($)} end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Extend explorer by information action to analyse a solution (displays the number errors in the solution)
%%

{Explorer.object
 add(information 
     proc {$ I X}
	DistinctStartTimes = {HowManyDistinctStartTimes X}
	NumberOfNotes = {Length {X collect($ test:isNote)}}
	Errors = NumberOfNotes - DistinctStartTimes
     in
	{Inspect I#unit(distinctStartTimes:DistinctStartTimes
			numberOfNotes:NumberOfNotes
			errors:Errors)}
     end
     label: 'tell HowManyDistinctStartTimes')}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Solver call
%%

/*

%% The last solution is a total success (no common start times except
%% at the beginning). NB: this solution can be found much faster with
%% a strict version of this CSP..
%%
%% NB: Use the explorer action 'tell HowManyDistinctStartTimes' for showing the 'quality' of the solution.
{SDistro.exploreBest
 {RhythmicalPatterns [2 4 3] [4 2 3]}  
 CompareSolutions
 unit(order:size
      %%value:random
      value:min)}


%% longer example..
{SDistro.exploreBest
 {RhythmicalPatterns [2 3 4] [8 6 4]}  
 CompareSolutions
 unit(order:size
      %%value:random
      value:min)}


%% more voices
{SDistro.exploreBest
 {RhythmicalPatterns [2 3 4 2 3 4] [4 3 2 4 3 2]}  
 CompareSolutions
 unit(order:size
      %%value:random
      value:min)}

*/






