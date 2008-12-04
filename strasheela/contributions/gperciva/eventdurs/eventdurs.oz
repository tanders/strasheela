/** %% EventDurs facilitates creating short rhythmic exercises. */

functor
import
   FD
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'

%    Browser(browse:Browse) % temp for debugging
export
   setup: Setup
   toScore: ToScore
   toScoreDouble: ToScoreDouble
   writeLilyFile: WriteLilyFile
   writeOnsetFile: WriteOnsetFile

define
   /** %% link Events with Durations.  Setting a value (or narrowing the domain) in either list will update the other list.

   NB: the Event list has a "courtesy one" at the end.*/
proc {Setup Beats BeatDivisions Events Durations}
   NumEvents = Beats*BeatDivisions
in
   %% setup lists, add fake note at end
   Durations = {FD.list NumEvents 0#NumEvents}
   Events = {FD.list NumEvents+1 0#2}
   %% "courtesy one" to simply Duration defintions
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

/** %% Combines the Events and Durations and produces a Score object. */
proc {ToScore EventsDurs BeatDivisions ?ScoreInstance}
   Durs = {GetNotes EventsDurs.1 EventsDurs.2}
in
   {Score.makeScore
    seq(info:[lily(" \\new RhythmicStaff")
	      staff]
	items:(
	       {Map Durs fun {$ Dur}
			    if (Dur<0) then
			       pause(duration:{Number.abs Dur})
			    else
			       note(duration:Dur
				    pitch:60
				    amplitude:64)
			    end
			 end})
	startTime:0
	timeUnit:beats(BeatDivisions))
    unit ScoreInstance}
   {ScoreInstance wait}
end

/** %% Combines the Events and Durations and produces a Score
* object.  Repeats the events and durs -- ie 1 bar becomes 2
* bars. */
proc {ToScoreDouble EventDurs BeatDivisions ?ScoreInstance}
   %% play games to avoid duplicating the "extra 1"
   Events = {Append {Append
		     {LUtils.butLast EventDurs.1}
		     {LUtils.butLast EventDurs.1}
		    } [1]}
   Durs = {Append EventDurs.2 EventDurs.2}
in
   ScoreInstance = {ToScore Events#Durs BeatDivisions}
end


/** %% outputs a Score to a file.  This supports triplets. */

C={NewCell 1}
proc {WriteLilyFile BaseFilename BeatDivisions MyScore}
   Filename
   OutClauses
   Pad
in
   if (@C<10) then
     Pad = '000'#@C
   elseif (@C<100) then
     Pad = '00'#@C
   elseif (@C<1000) then
     Pad = '0'#@C
   end
   Filename = BaseFilename#Pad
   if ({Int.'mod' BeatDivisions 3} == 0) then
      OutClauses = {Out.makeLilyTupletClauses [2#3]}
   else
      OutClauses = nil
   end
   {Out.outputLilypond
    MyScore
    unit(file:Filename clauses:OutClauses
	 implicitStaffs:false
	 wrapper:"\\score{"#(" \\layout{}\n \\midi{}\n}\n"#"")
	 unit)}
   C:=@C+1
end

D={NewCell 1}
proc {WriteOnsetFile BaseFilename EventDurs}
   % for some reason, Out.writeToFile doesn't prepend
   % the temp dir, whereas Out.outputLilypond does.
   Filename
   Pad
   Events = {LUtils.butLast EventDurs.1}
   Ascii = {Map Events fun {$ X} (X + 48) end}
in
   if (@D<10) then
     Pad = '000'#@D
   elseif (@D<100) then
     Pad = '00'#@D
   elseif (@D<1000) then
     Pad = '0'#@D
   end
   Filename = '/tmp/'#BaseFilename#Pad#'.txt'
   {Out.writeToFile Ascii#' ' Filename}
   D:=@D+1
end

end
