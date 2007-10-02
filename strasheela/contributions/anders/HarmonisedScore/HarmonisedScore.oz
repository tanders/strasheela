
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

/** %% Functor defines the top-level for a Strasheela extension which provides the user with means to define her/his own theory of harmony. For instance, HarmonisedScore defines generic representations for analytical objects such as chords and scales. Analytical objects are silent when the score is played, but constrains may restrict relations between actual notes in the score and such analytical objects.
%% The functor provides convenient means in a highly generic way -- the proposed concepts may therefore appear very abstract at first...
%%
%% This functor only exports subfunctors.
%%
%%
%% Terminology: (all terms denote numeric values)
%% ============
%%
%% pitch:
%% absolute pitch number. If pitchesPerOctave=12 (default), pitch is the common MIDI note number. The pitches per octave setting denotes any equidistant tuning (e.g. pitchesPerOctave=1200 results in a cent resolution). Among all such settings, the pitch 0 is always the same pitch (thus the MIDI pitch 60 and the MIDIcent pitch 6000 are equal).
%% Here, 'absolute pitch' means that the pitch is independent of any chord or scale in the piece. Nonetheless, the pitch depends of course on the general tuning of the concert pitch.
%%
%%
%% This pitch information can be expressed more elaborated by a compound representation consisting in a pitchClass and an octave. 
%%
%%
%% pitchClass:
%% absolute pitch number without octave component. If pitchesPerOctave=12, the meaning of pitchClass is defined as by Forte (??) (e.g. c# = 1). The range of possible pitchClasses is always in the interval [0, pitchesPerOctave-1]. Thus, for other pitches per octave settings, the pitchClass value 1 does not mean c# as in Forte anymore. For instance, for pitchesPerOctave=1200 the pitchClass value 1 means c raised by 1 cent instead.
%% See also HarmonisedScore.score.pitchClassToPitch
%%
%% octave:
%% number of octave to which pitch belongs starting with c. Middle c has octave 4, according to conventions (cf. http://en.wikipedia.org/wiki/Scientific_pitch_notation). 
%%
%%
%% This pitch class information can be expressed more elaborated by a compound representation consisting in a degree and an accidental (depending on a pitch class collection such as a scale).
%%
%%
%% degree:
%% a relative pitch representation which denotes quasi an index into a collection of pitch classes. This collection of pitch classes consists often in the pitch classes of a scale. However, other pitch class collections (e.g. the pitch classes of a chord) are possible as well.  
%% In case of a 'neutral' accidental (see below), the degree denotes the the pitch class of the pitch class collection at the position of the degree. For instance (given pitchesPerOctave=12), in case the pitch class collection consists in the pitch classes of the C-major scale -- [0, 2, 4, 5, 7, 9, 11] -- the degree 2 denotes the pitch class at position 2: the second of C-major denotes the pitch class 2 (i.e. the pitch class of d). However, the pitch class collection collection can contain an arbitrary collection of pitch classes, e.g., the D-minor chord [2 5 9]. For this collection, the degree 2 denotes the third in the chord (i.e. the pitch class 5 representing the pitch class of f).
%% The accidental has the effect of 'alternating' which pitch class the degree means. For instance, the degree 2 for the C-major scale with an accidental denoting the interval ~1 (a flat) the degree 2 for the C-major (i.e. denoting d-flat).
%% However, the actual meaning of the degree always depends on the meaning of the pitch class it is pointing to. Thus, the meaning of the degree also depends on the value of PitchesPerOctave.
%% See also HarmonisedScore.score.degreeToPC
%% 
%%
%% accidental:
%% An accidental is a device to express an 'alternating' of the pitch class denoted by a degree. The meaning of its actual numeric value is a bit complicated and depends on a two factors: (i) the maximum number of 'accumulated' accidentals (such as bb or x) which may be chosen dependent on the possible pitch classes between the pitch classes in the collection, and (ii) because Oz FD integers must be non-negative an offset must be added which depends also on (i). For common praxis, this accidentalOffset defaults 2, thus the common accidentals are numerically encoded as such: bb=0, b=1, neutral=2, #=3, x=4.
%% The accidental actually denotes an transposition interval for the pitch class to which the degree is pointing. Because the meaning of numeric intervals depend on the value of pitchesPerOctave, also the numeric value of the accidental depends on pitchesPerOctave. For instance, for pitchesPerOctave=1200 an accidental denoting the interval ~1 means a flatted pitch by only a single cent.
%% NB: To allow the user more flexibility, the accidentalOffset is not automatically set when the user sets the pitchesPerOctave value. Instead, the accidentalOffset can be set independently (see DB.setDB).
%% NB: In case of determined accidentals in the CSP definition, the user should avoid complicating the definition with accidentals encoded this way. Instead, the use of the accidental conversions Score.absoluteToOffsetAccidental or Score.offsetToAbsoluteAccidental is recommended.
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
   Score at 'source/Score.ozf'
   Rules at 'source/Rules.ozf'
   DBs at 'source/databases/Databases.ozf'
export
   db:DB
   dbs:DBs
   score:Score
   rules:Rules
end
