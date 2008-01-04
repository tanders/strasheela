/** %% TODO: general description of OnsetDurations.  (test of doc-string) */

functor
import
   FD
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'

   %% for WriteLilyFile; this might be moved to a different module
   System
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
export
   setup: Setup
   toScore: ToScore
   writeLilyFile: WriteLilyFile

define
%   BeatDivisions

   /** %% link Onsets with Durations.  Setting a value (or narrowing the domain) in either list will update the other list. */
   proc {Setup Beats BeatDivisionsGet Onsets Durations}
      NumOnsets = Beats*BeatDivisionsGet
   in
      %% BUG: from within a script (i.e. a local computation space), you can not determine a global variable (i.e. a variable in the top-level space)
%      BeatDivisions = BeatDivisionsGet

      %% setup lists, add fake note at end
       Durations = {FD.list NumOnsets 0#NumOnsets}
       Onsets = {FD.list NumOnsets+1 0#2}
      %% tmp comment
      {Nth Onsets NumOnsets+1} =: 1

      %% first onset can't be "continue note"
      {Nth Onsets 1} \=: 0

      for X in 1..NumOnsets do

	 %% setup maxmium durations
	 {Nth Durations X} =<: NumOnsets+1-X


	 %% align rests
	 {FD.equi
	  ({Nth Durations X} =: 0)
	  ({Nth Onsets X} =: 0)
	  1}


	 %% align 1 dur
	 {FD.equi
	  {Nth Durations X} =: 1
	  {FD.conj 
	   ({Nth Onsets X} >: 0)
	   ({Nth Onsets X+1} >: 0)
	  }
	  1}


	 %% align 2+ dur
	 for D in 2..NumOnsets do
	    if ( X =< (NumOnsets+1-D) ) then
	       {FD.equi
		({Nth Durations X} =: D)
		{FD.conj 
		 ({Nth Onsets X} >: 0)
		 {FoldR
		  {LUtils.sublist Onsets X+1 X+D-1}
		  fun {$ X Y}
		     {FD.conj (X=:0) Y}
		  end
		  ({Nth Onsets X+D} >: 0)
		 }
		}
		1}
	    end
	 end
      end
      
   end

   %% internal for ToScore
   fun {EventsIn Onsets}
      {FoldL Onsets fun {$ X Y} if Y>0 then X+1 else X end end
       0} -1
   end

   %% internal for ToScore
   proc {GetNotes Onsets Durations Notes}
      NumNotes = {EventsIn Onsets}
      Y = {NewCell 1}
   in
      Notes = {List.make NumNotes}
      for X in 1..{Length Durations}
      do
	 if {Nth Onsets X}==1 then
	    {Nth Notes @Y} = {Nth Durations X}
	    Y := @Y + 1
	 end
	 if {Nth Onsets X}==2 then
	    {Nth Notes @Y} = {Number.'~' {Nth Durations X}}
	    Y := @Y + 1
	 end
      end
   end

   /* %% Combines the Onsets and Durations and produces a Score object. */
   proc {ToScore Onsets Durations BeatDivisions ?ScoreInstance}
      Notes = {GetNotes Onsets Durations}
   in
      {Score.makeScore
       seq(
	  items:
	     {Map Notes fun {$ Note}
			   if (Note>0) then
			      note(duration:Note
				   pitch:60
				   amplitude:64)
			   else
			      pause(duration:{Number.abs Note})
			   end
			end}
	  startTime:0
	  timeUnit:beats(BeatDivisions))
       unit ScoreInstance}
      {ScoreInstance wait}
   end


   C={NewCell 1}
   /* %% outputs a Score to a file.  Adds support for rests (ie 'pause' events). */
   proc {WriteLilyFile BaseFilename MyScore}
      Filename=BaseFilename#@C
   in
      {System.show @C}
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
