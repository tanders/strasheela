%%% -*-oz-gump-*-
\switch +gump
\switch +gumpparseroutputsimplified
\switch +gumpparserverbose

functor
import
   System
   GumpParser
   
export
   'class': CSV_Parser

define

   parser CSV_Parser from GumpParser.'class'
					
      meth error(VS) Scanner in 
	 GumpParser.'class', getScanner(?Scanner)
	 {System.showInfo 'line '#{Scanner getLineNumber($)}#': '#VS}
      end

      token 'int' 'track' 'type' 'string'

      syn records($)
	 { Record($) }* 
      end

      syn Record($)
	 'track'(Track) 'int'(Time) 'type'(Type) Parameters(Params) => csv(track:Track
									   time:Time
									   type:Type
									   parameters:Params)
      end

      syn Parameter($)
	 'int'($) 
      [] 'string'($) 
      end

      syn Parameters($)
	 { Parameter($) }*
      end
   
      %% !! do I need this?
      syn Line($)
	 skip => {GumpParser.'class', getScanner($) getLineNumber($)}
      end 
   end

end
