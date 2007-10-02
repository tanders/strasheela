declare
[HarpClasses] = {ModuleLink ['x-ozlib://sprotte/Harp/HarpClasses.ozf']}


{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {Score.makeScore sim(startTime:0
				   timeUnit:beats(1)
				   items:[seq(offsetTime:0
					      items:[note(duration:2
							  pitch:{FD.int 60#72})
						     note(duration:2
							  pitch:{FD.int 60#72})]
					     )])
	       unit(note:HarpClasses.harpNote
		    sim:Score.simultaneous
		    seq:Score.sequential)}
 end
 unit}

