
declare
[MultiDict] = {ModuleLink ['x-ozlib://anders/strasheela/MultiDict/MultiDict.ozf']}


 
declare
MyDict = {MultiDict.new}

{MultiDict.is MyDict}

{MultiDict.is bla}



{MultiDict.put MyDict [a b c] 3}

{MultiDict.put MyDict [x y z] foo}

{MultiDict.get MyDict [a b c]}

{MultiDict.entries MyDict}

{MultiDict.removeAll MyDict}

{MultiDict.entries MyDict}
