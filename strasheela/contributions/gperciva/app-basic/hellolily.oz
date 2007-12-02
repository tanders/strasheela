%% outputs a simple score as lilypond
%% ozc -x hellolily.oz
functor
	import
		System Application
		Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
		Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
	define

	%% "hello world" for lilypond output
	local
		TextualScore = note(startTime:0
			duration:1000
			timeUnit:milliseconds
			pitch:60
			amplitude:64)
		ScoreInstance = {Score.makeScore TextualScore unit}
	in
		{Out.outputLilypond ScoreInstance
		unit(file:'foo')}
	end

	{Application.exit 0}
end
