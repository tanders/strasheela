/** %% TODO: general description of EventDurs.  (test of doc-string) */

functor
import
   FD
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   %% for debug
   %Browser

   %% for WriteLilyFile; this might be moved to a different module
%   System
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
export
   setup: Setup
   toScore: ToScore
   toScoreDouble: ToScoreDouble
   writeLilyFile: WriteLilyFile

define
   /** %% link Events with Durations.  Setting a value (or narrowing the domain) in either list will update the other list. */
   proc {Setup Beats BeatDivisionsGet Events Durations}
      NumEvents = Beats*BeatDivisionsGet
   in
      %% setup lists, add fake note at end
      Durations = {FD.list NumEvents 0#NumEvents}
      Events = {FD.list NumEvents+1 0#2}
      %% tmp comment
      {Nth Events NumEvents+1} =: 1

      %% first onset can't be "continue note"
      {Nth Events 1} \=: 0

      for X in 1..NumEvents do

	 %% setup maxmium durations
	 {Nth Durations X} =<: NumEvents+1-X


	 %% align rests
	 {FD.equi
	  ({Nth Durations X} =: 0)
	  ({Nth Events X} =: 0)
	  1}


	 %% align 1 dur
	 {FD.equi
	  {Nth Durations X} =: 1
	  {FD.conj 
	   ({Nth Events X} >: 0)
	   ({Nth Events X+1} >: 0)
	  }
	  1}


	 %% align 2+ dur
	 for D in 2..NumEvents do
	    if ( X =< (NumEvents+1-D) ) then
	       {FD.equi
		({Nth Durations X} =: D)
		{FD.conj 
		 ({Nth Events X} >: 0)
		 {FoldR
		  {LUtils.sublist Events X+1 X+D-1}
		  fun {$ X Y}
		     {FD.conj (X=:0) Y}
		  end
		  ({Nth Events X+D} >: 0)
		 }
		}
		1}
	    end
	 end
      end
      
   end

   %% internal for ToScore
   fun {EventsIn Events}
      {FoldL Events fun {$ X Y} if Y>0 then X+1 else X end end
       0} - 1
   end

   %% internal for ToScore
   proc {GetNotes Events Durations ?Notes}
      NumNotes = {EventsIn Events}
      Y = {NewCell 1}
   in
      Notes = {List.make NumNotes}
      for X in 1..{Length Durations}
      do
	 if {Nth Events X}==1 then
	    {Nth Notes @Y} = {Nth Durations X}
	    Y := @Y + 1
	 end
	 if {Nth Events X}==2 then
	    {Nth Notes @Y} = {Number.'~' {Nth Durations X}}
	    Y := @Y + 1
	 end
      end
   end

   /* %% Combines the Events and Durations and produces a Score object. */
   proc {ToScore EventsDurs BeatDivisions ?ScoreInstance}
      Notes = {GetNotes EventsDurs.1 EventsDurs.2}
   in
      {Score.makeScore
       seq(info:staff
	   items:(
		  {Map Notes fun {$ Note}
				if (Note>0) then
				   note(duration:Note
					pitch:60
					amplitude:64)
				else
				   pause(duration:{Number.abs Note})
				end
			     end})
	   startTime:0
	   timeUnit:beats(BeatDivisions))
       unit ScoreInstance}
      {ScoreInstance wait}
   end

   /* %% Combines the Events and Durations and produces a Score
   * object.  Repeats the events and durs -- ie 1 bar becomes 2
   * bars. */
   proc {ToScoreDouble EventDurs BeatDivisions ?ScoreInstance}
      %% play games to avoid duplicating the "extra 1"
      Events = {Append {Append
			{List.take EventDurs.1 {Length EventDurs.1}-1}
			{List.take EventDurs.1 {Length EventDurs.1}-1}
		       } [1]}
      Durs = {Append EventDurs.2 EventDurs.2}
   in
      ScoreInstance = {ToScore Events#Durs BeatDivisions}
   end


   OutClauses = [isPause#
		 fun {$ MyPause}
		    %%  returns a list of Lilypond rhythm
		    %%  values matching dur of MyPause
		    Rhythms = {Out.lilyMakeRhythms
			       {MyPause getDurationParameter($)}}
		 in
		    %% if pause duration is 0 or
		    %% too short (less than a 64th
		    %% note, or 0.0625 beat)
		    if Rhythms == nil
		    then '' % omit pause
		       %% otherwise output VS
		       %% of Lily pause(s)
		    else {Out.listToVS
			  {Map Rhythms
			   fun {$ R} r#R end}
			  " "}
		    end
		 end
		 %% make sure only seqs representing staffs
		 %% are turned into staffs in Lilypond
		 fun {$ X}
		    {X isSequential($)} andthen {X hasThisInfo($ staff)}
		 end#fun {$ Staff}
			"\\new RhythmicStaff"#
			{Out.seqToLily Staff OutClauses}
		     end
		]
   C={NewCell 1}
   /* %% outputs a Score to a file.  Adds support for rests (ie 'pause' events) and RhythmicStaff. */
   proc {WriteLilyFile BaseFilename MyScore}
      Filename=BaseFilename#@C
   in
      {Out.outputLilypond
       MyScore
       unit(file:Filename
	    clauses:OutClauses
	   )}
      C:=@C+1
   end


end
