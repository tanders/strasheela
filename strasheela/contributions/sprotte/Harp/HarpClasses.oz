%%% *************************************************************
%%% Copyright (C) 2007 Kilian Sprotte (kilian.sprotte@gmail.com) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% Note: This functor is not ready yet. 
%% */

functor
import
   FD
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
export
   HarpNote
   IsHarpNote
prepare
   HarpNoteType = {Name.new}
define
   class HarpNote from Score.note
      feat
	 label:harpNote
	 !HarpNoteType:unit
      attr foo
      meth init(foo:Foo<=_ ...) = M
	 Score.temporalElement, {Record.subtractList M
				 [foo]}
	 @foo = {New Score.parameter init(value:Foo info:foo)}
	 {self bilinkParameters([@foo])}
      end
      meth getFoo($) {@foo getValue($)} end
      meth getFooParameter($) @foo end
      meth getInitInfo($ ...)
	 unit(
	    superclass:Score.temporalElement
	    args:[foo#getFoo#{FD.decl}])
      end
   end
   fun {IsHarpNote X}
      {Score.isScoreObject X} andthen {HasFeature X HarpNoteType}
   end
end
