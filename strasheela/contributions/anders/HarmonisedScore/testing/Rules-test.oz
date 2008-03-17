
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
%% test ProgressionStrength 
%%

%%
%% chord seq: 
%%




