
%%
%% TODO:
%%
%% - display interval names/ratios -- if such are defined by the database
%%
%% - find chord/scale entries with equal pitch class set, or with pitch class sets which are merely transposed
%%   having such doubles can be a good thing (e.g., they may differ in their root), but one should know..
%%
%% - find subset chord/scale database entries, i.e. entries which are fully contained in other chords/scales
%%   having such subsets can be a good thing (e.g., they may differ essential pitch classes), but one should know..
%%
%% - allow for displaying arbitrary further chord/scale features, e.g., 'essentialPitchClasses' or 'dissonances'
%%
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% The following examples show the database entries in the HS database, that is, all intervals, chords and scales. These examples can be valuable to better understand the entries in the databases predefined, and also can help to check the databases you define yourself.   
%%
%%

%%
%% Usage: first feed buffer, then any commented example example call 
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Specify your database
%%

declare
[ET22] = {ModuleLink ['x-ozlib://anders/strasheela/ET22/ET22.ozf']}
{HS.db.setDB ET22.db.fullDB}



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Specify your output defs. Note that music notation output defs can differ for different temperaments. 
%%


%% Try to notate all pitches as intervals above C. Also, try not to use minimise use of enharmonic euqivalents (which would be equivalent in 12 ET), because I get confused that C# is higher than Db
%% I still feel unsure with the accidentals for which I did not specify any ratio
{ET22.out.setEnharmonicNotationTable
 unit(0:'C' 			% 1#1
      1:'C/' 
      2:'Db/' 			% 16#15
      3:'D\\' 
      4:'D' 			% 8#7
      5:'Eb'			% 7#6
      6:'Eb/'			% 6#5
      7:'E\\'  			% 5#4
      8:'E' 			% 
      9:'F' 			% 4#3
      10:'F/' 			% 11#8
      11:'F#\\' 		% 7#5 / 10#7
      12:'G\\' 			% 16#11
      13:'G'			% 3#2
      14:'Ab' 
      15:'Ab/'			% 8#5
      16:'A\\' 			% 5#3
      17:'A'			% 12#7
      18:'Bb'  			% 7#4
      19:'Bb/' 
      20:'B\\' 			% 15#16
      21:'B' 
     )}


%% change lily horizonal spacing
LilyHeader = 
"\\layout {
    \\context {
      \\Score
      \\override SpacingSpanner
                #'base-shortest-duration = #(ly:make-moment 1 32)
    }
  }
"

proc {RenderLily_ET22 X Args}
   {ET22.out.renderAndShowLilypond X
    {Adjoin unit(wrapper:[LilyHeader "\n}"])
     Args}}
end


proc {RenderLily_ET31 X Args}
   {ET31.out.renderAndShowLilypond X
    {Adjoin unit(wrapper:[LilyHeader "\n}"])
     Args}}
end


%% Explorer output 
proc {Render_ET22 I X}
   if {Score.isScoreObject X}
   then 
      FileName = out#{GUtils.getCounterAndIncr}#'-'#I#'-'#{OS.rand}
   in
      {RenderLily_ET22 X unit(file: FileName)}
      {Out.renderAndPlayCsound X unit(file: FileName)}
   end
end
{Explorer.object
 add(information Render_ET22
     label: 'to Lily + Csound (22 ET)')}




%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Show/play all intervals  
%%


/** %% This example lists all intervals. 
%% */
fun {AllIntervals Args}
   Defaults = unit(pitchOffset:0
		   %% offsetTime for each note
		   noteOffsetTime: 0
		   %% duration for each note
		   noteDuration: 1)
   As = {Adjoin Defaults Args}
   fun {RatioToVS Nom#Denom}
      Nom#"/"#Denom
   end
   fun {MakeNote Pitch}
      note(offsetTime:As.noteOffsetTime
	    duration:As.noteDuration
	    pitch:Pitch+As.pitchOffset
	    amplitude:64)
   end
   Intervals = {Record.toList {HS.db.getEditIntervalDB}}
in
   {Score.makeScore
    seq(items:{Map Intervals
	       fun {$ Interval}
		  %% BUG: to get this working I need to place lilycode *after* chord, but info tag lily always put before chord
% 		  Comment = "_\\markup{"#{RatioToVS Interval.comment.interval.ratio}#"}^\\markup{"#Interval.comment.interval.error#"}"
% 	       in
		  sim(%info: lily(Comment)
		      items:[{MakeNote Interval.interval}
			     {MakeNote 0}])
	       end}
	startTime:0
	timeUnit:beats)
    add(note:HS.score.note2)}
end



/* % output 

{Init.setTempo 50.0}
declare
MyScore = {AllIntervals unit(pitchOffset: {ET22.pitch 'C'#4})}
{MyScore wait}
{Out.renderAndPlayCsound MyScore
 unit(file: "ET22-allIntervals")}
{RenderLily_ET22 MyScore
 unit(file:"ET22-allIntervals")}

{Browse {MyScore toInitRecord($)}}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Show/play all chords  
%%


/** %% This example lists all chords in present DB. 
%% */
fun {AllChords Args}
   Defaults = unit(%% duration for each chord
		   chordDuration: 1
		   root:0)
   As = {Adjoin Defaults Args}
   L = {Width {HS.db.getEditChordDB}}
in
   {Score.makeScore
    seq(items:{Map {List.number 1 L 1}
	       fun {$ I}
		  chord(duration:As.chordDuration
			index:I
			root:As.root)
	       end}
	startTime:0
	timeUnit:beats)
    add(chord:HS.score.chord)}
end



/** %% Expresses chords by notes. Chords is a list of textual chord objects. 
%% */
%% Lily output: first note prints chord name, last note double bar and line break, each note the possibly JI interpretations (?? there are too many..).
%% OK, forget the ratios for now...
fun {ExpressChords Chords Args}
   Defaults = unit(pitchOffset:0
		   %% duration for each note/chord
		   noteDuration: 1)
   As = {Adjoin Defaults Args}
   Octave = {HS.db.getPitchesPerOctave}
   fun {MakeNote Pitch}
      note(duration:As.noteDuration
	   pitch:Pitch+As.pitchOffset
	   amplitude:64)
   end
in
   {Score.makeScore
    sim(items:[seq(items:{Map Chords
			  fun {$ MyChord}
			     PCs = {FsToInts {MyChord getPitchClasses($)}}
% 			     ChordName = {HS.db.getName MyChord}.1
			  in
			     sim(items:{MakeNote {MyChord getRoot($)}}
				 | {Map {Map PCs fun {$ PC} PC+Octave end}
				      MakeNote})
% 			     sim(% info:lily('^\\markup{'#ChordName#'}')
% 				 items:
% 				    {Append
% 				     %% do root note "by hand" and add chord name
% 				     [{Adjoin note(info:lily('^\\markup{'#ChordName#'}'))
% 				       {MakeNote {MyChord getRoot($)}}}]
% 				     {Map {Map PCs fun {$ PC} PC+Octave end}
% 				      MakeNote}}
% 				)
			  end})
	       seq(items:{Map Chords
			  fun {$ MyChord}
			     ChordText = {Adjoin  {Record.subtractList {MyChord toInitRecord($)}
						   [startTime]}
					  chord(duration:As.noteDuration)}
			  in
			     ChordText
			  end})]
	startTime:0
	timeUnit:beats)
    add(note:HS.score.note2
	chord:HS.score.chord)}
end

/** %% Expresses pitches declared as essential pitch classes in DB for chords by notes. Chords is a list of textual chord objects. 
%% */
%% code doublication with ExpressChords
fun {ExpressEssentialChordPCs Chords Args}
   Defaults = unit(pitchOffset:0
		   %% duration for each note/chord
		   noteDuration: 1)
   As = {Adjoin Defaults Args}
   Octave = {HS.db.getPitchesPerOctave}
   fun {MakeNote Pitch}
      note(duration:As.noteDuration
	   pitch:Pitch+As.pitchOffset
	   amplitude:64)
   end
in
   {Score.makeScore
    sim(items:[seq(items:{Map Chords
			  fun {$ MyChord}
			     PCs = {FsToInts {HS.rules.getFeature MyChord essentialPitchClasses}}
% 			     ChordName = {HS.db.getName MyChord}.1
			  in
			     sim(% {MakeNote {MyChord getRoot($)}} |
				 {Map {Map PCs fun {$ PC} PC+Octave end}
				      MakeNote})
			  end})
	       seq(items:{Map Chords
			  fun {$ MyChord}
			     ChordText = {Adjoin  {Record.subtractList {MyChord toInitRecord($)}
						   [startTime]}
					  chord(duration:As.noteDuration)}
			  in
			     ChordText
			  end})]
	startTime:0
	timeUnit:beats)
    add(note:HS.score.note2
	chord:HS.score.chord)}
end


/*


declare
MyScore_ChordsOnly = {AllChords unit(chordDuration:2)}
{MyScore_ChordsOnly wait}
{RenderLily_ET22 MyScore_ChordsOnly
 unit(file:"ET22-all-chords")}


declare
MyScore_ChordNotes = {ExpressChords {MyScore_ChordsOnly
				     collect($ test:HS.score.isChord)}
		      unit(pitchOffset:{ET22.pitch 'C'#3}
			   noteDuration:4)}
{MyScore_ChordNotes wait}
{Init.setTempo 60.0}
{Out.renderAndPlayCsound MyScore_ChordNotes
 unit(file: "ET22-all-chords-explicitNotes")}
{RenderLily_ET22 MyScore_ChordNotes
 unit(file:"ET22-all-chords-explicitNotes")}


{Browse {MyScore_ChordsOnly toInitRecord($)}}

{Browse {MyScore_ChordNotes toInitRecord($)}}




*/ 




%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Show/play all scales  
%%


/** %% This example lists all scales. 
%% */
fun {AllScales Args}
   Defaults = unit(%% duration for each chord
		   %% ?? do I need this?
		   scaleDuration: 1
		   root:0)
   As = {Adjoin Defaults Args}
   L = {Width {HS.db.getEditScaleDB}}
in
   {Score.makeScore
    seq(items:{Map {List.number 1 L 1}
	       fun {$ I}
		  scale(duration:As.scaleDuration
			index:I
			root:As.root)
	       end}
	startTime:0
	timeUnit:beats)
    add(scale:HS.score.scale)}
end


/** %% Expresses scales by notes. Scales is a list of textual scale objects. 
%% */
%% Lily output: first note prints scale name, last note double bar and line break, each note the possibly JI interpretations (?? there are too many..).
%% OK, forget the ratios for now...
fun {ExpressScales Scales Args}
   Defaults = unit(pitchOffset:0
		   %% offsetTime after each scales
		   scaleOffsetTime: 0
		   %% duration for each note
		   noteDuration: 1)
   As = {Adjoin Defaults Args}
   fun {MakeNote Pitch}
      note(duration:As.noteDuration
	   pitch:Pitch+As.pitchOffset
	   amplitude:64)
   end
in
   {Score.makeScore
    seq(items:{Map Scales
	       fun {$ MyScale}
		  PCs = {FsToInts {MyScale getPitchClasses($)}}
		  ScaleName = {HS.db.getName MyScale}.1 % can be multiple alternative names
	       in
		  seq(items:{Append
			     %% do first note "by hand" and add scale name
			     {Adjoin note(info:lily('^\\markup{'#ScaleName#'}'))
			      {MakeNote PCs.1}}
			     | {Map PCs.2 MakeNote}
			     [{MakeNote {MyScale getRoot($)}+{HS.db.getPitchesPerOctave}}
			      pause(duration:As.scaleOffsetTime
				    info:lily(" \\bar \"||\" \\break"))
			     ]})
		     end}
	startTime:0
	timeUnit:beats)
    add(note:HS.score.note2)}
end



/*

declare
MyScore_ScalesOnly = {AllScales unit(scaleDuration:2)}
{MyScore_ScalesOnly wait}
{RenderLily_ET22 MyScore_ScalesOnly unit(file: "ET22-all-scales")}

declare
MyScore_ScaleNotes = {ExpressScales {MyScore_ScalesOnly
				     collect($ test:HS.score.isScale)}
			  unit(pitchOffset:{ET22.pitch 'C'#4}
			       scaleOffsetTime:1)}
{MyScore_ScaleNotes wait}
{Init.setTempo 70.0}
%% Note: no scale names etc displayed in this Lily output
{RenderLily_ET22 MyScore_ScaleNotes
 unit(file:"ET22-all-scales-explicitNotes")}
{Out.renderAndPlayCsound MyScore_ScaleNotes
 unit(file: "ET22-all-scales-explicitNotes")}


{Browse {MyScore_ScalesOnly toInitRecord($)}}



*/ 



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% For each given scale, and for each scale degree of this scale, display all chords whose root is this scale degree note and which only use scale tones. 
%%


%% Extended script: for a given scale and degree find "matching" chord object. 
proc {ChordAtScaleDegree Args MyChord}
   Defaults = unit(scale:unit	% required arg
		   degree:1
		   %% Note: for single solution the startTime and duration must be
		   %% determined to avoid symmetries
		   startTime:0
		   duration:1
		   timeUnit:beats)
   As = {Adjoin Defaults Args}
   ScaleDegreePC = {FD.decl}
in
   ScaleDegreePC = {HS.score.degreeToPC
		    {HS.score.pcSetToSequence {As.scale getPitchClasses($)}
		     {As.scale getRoot($)}}
		    As.degree#{HS.score.absoluteToOffsetAccidental 0}}
   MyChord = {Score.makeScore {Adjoin {Record.subtractList As [scale degree]}
			       chord(root:ScaleDegreePC)}
	      unit(chord:HS.score.chord)}
   {HS.rules.diatonicChord MyChord As.scale}
end


/* % test

declare
MyScale = {Score.makeScore
	   scale(index:{HS.db.getScaleIndex 'standard pentachordal major'}
		 transposition:{ET22.pc 'C'})
	   unit(scale:HS.score.scale)}

{SDistro.exploreOne
 {GUtils.extendedScriptToScript ChordAtScaleDegree
  unit(scale:MyScale
       degree:1)}
 unit(value:min)}

*/


/** %% For each scale degree of MyScale (scale object) find all chords whose root is that scale degree and whose other pitch classes also fall into this scale. Outputs score where first the scale and then all the chords are listed in a seq (chords in subseqs per scale degree).
%% */
%% Note: this is no script, but calls script ChordAtScaleDegree internally
proc {FindChordsAtAllScaleDegrees MyScale ?MyScore}
   %% [aux]
   fun {ObjectToText X}
      {Record.subtractList {X toInitRecord($)} [startTime timeUnit]}
   end
   Degrees = {List.number 1 {FS.card {MyScale getPitchClasses($)}} 1}
   ChordSeqs = {Map Degrees
		fun {$ Degree}
		   Chords = {Map
			       %% Always search for single chords
			       {SDistro.searchAll
				{GUtils.extendedScriptToScript ChordAtScaleDegree
				 unit(scale:MyScale
				      degree:Degree
				      duration:2)}
				unit(value:min
				     %% only search for chord index (transposition determined by root -- all chords have only a single root spec)
				     test:fun {$ X}
					     {X hasThisInfo($ index)} orelse
					     {X hasThisInfo($ transposition)}
					  end)}
			       ObjectToText}
		in
		   if Chords == nil then
		      {Browse emptyChord}
		      seq(info:lily("\\bar \"||\" \\break")
			  items: [note(info:lily("_\\markup{\\column{no chord}}")
				       %% BUG: pitch is not Degree 
				       pitch: Degree
				       %% not correct either
% 				       pitch:{MyScale degreeToPC(Degree {HS.score.absoluteToOffsetAccidental 0}
% 								 $)}
				       duration:2)])
		   else 
		      seq(info:lily("\\bar \"||\" \\break")
			  items: Chords)
		   end
		end}
in
   {Out.show "Search for all chords finished"}
%    {Browse chords#{Map ChordSeqs fun {$ Seq} Seq.items end}}
   MyScore = {Score.makeScore
	      seq(items: {ObjectToText MyScale} | ChordSeqs
		  startTime:0
		  timeUnit:beats)
	      add(scale:HS.score.scale
		  chord:HS.score.chord)}
end

/* % test

declare
MyScale = {Score.makeScore
	   scale(index:{HS.db.getScaleIndex 'standard pentachordal major'}
		 transposition:{ET22.pc 'C'}
		 %% duration should be determined
		 duration:4
		 startTime:0
		 timeUnit:beats)
	   unit(scale:HS.score.scale)}
MyScore = {FindChordsAtAllScaleDegrees MyScale}

{MyScore isDet($)}

{MyScore toInitRecord($)}

*/


/* % test for ET31

declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}

declare
MyScale = {Score.makeScore
	   scale(index:{HS.db.getScaleIndex 'genus enharmonicum instrumentale'}
		 transposition:{ET31.pc 'C'}
		 %% duration should be determined
		 duration:4
		 startTime:0
		 timeUnit:beats)
	   unit(scale:HS.score.scale)}
MyScore_ChordsAtDegrees = {FindChordsAtAllScaleDegrees MyScale}

{MyScore_ChordsAtDegrees isDet($)}

{MyScore_ChordsAtDegrees toInitRecord($)}


{SDistro.exploreOne
 {GUtils.extendedScriptToScript ChordAtScaleDegree
  unit(scale:MyScale
       degree:1)}
 unit(value:min)}

*/


proc {ProcessScale_ET22 ScaleIndex OutFilenameStart Dir}
   MyScale = {Score.makeScore
	      scale(index:ScaleIndex
		    transposition:{ET22.pc 'C'}
		    %% duration should be determined
		    duration:4
		    startTime:0
		    timeUnit:beats)
	      unit(scale:HS.score.scale)}
   MyScore_ChordsAtDegrees = {FindChordsAtAllScaleDegrees MyScale}
   {MyScore_ChordsAtDegrees wait}
%    {Browse MyScore_ChordsAtDegrees}
   MyScore_ChordNotes = {ExpressChords {MyScore_ChordsAtDegrees
					collect($ test:HS.score.isChord)}
			 unit(pitchOffset:{ET22.pitch 'C'#3}
			      noteDuration:4)}
in
   {MyScore_ChordNotes wait}
%    {Browse chordsAtDegrees#{MyScore_ChordsAtDegrees toInitRecord($)}}
   %% render lily output (scale and chord objects)
   {RenderLily_ET22 MyScore_ChordsAtDegrees
    unit(file:OutFilenameStart#"-ChordsAtScaleDegrees"
	 dir:Dir)}
   {Init.setTempo 70.0}
   {Out.renderAndPlayCsound MyScore_ChordNotes
    unit(file:OutFilenameStart#"-ChordsAtScaleDegrees-withNotes"
	 soundDir:Dir)}
   %% render lily output (chord objects and notes)
   {RenderLily_ET22 MyScore_ChordNotes
    unit(file:OutFilenameStart#"-ChordsAtScaleDegrees-withNotes"
	 dir:Dir)}
end
%% sub set of processing of ProcessScale_ET22
proc {ShowScaleChords_ET22 ScaleIndex OutFilenameStart Dir}
   MyScale = {Score.makeScore
	      scale(index:ScaleIndex
		    transposition:{ET22.pc 'C'}
		    %% duration should be determined
		    duration:4
		    startTime:0
		    timeUnit:beats)
	      unit(scale:HS.score.scale)}
   MyScore_ChordsAtDegrees = {FindChordsAtAllScaleDegrees MyScale}
   {MyScore_ChordsAtDegrees wait}
in
   {RenderLily_ET22 MyScore_ChordsAtDegrees
    unit(file:OutFilenameStart#"-ChordsAtScaleDegrees"
	 dir:Dir)}
end


proc {ProcessScale_ET31 ScaleIndex OutFilenameStart Dir}
   MyScale = {Score.makeScore
	      scale(index:ScaleIndex
		    transposition:{ET31.pc 'C'}
		    %% duration should be determined
		    duration:4
		    startTime:0
		    timeUnit:beats)
	      unit(scale:HS.score.scale)}
   MyScore_ChordsAtDegrees = {FindChordsAtAllScaleDegrees MyScale}
   {MyScore_ChordsAtDegrees wait}
%    {Browse MyScore_ChordsAtDegrees}
   MyScore_ChordNotes = {ExpressChords {MyScore_ChordsAtDegrees
					collect($ test:HS.score.isChord)}
			 unit(pitchOffset:{ET31.pitch 'C'#3}
			      noteDuration:4)}
in
   {MyScore_ChordNotes wait}
%    {Browse chordsAtDegrees#{MyScore_ChordsAtDegrees toInitRecord($)}}
   %% render lily output (scale and chord objects)
   {RenderLily_ET31 MyScore_ChordsAtDegrees
    unit(file:OutFilenameStart#"-ChordsAtScaleDegrees"
	 dir:Dir)}
   {Init.setTempo 70.0}
   {Out.renderAndPlayCsound MyScore_ChordNotes
    unit(file:OutFilenameStart#"-ChordsAtScaleDegrees-withNotes"
	 soundDir:Dir)}
   %% render lily output (chord objects and notes)
   {RenderLily_ET31 MyScore_ChordNotes
    unit(file:OutFilenameStart#"-ChordsAtScaleDegrees-withNotes"
	 dir:Dir)}
end
%% sub set of processing of ProcessScale_ET31
proc {ShowScaleChords_ET31 ScaleIndex OutFilenameStart Dir}
   MyScale = {Score.makeScore
	      scale(index:ScaleIndex
		    transposition:{ET31.pc 'C'}
		    %% duration should be determined
		    duration:4
		    startTime:0
		    timeUnit:beats)
	      unit(scale:HS.score.scale)}
   MyScore_ChordsAtDegrees = {FindChordsAtAllScaleDegrees MyScale}
   {MyScore_ChordsAtDegrees wait}
in
   {RenderLily_ET31 MyScore_ChordsAtDegrees
    unit(file:OutFilenameStart#"-ChordsAtScaleDegrees"
	 dir:Dir)}
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% 
%%

% %% TODO: define extended script where chord, scale and scale degree are both input and output, and where I can specify params (e.g. restrict index domain)  
% %%
% %% Extended script: for a given scale and degree find "matching" chord object. 
% proc {ChordAtScaleDegree Args MyChord}
%    Defaults = unit(scale:unit	% required arg
% 		   degree:1
% 		   %% Note: for single solution the startTime and duration must be
% 		   %% determined to avoid symmetries
% 		   startTime:0
% 		   duration:1
% 		   timeUnit:beats)
%    As = {Adjoin Defaults Args}
%    ScaleDegreePC = {FD.decl}
% in
%    ScaleDegreePC = {HS.score.degreeToPC
% 		    {HS.score.pcSetToSequence {As.scale getPitchClasses($)}
% 		     {As.scale getRoot($)}}
% 		    As.degree#{HS.score.absoluteToOffsetAccidental 0}}
%    MyChord = {Score.makeScore {Adjoin {Record.subtractList As [scale degree]}
% 			       chord(root:ScaleDegreePC)}
% 	      unit(chord:HS.score.chord)}
%    {HS.rules.diatonicChord MyChord As.scale}
% end


% /** %% For given chord MyChord, collect all scales and the corresponding scale degrees into which this chord "fits" (i.e., chord root is scale degree pitch class and all chord pitch classes fall into scale). 
% %% */
% proc {FindAllScalesAndDegreesForChord MyChord ?MyScore}
   
% end


%%%%%%%%%%

/*

% declare
% proc {ProcessScale_ET31 ScaleIndex OutFilenameStart Dir}
%    MyScale = {Score.makeScore
% 	      scale(index:ScaleIndex
% 		    transposition:{ET22.pc 'C'}
% 		    %% duration should be determined
% 		    duration:4
% 		    startTime:0
% 		    timeUnit:beats)
% 	      unit(scale:HS.score.scale)}
%    MyScore_ChordsAtDegrees = {FindChordsAtAllScaleDegrees MyScale}
%    {MyScore_ChordsAtDegrees wait}
%    MyScore_ChordNotes = {ExpressChords {MyScore_ChordsAtDegrees
% 					collect($ test:HS.score.isChord)}
% 			 unit(pitchOffset:{ET22.pitch 'C'#3}
% 			      noteDuration:4)}
% in
%    {MyScore_ChordNotes wait}
%    %% render lily output (scale and chord objects)
%    {RenderLily_ET22 MyScore_ChordsAtDegrees
%     unit(file:OutFilenameStart#"-ChordsAtScaleDegrees"
% 	 dir:Dir)}
%    {Init.setTempo 70.0}
%    {Out.renderAndPlayCsound MyScore_ChordNotes
%     unit(file:OutFilenameStart#"-ChordsAtScaleDegrees-withNotes"
% 	 soundDir:Dir)}
%    %% render lily output (chord objects and notes)
%    {RenderLily_ET22 MyScore_ChordNotes
%     unit(file:OutFilenameStart#"-ChordsAtScaleDegrees-withNotes"
% 	 dir:Dir)}
% end


{ShowScaleChords_ET22 {HS.db.getScaleIndex 'standard pentachordal major'}
 "StandardPentachordalMajor"
 "/Users/t/sound/tmp/"}

{ShowScaleChords_ET22 {HS.db.getScaleIndex 'static symmetrical major'}
 "StaticPentachordalMajor"
 "/Users/t/sound/tmp/"}

{ShowScaleChords_ET22 {HS.db.getScaleIndex 'alternate pentachordal major'}
 "AlternatePentachordalMajor"
 "/Users/t/sound/tmp/"}

{ShowScaleChords_ET22 {HS.db.getScaleIndex 'dynamic symmetrical major'}
 "DynamicPentachordalMajor"
 "/Users/t/sound/tmp/"}

{ShowScaleChords_ET22 {HS.db.getScaleIndex 'standard pentachordal minor'}
 "StandardPentachordalMinor"
 "/Users/t/sound/tmp/"}

{ShowScaleChords_ET22 {HS.db.getScaleIndex 'static symmetrical minor'}
 "StaticPentachordalMinor"
 "/Users/t/sound/tmp/"}

{ShowScaleChords_ET22 {HS.db.getScaleIndex 'alternate pentachordal minor'}
 "AlternatePentachordalMinor"
 "/Users/t/sound/tmp/"}

{ShowScaleChords_ET22 {HS.db.getScaleIndex 'dynamic symmetrical minor'}
 "DynamicPentachordalMinor"
 "/Users/t/sound/tmp/"}


%%%


declare
MyScale = {Score.makeScore
	   scale(index:{HS.db.getScaleIndex 'alternate pentachordal major'}
		 transposition:{ET22.pc 'C'}
		 %% duration should be determined
		 duration:4
		 startTime:0
		 timeUnit:beats)
	   unit(scale:HS.score.scale)}
MyScore_ChordsAtDegrees = {FindChordsAtAllScaleDegrees MyScale}
{MyScore_ChordsAtDegrees wait}

{Out.outputScoreConstructor MyScore_ChordsAtDegrees
 unit(file: 'AlternatePentachordalMajor-chords')}

{MyScore_ChordsAtDegrees toInitRecord($)}

*/








%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Aux defs
%%

/** %% [Convenience fun] This function is an extention of FS.int.match: it expects a determined FS variable, and returns a list of the integers in this FS.
% Internally, this list is declared implicitely as a list of FD ints first..
%% NB: blocks until MyFS is determined.
%% */
%% NOTE: shall I put this fun into GUtils?
fun {FsToInts MyFS}
   Ints = {FD.list {FS.card MyFS} 0#FD.sup}
in
   {FS.int.match MyFS Ints}
   Ints
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% output another database 
%%

/*


declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}
%%

%%
%% all intervals
%%

{Init.setTempo 50.0}
declare
MyScore = {AllIntervals unit(pitchOffset: {ET31.pitch 'C'#4})}
{MyScore wait}
{RenderLily_ET31 MyScore
 unit(file:"ET31-allIntervals")}
{Out.renderAndPlayCsound MyScore
 unit(file: "ET31-allIntervals")}


%%
%% test single chord
%%

declare
MyChord
MyScore = {Score.make
	   seq([chord(handle:MyChord
		      index:1 transposition:0 duration:2)]
	       startTime:0
	       timeUnit:beats)
	   add(chord:HS.score.chord)}

{RenderLily_ET31 MyScore
 unit}

{HS.db.getName MyChord}
 

%%
%% all chords
%%

declare
MyScore_ChordsOnly = {AllChords unit(chordDuration:8)}
{MyScore_ChordsOnly wait}
{RenderLily_ET31 MyScore_ChordsOnly
 unit(file:"ET31-all-chords")}
MyScore_ChordNotes = {ExpressChords {MyScore_ChordsOnly
				     collect($ test:HS.score.isChord)}
		      unit(pitchOffset:{ET31.pitch 'C'#3}
			   noteDuration:4)}
{MyScore_ChordNotes wait}	
{Init.setTempo 60.0}
{Out.renderAndPlayCsound MyScore_ChordNotes
 unit(file: "ET31-all-chords-explicitNotes")}
{RenderLily_ET31 MyScore_ChordNotes
 unit(file:"ET31-all-chords-explicitNotes")}


declare
MyScore_ChordsOnly = {AllChords unit(chordDuration:2)}
{MyScore_ChordsOnly wait}
MyScore_EssentialChordNotes = {ExpressEssentialChordPCs {MyScore_ChordsOnly
							 collect($ test:HS.score.isChord)}
			       unit(pitchOffset:{ET31.pitch 'C'#3}
				    noteDuration:4)}
{MyScore_EssentialChordNotes wait}
{RenderLily_ET31 MyScore_EssentialChordNotes
 unit(file:"ET31-all-chords-essentialNotes")}

{Browse {MyScore_ChordsOnly toInitRecord($)}}

{Browse {MyScore_ChordNotes toInitRecord($)}}


%%
%% all scales
%%

declare
MyScore_ScalesOnly = {AllScales unit(scaleDuration:2)}
{MyScore_ScalesOnly wait}
{RenderLily_ET31 MyScore_ScalesOnly unit(file: "ET31-all-scales")}
MyScore_ScaleNotes = {ExpressScales {MyScore_ScalesOnly
				     collect($ test:HS.score.isScale)}
			  unit(pitchOffset:{ET31.pitch 'C'#4}
			       scaleOffsetTime:1)}
{MyScore_ScaleNotes wait}
{Init.setTempo 70.0}
%% Note: no scale names etc displayed in this Lily output
{RenderLily_ET31 MyScore_ScaleNotes
 unit(file:"ET31-all-scales-explicitNotes")}
{Out.renderAndPlayCsound MyScore_ScaleNotes
 unit(file: "ET31-all-scales-explicitNotes")}

{Browse {MyScore_ScalesOnly toInitRecord($)}}


%%
%% For each scale and scale degree, all fitting chords
%%



{ProcessScale_ET31 {HS.db.getScaleIndex 'major'}
 "Major"
 "/Users/t/sound/tmp/"
%  "/Users/t/oz/music/Strasheela/strasheela/trunk/strasheela/contributions/anders/ET31/doc-DB/"
}

{ShowScaleChords_ET31 {HS.db.getScaleIndex 'major'}
 'Major'
 "/Users/t/sound/tmp/"
}

{ShowScaleChords_ET31 {HS.db.getScaleIndex 'Secor/Barton no-fives'}
 'SecorBarton'
 "/Users/t/sound/tmp/"
}



{ShowScaleChords_ET31 {HS.db.getScaleIndex 'septimal natural minor'}
 "SeptimalMinor"
 "/Users/t/sound/tmp/"
}


%% !! No chord fits into this scale
{ShowScaleChords_ET31 {HS.db.getScaleIndex 'Rothenberg generalised diatonic'}
 "RothenbergGeneralisedDiatonic"
 "/Users/t/sound/tmp/"
}


{ShowScaleChords_ET31 {HS.db.getScaleIndex 'modus conjunctus'}
 "ModusConjunctus"
 "/Users/t/sound/tmp/"
}


{ShowScaleChords_ET31 {HS.db.getScaleIndex 'octatonic'}
 "Octatonic"
 "/Users/t/sound/tmp/"
}

{ShowScaleChords_ET31 {HS.db.getScaleIndex 'Hahn symmetric pentachordal'}
 "HahnSymmetricPentachordal"
 "/Users/t/sound/tmp/"
}

{ShowScaleChords_ET31 {HS.db.getScaleIndex 'Hahn pentachordal'}
 "HahnPentachordal"
 "/Users/t/sound/tmp/"
}

{ShowScaleChords_ET31 {HS.db.getScaleIndex 'Lumma decatonic'}
 "LummaDecatonic"
 "/Users/t/sound/tmp/"
}


%% many scale degrees without fitting chord
{ShowScaleChords_ET31 {HS.db.getScaleIndex 'Orwell'}
 "Orwell"
 "/Users/t/sound/tmp/"
}


%% many scale degrees without fitting chord
{ShowScaleChords_ET31 {HS.db.getScaleIndex 'genus sextum'}
 "GenusSextum"
 "/Users/t/sound/tmp/"
}


%% many scale degrees without fitting chord
{ShowScaleChords_ET31 {HS.db.getScaleIndex 'genus septimum'}
 "GenusSeptimum"
 "/Users/t/sound/tmp/"
}

{ShowScaleChords_ET31 {HS.db.getScaleIndex 'genus enharmonicum instrumentale'}
 "GenusEnharmonicumInstrumentale"
 "/Users/t/sound/tmp/"
}


{ShowScaleChords_ET31 {HS.db.getScaleIndex 'neutral diatonic dorian'}
 "NeutralDiatonicDorian"
 "/Users/t/sound/tmp/"
}

{ShowScaleChords_ET31 {HS.db.getScaleIndex 'neutral dorian'}
 "NeutralDorian"
 "/Users/t/sound/tmp/"
}


{ShowScaleChords_ET31 {HS.db.getScaleIndex 'Breed 10-tone'}
 "Breed10tone"
 "/Users/t/sound/tmp/"
}

%% very many harmonic possibilities, but has perhaps conventional touch
%% but certainly reduces 31 tone set to perhaps useful subset
{ShowScaleChords_ET31 {HS.db.getScaleIndex 'genus bichromaticum'}
 "GenusBichormaticum"
 "/Users/t/sound/tmp/"
}



{ShowScaleChords_ET31 {HS.db.getScaleIndex 'Hahn 12-pitch 7-limit 1'}
 "Hahn12tone-1"
 "/Users/t/sound/tmp/"
}

{ShowScaleChords_ET31 {HS.db.getScaleIndex 'Hahn 12-pitch 7-limit 2'}
 "Hahn12tone-2"
 "/Users/t/sound/tmp/"
}

{ShowScaleChords_ET31 {HS.db.getScaleIndex 'Fokker 12-pitch 7-limit'}
 "Foker12tone"
 "/Users/t/sound/tmp/"
}

{ShowScaleChords_ET31 {HS.db.getScaleIndex 'stellated hexany'}
 "StellatedHexany"
 "/Users/t/sound/tmp/"
}


{ShowScaleChords_ET31 {HS.db.getScaleIndex 'major'}
 "Major"
 "/Users/t/sound/tmp/"
}



{ShowScaleChords_ET31 {HS.db.getScaleIndex 'miracle'}
 "Miracle"
 "/Users/t/sound/tmp/"
}


%% Test

declare
MyChordSeq = {FindChordsAtAllScaleDegrees {Score.makeScore
					   scale(index:{HS.db.getScaleIndex 'Rothenberg generalised diatonic'}
						 transposition:{ET31.pc 'C'}
						 %% duration should be determined
						 duration:4
						 startTime:0
						 timeUnit:beats)
					   unit(scale:HS.score.scale)}}
{MyChordSeq wait}
{Browse ok}

declare
MyScore_ChordNotes = {ExpressChords {MyChordSeq
				     collect($ test:HS.score.isChord)}
		      unit(pitchOffset:{ET31.pitch 'C'#3}
			   noteDuration:4)}
{MyScore_ChordNotes wait}
{Browse ok}


{MyScore_ChordNotes toInitRecord($)}



%% TODO: same for other scales ... 


%% Question the other way round: for a given chord -- in which scale and at which scale degree does chord fit?


%%
%% For each chord, all scales and scale degrees
%%

% %% NOTE: unfinished
% declare
% proc {ProcessChord ChordIndex OutFilenameStart Dir}
%    MyChord = {Score.makeScore
% 	      chord(index:ChordIndex
% 		    transposition:{ET31.pc 'C'}
% 		    %% duration should be determined
% 		    duration:4
% 		    startTime:0
% 		    timeUnit:beats)
% 	      unit(chord:HS.score.chord)}
%    MyScore_ChordsAtDegrees = {FindChordsAtAllScaleDegrees MyScale}
%    {MyScore_ChordsAtDegrees wait}
%    MyScore_ChordNotes = {ExpressChords {MyScore_ChordsAtDegrees
% 					collect($ test:HS.score.isChord)}
% 			 unit(pitchOffset:{ET31.pitch 'C'#3}
% 			      noteDuration:4)}
% in
%    {MyScore_ChordNotes wait}
%    %% render lily output (scale and chord objects)
%    {RenderLily_ET31 MyScore_ChordsAtDegrees
%     unit(file:OutFilenameStart#"-ChordsAtScaleDegrees"
% 	 dir:Dir)}
%    {Init.setTempo 70.0}
%    {Out.renderAndPlayCsound MyScore_ChordNotes
%     unit(file:OutFilenameStart#"-ChordsAtScaleDegrees-withNotes"
% 	 soundDir:Dir)}
%    %% render lily output (chord objects and notes)
%    {RenderLily_ET31 MyScore_ChordNotes
%     unit(file:OutFilenameStart#"-ChordsAtScaleDegrees-withNotes"
% 	 dir:Dir)}
% end



*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% CSP
%%

%% Find scale of 7-11 tones in 31 ET
%%
%% - on each scale degree can be build a tetrad consisting only of scale tones
%% - the scale uses only 3 different step sizes at maximum
%% - no stepsize is the 31 ET interval 1
%% - the scale contains the fifth
%%
%% Likely, there does not exist any solution for the CSP. In that case, try to reduce the constraints 

%%
%% Perhaps there does not even exist a scale where on each scale degree there is a [leitereigener] chord
%%

/*

declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}
% {Explorer.object
%  add(information proc {$ I unit(scale:Scale chords:Chords)}
% 		    {Browse unit(scale:Scale
% 				 chords:{Map Chords fun {$ MyChord} {MyChord toInitRecord($)} end})}
% 		 end
%      label: 'show sol (scale search CSP)')}
%%
declare
proc {MyScript Root}
   N = 10			% change to vals between 7 and 11
   MyScale = {FD.list N 0#30}	% elements are ET31 pitch classes
   MyScale_FS = {FS.var.decl}
   Chords = {Score.makeItems unit(n:N
				  constructor: HS.score.chord)}
%    ScaleIntervals 
in
   Root = unit(scale:MyScale
% 	       chords:Chords
	       chords:{Map Chords fun {$ MyChord} {MyChord getPitchClasses($)} end}
	      )
   {Pattern.increasing MyScale}
   %% On each scale degree there exists a [leitereigen] tetrad / chord
   {FS.int.match MyScale_FS MyScale} % GUtils.intsToFS
   {ForAll {LUtils.matTrans [MyScale Chords]}
    proc {$ [ScaleTone MyChord]}
       ScaleTone = {MyChord getRoot($)}
       {FS.subset {MyChord getPitchClasses($)} MyScale_FS}
       {FS.card {MyChord  getPitchClasses($)}} >=: 4
    end}
%    %% no stepsize is the 31 ET interval 1
%    {Pattern.for2Neighbours MyScale
%     proc {$ X Y}
%        Z = {FD.decl} in
%        Y - X =: Z
%        Z >: 1
%     end}
   %% Distro
   %% TODO: improve distro?
   {FD.distribute ff
    {LUtils.accum [MyScale
		   {Pattern.mapItems Chords getIndex}
		   {Pattern.mapItems Chords getTransposition}]
     Append}}
end
%%
{ExploreOne MyScript}

*/




% declare
% [ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
% {HS.db.setDB ET31.db.fullDB}
% {Explorer.object
%  add(information proc {$ I X}
% 		    if {Score.isScoreObject X}
% 		    then 
% 		       FileName = out#{GUtils.getCounterAndIncr}
% 		    in
% 		       {ET31.out.renderAndShowLilypond X
% 			unit(file: FileName#'-'#I)}
% 		    end
% 		 end
%      label: 'to Lilypond (31 ET)')}


% %% dummy 1
% {SDistro.exploreOne
%  proc {$ MyScale}
%     MyScale = {Score.make seq([scale(duration:2)]
% 			      startTime:0
% 			      timeUnit:beats)
% 	       add(scale:HS.score.scale)}
%  end
%  unit}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% DB check: find doublettes: 2 chords (scales) with same pitch class set but different index
%%

/*

%% check ET31 chord database 
declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}
{Explorer.object
 add(information proc {$ I MyScore}
		    Chord1 = {MyScore getItems($)}.1
		    Chord2 = {MyScore getItems($)}.2.1
		 in
		    {Browse I#{MyScore toInitRecord($)}}
		    {Browse indices(chord1:{HS.db.getName Chord1}
				    chord2:{HS.db.getName Chord2})}
		 end
     label: 'browse initRecord and chord names')}

{SDistro.exploreOne
 proc {$ MyScore}
    Chord1 Chord2
 in
    MyScore = {Score.make seq([chord(handle:Chord1
				     duration:2)
			       chord(handle:Chord2
				     duration:2)]
			      startTime:0
			     timeUnit:beats)
	       add(chord:HS.score.chord)}
    {Chord1 getPitchClasses($)} = {Chord2 getPitchClasses($)}
    {Chord1 getRoot($)} =: {Chord2 getRoot($)}
    {Chord1 getIndex($)} \=: {Chord2 getIndex($)}
 end
 unit}

*/




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% DB check: find chord pairs with the same pitch class set, which only differ in their root and index, so I am aware of these
%%

/*

%% check ET31 chord database 
declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}
{Explorer.object
 add(information proc {$ I MyScore}
		    Chord1 = {MyScore getItems($)}.1
		    Chord2 = {MyScore getItems($)}.2.1
		 in
		    {Browse I#{MyScore toInitRecord($)}}
		    {Browse indices(chord1:{HS.db.getName Chord1}
				    chord2:{HS.db.getName Chord2})}
		 end
     label: 'browse initRecord and chord names')}

{SDistro.exploreAll
 proc {$ MyScore}
    Chord1 Chord2
 in
    MyScore = {Score.make seq([chord(handle:Chord1
				     duration:2)
			       chord(handle:Chord2
				     duration:2)]
			      startTime:0
			     timeUnit:beats)
	       add(chord:HS.score.chord)}
    {Chord1 getPitchClasses($)} = {Chord2 getPitchClasses($)}
    {Chord1 getRoot($)} \=: {Chord2 getRoot($)}
%     {Chord1 getIndex($)} \=: {Chord2 getIndex($)}
    %% remove symmetries
    {Chord1 getTransposition($)} = 0
    {Chord1 getIndex($)} <: {Chord2 getIndex($)}
 end
 unit}

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% TODO: DB check: find chord pairs where the pitch class sets are subsets of each other,  so I am aware of these
%%

/*

%% check ET31 chord database 
declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}
{Explorer.object
 add(information proc {$ I MyScore}
		    Chord1 = {MyScore getItems($)}.1
		    Chord2 = {MyScore getItems($)}.2.1
		 in
		    {Browse I#{MyScore toInitRecord($)}}
		    {Browse indices(chord1:{HS.db.getName Chord1}
				    chord2:{HS.db.getName Chord2})}
		 end
     label: 'browse initRecord and chord names')}

%% 82 solutions!
{SDistro.exploreAll
 proc {$ MyScore}
    Chord1 Chord2
 in
    MyScore = {Score.make seq([chord(handle:Chord1
				     duration:2)
			       chord(handle:Chord2
				     duration:2)]
			      startTime:0
			     timeUnit:beats)
	       add(chord:HS.score.chord)}
    {FS.subset {Chord1 getPitchClasses($)} {Chord2 getPitchClasses($)}}
    {Chord1 getRoot($)} \=: {Chord2 getRoot($)}
    {Chord1 getIndex($)} \=: {Chord2 getIndex($)}
    %% remove symmetries
    {Chord1 getTransposition($)} = 0
 end
 unit}

*/


