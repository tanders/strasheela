
declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}


/*

%% globally change to arpeggio (e.g., for listening to scales)
{ET31.c.setOffset 1000}
{ET31.c.setDuration 1000}

%% back to default (chords, no arpeggio)
{ET31.c.setOffset 0}
{ET31.c.setDuration 10000}

*/


/*
   
%%
%% triads and derivations
%%

%% single pitch: for tuning
{ET31.c.playRChord [1#1]}
{ET31.c.playPCs [0]}

% major triad
{ET31.c.playRChord [1#1 5#4 3#2]}

% minor triad
{ET31.c.playRChord [1#1 6#5 3#2]}

%%
%% note: large difference
%%

% diminished triad 1: two minor thirds 
{ET31.c.playRChord [1#1 6#5 36#25]}

% diminished triad 2 with harmonic seventh
{ET31.c.playRChord [1#1 6#5 7#5]}

% diminished triad 1 (two minor thirds) in 31 ET pitch classes
%% relatively high tuning error of 'tritone' (almost 12 cent), but sounds good enough 
{ET31.c.playPCs [0 8 16]}
% diminished triad 2 (with harmonic seventh) in 31 ET pitch classes
{ET31.c.playPCs [0 8 15]}


% diminished triad 2 with harmonic seventh -- with its root
{ET31.c.playRChord [4#5 1#1 6#5 7#5]}


%% 'diminished seventh'
{ET31.c.playRChord [1#1 6#5 36#25 6*6*6#5*5*5]}

%% 'diminished seventh' including non-octave -- hm, not bad ;-)
{ET31.c.playRChord [1#1 6#5 36#25 6*6*6#5*5*5 6*6*6*6#5*5*5*5]}


% augmented triad
{ET31.c.playRChord [1#1 5#4 25#16]}

%% augmented including non octave!
{ET31.c.playRChord [1#1 5#4 25#16 5*5*5#4*4*4]}


% minor
{ET31.c.playPCs [0 8 18]}

% neutral third
{ET31.c.playPCs [0 9 18]}

% major
{ET31.c.playPCs [0 10 18]}


{ET31.c.playPCs [~31 10 ~31+18]}



%% note names (no octave specs for now)

%% minor
{ET31.c.playNames ['C' 'Eb' 'G']}

%% neutral third
{ET31.c.playNames ['C' 'E;' 'G']}

%% major
{ET31.c.playNames ['C' 'E' 'G']}


%% diminished chords

{ET31.c.playNames ['C' 'Eb' 'Gb']}

{ET31.c.playNames ['C' 'Eb' 'F#']}




{ET31.c.playNames ['C' 'D#' 'F#']}



{ET31.c.playRChord [7#7 7#6 7#5]}


%%
%% seventh chords
%%





%%
%% harmonic series
%%

{ET31.c.playRChord [8#8 9#8 10#8 11#8 12#8 13#8 14#8 15#8]}

*/ 





