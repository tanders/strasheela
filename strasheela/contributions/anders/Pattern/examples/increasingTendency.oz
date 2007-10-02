

%% constrains Xs (a list of FD ints) to have 'an increasing tendency'
%%
%% NB: CSP with symmetries for Xs: in case more values in Xs are decreasing than length Ys, Is (and Ys) can have diifferent values without changing Xs
%% BTW: try with random distro
{ExploreOne
 proc {$ Sol}
    XL = 10			% length of Xs
    YL = 7			% (min) number of Xs elements which strictly increase (not necessarily neighbours)
    Min = 1			% min Xs val (at least one occurance)
    Max = 10			% max Xs val (at least one occurance)
    NrDirChange = 6		% number of direction changes in Xs
    Xs = {FD.list XL Min#Max}	% the actual solution
    Is = {FD.list YL 1#XL}	% aux
    Ys = {FD.list YL Min#Max}	% aux
 in
    Sol = unit(xs:Xs is:Is ys:Ys)
    {Pattern.selectMultiple Xs Is Ys} % relation between Xs, Is and Ys
    %% selected Xs elements are increasing (causing a tendency to increase)
    {Pattern.increasing Ys}
    %% distance between Xs elements is restricted 
    {Pattern.for2Neighbours Xs
     proc {$ X1 X2}
	{FD.distance X1 X2 '<:' 5}
	X1 \=: X2
     end}
    %% one X element is Min one is Max
    {Pattern.oneTrue {Map Xs fun {$ X} X =: Min end}}
    {Pattern.oneTrue {Map Xs fun {$ X} X =: Max end}}
    %% the number of direction changes in Xs in constrained (i.e. no
    %% purely increasing Xs is permitted)
    {Pattern.howManyTrue
     {Pattern.mapNeighbours Xs 3
      %% !! also contour 'repetition' causes direction change
      fun {$ [X Y Z]} {Pattern.directionChangeR X Y Z} end}
     NrDirChange}
    %% Distribution strategy
    {FD.distribute ff {Append Xs Is}}
 end}


%% same for decreasing tendency: different distribution strategy
{ExploreOne
 proc {$ Sol}
    XL = 10			% length of Xs
    YL = 4			% (min) number of Xs elements which strictly increase (not necessarily neighbours)
    Min = 1			% min Xs val (at least one occurance)
    Max = 10			% max Xs val (at least one occurance)
    NrDirChange = 4		% number of direction changes in Xs
    Xs = {FD.list XL Min#Max}	% the actual solution
    Is = {FD.list YL 1#XL}	% aux
    Ys = {FD.list YL Min#Max}	% aux
 in
    Sol = unit(xs:Xs is:Is ys:Ys)
    {Pattern.selectMultiple Xs Is Ys} % relation between Xs, Is and Ys
    {Pattern.increasing Is}
    %% selected Xs elements are increasing (causing a tendency to increase)
    {Pattern.decreasing Ys}
    %% distance between Xs elements is restricted 
    {Pattern.for2Neighbours Xs
     proc {$ X1 X2}
	{FD.distance X1 X2 '<:' 5}
	X1 \=: X2
     end}
    %% one X element is Min one is Max
    {Pattern.oneTrue {Map Xs fun {$ X} X =: Min end}}
    {Pattern.oneTrue {Map Xs fun {$ X} X =: Max end}}
    %% the number of direction changes in Xs in constrained (i.e. no
    %% purely increasing Xs is permitted)
    {Pattern.howManyTrue
     {Pattern.mapNeighbours Xs 3
      fun {$ [X Y Z]} {Pattern.directionChangeR X Y Z} end}
     NrDirChange}
    %% Distribution strategy: for decreasing pattern 
    {FD.distribute generic(order:size
			   value:max)
     {Append Xs Is}}
 end}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% tendency zick zack
%%


{ExploreOne
 proc {$ Sol}
    XL = 15			% length of Xs
    YL = 5			% (min) number of Xs elements which strictly increase (not necessarily neighbours)
    Min = 1			% min Xs val (at least one occurance)
    Max = 4			% max Xs val (at least one occurance)
    Xs = {FD.list XL Min#Max}	% the actual solution
    Is = {FD.list YL 1#XL}	% aux
    Ys = {FD.list YL Min#Max}	% aux
 in
    Sol = unit(xs:Xs is:Is ys:Ys)
    {Pattern.selectMultiple Xs Is Ys} % relation between Xs, Is and Ys
    %% selected elements do zick-zack between Min and Max
    {Pattern.cycle2 Ys [Min Max]}
    %% %% {Pattern.map2Neighbours Ys fun {$ Y1 Y2} end}
    %% selected elements are no neighbours
    {Pattern.for2Neighbours Is
     proc {$ I1 I2}
	{FD.distance I1 I2 '>:' 1}
     end}
    %% distance between Xs elements is restricted 
    {Pattern.for2Neighbours Xs
     proc {$ X1 X2}
	{FD.distance X1 X2 '<:' 2}
	% X1 \=: X2
     end}
    %% Distribution strategy
    {FD.distribute ff {Append Xs Is}}
 end}


