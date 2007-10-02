
/** %% This functor exports GUI dialogs for setting Strasheela environment variables. These settings are used, in particular, to control the export of Strasheela scores into various output formats. 
%% */

%%
%% TODO
%%
%% * add settings of default directories: use tk_chooseDirectory, put these settings in extra tab of interface
%%
%%
%% {Tk.return tk_chooseDirectory(initialdir:"/Users/t/oz/"
%%			      title:"my test")}
%%
%% 

functor
import
   Property Tk 
   Init at 'x-ozlib://anders/strasheela/source/Init.ozf'
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   
   QTk at 'x-oz://system/wp/QTk.ozf'
   %% !! tmp Path
   Path at 'x-ozlib://anders/tmp/Path/Path.ozf'
   
export
   MakeFileSettings
   MakeApplicationFileSettings
   
define

   /** %% Is_MacOS is true if the platform is a powermac (!) and false otherwise. 
   %% */
   Is_MacOS = {Property.get 'platform.os'} == powermac
   
   /** %% Returns QTk spec for file setting. Label is a descriptive VS, EnvKey is the Strasheela environment key (an atom). Update is bound to nullary procedure which updates the value shown in the entry widget to the present Strasheela environment value at EnvKey. QTkSpec is the created QTk specification.
   %% */
   proc {MakeFileSetter Label LabelWidth EnvKey ?Update ?QTkSpec}
      EntryH
      proc {ButtonSet}
	 File = {Tk.return tk_getOpenFile} in
	 if File \= nil then
	    {EntryH set(File)}
	    {Init.putStrasheelaEnv EnvKey {EntryH get($)}}
	    if Is_MacOS andthen {Path.extension File} == "app"
	    then {GUtils.warnGUI "Please make sure that "#File#" is an executable and not an application package."}
	    end
	 end
      end
      proc {EntrySet}
	 {Init.putStrasheelaEnv EnvKey {EntryH get($)}}
      end
   in
      proc {Update}
	 {EntryH set({Init.getStrasheelaEnv EnvKey})}
      end
      QTkSpec = lr(glue:nwe
		   label(glue:e
			 anchor:w
			 width:LabelWidth
			 init:Label)
		   entry(glue:we
			 init:{Init.getStrasheelaEnv EnvKey}
			 handle:EntryH
			 %% !! tooltips cause TK crash on Fedora
%			 tooltips:"Set "#EnvKey
			 action:EntrySet)
		   button(init:'Set ...'
%			  tooltips:"Set "#EnvKey
			  action:ButtonSet))
   end

   /** %% Creates GUI windows for setting the Strasheela environment specified in Specs. Specs is a record of records with the format unit(label:L key:K), where L is a VS describing a setting and K is a Strasheela environment key (an atom). Title is a VS with the window title. DocString is a VS displayed above all settings. LabelWidth is for cosmetics: it is an integer specifying a width of all settings labels given in Spec (in characters).
   %% */
   proc {MakeFileSettings Title DocString LabelWidth Specs}
      FullDocString = DocString#"\n\nA setting is made either by directly entering it into the entry box, or by selecting a file with the 'Set...' button. The button 'Load...' ('Save...') loads (saves) the settings for all Strasheela environment variables (including the ones not displayed by this dialog) into (from) a file."
      proc {CallAll Ps} {ForAll Ps proc {$ P} {P} end} end
      UpdatesExtList = {New LUtils.extendableList init}
      Updates = UpdatesExtList.list
      QTkSpecs = {Record.map Specs
		  fun {$ unit(label:L key:K)}
		     Update QTkSpec in
		     {MakeFileSetter L LabelWidth K Update QTkSpec}
		     {UpdatesExtList add(Update)}
		     QTkSpec
		  end}
      Window = {QTk.build
		td(title:Title
		   menubutton(glue:e
			      text:"Help"
			      menu:menu(command(text:"Help"
						action:proc{$}
							  {GUtils.infoGUI FullDocString}
							  % _ = {Tk.return tk_messageBox(icon:info type:ok message:DocString)}
						       end)))
		   {Adjoin QTkSpecs
		    td(glue:nwe)}
		   lr(glue:sew
		      button(glue:w
			     init:'Load ...'
%			     tooltips:"Load a previously saved full Strasheela environment from a file."
			     action:proc {$}
				       File = {Tk.return tk_getOpenFile} in
				       if File \= nil then
					  {Init.loadStrasheelaEnv File}
					  {CallAll Updates}
				       end
				    end)
		      button(glue:w
			     init:'Save ...'
%			     tooltips:"Save the complete Strasheela environment to a file."
			     action:proc {$}
				       File = {Tk.return tk_getSaveFile} in
				       if File \= nil then
					  {Init.saveStrasheelaEnv File}
				       end
				    end)
		      %%
		      button(glue:e
			     init:'Close'
			     action:Window#close))
		  )}
   in
      {UpdatesExtList close}
      {Window show}  
   end

   /** %% Creates GUI windows for setting the Strasheela environment variables which specify application paths. 
   %% */
   proc {MakeApplicationFileSettings}
      {MakeFileSettings "Strasheela environment settings (applications)"
       "This dialog sets paths to applications called by Strasheela. NB: a setting is only necessary, if the respective application is not listed in your PATH environment variable with the command specified here by default."
%  unit(unit(label:"Lilypond" key:lilypond)
%       unit(label:"A PDF viewed (e.g. Acrobat)" key:pdfViewer)
%       unit(label:"Csound" key:csound)      
%       unit(label:"A sound editor (e.g. audacity)" key:sndplay)
%       unit(label:"A commandline sound player" key:cmdlineSndPlayer)
%       unit(label:"CSVMIDI (text to MIDI converter)" key:csvmidi)
%       unit(label:"A MIDI file player" key:midiPlayer)
%       unit(label:"Fomus " key:fomus)
       %% LabelWidth
       17
       unit(unit(label:"Lilypond" key:lilypond)
	    unit(label:"convert-ly" key:'convert-ly')
	    unit(label:"PDF viewer" key:pdfViewer)
	    unit(label:"Csound" key:csound)      
	    unit(label:"Sound editor" key:sndPlayer)
	    unit(label:"Cmdline sound player" key:cmdlineSndPlayer)
	    unit(label:"CSVMIDI" key:csvmidi)
	    unit(label:"MIDI file player" key:midiPlayer)
	    unit(label:"Fomus" key:fomus)
	   )}
   end

   
end
