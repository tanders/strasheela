/** %% TODO: general description of Intonation-funcs.  (test of doc-string) */

functor
import
   FD
%   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
%   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   %% for debug
%   Browser

export
   inMajorKey: InMajorKey
   inMinorKey: InMinorKey
   firstPos: FirstPosition
   changeToOpenString: ChangeToOpenString
   noFourOpen: NoFourOpen
   atLeastEqual: AtLeastEqual
   atLeastEqualTwo: AtLeastEqualTwo

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

   proc {NoFourOpen Strings Fingers}
      for X in 1..({Length Strings}-1) do
	 SA = {Nth Strings X}
	 SB = {Nth Strings X+1}
	 FA = {Nth Fingers X} 
	 FB = {Nth Fingers X+1}
      in 
	 {FD.impl
	  (FA =: 7)
	  {FD.disj
	   (SB \=: SA)
	   (FB \=: 0)}
	  1}
      end
   end


   proc {AtLeastEqual List Is Number}
      {FD.sum {Map List fun {$ X} (X =: Is) end} '>=:' Number}
   end

   proc {AtLeastEqualTwo ListOne IsOne ListTwo IsTwo Number}
      {FD.sum {List.zip ListOne ListTwo
	       fun {$ O T}
		  {FD.conj
		   (O =: IsOne)
		   (T =: IsTwo)
		  }
	       end} '>=:' Number}
   end


end
