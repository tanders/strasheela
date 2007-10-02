
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% This example defines an all-interval series (a classical CSP) and
%% outputs the result in a number of different ways as a
%% demonstration.
%%
%% The example stems from dodecaphonic music composition. A series (or
%% tone row) is a sequence of twelve tone names of the chromatic scale
%% or twelve pitch classes, in which each pitch class occurs exactly
%% once. In an all-interval series, also the eleven intervals between
%% the twelve pitches are all pairwise distinct (i.e. each interval
%% occurs only once). These intervals are computed in such a way that
%% they are inversional equivalent: complementary intervals such a
%% fifth upwards and a fourth downwards count as the same interval
%% (namely 7).
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Module linking and Strasheela initialisation
%%
%% Please note that it this example (like the following examples)
%% requires that the Oz initialisation file loads and configures
%% Strasheela as demonstrated in the template init file ../_ozrc or
%% _WindowsOZRC
%% (cf. http://strasheela.sourceforge.net/strasheela/doc/Installation.html)
%%
%% First feed the whole buffer, for example, with "Feed Buffer" from
%% the Oz menu. This defines definitions shared by multiple examples
%% (e.g., AllIntervalSeries). Then scroll down to the section 'Call
%% solver' (wrapped in a block comment to prevent unintended feeding)
%% and feed the examples one by one, for example, by selected them and
%% using "Feed Region" from the Oz menu.
%%


declare

/*
%% the OZRC file links the Strasheela modules as follows

%% Link Strasheela modules 
[Strasheela] = {ModuleLink ['x-ozlib://anders/strasheela/Strasheela.ozf']}
Score = Strasheela.score
SDistro = Strasheela.sDistro
Out = Strasheela.out
*/ 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% CSP definition
%%

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
%% Expects a list of pitches and returns a score (a sequence of notes with these pitches).
fun {MakeSeriesScore Pitches}
   {Score.makeScore seq(items:{Map Pitches fun {$ MyPitch}
					      note(pitch:MyPitch
						   duration:1
						   amplitude:64)
					   end}
			startTime:0
			timeUnit:beats)
    unit(seq:Score.sequential
	 note:Score.note)}
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Call solver (a few alternative solver calls are shown)
%%

/*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% solution is tuple of two lists. To see a solution upon clicking on
%% a solution in the search tree, select 'Inspect' as Explorer
%% information action (menu Nodes:information action)

{Explorer.one proc {$ Sol}
		 PitchClasses Intervals in
		 Sol = PitchClasses#Intervals
		 {AllIntervalSeries 12 Intervals PitchClasses}
	      end}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% there are 3856 solutions (as known from the literature, see:
%% Morris, Robert, and Daniel Starr, "All-Interval Series", Journal of
%% Music Theory, 18 (1974), 364-398)
%%
%% NB: this example opens the Browser to show the number of
%% solutions. Still, finding all solutions may take a few seconds,
%% depending on your machine..
declare
L
{Browse length#L}
Sols = {SearchAll proc {$ Sol}
			   Xs Dxs in
			   Sol =  Xs#Dxs
			   {AllIntervalSeries 12 Dxs Xs}
		  end}
L = {Length Sols}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% The solution is a score. Select output format (e.g. MIDI or Lilypond) in
%% the Explorer (menu Nodes:information action). Make sure you first
%% set appropriate values in the Strasheela environment (e.g. you set
%% the applications and directories for the various output formats,
%% cf. ../_ozrc).
%%
%% NB: messages of the applications called by Strasheela are shown in
%% the Oz emulator buffer. The emacs shortcut C-. e toggles between
%% showing and hiding this buffer.
{SDistro.exploreOne proc {$ MyScore}
		       PitchClasses in
		       {AllIntervalSeries 12 _/*Intervals*/ PitchClasses}
		       MyScore = {MakeSeriesScore {Map PitchClasses
						   proc {$ PC Pitch}
						      Pitch = {FD.decl}
						      Pitch =: PC + 60
						   end}}
		    end
 unit}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Alternatively, create score outside of script. This approach
%% requires considerable less memory (RAM) than having the score
%% created inside the script. However, the score representation
%% defines many means which simplify the definition of complex musical
%% CSPs. For example, the representation provides much information on
%% the music and offers convenient access to the information.
%%
%% Besides, having the score inside the script allows for special
%% score distribution strategies which can exploit arbitrary
%% information on the score. For complex musical CSPs (e.g. complex
%% polyphonic problems), special score distribution strategies can
%% improve runtime efficiency by several orders of magnitude,
%%
%% This example also demonstrates that Oz supports encapsulated search
%% (i.e. a non-deterministic search can be integrated into an
%% otherwise deterministic program).
declare
proc {MakeSeries ?PitchClasses}
   {AllIntervalSeries 12 _/*Ignore Intervals*/ PitchClasses}
end
MyScore = {MakeSeriesScore {Map {SearchOne MakeSeries}.1
			    fun {$ PC} PC+60 end}}

%% Output MyScore in various ways

%% Transform into a record which can be output to a textfile for
%% manual editing and then read back into Strasheela with
%% Score.makeScore
{Browse {MyScore toInitRecord($)}}


%% Output as MIDI file (playback with {Init.getStrasheelaEnv
%% midiPlayer}).  see docs/source for additional arguments
{Out.midi.renderAndPlayMidiFile MyScore
 unit(file:"AllIntervalSeries"
      %% !! this should be set by OZRC..
      csvmidi:{Init.getStrasheelaEnv csvmidi} 
      csvDir:{Init.getStrasheelaEnv defaultCSVDir}
      midiDir:{Init.getStrasheelaEnv defaultMidiDir})}

%% Output to Lilypond for creating sheet music
%% see docs/source for additional arguments 
{Out.renderAndShowLilypond MyScore
 unit(file:"AllIntervalSeries"
      dir:{Init.getStrasheelaEnv defaultLilypondDir})}

%% Output to Csound score for sound synthesis.
%% see docs/source for additional arguments 
{Out.renderAndPlayCsound MyScore
 unit(file:"AllIntervalSeries"
      orc:{Init.getStrasheelaEnv defaultOrcFile}
      orcDir:{Init.getStrasheelaEnv defaultCsoundOrcDir}
      scoDir:{Init.getStrasheelaEnv defaultCsoundScoDir}
      soundDir:{Init.getStrasheelaEnv defaultSoundDir})}


*/

