
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
   GUtils at 'GeneralUtils.ozf'
export
   KeynumToFreq FreqToKeynum RatioToKeynumInterval KeynumToPC
   LevelToDB DBToLevel
   Freq0
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
   /** %% Transforms a keynumber (a float) in an equally tempered scale with KeysPerOctave (a float) into its corresponding pitch class (a float) in [0, PitchesPerOctave).
% %% */
   fun {KeynumToPC Keynum PitchesPerOctave}
      {GUtils.mod_Float Keynum PitchesPerOctave}
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
   
end

