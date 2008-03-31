
declare
[ET22] = {ModuleLink ['x-ozlib://anders/strasheela/ET22/ET22.ozf']}
{HS.db.setDB ET22.db.fullDB}


%%
%% check microtonal Lilypond output
%%

/*

declare
MyScore = {Score.makeScore
	   seq(items:{Map {List.number 0 21 1}
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
{ET22.out.renderAndShowLilypond MyScore
 unit(file:"all-22ET-pitches")}

*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% use notation in determined score and create Lily + Csound output 
%%


/*


declare
fun {MakeNote Pitch}
   note(%offsetTime:10
	duration:2000
	pitch:Pitch
	pitchUnit:et31
	amplitude:64)
end
MyScore = {Score.makeScore seq(items:[sim(items:{Map [{ET22.pitch 'C'#4}
						      {ET22.pitch 'E\\'#4}
						      {ET22.pitch 'G'#4}]
						 MakeNote})
				      sim(items:{Map [{ET22.pitch 'G'#3}
						      {ET22.pitch 'B\\'#3}
						      {ET22.pitch 'D'#4}
						      {ET22.pitch 'F'#4}]
						 MakeNote})
				      sim(items:{Map [{ET22.pitch 'C'#4}
						      {ET22.pitch 'E\\'#4}
						      {ET22.pitch 'G'#4}]
						 MakeNote})]
			       timeUnit:msecs
			       startTime:0)
	   unit}

%% NOTE: convert-ly breaks ET22 in this case! 
{ET22.out.renderAndShowLilypond MyScore
 unit}

{Out.renderAndPlayCsound MyScore
 unit}

*/ 

