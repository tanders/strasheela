
%%
%% This file demonstrates features of the Lilypond output by a number
%% of examples. For simplicity, these examples directly create a
%% determined score and output it to Lilypond. Naturally, all these
%% features are also available for Lilypond output if you create your
%% score by constraint programming.
%%
%% These examples are sparsely documented. For further details please
%% see the Strasheela reference.
%%
%% As this file contains a number of examples, don't feed the whole
%% buffer. Instead feed one example after the other.
%%
%% All of Strasheela including contributions, Selection constraints,
%% Lilypond and a PDF viewer must be installed for these examples (see
%% the Strasheela installation instructions).
%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Dummy example: single note output
%%

declare
MyScore = {Score.makeScore note(duration:4
				pitch:60
				startTime:0
				timeUnit:beats)
	   unit}
{Out.renderAndShowLilypond MyScore
 unit(file:firstTest)}

%%

declare
MyScore = {Score.makeScore seq(items:[note(duration:4
					   pitch:60)]
			       startTime:0
			       timeUnit:beats)
	   unit}
{Out.renderAndShowLilypond MyScore
 unit(file:test)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% The Strasheela score topology sim(seq(...)+) results in the typical
%% Lilypond score layout with an extra staff for each sequential
%% directly contained in a top-level simultaneous container. Note
%% that the score can be further nested within the outmost sequential
%% containers corresponding to staffs. Also, note that item offset
%% times are notated as rests.
%%

%%
%% BUG: offset time must be inserted within container, not simply put before it.
%%

declare
MyScore = {Score.makeScore
	   sim(items:[ seq(items:[note(duration: 4
				       pitch: 60)
				  note(duration: 2
				       pitch: 62)
				  note(duration: 8
				       pitch: 64)])
		       seq(items:[note(duration: 4
				       pitch: 72)
				  note(duration: 8 
				       pitch: 67)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{Out.renderAndShowLilypond MyScore
 unit(file:defaultTopology)}


%%%%%


%% Further nesting: a seq in a seq and offset times for notes and containers 
declare
MyScore = {Score.makeScore
	   sim(offsetTime:4
	       items:[ seq(items:[note(duration: 4
				       pitch: 60)
				  seq(offsetTime: 2
				     items:[note(duration: 2
						 pitch: 62)
					    note(duration: 4
						 pitch: 64)])])
		       seq(items:[note(duration: 4
				       pitch: 72)
				  note(offsetTime: 4
				       duration: 4 
				       pitch: 67)]
			   offsetTime:4)]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{Out.renderAndShowLilypond MyScore
 unit(file:defaultTopology2)}


%%%%%


%% Inner nesting with a different effect: sims in a staff can express chords
declare
MyScore = {Score.makeScore
	   sim(items:[seq(items:[note(duration: 4
				      pitch: 60)
				 sim(offsetTime: 2
				     items:[note(offsetTime: 2
						 duration: 4
						 pitch: 62)
					    note(offsetTime: 2
						 duration: 8
						 pitch: 59)])])
		      seq(items:[note(duration: 4
				      pitch: 72)
				 note(duration: 4
				      pitch: 67)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{Out.renderAndShowLilypond MyScore
 unit(file:defaultTopology3)}


%%%%




%% Again, inner nesting with a different effect: sims in a staff can also express single staff polyphony
declare
MyScore = {Score.makeScore
	   sim(items:[seq(items:[note(duration: 4
				      pitch: 60)
				 sim(items:[seq(items:[note(duration: 4
							    pitch: 67)
						       note(duration: 8
							    pitch: 65)])
					    seq(offsetTime:2
						items:[note(duration: 2
							    pitch: 62)
						       note(duration: 4
							    pitch: 55)])])])
		      seq(items:[note(duration: 4
				      pitch: 72)
				 note(duration: 8
				      pitch: 71)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{Out.renderAndShowLilypond MyScore
 unit(file:defaultTopology4)}




%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Additional Lilypond code can be added to score items with the lily
%% info-tag (a tuple with legal Lilypond code strings)
%%

declare
MyScore = {Score.makeScore
	   sim(items:[seq(info:[lily("\\key d \\major \\time 3/4" "\\clef alto")]
			  items:[note(duration:8 pitch:64)
				 note(duration:8 pitch:64)])
		      seq(info:[lily("\\clef bass")]
			  items:[note(duration:4 pitch:60 info:lily("("))
				 note(duration:4 pitch:59 info:lily("\\staccato"))
				 note(duration:4 pitch:57 info:lily("\\mordent" "\\breathe"))
				 note(duration:4 pitch:55 info:lily(")"))
				])
		     ]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{Out.renderAndShowLilypond MyScore unit}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% The wrapper argument inserts Lilypond code at the beginning and end of the score (overwrites the default Lilypond score beginning and end)
%%

declare
MyScore = {Score.makeScore seq(items:[note(duration:4
					   pitch:60)]
			       startTime:0
			       timeUnit:beats)
	   unit}
{Out.renderAndShowLilypond MyScore
 unit(wrapper:[%% header
	       "\\paper {}"
	       #"\\header { title = \"Symphony\" composer = \"Me\" opus = \"Op. 9\" }"
	       #"\n\n{\n"
	       %% footer
	       "\n}"]
	file:wrappertest)}



%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Single voice polyphony and chords 
%%


declare
MyScore = {Score.makeScore
	   seq(items:[sim(items:[seq(items:[note(duration:2
						 pitch:72)
					    note(duration:2
						 pitch:71)
					    note(duration:2
						 pitch:69)
					    note(duration:2
						 pitch:67)])
				 seq(items:[note(duration:2
						 pitch:60)
					    note(duration:2
						 pitch:62)
					    note(duration:2
						 pitch:64)
					    note(duration:2
						 pitch:67)])])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{Out.renderAndShowLilypond MyScore
 unit}


%%%

declare
MyScore = {Score.makeScore
	   seq(items:[sim(items:[seq(items:[note(duration:2
						 pitch:72)
					    seq(items:[note(duration:2
							    pitch:71)
						       note(duration:2
							    pitch:69)
						       note(duration:2
							    pitch:67)])])
				 seq(items:[%% This nested sim results in a chord
					    sim(items:[note(duration:2
							    pitch:60)
						       note(duration:2
							    pitch:57)
						       note(duration:2
							    pitch:48)])
					    note(duration:2
						 pitch:62)
					    note(duration:2
						 pitch:64)
					    note(duration:2
						 pitch:67)])])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{Out.renderAndShowLilypond MyScore
 unit}

%% More complex case. Problematic: no staff implicitly created for
%% nested sims -- staffs created explicitly
declare
MyScore = {Score.makeScore
	   sim(items:[sim(info:lily("\\new Staff")
			  items:[seq(items:[note(duration:2
						 pitch:72)
					    note(duration:2
						 pitch:71)
					    note(duration:2
						 pitch:69)
					    note(duration:2
						 pitch:67)])
				 seq(items:[note(duration:2
						 pitch:60)
					    note(duration:2
						 pitch:62)
					    note(duration:2
						 pitch:64)
					    note(duration:2
						 pitch:67)])])
		      sim(info:lily("\\new Staff")
			  items:[seq(items:[note(duration:2
						 pitch:72)
					    note(duration:2
						 pitch:71)
					    note(duration:2
						 pitch:69)
					    note(duration:2
						 pitch:67)])
				 seq(items:[note(duration:2
						 pitch:60)
					    note(duration:2
						 pitch:62)
					    note(duration:2
						 pitch:64)
					    note(duration:2
						 pitch:67)])])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{Out.renderAndShowLilypond MyScore
 unit}




%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Enharmonic notation is supported for the class
%% HS.score.enharmonicNote (and other subclasses of
%% HS.score.enharmonicSpellingMixinForNote). Note that
%% {HS.db.getPitchePerOctave} must return 12 (which is the default). 
%%
%% Alternatively, enharmonic notation is supported for 31-tone equal
%% temperament which pitches such as C# or Db are different pitch
%% classes.
%%

declare
%% The functor ET12 exports functions for convenient pitch notation
%% for the common 12 pitches per octave, including accidentals.
%%
%% ET12.pitch returns a pitch integer which is not unambiguous
%% enharmonically, hence the accidental must be defined as well. The
%% class HS.score.enharmonicNote defines the parameter
%% cMajorAccidental (together with cMajorDegree) -- the name is choses
%% to clearly distinguish it from parameters such as scaleAccidental
%% or chordAccidental (see the doc of HS for details).
[ET12] = {ModuleLink ['x-ozlib://anders/strasheela/ET12/ET12.ozf']}
%%
MyScore = {Score.makeScore
	   seq(info:[lily("\\key d \\major \\time 3/4")]
	       items:[seq(items:[note(duration:2
				      %% pitch specified by a pair Pitchclass#Octave
				      pitch:{ET12.pitch 'D'#4}
				      %% natural accidental is ''
				      cMajorAccidental:{ET12.acc ''})
				 note(duration:1
				      pitch:{ET12.pitch 'Eb'#4}
				      %% flat accidental: b
				      cMajorAccidental:{ET12.acc 'b'})
				 note(duration:1
				      pitch:{ET12.pitch 'F#'#4}
				      cMajorAccidental:{ET12.acc '#'})
				 note(duration:2
				      pitch:{ET12.pitch 'G#'#4}
				      cMajorAccidental:{ET12.acc '#'})])
		      seq(info:lily("\\key f \\minor")
			  items:[note(duration:1
				      pitch:{ET12.pitch 'G'#4}
				      cMajorAccidental:{ET12.acc ''})
				 note(duration:1
				      pitch:{ET12.pitch 'Db'#4}
				      cMajorAccidental:{ET12.acc 'b'})
				 note(duration:1
				      pitch:{ET12.pitch 'E'#4}
				      cMajorAccidental:{ET12.acc ''})
				 note(duration:3
				      pitch:{ET12.pitch 'Gb'#4}
				      cMajorAccidental:{ET12.acc 'b'})])]
	       startTime:0
	       timeUnit:beats(2))
	   add(note:HS.score.enharmonicNote)}
%%
{Out.renderAndShowLilypond MyScore
 unit(file:enharmonicTest)}



%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Tuplet output
%%
%% Create clauses for tuplet support with the function
%% Out.makeLilyTupletClauses. This example also demonstrates how the
%% implicit staff drawing is disabled and an alternative staff is
%% explicitly specified instead.
%%


declare
/** %% Function for easy score creation: outputs a sequential container with notes and pauses. Durs is a list of durations (integers), pauses are represented by negative numbers. BeatDivision sets the score timeUnit to beats(BeatDivision). 
%% */
proc {MakeScore Durs BeatDivision ?ScoreInstance}
   ScoreInstance = {Score.makeScore
		    seq(info:[lily(" \\new RhythmicStaff")
			      staff]
			items:{Map Durs MakeElement}
			startTime:0
			timeUnit:beats(BeatDivision))
		    unit}
   {ScoreInstance wait}
end
%% aux definition
fun {MakeElement Dur}
   if (Dur < 0) then
      pause(duration:{Number.abs Dur})
   else
      note(duration:Dur
	   pitch:60
	   amplitude:64)	 
   end
end   


declare
%% produces triplets:
%% Resulting Lily code: c4 \times 2/3 {r8 c8 c} r8 r8 \times 2/3 {c4 c8}
Durations = [6 ~2 2 2 ~3 3 4 2]
BeatDivision = 6
MyScore = {MakeScore Durations BeatDivision}
{Out.renderAndShowLilypond MyScore
 unit(file:'triplet-test'
      implicitStaffs:false
      %% definition of pause output
      clauses:{Out.makeLilyTupletClauses [2#3]})}


declare
%% produces triplets and dotted notes (no dotted triplets)
Durations = [6 ~2 2 2 3 3 4 2 9 3 6 2 4]
BeatDivision = 6
MyScore = {MakeScore Durations BeatDivision}
{Out.renderAndShowLilypond MyScore
 unit(file:'triplet-test-2'
      implicitStaffs:false
      %% definition of pause output
      clauses:{Out.makeLilyTupletClauses [2#3]})}

declare
%% produces quintuplets
Durations = [10 2 ~2 2 2 ~2 ~5 5 4 2 ~4]
BeatDivision = 10
MyScore = {MakeScore Durations BeatDivision}
{Out.renderAndShowLilypond MyScore
 unit(file:'quintuplet-test'
      implicitStaffs:false
      %% definition of pause output
      clauses:{Out.makeLilyTupletClauses [2#5]})}


declare
%% produces triplets and quintuplets (nested tuplets not supported)
Durations = [60 20 20 ~20 30 30 12 12 12 12 12 6 6 6 ~12 10 20 60 120]
BeatDivision = 60
MyScore = {MakeScore Durations BeatDivision}
{Out.renderAndShowLilypond MyScore
 unit(file:'triplet-and-quintuplet-test'
      implicitStaffs:false
      %% definition of pause output
      clauses:{Out.makeLilyTupletClauses [2#3 2#5]})}
 


