
declare
%% To link the functor with auxiliary definition of this file: within
%% OPI (i.e. emacs) start Oz from within this buffer (e.g. by
%% C-. b). This sets the current working directory to the directory of
%% the buffer.
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs/AuxDefs.ozf.bin']}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%
%% unifying chords
%%

declare
Chord1 = {Score.makeScore chord(index:1
				transposition:2)
	 Aux.myCreators}
Chord2 = {Score.makeScore chord
	  Aux.myCreators}


%% some parameter values in Note2 are undetermined
{Browse {Chord2 toFullRecord($ exclude:[flags])}}

%% unification determines those variables 
{Chord1 unify(Chord2)}

{Browse Chord1 == Chord2}
% -> false 

{Browse {Chord1 '=='($ Chord2)}}
% -> true 


%%%


declare
Chord1 = {Score.makeScore chord(untransposedPitchClasses:{FS.value.make [0 4 7]})
	 Aux.myCreators}
Chord2 = {Score.makeScore chord(transposition:2)
	  Aux.myCreators}

%% unification determines those variables 
{Chord1 unify(Chord2)}

%% some parameter values in Note2 are undetermined
{Browse {Chord2 toFullRecord($ exclude:[flags])}}

