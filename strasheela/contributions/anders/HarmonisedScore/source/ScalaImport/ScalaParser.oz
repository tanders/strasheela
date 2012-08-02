%%% -*-oz-gump-*-
\switch +gump
\switch +gumpparseroutputsimplified
\switch +gumpparserverbose

%% TODO:
%% - parenthesis permitted
%% - backslash may be used to break long lines

functor
import
   System
   GumpParser('class':GP)
   
export
   'class': ScalaParser

define
   
   parser ScalaParser from GP 
      meth error(VS) Scanner LookaheadMessage in 
	 GumpParser.'class', getScanner(?Scanner)
	 LookaheadMessage = case @lookaheadValue of unit
			    then ', while processing class `'#@lookaheadSymbol#'\''
			    else ', while processing '#@lookaheadValue
			          #' (class `'#@lookaheadSymbol#'\')'
			    end 
	 {System.showInfo 'line '#{Scanner getLineNumber($)}#': '#VS#LookaheadMessage}
	 %% Test: try to continue after error
	 %% See doc: The application of the predefined terminal 'error' defines a restart point for error recovery. Consult the bison manual [DS95] for additional information. 
	 % GumpParser.'class', errorOK 
      end 

      token
	 'comment' 'newline'
	 % ')'
	 'int'
	 % 'float'
	 'text' 'string'
	 '-': leftAssoc(2)
	 % ':': leftAssoc(2)
	 '=': leftAssoc(1)
	 % '(': leftAssoc(1)
	 ',': rightAssoc(1)
	 	 
      syn database($)
	 { ChordOrComment($) }*
      end

      syn ChordOrComment($)
	 Chord($)
      [] Comment($)
      end
      
      syn Comment($)
	 'comment'(X) 'newline' => comment(X)
      end
	 
      %% TODO: add that chord/scale degrees etc always start after a new line
      syn Chord($)
	 ChordDegrees(Ds) ChordLabels(Ls) 'newline' => labelledDegrees(Ds Ls)
						 %% TODO: allow for alternative syntax
      % [] AbsoluteRatios(Rs) Ns={ ChordLabel($) }+ => labelledAbsoluteRatios(Rs Ns) 
      % [] RelativeRatios(Rs) Ns={ ChordLabel($) }+ => labelledRelativeRatios(Rs Ns) 
      % [] ToneNames(Ts) Ns={ ChordLabel($) }+  => labelledToneNames(Ts Ns)
      end 

      %% TODO: scale degrees without '-' in between
      syn ChordDegrees($) 
	 %% TMP: this should be wrong! but parsing causes error otherwise
	 %% (*.simplified output indicates that this is sufficient, see comment in ChordDegrees_Aux)
	 ChordDegrees_Aux(Is) => chordDegrees(Is) 
	 % ChordDegrees_Aux(Is) 'int'(I_last) => chordDegrees({Append Is [I_last]}) 
      end
      syn ChordDegrees_Aux(?Is)
	 %% *.simplified output shows that this is basically translated into
	 %% int($) [] ChordDegrees_Aux($) '-' int($)
	 !Is=('int'($) // '-')*
      end

      
      % %% - BUG: text in a string can start with a digit, so a string is not just containing text...
      % syn String($)
      % 	 '"' text(T) '"' => string(T)
      % end
      %% TODO:
      % %% - can also contain '=' or '-'
      % %% - collect multiple tokens between strings and commas into single chord degree
      % syn TextOrString($)
      % 	 string(T) => string(T)
      % 		      %% TODO: notation for or (not |)
      % [] {'='}? Ts={ text($) | int($) }+ ',' => text(Ts)
      % end

      syn ChordLabels($)
	 {'='}? Ts=( ChordLabel($) )* LastChordLabel(T) => chordLabels({Append Ts [T]})
      end
      syn ChordLabel($)
	 string($) 
      [] Ts=( TextOrInt($) )+ ',' => text(Ts)
      end
      syn LastChordLabel($)
	 Ts=( TextOrInt($) )+ => text(Ts)
      end
      syn TextOrInt($)
	 text($)
      [] int($) 
      end

      %% rule unused 
      % syn Line($)
      % 	 skip => {GumpParser.'class', getScanner($) getLineNumber($)}
      % end

   end

end

