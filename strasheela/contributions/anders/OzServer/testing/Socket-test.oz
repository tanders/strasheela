
declare
[Socket] = {ModuleLink ['x-ozlib://anders/strasheela/OzServer/source/Socket.ozf']}

declare
Port = 50001
MyServer 
MyClientProxi
{Socket.makeServer localhost Port MyServer MyClientProxi}


declare
MyClient = {Socket.makeClient localhost Port}

declare
Xs = {Socket.readToStream MyClientProxi 1024}
{Browse Xs}

%% set Browser representation string

{MyClient write(vs:"this is a test")}


%%
%% communication the other way
%%

declare
Ys = {Socket.readToStream MyClient 1024}
{Browse Ys}

{MyClientProxi write(vs:"hi client")}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% BUG
%%

%% !! Bug: multiple writes shortly after each other: these are 'appended' to in a single value (VS) in the output stream 
{ForAll [hi there]
 proc {$ X} {MyClient write(vs:X)} end}




