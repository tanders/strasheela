
declare
[ET41] = {ModuleLink ['x-ozlib://anders/strasheela/ET41/ET41.ozf']}
{HS.db.setDB ET41.db.fullDB}


%%
%% check microtonal Lilypond output
%%

/*

declare
MyScore = {Score.makeScore
	   seq(items:{Map {List.number 0 40 1}
		      fun {$ PC}
			 note(duration:1
			      amplitude:64
			      pitchClass:PC
			      octave:4)
		      end}
	       startTime:0
	       timeUnit:beats)
	   unit(seq:Score.sequential
		note:HS.score.note)}
%% 
{ET41.out.renderAndShowLilypond MyScore
 unit(file:"41ET-test")}

*/
