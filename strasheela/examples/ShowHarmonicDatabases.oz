
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
  }"

proc {RenderLily X Args}
   {ET22.out.renderAndShowLilypond X
    {Adjoin unit(wrapper:[LilyHeader "\n}"])
     Args}}
end

%% Explorer output 
proc {Render_ET22 I X}
   if {Score.isScoreObject X}
   then 
      FileName = out#{GUtils.getCounterAndIncr}#'-'#I#'-'#{OS.rand}
   in
      {RenderLily X unit(file: FileName)}
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
   fun {MakeNote Pitch}
      note(offsetTime:As.noteOffsetTime
	   duration:As.noteDuration
	   pitch:Pitch+As.pitchOffset
	   amplitude:64)
   end
   Intervals = {Record.toList {HS.db.getInternalIntervalDB}.interval}
in
   {Score.makeScore seq(items:{Map Intervals
			       fun {$ I}
				  sim(items:[{MakeNote I}
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
{RenderLily MyScore
 unit(file:"ET22-allIntervals")}

{Browse {MyScore toInitRecord($)}}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Show/play all chords  
%%


/** %% This example lists all chords. 
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
			     ChordName = {HS.db.getName MyChord}
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



/*


declare
MyScore_ChordsOnly = {AllChords unit(chordDuration:2)}

{MyScore_ChordsOnly wait}
{RenderLily MyScore_ChordsOnly
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
{RenderLily MyScore_ChordNotes
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
		  ScaleName = {HS.db.getName MyScale}
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
{RenderLily MyScore_ScalesOnly unit(file: "ET22-all-scales")}

declare
MyScore_ScaleNotes = {ExpressScales {MyScore_ScalesOnly
				     collect($ test:HS.score.isScale)}
			  unit(pitchOffset:{ET22.pitch 'C'#4}
			       scaleOffsetTime:1)}

{MyScore_ScaleNotes wait}
{Init.setTempo 70.0}
%% Note: no scale names etc displayed in this Lily output
{RenderLily MyScore_ScaleNotes
 unit(file:"ET22-all-scales-explicitNotes")}
{Out.renderAndPlayCsound MyScore_ScaleNotes
 unit(file: "ET22-all-scales-explicitNotes")}


{Browse {MyScore_ScalesOnly toInitRecord($)}}



*/ 



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% For each given scale, and for each scale degree of this scale, display all chords whose root is this scale degree note and which only use scale tones. 
%%


%% NOTE: TMP: vorlauefige teilweise def: single scale and single scale degree
%%
%% Extended script
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
       degree:1
       value:min)}
 unit}

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
		   seq(info:lily("\\bar \"||\" \\break")
		      items: {Map
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
			       ObjectToText})
		end}
in
   {Out.show "Search for all chords finished"}
   MyScore = {Score.makeScore
	      seq(items: {ObjectToText MyScale} | ChordSeqs
		  startTime:0
		  timeUnit:beats)
	      add(scale:HS.score.scale
		  chord:HS.score.chord)}
end




/*

declare
proc {ProcessScale ScaleIndex OutFilenameStart Dir}
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
   MyScore_ChordNotes = {ExpressChords {MyScore_ChordsAtDegrees
					collect($ test:HS.score.isChord)}
			 unit(pitchOffset:{ET22.pitch 'C'#3}
			      noteDuration:4)}
in
   {MyScore_ChordNotes wait}
   %% render lily output (scale and chord objects)
   {RenderLily MyScore_ChordsAtDegrees
    unit(file:OutFilenameStart#"-ChordsAtScaleDegrees"
	 dir:Dir)}
   {Init.setTempo 70.0}
   {Out.renderAndPlayCsound MyScore_ChordNotes
    unit(file:OutFilenameStart#"-ChordsAtScaleDegrees-withNotes"
	 soundDir:Dir)}
   %% render lily output (chord objects and notes)
   {RenderLily MyScore_ChordNotes
    unit(file:OutFilenameStart#"-ChordsAtScaleDegrees-withNotes"
	 dir:Dir)}
end


{ProcessScale {HS.db.getScaleIndex 'standard pentachordal major'}
 "StandardPentachordalMajor"
 "/Users/t/oz/music/Strasheela/strasheela/trunk/strasheela/contributions/anders/ET22/doc-DB/"}
{ProcessScale {HS.db.getScaleIndex 'static symmetrical major'}
 "StaticPentachordalMajor"
 "/Users/t/oz/music/Strasheela/strasheela/trunk/strasheela/contributions/anders/ET22/doc-DB/"}
{ProcessScale {HS.db.getScaleIndex 'alternate pentachordal major'}
 "AlternatePentachordalMajor"
 "/Users/t/oz/music/Strasheela/strasheela/trunk/strasheela/contributions/anders/ET22/doc-DB/"}
{ProcessScale {HS.db.getScaleIndex 'dynamic symmetrical major'}
 "DynamicPentachordalMajor"
 "/Users/t/oz/music/Strasheela/strasheela/trunk/strasheela/contributions/anders/ET22/doc-DB/"}
{ProcessScale {HS.db.getScaleIndex 'standard pentachordal minor'}
 "StandardPentachordalMinor"
 "/Users/t/oz/music/Strasheela/strasheela/trunk/strasheela/contributions/anders/ET22/doc-DB/"}
{ProcessScale {HS.db.getScaleIndex 'static symmetrical minor'}
 "StaticPentachordalMinor"
 "/Users/t/oz/music/Strasheela/strasheela/trunk/strasheela/contributions/anders/ET22/doc-DB/"}
{ProcessScale {HS.db.getScaleIndex 'alternate pentachordal minor'}
 "AlternatePentachordalMinor"
 "/Users/t/oz/music/Strasheela/strasheela/trunk/strasheela/contributions/anders/ET22/doc-DB/"}
{ProcessScale {HS.db.getScaleIndex 'dynamic symmetrical minor'}
 "DynamicPentachordalMinor"
 "/Users/t/oz/music/Strasheela/strasheela/trunk/strasheela/contributions/anders/ET22/doc-DB/"}


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



