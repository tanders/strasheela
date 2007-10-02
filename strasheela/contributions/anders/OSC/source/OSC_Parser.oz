%%% -*-oz-gump-*-
\switch +gump
\switch +gumpparseroutputsimplified
\switch +gumpparserverbose

%%
%% TODO: 
%% 
%%

functor
import
   System
   GumpParser('class':GP)
   %% load OSC.ozf from x-ozlib, so ozh will not load that functor again!  
   OSC at 'x-ozlib://anders/strasheela/OSC/OSC.ozf'
   % OSC at '../OSC.ozf' 
   
export
   'class': OSC_Parser

define
   
   parser OSC_Parser from GP 
      meth error(VS) Scanner in 
	 GumpParser.'class', getScanner(?Scanner)
	 {System.showInfo 'line '#{Scanner getLineNumber($)}#': '#VS}
      end 

      token
	 'addressPattern' 'int' 'hex' 'float' 'string' ']'
	 '[' : leftAssoc(1)

	 %% The unit of transmission of OSC is an OSC Packet. The contents of an OSC packet must be either an OSC Message or an OSC Bundle.
      syn packet($)
	 Packets($)
      end

      syn Packet($)
	 Message($)
      [] Bundle($)
      end

      syn Packets($)
	 { Packet($) }*
      end
   
      %% !! efficiency: just appending Address in front of As is probably more efficient that transformation into tuple
      syn Message($)
	 'addressPattern'(Address) Args(As) => {List.toTuple Address As}
      end
      syn Messages($)
	 { Message($) }*
      end

      syn Timetag($)
	 %% FIXME: set to time NOW? 
	 'int'(I) => if I == 1 
		     then 1.0
		     else raise unrecognisedTimetag(I 'this should never happen') end
		     end
      [] 'hex'(S) => {OSC.ntpToUnixTime1000 {OSC.hexToDecimal1000 S}}
      end
   
      syn Arg($)
	 'int'($) 
      [] 'float'($) 
      [] 'string'($)
      end
      syn Args($) { Arg($) }* end
   
      syn Bundle($)
	 '[' Timetag(TT) Packets(Ps) ']' => TT | Ps
      end
   
      %% !! do I need this?
      syn Line($)
	 skip => {GumpParser.'class', getScanner($) getLineNumber($)}
      end 
   end

end
