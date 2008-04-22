
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% toProc
%% 

declare
[GUtils] = {ModuleLink ['x-ozlib://anders/music/sdl/GeneralUtils.ozf']}
[Score] = {ModuleLink ['x-ozlib://anders/music/sdl/ScoreCore.ozf']}

declare
MyScore = {Score.makeScore seq(items:[note note]) unit}
ToPPrintRecord = {GUtils.toProc toPPrintRecord(features:_)}
IsItem = {GUtils.toProc isItem(_)}
IsParameter = {GUtils.toProc isParameter(_)}

{MyScore toPPrintRecord($)}

%% method with single arg: OK
{MyScore collect($ test:IsItem)}

%% method with multiple args:
%% OK
{ToPPrintRecord MyScore unit}	     
%% OK
{ToPPrintRecord MyScore unit(features:[items])}
%% OK
%{ToPPrintRecord {MyScore getItems($)}.1 unit}

%% value '[items]' at 'features' has no effect.. 
{{GUtils.toProc toPPrintRecord(features:[items])} MyScore unit}



%%
%% toFun
%%

declare
MyNote = {Score.makeScore note(pitch:60) unit}

{{GUtils.toFun getPitch} MyNote}

%% test exception
{Browse {{GUtils.toFun 3.14} MyNote}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% random
%% 

declare
[U] = {ModuleLink ['x-ozlib://anders/music/sdl/GeneralUtils.ozf']}

for I in 1..10 do {Browse {GUtils.random 100}} end

for I in 1..10 do {Browse {GUtils.random 3}} end

%%%%%%

{GUtils.arithmeticSeries 1.0 1.0/4.0 4} 

%% ?? this OK
{GUtils.reciprocalArithmeticSeries 1.0 1.0/4.0 4}

{GUtils.reciprocalArithmeticSeries 3.0 1.0/4.0 4}



{Map {GUtils.arithmeticSeries 1.0 1.0/4.0 4}
 fun {$ X}
    1.0/X + (1.0 - 1.0/1.75)
 end} 


{Map {GUtils.arithmeticSeries 1.0 1.0/4.0 4}
 fun {$ X}
    1.0/X * 1.75
 end} 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

{GUtils.cases 2 [IsAtom#fun {$ X} atom end
		 IsNumber#fun {$ X} number end
		 IsClass#fun {$ X} 'class' end]}

{GUtils.cases "test" [IsAtom#fun {$ X} atom end
		      IsNumber#fun {$ X} number end
		      IsClass#fun {$ X} 'class' end]}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% GUtils.applySelected
%%


declare
%% list of FD vars
MyMotif = {FD.list 3 0#20}
%% tuple of determined tuples: I can only select  
MotifDB = unit([1 2 3]
	       [11 12 13])
%% index into DB -- I only need to decide this
Index = {FD.decl}		


{Browse problem(db:MotifDB
		motif:MyMotif
		index:Index)}

{GUtils.applySelected [proc {$} MotifDB.1=MyMotif end
		       proc {$} MotifDB.2=MyMotif end]
 Index}


MyMotif.1 = 11			% i.e. Index = 1

Index >: 1

MotifDB.1=MyMotif




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% GUtils.isFS
%%


declare
DetFS = {FS.value.make [1 2 3]}
UndetFS = {FS.var.decl}

{GUtils.isFS DetFS}

{GUtils.isFS UndetFS}

/*

%% !! false
{FS.var.is DetFS}

%% 
{FS.value.is DetFS}


{FS.var.is UndetFS}

%% !! blocks
{FS.value.is UndetFS}

*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% GUtils.warnGUI
%%

%%
%% this is longer than what can is shown by the warning GUI..
%%

{GUtils.warnGUI "This is a test with a rather long text. The is also a singleverylongwordhere. The test text continues. This is a test with a rather long text. The is also a singlverylongwordheresinglverylongwordheresinglverylongwordhere. The test text continues. This is a test with a rather long text. The is also a singleverylongwordhere. The test text continues. This is a test with a rather long text. The is also a singleverylongwordhere. The test text continues. This is a test with a rather long text. The is also a singlverylongwordheresinglverylongwordheresinglverylongwordhere. The test text continues. This is a test with a rather long text. The is also a singleverylongwordhere. The test text continues."}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% GUtils.timeSpend
%%

{Browse {GUtils.timeSpend proc {$} _ = {List.number 1 10000000 1} end}}


