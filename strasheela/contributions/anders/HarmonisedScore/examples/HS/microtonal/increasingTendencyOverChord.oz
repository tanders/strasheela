

%% To link the functor with auxiliary definition of this file: within OPI (i.e. emacs) start Oz from within this buffer (e.g. by C-. r). This sets the current working directory to the directory of the buffer.  
declare
[Aux] = {ModuleLink [{OS.getCWD}#'/../ExampleAuxDefs.ozf']}


%%
%% define and set microtonal chord DB (alternatively use predef. DB, such as {HS.dbs.arithmeticalSeriesChords.getSelectedChords 72})
%% 
declare
PitchesPerOctave = 72
ChordDB = {Record.map chords(chord(pitchClasses:[4#4 5#4 6#4 7#4]
				   roots:[1#1]
				   comment:'4/4 5/4 6/4 7/4')
			     chord(pitchClasses:[4#4 4#5 4#6 4#7]
				   roots:[1#1]
				   comment:'4/4 4/5 4/6 4/7'))
	   fun {$ X} {HS.db.ratiosInDBEntryToPCs X PitchesPerOctave} end}
%%
%% !! databases can not be empty: thus the et12 default DBs for scales and intervals are still set!
%% empty DBs (to be explicit)
% ScaleDB = scales  %% ?? what kind of scale should I use here? 
IntervalDB = {HS.dbs.partch.getIntervals PitchesPerOctave}
{HS.db.setDB unit(
		  chordDB:ChordDB
		  %chordDB:{HS.dbs.arithmeticalSeriesChords.getSelectedChords 72}
		  % scaleDB:ScaleDB
		  intervalDB:IntervalDB
		  pitchesPerOctave:PitchesPerOctave)}


%% check
{HS.db.getInternalChordDB}

{HS.db.getInternalIntervalDB}

%% !! still old setting
{HS.db.getInternalScaleDB}

%%%%%%%%%%%%%%%%%%%


%% simple CSP: 8 random pitches out of random 2 chords out of chord DB
{SDistro.exploreOne
 proc {$ MyScore}
    MyVoice = {Score.makeScore2
	       seq(items:{LUtils.collectN 8 fun {$} note(duration:2) end})
	       Aux.myCreators}
    MyChords = {Score.makeScore2
		seq(items:{LUtils.collectN 2 fun {$} chord(duration:8) end})
		Aux.myCreators}
 in
    MyScore = {Score.makeScore
	       sim(items:[MyVoice
			  MyChords]
		   startTime:0
		   timeUnit:beats(4))
	       Aux.myCreators}
 end
 Aux.myDistribution}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% TODO:  



%%
%% only chord notes (over single chord or chord progression.
%%
%% I wouldn't necessaily need constraint programming (in Longing I did something similar). On the other hand, def is much more easy. Besides, I constrain both horizontal intervals and chord (progression). Later, I will even intro non-harmonic notes, which would be virtually impossible to def without constraints.
%%

%% (later, e.g. by CM processing) set quasi note offset < 0 to turn this into harmony cloud with a tendency upwards



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% tmp
%%

%% constrains Xs (a list of FD ints) to have 'an increasing tendency'
%%
%% !! into pattern rule on Xs
{ExploreOne
 proc {$ Sol}
    XL = 10			% length of Xs
    YL = 4			% (min) number of Xs elements which strictly increase (not necessarily neighbours)
    Min = 1			% min Xs val (at least one occurance)
    Max = 10			% max Xs val (at least one occurance)
    NrDirChange = 4		% number of direction changes in Xs
    Xs = {FD.list XL Min#Max}	% the actual solution
    Is = {FD.list YL 1#XL}	% aux
    Ys = {FD.list YL Min#Max}	% aux
 in
    Sol = unit(xs:Xs is:Is ys:Ys)
    {Pattern.selectMultiple Xs Is Ys} % relation between Xs, Is and Ys
    {Pattern.increasing Is}
    %% selected Xs elements are increasing (causing a tendency to increase)
    {Pattern.decreasing Ys}
    %% distance between Xs elements is restricted 
    {Pattern.for2Neighbours Xs
     proc {$ X1 X2}
	{FD.distance X1 X2 '<:' 3}
     end}
    %% one X element is Min one is Max
    {Pattern.oneTrue {Map Xs fun {$ X} X =: Min end}}
    {Pattern.oneTrue {Map Xs fun {$ X} X =: Max end}}
    %% the number of direction changes in Xs in constrained (i.e. no
    %% purely increasing Xs is permitted)
    {Pattern.howManyTrue
     {Pattern.mapNeighbours Xs 3
      fun {$ [X Y Z]} {Pattern.directionChangeR X Y Z} end}
     NrDirChange}
    %% Distribution strategy
    {FD.distribute ff {Append Xs Is}}
 end}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% also non-harmonic notes (but when these notes should be in scale: what is the scale? Partch Intervals over root=0?)
%%


