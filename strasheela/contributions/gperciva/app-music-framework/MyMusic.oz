functor
import
	LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
	Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
	% SDistro at 'x-ozlib://anders/strasheela/source/ScoreDistribution.ozf'
export
	myScore: MyScore
define

	proc {MyScore NumNotes Return}
		Return = {Score.makeScore
			seq(items:{LUtils.collectN NumNotes
				fun {$}
				note(duration:4
					pitch:60
					amplitude:64)
				end}
			startTime:0
			timeUnit:beats(4)
			)
			unit}
		end

end

