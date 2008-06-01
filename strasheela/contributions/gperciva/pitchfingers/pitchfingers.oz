/** %% TODO: general description of PitchFingers. */

functor
import
   FD
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'

%   Browser(browse:Browse) % temp for debugging
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
      Fingers = {FD.list NumNotes+1 0#4}

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
	 NotOpen
% TODO: what about extended 4?
	 FingerPitch = {FD.int 0#7}
      in
	 NotOpen = (Finger >: 0)

	 {FD.equi
	  (Finger =: 0)
	  (FingerPitch =: 0)
	  1}
	 {FD.equi
	  (Finger =: 1)
	  {FD.disj
	   (FingerPitch =: 1)
	   (FingerPitch =: 2)}
	  1}
	 {FD.equi
	  (Finger =: 2)
	  {FD.disj
	   (FingerPitch =: 3)
	   (FingerPitch =: 4)}
	  1}
	 {FD.equi
	  (Finger =: 3)
	  {FD.disj
	   (FingerPitch =: 5)
	   (FingerPitch =: 6)}
	  1}
	 {FD.equi
	  (Finger =: 4)
	  (FingerPitch =: 7)
% TODO: what about extended 4?
	  %{FD.disj
	  % (FingerPitch =: 7)
	  % (FingerPitch =: 8)}
	  1}

	 Pitch =: 83 - (7*String) + NotOpen*(Position-2) + FingerPitch
      end

      %% cannot repeat notes (required for pitch analysis)
      {Pattern.forNeighbours
       Pitches
       2
       proc {$ X}
	  {Nth X 1} \=: {Nth X 2}
       end}
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
			  info:lily("-"#Finger)
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
