
declare 
[Out] = {ModuleLink ['x-ozlib://anders/music/sdl/Output.ozf']}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% transform data into virtual strings
%%

{Out.listToLines [a b c d]}

{Out.listToVS [a b c] ''}

{Out.recordToVS [a b c]}

{Out.recordToVS test(a(x:1 y:2) z:bla)}

{Out.recordToVS test([a b [1#c(2) d]] x:blau)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% general text output
%%

{Out.writeToFile "this is a test "#which#' continues here'
 "/tmp/test.oz"}


%% reads value as string
{Browse {Out.readFromFile "/tmp/test.oz"}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Out.toScoreConstructor
%%

declare
MyScore = {Score.makeScore seq(items:[note(duration:1
					   pitch:60
					   amplitude:64)
				      note(duration:1
					   pitch:60
					   amplitude:64)
				      note(duration:1
					   pitch:60
					   amplitude:64)]
			       startTime:0
			       timeUnit:(beats))
	   unit}


{Out.outputScoreConstructor MyScore
 unit(prefix:"{Score.makeScore\n"
      file:"testScore")}


%% tmp
%% ?? before store orig state of expression switch?
%% !! makes OPI unusable
% {OPI.compiler enqueue(setSwitch(expression false))}

%% this does not work: I can not call compiler in expression and in non-expression mode in the same statement!
{Browse {OPI.compiler enqueue(feedVirtualString("1 + 1" return(result:$)))}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% save/load score
%%


declare
MyScore = {Score.makeScore seq(items:[note(duration:1
					   pitch:60
					   amplitude:64)
				      note(duration:1
					   pitch:60
					   amplitude:64)
				      note(duration:1
					   pitch:60
					   amplitude:64)]
			       startTime:0
			       timeUnit:(beats))
	   unit}

{Out.saveScore MyScore unit}


%% !! Blocks
declare
MyLoadedScore = {Out.loadScore unit}

{MyLoadedScore toInitRecord($)}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Make output with Lisp syntax
%%

{Out.lispList test}
{Out.lispList ['+' 1 3 2]}

{Out.lispList ['clm::p' 0 {Out.lispKeyword duration} 10.0]}
{Out.lispList nil}

{Out.toDottedList ['+' 1 3 2]}

{Out.toDottedList [quote ['+' 1 3 2]]} % (quote . ((+ . (1 . (3 . (2 . nil)))) . nil))

{Out.writeToFile {Out.toDottedList [quote ['+' 1 3 2]]}
 "/home/t/test.lisp"}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Out.toLispKeywordList
%%

{Out.recordToLispKeywordList bla}
% bla

{Out.recordToLispKeywordList test(x:a y:1)}
% "(:x a :y 1)"

{Out.recordToLispKeywordList [1 3.14]}
% "(1 3.14)"

{Out.recordToLispKeywordList unit(1:[2 3 unit(a b)]
				  x:unit([foo bar] a:hi b:there)
				  y:2
				  z:2.5)}



declare
MyNote = {Score.makeScore note(startTime:0
			       duration:2
			       timeUnit:seconds
			       pitch:60
			       amplitude:127) unit}

{Out.toLispKeywordList
 MyNote
 unit(time:getStartTimeInSeconds
      dur:getDurationInSeconds
      keynum:fun {$ X} {X getPitchInMidi($)} end
      amplitude:getAmplitudeInNormalized)}

{Out.makeCMEvent
 MyNote
 midi(time:getStartTimeInSeconds
      dur:getDurationInSeconds
      keynum:fun {$ X} {X getPitchInMidi($)} end
      amplitude:getAmplitudeInNormalized)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Out.ozToLisp
%%

%% tests
{Out.ozToLisp ~1.5e~10 unit}
% -> "-1.5e-10" [transformed to string..]

{Out.ozToLisp hi unit}
% -> "hi"
{Out.ozToLisp 'Hi there' unit}
% -> "|Hi there|"

{Out.ozToLisp [test unit(a:1)] unit}
% -> "(test (:a 1 :record-label unit))"

{Out.ozToLisp [a nil b] unit}
% -> "(a nil b)"

{Out.ozToLisp true(x y a:1 b:2) unit}
% -> "(x y :a 1 :b 2 :record-label T)"
%% NB: truth value as label can cause problems: avoid..
   
{Out.ozToLisp "some Test" unit(stringTransform:true)}
% -> "\"some Test\""
{Out.ozToLisp "some Test" unit(stringTransform:false)}
% -> "(115 111 109 101 32 84 101 115 116)"

%% VS are passed unaltered
{Out.ozToLisp "("#'some Test'#")" unit}

{IsVirtualString "("#'some Test'#")"}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% SDL note -> clm::p note
%%

declare 
[S Out] = {ModuleLink ['x-ozlib://anders/music/sdl/ScoreCore.ozf'
			'x-ozlib://anders/music/sdl/Output.ozf']}
MyNote = {New S.note init(startTime:1.5 duration:3 pitch:60.5 amplitude:0.7)}
{MyNote closeScoreHierarchy}

{Browse {Out.note2ClmP MyNote}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% test output note seq
%%

declare 
[SDL S Out] = {ModuleLink ['x-ozlib://anders/music/sdl/SDL.ozf'
			    'x-ozlib://anders/music/sdl/ScoreCore.ozf'
			    'x-ozlib://anders/music/sdl/Output.ozf']}
MyScore ={SDL.fillContainer 3 
	  spec(initItem:init(offsetTime:0
			     duration:3
			     pitch:[60 60.7 67]
			     amplitude:0.7))}
{SDL.initScore MyScore unit(mode:tree)}


{MyScore toPPrintRecord($)}

{Out.makeEventlist MyScore Out.note2ClmP Out.makeClmScore}

{Out.outputEventlist MyScore Out.note2ClmP Out.makeClmScore
 '/home/t/tmp/out-test.clm'}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% SDL note -> Csound note
%%

% declare 
% [GUtils Score Out] =
% {ModuleLink ['x-ozlib://anders/music/sdl/GeneralUtils.ozf'
% 	      'x-ozlib://anders/music/sdl/ScoreCore.ozf'
% 	      'x-ozlib://anders/music/sdl/Output.ozf']}

% declare
% MyNote = {Score.makeScore note(startTime:0 duration:3 offsetTime:0
% 			       pitch:60 amplitude:64)
% 	  unit}
% fun {ToCsoundNote N}
%    {Out.list2VS [i1 {N getStartTime($)} {N getDuration($)} {N getAmplitude($)} {N getPitch($)}]} 
% end
% %% Spec is a list of accessor functions/methods. However, every accessor function/method can be given a transformation function/method for the accessed data as Accessor#Transformator.
% fun {MakeNote2CsoundFn Instrument Spec}
%    fun {$ N}
%       {Out.list2VS
%        {Append
% 	[i#Instrument]
% 	{Map Spec
% 	 fun {$ X}
% 	    case X of Accessor#Transformator
% 	    then {Transformator {{GUtils.toFun Accessor} N}}
% 	    else {{GUtils.toFun X} N}
% 	    end
% 	 end}}}
%    end
% end
% ToI1 = {MakeNote2CsoundFn 1 [getStartTime getDuration getAmplitude getPitch]}
% ToI1b = {MakeNote2CsoundFn 1
% 	 [getStartTime getDuration
% 	  getAmplitude#IntToFloat getPitch#IntToFloat]}
% fun {MakeCsoundScoreFn Header}
%    fun {$ Ignore EventVSs}
%       Header#'\n\n'#
%       {Out.list2Lines EventVSs}#'\n'
%    end
% end


% {VirtualString.toString {ToCsoundNote MyNote}}

% {VirtualString.toString {ToI1 MyNote}}

% {VirtualString.toString {ToI1b MyNote}}

% {VirtualString.toString
%  {Out.makeEventlist
%   {Score.makeScore seq(items:[note(duration:1 offsetTime:0
% 				   pitch:60 amplitude:64)
% 			      note(duration:1 offsetTime:0
% 				   pitch:60 amplitude:64)
% 			      note(duration:1 offsetTime:0
% 				   pitch:60 amplitude:64)]
% 		       startTime:0 offsetTime:0)
%    unit}
%   ToI1 {MakeCsoundScoreFn 'f test'}}}


% {Out.outputEventlist
%  {Score.makeScore seq(items:[note(duration:1 offsetTime:0
% 				  pitch:60 amplitude:70)
% 			     note(duration:1 offsetTime:0
% 				  pitch:64 amplitude:80)
% 			     note(duration:1 offsetTime:0
% 				  pitch:67 amplitude:90)]
% 		      startTime:0 offsetTime:0)
%   unit}
%  ToI1 {MakeCsoundScoreFn ''}
%  "/Users/t/tmp/test.sco"}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% SDL note -> Csound note
%%

declare 
[Score Out] =
{ModuleLink ['x-ozlib://anders/music/sdl/ScoreCore.ozf'
	      'x-ozlib://anders/music/sdl/Output.ozf']}

declare
MyScore = {Score.makeScore seq(items:[note(duration:1000 offsetTime:0
					   pitch:60 amplitude:70)
				      note(duration:1000 offsetTime:0
					   pitch:62 amplitude:{FD.decl})
				      note(duration:1000 offsetTime:0
					   pitch:64 amplitude:80)]
			       startTime:0 offsetTime:0)
	   unit}
Note2I1 = {Out.makeEvent2CsoundFn 1
	   [getStartTimeParameter getDurationParameter getAmplitudeParameter
	    getPitchParameter#fun {$ Param} {IntToFloat {Param getValue($)}} end]}

%% Create a csound score of Score, but only include fully determined events
{Out.writeToFile
 {Out.makeCsoundScore
  {Map {MyScore collect($ test:fun {$ X}
				  {X isEvent($)} andthen {X isDet($)}
			       end)}
   Note2I1}
  nil}
 "/Users/t/tmp/my-test.sco"}

{Out.outputCsoundScore MyScore unit(sco:'my-test-7.sco')}

{Out.renderAndPlayCsound MyScore unit(sco:'test4.'#'sco' sound:'test4.'#'aiff')}

% local
%    Defaults = unit(detIns:i1
% 		   accessors:[getStartTime getDuration
% 			      getAmplitude getPitch])
% in
%    /** % Output Csound score VS of Score. Not all events of Score must be fully determined 
%    %% */
%    fun {PartialDetScore2Csound Score Spec}
%    end
% end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Shell
%%

%%
%% using the default: sh
%%

declare
MyShell = {New Out.shell init}

{MyShell cmd("ls -l /Users/")}

%% either output lines one by one 
{Inspect {MyShell outputLine($)}}

%% or show all output at stdout
{MyShell showAll}

{MyShell close}


%%
%% running an interpreter: irb, the Interactive Ruby Shell
%% watch the output at stdout
%%

declare
MyShell = {New Out.shell init(cmd:irb args:nil)}
{MyShell showAll}

{MyShell cmd("1 + 2")}

{MyShell cmd("def fact(n)
  if n <= 1
     1
  else
     n * fact(n - 1)
  end
end")}

{MyShell cmd("n=5
")}

{MyShell cmd("fact(n)")}


%%
%% running an interpreter: sbcl, Steel Bank Common Lisp
%%

declare
MyShell = {New Out.shell init(cmd:sbcl args:nil)}
{MyShell showAll}

{MyShell cmd("(+ 1 3)")}

%% force an error: gets me into the debugger ;-)
{MyShell cmd("(/ 1 0)")}


{MyShell cmd("(quit)")}

{MyShell close}


%% variant: suppress printing of banner etc., so the output could be used by some Oz program more easily..
%% NB: the promt is still printed, but it will be easy to get rid of that!
%% there is also the --noprint option: don't print a prompt and don't echo results
declare
MyShell = {New Out.shell init(cmd:sbcl args:["--noinform" "--disable-debugger"])}
{MyShell showAll}

{MyShell cmd("(+ 1 3)")}

%% causes now error message with backtrace and quit
{MyShell cmd("(/ 1 0)")}

{MyShell cmd("(quit)")

{MyShell close}


%%
%% running Python 
%%

declare
MyShell = {New Out.shell init(cmd:python args:["-i"])}
{MyShell showAll}

{MyShell cmd("1 + 2")}

{MyShell close}



%%
%% looking at the environment
%@

declare
MyShell = {New Out.shell init}
{MyShell showAll}

%% TERM is not actual terminal (e.g. xterm), but dumb -- can that cause problems
%% answer: I don't need a terminal -- A UNIX pipe doen't either..
%% http://lists.gforge.info.ucl.ac.be/pipermail/mozart-users/2003/003289.html
{MyShell cmd("env")}

/* % -> 
% MANPATH=/sw/share/man:/usr/share/man:/usr/local/share/man:/Library/TeX/Distributions/.DefaultTeX/Contents/Man:/usr/X11R6/man:/sw/lib/perl5/5.8.6/man
% TERM=dumb
% SHELL=/bin/bash
% PERL5LIB=/sw/lib/perl5:/sw/lib/perl5/darwin
% EMACSDATA=/Applications/Aquamacs Emacs.app/Contents/Resources/etc
% COPY_EXTENDED_ATTRIBUTES_DISABLE=true
% TK_LIBRARY=/usr/local/oz/platform/i486-darwin/wish/tk
% EMACSPATH=/Applications/Aquamacs Emacs.app/Contents/MacOS/libexec:/Applications/Aquamacs Emacs.app/Contents/MacOS/bin
% EMACS=t
% USER=t
% LD_LIBRARY_PATH=/Users/t/.oz/1.3.99/platform/i486-darwin/lib:/usr/local/oz//platform/i486-darwin/lib
% OZ_PI=1
% TCL_LIBRARY=/usr/local/oz/platform/i486-darwin/wish/tcl
% TERMCAP=
% __CF_USER_TEXT_ENCODING=0x1F5:0:2
% COLUMNS=91
% PATH=/usr/local/oz//bin:/usr/local/oz//bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/texlive/2007/bin/i386-darwin/:/usr/local/oz/bin/:/Users/t/.oz/1.3.99/bin/:/usr/local/bin:/opt/local/bin:/opt/local/sbin:/sw/bin:/sw/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/texbin:/usr/X11R6/bin:/usr/local/texlive/2007/bin/i386-darwin/:/usr/local/oz/bin/:/Users/t/.oz/1.3.99/bin/:/usr/local/bin:/opt/local/bin:/opt/local/sbin:/sw/bin:/sw/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/texbin:/usr/X11R6/bin:/usr/local/teTeX/bin/powerpc-apple-darwin-current
% PWD=/Users/t/oz/music/Strasheela/strasheela/testing
% EDITOR=emacs
% SFDIR=/Users/t/Sound/tmp
% EMACSLOADPATH=/Applications/Aquamacs Emacs.app/Contents/Resources/lisp:/Applications/Aquamacs Emacs.app/Contents/Resources/leim:/Applications/Aquamacs Emacs.app/Contents/Resources/site-lisp
% SHLVL=3
% HOME=/Users/t
% DYLD_LIBRARY_PATH=/Users/t/.oz/1.3.99/platform/i486-darwin/lib:/usr/local/oz//platform/i486-darwin/lib
% OZPATH=.:/usr/local/oz//share
% INFOPATH=/sw/share/info:/sw/info:/usr/share/info:~/Library/Application Support/Emacs/info:/Library/Application Support/Emacs/info:/Applications/Aquamacs Emacs.app/Contents/Resources/site-lisp/edit-modes/info:/Applications/Aquamacs Emacs.app/Contents/Resources/info:~/Library/Application Support/Emacs/info:/Library/Application Support/Emacs/info:/Applications/Aquamacs Emacs.app/Contents/Resources/site-lisp/edit-modes/info:/Applications/Aquamacs Emacs.app/Contents/Resources/info
% DISPLAY=:0.0
% OZHOME=/usr/local/oz/
% INSIDE_EMACS=22.1.1,comint
% EMACSDOC=/Applications/Aquamacs Emacs.app/Contents/Resources/etc
% SECURITYSESSIONID=405610
% _=/usr/bin/env
*/

% asking for env: returns no
{MyShell cmd("if test -t 0; then echo yes; else echo no; fi")}
{MyShell cmd("if test -t 1; then echo yes; else echo no; fi")}
{MyShell cmd("if test -t 2; then echo yes; else echo no; fi")}

{MyShell close}


%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% How does python know it is not running in an interactive terminal?
%% Can I trick python into believing it is by setting the TERM environment variable??
%%
%% -> doesn't work..
%%

%% I can not change environment variable TERM in Oz: after all, I don't want to change it globally.. 
{OS.putEnv 'TERM' xterm}

{OS.getEnv 'TERM'}

%% but this does not change behaviour of python
declare
MyShell = {New Out.shell init(cmd:python args:nil)}
{MyShell showAll}

{MyShell cmd("1 + 2")}

{MyShell close}
	       
	       
%%%%%%%%%%%%%%%%%

%% Test some OS and System related stuff

declare
Status 

%% starts the Calculator on MacOS 
{OS.system '/Applications/Calculator.app/Contents/MacOS/Calculator'
 Status}

declare
Status Pid

%% starts the Calculator on MacOS 
{OS.pipe '/Applications/Calculator.app/Contents/MacOS/Calculator'
 nil Pid Status} 

%% Close App with Pid
{OS.kill Pid 'SIGTERM' _}

declare Path
%% create full temp path name
{OS.tmpnam Path}

%% ls
{OS.getDir '/Users/t/'}


{OS.getEnv 'OZHOME'}

{OS.getEnv 'PATH'}


declare
Proc = {New Open.pipe init(cmd:'ls' args:['-l'])}
{Browse {Proc read(list:$ size:all)}}

declare
Proc = {New Open.pipe init(cmd:'ls'
			   args:['-la' '/Users/t/'])}
{System.showInfo {Proc read(list:$ size:all)}}


declare
Proc = {New Open.pipe init(cmd:'/usr/local/bin/csound'
			   args:['-A' '-o'#'/Users/t/tmp/'#'test.aiff'
				 '/Users/t/csound/SDL-demo/'#'pluck.orc'
				 '/Users/t/tmp/'#'test.sco'])}
{System.showInfo {Proc read(list:$ size:all)}}



%%%%%%%%%%%%%%%%%

% declare 
% [GUtils Score Out] =
% {ModuleLink ['x-ozlib://anders/music/sdl/GeneralUtils.ozf'
% 	      'x-ozlib://anders/music/sdl/ScoreCore.ozf'
% 	      'x-ozlib://anders/music/sdl/Output.ozf']}

% declare
% local
%    Defaults = unit(orc:'pluck.orc'
% 		      sco:'test.sco'
% 		      out:'test.aiff'
% 		      orcDir:'/Users/t/csound/SDL-demo/'
% 		      scoDir:'/Users/t/tmp/'
% 		      outDir:'/Users/t/tmp/'
% 		      flags:'-A')
%    %% into GUtils
%    fun {SelectArg Feature Spec Defaults} 
%       if {HasFeature Spec Feature}
%       then Spec.Feature
%       else Defaults.Feature
%       end
%    end
% in
%    %% call Csound with args and write output on standard output
%    proc {CallCsound Spec}
%       OrcPath = {SelectArg orcDir Spec Defaults}#{SelectArg orc Spec Defaults}
%       ScoPath = {SelectArg scoDir Spec Defaults}#{SelectArg sco Spec Defaults}
%       OutPath = {SelectArg outDir Spec Defaults}#{SelectArg out Spec Defaults}
%       Flags = {SelectArg flags Spec Defaults}
%       %% !! Open.pipe is very picky with input format: no additional
%       %% whitespace and separate flags either as separate atoms or
%       %% without any hyphen between them -- try later to generalise Flags arg
%       %%
%       %% !! temp: absolute path for csound ($PATH of shell forked by
%       %% Oz  not bound be .profile on Mac)
%       SynthProc = {New Open.pipe init(cmd:'/usr/local/bin/csound'
% 				 args:[Flags '-o'#OutPath OrcPath ScoPath])}
%       PlayProc
%    in
%       {System.showInfo
%        {Out.list2VS
% 	['>' '/usr/local/bin/csound' Flags '-o'#OutPath OrcPath ScoPath]}}
%       {System.showInfo
%        {SynthProc read(list:$   
% 		  size:all)}}
%       %{SynthProc flush}		% wait until csound is finished
%       {SynthProc close}
%       {System.showInfo 'csound finished'}
%       %% !! temp: absolute path
%       PlayProc = {New Open.pipe init(cmd:'/usr/local/bin/sndplay'
% 				     args:[OutPath])}
%       %{System.showInfo {PlayProc read(list:$ size:all)}}
%       %{PlayProc close}  % stops playback
%    end
% end

% {CallCsound unit(out:'my-test2.aiff')}

% {OS.system '/usr/local/bin/sndplay /Users/t/tmp/test2.aiff' _}

% {OS.pipe '/usr/local/bin/sndplay'
%  ['/Users/t/tmp/my-test2.aiff'] _ _}

% declare
% Proc = {New Open.pipe init(cmd:'/usr/local/bin/sndplay'
% 			   args:['/Users/t/tmp/my-test2.aiff'])}

% {Proc flush}
% {Proc close}

% {System.showInfo {Proc read(list:$ size:all)}}

% {Proc close}

% %% window..
% %%
% declare
% Sound = {Cell.new _}
% proc {Start}
%     if {Value.isFree {Cell.access Sound}}
%     then {Cell.access Sound} =
%        {New Open.pipe
% 	init(cmd:'/usr/local/bin/sndplay'
% 	     args:['/Users/t/tmp/'#'my-test2.aiff'])}
%     end
% end
% proc {Stop}
%    if {Value.isDet {Cell.access Sound}}
%    then {{Cell.access Sound} close}
%    end
%    {{Cell.assign Sound} _}
% end
% W={New Tk.toplevel tkInit(title:'Play Sound')}
% %E={New Tk.entry    tkInit(parent:W)}
% B1={New Tk.button
%    tkInit(parent: W
% 	  text:   'Play' 
% 	  action: Start)}
% B2={New Tk.button
%    tkInit(parent: W
% 	  text:   'Stop' 
% 	  action: Stop)}
% B3={New Tk.button
%    tkInit(parent: W
% 	  text:   'Quit' 
% 	  action: proc {$}
% 		     thread {Stop} end
% 		     {W tkClose}
% 		  end)}
% {Tk.send pack(B1 B2 B3 fill:x padx:4 pady:4)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% test csound rendering and sound output

declare 
[Out] =
{ModuleLink ['x-ozlib://anders/music/sdl/Output.ozf']}


{Out.callCsound unit(out:'mytest.aiff')}

{Out.playSound unit(file:'mytest.aiff' title:test)}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% lauch an apple script: 
%%

%% does not work: I either give a filename or use flag -e
declare
Proc = {New Open.pipe init(cmd:'osascript')}

{Proc write(vs:'tell application \"QuickTime Player\"
	activate
	open file \"Macintosh HD:Users:t:tmp:out1.aiff\"
	play movie \"out1.aiff\"
end tell')}
{System.showInfo {Proc read(list:$ size:all)}}

%% !! closing does not work if app didn't start (killing on the shell
%% works)
{Proc close}


%% OK
local
   Script = '/Users/t/tmp/test.scpt'
   Proc
in 
   {Out.writeToFile 'tell application \"QuickTime Player\"
	activate
	open file \"Macintosh HD:Users:t:tmp:out1.aiff\"
	play movie \"out1.aiff\"
end tell'
   Script}
   Proc = {New Open.pipe init(cmd:'osascript'
			   args:[Script])}
   {System.showInfo {Proc read(list:$ size:all)}}
   {Proc close}
end




%% does not work yet, 
declare
Proc = {New Open.pipe
	init(cmd:'osascript'
	     args:['-e \'tell application \"QuickTime Player\"\''
		   '-e \'activate\''
		  % '-e \'open file \"Macintosh HD:Users:t:tmp:out1.aiff\"\''
		  % '-e \'play movie \"out1.aiff\"\''
		  ])}
{System.showInfo {Proc read(list:$ size:all)}}
%% !! closing does not work
{Proc close}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% Lilypond output
%%

/*
{NoteToLily
 {Score.makeScore
  note(duration: 1000 
       offsetTime: 0
       pitch: 60)
  unit}}

{NoteToLily
 {Score.makeScore
  note(duration: 1750 
       offsetTime: 0
       pitch: 60)
  unit}}

{NoteToLily
 {Score.makeScore
  note(duration: 1125 
       offsetTime: 0
       pitch: 60)
  unit}}
*/

{Out.toLilypond
 {Score.makeScore
  note(duration: 1
       offsetTime: 0
       timeUnit:beats(4)
       pitch: 60)
  unit}
 nil}

%% note with dur = 0
{Out.toLilypond
 {Score.makeScore
  note(duration: 0
       offsetTime: 0
       timeUnit:beats(4)
       pitch: 60)
  unit}
 nil}

%% container with note of dur = 0
{Out.toLilypond
 {Score.makeScore
  seq(items:[note(duration: 0
		  offsetTime: 0
		  timeUnit:beats(4)
		  pitch: 60)
	     note(duration: 1
		  offsetTime: 0
		  timeUnit:beats(4)
		  pitch: 60)])
  unit}
 nil}

%% container with all notes of dur = 0
{Out.toLilypond
 {Score.makeScore
  seq(items:[note(duration: 0
		  offsetTime: 0
		  timeUnit:beats(4)
		  pitch: 60)
	     note(duration: 0
		  offsetTime: 0
		  timeUnit:beats(4)
		  pitch: 60)])
  unit}
 nil}


{Out.toLilypond
 {Score.makeScore
  note(duration: 4
       timeUnit:beats(4)
       pitch: 47)
  unit}
 nil}


{Out.toLilypond
 {Score.makeScore
  seq(items:[ note(duration: 4
		   offsetTime: 0
		   pitch: 60)
	      note(duration: 1 
		   offsetTime: 0
		   pitch: 73)]
     timeUnit:beats(4))
  unit}
 nil}

{VirtualString.toString
 {Out.toLilypond
  {Score.makeScore
   sim(items:[ note(duration: 4
		   offsetTime: 0
		    pitch: 60)
	       note(duration: 1 
		    offsetTime: 0
		    pitch: 73)]
     timeUnit:beats(4))
   unit}
 nil}}

{VirtualString.toString
 {Out.toLilypond
  {Score.makeScore
   sim(items:[ seq(items:[ note(duration: 4
		 	      offsetTime: 0
			       pitch: 60)
			  note(duration: 1 
			       offsetTime: 0
			       pitch: 73)])
	       seq(items:[ note(duration: 4 
		 	      offsetTime: 0
			       pitch: 60)
			  note(duration: 1 
			       offsetTime: 0
			       pitch: 73)])]
     timeUnit:beats(4))
   unit}
  nil}}

{Out.writeToFile
  {Out.toLilypond
   {Score.makeScore
    sim(items:[ seq(items:[ note(duration: 4
				 offsetTime: 0
				 pitch: 60)
			    note(duration: 6
				 offsetTime: 0
				 pitch: 73)
			    note(duration: 2
				 offsetTime: 0
				 pitch: 70)])
		seq(items:[ note(duration: 10 
				 offsetTime: 0
				 pitch: 63)
			    note(duration: 2 
				 offsetTime: 0
				 pitch: 63)])]
            timeUnit:beats(4))
    unit}
   nil}
 "/home/to/tmp/test.ly"}

%%%%%%%%

% {OS.getCWD}


{Out.renderAndShowLilypond
 {Score.makeScore
  note(duration: 4
       offsetTime: 0
       timeUnit:beats(4)
       pitch: 63)
  unit}
 unit}

%% container note of dur = 0
{Out.renderAndShowLilypond
 {Score.makeScore
  seq(items:[note(duration: 0
		  offsetTime: 0
		  pitch: 60)
	     note(duration: 1
		  offsetTime: 0
		  pitch: 60)]
      timeUnit:beats(4))
  unit}
 unit}

{Out.writeToFile
 {Out.toLilypond
  {Score.makeScore
   note(duration: 2
	offsetTime: 0
	timeUnit:beats(4)
	pitch: 75)
   unit}
  nil}
 "/home/to/tmp/test.ly"}

{Out.outputLilypond
  {Score.makeScore
   note(duration: 2
	offsetTime: 0
	timeUnit:beats(4)
	pitch: 75)
   unit}
 unit(file:myTest)}

{OS.getEnv 'PATH'}
% 


{Out.callLilypond unit(file:myTest)}

{Out.outputLilypond
 {Score.makeScore
  note(duration: 4
       offsetTime: 0
       timeUnit:beats(4)
       pitch: 60)
  unit}
 unit(file:testA)}
{Browse ok}

{Out.outputLilypond
 {Score.makeScore
  sim(items:[ seq(items:[ note(duration: 4
			       offsetTime: 0
			       pitch: 60)
			  note(duration: 6
			       offsetTime: 0
			       pitch: 73)
			  note(duration: 2
			       offsetTime: 0
			       pitch: 70)])
	      seq(items:[ note(duration: 10 
			       offsetTime: 0
			       pitch: 63)
			  note(duration: 2 
			       offsetTime: 0
			       pitch: 63)])]
	timeUnit:beats(4))
  unit}
 unit(file:testA)}
{Browse ok}

{Out.callLilypond unit(file:testA)}

{Out.callGV  unit(file:testA)}

{Out.renderAndShowLilypond
 {Score.makeScore
  sim(items:[ seq(items:[ note(duration: 4
			       offsetTime: 0
			       pitch: 60)
			  note(duration: 6
			       offsetTime: 0
			       pitch: 73)
			  note(duration: 2
			       offsetTime: 0
			       pitch: 70)])
	      seq(items:[ note(duration: 10 
			       offsetTime: 0
			       pitch: 63)
			  note(duration: 2 
			       offsetTime: 0
			       pitch: 63)])]
	timeUnit:beats(4))
  unit}
 unit}


%%%%%%%%%%%%%%%%%%%%%%

%% check offsets

{Out.toLilypond
 {Score.makeScore
  sim(items:[ note(duration: 4
		   offsetTime: 2500
		   pitch: 60)
	      note(duration: 12 
		   offsetTime: 0
		   pitch: 63) ]
      offsetTime:0
      timeUnit:beats(4))
  unit}
 nil}


{Out.renderAndShowLilypond
 {Score.makeScore
  sim(items:[ note(duration: 4
		   offsetTime: 2500
		   pitch: 60)
	      note(duration: 12
		   offsetTime: 0
		   pitch: 63) ]
      offsetTime:0
      timeUnit:beats(4))
  unit}
 unit}

{Out.renderAndShowLilypond
 {Score.makeScore
  sim(items:[ seq(items:[ note(duration: 8
			       offsetTime: 0
			       pitch: 48)
			  note(duration: 8 
			       offsetTime: 0
			       pitch: 50)
			  note(duration: 8 
			       offsetTime: 8
			       pitch: 52) ]
		  offsetTime:2000)
	      seq(items:[ note(duration: 8 
			       offsetTime: 2
			       pitch: 67)
			  note(duration: 8 
			       offsetTime: 4
			       pitch: 65)
			  note(duration: 8 
			       offsetTime: 0
			       pitch: 63) ]
		  offsetTime:0)]
     offsetTime:0
      timeUnit:beats(4))
  unit}
 unit}

declare
MyScore = {Score.makeScore
	   sim(items:[ seq(items:[ note(duration: 1000 
					offsetTime: 0
					pitch: 60) ]
			   offsetTime:2000)
		       seq(items:[ note(duration: 3000 
					offsetTime: 0
					pitch: 63) ])]
	       timeUnit:milliseconds)
	   unit}

{Out.renderAndShowLilypond MyScore unit}

{MyScore collect($ test:isSequential)}

{MyScore toPPrintRecord($)}


%%%%%%%%%%%%%%%%%%%%%%

%% Check outmost sims within seqs: OK (new!) implicit staff creation.
%% However, I probably don't want this behaviour -- just always put a
%% Sim around your score?
{Out.writeToFile
 %{VirtualString.toString
 {Out.toLilypond
  {Score.makeScore
   seq(items:[sim(items:[ seq(items:[ note(duration: 1000 
					   offsetTime: 0
					   pitch: 60)
				      note(duration: 2000
					   offsetTime: 0
					   pitch: 73)])
			  seq(items:[ note(duration: 2000 
					   offsetTime: 0
					   pitch: 63)
				      note(duration: 1000 
					   offsetTime: 0
					   pitch: 67)])])
	      seq(items:[ note(duration: 4000 
			       offsetTime: 0
			       pitch: 48)
			  note(duration: 2000
			       offsetTime: 0
			       pitch: 50)])]
       timeUnit:milliseconds)
   unit}
  nil}
 "/home/t/tmp/test2.ly"}

{Out.writeToFile
 {VirtualString.toString
 {Out.toLilypond
  {Score.makeScore
   seq(items:[sim(items:[ seq(items:[ note(duration: 1000 
					   offsetTime: 0
					   pitch: 60)
				      note(duration: 2000
					   offsetTime: 0
					   pitch: 73)])
			  seq(items:[ note(duration: 2000 
					   offsetTime: 0
					   pitch: 63)
				      note(duration: 1000 
					   offsetTime: 0
					   pitch: 67)])])
	      sim(items:[ seq(items:[ note(duration: 1000 
					   offsetTime: 0
					   pitch: 60)
				      note(duration: 2000
					   offsetTime: 0
					   pitch: 73)])
			  seq(items:[ note(duration: 2000 
					   offsetTime: 0
					   pitch: 63)
				      note(duration: 1000 
					   offsetTime: 0
					   pitch: 67)])])]
       timeUnit:milliseconds)
   unit}
  nil}}
 "/home/t/tmp/test2.ly"}



{{Score.makeScore
    sim(items:[ seq(items:[ note(duration: 1000 
				 offsetTime: 0
				 pitch: 60)
			    note(duration: 1500
				 offsetTime: 0
				 pitch: 73)
			    note(duration: 500
				 offsetTime: 0
				 pitch: 72)])
		seq(items:[ note(duration: 2500 
				 offsetTime: 0
				 pitch: 63)
			    note(duration: 500 
				 offsetTime: 0
				 pitch: 63)])]
	timeUnit:milliseconds)
  unit}
 toPPrintRecord($)}


%% 
%% microtonal output
%%


{Out.renderAndShowLilypond
 {Score.makeScore
  seq(items:[note(duration: 4
		  pitch:60*6+2
		  pitchUnit:et72)
	     sim(items:[note(duration: 4
			     pitch:60*6+2
			     pitchUnit:et72)
			note(duration: 4
			     pitch:64*6+1
			     pitchUnit:et72)
			note(duration: 4
			     pitch:67*6+2
			     pitchUnit:et72)])]
      timeUnit:beats(4))
  unit}
 unit}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Hierarchical output

declare
MyScore = {Score.makeScore
	    sim(items:[ seq(items:[ note(duration: 2
					 offsetTime: 0
					 pitch: 60)
				    note(duration: 3
					 offsetTime: 0
					 pitch: 73)
				    note(duration: 1
					 offsetTime: 0
					 pitch: 72)]
			    offsetTime: 0)
			seq(items:[ note(duration: 5 
					 offsetTime: 0
					 pitch: 63)
				    note(duration: 1 
					 offsetTime: 0
					 pitch: 63)]
			    offsetTime: 0)]
		startTime:0
		timeUnit:milliseconds)
	   unit}


{Out.makeHierarchicVSScore MyScore
 fun {$ X} event({X getPitch($)} {X getAmplitude($)}) end
 fun {$ X} [sim ' ' e] end
 fun {$ X} [seq ' ' e] end}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SC output

declare
TestSCEventOut = {Out.makeSCEventOutFn
		  fun {$ X}
		     Pitch
		  in
		     if {IsDet {X getPitchUnit($)}}
		     then Pitch = {X getPitchInMidi($)}
		     else Pitch = {X getPitch($)}
		     end
		     'Patch(\\saw, ['#Pitch
		     #', '#{X getAmplitude($)}#'])'
		  end}

declare
MyScore = {Score.makeScore
	   note(startTime:0
		%timeUnit:beats
		duration: 5 
		offsetTime: 0
		pitch: 63
		timeUnit:milliseconds
		%pitchUnit:midi
		%amplitude:1
	       )
	   unit}

%{MyScore getDurationInBeats($)}
%{MyScore isDet($)}
%{IsDet {MyScore getTimeUnit($)}}

{TestSCEventOut MyScore}

{Out.makeSCScore MyScore TestSCEventOut}


%%%

declare
TestSCEventOut = {Out.makeSCEventOutFn
		  fun {$ X}
		     Pitch
		  in
		     if {IsDet {X getPitchUnit($)}}
		     then Pitch = {X getPitchInMidi($)}
		     else Pitch = {X getPitch($)}
		     end
		     %% !! third and forth vibraphone param fixed here  
		     '~vibraphone.makePlayer(['#Pitch
		     #', '#{X getAmplitude($)}#',7, 1])'
		  end}
MyScore = {Score.makeScore
	    sim(items:[ seq(items:[ note(duration: 2
					 offsetTime: 0
					 pitch: 60)
				    note(duration: 3
					 offsetTime: 0
					 pitch: 73)
				    note(duration: 1
					 offsetTime: 0
					 pitch: 72)]
			    offsetTime: 0)
			seq(items:[ note(duration: 5 
					 offsetTime: 0
					 pitch: 63)
				    note(duration: 1 
					 offsetTime: 0
					 pitch: 63)]
			    offsetTime: 0)]
		startTime:0
		offsetTime:0)
	   unit}
{MyScore forAll(proc {$ X} {X getAmplitude($)}=5 end test:isNote)}
{MyScore getTimeUnit($)} = beats(5)
{MyScore setAllParameterUnits(getPitchParameter midi test:isNote)}

/*
% {MyScore getUnit($)}
{MyScore map($ getUnit test:isItem)}
{MyScore map($ getTimeUnit test:isItem)}
{MyScore map($ getStartTimeInBeats test:isItem)}
*/

{Out.makeSCScore MyScore TestSCEventOut}

{Out.outputSCScore MyScore TestSCEventOut unit(file:'SCScore-test2')}


%%%%%%%%%%%%%%%%%%%%%%%

{Out.sendSClang 'open,/Users/t/tmp/SCScore-test'}

{Out.sendSClang 'bind,x,1+2'}

{Out.sendSClang 'bindPath,x,/Users/t/tmp/SCScore-test'}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% PWGL output
%%

%% topology:
%% score(part(voice(chord(note ..))))
declare
MyScore = {Score.makeScore
	   sim(items:[sim(items:[seq(items:[sim(items:[note(duration: 2
							    pitch: 60
							    amplitude:64)
						       note(duration: 2
							    pitch: 64
							    amplitude:64)])
					    sim(items:[note(duration: 2
							    pitch: 67
							    amplitude:64)])
					    sim(items:[note(duration: 2
							    pitch: 62
							    amplitude:64)
						       note(duration: 2
							    pitch: 65
							    amplitude:64)])])])]
		startTime:0
		timeUnit:beats(4))
	   unit}

{Out.toNonmensuralENP MyScore unit}

%% !! ENP score seems to be OK, but PWGL does not yet support importing ENP scores!!
{Out.outputNonmensuralENP MyScore unit}


%% outputting a different score topology by setting accessors accordingly
declare
MyScore = {Score.makeScore
	   sim(items:[ seq(items:[ note(duration: 2
					pitch: 60
					amplitude:64)
				   note(duration: 3
					pitch: 73
					amplitude:64)
				   note(duration: 1
					pitch: 72
					amplitude:64)])
		       seq(items:[ note(duration: 5 
					pitch: 63
					amplitude:64)
				   note(duration: 1 
					pitch: 63
					amplitude:64)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}

%% In case the outer container of X is a sim, then its content is interpreted as ENP parts (each part with a single voice and multiple chords where each chord contains a single note). Otherwise the whole score is output into a single part (with a single voice and multiple chords where each chord contains a single note).
{Out.outputNonmensuralENP MyScore
 unit(getParts:fun {$ X}
		  if {X isSimultaneous($)}
		  then {X getItems($)}
		  else [X]
		  end
	       end
      getVoices:fun {$ X} [X] end
      getChords:fun {$ X} {X collect($ test:isNote)} end
      getNotes:fun {$ X} [X] end)}


%% TODO: Piano layout of arbitrarily nested score: 
%%
%% mark each Strasheela note with an info tag like leftHand and rightHand. The Accessor getParts returns two lists with notes sorted accordingly: [[LeftHandNote*][RightHandNote*]]
%% getVoices:fun {$ X} [X] end
%% getChords: fun {$ X} X end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Fomus output
%%

declare
MyScore = {Score.makeScore
	   sim(items:[ seq(items:[ note(duration: 2
					pitch: 60
					amplitude:64)
				   note(duration: 3
					pitch: 73
					amplitude:64)
				   note(duration: 1
					pitch: 72
					amplitude:64)])
		       seq(items:[ note(duration: 5 
					pitch: 63
					amplitude:64)
				   note(duration: 1 
					pitch: 63
					amplitude:64)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}

{Out.toFomus MyScore unit}

{Out.outputFomus MyScore unit}

{Out.renderFomus MyScore
 unit(file:"fomus-test"
      getScoreKeywords:fun {$ MyScore}
			  unit(output: "((:lilypond :view t))"
			       %% !!?? 'default-beat' has no effect (not yet implemented?)?
			       % 'default-beat': "1/4"
			       %% !!?? no effect either?
			       % global: "(list (make-timesig :off 0 :time '(3 8)) (make-timesig :off 3 :time '(5 8)))"
			       title: "\"My test score\""
			       %% quartertones: "t"
			       instruments: "#.(list (fm:make-instr :treble-bass :clefs '(:treble :bass)))"
			      )
		       end
      getEventKeywords:fun {$ MyEvent}
			  unit(off:{MyEvent getStartTimeInBeats($)}
			       dur:{MyEvent getDurationInBeats($)}
			       note:{MyEvent getPitchInMidi($)}
			       marks: case {GUtils.random 3}
				      of 1 then "(:staccato)"
				      [] 2 then "(:accent)"
				      else "()"
				      end)
		       end
     )}

%%
%% output to MusicXML
%%

declare
MyScore = {Score.makeScore 
	   sim(items:[seq(items:[note(duration:2
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

{Out.renderFomus MyScore
 unit(file:test
      flags:['-x'])}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Common Music output
%%

declare
MyScore = {Score.makeScore
	    sim(items:[ seq(items:[ note(duration: 2
					 pitch: 60
					 amplitude:64)
				    note(duration: 3
					 pitch: 73
					 amplitude:64)
				    note(duration: 1
					 pitch: 72
					 amplitude:64)])
			seq(items:[ note(duration: 5 
					 pitch: 63
					 amplitude:64)
				    note(duration: 1 
					 pitch: 63
					 amplitude:64)])]
		startTime:0
		timeUnit:seconds)
	   unit}


{MyScore toInitRecord($)}

{Out.makeCMScore MyScore unit}

{Out.outputCMScore MyScore unit(file:myTest2)}


%%
%% microtonal output
%%

declare
MyScore = {Score.makeScore
	    seq(items:[ note(duration: 2
			     pitch: 60*6
			     pitchUnit:et72
			     amplitude:64)
			note(duration: 3
			     pitch: 60*6+2
			     pitchUnit:et72
			     amplitude:64)
			note(duration: 1
			     pitch: 60*6+3
			     pitchUnit:et72
			     amplitude:64)]
		startTime:0
		timeUnit:seconds)
	   unit}

%% output to CM works nicely, but pitchbend is not heard in output from CM

{Out.makeCMScore MyScore unit}

{Out.outputCMScore MyScore unit(file:myMicrotonalTest)}

%% for microtonal output, the CM user sets a devision per semitone and CM than routes the midi notes to different detuned channels accordingly. Advantage: no pitchbend information per note needed (i.e. easy editing in sequencer). Disadvantages: uses up MIDI channels (e.g. no orchestra arrangement that way..)

%% alternatively, I can output appropriate pitch bend information 'by hand' (midi playback yet untested)

/* %% CM def

(defun step->bend (value &optional (width 2))
  ;; convert a value between +-width to a pitch
  ;; bend value ranging from -8192 to 8191
  (inexact->exact
   (floor (rescale value (- width) width -8192 8191))))

*/

declare
fun {EventOut MyNote}
   {Out.makeCMEvent MyNote
    'midi-pitch-bend'(time:getStartTimeInSeconds
		      bend:fun {$ X}  
			      Pitch = {X getPitchInMidi($)}
			      %% get only fractional part
			      MicroPitch = {Ceil Pitch} - Pitch
			   in
			      '(step->bend '#MicroPitch#')'
			   end)}#'\n'
   #{Out.makeCMEvent MyNote
     midi(time:getStartTimeInSeconds
	  duration:getDurationInSeconds
	  keynum:getPitchInMidi
	  amplitude:getAmplitudeInNormalized)}
end
MyScore = {Score.makeScore
	    seq(items:[ note(duration: 2
			     pitch: 60*6
			     pitchUnit:et72
			     amplitude:64)
			note(duration: 3
			     pitch: 60*6+2
			     pitchUnit:et72
			     amplitude:64)
			note(duration: 1
			     pitch: 60*6+3
			     pitchUnit:et72
			     amplitude:64)]
		startTime:0
		timeUnit:seconds)
	   unit}



{Out.outputCMScore MyScore unit(file:myMicrotonalTest3
				eventOut:EventOut)}


%%
%% output to SuperCollider
%%

/*
;; SC def (all args lower cases)

(
 SynthDef("simple",
	  {arg dur=1.0,freq=440.0,amp=0.2,pan=0.0;
	   var osc;
	   osc = EnvGen.kr(Env.triangle(dur,amp), doneAction: 2) * SinOsc.ar(freq);
	   Out.ar(0,Pan2.ar(osc,pan));
	  }).writeDefFile.load(s);
)

;; CM def 

(defobject simple (scsynth)
 ((keynum :initform 60)
  (dur :initform 1)
  (amp :initform .2)
  (pan :initform 0))
 (:parameters keynum dur amp pan))

;; plain CM example

(events (new simple :time 0 :keynum 300.0 :dur 2)
 (io "/Users/t/Sound/tmp/SC-test.osc"
  :play true))

(dumposc "/Users/t/Sound/tmp/SC-test.osc")

*/

declare
MyScore = {Score.makeScore
	    sim(items:[ seq(items:[ note(duration: 2
					 pitch: 60
					 amplitude:64)
				    note(duration: 3
					 pitch: 73
					 amplitude:64)
				    note(duration: 1
					 pitch: 72
					 amplitude:64)])
			seq(items:[ note(duration: 5 
					 pitch: 63
					 amplitude:64)
				    note(duration: 1 
					 pitch: 63
					 amplitude:64)])]
		startTime:0
		timeUnit:seconds)
	   unit}
fun {EventOut MyNote}
   {Out.makeCMEvent MyNote
	  simple(time:getStartTimeInSeconds
		 dur:getDurationInSeconds
		 keynum:getPitchInMidi
		 amp:getAmplitudeInNormalized)}
%    if {MyNote isNote($)}
%    then
%       '(new simple time '#{MyNote getStartTimeInSeconds($)}
%       #' dur '#{MyNote getDurationInSeconds($)}
%       #' keynum '#{MyNote getPitchInMidi($)}
%       #' amp '#{MyNote getAmplitudeInNormalized($)}
%       #')'
%    else raise wrongArg(function:EventOut arg:MyNote) end
%    end
end

{Out.outputCMScore MyScore unit(eventOut:EventOut  
				file:scTest
				%dir:{Init.getStrasheelaEnv defaultCommonMusicDir}
				ioExtension:'.osc' 
			       )}r



%%
%% output to CM transformation which transformes score container wise by envelopes (or CM pattern ?):  (e.g. to edit tempo with env, add further params with CM pattern etc) 
%%

/*
%% intended result:


(new seq subobjects
 (let ((pattern <make-pattern>))
  (my-map #'(lambda (n i x) <body using pattern>)
(list
 (new simple time 0.0 dur 2.0 keynum 60.0 amp 0.503937)
 (new simple time 2.0 dur 3.0 keynum 73.0 amp 0.503937)
 (new simple time 5.0 dur 1.0 keynum 72.0 amp 0.503937)
)))


%% unfinished
(new seq subobjects 
 (list
  (new simple time 0.0 dur 2.0 keynum 60.0 amp 0.503937)
  (new simple time 2.0 dur 3.0 keynum 73.0 amp 0.503937)
  (new simple time 5.0 dur 1.0 keynum 72.0 amp 0.503937)
 ))

*/

%%
%% output to plotter .. on CM side just add a line in Strasheela *.cm output (no GTK on my iBook)
%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


declare
MyScore = {Score.makeScore
	   seq(items:[note(duration:2 pitch:60 amplitude:64)
		      note(duration:2 pitch:62 amplitude:64)
		      note(duration:2 pitch:64 amplitude:64)]
	       startTime:0
	       timeUnit:beats)
	   unit}

{MyScore toInitRecord($)}

{Out.scoreToEvents MyScore [isNote#fun {$ MyNote}
				      [{Out.listToVS
					[i1
					 {MyNote getStartTimeInSeconds($)}
					 {MyNote getDurationInSeconds($)}
					 {MyNote getPitchInMidi($)}
					 {MyNote getAmplitudeInVelocity($)}]
					' '}]
				   end]
 unit}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




