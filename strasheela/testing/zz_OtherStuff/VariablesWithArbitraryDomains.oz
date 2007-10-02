
%% This is only proof of concept: you can do CSP with universal domains in Oz. Even the benefits of the space-based constraint model such as user-defined dynamic variable and value ordering are retained.
%% Still, performance with suffer greatly due to missing propagation.
%%


declare
MyName = {NewName}
functor ArbitraryDomain
export
   make:MakeVariable
   IsVar
   isDet:IsDetVar
   GetVal
   GetDom
   Add 
   number: NumberP float: FloatP int: IntP
   Distribute
define
   %% internal variable representation var(value:X domain:Xs)
   fun {MakeVariable Domain}
      MyName(value:_ domain:{NewCell Domain})
   end
   fun {IsVar X}
      {IsRecord X} andthen {Label X}==MyName
   end
   fun {IsDetVar Var}
      {IsDet Var.value}
   end
   fun {GetVal Var}
      Var.value
   end
   fun {GetDom Var}
      @(Var.domain)
   end
   proc {SetDom Var Xs}
      (Var.domain) := Xs
   end
   %% Demo constraint
   proc {Add X Y Z}
      A = if {IsVar X} then {GetVal X} else X end
      B = if {IsVar Y} then {GetVal Y} else Y end
      C = if {IsVar Z} then {GetVal Z} else Z end
   in
      %% each constraint runs in its own thread
      thread A + B = C end
   end   
   %% MakePropagator abstract propagator creation: MakePropagator expects a procedure, and returns the propagator proc which expects its arguments in a list.
   %% This approach allows for easy propagator creation in the CSP or for automatic creation of a large number of propagators at once (e.g. )
   fun {MakePropagator P}
%      N = {Procedure.arity P}
%   in
      %% to automatically create a propagator where the number of args equals {Procedure.arity P} I better wait for macros..
      proc {$ Xs}
	 thread
	    {Procedure.apply P
	     {Map Xs fun {$ X} if {IsVar X} then {GetVal X} else X end end}}
	 end
      end
   end
   %% All procs in Number have their equivalent propagator in
   %% NumberP (only the propagator expects its args in a
   %% list)
   NumberP = {Record.map Number MakePropagator}
   FloatP = {Record.map Float MakePropagator}
   IntP = {Record.map Int MakePropagator}
   %%
   proc {Distribute Order Value Xs}
      {Space.waitStable}
      local Vars={Filter Xs fun {$ X} {Not {IsDetVar X}} end}
      in
	 if Vars \= nil
	 then
	    %% !! tmp: sort does too much
	    Var = {Sort Vars Order}.1
	    N = {Value Var}
	 in
	    choice {GetVal Var}=N {SetDom Var nil}
	    [] {SetDom Var {Filter {GetDom Var} fun {$ X} {Not X==N} end}}
	    end
	    {Distribute Order Value Vars}
	 end
      end
   end 
end
[AD]={Module.apply [ArbitraryDomain]}

%% demo CSP 
{ExploreOne proc{$ Sol}
	       A = {AD.make [~1.0 ~0.5 0.0 0.5 1.0 1.5 2.0 2.5 3.0]}
	       B = {AD.make [~1.0 ~0.5 0.0 0.5 1.0 1.5 2.0 2.5 3.0]}
	    in
	       %% define some Explorer information action to look inside the var domain..
	       Sol = [A B]
	       %% Constraint
	       {AD.add A B 2.0}
	       %% naive distribution
	       {AD.distribute
		fun {$ Var1 Var2} true end
		fun {$ Var} {AD.getDom Var}.1 end
		[A B]}
	    end}


%% variant with AD.number.'+'
{ExploreOne proc{$ Sol}
	       A = {AD.make [~1.0 ~0.5 0.0 0.5 1.0 1.5 2.0 2.5 3.0]}
	       B = {AD.make [~1.0 ~0.5 0.0 0.5 1.0 1.5 2.0 2.5 3.0]}
	    in
	       %% define some Explorer information action to look inside the var domain..
	       Sol = [A B]
	       %% Constraint
	       {AD.number.'+' [A B 2.0]}
	       %% naive distribution
	       {AD.distribute
		fun {$ Var1 Var2} true end
		fun {$ Var} {AD.getDom Var}.1 end
		[A B]}
	    end}


%% TODO: define a more complex CSP for floats using the propagators in AD.number and AD.float ...
%% To repeat fundamental problem of this approach: domain for float constraints like sin or log has often to be ridiculously large because the exact result must be in domain



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
/** %% Creates a number of choice points: in each choice point X is unified to another value in Dom (a list).
%% */
proc {MakeDomain Dom X}
   {Combinator.'choice' {List.toTuple unit
			 {Map Dom
			  fun {$ DomVal}
			     proc {$} X=DomVal end
			  end}}}
end
proc {MyAppend X Y Z}
   or X=nil Y=Z
   [] Xs Zs Aux in
      X=Aux|Xs Z=Aux|Zs {MyAppend Xs Y Zs}
   end
end
% proc {Distributor unit(order:Ord value:Val) Xs}
%    {Space.waitStable}
%    local Vars={Filter Xs fun {$ X} {Not {IsDet X}} end}
%    in
%       if Vars \= nil
%       then
% 	 Var = {Order Vars Ord}.1
% 	 %% !! I can not access the domain of a variable
% 	 N = {Val Var}
%       in choice Var=N [] Var\=N end
% 	 {MyDistributor unit(order:Ord value:Val) Vars}
%       end
%    end
% end 

%% list domain
{Browse {SearchAll proc{$ Sol}
		      A B
		   in
		      Sol=A#B
		      %% domain of A is set {nil, [a], [a b], [a b c]}
		      A = {MakeDomain [nil [a] [a b] [a b c]]} 
		      B = {MakeDomain [nil [c] [b c] [a b c]]}
		      {MyAppend A B [a b c]}
		      %% !!?? distro strategy?
		   end}}

%% float domain
{Browse {SearchAll proc{$ Sol}
		      A B
		   in
		      Sol=A#B
		      A = {MakeDomain [~1.0 ~0.5 0.0 0.5 1.0 1.5 2.0 2.5 3.0]} 
		      B = {MakeDomain [~1.0 ~0.5 0.0 0.5 1.0 1.5 2.0 2.5 3.0]}
		      A + B = 2.0
		      %% !!?? distro strategy?
		   end}}

{ExploreAll proc{$ Sol}
	       A B
	    in
	       Sol=A#B
	       A = {MakeDomain [~1.0 ~0.5 0.0 0.5 1.0 1.5 2.0 2.5 3.0]} 
	       B = {MakeDomain [~1.0 ~0.5 0.0 0.5 1.0 1.5 2.0 2.5 3.0]}
	       A + B = 2.0
	       %% !!?? distro strategy?
	    end}
