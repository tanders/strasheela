
%%
%% This file contains a number of rhythmic examples based on the notion of constraining accents (notes that meet a number of given conditions) to certain metric positions.
%% These examples clearly focus on rhythm and accent constraint (e.g., in the beginning they even use constraint pitches), but they could be complemented by constrains on other aspects.
%%
%% Usage: first feed buffer, then feed actual examples in block comments.
%%

%% For ideas for further examples see ./strasheela/trunk/strasheela/others/TODO/Strasheela-TODO.org::*Application examples 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Examples
%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Example with only a single simple accent constraint
%%%

%%
%% Example with only a single simple accent constraint:
%% Notes that are at least of duration quarter note count as accentuated notes.
%% Every accented note must be on a metric accent of 4/4, but there can be metric accents without such notes.
%% In this relatively simple example, all solutions are found.
%%

/*


declare
Beat = 4
proc {MyScript MyScore}
   MyScore = {Score.make sim([seq([note note note note note note note note
				   note note note note note note note note])
			      seq([measure(n: 8
					   beatNumber: 4
					   beatDuration: Beat)])]
			     startTime:0
			     timeUnit:beats(Beat))
	      add(note: fun {$ _}
			   {Score.make2 note(duration: {FD.int [2 4]}
					     pitch: {FD.int 60})
			    unit(note:Measure.note)}
			end
		  measure: Measure.uniformMeasures)}
   %% 
   {ForAll {MyScore collect($ test:isNote)}
    proc {$ N}
       {Measure.accent_If N [{Measure.make_HasAtLeastDuration Beat}] 
	%% If the accent rating of a note exceeds the default minRating 1, then this note is positioned on an accentuated beat of the 4/4 measure
	unit(strictness: note % note position noteAndPosition
	     metricPosition: accent % Beat*2 beat accent measureStart
	    )}
    end}      
end
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreAll MyScript
 unit(order:leftToRight
      value:random)}


*/

/*

declare
{GUtils.setRandomGeneratorSeed 0}
[MyScore] = {SDistro.searchOne MyScript
	     unit(order:leftToRight
		  value:random)}

{MyScore toInitRecord($)}

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Example combining two accent constraints
%%%

%%
%% Accented notes have either at least the note value of a quarter note, or they are preceded by a skip. Accents mut be positioned on an accentuated beat of 5/4 (by default the accents of 5/4 are the 1st and 4th beat)
%%
%% Note that other means exist to express an accent (e.g., an anacrusis consisting only in steps would not be taken into account in this example). The strength of Measure.accent_If is that users can define what they consider is an accent (and many cases are predefined already).
%%

/*


declare
Beat = 4
proc {MyScript MyScore}
   MyScore = {Score.make sim([seq([note note note note note note note note
				   note note note note note note note note])
			      seq([measure(n: 8
					   beatNumber: 5
					   beatDuration: Beat)])]
			     startTime:0
			     timeUnit:beats(Beat))
	      add(note: fun {$ _}
			   {Score.make2 note(duration: {FD.int [2 4]}
					     pitch: {FD.int [60 62 64 65 67 69 71 72]})
			    unit(note:Measure.note)}
			end
		  measure: Measure.uniformMeasures)}
   %% 
   {ForAll {MyScore collect($ test:isNote)}
    proc {$ N}
       {Measure.accent_If N [{Measure.make_HasAtLeastDuration Beat}
			     Measure.isSkip] 
	unit(strictness: note % note position noteAndPosition
	     metricPosition: accent % Beat*2 beat accent measureStart
	    )}
    end}      
end
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript
 unit(order:leftToRight
      value:random)}

*/


/*

declare
{GUtils.setRandomGeneratorSeed 0}
[MyScore] = {SDistro.searchOne MyScript
	     unit(order:leftToRight
		  value:random)}

{MyScore toInitRecord($)}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Examples with rests 
%%%

/*


declare
Beat = 4
/** %% Definition of a simple accent constraint. An accent constraint expects a note (an item) and returns a rating, where higher values mean that the accent constraint's condition is met better by N. In this simple case, IsAtLeastQuarterNote returns 1 for a note with a note value of a beat or more and 0 otherwise.  
%% */
fun {IsAtLeastQuarterNote N}
   ({N getDuration($)} >=: Beat)
end
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne
 proc {$ MyScore}
    MyScore = {Score.make sim([seq([note note note note note note note note
				    note note note note note note note note]
				   offsetTime: {FD.int [0 Beat Beat+(Beat div 2)]})
			       seq([measure(n: 8
					    beatNumber: 5
					    beatDuration: Beat)])]
			      startTime:0
			      timeUnit:beats(Beat))
	       add(note: fun {$ _}
			    {Score.make2 note(duration: {FD.int [(Beat div 2) Beat]}
					      pitch: {FD.int 60}
					      offsetTime: {FD.int [0 Beat Beat+(Beat div 2)]})
			     unit(note:Measure.note)}
			 end
		   measure: Measure.uniformMeasures)}
    %% 
    {ForAll {MyScore collect($ test:isNote)}
     proc {$ N}
	{Measure.accent_If N [IsAtLeastQuarterNote] % Measure.isLongerThanSurrounding
	 unit(strictness: noteAndPosition % note position noteAndPosition
	      metricPosition: measureStart % Beat*2 beat accent measureStart
	     )}
     end}
    %% Restrict total sum of offset times 
    %% Without heuristic constraints, most rests will be in the beginning (a relevant heursitic constraint would require also distributing the offset times)
    Beat*5 >: {LUtils.accum {MyScore map($ getOffsetTime test:isNote)}
	       FD.plus}
 end
 unit(order:leftToRight
      value:random)}

   
*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Example with anacrusis: simple case
%%%

/*


declare
Beat = 4
proc {MyScript MyScore}
   Ns
in
   MyScore = {Score.make sim([seq([note note note note note note note note
				   note note note note note note note note]
				  offsetTime: {FD.int 12#19})
			      seq([measure(n: 8
					   beatNumber: 5
					   beatDuration: Beat)])]
			     startTime:0
			     timeUnit:beats(Beat))
	      add(note: fun {$ _}
			   {Score.make2 note(duration: {FD.int [1 2 4]}
					     pitch: 60)
			    unit(note:Measure.note)}
			end
		  measure: Measure.uniformMeasures)}
   Ns = {MyScore collect($ test:isNote)}
   %% 
   {ForAll Ns
    proc {$ N}
       {Measure.accent_If N [{Measure.make_HasAnacrusis
			      unit(ratingPs: [Measure.anacrusis_FirstNEvenDurations]
				   requirements: [Measure.anacrusis_AccentLonger])}] 
	unit(strictness: note % note position noteAndPosition
	     metricPosition: beat % Beat*2 beat accent measureStart
	    )}
    end}
   %% NOTE: 1st note with forced accent rating. Otherwise, its rating may be unconstrained and thus some random value
   {Ns.1 getAccentRating($)} = 0
end
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript
 unit(order:leftToRight
      value:random)}
  

*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 
%%% Additional constraints: 
%%%  - pitch affects anacrusis as well
%%%  - require a minimum number of higher accent ratings
%%%  - ensure that the 1st note is not syncopated
%%% 
%%%


/*


declare
Beat = 4
proc {MyScript MyScore}
   Ns Measures
in
   MyScore = {Score.make sim([seq([note note note note note note note note
				   note note note note note note note note]
				  offsetTime: {FD.int 12#19})
			      seq([measure(n: 8
					   beatNumber: 5
					   beatDuration: Beat)])]
			     startTime:0
			     timeUnit:beats(Beat))
	      add(note: fun {$ _}
			   {Score.make2 note(duration: {FD.int [1 2 4]}
					     pitch: {FD.int 60#72}
					    )
			    unit(note:Measure.note)}
			end
		  measure: Measure.uniformMeasures)}
   Ns = {MyScore collect($ test:isNote)}
   [Measures] = {MyScore collect($ test:Measure.isUniformMeasures)}
   %% 
   {ForAll Ns
    proc {$ N}
       {Measure.accent_If N [{Measure.make_HasAnacrusis
			      unit(requirements: [Measure.anacrusis_AccentLonger]
				   ratingPs: [Measure.anacrusis_FirstNPossibilyShorterTowardsAccent
					      Measure.anacrusis_FirstNUpwardPitchIntervals])}] 
	unit(strictness: note % note position noteAndPosition
	     metricPosition: beat % Beat*2 beat accent measureStart
	    )}
    end}
   %% Num1+Num2 notes have at least an accent rating of 3
   local
      Num1 = 1
      Num2 = 2
      L = {Length Ns}
      Ns1 Ns2
   in
      %%  Make search cheaper by explicitly constraining that a certain amount of higher accent ratings is in certain sections of Ns 
      {List.takeDrop Ns (L div 2) Ns1 Ns2}
      {Pattern.howManyTrue {Map Ns1
			    fun {$ N} {N getAccentRating($)} >=: 3 end}
       Num1}
      {Pattern.howManyTrue {Map Ns2
			    fun {$ N} {N getAccentRating($)} >=: 3 end}
       Num2}
   end
   %% NOTE: 1st note with forced accent rating. Otherwise, its rating may be unconstrained and thus some random value
   {Ns.1 getAccentRating($)} = 0
   %% 1st note is *not* syncopated
   {Measures beatSyncopationR(0 {Ns.1 getStartTime($)} {Ns.1 getEndTime($)})} 
end
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne MyScript
 unit(order:leftToRight
      value:random)}

*/

/*
  
declare
{GUtils.setRandomGeneratorSeed 0}
[MyScore] = {SDistro.searchOne MyScript
	     unit(order:leftToRight
		  value:random)}
  
{MyScore toInitRecord($)}
  
*/
  
  
  
  
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  - Longer note at end of phrase (which will not be accent-syncopated)
%%%  - In addition to anacrusis, pitch skips are taken into account in the metric rating
%%%

      
%%
%% Note: combining anacrusis constraints with other accent constraints can result in very expensive search (is there a bug?)     
%%

/*

declare
Beat = 4
%% NOTE: when turning into a sub-CSP, put measure def outside
proc {RhythmicPhrase ?MyScore}
   %% The defaults can later be overwritten by some sub-CSP arguments
   Defaults = unit(%% of note's seq
		   offsetTimeDomain: 12#19
		   durDomain: [1 2 4] % for all but the last note
		   lastDurDomain: [8] % last note's domain
		  )
   MyPart Ns
   Measures
in
   MyPart = {Score.makeSeq unit(iargs: unit(constructor: Measure.note
					    n: 16
					    pitch: fd#(60#72))
				offsetTime: {FD.int Defaults.offsetTimeDomain})}
   MyScore = {Score.make
	      sim([MyPart
		   seq([measure(n: 8
				beatNumber: 5
				beatDuration: Beat)])]
		  startTime:0
		  timeUnit:beats(Beat))
	      add(measure: Measure.uniformMeasures)}
   Ns = {MyPart collect($ test:isNote)}
   [Measures] = {MyScore collect($ test:Measure.isUniformMeasures)}
   %% 
   {ForAll Ns
    proc {$ N}
       {Measure.accent_If N
	%% List of accent constraints
	[% Measure.isSkip
	 %% Note: makes search clearly more expensive
             % Measure.isHigherThanSurrounding_Rated
	 {Measure.make_HasAnacrusis
	  unit(requirements: [Measure.anacrusis_AccentLonger]
	       ratingPs: [Measure.anacrusis_FirstNPossibilyShorterTowardsAccent
			  Measure.anacrusis_FirstNUpwardPitchIntervals])}] 
	unit(strictness: note % note position noteAndPosition
	     metricPosition: beat % Beat*2 beat accent measureStart
	    )}
    end}
   %% Dur domains
   {ForAll {LUtils.butLast Ns}
    proc {$ N} {N getDuration($)} = {FD.int Defaults.durDomain} end}
   {{List.last Ns} getDuration($)} = {FD.int Defaults.lastDurDomain}
   %% Num1+Num2 notes have at least an accent rating of 3
   local % FIXME: tmp setting 0
      Num1 = 1 % 0
      Num2 = 2 % 0
      L = {Length Ns}
      Ns1 Ns2
   in
      %%  Make search cheaper by explicitly constraining that a certain amount of higher accent ratings is in certain sections of Ns 
      {List.takeDrop Ns (L div 2) Ns1 Ns2}
      {Pattern.howManyTrue {Map Ns1
			    fun {$ N} {N getAccentRating($)} >=: 3 end}
       Num1}
      {Pattern.howManyTrue {Map Ns2
			    fun {$ N} {N getAccentRating($)} >=: 3 end}
       Num2}
   end
   %% NOTE: 1st note with forced accent rating. Otherwise, its rating may be unconstrained and thus some random value
   {Ns.1 getAccentRating($)} = 0
   %% 1st note is *not* beat syncopated, nor is the last accent syncopated
   {Measures beatSyncopationR(0 {Ns.1 getStartTime($)} {Ns.1 getEndTime($)})}
   {Measures accentSyncopationR(0 {{List.last Ns} getStartTime($)}
				{{List.last Ns} getEndTime($)})}
   %% Intervals between local maxima are steps (no repetition) that
   %% ?? form an arch
   %% NOTE: very expensive constraint; consider adding constraint to determine local max (e.g., using Pattern.localMaxR or Pattern.contour
   %% Problem with doing so: local max likely have > 0 accent rating, and I cannot predetermine where these should be. I could slighly help by requiring that higher accent ratings mean local max and no others are local max.
           % {Pattern.constrainLocalMax {MyScore map($ getPitch test:isNote)}
           %  Pattern.increasing
           %  % proc {$ Xs}
           %  % end
           % }
   %%
   %% Rhythmic imitation within the same voice
   %% This seems to be also very expensive. 
   %% Would be a good idea to have arg timeRange instead of numericRange to ensure that metric position works
   {Segs.texture Segs.homophonic MyPart [MyPart]
    unit(numericRange: [2#3]
	 offsetTime: 20)}
end     
{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne RhythmicPhrase
 unit(order:leftToRight
      value:random)}


*/


/*
        
declare
{GUtils.setRandomGeneratorSeed 0}
[MyScore] = {SDistro.searchOne RhythmicPhrase
	     unit(order:leftToRight
		  value:random)}
        
{MyScore toInitRecord($)}
        
*/
        
        


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% 
%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Aux defs
%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Notation output:
%%% The Fomus output also prints accent ratings > 0 (for notes that inherited the accent rating mixing )
%%%

declare

/** %% [Note markup function] Expects two Fomus markup records (e.g., unit(marks: ['x "x"']), the value returned by MakeNonChordTone_FomusMarks) and returns a single record with those marks combined.  
%% */
%% TODO: save in core Output.oz or contributions/anders/HarmonisedScore/source/Output.oz
fun {AppendFomusMarks Mark1 Mark2}
   Ms1 = {Value.condSelect Mark1 marks nil} 
   Ms2 = {Value.condSelect Mark2 marks nil}
in
   %% TMP:
   {Browse AppendFomusMarks#{Adjoin unit(marks: {Append Ms1 Ms2})
			     {Adjoin Mark1 Mark2}}}
   {Adjoin unit(marks: {Append Ms1 Ms2})
    {Adjoin Mark1 Mark2}}
end


/** %% [markup function] Expects a VS and returns a Fomus markup record.
%%
%% Args:
%% 'where' (default 'x'): atom in Fomus syntax where to position the VS (e.g., 'x', 'x^', 'x_' or 'x!', see http://fomus.sourceforge.net/doc.html/Articulation-Markings-_0028File_0029.html#Articulation-Markings-_0028File_0029). 
%% */
%% TODO: save in core Output.oz or contributions/anders/HarmonisedScore/source/Output.oz
fun {VsToFomusMarks VS Args}
   Default = unit(where: 'x')
   As = {Adjoin Default Args}
in
   if {Not {IsVirtualString VS}}
   then raise noVS(VS) end
      unit % never returned 
   else unit(marks: [As.where#" \""#VS#"\""])
   end
end
   
LilyHeader 
= {VirtualString.toString
   {Out.listToLines
    ["\\paper {"
     " indent=0\\mm"
     " line-width=180\\mm" 
     " oddFooterMarkup=##f"
     " oddHeaderMarkup=##f"
     " bookTitleMarkup=#ff"
     " scoreTitleMarkup=##f"
     " }"
     ""
     "\\layout {"
     "\\context {"
     "\\Voice \\remove \"Note_heads_engraver\""
     "\\remove \"Forbid_line_break_engraver\""
     "\\consists \"Completion_heads_engraver\""
     "}"
     "} "
     ""
%     "\\score{\n{\n"
    ]}}

proc {RenderFomus MyScore Args}
   %% TMP (replace by new method addToInfoRecord)
   %% TODO: make this optional
   {MyScore
    addInfo(fomus('lily-file-header': LilyHeader
		  'lily-exe-args': '("--png" "--pdf" "-dbackend=eps" "-dno-gs-load-fonts" "-dinclude-eps-fonts")'
                  % 'lily-exe-args': '("--format=png" "--format=pdf")'
                  % 'lily-exe-args': '("-dbackend=eps")'
		 ))}
   {Out.renderFomus MyScore
    {Adjoin unit(eventClauses:
		    [ %% for HS notes
		      {HS.out.makeNoteToFomusClause
		       unit(% getPitchClass: midi
			    table: ET31.out.fomusPCs_DoubleAccs
                           % table:ET31.out.fomusPCs_Quartertones
			    getSettings:
			       fun {$ N}
				  TextMarks = {VsToFomusMarks {N getAccentRating($)}
					       unit(where: 'x')}
			       in
				  {AppendFomusMarks TextMarks {HS.out.makeNonChordTone_FomusMarks N}}
			       end)}
		      %% for plain notes
		      Measure.isAccentRatingMixin
		      #fun {$ N PartId}
			  TextMarks = if {N getAccentRating($)} > 0
				      then {VsToFomusMarks {N getAccentRating($)}
                                                  % 'ar:'#{N getAccentRating($)}
					    unit(where: 'x^')}
				      else unit
				      end
		       in
			  {Out.record2FomusNote {Adjoin TextMarks
						 unit(part:PartId
						      time:{N getStartTimeInBeats($)}
						      dur:{N getDurationInBeats($)}
						      pitch:{N getPitchInMidi($)})}
			   N}
		       end
		      %% chords
		      {HS.out.makeChordToFomusClause
		       unit(% getPitchClass: midi
			    table: ET31.out.fomusPCs_DoubleAccs
			    getSettings:HS.out.makeChordComment_FomusForLilyMarks)}
		      %% scales
		      {HS.out.makeScaleToFomusClause
		       unit(% getPitchClass: midi
			    table: ET31.out.fomusPCs_DoubleAccs
			    getSettings:HS.out.makeScaleComment_FomusForLilyMarks)}
		      {Measure.out.makeUniformMeasuresToFomusClause unit(explicitTimeSig: false)}])
     Args}}
end


{Explorer.object
 add(information
     proc {$ I X}
	if {Score.isScoreObject X}
	then 
	   FileName = out#{GUtils.getCounterAndIncr}
	in
	   {Out.renderAndPlayCsound X
	    unit(file: FileName
		 title:I)}
	   {RenderFomus X unit(file: FileName)}
	end
     end
     label: 'to Csound and Fomus (with measures and accent ratings)')}

{Explorer.object
 add(information
     proc {$ I X}
	if {Score.isScoreObject X}
	then 
	   FileName = out#{GUtils.getCounterAndIncr}
	in
	   {RenderFomus X unit(file: FileName)}
	end
     end
     label: 'to Fomus (with measures and accent ratings)')}
