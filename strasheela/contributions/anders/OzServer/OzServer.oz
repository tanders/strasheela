
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

/** %% This is an application which serves as a 'headless' OPI: its starts a full Oz compiler and the compiler awaits arbitrary Oz code (even compiler directives) sent via a socket. This allows, for example, another application (e.g. another language such as Lisp, C, ..) to start a full Oz evaluator/compiler and to execute arbitrary Oz code from within that other application. The code is executed concurrently, i.e. without waiting for it to terminate before proceeding to the next fed input.
%% On its initialisation, the full environment (comparable to the OPI) is loaded to the compiler and it is fed an OZRC file according conventions (cf. oz/doc/opi/node4.html). As interface, the compiler panel GUI is opened. To quit the compiler, quit this application by C-c (closing the panel is not sufficient) or send the OzServer directive quit (see below). When compared with the OPI, the compiler panel (messages panel) serves as Oz Compiler buffer and the standard out of the shell in which the OzServer was started serves as Oz Emulator buffer. 
%%
%%
%% USAGE
%%
%%   <code>OzServer [OPTIONS]</code>
%%
%%
%% OPTIONS
%%
%% <code>--port integer</code>   Portnumber of socket, defaults to 50000
%%
%% <code>--file file</code>   Feed given Oz source file at initialisation.
%%
%% <code>--resultFormat symbol</code>  An atom specifying the syntax of results output back to the client. Presently, supported values are oz (the default), lisp, and lispWithStrings.
%% oz: outputs textual representation of the Oz values, terminated by a newline (to distinguish multiple results).
%% lisp: outputs literal Oz values transformed into Lisp syntax. Transformation to lisp values works for a booleans, numbers, atoms, records/tuples and lists (possibly nested). NB: Strings are not supported in this Lisp output syntax (they are output as integer lists). Other values (e.g. functions, classes) raise an exception.
%% lispWithStrings: like lisp, but integers between 0-255 are output as characters and lists of integers between 0-255 as strings. 
%% NB: Additional output formats can be specified by extending the procedure TransformResult in <OzServer>/source/Compiler.oz. 
%%
%% <code>--size integer</code>   Maximum number of bytes read at once via the socket, defaults to 1024
%%
%%
%% FORMAT OF THE CODE FEED 
%%
%%   ["%!"&lt;DIRECTIVE&gt;\n]&lt;CODE&gt;
%%
%% The Oz compiler can be fed statements by simply sending the code (as a string) via the socket. Alternatively, OzServer supports a few options which are always signalled by the two characters %! at the beginning of the fed (inspired by the UNIX shell #! notation), followed by some directive and a new line before the actual code. Supported directives are
%%
%%   <code>statement</code>   The code fed to the compiler is a statement (this is the same as no directive).
%%
%%   <code>expression</code>   The code fed to the compiler is an expression and its result is output via the socket.
%%
%%   <code>file</code>         The 'code' fed is a path to the file to feed to the compiler.
%%
%%   <code>browse</code>       The code fed to the compiler is an expression and its result is presented via the Oz browser.
%%
%%   <code>inspect</code>      The code fed to the compiler is an expression and its result is presented via the Oz inspector.

%%   <code>quit</code>         Quits the OzServer with return status 0.
%%
%%
%% NB: Instead of sending very long code strings via the socket, consider writing the code to a file and let the compiler read the file.
%%
%% NB: As arbitrary code can be executed by a client, this program poses a severe security thread! (e.g., you better don't run this program with root priviliges on a machine with network access, just in case ..). 
%%
%% NB: see TODO list in source for missing/planned features.
%%
%% */


%% TODO:
%%
%% * !! TO ADD: Security: the application gets arg --password at the commandline. Each client must send this password as first feed after connecting "%!password\n<password>". Otherwise the server immediately disconnects the client.
%%
%%   NB: this means no security like ssh would provide.. However, with TCP and initial password check, i have security that the client is always the same entity (during a session), while with UDP some other application might be re-using a former socket.
%%
%% * TO FIX: there seems to be a bug in the Oz Path module for MacOS which requires every path (even normal files) to end in a slash..
%%
%% * ?? TO ADD: shall server accept multiple clients (and sort output accordingly)? Why, who will need this?
%% -> !! if multiple clients feed concurrently, then I have to adapt the proc CallCompiler in OzServer/source/Compiler.oz. I have to set compiler switches and then feed code in atomic operation! However, this is not necessary as long as there is only a single socket feedi
%% -> BTW: for accessing multiple clients consider using Socket receive instead of Socket read (receive accepts host and port as args)
%% * !! TO FIX: after closing a connection no reconnection is possible.. {MyServer accept(host:H port:P)} must be called again..
%% -> For both issues see Socket.oz MakeServer: I may call {MyServer accept(host:H port:P)} recursively, but then I must deal with the fact how to deal with the output of multiple clients, multiple clients share the same compiler instance (e.g. variable bindings are shared)... This needs care...
%%
%% * ?? TO ADD: are there further directives required (see OPI)?
%%
%% * !!?? TO ADD: option to choose the interface: either Compiler panel (default?, hard wired right now), OPI (that would need some rewriting, but inside the OPI the compiler is accessible as OPI.compiler), or standard out/error out
%% -> Currently, the compiler panel serves quasi as Oz Compiler buffer and the standard out of the shell in which the OzServer was started serves quasi as Oz Emulator buffer. How can I otherwise distinuish between compiler messages and messages send to the 'emulator'? Moreover, which program whats to process the rather verbose compiler messages anyway? 
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% Sorted issues:
%%
%% OK? * TO FIX: exception in OzServer crashes the server. Instead, print exception (e.g. in GUI?)
%% OK * Extend the initial environment of the compiler to the full environment of the OPI (see its code..)
%% 
%% OK * !! TO FIX: closing the client-side of the socket crashes the application
%% * in case the client ends without [closing] the socket properly, then the server crashes with error
%***************** Error: illegal field selection ***************
%**
%** In statement: nil . 1 = _<optimized>
%**
%** Call Stack:
%** procedure 'GetHeader' in file "/home/t/oz/music/Strasheela/strasheela/contributions/anders/OzServer/source/Compiler.oz", line 351, column 3, PC = 142617352
%** procedure 'CallCompiler' in file "/home/t/oz/music/Strasheela/strasheela/contributions/anders/OzServer/source/Compiler.oz", line 364, column 3, PC = 142617632
%%
%% OK * !! TO FIX: feeds are executed concurrently. Presently, multiple expressions feed one after the other run concurrently and results are output in the order the expressions finish. Improvement: results are output in the order the expressions were fed to the compiler. E.g., write all results (first) into a stream as undetermined vars which are then by and by bound. The output for a missing result will block, but expressions fed later may already have finished their computation concurrently and their result simply waits in the stream for outputting.
%%
%% OK * !! TO FIX: LispWorks blocks when reading the results of expressions send to the OzServer. When the OzServer is killed, then the results are read by LispWorks.
%% -> additional problem: results are often concatenated in a single string or value -- I need to have some EOF symbol which is then used to split the results (but that can be done simply either by the %!expression directly, or by some 'pluging' output processing..)
%%
%% * !! TO FIX: Socket: multiple writes shortly after each other: these are 'appended' to in a single value (VS) in the output stream. For feeding the compiler this is irrelevant. However, for outputting results it is important that multiple results can be distinguished. [this seems to be a problem of Oz' socket interface, see testing/Socket-test.oz. After more extensive testing I may need to file a Bug report..]
%%   -> tmp solution: set compiler switch 'threadedqueries' to false (e.g. simply in GUI Compiler panel)
%% -> fixed by added newline at end of each output...
%%
%% OK * TO ADD: Somehow add control (user-defined functions) for postprocessing of any result send 'back' via the socket. These processings will then be applied to any feed. For example, a Strasheela score will always be transformed to some output format 
%%
%% OK? * !!?? TO FIX: currently, expression results are send back 'raw' -- it is the users responsibility to convert the result to a VS. A fix would implicitly transform arbitrary Oz values into their print form (i.e. ADTs such as procs and classes can still not be send but at least a somewhat meaningful output is send back).
%% -> special output processing, but ADT etc are not supported..
%%
%% OK * ?? TO ADD: some clean shutdown of server and socket etc (at the minute, C-c in the command-line works fine)
%%
%%
%% Solved?? BUGS
%%
%% * When feeding multiple expressions where a later expression is finished more early the a previous expression, the results are possibly 'appended' into a single value in the output stream.
%%   Temporary workaround: set the compiler switch 'threadedqueries' to false (e.g. simply in GUI Compiler panel), so queries are fed and processed one after another.
%%

functor
import 
   Application System Property
%   Open
   Socket at 'source/Socket.ozf' 
   CustomCompiler at 'source/Compiler.ozf'
%   Browser(browse:Browse) % temp for debugging
   
define
   
   %% MyServer is a socket
   MyServer 
   
   proc{ShowHelp M}
      {System.printError
       if M==unit then nil else "Command line option error: "#M#"\n" end#
       "Usage: "#{Property.get 'application.url'}#" [OPTIONS]\n"#
       "   --port <INTEGER>        Portnumber of socket, defaults to 50000\n"#
       "   --file <FILE>           Feed given Oz source file at initialisation\n"#
       "   --resultFormat <SYMBOL> Atom specifying the syntax of results output back to the client. Presently, supported values are oz (the default), lisp, and lispWithStrings\n"#
       "   --size <INTEGER>        Maximum number of bytes read at once via the socket, defaults to 1024\n"}
   end

   try
   
      Args = {Application.getArgs record(port(single type:int default:50000)
					 size(single type:int default:1024)
					 file(single type:string default:"")
					 %% e.g. transform result to Lisp value
					 %% I don't need delimiter then..
				      %processResults(single )
				      %delimiterResults(single type:string default:" ")
					 resultFormat(single type:atom(oz lisp lispWithStrings) default:oz)
				      
					 'help'(single char:&h type:bool default:false)
				      % 'version'(single char:&v type:bool default:false)
					)}

      
   in
      
       %% Ask for help?
       if Args.help==true then
	  {ShowHelp unit}
	  {Application.exit 0}
       end
      

      %%
      %% create compiler and socket server, and feed socket input to compiler
      %%
      %% NB: this application functor is not wrapped in a try/catch statement for calling Oz exceptions. Instead, exceptions created by the code fed to the compiler are reported by the compiler panel.
      %% !!! Problem with this approach: exceptions could also be caused by the OzExplorer itself. These exceptions are not caught. Moreover, the OzServer can only exit with 0.  
      %% However, it appears most possible errors are reported by compiler panel already. E.g., in case a file is loaded with the arg 'file' which does not exist, then the error is reported in the compiler panel. For more error possibilities see test file
      %% Other errors are reported in shell starting the OzServer (e.g. the OzServer is called with an undefined arg). Nevertheless, the application may still return 0... -- TO CHECK
       
       local
	  %% MyClient is a socket
	  MyClient = {Socket.makeServer localhost Args.port MyServer}
	  MyInterface MyCompiler 
       in
	  {CustomCompiler.makeFullCompiler MyInterface MyCompiler}
	  if Args.file \= ""
	  then {MyCompiler enqueue(feedFile(Args.file))}
	  end
	  {CustomCompiler.feedAllInput MyCompiler MyInterface MyServer MyClient Args}
       end
       
%   {Wait _}
%   {Application.exit 0}
       
   catch X then
      case X of quit then
	 {MyServer close}
	 {System.showInfo "% OzServer quits"}
	 {Application.exit 0}
      elseof error(ap(usage M) ...) then
	 {ShowHelp M}
	 {Application.exit 2}
      elseof E then
	 raise E end
      end
   end
   
end

