
%%% *************************************************************
%%% Copyright (C) 2005 Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% Functor defines data abstraction for a user-defined database of settings like chord and scale structures which are used by the contribution HarmonisedScore. See SetDB of further details. 
%% */

%%
%% TODO
%%
%% OK? * extend means for chord and scale database by means for interval
%% database (various rules may build on top of that, e.g., a rule
%% constraining the interval dissonance degree between the roots of
%% two neighbouring chords..)
%%
%% OK * I should support setting the whole database with a single value to explicitly express the interdependencies of these values (e.g. dependency between chordDB and pitchesPerOctave) -- replace all setters by a single setter SetDB which expects a record with the settings as features. All features are optional and missing features are substituted by their defaults. For this end, replace all these cells by a single cell and all accessors access features of the record in this cell.
%%

functor
import
   
   FD FS RecordC
   Browser(browse:Browse) 
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
   DBs at 'databases/Databases.ozf'
   
export

   SetDB
   % SetChordDB SetScaleDB
   % SetPitchesPerOctave SetAccidentalOffset SetOctaveDomain

   GetEditChordDB GetInternalChordDB
   GetEditScaleDB GetInternalScaleDB
   GetEditIntervalDB GetInternalIntervalDB
   GetPitchesPerOctave GetPitchUnit GetAccidentalOffset GetOctaveDomain

   MakePitchClassFDInt MakeOctaveFDInt MakeAccidentalFDInt
   MakeScaleDegreeFDInt MakeChordDegreeFDInt
   
   RatiosInDBEntryToPCs

   Pc2Ratios
   
define

   %% The default database -- put on top for documentation. For an
   %% explaination of the format see the doc for SetDB.
   DefaultDB = DBs.default.db
%    = unit(chordDB: chords(chord(pitchClasses:[0 4 7]
% 				roots:[0]
% 				dissonanceDegree:2
% 				comment:major)
% 			  chord(pitchClasses:[0 3 7]
% 				roots:[0] % ? [7]
% 				dissonanceDegree:3
% 				comment:minor))
% 	  scaleDB: scales(scale(pitchClasses:[0 2 4 5 7 9 11]
% 				roots:[0]
% 				comment:major)
% 			  scale(pitchClasses:[0 2 3 5 7 8 10]
% 				roots:[0] 
% 				comment:minorPure)
% 			  %% !! such extended scale def with 'alternative' scale degrees as 10 or 11 makes correct recognition of scale degree impossible -- better introduce 'alternatives' by explicit accidentals 
% % 				    scale(pitchClasses:[0 2 3 5 7 8 9 10 11]
% % 					  roots:[0] 
% % 					  comment:minor)
% 			 )
% 	  %% only intervals within the octave (quasi interval pitch classes)
% 	  intervalDB: intervals(interval(interval:0
% 					 dissonanceDegree:0
% 					 comment:unison)
% 				interval(interval:1
% 					 dissonanceDegree:6
% 					 comment:minorSecond)
% 				interval(interval:2
% 					 dissonanceDegree:5
% 					 comment:majorSecond)
% 				interval(interval:3
% 					 dissonanceDegree:4
% 					 comment:minorThird)
% 				interval(interval:4
% 					 dissonanceDegree:3
% 					 comment:majorThird)
% 				interval(interval:5
% 					 dissonanceDegree:2
% 					 comment:fourth)
% 				interval(interval:6
% 					 dissonanceDegree:6
% 					 comment:tritone)
% 				interval(interval:7
% 					 dissonanceDegree:1
% 					 comment:fifth)
% 				interval(interval:8
% 					 dissonanceDegree:3
% 					 comment:minorSixth)
% 				interval(interval:9
% 					 dissonanceDegree:4
% 					 comment:majorSixth)
% 				interval(interval:10
% 					 dissonanceDegree:5
% 					 comment:minorSeventh)
% 				interval(interval:11
% 					 dissonanceDegree:6
% 					 comment:majorSeventh)
% 			       )
% 	  pitchesPerOctave: 12
% 	  accidentalOffset: 2
% 	  % pitchUnit: midi % implicitly set with pitchesPerOctave
% 	  %% domain=2#7 corresponds to MIDI pitch range 36--83
% 	  %% (for pitchesPerOctave=12)
% 	  octaveDomain:2#6) 

   
   /** %% Transforms an sub-database given in the edit format (e.g. the ChordDB) into the internal format used to define constraints and rules.
   %% This transformation quasi 'mat-trans' the DB (see example transformation below). In the transformation, the feature values are type checked and possibly transformed. The value at the feature comment remains unchecked and unchanged, integers are checked and remain integers, lists of integers are checked and transformed to constant FSs. All other value types on features except the comment cause an exception.
   %% Example:
   {EditToInteral unit(x(a:1
			 b:[2 3]
			 comment:foo)
		       x(a:10
			 b:[20 30]
			 comment:bar))}
      % results in
   x(a:unit(1 10)
     b:unit({FS.value.make [2 3]} {FS.value.make [20 30]})
     comment:unit(foo bar))
   %% */
   %% not exported
   proc {EditToInteral SubDB ?Result}
      %% first transform all integer lists into constant FS and make sure all other chord feature values (except at feature 'comment') are integers
      TransformedInput = {Record.map SubDB
			  fun {$ DBEntry} % DBEntry is, e.g., single chord spec
			     {Adjoin
			      %% don't process/typecheck comment..
			      if {HasFeature DBEntry comment}
			      then unit(comment: DBEntry.comment)
			      else unit
			      end
			      {Record.map {Record.subtract DBEntry comment}
			       fun {$ X}
				  %% transform list of ints into determined FS
				  if {IsList X} andthen {All X IsInt}
				  then {FS.value.make X}
				     %% keep int as (determined) int
				  elseif {IsInt X}
				  then X
				     %% for other values raise exeption
				  else raise malformedDBEntryFeature(X) end
				  end
			       end}}
			  end}
   in
      %% transform (quasi mat-trans) the tuple of DB entry records
      %% (e.g. a tuple of chord records) with entry features
      %% (e.g. a record of chord features) into a record of entry
      %% features with tuples of DB entry data: 
      Result = {MakeRecord {Label SubDB.1} {Arity SubDB.1}}
      {Record.forAllInd Result
       proc {$ I X}
	  X = {Record.map TransformedInput
	       fun {$ X} X.I end}
       end}
   end
     
   %% The database is stored in a number of stateful variables which
   %% can not be accessed directly from outside. Different aspects
   %% (i.e. different variables) of the database can be read by a
   %% number of accessors (e.g. GetEditChordDB) and the database can
   %% only be set as a whole (i.e. all variables) by SetDB (which
   %% calls a number of aux setters like SetChordDB).
   local
      %% NB: these DB vars are later updated with {SetDB DefaultDB} at the
      %% very end of this functor
      EditChordDB  = {NewCell unit}
      InternalChordDB = {NewCell unit}
      EditScaleDB = {NewCell unit}
      InternalScaleDB = {NewCell unit}
      EditIntervalDB = {NewCell unit}
      InternalIntervalDB = {NewCell unit}
      PitchesPerOctave = {NewCell unit}
      AccidentalOffset = {NewCell unit}
      PitchUnit = {NewCell unit}
      OctaveDomain = {NewCell unit}
      %% !! I can not request of global lock from local space..
      %% MyLock = {NewLock} 	% to deny access while setting the database vars
   in


      /** %% Sets the database which is used by the music representation and rules of the HarmonisedScore contribution.
      %% The syntax of the database is
      &lt;DB&gt; ==:: unit([chordDB:&lt;PCGroupDB&gt;]
		     [scaleDB:&lt;PCGroupDB&gt;]
		     [intervalDB:&lt;IntervalDB&gt;]
		     [pitchesPerOctave:&lt;PitchesPerOctave&gt;]
		     [accidentalOffset:&lt;AccidentalOffset&gt;]
		     [octaveDomain:&lt;OctaveDomain&gt;])
      &lt;PCGroupDB&gt; ==:: unit(&lt;PCGroupEntry&gt;+)
      &lt;PCGroupEntry&gt; ==:: unit(pitchClasses:&lt;IntList&gt;
			       roots:&lt;IntList&gt;
			       [&lt;FeatureValuePair&gt;*]
			       [comment:&lt;Value&gt;])
      &lt;IntervalDB&gt; ==:: unit([&lt;FeatureValuePair&gt;+]
			     [comment:&lt;Value&gt;])
      &lt;PitchesPerOctave&gt; ==:: &lt;Int&gt;
      &lt;AccidentalOffset&gt; ==:: &lt;Int&gt;
      &lt;OctaveDomain&gt; ==:: &lt;Int&gt;#&lt;Int&gt;
      
      %% All features of the whole DB and also of some sub-DBs (e.g. of the chordDB and scaleDB) are optional (as marked by square brackets).
      %% NB: every DB feature missing in NewDB is set to a default value. 

      %% Temp doc: For further details read the doc of the aux accessors.
      %% TODO: write a better doc..
      %% */
      proc {SetDB NewDB}
	 %% Locking to ensure that reading happens only after (or before) _all_ DB variables are updated, even in a concurrent program. It is the responsibility of the user to ensure that reading happens only _after_ setting the DB, therefore, doing this locking is in fact overdone.. 
	 %% lock MyLock then	
	 DB = {Adjoin DefaultDB NewDB} 
      in
	 {SetChordDB DB.chordDB}
	 {SetScaleDB DB.scaleDB}
	 {SetIntervalDB DB.intervalDB}
	 {SetPitchesPerOctave DB.pitchesPerOctave} % implicitly sets PitchUnit
	 {SetAccidentalOffset DB.accidentalOffset}
	 {SetOctaveDomain DB.octaveDomain}
	 %% end
      end
      
      /** %% Sets the database of chords which is used by a chord progression. Each chord is defined by its untransposed pitch classes, the possible untransposed roots (usually a single root) and further optional information. The chord pitch classes and roots are defined as indexes (i.e. integers) into an equidistanct tuning. The tuning is defined by the number of pitches per octave which is set by the proc SetPitchesPerOctave (defaults to 12).
      %% Chord database format: a tuple of records, each record defines an untransposed chord.
      %% Obligatory chord feature are 'pitchClasses' (a list of chord pitch classes, e.g., for major in et12 the pitch classes are [0 4 7]) and 'roots' (a list of possible chord root pitch classes, e.g. for major the roots are [0]). 'roots' must not be nil (because the (untransposed) chord root is constrained to be included in the roots -- which value should a chord root have if roots is nil?). 
      %% Arbitrary additional features can be added (e.g. 'dissonanceDegree'), but the values at these features are restricted to either integers or lists of integers. Besides, all chord entries in the database must have the same arity of features. 
      %% In the special optional record feature 'comment' an arbitrary data stracture can be stored with further information on the chord.
      %%
      %% Internally, the chord database is transformed into a format which swaps the 'rows' and 'columns' of the representation: the internal format is a record with tuples at the feature fields. Each tuple itemises the values of all chords at the respective record feature.
      %% Each list of integers in the database is transformed into a constant finite set. The integers and the data at the feature 'comment' remain unchanged.
      %% */
      proc {SetChordDB NewChordDB}
	 %% there is at least one chord in NewChordDB (more checking
	 %% within EditToInteral)
	 if {IsTuple NewChordDB} andthen {HasFeature NewChordDB 1}
	 then
	    EditChordDB := NewChordDB
	    InternalChordDB := {EditToInteral NewChordDB}
	 else raise malformedChordDB(NewChordDB) end
	 end 
      end
      %% !!?? unfinished doc?
      /** %% Sets the database of scales. The database has the same format as the chord database (see SetChordDB).
      %% */
      proc {SetScaleDB NewScaleDB}
	 %% there is at least one scale in NewScaleDB (more checking
	 %% within EditToInteral)
	 if {IsTuple NewScaleDB} andthen {HasFeature NewScaleDB 1}
	 then
	    EditScaleDB := NewScaleDB
	    InternalScaleDB := {EditToInteral NewScaleDB}
	 else raise malformedScaleDB(NewScaleDB) end
	 end 
      end

      proc {SetIntervalDB NewIntervalDB}
	 %% there is at least one interval in NewIntervalDB (more checking
	 %% within EditToInteral)
	 if {IsTuple NewIntervalDB} andthen {HasFeature NewIntervalDB 1}
	 then
	    EditIntervalDB := NewIntervalDB
	    InternalIntervalDB := {EditToInteral NewIntervalDB}
	 else raise malformedIntervalDB(NewIntervalDB) end
	 end 
      end
	    
      /** %% All pitch classes defined in the current functor are indexes into an equidistanct tuning. The tuning is defined by the number of pitches per octave (an integer, e.g. 12 for et12 or 1200 for cent values), the default is 12. Implicitly, this setting determines the pitchUnit for all pitches and pitch classes to either midi (NewPitchesPerOctave=12), et72 (NewPitchesPerOctave=72) or midicent (NewPitchesPerOctave=1200).
      %% */
      proc {SetPitchesPerOctave NewPitchesPerOctave}
	 if {IsInt NewPitchesPerOctave}
	 then PitchesPerOctave := NewPitchesPerOctave
	    case NewPitchesPerOctave
	    of 12 then PitchUnit := midi
	    [] 72 then PitchUnit := et72
	    [] 1200 then PitchUnit := midicent
	    else {Browse 'warn: pitch unit is not recognised and remains unbound'}
	       PitchUnit := _
	    end
	 else raise noInteger(NewPitchesPerOctave) end
	 end
      end
      /** %% An accidental denotes an offset for a scaleDegree (a relative pitch class) or a noteName (an absolute pitch class, a scaleDegree into c-major). Because accidentals are FD integers, they can not be negative and thus an offset must be defined, the accidental offset. As the meaning of the numeric value of an accidental depends also on the maximum number of possible pitches between scale degrees (and thus on PitchesPerOctave), the offset can be set by the user.
      %% The default AccidentalOffset for common praxis music is 2.       
      %% NB: To avoid complicating the CSP definition with offsets, the use of the accidental conversions HarmonisedScore.score.absoluteToOffsetAccidental or HarmonisedScore.score.offsetToAbsoluteAccidental is recommended.
      %% */
      proc {SetAccidentalOffset Offset}
	 AccidentalOffset := Offset
      end
      
      /** %% To implicitely reduce the domain of all note pitches instantiated by the current functor an octave domain is defined by a FD spec (i.e. Min#Max). The resulting pitch range is (OctaveDomainMin * PitchesPerOctave) # (OctaveDomainMax * PitchesPerOctave + PitchesPerOctave-1). Middle c has octave 4, according to conventions (cf. http://en.wikipedia.org/wiki/Scientific_pitch_notation).
      %% */
      % The default is 0#9 which corresponds to MIDI pitch range 12-127+ if pitches per octave are 12.
      proc {SetOctaveDomain Min#Max}
	 OctaveDomain := Min#Max
      end
      
      %% NB: It is of course the responsibility of the user to ensure that any reading of the DB happens only _after_ setting the database.
      /*
      fun {GetEditChordDB} lock MyLock then @EditChordDB end end
      fun {GetInternalChordDB} lock MyLock then @InternalChordDB end end
      fun {GetEditScaleDB} lock MyLock then @EditScaleDB end end
      fun {GetInternalScaleDB} lock MyLock then @InternalScaleDB end end
      fun {GetEditIntervalDB} lock MyLock then @EditIntervalDB end end
      fun {GetInternalIntervalDB} lock MyLock then @InternalIntervalDB end end
      fun {GetPitchesPerOctave} lock MyLock then @PitchesPerOctave end end
      fun {GetAccidentalOffset} lock MyLock then @AccidentalOffset end end
      fun {GetPitchUnit} lock MyLock then @PitchUnit end end
      fun {GetOctaveDomain} lock MyLock then @OctaveDomain end end
      */
      fun {GetEditChordDB} @EditChordDB end
      fun {GetInternalChordDB} @InternalChordDB end 
      fun {GetEditScaleDB} @EditScaleDB end 
      fun {GetInternalScaleDB} @InternalScaleDB end 
      fun {GetEditIntervalDB} @EditIntervalDB end 
      fun {GetInternalIntervalDB} @InternalIntervalDB end 
      fun {GetPitchesPerOctave} @PitchesPerOctave end 
      fun {GetAccidentalOffset} @AccidentalOffset end 
      fun {GetPitchUnit} @PitchUnit end 
      fun {GetOctaveDomain} @OctaveDomain end
      
   end

 


   
   /** %% Return a FD integer representing a pitch class (range defined by PitchesPerOctave).
   %% */
   fun {MakePitchClassFDInt}
      {FD.int 0#{GetPitchesPerOctave}-1}
   end
   /** %% Return a FD integer representing an octave (range OctaveDomain).
   %% */
   fun {MakeOctaveFDInt}
      {FD.int {GetOctaveDomain}}
   end
   /** %% Return a FD integer representing an accidental (range 0#AccidentalOffset*2). 
   %% */
   fun {MakeAccidentalFDInt}
      {FD.int 0#{GetAccidentalOffset}*2}
   end

   local
      /** %% Returns an integer with the maximum scale length in the scale database.
      %% */
      fun {GetMaxScaleLength}
	 {LUtils.accum {Map {Record.toList {GetEditScaleDB}}
			fun {$ ScaleSpec} {Length ScaleSpec.pitchClasses} end}
	  Max}
      end
   in
      /** %% Returns a FD integer representing a scale degree (range 1#MaxScaleLength).
      %% */
      fun {MakeScaleDegreeFDInt}
	 {FD.int 1#{GetMaxScaleLength}}
      end
   end
   
   local
      /** %% Returns an integer with the maximum scale length in the scale database.
      %% */
      fun {GetMaxChordLength}
	 {LUtils.accum {Map {Record.toList {GetEditChordDB}}
			fun {$ ScaleSpec} {Length ScaleSpec.pitchClasses} end}
	  Max}
      end
   in
      /** %% Returns a FD integer representing a chord degree (range 1#MaxChordLength).
      %% */
      fun {MakeChordDegreeFDInt}
	 {FD.int 1#{GetMaxChordLength}}
      end
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   local
      /** %% Returns the rounding error of rounding a pitch class float into a pitch class int. The meaning of PC (a float) depends on KeysPerOctave (a float). The error is returned in cent (a float).
      %% */
      fun {PCError PC KeysPerOctave}
	 fun {ToCent X}
	    (X / KeysPerOctave) * 1200.0
	 end
      in
	 {ToCent (PC - {Round PC})}
      end
      /** %% Transform Ratio (either a float or a fraction specification in the form &lt;Int&gt;#&lt;Int&gt;) into a pitch class interval (a float) depending on KeysPerOctave (a float).
      %% */
      fun {RatioToPC Ratio KeysPerOctave}
	 PC = {MUtils.keynumToPC {MUtils.ratioToKeynumInterval Ratio
				  KeysPerOctave}
	       KeysPerOctave}
      in
	 unit(ratio:Ratio pc:{FloatToInt PC} error:{PCError PC KeysPerOctave}#cent)
      end
      fun {RatiosToPCs Ratios KeysPerOctave}
	 {Map Ratios
	  fun {$ X} {RatioToPC X KeysPerOctave} end}
      end
      %% X is either a float or a fraction specification in the form &lt;Int&gt;#&lt;Int&gt;
      fun {IsRatio X}
	 case X
	 of Nom#Denom  
	 then if {IsInt Nom} andthen {IsInt Denom}
	      then true
	      else false
	      end
	 else if {IsFloat X}
	      then true
	      else false
	      end
	 end
      end
      fun {IsIntList X}
	 {IsList X} andthen {List.all X IsInt}
      end
      fun {IsRatioList X}
	 {IsList X} andthen {List.all X IsRatio}
      end
   in
      /** %% Processes an entry for a HS database (e.g. for a chord database). HS depends on pitches as keynumbers and pitch classes (all represented by integers or FD ints), both depending on KeysPerOctave. RatiosInDBEntryToPCs, on the other hand, permits also ratios (floats or fractions specs) which are transformed and rounded to the nearest pitch class (a ratio representing an interval exceeding an octave is transformed into an interval within an octave). 
      %% MyDBEntry is a record with arbitrary features. Each feature value is either an interger, a list of integers, a ratio spec (either a float or a fraction spec in the form &lt;Int&gt;#&lt;Int&gt;), or a list of ratio specs. The output contains each integer/lists of integers unchanged but substitutes each ratio/list of ratios by the nearest pitch class interval (an integer), depending on KeysPerOctave (an integer).
      %% Additionally, a comment feature in MyDBEntry with arbitrary value is permitted. The returned record has always a comment feature with a record as value. The explaination of the comment in the return value is a bit complicated and depends on MyDBEntry. For features in MyDBEntry with a ratio, collect in comment the ratio, its pitch class plus the error, for other features in Test keep the orig value. In case MyDBEntry contains a feature comment as well, this value is preserved: in case MyDBEntry.comment is a record as well, its features are added to the comment record of the result. However, in case MyDBEntry.comment contains a feature 'comment' with the same feature as a feature in MyDBEntry itself, then the feature of MyDBEntry.comment is preferred. See the test file for examples.
      %%
      %% NB: in HS.db, an OctaveDomain is also specified as &lt;Int&gt;#&lt;Int&gt;, but must not be mixed up with a fraction spec.
      %% */
      proc {RatiosInDBEntryToPCs MyDBEntry KeysPerOctave Out}
	 %% Internally, KeysPerOctave arg is always a float
	 KeysPerOctave_F = {IntToFloat KeysPerOctave} 
	 % Comment = {Record.clone MyDBEntry}
	 Comment = {RecordC.tell {Label MyDBEntry}} 
      in
	 if {HasFeature MyDBEntry comment}
	 then
	    if {IsRecord MyDBEntry.comment} andthen {Width MyDBEntry.comment} > 0
	    then {Record.forAllInd MyDBEntry.comment
		  proc {$ Feat X}
		     Comment ^ Feat = X
		  end}
	    else
	       Comment ^ comment = MyDBEntry.comment
	    end
	 end
	 Out = {Record.clone {Adjoin
			      unit(comment:_) %% compulsary feat 'comment'
			      MyDBEntry}}
	 %%
	 {Record.forAllInd {Record.subtract MyDBEntry comment}
	  proc {$ Feat X}
	     proc {BindComment Val}
		CommentFeat = Comment ^ Feat
	     in
		%% for features which are contained in both MyDBEntry
		%% and MyDBEntry.comment, the (already
		%% determined) value of MyDBEntry.comment is kept
		if {IsFree CommentFeat}
		then CommentFeat = Val
		end
	     end
	  in
	     if {IsInt X} orelse {IsIntList X}
	     then
		{BindComment X}
		Out.Feat = X
	     elseif {IsRatio X}
	     then Aux = {RatioToPC X KeysPerOctave_F} in
		{BindComment Aux}
		Out.Feat = Aux.pc
	     elseif {IsRatioList X}
	     then Aux = {RatiosToPCs X KeysPerOctave_F} in
		{BindComment Aux}
		Out.Feat = {Map Aux fun {$ X} X.pc end}
	     else raise unsupportedValue(RatiosInDBEntryToPCs MyDBEntry value:X) end
	     end
	  end}
	 Out.comment = Comment
	 %% close comment
	 {RecordC.width Comment} = {Length {RecordC.reflectArity Comment}}
      end
   end

   
   /** %% Returns a list of all ratios which match PC (an int) in IntervalDB (given in its edit form) which was defined using ratios (e.g. {HS.dbs.partch.getIntervals {HS.db.getPitchesPerOctave}}).
   %% A ratio consists in two integers and has the form Nom#Denom. If no entry in the database matches PC, nil is returned.
   %%
   %% Two examples:
   {PC2Ratios 9 {HS.dbs.partch.getIntervals 12}}
   {PC2Ratios 53 {HS.dbs.partch.getIntervals 72}}
   %%
   %% NB: Pc2Ratios is a deterministic function and no constraint.
   %% */
   fun {Pc2Ratios PC IntervalDB}
      {Map {Filter {Record.toList IntervalDB} fun {$ X} X.interval == PC end}
       fun {$ X} X.comment.interval.ratio end}
   end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   %% !! initialise database -- evaluated when linked functor/module is 'used' for first time (i.e. when something defined in the functor is accessed for the first time)
   {SetDB DefaultDB}
   
end