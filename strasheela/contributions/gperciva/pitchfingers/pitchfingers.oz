/** %% TODO: general description of PitchFingers. */

functor
import
   FD
%   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   %% for debug
   %Browser

   %% for WriteLilyFile; this might be moved to a different module
%   System
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
export
   setup: Setup
   toScore: ToScore
   writeLilyFile: WriteLilyFile

define
   proc {Setup NumNotes Pitches Strings Positions Fingers}
      %% setup lists
      Pitches = {FD.list NumNotes 0#127}
      %% need to redo this: define numbers for finger extentions
      Strings = {FD.list NumNotes 1#4}
      Positions = {FD.list NumNotes 1#8}
      Fingers = {FD.list NumNotes 0#4}

      %% definition of pitches on a violin
      for X in 1..NumNotes do
	 Pitch = {Nth Pitches X}
	 String = {Nth Strings X}
	 Position = {Nth Positions X}
	 Finger = {Nth Fingers X}
      in
	 Pitch =: 81 - (7*String) + Position + Finger

      end

      %% cannot repeat notes -- required for analysis
      {Pattern.forNeighbours
       Pitches
       2
       proc {$ X}
	  {Nth X 1} \=: {Nth X 2}
       end}

   end


   proc {ToScore Pitches ?ScoreInstance}
      {Score.makeScore
       seq(
	  items:
	     {Map Pitches fun {$ Pitch}
			     if (Pitch>0) then
				note(duration:4
				     pitch:Pitch
				     amplitude:64)
			     else
				pause(duration:4)
			     end
			  end}
	  startTime:0
	  timeUnit:beats(4))
       unit ScoreInstance}
      {ScoreInstance wait}
   end


   C={NewCell 1}
   /* %% outputs a Score to a file.  Adds support for rests (ie 'pause' events). */
   proc {WriteLilyFile BaseFilename MyScore}
      Filename=BaseFilename#@C
   in
      %{System.show @C}
      {Out.outputLilypond
       MyScore
       unit(file:Filename
	    %% definition of pause output
	    clauses:[ isPause#fun {$ MyPause}
				 %%  returns a list of Lilypond rhythm
				 %%  values matching dur of MyPause
				 Rhythms = {Out.lilyMakeRhythms
					    {MyPause getDurationParameter($)}}
			      in
				 %% if pause duration is 0 or too
                             %short
				 %% (less than a 64th note, or 0.0625
                             %beat)
				 if Rhythms == nil
				 then '' % omit pause
				    %% otherwise output VS of Lily
                                %pause(s)
				 else {Out.listToVS {Map Rhythms fun
								    {$ R} r#R
								 end}
				       " "}
				 end
			      end]

	   )}
      C:=@C+1
   end




end
