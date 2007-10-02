
%% To link the functor with auxiliary definition of this file: within OPI (i.e. emacs) start Oz from within this buffer (e.g. by C-. r). This sets the current working directory to the directory of the buffer.  
declare
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs.ozf']}




%%
%% TODO
%%
%% * Constrain motif sequence: I need to force some form: I need to split up the melody into phrases and to do a cadence (at least at the end..)  
%%   shall I intro something like Copes SPEAC?
%%
%% * Constrain melodic interval size: within motif? or interval between min and max pitch of motif?
%%
%% * Constrain interval between maxes of neighbouring pitches
%%
%% -> I don't want to extend the music representation to store these motif max pitches, but I also don't want to call the Pattern.max propagator multiple times: define rule which expect max variable as arg and combine these rules in some rule which 'accesses' max (a context undetermined in CSP def)
%%  -> selbst wenn ich spaeter die music representation entsprechend erweitere: wenn in die Regeldef. davon unabhaengig mache, werden diese Regeln wiederverwendbar
%%
%% -> Copy this idea as refactoring idea into Josquin example



%%
%% This example shall later lead to inventio composition..
%%

%%
%% * Simple harmonic progression: either determined in CSP def or simple rule set.
%%   Harmony rule set in case harmony is not determined in CSP
%%
%%   - Simple Schoenbergian rules (C major, diatonic chords, only chords with harmonic band, seventh chords always resolve by fourth skip upwards of root) 
%%
%%   - Simple (i.e. regular) harmonic rhythm (e.g. in 4/4 a chord each two beats) [this is rather simplifying]
%%
%%     ?? + shall I allow chord repetitions to allow for longer chords and still determine chord durations in CSP
%%
%%   ?? - Do I need explicit rules to control formal aspect of harmonic progression (e.g. end in cadence and possibly do simple cadence in the beginning) 
%%
%%
%% OK * All melody notes are diatonic (?? for extension to support later minor: at least all non-harmonic notes are diatonic OR Schoenbergian rules on resolution of raised pitches?)
%%
%% OK * Non-harmonic melody notes: only simple cases allowed (passing note, auxiliary), but multiple non-harmonic notes may occur in a sequence (only multiple passing notes?). First and last pitch of a phrase must be harmonic melody note.
%%
%% * Motifs: short, simple [unauffaelliges] but clear motifs in DB (cp. Vivaldi example in Piston Counterpoint p. 105) -- only very few and related motifs (2-3)
%%
%% OK * Motif database entries define:
%%
%%   - note number (e.g. max 4)
%%
%%   - note durations (e.g. either all note durs determined OR duration of full motif determined (??) -- for simplicity each motif has same full duration (e.g. beat))
%%
%%   - pitch contour
%%
%%   - [small] motif [ambitus] (depends on contour, e.g. third or fifth)
%%
%% OK * A few distinct motif constraint database entries affecting application of pitch contour: original, inversion, rectograde
%%
%%
%% * Rules on motif sequence:
%%
%%  OK? - interval between pitch maxima of neighbouring pitches
%%     (?? call rule in motif constraint to avoid multiple propagators for max motif pitch)
%%
%%   - ?? Clear formal sectioning by longer notes at the end of phrases, i.e. after a few other motifs (e.g. define specific motif DB entries with longer notes and allow these motifs only at phrase endings, alternatively/optionally followed by a pause (??))
%%
%%   - ?? motif sequence constrained by any patterns (or higher-level 'motifs')?
%%
%%   !! - motifs in DB marked and rule constraints sequence of markings (e.g. with Cope's [SPEAC ?], i.e. with Pattern.markowChain)
%%
%%
%% * Rules on melody
%%
%%   ?? - only single occurence of max pitch
%%
%%   ?? - no pitch repetition
%%
%%   
%%
%%
%%
%%
%%
%%
%%
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% motif sequence over harmonised score with single predetermined chord
%% 

%% orientieren an Vivaldi B. aus Piston Counterpoint p. 105

declare
%%
%% rules
%%
proc {IsPassingNoteR Note B}
   {HS.rules.isPassingNoteR Note unit B}
end
proc {IsAuxiliaryR Note B}
   {HS.rules.isAuxiliaryR Note unit B}
end
%% first and last note of Voice are chord notes
proc {StartAndEndWithChordNote Voice}
   Notes = {Voice collect($ test:isNote)}
in
   {Notes.1 isInChord($)} = 1
   {{List.last Notes} isInChord($)} = 1
end
%% ??!! much too strict rule? large skips perfectly fine -- except between maxima..
proc {NeigbouringMotifPitchMaxInterval Motif1 Motif2}
   %% !! Pattern.max called twice (here and in motif constraint for motif pitch range)
   Interval = {FD.int 1#4}	% no repetition and max major 3rd
in
   {FD.distance 
    {Pattern.max {Motif1 mapItems($ getPitch)}}
    {Pattern.max {Motif2 mapItems($ getPitch)}}
    '=:'
    Interval}
end
%%
%% motif constraints
%%
local
   %% DB is a tuple of records. CollectFeats returns the values of all records in DB at feature Feat in a list.
   %%
   %% !! copy from Aux
   fun {CollectFeats DB Feat}
      {Map DB fun {$ X} X.Feat end}
   end
in
   %% !! slightly edited copy from Aux
   %%
   %% ProcessContour is a binary procedure: the first arg is the contour DB entry and the second arg is the contour applied to the motif instance.
   fun {MakeMotifConstraint ProcessContour}
      proc {$ MyMotif B}
	 {Combinator.'reify'
	  proc {$}
	     MotifDB = {MyMotif getMotifDB($)}
	     MotifIndex = {MyMotif getMotifIndex($)}
	     %%
	     DurDB = {CollectFeats MotifDB durations}
	     ContourDB = {CollectFeats MotifDB pitchContour}
	     MaxRangeDB = {CollectFeats MotifDB maxRange}
	     %%
	     MyDurs = {MyMotif mapItems($ getDuration)} 
	     MyPitches = {MyMotif mapItems($ getPitch)}
	     ContourDBInstance = {FD.list {Length MyPitches}-1 0#2}
	     MyContour = {FD.list {Length MyPitches}-1 0#2}
	     MyMaxRange = {FD.decl}
	  in
	     MyDurs = {Pattern.selectList DurDB MotifIndex}
	     ContourDBInstance = {Pattern.selectList ContourDB MotifIndex}
	     MyContour = {ProcessContour ContourDBInstance}
	     MyMaxRange = {Select.fd MaxRangeDB MotifIndex}
	     {Pattern.contour MyPitches MyContour}
	     MyMaxRange = {FD.distance {Pattern.max MyPitches} {Pattern.min MyPitches}
			   '=<:'}
	  end
	  B}
      end
   end
   Original = {MakeMotifConstraint proc {$ Xs Ys} Xs=Ys end}
   Inversion = {MakeMotifConstraint 
		proc {$ Xs Ys} {Pattern.inverseContour Xs Ys} end}
   Rectograde = {MakeMotifConstraint 
		 proc {$ Xs Ys} Ys = {Reverse Xs} end}
%    %% !! slightly edited copy from Aux
%    proc {OrigMotifConstraint MyMotif B}
%       {Combinator.'reify'
%        proc {$}
% 	  MotifDB = {MyMotif getMotifDB($)}
% 	  MotifIndex = {MyMotif getMotifIndex($)}
% 	  %%
% 	  DurDB = {CollectFeats MotifDB durations}
% 	  ContourDB = {CollectFeats MotifDB pitchContour}
% 	  MaxRangeDB = {CollectFeats MotifDB maxRange}
% 	  %%
% 	  MyDurs = {MyMotif mapItems($ getDuration)} 
% 	  MyPitches = {MyMotif mapItems($ getPitch)}
% 	  MyContour = {FD.list {Length MyPitches}-1 0#2}
% 	  MyMaxRange = {FD.decl}
%        in
% 	  MyDurs = {Pattern.selectList DurDB MotifIndex}
% 	  MyContour = {Pattern.selectList ContourDB MotifIndex}
% 	  MyMaxRange = {Select.fd MaxRangeDB MotifIndex}
% 	  {Pattern.contour MyPitches MyContour}
% 	  MyMaxRange = {FD.distance {Pattern.max MyPitches} {Pattern.min MyPitches}
% 			'=<:'}
%        end
%        B}
%    end
end
%%
%% script and solver
%%
{SDistro.exploreOne
 proc {$ MyScore}
    %% Two motifs which effectively differ in length (4 and 3 notes). However, each motif instance in score consists of 4 notes and the duration of the 'unwanted' notes is set to 0.
    %% NB: this motif DB includes an undetermined variable: because the last note of the second motif is effectively non-existant (its duration is 0), the last contour of this motif is undetermined (the pitch of the last note is implicitly determined by CTT.avoidSymmetries).
    MaxMotifNoteNr = 4		% all motifs contain this number of notes
    MotifNr = 4 % 8
    MyDB = {New Motif.database
	    %%
	    %% instead of several motifConstraintDBs, defining multiple motifDB entries would be more simple..
	    %%
	    init(motifDB:[motif(% motifDuration:[]
				durations:[1 1 1 1]
				pitchContour:[2 2 0]
				maxRange:5 % ?? 4
				comment:'a (orig)')
			  motif(% motifDuration:[]
				durations:[1 1 1 1]
				pitchContour:[0 0 2]
				maxRange:5
				comment:'a (inversion)')
			  motif(% motifDuration:[]
				durations:[1 1 1 1]
				pitchContour:[0 2 2]
				maxRange:5
				comment:'a (rectrograde)')
			  %%
			  motif(% motifDuration:[]
				durations:[1 1 1 1]
				pitchContour:[2 2 2]
				maxRange:7 % ??  5
				comment:'b (orig)')
			  motif(% motifDuration:[]
				durations:[1 1 1 1]
				pitchContour:[0 0 0]
				maxRange:7 % ??  5
				comment:'b (rectograde)')
			  %%
			  motif(% motifDuration:[]
				durations:[2 2 0 0]
				pitchContour:[0 {FD.int 0#2} {FD.int 0#2}]
				maxRange:12
				comment:'c')
			  %%
			  motif(% motifDuration:[]
				durations:[1 1 2 0]
				pitchContour:[0 0 {FD.int 0#2}]
				maxRange:7
				comment:'d')
			 ]
		 % motifConstraintDB:[Original Inversion Rectograde]
		 motifConstraintDB:[Original]
		)}
    Dur				% common dur of motif and chordseq
    Voice = {Score.makeScore2
	       seq(info:voice
		   items:{LUtils.collectN MotifNr
			  fun {$}
			     motif(items:{LUtils.collectN MaxMotifNoteNr
					  fun {$}
					     diatonicNote(offsetTime:0
							  inChordB:{FD.int 0#1})
					  end}
				   database:MyDB)
			  end}
		   duration:Dur)
	       Aux.myCreators}
    %%
    %% determine harmonic progression: I V V I (default chord DB)
    %% (!! tmp rule)
    ChordSeq = {Score.makeScore2
		  seq(info:chordSeq
		      %% !!?? diatonicChord
		      items:[chord(index:1 transposition:0) 
			     chord(index:1 transposition:7)
			     chord(index:1 transposition:7)
			     chord(index:1 transposition:0)]
		      duration:Dur)
		  Aux.myCreators}
 in
    MyScore = {Score.makeScore
	       sim(items:[Voice
			  ChordSeq
			  %% determined scale: C major (default chord DB)
			  scale(duration:Dur index:1 transposition:0)]
		   startTime:0
		   timeUnit:beats(4))
	       Aux.myCreators}
    %% restrict non-harmonic pitches
    {Voice 
     forAll(test:isNote
	    proc {$ MyNote}
	       {MyNote nonChordPCConditions([IsPassingNoteR
					     IsAuxiliaryR])}
	    end)}
    {StartAndEndWithChordNote Voice}
    {Pattern.for2Neighbours {Voice getItems($)} NeigbouringMotifPitchMaxInterval}
    %% all chords of equal length (i.e. Dur dividable by 4)
    %% (!! tmp rule)
    {Pattern.allEqual {ChordSeq mapItems($ getDuration)}}
    %% no pitch repetition
    {Pattern.for2Neighbours {Voice map($ getPitch test:isNote)}
     proc {$ Pitch1 Pitch2} Pitch1 \=: Pitch2 end}
    %% motifs are of different effectiv length, thus
    {CTT.avoidSymmetries MyScore}
 end
 Aux.myDistribution}











%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% older Test with 'Beethoven fifth' motif: motif sequence over harmonised score with single predetermined chord
%% 

{SDistro.exploreOne
 proc {$ MyScore}
    %% Two motifs which effectively differ in length (4 and 3 notes). However, each motif instance in score consists of 4 notes and the duration of the 'unwanted' notes is set to 0.
    %% NB: this motif DB includes an undetermined variable: because the last note of the second motif is effectively non-existant (its duration is 0), the last contour of this motif is undetermined (the pitch of the last note is implicitly determined by CTT.avoidSymmetries).
    MaxMotifNoteNr = 4		% all motifs contain this number of notes
    MotifNr = 4
    MyDB = {New Motif.database
	    init(motifDB:[%% motif starts with pause (offset times)
			  motif(pitchContour:[1 1 0]
				durations:[2 2 2 4] % length: MaxMotifNoteNr
				offsets:[2 0 0 0]
				comment:beethovensFifth)
			  %% !!?? Buglet: motif boundaries nicht ganz sauber fuer effective kuerzeres Motif
			  motif(pitchContour:[2 0 {FD.int 0#2}]
				durations:[4 4 8 0]
				offsets:[0 0 0 0]
				comment:test)]
		 motifConstraintDB:[Aux.durationsAndContourMotifConstraint2])}
    Dur				% common dur of motif and chord
 in
    MyScore = {Score.makeScore
	       sim(items:[seq(items:{LUtils.collectN MotifNr
				     fun {$}
					motif(items:{LUtils.collectN MaxMotifNoteNr
						     fun {$}
							%% offsetTime defaults to 0, but here we need kinded var
							note(offsetTime:{FD.decl})
						     end}
					      database:MyDB)
				     end}
			      duration:Dur)
			  %% single predetermined chord (default chord DB: C major)
			  chord(duration:Dur index:1 transposition:0)]
		   startTime:0
		   timeUnit:beats(4))
	       Aux.myCreators}
    %% motifs are of different effectiv length, thus
    {CTT.avoidSymmetries MyScore}
 end
 Aux.myDistribution}


