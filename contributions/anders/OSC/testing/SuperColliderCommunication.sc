



/////////////////////////////////////////////////////////////////////
///
/// connection between SuperCollider and Oz via OSC
///


// create responder and sender 







/////////////////////////////////////////////////////////////////////
///
/// old tests
///

/////////////////////////////////////////////////////////////////////
///
/// initial setup
///
/// Whenever Supercollider receives a OSC message on port 57120 it calls Main::recvOSCmessage
//// (for a bundle there is additionally Main recvOSCbundle)
///
/// so, to send something to SC from another application (e.g., sendOSC) on this port, you may hack the above methods and recompile the library
///

// or alternatively and even better: set thisProcess.recvOSCfunc
// now even with the suitable delay

(
thisProcess.recvOSCfunc = { arg time, addr, msg; 
	var delay = time - thisThread.seconds; ("delay = " ++ delay).postln; 	SystemClock.sched( delay, { [ "Process : ", msg ].postln })};
)


/*
// then I envoke send osc like so:
./sendOSC -h localhost 57120
/blah 1 2
*/


//
// OK, this works
//




////////////////////////////////////////////////////
///
/// 
///


// http://gersic.com/dspwiki/index.php?title=OSC_between_Max/MSP_and_SC3
// no NetAddr specified: should respond on all ports..  

OSCresponder(nil, '/goNOW', { | ... args | args.postln; }).add;


OSCresponder(nil, nil, { | ... args | args.postln; }).add;


//
// This works:  
// see also http://www.create.ucsb.edu/pipermail/sc-users/2006-July/026784.html
//


o = OSCresponder(nil, "/test", {|... args| args.postln})
o.add

/*
// in shell do

$ sendOSC -h localhost 57120
/test

*/


////////////////////////////////////////////////////
///
/// talk to Oz via TCP 
///

// create client
~ip = "127.0.0.1";
//~port = 57120;
~port = 1234;
~socket = NetAddr( ~ip, ~port ).connect; // connect opens TCP socket


// send messages
~socket.sendMsg( '/code', "sendMsg 1: this is a test");

~socket.sendMsg("sendMsg 2: this is a test");


// sendRaw is indeed my plain socket!
~socket.sendRaw("sendRaw: this is a test");

// sendRaw is indeed my plain socket!
// Numbers are complexly encoded -- I may betetr send only numbers in strings for now 
~socket.sendMsg('/test', 1.2);



// receive messages
o = OSCresponder(~socket, '/chat', { |t, r, msg| ("time:" + t).postln; msg[1].postln }).add;


p = OSCresponder(~socket, '/sc', { |t, r, msg| msg[1].postln }).add;



////////////////

// test how it should look like
~socket.sendMsg("/chat", "Hello App 1");




/////////////////////////////////////////////////////////////////////
///
/// use sendOSC and dumpOSC
///
/// these always use UDP
///


//
// problem: no reaction of SC whatsoever
//

/*

http://www.create.ucsb.edu/pipermail/sc-users/2003-June/004147.html

!! you can't create a OSCresponder for sendOSC


Since SCLang uses port 57120, only SCLang from <yout IP> can send 
OSCMessage to this OSCresponder.

*/


// set up connection 

x = OSCresponder(NetAddr("localhost", 57120 ), '/blah', { | ... args |  args.postln; }).add; 


/*
// then I envoke send osc like so:
./sendOSC -h localhost 57120
/blah 1 2
*/


////////////////////


// set up connection 

n = NetAddr("127.0.0.1", 1234); 

o = OSCresponder(n, '/chat', { |t, r, msg| ("time:" + t).postln; msg[1].postln }).add;


/*
now call sendOSC on the same machine as follows:

> ./sendOSC -h "127.0.0.1" 1234
/chat "hi supercollider" 3.14159 foo bar
*/





////////////////////////////////////////////////////
///
/// dumpOSC 
///


// set up connection 
n = NetAddr("localhost", 1234); 

/*
now call sendOSC on the same machine as follows:


> ./dumpOSC 1234
*/

// then send something

n.sendMsg( '/code', "sendMsg 1: this is a test");



//
// 
//



////////////////////////////////////////////////////
///
/// Client listening to sendOSC -- does not work either
///

(
// port is hardcoded to 57120
~myClient = LocalClient(\default, nil);
~myClient.verbose = true;
~myClient.start; 
ClientFunc(\ok, { arg ... args; args.postln });
)

/*
// On command line do
./sendOSC -h localhost 57120

\ok 2.0 3.14159 
*/





