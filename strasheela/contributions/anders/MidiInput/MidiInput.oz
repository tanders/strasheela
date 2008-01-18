
%%% *************************************************************
%%% Copyright (C) Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% This functor defines MIDI import for Strasheela. Similar to the MIDI output functor, this functor relies on midicsv (see http://www.fourmilab.ch/webtools/midicsv/). A MIDI file is transformed into a midicsv text file with the procedure RenderCSVFile. This text file is read into a list of Oz values (MIDI events) with the function ParseCSVFile. The format of this event list is exactly the same as the format supported and documented by the  MIDI output functor. 
%%
%% You may use this list of MIDI events directly. Alternatively, it can be transformed into a Strasheela score using the functions EventsToNestedEvents and NestedEventsToScore. Examples for both approaches are provided in the test file (../testing/MidiInput-test.oz).
%%
%% This functor is provided as a contribution (i.e. not as part of the Strasheela core), because its compilation requires a C++ compiler, which is not necessarily available on all systems (especially not on Windows).
%% */

functor 
import
   RecordC
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   MyParser(parseCSVFile:ParseCSVFile
	   renderCSVFile:RenderCSVFile) at 'source/ParserWrapper.ozf'
   
export
   ParseCSVFile
   RenderCSVFile

   PairNoteEvents
   EventsToNestedEvents
   NestedEventsToScore
   
define

%   ParseCSVFile = MyParser.parseCSVFile
%   RenderCSVFile = MyParser.renderCSVFile


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Process event lists
%%%%
   
   /** %% Expects a list of CSV Events. All note-on events and their corresponding note-off events are grouped into matching pairs NoteOn#NoteOff. All other events are passed unaltered.
   %% PairNoteEvents finds for every note-on event the first following note-off event with the same pitch and channel. Note that in case there is no corresponding note-off event, the returned note pair is NoteOn#nil. 
   %% */
   fun {PairNoteEvents Events}
      {Filter			% removes nils
       {Pattern.mapTail Events
	fun {$ H | T}
	   if {Out.midi.isNoteOn H}
	   then H # {LUtils.find T fun {$ X}
				      {Out.midi.isNoteOff X}
				      andthen {GetPitch H} == {GetPitch X}
				      andthen {GetChannel H} == {GetChannel X}
				   end}
	   elseif {Out.midi.isNoteOff H}
	   then unit			% remove later
	   else H				% leave all other events untouched
	   end
	end}
       fun {$ X} X \= unit end} 
   end
   
   /** %% Expects a list of CSV events and returns a nested record. The top-level record (label tracks) sorts the events by their track number. The features of this record are the different track numbers, and their values are a list of records which (nested) contain only events of that track number. These records and the second nesting level (label channels) sort events by channel numbers. The features of the record are the different channel numbers and their values are lists of events of that channel. Events without channel number are placed at the record feature nil. Finally, note events are grouped into pairs NoteOn#NoteOff.
   %% */
   %% I don't directly transform the event list into a nested Strasheela score object, so that the user can control how this transformation process is done (e.g., which objects are transformed, and into what score objects).
   %% To decide: shall I make the nesting controllable -- currently there always result three levels of nested contains, which may be too much (e.g., I seldomly need tracks put in their own container and sometimes even different containers for channels may be too much). However, the advantage of this fixed nesting is that I can rely on it. And if I only need some subcontainers, I can always extract them from the result
   fun {EventsToNestedEvents Events}
      {Record.map
       %% sort into sublists by track
       {SortIntoCategories Events fun {$ X} X.track end tracks}
       %% sort into sublists by channel
       %% Note: only specific events have channel param
       fun {$ TrackEvents}
	  {Record.map {SortIntoCategories TrackEvents GetChannel track}
	   fun {$ ChanEvents}
	      {List.toTuple channel {PairNoteEvents ChanEvents}}
	   end}
       end}
   end

   local
      %% default clauses for NestedEventsToScore
      Defaults = unit(clauses:[%% full score case
			       fun {$ X} {Label X} == tracks end
			       # fun {$ X}
				    Items = {Record.toList X}
				 in
				    if Items == nil then nil
				    else sim(info:score
					     %% track elements already transformed
					     items:Items
					     %startTime:0
					     %timeUnit:beats
					    )
				    end
				 end
			       %% single track case
			       fun {$ X} {Label X} == track end
			       # fun {$ X}
				    Items = {Record.toList X}
				 in
				    if Items == nil then nil
				    else sim(info:track
					     items:Items)
				    end
				 end
			       %% single channel case 
			       fun {$ X} {Label X} == channel end
			       # fun {$ X}
				    Items = {Record.toList X}
				 in
				    if Items == nil then nil
				    else
				       IsSeq = {All {Pattern.map2Neighbours Items
						     fun {$ X Y} X.endTime =< Y.startTime end}
						fun {$ B} B end}
				    in
				       if IsSeq
				       then seq(info:channel
						items:Items)
				       else sim(info:channel
						items:Items)
				       end
				    end
				 end
			       %% note case
			       fun {$ X}
				  {Label X} == '#' andthen
				  {Out.midi.isNoteOn X.1}
			       end
			       # fun {$ csv(parameters:[Chan Pitch Velo]
					    time:Start ...) # csv(time:End ...)}
				    note(startTime:{Out.midi.ticksToBeats Start}
					 endTime:{Out.midi.ticksToBeats End} 
					 pitch:Pitch
					 amplitude:Velo
					 channel:Chan)
				 end])
   in
      /** %% Expects a nested CSV event list as returned by EventsToNestedEvents, and returns a textual Strasheela score. The optional arg clauses (in Args) expects a list of Test#Process pairs, where Test is a boolean function and Process is a transformation function. Test expects an element in the hierarchy of the result of EventsToNestedEvents, and if it returns true then Process expects this element as argument and returns a transformation (a textual Strasheela score object). If it returns nil, then the next clause is tried. When process returns nil, then its output is omitted from the result. Note that the score transformation happens from the inside to the outside, i.e., when  a container datum is transformed its elements are transformed already. 
      %% The default clauses (see source) result in a hierarchic score whose elements are the MIDI notes (i.e., all other MIDI events are skipped by default). Support for additional MIDI events is added simply by adding further Test#Process clauses. The score topology follows the hierarchic nesting returned by EventsToNestedEvents (see below). Whether the channel container is a simultaneous container or a sequential container depends on whether the notes in the container overlap in time (in that case a sim is created, a seq otherwise).
      
      sim(info:score
	  items:[sim(info:track
		     items:[seq(info:channel
				items:[Note1 Note2 ..])
			    ...])
		 ...])

      %% 
      %%
      %% */
      %% BTW: clauses provide implcit test: if no clause matches, the event is skipped
      %%
      %% TODO
      %%
      %% -  When we have an extended music representation for stuff like continuous controllers, meter/key sign etc., then we may add default clauses for these to NestedEventsToScore
      %%
      %% - generalise: I may later want to group lots of CC messages into a single object: EventsToNestedEvents/NestedEventsToScore don't support that yet
      %%
      fun {NestedEventsToScore NestedEvents Args}
	 As = {Adjoin Defaults Args}
	 fun {FilterOutNils R} {Record.filter R fun {$ X} X \= nil end} end
      in
	 %% NB: NestedEventsToScore ignores some information in the input: the feature-names of the nested records
	 %% To decide: shall I change the definition into a recursive variant which can handle arbitrary nesting? Hm, do I really need that -- instead I may simply process the result and extract some nested records
	 %%
	 %% I know that NestedEvents is a record of records of events
	 {GUtils.cases
	  {FilterOutNils
	   {Record.map NestedEvents
	    fun {$ TrackEvents} 
	       {GUtils.cases
		{FilterOutNils
		 {Record.map TrackEvents
		  fun {$ ChanEvents} 
		     %% filter out events for which no clause matched
		     %% (in which case GUtils.cases returns nil)
		     {GUtils.cases
		      {FilterOutNils {Record.map ChanEvents
				      fun {$ Event}
					 {GUtils.cases Event As.clauses}
				      end}}
		      As.clauses}
		  end}}
		As.clauses}
	    end}}
	  As.clauses}
      end
   end
   
   %%
   %% aux defs
   %%
   
   /* %% [aux] Expects a list of CSV Events and returns a record with label L. The sorting condition is GetSortFeat, a function expecting an element of Events and returning the categorising feature (e.g., the track number). These categorising features are also the features of the returned record. The value at a given feature is a list of events for which GetSortFeat returned this feature (e.g., all events of a specific track number).
   %% */
   fun {SortIntoCategories Events GetSortFeat L}
      IDs Tmp
      proc {CloseRecord R} {Length {RecordC.reflectArity R}} = {RecordC.width R} end
   in
      %% first collect all sort feature values
      IDs = L(...)
      {ForAll Events proc {$ X} IDs ^ {GetSortFeat X} = unit end}
      {CloseRecord IDs}
      %% then collect the events in sublists corresponding to their sort
      %% feat, using extendable lists
      Tmp = {Record.clone IDs} 
      {Record.forAll Tmp proc {$ X} X={New LUtils.extendableList init} end}
      {ForAll Events
       proc {$ X} {Tmp.{GetSortFeat X} add(X)} end}
      %% finally return record with plain lists
      {Record.map Tmp fun {$ XList} {XList close} XList.list end}
   end
   
   /** %% Returns the pitch of a note CSV event.
   %% */
   fun {GetPitch csv(parameters:[_ Pitch _] ...)} Pitch end

   /** %% Returns the channel of a CSV event. In case no channel is defined for the type of the event, nil is returned.
   %% */
   fun {GetChannel X}
      if {Out.midi.hasChannel X}
      then case X of csv(parameters:Channel|_ ...)
	   then Channel 
	   end
      else nil
      end
   end
   
end
