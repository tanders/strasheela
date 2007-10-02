
%% orig Path 
declare [Path]={Module.link ['x-oz://system/os/Path.ozf']}

%% !! tmp: my changes
declare [Path]={Module.link ['x-ozlib://anders/tmp/Path/Path.ozf']}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Testing filenames which do not necessarily exists
%%

declare
TestCases = unit(
	       absFile:{Path.make '/home/test/tmp.txt'}#'/home/test/tmp.txt'
	       absDir:{Path.make '/home/test/'}#'/home/test/'
	       relFile:{Path.make 'home/test/tmp.txt'}#'home/test/tmp.txt'
	       relDir:{Path.make 'home/test/'}#'home/test/'
	       rootDir:{Path.make '/'}#'/'
	       emptyPath:{Path.make nil}#nil
	       plainFile:{Path.make 'text.txt'}#'text.txt'
	       absFileWin:{New Path.'class' init('D:\\home\\test\\tmp.txt' windows:true)}#'D:\\home\\test\\tmp.txt'
	       relDirWin:{New Path.'class' init('home\\test\\' windows:true)}#'home\\test\\'
	       )

declare
%% same, but always with arg exact: true
TestCases = unit(
	       absFile:{New Path.'class' init('/home/test/tmp.txt' exact:true)}#'/home/test/tmp.txt'
	       absDir:{New Path.'class' init('/home/test/' exact:true)}#'/home/test/'
	       relFile:{New Path.'class' init('home/test/tmp.txt' exact:true)}#'home/test/tmp.txt'
	       relDir:{New Path.'class' init('home/test/' exact:true)}#'home/test/'
	       rootDir:{New Path.'class' init('/' exact:true)}#'/'
	       emptyPath:{New Path.'class' init(nil exact:true)}#nil
	       plainFile:{New Path.'class' init('text.txt' exact:true)}#'text.txt'
	       absFileWin:{New Path.'class' init('D:\\home\\test\\tmp.txt' exact:true windows:true)}#'D:\\home\\test\\tmp.txt'
	       relDirWin:{New Path.'class' init('home\\test\\' exact:true windows:true)}#'home\\test\\'
	       )


%% getInfo is new and only tmp for debugging..
{Record.map TestCases
  fun {$ P#X} {P getInfo($)}#X end}

{Record.map TestCases
 fun {$ P#X} {P toAtom($)}#X end}

{Record.map TestCases
 fun {$ P#X} {P toString($)}#X end}

{Record.map TestCases
 fun {$ P#X} {P isAbsolute($)}#X end}

%% isDir2 is new
{Record.map TestCases
 fun {$ P#X} {P isDir2($)}#X end}

{Record.map TestCases
 fun {$ P#X} {P basenameString($)}#X end}

{Record.map TestCases
 fun {$ P#X} {{P basename($)} toString($)}#X end}

%% dirnameString is new
{Record.map TestCases
 fun {$ P#X} {P dirnameString($)}#X end}


{Record.map TestCases
 fun {$ P#X} {{P dirname($)} isDir2($)}#X end}

{Record.map TestCases
 fun {$ P#X} {{P basename($)} isDir2($)}#X end}

{Record.map TestCases
 fun {$ P#X} {{P resolve('testDir/myFile.txt' $)} toString($)}#X end}

{Record.map TestCases
 fun {$ P#X} {{P resolve('testDir/myFile.txt' $)} getInfo($)}#X end}

{Record.map TestCases
 fun {$ P#X} {P isRoot($)}#X end}

{Record.map TestCases
 fun {$ P#X} {P extension($)}#X end}

{Record.map TestCases
 fun {$ P#X} {{P dropExtension($)} toString($)}#X end}

{Record.map TestCases
 fun {$ P#X} {{P addExtension('test' $)} toString($)}#X end}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Testing existing filenames 
%%

declare
TestCases = unit(
	       cwd:{Path.getcwd}
	       %% expects that OPI is started in this file
	       thisFile:{Path.make {{Path.getcwd} toString($)}#'/Path-test.oz'}
	       )

{Record.map TestCases
 fun {$ P} {P getInfo($)} end}

{Record.map TestCases
 fun {$ P} {P exists($)} end}

{Record.map TestCases
 fun {$ P} {P isDir2($)} end}

{Record.map TestCases
 fun {$ P} {P isDir($)} end}

{Record.map TestCases
 fun {$ P} {P stat($)} end}

{Map {{Path.getcwd} readdir($)}
 fun {$ P} {P toString($)} end}

{Map {{Path.getcwd} readdir($)}
 fun {$ P} {P getInfo($)} end}

{Map {{{Path.getcwd} dirname($)} readdir($)}
 fun {$ P} {P toString($)} end}

{Map {{{Path.getcwd} dirname($)} readdir($)}
 fun {$ P} {P getInfo($)} end}

{Record.map TestCases
 fun {$ P} {{P maybeAddPlatform($)} toString($)} end}



