
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

/** %% Functor defines means for output, e.g. means to output a Strasheela score to a csound score and play the result.
% */

%% TODO:
%%
%% * Many formats output nothing at all if some part of the score is undetermined. Instead, output all events etc. which are already determined (and possibly a warning).  
%%
%% OK? * add Fomus output (http://common-lisp.net/project/fomus/)
%%
%% * add GUI for output settings (cf. Common Music GUI CMIO, http://commonmusic.sourceforge.net/doc/dict/cmio-topic.html) 
%%
%% * Refactor: there are some early attempts to prevent
%% code-doublettes by using somewhat more general constructs as
%% MakeHierarchicVSScore. However, code can probably cleaned up more
%% nicely..
%%
%% * Functionality and naming inconsistent: e.g. MakeCsoundScore
%% vs. ToLilypond, and OutputCsoundScore vs. OutputLilypond
%%
%% * Def of lilypond output (ToLilypond) inconsistent: for some classes output is build-in (as for note) and for others the output can be added. More consistent would be a solution which hands all transformers as arg (and supports adding instead of replacing for convenience, similar to Score.makeScore)
%%
%% * GUtils.selectArgs is probably better replaced by a construct
%% using Adjoin: {Adjoin Defaults Args} = EffectiveArgs
%%
%% * ?? unit of measurement not in score parameter but (at least optional) given to output transformer
%%

functor
import
   Open OS Tk System Compiler% Time
   FD FS
   Browser(browse:Browse)
%    Inspector(inspect:Inspect)

   OPIEnv at 'x-oz://system/OPIEnv.ozf'
   
   %% !! tmp
   Path at 'x-ozlib://anders/tmp/Path/Path.ozf'
   
   GUtils at 'GeneralUtils.ozf'
   LUtils at 'ListUtils.ozf'
   MUtils at 'MusicUtils.ozf'
   Score at 'ScoreCore.ozf'
   Init at 'Init.ozf'
   Midi at 'MidiOutput.ozf'
%   Score at 'ScoreCore.ozf'

   %% NOTE: adds dependency to Strasheela extension
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   
export
   Show
   WriteToFile ReadFromFile
   RecordToVS RecordToVS_simple ListToVS ListToLines % ListToVS2 ListToVS3 
   MakeEventlist OutputEventlist
   ScoreToEvents
   MakeHierarchicVSScore
   ToScoreConstructor OutputScoreConstructor SaveScore LoadScore
   MakeEvent2CsoundFn MakeCsoundScore
   OutputCsoundScore RenderCsound RenderAndPlayCsound
   CallCsound
   ToLilypond ToLilypond2 OutputLilypond CallLilypond ViewPDF
   RenderLilypond RenderAndShowLilypond MakeLilyTupletClauses

   %% expert lily procs
   SeqToLily SimToLily 
   MakeNoteToLily MakeNoteToLily2
   LilyMakePitch LilyMakeFromMidiPitch LilyMakeMicroPitch LilyMakeEt72MarkFromMidiPitch
   PauseToLily LilyRest
   LilyMakeRhythms LilyMakeRhythms2 
   IsOutmostSeq IsSingleStaffPolyphony SingleStaffPolyphonyToLily IsLilyChord SimToLilyChord GetUserLily
   SetMaxLilyRhythm
   
   %% 
   OutputSCScore MakeSCScore MakeSCEventOutFn
   SendOsc SendSCserver SendSClang
   ToNonmensuralENP OutputNonmensuralENP
   ToFomus OutputFomus RenderFomus
   MakeCMEvent MakeCMScore OutputCMScore
   ToDottedList LispList % LispKeyword
   RecordToLispKeywordList ToLispKeywordList
   OzToLisp
   Note2ClmP MakeClmScoreFn
   PlaySound
   Exec ExecNonQuitting ExecWithOutput
   Shell

   Midi
   
define
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% General stuff
%%%

   /** %% Simple tool for showing results in the emulator. The idea is, that sometimes we need to copy/paste results. Note that values without a print-representation (e.g., FD ints, procedures, objects) are *not* transformed into any contructor call, but output similarily to how they would be shown in the Browser.
   %% */
   proc {Show X}
      {System.showInfo
       if {IsVirtualString X}
       then X
       else {Value.toVirtualString X 1000000 1000000}
       end}
   end

   /** %% Writes/overwrites Output (a virtual string) to file at Path.
   %% */
   %% TODO: 
   %% !! how to ensure that {File close} is called, ie. how to
   %% 'unwind-protect'
%    try  
%       {Process F}
%    catch X then {Browse '** '#X#' **'}  
%    finally {CloseFile F} end
   proc {WriteToFile Output Path}
      File = {New Open.file  
	      init(name: Path
		   flags: [write create truncate text]
		   mode: mode(owner: [read write]  
			      group: [read write]))}
   in
      {System.showInfo "writing to "#Path}
      {File write(vs:Output)}
      {File close}
   end
   /** %% Reads the content of the text file at Path and returns it as string.
   %% */
   %% !! this should go into some functor Input.oz
   proc {ReadFromFile Path ?Result}
      File = {New Open.file init(name: Path)}
   in
      {System.showInfo "reading from "#Path}
      {File read(list:Result
		 size:all)}
      %% !! how to ensure that {File close} is called, ie. how to
      %% 'unwind-protect'
      {File close}
   end

   local
      fun {Domain2VS X}
	 if X == nil then "nil"
	 elseif {IsList X}
	 then "["#{ListToVS {Map X Domain2VS} ' '}#"]"
	 else case X of A#B
	      then A#"#"#B
	      else X
	      end
	 end
      end
      /** %% Double any escape char (\)
      %% */
      fun {PreserveEscapes S}
	 {LUtils.mappend S
	  fun {$ Char} case Char of &\\ then [&\\ &\\] else [Char] end end}
      end
   in
      /** %% Transforms a (possibly nested) record into a single virtual string with Oz record syntax. RecordToVS also transforms the special Oz records with the labels '|' (i.e. lists) and '#' into their shorthand syntax. The virtual string output is not indented, but every record feature (or list element) starts a new line. As the output is basically a text value (i.e. no 'normal' Oz value anymore), FD and FS variables are transformed into a constructor call (FD.int and FS.var.bounds) which would create these variables when evaluated. 
      %% NB: Value.toVirtualString does something very similar: it transforms nested data into their print representation. However, RecordToVS tries to create code which when executed results in same value, whereas Value.toVirtualString creates print representation. Also, RecordToVS does not expect any max width/depth arguments and attempts to format the output. 
      %% NB: if X (or some value in X) is not of any of the types record (or list or #-pair) or virtual string, Value.toVirtualString is called on this value.
      %%
      %% */
      fun {RecordToVS X}
	 if {IsDet X} then
	    %% Strings should always be surrounded by double quotes, and all escape sequences should be preseved when printed
	    %% same for atoms and virtual strings..
	    if {IsString X} then "\""#{PreserveEscapes X}#"\""
	    elseif {IsAtom X} then "'"#{PreserveEscapes {AtomToString X}}#"'"
	    elseif {IsNumber X} then X
	       %% Note: bytestrings would result in error..
	    elseif {IsVirtualString X} then {Record.map X RecordToVS}
	    elseif {IsRecord X} andthen {Arity X} \= nil
	    then L = {Label X}
	    in
	       case L
	       of '|' then '['#{ListToLines {Map X RecordToVS}}#"]"
	       [] '#' then {ListToVS {Map {Record.toList X} RecordToVS} "#"} 
	       else {RecordToVS L}#"("
		  #{ListToLines 
		    {Map {Arity X}
		     fun {$ Feat}
			if {IsNumber Feat}
			then {RecordToVS X.Feat}
			else Feat#":"#{RecordToVS X.Feat}
			end
		     end}}
		  #")"
	       end
	    elseif {GUtils.isFS X}
	    then {VirtualString.toString
		  '{FS.var.bounds '
		  #{Domain2VS {FS.reflect.lowerBound X}}#' '
		  #{Domain2VS {FS.reflect.upperBound X}}#'}'}
	       %% determined other values
	    else {Value.toVirtualString X 10 1000}
	    end
	 elseif {IsFree X} then "_"
	 elseif {FD.is X} then {VirtualString.toString
				'{FD.int '#{Domain2VS {FD.reflect.dom X}}#'}'}
	 elseif {GUtils.isFS X}
	 then {VirtualString.toString
	       '{FS.var.bounds '
	       #{Domain2VS {FS.reflect.lowerBound X}}#' '
	       #{Domain2VS {FS.reflect.upperBound X}}#'}'}
	    %% undetermined other values
	 else {Value.toVirtualString X 10 1000}
	 end
      end
   end
   /** %% A simpler form of RecordToVS which does not handle variables, and virtual strings are preseved as is.
   %% */
   fun {RecordToVS_simple X}
      if {IsDet X} then
	 if {IsVirtualString X} then X
	 elseif {IsRecord X} andthen {Arity X} \= nil
	 then L = {Label X}
	 in
	    case L
	    of '|' then '['#{ListToLines {Map X RecordToVS_simple}}#"]"
	    [] '#' then {ListToVS {Map {Record.toList X} RecordToVS_simple} "#"} 
	    else {RecordToVS_simple L}#"("
	       #{ListToLines 
		 {Map {Arity X}
		  fun {$ Feat}
		     if {IsNumber Feat}
		     then {RecordToVS_simple X.Feat}
		     else Feat#":"#{RecordToVS_simple X.Feat}
		     end
		  end}}
	       #")"
	    end
	    %% undetermined other values
	 else {Value.toVirtualString X 10 1000}
	 end
      end
   end
      
   /** % Transforms Xs, a list of virtual strings, into a single virtual string. Delimiter is the virtual string between all list elements.
   %% */
   fun {ListToVS Xs Delimiter}
      case Xs
      of nil then nil
      [] X|nil then X
      [] X|Tail then X#Delimiter#{ListToVS Tail Delimiter}
      end
   end


   %% old defs kept for reference for a while, just in case 
   %%
%     % Transforms a list of virtual strings into a single virtual string without any sign between the list elements.
%    %% 
%    fun {ListToVS2 Xs}
%       {ListToVS Xs ''}
% %       case Xs
% %       of X|nil then X
% %       [] X|Tail then X#{ListToVS2 Tail}
% %       [] nil then nil
% %       end
%    end
%     % Transforms a list of virtual strings into a single virtual string with a single whitespace between the list elements.
%    %% 
%    fun {ListToVS3 Xs}
%       {ListToVS Xs " "}
% %       case Xs
% %       of X|nil then X
% %       [] X|Tail then X#" "#{ListToVS Tail}
% %       [] nil then nil
% %       end
%    end
   
   
   /** % Transforms a list of virtual strings into a single virtual string, every list element starts at a new line.
   %% */
   %% !! handle case Xs=nil
   fun {ListToLines Xs}
      {ListToVS Xs "\n"}
%       case Xs
%       of X|nil then X
%       [] X|Tail then X#"\n"#{ListToLines Tail}
%       [] nil then nil
%       end
   end

   /** %% [Temp def? Def. not general enough] MakeEventlist generates a virtual string for output from Score. The unary function EventOut generates the output of a single event. The binary function ScoreOut combines all events to a score.
   %% */
   fun {MakeEventlist Score EventOut ScoreOut}
      % Test is a predicate to filter 
      Test = fun {$ X}
		{X isEvent($)} andthen {X isDet($)} andthen
		({X getDuration($)} > 0)
	     end 		
      Events = {Score collect($ test:Test)}
   in
      %% !! proper call ??
      {ScoreOut Score {Map Events EventOut}}
   end
   /** %% [Temp def -- use WriteToFile directly instead] OutputEventlist transforms Score for output and outputs it at Path. The unary function EventOut generates the output of a single event. The binary function ScoreOut combines all events to a score.
   %% */
   proc {OutputEventlist Score EventOut ScoreOut Path}
      {WriteToFile {MakeEventlist Score EventOut ScoreOut}
       Path}
   end

   /** %% Transforms MyScore (a Strasheela score) into a list of events. Specs is a list of pairs in the form [Test1#Transform1 ...]. Each Test is a unary function (or method) expecting a score object and returning a boolean. Each Transform is a unary function expecting a score object and returning a list of events.
   %% The record Args expects the only optional argument test, a unary boolean function used to filter the set of score objects in MyScore: only  objects for which the test returns true are considered for processing. This test defaults to
   fun {Test X} {X isEvent($)} andthen {X isDet($)} andthen {X getDuration($)} > 0 end
   %%  For every score object in MyScore which passes this Test, the appropriate Test#Transform pair is found out (i.e. the first pair whose test returns true for the score object). If no matching pair is found, the object is skipped. Otherwise, the respective Transform is applied to this score object and the result appended to the full result of ScoreToEvents.
   %% The following example implements a simple Strasheela score -> Csound score transformation. Only the notes in the Strasheela score are considered (everything else is ignored) and these notes are transformed into a csound score event.
   {Out.scoreToEvents MyScore [isNote#fun {$ MyNote}
					 [{Out.listToVS
					   [i1
					    {MyNote getStartTimeInSeconds($)}
					    {MyNote getDurationInSeconds($)}
					    {MyNote getPitchInMidi($)}
					    {MyNote getAmplitudeInVelocity($)}]
					   " "}]
				      end]
    unit}
   
   %% For example, the result returned could look like this:
   ["i1 0.0 1.0 60.0"
    "i1 1.0 2.0 62.0"
    "i1 2.0 4.0 64.0"]
   
   %% */
   fun {ScoreToEvents MyScore Specs Args}
      Defaults = unit(test:fun {$ X}
			      {X isEvent($)} andthen {X isDet($)} andthen
			      ({X getDuration($)} > 0)
			   end)
      As = {Adjoin Defaults Args}
      %% process MyScore as well, if it fits test
      ScoreObjects = {Append if {As.test MyScore} then [MyScore] else nil end
		      {MyScore collect($ test:As.test)}}
   in
      {LUtils.mappend ScoreObjects
       fun {$ X}
	  Matching = {LUtils.find Specs
		      fun {$ Test#_}
			 {{GUtils.toFun Test} X}
		      end}
       in if Matching == nil
	  then nil
	  else 
	     _#Transform = Matching
	  in
	     {{GUtils.toFun Transform} X}
	  end
       end}
%       %%
%       {MyScore mappend($ fun {$ X}
% 			    Matching = {LUtils.find Specs
% 					fun {$ Test#_}
% 					   {{GUtils.toFun Test} X}
% 					end}
% 			 in if Matching == nil
% 			    then nil
% 			    else 
% 			       _#Transform = Matching
% 			    in
% 			       {{GUtils.toFun Transform} X}
% 			    end
% 			 end
% 		       test:As.test)}
   end
   
   
   
   /** %% [Temp def? Def. not general enough] Translates Score into some hierarchic score (a tree, not a graph) for output. EventOut, SimOut, and SeqOut are all functions which output a VS representation of the output format. The functions SimOut and SeqOut return something in the form [BeginVS Delimiter EndVS] -- the representation of their items will be placed between these "tags". FurtherClauses is a list to define additional output alternatives as in the form [testFnOrMeth1#Fn1 ..]. 
   %% */
   fun {MakeHierarchicVSScore Score EventOut SimOut SeqOut FurtherClauses}
      fun {TransformContainer Score Fn}
	 [Begin Delimiter End] = {Fn Score}
	 Items = {Map {Score getItems($)}
		  fun {$ X}
		     {MakeHierarchicVSScore X EventOut SimOut SeqOut FurtherClauses}
		  end}
	 DelimitedItems = {ListToVS
			   Items.1 | {List.map Items.2
				      fun {$ X} Delimiter#X end}
			   ""}
      in
	 Begin#DelimitedItems#End
      end
   in
      {GUtils.cases Score
       {Append FurtherClauses
	[%% return empty VS for everything of dur =< 0
	 fun {$ X} ({X getDuration($)} =< 0) end#fun {$ X} {Browse hi} '' end
	 isSimultaneous#fun {$ X} {TransformContainer X SimOut} end
	 isSequential#fun {$ X} {TransformContainer X SeqOut} end
	 isEvent#fun {$ X}
		    if %% !! event must be fully determined 
		       {X isDet($)} 
		    then {EventOut X} 
		       %% [?? general enough] output empty atom for undetermined events
		    else ''		
		    end
		 end
	 fun {$ X} true end
	 #fun {$ X} 
	     %%raise unsupportedClass(Score MakeHierarchicVSScore) end
	     {GUtils.warnGUI "Score contains object for which no clause was defined!"}
%	     {Browse warn#unsupportedClass(Score MakeHierarchicVSScore)}
	     ''
	  end]}}
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Oz record output
%%%

   
   /** %% Creates an Oz program (as a VS) which re-constructs MyScore. 
   %% */
   fun {ToScoreConstructor MyScore Spec}
      Defaults = unit(prefix:"declare \n MyScore \n = "
		      postfix:"")
      Args = {Adjoin Defaults Spec}
      StartTime = {MyScore getStartTime($)}
      TimeUnit = {MyScore getTimeUnit($)}   
   in
      if {Not {IsDet StartTime}}
      then {GUtils.warnGUI "warn: undetermined toplevel startTime"}
      end
      if {Not {IsDet TimeUnit}}
      then {GUtils.warnGUI "warn: undetermined timeUnit"}
      end
      %% NB: RecordToVS can handle undetermined variables
      local
	 InitRecord
      in
	 {MyScore {Adjoin {Record.subtractList Args [prefix postfix file extension dir]}
		   toInitRecord(InitRecord)}}
	 %%
	 Args.prefix#	 
	 "{Score.makeScore\n"#{RecordToVS
			       {Adjoin unit(startTime:StartTime
					    timeUnit:TimeUnit)
				InitRecord}}
	 #"\n"#{MyScore getInitClassesVS($)}#"}"#Args.postfix
      end
   end
   
   /** %% Stores an Oz program in a file which re-constructs MyScore. For example, this file can also be used for editing purposes.
   %% Args
   %%
   %% 'prefix' and 'postfix': VSs added before and after code for creating score object
   %% 'exclude' and 'clauses': arguments of method toInitRecord
   %%
   %% Defaults:
   %%
   unit(file:"test"
	extension:".ssco"
	dir:{Init.getStrasheelaEnv defaultSScoDir}
	prefix:"declare \n MyScore \n = "
	postfix:""
       )
   %% */
   %% !! renamed, was: OutputInitRecord
   proc {OutputScoreConstructor MyScore Spec}
      Defaults = unit(file:"test"
		      extension:".ssco"
		      dir:{Init.getStrasheelaEnv defaultSScoDir}
		      %% prefix/postfix defaults defined in ToArchiveInitRecord
		     )
      Args = {Adjoin Defaults Spec}
      Path = Args.dir#Args.file#Args.extension
   in
      {WriteToFile
       '%% -*- mode: oz -*-\n'#
       {ToScoreConstructor MyScore Args}
       Path}
      %% !! BUG: script does not work yet when called from Oz, when called in shell it works fine..
      %%
      %% ksprotte, svn commit r48, Tue, 05 Sep 2006: 
      %%
      %% Init record should now be auto-indented (see below)
      %% Not sure if this works better on linux...
      %%
      %% On osx I get the following error in the OZemulator:
      %%      
      %% writing to /tmp/out3.ssco
      %% > /Users/paul/src/strasheela/scripts/ozindent.sh /tmp/out3.ssco
      %% Formatting /tmp/out3.ssco
      %% Cannot open load file: /Applications/Emacs.app/Contents/MacOS/libexec/fns-21.2.1.el
      %%
      %% The invocation of the script from the shell works, of course :)
      %%
      %% Not sure, what to do here, will remove it again from the archive
      %% init record function of no success.
      %%
      %%
      %% T Anders (9 August 2007): more info on fns-21.2.1.el
      %%
      %% http://www.interopcommunity.com/tm.aspx?m=10583
      %% http://www.cse.huji.ac.il/support/emacs/elisp-help/elisp-manref/elisp_15.html#SEC199
      %%
      %% still, no idea how to fix this
      %%
      %% the file fns-21.2.1.el is loaded by emacs function symbol-file 
      %%
      %% Plainly doing emacs --batch already shows the problem
      {Exec {Init.getStrasheelaEnv strasheelaDir}#'/scripts/ozindent.sh' [Path]}
   end

   /** %% Saves MyScore into a text file which can be compiled and loaded again later with LoadScore.
   %% NB: SaveScore internally uses toInitRecord (because a stateful data structure like an object can not be pickled). Therefore, all present restrictions of toInitRecord apply:  getInitInfo must be defined correctly for all classes and only tree-form score topologys are supported.

%   %% Saves MyScore into a pickle which can be loaded again later with LoadScore.
%   %% NB: Only a fully determiend score can be pickled, otherwise an exception is raised.
   %% */
   %% A pickle is not used, because undetermined variables can not be pickled.
   proc {SaveScore MyScore Args}
      {OutputScoreConstructor MyScore
       {Adjoin Args unit}}
   end

   local
      CompilerEnvironment = {Adjoin OPIEnv.full
			     env(%'Debug': Debug 
				 'Path': Path % use my Path fixes
				%% Strasheela stuff
				'Init':Init 'GUtils':GUtils 'LUtils':LUtils 'MUtils':MUtils
				'Score':Score
				% 'SDistro':SDistro
				% 'Out':Out % .. would be recursive?
				)}
   in
      /** %% Loads a pickeled score from path.
      %% NB: If the class definitions for the classes used in the score will have changed meanwhile, the loaded score will still use the new class definitions (it is re-created from the textual specification). 
      %% */
      fun {LoadScore Args}
	 Defaults = unit(file:"test"
			 extension:".ssco"
			 dir:{Init.getStrasheelaEnv defaultSScoDir})
	 As = {Adjoin Defaults Args}
	 Path = As.dir#As.file#As.extension
	 VS = {ReadFromFile Path}
	 %% !!?? this environment may not be sufficient..
	 Env = {Adjoin CompilerEnvironment
		{Init.getStrasheelaEnv strasheelaFunctors}}
      in
	 {Compiler.evalExpression VS Env _}
      end
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Csound output related stuff
%%%

   /** % Outputs unary function which transforms an Score.event into a csound note virtual string. 
   %% Spec is a list of accessor functions/methods. However, for every accessor function/method a transformation function/method for the accessed data can be specified using the syntax Accessor#Transformator. All accessors mmust return a parameters (e.g. use getPitchParameter instead of getPitch).
   %% */
   %%
   %% !! not general enough, e.g., parameter units are ignored. Idea
   %% Spec is either some method (e.g. an accessor) or some unary
   %% function which gets object as arg.
   fun {MakeEvent2CsoundFn Instrument Spec}
      fun {$ X}
	 {ListToVS
	  {Append
	   [i#Instrument]
	   {Map Spec
	    fun {$ Y}
	       case Y of ParamAccessor#Transformator
	       then {{GUtils.toFun Transformator}
		     {{GUtils.toFun ParamAccessor} X}}
	       else
		  ParamAccessor = Y
	       in
		  {{{GUtils.toFun ParamAccessor} X} getValue($)}
	       end
	    end}}
	  " "}
      end
   end
   /** % Returns a Csound score as a virtual string. EventVSs is a note list. Each note is a virtual string. Header is the Csound header, e.g. f statements.
   %% */
   fun {MakeCsoundScore EventVSs Header}
      Header#"\n\n"#{ListToLines EventVSs}
   end

   
%       fun {TimeToSeconds Param}
% 	 {Param getValueInSeconds($)}
%       end
   
   /** % Create a csound score file of MyScore, but only include fully determined events. The defaults for Spec are:
   unit(file:"test" % without extension
	scoDir:{Init.getStrasheelaEnv defaultCsoundScoDir}
	header:nil
	event2CsoundFn:&lt;see source&gt;
	test:&lt;see source&gt;)
   %% header is the csound header VS (e.g. for f-tables).
   %% The default event2CsoundFn of OutputCsoundScore supports parameter unit specifications for the transformation process (see the Parameter documentation). Without determined Parameter unit the unit defaults to seconds for TimeParameters and midi for Pitches. The event2CsoundFn always returns seconds and midi pitches. 
   always transforms timing parameters into seconds and 
   %% */
   proc {OutputCsoundScore MyScore Spec}
      Defaults = unit(file:"test"
		      scoDir:{Init.getStrasheelaEnv defaultCsoundScoDir}
		      header:nil
		      event2CsoundFn:{MakeEvent2CsoundFn 1
				      [getStartTimeParameter#getValueInSeconds
				       fun {$ X} X end#getDurationInSeconds
				       getAmplitudeParameter#getValueInNormalized
				       getPitchParameter#getValueInMidi]}
		      test:fun {$ X}
			      {X isEvent($)} andthen {X isDet($)} andthen
			      ({X getDuration($)} > 0)
			   end)
      Args = {Adjoin Defaults Spec}
      Tempo = "\n\nt 0 "#{Init.getTempo}
      Header = if Args.header == nil
	       then nil
	       else "\n\n"#Args.header
	       end
   in
      {WriteToFile
       {MakeCsoundScore
	{Map {MyScore collect($ test:Args.test)} Args.event2CsoundFn}
	";;; created by Strasheela at "#{GUtils.timeVString}#Header#Tempo}
       Args.scoDir#Args.file#".sco"}
   end
   
   /** % Calls Csound with args in Spec and writes Csound messages on standard output (Oz emulator). Spec is a record with optional arguments. The defaults are:
   unit(orc:{Init.getStrasheelaEnv defaultOrcFile} % with extension!, e.g. "pluck.orc"
	file:"test" % without extension!
	soundExtension:{Init.getStrasheelaEnv defaultCsoundSoundExtension} % ".aiff"
	orcDir:{Init.getStrasheelaEnv defaultCsoundOrcDir}
	scoDir:{Init.getStrasheelaEnv defaultCsoundScoDir}
	soundDir:{Init.getStrasheelaEnv defaultSoundDir}
	csound:{Init.getStrasheelaEnv csound}
	flags:{Init.getStrasheelaEnv defaultCsoundFlags})
   %% */
   proc {CallCsound Spec}
      Defaults = unit(orc:{Init.getStrasheelaEnv defaultOrcFile} %"pluck.orc"
		      file:"test"
		      soundExtension:{Init.getStrasheelaEnv defaultCsoundSoundExtension} % ".aiff"
		      orcDir:{Init.getStrasheelaEnv defaultCsoundOrcDir}
		      scoDir:{Init.getStrasheelaEnv defaultCsoundScoDir}
		      soundDir:{Init.getStrasheelaEnv defaultSoundDir}
		      csound:{Init.getStrasheelaEnv csound}
		      flags:{Init.getStrasheelaEnv defaultCsoundFlags})
      MySpecs = {Adjoin Defaults Spec}
      OrcPath = MySpecs.orcDir#MySpecs.orc
      ScoPath = MySpecs.scoDir#MySpecs.file#".sco"
      SoundPath = MySpecs.soundDir#MySpecs.file#MySpecs.soundExtension
      Flags = {GUtils.selectArg flags Spec Defaults}
      %% !! Open.pipe is very picky with input format: no
      %% additional whitespace and separate flags either as
      %% separate atoms or without any hyphen between them -- try
      %% later to generalise Flags arg
	 % Pipe 
   in
% 	 %% output command
% 	 {System.showInfo
% 	  {ListToVS
% 	   ['>' CSoundApp Flags '-o '#SoundPath OrcPath ScoPath]}}
% 	 Pipe = {New Open.pipe
% 		      init(cmd:CSoundApp
% 			   args:[Flags "-o "#SoundPath OrcPath ScoPath])}
% 	 {System.showInfo
% 	  {Pipe read(list:$ size:all)}}
%       %{Pipe flush}		% wait until csound is finished
% 	 {Pipe close}      
      {Exec MySpecs.csound {Append Flags ['-o' SoundPath OrcPath ScoPath]}}
   end

   /** % Creates a csound score of all (determined) events in MyScore, and renders the score. See the documentation of OutputCsoundScore, CallCsound, and PlaySound for arguments in Spec (the PlaySound argument extension is substituted by the argument soundExtension).
   %% */
   proc {RenderCsound MyScore Spec}	 
      Defaults = unit(test:fun {$ X}
			      {X isEvent($)} andthen {X isDet($)}
			   end
		      soundExtension:{Init.getStrasheelaEnv defaultCsoundSoundExtension})
      MySpec = {Adjoin Defaults Spec}
      Events = {MyScore collect($ test:MySpec.test)}
   in
      if Events \= nil then
	 {OutputCsoundScore MyScore MySpec}
	 {CallCsound MySpec}
      end
   end

   /** % Creates a csound score of all (determined) events in MyScore, renders the score and plays the resulting sound. See the documentation of OutputCsoundScore, CallCsound, and PlaySound for arguments in Spec (the PlaySound argument extension is substituted by the argument soundExtension).
   %% */
   proc {RenderAndPlayCsound MyScore Spec}
      Defaults = unit(test:fun {$ X}
			      {X isEvent($)} andthen {X isDet($)}
			   end
		      soundExtension:{Init.getStrasheelaEnv defaultCsoundSoundExtension})
      MySpec = {Adjoin Defaults Spec}
      Events = {MyScore collect($ test:MySpec.test)}
   in
      if Events \= nil then
	 {RenderCsound MyScore MySpec}
	 {PlaySound {Adjoin MySpec unit(extension: MySpec.soundExtension)}}
      else
	 {GUtils.warnGUI "No events in resulting Csound score. Is score fully determined?"}
%	 {System.showInfo "Warning: no events in Csound score. Are events fully determined?"}
      end
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Lilypond output related stuff
%%%

   
   BeatsPerQuarterNote = 1.0		% !! arg
   IdxFactor = 64.0
   %%
   %%
   LilyPCs = pcs(c cis d 'dis' e f fis g gis a ais b)
   LilyOctaves = octs(",,,," ",,," ",," "," "" "'" "''" "'''" "''''")
   fun {BeatsToIdx Beats}		% Beats is float
      {FloatToInt Beats * BeatsPerQuarterNote * IdxFactor}
   end
   fun {BeatSpecToIdx BeatSpec}
      {FloatToInt BeatSpec * IdxFactor}
   end
   %% Lily meanwhile does tie automatically in specific cases, but I still need this (simplyt scaling durations has not always any effect on the notation)
   proc {MakeLilyRhythm Result}
      %% this determines IdxFactor (IdxFactor * 0.109375 = 7.0,
      %% i.e. can be integer)
      Spec = [[16.0 " \\longa "]
	      [8.0 " \\breve "]
	      [4.0 1] [6.0 "1."] [7.0 "1.."]
	      [2.0 2] [3.0 "2."] [3.5 "2.."]
	      [1.0 4] [1.5 "4."] [1.75 "4.."]
	      [0.5 8] [0.75 "8."] [0.825 "8.."]
	      [0.25 16] [0.375 "16."] [0.4375 "16.."]
	      [0.125 32] [0.1875 "32."] [0.21875 "32.."]
	      [0.0625 64] [0.09375 "64."] [0.109375 "64.."]]
      Feats = {Map Spec fun {$ [Feat _]} {BeatSpecToIdx Feat} end}
   in
      Result = {MakeRecord rhythms Feats}
      {ForAll Spec proc {$ [Feat Val]} Result.{BeatSpecToIdx Feat} = Val  end}
   end
   LilyRhythms = {MakeLilyRhythm}
   
   %% all un-punctuated and many single-punctuated BeatIndices 
   LilyFullRhythmIdxs = {Map [16.0 8.0 6.0 4.0 3.0 2.0 1.5 1.0 0.75 0.5 0.375 0.25 0.125]
			 BeatSpecToIdx}
   SmallesRhythmIdxs = {BeatSpecToIdx 0.125}
   local
      LilyRhythmIdxs = {NewCell nil}
   in
      /** %% When outputting a Lilypond file, Strasheela automatically splits very long notes (or other score objects notated by notes such as chords or scales) into multiple notes connected by ties. The maximum duration notated by a single note can be set with this procedure. Dur is a float measured in quarternotes. For example, 2.0 indicates a halve note and 0.5 an eighth note. The maximum duration supported by Lilypond is a longa (16.0). The default is 4.0 (a whole note).
      %% It is recommended to set Dur to the length of your bars (e.g., 4.0 for 4/4).
      %% */ 
      proc {SetMaxLilyRhythm Dur}
	 LilyRhythmIdxs := {Filter LilyFullRhythmIdxs
			    fun {$ X} X =< {BeatSpecToIdx Dur} end}
      end
      proc {GetLilyRhythmIdxs Idxs}
	Idxs = @LilyRhythmIdxs
      end
      {SetMaxLilyRhythm 4.0}
   end
      
   /** %% [for clause definitions] creates Lilypond duration output (a list of Lilypond rhythm values, which in the end are tied together) for a duration parameter.
   %% */
   fun {LilyMakeRhythms DurationParam}
      {LilyMakeRhythms2 {DurationParam getValueInBeats($)}}
   end
   /** %% [for clause definitions] creates Lilypond duration output (a list of Lilypond rhythm values, which in the end are tied together) for a duration measured in beats (a float).
   %% */
   fun {LilyMakeRhythms2 DurationInBeats}
      {MakeRhythmsAux {BeatsToIdx DurationInBeats}}
   end
   fun {MakeRhythmsAux BeatIdx}
      %% create a list of note durations, dots and ties
      if BeatIdx < SmallesRhythmIdxs % stop condition 
      then nil
      elseif {HasFeature LilyRhythms BeatIdx} andthen
	 {Member BeatIdx {GetLilyRhythmIdxs}}
      then [ LilyRhythms.BeatIdx ]
      else				% tied notes: 
	 %% find biggest LilyRhythms index smaller IdxBeat
	 BiggestSubRhythm = {LUtils.find {GetLilyRhythmIdxs}
			     fun {$ X} BeatIdx > X end}
      in
	 LilyRhythms.BiggestSubRhythm | {MakeRhythmsAux BeatIdx-BiggestSubRhythm}
      end
   end
   /** %% [for clause definitions] creates Lilypond 72 ET microtonal pitch output (a VS) for a pitch parameter. Note: works only if the pitch unit is et72.
   %% */
   %% !!?? temp fix
   fun {LilyMakeMicroPitch PitchParam}
      %% et72: represent 12th notes by fingering marks
      if {PitchParam getUnit($)} == et72
      then {LilyMakeEt72MarkFromMidiPitch {PitchParam getValueInMidi($)}}
      else ''
      end
   end
%    %% Returns a Lily fingering mark (a virtual string) which represents a micro-tonal tuning deviation in 72ET temperament.
%    %% 
%    fun {LilyMakeEt72MarkFromMidiPitch MidiPitch}
%       Marks = unit("-0" "-1" "-2" "-3" "-4" "-5" "-6")
%       %Pitch = {PitchParam getValueInMidi($)}
%       Micro = {FloatToInt ((MidiPitch - {Round MidiPitch}) * 6.0)} + 4
%    in
%       Marks.Micro
%    end
   /** %% [for clause definitions] Returns a Lily fingering mark (a virtual string) which represents a micro-tonal tuning deviation in 72 ET temperament.
   %% */
   fun {LilyMakeEt72MarkFromMidiPitch MidiPitch}
      Marks = unit(%% !!?? alternative sign for quarter note flat?
		   %% combination of + and - as advocated by Hans Zender
		   "^\\markup{\\override #\'(baseline-skip . 1) \\column <-- -- -->}"
		   "^\\markup{\\override #\'(baseline-skip . 1) \\column <-- -->}"
		   "^\\markup{--}"
		   ""
		   "^\\markup{+}"
		   "^\\markup{\\override #\'(baseline-skip . 1) \\column <+ +>}"
		   "^\\markup{\\override #\'(baseline-skip . 1) \\column <+ + +>}"
		   %% Manuel Op de Coul's version of HEWM (www.tonalsoft.com/enc/h/hewm.aspx)
% 		   "^\\markup{v}"
% 		   "^\\markup{L}"
% 		   "^\\markup{"\\"}" % this causes Lily problems
% 		   ""
% 		   "^\\markup{/}"
% 		   "^\\markup{7}"
% 		   "^\\markup{^}"
		   %%  edited version of Manuel Op de Coul's HEWM (because of Lily problems with \)
% 		   "^\\markup{v}"
% 		   "^\\markup{L}"
% 		   "^\\markup{-}" 
% 		   ""
% 		   "^\\markup{+}"
% 		   "^\\markup{7}"
% 		   "^\\markup{"\^"}"
		  )
      %Pitch = {PitchParam getValueInMidi($)}
      Micro = {FloatToInt ((MidiPitch - {Round MidiPitch}) * 6.0)} + 4
   in
      Marks.Micro
   end
   
   /** %% [for clause definitions] creates Lilypond pitch output (a VS) for a pitch parameter.
   %% */
   fun {LilyMakePitch PitchParam}
      %% create pitchClass and octave expression
      %% !! unit must be bound
      MidiPitch = {FloatToInt {PitchParam getValueInMidi($)}}
   in
      {LilyMakeFromMidiPitch MidiPitch}
   end
   /** %% [for clause definitions] creates Lilypond pitch output (a VS) for a midi pitch value (an integer).
   %% */
   fun {LilyMakeFromMidiPitch MidiPitch}
      PC = {Int.'mod' MidiPitch 12} + 1
      Oct = {Int.'div' MidiPitch 12} + 1
   in
      LilyPCs.PC#LilyOctaves.Oct
   end

   /** %% [for clause definitions] Returns unary function which expects a note object and returns a Lilypond note output (a VS). Simplified version of MakeNoteToLily2.
   %% */
   fun {MakeNoteToLily MakeAddedSigns}
      {MakeNoteToLily2 fun {$ N} {LilyMakePitch {N getPitchParameter($)}} end
       MakeAddedSigns}
   end

   %% !! TODO: What about notating other Events (e.g. percussion notation)?
   %% !! TODO: angleichen die verschiedenen Funs   
   /** %% [for clause definitions] Returns unary function which expects a note object and returns a Lilypond note output (a VS). MakePitch is a unary function expecting the note and returning a Lilypond pitch (a VS). MakeAddedSigns is unary function expecting the note and returning a VS of arbitrary added signs (e.g. fingering marks, articulation marks etc.). MakeNoteToLily2 adds the rhythmic information and cares for ties.
   %% */
   fun {MakeNoteToLily2 MakePitch MakeAddedSigns}
      fun {$ Note}
	 Rhythms = {LilyMakeRhythms {Note getDurationParameter($)}}
      in
	 if Rhythms == nil
	 then ''
	 else
	    Pitch = {MakePitch Note}
	    AddedSigns = {MakeAddedSigns Note}
	    FirstNote = {ListToVS [{OffsetToLilyRest Note} " "
				   Pitch Rhythms.1
				   AddedSigns
				   {GetUserLily Note}]
			 ""}
	    % MicroPitch = {LilyMakeMicroPitch {Note getPitchParameter($)}}  % ?? temp fix?
	    % FirstNote = Pitch#Rhythms.1#MicroPitch
	 in
	    %% !! ?? generalise (needed elsewhere)
	    if {Length Rhythms} == 1
	    then FirstNote
	       %% all values in Rhythm.2 are tied to predecessor
	    else FirstNote#{ListToVS
			    {Map Rhythms.2
			     fun {$ R}
				" ~ "#Pitch#R#AddedSigns
				%" ~ "#Pitch#R#MicroPitch
			     end}
			    " "}
	    end
	 end
      end
   end

   /** %% [for clause definitions] Expects a pause duration in beats (a float) and returns a Lilypond rest (a VS).  
   %% */
   fun {LilyRest PauseDurInBeats}
      %%  returns a list of Lilypond rhythm
      %%  values matching dur of MyPause
     Rhythms = {LilyMakeRhythms2 PauseDurInBeats}
   in
      %% if pause duration is 0 or
      %% too short (less than a 64th
      %% note, or 0.0625 beat)
      if Rhythms == nil
      then '' % omit pause
	 %% otherwise output VS of Lily pause(s)
      else {ListToVS {Map Rhythms fun {$ R} r#R end}
	    " "}
      end
   end

   /** %% [for clause definitions] Expects a pause object and returns a Lilypond rest (a VS).
   %% */
   fun {PauseToLily MyPause}
      {LilyRest {MyPause getDurationInBeats($)}}#{GetUserLily MyPause}
   end
   

   %% create Lily pause (VS) for the offset time of X
   fun {OffsetToLilyRest X}
      {LilyRest {X getOffsetTimeInBeats($)}}
   end

   
   /** %% [for clause definitions] creates Lilypond output (a VS) for a simultaneous container. Args is a record of optional args (clauses and implicitStaffs).
   %% Default Lilypond output uses this definition. Using this function may simplify writing custom output clauses which overwrite the default output.
   %% */
   fun {SimToLily Sim Args}
      {ListToVS
       {GetUserLily Sim} |
       "\n << " | 
       {OffsetToLilyRest Sim} |
       {Append {Map {Sim getItems($)}
		fun {$ X} {ToLilypond2 X Args} end}
	["\n>>"]}
       " "}
   end

   /** %% [for clause definitions] Returns true if X can be notated as a chord, i.e. X is a simultaneous which contains only notes with equal offset time, start and end times
   %% */
   fun {IsLilyChord X}
      if {X isSimultaneous($)} 
      then Items = {X getItems($)} in 
	 {All Items {GUtils.toFun isNote}}
	 andthen {All Items.2
		  fun {$ Y}
		     {Y getStartTime($)} == {Items.1 getStartTime($)}
		     andthen {Y getEndTime($)} == {Items.1 getEndTime($)}
		     andthen {Y getOffsetTime($)} == {Items.1 getOffsetTime($)}
		  end}
      else false
      end
   end

   /** %% [for clause definitions] Outputs Sim (for which IsLilyChord must return true) as a Lilypond chord VS. 
   %% */
   fun {SimToLilyChord Sim}
      Items = {Sim getItems($)}
      Pitches = {ListToVS
		 {Map Items
		  fun {$ X}
		     %% ?? micro pitch tmp fix?
		     {LilyMakePitch {X getPitchParameter($)}}
		     #{LilyMakeMicroPitch {X getPitchParameter($)}} 
		  end}
		 " "}
      Rhythms = {LilyMakeRhythms
		 {Items.1 getDurationParameter($)}}
      FirstChord = {ListToVS
		    [{GetUserLily Sim}
		     {OffsetToLilyRest Sim}
		     {OffsetToLilyRest Items.1}
		     "\n <" Pitches ">"
		     Rhythms.1]
		    " "}
   in
      if {Length Rhythms} == 1
      then FirstChord
      else FirstChord#{ListToVS
		       {Map Rhythms.2
			fun {$ R} " ~ <"#Pitches#">"#R end}
		       " "}
      end
   end
   
   /** %% [for clause definitions] creates Lilypond output (a VS) for a sequential container. Args is a record of optional args (clauses and implicitStaffs).
   %% Default Lilypond output uses this definition. Using this function may simplify writing custom output clauses which overwrite the default output.
   %% */
   fun {SeqToLily Seq Args}
      {ListToVS
       {GetUserLily Seq} |
       "\n {\n" |
       {OffsetToLilyRest Seq} | 
       {Append {Map {Seq getItems($)}
		fun {$ X}  {ToLilypond2 X Args} end}
	["\n}"]}
       " "}
   end

   
   /** %% [for clause definitions] Tests whether X is an Outmost sequential container, i.e. a container which has no direct or indirect temporal container which is also a sequential container. X is either the top-level container, or (the most common case) contained in a top-level simultaneous container.
   %% An outmost sequential implicitly creates a staff by default. 			%% */
   fun {IsOutmostSeq X}
      %% Returns true if Y has a sequential as either direct or indirect container
      fun {HasSequentialAsContainer Y}
	 C = {Y getTemporalContainer($)}
      in 
	 C \= nil andthen
	 ({C isSequential($)} orelse {HasSequentialAsContainer C})
      end
   in
      {X isSequential($)} andthen
      {Not {HasSequentialAsContainer X}} andthen
      {Not {X hasTemporalContainer($)} andthen
       {{X getTemporalContainer($)} hasTemporalContainer($)}}
   end
	  
   local
      %% average pitch decides clef
      %% LilyClefs = clef(bass_8 bass violin "violin^8")
      fun {DecideClef X}
	 %% simple check avarage pitch got confused with pitch classes
	 %% (note pitch class and chord root are also pitches)
	 Pitches = {X map($ getValueInMidi test:fun {$ X}
						   {X isPitch($)} andthen
						   {Not {X hasThisInfo($ pitchClass)}}
						% {{X getItem($)} isNote($)}
						end)}
	 AveragePitch = {FoldL Pitches Number.'+' 0.0} / {IntToFloat
							  {Length Pitches}}
      in
	 if AveragePitch < 12.0 then "\"bass_29\""
	 elseif AveragePitch < 24.0 then "\"bass_22\""
	 elseif AveragePitch < 36.0 then "\"bass_15\""
	 elseif AveragePitch < 48.0 then "\"bass_8\""
	 elseif AveragePitch < 60.0 then bass
	 elseif AveragePitch < 72.0 then violin
	 elseif AveragePitch < 84.0 then "\"violin^8\""
	 elseif AveragePitch < 96.0 then "\"violin^15\""
	 elseif AveragePitch < 108.0 then  "\"violin^22\""
	 else "\"violin^29\""
	 end
      end
   in
      /** %% Create a staff and clef for Seq, then output Seq
      %% */
      %% Not exported
      fun {OutmostSeqToLily Seq Args}
	 Staff = if Args.implicitStaffs
		 then "\\new Staff "#"{ \\clef "#{DecideClef Seq}
		 else ""
		 end
	 Closing = if Args.implicitStaffs
		 then " }"
		 else ""
		 end
      in
	 "\n "#Staff#" "#{SeqToLily Seq Args}#Closing
      end
   end

   /** %% [for clause definitions] Accesses tuple with label 'lily' in info feature of X, and returns VS (concatenating all lily tuple elements). The lily tuple must only contain VSs.
   %% */
   fun {GetUserLily X}
      Lily = {X getInfoRecord($ lily)}
   in
      case Lily of nil then nil
      else {Adjoin Lily '#'}
      end
   end

   local
      fun {IsVoiceContent X}
	 {X isElement($)} orelse 
	 {IsLilyChord X} orelse
	 ({X isSequential($)} andthen {All {X getItems($)} IsVoiceContent})
      end
   in
      /** %% [for clause definitions] Returns true if X is a simultaneous container which containes multiple voices; each voice is a sequential which contains only (i) notes, (ii) simultaneous containers which are chords or (iii) sequentials which in turn contain only notes or chords.
      %% By default, such a simultaneous container creates a single staff polyphony.
      %% */
      fun {IsSingleStaffPolyphony X}
	 if {X isSimultaneous($)}
	    andthen {X hasTemporalContainer($)}
	 then {All {X getItems($)}
	       fun {$ Y}
		  {Y isSequential($)} andthen
		  {All {Y getItems($)} IsVoiceContent}
	       end}
	 else false
	 end
      end
   end
   /** %% [for clause definitions] Outputs X (for which IsSingleStaffPolyphony must return true) as a single staff polyphony Lily VS. 
   %% */
   fun {SingleStaffPolyphonyToLily Sim Args}
      {ListToVS
       {GetUserLily Sim} |
       {OffsetToLilyRest Sim} | 
       "\n <<" |
       {ListToVS {Map {Sim getItems($)}
		  fun {$ X} {ToLilypond2 X Args} end}
	"\\\\"} |
	["\n>>"]
       " "}
   end
   
   local
      TupletName = {NewName}
      
      /** %% Mark X (score element) and all its successors as belonging to a tuplet, until the duration of the tuplets Accum (an int) sums to something dividable by 3. 
      %% */
      proc {MarkSuccessors X Num#Denom Accum}
	 Accum2 = Accum + {X getDuration($)}
      in
	 if Accum2 > ({X getTimeUnit($)}.1 * 16)
	 then {Exception.raiseError
	       strasheela(failedRequirement Accum2
			  "Tuplet duration exceeds 4 whole notes, error in score input assumed.")}
	 else 
	    if Accum2 mod Denom == 0 
	    then {X addInfo(TupletName(Num#Denom 'end'))} 
	    else
	       {X addInfo(TupletName(Num#Denom))}
	       if {Not {X hasTemporalSuccessor($)}} orelse {Not {{X getTemporalSuccessor($)} isElement($)}}
	       then {Exception.raiseError
		     strasheela(failedRequirement X
				"No successor element found, and tuplet duration not completed.")}
	       else {MarkSuccessors {X getTemporalSuccessor($)} Num#Denom Accum2}
	       end
	    end
	 end
      end
      fun {MakeEmptyString _} "" end
      /** %%
      %% */ 
      fun {MakeLilyTupletElement E Num#Denom}
	 CorrectedDur = {E getDuration($)} * Denom div Num
	 DurcorrectedElement = {Score.makeScore {Adjoin {E toInitRecord($)}
						 x(duration:CorrectedDur
						   startTime:{E getStartTime($)}
						   timeUnit:{E getTimeUnit($)})}
				unit(x: {E getClass($)})}
      in
	 if {E isNote($)}
	 then {{MakeNoteToLily MakeEmptyString} DurcorrectedElement}
	 elseif {E isPause($)}
	 then {PauseToLily DurcorrectedElement} 
	 end 
      end
   in
      /** %% [for clause definitions] MakeLilyTupletClauses creates a list of Lilypond clauses for tuplet output. Fractions is a list of pairs Numerator#Denominator indicating the fractions of the tuplets. For example, clauses for triplets are created with he fraction 2#3 and clauses for quintuplets with the fraction 2#5. Tuplets are recognised automatically in the score by the duration of score elements (notes and pause objects). The time unit must be set to beats(N), where N is some quarter note division which allows to express all required durations. For example, if the time unit is beats(60) then the duration 60 indicates a quarter note, 30 indicates an eigth note, three notes of duration 20 form an eigth note triplet and 5 notes of duration 6 form a sixteenth note quintuplet.   
      %% LIMITATIONS: Rests must be expressed explicitly with pause objects, rests expressed by the offset time of score objects are not notated correctly if their duration should be part of a tuplet. Dotted notes at the beginning of a tuplet do not work. Tuplets only work correctly for score elements within a single sequential container: a tuplet must not extend across container boundaries. Also, tuplets cannot be nested. Due to these shortcomings, the default Lilypond output does not support tuplets.
      %% */
      fun {MakeLilyTupletClauses Fractions}
	 TupletStartClauses
	 = {Map Fractions
	    fun {$ Num#Denom}
	       %% find beginning of a tuplet note
	       fun {$ X}
		  {X isElement($)} andthen {Not {X getDuration($)} mod Denom == 0}
		  %% necessary if we have different tuplets
		  andthen {X getDuration($)} mod Num == 0
		  andthen {Not {X hasThisInfo($ TupletName)}}
	       end#fun {$ X}
		      {X addInfo(TupletName(Num#Denom 'start'))}
		      %% process sucessors
		      if {Not {X hasTemporalSuccessor($)}} orelse
			 {Not {{X getTemporalSuccessor($)} isElement($)}}
		      then {Exception.raiseError
			    strasheela(failedRequirement X
				       "No successor element found, and tuplet duration not completed.")}
		      else {MarkSuccessors {X getTemporalSuccessor($)} Num#Denom {X getDuration($)}}
		      end
		      %% create note output
		      "\\times "#Num#"/"#Denom#" {"#{MakeLilyTupletElement X Num#Denom}
		   end 
	    end}
	 TupletContinuationClause
	 = fun {$ X} {X isElement($)} andthen {X hasThisInfo($ TupletName)}
	   end#fun {$ N}
		  case {N getInfoRecord($ TupletName)} of
		     TupletName(Num#Denom) then {MakeLilyTupletElement N Num#Denom} % intermediate tuplet notes 
		  [] TupletName(Num#Denom 'end') then {MakeLilyTupletElement N Num#Denom}#"}" % final tuplet note
		  end
	       end	     
      in
	 TupletContinuationClause | TupletStartClauses
      end
   end
   


   /** %% [for clause definitions] like ToLilypond, except only the bare Lilypond score is created. That is, no Lilypond version number is inserted in the output, nor is the wrapper Lilypond code inserted (see wrapper argument of ToLilypond).
   %% */ 
   fun {ToLilypond2 MyScore Args}
      Clauses
      %% NOTE: Args.clauses, not As.clauses is used below
      As = {Adjoin Args unit(clauses:Clauses)}
   in
      Clauses
      = {Append Args.clauses
	 %%
	 %% NOTE: these are the default Lily output clauses
	 %%
	 [
	  IsOutmostSeq#fun {$ X} {OutmostSeqToLily X As} end
	 
	  isSequential#fun {$ X} {SeqToLily X As} end

	  IsSingleStaffPolyphony#fun {$ X} {SingleStaffPolyphonyToLily X As} end
	 
	  IsLilyChord#SimToLilyChord

	  isSimultaneous#fun {$ X} {SimToLily X As} end
	 
	 %% enharmonic note output
	 %%
	 %% NOTE: adds dependency to Strasheela HS extension
	 fun {$ X}
	    {HS.score.isEnharmonicSpellingMixinForNote X}
	    andthen {HS.db.getPitchesPerOctave} == 12
	 end#local
		LilyNominals = unit(c d e f g a b)
		LilyAccidentals = unit(eses es "" is isis)
		LilyOctaves = octs(",,,," ",,," ",," "," "" "'" "''" "'''" "''''")
	     in
		{MakeNoteToLily2
		 %% create enharmonic Lily note
		 fun {$ N}
		    Nominal = LilyNominals.{N getCMajorDegree($)}
		    Accidental = LilyAccidentals.({N getCMajorAccidental($)} + 1)
		    Octave = LilyOctaves.({N getOctave($)} + 2)
		 in
		    Nominal#Accidental#Octave
		 end
		 %% no additional articulations etc for now
		 fun {$ N} nil end}
	     end
	 
	 isNote#{MakeNoteToLily
		 fun {$ Note}
		    {LilyMakeMicroPitch {Note getPitchParameter($)}} 
		 end}

	 
	 isPause#PauseToLily
	 
	   % Otherwise clause
	  fun {$ X} true end
	  #fun {$ X}
	      {GUtils.warnGUI "Score contains object for which no clause for Lilypond output was defined!"}
%	      {Browse warn#unsupportedClass(X ToLilypond2)}
	      ''
	   end]}
      
      {GUtils.cases MyScore Clauses}
   end
   
   /** %% ToLilypond transforms a score object into a Lilypond score virtual string.
   %% By default, Strasheela supports the following cases for Lilypond score output. Strasheela temporal containers are transformed into their Lilypond counterpart. A simultaneous container becomes "<< .. >>" and a sequential container becomes "{ ... }". Nevertheless, there are a few special cases supported by default.
   %% By default, a staff is implicitly created for a sequential container which is either at the top-level or contained in a top-level simultaneous container. In typical Strasheela score topology for Lilypond output, a simultaneous is the top-level container and its items are sequential containers corresponding to staffs. If top-level is a sequential, then there is only a single staff. You can define arbitrary other nestings, but in such cases you should explicitly specify which container corresponds to a staff using the lily info-tag (see below). Moreover, you can also explicitly create staff or staff groups which last for the duration of their container only with the lily info-tag. The implicit staff creation can be switched off entirely by setting the optional argument 'implicitStaffs' to false.
   %% A simultaneous container within a staff containing only notes with common start and end times result in a chord (notes on a single staff sharing a stem). Single staff polyphony is supported: multiple (nested) sequentials and simultaneous container representing chords which are contained in a simultaneous (and which corresponds to or is situated in a staff) are output as single staff polyphony. Note that the description of these special cases is slightly simplified in this explanation, see the clause test function sources in Output.oz, when exactly these clauses apply.
   %% Note and pause objects (rests) are notated as expected, including ties for complex durations. However, their duration must exceed the minimum duration value supported (a 64th), shorted durations (or shorter tired fractions) are ignored. Also, offset times of score objects are notated as rests in front of the objects (again, except its duration is less than the minimum duration value supported (offset time notation is not supported by default for a top-level simultaneous container). 
   %% Enharmonic notation is supported for enharmonic note objects (subclasses of HS.score.enharmonicSpellingMixinForNote such as HS.score.enharmonicNote). Tuplet output is supported via clauses conveniently created with the function MakeLilyTupletClauses (see there).
   %% 
   %% ToLilypond expects the following further arguments. The optional argument 'clauses' provides much control on how the Lilypond output is conducted. Internally, almost all functionality of ToLilypond is also defined by such clauses: further special cases (as described above) can be defined, or the default ones overwritten. 'clauses' expects a list of the form [Test1#ProcessingFun1 ...]. TestN and ProcessingFunN are both unary functions expecting a score object (an item instance such as notes or containers). If the Boolean function TestN is the first clause test which returns true for a score object in MyScore, then ProcessingFunN will create the Lilypond VS for this object. For example, the user may define a subclass of Score.note with an additional articulation attribute (e.g. values may be staccato, tenuto etc.) and the user then defines a clause which causes Lilypond to show the articulation by its common sign in the printed score.
   %% The argument 'wrapper' expects a list of two VSs with legal Lilypond code. These VSs are inserted at the beginning and the end respecitively of the Lilypond score. Note that the Lilypond version statement is hardwired -- you should not add a version statement to your header (there is a 'version' argument expecting the version number as a VS, use at own risk). 
   %% Arbitrary Lilypond code can be added to container and note objects via a tuple with the label 'lily' given to the info attribute of the score object. This tuple must only contain VSs which are legal Lilypond code. For containers, this lilypond code is always inserted in the Lilypond output before the container, for notes it is inserted after the note.
   %% The argument defaults are shown below. 
   
   unit(clauses:nil
	wrapper:["\\paper {}\n\n\\score{" %% empty paper def
		 "\n}"]
	implicitStaffs:true)

   %% */
   fun {ToLilypond MyScore Args}
      Default =  unit(clauses:nil
		      wrapper:["\\paper {}\n\n\\score{" %% empty paper def
			       "\n}"]
		      implicitStaffs:true
		      version:"2.10.0")
      As = {Adjoin Default Args}
   in
      if {Not {MyScore isDet($)}} then
	 {GUtils.warnGUI "Lilypond output may block -- score not fully determined!"}
% 	 {System.showInfo "Warning: Lilypond output may block -- score not fully determined!"}
      end
      {ListToVS ["%%% created by Strasheela at "#{GUtils.timeVString}
		 "\n\\version \""#As.version#"\"\n"
		 As.wrapper.1
		 {ToLilypond2 MyScore As}
		 As.wrapper.2.1]
       "\n"}
   end
   
   /** %% Transforms MyScore into a Lilypond score and writes it to a file. The default values for the optional arguments are shown below. See the documentation of ToLilypond for an explanation of additional arguments.
   
   unit(dir: {Init.getStrasheelaEnv defaultLilypondDir}
	file: "test" % !! file name without extention
       )
					  
   %% */
   proc {OutputLilypond MyScore Args}
      Default =  unit(dir: {Init.getStrasheelaEnv defaultLilypondDir}
		      file: "test" % !! file name without extention
		     )
      As = {Adjoin Default Args}
      Path = As.dir#As.file#".ly"
   in
      {WriteToFile {ToLilypond MyScore As} Path}
   end

   /** %% Calls Lilypond on a Lilypond file specified by Args. The defaults of Args are:
   unit(dir: {Init.getStrasheelaEnv defaultLilypondDir}
	file: test) % !! file name without extention
   %% */
   %%
   %% !! ?? Path part of some Args? e.g. default dir (see CallCsound)
   %% !! I could generalise this into CallApp -- move into GUtils
   proc {CallLilypond Args}
      DefaultSpec = unit(dir: {Init.getStrasheelaEnv defaultLilypondDir}
			 file: test % !! file name without extention
			 % 'convert-ly':{Init.getStrasheelaEnv 'convert-ly'}
			 lilypond:{Init.getStrasheelaEnv lilypond}
			 flags:{Init.getStrasheelaEnv defaultLilypondFlags})
      MySpec = {Adjoin DefaultSpec Args}
      %% MySpec.dir may be nil but Dir is not (full path given to file)
      MyPath = {{Path.make MySpec.dir} resolve(MySpec.file#".ly" $)}
      Dir = {Path.dirname MyPath}
      LyFile = {Path.basename MyPath}
   in
      {System.showInfo "> cd "#Dir}
      {OS.chDir Dir}
      % {Exec MySpec.'convert-ly' ["-e" LyFile]}
      {Exec MySpec.lilypond {Append  MySpec.flags [LyFile]}}
   end

   /** %% Calls a PDF viewer on a PDF file specified by Args. The name of the PDF file is given without extension. The PDF viewer application defaults to the value of the Strasheela environment variable pdfViewer. The defaults of Spec are:
   unit(dir: {Init.getStrasheelaEnv defaultLilypondDir}
	file: test
	pdfViewer: {Init.getStrasheelaEnv pdfViewer}
	extension:".pdf")
   %% */
   %% !! I could generalise this into CallApp -- move into GUtils
   proc {ViewPDF Args}
      DefaultSpec = unit(dir: {Init.getStrasheelaEnv defaultLilypondDir}
			 file: test % !! file name without extention
			 pdfViewer: {Init.getStrasheelaEnv pdfViewer}
			 extension:".pdf"
			)
      MySpec = {Adjoin DefaultSpec Args}
      Path = MySpec.dir#MySpec.file#MySpec.extension
   in
      {ExecNonQuitting MySpec.pdfViewer [Path]}
   end

   /** %% Outputs a Lilypond file for MyScore, calls Lilypond to process it, and calls the PDF viewer with the result. See ToLilypond, OutputLilypond, CallLilypond, and ViewPDF for details on Args.
   %% */ 
   %% !! ?? this does not necessarily work for partly undetermined score
   proc {RenderAndShowLilypond MyScore Args}
      DefaultSpec = unit
      MySpec = {Adjoin DefaultSpec Args}
   in
      %% !! unefficient: transformation of Specs is done several times
      {OutputLilypond MyScore MySpec}
      {CallLilypond  MySpec}
      {ViewPDF MySpec}
   end

   /** %% Outputs a Lilypond file for MyScore and calls Lilypond to process it. See ToLilypond, OutputLilypond and CallLilypond for details on Spec.
   %% */ 
   proc {RenderLilypond MyScore Args}
      DefaultSpec = unit
      MySpec = {Adjoin DefaultSpec Args}
   in
      %% !! unefficient: transformation of Specs is done several times
      {OutputLilypond MyScore MySpec}
      {CallLilypond  MySpec}
      % {ViewPDF MySpec}
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% SuperCollider output related stuff
%%%

   /** %% [aux means for MakeSCScore] Outputs a unary function which transforms a SDL event into a SC event (a VS). PlayerOut is a unary function with the event a argument which returns a SC player call (a VS). The TimeParameter units must be determined.
   %% */
   fun {MakeSCEventOutFn PlayerOut}
      fun {$ X}
	 Player = {PlayerOut X}
	 Dur = {X getDurationInBeats($)}
	 Offset = {X getOffsetTimeInBeats($)}
      in
	 "SEvent("#Player#", "#Dur#", "#Offset#")"
      end
   end
   /** %% Generate a SuperCollider score in hierarchic score format (a VS). SCEventOut is a unary function transforming a single SDL event into a SC event (a VS). The TimeParameter units must be determined.
   %% */
   fun {MakeSCScore Score SCEventOut MkContainerOut FurtherClauses}
      {MakeHierarchicVSScore Score
       SCEventOut {MkContainerOut "SSim"} {MkContainerOut "SSeq"}
       FurtherClauses}
   end
   proc {OutputSCScore Score SCEventOut Spec}
      DefaultSpec =
      unit(dir: {Init.getStrasheelaEnv defaultSuperColliderDir}
	   file: test % !! file name without extension
	   extension:".sc"
	   %% Resulting fun transforms container X in SC VS token of
	   %% form [BeginVS Delimiter EndVS]. Arg OutType is VS of
	   %% container type.
	   mkContainerOut:fun {$ OutType}
			     fun {$ X}
				Start = {X getStartTimeInBeats($)}
				Offset = {X getOffsetTimeInBeats($)}
			     in
				%% !! tmp
				{Browse test#OutputSCScore}
				[OutType#"(["
				 ",\n"
				 "], "#Start#", "#Offset#")"]
			     end
			  end
	   furtherClauses:nil
	   %% postProcess transforms final VS score 
	   postProcess:fun {$ ScoreVS}
			  "(\nTempo.bpm = "
			  #{Init.getTempo}#";\nx="#ScoreVS
			  #";\nx.prepareForPlay;\n)\n\nx.spawn;" 
		       end)
      MySpec = {Adjoin DefaultSpec Spec}
      Path = MySpec.dir#MySpec.file#MySpec.extension
   in
      {WriteToFile
       {MySpec.postProcess
	{MakeSCScore Score SCEventOut MySpec.mkContainerOut
	 MySpec.furtherClauses}}
       Path}
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% OSC related stuff
%%%

   /** %%
   %% NB: the network address must be set by setting the environment var REMOTE_ADDR (defaults to '127.0.0.1').
   %% */
   proc {SendOsc Host Port OSCcmd}
      {Exec {Init.getStrasheelaEnv sendOSC} ["-h" Host Port OSCcmd]}
   end
   /** [tmp restricted def?] */
   proc {SendSCserver OSCcmd}
      Host = "127.0.0.1"
      Port = 57110
   in
      {SendOsc Host Port OSCcmd}
   end
   /** [tmp restricted def?] */
   proc {SendSClang OSCcmd}
      Host = "127.0.0.1"
      Port = 57120 
   in
      {SendOsc Host Port OSCcmd}
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Lisp output related stuff
%%%
   
   /** % Recursively transform X into virtual string representing a Lisp list (a dotted list). X is a (possibly nested) list of virtual strings or a virtual string.
   %% */
   %% !! Todo: X is list or record of VS: transform non-numerical record features into keywords
   fun {ToDottedList X}
      case X
      of nil then "nil"
      [] H|T then "("#{ToDottedList H}#" . "#{ToDottedList T}#")"
      else X
      end
   end
   
   /** % Outputs virtual string with round paranthesis wrapped around X. X is either a virtual string or an Oz list of virtual strings
   %% */
   fun {LispList X}
      if X==nil
      then nil
      elseif {IsList X}
      then "("#{ListToVS X " "}#")"
      else "("#X#")"
      end
   end
   /** % Outputs a virtual string denoting a Lisp keyword, i.e puts a colon before X. X is a virtual string.
   %% */
   fun {LispKeyword X}
      ":"#X
   end  

   /** %% This functions transforms a 'literal' Oz value (i.e. a value with a textual representation) into a corresponding literal Lisp value. It transforms an Oz record or list (possibly nested) into a virtual strings representing a Lisp keyword list. Each Oz record feature is transformed into a Lisp keyword (i.e. there is a colon in front of it) and the Oz value into a the corresponding Lisp value. Any record label is omitted (except the whole record is a plain Oz atom). In case a feature is an integer the keyword is omitted.
   %% !! NB: Currently, a value must be either (i) a literal which can be used directly in a VS and doesn't need to be further translated into a Lisp value (e.g. an atom, number, or string), (ii) an Oz list of supported values, or (iii) a record of supported values. 
   %% 
   %% A record feature can only be an integer or a symbol
   %%
   %% NB: The list is output without any line breaks. Use the pprint Lisp function for a more human-readable format.
   %% NB: Oz strings are lists of integers between 0 and 255, i.e. it can not be distinguished from a plain list of integers (e.g. denoting an all-interval series). Therefore, strings are not transformed into Lisp syntax!
   %% NB: Oz atoms can contain whitespace list 'Hi there' which result into two Lisp values!
   %% */
   fun {RecordToLispKeywordList X}
      %% an atom is also a record, but handled special here
      if {IsAtom X}		
      then X
	 %% a list is also a record, but handled special here
      elseif {IsList X}
      then {LispList {Map X RecordToLispKeywordList}}
      elseif {IsRecord X}
      then {LispList
	    {Map {Record.toListInd X}
	     fun {$ Feat#Val}
% 		ValVS = if {IsList Val}
% 			then {LispList {Map Val RecordToLispKeywordList}}
% 			elseif {IsRecord Val}
% 			then {RecordToLispKeywordList Val}
% 			else Val
% 			end
		ValVS = {RecordToLispKeywordList Val}
	     in
		if {IsInt Feat}
		then ValVS
%	   then ValVS#"\n"
		else {LispKeyword Feat}#" "#ValVS
		end
	     end}}
	 % Syntax transformation for negative numbers and exponential notation already buildin in Oz.
      elseif {IsNumber X}
      then X
      else
	 {Exception.raiseError
	  kernel(type
		 'Out.recordToLispKeywordList'
		 [X _]		% args
		 'atom, list, record or number' % type
		 1 % arg position
		 "Transformation only defined for an atom, list, record or a number."
		)}
	 unit % never returned
      end
   end
   
   /** %% Returns a lisp keyword list (a VS). X is a Strasheela score object (e.g. a note) and Spec is a record of the form unit(keyword1: accessor1 ..). The returned keyword list contains the record features as keywords and at these keywords the values of returned by the accessor (a unary function or method expecting X), i.e. ToLispKeywordList returns a VS of the form '(:keyword1'#{accessor1 X}# .. #')'
   %% */
   fun {ToLispKeywordList X Spec}
      {RecordToLispKeywordList
       {Record.map Spec
	fun {$ Accessor}
	   {{GUtils.toFun Accessor} X} 
	end}}
   end

   
   local
      %% NB: Lisp2Oz: nil can also be empty list..
      fun {Bool2LispBool X}
	 if X
	 then 'T'
	 else nil
	 end
      end
      %%
      fun {Atom2LispSymbol X}	
	 if {Some {AtomToString X} Char.isSpace}
	 then '|'#X#'|'
	 elseif  X==nil then
	    "nil"
	 else
	    X
	 end
      end
      fun {String2LispString X}
	 "\""#X#"\"" 
      end
      %% only works for Lisp implementations implementing character code ISO 8859-1, cf. oz/doc/base/char.html#section.text.characters
      fun {Char2LispChar X}
	 "(code-char \""#X#"\")"
      end
      fun {List2LispList X Args}
	 %% X==nil should never occur. List tails are 'filtered out'
	 %% by Map below and plain empty lists are processed by
	 %% Atom2LispSymbol instead (recursive call to OzToLisp..)
	 if X==nil		
	 then nil
	 else "("#{ListToVS {Map X fun {$ X} {OzToLisp X Args} end} " "}#")"
	 end
      end
      fun {Record2Lisp X Args}
	 "("#{ListToVS
	      %% all integer features must come first (Record.toListInd is defined that way).
	      {Append {Map {Record.toListInd X}
		       fun {$ Feat#Val}
			  ValVS = {OzToLisp Val Args}
		       in
			  if {IsInt Feat}
			  then ValVS
			  else {LispKeyword Feat}#" "#ValVS
			  end
		       end}	      
	       %% Record label is stored in last keyword/value pair in returned list. It is not suitable to put :label MyLabel at the beginning of the list: after the first keyword there should be only keywork value pairs, but Record2Lisp omits feature-keywords for number-keywords (e.g. for a tuple there are no feature-keywords at all). 
	       %% Disadvantage for performance: checking for the label requires traversing the whole list
	       %% NB: in case the list contains more than one :label, the first such pair determines the property. 
	       [{LispKeyword 'record-label'} {OzToLisp {Label X} Args}]}
	      " "}#")"
      end
   in
      /** %% OzToLisp transforms a literal Oz value (i.e. a value with a textual representation) into a corresponding literal Lisp value expressed by a VS. 
      %% Supported Oz values are integers, floats, atoms, records/tuples, lists and virtual strings. These values can be freely nested. In principle, characters and strings are supported as well, see below. Not supported are Oz values without a textual representation (e.g. names, procedures, and chunks).
      %% Oz characters are equivalent to integers and Oz strings are equivalent to lists of integers. Therefore, the users must decide for either integer or character/string transformation. For this purpose, Arg expects the optional arguments charTransform and stringTransform (both default to false, i.e. characters and strings are per default transformed into Lisp integers / integers lists).
      %% The following list details how values are transformed:  
      %%
      %% boolean -> boolean: true -> T, false -> nil [NB: Lisp2Oz: nil can also be empty list..]
      %% integer -> integer: 1 -> 1 [only decimal notation supported, NB: tilde ~ as unary minus for int and float supported]
      %% float -> float: 1.0 -> 1.0  [exponential notation supported]
      %% atom -> symbol: abc -> abc 
      %% record -> keyword list: unit(a:1 b:2) -> (:a 1 :b 2 :record-label unit)
      %% tuple -> keyword list: test(a b) -> (a b :record-label test)
      %% list -> list: [a b c] -> (a b c)
      %% VS -> unaltered VS: "("#'some Test'#")" -> (some Test)
      %%
      %% character -> character: &a -> (code-char 97) equivalent to 97 -> #\a
      %% string -> string: "Hi there" -> "Hi there"
      %%
      %% NB: Virtual strings are passed unaltered: the user is responsible that any (composite) VS results in a valid Lisp value.
      %% NB: the keyword-value pair :record-label <label> is always the last two elements in a record/tuple list.
      %% 
      %% NB: OzToLisp is very similar to RecordToLispKeywordList. The main difference is that OzToLisp can handle more cases truely in Lisp syntax (e.g. outputs something as 'Hi there' as |Hi there|). Moreover, the values are transformed in such a way that no information is lost and backtransformation (LispToOz) would be possible as well (e.g. the label of a record is preserved and the presence of the label marks a difference to a plain list).
      %%
      %% TODO:
      %% 
      %% * Lisp does not distinguish between cases, but for back-transformation of symbols etc in CamelCase I should possibly use symbols like |CamelCase|.
      %% */
      %%
      %% * shall I add support for the following values? 
      %%
      %% ?? FD int
      %% ?? FS
      fun {OzToLisp X Args}
	 Default = unit(charTransform:false
			stringTransform:false)
	 As = {Adjoin Default Args}
      in	 
	 if {IsBool X} then {Bool2LispBool X}    
	 elseif {IsUnit X} then 'unit'
	 elseif {IsAtom X} then {Atom2LispSymbol X}
	 elseif As.charTransform andthen {IsChar X} 
	 then {Char2LispChar X}	    
	    %% Syntax transformation for negative numbers and exponential notation already buildin in Oz.
	 elseif {IsNumber X} then X
	    %% unit is no VS 
	 elseif As.stringTransform andthen {IsString X} 
	 then {String2LispString X}
	 elseif {IsList X} then {List2LispList X Args}
	    %% 
	 elseif {IsVirtualString X} then X  
	 elseif {IsRecord X} then {Record2Lisp X Args}
	 else
	    {Exception.raiseError
	     kernel(type
		    'Out.ozToLisp'
		    [X Args _]		% args
		    'bool, unit, atom, number, list, VS, nor record' % type
		    1 % arg position
		    "Transformation only defined for an boolean, unit, atom, number (including chars), list (including strings), VS, nor a record."
		   )}
	    unit % never returned
	 end
      end
   end

   
   %%
   %% CLM output related stuff
   %%

   %% FIXME: [unfinished definition -- not general enough]
   %%
   %% generalisation: argument with list of matching clm::p argument
   %% keywords and SDL note accessors
%    local
%       Defaults = ["clm::p"#getStartTime
% 		  ":duration"#getDuration
% 		  ":keynum"#getPitch
% 		  ":strike-velocity"#getAmplitude]
%    in
   fun {Note2ClmP Note}
      {LispList ["clm::p" {Note getStartTime($)}
		 ":duration" {Note getDuration($)}
		 ":keynum" {Note getPitch($)}
		 ":strike-velocity" {Note getAmplitude($)}]}
   end
%   end
   /** %% [a quick and probably temp. hack]
   %% */
   fun {MakeClmScoreFn WithSoundArgs} 
      fun {$ _ EventVSs}
	 "(in-package :clm) \n\n"#{LispList ["with-sound"
					     {LispList WithSoundArgs} "\n"
					     {ListToLines EventVSs}
					     "\n"]}
      end
   end

   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% PWGL output
%%%

   /** %% Exports TheScore (a Strasheela score) into a non-mensural ENP score (a VS). The ENP format is rather fixed, whereas the information contained in the Strasheela score format is highly user-customisable. Therefore, the export-process is also highly user-customisable. 
   %% An ENP score has a fixed topology. The non-mensural ENP has the following nesting: <code>score(part(voice(chord(note+)+)+)+)</code>. See the PWGL documentation for details. 
   %% Strasheela, on the other hand, supports various topologies. However, ToNonmensuralENP does not automatically perform a score topology transformation into the ENP topology. Instead, ToNonmensuralENP expects a number of optional accessor functions as arguments (e.g. getScore, getParts, getVoices) which allow for a user-defined topology transformation. These functions expect a (subpart of the) score and return the contained objects according to the ENP topology. For instance, the function getVoices expects a Strasheela object corresponding to an ENP part and returns a list of Strasheela object corresponding to ENP voices. The default values for these accessor functions require that the topology of TheScore fully corresponds with the ENP score topology. That is, for the default accessor functions, TheScore must have the following topology: <code>sim(sim(seq(sim(note+)+)+)+)</code>. The set of all supported accessor functions (together with their default values) is given below.
   %% Any ENP attribute of a score object can be specified by the user. For this purpose, ToNonmensuralENP expects a number of optional attribute accessor functions (e.g. getScoreKeywords, getPartKeywords). These functions expect a Strasheela object corresponding to an ENP part and returns an Oz record whose features are the ENP keywords for this objects and the feature values are the values for these ENP keywords. See the default of getNoteKeywords for an example.
   %% In addition, enp syntax can be given directly to score objects via an info tag/record with the label 'enp' where the keywords are the record features with their associated values (e.g., enp(expression: [accent])). In case a keyword is defined both with an acessor function (e.g., getVoiceKeywords) and directly as an enp info tag, then the info tag is taken instead. 
   %%
   %% Default arguments: 
   unit(getScore:fun {$ X} X end
	getParts:fun {$ MyScore} {MyScore getItems($)} end
	getVoices:fun {$ MyPart} {MyPart getItems($)} end
	getChords:fun {$ MyVoice} {MyVoice getItems($)} end
	getNotes:fun {$ MyChord} {MyChord getItems($)} end
	getScoreKeywords:fun {$ MyScore}
			    unit % put further ENP score keywords here
			 end
	getPartKeywords:fun {$ MyPart}
			   unit % put further ENP part keywords here
			end
	getVoiceKeywords:fun {$ MyVoice}
			    unit % put further ENP voice keywords here
			 end
	getChordKeywords:fun {$ MyChord}
			    unit % put further ENP chord keywords here
			 end
	getNoteKeywords:fun {$ MyNote}
			   %% put further ENP note keywords here
			   unit('offset-time': {MyNote getOffsetTimeInSeconds($)})
			end)
   %%
   %% Note: this function also works for the format expected by the simple format of the PWGL library KSQuant. You need to set the argument toKSQuant to true for this purpose.
   %% 
   %% */
   %%
   %% NB: output unit of measurement of chord start times and note offset times hard-wired to seconds
   fun {ToNonmensuralENP TheScore Args}
      Defaults
      = unit(getScore:fun {$ X} X end
	     getParts:fun {$ MyScore} {MyScore getItems($)} end
	     getVoices:fun {$ MyPart} {MyPart getItems($)} end
	     getChords:fun {$ MyVoice} {MyVoice getItems($)} end
	     getNotes:fun {$ MyChord} {MyChord getItems($)} end
	     getScoreKeywords:fun {$ MyScore}
				 %% put further ENP score keywords here
				 unit
			      end
	     getPartKeywords:fun {$ MyPart}
				%% put further ENP part keywords here
				unit
			     end
	     getVoiceKeywords:fun {$ MyVoice}
				 %% put further ENP voice keywords here
				 unit
			      end
	     getChordKeywords:fun {$ MyChord}
				 %% put further ENP chord keywords here
				 unit
			      end
	     getNoteKeywords:fun {$ MyNote}
				%% put further ENP note keywords here
				unit('offset-time': {MyNote getOffsetTimeInSeconds($)})
			     end
	     toKSQuant:false)
      As = {Adjoin Defaults Args}
      fun {Object2Record MyObject
	   GetSubObjects MakeSubObjectRecord GetKeywords}
	 {Adjoin {Adjoin {GetKeywords MyObject}
		  {MyObject getInfoRecord($ 'enp')}}
	  {List.toTuple unit {Map {GetSubObjects MyObject}
			      MakeSubObjectRecord}}}
      end
      fun {MakeScoreRecord MyScore}
	 {Object2Record MyScore
	  As.getParts MakePartRecord As.getScoreKeywords}
      end
      fun {MakePartRecord MyPart}
	 {Object2Record MyPart
	  As.getVoices MakeVoiceRecord As.getPartKeywords}
      end
      fun {MakeVoiceRecord MyVoice}
	 if As.toKSQuant
	 then
	    %% for KSQuant we must add an explicit end time (as last start time)
	    LastEndTime = {{List.last {As.getChords MyVoice}} getEndTimeInSeconds($)}
	    VoiceRecord = {Object2Record MyVoice
			   As.getChords MakeChordRecord As.getVoiceKeywords}
	    LastPos = {Width VoiceRecord} + 1
	 in
	    {Adjoin VoiceRecord
	     unit(LastPos: unit(LastEndTime))}
	 else 
	    {Object2Record MyVoice
	     As.getChords MakeChordRecord As.getVoiceKeywords}
	 end
      end
      fun {MakeChordRecord MyChord}
	 {Adjoin
	  {As.getChordKeywords MyChord}
	  unit(1:{MyChord getStartTimeInSeconds($)}
	       notes:{Map {As.getNotes MyChord}
		      fun {$ MyNote}
			 {Adjoin {As.getNoteKeywords MyNote}
			  unit(1:{MyNote getPitchInMidi($)})}
		      end})}
      end
   in
      {RecordToLispKeywordList {MakeScoreRecord TheScore}}
   end
   
   /** %%  Exports MyScore (a Strasheela score) into a text file with a non-mensural ENP score. The file path is specified with the arguments file, extension and dir. For further arguments see the ToNonmensuralENP documentation.
   %% */
   proc {OutputNonmensuralENP MyScore Args}
      Defaults = unit(file:"test"
		      extension:".enp"
		      dir:{Init.getStrasheelaEnv defaultENPDir})
      As = {Adjoin Defaults Args}
   in
      {WriteToFile
       {ToNonmensuralENP MyScore As}
       As.dir#As.file#As.extension}
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Fomus
%%%

   /** %% Exports MyScore into Fomus format (as a VS). The Fomus format is rather fixed, whereas the information contained in the Strasheela score format is highly user-customisable. Therefore, the export-process is also highly user-customisable.
   %% A Fomus score has a fixed topology: <code>score(part(event+)+)</code> (see the Fomus documentation at http://common-lisp.net/project/fomus/doc/). Strasheela, on the other hand, supports various topologies. However, ToFomus does not automatically perform a score topology transformation into the Fomus topology. Instead, ToFomus expects two optional accessor functions as arguments which allow for a user-defined topology transformation: getParts and getEvents. The function given to the argument getParts expects MyScore and returns a list of values corresponding to the Fomus parts. The function given to the argument getEvents expects a part and returns a list of values corresponding to the Fomus events. The default values for these accessor functions require that the topology of MyScore corresponds with the Fomus score topology. That is, for the default accessor functions, MyScore must have the following topology: <code>sim(seq(&lt;arbitrarily nested note&gt;+)+)</code>.
   %% Any Fomus setting for the score, a part, or event can be specified by the user as well. For this purpose, ToFomus expects three optional attribute accessor functions: getScoreKeywords, getPartKeywords, and getEventKeywords. These functions expect a Strasheela object corresponding to a Fomus score/part/event and return an Oz record whose features are the Fomus keywords for this objects and the feature values are the values for these keywords. For example, getEventKeywords may be set to the following function.
   fun {$ MyEvent}
      unit(off:{MyEvent getStartTimeInBeats($)}
	   dur:{MyEvent getDurationInBeats($)}
	   note:{MyEvent getPitchInMidi($)})
   end
   %%
   %% Please inspect the implementation code to see the default values for the arguments. 
   %% */
   %%
   %% !! default args file, extension, and dir are given explicitly thrice in ToFomus, OutputFomus, and CallFomus
   %%
   %% The Oz-created .fms file gets overwritten by fomus, which is kind of fun :) -
   %%
   %%   it also enables you -- for the time being -- to edit the richer settings by hand...
   fun {ToFomus MyScore Args}
      Defaults
      = unit(getParts:fun {$ MyScore} {MyScore getItems($)} end
	     getEvents:fun {$ MyPart} {MyPart collect($ test: isNote)} end
	     /** %% Outputs a record where the features are later Fomus keywords and the values are the corresponding Fomus values for these keywords.
	     %% */
	     getScoreKeywords:fun {$ MyScore}
				 %% :midi will generate an error message, if fomus has not been installed with cm
				 %% however, this will not hurt other processing
				 unit(output: "((:lilypond :view t) (:midi))"
				      %% filename keyword now hard-wired (see below) to keep interface for all three get*Keywords functions consistent.
				      quartertones: "t"
				      %% midi playback will be program 1 - piano
				      instruments: "#.(list (fm:make-instr :treble-bass :clefs '(:treble :bass) :midiprgch-ex 1))")
			      end
	     getPartKeywords:fun {$ MyPart}
				unit(instr:":treble-bass")
			     end
	     getEventKeywords:fun {$ MyEvent}
				 unit(off:{MyEvent getStartTimeInBeats($)}
				      dur:{MyEvent getDurationInBeats($)}
				      note:{MyEvent getPitchInMidi($)})
			      end
	     file:"test"
	     extension:".fms"
	     dir:{Init.getStrasheelaEnv defaultFomusDir})
      As = {Adjoin Defaults Args}
      Path = As.dir#As.file#As.extension
      /** %% [Aux] Transforms a record into a VS, where the record features are lisp keywords and the record values remain as is.
      %% */
      fun {Record2KeyValPairs X}
	 {ListToVS {Map {Record.toListInd X}
		    fun {$ Feat#Val} {LispKeyword Feat}#" "#Val end}
	  " "}
      end
   in
      %% score creation
      {ListToLines
       "init "#{Record2KeyValPairs {Adjoin {As.getScoreKeywords MyScore}
				    unit(filename: "\""#Path#"\"")}}|
       {List.mapInd {As.getParts MyScore}
	fun {$ PartId MyPart}
	   %% part creation
	   {ListToLines
	    {ListToVS ["part" PartId {Record2KeyValPairs {As.getPartKeywords MyPart}}]
	     " "}|
	    {Map {As.getEvents MyPart}
	     fun {$ MyEvent}
		%% event creation
		{ListToVS ["note" PartId {Record2KeyValPairs {As.getEventKeywords MyEvent}}]
		 " "}
	     end}}
	end}}
   end
   
   /** %% Outputs a fomus file with optional Args. The defaults are
   unit(file:"test"
	extension:".fms"
	dir:{Init.getStrasheelaEnv defaultFomusDir}
	...)
   %% See the doc of ToFomus for further optional arguments.
   %% */
   %% !! default args file, extension, and dir are given explicitly thrice in ToFomus, OutputFomus, and CallFomus
   proc {OutputFomus MyScore Args}      
      Defaults = unit(file:"test"
		      extension:".fms"
		      dir:{Init.getStrasheelaEnv defaultFomusDir})
      As = {Adjoin Defaults Args}
      Path = As.dir#As.file#As.extension
   in
      {WriteToFile {ToFomus MyScore As} Path}
   end
   
   /** %% Creates a fomus file from MyScore and calls the fomus command-line application on this file. The argument flags expects a list of fomus flags (default is nil). See the doc of OutputFomus for further arguments.
   %% */
   %% !! default args file, extension, and dir are given explicitly thrice in ToFomus, OutputFomus, and CallFomus
   proc {RenderFomus MyScore Args}   
      Defaults = unit(file:"test"
		      extension:".fms"
		      dir:{Init.getStrasheelaEnv defaultFomusDir}
		      flags:nil)
      As = {Adjoin Defaults Args}
      Path = As.dir#As.file#As.extension
      App = {Init.getStrasheelaEnv fomus}
   in
      {OutputFomus MyScore Args}
      {Exec App {Append As.flags [Path]}}
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Common Music output
%%%

   /** %% Returns CM note VS. Spec is a record of the form class(keywordSymbol1: noteAccessor1 ..). class is an atom, each keywordSymbol are an atom and each noteAccessor is funtions or method.
   %% */
   %% !! code doublication with ToLispKeywordList (aber das kann ich nicht verwenden: habe fuer liste in VS kein cons..)
   fun {MakeCMEvent Note Spec}
      {RecordToLispKeywordList
       {Adjoin
	%% put 'new <class>' in front
	unit(new {Label Spec})
	%% replace each Spec accessor by {Acessor Note} 
	{Record.map Spec
	 fun {$ Accessor}
	    {{GUtils.toFun Accessor} Note} 
	 end}}}
   end
   local
      fun {EventOut MyNote}
	 {MakeCMEvent MyNote
	  midi(time:getStartTimeInSeconds
	       duration:getDurationInSeconds
	       keynum:getPitchInMidi
	       amplitude:getAmplitudeInNormalized)} 
      end
      fun {ContainerOut X}
	 BeginVS = "(new seq subobjects \n(list\n"
	 Delimiter = "\n"
	 EndVS = "\n))"
      in
	 [BeginVS Delimiter EndVS]
      end
   in
      /** %% Transforms Score to Common Music score (VS). Common Music in turn can be used to output to various formats (e.g. MIDI, SuperCollider, Csound, music notation formats via FOMUS) or used to edit the score (e.g. with the CM Plotter). Optional Args features are containerOut (unary function, expecting a container and outputting a list of VS in the form [BeginVS Delimiter EndVS]), eventOut (unary function, expecting an event and outputting a VS), and furtherClauses (list of declarations, see MakeHierarchicVSScore for further details). The default eventOut outputs a CM 'midi' (i.e. events must be notes), the default containerOut outputs a CM 'seq' with the contained items as 'subobjects'.
      %% */
      fun {MakeCMScore Score Args}
	 Defaults = unit(containerOut:ContainerOut	% out for sim and seq
			 eventOut:EventOut
			 furtherClauses:nil)
	 As = {Adjoin Defaults Args}
      in
	 {MakeHierarchicVSScore Score As.eventOut
	  As.containerOut		
	  As.containerOut		
	  As.furtherClauses}
      end
   end

   /** %% Outputs Score into a CM score file. Optional Args features are dir (a VS, defaults to default CM dir in Strasheela env), file (VS, defaults to test), extension (VS, defaults to '.cm'), wrapper (a list of two VS as [WrapperHeader WrapperFooter]) and ioExtension (a VS). The Args feature wrapper specifies a Lisp expression surrounding the CM score in the output, it defaults to a var binding and an 'events' call for output with the same file name as specified by Args or Defaults and an extension as specified by ioExtension.
   %% Additionally, Args features are the Args supported by MakeCMScore (see there).
   %% */
   proc {OutputCMScore Score Args}
      Defaults = unit(dir:{Init.getStrasheelaEnv defaultCommonMusicDir}
		      file:test
		      extension:".cm"
		      ioExtension:".midi"
		      %% io out: file name in Args or Defaults
		      %% and extension Defaults.ioExtension
		      wrapper:["(in-package :cm)\n\n(define my-score \n" %% here goes the score
			       "\n)\n\n"#
			       "(events my-score "#
			       "\n(io \""
			       #{Init.getStrasheelaEnv defaultCommonMusicDir}
			       #{CondSelect Args file Defaults.file}
			       #{CondSelect Args ioExtension
				 Defaults.ioExtension}
			       #"\"))\n"])
      As = {Adjoin Defaults Args}
      [WrapperHeader WrapperFooter] = As.wrapper
      Path = As.dir#As.file#As.extension
   in
      {WriteToFile WrapperHeader#{MakeCMScore Score As}#WrapperFooter
       Path}
   end
   
%    /* %% for MacOS
%    '(defun macosx-midi (file) ; &rest args\n
%   ;; set file creator and type \n
%   (ccl:set-mac-file-creator file :TVOD)\n
%   (ccl:set-mac-file-type file "Midi"))\n
% (Set-midi-output-hook! #\'macosx-midi)n\n\'
% */

%    %% !!??
%    fun {RenderCMScore Score}


% %       ;; initialise MIDI output such that MacOS X recognises the output as
% % ;; MIDI file. [don't worry, you do not need to understand this ;-) ]
% % ;; BTW: I configured Common Music on the iMacs such that this is
% % ;; evaluated at init time.
% % (defun macosx-midi (file) ; &rest args
% %   ;; set file creator and type 
% %   (ccl:set-mac-file-creator file :TVOD)
% %   (ccl:set-mac-file-type file "Midi"))
% % (Set-midi-output-hook! #'macosx-midi)

%    end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Sound playback related stuff
%%%
   
   local
      proc {Start X File CmdlineSndPlayer}
	 if {Value.isFree {Cell.access X}}
	 then
	    {Cell.access X} =
	    {New Open.pipe init(cmd:CmdlineSndPlayer args:[File])}
	 end
      end
      proc {Stop X}
	 if {Value.isDet {Cell.access X}}
	 then
	    {{Cell.access X} close}
	    {{Cell.assign X} _}	% !! suspends, why ??
	 end
      end
      
      /** % Start sound file sound playback and opens control window that allows stopping and restarting payback. 
      %%*/
      %%
      %% !! Add test whether file exists and do warning in case
      %%
      %% !! Hitting Play to replay (i.e. before hitting stop first)
      %% has no effect. {Stop Sound} suspends, I don't know
      %% why. Otherwise I could just always stop sound playback first
      proc {SoundPlayerWithGui CmdlineSndPlayer File Spec}
	 Sound = {Cell.new _}
	 W={New Tk.toplevel tkInit(title:Spec.title)}
	 B1={New Tk.button
	     tkInit(parent: W text: "Play" 
		    action: proc {$}
			       %{Stop Sound} % suspends
			       {Start Sound File CmdlineSndPlayer}
			    end)}
	 B2={New Tk.button
	     tkInit(parent: W text: "Stop" 
		    action: proc {$} {Stop Sound} end)}
	 B3={New Tk.button
	     tkInit(parent: W text: "Quit" 
		    action: proc {$}
			       thread {Stop Sound} end
			       {W tkClose}
			    end)}
      in
	 {Tk.send pack(B1 B2 B3 fill:x padx:4 pady:4)}
	 {Start Sound File CmdlineSndPlayer}
      end
   in
      /** %% If a sndPlayer is specified, Strasheela assumes it has an own GUI and just calls it with the sound file. If a cmdlineSndPlayer is specified, Strasheela provides a minimal GUI for the cmdline soundPlayer. Spec is a record with optional arguments, the defaults are:
      unit(file:"test" % without extension
	   extension:".aiff"
	   soundDir:{Init.getStrasheelaEnv defaultSoundDir}
	   title:"Play Sound")
      %% */
      proc {PlaySound Spec}
	 Defaults = unit(file:"test"
			 extension:".aiff"
			 soundDir:{Init.getStrasheelaEnv defaultSoundDir}
			 title:"Play Sound")
	 MySpecs = {Adjoin Defaults Spec}
	 SoundPlayer = {Init.getStrasheelaEnv sndPlayer}
	 CmdlineSndPlayer = {Init.getStrasheelaEnv cmdlineSndPlayer}
	 File = MySpecs.soundDir#MySpecs.file#MySpecs.extension
      in
	 if SoundPlayer \= nil
	 then {Exec SoundPlayer [File]}
	    %{New Open.pipe init(cmd:SoundPlayer args:[File])}
	 elseif CmdlineSndPlayer \= nil
	 then {SoundPlayerWithGui CmdlineSndPlayer File MySpecs}
	 else
	    {Exception.raiseError
	     strasheela(initError 'No sound player specified. Please set either the environment variable sndPlayer or cmdlineSndPlayer.')}
	 end
      end
   end


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Shell interface
%%%
%%%
%%% !! consider the new Shell of the standard library als an alternative: http://www.mozart-oz.org/documentation/mozart-stdlib/os/shell.html
%%%

      
   /** %% Execute shell Cmd with Args, show standard out/error in the emulator and exit.
   %% */
   proc {Exec Cmd Args}
      Pipe = {New Open.pipe init(cmd:Cmd args:Args)}
   in
      {System.showInfo "> "#Cmd#" "#{ListToVS Args " "}}
      {System.showInfo {Pipe read(list:$ size:all)}}
      {Pipe flush}
      {Pipe close}
   end

   /** %% Execute shell Cmd with Args, show standard out/error in the emulator and exit. This is very similar to Exec, however the application Cmd does not automatically quit after finishing.
   %% */
   proc {ExecNonQuitting Cmd Args}
      Pipe = {New Open.pipe init(cmd:Cmd args:Args)}
   in
      {System.showInfo "> "#Cmd#" "#{ListToVS Args " "}}
      {System.showInfo {Pipe read(list:$ size:all)}}
      %% block closing (quitting application closes Pipe as well)
      {Pipe flush(how: [send])}
      {Pipe close}
   end

   /** %% Execute shell Cmd with Args, bind standard out/error to Output and exit.
   %% */
   proc {ExecWithOutput Cmd Args ?Output}
      Pipe = {New Open.pipe init(cmd:Cmd args:Args)}
   in
      {System.showInfo "> "#Cmd#" "#{ListToVS Args " "}}
      Output = {Pipe read(list:$ size:all)}
      {Pipe flush}
      {Pipe close}
   end
 
   /** %% Provides an interface to interactive commandline programs like a shell or an interpreter. Start interactive program with the method init (see below), close it with the method close. The Shell object features cmd and args bind the respective init arguments.
   %%
   %% More specialised classes (e.g. an interface to Common Lisp) may be obtained by subclasses..
   %% */
   %% Transformation of def by Christian Schulte in "Open Programming in Mozart"
   class Shell from Open.pipe Open.text
      feat cmd args
		  /** %% Start interactive program Cmd (VS) with Args (list of VSs). The default is the shell "sh" with args ["-s"] for reading from standard input. See the test file for examples for other interactive commands (e.g., the interactive ruby shell or a Common Lisp compiler). 
		  %% */
      meth init(cmd:Cmd<="sh" args:Args<=["-s"])
	 self.cmd = Cmd
	 self.args = Args
	 {System.showInfo "> "#Cmd#" "#{ListToVS Args " "}}
	 Open.pipe,init(cmd:Cmd args:Args)  
      end
      /** %% Feed Cmd (a VS) to the interactive program. Use one of the output/show methods to retrieve results.
      %% Please note that the output/show methods are exclusive (i.e., once some result is output one way, it is output again.). 
      %% */
      meth cmd(Cmd)
	 {System.showInfo "["#self.cmd#"] > "#Cmd}
	 Open.text,putS(Cmd)  
      end 
      /** %% Show any results and output of each command fed to the shell at stdout. 
      %% */
      %% !! does this only show stdout, but not stderror?
      meth showAll
	 Line = Open.text,getS($)
      in
	 {Wait Line}
	 case Line of false then
	    {System.showInfo "Process has died."} {self close}
	 else {System.showInfo Line}
	    {self showAll}
	 end
      end
      /** %% Return the next line (a string) of any result. In case the shell has died, nil is returned.
      %% */
      meth outputLine($)
	 case Open.text,getS($) of false then 
	    {self close}
	    nil
	 elseof S then S
	 end 
      end
%   /** %% Return any results . In case the shell has died, nil is returned.
%   %% */
%   meth outputAll($)
%   end
   end
   
end

