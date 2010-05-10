
%%
%% TODO: revise all tests (or delete)
%%

declare
[RegT] = {ModuleLink ['x-ozlib://anders/strasheela/RegularTemperament/RegularTemperament.ozf']}

% %%
% %% 5-limit JI
% {HS.db.setDB {RegT.db.makeFullDB unit(generators:[702 386] % 5-limit JI
% 				      %% paris of min/max to define full PC set of temperament
% 				      generatorFactors:[~10#10 ~2#2]
% 				      generatorFactorsOffset:0
% 				      pitchesPerOctave:1200 % 120000
% 				      accidentalOffset:2*100 % TODO: revise	
% 				      %% corresponds to MIDI pitch range 12-127+ (for pitchesPerOctave=12)
% 				      octaveDomain:0#9
% 				     )}}


% 5-limit JI
{RegT.db.makeFullDB unit(generators:[702 386] % 5-limit JI
			 %% paris of min/max to define full PC set of temperament
			 generatorFactors:[~10#10 ~2#2]
			 generatorFactorsOffset:0
			 pitchesPerOctave:1200 % 120000
			 maxError: 30
			)}


%% Meantone
%% generator: 696.578428 cent
{RegT.db.makeFullDB unit(generators:[69658]
			 %% pairs of min/max to define full PC set of temperament
			 generatorFactors:[~10#10]
			 generatorFactorsOffset:0
			 pitchesPerOctave: 120000
			 accidentalOffset:2*10000 
			 maxError: 3000
			)}



%%%%%%%%%%%%%%%%%%%%
%%
%% TODO: Unrevised old tests
%%

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
{Record.forAll RegT.db.fullDB.scaleDB
 proc {$ DB_Entry}
    MyScore = {MakeScore DB_Entry}
 in
    {MyScore wait}
    {RegT.out.renderAndShowLilypond MyScore
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
{Record.forAll RegT.db.fullDB.chordDB
 proc {$ DB_Entry}
    MyScore = {MakeScore DB_Entry}
 in
    {MyScore wait}
    {RegT.out.renderAndShowLilypond MyScore
     unit(file:{MyScore getInfoRecord($ doc)}.1)}
    {Out.renderAndPlayCsound MyScore
     unit(file:{MyScore getInfoRecord($ doc)}.1)}
 end}


*/


/* 


%% chord db with tuning errors of JI pitches: most are below 3 cent, only 147/1 has error -5.46
{Browse {Record.map RegT.db.fullDB.chordDB fun {$ R} R.comment.pitchClasses end}}


{Browse {HS.db.ratiosInDBEntryToPCs scale(pitchClasses:[12#1 14#1 18#1 21#1 27#1]) 12}}

{Browse {HS.db.ratiosInDBEntryToPCs scale(pitchClasses:[12#1 14#1 18#1 21#1 27#1]) 41}}

%% 12 ET
{Browse {HS.db.ratiosInDBEntryToPCs scale(pitchClasses:[1#1 5#4 3#2 7#4]) 12}}

%% 22 ET
{Browse {HS.db.ratiosInDBEntryToPCs scale(pitchClasses:[1#1 5#4 3#2 7#4]) 41}}


*/

