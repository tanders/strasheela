
/*
declare
[HS Pattern]
= {ModuleLink ['x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
		'x-ozlib://anders/strasheela/pattern/Pattern.ozf']}
*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% check database 
%%

{HS.db.getEditChordDB}
{HS.db.getInternalChordDB}

{HS.db.getEditScaleDB}
{HS.db.getInternalScaleDB}

{HS.db.getEditIntervalDB}
{HS.db.getInternalIntervalDB}

{HS.db.getPitchesPerOctave}	% 12 default
{HS.db.getPitchUnit}		% midi default
{HS.db.getAccidentalOffset}	% 2 -- for meaning of this see HarmonisedScore.score doc and tests ..
{HS.db.getOctaveDomain}		% 0#9 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% check FD int creators
%%

{HS.db.makePitchClassFDInt}	% default: {FD.int 0#11}

{HS.db.makeOctaveFDInt}		% default: {FD.int 3#6}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% set new database
%%


%% NB: changing only the pitches per octave renders most of the rest of the default DB (i.e. chordDB, scaleDB, intervalDB, and probably also accidental offset) useless
%% here, this setting is only done to check whether also pitch unit is appropriately updated
%% !! this causes exception now
{HS.db.setDB
 unit(pitchesPerOctave: 72)}

{HS.db.setDB
 unit(pitchesPerOctave: 1200)}

{HS.db.getPitchesPerOctave}	% 72 | 1200
{HS.db.getPitchUnit}		% et72 | midicent


%% setting whole DB with setDB is already 'tested', because it is used internally to set defaults..

{HS.db.setDB
 unit(chordDB: chords(chord(pitchClasses:[0 3 6 9]
			    roots:[2 5 8 11]
			    test:7
			    comment:diminished)
		      chord(pitchClasses:[0 4 8]
			    roots:[0 4 8]
			    test:0
			    comment:augmented))
      scaleDB: scales(scale(pitchClasses:[0 2 4 5 7 9 11]
			    roots:[0] % !!??
			    test:0
			    comment:major)
		      scale(pitchClasses:[0 2 4 6 8 10]
			    roots:[0 2 4 6 8 10] % !!??
			    test:1
			    comment:wholeTone))
      intervalDB: intervals(interval(comment: majorSecond
				     interval:2)
			    interval(comment:minorSeventh
				     interval:10))
      pitchesPerOctave:12)}


%% access indices from this database
{Browse {HS.db.getChordIndex augmented}} % -> 2
{Browse {HS.db.getScaleIndex wholeTone}} % -> 2
{Browse {HS.db.getIntervalIndex minorSeventh}} % -> 2

%% no db entry bla: nil
{Browse {HS.db.getChordIndex bla}}

%% !! I can do arbitrary chordDB accessors (e.g. get name of given chord pitch class set). I only need some standard format in the chord DB features 'comment'.
%%
%% find pitch classes of augmented chord (after updating DB..):
local
   ChordType = augmented
   I = {LUtils.findPosition
	{Record.toList {HS.db.getInternalChordDB}.comment}
	fun {$ X}
	   X == ChordType
	end}
in
   {HS.db.getInternalChordDB}.pitchClasses.I
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


{HS.db.ratiosInDBEntryToPCs
 test(interval:3#2
      dissonanceDegree:0
      resemblanceWithTradition:10
      test1:[1 2 3 4]
      test2:[3#2 5#4 7#4]
      test3:1.5
      test4:[1.5 1.25]
      comment: 'unisono'
     )
 12}

{HS.db.ratiosInDBEntryToPCs
 test(interval:3#2
      dissonanceDegree:0
      resemblanceWithTradition:10
      test1:[1 2 3 4]
      test2:[3#2 5#4 7#4]
      test3:1.5
      test4:[1.5 1.25]
      comment: 'unisono'
     )
 72}

%%
%% testing the comment creation:
%%

{HS.db.ratiosInDBEntryToPCs
 chord(test1:1#4
       test2:1)
 12}

{HS.db.ratiosInDBEntryToPCs
 chord(test1:1#4
       test2:1
       comment:blaumilch)
 12}

{HS.db.ratiosInDBEntryToPCs
 chord(test1:1#4
       test2:1
       test3:1#4
       comment:unit(test1:foo
		    test4:bar
		    comment:blaumilch))
 12}


%% provoke error
{HS.db.ratiosInDBEntryToPCs
 test(foo:bar)
 12}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

{HS.db.pc2Ratios 10 {HS.dbs.partch.getIntervals 12}}

{HS.db.pc2Ratios 53 {HS.dbs.partch.getIntervals 72}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% test: access scale/chord.interval name 
%%

declare
[ET22] = {ModuleLink ['x-ozlib://anders/strasheela/ET22/ET22.ozf']}
{HS.db.setDB ET22.db.fullDB}

declare
MyScale = {Score.makeScore
	   scale(index:{HS.db.getScaleIndex 'standard pentachordal major'}
		 transposition:{ET22.pc 'C'}
		 %% duration should be determined
		 duration:4
		 startTime:0
		 timeUnit:beats)
	   unit(scale:HS.score.scale)}
MyChord = {Score.makeScore
	   chord(index:{HS.db.getChordIndex 'harmonic 7th'}
		 transposition:{ET22.pc 'C'}
		 %% duration should be determined
		 duration:4
		 startTime:0
		 timeUnit:beats)
	   unit(chord:HS.score.chord)}
MyInterval = {Score.makeScore
	      interval(pitchClass:{ET22.pc 'G'}
		       octave:0
		       direction:2)
	      unit(interval:HS.score.interval)}


%% returns list of alternative names
{HS.db.getName MyScale}

{HS.db.getName MyChord}


{HS.db.getName MyInterval}


%%%

declare
[ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']}
{HS.db.setDB ET31.db.fullDB}


declare
MyScale = {Score.makeScore
	   scale(index:{HS.db.getScaleIndex 'major'}
		 transposition:{ET31.pc 'C'}
		 %% duration should be determined
		 duration:4
		 startTime:0
		 timeUnit:beats)
	   unit(scale:HS.score.scale)}
MyChord = {Score.makeScore
	   chord(index:{HS.db.getChordIndex 'major'}
		 transposition:{ET31.pc 'C'}
		 %% duration should be determined
		 duration:4
		 startTime:0
		 timeUnit:beats)
	   unit(chord:HS.score.chord)}
MyInterval = {Score.makeScore
	      interval(pitchClass:{ET31.pc 'G'}
		       octave:0
		       direction:2)
	      unit(interval:HS.score.interval)}


{HS.db.getName MyScale}

{HS.db.getName MyChord}


{HS.db.getName MyInterval}




