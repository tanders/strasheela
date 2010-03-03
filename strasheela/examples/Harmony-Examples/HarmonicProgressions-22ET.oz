
%%
%% This files defines harmonic progression CSPs in 22 ET. 
%% 
%% Examples provide different options to select (e.g., a
%% different scale to use such as major or minor). These options are
%% marked by a "SELECT" in comments.
%%
%% Usage: first feed buffer, to feed definitions shared by all
%% examples. Then feed the respective example in a /* comment block */.
%%

declare
[Segs] = {ModuleLink ['x-ozlib://anders/strasheela/Segments/Segments.ozf']}
[ET22] = {ModuleLink ['x-ozlib://anders/strasheela/ET22/ET22.ozf']}
{HS.db.setDB ET22.db.fullDB}

/* TMP

*/


/* % consider using an alternative tuning table

%% Pajara with RMS optimal generator
{Init.setTuningTable ET22.out.pajaraRMS_TuningTable}

%% Pajara TOP tuning
{Init.setTuningTable unit(65.60000
			  106.57000
			  172.17000
			  213.14000
			  278.74000
			  319.71000
			  385.31000
			  426.28000
			  491.88000
			  532.85000
			  598.45000
			  664.05000
			  705.02000
			  770.62000
			  811.59000
			  877.19000
			  918.16000
			  983.76000
			  1024.73000
			  1090.33000
			  1131.30000
			  1196.90000)}

%% JI
{Init.setTuningTable ET22.out.ji_TuningTable}


{Init.unsetTuningTable}

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% CSPs resulting in plain chord seq (use explorer action "ChordsToScore (ET22)")
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Decatonic cadence.
%%

/*

declare
%% SELECT scale. 
MyScale = {Score.makeScore
	   scale(
	      %% SELECT scale
% 	      index:{HS.db.getScaleIndex 'standard pentachordal major'}
% 	      index:{HS.db.getScaleIndex 'static symmetrical major'}
 	      index:{HS.db.getScaleIndex 'dynamic symmetrical major'}
% 	      index:{HS.db.getScaleIndex 'standard pentachordal minor'}
% 	      index:{HS.db.getScaleIndex 'static symmetrical minor'}
% 	      index:{HS.db.getScaleIndex 'dynamic symmetrical minor'}
	      transposition:{ET22.pc 'C'})
           unit(scale:HS.score.scale)}
%%
/** %% CSP with chord sequence solution. Only diatonic chords, follow Schoebergs recommendation on good roor progression, end in cadence. 
%% */
proc {MyScript ChordSeq}
   %% settings
   N = 8			% number of chords
   Dur = 2			% dur of each chord
   %% SELECT chords (for further chord names check the chord database in contributions/anders/ET22/source/DB.oz)
   %% only specified chord types are used 
   ChordIndices = {Map ['harmonic 7th'
			'subharmonic 6th'
			%% TODO: constraint: two augmented should not follow each other. BTW: how to resolve augmented?
% 			 'augmented'
		       ]
		   HS.db.getChordIndex}
   %% create chord objects
   Chords = {LUtils.collectN N
	     fun {$}
		{Score.makeScore2 chord(index:{FD.int ChordIndices}
					duration:Dur
					%% just to remove symmetries 
					sopranoChordDegree:1
					timeUnit:beats)
		 %% label can be either chord or inversionChord
		 unit(chord:HS.score.inversionChord)}
	     end} 
in
   %% create music representation for solution
   ChordSeq = {Score.makeScore seq(items:Chords
				   startTime:0)
	       unit}
   %% Good chord root progression 
   {HS.rules.schoenberg.resolveDescendingProgressions Chords unit}
   %% NOTE: no solution with only ascending progressions
%   {Pattern.for2Neighbours Chords
%    proc {$ C1 C2} {HS.rules.schoenberg.ascendingProgressionR C1 C2 1} end}
   %% NOTE: no solution with no super strong progression (with no scale and the given three chords)
%   {Pattern.for2Neighbours Chords
%    proc {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2 0} end}
   %% First and last chords are equal (neither index nor transposition are distinct)
   {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   %% All chords are in root position. 
   {ForAll Chords proc {$ C} {C getBassChordDegree($)} = 1 end}
   %% only diatonic chords
   {ForAll Chords proc {$ C} {HS.rules.diatonicChord C MyScale} end}
   %% last three chords form cadence
   {HS.rules.cadence MyScale {LUtils.lastN Chords 3}}
end
%% sed random seed to date
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript unit(order:startTime
				  value:random
				  % value:mid
				 )}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Decatonic and purely ascending chord progression.
%%
%% Note that this example does allow for all chords in the chord database (and there is no dissonance treatment)
%%
%% TODO: in a next example: somehow treat dissonances, e.g., slowly increase/decrease degree of dissonance or prepare/resolve dissonances.. 
%% 

/*

declare
%% SELECT scale. 
MyScale = {Score.makeScore
	   scale(
	      %% SELECT scale
 	      index:{HS.db.getScaleIndex 'standard pentachordal major'}
% 	      index:{HS.db.getScaleIndex 'static symmetrical major'}
% 	      index:{HS.db.getScaleIndex 'dynamic symmetrical major'}
% 	      index:{HS.db.getScaleIndex 'standard pentachordal minor'}
% 	      index:{HS.db.getScaleIndex 'static symmetrical minor'}
% 	      index:{HS.db.getScaleIndex 'dynamic symmetrical minor'}
	      transposition:{ET22.pc 'C'})
           unit(scale:HS.score.scale)}
%%
/** %% CSP with chord sequence solution. Only diatonic chords, follow Schoebergs recommendation on good roor progression, end in cadence. 
%% */
proc {MyScript ChordSeq}
   %% settings
   N = 4			% number of chords
   Dur = 2			% dur of each chord
   %% no solution with only these chords..
%    ChordIndices = {Map ['harmonic 7th'
% 			'subharmonic 6th'
% 			%% TODO: constraint: two augmented should not follow each other. BTW: how to resolve augmented?
% 			'augmented'
% 		       ]
% 		   HS.db.getChordIndex}
   %% create chord objects
   Chords = {LUtils.collectN N
	     fun {$}
		{Score.makeScore2 chord(% index:{FD.int ChordIndices}
					duration:Dur
					%% just to remove symmetries 
					sopranoChordDegree:1
					timeUnit:beats)
		 %% label can be either chord or inversionChord
		 unit(chord:HS.score.inversionChord)}
	     end} 
in
   %% create music representation for solution
   ChordSeq = {Score.makeScore seq(items:Chords
				   startTime:0)
	       unit}
   %% Good chord root progression 
%   {HS.rules.schoenberg.resolveDescendingProgressions Chords unit}
   {Pattern.for2Neighbours Chords
    proc {$ C1 C2} {HS.rules.schoenberg.ascendingProgressionR C1 C2 1} end}
%   {Pattern.for2Neighbours Chords
%    proc {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2 0} end}
   %% First and last chords are equal (neither index nor transposition are distinct)
   {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   %% All chords are in root position. 
   {ForAll Chords proc {$ C} {C getBassChordDegree($)} = 1 end}
   %% only diatonic chords
   {ForAll Chords proc {$ C} {HS.rules.diatonicChord C MyScale} end}
   %% last three chords form cadence
  {HS.rules.cadence MyScale {LUtils.lastN Chords 3}}
end
%% sed random seed to date
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript unit(order:startTime
				  value:random
				  % value:mid
				 )}

*/




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Better understand possibilities of decatonic scale. 
%% Show all chords possible on a given degree of the decatonic scale (var ScaleDegree)
%% 
%% (see examples/ShowHarmonicDatabases.oz for much more detailed examples for such purposes)
%%


/*

declare
%% SELECT scale. 
MyScale = {Score.makeScore
	   scale(
	      %% SELECT scale
% 	      index:{HS.db.getScaleIndex 'standard pentachordal major'}
 	      index:{HS.db.getScaleIndex 'static symmetrical major'}
% 	      index:{HS.db.getScaleIndex 'dynamic symmetrical major'}
% 	      index:{HS.db.getScaleIndex 'standard pentachordal minor'}
% 	      index:{HS.db.getScaleIndex 'static symmetrical minor'}
% 	      index:{HS.db.getScaleIndex 'dynamic symmetrical minor'}
	      transposition:{ET22.pc 'C'})
           unit(scale:HS.score.scale)}
%%
/** %% CSP with chord sequence solution. Only diatonic chords, follow Schoebergs recommendation on good roor progression, end in cadence. 
%% */
%% Select ScaleDegree: 1-10
ScaleDegree = 1
ScaleDegreePC = {FD.decl}
ScaleDegreePC = {HS.score.degreeToPC
		 {HS.score.pcSetToSequence
		  {MyScale getPitchClasses($)} {MyScale getRoot($)}}
		 ScaleDegree#{ET22.acc ''}}
proc {MyScript ChordSeq}
   %% settings
   N = 1			% number of chords
   Dur = 4			% dur of each chord
%    ChordIndices = {Map ['harmonic 7th'
% 			'subharmonic 6th'
% 			'augmented'
% 		       ]
% 		   HS.db.getChordIndex}
   %% create chord objects
   Chords = {LUtils.collectN N
	     fun {$}
		{Score.makeScore2 chord(% don't restrict the chord index
				        % index:{FD.int ChordIndices}
					duration:Dur
					% root position
					bassChordDegree:1
					root:ScaleDegreePC
					%% just to remove symmetries 
					sopranoChordDegree:1
					timeUnit:beats)
		 %% label can be either chord or inversionChord
		 unit(chord:HS.score.inversionChord)}
	     end} 
in
   %% create music representation for solution
   ChordSeq = {Score.makeScore seq(items:Chords
				   startTime:0)
	       unit}
   %% only diatonic chords
   {ForAll Chords proc {$ C} {HS.rules.diatonicChord C MyScale} end}
end
%% sed random seed to date
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript unit(order:startTime
				  value:random
				  % value:mid
				 )}

*/


/*

%% there are 31 chords in total in the DB
{Browse {Width {HS.db.getEditChordDB}}}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% CSPs resulting in homophonic choral setting
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/*

%%
%% TODO: some dissonance resolution (if 'augmented' then fundament upwards a fourth?).
%%

%% Schoenberg rules
%%
%% Note: no solution for purely ascending progression with only harmonic 7th, subarmonic 6th and augmented.
%% try: no super-strong, at least not at end
%% it is possible to have no augmented chords..
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    Chords = {HS.score.makeChords
	      unit(iargs: unit(n:9
% 			       constructor:HS.score.inversionChord
			       constructor:HS.score.fullChord
			       duration: 2
			       bassChordDegree: 1
			       inScaleB: 1)
		   rargs: unit(types: ['harmonic 7th'
				       'subharmonic 6th'
				       %% only root differs from 'subharmonic 6th'
% 				       'half subdiminished 7th' 
				       %% TODO: constraint: two augmented should not follow each other. BTW: how to resolve augmented?
% 				       'augmented'
% 				       'French augmented 6th'
				      ]))}
    MyScale = {Score.make2 scale(index: {HS.db.getScaleIndex 'dynamic symmetrical major'}
				 transposition: 0)
	     unit(scale:HS.score.scale)}
 in
   MyScore = {Segs.homophonicChordProgression
	      unit(voiceNo: 5
		   iargs: unit(inChordB: 1
			       inScaleB: 1
			      )
		   %% one pitch dom spec for each voice
		   rargs: each # [unit(minPitch: 'C'#4 
				       maxPitch: 'A'#5)
				  unit(minPitch: 'C'#4 
				       maxPitch: 'A'#5)
				  unit(minPitch: 'G'#3 
				       maxPitch: 'E'#5)
				  unit(minPitch: 'C'#3 
				       maxPitch: 'A'#4)
				  unit(minPitch: 'E'#2 
				       maxPitch: 'D'#4)]
		   chords: Chords
		   scales: [MyScale]
		   restrictMelodicIntervals: false
		   commonPitchesHeldOver: false
% 		   noParallels: false
		   startTime: 0
		   timeUnit: beats)}
    {HS.rules.schoenberg.progressionSelector Chords
     resolveDescendingProgressions
%      ascending
    }
    %% last three chords (cadence) no superstrong progressions
    {Pattern.for2Neighbours {Reverse {List.take {Reverse Chords} 3}}
     proc {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2 0} end}
%     {Pattern.for2Neighbours {Reverse {List.take {Reverse Chords} 3}}
%      proc {$ C1 C2} {HS.rules.schoenberg.ascendingProgressionR C1 C2 1} end}
%     {Pattern.for2Neighbours Chords
%      proc {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2 0} end}
    %% First and last chords are first scale degree.
    {Chords.1 getRootDegree($)} = {{List.last Chords} getRootDegree($)} = 1 
%     {HS.rules.distinctR Chords.1 {List.last Chords} 0}
%     %% only diatonic chords
%     {ForAll Chords proc {$ C} {HS.rules.diatonicChord C MyScale} end}
    %% last three chords form cadence
    {HS.rules.cadence MyScale {LUtils.lastN Chords 4}}
    %% NOTE: directly causes fail, some bug? 
%     {HS.rules.resolveDissonances Chords unit(consonantChords:['harmonic 7th'
% 							      'subharmonic 6th'])}
 end
 %% left-to-right strategy with breaking ties by type
 HS.distro.leftToRight_TypewiseTieBreaking
%  HS.distro.typewise_LeftToRightTieBreaking
}

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Simply list all scales in a musical examples 
%%






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Simple test with non-harmonic tones (checking adaptive JI)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/*


declare
%% initialise seed for randomisation of search
{GUtils.setRandomGeneratorSeed 0}
%% a beat (quarter note) has duration 4
Beat = 4
%% call solver
{SDistro.exploreOne
 %% define script 
 proc {$ MyScore}
    %% total number of notes
    ChordSpecs = [chord('C' 'harmonic 7th')
 		  chord('F' 'harmonic 7th')
 		  chord('G' 'harmonic 7th')
 		  chord('C' 'harmonic 7th')
		 ]
    L = {Length ChordSpecs}
    NoteDur = 2
    NotesPerChord = 6
    TotalNoteNo = L * NotesPerChord
    %% underlying scale is C major
    MyScale = {Score.make2 scale(index: {HS.db.getScaleIndex 'dynamic symmetrical major'}
				 transposition: {HS.pc 'C'})
	       unit(scale: HS.score.scale)}
    %% create list of chords from specs: every chord two beats long
    Chords = {Map ChordSpecs
	      fun {$ chord(Root Type)}
		 {Score.make2 chord(index: {HS.db.getChordIndex Type}
				    root: {HS.pc Root}
				    duration: NoteDur * NotesPerChord)
		 unit(chord: HS.score.chord)}
	      end}
    %% Create list of actual 
    VoiceNotes = {Segs.makeCounterpoint
		  unit(
		     %% args for individual notes
		     iargs: unit(n: TotalNoteNo
				 inScaleB:1 % only use scale pitches
				 %% possible durations
				 duration: NoteDur
				)
		     rargs: unit(maxPitch: 'G'#5
				 minPitch: 'G'#4
				 maxNonharmonicNoteSequence: 1)
		     )}
    Akks = {Segs.makeAkkords
	    unit(akkN:L
		 iargs: unit(n: 4 % chord tones
			     duration: NoteDur * NotesPerChord
			    )
		 rargs: unit(maxPitch: 'G'#4
			     minPitch: 'G'#3))}
    BassNs = {Segs.makeCounterpoint
	      unit(iargs: unit(n: L
			       inChordB:1 
			       duration: NoteDur * NotesPerChord
			      )
		   rargs: unit(maxPitch: 'B'#3
			       minPitch: 'C'#3)
		  )}
    End                         % for unifying endtimes
 in
    %% Pitch of notes created by Segs.makeCounterpoint are implicitely constrained to fit to simultaneous chords and scales
    MyScore = {Score.make sim(info: lily("\\time 3/4")
			      [seq(info: channel(0) % Midi channel 1
				   VoiceNotes
				   endTime: End)
			       seq(Akks
				   endTime: End)
			       seq(BassNs
				   endTime: End)
			       seq(Chords
				   endTime: End)
			       seq([MyScale]
				   endTime: End)]
			      startTime: 0
			      timeUnit: beats(Beat))
	       unit}
%     {VoiceNotes.1 getPitchClass($)} = {HS.pc 'G'}
%     {Pattern.increasing {Pattern.mapItems VoiceNotes getPitch}}
    {Pattern.cycle
     {Pattern.contour {Pattern.mapItems VoiceNotes getPitch}}
     NotesPerChord}
    {Pattern.for2Neighbours {Pattern.mapItems VoiceNotes getPitch}
     proc {$ P1 P2} P1 \=: P2 end}
    {ForAll BassNs
     proc {$ BN} {{BN getChords($)}.1 getRoot($)} = {BN getPitchClass($)} end}
 end
 %% definition of search strategy
 HS.distro.typewise_LeftToRightTieBreaking
}


*/

/* % TMP


{HS.db.getInternalIntervalDB}

{HS.db.getEditIntervalDB}

{HS.db.pc2Ratios 18 {HS.db.getEditIntervalDB}}



*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Aux defs
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Output
%%

%% Configure a Explorer output action for 22 ET, which expects only a
%% sequential container with chord objects as solution (i.e. without
%% the actual notes). The Explorer output action itself then creates a
%% CSP with expects a chord sequence and returns a homophonic chord
%% progression. The arguments of the action affect this CSP for the
%% homophonic chord progression. The result is transformed into music
%% notation (with Lilypond, requires Lilypond 2.11.43 or later), sound
%% (with Csound), and Strasheela code (archived score objects).
{ET22.out.addExplorerOut_ChordsToScore
 unit(outname:"ChordsToScore (ET22)"
      voices:5
      pitchDomain:{ET22.pitch 'C'#4}#{ET22.pitch 'C'#6}
      value:mid
%      value:min
      ignoreSopranoChordDegree:true
%      minIntervalToBass:{ET22.pc 'F'}
     )}

EventToCsound_adaptiveJI 
= {Out.makeEvent2CsoundFn 1
   [getStartTimeParameter#getValueInSeconds
    fun {$ X} X end#getDurationInSeconds
    getAmplitudeParameter#getValueInNormalized
    %% max 127 velo results in max 90 dB (Csound amp value 31622.764)
%     getAmplitudeParameter#fun {$ X} {MUtils.levelToDB {X getValueInNormalized($)} 1.0} + 90.0 end
    fun {$ X} X end#fun {$ MyNote}
		       JIPitch = {HS.score.getAdaptiveJIPitch MyNote unit}
% 		       ETPitch = {MyNote getPitchInMidi($)}
		    in
		       JIPitch
% 		       %% JI may at max be 10 cent off, otherwise take ETPitch
% 		       %% 13#8 is 11 cent error
% 		       if {Abs JIPitch-ETPitch} > 0.11 then
% 			  {Browse
% 			   off_JI(ji:{HS.score.getAdaptiveJIPitch MyNote unit}
% 				  midi: {MyNote getPitchInMidi($)}
% 				  note:{MyNote toInitRecord($)}
% 				  chordIndex: {{MyNote getChords($)}.1 getIndex($)}
% 				  chordTransposition: {{MyNote getChords($)}.1 getTransposition($)}
% 				  chordPCs: {{MyNote getChords($)}.1 getPitchClasses($)}
% 				  chordRatios: {HS.db.getUntransposedRatios {MyNote getChords($)}.1}
% 				  noteDegreeInChord: {HS.score.getDegree {MyNote getPitchClass($)} {MyNote getChords($)}.1 unit(accidentalRange: 0)}
% 				 )}
% % 			  ETPitch
% 			  JIPitch
% 		       else
% % 			  {Browse ok_JI}
% % 			  {System.show
% % 			   {Out.recordToVS
% % 			    ok_JI}}
% 			  JIPitch
% 		       end
		    end
   ]}

	     
%% Explorer output 
proc {RenderLilypondAndCsound I X}
   if {Score.isScoreObject X}
   then 
      FileName = "Test-"#I#"-"#{GUtils.getCounterAndIncr}
   in
      {ET22.out.renderAndShowLilypond X
       unit(file: FileName
	   )}
      {Out.renderAndPlayCsound X
       unit(file: FileName)} 
   end
end
proc {RenderCsoundAndLilypond_AdaptiveJI I X}
   if {Score.isScoreObject X}
   then 
      FileName = "test-"#I#"-"#{GUtils.getCounterAndIncr}#"-adaptiveJI"
   in
      {Out.renderAndPlayCsound X
       unit(file: FileName
	    event2CsoundFn: EventToCsound_adaptiveJI
	   )}
      {ET22.out.renderAndShowLilypond X
       unit(file: FileName
	    lowerMarkupMakers: [HS.out.makeAdaptiveJI2_Marker
				HS.out.makeChordComment_Markup
				HS.out.makeScaleComment_Markup]
	    wrapper: [LilyHeader 
		      "\n}\n}"]
	   )}
   end
end
{Explorer.object
 add(information RenderLilypondAndCsound
     label: 'to Lily + Csound: 22 ET')}
{Explorer.object
 add(information RenderCsoundAndLilypond_AdaptiveJI
     label: 'to Lily + Csound: 22 ET (adaptive JI)')}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Distro
%%

