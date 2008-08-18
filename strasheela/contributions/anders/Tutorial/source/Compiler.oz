

functor

import
 
   %% !! tmp functor until next release with debugged Path of stdlib
   Path at 'x-ozlib://anders/tmp/Path/Path.ozf'

   OPIEnv at 'x-oz://system/OPIEnv.ozf'

   Compiler ErrorListener OS
   
   %% General Oz stuff (load into environment of compiler)
   %% TODO: replace by OPIEnv.full: 
   %% x-oz://system/OPIEnv.ozf' conveniently exports the full environment as "OPIEnv.full".
%    Compiler Open OS System Application Error
%    Browser Combinator CompilerPanel Connection DistributionPanel DPControl DPInit DPStatistics DefaultURL Discovery  Emacs ErrorListener ErrorRegistry EvalDialog Explorer FD FS Fault Finalize Gump GumpParser GumpScanner Listener Macro Module Narrator OPI OPIEnv OPIServer ObjectSupport OsTime Ozcar OzcarClient Panel Pickle Profiler Property RecordC Remote Resolve Schedule Search Service Space Tix Tk TkTools Type URL VirtualSite
   % Inspector
   
%    QTk at 'x-oz://system/wp/QTk.ozf'
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
   
%    %% CompilerEnvironment copied from OzCompiler..   
%    Browse = Browser.browse
%    ScoreInspect = ScoreInspector.inspect 
%    %%
%    ExploreAll = Explorer.all
%    ExploreBest = Explorer.best
%    ExploreOne = Explorer.one
%    SearchAll = Search.base.all
%    SearchBest = Search.base.best
%    SearchOne = Search.base.one
%    Print = System.print
%    Show = System.show
%    Load = Pickle.load
%    Save = Pickle.save
%    Apply = Module.apply
%    Link = Module.link
%    %% class/object 
%    BaseObject = Object.base

%    %% Strasheela variables
%    Init = Strasheela.init
%    GUtils = Strasheela.gUtils
%    LUtils = Strasheela.lUtils
%    MUtils = Strasheela.mUtils
%    Score = Strasheela.score
% %   SMapping = Strasheela.sMapping
%    SDistro = Strasheela.sDistro
%    Out = Strasheela.out

   CompilerEnvironment = {Adjoin OPIEnv.full
			  env('Debug': Debug 
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
   
%    %% TODO: replace by OPIEnv.full: 
%    %% x-oz://system/OPIEnv.ozf' conveniently exports the full environment as "OPIEnv.full".
%    CompilerEnvironment = env('Abs': Abs
% 			     'Access': Access
% 			     'Acos': Acos
% 			     'Adjoin': Adjoin
% 			     'AdjoinAt': AdjoinAt
% 			     'AdjoinList': AdjoinList
% 			     'Alarm': Alarm
% 			     'All': All
% 			     'AllTail': AllTail
% 			     'And': And
% 			     'Append': Append
% 			     'Application': Application
% 			     'Apply': Apply
% 			     'Arity': Arity
% 			     'Array': Array
% 			     'Asin': Asin
% 			     'Assign': Assign
% 			     'Atan': Atan
% 			     'Atan2': Atan2
% 			     'Atom': Atom
% 			     'AtomToString': AtomToString
% 			     'BaseObject': BaseObject
% 			     'BitArray': BitArray
% 			     'BitString': BitString
% 			     'Bool': Bool
% 			     'Browse': Browse
% 			     'Browser': Browser
% 			     'ByNeed': ByNeed
% 			     'ByNeedFuture': ByNeedFuture
% 			     'ByteString': ByteString
% 			     'Ceil': Ceil
% 			     'Cell': Cell
% 			     'Char': Char
% 			     'Chunk': Chunk
% 			     'Class': Class
% 			     'Combinator': Combinator
% 			     'Compiler': Compiler
% 			     'CompilerPanel': CompilerPanel
% 			     'CondSelect': CondSelect
% 			     'Connection': Connection
% 			     'Cos': Cos
% 			     'DPControl': DPControl
% 			     'DPInit': DPInit
% 			     'DPStatistics': DPStatistics
% 			     'DefaultURL': DefaultURL
% 			     'Delay': Delay
% 			     'Dictionary': Dictionary
% 			     'Discovery': Discovery
% 			     'DistributionPanel': DistributionPanel
% 			     'Emacs': Emacs
% 			     'Error': Error
% 			     'ErrorListener': ErrorListener
% 			     'ErrorRegistry': ErrorRegistry
% 			     'EvalDialog': EvalDialog
% 			     'Exception': Exception
% 			     'Exchange': Exchange
% 			     'Exp': Exp
% 			     'ExploreAll': ExploreAll
% 			     'ExploreBest': ExploreBest
% 			     'ExploreOne': ExploreOne
% 			     'Explorer': Explorer
% 			     'FD': FD
% 			     'FS': FS
% 			     'Fault': Fault
% 			     'Filter': Filter
% 			     'Finalize': Finalize
% 			     'Flatten': Flatten
% 			     'Float': Float
% 			     'FloatToInt': FloatToInt
% 			     'FloatToString': FloatToString
% 			     'Floor': Floor
% 			     'FoldL': FoldL
% 			     'FoldLTail': FoldLTail
% 			     'FoldR': FoldR
% 			     'FoldRTail': FoldRTail
% 			     'For': For
% 			     'ForAll': ForAll
% 			     'ForAllTail': ForAllTail
% 			     'ForThread': ForThread
% 			     'ForeignPointer': ForeignPointer
% 			     'Functor': Functor
% 			     'Get': Get
% 			     'Gump': Gump
% 			     'GumpParser': GumpParser
% 			     'GumpScanner': GumpScanner
% 			     'HasFeature': HasFeature
% 			     'Inspect': ScoreInspect
% 			     'Inspector': ScoreInspector
% 			     'Int': Int
% 			     'IntToFloat': IntToFloat
% 			     'IntToString': IntToString
% 			     'IsArray': IsArray
% 			     'IsAtom': IsAtom
% 			     'IsBitArray': IsBitArray
% 			     'IsBitString': IsBitString
% 			     'IsBool': IsBool
% 			     'IsByteString': IsByteString
% 			     'IsCell': IsCell
% 			     'IsChar': IsChar
% 			     'IsChunk': IsChunk
% 			     'IsClass': IsClass
% 			     'IsDet': IsDet
% 			     'IsDictionary': IsDictionary
% 			     'IsEven': IsEven
% 			     'IsFailed': IsFailed
% 			     'IsFloat': IsFloat
% 			     'IsForeignPointer': IsForeignPointer
% 			     'IsFree': IsFree
% 			     'IsFuture': IsFuture
% 			     'IsInt': IsInt
% 			     'IsKinded': IsKinded
% 			     'IsList': IsList
% 			     'IsLiteral': IsLiteral
% 			     'IsLock': IsLock
% 			     'IsName': IsName
% 			     'IsNat': IsNat
% 			     'IsNeeded': IsNeeded
% 			     'IsNumber': IsNumber
% 			     'IsObject': IsObject
% 			     'IsOdd': IsOdd
% 			     'IsPort': IsPort
% 			     'IsProcedure': IsProcedure
% 			     'IsRecord': IsRecord
% 			     'IsString': IsString
% 			     'IsThread': IsThread
% 			     'IsTuple': IsTuple
% 			     'IsUnit': IsUnit
% 			     'IsVirtualString': IsVirtualString
% 			     'IsWeakDictionary': IsWeakDictionary
% 			     'Label': Label
% 			     'Length': Length
% 			     'Link': Link
% 			     'List': List
% 			     'Listener': Listener
% 			     'Literal': Literal
% 			     'Load': Load
% 			     'Lock': Lock
% 			     'Log': Log
% 			     'Loop': Loop
% 			     'Macro': Macro
% 			     'MakeList': MakeList
% 			     'MakeRecord': MakeRecord
% 			     'MakeTuple': MakeTuple
% 			     'Map': Map
% 			     'Max': Max
% 			     'Member': Member
% 			     'Merge': Merge
% 			     'Min': Min
% 			     'Module': Module
% 			     'Name': Name
% 			     'Narrator': Narrator
% 			     'New': New
% 			     'NewArray': NewArray
% 			     'NewCell': NewCell
% 			     'NewChunk': NewChunk
% 			     'NewDictionary': NewDictionary
% 			     'NewLock': NewLock
% 			     'NewName': NewName
% 			     'NewPort': NewPort
% 			     'NewWeakDictionary': NewWeakDictionary
% 			     'Not': Not
% 			     'Nth': Nth
% 			     'Number': Number
% 			     'OPI': OPI
% 			     'OPIEnv': OPIEnv
% 			     'OPIServer': OPIServer
% 			     'OS': OS
% 			     'Object': Object
% 			     'ObjectSupport': ObjectSupport
% 			     'Open': Open
% 			     'Or': Or
% 			     'OsTime': OsTime
% 			     'Ozcar': Ozcar
% 			     'OzcarClient': OzcarClient
% 			     'Panel': Panel
% 			     'Pickle': Pickle
% 			     'Port': Port
% 			     'Pow': Pow
% 			     'Print': Print
% 			     'Procedure': Procedure
% 			     'ProcedureArity': ProcedureArity
% 			     'Profiler': Profiler
% 			     'Property': Property
% 			     'Put': Put
% 			     'QTk': QTk
% 			     'Raise': Raise
% 			     'Record': Record
% 			     'RecordC': RecordC
% 			     'Remote': Remote
% 			     'Resolve': Resolve
% 			     'Reverse': Reverse
% 			     'Round': Round
% 			     'Save': Save
% 			     'Schedule': Schedule
% 			     'Search': Search
% 			     'SearchAll': SearchAll
% 			     'SearchBest': SearchBest
% 			     'SearchOne': SearchOne
% 			     'Send': Send
% 			     'Service': Service
% 			     'Show': Show
% 			     'Sin': Sin
% 			     'SiteProperty': SiteProperty
% 			     'Some': Some
% 			     'Sort': Sort
% 			     'Space': Space
% 			     'Sqrt': Sqrt
% 			     'String': String
% 			     'StringToAtom': StringToAtom
% 			     'StringToFloat': StringToFloat
% 			     'StringToInt': StringToInt
% 			     'System': System
% 			     'Tan': Tan
% 			     'Thread': Thread
% 			     'Time': Time
% 			     'Tix': Tix
% 			     'Tk': Tk
% 			     'TkTools': TkTools
% 			     'Tuple': Tuple
% 			     'Type': Type
% 			     'URL': URL
% 			     'Unit': Unit
% 			     'Value': Value
% 			     'VirtualSite': VirtualSite
% 			     'VirtualString': VirtualString
% 			     'Wait': Wait
% 			     'WaitNeeded': WaitNeeded
% 			     'WaitOr': WaitOr
% 			     'WeakDictionary': WeakDictionary
% 			     'Width': Width
% 			     %% add-ons
% 			     'Debug': Debug
% 			     %% Strasheela core
% 			     'Strasheela':Strasheela
% 			     'Init':Init 'GUtils':GUtils 'LUtils':LUtils 'MUtils':MUtils
% 			     'Score':Score 'SDistro':SDistro 'Out':Out
% 			     %% Strasheela extensions 
% 			     'Pattern':Pattern 'CTT':CTT 'Motif':Motif
% 			     'HS':HS 'Measure':Measure
% 			    )

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
