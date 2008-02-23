
declare
[SPrototyper]={ModuleLink ['x-ozlib://anders/strasheela/Tutorial/source/StrasheelaPrototyper.ozf']}

{SPrototyper.startPrototyper}

%% NB: first recompile Strasheela! 
{SPrototyper.outputMuse Init.strasheelaSourceDir#"/doc-source/"}

%%
%% the following calls work only when the respective procs are exported..
%%


{Browse {SPrototyper.myParser parseFile({SPrototyper.myChapters.1 toString($)} $)}}

{Browse {SPrototyper.tutToMuse {SPrototyper.myChapters.1 toString($)}}}

{IsVirtualString {SPrototyper.tutToMuse {SPrototyper.myChapters.1 toString($)}}}


declare
MyTut = {SPrototyper.myParser parseFile({SPrototyper.myChapters.1 toString($)} $)}
MyChapter = {LUtils.find MyTut
	     fun {$ X} {Label X} == chapter end}
MySection = {SPrototyper.getSections MyTut}.1
MySubsection = MySection.children.1 


{Browse {IsVirtualString {SPrototyper.subsectionToMuse MySubsection}}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% old stuff 
%%


{SPrototyper.readExamples}

{Map {SPrototyper.collectXMLFiles SPrototyper.examplesDir}
 fun {$ X} {X toAtom($)} end}


declare 
ParsedFile = {SPrototyper.myParser parseFile({{SPrototyper.collectXMLFiles SPrototyper.examplesDir}.1 toString($)} $)}


%% evaluate buffer StrasheelaPrototyper to define functor

%% NB: after adding/editing examples files the Prototyper must be restarted.

declare
[QTk
 SPrototyper]={ModuleLink ['x-oz://system/wp/QTk.ozf'
			    'x-ozlib://anders/strasheela/Prototyper/StrasheelaPrototyper.ozf']}

%% !! Bug: code is not shown anymore and nfo neither..

{SPrototyper.run}

{SPrototyper.readExamples}


%% tmp: change font
declare
F1 = {QTk.newFont font(family:'Helvetica' size:14)}
F2 = {QTk.newFont font(family:'Courier' size:14)}


{OS.getDir DIR#"/TheExamples"}

{OS.getDir {OS.getCWD}}
