declare
[RegT] = {ModuleLink ['x-ozlib://anders/strasheela/RegularTemperament/RegularTemperament.ozf']}


%% 7-limit JI
{HS.db.setDB {RegT.db.makeFullDB
	      unit(generators: [702 386 969]
		   generatorFactors: [90#110 99#101 99#101] % 31 tones
		   generatorFactorsOffset: 100
		   pitchesPerOctave:1200
		   maxError:3000)}}


%% 1/4-comman meantone
{HS.db.setDB {RegT.db.makeFullDB
	      unit(generators: [69659]
% 		   generatorFactors: [94#106] % 13 tones
		   %% Note: with 21 fifths there is another PC closer to 81/64 than 5/4
		   %% 8 fifths down (Fb, 427.28 cent) is closer to 81/64 than 5/4 
% 		   generatorFactors: [90#110] % 21 tones
		   generatorFactors: [85#115] % 31 tones
		   generatorFactorsOffset: 100
		   pitchesPerOctave:120000
		   maxError:3000)}}


/*
{HS.db.getTemperament}

%% 8 fifths down (Fb, 427.28 cent) is closer to 81/64 than 5/4 
{HS.db.makeRegularTemperament [69659] [92#107] unit(pitchesPerOctave:120000
						   generatorFactorsOffset: 100)}


*/


%% TODO: revise or delete tests

/*  
%% NOTE: first globally set 1/4-comman meantone before running these tests
%% ... there must be enough tones for the accidentals (e.g., 31) 

%% BUG: accidentals '#' and 'b' always produce slightly wrong pitches (both accidentals "too large")
%% 

%% OK
{RegT.pc 'C'#''}
%% OK
{RegT.pc 'C'#'^'}  %% 38.71 cent in 31-TET
%% BUG: returns 115908 -- not even in temperament
{RegT.pc 'D'#'b'#'b'} % 38.71 
%% BUG: returns 11705
{RegT.pc 'C'#'#'}  % 77.42
%% BUG: returns 76.13 -- diatonic and chromatic semitone swapped?
{RegT.pc 'D'#'b'}  % 116.13
%% BUG: returns 23410
{RegT.pc 'C'#'#'#'#'} % 116.13
%% OK
{RegT.pc 'D'#'v'} % 154.84
%% OK
{RegT.pc 'D'#''} % 193.55

%% Test: sequence of fifths -- always same intervals?
%% !!!! BUG: Interval B-F# is wrong: it is 46249 instead of 50341 (complement of 69659), i.e. F# is 4092 (^) too high
{Pattern.map2Neighbours
 {Map ['C'#'' 'G'#'' 'D'#'' 'A'#'' 'E'#'' 'B'#'' 'F'#'#' 'C'#'#']
  RegT.pc}
 fun {$ PC1 PC2} {Abs PC1 - PC2} end}


%% Tempered Pythagorean fifths and JI fifths are the same
%% OK
{RegT.pc 'E'#''}
{RegT.jiPC 'E'#'\\'}


%%%%%%%%%%


{RegT.jiPC 'C'#''}
%% ?? BUG: in meantone C# and C#\ should be the same!
{RegT.jiPC 'C'#'#'}
{RegT.jiPC 'C'#'#'#'\\'}
{RegT.jiPC 'D'#'b'}
{RegT.jiPC 'D'#'b'#'/'}
{RegT.jiPC 'D'#''}

%% ?? BUG: should be the same in meantone
%% Also, both PCs are wrong: should be 386 cent
%% Does work with smaller number of meantone pitches, but with larger factors a PC is chosen which actually has a higher error than 386 would have!  
{RegT.jiPC 'E'#''}
{RegT.jiPC 'E'#'\\'}


{RegT.jiPC 'C'#'7'}
{RegT.jiPC 'C'#'L'}

%% ?? BUG: should be the same in meantone
{RegT.jiPC 'B'#'b'#'L'}
{RegT.jiPC 'A'#'#'}


% {RegT.pcName 2}
% {RegT.pcName 3}

% {RegT.acc ''}
% {RegT.acc '7'}
% {RegT.acc 'L'}
% {RegT.acc '#'}
% {RegT.acc 'b'}

% {RegT.pitch 'C'#0}
% {RegT.pitch 'C7'#1}
% {RegT.pitch 'C'#4}


*/

