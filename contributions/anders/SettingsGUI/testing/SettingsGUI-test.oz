
declare
[Settings
 QTk] = {ModuleLink ['x-ozlib://anders/strasheela/SettingsGUI/SettingsGUI.ozf'
		     'x-oz://system/wp/QTk.ozf']}


%% 
{Settings.makeApplicationFileSettings}

{Settings.makeFileSettings "My Title"
 "My doc string"
 18
 unit(unit(label:"Lilypond" key:lilypond)
      unit(label:"Cmdline sound player" key:cmdlineSndPlayer)
      unit(label:"PDF viewer" key:pdfViewer))}
