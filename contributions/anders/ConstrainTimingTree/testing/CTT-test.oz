
%% create very little script (very small domain for params) which allows for duration 0 and check for all solutions

{SDistro.exploreAll
 proc {$ MyScore}
    MyScore = {Score.makeScore
	       seq(items:{LUtils.collectN 3
			  fun {$}
			     note(duration:{FD.int 0#1}
				  %% 'existing' notes can have two
				  %% different pitches
				  pitch:{FD.int 60#61}
				  amplitude:0
				 )
			  end}
		   startTime:0
		   timeUnit:beats(1))
	       unit}
    {CTT.avoidSymmetries MyScore}
    %% the score must not be empty (this actually makes avoidSymmetries _partly_ redundant..)
    {CTT.relevantLength MyScore {FD.int 1#3}}
 end
 unit}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% CTT.accessLastItem
%%


declare
MyScore = {Score.makeScore
	   seq(items:[note(duration:2
			   pitch:60
			   amplitude:64)
		      note(duration:2
			   pitch:62
			   amplitude:64)
		      note(duration:0
			   pitch:64
			   amplitude:64)]
	       startTime:0
	       timeUnit:beats(1))
	   unit}
%% not necessary..
{CTT.avoidSymmetries MyScore}

{CTT.accessLastItem MyScore 
 fun {$ X} {X getPitch($)} end}

{CTT.accessLastItem MyScore getPitch}


%%%

declare
MyScore = {Score.makeScore
	   seq(items:[note(duration:2
			   pitch:60
			   amplitude:64)
		      note(duration:2
			   pitch:62
			   amplitude:64)
		      note(duration:{FD.int 0#2}
			   pitch:64
			   amplitude:64)]
	       startTime:0
	       timeUnit:beats(1))
	   unit}
{CTT.avoidSymmetries MyScore}

{Browse {CTT.accessLastItem MyScore
	 fun {$ X} {X getPitch($)} end}}
{Browse hi}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% GetExistingItems
%%


declare
MyScore = {Score.makeScore
	   seq(items:[note(duration:2
			   pitch:60
			   amplitude:64)
		      note(duration:2
			   pitch:62
			   amplitude:64)
		      note(duration:0
			   pitch:64
			   amplitude:64)]
	       startTime:0
	       timeUnit:beats(1))
	   unit}
%% not necessary..
{CTT.avoidSymmetries MyScore}

{CTT.getExistingItems MyScore}


%%%

declare
MyNote 
MyScore = {Score.makeScore
	   seq(items:[note(duration:2
			   pitch:60
			   amplitude:64)
		      note(duration:2
			   pitch:62
			   amplitude:64)
		      note(handle:MyNote
			   duration:{FD.int 0#2}
			   pitch:64
			   amplitude:64)]
	       startTime:0
	       timeUnit:beats(1))
	   unit}
{CTT.avoidSymmetries MyScore}

%% NB: blocks, because duration of last note unknown
{Browse {CTT.getExistingItems MyScore}}
{Browse hi}


{MyNote getDuration($)} >: 0



