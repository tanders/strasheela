%% better example of standalone program.
%%   - has default values for command-line arguments
%%   - error handling
%%   - 
functor
import
   System Application Property
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
define


   %% Show help message
   proc{ShowHelp M}
      {System.printError
       if M==unit then nil else "Command line option error: "#M#"\n" end#
       "Usage: "#{Property.get 'application.url'}#" [OPTIONS]\n"#
       "   --file <FILE>         Lilypond output filename (basename without extension)\n"#
       "   --dir <DIR>           Lilypond output directory\n"#
       "   --size <INTEGER>      Number of notes in created score\n"}
   end
   
   try
      %% Args is record of parsed commandline arguments 
      Args = {Application.getArgs record(file(single type:string default:"foo")
					 dir(single type:string default:"/tmp/")
					 size(single type:int default:1)
					 help(single char:&h type:bool default:false)
					)} 
      
   in
      %% Ask for help?
      if Args.help==true then
	 {ShowHelp unit}
	 {Application.exit 0}
      end      

      %% your actual program
      local
	 {System.showInfo 'create score'}
	 MyScore = {Score.makeScore seq(items:{LUtils.collectN Args.size
					       fun {$}
						  note(duration:4 % 16th note duration
						       pitch:60
						       amplitude:64)
					       end}
					startTime:0
					%% lilypond output is better specified in beats instead of msecs
					timeUnit:beats(16)
				       )
		    unit} 
      in
	 %% wait until all score parameters are determined before outputting -- e.g., the note start times are determined by propagation here (you don't need that when you create your score by search, in that case it would do nothing) 
	 {MyScore wait} 
	 % 
	 {System.showInfo 'now output lilypond'}
	 {Out.outputLilypond MyScore
	  unit(file:Args.file
	       dir:Args.dir)}
      end

      {Application.exit 0}
      
      %% handling of exceptions
   catch X then
      case X of quit then
	 {Application.exit 0}
      elseof error(ap(usage M) ...) then
	 {ShowHelp M}
	 {Application.exit 2}
      elseof E then
	 raise E end
      end
   end
   
end

