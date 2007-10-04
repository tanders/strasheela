
declare 
[Pattern] = {ModuleLink ['x-ozlib://anders/strasheela/Pattern/Pattern.ozf']}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% generic example1

declare
proc {ArithmeticSeries Xs Difference}
   {Pattern.plainPattern Xs
    proc {$ X Predecessor}
       X =: Predecessor + Difference
    end}
end
Xs = {FD.list 4 1#20}
Difference
Difference :: 3#5
{Browse Xs}

{ArithmeticSeries Xs Difference}

Xs.1 = 3

Difference = 4

%% generic example2

declare 
proc {ArithmeticSeries Xs Difference}
   {Pattern.plainPattern2 Xs
    proc {$ X Predecessors N}
       %% N is index of X in Xs, not used here anyway
       if Predecessors==nil
       then skip
       else X =: Predecessors.1 + Difference
       end
    end}
end
Xs = {FD.list 4 1#20}
Difference
Difference :: 3#5
{Browse Xs}

{ArithmeticSeries Xs Difference}

Xs.1 = 3

Difference = 4


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% predefined pattern

declare
Xs = {FD.list 4 1#20}
{Browse Xs}

{Pattern.allEqual Xs}

Xs.1 = 4

declare
Xs = {FD.list 4 1#20}
{Browse Xs}

{Pattern.increasing Xs}

{Nth Xs 3 5}


declare
Xs = {FD.list 4 1#20}
Difference
{FD.decl Difference}
{Browse Xs}

{Pattern.arithmeticSeries Xs Difference}

Difference :: 3#5

Xs.1 = 3

Difference = 4


declare
Xs = {Append [2] {FD.list 5 0#1000}}
Y = {FD.int 1#10}

{Pattern.geometricSeries Xs Y}

Y <: 4

Y =: 3


declare
Xs = {FD.list 4 1#20}
Y Z
[Y Z] ::: 1#20
{Browse Xs#Y#Z}

{Pattern.inInterval Xs Y Z}

Y :: 3#5

Z :: 10#13



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
Xs = [_ _ _ _ _ _ _ _]

{Inspect Xs}

{Pattern.cycle Xs 3}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare 
[Pattern] = {Module.link ['x-ozlib://anders/music/sdl/Pattern.ozf']}

declare
Xs = {FD.list 8 1#20}
CycleElements = {FD.list 3 3#5}
{Browse Xs}

{Pattern.cycle2 Xs CycleElements}

CycleElements = [3 4 5]

declare
Xs = {FD.list 12 1#20}
Ys = {FD.list 3 3#5}
{Browse Xs#Ys}

{Pattern.rotation Xs Ys}

Ys = [3 4 5]


declare
Xs = {FD.list 12 1#20}
Ys = {FD.list 3 3#5}
{Browse Xs}

{Pattern.palindrome Xs Ys unit}

{Pattern.palindrome Xs Ys true}

{Pattern.palindrome Xs Ys first}

{Pattern.palindrome Xs Ys last}

Ys = [3 4 5]

declare
Xs = {FD.list 7 1#20}
Ys = {FD.list 3 3#5}
{Browse Xs}

{Pattern.line Xs Ys}

Ys = [3 4 5]

declare
Xs = {FD.list 7 1#20}
Ys = {FD.list 3 [1 4 6 7]}
{Browse Xs}

{Pattern.random Xs Ys}


declare
Xs = {FD.list 16 1#20}
HeapElements = {FD.list 3 3#5}
{Browse Xs}

{Pattern.heap Xs HeapElements}

HeapElements = [3 4 5]


declare
Xs = {FD.list 12 1#20}
Ys = {FD.list 3 3#5}
{Browse Xs}

{Pattern.accumulation Xs Ys}

Ys = [3 4 5]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% testing Pattern.max 

declare 
[Pattern] = {Module.link ['x-ozlib://anders/music/sdl/Pattern.ozf']}

declare
Xs = {FD.list 7 1#20}
Y
Y :: 1#20
Zs = {FD.list 3 3#6}
{Browse Xs#Y#Zs}

{Pattern.accumulation Xs Zs}

{Pattern.max Xs Y}

Y = 5

Zs = [3 4 5]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare 
[Pattern] = {Module.link ['x-ozlib://anders/music/sdl/Pattern.ozf']}

%% conjunction: the integers in Xs are increasing and all fall in the interval [X, Y].

declare
Xs = {FD.list 5 1#20}
Y Z
[Y Z] ::: 1#20
{Browse Xs#Y#Z}

{Pattern.inInterval Xs Y Z}

{Pattern.increasing Xs}

Y :: 3#5

Z :: 12#17

{Nth Xs 3 10}


%% Pairwise adding the elements of the increasing Xs and the Ys (in interval [0, 2]) constraints Zs to tend to increase but not strictly
declare
Xs = {FD.list 5 0#20}
Ys = {FD.list 5 0#20}
Zs = {FD.list 5 0#20}
{Browse Xs#Ys#Zs}

{Pattern.increasing Xs}

{Pattern.inInterval Ys 0 2}

{Pattern.parallelMap [Xs Ys]
 proc {$ [X Y] Z}
    X + Y =: Z
 end
 Zs}

{Nth Xs 3 10}



declare 
[Pattern] = {Module.link ['x-ozlib://anders/music/sdl/Pattern.ozf']}

declare
Xs = {FD.list 3 1#3}
Ys = {FD.list 3 0#2}
Zs = {FD.list 3 0#2}
As = {FD.list 10 0#20}
{Browse Xs#Ys#Zs#As}

{Pattern.zip [Xs Ys Zs] As}

{Pattern.increasing Xs}

{Pattern.allEqual Ys}

{Pattern.allEqual Zs}

Ys.1=0

Zs.1=1



declare 
[Pattern] = {Module.link ['x-ozlib://anders/music/sdl/Pattern.ozf']}

%% Xs are pitches, Ys are intervals between pitches with offset of 100
%% to aviod negative numbers
declare
Xs = {FD.list 7 60#72}
Ys = {FD.list 6 0#112}
{Browse Xs#Ys}

{Pattern.map2Neighbours Xs
 proc {$ X1 X2 Y}
    X2 - X1 + 100 =: Y
 end
 Ys}

{Pattern.cycle2 Xs [60 62 61]}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% appending a list of lists by flattening: length of result must certainly match. To generate a longer pattern of this I may just cycle through the resulting list by Pattern.cycle

declare
Xs = {FD.list 3 1#3}
Ys = {FD.list 3 0#2}
Zs = {FD.list 4 0#2}
As = {FD.list 10 0#20}
{Browse Xs#Ys#Zs#As}

{Flatten [Xs Ys Zs] As}

{Pattern.increasing Xs}

{Pattern.allEqual Ys}

{Pattern.allEqual Zs}

Ys.1=0

Zs.1=1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Pattern.transformDisj: decision for FnI leads to decision for transformation function 

%declare 
%[Pattern] = {Module.link ['x-ozlib://anders/music/sdl/Pattern.ozf']}

declare
Xs = {FD.list 3 1#10}
Ys = {FD.list 3 1#10}
FnI
{Browse Xs#Ys#FnI}

{Pattern.transformDisj Xs
 [fun {$ Xs} Xs end
  fun {$ Xs} {Reverse Xs} end]
 FnI
 Ys}

FnI = 2

Xs = [1 2 3]


%% Pattern.transformDisj: mismatch of input/output list length rules out clauses in the disjuction

declare
Xs = {FD.list 3 1#10}
Ys = {FD.list 4 1#10}
FnI
{Browse Xs#Ys#FnI}

{Pattern.transformDisj Xs
 [fun {$ Xs} Xs end
  fun {$ Xs} Xs.1 | {Reverse Xs} end]
 FnI
 Ys}


%declare 
%[Pattern] = {Module.link ['x-ozlib://anders/music/sdl/Pattern.ozf']}

%% Pattern.mapCartesianProduct

%% works as generator
declare Xs
{Browse Xs}

{Pattern.mapCartesianProduct [10 20] [1 2 3] Number.'+' Xs}


%% and as contraint
declare
Xs = {FD.list 2 1#20}
Ys = {FD.list 3 1#20}
Zs = {FD.list 6 1#30}
{Browse Xs#Ys#Zs}

{Pattern.mapCartesianProduct Xs Ys
 proc {$ X Y Z} X + Y =: Z end
 Zs}

Xs = [10 20]

Ys = [1 2 3]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% L-system: Pattern.makeLSystem
declare
A B

{LUtils.replace
 {Pattern.makeLSystem [a b '|']	% '|' marks period end
  5				% nr of periods
  fun {$ X}
     case X
     of a then [b]
     [] b then [a b]
     else [X]			% !! otherwise rule not implicit
     end
  end}
 unit(a:A b:B)}


%% It is also possible to split the resulting pattern in the single periods/generations by inserting a last symbol in the start pattern which is always simply copied. Splitting allows, e.g., to use only the n-th generation in the end (with all its self-similarities) and not the whole history of its genesis.
{LUtils.split 
 {Pattern.makeLSystem [a '|'] 7
  fun {$ X}
     case X
     of a then [b]
     [] b then [a a b c a]
     [] c then [a c]
     else [X]			% !! otherwise rule not implicit
     end
  end}
 '|'}
 
%% The definition of Pattern.makeLSystem can also be used for parameteric L-systems (although the translation into constrainable vars later may be less obvious)
{Pattern.makeLSystem [a(1)] 5
 fun {$ R}
    L = {Label R}
    X = R.1
 in
    case L
    of a then [a(X*2) b(X)]
    [] b then [b(X-1)]
    else [X]		
    end
 end}

%% Also pattern I defined for the Tao piece (but never used) using conditions and floats I can define this way as well
{Pattern.makeLSystem [1 2] 5
 fun {$ X}
    if X < 3 then [X+1]
    else [1 2]
    end
 end}

local
   Power1 = 2.0
   Power2 = 1.9
   Factor = 1.3
in
   {Pattern.makeLSystem [0.1] 20
    fun {$ X}
       if X < 1.0/Factor then [X*Factor]
       else [X / {Pow Factor Power1}
	     X / {Pow Factor Power2}]
       end
    end}
end

%% first-order markow chains are (almost) definable with Pattern.makeLSystem as well (actually, for a markov chain I can not define clauses which output periods like this...)
{ExploreOne
 proc {$ Sol}
    Sol = {Pattern.makeLSystem [a] 5
	   fun {$ X}
	      case X
		 %% using choice only for a test
	      of a then choice [a] [] [b] end
	      [] b then choice [a b] [] [a a] end
	      else [X]			% !! otherwise rule not implicit
	      end
	   end}
 end}


% %%
% %% Transformation of L-system result into funcs on list dependent of predecessor func ..
% %%

% declare
% MyLSystemOut = [a b '|' a a b '|' a b a a b '|']
% Xs = {List.make 50}
% %% in transformation funcs, Xs is resulting list of a previous call 
% MyLSystemTransformations = unit(a: fun {$ Xs}
% 				      Ys = {List.drop Xs 3}
% 				   in
% 				      Ys.1 = a
% 				      Ys
% 				   end
% 				b: fun {$ Xs}
% 				      Ys = {List.drop Xs 4}
% 				   in
% 				      Ys.1 = b
% 				      Ys
% 				   end
% 				'|': fun {$ Xs}
% 				      Ys = Xs.2
% 				   in
% 				      Ys.1 = '|'
% 				      Ys
% 				   end)
% proc {Transformation MyLSystemOut Xs}
%    if MyLSystemOut == nil then skip
%    else {Transformation MyLSystemOut.2
% 	 {MyLSystemTransformations.(MyLSystemOut.1) Xs}}
%    end
% end

% {Transformation MyLSystemOut Xs}

% %%%

%% ?! I may define LUtils.replaceAppending ?

{Flatten
 {LUtils.replace [a b '|' a a b '|']
  unit(a: [_ _ a]
       b: [_ _ _ b]
       '|': ['|'])}}
  
%% will constraints auf liste anwenden

% %%

% /** %% Transforms a list of symbols (atoms or integers)  
% %% */
% fun {TransformSymbols Xs Clauses}
%    if Xs == nil then nil
%    else {Clauses.(Xs.1) Xs} |
% 	 {TransformSymbols Xs.2}
%    end
% end

% %% arg of fns is always feature of Clauses, alternative is simple mapping or mapTail

% {TransformSymbols [a b '|' a a b '|']
%  unit(a: fun {$ X}
% 	    [_ _ a]
% 	 end
%       b: fun {$ X}
% 	    [_ _ _ b]
% 	 end
%       '|': fun {$ X}
% 	      ['|']
% 	   end}




% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% L-system: Pattern.makeLSystem2


%% old test (not using 'context') still working
{Pattern.makeLSystem2 [a b '|'] 5
 fun {$ Previous X Suceeding}
    case X
    of a then [b]
    [] b then [a b]
    else [X]			% !! otherwise rule not implicit
    end
 end}

%% umstaendliche Ausdrucksweise, aber im Prinzip OK 
{Pattern.makeLSystem2 [a b '|'] 9
 fun {$ Previous X Suceeding}
    %% more specific rules are listed before more general one and
    %% therefore considered first
    if (X==a andthen Previous \= nil andthen Previous.1==b) then [c]
%    if (X==a andthen Previous \= nil andthen Suceeding.1==b) then [c]
    elseif X==a then  [a b]
    elseif X==b then [a]
    elseif X==c then [c a]
    else [X]			% !! otherwise rule not implicit
    end
 end}


%% todo for L-system: how to express terminal node (ie. it produces no successor(s) in the pattern's next generation)

%% ?? todo (nested pattern): nodes in rules rewritable by patterns as well?


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%%
%% MkUniqueIntervalSeq
%%

declare
MyPatternFn = {Pattern.mkUniqueIntervalSeq 3 0}
Xs = {FD.list 3 1#10}
Ys = {FD.list 3 1#10}

{Browse Xs#Ys}

{MyPatternFn Xs}
{MyPatternFn Ys}

Xs.1 = 1

Ys.1 = 2

{Nth Xs 3} = 5

{Nth Ys 2} = 7


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%%
%% Pairwise
%%

{Pattern.mapPairwise [1 2 3 4 5] fun {$ X Y} X#Y end} 


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%%
%% 1/f noise
%%

%% deterministic
{Pattern.oneOverFNoiseDeterm 10 0.7}


%% constraint
declare
Xs = {List.make 10}
Xs ::: 0#100
Xs.1 = 70
{Browse Xs}

{Pattern.oneOverFNoise Xs}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Pattern.forPercent
%% 

{ExploreOne
 proc {$ Xs}
    Xs = {FD.list 5 0#1}
    {Pattern.forPercent Xs
     proc {$ X B} B={FD.decl} B =: (X >: 0) end
     45 55}
    {FD.distribute ff Xs}
 end}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Pattern.nDifferences / Pattern.forN
%% 

{ExploreOne
 proc {$ Sol}
    Xs = {FD.list 5 0#10}
    Ys = {FD.list 5 0#10}
    N = {FD.int 2#3}
 in
    Sol = Xs#Ys#N
    {Pattern.nDifferences Xs Ys N}
    {FD.distribute ff {Append N|Xs Ys}}
 end}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Pattern.forNEither / Pattern.forN
%% 

{ExploreOne
 proc {$ Sol}
    Xs = {FD.list 5 0#10}
    N = {FD.int 3#4}
 in
    Sol = Xs#N
    {Pattern.forNEither Xs
     proc {$ X ?B}
	B = {FD.decl}
	B = {FD.conj (X >: 0) (X <: 3)}
     end
     proc {$ X ?B}
	B = {FD.decl}
	B = {FD.conj (X >: 7) (X <: 10)}
     end
     N}
    {FD.distribute ff N|Xs}
 end}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Pattern.isDirectionChangeR
%%

{ExploreOne
 proc {$ Sol}
    X Y Z
in
    [X Y Z] ::: 0#2
    Sol = [X Y Z]
    {Pattern.directionChangeR X Y Z 0}
    {FD.distribute ff [X Y Z]}
 end}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Pattern.direction
%%

{ExploreOne
 proc {$ Sol}
    X1 X2 Y
in
    [X1 X2 Y] ::: 0#5
    Sol = [X1 X2 Y]
    {Pattern.direction X1 X2 Y}
    %% changing the order of distributed vars changes search tree??
    {FD.distribute ff [Y X1 X2]}
 end}

%% Pattern.directionR


declare
X1 X2 Y
[X1 X2 Y] ::: 0#10

{Browse [X1 X2 Y]}

{Pattern.direction X1 X2 Y}


Y = 0 %% muesste domain von X1 und X2 so reduzieren dass nur X1 > X2 moeglich ist

Y = 1 %% 


X2=1  %% reduziert domain von X1 richtig

X1=2


%%%%%

%%
%% !! Pattern.direction does not propagate very well
%%

declare
X1 = {FD.int 10#20}
X2 = {FD.int 10#20}
Dir = {FD.decl}

{Browse [X1 X2 Dir]}

{Pattern.direction X1 X2 Dir}


%% alt 1
Dir :: [0 1]

%% -> no propagation 

%% alt 1
X1 = 15

%% -> propagation


%% alt 2
Dir :: [1 2]

%% -> no propagation 

%% alt 2
X1 = 15
 
%% !! -> no propagation

%% alt 2
X2 = 14

%% -> correct failure 


%% alt 3
Dir :: [0]

%% -> propagation 


%% alt 4
Dir :: [1]

%% -> no propagation

%% alt 4
X1 = 15

%% -> propagation 



%% alt 5
Dir :: [2]

%% -> propagation 



%% alt 6
Dir :: [0 1]

%% -> no propagation 

%% alt 6
X2 = 15

%% -> propagation 



%% alt 7
Dir :: [1 2]

%% -> no propagation 

%% alt 7
X2 = 15




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Pattern.contour
%%

declare
Xs = [1 3 2 2 0]
Ys = {FD.list {Length Xs}-1 0#10}

{Browse Xs#Ys}

{Pattern.contour Xs Ys}


{ExploreOne
 proc {$ Sol}
    Ys = [2 2 0 1 0]
    Xs = {FD.list {Length Ys}+1 0#5}
in
    Sol = Xs#Ys
    {Pattern.contour Xs Ys}
    {FD.distribute ff {Append Xs Ys}}
 end}


%%
%% Pattern.inverseContour
%%

declare
Xs = [1 3 2 2 0]
Ys = {FD.list {Length Xs}-1 0#10}
Zs = {FD.list {Length Xs}-1 0#10}

{Browse Xs#Ys#Zs}

{Pattern.contour Xs Ys}

{Pattern.inverseContour Ys Zs}


%%
%% Pattern.contourMatrix
%%


%% contour matrix of first 8 note pitches of Kunst der Fuge 
{Browse {Pattern.contourMatrix [62 69 65 62 61 62 64 65]}}


%% create a list with following contour matrix of Kunst der Fuge
{Search.base.one
 proc {$ Xs}
    Xs = {FD.list 8 0#11}
    {Pattern.contourMatrix Xs} = {Pattern.contourMatrix [62 69 65 62 61 62 64 65]}
    {FD.distribute ff Xs}
 end}

%% create list following plain contour of Kunst der Fuge. Using contour matrix is more precise: equal pitches in orig are also equal in new list, absolute min and max are also absolute min/max (relations between local min/max would also be true). All this is not necessarily the case for plain contour.
{Search.base.one
 proc {$ Xs}
    Xs = {FD.list 8 0#11}
    {Pattern.contour Xs} = {Pattern.contour [62 69 65 62 61 62 64 65]}
    {FD.distribute ff Xs}
 end}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Pattern.selectList and friends
%%

declare
Xss = [[1 2 3] [2 3 4] [3 4 5] [3 2 1]]
I = {FD.decl}
Ys = {FD.list 3 0#10}

{Browse Xss#I#Ys}

{Pattern.selectList Xss I Ys}

Ys.1 = 3			% reduces the domain of I 


declare
Xs = [10 11 12 13 14 15]
Is = {FD.list 3 0#10}
Ys = {FD.list 3 0#20}

{Browse Xs#Is#Ys}

{Pattern.selectMultiple Xs Is Ys}

Is = [2 4 3]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Pattern.fdInts / Pattern.fdRanges
%%

declare
Xs = {FD.list 3 0#10}
Mins = [1 2 3]
Max = [10 9 8]

{Pattern.fdInts Xs Mins Max}
% Xs = [1#10 2#9 3#8]

declare
Xs = {FD.list 3 0#10}
Mids = [4 5 6]
Ranges = [4 3 2]

{Pattern.fdRanges Xs Mids Ranges}
% Xs = [2#6 4#7 5#7]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Pattern.howManyAs
%%

declare
Xs = {FD.list 5 0#10}
N = {FD.decl}

{Browse Xs#N}

{Pattern.howManyAs Xs 0 '=:' N}

{Nth Xs 2} = 0

{Nth Xs 3} = 0

{Nth Xs 4} = 5
{Nth Xs 5} = 5


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
X = {FD.decl}
Xs = {FD.list 5 1#10}
N = {FD.decl}

{Browse [X Xs N]}

{Pattern.howMany X Xs N}

Xs = [1 3 2 4 3]


%% does not propagate that X has domain of Xs valus
N = 2

X = 3

X = 20


declare
X = {FD.decl}
Xs = {FD.list 5 1#10}

{Browse [X Xs]}

{Pattern.once X Xs}

X = 3

X = 20


Xs = [1 3 2 4 3]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Pattern.zerosOnlyAtEnd, Pattern.relevantLength
%%

declare
Xs = {FD.list 3 0#1}

{Browse Xs}

{Pattern.zerosOnlyAtEnd Xs}

{Nth Xs 2} = 0

Xs.1 = 1



declare
Xs = {FD.list 4 0#2}
N 

{Browse Xs#N}

{Pattern.relevantLength Xs N}

{Nth Xs 3} = 0

{Nth Xs 2} = 1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Pattern.mapTail and friends
%%

{Pattern.mapTail [1 2 3 4] fun {$ Xs} Xs end}

{Pattern.mapTailInd [1 2 3 4] fun {$ I Xs} I#Xs end}

{Pattern.mapTailN [1 2 3 4] 3 fun {$ I Xs} Xs end}

%% exception
{Pattern.mapTailN [1 2 3 4] 5 fun {$ I Xs} Xs end}

{Pattern.forTail [1 2 3 4] proc {$ Xs} {Browse Xs} end}

{Pattern.forTailInd [1 2 3 4] proc {$ I Xs} {Browse I#Xs} end}

{Pattern.forTailN [1 2 3 4] 3 proc {$ I Xs} {Browse Xs} end}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Pattern.mapNeighbours and friends
%%

%% testing
{Pattern.mapNeighbours [1 2 3 4 5] 3 fun {$ Xs} Xs end}

{Pattern.mapNeighbours [1 2 3 4 5] 1 fun {$ Xs} Xs end}

{Pattern.mapNeighbours [1 2 3 4 5] 6 fun {$ Xs} Xs end} == nil

{Pattern.mapNeighboursInd [1 2 3 4 5] 3 fun {$ I Xs} I#Xs end}

{Pattern.forNeighbours [1 2 3 4 5] 3 proc {$ Xs} {Browse Xs} end}

{Pattern.forNeighboursInd [1 2 3 4 5] 3 proc {$ I Xs} {Browse I#Xs} end}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Pattern.markovChain
%%


%%%%%%%%%%%
%% 
%% first order markov chain
%%

declare
Xs = {FD.list 5 1#3}

{Browse Xs}


{Pattern.markovChain Xs
 [
  [1]#[2 3]
  [2]#[1]
  [3]#[2]
 ]}


%% determine predecessor and reduce domain of successor
{Nth Xs 2} = 1

{Nth Xs 3} = 3


%%%%%%%%%%%
%%
%% second order markov chain with two symbols
%%

declare
Xs = {FD.list 5 1#2}

{Browse Xs}

{Pattern.markovChain Xs
 [
  [1 1]#[2]
  [2 1]#[1 2]
  [1 2]#[1 2]
  [2 2]#[1]
 ]}


{Nth Xs 2} = 2

{Nth Xs 3} = 2




%%%%%%%%%%%
%%
%% second order markov chain with three symbols and a wildcard
%%

declare
Xs = {FD.list 5 1#3}

{Browse Xs}

{Pattern.markovChain Xs
 [
  [1 1]#[2 3]			% the sequence 1|1 is followed by 2 or 3
  [2 1]#[2 3]
  [1 2]#[1 2]
  [2 2]#[1 3]
  [x 3]#[1 2]			% 3 is always followed by 1 or 2
 ]}


{Nth Xs 2} = 2

{Nth Xs 3} = 2

{Nth Xs 5} = 1





%%%%%%%%%%%
%%
%% SPEAC
%%

declare
Xs = {FD.list 7 0#4}
S=0 P=1 E=2 A=3 C=4

{Browse Xs}

%% Cope's Succession rules according to da Silva (Torsten slightly edited)
{Pattern.markovChain Xs
 [
  [x x S]#[P E A]
  [x x P]#[S A C]
  [x x E]#[S P A C]
  [x x A]#[E C]
  %% C only in this progressions (no C in other clauses)
  [x A C]#[S P E A]
  [A x C]#[S P E A]
  %[A E C]#[S P E A]
  %[A P C]#[S P E A]
 ]}



{Nth Xs 3} = A
%% nice: determines {Nth Xs 4} to E (as intended)
{Nth Xs 5} = C


%% NO fail (as understood): clauses only constrain sublists of length 3
{Nth Xs 1} = S
{Nth Xs 2} = S


%% reduces domain of successor (as intended) 
{Nth Xs 3} = S
% {Nth Xs 4} = S



%% fail (as intended)
{Nth Xs 3} = S
{Nth Xs 4} = C



%%%%%%%
%%
%% SPEAC script
%%

{ExploreOne
 proc {$ Xs}
    S=0 P=1 E=2 A=3 C=4
    Aux = {FD.list 2 0#4}
    %% trick: markov chain holds from beginning:
    %% problem: introduces symmetries
    FullXs = {Append Aux Xs}	
 in
    Xs = {FD.list 7 0#4}
    %% determine first and last
    Xs.1 = S {List.last Xs} = C
    {Pattern.markovChain FullXs
     [[x x S]#[P E A]
      [x x P]#[S A C]
      [x x E]#[S P A C]
      [x x A]#[E C]
      %% C only in this progressions (no C in other clauses)
      [x A C]#[S P E A]
      [A x C]#[S P E A]]}
    %%
    {FD.distribute ff FullXs}
 end}

%%
%% possible unintended sol:
%%
%% !! * S P C: reached C without preceeded A
%%
%% Avoided by determining first and last by hand
%% * begin and end with S
%% * end with P
%%


%%%%%%%%%%%%%
%%
%% Pattern.markovChain_1
%%

declare
Xs = {FD.list 4 1#3}

{Browse Xs}

%% Markov chain of first order: alternatives without specifying of propability 
{Pattern.markovChain_1 Xs unit(1:[2 3] 2:[1] 3:[2])}


%% determine predecessor and reduce domain of successor
{Nth Xs 2} = 1

{Nth Xs 3} = 3



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


{Pattern.forRanges [a b c d e f g] [1#2 3 5#7] proc {$ Xs} {Browse Xs} end}

{Pattern.mapRanges [a b c d e f g] [1#2 3 5#7] fun {$ Xs} Xs end}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



{Pattern.collectPM [a b c d e f] ['?' x x]}
%% [[b c]]

{Pattern.collectPM [a b c d e f] [x '?' '?' x]}
%% [[a d]]

{Pattern.collectPM [a b c d] [x '*' x]}
%% [[a b] [a c] [a d]]

{Pattern.collectPM [a b c d] [x '?' '*' x]}
%% [[a c] [a d]]

{Pattern.collectPM [a b c d] ['?' x '*' x]}
%% [[b c] [b d]]

{Pattern.collectPM [a b c d e f] ['?' '*' x '*' x x]}
%% [[b c d] [b d e] [b e f] [c d e] [c e f] [d e f]]


{Pattern.forPM [a b c d e] [x '?' x] proc {$ [X1 X2]} {Browse [X1 X2]} end}
%% -> [a c]
{Pattern.forPM [a b c d e] ['*' x '?' x] proc {$ [X1 X2]} {Browse [X1 X2]} end}
%% -> [a c] [b d] [c e]


{Pattern.mapPM [a b c d e] [x '?' x] fun {$ [X1 X2]} [X1 X2] end}
%% -> [[a c]]
{Pattern.mapPM [a b c d e] ['*' x '?' x] fun {$ [X1 X2]} [X1 X2] end}
%% -> [[a c] [b d] [c e]] 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
Xs = {FD.list 10 1#10}
EncodedMean = 15
Q = 10

{Browse unit(xs:Xs mean:EncodedMean)}

{Pattern.arithmeticMean Xs EncodedMean Q}

Xs.1 = 5

%%


declare
Xs = {FD.list 10 1#10}
EncodedMean = {FD.int 10#20}
Q = 10

{Browse unit(xs:Xs mean:EncodedMean)}

{Pattern.arithmeticMean Xs EncodedMean Q}

Xs.1 = 5

Xs = [5 1 1 1 1 1 1 1 1 3]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

{Pattern.everyNth [a b c d e f g h i] 2}

% -> [a c e g i]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%