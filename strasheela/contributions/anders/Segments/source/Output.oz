
%%% *************************************************************
%%% Copyright (C) 2004-2009 Torsten Anders (t.anders@qub.ac.uk) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************



functor

import
   Resolve
   
   %% !! tmp functor until next release with debugged Path of stdlib
   Path at 'x-ozlib://anders/tmp/Path/Path.ozf'
   
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   
export
   
   UnmeteredMusic_LilyHeader
   
define
   
   /** %% Lilyheader for notating unmetered music. See file UnmeteredMusic-Lilyheader.ly.data for usage (directly with Lilypond).
   %% This header file does not end in "\score{", so it can be combined with other headerfiles.
   %% */
   UnmeteredMusic_LilyHeader = {Out.readFromFile
				{{Path.make
				  {Resolve.localize
				   'x-ozlib://anders/strasheela/Segments/source/UnmeteredMusic-Lilyheader.ly.data'}.1}
				 toString($)}}

end