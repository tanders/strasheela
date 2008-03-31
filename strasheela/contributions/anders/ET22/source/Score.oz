
functor
import
   
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   ET22 at '../ET22.ozf'
   
export
   ChordsToScore
   
define

   /** %% HS.score.chordsToScore with different Args defaults.
   %% */
   fun {ChordsToScore ChordSpecs Args}
      Defaults = unit(voices:5
		      pitchDomain:{ET22.pitch 'C'#3}#{ET22.pitch 'C'#5}
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
   
end


