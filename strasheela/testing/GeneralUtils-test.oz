
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% toProc
%% 

declare
MyScore = {Score.makeScore seq(items:[note(duration: 2)
				      pause(duration: 3)
				      note(duration:4)])
	   unit}
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

%% default test: isNote
{{GUtils.toProc mapItems(x getDuration test:isNote)} MyScore unit}
%% overwritten arg test
{{GUtils.toProc mapItems(x getDuration test:isNote)} MyScore unit(test:isItem)}


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

% declare
% [U] = {ModuleLink ['x-ozlib://anders/music/sdl/GeneralUtils.ozf']}

for I in 1..10 do {Browse {GUtils.random 100}} end

for I in 1..10 do {Browse {GUtils.random 3}} end


%%%%%%

%% OK, both max and min are among solutions
{LUtils.collectN 20 fun {$} {GUtils.randIntoRange {OS.rand} 0 10} end}



%% Random quality of OS.rand improved (in particular 1st value) by seed from GUtils.devRandom
declare
{OS.srand {GUtils.devRandom}}
{Browse {LUtils.collectN 10 fun {$} {GUtils.randIntoRange {OS.rand} 0 100}end}}


%% Nevertheless, GUtils.knuthRandom is even better
declare
{GUtils.setKnuthRandomSeed {GUtils.devRandom}}
{Browse {LUtils.collectN 10 fun {$} {GUtils.randIntoRange2 {GUtils.knuthRandom}  0 100 {Pow 2 64}} end}}


%% compare effeciency of GUtils.knuthRandom and OS.rand
%% OS.rand is about double as fast, but the time required is still very small. GUtils.randIntoRange2 again more than doubles that amount
{GUtils.timeSpend
 proc {$} _ = {LUtils.collectN 100000 fun {$} {GUtils.randIntoRange2 {GUtils.knuthRandom}  0 100 {Pow 2 64}} end} end}

{GUtils.timeSpend
 proc {$} _ = {LUtils.collectN 100000 fun {$} {GUtils.knuthRandom} end} end}

{GUtils.timeSpend
 proc {$} _ = {LUtils.collectN 100000 fun {$} {OS.rand} end} end}







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
%% GUtils.round_digits
%% 

{GUtils.roundDigits 1.23456 2}

{GUtils.roundDigits 1.23456 1}

{GUtils.roundDigits 1.23456 0}

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
%% GUtils.intsToFS
%%

declare
X = {FD.int 1#10} 
Y = {FD.int 1#10}
Z = {FD.int 1#10}
MyFS = {FS.var.decl} 


{Browse MyFS#[X Y Z]}

{GUtils.intsToFS [X Y Z] MyFS}

%% Compare with FS.int.match
MyFS = {FS.var.decl}
{FS.int.match MyFS [X Y Z]}


Y = 2



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




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% GUtils.recursiveAdjoin
%%

{GUtils.recursiveAdjoin
 unit(iargs:unit(a:1 c:2)
      x:test)
 unit(iargs:unit(b:1 c:42)
      x:hi)}


{GUtils.recursiveAdjoin
 unit(iargs: unit(n:7
		  duration:2
		  timeUnit:beats)
      rargs: unit(scale: cMajor
		  types: ['major' 'minor'])
      lilyKey: "my test")
 unit(iargs: unit(n:9)
      rargs: unit(scale: aMinor))}

{GUtils.recursiveAdjoin unit(bla:test)
 unit(duration: {FD.int 1#2})}


