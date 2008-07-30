
declare 
[LUtils] = {Module.link ['x-ozlib://anders/music/sdl/ListUtils.ozf']}

{All
 [
  {LUtils.mappend [1 2 3] fun {$ X} [X X] end} == [1 1 2 2 3 3]

  {LUtils.mappend [1 2 3 4] 
   fun {$ X}
      if {IsEven X} then [X] else nil end
   end}
  == [2 4]
  
  {LUtils.position c [a b c d]} == 3
  
  {LUtils.position x [a b c d]} == nil
  
  {LUtils.positions c [a b c d c e]} == [3 5]

  
  {LUtils.remove [1 2 3 4 5 6] IsOdd} == [2 4 6]
  

  {LUtils.find [1 2 3 4 5 6] IsEven} == 2

  {LUtils.find [1 2 3 4 5 6] IsAtom} == nil

  {LUtils.findPosition [1 2 3 4 5 6] IsEven} == 2

  {LUtils.findPositions [1 2 3 4 5 6] IsEven} == [2 4 6]
  
  {LUtils.subtractList [a b c d e] [b c]} == [a d e]

  {LUtils.accum [1 3 2 4] Number.'+'} == 10

  {LUtils.matTrans [[a b c] [d e f] [x y z]]} == [[a d x] [b e y] [c f z]]

  {LUtils.nthWrapped [a b c d] 2} == b
  {LUtils.nthWrapped [a b c d] 6} == b
 ]
fun {$ X} X==true end}


{LUtils.count [1 2 3 4] IsEven} ==  2
{LUtils.count [a b c] IsNumber} ==  0


{LUtils.split [a b a b c b a c a] c} == [[a b a b] [b a] [a]]


{LUtils.sublist [a b c d e f g] 2 5} == [b c d e]


% exception
{LUtils.sublist [a b c d e f g] 0 5} 

% !! returns only part..
{LUtils.sublist [a b c d e f g] 3 8} == [c d e f g]




%% Difference lists


 
%% extendableList

declare
EList = {New LUtils.extendableList init}

{Browse EList.list}

{EList add(1)}

{EList addList([1 2 3])}

{EList addList(nil)}

{LUtils.butLast EList.list}

%% suspends
{Filter EList.list fun {$ X} {IsEven X} end}

{EList close}



%{LUtils.arithmeticSeries 5 3 2} % -> [3 5 7 9 11]

%{LUtils.geometricSeries 5 2 2} % -> [1]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% LUtils.range 
%%


{LUtils.range [1 2 3 4 5 6 7] 2 6}

{LUtils.range [1 2 3 4 5 6 7] 1 3}

%% exception
{LUtils.range [1 2 3 4 5 6 7] 0 3}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% LUtils.everyNth
%%


{LUtils.everyNth [1 2 3 4 5 6 7 8 9] 2}

/*
{LUtils.evenPositions [1 2 3 4 5 6 7 8 9]}


{LUtils.arithmeticSeries {IntToFloat 3} {IntToFloat 2}
 {FloatToInt {Ceil {IntToFloat 9} / {IntToFloat 2}}}}
*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% LUtils.replace
%%

{LUtils.replace [a b c d] unit(b:hi d:there)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% LUtils.substitute
%%

{LUtils.substitute [a b c b d] b hi}

{LUtils.substitute1 [a b c b d] b hi}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% LUtils.cFilter 
%%


%%
%% Filter blocks are undetermined vars
%%

declare
Xs = [1 2 3 _ 4 _ 7]
Ys
thread Ys = {Filter Xs IsOdd} end
{Browse Ys}


%%
%% ConcurrentFilter, on the other hand, processes as much as there is available
%%

declare
Xs = [1 2 3 _ 4 _ 7]
Ys
{Browse Ys}
thread Ys = {LUtils.cFilter Xs IsOdd} end

{Nth Xs 6} = 6

{Nth Xs 4} = 5


%%
%% no results (nil returned)
%%

{LUtils.cFilter [1] fun {$ X} false end}

{LUtils.cFilter nil fun {$ X} false end}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% LUtils.cFind
%%


declare
Xs = [1 _ 2 _ 3]
Y
{Browse Y}
Y = {LUtils.cFind Xs fun {$ X} X > 3 end} 


%% Y will be either 5 or 6 (whoever comes first)
thread {Nth Xs 4} = 5 end
thread {Nth Xs 2} = 6 end



%%
%% no results (nil returned)
%%

{LUtils.cFind [1] fun {$ X} false end}

{LUtils.cFind nil fun {$ X} false end}

{LUtils.cFind [1 3] IsEven}




