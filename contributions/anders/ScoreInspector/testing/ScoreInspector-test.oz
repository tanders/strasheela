
declare
[ScoreInspector] = {ModuleLink ['x-ozlib://anders/strasheela/ScoreInspector/ScoreInspector.ozf']}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% use new inspector object (without configuring the original)
%% NB: is likely that Inspector and Inspect are already shadowed by the ScoreInspector in the OZRC
%%

{ScoreInspector.inspect {Score.makeScore note unit}}

%% alert: this may take some time...
{Inspect {Score.makeScore note unit}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% configure all inspector instances
%%

%% configure all inspector instances
{ScoreInspector.configureAll}

{Inspect {Score.makeScore note unit}}

{Inspect {Score.makeScore
	  sim(items:[seq(items:[note(pitch:60) note(pitch:{FD.int 60#72}) note])
		     seq(items:[note note note])])
	  unit}}

{Inspect Score.note}

{Inspect test(1 3 4)}



