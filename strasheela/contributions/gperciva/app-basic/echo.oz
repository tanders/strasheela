%% ozc -x echo.oz
%% ./echo --in=blah
functor
	import
		System Application
	define
		Args = {Application.getArgs record('in'(single type:string))}
		Echo = Args.'in'
		{System.showInfo ('Voices: '#Echo)}
		{Application.exit 0}
end
