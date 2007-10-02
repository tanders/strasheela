
%%% *************************************************************
%%% Copyright (C) 2004-2005 Torsten Anders (t.anders@qub.ac.uk) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

%% Later put grolaux Oz contributions into their extra package...

makefile(
   bin: ['StrasheelaTutorial.exe']
   lib: ['source/StrasheelaPrototyper.ozf'
	 'source/Compiler.ozf'
	 'TheExamples/01-Oz/01-Basics.tut'
	 'TheExamples/01-Oz/02-ConstraintProgramming.tut'
	 'TheExamples/02-Strasheela/01-MusicRepresentation.tut'
	 'TheExamples/02-Strasheela/02-MusicalCSPs.tut'
%	 'fromOthers/grolaux-tree-1.0/Tree.ozf'
%	 'fromOthers/grolaux-help-1.0/Help.ozf'
%	 'fromOthers/franzen-browsercontrol/BrowserControl.ozf'
	 ]
   %% !! requirements are currently ignored by ozmake
%   requires: [all of Strasheela..]
   uri: 'x-ozlib://anders/strasheela/Tutorial'
   mogul: 'mogul:/anders/strasheela/Tutorial'
   author: 'Torsten Anders')

