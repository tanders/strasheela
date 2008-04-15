
%%
%% This files defines harmonic progression CSPs in 22 ET. 
%% 
%% Wxamples provide different options to select (e.g., a
%% different scale to use such as major or minor). These options are
%% marked by a "SELECT" in comments.
%%
%% Usage: first feed buffer, to feed definitions shared by all
%% examples. The feed the respective example in a /* comment block */.
%%

declare
[ET22] = {ModuleLink ['x-ozlib://anders/strasheela/ET22/ET22.ozf']}
{HS.db.setDB ET22.db.fullDB}
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
 unit(outname:"ChordsToScore"
      voices:5
      pitchDomain:{ET22.pitch 'C'#3}#{ET22.pitch 'C'#5}
      value:mid
%      value:min
      ignoreSopranoChordDegree:true
%      minIntervalToBass:{ET22.pc 'F'}
     )}



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
proc {MyScript ChordSeq}
   %% settings
   N = 5			% number of chords
   Dur = 2			% dur of each chord
   %% SELECT chords (for further chord names check the chord database in contributions/anders/ET22/source/DB.oz)
   %% only specified chord types are used 
   ChordIndices = {Map ['harmonic 7th'
			'subharmonic 6th'
			'augmented'
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
   %% no super strong progression
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



