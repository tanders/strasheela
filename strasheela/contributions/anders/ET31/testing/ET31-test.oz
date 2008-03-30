
declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}
%%
%% Configure a Explorer output action for 31 ET, which expects only a
%% sequential container with chord objects as solution (i.e. without
%% the actual notes). The Explorer output action itself then creates a
%% CSP with expects a chord sequence and returns a homophonic chord
%% progression. The arguments of the action affect this CSP for the
%% homophonic chord progression. The result is transformed into
%% music notation (with Lilypond), sound (with Csound), and Strasheela
%% code (archived score objects).
{ET31.out.addExplorerOut_ChordsToScore
 unit(outname:"ChordsToScore"
      voices:4
      pitchDomain:{ET31.pitch 'C'#3}#{ET31.pitch 'C'#5}
      value:min
      ignoreSopranoChordDegree:true
%      minIntervalToBass:{ET31.pc 'F'}
     )}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Creates short demo chord progression in 31 ET. Neighbouring chords
%%  are harmonically closely related, but the example does not
%%  necessarily stay in a single key. The example also demonstrates
%%  one of the Schoenberg constraints: all chord progressions are
%%  either ascending, or some decending progression is only a 'passing
%%  chord'. See HS.rules.schoenberg for details on these constraints.
%% 
%% The solution contains a bare chord sequence, use the Explorer
%% action "ChordsToScore" to actually read and hear a solution.
%%

/*

declare
%%
/** %% Constraints the pitch class interval between the bass PCs of the chords C1 and C2 to IntervalPC. IntervalPC is implicitly declared an FD int. 
%% */
proc {TransposeBassPC [C1 C2] ?IntervalPC}
   {HS.score.transposePC {C1 getBassPitchClass($)} IntervalPC
    {C2 getBassPitchClass($)}}
end
%%
/** %% CSP with chord sequence solution.
%% */
proc {MyScript ChordSeq}
   %% settings
   N = 9			% number of chords
   Dur = 2			% dur of each chord
   %% only specified chord types are used 
   ChordIndices = {Map [% 'harmonic diminished'
			% 'harmonic halve-diminished seventh'
			'harmonic dominant seventh'
			% 'minor with minor seventh'
			'reversed harmonic dominant seventh']
		   HS.db.getChordIndex}
   %% create chord objects
   Chords = {LUtils.collectN N
	     fun {$} 
		{ET31.score.makeChord
		 chord(index:{FD.int ChordIndices}
		       duration:Dur
		       timeUnit:beats)}
	     end} 
in
   %% create music representation for solution
   ChordSeq = {Score.makeScore seq(items:Chords
				   startTime:0)
	       unit}
   %% Good progression: ascending or descending progression only as 'passing chords'
   {HS.rules.schoenberg.resolveDescendingProgressions Chords unit}
   %% no super strong progression in such a simple progression
   {Pattern.for2Neighbours Chords 
    proc {$ C1 C2} {HS.rules.schoenberg.superstrongProgressionR C1 C2 0} end}
   %% First and last chords are equal (neither index nor transposition are distinct)
   {HS.rules.distinctR Chords.1 {List.last Chords} 0}
   %% roots of all other chords are distinct
   {FD.distinct {Map Chords.2 fun {$ X} {X getRoot($)} end}}
   %% first chord is harmonic dominant seventh in C
   {Chords.1 getIndex($)} = {HS.db.getChordIndex 'harmonic dominant seventh'}
   {Chords.1 getRoot($)} = {ET31.pc 'C'}
   %% 30-70% are minor chords
   {Pattern.percentTrue_Range
    {Map Chords proc {$ C B}
		   B = ({C getIndex($)} =: {HS.db.getChordIndex
					    'reversed harmonic dominant seventh'})
		end}
    30 70}
   %% chord indices form cycle pattern
   {Pattern.cycle {Map Chords fun {$ C} {C getIndex($)} end} 3}
   %% All chords are in "root position". Note that some chords are (presently) defined such that the actual root is not a sounding chord tone.
   {ForAll Chords proc {$ C} {C getBassChordDegree($)} = 1 end}
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
%% test notation
%%

/*

{ET31.pc 'C#'}
{ET31.pc 'Db'}

{ET31.pcName 2}
{ET31.pcName 3}

{ET31.acc '#|'}
{ET31.acc 'bb'}


{ET31.pitch 'C'#0}
{ET31.pitch 'C#'#4}

*/


