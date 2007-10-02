/*
SuperCollider -> Oz OSC input -> process -> Oz OSC input -> SuperCollider

Use this example together with the Strasheela example with the same name in this directory. 
*/

// Sending 

(
//~host = "127.0.0.1";
~strasheelaPort = 7777;
~strasheelaSocket = NetAddr( "localhost", ~strasheelaPort );
)

~strasheelaSocket.sendMsg('/test', 3.14, 42, "this is a string")


// !! Strasheela receives only the integer part (but as float) 
~strasheelaSocket.sendMsg('/test', thisThread.seconds)


(
// workaround: send amound before and after period independently
// NB: Strasheela receives both numbers as floats
x = thisThread.seconds;
y = x.floor;
~strasheelaSocket.sendMsg('/test', y, x-y) 
)


// Whenever Strasheela receives a note, it sends it back transposed a whole 
// tone upwards.
// Note parameters: startTime, duration, pitch, amplitude (all floats)
~strasheelaSocket.sendMsg('/note', 1.0, 10.0, 60.0, 0.5)

// send note in bundle
// BUG in Supercollider or Strasheela: note responder does not reply 
// in OSC stream, only the timetag is received
~strasheelaSocket.sendBundle(1.0, ['/note', 1.0, 10.0, 60.0, 0.5])

// Whenever Strasheela receives a message with address /timetest, then it expects its first parameter to be a time (msecs by which the msg should be delayed). It sends the message back immediately as a bundle with a corresponding timetag. 
//~strasheelaSocket.sendMsg('/event', 1000)
//~strasheelaSocket.sendMsg('/timetest', 1000)
~strasheelaSocket.sendMsg('/timetest', 200, "test string")
~strasheelaSocket.sendMsg('/timetest', 1000, "this is a test")

~strasheelaSocket.sendMsg('/timetest', 0, "this is a test")


// Strasheela adds a message to each bundle
~strasheelaSocket.sendBundle(0.0, ["/good/news", "blaumilch", 42]);

~strasheelaSocket.sendBundle(0.2, ["/good/news", "blaumilch", 42]);

//  Whenever Strasheela receives a message with address '/event' it buffers it. 
// When it receives a message '/sendEvents', then it sends all notes received so far 
// back in a bundle. 
// NOTE: seems not to work
~strasheelaSocket.sendMsg('/event', 3.14)
~strasheelaSocket.sendMsg('/event', "this is a test", 42)
~strasheelaSocket.sendMsg('/event', \foo, \bar)
~strasheelaSocket.sendMsg('/sendEvents')


// Receiving 

///
/// Whenever Supercollider receives a OSC message on port 57120 it calls the 
/// function thisProcess.recvOSCfunc set below. 
/// (for a bundle there is additionally Main recvOSCbundle)
///
/// NB: this function is also called whenever SC receives something from scsynth. 
///

(
// always post whenever something is received (except from scsynth)
thisProcess.recvOSCfunc = { arg time, addr, msg; 
   if ( addr.port != 57110,  // ignore messages from the server
   { ["time: ", time, "offset: ",  time-thisThread.seconds, "addr:", addr,  "msg: ", msg].postln; } )
};
// ("Logical time:" + thisThread.seconds + "  Physical time:" + Process.elapsedTime).postln;
)

(
// processing received OSC with delay
thisProcess.recvOSCfunc = { arg time, addr, msg; 
	var delay;
	if ( addr.port != 57110, 
	{ delay = time - thisThread.seconds; 
	  ("delay = " ++ delay).postln; 	
	  SystemClock.sched( delay, { [ "Delayed msg : ", msg ].postln })};) 
}
)

// TODO: receive and process bundles 


