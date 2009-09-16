
declare
[ET41] = {ModuleLink ['x-ozlib://anders/strasheela/ET41/ET41.ozf']}
{HS.db.setDB ET41.db.fullDB}



/*

%% traverse all scales in database, create a score whose notes express it and output Lilypond + Csound

declare
/** %% Expects a DB_Entry (chord or scale spec). Returns a score objects with a container of notes expressing these pitch classes.
%% */
fun {MakeScore DB_Entry}
   PCs = DB_Entry.pitchClasses
   Doc = DB_Entry.comment.comment
in
   {Score.makeScore
    seq(info:doc(Doc)
	      items:{Map PCs
		     fun {$ PC}
			note(duration:1
			     amplitude:64
			     pitchClass:PC
			     octave:4)
		     end}
	      startTime:0
	      timeUnit:beats) 
    add(note:HS.score.note)}
end
{Record.forAll ET41.db.fullDB.scaleDB
 proc {$ DB_Entry}
    MyScore = {MakeScore DB_Entry}
 in
    {MyScore wait}
    {ET41.out.renderAndShowLilypond MyScore
     unit(file:{MyScore getInfoRecord($ doc)}.1)}
    {Out.renderAndPlayCsound MyScore
     unit(file:{MyScore getInfoRecord($ doc)}.1)}
 end}

*/



/*

%% Traverse all chords in database, create a score whose notes express it and output Lilypond + Csound 

declare
/** %% Expects a DB_Entry (chord or scale spec). Returns a score objects with a container of notes expressing these pitch classes.
%% */
fun {MakeScore DB_Entry}
   PCs = {Reverse DB_Entry.pitchClasses}
   Doc = DB_Entry.comment.comment
in
   {Score.makeScore
    sim(info:doc(Doc)
	      items:{Map PCs
		     fun {$ PC}
			note(duration:4
			     amplitude:64
			     pitchClass:PC
			     octave:4)
		     end}
	      startTime:0
	      timeUnit:beats)
    add(note:HS.score.note)}
end
%% 
{Record.forAll ET41.db.fullDB.chordDB
 proc {$ DB_Entry}
    MyScore = {MakeScore DB_Entry}
 in
    {MyScore wait}
    {ET41.out.renderAndShowLilypond MyScore
     unit(file:{MyScore getInfoRecord($ doc)}.1)}
    {Out.renderAndPlayCsound MyScore
     unit(file:{MyScore getInfoRecord($ doc)}.1)}
 end}


*/


/* 


%% chord db with tuning errors of JI pitches: most are below 3 cent, only 147/1 has error -5.46
{Browse {Record.map ET41.db.fullDB.chordDB fun {$ R} R.comment.pitchClasses end}}


{Browse {HS.db.ratiosInDBEntryToPCs scale(pitchClasses:[12#1 14#1 18#1 21#1 27#1]) 12}}

{Browse {HS.db.ratiosInDBEntryToPCs scale(pitchClasses:[12#1 14#1 18#1 21#1 27#1]) 41}}

%% 12 ET
{Browse {HS.db.ratiosInDBEntryToPCs scale(pitchClasses:[1#1 5#4 3#2 7#4]) 12}}

%% 22 ET
{Browse {HS.db.ratiosInDBEntryToPCs scale(pitchClasses:[1#1 5#4 3#2 7#4]) 41}}


*/

