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

define

   UniformMeasuresToFomusClause
   = Measure.isUniformMeasures # fun {$ MyMeasure _ /* PartID */}
				    {Out.record2FomusMeasure
				     unit(time: {MyMeasure getStartTimeInBeats($)}
					  dur: {{MyMeasure getMeasureDurationParameter($)} getValueInBeats($)}  
% 			       dur: {MyMeasure getDurationInBeats($)}
					  timesig:
					     "("#{MyMeasure getBeatNumber($)}#" "#({FloatToInt {{MyMeasure getBeatDurationParameter($)} getValueInBeats($)}}*4)#")"
					 )}
				 end

end
