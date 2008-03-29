
functor
import
%   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
%   SDistro at 'x-ozlib://anders/strasheela/source/ScoreDistribution.ozf'
   
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
%   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   
   ET31 at '../ET31.ozf'
   
export
   MakeChord
   ChordsToScore
   
define
   
   /** %% [Convenience def only] Expects C (a chord declaration of an inversion chord, labels are either chord or inversionChord) and returns a chord object.
   %% NB: the returned chord object is not fully initialised! 
   %% */
   fun {MakeChord C}
      {Score.makeScore2 C
       %% label can be either chord or inversionChord
       unit(chord:HS.score.inversionChord
	    inversionChord:HS.score.inversionChord)}
   end

   /** %% [Convenience def only] HS.score.chordsToScore with different Args defaults.
   %% */
   fun {ChordsToScore ChordSpecs Args}
      Defaults = unit(voices:5
		      pitchDomain:{ET31.pitch 'C'#3}#{ET31.pitch 'C'#5}
		      amp:30
		      %% as orig default
		      % value:mid
		      % ignoreSopranoChordDegree:false
		      % minIntervalToBass:0
		     ) 
      As = {Adjoin Defaults Args}
   in
      {HS.score.chordsToScore ChordSpecs As}
   end
   
   
%    /** %% Expects a list of chord declarations, transforms them to score objects with notes, and plays them using Csound.
%    %% Args are the arguments of ChordsToScore and 
%    %% */
%    proc {PlayChords Cs Args}
%       Defaults = unit(file:'test')
%       As = {Adjoin Defaults Args}
%    in
%       {Out.renderAndPlayCsound {ChordsToScore {Map Cs MakeChord}
% 				As}
%        As}
%    end
   
end


