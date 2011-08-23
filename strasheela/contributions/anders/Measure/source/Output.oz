%%% *************************************************************
%%% Copyright (C) Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% This functor defines output procedures for Measure objects.
%% */


functor
import
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   Measure at '../Measure.ozf'

export
   UniformMeasuresToFomusClause
   MakeUniformMeasuresToFomusClause

define

   /* %% MakeUniformMeasuresToFomusClause adds support for UniformMeasures objects to Fomus export.
   %%
   %% Args:
   %% explicitTimeSig (default true): a Boolean specifying wether explicit time signatures are exported to Fomus. If false, then Fomus receives only the duration of the measure and computes the time signature itself. 
   %%
   %% */
   fun {MakeUniformMeasuresToFomusClause Args}
      Defaults = unit(explicitTimeSig: true)
      As = {Adjoin Defaults Args}
   in
      Measure.isUniformMeasures
      # fun {$ MyMeasure _ /* PartID */}
	   {Out.record2FomusMeasure
	    {Record.adjoin
	     unit(time: {MyMeasure getStartTimeInBeats($)}
		  %% if explicitTimeSig is true, then Fomus ignores the dur
		  dur: {{MyMeasure getMeasureDurationParameter($)}
			getValueInBeats($)})
	     if As.explicitTimeSig then
		unit(timesig:
			"("#{MyMeasure getBeatNumber($)}#" "#{FloatToInt 4.0 / {{MyMeasure getBeatDurationParameter($)} getValueInBeats($)}}#")")
	     else unit
	     end}}
	end
   end

   UniformMeasuresToFomusClause = {MakeUniformMeasuresToFomusClause unit}

end
