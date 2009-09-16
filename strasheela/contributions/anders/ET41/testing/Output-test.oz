
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


%% chord notation test
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
