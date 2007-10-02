
declare
[OSC] = {Module.apply [OSCF]}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Communication between Oz and SuperCollider via OSC
%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% old tests
%%

/*

declare
[Socket] = {ModuleLink ['x-ozlib://anders/strasheela/OzServer/source/Socket.ozf']}

%%
%% create a TCP socket server 
%%

declare
%% Port = 57120		
Port = 1234			
MyClientProxi = {Socket.makeServer localhost Port _ /* Server */}


%%
%% now, in SuperCollider connect client 
%%


%%
%% listen to incoming OSC messages
%%

declare
Xs = {Socket.readToStream MyClientProxi 1024}

{Inspect Xs}

% thread for X in Xs do {Browse {String.toAtom X}} end end 
% {Browse Xs}

%%
%% Send messages back
%%
%% corresponds to bla.sendMsg("/chat", "Hello App 1");
{MyClientProxi write(vs:{VirtualString.toString
			 [0 0 0 24]#"/chat"#[0 0 0]#",s"#[0 0]#"Hello App 1"#[0]})}

%% also OK (hopefully more efficient??)
{MyClientProxi write(vs:{ByteString.make
			 [0 0 0 24]#"/chat"#[0 0 0]#",s"#[0 0]#"Hello App 1"#[0]})}

%% !! does not work -- I need to understand how OSC messages are written
{MyClientProxi write(http://www.mozart-oz.org/documentation/base/time.html#section.control.timevs:{VirtualString.toString
			 [0 0 0 24]#"/sc"#[0 0 0]#",s"#[0 0]#"this is a test"#[0]})}




%%
%% what is the format of OSC messages? Do they always start with three 0-chars??
%%

%%
%% OSC message format [try not to do reverse engeneering..]
%%
%% http://www.cnmat.berkeley.edu/OpenSoundControl/OSC-spec.html
%% 


%% before and after every [symbol] in message go 3 zero bytes
%% write comma between messages as ",s" followed by two 3 bytes

%% it seems I need to do padding zeros -- the number of zero bytes changes between different messages!


{Browse }

\000 

{VirtualString.toString [0 0 0]}


*/
