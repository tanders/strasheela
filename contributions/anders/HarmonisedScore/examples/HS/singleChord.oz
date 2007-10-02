
%% To link the functor with auxiliary definition of this file: within OPI (i.e. emacs) start Oz from within this buffer (e.g. halt Oz with 'C-. h' and then start Oz by evaluating the expression below). This sets the current working directory (OS.getCWD) to the directory of the buffer.  
declare
[Aux] = {ModuleLink [{OS.getCWD}#'/ExampleAuxDefs.ozf']}


%% note seq over single chord (use random distro)
%%
{SDistro.exploreOne
 proc {$ MyScore}
    MyVoice = {Score.makeScore2
	       seq(items:[note(duration:1)
			  note(duration:1)
			  note(duration:1)
			  note(duration:1)])
	       Aux.myCreators}
 in 
    MyScore = {Score.makeScore
	       sim(items:[MyVoice
			  chord(duration:4)]
		   startTime:0
		   timeUnit:beats(1))
	       Aux.myCreators}
 end
 Aux.myDistribution}


%% note seq over single chord with simple additional rule
%%
{SDistro.exploreOne
 proc {$ MyScore}
    MyVoice = {Score.makeScore2
	       seq(items:[note(duration:1)
			  note(duration:1)
			  note(duration:1)
			  note(duration:1)])
	       Aux.myCreators}
 in 
    MyScore = {Score.makeScore
	       sim(items:[MyVoice
			  chord(duration:4)]
		   startTime:0
		   timeUnit:beats(1))
	       Aux.myCreators}
    %% constrain intervals between notes in a voice
    {Pattern.for2Neighbours {MyVoice mapItems($ getPitch)}
     proc {$ Pitch1 Pitch2}
	Interval = {FD.int 1#7}
     in
	{FD.distance Pitch1 Pitch2 '=:' Interval}
     end}
    %% redundant constraint to avoid search (to avoid search decides for equal neighbouring PCs which don't allow any solution)
    {Pattern.for2Neighbours {MyVoice mapItems($ getPitchClass)}
     proc {$ PC1 PC2}
	PC1 \=: PC2
     end}
 end
 Aux.myDistribution}

