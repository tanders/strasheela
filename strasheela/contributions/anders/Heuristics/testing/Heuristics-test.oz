
%% see also strasheela/examples/Heuristic-Constraints.oz

declare
[H] = {ModuleLink ['x-ozlib://anders/strasheela/Heuristics/Heuristics.ozf']}

declare
HC = {H.makeGivenInterval_Abs 4}

{HC 4 4}
{HC 4 2}
{HC 2 4}
{HC 0 4}
{HC 4 0}
{HC 10 0}
{HC 0 10}



