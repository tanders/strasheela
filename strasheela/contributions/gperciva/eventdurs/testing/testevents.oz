
declare
[EventDurs] = {ModuleLink ['x-ozlib://gperciva/eventdurs/eventdurs.ozf']}

local
   Beats=4
   BeatDivisions=2
   Events
   Durs
in
   {EventDurs.setup Beats BeatDivisions Events Durs} 
   
   {Browse Events#events}
   {Browse Durs#durs}
   /*
   %% don't allow rests  -- not used
   {ForAll Events proc {$ X}
		     X\=:2
		  end
   }
   */
   %% each note must be 0 or 2 units long
   %%  (ie all existing notes must be a quarter note)
   {ForAll Durs proc {$ X} {FD.disj (X=:0) (X=:2) 1} end}
   
   {Nth Events 1} =: 1
   {Nth Events 3} =: 2
   {Nth Events 5} =: 2
   {Nth Events 7} =: 1
   /*
   {EventDurs.writeLilyFile
    'blahblah'
    {EventDurs.toScore Events Durs}
   }
   */
   %% check for blocking
   {Browse 'script end'}
end

