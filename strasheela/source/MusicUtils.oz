
%%% *************************************************************
%%% Copyright (C) 2002-2005 Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% This functor defines some utilities which are related to music or acoustics.
%% */
	    
functor
import
%    Browser(browse:Browse)
   GUtils at 'GeneralUtils.ozf'
   LUtils at 'ListUtils.ozf'
   Init at 'Init.ozf'
   Out at 'Output.ozf'
   %% NOTE: dependency to contribution
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
   
export
   KeynumToFreq FreqToKeynum
   IsET GetPitchesPerOctave
   PitchToMidi
   RatioToKeynumInterval % RatioToCent
   KeynumToPC
   TransposeRatioIntoStandardOctave RatioToStandardOctaveFloat
   SortRatios SortRatios2
   RatioToRatioPC OddLimit PrimeLimit
   
   LevelToDB DBToLevel
   Freq0
   FullTuningTable

   MakeNoteLengthsTable MakeNoteLengthsRecord MakeDurationsRecord
   SetNoteLengthsRecord ToDur SetDurationsRecord ToNoteLengths
   
define
   /** %% freq at keynum 0, keynum 69 = 440 Hz
   %% */
   Freq0 = 8.175798915643707 
   /** %% Transforms a Keynum into the corresponding frequency in an equally tempered scale with KeysPerOctave keys per octave. The function is 'tuned' such that {KeynumToFreq 69.0 12.0} returns 440.0 Hz. All arguments must be floats and a float is returned.
   %% NB: The term Keynum here is not limited to a MIDI keynumber but denotes a keynumber in any equidistant tuning. For instance, if KeysPerOctave=1200.0 then Keynum denotes cent values.
   %% */
   fun {KeynumToFreq Keynum KeysPerOctave}
      {Pow 2.0 (Keynum / KeysPerOctave)} * Freq0
   end
   /** %% Transforms Freq into the corresponding keynum in an equally tempered scale with KeysPerOctave keys per octave. The function is 'tuned' such that {FreqToKeynum 440.0 12.0} returns 69.0. All arguments must be floats and a float is returned.
   %% NB: The term Keynum here is not limited to a MIDI keynumber but denotes a keynumber in any equidistant tuning. For instance, if KeysPerOctave=1200.0 then Keynum denotes cent values.
   %% */
   fun {FreqToKeynum Freq KeysPerOctave}
      {GUtils.log (Freq / Freq0) 2.0} * KeysPerOctave
   end

    /** %% Returns true if PitchUnit is an atom which matches the pattern et<Digit>+ such as et31 or et72.
   %% */
   fun {IsET PitchUnit}
      S = {AtomToString PitchUnit}
      H T
   in
      {List.takeDrop S 2 H T}
      %% 
      H == "et" andthen T \= nil andthen
      {All T fun {$ C} {Char.isDigit C} end} 
   end
   /** %% Returns the pitches per octave expressed by an ET pitch unit, e.g., for et31 it returns 31. 
   %% */
   fun {GetPitchesPerOctave EtPitchUnit}
      {StringToInt {List.drop {AtomToString EtPitchUnit} 2}}
   end

   
   local
      LastNonmatchingPitchunit = {NewCell midi}
   in
      /** %% Transforms Pitch (an int) measured in PitchUnit (an atom) into the corresponding "Midi float" (a float), i.e. a Midi number where positions after the decimal point express microtonal pitch deviations (e.g., 60.5 is middle C raised by a quarter tone). Possible pitch units are midi (i.e., 12-TET), midicent/midic, frequency/freq/hz, mHz and and arbitrary equal temperaments (e.g., et31, et72).
      %% The transformation takes account a tuning table defined with Init.setTuningTable. Alternatively, a tuning table can be given directly to the optional arg 'table'.
      %% */
      proc {PitchToMidi Pitch PitchUnit Args ?Result}
	 Default = unit(table:nil)
	 As = {Adjoin Default Args}
	 FullTable = if As.table==nil
		     then {Init.getTuningTable}
		     else {FullTuningTable As.table}
		     end
	 Pitch_F = {IntToFloat Pitch}
      in
	 if FullTable == nil 
	 then 
	    %% !! IsDet does not wait for binding -- quasi side effect. 
	    if {Not {IsDet PitchUnit}}
	    then {GUtils.warnGUI 'pitch unit unbound'}
	    end
	    Result = case PitchUnit
		     of midi then Pitch_F
% 		   [] keynumber then Value
% 		[] et72 then Value / 6.0 % * 12.0 / 72.0
% 		[] et31 then Value * 12.0 / 31.0 
% 		[] et22 then Value * 12.0 / 22.0 
		     [] midicent then Pitch_F / 100.0
		     [] midic then Pitch_F / 100.0
		     [] millimidicent then Pitch_F / 10000.0
		     [] frequency then {FreqToKeynum Pitch_F 12.0}
		     [] freq then {FreqToKeynum Pitch_F 12.0}
		     [] hz then {FreqToKeynum Pitch_F 12.0}
		     [] mHz then {FreqToKeynum Pitch_F/1000.0 12.0}
		     else
			if {IsET PitchUnit}
			then Pitch_F * 12.0 / {IntToFloat {GetPitchesPerOctave PitchUnit}}
			else
			   {Exception.raiseError
			    strasheela(failedRequirement PitchUnit
				       "Supported pitch units are midi, midicent (or midic), frequency (or freq), hz, mHz, and arbitrary equal temperaments (notated et<number>).")}
			   unit		% never returned
			end
		     end
	 else 
	    PC = Pitch mod FullTable.size
	    Octave = Pitch div FullTable.size
	 in
	    %% warn if pitch unit and tuning table size don't
	    %% match, but only once until a new pitch unit was
	    %% found.
	    if PitchUnit \= @LastNonmatchingPitchunit andthen 
	       {IsET PitchUnit} andthen 
	       FullTable.size \= {GetPitchesPerOctave PitchUnit}
	    then LastNonmatchingPitchunit := PitchUnit
	       {GUtils.warnGUI
		"Conflict between size of tuning table ("#FullTable.size#") and pitch unit ("#PitchUnit#")!"}
	    end
	    %% ?? BUG: PC + 1 ?
	    % Result = (FullTable.period * {IntToFloat Octave} + FullTable.(PC + 1)) / 100.0
	    Result = (FullTable.period * {IntToFloat Octave} + FullTable.PC) / 100.0
	 end
      end
   end
   
   /** %% Transforms Ratio (either a float or a fraction specification in the form <Int>#<Int>) into the corresponding keynumber interval in an equally tempered scale with KeysPerOctave (a float) keys per octave. Returns a float.
   %% For example, {RatioToKeynumInteval 1.0 12.0}=0.0 or {RatioToKeynum 1.5 12.0}=7.01955). 
   %% NB: The term Keynum here is not limited to a MIDI keynumber but denotes a keynumber in any equidistant tuning. For instance, if KeysPerOctave=1200.0 then Keynum denotes cent values.
   %% */ 
   fun {RatioToKeynumInterval Ratio KeysPerOctave}
      case Ratio
      of Nom#Den 
      then {FreqToKeynum ({IntToFloat Nom} / {IntToFloat Den} * Freq0) KeysPerOctave}
      else {FreqToKeynum (Ratio * Freq0) KeysPerOctave}
      end
   end
%    /** %% Variant of RatioToKeynumInterval which directly outputs a cent value (a float).
%    %% */
%    fun {RatioToCent Ratio} {RatioToKeynumInterval Ratio 1200.0} end
   
   /** %% Transforms a keynumber (a float) in an equally tempered scale with KeysPerOctave (a float) into its corresponding pitch class (a float) in [0, PitchesPerOctave).
% %% */
   fun {KeynumToPC Keynum PitchesPerOctave}
      {GUtils.mod_Float Keynum PitchesPerOctave}
   end

   /** %% Expects a frequency ratio (a float) and octave transposes it into interval [1.0, 2.0]
   %% */
   fun {TransposeRatioIntoStandardOctave Freq}
      if Freq >= 2.0 then {TransposeRatioIntoStandardOctave Freq / 2.0}
      elseif Freq < 1.0 then {TransposeRatioIntoStandardOctave Freq * 2.0}
      else Freq
      end
   end
   /** %% Expects a ratio (pair of ints Nom#Denom) and returns the corresponding float, octave transposed into interval [1.0, 2.0].
   %% */
   fun {RatioToStandardOctaveFloat Ratio}
      {TransposeRatioIntoStandardOctave
       {GUtils.ratioToFloat Ratio}}
   end

   /** %% Expects a list of ratios and sorts them in ascending order (assuming all are situated in the same octave). For example, {SortRatios [4#1 5#1 6#1 7#1 9#1 11#1]} returns [4#1 9#1 5#1 11#1 6#1 7#1].
   %% */
   fun {SortRatios Ratios}
      {Sort Ratios
       fun {$ R1 R2}
	  {RatioToStandardOctaveFloat R1} < {RatioToStandardOctaveFloat R2}
       end}
   end
   /** %% Expects a list of ratios and sorts them in ascending order (assuming all are situated in the same octave). However, the first ratio in the result is StartRatio (which must occur in Ratios), and all smaller ratios are appended at the end. For example, {SortRatios2 [1#3 1#4 1#5 1#7] 1#7} returns [1#7 1#3 1#5 1#4].
   %% */
   fun {SortRatios2 Ratios StartRatio}
      SortedRs = {SortRatios Ratios}
      Pos = {LUtils.position StartRatio SortedRs}
      Xs Ys
   in
      if Pos == nil then
	 {Exception.raiseError
	  strasheela(failedRequirement StartRatio
		     "ratio not contained in ["
		     #{Out.listToVS {Map Ratios fun {$ X} {Value.toVirtualString X 2 2} end}
		       " "}
		     #"]")}
	 unit			% never returned
      else
	 {List.takeDrop SortedRs Pos-1 Xs Ys}
	 {Append Ys Xs}
      end
   end


   /* %% Transposes ratios Nom#Denom (pair if ints) into the octave 1#1 to 2#1. Returns ratio (pair of ints).
   %% */
   fun {RatioToRatioPC Nom#Denom}
      Ratio_F = {GUtils.ratioToFloat Nom#Denom}
   in
      if Ratio_F > 2.0
      then {RatioToRatioPC if {IsEven Nom}
			   then (Nom div 2)#Denom
			   else Nom#(Denom * 2)
			   end}
      elseif Ratio_F < 1.0
      then {RatioToRatioPC if {IsEven Denom}
			   then Nom#(Denom div 2)
			   else (Nom * 2)#Denom
			   end}
      else Nom#Denom
      end
   end
   /** %% Returns the odd limit of Ratio (pair of ints).
   %% Restriction: ratio is in lowest terms.
   %% */
   fun {OddLimit Ratio}
      Nom#Denom = {RatioToRatioPC Ratio}
   in
      {Sort {Filter [Nom Denom] IsOdd} Value.'>'}.1
   end
   
   /** %% Returns the prime limit of Ratio (pair of ints).
   %% */
   fun {PrimeLimit Nom#Denom}
   %    Nom#Denom = {RatioToRatioPC Ratio}
   % in
      {Sort [{List.last {GUtils.primeFactors Nom}}
	     {List.last {GUtils.primeFactors Denom}}]
       Value.'>'}.1
   end

   
   /** %% Converts a linear amplitude level L into an logarithmic amplitude (decibels).  LRel is the relativ full level.
   %% */
   fun {LevelToDB L LRel}
      20.0 * {GUtils.log (L / LRel) 10.0}
   end
   /** %%  Converts a logarithmic amplitude DB (decibels) into a linear amplitude level.  LRel is the relativ full level.
   %% */
   fun {DBToLevel DB LRel}
      LRel * {Pow  10.0 (DB / 20.0)}
   end

   /** %% Expects a tuning table declaration (see Init.setTuningTable for format) and returns a full tuning table used for pitch computation. The returned full table is a record which contains only pitches measured in cent, has 0.0 added as first table value, and has the two features size and period added.   
   %% */
   fun {FullTuningTable TuningTable}
      PureTable = {Record.subtractList TuningTable [size period]}
      FullTable = {Adjoin unit(0: 0.0)
		   {Record.map PureTable
		    fun {$ X}
		       case X of _#_ 
		       then {RatioToKeynumInterval X 1200.0}
		       else X
		       end
		    end}}
   in
      {Adjoin FullTable
       unit(size: if {HasFeature TuningTable size}
		  then TuningTable.size
		  else {Width TuningTable}
		  end
	    %% NOTE: ?? Required that this is given? Should always be 1200.0 anyway...
	    period: if {HasFeature TuningTable period}
		    then TuningTable.period
		    else FullTable.{LUtils.findBest {Arity PureTable} Value.'>'}
		    end)}
   end

   /** %% MakeNoteLengthsTable creates a list which maps symbolic note lengths to duration values. Expects the duration of a beat (i.e. the timeUnit is beats(Beat)) and a list of tuplet fractions to take into consideration (e.g., [3 5] denotes triplets and quintuplets). The function returns a list of pairs NotationI#DurI. NotationI is denotes a symbolic note length as a virtual string, and DurI is the corresponding duration (an int). 
   %% Notation of symbolic note lengths:
   %% plain durations: 'd' followed by reciprocal values. Example: d#4 is quarter note
   %% dotted note lengths: plain duration followed by _ (underscore). Example: d#4#'_' is quarter note + eighth note. Multiple dots are not supported (simply add multiple durations instead).
   %% tuplets (notated as individual note lengths): t followed by a number indicating the fraction, followed by the duration. Example: t#3#d#4 is a triplet quarter note and t#3#d#4#'_' is a dotted triplet note. Nested tuplets are not supported.
   %% ties: simply add the resulting durations of the individual notes.
   %%
   %% */
   fun {MakeNoteLengthsTable Beat TupletFractions}
      Beat4 = Beat*4
      /* %% Translates notation 1/D into corresponding duration. E.g., if D=4 then the result is Beat.
      %% Only works for durations which "fit into" Beat.
      %% */
      fun {Symdur2Dur D}
	 Beat * 4 div D
      end
      /** %% Returns list of pairs DurName#Dur for "plain durations". Create pairs for "plain durations" (1, 1/2, 1/4 etc.), in increasing order of durations (i.e. decreasing order of duration names)
      %% */
      fun {MakePlainDurPairs D}
	 fun {Aux D Accum}
	    if {GUtils.isDivisible Beat4 D}
	    then {Aux D*2
		  (d#D) # {Symdur2Dur D} | Accum}
	    else Accum
	    end
	 end
      in
	 {Aux D nil}
      end
      /** %% Returns list of pairs DurName#Dur for tuplets
      %% */
      %% code doublications with MakePlainDurPairs..
      fun {MakeTupletDurPairs D_outer}
	 fun {Aux D Accum}
	    if {GUtils.isDivisible Beat4 D}
	    then {Aux D*2
		  (t#D_outer#d#(D*2 div D_outer))#{Symdur2Dur D} | Accum}
	    else Accum
	    end
	 end
      in
	 {Aux D_outer nil}
      end
      /** %% Expects a list of dur pairs of one kind (e.g., plain or triplet) and returns the corresponding dotted dur pairs -- appended to DurPairs.
      %% */
      fun {MakeDottedPairs DurPairs}
	 if DurPairs == nil then nil
	 else 
	    {Append DurPairs
	     {Pattern.map2Neighbours DurPairs
	      fun {$ _#Dur1 Name2#Dur2}
		 Feat = {Width Name2}+1
	      in
		 {Adjoin Name2 '#'(Feat:'_')}#Dur1+Dur2
	      end}}
	 end
      end
      %%
      PlainDurPairs = {MakeDottedPairs {MakePlainDurPairs 1}}
      AllTupletDurPairs = {LUtils.mappend TupletFractions
			   fun {$ I} {MakeDottedPairs {MakeTupletDurPairs I}} end}
   in
      {Append PlainDurPairs AllTupletDurPairs}
   end
   /** %% Returns a record which maps symbolic note lengths (atoms which are record features) to duration values (integers, feature values in the record). See the documentation of MakeNoteLengthsTable for the arguments Beat and TupletFractions, and also the symbolic note length notation. However, whereas in MakeNoteLengthsTable this notation uses VSs (so it can be easily decomposed) here it uses atoms for convenience.
   %%
   %% Example: create a record R and then use this record for notating symbolic durations.  
   %% R = {MakeNoteLengthsRecord 15 [3 5]}
   %% R.d4    % quarter note
   %% R.d4t3  % quarter note triplet
   %% */
   fun {MakeNoteLengthsRecord Beat TupletFractions}
      {List.toRecord unit
       {Map {MakeNoteLengthsTable Beat TupletFractions}
	fun {$ Symbol#Dur} {VirtualString.toAtom Symbol}#Dur end}}
   end
   /** %% Returns a record which maps durations (integers, feature values in the record) to lists of symbolic note lengths (atoms which are record features). See the documentation of MakeNoteLengthsTable for the arguments Beat and TupletFractions, and also the symbolic note length notation.
   %% */
   fun {MakeDurationsRecord Beat TupletFractions}
      %% group DurI#NotationI pairs with same duration such that the notations are collected in a single list 
      fun {Accumulate Xs}
	 case Xs of [D#N] then [D#N]
	 [] D1#N1 | D2#N2 | R then
	    if D1 == D2 then
	       {Accumulate D1#{Append N1 N2} | R}
	    else D1#N1 | {Accumulate D2#N2 | R}
	    end
	 end
      end
   in
      {List.toRecord unit
       {Map 			% put most simple notation at front 
	{Accumulate
	 %% sort by duration
	 {Sort  {Map {MakeNoteLengthsTable Beat TupletFractions}
		 fun {$ Symbol#Dur} Dur#[Symbol] end}
	  fun {$ X Y} X.1 < Y.1 end}}
	fun {$ Dur#Notations}
	   Dur # {Sort Notations fun {$ X Y} {Width X} < {Width Y} end}
	end}}
   end

   local
      R = {NewCell {MakeNoteLengthsRecord 4 nil}}
   in
      /** %% Initialises transformation for ToDur. See the documentation of MakeNoteLengthsTable for the arguments Beat and TupletFractions.
      %% */
      proc {SetNoteLengthsRecord Beat TupletFractions}
	 R := {MakeNoteLengthsRecord Beat TupletFractions}
      end
      /** %% Expects a symbolic note length (atom) and returns the corresponding duration. Use SetNoteLengthsRecord for initialisation (default is {SetNoteLengthsRecord 4 nil}).
      %% */
      fun {ToDur NoteLength}
	 @R.NoteLength
      end
   end
   local
      R = {NewCell {MakeDurationsRecord 4 nil}}
   in
      /** %% Initialises transformation for ToNoteLengths. See the documentation of MakeNoteLengthsTable for the arguments Beat and TupletFractions.
      %% */
      proc {SetDurationsRecord Beat TupletFractions}
	 R := {MakeDurationsRecord Beat TupletFractions}
      end
      /** %% Expects a duration (int) and returns a list of the corresponding symbolic note lengths. Use SetDurationsRecord for initialisation (default is {MakeDurationsRecord 4 nil}).
      %% */
      fun {ToNoteLengths Dur}
	 @R.Dur
      end
   end
   
   
end

