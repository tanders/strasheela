/** %% TODO: general description of Intonation-funcs.  (test of doc-string) */

functor
import
   FD
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   %% for debug
%   Browser

export
   inMajorKey: InMajorKey
   inMinorKey: InMinorKey
   firstPos: FirstPosition
   changeToOpenString: ChangeToOpenString
   changeOneString: ChangeOneString
   noFingeredFifths: NoFingeredFifths
   atLeast: AtLeast
   atLeastTwin: AtLeastTwin
   atMost: AtMost
   minChanges: MinChanges

define
   proc {InMajorKey Pitches Tonic}
      BaseTonic = {Int.'mod' Tonic 12}
   in
      {ForAll Pitches
       proc {$ X}
	  for Oct in 1..9 do
	     X \=: 12*Oct+BaseTonic+1
	     X \=: 12*Oct+BaseTonic+3
	     X \=: 12*Oct+BaseTonic+6
	     X \=: 12*Oct+BaseTonic+8
	     X \=: 12*Oct+BaseTonic+10
	  end
       end}
   end

   proc {InMinorKey Pitches Tonic}
      BaseTonic = {Int.'mod' Tonic 12}
   in
      {ForAll Pitches
       proc {$ X}
	  for Oct in 1..9 do
	     X \=: 12*Oct+BaseTonic+1
	     X \=: 12*Oct+BaseTonic+4
	     X \=: 12*Oct+BaseTonic+6
	     X \=: 12*Oct+BaseTonic+9
	     X \=: 12*Oct+BaseTonic+11
	  end
       end}
   end

   proc {FirstPosition Positions}
      {ForAll Positions proc {$ X} X =: 2 end}
   end

   proc {ChangeToOpenString Strings Fingers}
      for X in 1..({Length Strings}-1) do
	 SA = {Nth Strings X}
	 SB = {Nth Strings X+1}
         %FA = {Nth Fingers X} 
	 FB = {Nth Fingers X+1}
      in 
	 {FD.impl
	  (SA \=: SB) 
	  (FB =: 0)
	  1}
      end
   end

   proc {ChangeOneString Strings}
      for X in 1..({Length Strings}-1) do
	 SA = {Nth Strings X}
	 SB = {Nth Strings X+1}
      in
	 {FD.distance SA SB '=<:' 1}
      end
   end

   proc {NoFingeredFifths Strings Fingers}
      for X in 1..({Length Strings}-1) do
	 SA = {Nth Strings X}
	 SB = {Nth Strings X+1}
	 FA = {Nth Fingers X} 
	 FB = {Nth Fingers X+1}
      in 
	 {FD.impl
	  % if not the same strings
	  (SA \=: SB)
	  {FD.disj
	  % we need either an open string,
	   {FD.disj
	    (FA =: 0) 
	    (FB =: 0)}
	  % different fingers,
	   {FD.conj
	    (FA \=: FB)
	  % but not 1+2 or 3+4
	    {FD.conj
	     {FD.conj
	      {FD.impl
	       (FA =: 1)
	       (FB \=: 2)}
	      {FD.impl
	       (FA =: 2)
	       (FB \=: 1)}}
	     {FD.conj
	      {FD.impl
	       (FA =: 3)
	       (FB \=: 4)}
	      {FD.impl
	       (FA =: 4)
	       (FB \=: 3)}}
	    }}
	  }
	  1}
      end
   end


   proc {AtLeast List Is Number}
      {FD.sum {Map
	       {LUtils.butLast List}
	       fun {$ X} (X =: Is) end} '>=:' Number}
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

   proc {AtMost List Is Number}
      {FD.sum {Map
	       {LUtils.butLast List}
	       fun {$ X} (X =: Is) end} '=<:' Number}
   end

   proc {MinChanges List Number}
      {FD.sum {Pattern.mapNeighbours
	       {LUtils.butLast List}
	       2
	       fun {$ X}
		  ({Nth X 1} \=: {Nth X 2})
	       end}
       '>=:' Number}

   end


end
