

%%
%% This file lists a number of small-scale examples that demostrate the creation of various textures. For simplicity many these examples only apply texture constraints. However, additional constraints can be added to these examples.  
%%
%% The first examples are all purely rhythmic
%%

%%
%% Usage: first feed buffer, then feed each example (all wrapped in a block comment).
%%

%%
%%
%%

declare
Beat = 4*3
{MUtils.setNoteLengthsRecord Beat [3]}
%% Makes all set symbolic note lengths available as variables in the compiler, e.g., D4 is set to Beat. For all (lower-case) note values see {Arity {MUtils.getNoteLengthsRecord}}.
{MUtils.feedNoteLengthVariables}



/*

%% An example of 3 parts where the beginning and end is homophonic, but not necessarily the whole score. Note that the three parts do not necessarily end together. 
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    fun {MakeNote _}
       %% constant pitch and reduced duration domain
       {Score.make2 note(duration: {FD.int [1 2 4]}
			 pitch: 60)
	unit}
    end
    Voice1 Voice2 Voice3
 in
    %% create a score with 3 parallel parts, each consisting of a sequence of 12 notes
    MyScore = {Score.make sim([{Score.makeSeq unit(iargs: unit(n:12
							       constructor: MakeNote)
						   handle:Voice1)}
			       {Score.makeSeq unit(iargs: unit(n:12
							       constructor: MakeNote)
						   handle:Voice2)}
			       {Score.makeSeq unit(iargs: unit(n:12
							       constructor: MakeNote)
						   handle:Voice3)}]
			      startTime:0
			      timeUnit:beats(4))
	       unit}
    %% The first 4 notes (range 1#4) of Voice1 are followed homophonically by Voice2 and Voice3.
    %% Also, the notes no 7-12 of Voice1 are followed homophonically by the simultaneous notes of Voice2 and Voice3 (if these notes exist).
    {Segs.texture Segs.homophonic Voice1 [Voice2 Voice3]
     unit(indexRange: [1#3 10#12])}
 end
 unit(order:leftToRight
      value:random)}

*/


/*

%% Basically the same example as before, but this time all parts must end together.
declare
proc {MyScript MyScore}
   fun {MakeNote _}
      {Score.make2 note(duration: {FD.int [1 2 4]}
			pitch: 60)
       unit}
   end
   Voice1 Voice2 Voice3
   End
in
   MyScore = {Score.make sim([{Score.makeSeq unit(iargs: unit(n:12
							      constructor: MakeNote)
						  handle:Voice1
						  endTime:End)}
			      {Score.makeSeq unit(iargs: unit(n:12
							      constructor: MakeNote)
						  handle:Voice2
						  endTime:End)}
			      {Score.makeSeq unit(iargs: unit(n:12
							      constructor: MakeNote)
						  handle:Voice3
						  endTime:End)}]
			     startTime:0
			     timeUnit:beats(4))
	      unit}
   %% The first and the last 3 notes are homophonic
   {Segs.texture Segs.homophonic Voice1 [Voice2 Voice3]
    unit(indexRange: [1#3 9#12])}
end
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript
 unit(order:leftToRight
      value:random)}


%% testing
declare
MyScore = {MyScript}


*/



/*

%% Basically the 1st example, but this time a time frame (instead of positional indices)
%% are given for the affected items of the leading part

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    fun {MakeNote _}
       %% constant pitch and reduced duration domain
       {Score.make2 note(duration: {FD.int [1 2 4]}
			 pitch: 60)
	unit}
    end
    Voice1 Voice2 Voice3
 in
    %% create a score with 3 parallel parts, each consisting of a sequence of 12 notes
    MyScore = {Score.make sim([{Score.makeSeq unit(iargs: unit(n:12
							       constructor: MakeNote)
						   handle:Voice1)}
			       {Score.makeSeq unit(iargs: unit(n:12
							       constructor: MakeNote)
						   handle:Voice2)}
			       {Score.makeSeq unit(iargs: unit(n:12
							       constructor: MakeNote)
						   handle:Voice3)}]
			      startTime:0
			      timeUnit:beats(4))
	       unit}
    %% The first 4 notes (range 1#4) of Voice1 are followed homophonically by Voice2 and Voice3.
    %% Also, the notes no 7-12 of Voice1 are followed homophonically by the simultaneous notes of Voice2 and Voice3 (if these notes exist).
    {Segs.texture Segs.homophonic Voice1 [Voice2 Voice3]
     %% times counted in 16th: ranges are 1st dotted quarter and 4th quarter of 1st bar to middle of next bar
     unit(timeRange: [0#D4_ D4*3#D4*6])}
 end
 unit(order:leftToRight
      value:random)}

*/



/*

%%
%% Example involving imitation (though the imitation is somewhat hidden here, because it is not preceeded by a rest -- which could be added).
%%
%% Demonstration of a texture, where the dependency between voices is user-defined (but 2 using
%% predefined texture dependency constraints for simplicity).
%% For simplicity no further harmonic constraints are applied -- the resulting harmony is rather random.


declare
%% The dependency between parts is defined by a precedure (constraint) that constrains the relation between pairs of individual notes: N1 is a note from Voice1 and N2 is a note from Voice2 or Voice3 that is simultaneous to N1. (for cases with non-simultaneous notes, e.g., for modelling imitation, see the use of the argument offsetTime below). 
proc {MyDependency N1 N2 Args} 
   {Segs.homophonic N1 N2 Args}
   {Segs.homoDirectional N1 N2 Args}
end
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne 
 proc {$ MyScore}
    Voice1 Voice2 Voice3
 in
    MyScore = {Score.make sim([seq(handle:Voice1
				   [note note note note note note note note note note note note])
			       seq(handle:Voice2
				   [note note note note note note note note note note note note])
			       seq(handle:Voice3
				   [note note note note note note note note note note note note])]
			      startTime:0
			      timeUnit:beats(4))
	       add(note:fun {$ _}
			   {Score.make2 note(duration: {FD.int [1 2 4]}
					     pitch: {FD.int 60#72})
			    unit}
			end)}
    %% Segs.textureProgression is a slighly more concise variant of multiple calls of Segs.texture.
    %% The corresponding calls of Segs.texture are added in comments afterwards.
    {Segs.textureProgression_Index
     [%% Imitation at the beginning (e.g., Voice2 at time 2 imitates 1st 5 notes of Voice1)
      (1#5) # unit(MyDependency Voice1 [Voice2 Voice3 Voice1]  
		   offsetTime: [2 4 6])
      %% Homophonic ending (if there are still simultaneous notes!)
      (8#12) # unit(Segs.homophonic Voice1 [Voice2 Voice3])
     ]}
    % {Segs.texture MyDependency Voice1 [Voice2 Voice3 Voice1]
    %  unit(indexRange: 1#5
    % 	  offsetTime: [2 4 6])}      
    % {Segs.texture Segs.homophonic Voice1 [Voice2 Voice3]
    %  unit(indexRange: 9#12)}16
 end
 unit(value: heuristic
          % value:random
      order: leftToRight
     )}

*/


/*

%%
%% Basically same example as before, but with specifying time ranges instead of index ranges for the leading part 
%% 


declare
proc {MyDependency N1 N2 Args} 
   {Segs.homophonic N1 N2 Args}
   {Segs.homoDirectional N1 N2 Args}
end
proc {MyScript MyScore}
   Voice1 Voice2 Voice3
in
   MyScore = {Score.make sim([seq(handle:Voice1
				  [note note note note note note note note note note note note])
			      seq(handle:Voice2
				  [note note note note note note note note note note note note])
			      seq(handle:Voice3
				  [note note note note note note note note note note note note])]
			     startTime:0
			     timeUnit:beats(4))
	      add(note:fun {$ _}
			  {Score.make2 note(duration: {FD.int [1 2 4]}
					    pitch: {FD.int 60#72})
			   unit}
		       end)}
   %% Segs.textureProgression is a slighly more concise variant of multiple calls of Segs.texture.
   %% The corresponding calls of Segs.texture are added in comments afterwards.
   {Segs.textureProgression_Time
    [%% Imitation at the beginning 
     (0#D4_) # unit(MyDependency Voice1 [Voice2 Voice3 Voice1]  
		  offsetTime: [2 4 6])
     %% Homophonic ending (if there are still notes!)
     (D4*6#D4*12) # unit(Segs.homophonic Voice1 [Voice2 Voice3])
    ]}
    % {Segs.texture MyDependency Voice1 [Voice2 Voice3 Voice1]
    %  unit(indexRange: 1#5
    % 	  offsetTime: [2 4 6])}      
    % {Segs.texture Segs.homophonic Voice1 [Voice2 Voice3]
    %  unit(indexRange: 9#12)}
end
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne 
 MyScript
 unit(value: heuristic
          % value:random
      order: leftToRight
     )}


%% testing
declare
MyScore = {MyScript}

*/



/* 

%% Demonstration of a texture, where the dependency between voices is user-defined (but 2 using
%% predefined texture dependency constraints for simplicity).
%% In the beginning and the end, the music is both homophonic and homodirectional, in the middle it is only homophonic, and two notes are not even that.. 
%% The harmony and counterpoint definition is very simple (C-major scale and chord).
%%
%% Warning: long search
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    Voice1 Voice2 Voice3
    End
    NoteIArgs = unit(n:16
		    duration: fd#[2 4 8]
		    pitch: fd#(57#72)
		    %% Not necessarily in underlying harmony, but must be in underlying scale
		    inChordB: fd#(0#1)
		    inScaleB: 1)
 in
    MyScore = {Score.make sim([{Segs.makeCounterpoint_Seq
				unit(iargs: NoteIArgs
				     handle:Voice1
				     endTime: End)}
			       {Segs.makeCounterpoint_Seq
				unit(iargs: NoteIArgs
				     handle:Voice2)}
			       {Segs.makeCounterpoint_Seq
				unit(iargs: NoteIArgs
				     handle:Voice3)}
			       %% Underlying harmony: C major chord 
			       seq([chord(index:{HS.db.getChordIndex 'major'}
					  root: 0)]
				   endTime: End)
			       %% Underlying scale: C major
			       seq([scale(index:{HS.db.getScaleIndex 'major'}
					  transposition:0)]
				   endTime: End)
			       ]
			      startTime:0
			      timeUnit:beats(4))
	       add(chord:HS.score.chord
		   scale:HS.score.scale)}
    %% Homophonic and homodirectional beginning and end
    {Segs.texture proc {$ N1 N2 Args}
    		     {Segs.homophonic N1 N2 Args}
    		     {Segs.homoDirectional N1 N2 Args}
		  end
     Voice1 [Voice2 Voice3]
     unit(indexRange: [1#3 12#16])}
    %% Homophonic middle part
    {Segs.texture Segs.homophonic
     Voice1 [Voice2 Voice3]
     unit(indexRange: 4#8)}
    %% Always at least 2 different PCs
    {ForAll {Voice1 collect($ test:isNote)}
     proc {$ N1}
	thread 
	   {HS.rules.minCard N1|{N1 getSimultaneousItems($ test:isNote)} 2}
	end
     end}
    %% 
    {HS.rules.onlyOrnamentalDissonance_Durations {Append {Append {Voice1 collect($ test:isNote)}
    							  {Voice2 collect($ test:isNote)}}
    						  {Voice3 collect($ test:isNote)}}}
    %% Reduce the duration domain of the beginning and end
    {SMapping.forNumericRange {Voice1 collect($ test:isNote)}
     [1#2 16]
     proc {$ N}
    	{N getDuration($)} = {FD.int [4 8]}
     end}
 end
 unit(order:leftToRight
      value:random)}


*/

