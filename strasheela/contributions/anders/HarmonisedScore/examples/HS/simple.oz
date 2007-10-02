
%% To link the functor with auxiliary definition of this file: within OPI (i.e. emacs) start Oz from within this buffer (e.g. by C-. r). This sets the current working directory to the directory of the buffer.  
declare
[Aux] = {ModuleLink [{OS.getCWD}#'/ExampleAuxDefs.ozf']}

%% simple test 
declare
MyScore = {Score.makeScore
	   sim(items:[note(duration:4)
		      chord(duration:4
			    root:0)]
	       startTime:0
	       timeUnit:beats(4))
	   Aux.myCreators}

{MyScore toFullRecord($)}


%% simplest CSP
{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {Score.makeScore
	       sim(items:[note(duration:4)
			  chord(duration:4
				% root:0
			       )]
		   startTime:0
		   timeUnit:beats(4))
	       Aux.myCreators}
 end
 Aux.myDistribution}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% note dur can be 0 (i.e. note not existing): in that case the note
%% pitch class is free
declare
MyChord = {Score.makeScore2 chord(duration:4
				  root:1)
	   Aux.myCreators}
MyNote = {Score.makeScore2 note(duration:{FD.int 0#2}
				% pitchClass:7
				getChords:fun {$ Ignore} [MyChord] end)
	   Aux.myCreators}
MyScore = {Score.makeScore
	   sim(items:[MyNote
		      MyChord]
	       startTime:0
	       timeUnit:beats(4))
	   Aux.myCreators}
{CTT.avoidSymmetries MyNote}

{MyScore toFullRecord($)}

{CTT.isExisting MyNote} = 0

{MyChord getIndex($)} = 1


%% With note dur=0, script has only 2 solutions (two different chord indices).
%% Alterantively, with note duration=1, there are six solutions
{SDistro.exploreOne
 proc {$ MyScore}
    MyChord = {Score.makeScore2 chord(duration:4
				      root:1)
	       Aux.myCreators}
    MyNote = {Score.makeScore2 note(% duration:1
				    duration:0
				    octave:5
				    getChords:fun {$ Ignore} [MyChord] end)
	      Aux.myCreators}
 in
    MyScore = {Score.makeScore
	       sim(items:[MyNote
			  MyChord]
		   startTime:0
		   timeUnit:beats(4))
	       Aux.myCreators}
    {CTT.avoidSymmetries MyNote}
 end
 Aux.myDistribution}


%% alternative using default getChords (i.e. sim chord item)
{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {Score.makeScore
	       %% mind the order: items of dur=1 at end
	       sim(items:[chord(duration:4
				root:1)
			  note(%duration:1
			       duration:0
			       octave:5)]
		   startTime:0
		   timeUnit:beats(4))
	       Aux.myCreators}
    {CTT.avoidSymmetries MyScore}
 end
 Aux.myDistribution}
