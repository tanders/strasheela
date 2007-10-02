
declare
[MultiRecord] = {ModuleLink ['x-ozlib://anders/strasheela/MultiRecord/MultiRecord.ozf']}


declare
MyRecord = {MultiRecord.new}

{MultiRecord.is MyRecord} == true

{MultiRecord.is bla(x:1)} == false

{MultiRecord.put MyRecord [a b c] 3}

{MultiRecord.put MyRecord [x y z] foo}

{MultiRecord.get MyRecord [a b c]} == 3

{MultiRecord.reflectHasFeat MyRecord [a b c]} == true

{MultiRecord.reflectHasFeat MyRecord [d e f]} == false

{MultiRecord.condGet MyRecord [a b c] unit} == 3

{MultiRecord.condGet MyRecord [d e f] unit} == unit

{MultiRecord.condGetPutting MyRecord [a b c] fun {$} bar end} == 3

{MultiRecord.condGetPutting MyRecord [d e f] fun {$} bar end} == bar

{MultiRecord.entries MyRecord} == [[a b c]#3 [d e f]#bar [x y z]#foo]

{MultiRecord.clear MyRecord}

{MultiRecord.entries MyRecord} == nil


%% putting different values at the same Keys raises an exception
{MultiRecord.put MyRecord [a b c] {Score.makeScore note unit}}

{MultiRecord.put MyRecord [a b c] {Score.makeScore note unit}}


