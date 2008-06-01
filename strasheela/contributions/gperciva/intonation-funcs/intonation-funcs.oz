/** %% TODO: general description of Intonation-funcs.  (test of doc-string) */

functor
import
   FD
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   %% for debug
   %Browser

export
   inMajorKey: InMajorKey
   inMinorKey: InMinorKey
   hasMinor: HasMinor
   firstPos: FirstPosition
   changeToOpenString: ChangeToOpenString
   changeOneString: ChangeOneString
   changeTwoOpen: ChangeTwoOpen
   changeFingerOrPosition: ChangeFingerOrPosition
   noFingeredFifths: NoFingeredFifths
   atLeast: AtLeast
   atLeastTwin: AtLeastTwin
   atMost: AtMost
   minChanges: MinChanges
   thirdPositionNoStretchBack: ThirdPositionNoStretchBack

define
   proc {InMajorKey Pitches Tonic}
      BaseTonic = {Int.'mod' Tonic 12}
   in
      {ForAll Pitches
       proc {$ X}
	{FD.modI X 12} \=: {Int.'mod' (BaseTonic+1) 12}
	{FD.modI X 12} \=: {Int.'mod' (BaseTonic+3) 12}
	{FD.modI X 12} \=: {Int.'mod' (BaseTonic+6) 12}
	{FD.modI X 12} \=: {Int.'mod' (BaseTonic+8) 12}
	{FD.modI X 12} \=: {Int.'mod' (BaseTonic+10) 12}
       end}
   end

   proc {InMinorKey Pitches Tonic}
      BaseTonic = {Int.'mod' Tonic 12}
   in
      {ForAll Pitches
       proc {$ X}
	{FD.modI X 12} \=: {Int.'mod' (BaseTonic+1) 12}
	{FD.modI X 12} \=: {Int.'mod' (BaseTonic+4) 12}
	{FD.modI X 12} \=: {Int.'mod' (BaseTonic+6) 12}
	{FD.modI X 12} \=: {Int.'mod' (BaseTonic+9) 12}
	{FD.modI X 12} \=: {Int.'mod' (BaseTonic+11) 12}
       end}
   end

   proc {HasMinor Pitches Tonic}
      BaseTonic = {Int.'mod' Tonic 12}
   in
      {FD.sum {Map
	       {LUtils.butLast Pitches}
	       fun {$ X}
{FD.disj
	{FD.modI X 12} =: {Int.'mod' (BaseTonic+3) 12}
{FD.disj
	{FD.modI X 12} =: {Int.'mod' (BaseTonic+8) 12}
	{FD.modI X 12} =: {Int.'mod' (BaseTonic+10) 12}
}}
	end} '>:' 0}
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

   %% if changing by two strings, it must be an open
   %% string.  Can't change by three strings.
   proc {ChangeTwoOpen Strings Fingers}
      for X in 1..({Length Strings}-1) do
	 SA = {Nth Strings X}
	 SB = {Nth Strings X+1}
	 FB = {Nth Fingers X+1}
      in
	 {FD.distance SA SB '=<:' 2}
	 {FD.impl
	  {FD.reified.distance SA SB '=:' 2}
	  (FB =: 0)
	  1}
      end
   end

   %% must change to a specific finger, or an open string
   proc {ChangeFingerOrPosition Fingers Positions Strings}
      for X in 1..({Length Fingers}-1) do
	 FA = {Nth Fingers X}
	 FB = {Nth Fingers X+1}
	 PA = {Nth Positions X}
	 PB = {Nth Positions X+1}
	 SA = {Nth Strings X}
	 SB = {Nth Strings X+1}
      in
	 {FD.impl
	  (PA \=: PB)
	  {FD.disj
	   {FD.disj
	    (FB =: 0)
	    (FA =: 0)}
	   {FD.disj
	    (SA =: SB)
            (FA =: FB)}
	   }
	  1}
      end
   end
%zz

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
	    {FD.disj
	    (FA =: 0) 
	    (FB =: 0)}
	  % different fingers,
	    (FA \=: FB)}
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

   proc {ThirdPositionNoStretchBack Pitches Positions Fingers}
      for X in 1..({Length Pitches}-1) do
	 A = {Nth Pitches X}
	 PA = {Nth Positions X}
	 FA = {Nth Fingers X}
      in
         {FD.impl
          {FD.conj
 (PA =: 5)
 (FA =: 1)}
 (A =: 74)
 1}
   end

   end

end

