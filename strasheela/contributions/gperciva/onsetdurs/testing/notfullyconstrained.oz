
declare
[OnsetDurs] = {ModuleLink ['x-ozlib://gperciva/onsetdurs/onsetdurs.ozf']}
Beats=2
BeatDivisions=1
%% script
proc {GetOnsets Sol}
   Durs Onsets
in
   Sol = Onsets#Durs
   %% setup defines the Onset and Durs list
   {OnsetDurs.setup Beats BeatDivisions Onsets Durs} 
   %%
   %% added constraints for testing
   {Nth Onsets 1} =: 1
   {Nth Onsets 2} \=: 2
   %%
%   {Browse Onsets#onsets}
%   {Browse Durs#durs}
   %%
   {FD.distribute ff {Append Onsets Durs}}
end


%{ExploreOne GetOnsets}
local
  Sols Sc
in
   Sols = {SearchAll GetOnsets}
   Sc = {Map Sols fun {$ X} {OnsetDurs.toScore X BeatDivisions} end}
   {ForAll Sc proc {$ X} {OnsetDurs.writeLilyFile 'foo' X} end}
end
%   {ToScore 
%   proc {ToScore Onsets Durations BeatDivisions ?ScoreInstance}


{Browse 'script end'}


