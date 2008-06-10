
%%% *************************************************************
%%% Copyright (C) 2005-2008 Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% This functor defines distribution strategie (and parts thereof) for harmonic CSPs.
%% */

functor

import
   HS_Score at 'Score.ozf'
   SDistro at 'x-ozlib://anders/strasheela/source/ScoreDistribution.ozf'

export
   MakeOrder_TimeScaleChordPitchclass
   MakeOrder_TimeScaleChordPitchclassOctave
   
   IsNoTimepointNorPitch 
   TypewiseHSDistro
   
define


   /** %% Defines a full distribution strategy for harmonic CSPs, which visits parameters type-wise. As the distribution is a record, single aspects (e.g., the value ordering) can be overwritten, e.g., using Adjoin.
   %%
   %% Filtering: Parameters are filtered with IsNoTimepointNorPitch. 
   %% Variable ordering: First the time parameters are determined, then scale, the chord and then pitch class parameters. Whenever a note pitch class parameter is determined, its corresponding octave is determined next.
   %% Value ordering: min
   %%
   %% NB: defines a select function for marking octaves -- don't overwrite that.
   %% */
   %%
   %% after determining a pitch class of a note, the next distribution
   %% step has to determine the octave of that note! Such distribution
   %% strategy results in clear performance increasing -- worth
   %% discussion in thesis. Increases performance by factor 10 at least !!
   %%
   %% ?? Can I get the same effect with left-to-right breaking ties with these type checks?
   %%
   %% BUG: (i) octave is already marked, although pitch class is still undetermined, (ii) octave does not get distributed next anyway.
   TypewiseHSDistro
   = unit(
	value:min
	%% value:random % mid % min % 
	select: fun {$ X}
		   %% !! needs abstraction
		   %%
		   %% mark param to determine next
		   if {HS_Score.isPitchClass X} andthen
		      {{X getItem($)} isNote($)}
		   then {{{X getItem($)} getOctaveParameter($)}
			 addInfo(distributeNext)}
		   end
		   %% the ususal parameter value select
		   {X getValue($)}
		end
	order:fun {$ X Y}
		 %% !! needs abstraction
		 %%
		 %% always checking both vars: rather inefficient..
		 if {X hasThisInfo($ distributeNext)}
		 then true
		 elseif {Y hasThisInfo($ distributeNext)}
		 then false
		    %% else do the usual distribution
		 else {{MakeOrder_TimeScaleChordPitchclass SDistro.dom} X Y}
		 end
	      end
	test: IsNoTimepointNorPitch)
   
   
   /** %% [variable ordering constructor] Returns a score variable ordering. A variable ordering is a binary function expecting two parameter objects and returning a boolean value, which is given to the argument 'order' expected by score solvers. This variable ordering first visits time parameters, then scale, then chord, and then pitch class parameters. It breaks ties (i.e. both parameters are the same type or not one of these type) with the score variable ordering P. For example, P can be SDistro.dom.
   %% */
   fun {MakeOrder_TimeScaleChordPitchclass P}
      {SDistro.makeSetPreferredOrder
       %% Preference order of distribution strategy
       [%% !!?? first always timing?
	fun {$ X} {X isTimeParameter($)} end
	%% first search for scales then for chords
	fun {$ X} {HS_Score.isScale {X getItem($)}} end
	fun {$ X} {HS_Score.isChord {X getItem($)}} end
	%% prefer pitch class over octave (after a pitch class, always the octave is determined, see below)
	%% !!?? does this always make sense? Anyway, usually the pitch class is the more sensitive param. Besides, allowing a free order between pitch class and octave makes def to determine the respective pitch class / octave next much more difficult
	fun {$ X}
	   %% only for note pitch classes: pitch classes in chord or scale are already more preferred by checking that item is isPitchClassCollection
	   {HS_Score.isPitchClass X}
	end
       ]
      P}
   end

   
   /** %% [variable ordering constructor] Returns a score variable ordering. This variable ordering first visits time parameters, then scale, then chord, then pitch class parameters, and then octaves. It breaks ties (i.e. both parameters are the same type or not one of these type) with the score variable ordering P. For example, P can be SDistro.dom.
   %% */
   fun {MakeOrder_TimeScaleChordPitchclassOctave P}
      {SDistro.makeSetPreferredOrder
       %% Preference order of distribution strategy
       [%% !!?? first always timing?
	fun {$ X} {X isTimeParameter($)} end
	%% first search for scales then for chords
	fun {$ X} {HS_Score.isScale {X getItem($)}} end
	fun {$ X} {HS_Score.isChord {X getItem($)}} end
	fun {$ X} {HS_Score.isPitchClass X} end
	fun {$ X} {X hasThisInfo($ octave)} end
       ]
      P}
   end


   /** %% [Parameter filtering test] Score distribution should only be performed on the parameters necessary for efficiency. IsNoTimepointNorPitch returns false for the following parameter types: time points, and pitch parameters with one of the following info tags: root, untransposedRoot and notePitch (notePitch is added to a note's pitch parameter info tags by PitchClassMixin), and true otherwise.
   %% NB: using this test for filtering is suitable for many harmonic CSPs. When time intervals (duration and offset time parameters) are determined, then time points will be determined by propagation. Similarily, pitch parameters will be determined by propagation if the pitch class and octave are determined. Nevertheless, depending on your CSP this filtering might not be appropriate. For example, if your CSP uses chord and scale degrees for notes, then it may be appropriate to filter these parameters out as well or alternatively filter out the note pitch class parameters.
   %% */
   fun {IsNoTimepointNorPitch X}
      %% {Not {{X getItem($)} isContainer($)}} orelse
      {Not {X isTimePoint($)}} orelse
      {Not {X isPitch($)} andthen
       ({X hasThisInfo($ root)} orelse
	{X hasThisInfo($ untransposedRoot)} orelse
	{X hasThisInfo($ notePitch)})}
   end
   
end
