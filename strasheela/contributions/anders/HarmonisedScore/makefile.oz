
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

makefile(
   lib: ['HarmonisedScore.ozf'
	 % 'source/ScalaImport/ScalaScanner.so'
	 % 'source/ScalaImport/ScalaScanner.ozf'
	 % 'source/ScalaImport/ScalaParser.ozf'
	]
   % rules: o('source/ScalaImport/ScalaScanner.so': ozg('source/ScalaImport/ScalaScanner.ozf'))
   uri: 'x-ozlib://anders/strasheela/HarmonisedScore'
   mogul: 'mogul:/anders/strasheela/HarmonisedScore'
   author: 'Torsten Anders')

