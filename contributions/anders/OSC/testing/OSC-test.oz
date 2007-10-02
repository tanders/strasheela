
declare
[OSC] = {ModuleLink ['x-ozlib://anders/strasheela/OSC/OSC.ozf']}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Oz OSC output -> dumpOSC -> sendOSC -> Oz OSC input
%%% 

/*

declare
MyPort = 1234
%% create dumpOSC and sendOSC interface with same port
MyDumpOSC = {New OSC.dumpOSC init(port:MyPort)}
%% default host is localhost..
MySendOSC = {New OSC.sendOSC init(port:MyPort)}
%% browse stream of all OSC packets received
{Browse {MyDumpOSC getOSCs($)}}
%% show strings in browser
{Browser.object option(representation strings:true)}


{MySendOSC send('/foo'(bar 3.14 42))}

%% negative number
{MySendOSC send('/test'(~3.14))}

{MySendOSC send('/test'(~42))}

%% bundle (without time tag!)
{MySendOSC send(['/foo'(bar 3.14 42)])}

%% nested bundle
{MySendOSC send([['/foo' '/bar']
		 '/test'("hi there" follow)])}

%% bundle with future time tag
{MySendOSC send([{OSC.timeNow} '/foo'(bar 3.14 42)])}


{MyDumpOSC close}
{MySendOSC close}

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% addResponder
%%%
%%% NOTE: no time tags yet ..
%%%

/*

declare
MyPort = 1234
MyDumpOSC = {New OSC.dumpOSC init(port:MyPort)}
%% default host is localhost..
MySendOSC = {New OSC.sendOSC init(port:MyPort)}
{MyDumpOSC addResponder('/foo' proc {$ Timetag Msg} {Browse foo#Msg} end)}
{MyDumpOSC addResponder('/bar' proc {$ Timetag Msg} {Browse bar#Msg} end)}
%% show strings in browser
{Browser.object option(representation strings:true)}




{MySendOSC send('/foo'(hi))}

{MySendOSC send('/bar'(there))}

%% bundle 
{MySendOSC send(['/foo'(some test)])}

*/

/*

%%
%% store incoming OSC messages in a buffer -- except for the message /trigger, which emties the buffer and sends its content somewhere (here, it is just browsed) 
%%


declare
MyPort = 1234
MyDumpOSC = {New OSC.dumpOSC init(port:MyPort)}
%% default host is localhost..
MySendOSC = {New OSC.sendOSC init(port:MyPort)}
MyBuffer = {New OSC.buffer init}
%% addDefaultResponder matches any OSC packet for which no other responder exists
{MyDumpOSC setDefaultResponder(proc {$ Timetag Msg} {MyBuffer put(Msg)} end)}
{MyDumpOSC addResponder('/trigger' proc {$ _ /*Timetag*/ _/* Msg */}
				      {Browse {MyBuffer getAll($)}}
				   end)}
%% show strings in browser
{Browser.object option(representation strings:true)}



{MySendOSC send('/foo'(bar 3.14 42))}

%% bundle (without time tag!)
{MySendOSC send(['/bar'(3.14 42)])}

%% bundle with future time tag
{MySendOSC send([{OSC.timeNow}+10000 '/timedBundle'(bar 3.14 42)])}


{MySendOSC send('/trigger')}


*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Strasheela score to OSC
%%%

/*

%%
%% Transforms the nested score into a flat event list, where each note
%% is represented by a bundle of the following format. Start times are
%% integers measuring time in msecs from some start time 0. Durations
%% are measured in seconds, pitch and amplitude in Midi, all as
%% floats.
%%
%% [StartTime '\note'(Duration Pitch Amplitude)]
%%
%% The list surrounding these events is a bundle with starttime of
%% score.
%%

declare
/** %% Output start time of score object X in milliseconds (as int).
%% */
fun {MakeTimeTag X}
   {FloatToInt {X getStartTimeInSeconds($)}*1000.0}
end
MyScore = {Score.makeScore sim(items:[seq(items:[note(duration:2
						      pitch:64
						      amplitude:64)
						 note(duration:2
						      pitch:65
						      amplitude:64)
						 note(duration:4
						      pitch:67
						      amplitude:64)
						 note(duration:4
						      pitch:62
						      amplitude:64)])
				      seq(items:[sim(items:[note(duration:8
								 pitch:48
								 amplitude:64)
							    note(duration:8
								 pitch:55
								 amplitude:64)])
						 sim(items:[note(duration:4
								 pitch:50
								 amplitude:64)
							    note(duration:4
								 pitch:54
								 amplitude:64)])])]
			       startTime:0
			       timeUnit:beats(4))
	   unit}
{MyScore wait}
OSCs = {MakeTimeTag MyScore}
  | {Sort
     {Out.scoreToEvents MyScore
      [isNote#fun {$ MyNote}
		 %% transform function returns list of events: ie. bundle in list
		 [[{MakeTimeTag MyNote}
		   '\note'({MyNote getDurationInSeconds($)}
			   {MyNote getPitchInMidi($)}
			   {MyNote getAmplitudeInVelocity($)})]]
	      end]
      unit}
     %% sort events by start time
     fun {$ X Y} X.1 =< Y.1 end}
{Browse OSCs}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% OSC to Strasheela score
%%%

/*

%%
%% Interpret each bundle as simultaneous container with the given start time
%%
%% 
%% Expects the following OSC format
%%
%% '\note'(StartTime Duration Pitch Amplitude)
%%

declare
MyOSC = [0 [0 '\note'(0 2.0 64 64)]]
/** %% Expects an OSC packet and transforms it into a Strasheela textual score, where bundles are transformed into simultaneous containers. 
%% Bundles must contain a timetag as UNIX time msecs integer (timetags are always output by sendOSC), and this timetag is used as simultaneous startTime. 
%% FIXME: make time format user-controllable.
%% */
fun {BundlesToSims MyOSC}
   case MyOSC of TimeT | Packets
   then sim(items:{Map Packets BundlesToSims}
	    timeUnit:msecs
	    startTime:TimeT)
   else MyOSC
   end
end
fun {MakeNote '\note'(Start Duration Pitch Amplitude)}
   {Score.makeScore2 note(startTime:Start
			  duration:{FloatToInt Duration}
			  pitch:Pitch
			  amplitude:Amplitude)
    unit}
end
TransformedOSCs = {BundlesToSims MyOSC}
MyScore = {Score.makeScore TransformedOSCs
	   unit('\note':MakeNote
		sim:Score.simultaneous)}
{Inspect MyScore}


*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% dumpOSC Interface
%%% 

/*

%% as above
declare
MyDumpOSC = {New OSC.dumpOSC init(port:1234)}
{Browse {MyDumpOSC getOSCs($)}}


{MyDumpOSC close}

%%
%% internal tests (user shouldn't do this): 
%%
declare Xs
thread Xs = {MyDumpOSC parseAll($)} end
{Browse Xs}

%% accessing the next line directly
{Browse {MyDumpOSC.dumpOSC getS($)}}


*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% sendOSC interface
%%%
%%% NB: no sendOSC output is shown 
%%% 

/*

%% first start some OSC server (e.g., dumpOSC, see above) at given port 

declare
%% default host is localhost..
MySendOSC = {New OSC.sendOSC init(port:1234)}

%%
%% you can raw sendOSC input with cmd method 
%%


%% bundle with future time tag
%% TODO: test whether this time is correct (e.g. with SuperCollider)
{MySendOSC send([{OSC.timeNow}+10000 '/foo'(bar 3.14 42)])}


%% send some test message
{MySendOSC cmd("/test 3.14 foo bar 42")}

%% send a bundle 
{MySendOSC cmd("[ 1\n/test \"hi there\"\n]")}

%% send two messages in one go
{MySendOSC cmd("/foo 42\n/bar 42")}

%% mix of bundles and messages 
{MySendOSC cmd("[ 1\n/test -3.14 \"hi there\" \"3-x\" 42\n/hiThere 1 3.13\n]\n[ 1\n/test -3.14 \"hi there\" \"3-x\" 42\n]\n/hiThere 1 3.13\n/bla \"foo\" 42")}


%% NB: showAll blocks, and does not show the expected output
{MySendOSC showAll}
{Browse hi}

{MySendOSC close}

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% OSC message round trip duration: Oz -> sendOSC -> dumpOSC -> Oz 
%%%
%%% store time when message was started in message
%%%
%%% Result (measurements where taken on a 2.2 GHz Macbook Pro) using
%%% UDP: round trip most times takes less than a msec, sometimes it is
%%% 10 msecs, and rather seldomly even more -- that should be
%%% sufficient for now ;-)
%%%
%%% NB: the latency is likely introduced by network irregularities
%%% (because: why should other parts of the program perform
%%% irregularily). Also, note that the communication between sclang
%%% and scserver has a latency of about 20 msecs: evaluate one of the
%%% following lines in sclang, and the server s reports the latency.
%%%
%%% s.ping(10, 1) 
%%% s.sendBundle(0.0, ["/s_new", "default", x = s.nextNodeID, 0, 1], ["/n_set", x, "freq", 500]);
%%% 

/*

declare
%% returns some time in msecs 
fun {TimeNow} {Property.get 'time.total'} end
MyPort = {GUtils.random 10000} + 2000
MyDumpOSC = {New OSC.dumpOSC init(port:MyPort)}
MySendOSC = {New OSC.sendOSC init(port:MyPort)}
{MyDumpOSC addResponder('/timetest'
			proc {$ Timetag Msg}
			   End = {TimeNow}
			   Start = Msg.1
			in
			   {Browse duration(End - Start)}
			end)}


%% send a few timetest tmessages
{MySendOSC cmd("/timetest "#{TimeNow})}


*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% OSC.buffer
%%%

/*

declare
MyBuffer = {New OSC.buffer init}

{MyBuffer put(a)}
{MyBuffer put(b)}
{MyBuffer put(c)}

{MyBuffer put(1)}
{MyBuffer put(2)}
{MyBuffer put(3)}

{Browse {MyBuffer getAll($)}}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Test timetag creation and parsing 
%%%
%%% Send message with UNIX time timetag in msecs and transform timetags in
%%% received messaged back into UNIX time in msecs. The time tags send and
%%% received should be equal
%%%

/*

declare
{Init.putStrasheelaEnv sendOSC "/Users/t/Download/send+dumpOSC-OSX/sendOSC"}
MyPort = {GUtils.random 10000} + 2000
MyDumpOSC = {New OSC.dumpOSC init(port:MyPort)}
MySendOSC = {New OSC.sendOSC init(port:MyPort)}


declare
StartTime = {OSC.timeNow}
{MyDumpOSC setBundleResponder(proc {$ TTag | Packets}
				 {Inspect received( TTag-StartTime | Packets)}
			      end)}

declare
{ForAll {List.number 0 10 1}
 proc {$ I}
    TTag = StartTime + (I * 1000)
 in
    {Inspect send([I * 1000 '/test'])}
    %% send a few timetest messages
    {MySendOSC send([TTag '/test'])}
 end}

*/


%%
%% create HEX timetags and convert them back for testing
%%

/*

declare
%% msecs between 1900-01-01 and 1970-01-01
ConversionConstant1000 = ((70 * 365 + 17) * 86400) * 1000
Now = {OSC.timeNow}

%% returns Now again
{OSC.hexToDecimal1000 
 {VirtualString.toString {OSC.formatTimeTag Now}}} - ConversionConstant1000

%% returns 10001 
{OSC.hexToDecimal1000 
 {VirtualString.toString {OSC.formatTimeTag 10001}}} - ConversionConstant1000

%% etc..
{OSC.hexToDecimal1000 
 {VirtualString.toString {OSC.formatTimeTag 10002}}} - ConversionConstant1000

{OSC.hexToDecimal1000 
 {VirtualString.toString {OSC.formatTimeTag 1000}}} - ConversionConstant1000

{OSC.hexToDecimal1000 
 {VirtualString.toString {OSC.formatTimeTag 1}}} - ConversionConstant1000


{OSC.hexToDecimal1000 
 {VirtualString.toString {OSC.formatTimeTag 2}}} - ConversionConstant1000

{OSC.hexToDecimal1000 
 {VirtualString.toString {OSC.formatTimeTag 100}}} - ConversionConstant1000


*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% OSC.dumpOSC method parseVS (not exported anymore)
%%%

/*

declare
MyDumpOSC = {New OSC.dumpOSC init(port:1234)}

%% !! blocks?
{Browse {MyDumpOSC parseVS($  "/test 3.140000 \"foo\" 42")}}


%% OLD
%% 
%% OK
{Browse {OSC.parseOSC "/test 3.140000 \"foo\" 42"}}

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% timetag for sendOSC
%%

/*
%% 

%% show time now and one second later (as VS)
{Browse {OSC.formatTimeTag {OS.time}}}
{Browse {OSC.formatTimeTag {OS.time}+30}}

{Browse {VirtualString.toAtom {OSC.formatTimeTag {OS.time}}}}

%% 1 min from now
{Browse {VirtualString.toAtom {OSC.formatTimeTag {OS.time}+60}}}


%% 10 minutes from now
{Browse {VirtualString.toAtom {OSC.formatTimeTag {OS.time}+600}}}

%% at 1 Jan 1970, 0:00 h
{Browse {OSC.formatTimeTag 0}}

%% create timed bundle for sendOSC
{System.showInfo "[ 0x"#{VirtualString.toAtom {OSC.formatTimeTag {OS.time}+60}}#"\n"
 #"/west bla"
 #"\n]"}



%% Elapsed real time in milli seconds from an arbitrary point in the past (for example, system start-up time).
%% !!?? how to set that arbitrary point? Does that mean some random time point?
{Property.get 'time.total'}


%% returns UNIX time (i.e. the time since 00:00:00 GMT, Jan. 1, 1970 in seconds)
{OS.time}

{OS.gmTime}

*/

/*
%% decimalToHex and formatHex not exported by OSC

{OSC.decimalToHex 15}
{OSC.decimalToHex 17}
{OSC.decimalToHex 31}

{OSC.formatHex {OSC.decimalToHex 31}}
*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% read OSC format with gump into Oz
%%% 

/*

\switch +gump 
\switch +gumpparseroutputsimplified +gumpparserverbose
declare  % for scanner/parser classes
\insert ../OSC_Scanner.ozg 
\insert ../OSC_Parser.ozg 


%% testing the scanner: I don't need this later
local
%   OSC_VS = "/test -3.14 \"hi there\" \"3-x\" 42"
   OSC_VS = "[ 1
/test -3.14 \"hi there\" \"3-x\" 42
]"
   MyScanner = {New OSC_Scanner init()}
   proc {GetTokens} T V in 
      {MyScanner getToken(?T ?V)}
      case T of 'EOF' then 
         {System.showInfo 'End of file reached.'}
      else 
         {System.show T#V}
         {GetTokens}
      end 
   end 
in 
   {MyScanner scanVirtualString(OSC_VS)}
   {GetTokens}
   {MyScanner close()}
end

declare
%%  Testing the parser: this will be actually used.. 
fun {ParseOSC VS} 
   MyScanner = {New OSC_Scanner init()}
   MyParser = {New OSC_Parser init(MyScanner)}
   Packets Status
in 
   {MyScanner scanVirtualString(VS)}
   {MyParser parse(packet(?Packets) ?Status)}
   {MyScanner close()}
   if Status then
%      {System.showInfo 'accepted'}
      Packets
   else 
%      {System.showInfo 'rejected'}
%      nil
      %% !! tmp exception
      raise parserError(VS) end
   end 
end


{Browse {ParseOSC "/test -3.14 \"hi there\" \"3-x\" 42"}}

{Browse {ParseOSC '/test -3.14 "hi there" "3-x" 42'}}

% bundle
{Browse {ParseOSC "[ 1\n/test -3.14 \"hi there\" \"3-x\" 42\n]"}}

% nested bundle
{Browse {ParseOSC "[ 000000001\n/foo \"bar\" 3.140000 42\n]\n[ 000000001\n[ 000000001\n/foo \n/bar \n]\n/test \"hi there\" \"follow\" \n]"}}

%% multiple messages..
{Browse {ParseOSC "
/hiThere 1 3.13
/bla \"foo\" 42
"}}

%% mix of bundles and messages 
{Browse {ParseOSC "[ 1
/test -3.14 \"hi there\" \"3-x\" 42
/hiThere 1 3.13
]
[ 1
/test -3.14 \"hi there\" \"3-x\" 42
]
/hiThere 1 3.13
/bla \"foo\" 42
"}}


%% unfinished list of messages etc: Parser rejects (see def of ParseOSC)!
{Browse {ParseOSC "[ 1
/test -3.14 \"hi there\" \"3-x\" 42
/hiThere 1 3.13
]
/hiThere 1 3.13
/bla \"foo\" 42
[
/hiThere 1 3.13
"}}

*/




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%
%%% old stuff
%%%
%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% tmp: getting dumpOSC working..
%%%
%%% 
%%%

/*

declare
%% tmp
[Socket] = {ModuleLink ['x-ozlib://anders/strasheela/OzServer/source/Socket.ozf']}
%%
NetCatPort = 7777
class DumpOSCInterface from Open.socket Open.text
end  
/** %% Creates a UDP socket server. Expects a Host (e.g., 'localhost') and a PortNo and returns a server plus its corresponding client. This client is an instance of Open.socket, and is the interface for reading and writing into the socket.
%% MakeServer blocks until the server listens. However, waiting until a connection has been accepted happens in its own thread (i.e. MakeServer does only block until the server listens). */
%% Copied and slightly modified from OzServer/source/Socket.oz. See doc there for further comments in code.. 
proc {MakeServer PortNo ?MyServer ?MyClient}
   proc {Accept MyClient}
      thread H in 
	 %% suspends until a connection has been accepted
	 {MyServer accept(host:H
			  acceptClass: DumpOSCInterface %  Open.socket 
			  accepted:?MyClient)} 
	 {System.showInfo "% connection accepted from host "#H}
      end
   end
in
   %% first test with TCP (the default)
   MyServer = {New Open.socket init}
   % MyServer = {New Open.socket init(type:datagram)} % protocol is UDP
   {MyServer bind(host:localhost takePort:PortNo)}
   %% no listing in case of UDP?
   {MyServer listen}
   {System.showInfo "% Socket listens at port "#PortNo}
   MyClient = {Accept}
end
%% create the UDP server before calling dumpOSC |nc to send its output here
MyServer
%% MyDumpOSC only bound after client connected
MyDumpOSC = {MakeServer NetCatPort MyServer}
% MyDumpOSC = {Socket.makeServer localhost NetCatPort MyServer}


declare
Term = 'xterm'
%% add doc: only works on UNIX
%% !!?? add warning: only works on UNIX
% IsWin = {Property.get 'platform.os'} == 'win32'
%% !! Oz Bug: this should be {Property.get 'platform.os'}
IsMac = {Property.get 'platform.arch'} == 'darwin'
X11 = '/Applications/Utilities/X11.app' % set in Strasheela env
%% starts X11 if it is not running (changes focus to X11 in any case)
if IsMac then {Out.exec 'open' [X11]} end
% DumpOSCPath = "/Users/t/Download/send+dumpOSC-OSX/dumpOSC"
DumpOSCPath = "/Users/t/c_cpp/OSC/CNMAT/dumpOSC/dumpOSC"
Port = 1234
NetCat = 'nc'
%% 
MyCmd = DumpOSCPath#" -quiet "#Port#" | "#NetCat#" localhost "#NetCatPort
% MyCmd = DumpOSCPath#" "#Port#" | "#NetCat#" -u localhost "NetCatPort
%% !!?? do different nc implementation have different options?
%% !!?? use UDP for netcat, because dumpOSC uses UDP anyway
% {Out.execNonQuitting 'xterm'
%  [% "-T" "\"dumpOSC to Strasheela interface\""
%   "-e" "\"echo '"#MyCmd#"'; echo 'closing this windows stops OSC input to Strasheela!'; "#MyCmd#"\""]}
{Out.execNonQuitting 'xterm'
 ["-e" "echo closing this windows stops OSC input to Strasheela!; "#MyCmd]}
% {Out.execNonQuitting 'xterm' ["-e" MyCmd]}


%% !! causes output 'no port[s] to connect to'

/*
%% this is OK (at least no such warning)
./dumpOSC -quiet 1234 | nc localhost 7777

xterm -T 'dumpOSC to Strasheela interface' -e "echo '/Users/t/c_cpp/OSC/CNMAT/dumpOSC/dumpOSC 1234 | nc localhost 7777';  echo 'closing this windows stops OSC input to Strasheela!'; /Users/t/c_cpp/OSC/CNMAT/dumpOSC/dumpOSC 1234 | nc localhost 7777"  

*/


%% read a line
{MyDumpOSC getS($)}




%% OK
{Out.execNonQuitting 'xterm' ["-e" "cat -"]}

{Out.execNonQuitting 'xterm' ["-e" "echo cat -; cat -"]}










%% terminals on Mac OS X

/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal


%% xterm supported by Linux and Mac OS X, so I use that per default.. However, as always, don't hardwire, and make also the option starting my dumpOSC | nc pipe user-controllable
%%
xterm 


%% for xterm, X must be running. Can I check or force that automatically.
%% I can start application with following, but rerunning it starts another X11
/Applications/Utilities/X11.app/Contents/MacOS/X11
%% this does the trick (changes focus to X11)
open /Applications/Utilities/X11.app

xterm -T "test title" -e "echo '$ cat -'; cat -"


%% this would open a terminal, if non was open already
open /Applications/Utilities/Terminal.app

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% !!?? General problem of Open.pipe if end of input is not known -- I don't think this is my problem
%%%
%%% see http://lists.gforge.info.ucl.ac.be/pipermail/mozart-users/2002/002800.html
%%% 
%% -> message was never anwsered 
%%

/*

declare
SortPipe = {New Open.pipe init(cmd:"sort") $}
Input = "Here is the first line.\nAnd here is line two.\nLast line."

{SortPipe write(vs:Input)}

{Browse {SortPipe read(list: $)}}

{SortPipe close}

*/

%%
%% do I want/need to explicitly read stdin with Open.file?
%%

/*
http://lists.gforge.info.ucl.ac.be/pipermail/mozart-users/2003/003287.html

*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Perl: simple test
%%%
%%% move this into Output-test.oz
%%% 

/*

declare
MyShell = {New Out.shell init}
{MyShell showAll}

%% watch stdout
{MyShell cmd("/Users/t/perl/hello.pl")}

%% !! this works!


{MyShell cmd("/Users/t/perl/hello-edit.pl")}

%% now, send OSC packets with sendOSC (from commandline)

{MyShell close}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Perl: Net-OpenSoundControl 
%%% 


/*

declare
ServerPath = "/Users/t/Download/Net-OpenSoundControl-0.05/examples/oscserver.pl"
MyShell = {New Out.shell init}
{MyShell showAll}

%% receive input from port 7777
%% watch stdout
{MyShell cmd(ServerPath)}

%% !!! again, I don't see the output! 

%% now, send OSC packets with sendOSC (from commandline)

{MyShell close}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% sendOSC interface
%%% 

/*

%%
%% sendOSC works, but no output is shown..
%%

declare
MySendOSC = {New OSC.sendOSC init(port:1234)}

%% !! showAll blocks, and does not show the expected output
{MySendOSC showAll}
{Browse hi}

%% OK
{MySendOSC cmd("/test 3.14 foo bar 42")}

{MySendOSC close}

*/


/*

declare
SendOSCPath = "/Users/t/Download/send+dumpOSC-OSX/sendOSC"
MySendOSC = {New Out.shell init(cmd:SendOSCPath args:["-h" localhost 1234])}

%% !! showAll block, and does not show the expected output
{MySendOSC showAll}
{Browse hi}

%% OK
{MySendOSC cmd("/test 3.14 foo bar 42")}

{MySendOSC close}

*/


/*

%%
%% why is sendOSC output (and dumpOSC output) not shown with method showAll?
%%

% this causes redirection of stdout, and greeting message is not shown anymore
$ ./sendOSC -h localhost 1234 > ~/tmp/test.log 

% however, noting ends up in ~/tmp/test.log either
$ cat ~/tmp/test.log 
$

%% Is the output written in some unstandard way, which may be the reason why I don't get it into Oz?
%% .. at the second try it worked!
%% ! no output is created when I close process with ^C, but with ^D it works fine!
%% -> this means no output is redirected during runtime, only afterwards..
%% !!?? does sendOSC need some special signal sent for writing its output?


% when I do piping, the writing is also delayed
$ ./sendOSC -h localhost 1234 | cat
% shows noting
% doing ^C then quits the pipe and still shows nothing
% doing ^D instead, quits the pipe and then shows the greeting ..


%% On the commandline, this works as expected. But not when started from Oz.. 
$ /dumpOSC 1234 | cat


%%
%% dumpOSC redirects slightly different: no redirection during runtime, but if program is terminated with ^C, the output is written. ^D, on the other hand, has no effect for dumpOSC. 
%%

%% !! does output immediately!
$ .dumpOSC 1234 | cat 


%%
%% It appears, sendOSC and dumpOSC are not written according to UNIX standards. There text output is blocking when redirected. 
%%

%%
%% when dumpOSC is executed with Out.shell (either directly or in sh) and then closed, no output is shown
%%
%% likewise, when sendOSC is executed with Out.shell and then closed, no output is shown
%%

%%
%% questions:
%%  - do sendOSC/dumpOSC (and perhaps python) need any special UNIX signals to cause them output 
%%  - if so, can I send these signals from Oz?
%%

%%
%% !!?? can I flush the buffer for stdin?
%% -> the Open.pipe method flush "Blocks until all requests for reading and writing have been performed." That doesn't help me..
%%

*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% dumpOSC interface
%%% 

/*

%% after running this, send OSC messages at port 1234 (e.g., with sendOSC)

declare
MyDumpOSC = {New OSC.dumpOSC init(port:1234)}

%% !! nothing at all happens yet, parseAll blocks -- even after closing MyDumpOSC
{Browse {MyDumpOSC parseAll($)}}
{Browse hi}

{MyDumpOSC close}

*/


/*
% stupid test: enter some command in init method, but never any cmd method: this works
% NB: it shows: shell has died! 
declare
MyShell = {New Out.shell init(cmd:"ls" args:["-l" "/users/"])}
{MyShell showAll}

{MyShell close}

*/

/*

declare
DumpOSCPath = "/Users/t/Download/send+dumpOSC-OSX/dumpOSC"
MyShell = {New Out.shell init(cmd:DumpOSCPath args:[1234])}
{MyShell showAll}

{MyShell close}

*/

/*

%% ;) somewhat desperate try -- still doesn't work.

declare
%% !! tmp PATH
DumpOSCPath = "/Users/t/Download/send+dumpOSC-OSX/dumpOSC"
MyShell = {New Out.shell init}
{MyShell showAll}

{MyShell cmd(DumpOSCPath#" 1234 | cat")}

% {MyShell cmd(DumpOSCPath#" 1234 -quiet")}

%% after running this, send OSC messages at port 1234 (e.g., with sendOSC)
%% !! nothing is output to stdout??

{MyShell close}

*/

/*

%% telling bash that it is interactive (option "-i"): makes still no difference

declare
%% !! tmp PATH
DumpOSCPath = "/Users/t/Download/send+dumpOSC-OSX/dumpOSC"
MyShell = {New Out.shell init(cmd:"bash" args:["-i"])}
{MyShell showAll}

{MyShell cmd("ls ~")}

{MyShell cmd(DumpOSCPath#" 1234")}

% {MyShell cmd(DumpOSCPath#" 1234 -quiet")}

%% after running this, send OSC messages at port 1234 (e.g., with sendOSC)
%% !! nothing is output to stdout??

{MyShell close}

*/



/*

%% In contrast to using it on the commandline, in this exammple dumpOSC does not produce any output to the log file -- even not after {MyShell close} was called.
%%
%% How does {MyShell close} close/kill the shell? 

declare
%% !! tmp PATH
DumpOSCPath = "/Users/t/Download/send+dumpOSC-OSX/dumpOSC"
MyShell = {New Out.shell init}
{MyShell showAll}

{MyShell cmd(DumpOSCPath#" 1234 &> /Users/t/tmp/test.log")}

% {MyShell cmd(DumpOSCPath#" 1234 -quiet")}

%% after running this, send OSC messages at port 1234 (e.g., with sendOSC)
%% !! nothing is output to stdout??

{MyShell close}

*/

/*
%% why does this not work?? On which channel is output shown?
%% -> I tried on commandline: dumpOSC outputs at stdout
%% Same problem as with python??

declare
%% !! tmp PATH
DumpOSCPath = "/Users/t/Download/send+dumpOSC-OSX/dumpOSC"
MyShell = {New Out.shell init}
{MyShell showAll}

{MyShell cmd(DumpOSCPath#" 1234")}

% {MyShell cmd(DumpOSCPath#" 1234 -quiet")}

%% after running this, send OSC messages at port 1234 (e.g., with sendOSC)
%% !! nothing is output to stdout??

{MyShell close}

*/


/*

% cat test: works fine 
declare
MyShell = {New Out.shell init(cmd:"cat" args:["-"])}
{MyShell showAll}

{MyShell cmd(test)}

{MyShell close}

*/


/*

% stupid test: enter some command in init method, but never any cmd method: this works
% NB: it shows: shell has died! 
declare
MyShell = {New Out.shell init(cmd:"ls" args:["-l" "/users/"])}
{MyShell showAll}

{MyShell close}

*/

/*

declare
S = {New Out.shell init}
{S showAll}

{S cmd("cd /Users/t/Download/send+dumpOSC-OSX/")}
{S cmd("ls -la")}

%% !! Silence
{S cmd("./dumpOSC 1234")}

%% OK: causes error: line 1: ./dumpOS: No such file or directory
%% so the command was found then before
{S cmd("./dumpOS 1234")}

%% !! Silence: same symptoms (not necessarily same problem..)
{S cmd("python")}

{S cmd("1 + 2")}



%% works but no output shown
{S cmd("./sendOSC -h localhost 1234")}
{S cmd("/test")}


{MyShell close}

*/

/*

%% test on plain command line with sed shows that output of dumpOSC contains non-print characters: there is a special line end (but perhaps this is just the newline char..)

./dumpOSC 1234 | sed l  dumpOSC version 0.2 (6/18/97 Matt Wright). Unix/UDP Port 1234 $
dumpOSC version 0.2 (6/18/97 Matt Wright). Unix/UDP Port 1234 
Copyright (c) 1992,96,97,98,99,2000,01,02,03 Regents of the University of C\
alifornia.$
Copyright (c) 1992,96,97,98,99,2000,01,02,03 Regents of the University of California.
/test $
/test 

-> you can tick this: there are no nonprintable characters in the dumpOSC output. "Long lines are folded, with the point of folding indicated by displaying a backslash followed by a new-line.  The end of each line is marked with a ``$''." (see man sed for details on representation of nonprintable characters)

*/




/*

%% using dumpOSC-wrapper

declare
MyShell = {New Out.shell init}
{MyShell showAll}

{MyShell cmd("cd ~/c_cpp/OSC/CNMAT/dumpOSC")}

{MyShell cmd("./dumpOSC-wrapper")}

{MyShell close}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% old stuff: formatting of binary OSC messages
%%% 
%%%

/*

/** %% Expects an Oz string (without any null characters) and pads it with null characters according to the OSC Spec. Returns VS.
%% */
fun {MakeOscString MyString}
   L = {Length MyString}
   Min0ToAdd = 1
   X = {Int.'mod' L+Min0ToAdd 4}
   N = if X==0 then Min0ToAdd else 5-X end
in
   MyString#{Map {List.make N} fun {$ _} 0 end}
end

*/

/*
%% test

{MakeOscString "hithere"}
{MakeOscString "hi there"}
{MakeOscString "hi  there"}

*/

/*

/** %% Expects an Oz integer (in interval [-2^8 / 2, 2^8 / 2 - 1]) and returns a 32-bit big-endian two's complement integer represented my a list of 4 chars.
%% */
%% interval: [~{Pow 2 8*4} div 2  {Pow 2 8*4} div 2 - 1]
fun {MakeOscInt MyInt}
   %% !! Check range
   if MyInt >= 0 then {IntTo4Chars MyInt}
   else {Map {IntTo4Chars MyInt} TwosComplement}
   end
end


/** %% Transforms X (a char) into its two's complement (quasi bit flipping plus 1).
%% */
%% see http://en.wikipedia.org/wiki/Two's_complement
%% for details how to do two's complement integers...
fun {TwosComplement X}
   {BinaryToDecimal {BitwiseOr {DecimalToBinary X}}}
end

/** %% Transform int X into a list of 4 chars representing this int as 32 bit int.
%% This is only fine for [unsigned] int. 
%% */
fun {IntTo4Chars X}
   fun {Aux X Accum}
      Rem = X mod 256		% {Pow 2 8}=256, i.e. 8 bit for singe char
      Quot = X div 256
   in
      if Quot == 0 then Rem|Accum
      else {Aux Quot Rem|Accum}
      end
   end
   Result = {Aux X nil}
   L = {Length Result}
in 
   if L > 4
      %% !! tmp exception
   then raise tooLargeInt(X) end
   else
      N = 4 - L
   in
      {Append {Map {List.make N} fun {$ _} 0 end}
       Result}
   end
end

*/

/*
{IntTo4Chars 256}
{IntTo4Chars 255}
{IntTo4Chars 257}
*/
   
/*

/** %% Expects an integer and returns its binary representation as list of 0/1-ints.
%% */
fun {DecimalToBinary X}
   fun {Aux X Accum}
      Rem = X mod 2
      Quot = X div 2
   in
      if Quot==0 then Rem|Accum
      else {Aux Quot Rem|Accum}
      end
   end
in
   {Aux X nil}
end

*/

/*
{DecimalToBinary 255}
*/

/*

/** %% Expects a binary (list of 8 0/1-ints) and returns the corresponding integer (plain int).
%% */
fun {BinaryToDecimal Bins}
   Factors = unit(128 64 32 16 8 4 2 1)
in
   %% !! tmp exception
   if {Length Bins} \= 8 then raise uncorrectLength(Bins) end end
   {LUtils.accum {List.mapInd Bins fun {$ I X} X * Factors.I end}
    Number.'+'}
end

{BinaryToDecimal [1 1 1 1 1 1 1 0]}
{BinaryToDecimal [0 0 0 0 0 0 0 0]}
{BinaryToDecimal [0 0 0 0 0 0 0 1]}
{BinaryToDecimal [0 0 0 0 0 0 1 0]}

*/

/*

declare

*/



/*

/** %% Expects a binary (list of 8 0/1-ints) and returns the complement of this binary number (i.e., "flips all bits").
%% */
fun {BitwiseOr Bins}
   {Map Bins fun {$ X} if X==0 then 1 else 0 end end}
end

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% number encoding is somewhat complex (I need to control exact byte size of number representation). So, for now I simply represent numbers by strings containing numbers..
%%

/** %% 
%% */
%% !!?? how to create a 32-bit big endian two's complement integer? Oz supports Ints of arbitrary size...
% fun {MakeOscInt32 MyInt}
% end

/*
%% Oz floats are internally represented in double precision (64 bits) using the IEEE floating point standard.

%% is this string a 32 bit float spec??
{Float.toString ~1.1234567e~8}


%% have arbitrarily big ints always converted to floats??
{Float.toString {Int.toFloat 123456789}}


%% is this 32 bit??
{Float.toString 1.0}



%% a BitArray or BitString proably don't help me -- I can not output them
%% neither does ByteString: thats intended for textual data..

{BitString.make 32 [1 3]}

{ByteString.make 12}


{BitString.toList {BitString.make 32 [1 3]}}


%% ?? 7
{ByteString.width {ByteString.make 0.123456789}}

declare
X = 12345
Rem = X - {Pow 2 8*4}


declare
X = 257
Rem = X - {Pow 2 8}
%% Rem=1


declare
X = 65537
Rem = X - {Pow 2 8*2}



*/

