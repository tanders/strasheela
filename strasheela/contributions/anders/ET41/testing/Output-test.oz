
declare
[ET41] = {ModuleLink ['x-ozlib://anders/strasheela/ET41/ET41.ozf']}
{HS.db.setDB ET41.db.fullDB}


%%
%% check microtonal Lilypond output
%%

/*

%% all 41 ET notes
declare
MyScore = {Score.makeScore
	   seq({Map {List.number 0 40 1}
		fun {$ PC}
		   note(duration:1
			pitchClass:PC
			octave:4)
		end}
	       startTime:0
	       timeUnit:beats)
	   unit(seq:Score.sequential
		note:HS.score.note)}
{MyScore wait}
%% 
{ET41.out.renderAndShowLilypond MyScore
 unit(file:"41ET-test")}



/** %% Notate full 41-TET with HE accidentals as defined in ET41.out.pcDecls, together with pitch classes.
%% */
declare
MyScore = {Score.make seq({Map {List.number 0 41 1}
			   fun {$ I}
			      note(info: lily("_\\markup{"#(I mod 41)#"}")
				   pitch: I+(41*5)
				   duration:2)
			   end}
			 startTime:0
			 timeUnit:beats)
	   add(note:HS.score.note)}
{MyScore wait}
{ET41.out.renderAndShowLilypond MyScore
 unit(file:"ET41-notation")}

*/

/*

%% Lily chord notation test
declare
fun {MakeChord PCs}
   sim({Map PCs
	fun {$ PC}
	   note(duration:1
		pitchClass:PC
		octave:4)
	end})
end
MyScore = {Score.make
	   seq([{MakeChord [0 15 30]}
		{MakeChord [1 16 31]}
		{MakeChord [2 17 32]}]
	       startTime:0
	       timeUnit:beats)
	   add(note:HS.score.note)}
{MyScore wait}
%% 
{ET41.out.renderAndShowLilypond MyScore
 unit(file:"41ET-test2")}

*/


/* 

%% chord and scale test
declare
MyScore = {Score.make
	   sim([seq([chord(index:1
			   transposition:1
			   duration:4)])
		seq([scale(index:1
			   transposition:1
			   duration:4)])]
	       startTime:0
	       timeUnit:beats)
	   add(note:HS.score.note
	       chord:HS.score.chord
	       scale:HS.score.scale)}
{MyScore wait}
%% 
{ET41.out.renderAndShowLilypond MyScore
 unit(file:"41ET-test3")}

*/