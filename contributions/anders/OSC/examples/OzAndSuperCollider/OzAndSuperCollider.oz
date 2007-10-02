
declare
[OSC] = {ModuleLink ['x-ozlib://anders/strasheela/OSC/OSC.ozf']}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% SuperCollider -> Oz OSC input -> process -> Oz OSC input -> SuperCollider
%%%

%% Use this example together with the SuperCollider example with the
%% same name in this directory.


declare
SuperColliderPort = 57120
OzPort = 7777
%% create dumpOSC and sendOSC interface with same port
MyDumpOSC = {New OSC.dumpOSC init(port:OzPort)}
%% default host is localhost..
MySendOSC = {New OSC.sendOSC init(port:SuperColliderPort)}
%% show strings in browser
{Browser.object option(representation strings:true)}
%% browse stream of all OSC packets received
{Browse {MyDumpOSC getOSCs($)}}


%% whenever a message with address '/note' is send, then it has the
%% following parameters: startTime, duration, pitch, amplitude (all
%% floats)
%%
%% Transpose each note by a whole tone upwards and send it back to
%% SuperCollider
{MyDumpOSC addResponder('/note' proc {$ Timetag Msg}
				   {Browse Timetag#Msg} % debugging..
				   case Msg of '/note'(Start Dur Pitch Amp) then
				      {MySendOSC send({Adjoin Msg '/note'(3:Pitch + 2.0)})}
				   end
				end)}

%% when a message with address /timetest is received, send it back as a bundle by adding its first argument to the time now.
{MyDumpOSC addResponder('/timetest' proc {$ Timetag Msg}
				       {Browse receivedTimetest(Msg)}
				       {MySendOSC send([{OSC.timeNow}+Msg.1 Msg])}
				    end)}

%% when a bundle is received, send it back by added a message: \from("Strasheela") to the bundle
{MyDumpOSC setBundleResponder(proc {$ TimeT | Packets}
				 {Browse receivedBunde(TimeT | Packets)}
				 {MySendOSC send(TimeT | '/from'("Strasheela") | Packets)}
			      end)}

%% NOTE: sending in '/sendEvents' seems note to work
local
   MyBuffer = {New OSC.buffer init}
in
   %% Whenever Strasheela receives a message with address '/event' it buffers it. When it receives a message '/sendEvents', it sends all notes received so far back in a bundle. 
   {MyDumpOSC addResponder('/event' proc {$ Timetag Msg}
				       {MyBuffer put(Msg)}
				       {Browse put#Msg}
				   end)}
   {MyDumpOSC addResponder('/sendEvents' proc {$ Timetag _ /* Ignore */}
					    Xs = {MyBuffer getAll($)}
					 in
					    {MySendOSC send(Xs)}
					    {Browse Xs}
					end)}
end




