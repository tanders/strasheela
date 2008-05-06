/** %% TODO: general description of PitchFingers. */

functor
import
   FD
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'

   Browser(browse:Browse) % temp for debugging
export
   setup: Setup
   toScore: ToScore
   toScoreDouble: ToScoreDouble
   writeLilyFile: WriteLilyFile

define
   proc {Setup NumNotes Pitches Strings Positions Fingers}
      %% setup lists
      Pitches = {FD.list NumNotes+1 0#127}
      Strings = {FD.list NumNotes+1 1#4}
      Positions = {FD.list NumNotes+1 1#8}
      Fingers = {FD.list NumNotes+1 0#8}

      {Nth Pitches NumNotes+1} =: {Nth Pitches 1}
      {Nth Strings NumNotes+1} =: {Nth Strings 1}
      {Nth Positions NumNotes+1} =: {Nth Positions 1}
      {Nth Fingers NumNotes+1} =: {Nth Fingers 1}

      %% definition of pitches on a violin
      for X in 1..NumNotes do
	 Pitch = {Nth Pitches X}
	 String = {Nth Strings X}
	 Position = {Nth Positions X}
	 Finger = {Nth Fingers X}
      in
	 Pitch =: 81 - (7*String) + Position + Finger
      end

      %% cannot repeat notes or have octaves
      %% required for pitch analysis
      {Pattern.forNeighbours
       Pitches
       2
       proc {$ X}
	{FD.modI {Nth X 1} 12} \=: {FD.modI {Nth X 2} 12}
       end}
   end

   fun {FingerToActualFinger Finger}
      case Finger of
	 0 then "-0"
      [] 1 then "-1"
      [] 2 then "-1"
      [] 3 then "-2"
      [] 4 then "-2"
      [] 5 then nil
      [] 6 then "-3"
      [] 7 then nil
      [] 8 then "-4"
      else nil
      end
   end

   proc {ToScore Pitches Fingers Lily ?ScoreInstance}
      {Score.makeScore
       seq(info:[lily(" "#Lily)]
	   items:
	      {List.zip {LUtils.butLast Pitches} {LUtils.butLast Fingers}
	       fun {$ Pitch Finger}
		  if (Pitch>0) then
		     note(duration:4
			  pitch:Pitch
			  amplitude:64
			  info:lily({FingerToActualFinger
				     Finger})
			 )
		  else
		     pause(duration:4)
		  end
	       end}
	   startTime:0
	   timeUnit:beats(4))
       unit ScoreInstance}
      {ScoreInstance wait}
   end

   /* %% doubles the number of pitches, and outputs a Score
   * object. */
   proc {ToScoreDouble Pitches Fingers Lily ?ScoreInstance}
      %% play games to avoid duplicating the "extra note"
      DoubledPitches = {Append {Append
				{LUtils.butLast Pitches}
				{LUtils.butLast Pitches}
			       } [{Nth Pitches 1}]}
      DoubledFingers = {Append {Append
				{LUtils.butLast Fingers}
				{LUtils.butLast Fingers}
			       } [{Nth Fingers 1}]}
   in
      ScoreInstance = {ToScore DoubledPitches DoubledFingers Lily}
   end


   C={NewCell 1}
   /* %% outputs a Score to a file. */
   proc {WriteLilyFile BaseFilename MyScore}
      Filename=BaseFilename#@C
   in
      {Out.outputLilypond
       MyScore
       unit(file:Filename
	    implicitStaffs:false
	    wrapper:"\\score{\n {"#(" }\n \\layout{}\n \\midi{}\n}\n"#"")
	    unit)}
      C:=@C+1
   end

end
