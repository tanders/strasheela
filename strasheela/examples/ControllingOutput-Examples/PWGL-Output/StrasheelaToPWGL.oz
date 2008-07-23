
%%
%% Output into PWGL score formats: non-mensural ENP and Kilian's simple score format.
%% It appears that the simple score format is actually the same as the non-mensural ENP format. The difference is that the simple format requires that a last time point marks the end of the score. 
%%

%%
%% TODO: change default Out.outputNonmensuralENP default args such that any Strasheela score topology creates some ENP score (i.e. it works for every Strasheela score topology)
%%

declare
%% use constant file name which is then always read into PWGL ENP editor
%% NOTE: Set output file path here: this file is then read into the PWGL patch
Dir = "/Users/t/sound/tmp/"
Filename = "StrasheelaOut"



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% relatively simple case 
%% Important: I need to specify the score topology transformation carefully..

declare
MyScore = {Score.makeScore
	   %% score
	   sim(items:[%% voice
		      seq(items:[%% chord and note..
				  note(duration: 6
				       pitch: 60
				       amplitude:64)
				 note(info:enp(expression: [accent])
				      duration: 2
				       pitch: 62
				       amplitude:64)
				  note(duration: 8
				       pitch: 64
				       amplitude:64)])
		       seq(items:[note(duration: 8
				       pitch: 72
				       amplitude:64)
				  note(duration: 8 
				       pitch: 67
				       amplitude:64)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}

%% output two voices with notes 
{Out.outputNonmensuralENP MyScore
 unit(file:Filename
      dir:Dir
      getScore:fun {$ X} X end
      getParts:fun {$ MyScore} [MyScore] end
      getVoices:fun {$ MyScore} {MyScore getItems($)} end
      getChords:fun {$ MyVoice} {MyVoice getItems($)} end
      getNotes:fun {$ MyChord} [MyChord] end
     )}


%% same example with a different score topology: output two parts with notes
{Out.outputNonmensuralENP MyScore
 unit(file:Filename
      dir:Dir
      getScore:fun {$ X} X end
      getParts:fun {$ MyScore} {MyScore getItems($)} end
      getVoices:fun {$ MyPart} [MyPart] end
      getChords:fun {$ MyVoice} {MyVoice getItems($)} end
      getNotes:fun {$ MyChord} [MyChord] end
     )}


%% double check: output into Csound too
{Out.renderAndPlayCsound MyScore
 unit}

%% double check: output into Lilypond too
{Out.renderAndShowLilypond MyScore
 unit}



%% now output to the KSQuart library simple format (two voices with notes)  
{Out.outputNonmensuralENP MyScore
 unit(toKSQuant:true
      file:Filename
      dir:Dir
      getScore:fun {$ X} X end
      getParts:fun {$ MyScore} [MyScore] end
      getVoices:fun {$ MyScore} {MyScore getItems($)} end
      getChords:fun {$ MyVoice} {MyVoice getItems($)} end
      getNotes:fun {$ MyChord} [MyChord] end
     )}

%% output to simple format with a different score topology: output two parts with notes
{Out.outputNonmensuralENP MyScore
 unit(toKSQuant:true
      file:Filename
      dir:Dir
      getScore:fun {$ X} X end
      getParts:fun {$ MyScore} {MyScore getItems($)} end
      getVoices:fun {$ MyPart} [MyPart] end
      getChords:fun {$ MyVoice} {MyVoice getItems($)} end
      getNotes:fun {$ MyChord} [MyChord] end
     )}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% same example as above, but now using 31 ET

declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
MyScore = {Score.makeScore
	   %% score
	   sim(items:[%% voice
		      seq(items:[%% chord and note..
				  note(duration: 4
				       pitch: {ET31.pitch 'C'#4}
				       pitchUnit:et31
				       amplitude:64)
				  note(duration: 2
				       pitch: {ET31.pitch 'D'#4}
				       pitchUnit:et31
				       amplitude:64)
				  note(duration: 8
				       pitch: {ET31.pitch 'E'#4}
				       pitchUnit:et31
				       amplitude:64)])
		       seq(items:[note(duration: 4
				       pitch: {ET31.pitch 'C'#5}
				       pitchUnit:et31
				       amplitude:64)
				  note(duration: 8 
				       pitch: {ET31.pitch 'G'#4}
				       pitchUnit:et31
				       amplitude:64)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}

{Out.outputNonmensuralENP MyScore
 unit(file:Filename
      dir:Dir
      getScore:fun {$ X} X end
      getParts:fun {$ MyScore} [MyScore] end
      getVoices:fun {$ MyScore} {MyScore getItems($)} end
      getChords:fun {$ MyVoice} {MyVoice getItems($)} end
      getNotes:fun {$ MyChord} [MyChord] end
     )}


%% double check: output into Csound too
{Out.renderAndPlayCsound MyScore
 unit}






