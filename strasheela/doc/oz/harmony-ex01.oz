
%%
%% Harmonic CSP: the pitches of a sequence of notes are constrained to
%% express a given harmony. 
%%
%% This example makes use of the Strasheela extension HarmonisedScore
%% (HS) which is documented at
%% ../contributions/anders/HarmonisedScore/doc/node1.html
%%

declare
%% To link the functor with auxiliary definition of this file: within
%% OPI (i.e. emacs) start Oz from within this buffer (e.g. by
%% C-. b). This sets the current working directory to the directory of
%% the buffer.
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs/AuxDefs.ozf.bin']}



%% Specifies a harmony consisting of the pitch classes [0 4 7],
%% i.e. [c, e, g] or C-major. Only a single pitch class can be chord
%% root, namely 0 (i.e. c). 
MajorChordSpec = chord(comment:'major'
		       pitchClasses:[0 4 7]
		       roots:[0])
%% The CSP uses a chord data base, which consists only of
%% MajorChordSpec. Chords in the database can be transposed in the CSP.
{HS.db.setDB unit(chordDB:chords(MajorChordSpec))}


%% Top-level definition of the CSP. Extends a score by a chord
%% progression -- consisting only of a single D-major chord here --
%% and constraints the note pitches in the score to express this
%% chord.
proc {MyScript HarmonisedScore}
   %% Number of notes in note sequence 
   N = 12
   %% A logic variable used below 
   EndTime
in
   %% Score.makeScore transforms a textual specification of a score
   %% and into a nested score object (see
   %% ../doc/api/node6.html#entity200). It expects the textual score
   %% AND the creators to use (an Oz record of score classes or
   %% procedures returning score instances), Here, the predefined
   %% creators Aux.myCreators are used.
   HarmonisedScore
   = {Score.makeScore
      %%  Score topology a sequence of N notes (with undetermined
      %%  pitches) running in parallel to a chord. The note sequence and
      %%  the chord both start at time 0 (only set for surrounding sim
      %%  container) and both end at the same time (the end time of both
      %%  objects is set to the same variable). The duration of each note
      %%  is set which implicitly sets the EndTime.
      %%
      %% sim: the seq of notes and the chord run parallel in time.
      sim(items:[%% seq: the temporal parameters of the contained notes (startTime,
		 %% endTime etc.) are implicitly constrained such that
		 %% they are arranged sequentially in time
		 seq(items:{LUtils.collectN N
			    %% LUtils.collectN calls given function N times and
			    %% collects results in list.
			    fun {$}
			       note(%% the meaning of the note duration depends on the
				    %% setting of the timeUnit: beats(4) means the
				    %% %% duration 4 corresponds to a quarter note
				    duration:4
				    %% pitch measure in MIDI keynumbers: domain
				    %% 60-72 means the octave above middle c
				    pitch:{FD.int 60#72}
				    %% MIDI velocity
				    amplitude:64)
			    end}
		     endTime:EndTime)
		 chord(endTime:EndTime
		       %% Select first chord in database set
		       %% above. (Because there is only a single
		       %% chord, this setting could be omitted.)
		       index:1 	       
		       %% Constrain the chord's transposition to pitch
		       %% class 2 (i.e. the tone d)
		       transposition:2)]
	  %% the score starts at time 0
	  startTime:0
	  timeUnit:beats(4))
      %% 
      %% Use predefined score object creators.
      %%
      %% NB: The note creator in Aux.myCreators implicitly constrains
      %% the pitch of a note to express the harmony of the
      %% simultaneous chord object.
      Aux.myCreators}   
end


/*
%% For clarity: the same definition without the comments

proc {MyScript HarmonisedScore}
   N=12 EndTime
in
   HarmonisedScore = {Score.makeScore
		      sim(items:[seq(items:{LUtils.collectN N
					    fun {$}
					       note(duration:4
						    pitch:{FD.int 60#72}
						    amplitude:64)
					    end}
				     endTime:EndTime)
				 chord(endTime:EndTime
				       transposition:2)]
			  startTime:0
			  timeUnit:beats(4))
		      Aux.myCreators} 
end

*/

/* % solver call for using explorer 

{SDistro.exploreOne MyScript Aux.myDistribution}

*/

/*

%% used solution of second run (more randomised)

%% Lilypond output is edited by hand, so the harmony staff is named "Analysis"

declare
File = "harmony-ex01"
OutDir = {OS.getCWD}#"/../sound/"
%% solver call
MySolution = {SDistro.searchOne MyScript Aux.myDistribution}.1
%%
{Init.setTempo 100.0}
%% output
{Aux.toMidi MySolution OutDir File}
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}

*/

