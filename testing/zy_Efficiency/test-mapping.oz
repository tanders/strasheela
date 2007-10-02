
%%
%% profile time it takes to map a list (can I just use the collect methods, or shall I add more methods like forAll, filter, count...)
%% 

declare
fun {ProfileMapping N}
   Time = {Property.get 'time.total'}
   L = {List.make N}
in
   {ForAll L proc {$ X} X=unit end}
   {Property.get 'time.total'}-Time
end

%%
%% !! For mapping long lists the memory needed by Oz increases !!
%% (machine starts swapping and performance decreases)
%%
%% mapping over 1000 elements takes 0 msecs
{ProfileMapping 1000}

%% mapping over 1000000 elements takes 300-900 msecs
{ProfileMapping 1000000}

%% mapping over 10000000 elements takes about 2-3 ... 60 secs
{ProfileMapping 10000000}

%% collect time for multiple calls: traversing n lists of length m
%% takes about as long as traversing a single list of length n*m
{FoldR {Map {List.make 10} fun {$ X} X=100000 end}
 fun {$ X I}% {Inspect X#I}
    {ProfileMapping X} + I end
 0}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Test loop instead

declare
fun {ProfileLooping N}
   Time = {Property.get 'time.total'}
   Xs = {List.make N}
in
   for X in Xs do X=unit end
   {Property.get 'time.total'}-Time
end

%%
%% !! For mapping long lists the memory needed by Oz increases !!
%% (machine starts swapping and performance decreases)
%%
%% looping over 1000 elements takes 0 msecs
{ProfileLooping 1000}

%% looping over 1000000 elements takes 300-900 msecs
{ProfileLooping 1000000}

{ProfileLooping 10000000}

{FoldR {Map {List.make 10} fun {$ X} X=100000 end}
 fun {$ X I}% {Inspect X#I}
    {ProfileLooping X} + I end
 0}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Looping/Mapping consumes a lot of memory. Nut I think this has less
%% to do with the memory consumption of the looping, but with the
%% memory a very huge list takes. However, this should not bother
%% me. If I need huge lists, e.g. to represent grain lists, a length
%% of 1000000 seems still managable (and for a grain duration of 30
%% msecs without any overlaps this means a total duration of 90 h)
%% 

declare
fun {ProfileMapping N}
   Time = {Property.get 'time.total'}
   L = {List.make N}
in
   {ForAll L proc {$ X} X=unit end}
   {Property.get 'time.total'}-Time
end



{Show {Property.get 'memory'}}

{Show {Property.get 'gc'}}

{System.gcDo}			% gc can take a lot of time !!

% memory(atoms:465637 code:2281632 freelist:94224 heap:2842 names:12439)
%%
%% top output:
%%  PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME COMMAND
%% 1318 t          9   0  8752 8752  2068 S     0.0  3.5   0:00 emulator.exe

{ForAll {List.make 1000000}  proc {$ X} X=unit end}

%% memory(atoms:465637 code:2282076 freelist:6608 heap:10848 names:12439)
%% 
%%  PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME COMMAND
%% 1318 t          9   0 16060  15M  2072 S     0.0  6.4   0:00 emulator.exe
 

{ForAll {List.make 1000000000}  proc {$ X} X=unit end}

%% killed computation -- too much memory

 
test \= xz
