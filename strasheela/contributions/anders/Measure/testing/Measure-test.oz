
%declare 
%[Measure] = {ModuleLink ['x-ozlib://anders/strasheela/Measure/Measure.ozf']}


%% single Measure:
declare
MyScore = {Score.makeScore measure(beatNumber:6
				   beatDuration:2 %{FD.int 1#2}
				   startTime:0
				   timeUnit:beats(4))
	   add(measure:Measure.measure)}

{MyScore toFullRecord($)}

{MyScore toInitRecord($)}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% single determined UniformMeasures:
declare
MyScore = {Score.makeScore measures(n:3 %{FD.int 1#3}
				    beatNumber:{FD.int 1#2}
				    beatDuration:{FD.int 1#2}
				    startTime:0
				    timeUnit:beats(4))
	   add(measures:Measure.uniformMeasures)}


{MyScore toInitRecord($)}

{MyScore toFullRecord($)}

{MyScore getBeatNumber($)} = 2

{MyScore getBeatDuration($)} = 2

% {MyScore getBeatDuration($)} = 3

{MyScore toInitRecord($)}

%% results for beatNumber=2, beatDuration=2
{MyScore onMeasureStartR($ 4)} % -> 1

{MyScore onMeasureStartR($ 6)} % -> 0

%% at end of measures
{MyScore onMeasureStartR($ 12)} % -> 1

%% far behind measures
{MyScore onMeasureStartR($ 120)} % -> 1

{MyScore onAccentR($ 0)} % -> 1

{MyScore onAccentR($ 4)} % -> 1

{MyScore onAccentR($ 6)} % -> 0 

{MyScore onBeatR($ 6)} % -> 1

{MyScore onBeatR($ 7)} % -> 0


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%% MeasureSeq temporalily commented
%%

%% single MeasureSeq:
declare
MyScore = {Score.makeScore measureSeq(items:{LUtils.collectN 2
					     fun {$}
						%% 2/8: a quarter note per measure
						measure(beatNumber:2
							beatDuration:{FD.int 2#3})
					     end}
				      startTime:0
				      timeUnit:beats(4))
	   add(measure:Measure.measure
	       measureSeq:Measure.measureSeq)}

{MyScore toFullRecord($)}

{MyScore toInitRecord($)}


%% results for beatDuration=2
{MyScore onMeasureStartR($ 0)} % -> 1

{MyScore onMeasureStartR($ 4)} % -> 1

{MyScore onMeasureStartR($ 6)} % -> 0

%% !! failure if Time < MyMeasure start 
{MyScore onAccentR($ 0)} % -> 1

%% !!?? implicitly constraints beatDuration of first measure
{MyScore onAccentR($ 4)} % -> 1

{MyScore onAccentR($ 6)} % -> 0

{MyScore onBeatR($ 6)} % -> 1

{MyScore onBeatR($ 7)} % -> 0

% {MyScore mapItems($ getBeatDuration)} = [2 2]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Measure.uniformMeasures, getMeasureAt
%%

declare
MyScore = {Score.makeScore measures(n:3
				    beatNumber:4
				    beatDuration:2
				    startTime:0
				    timeUnit:beats(4))
	   add(measures:Measure.uniformMeasures)}

{MyScore toFullRecord($)}

declare
Time = {FD.decl}

{MyScore getMeasureAt(3 Time)} % Time: 16#23


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Measure.uniformMeasures, overlapsBarlineR
%%

declare
MyScore = {Score.makeScore measures(n:3
				    beatNumber:4
				    beatDuration:2
				    startTime:0
				    timeUnit:beats(4))
	   add(measures:Measure.uniformMeasures)}

{MyScore toFullRecord($)}

declare
End = {FD.decl}
B

{MyScore overlapsBarlineR(B 8 End)} 

B = 1 % End > 16

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% tmp
%%

/*
%% score with predetermined rhythmic structure
%%
declare
MyScore = {Score.makeScore
	   sim(items:[seq(items:{LUtils.collectN 2
				 fun {$}
				    %% two quarter notes
				    note(duration:4
					 pitch:60
					 amplitude:1)
				 end})
		      measureSeq(items:{LUtils.collectN 2
					fun {$}
					   %% 2/8: a quarter note per measure
					   measure(beatNumber:2
						   beatDuration:2)
					end})]
	       startTime:0
	       timeUnit:beats(4))
	   add(measure:Measure.measure
	       measureSeq:Measure.measureSeq)}


{MyScore toFullRecord($)}

{MyScore toInitRecord($)}
*/


declare
proc {ArithmeticSeries Xs Difference}
   %% !! could be more propagation on bounds (i.e. max) of Difference
   {Pattern.for2Neighbours Xs
    proc {$ X Y}
       Y =: X + Difference
    end}
end

declare
Xs = {FD.list 4 1#10}
Diff = {FD.int 1#10}

{Browse Xs#Diff}

{ArithmeticSeries Xs Diff}

{Pattern.arithmeticSeries Xs Diff}

{Nth Xs 2} = 5

Diff = 2



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% test
%%

declare
M = {FS.var.decl}
D = {FD.decl}
B = {FD.int 0#1}

{Browse M#D#B}

{FS.reified.include D M B}

