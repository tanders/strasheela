
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

% \switch +gump 
% \switch +gumpparseroutputsimplified +gumpparserverbose

functor 
import
%   GumpScanner GumpParser System
   CSV_Scanner at 'CSV_Scanner.ozf'
   CSV_Parser at 'CSV_Parser.ozf'
   Init at 'x-ozlib://anders/strasheela/source/Init.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   
export
   ParseCSVFile
   RenderCSVFile
   
define

%   \insert CSV_Scanner.ozg 
%   \insert CSV_Parser.ozg

   /** %% Expects the path to a CSV file (a record of optional path components) and returns a list of corresponding midi events. The Spec defaults are the following
   unit(file:"test"
	csvDir:{Init.getStrasheelaEnv defaultCSVDir}
	csvExtension:'.csv')
   %% */
   proc {ParseCSVFile Spec ?Result}
      Defaults = unit(file:"test"
		      csvDir:{Init.getStrasheelaEnv defaultCSVDir}
		      csvExtension:'.csv')
      Args = {Adjoin Defaults Spec}
      CsvPath = Args.csvDir#Args.file#Args.csvExtension
      MyScanner = {New CSV_Scanner.'class' init()}
      MyParser = {New CSV_Parser.'class' init(MyScanner)}
      CSVRecords Status
   in 
      {MyScanner scanFile(CsvPath)}
      {MyParser parse(records(?CSVRecords) ?Status)}
      {MyScanner close()}
      if Status then
	 Result = CSVRecords
      else
	 %% TODO: proper exception
	 %% !!?? failedRequirement error??
%	 {Exception.raiseError
%	  strasheela(failedRequirement CsvPath "Message VS")}
	 raise parseError(CsvPath) end
      end 
   end

   
   /** %% Transforms a Midi file into a CSV file (by calling midicsv). The Spec defaults are the following.
   unit(file:"test"
	csvDir:{Init.getStrasheelaEnv defaultCSVDir}
	midiDir:{Init.getStrasheelaEnv defaultMidiDir}
	csvExtension:".csv"
	midiExtension:".mid"
	midicsv:{Init.getStrasheelaEnv midicsv}
	%% !!?? is flags control needed?
	flags:{Init.getStrasheelaEnv defaultCSVFlags})
   %% */
   %% !! Only CSV file with same basename (but different extension) as input MIDI file can be created.
   proc {RenderCSVFile Spec}
      Defaults = unit(file:"test"
		      csvDir:{Init.getStrasheelaEnv defaultCSVDir}
		      midiDir:{Init.getStrasheelaEnv defaultMidiDir}
		      csvExtension:".csv"
		      midiExtension:".mid"
		      midicsv:{Init.getStrasheelaEnv midicsv}
		      %% !!?? is flags control needed?
		      flags:{Init.getStrasheelaEnv defaultCSVFlags})
      Args = {Adjoin Defaults Spec}
      CsvPath = Args.csvDir#Args.file#Args.csvExtension
      MidiPath = Args.midiDir#Args.file#Args.midiExtension
   in
      {Out.exec Args.midicsv {Append Args.flags  [MidiPath CsvPath]}}
   end
   
end

