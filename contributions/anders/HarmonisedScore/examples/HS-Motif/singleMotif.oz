
%% To link the functor with auxiliary definition of this file: within OPI (i.e. emacs) start Oz from within this buffer (e.g. by C-. r). This sets the current working directory to the directory of the buffer.  
declare
[Aux] = {ModuleLink [{OS.getCWD}#'/AuxDefs.ozf']}


%%
%% TODO
%%
%% * Constrain melodic interval size: within motif? or interval between min and max pitch of motif?
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% single motif over harmonised score
%% 

{SDistro.exploreOne
 proc {$ MyScore}
    %% Two motifs which effectively differ in length (4 and 3 notes). However, each motif instance in score consists of 4 notes and the duration of the 'unwanted' notes is set to 0.
    %% NB: this motif DB includes an undetermined variable: because the last note of the second motif is effectively non-existant (its duration is 0), the last contour of this motif is undetermined (the pitch of the last note is implicitly determined by CTT.avoidSymmetries).
    MaxMotifNoteNr = 4		% all motifs contain this number of notes
    MyDB = {New Motif.database
	    init(motifDB:[motif(pitchContour:[1 1 0]
				durations:[2 2 2 4] % length: MaxMotifNoteNr
				comment:beethovensFifth)
			  motif(pitchContour:[2 0 {FD.int 0#2}]
				durations:[4 4 8 0]
				comment:test)]
		 motifConstraintDB:[Aux.durationsAndContourMotifConstraint])}
    Dur				% common dur of motif and chord
 in
    MyScore = {Score.makeScore
	       sim(items:[motif(items:{LUtils.collectN MaxMotifNoteNr
				       fun {$} note end}
				database:MyDB
				duration:Dur)
			  chord(duration:Dur)]
		   startTime:0
		   timeUnit:beats(4))
	       Aux.myCreators}
    %% motifs are of different effectiv length, thus
    {CTT.avoidSymmetries MyScore}
 end
 Aux.myDistribution}


