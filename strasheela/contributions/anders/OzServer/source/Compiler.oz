
%%% *************************************************************
%%% Copyright (C) 2006 Torsten Anders (t.anders@qub.ac.uk) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************


%% NB: Queries are processed concurrently (see MakeCompiler). Still, results are writting 'back' into socket in the order their corresponding expressions were fed, even if the result for an expression fed later is computed earlier already. Therefore, a port must ensure the order of the expression results (see FeedAllInput and CallCompiler).

functor
import

   %%
   %% this functor pretty much needs all variables available in the OPI
   %%

   %% vars essential for functionality of code below 
   Compiler CompilerPanel OS System Application

   Browser(browse:Browse)
   Inspector(inspect:Inspect)
   
   OPIEnv at 'x-oz://system/OPIEnv.ozf'

   
   %% some convenient vars depend on other functors    
   Path at 'x-oz://system/os/Path.ozf'  
   Socket at 'Socket.ozf' 

   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   
export
   MakeFullCompiler
   FeedAllInput

   %% for testing
%   MakeCompiler GetHeader CallCompiler
   
define
   
   local 
      CompilerEnvironment = {Adjoin OPIEnv.full
			     env(% 'Debug': Debug
				 'Path': Path 
				)}
      /** %% [Aux] Returns a new compiler MyCompiler with the (additional) environment Env (see compiler doc for the format) and feeding InitFile (a VS) if it is not set to nil.
      %% As a convenient interface, a GUI CompilerPanel for MyCompiler is created. 
      %% */
      %% this is an greatly edited/simplified version of Compiler.evalExpression (cf. oz/doc/compiler/node4.html) -- see that for possible extensions like killing the compiler etc.
      proc {MakeCompiler Env InitFile ?MyCompiler} % later extra arg: ?Kill 
	 MyCompiler = {New Compiler.engine init()}
	 %% ?? later, GUI interface should be opend only conditionally, and alternatively everything is printed on standard out and error out
	 _/*MyPanel*/ = {New CompilerPanel.'class' init(MyCompiler)}
	 {MyCompiler enqueue(mergeEnv(Env))}
	 %% NB: queries are processed concurrently
	 {MyCompiler enqueue(setSwitch(threadedqueries true))}
	 %%
	 if InitFile \= nil
	 then {MyCompiler enqueue(feedFile(InitFile))}
	 end
      end
   in
      /** %% Returns a new compiler with the full environment (comparable to the OPI) and fed the ozrc file according conventions (cf. oz/doc/opi/node4.html).
      %% */
      fun {MakeFullCompiler}
	 %% !! tmp: last slash: weirdness of Path.exists
	 InitFile = if {OS.getEnv 'OZRC'} \= false
		    then {OS.getEnv 'OZRC'}
		    elseif {Path.exists {OS.getEnv 'HOME'}#'/.oz/ozrc'#'/'}
		    then {OS.getEnv 'HOME'}#'/.oz/ozrc'
		    elseif {Path.exists {OS.getEnv 'HOME'}#'/.ozrc'#'/'}
		    then {OS.getEnv 'HOME'}#'/.ozrc'
		    else nil
		    end
      in
	 %% this defines almost every var which is defined in OPI (ommited vars are commented): 
%       {Out.writeToFile {Out.listToVS {Map {Arity {OPI.compiler enqueue(getEnv($))}}
% 				fun {$ X} "'"#X#"': "#X end}
% 		  "\n"}
%        "/tmp/Env.txt"}
	 {MakeCompiler CompilerEnvironment InitFile}
      end
   end
   
   local 
      /** %% [Aux] Returns the first line of MyString (i.e. the string before \n)
      %% */
      proc {GetLine MyString ?FirstLine}
	 {String.token MyString &\n ?FirstLine _}
      end
      proc {GetCodeAfterDirective MyString ?MyCode}
	 {String.token MyString &\n _ ?MyCode}
      end
      /** %% [Aux] If the Code-String starts with a 'header' of the form "%!"<header>"\n", return <header> and nil otherwise (i.e. <header> should never be nil)
      %% */
      fun {GetDirective Code}
	 if Code.1==&% andthen Code.2.1==&! 
	 then
	    {GetLine Code.2.2}
	    %% ?? Generalisation: remove whitespace
	 % {Filter {GetLine Code.2.2} Char.isSpace}
	 else nil
	 end
      end
      /** %% Feeds MyCompiler Input (Input is next string from InSocket) and optionally writes a result in socket (via ResultsPort).
      %% The header convention (used, e.g., to switch into 'expression-mode') is explained in top-level functor.
      %% */
      proc {CallCompiler MyCompiler MyServer Input ResultsPort} 
	 Directive = {GetDirective Input}
      in
	 if Directive==nil orelse Directive== "statement"
	 then
	    {MyCompiler enqueue(feedVirtualString(Input))}
	 elseif Directive=="expression"
	 then Result in
	    {MyCompiler enqueue(setSwitch(expression true))}
	    {MyCompiler enqueue(feedVirtualString(Input return(result: ?Result)))}
	    {Wait Result}
	    {Send ResultsPort Result}
	    {MyCompiler enqueue(setSwitch(expression false))}
	 elseif Directive=="browse"
	 then Result in
	    {MyCompiler enqueue(setSwitch(expression true))}
	    {MyCompiler enqueue(feedVirtualString(Input return(result: ?Result)))}
	    {Wait Result}
	    {Browse ?Result}
	    {MyCompiler enqueue(setSwitch(expression false))}
	 elseif Directive=="inspect"
	 then Result in
	    {MyCompiler enqueue(setSwitch(expression true))}
	    {MyCompiler enqueue(feedVirtualString(Input return(result: ?Result)))}
	    {Wait Result}
	    {Inspect ?Result}
	    {MyCompiler enqueue(setSwitch(expression false))}
	 elseif Directive=="file"
	 then {MyCompiler enqueue(feedFile({GetCodeAfterDirective Input}))}
	 elseif Directive=="quit"
	 then
	    {MyServer close} % close sockets
	    {System.showInfo "% OzServer quits"}
	    {Application.exit 0}
	 else raise illFormedExpr(Directive) end
	 end
      end   
   in
      /** %% FeedAllInput reads code sends from MyClient (a socket) and feeds them to MyCompiler. Socket input uses the format <code>["%!"<DIRECTIVE>\n]&lt;CODE&gt;</code>, as explained in top-level doc. Expression results are writting back into the socket (in the order their corresponding expressions were fed).
      %% Args is record with features size and resultFormat.
      %% */ 
      proc {FeedAllInput MyCompiler MyServer MyClient Args}
	 Results
	 ResultsPort = {NewPort Results}
      in 
	 thread 
	    {ForAll {Socket.readToStream MyClient Args.size}
	     proc {$ Input}
		{CallCompiler MyCompiler MyServer Input ResultsPort}
	     end}
	 end
	 thread
	    {ForAll Results
	     proc {$ Result}
		{Socket.write MyClient
		 {TransformResult Result Args.resultFormat}}
	     end}
	 end
      end

      /** %% Transforms result into a different syntax. Each output usually ends with an (added) newline in order to ensures that the parser (e.g. the Lisp reader) recognises a complete value. 
      %% */
      fun {TransformResult Result ResultFormat}
	 case ResultFormat
	 of
	    oz then {Wait Result} {Out.recordToVS Result}#"\n"
%	    oz then {Wait Result} {Value.toVirtualString Result 100000 100000}#"\n"
	 [] lisp then {Out.ozToLisp Result
		       unit(charTransform:false
			    stringTransform:false)}#"\n"
	 [] lispWithStrings then {Out.ozToLisp Result
				  unit(charTransform:true
				       stringTransform:true)}#"\n"
	 end
      end
      
   end
   
end

