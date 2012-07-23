%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% For Hans Tutschku
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% Usage: first evaluate buffer, then evaluate solver call
%%

%%
%% Given list of rhythmic motifs 
%% Given determined metric structure (list of determined measure objects)
%%
%% Find a solution that
%% - Ends exactly on last bar, and where the end completes a motifs
%% - Multiple parts: sim motifs should differ (either different motif or motifs do not start at the same time)
%%


declare


[MidiOut_T]
= {ModuleLink ['x-ozlib://anders/strasheela/MidiOut_toTassman/MidiOut_toTassman.ozf']}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Rhythm representation
%% 

%% Symbolic duration names: Note durations are then written uwing Init.symbolicDurToInt as 
%% follows: d16 (16th note), d8 (eighth note) and so forth, d8_
%% (dotted eighth note). See doc of MUtils.makeNoteLengthsTable for
%% more details.
Beat = 4 * 3 * 5 * 16
{Init.setNoteLengthsRecord Beat [3 5]}
%% Makes all set symbolic note lengths available as variables in the compiler, e.g., D4 is set to Beat. For all (lower-case) note values see {Arity {MUtils.getNoteLengthsRecord}}.
%% NOTE: feeding these vars must be done first..
% {MUtils.feedNoteLengthVariables}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% CSP def
%%

%% TODO: 
%%
%% - Polyphonic case: sim motifs starting together have different motif indices
%% - ? move output defs as default into Out.renderFomus
%%

proc {MyScript MyScore}
   N = 40 % number of notes
   EndTime % End of last specified measure (end of score)
   Measures = {Score.make2 seq([measure(n: 1
					beatNumber: 3
					beatDuration: {Init.symbolicDurToInt d4})
				measure(n: 1
					beatNumber: 5
					beatDuration: {Init.symbolicDurToInt d4})
				measure(n: 1
					beatNumber: 4
					beatDuration: {Init.symbolicDurToInt d4}
					endTime: EndTime)
				%% optional: dummy measures at end, in case some constraints depend on simultaneous measures
				measure(n: 10
					beatNumber: 1
					beatDuration: {Init.symbolicDurToInt d4})])
	       add(measure: Measure.uniformMeasures)}
   %% Motif format in spec: [[SymbolicOffset1 SymbolicDur1] ...]
   %% Internal motif format: [[MotifStartB1 SymbolicOffset1 SymbolicDur1] ...]
   Motifs = [[[t5d8 t5d8] [0 t5d8] [0 t5d8] [0 t5d8] [0 d8] [0 d8]] % anacrusis: 2 beats 
	     [[0 d4]] % 1 beat
	    ]
   %% Domain for both durations and offset times (offset times get 0 added)
   DurDomain = {Sort {Map [d16 d8 d4 t5d8]
		      Init.symbolicDurToInt}
		Value.'<'}
in
   MyScore = {Score.make
	      sim([{MakeCounterpoint_PatternMotifs_Seq
		    u(iargs: u(n: N
			       constructor: MyNoteConstructur
			       duration: fd#DurDomain
			       offsetTime: fd#(0|DurDomain)
			       articulation: 50
			       pitch: 60)
		      rargs: u(resolveNonharmonicNotesStepwise: false
			       motifSpecs: {CompleteMotifSpecs Motifs}
			       motifSpecTransformers: [GUtils.identity
						       Init.symbolicDurToInt
						       Init.symbolicDurToInt] 
			       motifAccessors: [{Segs.makeParametersAccessor
						 {GUtils.toFun getMotifStartB}}
						{Segs.makeParametersAccessor getOffsetTime}
						{Segs.makeParametersAccessor getDuration}]))}
		   Measures]
		  startTime:0
		  timeUnit:beats(Beat))
	      unit}
   %% The note that occurs at EndTime (end of last specified measure) must exactly start at EndTime and start a new motif (the note that ends at EndTime is already excluded by AtTimeR)
   {ForAll {MyScore collect($ test:isNote)}
    proc {$ MyNote}
       {FD.impl {Score.atTimeR MyNote EndTime}
	{FD.conj ({MyNote getStartTime($)} =: EndTime)
	 ({MyNote getMotifStartB($)} =: 1)}
	1}
    end}
end

% {Score.getDefaults Score.makeSeq}


%%
%% NOTE: Solver call
%%

/* 

declare
{GUtils.setRandomGeneratorSeed 0}
[MyScore] = {SDistro.searchOne MyScript LeftToRight_TypewiseTieBreaking_Distro2}
{ExportScore MyScore unit(file: myTest)}

*/


%% Testing
/*

{SDistro.exploreOne MyScript LeftToRight_TypewiseTieBreaking_Distro2}

declare
MyScore = {MyScript}

{MyScore toInitRecord($)}

{MyScore toFullRecord($)}

*/


/* %% Expects list of motif specs in form [[[Offset1 Dur1] ..] ..] and adds a param value for each motif note spec. The new first parameter is either 0 or 1, depending whether this note is the first note of the motif or note (MotifStartB). 
%% */
fun {CompleteMotifSpecs MotifSpecs}
   {Map MotifSpecs
    fun {$ MotifSpec}
       MotifStartBs = {List.make {Length MotifSpec}}
    in
       MotifStartBs.1 = 1 % motif start
       {ForAll MotifStartBs.2 proc {$ X} X=0 end}
       {Map 
	{LUtils.matTrans [MotifStartBs MotifSpec]}
	fun {$ [StartB NoteSpec]} StartB | NoteSpec end}
    end}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Score object definitions
%%

MyNoteConstructur = {Pattern.makeMotifStartClass
		     {Pattern.makeMotifIndexClass
		      HS.score.note % for outputting motif markers in Fomus :)
		      % Score.note
		     }}

MakeCounterpoint_PatternMotifs_Seq
= {Score.itemslistToContainerSubscript Segs.makeCounterpoint_PatternMotifs seq}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Search strategy definition
%%

fun {MakeOrder_MeasureMotifTimeScaleChordPitchclass P}
   {SDistro.makeSetPreferredOrder
    %% Preference order of distribution strategy
    [%% Measure parameters must be distributed first -- their constraints block otherwise
     fun {$ X} {Measure.isUniformMeasures {X getItem($)}} end
     fun {$ X} {X hasThisInfo($ motifIndex)} end
     fun {$ X} {X isTimeParameter($)} end
     %% first search for scales then for chords
     fun {$ X} {HS.score.isScale {X getItem($)}} end
     fun {$ X} {HS.score.isChord {X getItem($)}} end
     %% prefer pitch class over octave (after a pitch class, always the octave is determined, see below)
     %% !!?? does this always make sense? Anyway, usually the pitch class is the more sensitive param. Besides, allowing a free order between pitch class and octave makes def to determine the respective pitch class / octave next much more difficult
     fun {$ X}
	%% only for note pitch classes: pitch classes in chord or scale are already more preferred by checking that item is isPitchClassCollection
	{HS.score.isPitchClass X}
     end
    ]
    P}
end

%% Use this distro if all offset times are determined -- motif indices will be determined left-to-right together with all other params (less redundant work if motif index clashes with other constraints)
LeftToRight_TypewiseTieBreaking_Distro
   = unit(value:random
	  debug: unit
	  order: {SDistro.makeLeftToRight {MakeOrder_MeasureMotifTimeScaleChordPitchclass
					   SDistro.dom}}
	  test: HS.distro.isNoContainerNorTimepointNorPitchNorPcCollectionTimeInterval
	 )


%% Use this distro if there are notes with undetermined offset times in def -- all motif indices will be determined first
LeftToRight_TypewiseTieBreaking_Distro2
   = unit(value:random
	  debug: unit
	  order: {SDistro.makeLeftToRight2 {MakeOrder_MeasureMotifTimeScaleChordPitchclass
					    SDistro.dom}}
	  %% old def of SDistro.makeLeftToRight2 -- all motifs indices would be determined first
	  % order: {SDistro.makeLeftToRight2 {MakeOrder_MeasureMotif SDistro.dom}
	  % 	  {% MakeOrder_MeasureScaleChordMotifTimePitch
	  % 	   MakeOrder_TimeScaleChordPitch
	  % 	   SDistro.dom}}
	  test: HS.distro.isNoContainerNorTimepointNorPitchNorPcCollectionTimeInterval
	 )



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Output definitions
%%

   
%%
%% TODO: for Lily header
%% - surround by double quotes
%% - escape all \ and " within string
%% - don't put 'lily-file-header' into part def
%%

LilyHeader 
= {VirtualString.toString
    {Out.listToLines
   ["\\paper {"
   " indent=0\\mm"
   " line-width=180\\mm" 
   " oddFooterMarkup=##f"
   " oddHeaderMarkup=##f"
   " bookTitleMarkup=#ff"
   " scoreTitleMarkup=##f"
    " }"
    ""
    "\\layout {"
    "\\context {"
    "\\Voice \\remove \"Note_heads_engraver\""
    "\\remove \"Forbid_line_break_engraver\""
    "\\consists \"Completion_heads_engraver\""
    "}"
    "} "
    ""
%     "\\score{\n{\n"
   ]}}

%%
%%
proc {RenderFomus MyScore Args}
   %% TMP (replace by new method addToInfoRecord)
   %% TODO: make this optional
   {MyScore
    addInfo(fomus('lily-file-header': LilyHeader
		  'lily-exe-args': '("--png" "--pdf" "-dbackend=eps" "-dno-gs-load-fonts" "-dinclude-eps-fonts")'
		  % 'lily-exe-args': '("--format=png" "--format=pdf")'
		  % 'lily-exe-args': '("-dbackend=eps")'
		 ))}
   {Out.renderFomus MyScore
    {Adjoin unit(eventClauses:
		    [%% for plain notes (accent ratings, but not motif indices
                      % Measure.isAccentRatingMixin
                      % #fun {$ N PartId}
                      %     TextMarks = if {N getAccentRating($)} > 0
                      %                 then {HS.out.vsToFomusMarks {N getAccentRating($)}
                      %                             % 'ar:'#{N getAccentRating($)}
                      %                       unit(where: 'x^')}
                      %                 else unit
                      %                 end
                      %  in
                      %     {Out.record2FomusNote {Adjoin TextMarks
                      %                            unit(part:PartId
                      %                                 time:{N getStartTimeInBeats($)}
                      %                                 dur:{N getDurationInBeats($)}
                      %                                 pitch:{N getPitchInMidi($)})}
                      %      N}
		      %  end
		     %% TODO: consider writing a special chord output 
		     % Out.isFomusChord
		     %   #fun {$ MyChord PartId}
		     %   	    Ns = {MyChord getItems($)}
		     %   	 in
		     %   	   {ListToLines
		     %   	    {MakeFomusNote Ns.1 PartId} |
		     %   	    {Map Ns.2
		     %   	     fun {$ N}
		     %   		"  " % indent further chord tones
		     %   		#{Record2FomusEvent_Untimed
		     %   		  {Adjoin unit(pitch:{N getPitchInMidi($)})
		     %   		   {GetUserFomus N}}}
		     %   	     end}}
		     %   	end
		     %% HS notes
		     {HS.out.makeNoteToFomusClause
		      unit(% getPitchClass: midi
			   % table: ET31.out.fomusPCs_DoubleAccs
			   table:ET31.out.fomusPCs_Quartertones
			   getSettings:
			      fun {$ N}
				 if % {Measure.isAccentRatingMixin N} andthen
				    {Pattern.isMotifStartMixin N}
				 then 
				    % TextMarks_A = if {N getAccentRating($)} > 0
				    % 		  then {HS.out.vsToFomusMarks "a"#{N getAccentRating($)}
				    % 			unit(where: 'x^')}
				    % 		  else unit
				    % 		  end
				    TextMarks_M = if {N getMotifStartB($)} > 0
						  then {HS.out.vsToFomusMarks "m"#{N getMotifIndex($)}
							unit(where: 'x_')}
						  else unit
						  end
				 in
				    {HS.out.appendFomusMarks
				     TextMarks_M
				     % {HS.out.appendFomusMarks TextMarks_A TextMarks_M}
				     {HS.out.makeNonChordTone_FomusMarks N}}
				 else
				    {HS.out.makeNonChordTone_FomusMarks N}
				 end
			      end)}
		     {HS.out.makeChordToFomusClause
		      unit(% getPitchClass: midi
			   % table: ET31.out.fomusPCs_DoubleAccs
			   table:ET31.out.fomusPCs_Quartertones
			   getSettings:HS.out.makeComment_FomusMarks)}
		     {HS.out.makeScaleToFomusClause
		      unit(% getPitchClass: midi
			   % table: ET31.out.fomusPCs_DoubleAccs
			   table:ET31.out.fomusPCs_Quartertones
			   getSettings:HS.out.makeComment_FomusMarks)}
		     Measure.out.uniformMeasuresToFomusClause])
     Args}}
end



%% ?? Make selection of output formats controllable?
%% ?? No MIDI output?
proc {ExportScore MyScore Args} 
   % {Out.renderAndPlayCsound MyScore Args}
   {MidiOut_T.renderAndPlayMidiFile MyScore Args}
   {RenderFomus MyScore {Adjoin Args unit(output:xml)}} % XML 
   {RenderFomus MyScore Args} % Lily
%    {Out.callLilypond {Adjoin Args
% 		      unit(flags:["--png" "-dbackend=eps" "-dno-gs-load-fonts" "-dinclude-eps-fonts"]
% 			  )}}
   % {PDF2PNG {Init.getStrasheelaEnv defaultSoundDir}#Args.file}
   % {EncodeMP3 {Init.getStrasheelaEnv defaultSoundDir}#Args.file}
%    {PDF2PNG {Init.getStrasheelaEnv defaultSoundDir}#Args.file}
   % {Out.pickleScore MyScore unit(file: Args.file)}
   % {Out.outputScoreConstructor MyScore unit(file: Args.file)}
   % %% Remove aux files created by Lily (backend eps) and aiff files
   % {Out.exec rm [% wildcards did not work..
   % 		 {Init.getStrasheelaEnv defaultSoundDir}#Args.file#"-1.eps"
   % 		 {Init.getStrasheelaEnv defaultSoundDir}#Args.file#"-1.pdf"
   % 		 {Init.getStrasheelaEnv defaultSoundDir}#Args.file#"-systems.count" 
   % 		 {Init.getStrasheelaEnv defaultSoundDir}#Args.file#"-systems.tex"
   % 		 {Init.getStrasheelaEnv defaultSoundDir}#Args.file#"-systems.texi"
   % 		 {Init.getStrasheelaEnv defaultSoundDir}#Args.file#".eps"
   % 		 {Init.getStrasheelaEnv defaultSoundDir}#Args.file#".ly"
   % 		 % {Init.getStrasheelaEnv defaultSoundDir}#Args.file#".aiff"
   % 		]}
end




% {Explorer.object
%  add(information  proc {$ I X} {ExportScore X unit(file:"test-"#I)} end
%      label: 'Export Score (Fokker & Carillo)')}


/*

{Out.outputScoreConstructor MyScore unit(file:"mytest")}

{MyScore getInitClassesVS($)}

{FD.int nil}

*/


% /** %% Expects soundfile with full path but without extension and renders mp3 file.
% %% */
% proc {EncodeMP3 SoundFile}
%    %% notlame 
%     %       {Out.exec notlame ["-h" SoundFile#".aiff" SoundFile#".mp3"]}
%    %% lame
%    {Out.exec "lame" ["-V2" SoundFile#".aiff" SoundFile#".mp3"]}
% end
    
% /** %% Expects PDF with full path but without extension and renders PNG file.
% %% */
% proc {PDF2PNG File}
%    {Out.exec "convert" [File#".pdf" File#".png"]}
% end








