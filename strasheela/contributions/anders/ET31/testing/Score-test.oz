
declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}



/*

%% TODO: chord database: create presistent chord names (so I can start developing chord progressions, where the index is always expressed with the fun GetChordIndex) -- check names with Scala software 
declare
% fun {MyChordFn}
%    {Map [chord(index: {HS.db.getChordIndex 'major'}
% 	       root:{ET31.pc 'C#'}
% 	       bassChordDegree: 2
% 	       sopranoChordDegree:{FD.int 1#3}
% 	      )]
%     MakeChord}
% end
%%
%% All chord features are optional, but must be determined
Cs = [chord(index:{HS.db.getChordIndex 'major'}
	    root:{ET31.pc 'C#'}
	    bassChordDegree: 2
	    sopranoChordDegree:2
	    duration:2
	    timeUnit:beats
	   )]
MyScore = {ET31.score.chordsToScore Cs 
	   unit(voices:5
		amp:127)}

%% check
{Browse {MyScore toInitRecord($)}}




%%
%% ScoreObject,getInitClasses causes: Assignment to global dictionary from local space
%%

%% Customised Lily for et31: score output
%% .. can be improved..
{ET31.out.renderAndShowLilypond MyScore
 unit(file:"test")}

%% Csound output of score
{Out.out.renderAndPlayCsound MyScore
 unit(file:"test")}



%% Customised Lily for et31: chord seq output
%%
%% only demo here, does not work with chord seq fun above 
{ET31.out.renderAndShowLilypond {Score.makeScore seq(items:{Map Cs MakeChord})
				 unit}
 unit(file:"test")}




% {PlayChords [chord(index: {HS.db.getChordIndex 'major'}
% 		   root:{ET31.pc 'C#'}
% 		   %% optional -- if not constrained, then it can be anything
% 		   bassChordDegree:3
% 		   %% optional -- if not constrained, then it can be anything
% %		   sopranoChordDegree:3 
% 		  )]
%  unit(voices:5
%       amp:127)}

*/

