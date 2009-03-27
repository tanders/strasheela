
/** %% Provides score search support for the IOzSeF constraint solvers (http://www.mozart-oz.org/mogul/doc/tack/iozsef/iozsef.html). First install IOzSeF as described in the Strasheela installation instructions.  
%% */

functor
import
   Browser(browse:Browse)
   IOzSeF at 'x-ozlib://tack/iozsef/iozsef.ozf'
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   SDistro at 'x-ozlib://anders/strasheela/source/ScoreDistribution.ozf'
   ScoreInspector at 'x-ozlib://anders/strasheela/ScoreInspector/ScoreInspector.ozf'
   
export
   init: IozsefInit initBest: IozsefInitBest
   exploreOne: IozsefExploreOne exploreAll: IozsefExploreAll exploreBest: IozsefExploreBest
   searchOne: IozsefSearchOne searchAll: IozsefSearchAll searchBest: IozsefSearchBest

   AddIOzSeFOuts
   
define

   proc {IozsefInit ScoreScript Args}
      {IOzSeF.init {SDistro.makeSearchScript ScoreScript Args}}
   end
   /** %% Calls IOzSeF.init/IOzSeF.initBest with a script created by SDistro.makeSearchScript. It opens the IOzSeF 'Explorer' without starting any search. Best solution is performed with respect to OrderP (a binary procedure).  This variant of the Explorer provides additional features (e.g., support for more forms of recomputation, and various search strategies). It requires an installation of IOzSeF, see http://www.mozart-oz.org/mogul/doc/tack/iozsef/iozsef.html. The meaning of the arguments are the same as for SDistro.makeSearchScript.
   %%
   %% Please see the IOzSeF documentation for more information. Note the following procedures 
   %% - IOzSeF.getSolutions: Returns the solutions found so far during interactive exploration
   %% - IOzSeF.cancelExploration: Cancels the current interactive exploration.
   %% */
   %%
   proc {IozsefInitBest ScoreScript OrderP Args}
      {IOzSeF.initBest {SDistro.makeSearchScript ScoreScript Args} OrderP}
   end
   
   proc {IozsefExploreOne ScoreScript Args}
      {IOzSeF.exploreOne {SDistro.makeSearchScript ScoreScript Args}}
   end
   proc {IozsefExploreAll ScoreScript Args}
      {IOzSeF.exploreAll {SDistro.makeSearchScript ScoreScript Args}}
   end
   /** %% Calls IOzSeF.exploreOne/IOzSeF.exploreAll/IOzSeF.exploreBest with a script created by SDistro.makeSearchScript. Best solution is performed with respect to OrderP (a binary procedure). This variant of the Explorer provides additional features (e.g., support for more forms of recomputation, and various search strategies). It requires an installation of IOzSeF, see http://www.mozart-oz.org/mogul/doc/tack/iozsef/iozsef.html. The meaning of the arguments are the same as for SDistro.makeSearchScript.
   %%
   %% Please see the IOzSeF documentation for more information. Note the following procedures 
   %% - IOzSeF.getSolutions: Returns the solutions found so far during interactive exploration
   %% - IOzSeF.cancelExploration: Cancels the current interactive exploration.
   %% */
   proc {IozsefExploreBest ScoreScript OrderP Args}
      {IOzSeF.exploreBest {SDistro.makeSearchScript ScoreScript Args} OrderP}
   end
   
   proc {IozsefSearchOne ScoreScript Args}
      {IOzSeF.searchOne {SDistro.makeSearchScript ScoreScript Args}}
   end
   proc {IozsefSearchAll ScoreScript Args}
      {IOzSeF.searchAll {SDistro.makeSearchScript ScoreScript Args}}
   end
   /** %% Calls IOzSeF.searchOne/IOzSeF.searchAll/IOzSeF.searchBest with a script created by SDistro.makeSearchScript. Best solution is performed with respect to OrderP (a binary procedure). It requires an installation of IOzSeF, see http://www.mozart-oz.org/mogul/doc/tack/iozsef/iozsef.html. The meaning of the arguments are the same as for SDistro.makeSearchScript.
   %%
   %% Please see the IOzSeF documentation for more information. Note the following procedures 
   %% - IOzSeF.cancelSearch: Cancels the current non-interactive search.
   %% - IOzSeF.setOption(Key Value) sets options like explorationStrat (dfs,bdfs,id,lds), noOfSols (0,...), recompStrat (plain,fixed,adaptive), mrd (0,...)
   %% - IOzSeF.getTime
   %% */
   %% 
   %% NB: no kill proc is supported -- should I instead define my own solvers?
   %% NB: it appears only a single search can be executed at one time. This is sufficient for most cases, but why this restriction?
   proc {IozsefSearchBest ScoreScript OrderP Args}
      {IOzSeF.searchBest {SDistro.makeSearchScript ScoreScript Args} OrderP}
   end



   %%
   %% NOTE: this following defs are simply copied from source/Init.oz
   %%
         proc {ArchiveInitRecord I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.outputScoreConstructor X
	     unit(file: FileName)}
	 end
      end
      proc {BrowseInitRecord I X}
	 if {Score.isScoreObject X}
	 then {Browse {X toInitRecord($)}}
	 end
      end
      proc {ArchiveENPNonMensural I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.outputNonmensuralENP X
	     unit(file:FileName
		  getParts:fun {$ X}
			      if {X isSimultaneous($)}
			      then {X getItems($)}
			      else [X]
			      end
			   end
		  getVoices:fun {$ X} [X] end
		  %% !!?? do I need special care for multiple sim notes (forming a chord)?
		  getChords:fun {$ X} {X collect($ test:isNote)} end
		  getNotes:fun {$ X} [X] end)}
	 end
      end
      proc {ArchiveFomus I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.outputFomus X
	     unit(file: FileName)}
	 end
      end
      proc {RenderFomus I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.callFomus X
	     unit(file: FileName)}
	 end
      end
      proc {RenderCsound I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.renderAndPlayCsound X
	     unit(file: FileName
		  title:I)}
	 end
      end
      proc {RenderLilypond I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.renderAndShowLilypond X
	     unit(file: FileName#'-'#I)}
	 end
      end
      proc {RenderMidi I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.midi.renderAndPlayMidiFile X
	     unit(file:FileName#'-'#I)}
	 end
      end


   /** %% Extends the IOzSeF menu "Options -> Information Action" by a few entries to output scores into various formats just by clicking the solution nodes in the Explorer. This procedure adds standard output formats like Csound, Lilypond, and MIDI, as well as further formats like ENP and Fomus.
      %% */
      %% NOTE: implementation simply reuses defs for Explorer actions. There Explorer actions always expect number of Explorer node as argument. IOzSeF does not support this -- so this node nubmer argument is always 1 here. 
      proc {AddIOzSeFOuts}
	 %% Standard
	 {IOzSeF.addInformationAction 'Inspect Score (use score object context menu)' root
	  proc {$ X} {ScoreInspector.inspect X} end}
	 {IOzSeF.addInformationAction 'Browse initRecord' root
	  proc {$ X}  {BrowseInitRecord 1 X} end}
	 {IOzSeF.addInformationAction 'Archive initRecord' root
	  proc {$ X}  {ArchiveInitRecord 1 X} end}
	 {IOzSeF.addInformationAction 'to Csound' root
	  proc {$ X}  {RenderCsound 1 X} end}
	 {IOzSeF.addInformationAction 'to Lilypond' root
	  proc {$ X}  {RenderLilypond 1 X} end}
	 {IOzSeF.addInformationAction 'to Midi' root
	  proc {$ X}  {RenderMidi 1 X} end}
	 %% Extended
	 {IOzSeF.addInformationAction 'Archive ENPNonMensural' root
	  proc {$ X}  {ArchiveENPNonMensural 1 X} end}
	 {IOzSeF.addInformationAction 'Archive Fomus' root
	  proc {$ X}  {ArchiveFomus 1 X} end}
	 {IOzSeF.addInformationAction 'to Fomus' root
	  proc {$ X}  {RenderFomus 1 X} end}
      end
   
end



