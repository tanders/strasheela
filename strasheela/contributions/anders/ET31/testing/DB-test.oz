
declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}



/* 


%% interval db with errors..
{Browse {Record.map ET31.db.fullDB.intervalDB fun {$ R} R.comment.interval end}}


%% chord db with errors..
{Browse {Record.map ET31.db.fullDB.chordDB fun {$ R} R.comment.pitchClasses end}}


{Width ET31.db.fullDB.scaleDB}



%% comparison: precision in 12 ET: 5#4: error 13.686 cent, 5#6 and 5#3 error 15.641
{Browse {HS.db.ratiosInDBEntryToPCs scale(pitchClasses:[1#1 9#8 5#6 5#4 4#3 3#2 5#3 15#8]) 12}}



*/


/*
%% causes exception

{HS.db.setDB unit(pitchesPerOctave: 30)}

*/

