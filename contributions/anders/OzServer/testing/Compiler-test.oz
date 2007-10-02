
declare
[Socket CustomCompiler]
= {ModuleLink ['x-ozlib://anders/strasheela/OzServer/source/Socket.ozf'
	       'x-ozlib://anders/strasheela/OzServer/source/Compiler.ozf']}

declare
%% !! running this example multiple times may cause system error as the port number is already used. In that case, just wait shortly until it is free again.
Port = 50001
ClientProxi
Client 
Results
MyCompiler


%% !! change browser to string mode
{Browser.object option(representation strings:true)}
%% browse receiving ports
% {Browse code#CodeReceiverStream}
{Browse result#Results}


ClientProxi = {Socket.makeServer localhost Port _/* Server */}
%% client must wait until server is ready
Client = {Socket.makeClient localhost Port}
Results = {Socket.readToStream Client 1024} 


MyCompiler = {CustomCompiler.makeFullCompiler}

%% connect compiler with ports
{CustomCompiler.feedAllInput MyCompiler ClientProxi unit(size:1024
							 resultFormat:oz)} 
{Browse ok}


%% tests: feed compiler

%% first feeds shows up, but does not cause any action (not even browsing defined in CallCompiler)

%% a statement
{Client write(vs:"{Browse 'it works!!'}")}

%% sequence of statements
{Client write(vs:"declare X=3")}

{Client write(vs:"{Browse X+3}")}


%% an expression
{Client write(vs:"%!expression\n1+2")}

%% !! BUG: first inspected value is _
{Client write(vs:"%!inspect\n1+2")}

{Client write(vs:"%!browse\n1+2")}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% these tests only work when the respective procs etc are exported
%%


%% set browser representation to string

{Comp.getHeader "%!expression\n1+2"} == "expression"

