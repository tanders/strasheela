

% declare
% [HS Pattern]
%  = {ModuleLink ['x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
% 		  'x-ozlib://anders/strasheela/Pattern/Pattern.ozf']}


%% add relations/constraints between scale, chord and note

%% Linking of items with predetermined rhythmic structure is rather straitforward. Bleibe einfach demnaechst mal bei vordef. Rhythmik. Anderes kann dann noch etwas spaeter geleistet werden.
%%
%% !! TODO: when note PC in chord when in scale?
{SDistro.exploreOne
 proc {$ MyScore}
    NoteNr = 12
    Notes NeighbouringNotes
 in
    MyScore = {Score.makeScore
	       sim(items:[seq(items:{LUtils.collectN NoteNr
				     fun {$} note(duration:1) end})
			  %% tmp roots.. 
			  %%
			  %% Nr * Dur = NoteNr
			  seq1(items:{Map [2 9 2] % [T D T] for scale root 2
				      fun {$ X} chord(duration:4
						      root:X) end})
			  scale(duration:NoteNr
				root:2)]
		   startTime:0
		   timeUnit:beats(4))
	       unit(%% ?? tmp: HS.score.simultaneous/sequential not defined (was with added chord start marker?)
                    %sim:HS.score.simultaneous 
		    %seq:HS.score.sequential
		    sim:Score.simultaneous
		    seq:Score.sequential
		    seq1:Score.sequential
		    note:HS.score.note
		    chord:HS.score.chord
		    scale:HS.score.scale)}
    Notes = {MyScore collect($ test:isNote)}
    %% representation: list elements of form unit(pre post int)
    NeighbouringNotes = {Pattern.map2Neighbours Notes
			 fun {$ Note1 Note2}
			    I = {FD.decl}
			 in
			    I = {FD.distance {Note1 getPitch($)} {Note2 getPitch($)} '=:'}
			    unit(pre:Note1
				 post:Note2
				 int:I)
			 end}
    %% First and last note in sim chord
    {ForAll [Notes.1 {List.last Notes}]
     proc {$ N}
	SimChord = {N getSimultaneousItems($ test:HS.score.isChord)}.1
     in
	{FS.include {N getPitchClass($)}
	 {SimChord getPitchClasses($)}}
     end}
    %% All note pitches are in sim scale pitch classes. 
    %% Linking easy because of predetermined rhythm
    {ForAll {LUtils.butLast Notes.2}
     proc {$ N}
	SimScale = {N getSimultaneousItems($ test:HS.score.isScale)}.1
     in
	{FS.include {N getPitchClass($)}
	 {SimScale getPitchClasses($)}}
     end}
    %% Chord pitch classes subset of sim scale pitch classes. 
    {MyScore
     forAll(proc {$ C}
	       SimScale = {C getSimultaneousItems($ test:HS.score.isScale)}.1
	    in
	       {FS.subset {C getPitchClasses($)} {SimScale getPitchClasses($)}}
	    end
	    test:HS.score.isChord)}
    %% exactly 2 intervals are jumps up to octave, the rest are steps.
    %% At a jump, both notes are in sim chord
    {Pattern.forN NeighbouringNotes
     proc {$ unit(pre:Note1 post:Note2 int:I) ?B}
	%% linking: sim (predetermined rhythm)
	%%
	%% !!?? temp: chord/scale is sim to _first_ note of interval (i.e. both notes are constrained to first chord/scale only)
	SimChordPCs = {{Note1 getSimultaneousItems($ test:HS.score.isChord)}.1
		       getPitchClasses($)}
    in
	%B = {FD.decl}
	%% in case of jump
	B = {FD.conj (I >=: 3) (I <: 13)}
	{FD.impl B
	 {FD.conj {FS.reified.include {Note1 getPitchClass($)} SimChordPCs}
	  {FS.reified.include {Note2 getPitchClass($)} SimChordPCs}}
	 1}
	%% in case of step
	{FD.nega B} = {FD.conj (I >: 0) (I <: 3)}
     end
     2}
    %% exactly 3 direction changes happen in NotePitches, the local
    %% min/max pitch is in sim chord
    {Pattern.forN {LUtils.matTrans
		   [{List.take Notes NoteNr-2}
		    {List.take Notes.2 NoteNr-2}
		    {List.drop Notes 2}]}
     proc {$ [Note1 Note2 Note3] ?B}
	SimChordPCs = {{Note2 getSimultaneousItems($ test:HS.score.isChord)}.1
		       getPitchClasses($)}
     in
	%B = {FD.decl}
	B = {Pattern.directionChangeR
	     {Note1 getPitch($)} {Note2 getPitch($)} {Note3 getPitch($)}}
	{FD.impl B {FS.reified.include {Note2 getPitchClass($)} SimChordPCs}
	 1}
     end
     3}
 end
 unit(value:mid %random
      %% Erst entscheidung fuer scala/chord, dann noten: deutlich bessere Performance.
      %% Ich koennte auch noch die Reihenfolge erst scala dann chord kontrollieren..
      order:local
	       fun {IsPreferredParam X}
		  {HS.score.isChord {X getItem($)}} orelse
		  {HS.score.isScale {X getItem($)}}
	       end
	       fun {GetDomSize X}
		  {FD.reflect.size {X getValue($)}}
	       end
	    in
	       /** %%
	       %% */
	       fun {$ X Y}
		  %% search strategy (i.e. distribution strategy): size, but
		  %% prefer certain params (no preferred order of chord params). NB:
		  %% timing parameters must be predetermined for this distribution
		  %% strategy to work efficiently.
		  B = {IsPreferredParam X}
	       in
		  if B orelse {IsPreferredParam Y}
		  then B
		  else {GetDomSize X} < {GetDomSize Y}
		  end
	       end
	    end
      test:fun {$ X}
	      % {Not {{X getItem($)} isContainer($)}} orelse
	      {Not {X isTimePoint($)}} orelse
	      {Not {X isPitch($)} andthen
	       ({X hasThisInfo($ root)} orelse
		{X hasThisInfo($ untransposedRoot)} orelse
		{X hasThisInfo($ notePitch)})}
	   end)}

