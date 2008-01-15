
/** %% This functor provides an interface to OpenSound Control (OSC), by using the UNIX programs sendOSC and dumpOSC: using these applications instead of a C/C++ library is less efficient, but more easy to implement ;-). See http://www.cnmat.berkeley.edu/OpenSoundControl/ for more details on OSC in general, and also for details about these two applications. 
%%
%% This functor provides a representation of OSC messages as Oz values in the following way. An OSC message is represented by an Oz tuple. The tuple label is the OSC Address Pattern (e.g., '/test'). 0 or more OSC arguments are represented by the contained tuple values. OSC arguments can be Oz integers, floats and virtual strings. 
%%
%% An OSC bundle is represented by an Oz list. Optionally, the first element is the time tag, followed by 0 or more OSC bundle elements (i.e. OSC messages or other bundles). Timetags can be specified in different formats, but must always be a number. The send method of the class SendOSC supports the user-definable transformation of timetags into different formats. By default, the number of milliseconds elapsed since midnight UTC of January 1, 1970 is expected (i.e. UNIX time multiplied by 1000), but other formats are possible (e.g., a float measuring in beats, where the time 0.0 is some user-defined UNIX time). Timetags in received bundles are obligarory, but may be 1 (meaning 'now'). Bundles can be nested (as sendOSC and dumpOSC support nested bundles). However, for sending bundles please note that some applications with OSC support don't support nested bundles (e.g. SuperCollider's synthesis server scsynth).
%%
%% The following examples show the textual OSC representation used by sendOSC and the Oz representation alongside: 
%%
%% sendOSC:
%%
%% /address "test string" 3.14 -42
%% [
%% /voices/0/tp/timbre_index 0
%% /voices/0/tm/goto 0.0
%% ]
%%
%% Oz:
%%
%% '/address'("test string" 3.14 ~42)
%% ['/voices/0/tp/timbre_index'(0) '/voices/0/tm/goto'(0.0)]
%% [{OSC.timeNow} '/test'(foo bar)]
%%
%% Please note that this interface is only available for UNIX systems (e.g., MacOS and Linux), because sendOSC and dumpOSC are UNIX applications. Moreover, the original dumpOSC delays the printout of bundles (when called in a pipe as this interface does) and it is recommended to apply the dumpOSC patch available at ../others/dumpOSC/dumpOSC-patch.diff (or simply replace the original file dumpOSC.c with the already patched dumpOSC.c in the same directory before compiling dumpOSC).
%%
%% This interface calls dumpOSC in a terminal (xterm), and sends its output to Oz with netcat via a socket. Starting dumpOSC in a terminal is necessary, because for unkown reasons dumpOSC refuses to output anything when called by Oz directly in a pipe (for details, see postings in the mailing lists osc_dev@create.ucsb.edu, and users@mozart-oz.org, on the 7 Septermber 2007 and following days). This interface relies thus on the following applications, which must be installed, and should be specified in the Strasheela environment (if they are not in the PATH): sendOSC, dumpOSC, xterm, and netcat (nc). On most Unixes, xterm is already there. On MacOS, however, X11 must be installed in order to make xterm available, and the location of X11.app must be specified in the Strasheela environment. The respective Strasheela environment variables are sendOSC (its default value is 'sendOSC'), dumpOSC (default 'dumpOSC'), xterm (default 'xterm'), netcat (default 'nc'), and 'X11.app' (default '/Applications/Utilities/X11.app').  
%% */

%%
%% NB: this is not a generic solution yet, because Windows in not
%% supported. Moreover, installing a C++ compiler would be required on
%% Windows for the compilation -- although it can not be used on
%% Windows. Therefore, it is only available as contribution, and not
%% yet added to the Strasheela core.
%%


%%
%% Idea
%%
%% !! OSC terminology not clean!
%%
%% - OSC messages as tuples with [name tag (first message element)] as record label
%% - bundles are records with [messages/bundles] at integer features. all  the time tag is stored under the (optional) feature 'timeTag'
%%
%%  -> format is not consistent! 
%%


%\switch +gump
%% create the .simplified file with the BNF version of the grammar
%% create the .output file with the Bison verbose output
% \switch +gumpparseroutputsimplified +gumpparserverbose

functor 
import
   System OS Open  
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Init at 'x-ozlib://anders/strasheela/source/Init.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   OSC_Scanner at 'source/OSC_Scanner.ozf'
   OSC_Parser at 'source/OSC_Parser.ozf'
   
export
   SendOSC
   DumpOSC

   TimeNow

   Buffer


   %% NOTE: aux, but some are needed by OSC_Parser
   %% !!?? should I put all such low-level stuff in extra functor, which then freely exports all the low-level procs etc, but they do not litter up the export features of OSC..
   HexToDecimal1000 FormatHex 
   ntpToUnixTime1000: NTPToUnixTime1000
   %% !! tmp
   DecimalToHex_Int DecimalToHex_Frac
   
   FormatTimeTag % FormatTimeTag_OLD
   
define

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% the Gump definitions
%%%

%   \insert OSC_Scanner.ozg 
%   \insert OSC_Parser.ozg 
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Interface to the UNIX programs sendOSC and dumpOSC 
%%%

   
   /** %% Implements Oz interface to the UNIX program sendOSC (using its interactive mode). 
   %% */
   %%
   %% TODO:
   %%
   %% !! SendOSC and DumpOSC not symmetric: one is instance of Out.shell and the other contains instance of socket
   %% !!?? should I change SendOSC also just to contain an Out.shell??
   %%
   %% !!?? echo command starting sendOSC and echo sent OSC packets at stdout 
   class SendOSC from Out.shell

      /** %% Starts sendOSC in the background. The host H is a VS (e.g., "128.32.122.14"), default is localhost. The port P (an Int) defaults to 57120, the port number of the SuperCollider language (i.e., sclang).
      %% */
      meth init(host:H<=localhost port:P<=57120)	  
	 SendOSC = {Init.getStrasheelaEnv sendOSC} 
      in
	 Out.shell, init(cmd:SendOSC args:['-h' H P])
      end

      /** %% Sends the OSC packet Packet. Packet can be either an OSC message or a bundle in the format described above.
      %% The optional timeTagFormatter argument expects a function TTFormatter which transforms any timetag in Packet (in case it is a bundle) into an integer specifying the milliseconds since midnight UTC of January 1, 1970 (i.e. UNIX time multiplied by 1000). This allows for other timetag formats in Packet (e.g. beats). The default TTFormatter does no transformation (i.e. every timetag is UNIX time in msecs, e.g., created with TimeNow plus some value).
      %% */
      meth send(Packet timeTagFormatter:TTFormatter<=fun {$ TimeT} TimeT end)
	 %% gets an OSC packet and transforms it into a string understood by sendOSC
	 proc {Aux Packet ?VS}
	    if {IsList Packet}
	       %% is bundle
	    then if {IsNumber Packet.1}
		    %% starts with time tag
		 then TimeT | Packets = Packet in
		    ?VS = "[ "#{FormatTimeTag {TTFormatter TimeT}}#"\n"#{Out.listToVS {Map Packets Aux} "\n"}#"\n]"
		    %% time tag is omitted: don't add one either... (meaning 'now')
		 else
		    ?VS = "[ "#"\n"#{Out.listToVS {Map Packet Aux} "\n"}#"\n]"
		 end
	       %% is message
	    elseif {IsRecord Packet}
	    then Address = {Label Packet} in	       
	       ?VS = {Out.listToVS Address|{Map {Record.toList Packet}
					    %% surround strings by quotes in case of whitespaces
					    fun {$ Arg}
					       if {IsString Arg} orelse {IsAtom Arg}
					       then "\""#Arg#"\""
					       else Arg
					       end
					    end}
		      " "}
	       %% FIXME: tmp exception
	    else raise unrecognisedOSCPacket(Packet) end 
	    end	
	 end
      in
	 {self cmd({Aux Packet})}
      end
      
   end


   %%
   %% dumpOSC
   %%

   /** %% [private fun] Creates a UDP socket server. Expects a Host (e.g., 'localhost') and a PortNo and returns a server plus its corresponding client. This client is an instance of Open.socket, and is the interface for reading and writing into the socket.
   %% MakeServer blocks until the server listens. However, waiting until a connection has been accepted happens in its own thread (i.e. MakeServer does only block until the server listens). */
   %%
   %% TODO:
   %%
   %% - close socket e.g. like {Finalize.register X proc {$ X} {X close} end}
   %%
   proc {MakeServer ?PortNo ?MyServer}
      %% socket with text support
      class DumpOSCInterface from Open.socket Open.text end
   in
      MyServer = {New DumpOSCInterface init(type:datagram)} % protocol is UDP
      {MyServer bind(port:?PortNo)}
   end

   /** %% [private fun]
   %% ... Copied and slightly modified from ExecNonQuitting in Output.oz. 
   %% */
   proc {StartPipe Cmd Args ?Pipe}
      Pipe = {New Open.pipe init(cmd:Cmd args:Args)}
      {System.showInfo "> "#Cmd#" "#{Out.listToVS Args " "}}
      {System.showInfo {Pipe read(list:$ size:all)}}
   end
   /** %% [private fun] Reads first char of Line (a string). If it is &[, return true, false otherwise.
   %% */
   fun {DoesStartBundle Line} Line.1 == &[ end
   /** %% [private fun] Reads first char of Line (a string). If it is &], return true, false otherwise.
   %% */
   fun {DoesEndBundle Line} Line.1 == &] end
   /** %% [private fun]
   %% */
   fun {LinesToVS Lines} {LUtils.accum {Reverse Lines} fun {$ X Y} X#"\n"#Y end} end

   
   /** %% Implements an Oz interface to dumpOSC for receiving OSC packets at a given port. Ineternally, the textual output of dumpOSC is parsed into Oz values, and a stream of OSC messages in the format described above is provided.
   %% Please note that dumpOSC is called in a terminal (xterm), and its output is send by netcat via a socket to Oz (on MacOS X, X11 is started if not already running). See above for an explanation. 
   %% Also, note that several clients can send to dumpOSC, but no information who sends is transmitted (e.g., no sender IP). If knowing the sender is important, just include your sender in your OSC messages :)
   %% */
   %%
   %% TODO:
   %%
   %%  - [DONE?] add support for time tags (hex values) -- start in Gump parser...
   %%  - remove timetags 1? Why? Replacing that by computed time for now introduces incorrect timing. Better I can recognise this special timetag..
   %%
   %%
   %% NOTE: inconsistent: why multiple responders for the same address, but only a single default responder and only a single bundle responder. Possibly this makes sense in practise, though..
   class DumpOSC 

      feat
	 %% FIXME: some of these features I may make inaccessible from the outside (turn them into variables?)
	 netcatPort % port number to which netcat writes dumpOSC output
	 pipe			% pipe in which xterm which "dumpOSC | netcat" is run
%	 server			% server to listen to dumpOSC output
	 dumpOSC		% socket object to read dumpOSC output
	 myScanner		% Gump scanner instance for OSC
	 myParser		% Gump parser instance for OSC
	 oscs			% stream of OSC packages
	 responders 		% dictionary: keys are OSC addresses, entries are lists of procs
	 	
	 defaultResponderAddr	% a Name for the default responder
	 
      attr counter: 0
	 bundleResponder % a proc

	 /** %% Initialises dumpOSC interface to receive at port Port (defaults to 7777).
	 %% */
      meth init(port:Port<=7777)
	 XTerm = {Init.getStrasheelaEnv xterm} 
	 X11 = {Init.getStrasheelaEnv 'X11.app'} 
	 DumpOSC = {Init.getStrasheelaEnv dumpOSC} 
	 NetCat = {Init.getStrasheelaEnv netcat} 
	 %%
	 %% !! Oz Bug: this should be {Property.get 'platform.os'}
	 %% !! Bug fixed in SVN, so different versions behave differently now!
	 %% IsMac = {Property.get 'platform.arch'} == 'darwin'
	 IsMac = {OS.uName}.sysname == "Darwin"
	 MyCmd
      in
	 self.myScanner = {New OSC_Scanner.'class' init}
	 self.myParser = {New OSC_Parser.'class' init(self.myScanner)}
	 %%
	 self.dumpOSC = {MakeServer self.netcatPort}
	 %% starts X11 if it is not running (changes focus to X11 in any case)
	 if IsMac then {Out.exec 'open' [X11]} end 
	 %% in xterm, rum ./dumpOSC -quiet PORT | nc localhost NETCATPORT
	 %% netcat option -u specifies UDP 
	 MyCmd = DumpOSC#" -quiet "#Port#" | "#NetCat#" -u localhost "#(self.netcatPort)
	 thread 
	    self.pipe = {StartPipe XTerm
			 ["-e" "echo closing this windows stops the OSC input into Strasheela!; "#MyCmd]}
	 end
	 thread self.oscs = {self ParseAll($)} end
	 %% 
	 self.responders = {NewDictionary}
	 self.defaultResponderAddr = {NewName}
	 {self setDefaultResponder(proc {$ _ _} skip end)}
	 @bundleResponder = proc {$ _} skip end
	 {self ProcessResponders}
      end

      /** %% Stop dumpOSC interface and close its ressources. 
      %% */
      %% !! BUG: does not close xterm window! What does it actually do?
      meth close
	 %% close socket and pipe
	 {self.pipe close}
	 {self.server close}
	 {self.dumpOSC close}
	 %% Closes all buffers on the scanner buffer stack: does a VS create a buffer?
	 {self.myScanner close}
      end

      /** %% Returns a stream of OSC messages received by dumpOSC in the internal OSC format described above. Many receivers can call this method for accessing the OSC packages.  
      %% */
      meth getOSCs($) self.oscs end

      /** %% Installs a new responder for any OSC message with the address pattern Address (an atom). Whenever such a message is received, Proc (a binary procedure) is called. The first argument is a timetag (the timetag of the bundle in which the message was contained, or 1), and the second argument is the Message (in internal OSC format, that is a record whose label is the message address, see above for details).
      %% In contrast to a SuperCollider OSCresponder, the sender address is not added, as the information about the sender is not provided by dumpOSC (if required, consider enclosing the address in the message). 
      %% Multiple responders can be installed for the same Address, in which case all their Procs will be applied to each matching message (last applied responder first).
      %% */
      meth addResponder(Address Proc)
	 %% add Proc at head of list at Address
	 {Dictionary.put self.responders Address
	  Proc | {Dictionary.condGet self.responders Address nil}}
      end
      /** %% Deinstalls all responders for Address and adds the new responder Proc. See addResponder for details.
      %% */
      meth setResponder(Address Proc)
	 {Dictionary.put self.responders Address [Proc]}
      end
      /** %% Deinstalls all responders for Address.
      %% */
      meth removeResponder(Address)
	 {Dictionary.remove self.responders Address}
      end
      /** %% Installs a new responder like addResponder. However, this responder Proc is called always whenever no responder installed with addResponder matches.
      %% Please note that there is always only a single default responder installed. Setting a new default responder overwrites the old one.  
      %% */
      meth setDefaultResponder(Proc)
	 %% add Proc at head of list at self.defaultResponderAddr
	 {Dictionary.put self.responders self.defaultResponderAddr
	  Proc}
      end
      /** %% Installs a new bundle responder: The unary procedure proc will be called whenever a bundle (a list) is received, with the timetag as first list element. The timetag is obligatory, but it may be 1 (meaning now).
      %% Please note that there is always only a single bundleResponder installed. Setting a new responder overwrites the old one.  
      %% */
      meth setBundleResponder(Proc)
	 bundleResponder <- Proc
      end

      
      %%
      %% Private / Aux methods 
      %%

      /* %% Traverse stream of OSC packets. Whenever some message is found for whose address (record label) one or more responder have been added, then apply their procs to this message. 
      %% */
      meth ProcessResponders	 
	 proc {Aux Packet Timetag}
	    case Packet
	       %% is bundle
	    of TT | Packets then
	       {@bundleResponder TT | Packets}
	       {ForAll Packets proc {$ X} {Aux X TT} end}
	       %% is message
	    [] Msg andthen {IsRecord Msg} then
	       Address = {Label Msg}
	       Procs = {Dictionary.condGet self.responders Address nil}
	    in if Procs \= nil
	       then {ForAll Procs proc {$ Proc} {Proc Timetag Msg} end}
		  %% always call default responder otherwise
	       else {{Dictionary.get self.responders self.defaultResponderAddr}
		     Timetag Msg}
	       end
	       %% FIXME: tmp exception
	    else raise unrecognisedOSCPacket(Packet) end
	    end
	 end
      in
	 thread {ForAll self.oscs proc {$ X} {Aux X 1} end} end
      end

      /** %% Transforms a VS of valid OSC messages (output of dumpOSC) into a list of values in the OSC format (see above).
      %% */
      meth ParseVS(?Result VS)	 
	 Packets Status
      in
	 {self.myScanner scanVirtualString(VS)}
	 {self.myParser parse(packet(?Packets) ?Status)}
	 if Status then
	    %% parser always returns a list -- should be save to take the first element only
	    ?Result = Packets.1
	 else 
	    %% !! tmp exception
	    raise parserError({VirtualString.toAtom VS}) end
	 end 
      end
      
      /** %% Increment the brackets (i.e. bundles nesting) counter by 1.
      %% */
      meth IncrCounter counter := @counter + 1 end
      /** %% Decrement the brackets (i.e. bundles nesting) counter by 1.
      %% */
      meth DecrCounter counter := @counter - 1 end
      meth ExistsOpenBundle($)
	 @counter > 0
      end

      /** %% Parses any textual output of OSC messages and bundles and returns it as a stream of values in the OSC format (see above). The arg prevLines is only for internal use (accumulation of lines).
      %%
      %% NB: ParseAll must be called in its own thread. 
      %% */
      %% always process full messages or bundles
      %% if the first char is not &[ and there are no open bundles, the line is a message: parse line
      %% if the first char is a &[, it starts a bundle: incr counter, and add next lines until you find the matching &]
      %% if another &[ is found before, further incr counter and collect lines until the bracketsCounter is again 0 
      %% if the first char is a &], decrement counter and check how to proceed..
      %%
      %% NOTE:
      %%
      %% - in case of parse error, ParseAll does not recover. However, a
      %% parse error should not occur...
      %%
      meth ParseAll($ prevLines:PrevLines<=nil)
	 Line = {self.dumpOSC getS($)}
      in
	 %% case waits until Line is bound
	 case Line of false then
	    %% !!?? do I need this test 
	    %% !! tmp exception
	    raise endOfInput end
	    {self close}
	    unit		% never returned (after exception)
	 else	    
	    %% The parser requires complete OSC messages/bundles. The
	    %% following nested ifs ensure that.
	    %% This stuff is hard to read, but for now just leave it like that..
	    if {self ExistsOpenBundle($)}
	       %% we are in a (possbily nested) bundle 
	    then if {DoesEndBundle Line} 
		 then
		    {self DecrCounter}
		    if {self ExistsOpenBundle($)}
		       %% its a nested bundle, we are not at the top-level yet
		    then {self ParseAll($ prevLines:Line|PrevLines)}
		    else % (possbily nested) bundle is complete
		       {self ParseVS($ {LinesToVS Line|PrevLines})} | {self ParseAll($ prevLines:nil)}
		    end
		 else if {DoesStartBundle Line}
		      then 
			 {self IncrCounter}
			 {self ParseAll($ prevLines:Line|PrevLines)}
		      else
			 {self ParseAll($ prevLines:Line|PrevLines)}
		      end
		 end
	       %% we are at top-level (no open bundle)
	    else if {DoesStartBundle Line}
		 then
		    {self IncrCounter}
		    {self ParseAll($ prevLines:Line|PrevLines)}
		 else % Line is plain message, but it does not hurt appending the PrevLines
		    {self ParseVS($ {LinesToVS Line|PrevLines})} | {self ParseAll($ prevLines:nil)}
		 end
	    end
	 end	 
      end
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Construction of OSC messages for sendOSC
%%%

   /** %% Returns the milliseconds since midnight UTC of January 1, 1970, in other words UNIX time (see http://en.wikipedia.org/wiki/Unix_time) multiplied by 1000.
   %% FIXME: presently, only plain seconds are output. Therefore, the returned value can be rather late already. For a more finegrained solution later, use e.g. gettimeofday (see http://www.penguin-soft.com/penguin/man/2/gettimeofday.html?manpath=/man/man2/gettimeofday.2.inc and http://developer.apple.com/documentation/Darwin/Reference/ManPages/man2/gettimeofday.2.html).
   %% */
   %%
   fun {TimeNow}
      {OS.time} * 1000
   end

   local
      %% seconds between 1900-01-01 and 1970-01-01
      ConversionConstant = ((70 * 365 + 17) * 86400)
      %% msecs between 1900-01-01 and 1970-01-01
      ConversionConstant1000 = ConversionConstant * 1000
   in
      /** %% [aux] Outputs an OSC time tag for the given UnixTime1000 as a hexadecimal number (a VS). UnixTime1000 (an integer) are the milliseconds since midnight UTC of January 1, 1970, in other words UNIX time multiplied by 1000.
      %% */
      fun {FormatTimeTag UnixTime1000}
	 UTimeSecs = UnixTime1000 div 1000
	 %% First, convert to number of seconds since 00:00:00 GMT,
	 %% Jan. 1, 1900, then transform into secs in HEX (zero
	 %% padding not necessary, because ConversionConstant is big
	 %% enough)
	 NTPTimeHex = {DecimalToHex_Int UTimeSecs + ConversionConstant}
	 %% msecs (i.e. fractional part), transformed into Hex 
	 UTimeMSecsHex = {DecimalToHex_Frac UnixTime1000 mod 1000}
	 %% zero padding to 8 digits, if necessary
	 FullUTimeMSecsHex = {Append UTimeMSecsHex
			      {Map {List.make 8-{Length UTimeMSecsHex}} fun {$ X} X=0 end}}
      in
	 {FormatHex {Append NTPTimeHex FullUTimeMSecsHex}}
      end
%       %% Old def for testing / comparing: ignores everything below whole seconds
%       fun {FormatTimeTag_OLD UnixTime1000}
% 	 UTimeSecs = UnixTime1000 div 1000
% 	 %% FIXME: unused variable..
% %	 UTimeMSecs =  UnixTime1000 mod 1000
% 	 %% convert to number of seconds since 00:00:00 GMT, Jan. 1, 1900
% 	 NTPTime = UTimeSecs + ConversionConstant
% 	 %% fractional part of seconds...
% 	 %%
% 	 %% FIXME:
% 	 %%
% 	 %% !! tmp: for now the fractional part is just zeros, later I may allow for a more accurate input time..
% 	 FractionalPart = [0 0 0 0 0 0 0 0]
%       in
% 	 {FormatHex {Append 
% 		     %% seconds in HEX
% 		     {DecimalToHex_Int NTPTime}
% 		     FractionalPart}}
%       end
   
      /** %% [aux] NTPTime1000 (an int: NTP time in msecs) transformed into UNIX time in msecs (an int).
      %% */
      fun {NTPToUnixTime1000 NTPTime1000}
	 NTPTime1000 - ConversionConstant1000
      end
   end

   /** %% [aux] Outputs list of 'digits' for hexadecimal number of the decimal number X (an int).
   %% NB: integers are used as figures: i.e. the decimal number 31 is represented as [1 15] instead of the usual 1F.
   %% */
   fun {DecimalToHex_Int X}
      fun {Aux X Accum}
	 Rem = X mod 16
	 Quot = X div 16
      in
	 if Quot==0 then Rem|Accum
	 else {Aux Quot Rem|Accum}
	 end
      end
   in
      {Aux X nil}
   end
   /** %% [aux] Convert the fractional part. X is in [999, 0] msecs, corresponding to [0.999, 0.0] secs. 
   %% */
   fun {DecimalToHex_Frac X}
      fun {Aux X Accum I}
	 Num = X * 16
	 Rem = Num mod 1000
	 Quot = Num div 1000
      in
	 %% max 8 digits
	 if Rem==0 orelse I==7 then Quot|Accum
	 else {Aux Rem Quot|Accum I+1}
	 end
      end
   in
      {Reverse {Aux X nil 0}}
   end
   /** %% [aux] Transforms a list of integers representing a hexadecimal number (as returned by DecimalToHex) into a VS in the usual format.
   %% The dumpOSC output format is created: lowercase letters are used with (however, sendOSC also understands uppercase letters and leading 0x).
   %% */
   fun {FormatHex Xs}
      {LUtils.accum {Map Xs fun {$ X}
			       case X of 10 then 'a'
			       [] 11 then 'b'
			       [] 12 then 'c'
			       [] 13 then 'd'
			       [] 14 then 'e'
			       [] 15 then 'f'
			       else X
			       end
			    end}
       fun {$ X Y}
	  X#Y
       end}
   end


   /* %% Input is hex digit (a character) and returned is the corresponding integer.
   %% NB: Output for non-hex chars is unspecified.
   %% */
   fun {HexCharToInt Chr}
      if Chr =< &9
      then Chr - &0
      elseif Chr >= &a 
      then Chr - &a + 10
      end
   end
%       %% less efficient, but more easy/secure versions
%       fun {HexCharToInt3 Char}
% 	 case Char
% 	 of &0 then 0
% 	 [] &1 then 1
% 	 [] &2 then 2
% 	 [] &3 then 3
% 	 [] &4 then 4
% 	 [] &5 then 5
% 	 [] &6 then 6
% 	 [] &7 then 7
% 	 [] &8 then 8
% 	 [] &9 then 9
% 	 [] &a then 10
% 	 [] &b then 11
% 	 [] &c then 12
% 	 [] &d then 13
% 	 [] &e then 14
% 	 [] &f then 15
% 	 end
%       end
%       %% !!?? is this really more efficient? If I am 100% sure Char is hex digit, then I can reduce code further.
%       fun {HexCharToInt2 Char}
% 	 if Char >= &0 andthen Char =< &9
% 	 then Char - &0
% 	 elseif Char >= &a andthen Char =< &f
% 	 then Char - &a + 10
% 	 end
%       end

   /*
   {HexCharToInt &b}
   {HexCharToInt &2}
   */
      
   /** %% [aux] Expects an hex number (string of exactly 16 ints/chars a-f, where the first 8 digits are greater 1 and the last 8 digits are less then 1, i.e. the last 8 digits are behind the dot) and returns the corresponding decimal integer times 1000.
   %% */
   fun {HexToDecimal1000 HexChars}
      %% internal accuracy: times 1000000 (i.e. 3 digits more accurate) 
      Factors = unit(268435456000000 16777216000000 1048576000000 65536000000 4096000000 256000000 16000000 1000000
		     62500 3906 244 15
		     %%% orig accuracy with floats
		     % 0.0625 0.00390625 0.000244140625 1.52587890625e~05 9.5367431640625e~07 5.9604644775391e~08 3.7252902984619e~09 2.3283064365387e~10
		    )
      Int1000000 Rem
   in
      %% !! tmp exception
%   if {Length Bins} \= 16 then raise uncorrectLength(HexChars) end end
      Int1000000 = {LUtils.accum
		    {List.mapInd
		     %% NB: the last 4 digits are rather irrelevant -- I just ignore them
		     {List.take HexChars 12}
		     fun {$ I X} {HexCharToInt X} * Factors.I end}
		    Number.'+'}
      % go back to accuracy of integer times 1000 (round)
      Rem = Int1000000 mod 1000
      Int1000000 div 1000 + (if Rem >= 500 then 1 else 0 end)
   end
      
   /*
   {BinaryToDecimal "ca95573d00000000"}
   */

      
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% buffering OSC messages 
%%%


   /** %% This class defines a buffer for any incoming data (e.g., OSC packets): arriving data is collected with the method put, and all data collected so far retrieved with the method getAll.  
   %% */ 
   class Buffer
      
      attr xlist
	
      meth init
	 @xlist = {New LUtils.extendableList init}
      end

      /** %% Add X to the tail of the buffer.
      %% */
      meth put(X)
	 {@xlist add(X)}
      end

      /** %% Returns Xs, a list with all buffer elements collected so far (since the last call of getAll), and empties the buffer. Elements in Xs are in the order they where written into the buffer.
      %% */
      meth getAll(?Xs)
	 {@xlist close}
	 Xs = @xlist.list
	 xlist <- {New LUtils.extendableList init}
      end
      
   end
   
   
end

   
