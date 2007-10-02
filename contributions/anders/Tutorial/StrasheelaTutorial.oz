
/** %% This provides an interactive tutorial for the Oz programming language and for Strasheela. Just start InteractiveTutorial.exe (e.g. at the command line).
%%
%% Please note: whenever you move around your Strasheela folder in your file system (or copy it to another machine), this functor must be recompiled in order to find the example files. You better first delete the file StrasheelaPrototyper.ozf file by hand. 
%% */

functor
import
   Application System Property
%   Browser(browse:Browse)
   
   SPrototyper at 'source/StrasheelaPrototyper.ozf'
   
define

    proc{ShowHelp M}
       {System.printError
	if M==unit then nil
	else "Command line option error: "#M#"\n"
	end#
	"Usage: "#{Property.get 'application.url'}#" [OPTIONS]\n"#
	"Start an interactive tutorial for learning Oz and Strasheela basics.\n"#
%	"   --bla <TYPE>        explanation\n"#
	"   --help         show this help\n"}
    end

   try
   
      Args = {Application.getArgs
	      record('help'(single char:&h type:bool default:false)
		    )}
      
   in
      
      %% Ask for help?
      if Args.help==true then
	 {ShowHelp unit}
	 {Application.exit 0}
      end
     
      {SPrototyper.startPrototyper}
      
   catch X then
      case X of quit then
	 {Application.exit 0}
      elseof error(ap(usage M) ...) then
	 {ShowHelp M}
	 {Application.exit 2}   
      elseof E then
	 %% show run-time errors of this application 
	 raise E end
      end
   end
   
end
