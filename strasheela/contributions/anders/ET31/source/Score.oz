
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
   
   /** %% [Convenience def only] Expects C (declaration of a chord, a record with the label chord) and returns a chord object (instance of HS.score.fullChord). 
   %% NB: the returned chord object is not fully initialised! 
   %% */
   fun {MakeChord C}
      Defaults = chord(%% just to remove symmetries 
		       sopranoChordDegree:1
		      )
      ChordSpec = {Adjoin {Adjoin Defaults C} chord}
   in
      {Score.makeScore2 ChordSpec
       %% label can be either chord or inversionChord
       unit(chord:HS.score.inversionChord)
      }
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


