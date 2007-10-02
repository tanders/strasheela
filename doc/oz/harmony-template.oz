
%% sequence of notes constrained to given chord

declare
%% To link the functor with auxiliary definition of this file: within
%% OPI (i.e. emacs) start Oz from within this buffer (e.g. by
%% C-. b). This sets the current working directory to the directory of
%% the buffer.
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs/AuxDefs.ozf.bin']}


proc {MyScript HarmonisedScore}
    ScoreSpec = seq(info:testScore
		    items:[note(duration:2
				pitch:{FD.int 48#72}
				amplitude:64)
			   note(duration:2
				pitch:{FD.int 48#72}
				amplitude:64)
			   note(duration:2
				pitch:{FD.int 48#72}
				amplitude:64)] 
		    startTime:0
		    timeUnit:beats(4))
    ActualScore = {Score.makeScore2 ScoreSpec Aux.myCreators}
    ItemsStartingWithChord = [ActualScore]
    ChordSeq
 in
    HarmonisedScore = {HS.score.harmoniseScore ActualScore ItemsStartingWithChord
		       unit ChordSeq} 
    %% put constraints on ChordSeq here...
 end



/*

declare
File = "harmony-template"
OutDir = {OS.getCWD}#"/../sound/"
%% solver call
MySolution = {SDistro.searchOne MyScript Aux.myDistribution}.1
%%
%% output
{Aux.toMidi MySolution OutDir File}
{Aux.toSheetMusic MySolution OutDir File}
{Aux.toSound MySolution OutDir File}

*/


