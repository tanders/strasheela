
declare
[OnsetDurs] = {ModuleLink ['x-ozlib://gperciva/onsetdurs/onsetdurs.ozf'] }

local
   Beats=2
   BeatDivisions=1
in
   proc {GetOnsets Onsets}
      Durs in
      %% setup defines the Onset and Durs list
      {OnsetDurs.setup Beats BeatDivisions Onsets Durs}

      %% added constraints for testing
      {Nth Onsets 1} =: 1
      {Nth Onsets 2} \=: 2

      {Browse Onsets}
      {Browse Durs}

      {FD.distribute ff Onsets}
   end

   {ExploreOne GetOnsets}

   {Browse 'script end'}
end

