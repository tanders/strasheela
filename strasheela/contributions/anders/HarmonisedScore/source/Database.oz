
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
%% TODO:
%%
%% OK? * extend means for chord and scale database by means for interval
%% database (various rules may build on top of that, e.g., a rule
%% constraining the interval dissonance degree between the roots of
%% two neighbouring chords..)
%%
%% OK * I should support setting the whole database with a single value to explicitly express the interdependencies of these values (e.g. dependency between chordDB and pitchesPerOctave) -- replace all setters by a single setter SetDB which expects a record with the settings as features. All features are optional and missing features are substituted by their defaults. For this end, replace all these cells by a single cell and all accessors access features of the record in this cell.
%%
%%
%%
%%

functor
import
   
   FD FS RecordC
%    Browser(browse:Browse) 
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   HS_Score at 'Score.ozf'
   DBs at 'databases/Databases.ozf'
   
export

   SetDB
   % SetChordDB SetScaleDB
   % SetPitchesPerOctave SetPitchUnit SetAccidentalOffset SetOctaveDomain

   GetEditChordDB GetInternalChordDB
   GetEditScaleDB GetInternalScaleDB
   GetEditIntervalDB GetInternalIntervalDB
   GetPitchesPerOctave GetPitchUnit GetAccidentalOffset GetOctaveDomain

   MakePitchClassFDInt MakeOctaveFDInt MakeAccidentalFDInt
   MakeScaleDegreeFDInt MakeChordDegreeFDInt
   
   RatiosInDBEntryToPCs WasRatiosDBEntry

   Pc2Ratios

   GetChordIndex GetScaleIndex GetIntervalIndex
   GetComment GetName

   GetUntransposedRatios
   GetUntransposedRootRatio
   GetUntransposedRootRatio_Float
   
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

      %% maps db features to the respective setters
      Optional_DB_Setters = unit(chordDB:SetChordDB
				 scaleDB:SetScaleDB
				 intervalDB:SetIntervalDB
				 %% implicitly sets PitchUnit
				 pitchesPerOctave:SetPitchesPerOctave)
      %% complements Optional_DB_Setters: always set these features 
      Obligatory_DB_Setters = unit(accidentalOffset:SetAccidentalOffset
				   octaveDomain:SetOctaveDomain)
      
      %% !! I can not request of global lock from local space..
      %% MyLock = {NewLock} 	% to deny access while setting the database vars
   in
      /** %% Sets the database which is used by the HarmonisedScore contribution (e.g., its music representation and rules).
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
      
      %% All features of the DB and also of some sub-DBs (e.g. of the chordDB and scaleDB) are optional (as marked by square brackets). Missing features are set to the features of the default database (HS.dbs.default). However, in case PitchesPerOctave \= 12, then the following features are mandatory: chordDB, scaleDB and intervalDB.
      %% Note the above doc is unfinished: for further details read the doc of the aux accessors (available in the source file contributions/anders/HarmonisedScore/source/Database.oz).
      %%
      %% 'comment' feature of database entries: is either a single value (usually an atom) or a record.
      %% Naming database entries: either by an atom given to the 'comment' feature of a database, or an atom given to the 'name' feature of the record at the 'comment' feature, or -- for multiple alternative names -- a list of atoms given to the 'name' feature of the record at the 'comment' feature.
      %%
      %% TODO: write a better doc..
      %% */
      proc {SetDB NewDB}
	 %% [outdated comment] Locking to ensure that reading happens only after (or before) _all_ DB variables are updated, even in a concurrent program. It is the responsibility of the user to ensure that reading happens only _after_ setting the DB, therefore, doing this locking is in fact overdone.. 
	 %% lock MyLock then
	 %%
	 FullDB = {Adjoin DefaultDB NewDB}
      in
	 if FullDB.pitchesPerOctave == 12
	 then 
	    {Record.forAllInd {Adjoin Optional_DB_Setters
			       Obligatory_DB_Setters}
	     proc {$ Feat Setter} {Setter FullDB.Feat} end}
	 else
	    %% if PitchesPerOctave \= 12, then leave missing feats unset 
	    MissingFeats = {Filter {Arity Optional_DB_Setters}
			    fun {$ Feat} {Not {HasFeature NewDB Feat}} end}
	 in
	    if MissingFeats \= nil then
	       %% NOTE: tmp solution: chord, scale and interval database are all required if PitchesPerOctave \= 12. Later, I may allow for leaving out some of them, but then I must carefully check all dependencies.
	       {Exception.raiseError 
		strasheela(failedRequirement NewDB "If PitchesPerOctave \\= 12, then all of the following features must be given to SetDB: "#{Out.listToVS MissingFeats ", "})}
% 	    {Browse 'HS database setting: non-default PitchesPerOctave, so only explicitly specified database features are set. The following features are set to _'#MissingFeats} 
% 	       {ForAll MissingFeats
% 		proc {$ Feat} {Optional_DB_Setters.Feat unit} end}
 	    end
	    %% set explicitly given feats
	    {Record.forAllInd Optional_DB_Setters
	     proc {$ Feat Setter} {Setter NewDB.Feat} end}    
	    %% always set these
	    {Record.forAllInd Obligatory_DB_Setters
	     proc {$ Feat Setter} {Setter FullDB.Feat} end}
	 end
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
	 if {IsTuple NewChordDB} andthen {HasFeature NewChordDB 1} then
	    EditChordDB := NewChordDB
	    InternalChordDB := {EditToInteral NewChordDB}
	 elseif NewChordDB == unit orelse NewChordDB == nil then
	    EditChordDB := unit
	    InternalChordDB := unit
	 else raise malformedChordDB(NewChordDB) end
	 end 
      end
      %% !!?? unfinished doc?
      /** %% Sets the database of scales. The database has the same format as the chord database (see SetChordDB).
      %% */
      proc {SetScaleDB NewScaleDB}
	 %% there is at least one scale in NewScaleDB (more checking
	 %% within EditToInteral)
	 if {IsTuple NewScaleDB} andthen {HasFeature NewScaleDB 1} then
	    EditScaleDB := NewScaleDB
	    InternalScaleDB := {EditToInteral NewScaleDB}
	 elseif NewScaleDB == unit orelse NewScaleDB == nil then
	    EditScaleDB := unit
	    InternalScaleDB := unit
	 else raise malformedScaleDB(NewScaleDB) end
	 end 
      end

      proc {SetIntervalDB NewIntervalDB}
	 %% there is at least one interval in NewIntervalDB (more checking
	 %% within EditToInteral)
	 if {IsTuple NewIntervalDB} andthen {HasFeature NewIntervalDB 1} then
	    EditIntervalDB := NewIntervalDB
	    InternalIntervalDB := {EditToInteral NewIntervalDB}
	 elseif NewIntervalDB == unit orelse NewIntervalDB == nil then
	    EditIntervalDB := unit
	    InternalIntervalDB := unit
	 else raise malformedIntervalDB(NewIntervalDB) end
	 end 
      end
	    
      /** %% All pitch classes defined in the current functor are indexes into an equidistanct tuning. The tuning is defined by the number of pitches per octave (an integer, e.g. 12 for et12 or 1200 for cent values), the default is 12.
      %% Implicitly, SetPitchesPerOctave also sets the pitchUnit for all pitches and pitch classes. Common pitchUnit cases are midi (NewPitchesPerOctave=12), and midicent (NewPitchesPerOctave=1200). For any other value of NewPitchesPerOctave, the pitchUnit is set to an atom 'et&lt;Int&gt;', where '&lt;Int&gt;' is NewPitchesPerOctave (e.g., et31 or et72 for NewPitchesPerOctave=31 or NewPitchesPerOctave=72).
      %% */
      proc {SetPitchesPerOctave NewPitchesPerOctave}
	 if {IsInt NewPitchesPerOctave}
	 then PitchesPerOctave := NewPitchesPerOctave
	    case NewPitchesPerOctave
	    of 12 then {SetPitchUnit midi}
	    [] 1200 then {SetPitchUnit midicent}
	    else {SetPitchUnit {VirtualString.toAtom 'et'#NewPitchesPerOctave}}
	    end
	 else raise noInteger(NewPitchesPerOctave) end
	 end
      end
 
      proc {SetPitchUnit NewPitchUnit}
	 PitchUnit := NewPitchUnit
      end
      
      /** %% An accidental denotes an offset for a scaleDegree (a relative pitch class) or a noteName (an absolute pitch class, a scaleDegree into c-major). Because accidentals are FD integers, they can not be negative and thus an offset must be defined, the accidental offset. As the meaning of the numeric value of an accidental depends also on the maximum number of possible pitches between scale degrees (and thus on PitchesPerOctave), the offset can be set by the user.
      %% The default AccidentalOffset for common praxis music is 2.       
      %% NB: To avoid complicating the CSP definition with offsets, the use of the accidental conversions HarmonisedScore.score.absoluteToOffsetAccidental or HarmonisedScore.score.offsetToAbsoluteAccidental is recommended.
      %% */
      proc {SetAccidentalOffset NewOffset}
	 AccidentalOffset := NewOffset
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
	 ~{ToCent (PC - {Round PC})}
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

      MyName = {NewName}
   in
      /** %% Processes an entry for a HS database (e.g. for a chord database). HS depends on pitches as keynumbers and pitch classes (all represented by integers or FD ints), both depending on KeysPerOctave. RatiosInDBEntryToPCs, on the other hand, permits also ratios (floats or fractions specs) which are transformed and rounded to the nearest pitch class (a ratio representing an interval exceeding an octave is transformed into an interval within an octave). 
      %% MyDBEntry is a record with arbitrary features. Each feature value is either an interger, a list of integers, a ratio spec (either a float or a fraction spec in the form &lt;Int&gt;#&lt;Int&gt;), or a list of ratio specs. The output contains each integer/lists of integers unchanged but substitutes each ratio/list of ratios by the nearest pitch class interval (an integer), depending on KeysPerOctave (an integer).
      %% Additionally, a comment feature in MyDBEntry with arbitrary value is permitted. The returned record has always a comment feature with a record as value. The explanation of the comment in the return value is a bit complicated and depends on MyDBEntry. For features in MyDBEntry with a ratio, collect in comment the ratio, its pitch class plus the error, for other features in Test keep the orig value. In case MyDBEntry contains a feature comment as well, this value is preserved: in case MyDBEntry.comment is a record as well, its features are added to the comment record of the result. However, in case MyDBEntry.comment contains a feature 'comment' with the same feature as a feature in MyDBEntry itself, then the feature of MyDBEntry.comment is preferred. See the test file for examples.
      %% Because the comment feature of the returned DB entry is changed, the function WasRatiosDBEntry recognises a DB entry processed by RatiosInDBEntryToPCs.
      %%
      %% NB: in HS.db, an OctaveDomain is also specified as &lt;Int&gt;#&lt;Int&gt;, but must not be mixed up with a fraction spec.
      %% 
      %%
      %% BUG: reported error signs not correct -- check JI signs (you know what to expect..)
      %% */
      proc {RatiosInDBEntryToPCs MyDBEntry KeysPerOctave Out}
	 %% Internally, KeysPerOctave arg is always a float
	 KeysPerOctave_F = {IntToFloat KeysPerOctave} 
	 % Comment = {Record.clone MyDBEntry}
	 Comment = {RecordC.tell {Label MyDBEntry}}
	 %% sort PC ratios to start with root -- important for GetDegree (e.g. for adaptive JI) 
	 MyDBEntry_Sorted
	 = {Adjoin MyDBEntry
	    {Adjoin
	     if {HasFeature MyDBEntry pitchClasses}
	     then
		PCs = MyDBEntry.pitchClasses
		Root = MyDBEntry.roots.1
	     in
		unit(pitchClasses:
			if {All PCs GUtils.isRatio}
			then
			   %% sorted in ascending order and (first) root is always first.
			   %% important for correct adaptive JI (so HS.score.getDegree returns currect ratio position)
			   {MUtils.sortRatios2 PCs Root}
			else RootPos = {LUtils.position Root PCs} in
			   {Append {List.drop PCs RootPos-1} {List.take PCs RootPos-1}} 
			end)
	     else unit
	     end
	     {Label MyDBEntry}}}
      in
	 if {HasFeature MyDBEntry_Sorted comment}
	 then
	    if {IsRecord MyDBEntry_Sorted.comment} andthen {Width MyDBEntry_Sorted.comment} > 0
	    then {Record.forAllInd MyDBEntry_Sorted.comment
		  proc {$ Feat X}
		     Comment ^ Feat = X
		  end}
	    else
	       Comment ^ comment = MyDBEntry_Sorted.comment
	    end
	 end
	 Out = {Record.clone {Adjoin
			      unit(comment:_) %% compulsary feat 'comment'
			      MyDBEntry_Sorted}}
	 %%
	 {Record.forAllInd {Record.subtract MyDBEntry_Sorted comment}
	  proc {$ Feat X}
	     proc {BindComment Val}
		CommentFeat = Comment ^ Feat
	     in
		%% for features which are contained in both MyDBEntry_Sorted
		%% and MyDBEntry_Sorted.comment, the (already
		%% determined) value of MyDBEntry_Sorted.comment is kept
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
	     else raise unsupportedValue(RatiosInDBEntryToPCs MyDBEntry_Sorted value:X) end
	     end
	  end}
	 Out.comment = Comment
	 %% add feature for recognising processed records
	 Comment ^ MyName = unit
	 %% close comment
	 {RecordC.width Comment} = {Length {RecordC.reflectArity Comment}}
      end

      /** %% Returns true if MyDBEntry was processed by RatiosInDBEntryToPCs.
      %% */
      fun {WasRatiosDBEntry MyDBEntry}
	 {HasFeature MyDBEntry comment} andthen
	 {HasFeature MyDBEntry.comment MyName}
      end
      
   end

   local
      %% NOTE: I tried adding support for multiple names (feat 'comment' or 'name' may get list). Does not work out of the box, though -- transformation of DB from edit format into internal format somehow scrables comments containing a list
      fun {IsMatching Entry Feat MyName}
	 {HasFeature Entry Feat} andthen
	 (Entry.Feat == MyName orelse
	  ({IsList Entry.Feat} andthen {Member MyName Entry.Feat}))
      end
      fun {Index MyName DB}
	 X = {LUtils.find {Record.toListInd DB}
	      fun {$ _/*I*/#X}
		 DBEntry = if {WasRatiosDBEntry X} then X.comment else X end
	      in
		 {IsMatching DBEntry comment MyName} orelse
		 {IsMatching DBEntry name MyName}
	      end}
      in
	 case X of  I#_/*DBEntry*/ then I
	 else nil
	 end
      end
   in
      /** %% Convenience functions. ChordIndex expects a name (atom) for a chord and returns the corresponding index. This name is either the value stored under the edit database feature 'comment', or the value of a feature 'name' of a record stored under the edit database feature 'comment'. If no database entry with this name is defined, then nil is returned.
      %% ScaleIndex and IntervalIndex do the same for scales and intervals.
      %% */
      %%
      %% Problem: RatiosInDBEntryToPCs transforms edit DB so that comment feature contains extended version of orig comment (for storing additional information like the PC errors and ratios)
      fun {GetChordIndex MyName} {Index MyName {GetEditChordDB}} end
      fun {GetScaleIndex MyName} {Index MyName {GetEditScaleDB}} end
      fun {GetIntervalIndex MyName} {Index MyName {GetEditIntervalDB}} end
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


   /** %% Expects a chord, scale or interval object and returns the comment value in its internal database format.
   %% Blocks until the index parameter is determined.
   %% */
   fun {GetComment X}
      if {HS_Score.isScale X}
      then {GetInternalScaleDB}.comment.{X getIndex($)}
      elseif {HS_Score.isChord X}
      then {GetInternalChordDB}.comment.{X getIndex($)}
      elseif {HS_Score.isInterval X}
      then {GetInternalIntervalDB}.comment.{X getIndex($)}
      else {Exception.raiseError
	    strasheela(failedRequirement X "must be interval, chord or scale object")}
	 unit			% never returned
      end
   end
   /** %% Returns the name of a chord, scale or interval specified in its database entry (a VS, usually an atom). The name is a list of atoms (its a list because there are sometimes multiple name alternatives). Returns nil if no name was found.
   %% Blocks until the index parameter is determined.
   %%
   %% The name is often specified as an atom at the 'comment' feature of a database entry. Alternatively, the entry defines a record at the 'comment' feature, and then the name is and atom at the feature 'name' in this subrecord, or a list of atoms at the feature 'name' (for specifying multiple alternative names).  
   %% */
   fun {GetName X}
      Comment = {GetComment X}
      NameAux = if {IsRecord Comment} then
		   if {HasFeature Comment comment} andthen {IsVirtualString Comment.comment}
		   then Comment.comment
		   elseif {HasFeature Comment name}
		   then Comment.name
		   else nil
		   end
		end
   in
      if {IsList NameAux} then NameAux else [NameAux] end 
   end

   local
      fun {GetRatios_aux PC_Specs}
	 {LUtils.mappend PC_Specs
	  fun {$ PC_Spec}
	     if {IsRecord PC_Spec} andthen {HasFeature PC_Spec ratio}
	     then [PC_Spec.ratio]
	     else nil
	     end
	  end}
      end
      %% NOTE: some functions below share code -- copy and paste was just more simple for now...
      %%
      /** %% Returns the ratios specs by which the chord MyChord is declared in the chord database. If the chord was declared by pitch classes instead and thus no ratios are available then nil is returned.
      %% */
      fun {GetUntransposedChordRatios MyChord}
	 DB_Entry = {GetEditChordDB}.{MyChord getIndex($)}
      in
	 case DB_Entry of chord(comment:chord(pitchClasses:PC_Specs
					      ...)
				...)
	 then {GetRatios_aux PC_Specs}
	 else nil
	 end
      end
      /** %% Returns the ratio specs by which the chord's MyChord roots are declared in the chord database. If the root was declared by a pitch class instead and thus no ratio is available then nil is returned.
      %% */
      fun {GetUntransposedChordRootRatio MyChord}
	 DB_Entry = {GetEditChordDB}.{MyChord getIndex($)}
      in
	 case DB_Entry of chord(comment:chord(roots:PC_Specs
					      ...)
				...)
	 then {GetRatios_aux PC_Specs}
	 else nil
	 end
      end
      /** %% Returns the ratios specs by which the scale MyScale is declared in the scale database. If the scale was declared by pitch classes instead and thus no ratios are available then nil is returned.
      %% */
      fun {GetUntransposedScaleRatios MyScale}
	 DB_Entry = {GetEditScaleDB}.{MyScale getIndex($)}
      in
	 case DB_Entry of scale(comment:scale(pitchClasses:PC_Specs
					      ...)
				...)
	 then {GetRatios_aux PC_Specs}
	 else nil
	 end
      end
      /** %% Returns the ratio specs by which the scales's MyScale roots are declared in the scale database. If the root was declared by a pitch class instead and thus no ratio is available then nil is returned.
      %% */
      fun {GetUntransposedScaleRootRatio MyScale}
	 DB_Entry = {GetEditScaleDB}.{MyScale getIndex($)}
      in
	 case DB_Entry of scale(comment:scale(roots:PC_Specs
					      ...)
				...)
	 then {GetRatios_aux PC_Specs}
	 else nil
	 end
      end
   in
      /** %% Returns the ratios specs by which X (chord or scale object) is declared in the database. If X was declared by pitch classes instead and thus no ratios are available then nil is returned.
      %% */
      fun {GetUntransposedRatios X}
	 if {HS_Score.isChord X} then {GetUntransposedChordRatios X}
	 elseif {HS_Score.isScale X} then {GetUntransposedScaleRatios X}
	 end
      end
      /** %% Returns the ratio specs by which the roots of X (chord or scale object) are declared in the database. If the root was declared by a pitch class instead and thus no ratio is available then nil is returned.
      %% */
      fun {GetUntransposedRootRatio X} 
	 if {HS_Score.isChord X} then {GetUntransposedChordRootRatio X}
	 elseif {HS_Score.isScale X} then {GetUntransposedScaleRootRatio X}
	 end
      end
      /** %%  Returns the frequency ratio of the [first] root of X (chord or scale object) as a float. For example, if the ratio 1#1 or the pitch class 0 is declared as root, then 1.0 is returned; it it is 3#2 then 1.5 is returned.
      %%
      %% NB: blocks until root and transposition of X are determined. 
      %% */
      fun {GetUntransposedRootRatio_Float X}
	 if {X getRoot($)} == {X getTransposition($)} then 1.0
	 else 
	    UntransposedRootRatio = {GetUntransposedRootRatio X}
	 in
	    if UntransposedRootRatio \= nil then
	       %% root defined by ratio
	       %%
	       {MUtils.transposeRatioIntoStandardOctave
		%% NOTE: simplicitation: just take first root (when is there more than one actually in any database?)
		{GUtils.ratioToFloat UntransposedRootRatio.1}}
	    else
	      PitchesPerOctave = {GetPitchesPerOctave}
	    in
	       %% root defined as PC
	       %%
	       {MUtils.keynumToFreq
		{IntToFloat {X getUntransposedRoot($)}} {IntToFloat PitchesPerOctave}}
	       / {MUtils.keynumToFreq 0.0 {IntToFloat PitchesPerOctave}}
	    end
	 end   
      end
   end
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   %% !! initialise database -- evaluated when linked functor/module is 'used' for first time (i.e. when something defined in the functor is accessed for the first time)
   {SetDB DefaultDB}
   
end
