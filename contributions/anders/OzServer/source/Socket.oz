
%%% *************************************************************
%%% Copyright (C) 2006 Torsten Anders (t.anders@qub.ac.uk) 
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
   Open
   System
   
export
   MakeClient
   MakeServer
   ReadToStream
   Write
   
define

   /** %% Expects a portnumber and returns a client.
   %% NB: This proc is only used for testing..
   %% */
   proc {MakeClient Host PortNr ?MyClient}
      thread 
	 MyClient = {New Open.socket init}
	 %% !! blocks the entire Oz system until it succeeds.
	 {MyClient connect(host:Host
			   port:PortNr)}
      end
   end

   /** %% Creates a TCP socket server. Expects a Host (e.g., 'localhost') and a PortNo and returns a server plus its corresponding client. This client is an instance of Open.socket, and is the interface for reading and writing into the socket.
   %% MakeServer blocks until the server listens. However, waiting until a connection has been accepted happens in its own thread (i.e. MakeServer does only block until the server listens).
   %% NB: A port can be used only once, so assign it carefully. In case this postnnumber was shortly used before, you may need to wait a bit before reusing it.
   %% */
   %% !! Alternatively, let it assign automatically and output the port number..
   %%
   %% NOTE: for supporting multiple connections see http://www.mozart-oz.org/documentation/op/node13.html#section.sockets.accept
   proc {MakeServer Host PortNo ?MyServer ?MyClient}
      proc {Accept MyClient}
	 thread H in % P
	    %% suspends until a connection has been accepted
	    {MyServer accept(host:H
			     acceptClass:Open.socket  
			     accepted:?MyClient)} 
%	    {Myserver accept(host:H port:P)} % suspends until a connection has been accepted
	    %% !!?? port number of client is usually created randomly..
	    {System.showInfo "% connection accepted from host "#H}
%	 {System.showInfo "connection accepted from host "#H#"(at port "#P#")"}

	 end
	 %% !!??? 
	 %% If Accept is called recursively, then server accepts multiple connections. These share the same compiler instance (e.g. variable bindings are shared). For multiple independent compiler instances call the OzServer application multiple times.
	 %% However, how shall the output for multiple connections be sorted?? Would using the different client sockets created with the Server accept method work?
	 %% NB: The number of clients accepted concurrently must be limited to the number set by {MyServer listen}
	 % {Accept}
      end
   in
      MyServer = {New Open.socket init}
      %% To avoid problems with portnumbers, the port could be assigned automatically and then output..
      %%{MyServer bind(port:PortNo)}
      {MyServer bind(host:Host takePort:PortNo)}
      {MyServer listen}
      {System.showInfo "% OzServer started at host "#Host#" and port "#PortNo}
      MyClient = {Accept}
   end

   local
      proc {Aux Socket Size Stream}
	 In = {Socket read(list:$
			   size:Size)}
      in
	 {Wait In}
	 %% !! Is this the right way to stop the processing??
	 %%
	 %% abort condition when client stream ended (i.e. nothing was sent)
	 if In == nil
	 then {System.showInfo "socket stream ended"}
	    Stream = nil
	 else Stream = In | {Aux Socket Size}
	 end
      end
   in
      /** %% The socket Server returns a stream of the strings it receives. The Server always waits until someone writes something into the socket, then the input is immediately written to a stream and the Server waits again.
      %% */
      proc {ReadToStream Socket Size Xs}
	 thread {Aux Socket Size Xs} end
      end
   end

   proc {Write Socket VS}
      %% !!?? transform Result into VS
      %% !!?? (Depth=1, Width=1)
      %% {Value.toVirtualString VS 1 1}
      {Socket write(vs:VS)}
      %% problem of blocking reading from LW no solved by this..
%      {Socket flush(how:[send])}
%      {Socket flush}
   end
         
end

