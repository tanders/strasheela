
%%
%% TODO:
%% - revise comments concerning score topology: meanwhile very many topologies are supported...
%%

%%
%% This file demonstrates features of the Fomus output by a number
%% of examples. For simplicity, these examples directly create a
%% determined score and output it to Fomus. Naturally, all these
%% features are also available for Fomus output if you create your
%% score by constraint programming.
%%
%% These examples are sparsely documented. For further details please
%% see the Strasheela reference.
%%
%% As this file contains a number of examples, don't feed the whole
%% buffer. Instead feed one example after the other.
%%
%% All of Strasheela including contributions, Selection constraints,
%% Fomus and a PDF viewer must be installed for these examples (see
%% the Strasheela installation instructions).
%%

%%
%% Usage: don't feed whole file, just feed examples one by one.
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Mini example: single note output
%%

%% firste create the score
declare
MyScore = {Score.makeScore note(duration:4
				pitch:60
				startTime:0
				timeUnit:beats)
	   unit}

%% then create the output 
{Out.renderFomus MyScore
 unit(file:firstTest)}


%% note nested in a container
declare
MyScore = {Score.makeScore seq(items:[note(duration:4
					   pitch:61)]
			       startTime:0
			       timeUnit:beats)
	   unit}

{Out.renderFomus MyScore
 unit(file:test)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% WARNING: a score must be fully determined for Fomus output (as
%% for other output formats, like Csound or MIDI). The following
%% example blocks (does nothing!), because some parameter values are
%% not determined -- the note pitch is missing!
%%
%% Nevertheless, a window with a warning is shown (This window may be
%% hid behing Emacs, you may need to switch to the Oz/QTk application
%% to see this warning).
%%

declare
MyScore = {Score.makeScore note(duration:4
				%% NOTE: pitch is not determined (it
				%% defaults to an FD int)
                                % pitch:60
				startTime:0
				timeUnit:beats)
	   unit}
{Out.renderFomus MyScore
 unit(file:blockingTest)}


%% One can make sure that a score is determined by using the score
%% method 'wait'. This method can also ensure that constraint
%% propagation finished before the score is output (e.g., in the
%% following example, the start times of the notes are determined by
%% constraint propagation)
declare
MyScore = {Score.makeScore seq(items:[note(duration:4
					   pitch:60)
				     note(duration:4
					  pitch:60)]
			       startTime:0
			       timeUnit:beats)
	   unit}
{MyScore wait}
{Browse waitingFinished} 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% By default, the Strasheela score topology sim(seq(...)+) results in
%% the typical Fomus score layout with an extra (piano) staff for each
%% sequential directly contained in a top-level simultaneous
%% container. Note that item offset times are notated as rests.
%%

declare
MyScore = {Score.makeScore
	   sim(items:[ seq(items:[note(duration: 4
				       pitch: 60)
				  note(duration: 2
				       pitch: 62)
				  note(duration: 8
				       pitch: 64)])
		       seq(items:[note(offsetTime: 4
				       duration: 4
				       pitch: 72)
				  note(duration: 8 
				       pitch: 67)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:defaultTopology)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% A different staff layout can be selected, e.g., by setting the
%% containers that correspond to parts to a Fomus instrument via an
%% info record with the label fomus. Note that the part of the b-flat
%% clarinet is automatically transposed by Fomus.
%%

declare
MyScore = {Score.makeScore
	   sim(items:[ seq(info: fomus(inst: 'bflat-clarinet')
			   [note(duration: 4
				 pitch: 60)
			    note(duration: 2
				 pitch: 62)
			    note(duration: 8
				 pitch: 64)])
		       seq(info: fomus(inst: violin)
			   [note(offsetTime: 4
				 duration: 4
				 pitch: 72)
			    note(duration: 8 
				 pitch: 67)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:defaultTopology)}



%%%%%


%% A score can be further nested within the outmost sequential
%% containers corresponding to staffs. The following examples features
%% a seq in a seq and offset times for notes and containers.
declare
MyScore = {Score.makeScore
	   sim(items:[seq(items:[note(duration: 4
				      pitch: 60)
				 seq(offsetTime: 2
				     items:[note(duration: 2
						 pitch: 62)
					    note(duration: 4
						 pitch: 64)])])
		      seq(offsetTime:4
			  items:[note(duration: 3
				      pitch: 72)
				 note(offsetTime: 1
				      duration: 4 
				      pitch: 67)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:defaultTopology2)}


%%%%%


%% Inner nesting with a different effect: sims in a staff can express chords
declare
MyScore = {Score.makeScore
	   sim(items:[seq(items:[note(duration: 4
				      pitch: 60)
				 %% NOTE: a chord
				 sim(offsetTime: 2
				     items:[note(offsetTime: 2
						 duration: 4
						 pitch: 62)
					    note(offsetTime: 2
						 duration: 4
						 pitch: 59)
					    note(offsetTime: 2
						 duration: 4
						 pitch: 55)])])
		      seq(items:[note(duration: 4
				      pitch: 72)
				 note(duration: 4
				      pitch: 67)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:defaultTopology3)}


%%%%


%%
%% TODO: single staff polyphony can be improved. Also, info tags in "intermediate" containers are currently ignored completely, which is a waste.
%%

%% Again, inner nesting with a different effect: sims in a staff can also express single staff polyphony
declare
MyScore = {Score.makeScore
	   sim(items:[seq(items:[note(duration: 4
				      pitch: 60)
				 sim(items:[seq(info: fomus(voice: 1) % ?? TODO: syntax and get it working
					       [note(duration: 4
						      pitch: 67)
						 note(duration: 8
						      pitch: 65)])
					    seq(info: fomus(voice: 2)
						offsetTime:2
						[note(duration: 2
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
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:defaultTopology4)}


%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Additional Fomus code can be added to score items with the fomus
%% info-tag (a record where features are Fomus values/settings and the
%% record values are then the actual settings).
%%

declare
MyScore = {Score.makeScore
	   sim(info: fomus(title: "My Composition"
			   author: "Myself"
			   keysig: dmaj % D major key 
% 			   'timesig-den': 8
			   'timesig': '(3 4)' % 3/4 time signature
			  )
	       [seq([note(duration:8 pitch:64)
		     note(duration:8 pitch:64)])
		seq(info: fomus(inst: violin)
		    [note(duration:4 pitch:60 info:fomus(marks: "(..")) % marks are given as VS or list of VSs
		     note(duration:4 pitch:59 info:fomus(marks: ["."]))
		     note(duration:4 pitch:59 info:fomus(marks: ['-' '>']))
		     note(duration:4 pitch:57 info:fomus(marks: ["^" "breath>"]))
		     note(duration:4 pitch:55 info:fomus(% dyns: yes
							 marks: ["..)"
								 %% TODO: howto use dyn?
% 								 "dyn 10"
								 "f"
								]))
		    ])
	       ]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore unit}




%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Multiple sections can be connected (e.g., by a top-level sequential container),
%% if corresponding parts are marked with the same id.
%%

%%
%% PartID must be an atom or an integer.
%%


declare
MyScore = {Score.makeScore
	   seq(info: fomus(title: "My Composition")
	       [sim([seq(info: [fomusPart(violin)
				fomus(inst: violin)]
			 [note(duration: 2
			       pitch: 60)
			  note(duration: 2
			       pitch: 62)
			  note(duration: 4
			       pitch: 64)])
		     seq(info: [fomusPart(viola)
				fomus(inst: viola)]
			 [note(duration: 8
			       pitch: 72)])])
		sim([seq(info: fomusPart(violin)
			 [note(duration: 8
			       pitch: 60)])
		     seq(info: fomusPart(viola)
			 [note(duration: 2
			       pitch: 72)
			  note(duration: 2
			       pitch: 69)
			  note(duration: 4 
			       pitch: 67)])])]
	       startTime:0
	       timeUnit:beats(2))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:multipleSections)}





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% The Fomus output to Lilypond can be customised with literal Lilypond code with settings such as lily-file-header, lily-insert-before, etc.
%%

declare
MyScore = {Score.makeScore seq(info: fomus(
					'lily-view-exe-args':
					   "--pdf -dbackend=eps -dno-gs-load-fonts -dinclude-eps-fonts" % Fomus ignored?
					'lily-file-header':
					   "\\header { title = \"Symphony\" composer = \"Me\" opus = \"Op. 42\" }")
			       [note(info: fomus('lily-insert-after': "\\staccato")
% 				     info: fomus('lily-insert-before': "\\clef alto") % Fomus error.. 
% 				     info: fomus('lily-insert-after': "_\\markup{test}") % Fomus error.. 
				     duration:4
				     pitch:60)]
			       startTime:0
			       timeUnit:beats)
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:literalLilyTest)}




%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Again, single voice polyphony and chords 
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
{MyScore wait}
{Out.renderFomus MyScore
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
{MyScore wait}
{Out.renderFomus MyScore
 unit}

%% More complex nesting.
declare
MyScore = {Score.makeScore
	   sim(items:[sim(items:[seq(items:[note(duration:2
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
		      sim(items:[seq(items:[note(duration:8
						 pitch:67)])
				 seq(items:[note(duration:3
						 pitch:64)
					    note(duration:1
						 pitch:62)
					    note(duration:4
						 pitch:60)])])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Creating an additional staff which lasts for only the duration of a
%% specific container
%%

%% TODO: this does not work as indented
%% NOTE: is this important?
declare
MyScore = {Score.makeScore
	   seq(items:[sim(items:[seq(offsetTime:4
				     items:[note(duration:2
						 pitch:72)
					    note(duration:2
						 pitch:71)
					    note(duration:2
						 pitch:69)
					    note(duration:2
						 pitch:67)])
				 seq(offsetTime:4
				     items:[seq([note(info:fomus('lily-insert-before': "\\new Staff")
						      duration:2
						      pitch:60)
						 note(duration:2
						      pitch:62)])
					    seq(items:[note(duration:2
							    pitch:64)
						       note(duration:2
							    pitch:67)])])])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:explicitStaff)}

%%



%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Enharmonic notation is supported, e.g., for 31-tone equal
%% temperament which pitches such as C# or Db are different pitch
%% classes.
%%

%% BUG: !
declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}
MyScore = {Score.makeScore
	   seq([note(duration:2
		     pitch:{HS.pitch 'D'#4})
		note(duration:2
		     pitch:{HS.pitch 'D|'#4})
		note(duration:2
		     pitch:{HS.pitch 'D#'#4})
		note(duration:2
		     pitch:{HS.pitch 'Eb'#4})
		note(duration:2
		     pitch:{HS.pitch 'E;'#4})
		note(duration:2
		     pitch:{HS.pitch 'E'#4})
	       ]
	       startTime:0
	       timeUnit:beats(4))
	   add(note:HS.score.note2)}
{MyScore wait}
%%
{Out.renderFomus MyScore
 unit(file:enharmonicTest
      eventClauses: [%% NOTE: comment out intended accidental format
		     %% Version with quarter-tone accidentals
		     {HS.out.makeNoteToFomusClause ET31.out.fomusPCs_Quartertones}
		     %% Version with double accidentals
% 		     {HS.out.makeNoteToFomusClause ET31.out.fomusPCs_DoubleAccs}
		    ])}

%% NOTE: Before continuing with the next example, unset the 31-TET setting
%% (i.e. set back the default setting)
{HS.db.setDB HS.dbs.default.db}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Chord and Scale objects 
%%

declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}
MyScore = {Score.makeScore
	   sim([seq([chord(duration: 4
			  index: {HS.db.getChordIndex 'major'}
			   transposition: {HS.pc 'G|'})])
		seq([scale(duration: 4
			  index: {HS.db.getScaleIndex 'major'}
			   transposition: {HS.pc 'D|'})])
	       ]
	       startTime:0
	       timeUnit:beats(1))
	   add(chord:HS.score.chord
	       scale:HS.score.scale)}
{MyScore wait}
%%
{Out.renderFomus MyScore
 unit(file:"ChordAndScale"
      eventClauses: [{HS.out.makeNoteToFomusClause ET31.out.fomusPCs_Quartertones}
		     {HS.out.makeChordToFomusClause ET31.out.fomusPCs_Quartertones}
		     {HS.out.makeScaleToFomusClause ET31.out.fomusPCs_Quartertones}
		    ])}

%% NOTE: Before continuing with the next example, unset the 31-TET setting
%% (i.e. set back the default setting)
{HS.db.setDB HS.dbs.default.db}


%%
%% TMP
%%

declare
MyChord = {Score.make chord(duration: 4
			    index: {HS.db.getChordIndex 'major'}
			    transposition: {HS.pc 'G|'})
	   unit(chord:HS.score.chord)}

{IsVirtualString '[x "'#{HS.db.getName MyChord}#'"]'}


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
		    seq(info:[staff]
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
%% triplets:
%% Intended Lily code: c4 \times 2/3 {r8 c8 c} r8 c8 \times 2/3 {c4 c8}
%% Instead, Fomus notates first note as part of triplet.
Durations = [6 ~2 2 2 ~3 3 4 2]
BeatDivision = 6
MyScore = {MakeScore Durations BeatDivision}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:'triplet-test')}


declare
%% triplets and dotted notes 
Durations = [6 ~2 2 2 3 3 4 2 9 3 6 2 4]
BeatDivision = 6
MyScore = {MakeScore Durations BeatDivision}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:'triplet-test-2')}

declare
%% quintuplets
Durations = [10 2 ~2 2 2 ~2 ~5 5 4 2 ~4]
BeatDivision = 10
MyScore = {MakeScore Durations BeatDivision}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:'quintuplet-test')}


declare
%% triplets and quintuplets (nested tuplets not supported)
Durations = [60 20 20 ~20 30 30 12 12 12 12 12 6 6 6 ~12 10 20 60 120]
BeatDivision = 60
MyScore = {MakeScore Durations BeatDivision}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:'triplet-and-quintuplet-test')}
 




%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Instrument Definition
%%

declare
MyScore = {Score.makeScore
	   sim(info: fomus("inst <id: elvla template: viola name: \"Electric Viola\" abbr: \"evla\">"
			   title: "Instrument Definition Example"
			   author: "Myself")
	       [seq(info: fomus(inst: elvla)
		    [note(duration: 6
			  pitch: 60)
		     note(duration: 2
			  pitch: 62)
		     note(duration: 8
			  pitch: 64)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:instrumentDefinition)}




%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Measure declaration
%%

declare
MyScore = {Score.makeScore
	   sim(info: fomus(beat: '1/8'  % a beat (duration 1) is notated as eighth note
% 			   'timesig-den': 8
			   "time = 0 dur = 3 ||" % triple measure (shorthand notation)
% 			   "measure <time: 0 dur: 3 timesig-den: 1/8>" % object notation (does not work!)
% 			   "measure <time: 0 dur: 3 beat: 1/8>" % object notation (does not work!)
			  ) 
	       [seq([note(duration: 8
			  pitch: 60)
		     note(duration: 4
			  pitch: 62)
		     note(duration: 12
			  pitch: 64)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:measure)}



%%
%% Start new measures with given start time and duration..
%%

declare
MyScore = {Score.makeScore
	   sim(info: fomus(beat: '1/8')  % a beat (duration 1) is notated as eighth note
	       [seq([note(info:fomus_before("time = 0 dur = 1 |timesig-den = 16|")
			  duration: 4
			  pitch: 60)
		     note(duration: 2
			  pitch: 62)
		     note(info:fomus_before("time = + dur = 7 |timesig-den = 16|")
			  duration: 6
			  pitch: 64)])]
	       startTime:0
	       timeUnit:beats(2))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:measure)}


%%
%% Alternative measure notation
%%

declare
MyScore = {Score.makeScore
	   sim(info: fomus(beat: '1/4')  
	       [seq([note(info:fomus_before("time = 0 dur = 3 measure < timesig-den = 4 >")
			  duration: 4
			  pitch: 60)
		     note(duration: 2
			  pitch: 62)
		     note(% info:fomus_before("time = 0 dur = 1 measure < timesig-den = 16 >")
			  duration: 6
			  pitch: 64)])]
	       startTime:0
	       timeUnit:beats(2))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:measure)}


%%
%% Workaround for offbeat: start with a long rest. You could later fine-tune notation in notation software...
%%

declare
MyScore = {Score.makeScore
	   sim(info: fomus("time = 0 dur = 3 ||")
	       [seq(offsetTime: 8
		    [note(duration: 4
			  pitch: 59)
		     note(duration: 8
			  pitch: 60)
		     note(duration: 4
			  pitch: 62)
		     note(duration: 12
			  pitch: 64)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:measure)}

{{MyScore find($ isNote)} getStartTime($)}


% % % % % % % % % % % % % % % % %
%%
%% Strasheela measure objects
%%
%% Note simple trick to avoid Strasheela measures cause outputting an extra staff: the seq of the measure and the first (and only) actual part of the score are set to the same part ID using the info tag fomusPart.
%%

declare
End
MyScore = {Score.makeScore
	   sim([seq(info: fomusPart(violin)
		   [measure(beatNumber:4 %% 4/4 beat
			    beatDuration:4 
% 			     endTime:End
			    )])
		seq(info: fomusPart(violin)
		    [note(duration: 4
			  pitch: 59)
		     note(duration: 8
			  pitch: 60)
		     note(duration: 4
			  pitch: 62)
		     note(duration: 16
			  pitch: 64)]
% 		    endTime:End
		   )]
	       startTime:0
	       timeUnit:beats(4))
	   add(measure:Measure.uniformMeasures)}

% {MyScore wait} % end time of measure undetermined!
{Out.renderFomus MyScore      
 unit(file:"StrasheelaMeasure"
      eventClauses: [Measure.out.uniformMeasuresToFomusClause]
     )}

     



%%
%% TODO: 
%% How to automatically start new measure at certain notes and let Fomus work out the measure duration?
%%

%% I've been planning on allowing measures with duration 0 (or no duration), but haven't finished this yet...  At the moment you have to accomplish this by supplying large durations so that fomus trims the overlapping measures.  




%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Setting keysignatures 
%%

declare
MyScore = {Score.makeScore
	   sim([seq([note(info:fomus_before("time = 0 dur = 3 |keysig: b-maj|") % B-flat major
			  duration: 8
			  pitch: 60)
		     note(duration: 4
			  pitch: 62)
		     note(info:fomus_before("time = + dur = 3 |keysig: cmin|") % C minor
% 			  info:fomus_before("time = + dur = 3 |keysig: gmin|") % Fomus bug: G-minor does not work
			  duration: 12
			  pitch: 64)])]
	       startTime:0
	       timeUnit:beats(4))
	   unit}
{MyScore wait}
{Out.renderFomus MyScore
 unit(file:measure)}

