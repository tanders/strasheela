
declare
[HS Pattern]
= {ModuleLink ['x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
		'x-ozlib://anders/strasheela/pattern/Pattern.ozf']}


/*
declare
Feat = dissonanceDegree

{HS.rules.getFeature Chord Feat I}
*/


{Select.fd [1 2 3 4] {FD.int 1#3}}

{Select.fs [{FS.value.make [1 2]} {FS.value.make [5 6]} {FS.value.make [11 12]}] {FD.int 2#3}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% test PassingNotes 
%%

declare
Pitches = {FD.list 3 60#72}
MaxStep = 2

{Browse Pitches}

{HS.rules.passingNotes Pitches MaxStep}

{Nth Pitches 2} = 65

Pitches.1 = 66

%% HS.rules.passingNotesR

declare
Pitches = {FD.list 3 60#72}
MaxStep = 2
B

{Browse Pitches#B}

{HS.rules.passingNotesR Pitches MaxStep B}

{Nth Pitches 2} = 65

B = 1

B = 0

Pitches.1 = 66

% rightly causes failure
{Nth Pitches 3} = 4 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% test Schoenberg 
%%


%%
%% DescendingProgressionR
%%
%% Find all pairs of major chords forming an descending progression, starting with c major.
%% Two sols: E major and G major (no restriction to diatonic chords..). 
declare
proc {MyScript MyScore}
   Chord1 Chord2
in
   MyScore = {Score.makeScore
	      seq(items:[chord(duration:1
			       index:1
			       transposition:0
			       handle:Chord1)
			 chord(duration:1
			       index:1
			       handle:Chord2)]
		  startTime:0
		  timeUnit:beats)
	      add(chord:HS.score.chord)}
   {HS.rules.schoenberg.descendingProgressionR Chord1 Chord2 1}
end
%% browse solutions as init record
{Browse {Map {SDistro.searchAll MyScript
		 unit(order:size
		      value:min)}
	 fun {$ Sol} {Sol toInitRecord($)} end}}



{SDistro.exploreOne MyScript
 unit(order:size
      value:min)}

%%%%%


%% AscendingProgressionR
%%
%% Find all pairs of major chords forming an ascending progression, starting with c major.
%% Four sols: Eb maj, F maj, Ab maj, A maj (no restriction to diatonic chords..). 
declare
proc {MyScript MyScore}
   Chord1 Chord2
in
   MyScore = {Score.makeScore
	      seq(items:[chord(duration:1
			       index:1
			       transposition:0
			       handle:Chord1)
			 chord(duration:1
			       index:1
			       handle:Chord2)]
		  startTime:0
		  timeUnit:beats)
	      add(chord:HS.score.chord)}
   {HS.rules.schoenberg.ascendingProgressionR Chord1 Chord2 1}
end
%% browse solutions as init record
{Browse {Map {SDistro.searchAll MyScript
		 unit(order:size
		      value:min)}
	 fun {$ Sol} {Sol toInitRecord($)} end}}

{SDistro.exploreOne MyScript
 unit(order:size
      value:min)}




%%%%%


%% SuperstrongProgressionR
%%
%% Find all pairs of major chords forming an superstrong progression, starting with c major.
%% five sols: C#, D, F#, Bb, B  (no restriction to diatonic chords..). 
declare
proc {MyScript MyScore}
   Chord1 Chord2
in
   MyScore = {Score.makeScore
	      seq(items:[chord(duration:1
			       index:1
			       transposition:0
			       handle:Chord1)
			 chord(duration:1
			       index:1
			       handle:Chord2)]
		  startTime:0
		  timeUnit:beats)
	      add(chord:HS.score.chord)}
   {HS.rules.schoenberg.superstrongProgressionR Chord1 Chord2 1}
end
%% browse solutions as init record
{Browse {Map {SDistro.searchAll MyScript
		 unit(order:size
		      value:min)}
	 fun {$ Sol} {Sol toInitRecord($)} end}}

{SDistro.exploreOne MyScript
 unit(order:size
      value:min)}



%%% 


%% ProgressionStrength 
%%
%% For all major and minor chords: access progression strength from C maj to this chord.  
%%

declare
%% Args specify 2nd chord
proc {GetProgressionStrength unit(transposition:T
				  index:I)
     ?N}
   Chord1 = {Score.makeScore chord(duration:1
				   index:1
				   transposition:0)
	      unit(chord:HS.score.chord)}
   Chord2 = {Score.makeScore chord(duration:1
				   index:I
				   transposition:T)
	     unit(chord:HS.score.chord)}
in
   {HS.rules.schoenberg.progressionStrength Chord1 Chord2 N}
end



%% indented results:

%% same root: 0
{Browse {GetProgressionStrength unit(transposition:0
				     index:1)}}

%% descending: 1-11
%% E major: 11, E minor:10 (1 vs 2 common tones with C maj)
{Browse {GetProgressionStrength unit(transposition:4 index:1)}}
{Browse {GetProgressionStrength unit(transposition:4 index:2)}}
%% G maj: 11
{Browse {GetProgressionStrength unit(transposition:7 index:1)}}


%% ascending: 13-23
%% F maj: 23
{Browse {GetProgressionStrength unit(transposition:5 index:1)}}
%% A min: 22
{Browse {GetProgressionStrength unit(transposition:9 index:2)}}
%% Ab maj: 23
{Browse {GetProgressionStrength unit(transposition:8 index:1)}}


%% superstrong: 24
{Browse {GetProgressionStrength unit(transposition:2
				     index:1)}}



%%%%%


%% TODO: ResolveDescendingProgressions








