
%%
%% Harmonic progression CSPs in 41 ET (very close to Phythagorean and 7-limit JI, 5-limit JI less so)
%%

declare
[ET41] = {ModuleLink ['x-ozlib://anders/strasheela/ET41/ET41.ozf']}
{HS.db.setDB ET41.db.fullDB}

{Explorer.object
 add(information proc {$ I X}
		    if {Score.isScoreObject X}
		    then 
		       FileName = out#{GUtils.timeForFileName}
		    in
		       %% Csound output of score
		       {Out.renderAndPlayCsound X
			unit(file:FileName)}
		       %% Lily
		       {ET41.out.renderAndShowLilypond X
			unit(file:FileName)}
		       %% Archive output
		       {Out.outputScoreConstructor X
			unit(file:FileName)}
		    end
		 end
     label: 'Csound and Lily output (ET41)')}


% %% TODO: define ET41.out.addExplorerOut_ChordsToScore
% {ET41.out.addExplorerOut_ChordsToScore
%  unit(outname:"ChordsToScore"
%       voices:4
%       pitchDomain:{ET41.pitch 'C'#3}#{ET41.pitch 'C'#5}
%       value:random
% %      value:min
%       ignoreSopranoChordDegree:true
% %      minIntervalToBass:{ET41.pc 'F'}
%      )}


% {Init.setTempo 60.0}

/*

{HS.db.getEditIntervalDB}

{HS.db.getEditChordDB}

*/




%%
%% Using chords from La Monte Young's The Well-Tuned Piano, and restricting the voice-leading distance between chords.
%% Homophonic chord progression
%%
%% Starts in C, but no tonal centre
%%


/*

%%
%% Homophonic chord progression
%%

declare
{GUtils.setRandomGeneratorSeed 0}
/** %% CSP with chord sequence solution.
%% */
proc {MakeYoungChords Chords}
   %% settings
   N = 9			% number of chords
   Dur = 2			% dur of each chord
   %% only specified chord types are used 
   ChordIndices = {Map [%% chords from La Monte Young's The Well-Tuned Piano
			'opening'
% 			'magic'
% 			'romantic'
% 			'gamelan'
			'tamiar dream'
% 			'lost ancestral region'
% 			'brook'
% 			'pool'
		       ]
		   HS.db.getChordIndex}
in
   %% create chord objects
   Chords = {LUtils.collectN N
	     fun {$} 
		{Score.makeScore2 chord(index:{FD.int ChordIndices}
					duration:Dur
					%% just to remove symmetries 
					% sopranoChordDegree:1
					timeUnit:beats)
		 %% label can be either chord or inversionChord
		 unit(chord:HS.score.inversionChord)}
	     end}
   %% end with 'opening' chord
   {{List.last Chords} getIndex($)} = {HS.db.getChordIndex 'opening'}
   %%
   %% First and last chords are equal (neither index nor transposition are distinct)
%    {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   %% Firs chord in C -- makes deciphering of notation more easy...
   {Chords.1 getRoot($)} = {ET41.pc 'C'}
   {HS.rules.distinctNeighbours Chords}
   {HS.rules.neighboursWithCommonPCs Chords}
   %% 
   {Pattern.for2Neighbours Chords
    proc {$ C1 C2}
       %% 60 percent or more note pairs change by a small interval (includes unisons).
%        Percent = {FD.int 60#100} 
%     in
%        {HS.rules.smallIntervalsInProgression_Percent C1 C2
% 	unit(ignoreUnisons: false)
% 	Percent}
       %%
       %% size of 15:14
       SmallInterval = {FloatToInt {MUtils.ratioToKeynumInterval 15#14
				    {IntToFloat {HS.db.getPitchesPerOctave}}}}
       N = {FD.decl}
    in
       {HS.rules.voiceLeadingDistance C1 C2 N}
       N =<: 2 * SmallInterval
    end}
   %% All chords are in root position.
   {ForAll Chords proc {$ C} {C getBassChordDegree($)} = 1 end}
   %%
   %% ?? TODO: some pattern constraint...
   %%
end
{SDistro.exploreOne
 proc {$ MyScore}
   MyScore = {Segs.homophonicChordProgression
	      unit(voiceNo: 5 % 8
		   iargs: unit(inChordB: 1
% 			       inScaleB: 1
			      )
		   %% one pitch dom spec for each voice
		   rargs: each # [unit(minPitch: 'C'#4 
				       maxPitch: 'A'#5)
				  unit(minPitch: 'G'#3 
				       maxPitch: 'E'#5)
				  unit(minPitch: 'G'#3 
				       maxPitch: 'E'#5)
				  unit(minPitch: 'C'#3 
				       maxPitch: 'A'#4)
				  unit(minPitch: 'E'#2 
				       maxPitch: 'D'#4)]
% 		   rargs: each # [unit(minPitch: 'C'#4 
% 				       maxPitch: 'A'#5)
% 				  unit(minPitch: 'C'#4 
% 				       maxPitch: 'A'#5)
% 				  unit(minPitch: 'G'#3 
% 				       maxPitch: 'E'#5)
% 				  unit(minPitch: 'G'#3 
% 				       maxPitch: 'E'#5)
% 				  unit(minPitch: 'C'#3 
% 				       maxPitch: 'A'#4)
% 				  unit(minPitch: 'C'#3 
% 				       maxPitch: 'A'#4)
% 				  unit(minPitch: 'E'#2 
% 				       maxPitch: 'D'#4)
% 				  unit(minPitch: 'E'#2 
% 				       maxPitch: 'D'#4)]
		   chords: {MakeYoungChords}
% 		   scales: {HS.score.makeScales
% 			    unit(iargs: unit(n:1
% 					     transposition: 0)
% 				 rargs: unit(types: ['major']))}
		   restrictMelodicIntervals: false
		   commonPitchesHeldOver: false
		   noParallels: false
		   playAllChordTones: true
		   noVoiceCrossing: true
		   maxUpperVoiceDistance: {HS.db.getPitchesPerOctave}
		   startTime: 0
		   timeUnit: beats)}
 end
 %% left-to-right strategy with breaking ties by type
 HS.distro.leftToRight_TypewiseTieBreaking
}

*/


/*

%%
%% Example that brings a single chord "into motion"
%% Only chord tones
%%
%% Two layers:
%%
%% - upper layer with simultaneous dyads, where the upper line is constrained by some pattern
%% - lower layer is monophonic line, with longer notes than upper line
%%

%%
%% Note: Musically, the present example is rather simplistic. La Monte Young quasi applies some counterpoint rules in Welltuned Piano...
%%
%% Ad hoc ideas for improvement: 
%% - Some pattern on bass pitch sequence that ensures some form
%% - Some other pattern on upper pitch sequence that introduces some global form (e.g., it is not clear why the example ends where it ends)
%% - Introduce some simple rhythmic pattern for upper voices
%%

%%
%% TODO:
%%
%% - ?? rhythm
%%
%%

declare
{GUtils.setRandomGeneratorSeed 0}
%%
{SDistro.exploreOne
 proc {$ MyScore}
    End
    AkkNo = 20 % TMP. See Limit7Bs constraint below -- depends on this number... Also number etc of LowerLayer notes
    AkkDur = 4 % TMP
    %% TMP constant note dur of akkords
    UpperLayer = {Segs.makeAkkords
		  unit(akkN: AkkNo		
		       iargs: unit(n: 2 % chord tones
				   duration: AkkDur
				   inChordB:1 
				  )
		       rargs: unit(maxPitch: 'G'#5
				   minPitch: 'G'#3
				   maxRange: 7#4 % max interval between tones
				   minPcCard: 2 % always two different PCs
				   sopranoPattern: proc {$ Ps}
						      %% constrain pitch sequence of all upper tones of akkords sequence 
						      {Pattern.undulating Ps unit}
						      {HS.rules.ballistic Ps unit(oppositeIsStep: true)}
						      {Pattern.noRepetition Ps}
						   end
				   rule: proc {$ Akks}
					    %% At least 50 percent of dyads are 7-limit (i.e. no 3-limit dyads)
					    Limit7Bs = {Map Akks
							fun {$ Akk}
							   [N1 N2] = {Akk getItems($)}
							in
							   {HS.rules.isLimit7ConsonanceR {HS.rules.getInterval N1 N2}}
							end}
					 in
					    %% Ensure that the 7-limit dyads are somewhat evenly distributed (at least 3 in every 5 dyads)
					    %%
					    %% TMP: hardcoded total number of Limit7Bs
					    {ForAll {LUtils.sublists Limit7Bs
						  [1#5 6#10 11#15 16#20]}
					     proc {$ Bs}
						{Pattern.percentTrue_Range Bs 50 100}
					     end}
					 end
				  ))}
    LowerLayer = {Segs.makeCounterpoint
		  unit(iargs: unit(n: AkkNo div 5
				   inChordB:1 
				   duration: AkkDur * 5
				   rule: proc {$ Ns}
					    {Pattern.noRepetition {Pattern.mapItems Ns getPitch}}
					 end)
		       rargs: unit(maxPitch: 'B'#3
				   minPitch: 'C'#3)
		      )}
    AllNotes
 in
    MyScore = {Score.make sim([seq(UpperLayer
				   endTime: End)
			       seq(LowerLayer
				   endTime: End)
			       %% use chord with at least 5 PCs, so there are different options if there should be always 3 sim PCs
			       seq([chord(index:{HS.db.getChordIndex 'lost ancestral region'}
					  root:{HS.pc 'C'})]
				   endTime: End)]
			      startTime:0
			      timeUnit: beats(4))
	       add(chord: HS.score.inversionChord)}
    AllNotes = {MyScore collect($ test:isNote)}
    %%
    %% always at least 3 different sim PCs, i.e. there are never unisonos nor octaves 
    thread
       {SMapping.forTimeslices AllNotes
	proc {$ Ns} {HS.rules.minCard Ns 3} end
	unit(endTime: End
	     %% NOTE: avoid reapplication of constraint for equal consecutive sets of score object
	     step: AkkDur		% ?? should be shortest note dur available..
	    )}
    end
 end
  HS.distro.leftToRight_TypewiseTieBreaking
}





*/


/* % TMP test



*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%
%%
