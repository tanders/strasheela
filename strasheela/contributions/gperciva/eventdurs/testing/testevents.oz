
declare
[EventDurs] = {ModuleLink ['x-ozlib://gperciva/eventdurs/eventdurs.ozf']}

local
   Beats=4
   BeatDivisions=2
   Events
   Durs
in
   {EventDurs.setup Beats BeatDivisions Events Durs} 
      
   %% each note must be 0 or 2 units long
   %%  (ie all existing notes must be a quarter note)
   {ForAll Durs proc {$ X} {FD.disj (X=:0) (X=:2) 1} end}
   
   {Nth Events 1} =: 1
   {Nth Events 3} =: 2
   {Nth Events 5} =: 2
   {Nth Events 7} =: 1
   {EventDurs.writeLilyFile
    'blahblah'
    {EventDurs.toScore Events#Durs BeatDivisions}
   }
   %% check for blocking
   % {Browse 'script end'}
end

