
%%
%% This functor started from the QTk Prototyper by Donatien
%% Grolaux. The functor has been refactored and extended by Torsten
%% Anders almost beyond recognition, but the original copyright notice
%% is kept below for copyright reasons.
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                                      %%
%% QTk                                                                  %%
%%                                                                      %%
%%  (c) 2000 Université catholique de Louvain. All Rights Reserved.     %%
%%  The development of QTk is supported by the PIRATES project at       %%
%%  the Université catholique de Louvain.  This file is subject to the  %%
%%  general Mozart license.                                             %%
%%                                                                      %%
%%  Author: Donatien Grolaux                                            %%
%%                                                                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/** %% This functor provides an interactive tutorial for the Oz programming language and for Strasheela. Just start InteractiveTutorial.exe (e.g. at the command line).
%%
%% The examples (documentation and code) is all stored in the directory "./TheExamples/" (possibly in subdirectories). They are stored in *.tut files of the following XML format just (giving some example, for a formal definition see ../xml-schema/tutorial.rnc). Examples are shown in the alphabetical order of their *.tut file pathes, and in the order they are stored in the *.tut file. 

&lt;?xml version="1.0" encoding="UTF-8"?&gt;

&lt;examples&gt;
&lt;example title="My Test 1"&gt;
&lt;info&gt;this is a test&lt;/info&gt;
&lt;oz&gt;{Browse hi}&lt;/oz&gt;
&lt;/example&gt;
&lt;example title="My Test 2"&gt;
&lt;info&gt;
the
next
test is
this
&lt;/info&gt;
&lt;oz title="Browse hi"&gt;{Browse hi}&lt;/oz&gt;
&lt;oz title="Browse there"&gt;{Browse there}&lt;/oz&gt;
&lt;/example&gt;
&lt;/examples&gt;

%% The *.tut files are best edited with the Emacs nxml-mode (http://thaiopensource.com/nxml-mode/). Validation, automatic completition etc. are supported for the *.tut files format: an XML schema for *.tut files is provided (in the Relax NG format) at ../xml-schema/tutorial.rnc. For the existing files, Emacs finds this schema file automatically (at least on UNIX..) due to a schemas.xml file in the respective directories.
%%
%%
%% NB: QTk defines some default behaviour (is it a look? cf. http://www.mozart-oz.org/documentation/mozart-stdlib/wp/qtk/html/node5.html#chapter.advanced), which overwrites the default color scheme of other TK applications. For example, whenever QTk is used, the background color of the Inspector turns grey.
%% */


%%
%% TODO
%%
%% - Other feed options (just add a few procs similar to Run and a few buttons below)
%%
%%   * feed/browse/inspect line/region/buffer  
%%
%% - ???? Spead up start up: Store datastructure with all examples (i.e. what is returned by ReadExamples) as persistant value (pickle, cf. http://www.mozart-oz.org/documentation/system/node56.html#chapter.pickle).
%%
%%   * first do some profiling: how long does ReadExamples take: is this really the issue which slows down the start up?
%%     -> always starts quickly? Is perhaps starting the compiler is issue??
%%
%%   * after startup read old pickled example data structure. Only in case there is no such pickle, then execute ReadExamples
%%
%%   * Add a menu entry: Re-Read Examples which also calls ReadExamples (i.e. the examples are stored in a cell which can be updated)
%%
%%

%%
%% The compiler created by this functor is independent from any OZRC,
%% and thus these examples can be tried out even if OZRC has not been
%% set up properly -- only a full Strasheela installation is sufficient. 
%% Problem: this way I have no software to playback the music output...
%% For now, just make output dir explicit in examples code and let user open output with their own app..
%% Still, paths to external apps like lily and csound are still problematic. So, I should first do my output GUI before I release this..
%%


functor

import

   Resolve
   
   %% !! tmp functor until next release with debugged Path of stdlib
   Path at 'x-ozlib://anders/tmp/Path/Path.ozf'

   Parser at 'x-oz://system/xml/Parser.ozf'
   QTk at 'x-oz://system/wp/QTk.ozf'
   Application
   Browser(browse:Browse)
   % Error
   
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   Settings at 'x-ozlib://anders/strasheela/SettingsGUI/SettingsGUI.ozf'
   CustomCompiler at 'Compiler.ozf'

   
export
   StartPrototyper
   
   OutputMuse
   
   %% !! Tmp for debugging
   /*
   ReadExamples
   ExamplesDir
   MyParser
   GetExamples
   GetTitle
   GetOz
   GetInfo
   */

%require
%   OS
   
%prepare
   %% NB: functor must be re-compiled whenever it is moved in the file system or to another machine (copying the *.ozf file does NOT work)
%   CWD = {OS.getCWD}
   
define

%   ExamplesDir = {Path.make CWD#"/../TheExamples/"}

   %% List of XML files with the examples. When extending, also add new files to makefile.oz! 
   MyExamples = {Map ['x-ozlib://anders/strasheela/Tutorial/TheExamples/01-Oz/01-Basics.tut'
		      'x-ozlib://anders/strasheela/Tutorial/TheExamples/01-Oz/02-ConstraintProgramming.tut'
		      'x-ozlib://anders/strasheela/Tutorial/TheExamples/02-Strasheela/01-MusicRepresentation.tut'
		      'x-ozlib://anders/strasheela/Tutorial/TheExamples/02-Strasheela/02-MusicalCSPs.tut']
		 fun {$ URI}
		    {Path.make {Resolve.localize URI}.1}
		 end}
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Top-level definition
%%%
   
   /** %% Top-level definition: starts Prototyper.
   %% */
   proc{StartPrototyper}
      Args = {MakeInterchangeData}
      Window = {QTk.build {MakeGui Args}}
      Args.toplevelH = Window
   in      
      %% show first info (set all but first list selection to false..)
      {Args.listH set(selection:(true|{Map Args.examples.2 fun {$ X} false end}))}
      {Args.infoH set(Args.examples.1.info)}
      %% 
      {Window show(wait:true)}
   end
   
   /** %% MakeInterchangeData creates a record which is interchanged by the procs of the prototyper. This record has following format.

   unit(examples: &lt;list of example specs in the form unit(title:VS oz:Xs info:VS), where each oz spec is a list of records in the form oz(title:VS text:VS)&gt;
	currentExample: &lt;cell with present example spec&gt;
	toplevelH: &lt;top level window handle&gt;
	listH:&lt;list object handle: shows list of example titles&gt;
	listSelection:&lt;cell recording selection of listH&gt;
	codeListH:&lt;list object handle: shows list of code example per example titles&gt;
	infoH: &lt;info text widget handle&gt;
	codeH: &lt;code text widget handle&gt;)
   */
   fun {MakeInterchangeData}
      unit(examples:{ReadExamples}
	   currentExample: {NewCell nil}
	   %% <Something>H denotes a Gui object handle
	   toplevelH:_
	   listH:_
	   listSelection: {NewCell nil}
	   codeListH:_
	   infoH:_
	   codeH:_)
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% GUI definition
%%%

   /** %% Window Title -- always shown before the example title */
   Title = "Strasheela Tutorial" 

   /** %% Create GUI spec. This spec also contains calls to the processes defined above
   %% */
   fun {MakeGui Args}
      unit(examples:Examples
	   listH:ListH infoH:InfoH codeListH:CodeListH codeH:CodeH
%	   dropListH:DropListH codeTitleH:CodeTitleH
	   ...) = Args
      Titles = {List.map Examples fun{$ unit(title:N ...)} N end}
   in
      td(title:Title
	 %% top interface line
	 lr(glue:nwe
	    menubutton(glue:w
		       text:"File"
		       menu:menu(command(text:"About"
					 action:proc{$}
						   {{QTk.build
						     td(label(text:"Author: Torsten Anders (starting from Donatien Grolaux' QTk Prototyper)")
							button(glue:s padx:5 pady:5
							       text:"Close"
							       action:toplevel#close))}
						    show(wait:true modal:true)}
						end)
%				 separator
				 command(text:"Settings..."
					 action:Settings.makeApplicationFileSettings)
				 command(text:"Quit"
					 action:QuitApplication)))
	   )
	 %% main three widgets: example list, info text, code text
	 tdrubberframe(glue:nswe padx:2 pady:2
		       td(glue:nswe
			  lrrubberframe(glue:nswe
					td(glue:nswe
					   listbox(glue:nswe bg:white
						   handle:ListH
						   tdscrollbar:true
						   init:Titles
						   width:20
						   action:proc {$} {ChangeExample Args} end))
					td(glue:nswe
					   text(glue:nswe bg:white
						tdscrollbar:true
						wrap:word
%						state:disabled
						handle:InfoH))
				       ))
		       td(glue:nswe
			  lrrubberframe(glue:nswe
					td(glue:nswe
					   text(glue:nswe bg:white
						tdscrollbar:true
						wrap:word
						handle:CodeH))
					td(glue:nswe
					   listbox(glue:nswe bg:white
						   handle:CodeListH
						   tdscrollbar:true
						   width:20
						   action:proc {$} {ChangeCode Args} end))
				       ))
		      )
	 %% buttons in bottom line  
	 lr(glue:swe
	    button(glue:w padx:5 pady:5
		   text:"Run"
		   action:proc {$} {FeedStatement Args} end)
% 	    button(glue:w padx:5 pady:5
% 		   text:"Revert"
% 		   action:proc {$}{ReloadCode Args} end)
	    button(glue:e padx:5 pady:5
		   text:"Quit"
		   action:QuitApplication))
	)
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Application processes (these are called by the GUI)
%%%
      
   /** %% Quits Oz application.
   %% */ 
   proc {QuitApplication} {Application.exit 0} end


   local
      MyCompiler = {CustomCompiler.makeCompiler}
      % {FeedInitFile MyCompiler}
   in
      /** %% Execute example code in CodeTextH with compiler
      %% */
      proc {FeedStatement unit(codeH:CodeH ...)}
	 MyCode = {CodeH get($)}
	 %% !! wrap some code around every code fed to compiler in order to catch runtime errors in CustomCompiler. Unfortunately, this trick somewhat obscures the code, if the code fed to the compiler is shown..
	 MyFullCode={LUtils.accum ["try\n"
				   %% InitCode
				   "skip\n" % do something in any case..
				   MyCode
				   "\ncatch E then {Error.printException E} end\n"]
		     List.append}
      in
	 {CustomCompiler.feedStatement MyFullCode MyCompiler}
      end
   end

%    /** %% This proc is called when the revert buttom is pressed: reload possibly edited code.
%    %% */
%    proc {ReloadCode unit(currentExample:CurrEx codeH:CodeH ...)}
%       MyExample = {Access CurrEx}
%    in
%       %% MyExample is nil just after startup
%       if MyExample\=nil
%       then {CodeH set(MyExample.oz)}
%       end
%    end
   
   /** %% This proc is called when the list object was touched by user: load selected example into titleH, InfoH, and CodeH
   %% */ 
   proc {ChangeExample Args}
      unit(examples:Examples currentExample:CurrEx
	   toplevelH:ToplevelH
	   listH:ListH listSelection:ListSel
	   codeListH:CodeListH
	   infoH:InfoH codeH:CodeH ...) = Args 
      Index = {ListH get(firstselection:$)}
   in
      if Index \= 0 then
	 MyExample = {Nth Examples Index}
	 MyCodeTitles = {Map MyExample.oz fun {$ X} X.title end}
	 %% init to first code example
      in
	 {Assign CurrEx MyExample}
	 {Assign ListSel {ListH get(selection:$)}}
	 %%
	 {ToplevelH set(title:Title#": "#MyExample.title)}
	 {CodeListH set(MyCodeTitles)}
	 %% select first code example
	 {CodeH set({Nth MyExample.oz 1}.text)}
%	 %% users can not edit the info text, but I need to enable
%	 %% editing before I can update this window.
%	 {InfoH set(state:normal)}
	 {InfoH set(MyExample.info)}
%	 {InfoH set(state:disabled)}
      else
	 %% just savety: Index is only 0 before list object is
	 %% touched, but then ChangeExample was not called yet ...
	 {InfoH set("")}
	 {CodeH set("")}
      end	    
   end

   /** %% Called after user selects a code example with dropdownlist: update content of dropdownlist label and of code widget. 
   %% */
   proc {ChangeCode unit(currentExample:CurrEx
			 listH:ListH listSelection:ListSel
			 codeListH:CodeListH codeH:CodeH ...)}      
      %% firstselection returns index of selected list element
      Index = {CodeListH get(firstselection:$)}
   in
      if Index > 0
      then
	 MyExample = {Access CurrEx}
      in
	 {CodeH set({Nth MyExample.oz Index}.text)}
	 %% keep the present ListH selection
	 {ListH set(selection:{Access ListSel})}
      end
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Output into the Emacs Muse format
%%%

   
   /** %% Expects a directory (VS), transforms all *.tut files of the tutorial in *.muse files and writes them into this directory. The basefile name of the *.tut files are kept, but their extension is changed to *.muse.
   %% */
   proc {OutputMuse Dir}
      {ForAll MyExamples
       % {CollectXMLFiles ExamplesDir}
       proc {$ PathObject}
	  PathString = {PathObject toString($)}
       in
	  {Out.writeToFile {TutToMuse PathString}
	   Dir#{{{{PathObject basename($)}
		  dropExtension($)}
		 addExtension("muse" $)}
		toString($)}}
       end}
   end
   
   /** %% Expects path to a *.tut file and outputs its content in *.muse format (as VS).
   %% */ 
   fun {TutToMuse PathString}
      ParsedFile = {MyParser parseFile(PathString $)}
      Examples = {LUtils.find ParsedFile
		  fun {$ X} {Label X} == examples end}
      %% title obligatory
      Title = "#title "#{GetTitle Examples}
   in
      {Out.listToLines
       {Append [Title
		nil % empty line
		'<contents depth="2">'
		nil
		"* About this document\n\nThis file was automatically generated from the interactive Strasheela tutorial. Some aspects of the text only make sense in the original interactive tutorial application (e.g., buttons indicated to press, and positions specified on the screen), and not in this version of the text."
		nil]
	{Map {GetExamples ParsedFile}
	 ExampleToMuse}}}
   end

   /** %% Expects parsed example and outputs example in Muse format (as VS)
   %% */ 
   fun {ExampleToMuse Example}
      %% title obligatory
      Title = "* "#{GetTitle Example}
      [info(text:InfoText
	    title:_)] = {GetContent Example info nil}
      OzData = {GetContent Example oz nil}
      OzAsMuse = {Map OzData
		  fun {$ oz(text:Text
			    title:Title)}		   
		     FullTitle = if Title == nil then nil
				 else "** "#Title
				 end
		     FullText = if Text == nil then nil
				else 
				   ["<src lang=\"oz\">"
				    Text
				    "</src>"
				    nil]
				end
		  in
		     {Out.listToLines {Append [FullTitle
					       nil] % empty line
				       FullText}}
		  end}
   in
      {Out.listToLines
       {Append [Title
		nil % empty line
		InfoText
		nil]
	OzAsMuse}}
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Finding and reading all the examples 
%%%
   
%    /** %% Recursively collect all *.tut pathes contained recursively in MyPath. 
%    %% */
%    %% !! this definition is overkill -- I only have a wellknown number of files!
%    fun {CollectXMLFiles MyPath}      
%       /** %% Returns true if string S1 is more early in alphabetical order than S2. A shorter but otherwise equal string is more early.. 
%       %% */
%       fun {StringLessThan S1 S2}
% 	 if S1 == nil
% 	 then true
% 	 elseif S2 == nil
% 	 then false
% 	 elseif S1.1 == S2.1
% 	 then {StringLessThan S1.2 S2.2}
% 	 else S1.1 < S2.1
% 	 end
%       end
%    in
%       if {MyPath isDir($)}
%       then {LUtils.mappend
% 	    %% sort alphabetically 
% 	    {Sort {MyPath readdir($)}
% 	     fun {$ P1 P2}
% 		{StringLessThan {P1 toString($)} {P2 toString($)}}
% 	     end}
% 	    CollectXMLFiles}
%       else
% 	 if {MyPath extension($)} == "tut" 
% 	 then [MyPath]
% 	 else nil
% 	 end
%       end
%    end
   /** %% ["data abstraction"] expects the full parse tree of an XML file and returns the list of all examples contained in the top-level <examples> element.
   %% */
   fun {GetExamples FullParseTree}
     Examples = {LUtils.find FullParseTree
		 fun {$ X} {Label X} == examples end}
   in
      Examples.children
   end
   /** %% ["data abstraction"] Returns title of example (record created by parsing the XML data)
   %% */ 
   fun {GetTitle Example} Example.alist.title end   
   /** %% ["data abstraction"] Returns content of example (record created by parsing the XML data)  of Type (either oz or info), and uses Default in case there is no content or the type does not exist.
   %% Returned is a list of records of the form Type(title:Title content:Content).
   %% NB: there is always a single info without a title, but this format is created consistently for infos and oz. GetInfo extracts the 'pure' info..
   %% */ 
   fun {GetContent Example Type Default}
      Xs = {Filter Example.children
	    fun {$ X} {Label X} == Type end}
      TitleDefault = ""
   in
      if Xs == nil then [Type(1:Default
			      title:TitleDefault)]
      else
	 {Map Xs
	  fun {$ X}
	     MyTitle = if {HasFeature X.alist title}
		       then X.alist.title
		       else TitleDefault
		       end
	     MyContent = if X.children == nil
			 then Default
			 else {ByteString.toString X.children.1.data}
			 end
	  in
	     Type(text:MyContent
		  title:MyTitle)
	  end}
      end
   end
   fun {GetInfo Example}
      %% info and oz have the same format, but I don't need multiple infos and no info title..
      {GetContent Example info "No information available."}.1.text
   end
   fun {GetOz Example} {GetContent Example oz nil} end
   
   /** %% Returns list of example specs in the form unit(title:VS oz:Xs info:VS), where each oz spec is a list of records in the form oz(title:VS text:VS).
   %% */ 
   %% efficiency: use record instead of list with example titles as feats (e.g. see loadCurFile)
   fun {ReadExamples}
      {Flatten
       {Map MyExamples
	% {CollectXMLFiles ExamplesDir}
	fun {$ XMLPath}
	   {Map {GetExamples {MyParser parseFile({XMLPath toString($)} $)}}
	    fun {$ Example}
	       unit(title:{GetTitle Example}
		    oz:{GetOz Example}
		    info:{GetInfo Example})
	    end}	  
	end}}
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Parsing the examples (XML files) 
%%%
   
   /** %% Defines XML parser (cf. example in http://www.mozart-oz.org/documentation/mozart-stdlib/xml/parser/index.html).
   %% */
   class MyParserClass from Parser.parser 
      meth init
	 M = {New Parser.spaceManager init}
      in
	 {M stripSpace('*' '*')}
	 Parser.parser,init
	 {self setSpaceManager(M)}
      end
      meth onAttribute(Tag Value)
	 {self attributeAppend(Tag.name#Value)}
      end
      meth onStartElement(Tag Alist Children)
	 Name = Tag.name
      in
	 {self append(
		  Name(
		     alist    : {List.toRecord alist Alist}
		     children : Children))}
      end
   end
   MyParser = {New MyParserClass init}


   

end
