
%%% *************************************************************
%%% Copyright (C) Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Module linking: link all Strasheela modules are loaded as
%% demonstrated in the template init file ../_ozrc
%%
%% Additionally, this example makes use of auxiliary definitions defined in
%% ./AuxDefs/AuxDefs.ozf.  To link the functor with auxiliary
%% definition of this file: within OPI (i.e. emacs) start Oz from
%% within this buffer (e.g. by C-. b). This sets the current working
%% directory to the directory of the buffer.
declare
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs/AuxDefs.ozf.bin']}
%% I usually link the selection constraints also in my OZRC, just in
%% case it is linked here as well
[Select] = {ModuleLink ['x-ozlib://duchier/cp/Select.ozf']}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% This example creates a four-voice homophonic chord progression in
%% extended just intonation. The chords are all transpositions of the
%% two chords which constitute Harry Partch's 11-limit tonality
%% diamond (cf. Partch [1974]). This two chords can be freely
%% transposed (i.e. the resultiong chord progression can contain chord
%% transpositions which are not part of the original diamond).
%%
%% Yet, a few harmonic rules restrict the progression. For instance,
%% the interval between the root notes of two neighbouring notes (the
%% chord root is the 1/1 of the untransposed chord) is restricted in
%% its dissonance degree (the dissonance degree of an interval is
%% deduced from Partch's one-footed bridge): this interval must be a
%% fifth, fourth, minor/major third or minor/major sixth. This allows
%% for mediant-like chord root progressions like C major -> E flat
%% major (simplified to 5-limit chords).
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Create a database of chords and intervals for extended just intonation. 
%%
%% The example uses 5-limit to 11-limit extended just intonation
%% (http://tonalsoft.com/enc/l/limit.aspx) which is rounded to 72 EDO
%% (http://tonalsoft.com/enc/number/72edo.aspx). This rounding can be
%% easily changed (e.to cent precisision) by changing the value of
%% PitchesPer100Cent (by that needlessly increases the search space).
%%


% PitchesPer100Cent = 1    % 12 EDO 
PitchesPer100Cent = 6    % 72 EDO
% PitchesPer100Cent = 100  % pitches measured in cent -- no appropriate notation output defined...
PitchesPerOctave = PitchesPer100Cent * 12


%%
%% VoiceNo (number of voices) depends on chordDB, because all sim
%% pitch classes must differ. In addition, VoiceNo must not be larger
%% than 6 (or problems in MakeScript occur).
%%
%% So, just uncomment one of the setting pairs below.
%%

/*
VoiceNo = 3 
{HS.db.setDB unit(chordDB:{HS.dbs.partch.get5LimitDiamondChords PitchesPerOctave}
		  intervalDB:{HS.dbs.partch.getIntervals PitchesPerOctave}
		  pitchesPerOctave:PitchesPerOctave
		  %% NB: still default et12 scales in database (scales
		  %% are not used in this example).
		  % scaleDB:MyScaleDB
		 )}
*/

VoiceNo = 4 
{HS.db.setDB unit(chordDB:{HS.dbs.partch.get7LimitDiamondChords PitchesPerOctave}
		  intervalDB:{HS.dbs.partch.getIntervals PitchesPerOctave}
		  pitchesPerOctave:PitchesPerOctave
		  %% NB: still default et12 scales in database (scales
		  %% are not used in this example).
		  % scaleDB:MyScaleDB
		 )}


/*
%% either VoiceNo is 5 or 6 
% VoiceNo = 5 
VoiceNo = 6 
{HS.db.setDB unit(chordDB:{HS.dbs.partch.get11LimitDiamondChords PitchesPerOctave}
		  intervalDB:{HS.dbs.partch.getIntervals PitchesPerOctave}
		  pitchesPerOctave:PitchesPerOctave
		  %% NB: still default et12 scales in database (scales
		  %% are not used in this example).
		  % scaleDB:MyScaleDB
		 )}
*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% top-level definition: create score and apply rules
%%

fun {MakeScript Args} 
   Default = unit(chordNo:10	% number of chords
		  dur:4        % dur of each chord and note (default semibreve)
		  %% rule args
		  maxRootPrimeLimit:5
		  maxRootIntervalDissDegree:3
		  minRootPositions:6
		  maxMelodicSkipsPerVoice:2)
   As = {Adjoin Default Args}
in 
   proc {$ MyScore}
      %% creates homophonic chord progression. All voice notes and all
      %% chords with same duration.
      fun {MakeVoice unit(midiPitchDomain:PD1#PD2
			  info:Info)}
	 %% midiPitchDomain: for convenience, the note pitch domain is
	 %% specified as MIDI keynumber. Internally, this domain is
	 %% transformed to the microtonal resolution defined by
	 %% PitchesPer100Cent
	 {Score.makeScore2
	  seq(items:{LUtils.collectN As.chordNo
		     fun {$}
			note(duration:As.dur
			     pitch:{FD.int PD1*PitchesPer100Cent#PD2*PitchesPer100Cent})
		     end}
	      info:Info)
	  Aux.myCreators}
      end
      %% order of voices: bass last. However, the pitch domains are
      %% given in reverse order to ensure proper pitch domain for
      %% bass etc.
      PitchDomains = {Reverse {List.take [48#60 55#67 57#69 59#71 60#72 60#72]
			       VoiceNo}}
      Voices = {List.mapInd PitchDomains fun {$ I D}
					    {MakeVoice unit(midiPitchDomain:D
							    info:voice#I)}
					 end}
      ChordSeq = {Score.makeScore2
		  seq(info:chordSeq
		      items:{LUtils.collectN As.chordNo
			     fun {$} chord(duration:As.dur) end})
		  Aux.myCreators}
      Chords = {ChordSeq getItems($)}
   in
      MyScore = {Score.makeScore
		 sim(items:{Append Voices
			    [ChordSeq]}
		     startTime:0
		     timeUnit:beats(1))
		 Aux.myCreators}
      %%
      %% SCORE RULES
      %%
      %% all chord notes are distinct
      {DistinctSimPitchClasses MyScore}
      {NoVoiceCrossing MyScore}
      %% no skip in bass into 6 or 4/6 chord etc. 
      {ApproriateChordInversion MyScore As.minRootPositions}
      {RestrictMelodicIntervals MyScore As.maxMelodicSkipsPerVoice}
      %%
      %% CHORD SEQ RULES
      %%
      %% start and end with 'tonic'
%      {StartAndEndWithRelatedChords ChordSeq}
      {StartAndEndWithEqualChords ChordSeq}
      %% no chord repetition (root repetition is also disallowed by StrongProgression)
%      {HS.rules.distinctNeighbours Chords}
      %% every chord unique (except first and last)
      {HS.rules.pairwiseDistinct Chords.2}
      {StrongProgression Chords As.maxRootIntervalDissDegree}
      %%
      {RestrictRootPrimeLimit Chords As.maxRootPrimeLimit}
      {RestrictUtonalityRoot Chords}
      %% all chord indices are 2 (i.e. utonality)
%   {ForAll Chords proc {$ MyChord} {MyChord getIndex($)} = 2 end}   
      %% all chord indices are 1 (i.e. otonality)
%   {ForAll Chords proc {$ MyChord} {MyChord getIndex($)} = 1 end}      
   end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Rules defined for the whole score
%%

/** %% The pitch classes of any set of simultaneous notes are all distinct
%% */
proc {DistinctSimPitchClasses MyScore}   
   proc {MyRule MyNote}
      %% the pitch classes of MyNote and all its sim notes are distinct
      %%
      %% !!?? use FD.distinct instead?
      {FD.distinctD {Map MyNote|{MyNote getSimultaneousItems($ test:isNote)}
		     fun {$ X} {X getPitchClass($)} end}}
   end
in
   %% apply MyRule on any note of soprano voice in MyScore
   {{MyScore findItem($ {MkInfoCheck voice#1})} forAllItems(MyRule)} 
end

/** %% No voice crossing: the order of the pitches of all sim notes starting with the first (i.e. highest voice) is decreasing.
%% */
proc {NoVoiceCrossing MyScore}   
   proc {MyRule HighestNote}
      {Pattern.decreasing
       {Map HighestNote|{HighestNote getSimultaneousItems($ test:isNote)}
	fun {$ X} {X getPitch($)} end}}
   end
in
   %% apply MyRule on any note of first voice in MyScore
   {{MyScore getItems($)}.1
    forAllItems(MyRule)} 
end


/** %% Bass may only skip into chord root, otherwise only steps. First and last bass notes must be roots. At lease MinRootPositions chords are in root position (usually, root position is preferred).
%% */
%% !!?? wenn chord index = 5 (for specific chord DB) gibt es keine Loesung wegen ChordInversion??
proc {ApproriateChordInversion MyScore MinRootPositions}
   BassVoice = {MyScore findItem($ {MkInfoCheck voice#VoiceNo})}
   /** %% B=1 <-> interval between BassNote pitch and the pitch of its predecessor is larger than 2*PitchesPer100Cent (i.e. a major second)
   %% */
   proc {IsSkippingR Note1 Note2 B}
      B = {FD.reified.distance {Note1 getPitch($)} {Note2 getPitch($)}
	   '>:' 2*PitchesPer100Cent}
   end
   /** %% B=1 <-> BassNote pitch class equals root of simultaneous chord object
   %% */
   proc {IsChordRoot BassNote B}
      %% take first sim chord (there is only one)
      MyChord = {BassNote getSimultaneousItems($ test:HS.score.isChord)}.1
   in
      B = ({BassNote getPitchClass($)} =: {MyChord getRoot($)})
      %% redundant constraint to improve propagation (not all chords
      %% include root in its pitch classes)
      {FD.impl B
       {FS.reified.include {MyChord getUntransposedRoot($)}
	{MyChord getUntransposedPitchClasses($)}}
       1}
   end
   BassNotes = {BassVoice getItems($)}
   %% 0/1 vars expressing whether chords are in root position
   RootPositionBs = {Map BassNotes IsChordRoot}
   %% number of chords in root position
   RootPositionNo = {FD.decl} 
in
   %% first and last chord in root position
   RootPositionBs.1 = 1
   {List.last RootPositionBs} = 1
   %% control number of root positions
   RootPositionNo = {Pattern.howManyTrue RootPositionBs}
   RootPositionNo >=: MinRootPositions
   %% only apply to butLast of BassNotes to avoid redundant propagators
   {Pattern.for2Neighbours {LUtils.butLast BassNotes} 
    proc {$ BassNote1 BassNote2}
       {FD.impl
	{IsSkippingR BassNote1 BassNote2}
	{IsChordRoot BassNote2}
	1}
    end}
end


/** %% Restrict the melodic interval of each voice to a fifth (3/2) at maximum. In addition, restrict each upper voices (i.e. except the bass) to have MaxMelodicSkipsPerVoice. That is, in case MaxMelodicSkipsPerVoice = 0, then the voice consists only in steps (9/8 at maximum).
%% */
%%
%% Possible changes/enhancements: give max standard skip size as arg + number of exceptions permitted as arg
proc {RestrictMelodicIntervals MyScore MaxMelodicSkipsPerVoice}
   proc {GetInterval Pitch1 Pitch2 Interval}
      Interval = {FD.decl}
      Interval = {FD.distance Pitch1 Pitch2 '=:'}
   end
   proc {IsStep Interval B}
      B = {FD.int 0#1}
      B =: (Interval =<: MajorSecond)
   end
   proc {RestrictInterval Interval}
      Interval =<: Fifth
   end
   proc {MyRule_UpperVoice MyVoice}
      Intervals = {Pattern.map2Neighbours {MyVoice mapItems($ getPitch)}
		   GetInterval}
      StepNo = {FD.decl}
   in
      {ForAll Intervals RestrictInterval}
      StepNo = {Pattern.howManyTrue {Map Intervals IsStep}}
      StepNo >=: MaxMelodicSkipsPerVoice      
   end
   proc {MyRule_Bass MyVoice}
      Intervals = {Pattern.map2Neighbours {MyVoice mapItems($ getPitch)}
		   GetInterval}
   in
      {ForAll Intervals RestrictInterval}     
   end
   %% !! depends on unchanged score topology
   Voices = {LUtils.butLast {MyScore getItems($)}}
%   Voices = {MyScore findItem($ {MkInfoCheck voice#_})}
   Fifth = {RatioToKeynum 3#2}
   MajorSecond = {RatioToKeynum 9#8}
in
   {ForAll {LUtils.butLast Voices} MyRule_UpperVoice}
   {MyRule_Bass {List.last Voices}}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Rules defined for the ChordSeq
%%


/** %% Ensures ChordSeq starts and ends with something like a tonic. Unifies the root of the first and last chord. Additionally, this root is constrained to 0 (i.e. c) to reduce the search space.
%% */
% proc {StartAndEndWithRelatedChords ChordSeq}
%    FirstChord = {ChordSeq getItems($)}.1
%    LastChord = {List.last {ChordSeq getItems($)}}
% in
%    {FirstChord getRoot($)} = {LastChord getRoot($)} = 0
% end
proc {StartAndEndWithEqualChords ChordSeq}
   FirstChord = {ChordSeq getItems($)}.1
   LastChord = {List.last {ChordSeq getItems($)}}
in
   {FirstChord getRoot($)} = {LastChord getRoot($)} = 0
   {FirstChord getIndex($)} = {LastChord getIndex($)}
end

% /** %% The first chord in ChordSeq is set to a low dissonance degree. The dissonance degree can only change gradually across the  ChordSeq: the distance between the dissonance degree of neighbouring notes is restricted.
% %% */ 
% proc {DissonanceDegreeProgression ChordSeq}
%    DissonanceDegrees = {Map {ChordSeq getItems($)}
% 			fun {$ X} {HS.rules.getFeature X dissonanceDegree} end}
%    LowestDissonanceDegree = 3 % lowest dissonance degree in selected chord database
%    MaxDissonanceDegreeDistance = 1
% in
%    DissonanceDegrees.1 =<: LowestDissonanceDegree
%    {Pattern.for2Neighbours DissonanceDegrees
%     proc {$ X Y}
%        {FD.distance X Y
% 	'=<:' MaxDissonanceDegreeDistance}
%     end}
% end



/** %% simple ADT for interval as record: attributes index, interval value accessible as record feats
%%
%% NB: HS.score will at some stage provide a suitable data structure (which is still missing).
%% */
proc {MakePartchInterval MyInterval}
   %% interval DB: Partch intervals
   IntervalDB = {HS.db.getInternalIntervalDB}.interval
   Index = {FD.decl}
   IntervalVal = {FD.decl}
in
   {Select.fd IntervalDB Index IntervalVal}
   MyInterval = interval(index:Index
			 value:IntervalVal)
end
/** %% [aux def] HS.rule.getFeature variant for intervals 
%% */
proc {GetIntervalFeature MyInterval Feat I}   
   FeatDB = {HS.db.getInternalIntervalDB}.Feat
in
   I = {Select.fd FeatDB MyInterval.index}    
end

% /** %% Schoenberg [1911] introduced the notion of strong chord root progressions. This rule is inspired by Schoenberg's notion, but this notion is also clearly transformed in this rule.
% %% A progression is strong in case the interval between the root pitches of two neighbouring chords meets a certain condition: the interval must be from Partch's 43-tone scale and the dissonance degree of this interval must be below or equal MaxDissDegree.
%% Ensure reasonable chord progression. 
%% dissonance degree 2 corresponds, e.g., to major/minor third, 3
%% to minor/major sixth, and 4 to harmonic seventh
% %% */ 
% %% limit dissonance degree of intervals between chord roots.
proc {StrongProgression Chords MaxDissDegree}
   ChordRoots = {Map Chords fun {$ X} {X getRoot($)} end}
in 
   {Pattern.for2Neighbours ChordRoots
    %% constrain the pitch class intervals between
    %% neighbouring roots to form a partch interval with DissDegree
    proc {$ Root1 Root2}
       %% !!?? is PartchInterval always determined?       
       PartchInterval = {MakePartchInterval}
       DissDegree = {GetIntervalFeature PartchInterval dissonanceDegree}
    in
       {HS.score.transposePC Root1 PartchInterval.value Root2}
       %% DissDegree must not be 0 (unison), but thats also implicitly
       %% constrained by HS.rules.distinctNeighbours
%       DissDegree \=: 0
       MaxDissDegree >=: DissDegree
    end}
end

proc {RestrictRootPrimeLimit Chords MaxLimit}
   ChordRoots = {Map Chords fun {$ X} {X getRoot($)} end}
in 
   {ForAll ChordRoots
    proc {$ Root}
       PartchInterval = {MakePartchInterval}
       Limit = {GetIntervalFeature PartchInterval limit}
    in
       Root = PartchInterval.value
       MaxLimit >=: Limit 
    end}
end

% proc {RestrictRootIntervalPrimeLimit Chords MaxLimit}
%    ChordRoots = {Map Chords fun {$ X} {X getRoot($)} end}
% in 
%    {Pattern.for2Neighbours ChordRoots
%     proc {$ Root1 Root2}
%        PartchInterval = {MakePartchInterval}
%        Limit = {GetIntervalFeature PartchInterval limit}
%     in
%        {HS.score.transposePC Root1 PartchInterval.value Root2}
%        MaxLimit >=: Limit
%     end}
% end

/** %% If chord is Utonality then untransposed root is 4/3 (and not 1/1, which is possible too).
%% */ 
proc {RestrictUtonalityRoot Chords}
   {ForAll Chords
    proc {$ MyChord}
       Fourth = {RatioToKeynum 4#3}
       UtonalityB = {FD.int 0#1}
       SuitableRootB = {FD.int 0#1}
    in
       UtonalityB =: ({MyChord getIndex($)} =: 2)
       SuitableRootB =: ({MyChord getUntransposedRoot($)} =: Fourth)
       {FD.impl UtonalityB SuitableRootB 1}
    end}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Aux defs 
%%

/** %% Returns test function. This test function returns true in case its argument stores Info as info. 
%% */
fun {MkInfoCheck Info}
   fun {$ X}
      {X hasThisInfo($ Info)}
   end
end

/** %% Transforms ratio spec in format X#Y into pitchclass matching current PitchesPerOctave.
%% */ 
fun {RatioToKeynum Ratio}
   {FloatToInt {MUtils.ratioToKeynumInterval Ratio
		{IntToFloat PitchesPerOctave}}}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Explorer: add Lilypond output for microtonal music 
%%

/** %% Transforms the pitch class PC into a ratio VS. Alternative ratio transformations are given (written like 1/2|1/3). If no transformation existists, 'n/a' is output.
%% !! The partch DB does not contain all PC I need for et72 (I go beyond limit 11). Shall I create the necessary interval database automatically??
%% */
fun {PC2RatioVS PC}
   IntervalDB = {HS.dbs.partch.getIntervals {HS.db.getPitchesPerOctave}}
   fun {PrettyRatios Ratios}
      %% alternative ratio transformations written as 1/2|1/3
      {Out.listToVS
       {Map Ratios fun {$ Nom#Den} Nom#'/'#Den end}
       '|'}
   end
   Ratios = {HS.db.pc2Ratios PC IntervalDB}
in
   if Ratios == nil
   then 'n/a'
   else {PrettyRatios Ratios}
   end
end
/** %% Returns unary function expecting chord. Lilyout: Outputs single root note and all added signs returned by MakeAddedSigns (unary fun expecting chord and returing articulations etc added to the root note)
%% */
fun {MakeChordToLily MakeAddedSigns}
   fun {$ X}
      Rhythms = {Out.lilyMakeRhythms {X getDurationParameter($)}}
   in
      if Rhythms == nil
      then ' '
      else 
	 RootPitch = {Out.lilyMakePitch {X getRootParameter($)}}
	 AddedSigns = {MakeAddedSigns X}
	 FirstChord = RootPitch#Rhythms.1#AddedSigns#' ' 
      in
	 if {Length Rhythms} == 1
	 then FirstChord
	 else FirstChord#{Out.listToVS
			  {Map Rhythms.2
			   fun {$ Rhythm}
			      RootPitch#Rhythm#AddedSigns#' ' 
				 % RootPitch#Rhythm#RootMicroPitch 
			   end}
			  " "}
	 end
      end
   end
end
/** %% Expects a note and returns its MicroPitch, ChordMarker and ratio as VS.
%% */
fun {DefaultAddedSigns Note}
   MicroPitch = {Out.lilyMakeMicroPitch
		 {Note getPitchParameter($)}}
   ChordMarker = if {Note isInChord($)} == 1
		 then ''
		 else '^x'
		 end
   Ratio = '\\markup{'#{PC2RatioVS {Note getPitchClass($)}}#'}'
in
   MicroPitch#ChordMarker#'_'#Ratio 
end
proc {RenderLilypondForHS I X}
   fun {MakeChordDescr MyChord}
      %% Transform chord PCs into ratios according to Partch interval DB (Transposition x untransposed PC)
      {PC2RatioVS {MyChord getTransposition($)}}
      #' x ('
      #'\\column < '
      #{Out.listToVS {Map {FS.reflect.lowerBoundList
			   {MyChord getUntransposedPitchClasses($)}}
		      PC2RatioVS}
	' '}
      #') >' 
   end
in
   if {Score.isScoreObject X}
   then 
      FileName = out#{GUtils.getCounterAndIncr}
   in
      %% !! on Mac with new Lily, pdf is shown automatically after rendering
      {Out.renderAndShowLilypond X
	% {Out.renderLilypond X  
       unit(file: FileName#'-'#I
	    clauses:[HS.score.isChord#{MakeChordToLily
				       fun {$ MyChord}	    
					  RootMicroPitch = {Out.lilyMakeMicroPitch {MyChord getRootParameter($)}}
					  ChordDescr = {MakeChordDescr MyChord}
				       in
					  if {Not {IsVirtualString ChordDescr}}
					  then raise noVS(chordDesc:ChordDescr) end
					  end
					  RootMicroPitch#'_\\markup{'#ChordDescr#' }'
				       end}
		     %% marking non-chord pitch notes
		     isNote#{Out.makeNoteToLily DefaultAddedSigns}
		    ])}
   end
end
{Explorer.object
 add(information RenderLilypondForHS
     label: 'to Lilypond (HS: show ratios)')}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Create additional Explorer action which shows analytical
%% information: information on the intervals between chord roots.
%%
%% NB: the chord comment output requires that the interval between
%% roots is determined (i.e. the chord roots are determined)
%%

proc {ShowRootIntervalsInfo I MyScore}
   ChordSeq = {MyScore findItem($ fun {$ X} {X hasThisInfo($ chordSeq)} end)}
   Chords = {ChordSeq getItems($)}
   ChordRoots = {Map Chords fun {$ X} {X getRoot($)} end}
in
   {Browse 
    I#{Pattern.map2Neighbours ChordRoots
       fun {$ Root1 Root2}
	  PartchInterval = {MakePartchInterval}
	  IntervalComment
       in
	  {HS.score.transposePC Root1 PartchInterval.value Root2}
	  thread
	     %% in extra thread because it requires determined PartchInterval
	     IntervalComment
	       = {HS.db.getInternalIntervalDB}.comment.(PartchInterval.index)
	  end
	  %% return interval description
	  interval(spec:PartchInterval
		   comment:IntervalComment)
       end}}
end
{Explorer.object
    add(information ShowRootIntervalsInfo
	label: "show info about intervals between chord roots")}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% call solver
%%

/*

%% output to Lilypond and to csound (MIDI output not suitable without customisation)

%% NB: Use the explorer output action 'to Lilypond (HS: show ratios)' (defined above). 
%% This Lilypond output displays the voices in the four upper staffs and the chords themselfes in the lowest staff.
%% For each voice note, its pitch is notated in two ways. (i) In common music notation with additional + or - signs to indicate the raising or flattening of the note by a 1/12th note (the smalles interval in 72 EDO). (ii) as a ratio (if the notes pitch is a pitch in Partch's 43-note scale, otherwise n/a).
%% For each chord, (i) the root is displayed in common music notation with additional + or - signs, and (ii) ratios of the chord are shown as a list of  untransposed (!!) ratios and the transposition given extra as factor.
%% The resulting Lilypond score may be rather dense, but that can be tweated with Lilypond means (see Lily docs..). 
%% If you wish a different Lilypond output feel free to edit RenderLilypondForHS given above ;-)

%% call script
{SDistro.exploreOne {MakeScript unit}
 Aux.myDistribution}


{SDistro.exploreOne {MakeScript unit(chordNo:10
				     dur:4       
				     maxRootPrimeLimit:5
				     maxRootIntervalDissDegree:2
				     minRootPositions:6
				     maxMelodicSkipsPerVoice:2)}
 Aux.myDistribution}


*/

%%
%% output settings used below
%%

% OutDir = {OS.getCWD}#"/Output/"
%% tmp
OutDir = "/Users/t/oz/music/Strasheela/private/examples/Standard-Examples-Output/05-MicrotonalChordProgression/"
%%
%% 5-limit 
{Init.setTempo 90.0}

%% 7-limit 
% {Init.setTempo 83.0}

%% 11-limit 
% {Init.setTempo 75.0}

/*

%%
%% limit-5 (uncomment suitable tempo setting above)
%%

%% !! above, set VoiceNo=3 before feeding CSP
declare
File = "05-MicrotonalChordProgression-ex1"
MySolution = {SDistro.searchOne {MakeScript unit(chordNo:6
						 dur:4       
						 maxRootPrimeLimit:3
						 maxRootIntervalDissDegree:1
						 minRootPositions:6
						 maxMelodicSkipsPerVoice:0)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic_ShowRatios MySolution OutDir File}
{Aux.toSound MySolution OutDir File}


%% !! above, set VoiceNo=3 before feeding CSP
declare
File = "05-MicrotonalChordProgression-ex2"
MySolution = {SDistro.searchOne {MakeScript unit(chordNo:10
						 dur:4       
						 maxRootPrimeLimit:3
						 maxRootIntervalDissDegree:2
						 minRootPositions:8
						 maxMelodicSkipsPerVoice:1)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic_ShowRatios MySolution OutDir File}
{Aux.toSound MySolution OutDir File}



%% !! above, set VoiceNo=3 before feeding CSP
declare
File = "05-MicrotonalChordProgression-ex3"
MySolution = {SDistro.searchOne {MakeScript unit(chordNo:10
						 dur:4       
						 maxRootPrimeLimit:5
						 maxRootIntervalDissDegree:2
						 minRootPositions:8
						 maxMelodicSkipsPerVoice:1)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic_ShowRatios MySolution OutDir File}
{Aux.toSound MySolution OutDir File}




%% !! above, set VoiceNo=3 before feeding CSP
declare
File = "05-MicrotonalChordProgression-ex4"
MySolution = {SDistro.searchOne {MakeScript unit(chordNo:10
						 dur:4       
						 maxRootPrimeLimit:5
						 maxRootIntervalDissDegree:4
						 minRootPositions:7
						 maxMelodicSkipsPerVoice:1)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic_ShowRatios MySolution OutDir File}
{Aux.toSound MySolution OutDir File}


%%
%% limit-7 (uncomment suitable tempo setting above)
%%

%% !! above, set VoiceNo=4 before feeding CSP
declare
File = "05-MicrotonalChordProgression-ex5"
%% solver call
MySolution = {SDistro.searchOne {MakeScript unit(chordNo:6
						 dur:4       
						 maxRootPrimeLimit:3
						 maxRootIntervalDissDegree:6
						 minRootPositions:6
						 maxMelodicSkipsPerVoice:1)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic_ShowRatios MySolution OutDir File}
{Aux.toSound MySolution OutDir File}


%% !! above, set VoiceNo=4 before feeding CSP
declare
File = "05-MicrotonalChordProgression-ex6"
%% solver call
MySolution = {SDistro.searchOne {MakeScript unit(chordNo:10
						 dur:4       
						 maxRootPrimeLimit:5
						 maxRootIntervalDissDegree:4
						 minRootPositions:8
						 maxMelodicSkipsPerVoice:1)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic_ShowRatios MySolution OutDir File}
{Aux.toSound MySolution OutDir File}


%% !! above, set VoiceNo=4 before feeding CSP
declare
File = "05-MicrotonalChordProgression-ex7"
%% solver call
MySolution = {SDistro.searchOne {MakeScript unit(chordNo:10
						 dur:4       
						 maxRootPrimeLimit:5
						 % maxRootIntervalDissDegree:8
						 maxRootIntervalDissDegree:6
						 minRootPositions:8
						 maxMelodicSkipsPerVoice:2)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic_ShowRatios MySolution OutDir File}
{Aux.toSound MySolution OutDir File}


%% !! above, set VoiceNo=4 before feeding CSP
declare
File = "05-MicrotonalChordProgression-ex8"
%% solver call
MySolution = {SDistro.searchOne {MakeScript unit(chordNo:10
						 dur:4       
						 maxRootPrimeLimit:7
						 % maxRootIntervalDissDegree:8
						 maxRootIntervalDissDegree:6
						 minRootPositions:8
						 maxMelodicSkipsPerVoice:2)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic_ShowRatios MySolution OutDir File}
{Aux.toSound MySolution OutDir File}



%%
%% limit-11 (uncomment suitable tempo setting above)
%%

%% !! above, set VoiceNo=6 before feeding CSP
declare
File = "05-MicrotonalChordProgression-ex9"
%% solver call
MySolution = {SDistro.searchOne {MakeScript unit(chordNo:12
						 dur:4       
						 maxRootPrimeLimit:5
						 maxRootIntervalDissDegree:4
						 minRootPositions:12
						 maxMelodicSkipsPerVoice:1)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic_ShowRatios MySolution OutDir File}
{Aux.toSound MySolution OutDir File}


%% !! above, set VoiceNo=6 before feeding CSP
declare
File = "05-MicrotonalChordProgression-ex10"
%% solver call
MySolution = {SDistro.searchOne {MakeScript unit(chordNo:12
						 dur:4       
						 maxRootPrimeLimit:11
						 maxRootIntervalDissDegree:6
						 minRootPositions:12
						 maxMelodicSkipsPerVoice:1)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic_ShowRatios MySolution OutDir File}
{Aux.toSound MySolution OutDir File}


%%
%% limit-11 with limit-7 chord database 
%%

%% !! above, set VoiceNo=4 and chord database to limit-7 before feeding CSP
declare
File = "05-MicrotonalChordProgression-ex11"
%% solver call
MySolution = {SDistro.searchOne {MakeScript unit(chordNo:14
						 dur:4       
						 maxRootPrimeLimit:11
						 maxRootIntervalDissDegree:8
						 minRootPositions:11
						 maxMelodicSkipsPerVoice:1)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic_ShowRatios MySolution OutDir File}
{Aux.toSound MySolution OutDir File}

*/


/*

%% !! above, set VoiceNo=3 before feeding CSP
declare
File = "05-MicrotonalChordProgression-tmp2"
MySolution = {SDistro.searchOne {MakeScript unit(chordNo:6
						 dur:4       
						 maxRootPrimeLimit:3
						 maxRootIntervalDissDegree:1
						 minRootPositions:6
						 maxMelodicSkipsPerVoice:0)}
	      Aux.myDistribution}.1
%% output
{Aux.toSheetMusic_ShowRatios MySolution OutDir File}
{Aux.toSound MySolution OutDir File}

*/
