
%% To link the functor with auxiliary definition of this file: within OPI (i.e. emacs) start Oz from within this buffer (e.g. by C-. r). This sets the current working directory to the directory of the buffer.  
declare
[Aux] = {ModuleLink [{OS.getCWD}#'/ExampleAuxDefs.ozf']}


%% note seq over a chord progression (use random distro)
%%
{SDistro.exploreOne
 proc {$ MyScore}
    MyChords = {Score.makeScore2
		seq(items:{LUtils.collectN 4
			   fun {$} chord(duration:4) end})
		Aux.myCreators}
    MyVoice = {Score.makeScore2
	       seq(items:{LUtils.collectN 16
			  fun {$} note(duration:1) end})
	       Aux.myCreators}
 in
    MyScore = {Score.makeScore
	       sim(items:[MyVoice
			  MyChords]
		   startTime:0
		   timeUnit:beats(1))
	       Aux.myCreators}
 end
 Aux.myDistribution}


%% note seq over a chord progression with simple additional rules (determined rhythmic structure)
%%
%% !! wrong enharmonic spelling in Lily output 
{SDistro.exploreOne
 proc {$ MyScore}
    MyChords = {Score.makeScore2
		seq(items:{LUtils.collectN 4
			   fun {$} chord(duration:4) end})
		Aux.myCreators}
    MyVoice = {Score.makeScore2
	       seq(items:{LUtils.collectN 16
			  fun {$} note(duration:1) end})
	       Aux.myCreators}
 in
    MyScore = {Score.makeScore
	       sim(items:[MyVoice
			  MyChords]
		   startTime:0
		   timeUnit:beats(1))
	       Aux.myCreators}
    %%
    %% constrain intervals between notes in a voice
    {Pattern.for2Neighbours {MyVoice mapItems($ getPitch)}
     proc {$ Pitch1 Pitch2}
	Interval = {FD.int 1#4}
     in
	{FD.distance Pitch1 Pitch2 '=:' Interval}
     end}
    %% redundant constraint to avoid search (to avoid search decides for equal neighbouring PCs which don't allow any solution)
    {Pattern.for2Neighbours {MyVoice mapItems($ getPitchClass)}
     proc {$ PC1 PC2}
	PC1 \=: PC2
     end}
    %% constrain chord progression
    {HS.rules.neighboursWithCommonPCs {MyChords getItems($)}}
    {HS.rules.distinctNeighbours {MyChords getItems($)}}
    {{MyChords getItems($)}.1 getRoot($)} = {{List.last {MyChords getItems($)}} getRoot($)}
 end
 Aux.myDistribution}

