
%%
%% This file demonstrates the MIDI file export facilities of
%% Strasheela. Note that these examples partly use
%% Out.midi.renderAndPlayMidiFile and partly
%% Fenv.renderAndPlayMidiFile. The latter is an extension of the
%% former which supports additional settings directly in the score
%% which are then exported into the MIDI file.
%%

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
      %% The first two MakeTitle etc arguments are Track (1 is header track) and Time (0 is start) 
      headerEvents:[{Out.midi.makeTitle 1 0 "Opus Magnum"}
		    %% D major = 2 major (not really consistent with example above..)
		    {Out.midi.makeKeySignature 1 0 2 major}
		    %% corresponds to 3/8, see Out.midi.makeTimeSignature doc  
		    {Out.midi.makeTimeSignature 1 0 3 3 24 8}
		   ])}


%% Use MIDI note objects with channels specified
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


%% TODO: Control timing with timeshift functions 




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% All remaining examples use Fenv.renderAndPlayMidiFile 
%%


%% set channel with info tag (either in single notes, or in a container)


%% Setting the program (info-tag to either to a note or a temporal container). No MIDI channel defined (default is 0).
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



