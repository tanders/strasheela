
%%% *************************************************************
%%% Copyright (C) 2007 Torsten Anders (t.anders@qub.ac.uk) 
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
   lib: ['source/OSC_Scanner.so'
	 'source/OSC_Scanner.ozf'
	 'source/OSC_Parser.ozf'
	 'OSC.ozf']
   rules: o('source/OSC_Scanner.so': ozg('source/OSC_Scanner.ozf'))
   uri: 'x-ozlib://anders/strasheela/OSC'
   mogul: 'mogul:/anders/strasheela/OSC'
   author: 'Torsten Anders')


