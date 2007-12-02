%% ozc -x echo.oz
%% ./echo --in=4
functor
	import
		System Application
	define
		Args = {Application.getArgs record('in'(single type:Int))}
		Echo = Args.'in'
		{System.showInfo ('Voices: '#Echo)}
		{Application.exit 0}
end
