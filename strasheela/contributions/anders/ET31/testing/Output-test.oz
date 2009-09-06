
declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}


%%
%% check microtonal Lilypond output
%%

/*

declare
MyScore = {Score.makeScore
	   seq(items:{Map {List.number 0 30 1}
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
{ET31.out.renderAndShowLilypond MyScore
 unit(file:"31ET-test")}

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
MyScore = {Score.makeScore seq(items:[sim(items:{Map [{ET31.pitch 'C'#4}
						      {ET31.pitch 'E'#4}
						      {ET31.pitch 'G'#4}]
						 MakeNote})
				      sim(items:{Map [{ET31.pitch 'Ab'#3}
						      {ET31.pitch 'C'#4}
						      {ET31.pitch 'D|'#4}
						      {ET31.pitch 'F'#4}]
						 MakeNote})
				      sim(items:{Map [{ET31.pitch 'G'#3}
						      {ET31.pitch 'B'#3}
						      {ET31.pitch 'D'#4}
						      {ET31.pitch 'F;'#4}]
						 MakeNote})
				      sim(items:{Map [{ET31.pitch 'C'#3}
						      {ET31.pitch 'G'#3}
						      {ET31.pitch 'B'#3}
						      {ET31.pitch 'E'#4}]
						 MakeNote})]
			       timeUnit:msecs
			       startTime:0)
	   unit}

%% NOTE: currently, a new set of Lily staffs is created for each sim
%% in a seq and this for eeach chord in this example (reason is that
%% Strasheela presently outputs old Lily version format)
{ET31.out.renderAndShowLilypond MyScore
 unit}

{Out.renderAndPlayCsound MyScore
 unit}

*/ 


