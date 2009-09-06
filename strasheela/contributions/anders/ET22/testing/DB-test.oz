
declare
[ET22] = {ModuleLink ['x-ozlib://anders/strasheela/ET22/ET22.ozf']}
{HS.db.setDB ET22.db.fullDB}


/*

{HS.db.getEditIntervalDB}

*/

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


%% single scale test
declare
MyScore = {MakeScore ET22.db.fullDB.scaleDB.1}
{ET22.out.renderAndShowLilypond MyScore
 unit(file:{MyScore getInfoRecord($ doc)}.1)}
{Out.renderAndPlayCsound MyScore
 unit(file:{MyScore getInfoRecord($ doc)}.1)}


%% all scales
{Record.forAll ET22.db.fullDB.scaleDB
 proc {$ DB_Entry}
    MyScore = {MakeScore DB_Entry}
 in
    {ET22.out.renderAndShowLilypond MyScore
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
{Record.forAll ET22.db.fullDB.chordDB
 proc {$ DB_Entry}
    MyScore = {MakeScore DB_Entry}
 in
    {ET22.out.renderAndShowLilypond MyScore
     unit(file:{MyScore getInfoRecord($ doc)}.1)}
    {Out.renderAndPlayCsound MyScore
     unit(file:{MyScore getInfoRecord($ doc)}.1)}
 end}


%%
%% old tests
%%

declare
MyScore = {MakeScore ET22.db.fullDB.scaleDB.1 seq}

{MyScore toInitRecord($)}


{ET22.out.renderAndShowLilypond MyScore
 unit(file:{MyScore getInfoRecord($ doc)}.1)}

{Out.renderAndPlayCsound MyScore
 unit(file:{MyScore getInfoRecord($ doc)}.1)}



ET22.db.fullDB.scaleDB.1.pitchClasses

ET22.db.fullDB.scaleDB.1.comment.comment


*/


/*

%% tmp

{AtomToString et22}

declare


{IsET et53}

{IsET et1200}

{GetPitchesPerOctave et22}

*/


/* 


%% chord db with errors..
{Browse {Record.map ET22.db.fullDB.chordDB fun {$ R} R.comment.pitchClasses end}}


%% comparison: precision in 12 ET: 5#4: error 13.686 cent, 5#6 and 5#3 error 15.641
{Browse {HS.db.ratiosInDBEntryToPCs scale(pitchClasses:[1#1 9#8 5#6 5#4 4#3 3#2 5#3 15#8]) 12}}

{Browse {HS.db.ratiosInDBEntryToPCs scale(pitchClasses:[1#1 9#8 5#6 5#4 4#3 3#2 5#3 15#8]) 22}}

%% 12 ET
{Browse {HS.db.ratiosInDBEntryToPCs scale(pitchClasses:[1#1 5#4 3#2 7#4]) 12}}

%% 22 ET
{Browse {HS.db.ratiosInDBEntryToPCs scale(pitchClasses:[1#1 5#4 3#2 7#4]) 22}}


*/





