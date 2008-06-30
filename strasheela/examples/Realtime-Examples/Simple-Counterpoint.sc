/*
SuperCollider Part of a Simple Realtime Counterpoint Example 

The following code received OSC note messages from Strasheela and plays them. See Simple-Counterpoint.oz for details.

USAGE: First feed corresponding Strasheela code in Simple-Counterpoint.oz (see USAGE there), then start SuperCollider server, then evaluate large code block for sending and receiving, finally start playback in SC.

*/

s.boot;


(

// latency of all notes
// when this latency is not enough, scsyth reports late notes: just increase the latency..
~latency = 0.035  ; // in secs

// network settings
~outPort = 7777;
~mySendOSC = NetAddr("localhost", ~outPort);


// Patterns for "cantus firmus" generation
~tempoFactor = 0.6;
// tempoFactor = 0.05; // some stress test...
// MIDI key-numbers (ints)
// pitches = Pseq([60, 63, 67], inf).asStream; 
~pitches = Pwalk(
			 // pitches in C major from g to c over 1 1/2 octaves
			 [55, 57, 59, 60, 62, 64, 65, 67, 69, 71, 72],
			 // steps up to 3 in either direction, but no repetition, and weighted toward positive
			 Pwrand([-3, -2, -1, 1, 2, 3], [0.02, 0.05, 0.4, 0.4, 0.1, 0.03], inf),
		      // reverse direction at boundaries
	           1,
	           3	// start at tonic
		   ).asStream;
// some triple meter ..
~durs = Prand([Pseq([2.0, 1.0]), Pseq([1.0, 1.0, 1.0]), 3.0], inf).asStream; // in  secs (floats)
~amps = 64.asStream; // MIDI velocities (ints)


// the synth def
// dur measured in secs, freq in Hz, amp in interval [0,1], ffreq in Hz, pan in interval [-1,1]
SynthDef("Strasheela-playback", { arg dur=1, freq=440, amp=0.3, ffreq=1000, pan=0; 
  var env = EnvGen.kr(Env.perc(0.05, dur-0.05, 1, -2), 1.0, doneAction: 2);
  Out.ar(0, Pan2.ar(RLPF.ar(Saw.ar(freq, amp*env), ffreq, 0.1), pan, 0.3)) 
}).send(s);


// receiving and playback of Strasheela notes
thisProcess.recvOSCfunc = { arg time, addr, msg; 
	if ( addr.port != 57110, // ignore scsynth messages
	{ // time is logical time (secs), dur is measured in secs, pitch is MIDI key-number, amp is MIDI velocity
	  var address, dur, pitch, amp;
	  // !! only works for note messages of format ['\note', duration, pitch, amplitude]
	  # address, dur, pitch, amp = msg;
	  // posting for debugging 
	  // ("playing received note: time: " + time + "msg: " + msg).postln;
	  // let scsynth do scheduling
	  s.makeBundle(time-thisThread.seconds,
	       {Synth("Strasheela-playback", [\dur, dur, \freq, pitch.midicps, \amp, amp/127, \ffreq, 2000, \pan, -0.9]);});
	  // schedule the playback of note messages with sclang
//	  SystemClock.schedAbs( start1+start2,  
//	  	{ Synth("Strasheela-playback", [\dur, dur, \freq, pitch.midicps, \amp, amp/127, \ffreq, 2000]);}
//       )
	  };) 
};


// "Cantus firmus" generation, note sending to Strasheela, playback of "cantus firmus".
~myRoutine = Routine.new({
	inf.do({ arg i;
		var dur, pitch, amp;
		dur = ~durs.next * ~tempoFactor;				
		amp = ~amps.next;
		pitch = ~pitches.next;
		// debugging
	  	// ("playing generated note at" + start + ", now:" + thisThread.seconds).postln;
		/* Send OSC bundles at timetag ~latency in format ['/note', duration, pitch, amplitude]. All note parameters must be integers. Duration is measured in msecs, Pitch is MIDI key-number, and Amplitude is MIDI velocity. */
		~mySendOSC.sendBundle(~latency, ['/note', (dur*1000).asInt, pitch, amp]);		// let scsynth do scheduling
	  	s.makeBundle(~latency,
	       {Synth("Strasheela-playback", [\dur, dur, \freq, pitch.midicps, \amp, amp/127, \ffreq, 500, \pan, 0.9]);});
	       //  sclang scheduling 
//		SystemClock.schedAbs( start,  
//	  	  { Synth("Strasheela-playback", [\dur, dur, \freq, pitch.midicps, \amp, amp/127, \ffreq, 500]); });
		dur.wait;
	});
	"done".postln;
});
)

// start playback 
SystemClock.play(~myRoutine);
 	





/////////////////////////////////////////////////
///
/// testing
///
///


/*
// test pitch pattern

200.do({ ~pitches.next.post; ", ".post });
*/

/*
// play test notes

Synth("Strasheela-playback", [\dur, 3, \freq, 72.midicps, \amp, 1, \ffreq, 2000]);
Synth("Strasheela-playback", [\dur, 3, \freq, 72.midicps, \amp, 1, \ffreq, 500]);
*/

