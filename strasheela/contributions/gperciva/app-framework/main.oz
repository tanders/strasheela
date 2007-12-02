%% ozmake -vm Makefile.oz

functor
import
	%% basic Oz stuff
	System Application Property
	%% your personal definitions
	MyCode
define

	%% Show help message
	proc{ShowHelp M}
		{System.printError
		if M==unit then nil else "Command line option error: "#M#"\n" end#
			"Usage: "#{Property.get 'application.url'}#" [OPTIONS]\n"#
			"   --arg1 <INTEGER>		First number\n"#
			"   --arg2 <INTEGER>		Second number\n"#
			"   --name <STRING>	    Your name\n"}
	end

	try
		%% Args is record of parsed commandline arguments 
		Args = {Application.getArgs record(
			arg1(single type:int default:1)
			arg2(single type:int default:2)
			name(single type:string default:"you")
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
		X
	in
		{MyCode.myProc Args.arg1 Args.arg2 X}
		{System.showInfo 'Hello '#Args.name#', the biggest number was '#X}
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

