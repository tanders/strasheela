
declare
[Socket] = {ModuleLink ['x-ozlib://anders/strasheela/OzServer/source/Socket.ozf']}



%% first start OzServer.exe on commandline

%% then evaluate the statements below one by one

declare
Port = 50000
% Port = 5001
Client 
Results


%% !! change browser to string mode
{Browser.object option(representation strings:true)}
{Browse result#Results}

Client = {Socket.makeClient localhost Port}
Results = {Socket.readToStream Client 1024}

%% a statement
{Client write(vs:"{Browse 'it works!!'}")}

%% sequence of statements
{Client write(vs:"declare X=3")}

{Client write(vs:"{Browse X+3}")}


%% an expression
%%
%% !! Bug: if re-evaluated, only _ is returned! 
{Client write(vs:"%!expression\n1+2")}

{Client write(vs:"%!expression
	      X+4")}

%% !! Bug: multiple expressions fed almost at the same time: the results are appended in a single value n the Results stream
{Client write(vs:"%!expression
	      hi")}
{Client write(vs:"%!expression
	      there")}


%%
%% test that multiple expressions are always output in the correct order (although the compiler processes them concurrently)
%% Bug: if multiple results are output which were computed concurrently, then both results are written into a single value (VS) of the socket output
%%

/*
declare
/** %% Ackermann functions takes some time to evaluate...
%% */
fun {Ack M N}
   if M==0 then N+1
   elseif N==0 then {Ack (M-1) 1}
   else {Ack (M-1) {Ack M (N-1)}}
   end
end

%% takes a reasonable while..
{Ack 3 12}
*/

{Client write(vs:"declare
fun {Ack M N}
   if M==0 then N+1
   elseif N==0 then {Ack (M-1) 1}
   else {Ack (M-1) {Ack M (N-1)}}
   end
end")}

{Client write(vs:"%!expression
	      {Value.toVirtualString unit(1 {Ack 3 12}) 1000 1000}")}

{Client write(vs:"%!expression
	      {Value.toVirtualString unit(2 hi) 1000 1000}")}



%% show writes to standard out (i.e. the shell on which the OzServer was started)
{Client write(vs:"{Show 'hi there'}")}


%% other 'modes'
{Client write(vs:"%!inspect\n1+2")}

{Client write(vs:"%!browse\n1+2")}



%%
%% testing a few error cases: all are reported in compiler panel
%%

%% Ozcode which causes syntax error  
{Client write(vs:"hi")}

%% Ozcode with static analysis error  
{Client write(vs:"{Browse hi there}")}

%% type error 
{Client write(vs:"{Browse 1 / 0}")}

%% binding analysis error 
{Client write(vs:"{Browse MyNewVar}")}

%% !!?? after an error in an expression, expression results are not shown any more (the socket/port is blocked, waiting for the value which gets never writting).
{Client write(vs:"%!expression\n1+2")}


%% a long statement: this only works with a size > 1024 (the default)
{Client write(vs:"declare
MyName = {NewName}
functor ArbitraryDomain
export
   make:MakeVariable
   IsVar
   isDet:IsDetVar
   GetVal
   GetDom
   Add
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
   %%
   proc {Distribute Order Value Xs}
      {Space.waitStable}
      local Vars={Filter Xs fun {$ X} {Not {IsDetVar X}} end}
      in
	 if Vars \\= nil
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
[AD]={Module.apply [ArbitraryDomain]}")}

