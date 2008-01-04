
declare
[OnsetDurs] = {ModuleLink ['x-ozlib://gperciva/onsetdurs/onsetdurs.ozf']}
Beats=4
BeatDivisions=2
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


{ExploreOne GetOnsets}   
{Browse 'script end'}

