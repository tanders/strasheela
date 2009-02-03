/** %% TODO: general description of Rhythm-funcs.  (test of doc-string) */

functor
import
   FD
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   %% for debug
   %Browser

export
   eventEvery: EventEvery
   noRests: NoRests
   restsOnlyOnBeats: RestsOnlyOnBeats
   beatsAllSame: BeatsAllSame
   noTwoIdenticalAdjacentBeats: NoTwoIdenticalAdjacentBeats
   noThreeIdenticalAdjacentBeats: NoThreeIdenticalAdjacentBeats
   minDursOnBeats: MinDursOnBeats
   minDurs: MinDurs
   maxDurs: MaxDurs
   atLeastTwin: AtLeastTwin
   noAdjacentRests: NoAdjacentRests

define
   proc {EventEvery List NumEvents}
      {ForAll {LUtils.everyNth List NumEvents 0}
       proc {$ X}
	  X \=: 0
       end}
   end

   proc {NoRests List}
      {ForAll List
       proc {$ X}
	  X\=:2
       end}
   end

   proc {RestsOnlyOnBeats Events BeatDivisions}
      {ForAll
       {Pattern.adjoinedSublists Events BeatDivisions}
       proc {$ Beat}
	  {ForAll Beat.2 proc {$ X}
			    X \=: 2
			 end}
       end}
   end


   proc {BeatsAllSame Durs BeatDivisions}
      {ForAll
       {Pattern.adjoinedSublists Durs BeatDivisions}
       proc {$ Beat}
	  {ForAll Beat.2 proc {$ Y}
			    {FD.disj
			     Y =: 0
			     Y =: Beat.1
			     1}
			 end}
       end}
   end

   proc {NoThreeIdenticalAdjacentBeats Durs BeatDivisions}
      {Pattern.forNeighbours
       {LUtils.everyNth Durs BeatDivisions 0}
       3
       proc {$ X}
	  {FD.impl
	   ( {Nth X 1} =: {Nth X 2} )
	   ( {Nth X 3} \=: {Nth X 1} )
	   1}
       end}   
   end

   proc {NoTwoIdenticalAdjacentBeats Durs BeatDivisions}
      {Pattern.forNeighbours
       {LUtils.everyNth Durs BeatDivisions 0}
       2
       proc {$ X}
	  ( {Nth X 1} \=: {Nth X 2} )
       end}   
   end

   proc {MinDursOnBeats Durs BeatDivisions DurValue NumDurs}
      {FD.sum {Map
	       {LUtils.everyNth Durs BeatDivisions 0}
	       fun {$ X} (X=:DurValue) end}
       '>=:' NumDurs}
   end

   proc {MinDurs Durs DurValue NumDurs}
      {FD.sum {Map Durs fun {$ X} (X=:DurValue) end} '>=:' NumDurs}
   end

   proc {MaxDurs Durs DurValue NumDurs}
      {FD.sum {Map Durs fun {$ X} (X=:DurValue) end} '=<:' NumDurs}
   end


  %% only does 1-6 durations!
  proc {NoAdjacentRests Events Durs}
   %% 1r R  cannot in this level
   for I in 1..{Length Events}-1 do
      {FD.impl
       ( {FD.conj
	  ({Nth Events I} =: 2)
	  ({Nth Durs I} =: 1)
	 } )
       ( {Nth Events I+1} \=: 2 )
       1}
   end
   %% removes 2r . R rests
   for I in 1..{Length Events}-2 do
      {FD.impl
       ( {FD.conj
	  ({Nth Events I} =: 2)
	  ({Nth Durs I} =: 2)
	 } )
       ( {Nth Events I+2} \=: 2 )
       1}
   end
   %% removes 3r . . R rests
   for I in 1..{Length Events}-3 do
      {FD.impl
       {FD.conj
	({Nth Events I} =: 2)
	({Nth Durs I} =: 3) }
       ( {Nth Events I+3} \=: 2 )
       1}
   end
   %% removes 4r . . . R rests
   for I in 1..{Length Events}-4 do
      {FD.impl
       {FD.conj
	({Nth Events I} =: 2)
	({Nth Durs I} =: 4) }
       ( {Nth Events I+4} \=: 2 )
       1}
   end
   %% removes 5 rests
   for I in 1..{Length Events}-5 do
      {FD.impl
       {FD.conj
	({Nth Events I} =: 2)
	({Nth Durs I} =: 5) }
       ( {Nth Events I+5} \=: 2 )
       1}
   end   %% removes 6 rests
   for I in 1..{Length Events}-6 do
      {FD.impl
       {FD.conj
	({Nth Events I} =: 2)
	({Nth Durs I} =: 6) }
       ( {Nth Events I+6} \=: 2 )
       1}
   end
  end

 proc {AtLeastTwin ListOne IsOne ListTwo IsTwo Number}
      {FD.sum {List.zip
	       {LUtils.butLast ListOne}
	       {LUtils.butLast ListTwo}
	       fun {$ O T}
		  {FD.conj
		   (O =: IsOne)
		   (T =: IsTwo)
		  }
	       end} '>=:' Number}
   end


end
