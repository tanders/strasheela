
%%
%% TODO
%%
%% * example which demonstrates other musical viewpoints constrained by MotifDescriptionDB and MotifVariationDB. For exampple, the pitch sequence, pitch interval sequence, duration 'intervals' etc.   
%%
%% * polyphonic motif definition..
%%
%% * ?? nested motif definition 
%%
%% * example which uses multiple motifs in context of a musical fragment (possibly together with harmonic constraints..)
%%


/*
declare 
[Motif CTT] = {ModuleLink ['x-ozlib://anders/strasheela/Motif/Motif.ozf'
			   'x-ozlib://anders/strasheela/ConstrainTimingTree.ozf']}
*/



declare
%% Aux defs 
%%
MyConstructors = unit(seq:Score.sequential
		      motif:Motif.sequential
		      note:Score.note)
%% constraint distribution / search order: first determine parameters motifIdentity and motifVariation. These parameters in turn determine the rhythmic structure which therefore does not need specific consideration in the distribution order.
MyDistribution = unit(order:local
			       fun {IsPreferredParam X}
				  {X hasThisInfo($ motifIdentity)} orelse
				  {X hasThisInfo($ motifVariation)}
			       end
			       fun {GetDomSize X}
				  {FD.reflect.size {X getValue($)}}
			       end
			    in
			       fun {$ X Y}
				  %% search strategy: decide for variables with
				  %% smalles domain first, but prefer certain
				  %% params. NB: timing parameters must be
				  %% predetermined for this distribution strategy to
				  %% work efficiently.
				  if {IsPreferredParam X} then
				     true
				  elseif {IsPreferredParam Y} then
				     false
				  else {GetDomSize X} < {GetDomSize Y}
				  end
			       end
			    end
		      value:random)
%%
%% test databases
%% 
MaxMotifNoteNr = 4		% depends on length of lists in MotifDescriptionDB 
MotifDescriptionDB = [motif(pitchContour:[1 1 0] durs:[2 2 2 4])
		      motif(pitchContour:[1 1 0] durs:[4 2 2 8])]
MotifVariationDB = [
		    %% orig
		    {Motif.makeVariation 
		     var(pitchContour:
			    proc {$ MyMotif MyContour}
			       MyPitches = {MyMotif mapItems($ getPitch)}
			    in
			       MyContour = {FD.list {Length MyPitches}-1 0#2}
			       {Pattern.contour MyPitches MyContour}
			    end
			 durs:
			    fun {$ MyMotif} {MyMotif mapItems($ getDuration)} end)} 
		    %% Inverse pitch contour 
		    {Motif.makeVariation 
		     var(pitchContour:
			    proc {$ MyMotif MyContour}
			       MyPitches = {MyMotif mapItems($ getPitch)}
			       MyInverseContour = {FD.list {Length MyPitches}-1 0#2}
			    in
			       MyContour = {FD.list {Length MyPitches}-1 0#2}
			       {Pattern.contour MyPitches MyInverseContour}
			       {Pattern.inverseContour MyInverseContour MyContour} 
			    end
			 durs:
			    fun {$ MyMotif} {MyMotif mapItems($ getDuration)} end)}
		   ]

/* 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% examples
%% 

%% A single motif description and two variations. Highly restricted pitch domain and thus only two possible solutions (either this or that motif variation).
{SDistro.exploreAll
 proc {$ MyScore}
    MyDB = {New Motif.database init(motifDescriptionDB:[MotifDescriptionDB.1]
				    motifVariationDB:MotifVariationDB)}
 in
    MyScore = {Score.makeScore
	       motif(items:{LUtils.collectN MaxMotifNoteNr
			    fun {$}
			       note(duration:{FD.int 0#16}
				    pitch:{FD.int [60 62]}
				    amplitude:64)
			    end}
		     database:MyDB
		     startTime:0
		     timeUnit:beats(4))
	       MyConstructors}
 end
 MyDistribution}


%% Two motif descriptions and a single variation. Highly restricted pitch domain and thus only two possible solutions (either this or that motif identity).
{SDistro.exploreAll
 proc {$ MyScore}
    MyDB = {New Motif.database init(motifDescriptionDB:MotifDescriptionDB
				    motifVariationDB:[MotifVariationDB.1])}
 in
    MyScore = {Score.makeScore
	       motif(items:{LUtils.collectN MaxMotifNoteNr
			    fun {$}
			       note(duration:{FD.int 0#16}
				    pitch:{FD.int [60 62]}
				    amplitude:64)
			    end}
		     database:MyDB
		     startTime:0
		     timeUnit:beats(4))
	       MyConstructors}
 end
 MyDistribution}


%% Two motif descriptions and two variations. Highly restricted pitch domain and thus only four possible solutions.
{SDistro.exploreAll
 proc {$ MyScore}
    MyDB = {New Motif.database init(motifDescriptionDB:MotifDescriptionDB
				    motifVariationDB:MotifVariationDB)}
 in
    MyScore = {Score.makeScore
	       motif(items:{LUtils.collectN MaxMotifNoteNr
			    fun {$}
			       note(duration:{FD.int 0#16}
				    pitch:{FD.int [60 62]}
				    amplitude:64)
			    end}
		     database:MyDB
		     startTime:0
		     timeUnit:beats(4))
	       MyConstructors}
 end
 MyDistribution}



%%
%% Example to demonstrate how to model motifs of different effective length 
%%
%% All motifs (in motif database and score motif instances) have the same actual length. In the example, each motif contains MaxMotifNoteNr = 4 notes. However, in the database as well as in the score shorter motifs are represented: all notes with the duration = 0 are considered non-existent.
%%
%% Constraining the length of the motif as well (using CTT). There are only two solutions, where each solution consists of a different number of notes. (Only a single variation for simplicity.)
%%
{SDistro.exploreAll
 proc {$ MyScore}
    MaxMotifNoteNr = 4		% depends on length of lists in MotifDescriptionDB    
    %% Two motifs which effectively differ in length (4 and 3 notes). However, each motif instance in score consists of 4 notes and the duration of the 'unwanted' notes is set to 0.
    %% NB: this motif DB includes effectively an undetermined variable: because the last note of the second motif is effectively non-existant (its duration is 0), the last contour of this motif is undetermined (the pitch of the last note is implicitly determined by CTT.avoidSymmetries).
    MotifDescriptionDB
    = [motif(pitchContour:[2 0 1] % NB: last contour value ignored because of 0 in durs
	     durs:[4 4 8 0] comment:motif1)
       motif(pitchContour:[1 1 0]
	     durs:[2 2 2 4] comment:motif2)]
    MotifVariationDB 
    = [{Motif.makeVariation 
	var(pitchContour:proc {$ MyMotif MyContour}
			    MyPitches = {MyMotif mapItems($ getPitch)}
			 in
			    MyContour = {FD.list {Length MyPitches}-1 0#2}
			    {Pattern.contour MyPitches MyContour}
			 end
	    durs:fun {$ MyMotif} {MyMotif mapItems($ getDuration)} end)}]
    MyDB = {New Motif.database init(motifDescriptionDB:MotifDescriptionDB
				    motifVariationDB:MotifVariationDB)}
 in
    MyScore = {Score.makeScore
	       motif(items:{LUtils.collectN MaxMotifNoteNr
			    fun {$}
			       note(duration:{FD.int 0#16}
				    pitch:{FD.int [60 62]}
				    amplitude:64)
			    end}
		     database:MyDB
		     startTime:0
		     timeUnit:beats(4))
	       MyConstructors}
    {CTT.avoidSymmetries MyScore}
 end
 MyDistribution}



%%
%% MotifDescriptionDB contains variables: the motif identity is not fixed. There are two solutions (either motif is falling or raising).
%% (only a single motif description and variation for simplicity)
%%
{SDistro.exploreAll
 proc {$ MyScore}
    MaxMotifNoteNr = 4		% depends on length of lists in MotifDescriptionDB 
    MotifDescriptionDB
    = [motif(pitchContour:[1 1 {FD.int [0 2]}] durs:[2 2 2 4])]
    MotifVariationDB 
    = [{Motif.makeVariation 
	var(pitchContour:proc {$ MyMotif MyContour}
			    MyPitches = {MyMotif mapItems($ getPitch)}
			 in
			    MyContour = {FD.list {Length MyPitches}-1 0#2}
			    {Pattern.contour MyPitches MyContour}
			 end
	    durs:fun {$ MyMotif} {MyMotif mapItems($ getDuration)} end)}]
    MyDB = {New Motif.database init(motifDescriptionDB:MotifDescriptionDB
				    motifVariationDB:MotifVariationDB)}
 in
    MyScore = {Score.makeScore
	       motif(items:{LUtils.collectN MaxMotifNoteNr
			    fun {$}
			       note(duration:{FD.int 0#16}
				    pitch:{FD.int [60 62]}
				    amplitude:64)
			    end}
		     database:MyDB
		     startTime:0
		     timeUnit:beats(4))
	       MyConstructors}
 end
 MyDistribution}


%%
%% Both motif entries in MotifDescriptionDB state durations, but only
%% one entry states also pitch contour.
%%
{SDistro.exploreAll
 proc {$ MyScore}
        MaxMotifNoteNr = 4 % depends on length of lists in MotifDescriptionDB    
    MotifDescriptionDB
    = [
       motif(pitchContour:[1 1 0]
	     durs:[2 2 2 4] comment:a)
       %% no pitchContour specification
       motif(durs:[8 4 4 8] comment:b)
      ]
    MotifVariationDB 
    = [{Motif.makeVariation 
	var(pitchContour:proc {$ MyMotif MyContour}
			    MyPitches = {MyMotif mapItems($ getPitch)}
			 in
			    MyContour = {FD.list {Length MyPitches}-1 0#2}
			    {Pattern.contour MyPitches MyContour}
			 end
	    durs:fun {$ MyMotif} {MyMotif mapItems($ getDuration)} end)}]
    MyDB = {New Motif.database init(motifDescriptionDB:MotifDescriptionDB
				    motifVariationDB:MotifVariationDB)}
 in
    MyScore = {Score.makeScore
	       motif(items:{LUtils.collectN MaxMotifNoteNr
			    fun {$}
			       note(duration:{FD.int 0#16}
				    pitch:{FD.int [60 62]}
				    amplitude:64)
			    end}
		     database:MyDB
		     startTime:0
		     timeUnit:beats(4))
	       MyConstructors}
 end
 MyDistribution}

%%
%% Both variation entries in MotifVariationDB constrain durations, but only
%% one entry constrains also pitch contour.
%%
{SDistro.exploreAll
 proc {$ MyScore}
        MaxMotifNoteNr = 4 % depends on length of lists in MotifDescriptionDB    
    MotifDescriptionDB
    = [motif(pitchContour:[1 1 0]
	     durs:[2 2 2 4] comment:a)]
    MotifVariationDB 
    = [{Motif.makeVariation 
	var(pitchContour:proc {$ MyMotif MyContour}
			    MyPitches = {MyMotif mapItems($ getPitch)}
			 in
			    MyContour = {FD.list {Length MyPitches}-1 0#2}
			    {Pattern.contour MyPitches MyContour}
			 end
	    durs:fun {$ MyMotif} {MyMotif mapItems($ getDuration)} end)}
       %% reversed durations, no pitch contour constraints at all
       {Motif.makeVariation 
	var(durs:fun {$ MyMotif} {Reverse {MyMotif mapItems($ getDuration)}} end)}]
    MyDB = {New Motif.database init(motifDescriptionDB:MotifDescriptionDB
				    motifVariationDB:MotifVariationDB)}
 in
    MyScore = {Score.makeScore
	       motif(items:{LUtils.collectN MaxMotifNoteNr
			    fun {$}
			       note(duration:{FD.int 0#16}
				    pitch:{FD.int [60 62]}
				    amplitude:64)
			    end}
		     database:MyDB
		     startTime:0
		     timeUnit:beats(4))
	       MyConstructors}
 end
 MyDistribution}


%%
%% Specific variations are only permitted for specific motif identities.
%%
{SDistro.exploreAll
 proc {$ MyScore}
        MaxMotifNoteNr = 4 % depends on length of lists in MotifDescriptionDB    
    MotifDescriptionDB
    = [motif(pitchContour:[1 1 0] durs:[2 2 2 4] comment:a)
       motif(pitchContour:[1 1 0] durs:[8 4 8 4] comment:b)]
    MotifVariationDB 
    = [{Motif.makeVariation 
	var(pitchContour:proc {$ MyMotif MyContour}
			    MyPitches = {MyMotif mapItems($ getPitch)}
			 in
			    MyContour = {FD.list {Length MyPitches}-1 0#2}
			    {Pattern.contour MyPitches MyContour}
			 end
	    durs:fun {$ MyMotif} {MyMotif mapItems($ getDuration)} end)}
       {Motif.makeVariation 
	var(pitchContour:proc {$ MyMotif MyContour}
			    MyPitches = {MyMotif mapItems($ getPitch)}
			 in
			    MyContour = {FD.list {Length MyPitches}-1 0#2}
			    {Pattern.contour MyPitches MyContour}
			 end	    
	    %% variation reversing duration seq only permitted for
	    %% motif 2 (parameter MotifIdentity can be constrained
	    %% arbitrarily in specific variation..)
	    durs:fun {$ MyMotif}
		    {MyMotif getMotifIdentity($)} = 2
		    {Reverse {MyMotif mapItems($ getDuration)}}
		 end)}]
    MyDB = {New Motif.database init(motifDescriptionDB:MotifDescriptionDB
				    motifVariationDB:MotifVariationDB)}
 in
    MyScore = {Score.makeScore
	       motif(items:{LUtils.collectN MaxMotifNoteNr
			    fun {$}
			       note(duration:{FD.int 0#16}
				    pitch:{FD.int [60 62]}
				    amplitude:64)
			    end}
		     database:MyDB
		     startTime:0
		     timeUnit:beats(4))
	       MyConstructors}
    
 end
 MyDistribution}


%%
%% Combining several of the examples above. The pitch domain is still very small, so there are only few solutions...
%%
%% Please note: the ambiguity introduced by an MotifDescriptionDB entry and specific MotifVariationDB entries can result in multiple instances of the same solution. For example, if a pitch contour of an MotifDescriptionDB entry allows for an inversion of the pitch contour and there is a variation which inverts the contour, then there will be multiple equal solutions. 
%%
{SDistro.exploreOne
 proc {$ MyScore}
    MaxMotifNoteNr = 4		% depends on length of lists in MotifDescriptionDB 
    %% Two motifs which effectively differ in length (4 and 3 notes). However, each motif instance in score consists of 4 notes and the duration of the 'unwanted' notes is set to 0.
    MotifDescriptionDB
    = [
       motif(pitchContour:[2 0 1] % NB: last contour value ignored because of 0 in durs
	     durs:[4 4 8 0] comment:motif1)
       motif(pitchContour:[1 {FD.int [0 2]} 1] durs:[2 2 2 4] comment:motif2)       
      ]
    MotifVariationDB 
    = [
       %% orig
       {Motif.makeVariation 
	var(pitchContour:proc {$ MyMotif MyContour}
			    MyPitches = {MyMotif mapItems($ getPitch)}
			 in
			    MyContour = {FD.list {Length MyPitches}-1 0#2}
			    {Pattern.contour MyPitches MyContour}
			 end
	    durs:fun {$ MyMotif} {MyMotif mapItems($ getDuration)} end)}
       %% reversed pitch contour
       {Motif.makeVariation 
	var(pitchContour:proc {$ MyMotif MyContour}
			    MyPitches = {MyMotif mapItems($ getPitch)}
			 in
			    MyContour = {FD.list {Length MyPitches}-1 0#2}
			    {Pattern.contour MyPitches
			     {Reverse MyContour}}
			 end
	    durs:fun {$ MyMotif} {MyMotif mapItems($ getDuration)} end)}                
       %% Inverse pitch contour 
       {Motif.makeVariation 
	var(pitchContour:proc {$ MyMotif MyContour}
			    MyPitches = {MyMotif mapItems($ getPitch)}
			    MyInverseContour = {FD.list {Length MyPitches}-1 0#2}
			 in
			    MyContour = {FD.list {Length MyPitches}-1 0#2}
			    {Pattern.contour MyPitches MyInverseContour}
			    {Pattern.inverseContour MyInverseContour MyContour} 
			 end
	    durs:fun {$ MyMotif} {MyMotif mapItems($ getDuration)} end)}
       %% stretched duration (buggy)
%        {Motif.makeVariation 
% 	var(pitchContour:proc {$ MyMotif MyContour}
% 			 MyPitches = {MyMotif mapItems($ getPitch)}
% 		      in
% 			 MyContour = {FD.list {Length MyPitches}-1 0#2}
% 			 {Pattern.contour MyPitches MyContour}
% 		      end
% 	 durs:proc {$ MyMotif MyDurs}
% 		 StretchedDurs = {MyMotif mapItems($ getDuration)}
% 	      in
% 		 MyDurs = {FD.list {Length StretchedDurs} 0#16}
% 		 {Pattern.parallelForAll [MyDurs StretchedDurs]
% 		  proc {$ [Dur1 Dur2]} Dur1 * 2 =: Dur2 end}
% 	      end)}
      ]
    MyDB = {New Motif.database init(motifDescriptionDB:MotifDescriptionDB
				    motifVariationDB:MotifVariationDB)}
 in
    MyScore = {Score.makeScore
	       motif(items:{LUtils.collectN MaxMotifNoteNr
			    fun {$}
			       note(duration:{FD.int 0#16}
				    pitch:{FD.int [60 62]}
				    amplitude:64)
			    end}
		     database:MyDB
		     startTime:0
		     timeUnit:beats(4))
	       MyConstructors}
    {CTT.avoidSymmetries MyScore}
 end
 MyDistribution}


%%
%%
%% 

*/







/*

%% full Variation definition - kept for reference to show how things can be done from scratch..

[proc {$ MyMotif B}
    {Combinator.'reify'
     proc {$}
	MotifDescriptionDB = {MyMotif getMotifDescriptionDB($)}
	ContourDB = {CollectFeats MotifDescriptionDB pitchContour}
	DurDB = {CollectFeats MotifDescriptionDB durs}
	MyDurs = {MyMotif mapItems($ getDuration)} 
	MyPitches = {MyMotif mapItems($ getPitch)}
	MyContour = {FD.list {Length MyPitches}-1 0#2}
	MotifIdentity = {MyMotif getMotifIdentity($)}
     in
	MyDurs = {Pattern.selectList DurDB MotifIdentity}
	MyContour = {Pattern.selectList ContourDB MotifIdentity}
	{Pattern.contour MyPitches MyContour}
     end
     B}
 end]

*/
















/* 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% old stuff
%%

declare
%% Two motifs which effectively differ in length (4 and 3 notes). However, each motif instance in score consists of 4 notes and the duration of the 'unwanted' notes is set to 0.
%% NB: this motif DB includes an undetermined variable: because the last note of the second motif is effectively non-existant (its duration is 0), the last contour of this motif is undetermined (the pitch of the last note is implicitly determined by CTT.avoidSymmetries).
MotifDescriptionDB = [motif(pitchContour:[1 1 0] durs:[2 2 2 4] comment:beethovensFifth)
		      motif(pitchContour:[2 0 {FD.int 0#2}] durs:[4 4 8 0] comment:test)
		     ]
MotifVariationDB = [proc {$ MyMotif B}
		       {Combinator.'reify'
			proc {$}
			   MotifDescriptionDB = {MyMotif getMotifDescriptionDB($)}
			   ContourDB = {CollectFeats MotifDescriptionDB pitchContour}
			   DurDB = {CollectFeats MotifDescriptionDB durs}
			   MyDurs = {MyMotif mapItems($ getDuration)} 
			   MyPitches = {MyMotif mapItems($ getPitch)}
			   MyContour = {FD.list {Length MyPitches}-1 0#2}
			   MotifIdentity = {MyMotif getMotifIdentity($)}
			in
			   MyDurs = {Pattern.selectList DurDB MotifIdentity}
			   MyContour = {Pattern.selectList ContourDB MotifIdentity}
			   {Pattern.contour MyPitches MyContour}
			end
			B}
		    end]
MyDB = {New Motif.database init(motifDescriptionDB:MotifDescriptionDB
				motifVariationDB:MotifVariationDB)}
MyScore = {Score.makeScore
	   motif(items:{LUtils.collectN MaxMotifNoteNr MakeMyNote}
		 database:MyDB
		 startTime:0
		 timeUnit:beats(4))
	   MyConstructors}
{CTT.avoidSymmetries MyScore}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% very first simple test: create a single motif
%%

declare
MyMotif = {Score.makeScore motif(items:{LUtils.collectN MaxMotifNoteNr MakeMyNote}
				 startTime:0
				 timeUnit:beats(4))
	   unit(seq:Score.sequential
		motif:Motif.sequential
		note:Score.note)}
{MyMotif forAll(HandleNonexistentNote test:isNote)}

{MyMotif toFullRecord($)}


{MyMotif getMotifIdentity($)} = 1

{MyMotif getMotifIdentity($)} = 2

*/ 
