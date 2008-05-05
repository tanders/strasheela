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

/** %% This functor provides procedures related to the technique of harp playing. 
%% */

functor
import
   FD FS
export
   PedalsPCs PedalsPCs2
define
   fun {MakePedals}
      Domains = [[0 1 11] [1 2 3] [3 4 5] [4 5 6] [6 7 8] [8 9 10] [0 10 11]]
   in
      {Map Domains FD.int}
   end

   fun {MakePCs}
      Set = {FS.var.upperBound 0#11}
      Card = {FS.card Set}
   in
      Card >: 3
      Card <: 8
      Set
   end
   
   /** %% This procedure establishes a relation between the positions of the Pedals
   %% and the set of available pitch-classes PCs. If they are unbound, Pedals or PCs
   %% will be bound to default values.
   %% */
   proc {PedalsPCs Pedals PCs}
      PCsIncludedList
      fun {IsPCIncluded PC} {Nth PCsIncludedList PC+1} end
   in
      if {Not {IsDet Pedals}} then Pedals = {MakePedals} end
      if {Not {IsDet PCs}} then PCs = {MakePCs} end
      
      PCsIncludedList = for PC in 0..11 collect:C do {C {FS.reified.include PC PCs}} end
      
      {IsPCIncluded 2} =: ({Nth Pedals 2} =: 2)
      {IsPCIncluded 7} =: ({Nth Pedals 5} =: 7)
      {IsPCIncluded 9} =: ({Nth Pedals 6} =: 9)

      
      {IsPCIncluded 0} =: {FD.disj
			   ({Nth Pedals 1} =: 0)
			   ({Nth Pedals 7} =: 0)}
      {IsPCIncluded 1} =: {FD.disj
			   ({Nth Pedals 1} =: 1)
			   ({Nth Pedals 2} =: 1)}
      {IsPCIncluded 3} =: {FD.disj
			   ({Nth Pedals 2} =: 3)
			   ({Nth Pedals 3} =: 3)}
      {IsPCIncluded 4} =: {FD.disj
			   ({Nth Pedals 3} =: 4)
			   ({Nth Pedals 4} =: 4)}
      {IsPCIncluded 5} =: {FD.disj
			   ({Nth Pedals 3} =: 5)
			   ({Nth Pedals 4} =: 5)}
      {IsPCIncluded 6} =: {FD.disj
			   ({Nth Pedals 4} =: 6)
			   ({Nth Pedals 5} =: 6)}
      {IsPCIncluded 8} =: {FD.disj
			   ({Nth Pedals 5} =: 8)
			   ({Nth Pedals 6} =: 8)}
      {IsPCIncluded 10} =: {FD.disj
			    ({Nth Pedals 6} =: 10)
			    ({Nth Pedals 7} =: 10)}
      {IsPCIncluded 11} =: {FD.disj
			    ({Nth Pedals 1} =: 11)
			    ({Nth Pedals 7} =: 11)}

      {FD.impl
       {FD.conj
	{IsPCIncluded 4}
	{IsPCIncluded 5}}
       {FD.conj ({Nth Pedals 3} \=: 3) ({Nth Pedals 4} \=: 6)}
       1}

      {FD.impl
       {FD.conj
	{IsPCIncluded 0}
	{IsPCIncluded 11}}
       {FD.conj ({Nth Pedals 1} \=: 1) ({Nth Pedals 7} \=: 10)}
       1}
   end

   /** %% This procedure propagates less than PedalsPCs.
   %% */
   proc {PedalsPCs2 Pedals PCs}
      PCsIncludedList
      fun {IsPCIncluded PC} {Nth PCsIncludedList PC+1} end
   in
      if {Not {IsDet Pedals}} then Pedals = {MakePedals} end
      if {Not {IsDet PCs}} then PCs = {MakePCs} end
      
      PCsIncludedList = for PC in 0..11 collect:C do {C {FS.reified.include PC PCs}} end
      
      {IsPCIncluded 2} =: ({Nth Pedals 2} =: 2)
      {IsPCIncluded 7} =: ({Nth Pedals 5} =: 7)
      {IsPCIncluded 9} =: ({Nth Pedals 6} =: 9)

      
      {IsPCIncluded 0} =: {FD.disj
			   ({Nth Pedals 1} =: 0)
			   ({Nth Pedals 7} =: 0)}
      {IsPCIncluded 1} =: {FD.disj
			   ({Nth Pedals 1} =: 1)
			   ({Nth Pedals 2} =: 1)}
      {IsPCIncluded 3} =: {FD.disj
			   ({Nth Pedals 2} =: 3)
			   ({Nth Pedals 3} =: 3)}
      {IsPCIncluded 4} =: {FD.disj
			   ({Nth Pedals 3} =: 4)
			   ({Nth Pedals 4} =: 4)}
      {IsPCIncluded 5} =: {FD.disj
			   ({Nth Pedals 3} =: 5)
			   ({Nth Pedals 4} =: 5)}
      {IsPCIncluded 6} =: {FD.disj
			   ({Nth Pedals 4} =: 6)
			   ({Nth Pedals 5} =: 6)}
      {IsPCIncluded 8} =: {FD.disj
			   ({Nth Pedals 5} =: 8)
			   ({Nth Pedals 6} =: 8)}
      {IsPCIncluded 10} =: {FD.disj
			    ({Nth Pedals 6} =: 10)
			    ({Nth Pedals 7} =: 10)}
      {IsPCIncluded 11} =: {FD.disj
			    ({Nth Pedals 1} =: 11)
			    ({Nth Pedals 7} =: 11)}


   end
end

