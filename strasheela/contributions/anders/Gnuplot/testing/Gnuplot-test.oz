
%%
%% this files is test suite and documentation
%%

declare
[Gnuplot] = {ModuleLink ['x-ozlib://anders/strasheela/Gnuplot/Gnuplot.ozf']}

% simple plot 
{Gnuplot.plot [0 5 3 7] unit}

% line style (see gnuplot doc for details)
{Gnuplot.plot [0 5 3 7] unit(style:impulses)}
% more extensive line style setting 
{Gnuplot.plot [0 5 3 7] unit(style:'linespoints linetype 1 linewidth 5 pointtype 3 pointsize 3')}
% shorthand 
{Gnuplot.plot [0 5 3 7] unit(style:'linesp lt 1 lw 5 pt 3 ps 3')}


% x and y given (otherwise x is natural numbers)
{Gnuplot.plot [0 5 3 7] unit(x:[0.1 0.5 2 2.1])} 

% 3D plot
{Gnuplot.plot [1 3 2 4] unit(x:[0.1 0.5 2 2.1] 
			     z:[0.5 3 2 ~1]
			     style:lines)}

% multiple plots
{Gnuplot.plot [[1 5 4 0 4] [4 2 6 0 1]] unit} 


% multiple line styles
{Gnuplot.plot [[1 5 4 0 4] [4 2 6 0 1]] unit(style: [lines impulses])} 

% multiple 3D plots
{Gnuplot.plot [[1 5 3] [4 6 0]] unit(x:[[1 2 1.5] [1 7 6]]
				     z:[[0 1 4] [0 3 2]])}

% title for graphs
{Gnuplot.plot [0 5 3 7] unit(title:myTest)}
{Gnuplot.plot [[0 5 3 7] [2 3 4 5]] unit(title:[test1 test2])}

% additional settings (out to ps file in /tmp/)
{Gnuplot.plot [0 5 3 7] unit(set:["title 'test'" % title of whole plot
				  "output '/tmp/plot.ps'" % output file
				  "terminal postscript"	% output format
				 ])}
%% set the viewing angle for 3D plots (see below and gnuplot doc for details)
{Gnuplot.plot [0 1 5] unit(x:[0 1 2] z:[0 5 1] set:["view 120, 30, 1, 1"])}
% {Gnuplot.plot [0 1 5] unit(x:[0 1 2] z:[0 5 1])}


%% output on Mac (AquaTerm)
%% -> this should not be needed, terminal aqua is default terminal for AquaTerm
{Gnuplot.plot [0 1 5] unit(x:[0 1 2] z:[0 5 1] set:["terminal aqua"])}

% plain plot and also output to postscript file
%%
%% !! still buggy!
{Gnuplot.plot [0 5 3 7] unit(additionalPsOut:"/tmp/plot2.ps")}



/*

%% --> the following is quoted from doc of gnuplot, see that for (much) more info <--

% some styles (all styles using 2 (2D) or 3 (3D) parameters) can be used)
% "lines" The `lines` style connects adjacent points with straight line segments.
% "points" The `points` style displays a small symbol at each point. (:set "pointsize <number>" may be used to change the size of the points)
% "linespoints" The `linespoints` style does both `lines` and  `points`, that is, it draws a small symbol at each point and then connects adjacent points with straight line segments. `linespoints` may be abbreviated `lp`. (:set "pointsize <number>" may be used to change the size of the points). 
% "impulses"  The `impulses` style displays a vertical line from the x axis (not the graph border), or from the grid base in a 3D plot, to each point.
% "dots" The `dots` style plots a tiny dot at each point -- this is useful for scatter plots with many points.
% "steps" The `steps` style is only relevant to 2-d plotting.  It connects consecutive points with two line segments: the first from (x1,y1) to (x2,y1) and the
%  second from (x2,y1) to (x2,y2).
% "boxes" The `boxes` style is only relevant to 2-d plotting.  It draws a box centered about the given x coordinate from the x axis (not the graph border) to the given y coordinate.

% %% further settings
% The 'set' command of gnuplot can be used to sets _lots_ of options.

% %% output type
% "terminal <val>" sets what kind of output to generate, many formats are supported, e.g.:
% x11 X11 Window System 
% aifm  Adobe Illustrator 3.0 Format
% corel  EPS format for CorelDRAW
% fig  FIG 3.1 graphics language: can be edited by xfig graphics editor
% mif  Frame maker MIF 3.00 format
% postscript  PostScript graphics language
% latex  LaTeX picture environment
% [further special Tex/LaTeX environments]
% [many special printer formats]

% %% view
% "view <rot_x> {,{<rot_z>}{,{<scale>}{,<scale_z>}}}" sets the viewing angle for 3D plots, where <rot_x> and <rot_z> control the rotation angles (in degrees). <rot_x> is bounded to the [0:180] range with a default of 60 degrees, while <rot_z> is bounded to the [0:360] range with a default of 30 degrees. <scale> controls the scaling of the entire `splot`, while <scale_z> scales the z axis only.  Both scales default to 1.0.
*/
	

%%%%%%%%%%%%%%%%%%%%%%%%		     

/*

(multiple-pages-plot 2 '(1 2 3 2 3 4 3 4 5 4 5 6 5 6 7 6 7 8 7 8 9) 
		     :additional-ps-out "/home/to/my-plot")
(multiple-pages-plot 2 '(1 2 3 4 5 6 7 8 9 10))

*/
