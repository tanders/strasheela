/*
SuperCollider Part of a Simple Realtime Music Constraint Programming Example 

The following code received OSC note messages from Strasheela and plays them. See Simple-RealTimeOut.oz for details.
*/

s.boot;

(
// dur measured in secs
SynthDef("Strasheela-playback", { arg dur=1, freq=440, amp=0.3; 
  var env = EnvGen.kr(Env.perc(0.05, dur-0.05, 1, -4), 1.0, doneAction: 2);
  Out.ar(0, RLPF.ar(Saw.ar(freq, amp*env), 1000, 0.03)) 
}).send(s);

// processing received OSC with delay
thisProcess.recvOSCfunc = { arg time, addr, msg; 
	if ( addr.port != 57110, // ignore scsynth messages
	{ var address, dur, pitch, amp;
	  // delay every note by given amount of sec to comprehend for Strasheela's computation time
	  var latency = 0.2; 
	  var delay = time - thisThread.seconds + latency; 
	  // !! only works for note messages of format ['\note', duration, pitch, amplitude]
	  // !!?? can I somehow use OSCresponder instead 
	  # address, dur, pitch, amp = msg;
	  SystemClock.sched( delay, 
	  	{ // posting for debugging 
	  	  ("playing note..." + "time:" + time + "delay:" + delay + "msg:" + msg).postln;
	  	  // transform dur from msec to secs
	  	  Synth("Strasheela-playback", [\dur, dur/1000, \freq, pitch.midicps, \amp, amp]);
	  	})};) 
}
)


/*
// a test note
Synth("Strasheela-playback", [\dur, 3, \freq, 72.midicps, \amp, 1]);
*/




////////////////////////////////////////////////////////////////////////////
//
// .. old tests etc
//

(
// always post whenever something is received (except from scsynth)
thisProcess.recvOSCfunc = { arg time, addr, msg; 
   if ( addr.port != 57110,  // ignore messages from the server
   { ["time: ", time, "addr:", addr,  "msg: ", msg].postln; } )
};
)

// !! TODO: starttime offset..
// either on sclang side or on scsynth side.. Actually, I would prefer the scsynth side.. But sclang side is more easy..


(
// the following is a collection of ideas, but does not work



option: create Synth with newPaused, and after delay send the synth message run

Synth("Strasheela-playback", [\dur, 3, \freq, 72.midicps, \amp, 1]).newMsg;


x = Synth.basicNew("Strasheela-playback")
x.newMsg;

x.set(\freq, 72.midicps)
x.getMsg(\freq)

)


