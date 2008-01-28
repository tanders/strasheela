
declare
[EventDurs] = {ModuleLink ['x-ozlib://gperciva/eventdurs/eventdurs.ozf']}
Beats=2
BeatDivisions=1
%% script
proc {GetEvents Sol}
   Durs Events
in
   Sol = Events#Durs
   %% setup defines the Onset and Durs list
   {EventDurs.setup Beats BeatDivisions Events Durs} 
   %%
   %% added constraints for testing
   {Nth Events 1} =: 1
   {Nth Events 2} \=: 2
   %%
%   {Browse Events#events}
%   {Browse Durs#durs}
   %%
   {FD.distribute ff {Append Events Durs}}
end


%{ExploreOne GetEvents}
local
  Sols Sc
in
   Sols = {SearchAll GetEvents}
   Sc = {Map Sols fun {$ X} {EventDurs.toScore X BeatDivisions} end}
   {ForAll Sc proc {$ X} {EventDurs.writeLilyFile 'foo' X} end}
end
%   {ToScore 
%   proc {ToScore Events Durations BeatDivisions ?ScoreInstance}


{Browse 'script end'}


