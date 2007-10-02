
/** %% This functor defines an interface to gnuplot (www.gnuplot.info) for plotting numeric Oz data.
%% The test file testing/Gnuplot-test.oz provides many examples which also serve as documentation of this interface's features. 
%% */

%%
%% TODO:
%%
%% - ?? file defaults (commandFile, commandFile) should be set in Init 
%%
%% - multiple-pages-plot is still missing (see my gnuplot.lisp)
%% 
%%
%% BUGS
%%
%% - proc Plot: gnuplot is blocked with "pause -1" (so the graph is shown for a while), this blocks Out.exec forever
%%
%% - proc Plot: additionalPsOut not working: outputs empty ps file
%%

functor  

import
   Browser(browse:Browse) % temp for debugging
   
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'

export
   Plot

define

   /** %% Generates script and data file for gnuplot and calls gnuplot with these files. Coordinates (i.e. x, y, and z) may be either a list of numbers (for a single plot) or a list of lists (for multiple plots) -- the nesting of all lists must be the same. Specifying z results in a 3D plot.
   %% The argument 'style' (sets the lines style) expects either a single VSs for all or a list of styles with a new value for every plot. The argument 'title' (sets the title for each) plot expects also either a single VSs for all or a list of styles with a new value for every plot. The argument 'set' expects a list of VSs describing arbitrary additional settings to gnuplot (without the leading 'set'). The argument dataFile gives the beginning of the data file names (every plot is written to an own data file). commandFile is the name of the command file. The arg additionalPsOut expects a string to which a postscript file of the plot is saved.
   %% */
   proc {Plot Y Args}
      Defaults = unit(x:nil
		      z:nil
		      style:linespoints
		      set:nil
		      title:nil
%		      additional-ps-out:unit
		      %% tmp settings -- use Init..
		      dataFile: "/tmp/gnuplot_daten"
		      commandFile: "/tmp/gnuplot_command"
		      additionalPsOut: nil
		     )
      As = {Adjoin Defaults Args}
      %%
      %% generate settings
      PlotCmd = if As.z == nil then plot else splot end % 2D or 3D
      DataFiles = for D in {CombineCoordinates As.x Y As.z}
		     I in 1;I+1
		     collect:C
		  do {C {WriteToFile2 {MakeLines D}
			 As.dataFile#I}}
		  end
      L = {Length DataFiles}
      Titles = if As.title==nil
	       then for I in 1..L
		     collect:C
		    do {C data#I}
		    end
	       else {Listify As.title L}
	       end
      Styles = {Listify As.style L}
      Plots = {Map {LUtils.matTrans [DataFiles Titles Styles]}
	       fun {$ [Data Title Style]}
		  " '"#Data#"' title '"#Title#"' with "#Style
	       end}
      Settings = {Out.listToLines {Map As.set fun {$ X} "set "#X#"\n" end}}      
   in
      %% !! quick hack: gnuplot is blocked with "pause -1", this
      %% blocks Out.exec forever
      thread 			% avoid blocking because of Out.exec with never ending command
	 {Out.writeToFile
	  Settings#PlotCmd#{Out.listToVS Plots ", "}#"; pause -1 'Hit return to continue'" 
	  As.commandFile}
%      {Out.exec xterm ["-e" "gnuplot "#As.commandFile "\&"]}
	 {Out.exec gnuplot [As.commandFile "\&"]}
      end
      %%
      %% quick hack
      if As.additionalPsOut \= nil 
      then
	 Settings2 = "set output '"#As.additionalPsOut#"' set terminal postscript"#Settings
	 CommandFile2 = As.commandFile#2
      in
	 {Out.writeToFile Settings2#PlotCmd#{Out.listToVS Plots ", "}
	  CommandFile2}
	 {Out.exec gnuplot [CommandFile2 "\&"]}
      end
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% utils
%%%

   /** %% Writes each coordinate in its own column.
   %% */
   %% (Data is result of CombineCoordinates, i.e. a list of of lists of lists)
   fun {MakeLines Data}
      {Out.listToLines
       {Map Data
	fun {$ Line}
	   {Out.listToVS Line [&\t]}
	end}}
   end

   /** %% Combines the lists (or list of lists) of X (and possibly Y and Z) coordinates into a list of the form [[[X1 Y1 Z1] ...] <coors for second plot> ...]. Both X or Z may be nil.
   %% */
   fun {CombineCoordinates X Y Z}
      fun {Prepare Args} {LUtils.remove Args fun {$ Xs} Xs==nil end} end
   in
      if Z\=nil andthen Y==nil
      then {GUtils.errorGUI "Z can not be given without X"} % Y is always compulsary
      end
      %%
      if {IsList Y.1}		% checks only first element!!
      then {Map {LUtils.matTrans {Prepare [X Y Z]}} LUtils.matTrans}
      else [{LUtils.matTrans {Prepare [X Y Z]}}]
      end
   end

% (combine-coordinates '(1 2 3) NIL NIL)
% (combine-coordinates '(1 2 3) '(a b c) NIL)
% (combine-coordinates '((1 2 3) (5 6 7)) '((a b c) (x y z)) NIL)

   /** %% Writes VS to Path and returns Path.
   %% */
   fun {WriteToFile2 VS Path}
      % {Browse WriteToFile2#VS}
      {Out.writeToFile VS Path}
      Path
   end

   /** %% If X is a list then return X, otherwise return a list consisting of L occurences of X. 
   %% */
   fun {Listify X L}
      if {IsList X} then X
      else {Map {MakeList L} fun {$ _} X end} 
      end
   end
   
end

