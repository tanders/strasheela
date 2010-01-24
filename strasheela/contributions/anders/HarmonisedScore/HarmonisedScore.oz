
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

/** %% This functor defines a harmony model for Strasheela. This functor exports several subfunctors. 
%%
%% The harmony model provides users with the means for defining their own theory of harmony. The functor defines representations for analytical concepts (such as intervals, chords and scales), provides databases with information for specific instances of such analytical concepts (e.g. specific chords), and also predefines generic rules on harmonic concepts. Strasheela objects representing analytical concepts such as intervals, chords and scales are silent when the score is played. However, constraints may restrict relations between actual notes in the score and such analytical objects.
%%
%% The harmony model provides convenient means in a highly generic way. For example, the model is suitable for theories of harmony is the conventional 12-tone equal-temperament. However, also microtonal music is supported: the representations for analytical concepts are suitable for any other equal division of the octave, and that way also for approximations of just intonation. For this purpose, the model generalises established concepts of 12-tone equal-temperament for other equal-temperaments. A number of fundamental terms which are generalised are explained below.
%% 
%% The present functor is the top-level functor of the harmony model. It primarily exports subfunctors.
%%
%%
%% Terminology: (all terms denote integers and can be represented by FD ints)
%% ============
%%
%% pitch:
%% Pitches are integers and they are hence evenly spaced. The user can freely specify the number of pitches per octave. If PitchesPerOctave=12 (the default), pitch is the common MIDI note number. PitchesPerOctave=1200, on the other hand, results in a MIDIcent pitch unit. 
%% By default, the pitches per octave setting denotes an equidistant tuning. In addition, the user can specify a tuning table (e.g., globally set with Init.setTuningTable) which affects the pitches used during playback. Nevertheless, the pitches in a CSP are still integer. For example, the user can specify PitchesPerOctave=12 (i.e. the pitch unit is et12) where the pitch 60 denotes 'C4' and 64 denotes 'E4'. However, the global tuning table might be set to meantone temperament, that is, the MIDI pitch 64 playback is tuned to a just major third, the MIDI float 63.863.   
%%
%%
%% This pitch information can be expressed more elaborated by a compound representation consisting in a pitchClass and an octave. 
%%
%%
%% pitchClass:
%% a pitch without octave component. Like all other parameters defined by this functor, the pitch class is an integer. If pitchesPerOctave=12, the meaning of pitchClass is defined as by Allen Forte (e.g. c# = 1). The range of possible pitchClasses is always in the interval [0, pitchesPerOctave-1]. However, for other pitches per octave settings, the pitchClass value 1 does not mean c# as in Forte's definition anymore. For instance, for pitchesPerOctave=1200 the pitchClass value 1 means c raised by 1 cent instead.
%% Note that the playback of a pitch class (plus octave) can depend on a tuning table (see above). See also HS.score.pitchClassToPitch.
%%
%% octave:
%% number of octave to which a pitch belongs. Every transposition of c starts a new octave. Middle c has octave 4, according to conventions (cf. http://en.wikipedia.org/wiki/Scientific_pitch_notation), and thus octave 0 (the lowest octave) starts with pitch 12. Also an interval can be represented by a pitch class and an octave, but for an interval the octave 0 starts with the interval's pitch distance 0 (i.e. the pitch distance 12 has the octave 1 and differs in that respect from a pitch octave). 
%%
%%
%% This pitch class information can be expressed more elaborated by a compound representation consisting in a degree and an accidental (depending on a pitch class collection such as a scale).
%%
%%
%% degree:
%% a relative pitch representation which denotes quasi an index into a collection of pitch classes. This collection of pitch classes consists often in the pitch classes of a scale. However, other pitch class collections (e.g. the pitch classes of a chord) are possible as well.  
%% In case of a 'neutral' accidental (see below), the degree denotes the pitch class in the collection at the position of that degree. For instance (given pitchesPerOctave=12), in case the pitch class collection consists in the pitch classes of the C-major scale -- [0, 2, 4, 5, 7, 9, 11] -- the degree 3 denotes the pitch class at position 3 (the third of C-major), which is the pitch class 4 (i.e. the pitch class of e). However, the pitch class collection can contain an arbitrary collection of pitch classes, e.g., the D-minor chord [2 5 9]. For this collection, the (chord) degree 3 denotes the third note in the chord (i.e. the pitch class 9 representing the pitch class of a).
%% The accidental has the effect of 'alternating' which pitch class the degree means. For instance, the degree 3 for the C-major scale with an accidental denoting the interval ~1 (a flat) is the pitch class 4 together with the flat-accidental (i.e. denoting e-flat).
%% Please remember that the meaning of a pitch class depends on the PitchesPerOctave. This naturally effects the meaning of degrees. For example, if PitchesPerOctave=1200 then degrees point into a collection of pitch classes measured in MIDIcent.
%% See also HarmonisedScore.score.degreeToPC
%% 
%%
%% accidental:
%% An accidental is a device to express an 'alternating' of the pitch class denoted by a degree. The meaning of its actual numeric value is a bit complicated due to the fact that a FD integer must be positive. It depends on two factors: (i) the maximum number of 'accumulated' accidentals allowed (e.g., to sharp # accumulate to x in common praxis), and (ii) an offset, which must be added to the accidental value (because even flats must be non-negative) and which depends also on (i). The maximum number of 'accumulated' accidentals may be chosen dependent on the possible pitch classes between the pitch classes in the collection. For example, if the pitch class collection is harmonic C-minor [0, 2, 3, 5, 7, 8, 11] a double-sharp may be permitted to optionally bridge the pitch gap between the pitch classes 8 and 11). For common praxis, the accidental offset defaults 2, thus the common accidentals are numerically encoded as such: bb=0, b=1, neutral=2, #=3, x=4.
%% The accidental actually denotes an transposition interval for the pitch class to which the degree is pointing. Because the meaning of numeric intervals depend on the value of pitchesPerOctave, also the numeric value of the accidental depends on pitchesPerOctave. For instance, for pitchesPerOctave=1200 an accidental denoting the interval ~1 means a flatted pitch by only a single cent.
%% Please note that determined accidentals are specified more easily using the accidental conversions Score.absoluteToOffsetAccidental and Score.offsetToAbsoluteAccidental. The function Score.absoluteToOffsetAccidental expects an accidental without added offset (e.g., ~1 means b, and 0 means neutral) and internally uses the accidental offset to convert this accidental accordingly.
%% NB: To allow the user more flexibility, the accidentalOffset is not automatically set when the user sets the pitchesPerOctave value. Instead, the accidentalOffset can be set independently (see DB.setDB).
%%
%% */


%% unused terms
%% (I temporarily keep them here, just in case..)
%%
%% scaleDegree:
%% relative pitch, index into user defined transposed scale (e.g. if scale is d-major, absolute f# is scale degree 3). Thus, a scaleDegree is a relative pitch because it depends on a scale.
%%
%% scaleAccidental: an accidental for scaleDegree, similar to the accidental for noteName
%%
%% ?? noteName: absolute pitch, index into c-major scale (e.g. note e is 3)  [noteName is unused yet]
%% 
%%
%%


%%
%% Nachdenken:

%% Conveniently establishing relations between notes and chords/scales 
%%
%% * with Note mixins InScore and InScale I have convenient means to define whether or not a note is related to a chord/scale:
%%
%%   - which chord/scale a note is related to is generically and conveniently defined with init args getChords, isRelatedChord and friends
%%
%%   - new params InChordB/InScaleB can be freely constrained
%%
%%   - even better: there are convenient means to define in what cases non-chord/non-scale pitches are permitted.
%%
%% * However, I have no way to access the chord/scale to which the note is related (as reflected by InChordB/InScaleB). Similarily, I have no way to access all notes related to a chord/scale from the chord/scale. Usages for both scenarios:
%%
%%   - I case I could access the chord/scale a note is related to, I could easily define new constraints such as constraining the degree of the note in the chord/scale.
%%
%%   - Similarily, from the chord I could define that in the union of all chord-related note  pitch classes there is at least one representing degree n (e.g. the seventh of the dominant)
%%
%%   !!! - easy to do this as long as relation note-chord is determined in problem def.: use accessor getChords and store result in note attr (and vice versa). However, in case this relation is undetermined in the problem def. I use reified constraints to constraint value, e.g., of InChordB. In case each item is marked with an unique int ID, I could somehow constrain (in a reified way) a note's param/attr ChordID to the ID of the related chord. I could use this information to access the respective chord from the list of chord candidates. However, any additional constraint which depends on accessing the right chord will only be applied _after_ this relation is fully established. That is, there is no constraint propagation. But at least..
%%
%% - nochmal: getChords returns list of candidates of related chords, which is bound to some note attr. Each chord is marked with unique numeric ID (int). The note is related to exactly one chord (vergesse erstmal den Fall das getChords nil zurueckgibt). An additional note param/attr RelatedChordID is FD int constrained to the ID of the single chord related to the chord. As soon as RelatedChordID is determined, a further note attr RelatedChord can be bound and its value can be constrained.. This could happen rather late, but it is something..
%% -> Now, how to constrained RelatedChordID?: for each pair Chord#IsRelatedChordB def
%% {FD.equi (RelatedChordID =: {Chord getID($)}) (IsRelatedChordB =: 1)}
%%
%%
%% the other way round (access all notes related to chord) is more hard to do: the number of notes is unknown and I therefore can hardly tell at what time all related notes are known..
%%
%% -> Anyway, is this effort worth the trouble? Fuer meine eigene kompositorische Arbeit ist das was ich jetzt habe warscheinlich (zunaechst ;-) genug. Mehr waere vor allem fuer das sehr genaue Modellieren von traditionellen Stilen vonnoeten.. Und so genau will es vielleicht gar keiner z.Z. der Diss wissen..



%%
%% * I introduced degree + accidental: I can use the accidental to express relations of non-chord/non-scale pitch classes to a chord/scale. Besides, the note params inChord or inScale also express this relation of a note pitch to a chord/scale. This info should be propagated between accidental and inChord/inScale (i.e. if accidental not neutral then inChord/inScale=0)
%%
%% * In the same issue: Do I want to introduce the notion of alternated chords, i.e. chords in the music representation which differ from some chord in the database. Or shall all chords/scales in the actual score be a literate (but possibly transposed) copy of some chord/scale in the database? Otherwise, things can get quite complex..
%%
%% * I think, I should have for every 'chord variation' (i.e. either alternated or with additional note) a model in the database. However, to avoid symmetries in the solution scores I should add additional constraints:
%%
%%   - !! for chord database 'instances' in the score, which are a variation of some other chord in the database the variated (i.e. either added or alterated) pitches are constrained to really sound (e.g. for a dominant seventh, at least a single note must sound the seventh)
%%
%%  - optionally, chord variations are further constrained (e.g. not to follow each other or to be excluded in a chord progression if another variante is present etc)
%%
%%

%%
%% TODO:
%%
%% * Binding of databases to cell is inconsistent with Motif contribution (which defines database class instead). Database class would also allow multiple chord etc databases in a single CSP (e.g. different databases for different sections).
%%
%% * OK? check whether terminology is used consistently
%%

functor
import
   DB at 'source/Database.ozf'
   HS_Score at 'source/Score.ozf'
   Rules at 'source/Rules.ozf'
   DBs at 'source/databases/Databases.ozf'
   HS_Distro at 'source/Distribution.ozf'
   HS_Out at 'source/Output.ozf'

   %% for Pitch etc.
   ET12 at 'x-ozlib://anders/strasheela/ET12/ET12.ozf'
   ET22 at 'x-ozlib://anders/strasheela/ET22/ET22.ozf'
   ET31 at 'x-ozlib://anders/strasheela/ET31/ET31.ozf'
   ET41 at 'x-ozlib://anders/strasheela/ET41/ET41.ozf'
   
export
   db: DB
   dbs: DBs
   score: HS_Score
   rules: Rules
   distro: HS_Distro
   out: HS_Out
   
   Acc pc:PC pcName:PCName Pitch
   
define

   %% Aux for PC etc. MakeTranslation simply calls respective function of respective ET<Int> functor, i.e. this works only for specific equal temperaments.
   fun {MakeTranslation FnSymbol}
      fun {$ X}
	 PitchesPerOctave = {DB.getPitchesPerOctave}
      in
	 case PitchesPerOctave
	 of 12 then {ET12.FnSymbol X}
	 [] 22 then {ET22.FnSymbol X}
	 [] 31 then {ET31.FnSymbol X}
	 [] 41 then {ET41.FnSymbol X}
	 else 
	    {Exception.raiseError
	     strasheela(failedRequirement PitchesPerOctave "No symbolic pitch translation supported for "#PitchesPerOctave#" ET.")}
	    unit		% never returned
	 end
      end
   end

   /** %% Transforms symbolic accidental (atom) into the corresponding accidental integer, depending on {HS.db.getPitchesPerOctave}. Note: function only works for specific values of {DB.getPitchesPerOctave} (e.g., 12, 22, 31, 41).
   %% */
   Acc = {MakeTranslation acc}

   /** %% Transforms symbolic note name (atom) into the corresponding pitch class integer, depending on {HS.db.getPitchesPerOctave}. Note: function only works for specific values of {DB.getPitchesPerOctave} (e.g., 12, 22, 31, 41).
   %% */
   PC = {MakeTranslation pc}

   /** %% Transforms pitch class integer into list of corresponding symbolic note names (atoms). Note: function only works for specific values of {DB.getPitchesPerOctave} (e.g., 12, 22, 31, 41).
   %% */
   PCName = {MakeTranslation pcName}  
      
   /** %% Translates a symbolic pitch P in the format PC#Octave (PC is an atom, Octave is an int) into the corresponding pitch integer, depending on {HS.db.getPitchesPerOctave}. Note: function only works for specific values of {DB.getPitchesPerOctave} (e.g., 12, 22, 31, 41).
   %% */
   Pitch = {MakeTranslation pitch}  
   
   
   
end
