
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

   %% vars imported to build compiler environment 
   %%
   %% vars defined by their on OZ/source/<FunctorName>.oz file 
   % Compiler OS % already imported 
%    Application Browser Combinator Connection DistributionPanel DPControl DPInit DPStatistics DefaultURL Discovery  Emacs Error ErrorListener ErrorRegistry EvalDialog Explorer FD FS Fault Finalize Gump GumpParser GumpScanner Inspector Listener Macro Module Narrator OPI OPIEnv OPIServer ObjectSupport Open OsTime Ozcar OzcarClient Panel Pickle Profiler Property RecordC Remote Resolve Schedule Search Service Space System Tix Tk TkTools Type URL VirtualSite   
   
   %% only for completeness:
   %% 
   %% vars not defined by their own file, but still these vars are available anyway..
   % Lock Loop BitArray ByteString Char Array Unit List Number Exception Time Value Float Atom Functor Class WeakDictionary SiteProperty Literal Tuple Cell Thread Object VirtualString Chunk String Int Procedure Port BitString ForeignPointer Dictionary Name Record Bool
   
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
   
%    Browse = Browser.browse
%    Inspect = Inspector.inspect
   
   local 
%       %% vars depending on other functors (i.e. not defined by their own file)
%       %%
%       %% procs
%       % Browse and Inspect were already defined above
%       ExploreAll = Explorer.all
%       ExploreBest = Explorer.best
%       ExploreOne = Explorer.one
%       SearchAll = Search.base.all
%       SearchBest = Search.base.best
%       SearchOne = Search.base.one
%       Print = System.print
%       Show = System.show
%       Load = Pickle.load
%       Save = Pickle.save
%       Apply = Module.apply
%       Link = Module.link
%       %% class/object 
%       BaseObject = Object.base 
%       %% 
%       CompilerEnvironment = env('Abs': Abs
% 				'Access': Access
% 				'Acos': Acos
% 				'Adjoin': Adjoin
% 				'AdjoinAt': AdjoinAt
% 				'AdjoinList': AdjoinList
% 				'Alarm': Alarm
% 				'All': All
% 				'AllTail': AllTail
% 				'And': And
% 				'Append': Append
% 				'Application': Application
% 				'Apply': Apply
% 				'Arity': Arity
% 				'Array': Array
% 				'Asin': Asin
% 				'Assign': Assign
% 				'Atan': Atan
% 				'Atan2': Atan2
% 				'Atom': Atom
% 				'AtomToString': AtomToString
% 				'BaseObject': BaseObject
% 				'BitArray': BitArray
% 				'BitString': BitString
% 				'Bool': Bool
% 				'Browse': Browse
% 				'Browser': Browser
% 				'ByNeed': ByNeed
% 				'ByNeedFuture': ByNeedFuture
% 				'ByteString': ByteString
% 				'Ceil': Ceil
% 				'Cell': Cell
% 				'Char': Char
% 				'Chunk': Chunk
% 				'Class': Class
% 				'Combinator': Combinator
% 				'Compiler': Compiler
% 				'CompilerPanel': CompilerPanel
% 				'CondSelect': CondSelect
% 				'Connection': Connection
% 				'Cos': Cos
% 				'DPControl': DPControl
% 				'DPInit': DPInit
% 				'DPStatistics': DPStatistics
% 				'DefaultURL': DefaultURL
% 				'Delay': Delay
% 				'Dictionary': Dictionary
% 				'Discovery': Discovery
% 				'DistributionPanel': DistributionPanel
% 				'Emacs': Emacs
% 				'Error': Error
% 				'ErrorListener': ErrorListener
% 				'ErrorRegistry': ErrorRegistry
% 				'EvalDialog': EvalDialog
% 				'Exception': Exception
% 				'Exchange': Exchange
% 				'Exp': Exp
% 				'ExploreAll': ExploreAll
% 				'ExploreBest': ExploreBest
% 				'ExploreOne': ExploreOne
% 				'Explorer': Explorer
% 				'FD': FD
% 				'FS': FS
% 				'Fault': Fault
% 				'Filter': Filter
% 				'Finalize': Finalize
% 				'Flatten': Flatten
% 				'Float': Float
% 				'FloatToInt': FloatToInt
% 				'FloatToString': FloatToString
% 				'Floor': Floor
% 				'FoldL': FoldL
% 				'FoldLTail': FoldLTail
% 				'FoldR': FoldR
% 				'FoldRTail': FoldRTail
% 				'For': For
% 				'ForAll': ForAll
% 				'ForAllTail': ForAllTail
% 				'ForThread': ForThread
% 				'ForeignPointer': ForeignPointer
% 				'Functor': Functor
% 				'Get': Get
% 				'Gump': Gump
% 				'GumpParser': GumpParser
% 				'GumpScanner': GumpScanner
% 				'HasFeature': HasFeature
% 				'Inspect': Inspect
% 				'Inspector': Inspector
% 				'Int': Int
% 				'IntToFloat': IntToFloat
% 				'IntToString': IntToString
% 				'IsArray': IsArray
% 				'IsAtom': IsAtom
% 				'IsBitArray': IsBitArray
% 				'IsBitString': IsBitString
% 				'IsBool': IsBool
% 				'IsByteString': IsByteString
% 				'IsCell': IsCell
% 				'IsChar': IsChar
% 				'IsChunk': IsChunk
% 				'IsClass': IsClass
% 				'IsDet': IsDet
% 				'IsDictionary': IsDictionary
% 				'IsEven': IsEven
% 				'IsFailed': IsFailed
% 				'IsFloat': IsFloat
% 				'IsForeignPointer': IsForeignPointer
% 				'IsFree': IsFree
% 				'IsFuture': IsFuture
% 				'IsInt': IsInt
% 				'IsKinded': IsKinded
% 				'IsList': IsList
% 				'IsLiteral': IsLiteral
% 				'IsLock': IsLock
% 				'IsName': IsName
% 				'IsNat': IsNat
% 				'IsNeeded': IsNeeded
% 				'IsNumber': IsNumber
% 				'IsObject': IsObject
% 				'IsOdd': IsOdd
% 				'IsPort': IsPort
% 				'IsProcedure': IsProcedure
% 				'IsRecord': IsRecord
% 				'IsString': IsString
% 				'IsThread': IsThread
% 				'IsTuple': IsTuple
% 				'IsUnit': IsUnit
% 				'IsVirtualString': IsVirtualString
% 				'IsWeakDictionary': IsWeakDictionary
% 				'Label': Label
% 				'Length': Length
% 				'Link': Link
% 				'List': List
% 				'Listener': Listener
% 				'Literal': Literal
% 				'Load': Load
% 				'Lock': Lock
% 				'Log': Log
% 				'Loop': Loop
% 				'Macro': Macro
% 				'MakeList': MakeList
% 				'MakeRecord': MakeRecord
% 				'MakeTuple': MakeTuple
% 				'Map': Map
% 				'Max': Max
% 				'Member': Member
% 				'Merge': Merge
% 				'Min': Min
% 				'Module': Module
% 				'Name': Name
% 				'Narrator': Narrator
% 				'New': New
% 				'NewArray': NewArray
% 				'NewCell': NewCell
% 				'NewChunk': NewChunk
% 				'NewDictionary': NewDictionary
% 				'NewLock': NewLock
% 				'NewName': NewName
% 				'NewPort': NewPort
% 				'NewWeakDictionary': NewWeakDictionary
% 				'Not': Not
% 				'Nth': Nth
% 				'Number': Number
% 				'OPI': OPI
% 				'OPIEnv': OPIEnv
% 				'OPIServer': OPIServer
% 				'OS': OS
% 				'Object': Object
% 				'ObjectSupport': ObjectSupport
% 				'Open': Open
% 				'Or': Or
% 				'OsTime': OsTime
% 				'Ozcar': Ozcar
% 				'OzcarClient': OzcarClient
% 				'Panel': Panel
% 				'Pickle': Pickle
% 				'Port': Port
% 				'Pow': Pow
% 				'Print': Print
% 				'Procedure': Procedure
% 				'ProcedureArity': ProcedureArity
% 				'Profiler': Profiler
% 				'Property': Property
% 				'Put': Put
% 				'Raise': Raise
% 				'Record': Record
% 				'RecordC': RecordC
% 				'Remote': Remote
% 				'Resolve': Resolve
% 				'Reverse': Reverse
% 				'Round': Round
% 				'Save': Save
% 				'Schedule': Schedule
% 				'Search': Search
% 				'SearchAll': SearchAll
% 				'SearchBest': SearchBest
% 				'SearchOne': SearchOne
% 				'Send': Send
% 				'Service': Service
% 				'Show': Show
% 				'Sin': Sin
% 				'SiteProperty': SiteProperty
% 				'Some': Some
% 				'Sort': Sort
% 				'Space': Space
% 				'Sqrt': Sqrt
% 				'String': String
% 				'StringToAtom': StringToAtom
% 				'StringToFloat': StringToFloat
% 				'StringToInt': StringToInt
% 				'System': System
% 				'Tan': Tan
% 				'Thread': Thread
% 				'Time': Time
% 				'Tix': Tix
% 				'Tk': Tk
% 				'TkTools': TkTools
% 				'Tuple': Tuple
% 				'Type': Type
% 				'URL': URL
% 				'Unit': Unit
% 				'Value': Value
% 				'VirtualSite': VirtualSite
% 				'VirtualString': VirtualString
% 				'Wait': Wait
% 				'WaitNeeded': WaitNeeded
% 				'WaitOr': WaitOr
% 				'WeakDictionary': WeakDictionary
% 				'Width': Width
% 				%%	   
% 				%% Strasheela stuff
% 				%%'StrasheelaDemos':StrasheelaDemos
% 	   %'Init':Init 'GUtils':GUtils 'LUtils':LUtils 'MUtils':MUtils
% 	   %'Score':Score 'Pattern':Pattern 'SDistro':SDistro 'Out':Out
% 			       )

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
      proc {CallCompiler MyCompiler Input ResultsPort} 
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
	    {System.showInfo "% OzServer quits"}
	    {Application.exit 0}
	 else raise illFormedExpr(Directive) end
	 end
      end   
   in
      /** %% FeedAllInput reads code sends from MySocket and feeds them to MyCompiler. Socket input uses the format <code>["%!"<DIRECTIVE>\n]&lt;CODE&gt;</code>, as explained in top-level doc. Expression results are writting back into the socket (in the order their corresponding expressions were fed).
      %% Args is record with features size and resultFormat.
      %% */ 
      proc {FeedAllInput MyCompiler MySocket Args}
	 Results
	 ResultsPort = {NewPort Results}
      in 
	 thread 
	    {ForAll {Socket.readToStream MySocket Args.size}
	     proc {$ Input}
		{CallCompiler MyCompiler Input ResultsPort}
	     end}
	 end
	 thread
	    {ForAll Results
	     proc {$ Result}
		{Socket.write MySocket
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

