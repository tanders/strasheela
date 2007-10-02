
%%% *************************************************************
%%% Copyright (C) 2002-2005 Torsten Anders (www.torsten-anders.de) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** % This is the top level functor of Strasheela. */

functor
import
   Init at 'source/Init.ozf'
   GUtils at 'source/GeneralUtils.ozf'
   LUtils at 'source/ListUtils.ozf' 
   MUtils at 'source/MusicUtils.ozf' 
   Score at 'source/ScoreCore.ozf'
   SMapping at 'source/ScoreMapping.ozf'
   SDistro at 'source/ScoreDistribution.ozf' 
   Out at 'source/Output.ozf'

   %% !!?? shall I link all Strasheela extensions here (linking their
   %% directly their installed URIs like 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf')
   %%
   %% Advantage: I only need to link this top-level Strasheela functor
   %% then in examples etc and can access all Strasheela functionality
   %% from that functor. This is slightly more clear as required
   %% definitions in OZRC are reduced. On the other hand, plain Oz
   %% already shows a clear tendency to have special variables for
   %% often used functionality -- in practice hardly anybody will
   %% access all Strasheela functionality always via this top-level
   %% functor..
   
export
   Init GUtils LUtils MUtils Score SMapping SDistro Out
define
   skip
end
