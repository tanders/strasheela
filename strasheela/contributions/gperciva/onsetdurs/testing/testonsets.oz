
declare
[OnsetDurs] = {ModuleLink ['x-ozlib://gperciva/onsetdurs/onsetdurs.ozf']}

local
   Beats=4
   BeatDivisions=2
   Onsets
   Durs
in
   {OnsetDurs.setup Beats BeatDivisions Onsets Durs} 
   
   {Browse Onsets#onsets}
   {Browse Durs#durs}
   /*
   %% don't allow rests  -- not used
   {ForAll Onsets proc {$ X}
		     X\=:2
		  end
   }
   */
   %% each note must be 0 or 2 units long
   %%  (ie all existing notes must be a quarter note)
   {ForAll Durs proc {$ X} {FD.disj (X=:0) (X=:2) 1} end}
   
   {Nth Onsets 1} =: 1
   {Nth Onsets 3} =: 2
   {Nth Onsets 5} =: 2
   {Nth Onsets 7} =: 1
   /*
   {OnsetDurs.writeLilyFile
    'blahblah'
    {OnsetDurs.toScore Onsets Durs}
   }
   */
   %% check for blocking
   {Browse 'script end'}
end

