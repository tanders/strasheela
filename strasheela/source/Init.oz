
%%% *************************************************************
%%% Copyright (C) 2003-2005 Torsten Anders (t.anders@qub.ac.uk) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** % This functor allows to customise a few settings: change to stateful which can be adjusted in, e.g., .ozrc
% */

functor
import
   Browser(browse:Browse)
   Inspector(inspect:Inspect)
   Pickle Explorer Error Resolve
   Strasheela at '../Strasheela.ozf'
   GUtils at 'GeneralUtils.ozf'
   Score at 'ScoreCore.ozf'
   Out at 'Output.ozf'

   %% !! dependency on extension!
   ScoreInspector at 'x-ozlib://anders/strasheela/ScoreInspector/ScoreInspector.ozf'
%    HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
%    Motif at 'x-ozlib://anders/strasheela/Motif/Motif.ozf'
%    Measure at 'x-ozlib://anders/strasheela/Measure/Measure.ozf'
%    CTT at 'x-ozlib://anders/strasheela/ConstrainTimingTree/ConstrainTimingTree.ozf'
%    Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   

require
   OS
   %% !! tmp
   Path at 'x-ozlib://anders/tmp/Path/Path.ozf'
   
prepare
   %% NB: functor must be re-compiled whenever it is moved in the file system or to another machine
   /** %% The top-level directory of the Strasheela sources (i.e., where the sources have been compiled) as string. 
   %% */
   StrasheelaSourceDir = {Path.dirname {OS.getCWD}}
%   StrasheelaDir = {Path.dirname {OS.getCWD}}
   
export
   %PATH
   %Csound Sndplay Lilypond PdfViewer SendOSC
   %DefaultSScoDir
   %DefaultCsoundOrcDir DefaultCsoundScoDir DefaultSoundDir
   %DefaultOrcFile DefaultCsoundFlags
   %DefaultLilypondDir DefaultSuperColliderDir
   GetStrasheelaEnv PutStrasheelaEnv GetFullStrasheelaEnv SetFullStrasheelaEnv
   SaveStrasheelaEnv LoadStrasheelaEnv
   GetBeatDuration SetBeatDuration GetTempo SetTempo
   AddExplorerOuts_Standard AddExplorerOuts_Extended
%   StrasheelaDir
   StrasheelaSourceDir StrasheelaInstallDir
   
define

   /** %% The top-level directory of the Strasheela installation (i.e. the full local pathname of 'x-ozlib://anders/strasheela/') as atom. 
   %% */
   StrasheelaInstallDir = {Resolve.localize 'x-ozlib://anders/strasheela/'}.1
   
   %% $PATH environment var: seems I need to do {OS.putEnv 'PATH' Init.pATH} on MacOS
   %%
   % PATH = '/Users/t/bin/:/usr/local/bin/:/Users/t/.oz/bin:/usr/local/oz/bin:/sw/bin:/sw/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin'
   % PATH = '/usr/java/jdk1.3.1_08/bin:/usr/local/plt/bin:/home/t/oz/mozart-install/bin:/home/t/.oz/bin:/home/t/scripte:/usr/lib/mozart/bin:/usr/java/jdk1.3.1_08/bin:/usr/local/plt/bin:/home/t/oz/mozart-install/bin:/home/t/.oz/bin:/home/t/scripte:/usr/lib/mozart/bin:/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin:/home/t/bin'
   
   %% Please adjust pathes here, if necessary. The (re-)compile the SDL by executing the script in <SDL-dir>/scripts/make-SDL
   %%
   %% !! temp: absolute paths ($PATH of shell forked by
   %% Oz  not bound be .profile on Mac)
   %% Csound = '/usr/local/bin/csound' % csound
   %% Sndplay = '/usr/local/bin/sndplay' % sndplay % sweep 
   %% Lilypond = '/sw/bin/lilypond' %lilypond
   % PdfViewer = '/Applications/Preview.app/Contents/MacOS/Preview'  % gv
   % SendOSC = '/Users/t/Desktop/OSC/sendOSCFolder/sendOSC'
   %Csound = csound
   %Sndplay = sndplay 
   %Sndplay = sweep 
   %Lilypond = lilypond
   %PdfViewer = '/Applications/Preview.app/Contents/MacOS/Preview'  % gv
   %PdfViewer = gv
   %SendOSC = sendOSC

   %DefaultCsoundOrcDir = '/home/t/csound/SDL-demo/'
   %DefaultCsoundScoDir = '/home/t/tmp/'
   %DefaultSoundDir = '/home/t/tmp/'
   %DefaultLilypondDir = '/home/t/tmp/'
   %TmpDir = '/tmp/'
   %TmpDir = '/Users/t/tmp/'
   %TmpDir = '/home/t/sound/tmp/'
   %DefaultCsoundOrcDir = '/Users/t/csound/SDL-demo/'
   %DefaultSScoDir = TmpDir
   %DefaultCsoundOrcDir = '/home/t/csound/SDL-demo/'
   %DefaultCsoundScoDir = TmpDir
   %DefaultSoundDir = TmpDir 
   % SFDIR = '/Users/t/tmp/'
   %DefaultLilypondDir = TmpDir
   %DefaultSuperColliderDir = TmpDir 

   %DefaultOrcFile = 'pluck.orc'
   %DefaultOrcFile = 'simple-organ.orc'
   %DefaultCsoundFlags = ['-A' '-g']
   %DefaultCsoundFlags = ['-A']

   local
      Dict = {NewCell
	      {Record.toDictionary
	       unit(%% apps
		    csound:csound
		    sndPlayer:nil % audacity
		    %% !! BUG/tmp: setting to sndplay instead of nil, because loading init file does not work properly..
%		   cmdlineSndPlayer:sndplay % nil
		    cmdlineSndPlayer:nil
		    lilypond:lilypond
		    'convert-ly':'convert-ly'
		    pdfViewer:acroread
		    sendOSC:sendOSC
		    dumpOSC:dumpOSC
		    csvmidi: csvmidi
		    midicsv: midicsv
		    midiPlayer: nil % pmidi
		    defaultMidiPlayerFlags: nil % pmidi: MIDI output of my sound card: ['-p 64:0']
		    xterm: xterm
		    %% !!?? suitable var name and value?
		    'X11.app': '/Applications/Utilities/X11.app'
		    netcat:nc
		    
		    %% files and dirs
		    strasheelaSourceDir:StrasheelaSourceDir
		    strasheelaInstallDir:StrasheelaInstallDir
		    % strasheelaDir:StrasheelaDir
		    tmpDir:'/tmp/'
		    defaultSoundDir:'/tmp/'
		    defaultSScoDir:'/tmp/'
		    defaultLilypondDir:'/tmp/'
		    defaultLilypondFlags:nil
		    defaultCsoundScoDir:'/tmp/'
		    defaultCsoundOrcDir:StrasheelaInstallDir#"/goodies/csound/"
		    defaultOrcFile:"pluck.orc" 
		    defaultCsoundSoundExtension: ".aiff"
		    defaultCsoundFlags:['-A' '-g']
		    defaultCSVDir:'/tmp/'
		    defaultCSVFlags:['-v']
		    defaultMidiDir:'/tmp/'
		    defaultSuperColliderDir:'/tmp/'
		    defaultCommonMusicDir:'/tmp/'
		    defaultENPDir:'/tmp/'
		    fomus:fomus
		    defaultFomusDir:'/tmp/'
		    firefox:'firefox'
		    
%		    textEditor:emacsclient
% 		    strasheelaFunctors: env('Strasheela':Strasheela
% 					    'HS':HS
% 					    'Motif':Motif
% 					    'Measure':Measure
% 					    'CTT':CTT
% 					    'Pattern':Pattern)
		    strasheelaFunctors: env('Strasheela':Strasheela)
		   )}}
   in
      /** %% Access the value of the Strasheela 'environment variable' Key. 
      %% */
      fun {GetStrasheelaEnv Key}
	 %{Browse GetStrasheelaEnv#Key}
	 {Dictionary.condGet @Dict Key nil} 
      end
      /** %% Set the value of the Strasheela 'environment variable' Key to Value. These variables are used, e.g., by the various output format transformers. 
      %% */
      proc {PutStrasheelaEnv Key Value}
	 {Dictionary.put @Dict Key Value}
      end

      /** %% Returns the full Strasheela environment as record. 
      %% */
      fun {GetFullStrasheelaEnv}
	 {Dictionary.toRecord unit @Dict}
      end
      /** %% Overwrites the full Strasheela environment (R is a record).
      %% */
      proc {SetFullStrasheelaEnv R}
	 Dict := {Record.toDictionary R}
      end
   end
   
   /** %% Save the full Strasheela environment as a pickle at Path. 
   %% */
   proc {SaveStrasheelaEnv Path}
      %% write to standard out..
      {Pickle.save {GetFullStrasheelaEnv} Path}
   end
   /** %% Load the full Strasheela environment from a pickle saved at Path (this was before created with SaveStrasheelaEnv). 
   %% */
   proc {LoadStrasheelaEnv Path}
      {SetFullStrasheelaEnv {Pickle.load Path}}
   end

   local
      BeatDuration = {NewCell 1.0}
   in
      /** %% Access the current beat duration in seconds (a float, defaults to 0.8).
      %% */
      fun {GetBeatDuration}
	 {Cell.access BeatDuration}
      end
      /** %% Access the current tempo in beats per minute (a float, defaults to 75.0).
      %% */
      fun {GetTempo}
	 60.0 / {Cell.access BeatDuration} 
      end
      /** %% Set the beat duration in seconds to Dur which must be a float.
      %% */
      proc {SetBeatDuration Dur}
	 %% assert important, because error would possibly occur much later and would be very hard to identify. Moreover, it is likely that an integer is given as Dur. 
	 {GUtils.assert {IsFloat Dur}
	  kernel(type
		 SetBeatDuration
		 [Dur]		% args
		 float % type
		 1 % arg position
		 nil)}
	 {Cell.assign BeatDuration Dur}
      end
      /** %% Set the tempo in beats per minute which must be a float.
      %% */
      proc {SetTempo Tempo}
	 {GUtils.assert {IsFloat Tempo}
	  kernel(type
		 SetTempo
		 [Tempo]		% args
		 float % type
		 1 % arg position
		 nil)}
	 {Cell.assign BeatDuration (60.0 / Tempo)}
      end
   end
   
   
   local
%       fun {ToPPrintRecord MyScore Excluded}
% 	 {MyScore toPPrintRecord($ features:[info items parameters value 'unit']
% 				 excluded:Excluded)}
%       end
%       proc {ScoreBrowse I X Excluded}
% 	 if {Score.isScoreObject X}
% 	 then {Browse I#{ToPPrintRecord X Excluded}}
% 	 else {Browse I#X}
% 	 end
%       end
%       proc {ScoreInspect I X Excluded}
% 	 if {Score.isScoreObject X}
% 	 then {Inspect I#{ToPPrintRecord X Excluded}}
% 	 else {Inspect I#X}
% 	 end
%       end
%       proc {BrowseMini I X}
% 	 {ScoreBrowse I X
% 	  [isTimeInterval isAmplitude
% 	   fun {$ X} 
% 	      Info = {X getInfo($)}
% 	   in
% 	      {IsDet Info} andthen
% 	      Info==endTime 
% 	   end]}
%       end
%       proc {InspectMini I X}
% 	 {ScoreInspect I X
% 	  [isTimeInterval isAmplitude
% 	   fun {$ X} 
% 	      Info = {X getInfo($)}
% 	   in
% 	      {IsDet Info} andthen
% 	      Info==endTime 
% 	   end]}
%       end
%       proc {InspectAllParams I X}
% 	 {ScoreInspect I X nil}
%       end
%       proc {BrowseAllParams I X}
% 	 {ScoreBrowse I X nil}
%       end
%       proc {BrowseInitRecord I X}
% 	 if {Score.isScoreObject X}
% 	 then {Browse I#{X toInitRecord($)}}
% 	 else {Browse I#X}
% 	 end
%       end
%       proc {InspectInitRecord I X}
% 	 if {Score.isScoreObject X}
% 	 then {Inspect I#{X toInitRecord($)}}
% 	 else {Inspect I#X}
% 	 end
%       end
      proc {ArchiveInitRecord I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.outputScoreConstructor X
	     unit(file: FileName)}
	 end
      end
%       proc {ArchiveENPNonMensural I X}
% 	 if {Score.isScoreObject X}
% 	 then 
% 	    FileName = out#{GUtils.getCounterAndIncr}
% 	 in
% 	    {Out.outputNonmensuralENP X
% 	     unit(file: FileName
% 		  getVoices:fun {$ X} [X] end)}
% 	 end
%       end
      /** %% In case the outer container of X is a sim, then its content is interpreted as ENP parts (each part with a single voice and multiple chords where each chord contains a single note). Otherwise the whole score is output into a single part (with a single voice and multiple chords where each chord contains a single note).
      %% */
      proc {ArchiveENPNonMensural I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.outputNonmensuralENP X
	     unit(file:FileName
		  getParts:fun {$ X}
			      if {X isSimultaneous($)}
			      then {X getItems($)}
			      else [X]
			      end
			   end
		  getVoices:fun {$ X} [X] end
		  %% !!?? do I need special care for multiple sim notes (forming a chord)?
		  getChords:fun {$ X} {X collect($ test:isNote)} end
		  getNotes:fun {$ X} [X] end)}
	 end
      end
      proc {ArchiveFomus I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.outputFomus X
	     unit(file: FileName)}
	 end
      end
      proc {RenderFomus I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.callFomus X
	     unit(file: FileName)}
	 end
      end
%       proc {InspectAsFullRecord I X}
% 	 if {Score.isScoreObject X}
% 	 then {Inspect I#{X toFullRecord($)}}
% 	 else {Inspect I#X}
% 	 end
%       end
%       proc {BrowseAsFullRecord I X}
% 	 if {Score.isScoreObject X}
% 	 then {Browse I#{X toFullRecord($)}}
% 	 else {Browse I#X}
% 	 end
%       end
      proc {RenderCsound I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.renderAndPlayCsound X
	     unit(file: FileName
		  title:I)}
	 end
      end
      proc {RenderLilypond I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.renderAndShowLilypond X
	     unit(file: FileName#'-'#I)}
	 end
      end
      proc {RenderMidi I X}
	 if {Score.isScoreObject X}
	 then 
	    FileName = out#{GUtils.getCounterAndIncr}
	 in
	    {Out.midi.renderAndPlayMidiFile X
	     unit(file:FileName#'-'#I)}
	 end
      end
%    TestSCEventOut =
%      {Out.makeSCEventOutFn
%       fun {$ X}
% 	 Pitch = {X getPitchInMidi($)}
% 	 Amp = {X getAmplitudeInNormalized($)}
%       in
% 	 %% !! third and forth vibraphone param fixed here  
% 	 %%'~vibraphone.makePlayer(['#Pitch#',3,7,1])'
% 	 %%
% 	 'Patch(\\simpleAnalog,['#Pitch#','#Amp#'])'
%       end}
   in
      
      /** %% Extends the Explorer menu Notes:Information Action by a few entries to output scores into various formats just by clicking the solution nodes in the Explorer.
      %% This procedure adds standard output formats like Csound, Lilypond, and MIDI.
      %% */
      proc {AddExplorerOuts_Standard}	 
% 	 {Explorer.object
% 	  add(information BrowseInitRecord
% 	      label: 'Browse as initRecord')}
	 {Explorer.object
	  add(information  proc {$ I X} {ScoreInspector.inspect I#X} end
	      label: 'Inspect Score (use score object context menu)')}
	 {Explorer.object
	  add(information ArchiveInitRecord
	      label: 'Archive initRecord')}
	 {Explorer.object
	  add(information RenderCsound
	      label: 'to Csound')}
	 {Explorer.object
	  add(information RenderLilypond
	      label: 'to Lilypond')}
	 {Explorer.object
	  add(information RenderMidi
	      label: 'to Midi')}
      end
      /** %% Extends the Explorer menu Notes:Information Action by a few entries to output scores into various formats just by clicking the solution nodes in the Explorer. 
      %% This procedure complements the formats of AddExplorerOuts_Standard by further formats like ENP and Fomus.
      %%
      %% This split into two procedures is only intended to avoid confusing new users with too many options. Anyway, the Explorer actions created by both procs are (hopefully) soon obsolete and replaced by a GUI settings dialog...
      %% */
      proc {AddExplorerOuts_Extended}
% 	 {Explorer.object
% 	  add(information BrowseMini
% 	      label: 'SBrowse mini')}
% 	 {Explorer.object
% 	  add(information BrowseAllParams
% 	      label: 'SBrowse all')}
% 	 {Explorer.object
% 	  add(information InspectMini
% 	      label: 'SInspect mini')}
% 	 {Explorer.object
% 	  add(information InspectAllParams
% 	      label: 'SInspect all')}
% 	 {Explorer.object
% 	  add(information BrowseAsFullRecord
% 	      label: 'SBrowse as full record')}
% 	 {Explorer.object
% 	  add(information InspectAsFullRecord
% 	      label: 'SInspect as full record')}
% 	 {Explorer.object
% 	  add(information InspectInitRecord
% 	      label: 'Inspect as initRecord')}
	 {Explorer.object
	  add(information ArchiveENPNonMensural
	      label: 'Archive ENPNonMensural')}
	 {Explorer.object
	  add(information ArchiveFomus
	      label: 'Archive Fomus')}
	 {Explorer.object
	  add(information RenderFomus
	      label: 'to Fomus')}
      end
      
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% The following calls are automatically executed whenever Strasheela is loaded. Therefore, some standard Strasheela settings which would be otherwise be put into OZRC can be set here.
%%%
%%% NB: These settings often perform stateful operations. Similar to the settings in OZRC, these stateful operations are not effective immediately after Oz is started, but require a little amount of time to take effect. 
%%%   

   /** %% ?? Always add standard explorer outs automatically?
   %% */
%   {AddExplorerOuts_Standard}

   
   /** %% Defines and registers special error formatters for Strasheela. See http://www.mozart-oz.org/documentation/system/node76.html for a documentation of the error formatter format.
   %% NB: for throwing exceptions use Exception.raiseError instead of raise ... end. Doing so automatically includes in the exception the feature-value-pair debug:unit (and that way provides information like tho offending souce file etc automatically), and additionally it allows for including more information with special error formatters like the ones here (this information is excluded if debug:unit is included directly in the exception). 
   %% */
   %%
   %% NB: Oz source itself very rarely introduces special exceptions and error formatters. E.g., the whole List functor contains not a single expecitly raised exception. One the one hand, this can lead to hardly conprehend error messages (e.g. if the arguments of Nth are reversed or not a list is given as arg). On the other hand, entering lots of explicit exceptions (e.g. to quasi have some ad-hoc type checking) clutters the code and also makes the code less efficient (e.g. how useful would it be to check always that Nth gets a list and an integer as arg, and perhaps even that the integer is =< {Length Xs}). So, I should also be cautios with explicit exceptions. Only introduce them if specific errors are likely or would be extremely hard to find. Also, try to always avoid some 'default' check (like assert) -- especially if it would be costly (e.g. computes the length of a list).
   
   {Error.registerFormatter strasheela
    fun {$ E}
       %% !! this is still unfinished!
       case E of strasheela(initError Msg) then
	  %% expected Msg: VS 
	  error(kind: 'strasheela: initialisation error'
		% msg: 
		items: [line(Msg)])
       elseof strasheela(illParameterUnit Unit Param Msg) then
	  %% expected Unit: any value, Param: object, MethodCall: VS, Msg: VS 
	  error(kind: 'strasheela: parameter unit error'
		msg: 'The parameter unit is ill-formed.' 
		items: [hint(l:'Unit found' m:oz(Unit))
			hint(l:'for parameter' m:oz(Param))
			line(Msg)])
       elseof strasheela(failedRequirement X Msg) then
	  %% expected X: any value, Msg: VS (or nil)
	  error(kind: 'strasheela: failed requirement error'
		msg: 'Value does not meet requirement'
		items: [hint(l: 'Given value' m: oz(X))
			line(Msg)])
	  %%
%    elseof strasheela(noSpec X Msg) then
	  %% expected X: any value, Msg: VS
	  %%
%     elseof strasheela(missingInitialisation EnvVar Msg) then
	  %% expected EnvVar: atom or list of atoms, Msg: VS
	  %%
       else
	  error(kind: 'strasheela: other error' 
		items: [line(oz(E))])
       end 
    end}
   


   
end
