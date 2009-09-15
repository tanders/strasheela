
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


%% sed random seed to date
{GUtils.setRandomGeneratorSeed 0}

% {Init.setTempo 60.0}

/*

{HS.db.getEditIntervalDB}

{HS.db.getEditChordDB}

*/




%%
%% Using chords from La Monte Young's The Well-Tuned Piano, and restricting the voice-leading distance between chords.
%% Homophonic chord progression
%%

/*

declare
/** %% CSP with chord sequence solution.
%% */
proc {MakeChords Chords}
   %% settings
   N = 9			% number of chords
   Dur = 2			% dur of each chord
   %% only specified chord types are used 
   ChordIndices = {Map [%% chords from La Monte Young's The Well-Tuned Piano
			'opening'
% 			'magic'
% 			'romantic'
% 			'gamelan'
% 			'tamiar dream'
			'lost ancestral region'
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
   %% first chord is harmonic dominant seventh in C
%    {Chords.1 getIndex($)} = {HS.db.getChordIndex 'harmonic 7th'}
%    {Chords.1 getRoot($)} = {ET41.pc 'C'}
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
		   chords: {MakeChords}
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



