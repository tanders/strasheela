
%% To link the functor with auxiliary definition of this file: within OPI (i.e. emacs) start Oz from within this buffer (e.g. by C-. r). This sets the current working directory to the directory of the buffer.  
declare
[Aux] = {ModuleLink [{OS.getCWD}#'/ExampleAuxDefs.ozf']}

%% Note seq over a chord progression with non-harmonic pitches (here passing notes between chord pitches).
%% Difficulty with solving CSP with passing notes: passing note rule constraints note pitches and these constraints are hardly propagated to note pitch classes. The search applied here decides first for pitch classes (see distribution strategy above), because the chord pitch classes are propagated to the note pitch classes but not to the note pitches (in case InChordB is determined to 1). Nevertheless, this problem (too little distribution between note pitch classes and pitches) is greatly reduces when -- after determining a note pitch class -- in the following distribution step the octave of that note (and thus also the pitch) is determined.
%% Besides, Aux.isPassingNoteR is a rather complex reified constraint which thus lacks much propagation..
%%
{SDistro.exploreOne
 proc {$ MyScore}
    ChordNr = 4
    NoteNr = 16
    MinPassingNotes = 2
    MaxPassingNotes = 5
    MyChords = {Score.makeScore2
		seq(items:{LUtils.collectN ChordNr
			   fun {$} chord(duration:4) end})
		Aux.myCreators}
    MyVoice = {Score.makeScore2
	       seq(items:{LUtils.collectN NoteNr
			  fun {$}
			     note(duration:1
				  %% was always determined to 1 (true) in CSPs above
				  inChordB:{FD.int 0#1}) 
			  end})
	       Aux.myCreators}
 in
    MyScore = {Score.makeScore
	       sim(items:[MyVoice
			  MyChords]
		   startTime:0
		   timeUnit:beats(1))
	       Aux.myCreators}
    %%
    %% Rules:
    %%
    %% only passing notes may be non-harmonic pitches
    {MyVoice
     forAllItems(proc {$ MyNote}
		    {MyNote nonChordPCConditions([Aux.isProperPassingNote])}
		 end)}
    %% control number of non-chord notes (= noteNr - sum) [if number is
    %% too high the whole melody goes only in the same direction]
    {FD.sum {MyVoice mapItems($ isInChord)} '=:'
     {FD.int (NoteNr-MaxPassingNotes)#(NoteNr-MinPassingNotes)}}
    %%
    %% constrain intervals between notes in a voice to be in [minor second, major third]
    {Pattern.for2Neighbours {MyVoice mapItems($ getPitch)}
     proc {$ Pitch1 Pitch2}
	Interval = {FD.int 1#4}
     in
	{FD.distance Pitch1 Pitch2 '=:' Interval}
     end}
    %% redundant constraint to avoid search (to avoid search decides
    %% for equal neighbouring PCs which don't allow any solution)
    {Pattern.for2Neighbours {MyVoice mapItems($ getPitchClass)}
     proc {$ PC1 PC2}
	PC1 \=: PC2
     end}
    %%
    %% constrain chord progression
    {HS.rules.neighboursWithCommonPCs {MyChords getItems($)}}
    {HS.rules.distinctNeighbours {MyChords getItems($)}}
    {{MyChords getItems($)}.1 getRoot($)} = {{List.last {MyChords getItems($)}} getRoot($)}
 end
 Aux.myDistribution}


%%
%% same as above, but both chord and note pitch classes are constrained to diatonic pitches (c major)  
%%
{SDistro.exploreOne
 proc {$ MyScore}
    ChordNr = 4 
    NoteNr = 16
    MinPassingNotes = 2
    MaxPassingNotes = 5
    %% default scale DB: C major scale
    MyScale = {Score.makeScore2 scale(index:1 transposition:0
				      startTime:0
				      duration:0 %% !!??
				     )
	       Aux.myCreators}
    %% add to Aux.myCreators chordInScale
    MyChords = {Score.makeScore2
		seq(items:{LUtils.collectN ChordNr
			   fun {$}
			      diatonicChord(duration:4
					    getScales:proc {$ Self Scales}
							 Scales = [MyScale]
						      end)
			   end})
		Aux.myCreators}
    MyVoice = {Score.makeScore2
	       seq(items:{LUtils.collectN NoteNr
			  fun {$}
			     note(duration:1
				  inChordB:{FD.int 0#1}
				  inScaleB:1
				  getScales:proc {$ Self Scales} Scales = [MyScale] end) 
			  end})
	       Aux.myCreators}
 in
    MyScore = {Score.makeScore
	       sim(items:[MyVoice
			  MyChords]
		   startTime:0
		   timeUnit:beats(1))
	       Aux.myCreators}
    %%
    %% Rules:
    %%
    %% only passing notes may be non-harmonic pitches
    {MyVoice
     forAllItems(proc {$ MyNote}
		    {MyNote nonChordPCConditions([Aux.isProperPassingNote])}
		 end)}
    %% control number of non-chord notes (= noteNr - sum) [if number is
    %% too high the whole melody goes only in the same direction]
    {FD.sum {MyVoice mapItems($ isInChord)} '=:'
     {FD.int (NoteNr-MaxPassingNotes)#(NoteNr-MinPassingNotes)}}
    %%
    %% constrain intervals between notes in a voice to be in [minor second, major third]
    {Pattern.for2Neighbours {MyVoice mapItems($ getPitch)}
     proc {$ Pitch1 Pitch2}
	Interval = {FD.int 1#4}
     in
	{FD.distance Pitch1 Pitch2 '=:' Interval}
     end}
    %% redundant constraint to avoid search (to avoid search decides
    %% for equal neighbouring PCs which don't allow any solution)
    {Pattern.for2Neighbours {MyVoice mapItems($ getPitchClass)}
     proc {$ PC1 PC2}
	PC1 \=: PC2
     end}
    %%
    %% constrain chord progression
    {HS.rules.neighboursWithCommonPCs {MyChords getItems($)}}
    {HS.rules.distinctNeighbours {MyChords getItems($)}}
    {{MyChords getItems($)}.1 getRoot($)} = {{List.last {MyChords getItems($)}} getRoot($)}
 end
 Aux.myDistribution}

