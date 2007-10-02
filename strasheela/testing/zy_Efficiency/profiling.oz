

%% Results:
%%


%% !!!! Main news:
%%
%% The Strasheela music representation is so memory demanding because it contains so much data. To solve CSPs more efficiently I may consider reducing this representation..
%%
%% Alternatively (better solution): keep the static data out of the computation space and copy only the variables


%% adding a number of (dummy) method does not by itself increase the memory footprint of a class instance (actually, it seems NoteWithMoreMethods requires slighly less memory than Score.note)
%% adding a number of (dummy) attributes does not by itself increase the memory footprint of a class instance (actually, it seems NoteWithMoreMethods requires slighly less memory than Score.note)
%%
%% BUT: The memory required by a single note corresponds with the memory required by a list of 400 FD ints!!!
%% (the amount required by this list is different at different calls -- does list allocate heap differently? Seems to depend how often proc was called since compilation..)
%% NB: a note has 2 features and 11 attributes from which there are 6 parameters (namely amplitude duration endTime offsetTime pitch startTime, each with 2 feats and 5 attrs), 2 extendable lists (2 feats and 1 attr, containers parameters), 1 dictionary (flags), and 2 other values (id info)
%%
%%
%% This amounts to a large number of data for a single note: at least  
%% feats: 2 + 6*2 + 2*2 = 18
%% attrs: 11 + 6*5 + 2 + 1 = 44
%%
%%


%% Memory requirement of general data structures
%%
%% * A single object instance (with 1 attr containing a FD int) takes slighly more as a single cell with a FD int which again is slighly more than a cell with a plain _. A FD itself takes about halve of this.
%%
%% * A dictionay is about twice the class instance
%%



%% it appears there is little difference in memory requirements for a CSP based on a record-based data structure or on an OOP data structure (using either attributes or features)
%%
%%
%% Still, updating attribute values (e.g. in init method) seems to be memory expensive


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% open profiler (Oz menu of OPI), feed definitions and feed calls
%% then press [update] in profiler and change [sort by] to [heap]
%% (befor additional checks do [reset] in compiler)

declare
%% check memory requirement of single Strasheela objects
%%
class NoteWithMoreMethods from Score.note
   meth bla1() skip end
   meth bla2() skip end
   meth bla3() skip end
   meth bla4() skip end
   meth bla5() skip end
   meth bla6() skip end
   meth bla7() skip end
   meth bla8() skip end
   meth bla9() skip end
   meth bla10() skip end
   meth bla11() skip end
   meth bla12() skip end
   meth bla13() skip end
   meth bla14() skip end
   meth bla15() skip end
   meth bla16() skip end
   meth bla17() skip end
   meth bla18() skip end
   meth bla19() skip end
   meth bla20() skip end
end
class NoteWithMoreAttrs from Score.note
   attr
      bla1
      bla2
      bla3
      bla4
      bla5
      bla6
      bla7
      bla8
      bla9
      bla10
end
%% a single note requires about 6500 byte
proc {MakeAnEvent}
   {Score.makeScore event unit _}
end 
proc {MakeANote}
   {Score.makeScore note unit(note:Score.note) _}
end 
proc {MakeANoteWithMoreMethods}
   {Score.makeScore note unit(note:NoteWithMoreMethods) _}
end
proc {MakeANoteWithMoreAttrs}
   {Score.makeScore note unit(note:NoteWithMoreAttrs) _}
end
proc {MakeManyFDInts N}
   {FD.list N 1#10000 _}
end


{MakeAnEvent}
{MakeANote}
{MakeANoteWithMoreMethods}
{MakeANoteWithMoreAttrs}
%
{MakeManyFDInts 400}


declare
%% test memory requirement of general data structures
%%
proc {MakeAnEmptyCell _}
   {Cell.new _ _}
end
proc {MakeACellWithFD _}
   {Cell.new {FD.decl} _}
end
proc {MakeAnFD _}
   {FD.decl _}
end
proc {MakeADictionary _}
   {Dictionary.new _}
end
class TestClass
   % feat foo:{FD.decl}
   attr bar:{FD.decl}
   meth init skip end
   meth test() skip end
end
proc {MakeAnInstance _}
   {New TestClass init _}
end


{For 1 100 1 MakeACellWithFD}
{For 1 100 1 MakeAnEmptyCell}
{For 1 100 1 MakeAnFD}
{For 1 100 1 MakeADictionary}
{For 1 100 1 MakeAnInstance}


%% how many takes a record with 10 FD ints compared with a class with 10 FD ints
%%
declare
class TenFDs1
   % feat foo:{FD.decl}
   attr
      test1:{FD.decl}
      test2:{FD.decl}
      test3:{FD.decl}
      test4:{FD.decl}
      test5:{FD.decl}
      test6:{FD.decl}
      test7:{FD.decl}
      test8:{FD.decl}
      test9:{FD.decl}
      test10:{FD.decl}
   meth init skip end
end
class TenFDs2
   % feat foo:{FD.decl}
   attr
      test1
      test2
      test3
      test4
      test5
      test6
      test7
      test8
      test9
      test10
   meth init(test1:Test1<={FD.decl}
	     test2:Test2<={FD.decl}
	     test3:Test3<={FD.decl}
	     test4:Test4<={FD.decl}
	     test5:Test5<={FD.decl}
	     test6:Test6<={FD.decl}
	     test7:Test7<={FD.decl}
	     test8:Test8<={FD.decl}
	     test9:Test9<={FD.decl}
	     test10:Test10<={FD.decl})
      @test1 = Test1
      @test2 = Test2
      @test3 = Test3
      @test4 = Test4 
      @test5 = Test5
      @test6 = Test6
      @test7 = Test7
      @test8 = Test8
      @test9 = Test9
      @test10 = Test10
   end
end
class TenFDs3
   % feat foo:{FD.decl}
   feat
      test1
      test2
      test3
      test4
      test5
      test6
      test7
      test8
      test9
      test10
   meth init(test1:Test1<={FD.decl}
	     test2:Test2<={FD.decl}
	     test3:Test3<={FD.decl}
	     test4:Test4<={FD.decl}
	     test5:Test5<={FD.decl}
	     test6:Test6<={FD.decl}
	     test7:Test7<={FD.decl}
	     test8:Test8<={FD.decl}
	     test9:Test9<={FD.decl}
	     test10:Test10<={FD.decl})
      self.test1 = Test1
      self.test2 = Test2
      self.test3 = Test3
      self.test4 = Test4 
      self.test5 = Test5
      self.test6 = Test6
      self.test7 = Test7
      self.test8 = Test8
      self.test9 = Test9
      self.test10 = Test10
   end
end
proc {MakeTenFDsInstance1 _}
   X = {New TenFDs1 init}
in
   skip
end
proc {MakeTenFDsInstance2 _}
   X = {New TenFDs2 init}
in
   skip
end
proc {MakeTenFDsInstance3 _}
   X = {New TenFDs2 init}
in
   skip
end
proc {MakeTenFDsRecord _}
   X = unit(test1:{FD.decl}
	    test2:{FD.decl}
	    test3:{FD.decl}
	    test4:{FD.decl}
	    test5:{FD.decl}
	    test6:{FD.decl}
	    test7:{FD.decl}
	    test8:{FD.decl}
	    test9:{FD.decl}
	    test10:{FD.decl})
in
   skip
end



{For 1 10 1 MakeTenFDsRecord}	% 1600 byte
{For 1 10 1 MakeTenFDsInstance1} % 800 byte
{For 1 10 1 MakeTenFDsInstance2} % 1760 byte (+ 7840 b for TenFDs2, init ??)
{For 1 10 1 MakeTenFDsInstance3} % 1760 byte 

% {For 1 10 1 MakeTenFDsInstance2} % 3664 byte (+ 1600 for TenFDs2, init ??)



{For 1 100 1 MakeTenFDsRecord}	% 15k
{For 1 100 1 MakeTenFDsInstance1} % 8000b
{For 1 100 1 MakeTenFDsInstance2} % 17k byte (+ 99k for TenFDs2, init ??)
{For 1 100 1 MakeTenFDsInstance3} % 17k byte 

% {For 1 10 1 MakeTenFDsInstance2} % 3664 byte (+ 1600 for TenFDs2, init ??)

