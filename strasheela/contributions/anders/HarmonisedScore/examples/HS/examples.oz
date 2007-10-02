
%% To link the functor with auxiliary definition of this file: within OPI (i.e. emacs) start Oz from within this buffer (e.g. by C-. r). This sets the current working directory to the directory of the buffer.  
declare
[Aux] = {Module.link [{OS.getCWD}#'/ExampleAuxDefs.ozf']}

declare
/** %% The passing note is situated between chord pitches.
%% */
proc {IsPassingNoteR Note B}
   B = {FD.conj 
	{HS.rules.isPassingNoteR Note unit}
	{HS.rules.isBetweenChordNotesR Note unit}}
end
/** %% The auxiliary is situated between chord pitches.
%% */
proc {IsAuxiliaryR Note B}
   B = {FD.conj 
	{HS.rules.isAuxiliaryR Note unit}
	{HS.rules.isBetweenChordNotesR Note unit}}
end


%%
%% aim for inventio (largly determined rhythmic structure)
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% single voice consisting motif sequence along a harmonic progression and non-harmonic pitches (see example ./nonharmonicPitches.oz)

{SDistro.exploreOne
 proc {$ MyScore}
    ChordNr = 4 
    NoteNr = 16
    MinNonHarmNotes = 2
    MaxNonHarmNotes = 5
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
		    {MyNote nonChordPCConditions([IsPassingNoteR
						  IsAuxiliaryR])}
		 end)}
    %% control number of non-chord notes (= noteNr - sum) [if number is
    %% too high the whole melody goes only in the same direction]
    {FD.sum {MyVoice mapItems($ isInChord)} '=:'
     {FD.int (NoteNr-MaxNonHarmNotes)#(NoteNr-MinNonHarmNotes)}}
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% as above, but with motifs: motifs determine rhythmic structure and contour: for now simplify: determine motif IDs 




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% two voices with motifs along a harmonic progression






%% multiple voices (homophonic)

