
%%% *************************************************************
%%% Copyright (C) 2004-2007 Torsten Anders (t.anders@qub.ac.uk) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

makefile(
   lib: ['Pattern.ozf']
   %% !! requirements are currently ignored by ozmake
   requires: ['x-ozlib://duchier/cp/Select.ozf'
	      'x-ozlib://anders/strasheela/GeneralUtils.ozf'
	      'x-ozlib://anders/strasheela/ListUtils.ozf']
   uri: 'x-ozlib://anders/strasheela/Pattern'
   mogul: 'mogul:/anders/strasheela/Pattern'
   author: 'Torsten Anders')

