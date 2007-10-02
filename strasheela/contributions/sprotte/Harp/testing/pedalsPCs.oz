declare
[Harp] = {ModuleLink ['x-ozlib://sprotte/Harp/Harp.ozf']}

{Browse {Length {SearchAll proc {$ R}
			      R = r(pedals:_ pcs:_)
			      {Harp.pedalsPCs R.pedals R.pcs}
			      {FD.distribute naive R.pedals}
			   end}}}

{Browse {SearchAll proc {$ R}
		      R = r(pedals:_ pcs:_)
		      {Harp.pedalsPCs R.pedals R.pcs}
		      {FD.distribute naive R.pedals}
		   end}}



{Browse {SearchAll proc {$ R}
		      R = r(pedals:_ pcs:{FS.value.make [0 1 3 4 8]})
		      {Harp.pedalsPCs R.pedals R.pcs}
		      {FD.distribute naive R.pedals}
		   end}}

{Browse {Length {SearchAll proc {$ R}
			      R = r(pedals:_ pcs:{FS.var.lowerBound [0 1 3 4 8]})
			      {Harp.pedalsPCs R.pedals R.pcs}
			      {FD.distribute naive R.pedals}
			   end}}}
%%

{Browse {Length {SearchAll proc {$ R}
			      R = r(pedals:_ pcs:_)
			      {Harp.pedalsPCs R.pedals R.pcs}
			      {FS.distribute naive [R.pcs]}
			   end}}}

{Browse {SearchAll proc {$ R}
		      R = r(pedals:_ pcs:_)
		      {Harp.pedalsPCs R.pedals R.pcs}
		      {FS.distribute naive [R.pcs]}
		   end}}

for Card in 4..7
do
   {Browse Card#{Length {SearchAll proc {$ R}
				      R = r(pedals:_ pcs:_)
				      {Harp.pedalsPCs R.pedals R.pcs}
				      {FS.card R.pcs Card}
				      {FS.distribute naive [R.pcs]}
				   end}}}
end

%%

{ExploreAll proc {$ R}
	       R = r(pedals:_ pcs:_)
	       {Harp.pedalsPCs R.pedals R.pcs}
	       {FD.distribute naive R.pedals}
	    end}

{ExploreAll proc {$ R}
	       R = r(pedals:_ pcs:_)
	       {Harp.pedalsPCs R.pedals R.pcs}
	       {FS.distribute naive [R.pcs]}
	    end}


