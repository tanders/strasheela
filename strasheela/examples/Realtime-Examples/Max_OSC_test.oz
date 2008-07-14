
%%
%% This test/example works together with the Max patch ./Max_OSC_test.pat
%%


declare

[OSC] = {ModuleLink ['x-ozlib://anders/strasheela/OSC/OSC.ozf']}

OutPort = 8888			% to Max, port set in [udpreceive]
InPort = 7777



%%
%% OSC interface
%%

MySendOSC = {New OSC.sendOSC init(port:OutPort)}
MyDumpOSC = {New OSC.dumpOSC init(port:InPort)}


%% every /event OSC message calls this procedure
{MyDumpOSC setResponder('/event' proc {$ _ /*TimeTag*/ Msg}
				    %% browse this message and send some dummy test message back
				    {Browse osc_input#Msg}
				    {MySendOSC send('/test'(42))}
				 end)}




/* % test sending 

%% works
{MySendOSC send('/test'(42 3.41 "test string" atom))}

%% Works. And also the order of events seems to be fine
{MySendOSC send([a b c d e f g h])}

*/



