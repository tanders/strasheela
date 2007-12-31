
declare
[OnsetDurs] = {ModuleLink ['x-ozlib://gperciva/onsetdurs/onsetdurs.ozf'] }

local
   Beats=4
   BeatDivisions=2
   Onsets
   Durs
   {OnsetDurs.setup Beats BeatDivisions Onsets Durs}
in
   {Browse Onsets}
   {Browse Durs}
   /*
   {ForAll Onsets proc {$ X}
		     X\=:2
		  end
   }
   */
   {ForAll Durs proc {$ X}
		   {FD.disj X=:0 X=:2 1
		   } end
   }
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
   {Browse 'script end'}
end

