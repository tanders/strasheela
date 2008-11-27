
%%
%% This file demonstrates MIDI file export facilities/features of
%% Strasheela. For simplicity, this is done with "precomposed" score
%% snippets.
%%
%% Note that these examples partly use
%% Out.midi.renderAndPlayMidiFile and partly
%% Fenv.renderAndPlayMidiFile. The latter is an extension of the
%% former which supports additional settings directly in the score
%% which are then exported into the MIDI file.
%%
%% Users can widely customise Strasheela file export. The examples
%% below show more basic usage. Further examples which extend or
%% overwrite the default output definition are shown in the files
%% ./ContinuousControllersInScore-MidiOutput.oz and
%% ./Microtonal-MIDI-examples.oz.
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Global definitions
%%
%% These definitions are used by multiple examples below -- always
%% feed these definitions first, then feed the examples paragraph-wise. 
%%

declare
[Fenv] = {ModuleLink ['x-ozlib://anders/strasheela/Fenv/Fenv.ozf']}
%% Create test score used by several examples below 
MyTestScore = {Score.makeScore
	       seq(items:[note(duration:2
			       pitch:60
			       amplitude:80)
			  note(duration:2
			       pitch:64
			       amplitude:60)
			  note(duration:2
			       pitch:67
			       amplitude:50)
			  note(duration:6
			       pitch:72
			       amplitude:100)
			 ]
		   startTime:0
		   timeUnit:beats(4))
	       unit}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Controlling where to save the result
%%

%% Basic usage: only the base name of the resulting files is
%% given. The default extensions are used (they should be OK in most
%% cases), and the default directory is either what you specified
%% (e.g., in your init file, and you can specified different
%% directories for different file types) or the system default /tmp/.
%%
%% For feedback where the files are stored check standard out (Oz
%% menu: Show/Hide: Emulator)
{Out.midi.renderAndPlayMidiFile MyTestScore
 unit(file:myTestScore)}


%% Explicitly specify all directories involved, just to make the
%% point. Please note that you can control independently where the
%% auxiliary *.csv files and the actual *.mid files are
%% stored. Remember that you can set these directories in your init
%% file.
{Out.midi.renderAndPlayMidiFile MyTestScore
 unit(file:myTest
      midiDir:'/tmp/'
      csvDir:'/tmp/')}

%% Specify the the destination (directory and file) with a file
%% dialog. Internally, the directories are simply appended in front of
%% the file name. Because the file dialog returns the full file name,
%% we need to set the directories involved to nil. You notice that
%% several directories are set to nil here, namely all directories
%% involved.
{Out.midi.renderAndPlayMidiFile MyTestScore
 unit(file:{Tk.return tk_getSaveFile}
      midiDir:nil
      csvDir:nil)}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Basic output settings 
%%

%% set playback tempo
{Init.setTempo 120.0}
{Out.midi.renderAndPlayMidiFile MyTestScore
 unit(file:myTestScore)}

%% MIDI header settings 
{Init.setTempo 60.0}
{Out.midi.renderAndPlayMidiFile MyTestScore
 unit(file:scoreWithHeader
      %% The first two MakeTitle etc arguments are Track (1 is header
      %% track) and Time (0 is start)
      headerEvents:[{Out.midi.makeTitle 1 0 "Opus Magnum"}
		    %% D major = 2 major (not really consistent with example above..)
		    {Out.midi.makeKeySignature 1 0 2 major}
		    %% corresponds to 3/8, see Out.midi.makeTimeSignature doc  
		    {Out.midi.makeTimeSignature 1 0 3 3 24 8}
		   ])}


%% Use MIDI note objects with channels specified per note
declare
MyScore = {Score.makeScore
	   seq(items:[note(duration:2
			   channel:0
			   pitch:60
			   amplitude:80)
		      note(duration:2
			   channel:1
			   pitch:64
			   amplitude:60)
		      note(duration:2
			   channel:2
			   pitch:67
			   amplitude:50)
		      note(duration:6
			   channel:3
			   pitch:72
			   amplitude:100)
		     ]
	       startTime:0
	       timeUnit:beats(4))
	   add(note:Out.midi.midiNote)}
{MyScore wait}
{Out.midi.renderAndPlayMidiFile MyScore
 unit(file:differentChannels)}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Expressive timing with time shift functions
%%

%% The first three notes are played slightly faster (performance time
%% shorter than score time), but the length of the whole score remains
%% exactly the same
{Init.setTempo 70.0} 
declare
MyScore = {Score.makeScore
	   seq(info:timeshift({Fenv.sinFenv [[0.0 0.0] [0.4 ~0.8] [1.0 0.0]]})
	       items:[note(duration:2
			   pitch:60
			   amplitude:80)
		      note(duration:2
			   pitch:64
			   amplitude:60)
		      note(duration:2
			   pitch:67
			   amplitude:50)
		      note(duration:6
			   pitch:72
			   amplitude:100)
		     ]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Out.midi.renderAndPlayMidiFile MyScore
 unit(file:timeshifted)}


%% For comparison, the example without the performance time
%% modification from above
{Init.setTempo 70.0}
{Out.midi.renderAndPlayMidiFile MyTestScore
 unit(file:myTestScore)}


%% The expressive performance is specified with a time shift fenv. A
%% fenv is an envelope defined by a numeric function. For each time
%% point in the score (e.g., the start of each note), the performance
%% time is computed by accessing the corresponding fenv value and
%% adding it to this score time point. Lets have a look at the
%% timeshift fenv of the example above (you need to have gnuplot
%% installed).
%%
%% At the x-axis, a fenv always ranges from 0.0 to 1.0, where 0.0
%% corresponds to the start time of a temporal item (the seq in the
%% example above) and 1.0 to its end. As the last note starts at
%% exactly the middle of this sequence (start time 6 of sequence
%% duration 12), the corresponding fenv x-value is 0.5.
%%
%% The fenv starts and ends with 0.0, therefore resulting performance
%% starts and ends at the score time. However, all other fenv y-values
%% are below 0.0 and are thus early. The curved shape of the fenv
%% results in smooth "tempo changes".
{{Fenv.sinFenv [[0.0 0.0] [0.3 ~0.5] [1.0 0.0]]}
 plot}


%% Time shift fenvs can be defined for each container in the score,
%% and they can be hierarchically nested. Also, time shift functions
%% are supported for any sound synthesis output (e.g., they can also
%% be used for Csound output).
declare
MyScore = {Score.makeScore
	   seq(info:timeshift({Fenv.scaleFenv
			       %% The tempo curve to time shift transformation is experimental..
			       {Fenv.tempoCurveToTimeShift 
				{Fenv.linearFenv [[0.0 2.0] [0.8 0.5] [1.0 1.0]]}
				0.01}
			       unit(mul:40.0)})
	       items:[seq(info:timeshift({Fenv.sinFenv [[0.0 0.0] [0.3 ~0.5] [1.0 0.0]]})
			  items:[note(duration:2
				      pitch:60
				      amplitude:80)
				 note(duration:2
				      pitch:64
				      amplitude:60)
				 note(duration:2
				      pitch:67
				      amplitude:50)
				 note(duration:6
				      pitch:72
				      amplitude:100)])
		      seq(info:timeshift({Fenv.sinFenv [[0.0 0.0] [0.3 ~0.5] [1.0 0.0]]})
			  items:[note(duration:2
				      pitch:60
				      amplitude:80)
				 note(duration:2
				      pitch:64
				      amplitude:60)
				 note(duration:2
				      pitch:67
				      amplitude:50)
				 note(duration:6
				      pitch:72
				      amplitude:100)])
		      seq(info:timeshift({Fenv.sinFenv [[0.0 0.0] [0.3 ~0.5] [1.0 0.0]]})
			  items:[note(duration:2
				      pitch:60
				      amplitude:80)
				 note(duration:2
				      pitch:64
				      amplitude:60)
				 note(duration:2
				      pitch:67
				      amplitude:50)
				 note(duration:6
				      pitch:72
				      amplitude:100)])
		      seq(info:timeshift({Fenv.sinFenv [[0.0 0.0] [0.3 ~0.5] [1.0 0.0]]})
			  items:[note(duration:2
				      pitch:60
				      amplitude:80)
				 note(duration:2
				      pitch:64
				      amplitude:60)
				 note(duration:2
				      pitch:67
				      amplitude:50)
				 note(duration:6
				      pitch:72
				      amplitude:100)])
		     ]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Out.midi.renderAndPlayMidiFile MyScore
 unit(file:timeshifted)}


%% Plotting top-level time shift fenv
{{Fenv.scaleFenv
  {Fenv.tempoCurveToTimeShift 
   {Fenv.linearFenv [[0.0 2.0] [0.8 0.5] [1.0 1.0]]}
   0.01}
  unit(mul:40.0)}
 plot}


%% Strasheela's fenvs support a wide range of techniques for creating
%% and modifying them. Check out their documentation and the examples
%% in their test file
%%
%% http://strasheela.sourceforge.net/strasheela/contributions/anders/Fenv/doc/node1.html
%% http://strasheela.sourceforge.net/strasheela/contributions/anders/Fenv/testing/Fenv-test.oz
%%
%% Here are only a few brief examples shown as plots. 

%% Concatenating two fenvs defined explicitly by numeric functions 
{{Fenv.fenvSeq
  [{New Fenv.fenv init(env:fun {$ X} {Sin X} end
		       min:0.0
		       max:GUtils.pi)}
   0.6
   {New Fenv.fenv init(env:fun {$ X} X end)}]}
 plot}

%% a linear envelope, defined by x/y-pairs
{{Fenv.linearFenv [[0.0 0.0] [0.7 1.0] [1.0 0.0]]}
 plot}

%% more complex fenvs, created by transforming fenvs

{{Fenv.rescaleFenv {Fenv.triangle 3 unit}
  unit(newmin:{Fenv.linearFenv [[0.0 0.1] [0.3 0.0] [1.0 0.6]]}
       newmax:{Fenv.linearFenv [[0.0 0.1] [0.3 1.0] [1.0 0.6]]})}
 plot}

{{Fenv.combineFenvs fun {$ Xs} {LUtils.accum Xs Number.'*'} end
  [{Fenv.linearFenv [[0.0 0.0] [0.3 1.0] [1.0 0.0]]}
   {Fenv.triangle 7 unit}]}
 plot}



%% BTW: if you want to create Nancarrow-like tempo canons and similar
%% forms, it is probably best to express note start times, durations
%% etc. directly in msec, instead of using timeshift functions (or
%% tempo curves) for post-processing the score. If the tempi are
%% expressed directly by the temporal parameters, then methods like
%% getSimultaneousItems work as expected.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Note: All remaining examples use Fenv.renderAndPlayMidiFile 
%%


%% TODO: set channel with info tag (either in single notes, or in a container)


%% Setting the program (info-tag to either to a note or a temporal
%% container). No MIDI channel defined (default is 0).
declare
MyScore = {Score.makeScore seq(info:[
				     test
				     program(64)
% 				     channel(0)
				    ]
			       items:[note(duration:2
					   pitch:60
					   amplitude:51)
				      note(duration:2
					   pitch:64
					   amplitude:58)
				      note(duration:2
					   pitch:67
					   amplitude:65)
				      note(duration:6
					   pitch:72
					   amplitude:80)]
			       startTime:0
			       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Fenv.renderAndPlayMidiFile MyScore
 unit}





%%
%% The following examples demonstrates how Strasheela fenvs can be
%% used as continuous controllers. Fenvs (function envelope) provide a
%% highly flexible means for expressing envelopes with numeric
%% functions (see the fenv documentation for details and its test file
%% for examples). The examples below show how score values are
%% generated from fenvs, how fenvs can be stored in the score
%% directly, and how MIDI output can use these fenvs in the score in
%% various ways.
%%
%% Strasheela predefines ready-to-use MIDI file export where
%% fenvs can be used for CC events, timeshift functions and tempo
%% curves. These examples demonstrate the ready-to-use MIDI export
%% facilities of Fenv.renderAndPlayMidiFile.
%%


%% TODO: Define and output continuous controllers (pitch bend, aftertouch, CC) for single notes or containers  


%% TODO: Define a global tempo curve 



