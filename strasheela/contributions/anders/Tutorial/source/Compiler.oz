

functor

import
 
   %% !! tmp functor until next release with debugged Path of stdlib
   Path at 'x-ozlib://anders/tmp/Path/Path.ozf'

   OPIEnv at 'x-oz://system/OPIEnv.ozf'

   Compiler ErrorListener OS
      
   QTk at 'x-oz://system/wp/QTk.ozf'
   Debug at 'x-oz://boot/Debug'
   
   %% Strasheela core
   Strasheela at 'x-ozlib://anders/strasheela/Strasheela.ozf'
   %% Strasheela extensions
   CTT at 'x-ozlib://anders/strasheela/ConstrainTimingTree/ConstrainTimingTree.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   Motif at 'x-ozlib://anders/strasheela/Motif/Motif.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   Measure at 'x-ozlib://anders/strasheela/Measure/Measure.ozf'
   ScoreInspector at 'x-ozlib://anders/strasheela/ScoreInspector/ScoreInspector.ozf'
   
export

   MakeCompiler
   FeedStatement
   FeedExpression
   FeedInitFile
   
define

   /* %% Oz initialisation for any compiler created with MakeCompiler.
   %% */
   OZRC =
   "\\switch -threadedqueries
   {Init.addExplorerOuts_Standard}
   {Init.putStrasheelaEnv strasheelaFunctors env('Strasheela':Strasheela
						 'HS':HS
						 'Motif':Motif
						 'Measure':Measure
						 'CTT':CTT
						 'Pattern':Pattern)}
   \\switch +threadedqueries" 
   
   CompilerEnvironment = {Adjoin OPIEnv.full
			  env('QTk': QTk
			     'Debug': Debug 
			      'Path': Path % use my Path fixes
			      'Inspect':ScoreInspector.inspect
			      'Inspector': ScoreInspector
			     %% Strasheela core
			     'Strasheela':Strasheela
			     'Init': Strasheela.init
			     'GUtils':Strasheela.gUtils
			     'LUtils':Strasheela.lUtils
			     'MUtils':Strasheela.mUtils
			     'Score':Strasheela.score
			     'SDistro': Strasheela.sDistro
			     'Out':Strasheela.out
			     %% Strasheela extensions 
			     'Pattern':Pattern
			     'CTT':CTT
			     'Motif':Motif
			     'HS':HS
			     'Measure':Measure
			     )}
   
%    proc {WatchCompiler MyInterface}
%       {MyInterface sync()} % waits until the compiler engine becomes idle.
%       if {MyInterface hasErrors($)}
%       then Ms = {MyInterface getMessages($)}
%       in
% %	 {Browse error(compiler(evalExpression VS Ms))}
% 	 %% offending code missing! 
% 	 {Browse error(compiler(evalExpression myVS Ms))}
% 	 {WatchCompiler MyInterface}
%       else
% 	 {WatchCompiler MyInterface}
%       end 
%    end

   /** %% Returns a new compiler with the full environment (comparable to the OPI + Strasheela). 
   %% */
   %% The nullary procedure Kill interrupts the compiler. 
   proc {MakeCompiler ?MyCompiler /*?Kill*/}
%      MyInterface
%   in 
      MyCompiler = {New Compiler.engine init()}
%      MyInterface = {New Compiler.interface init(MyCompiler)}
%      _/*MyPanel*/ = {New CompilerPanel.'class' init(MyCompiler)}
%      _/*MyPanel*/ = {New CompilerPanel.'class' init(MyCompiler /*IconifiedB:*/true)}
      %% prints error messages to standard error (only reports static analysis errors, but runtime errors are not catched)
      _/*MyErrorListener*/ = {New ErrorListener.'class' init(MyCompiler unit auto)}
      {MyCompiler enqueue(mergeEnv(CompilerEnvironment))}
      %% NB: queries are processed concurrently
      {MyCompiler enqueue(setSwitch(threadedqueries true))}
      %%
      %% new stuff..
      %%
%      {WatchCompiler MyInterface}
      {FeedStatement OZRC MyCompiler}
   end

   local
      /** %% Returns ozrc file according conventions (cf. oz/doc/opi/node4.html).
      %% */ 
      fun {GetInitFile}      
	 if {OS.getEnv 'OZRC'} \= false
	 then {OS.getEnv 'OZRC'}
	 elseif {Path.exists {OS.getEnv 'HOME'}#'/.oz/ozrc'}
	 then {OS.getEnv 'HOME'}#'/.oz/ozrc'
	 elseif {Path.exists {OS.getEnv 'HOME'}#'/.ozrc'}
	 then {OS.getEnv 'HOME'}#'/.ozrc'
	 else nil
	 end
      end
   in
      /** %% Feeds OZRC file to MyCompiler. The OZRC is search for at the usual places according conventions (cf. oz/doc/opi/node4.html).
      %% */ 
      proc {FeedInitFile MyCompiler}
	 InitFile = {GetInitFile}
      in
	 if InitFile \= nil
	 then {MyCompiler enqueue(feedFile(InitFile))}
	 end
      end
   end

   /** %% Feeds statement MyCode (VS) to MyCompiler. 
   %% */
   proc {FeedStatement MyCode MyCompiler}
      {MyCompiler enqueue(setSwitch(expression false))}
      {MyCompiler enqueue(feedVirtualString(MyCode))}
   end

   /** %% Feeds expression MyCode (VS) to MyCompiler and returns Result.
   %% */ 
   proc {FeedExpression MyCode MyCompiler ?Result}
      {MyCompiler enqueue(setSwitch(expression true))}
      {MyCompiler enqueue(feedVirtualString(MyCode return(result: ?Result)))}
   end
   
end
