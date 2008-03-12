
/** %% This functor configures the Oz Inspector for score inspection. It defines several Inspector score filterings/mappings for interactive score traversal and display and Inspector score actions, for example, for outputting a score.
%% 
%% These Inspector mappings and actions are used in the common way. Score objects have a special context menu (right mouse click, on MacOS middle mouse click). See http://www.mozart-oz.org/documentation/inspector/node3.html#chapter.interactive for information on Inspector mappings and actions in general.
%%
%% Please note, that when a score object is mapped, then its context menu changes to the menu of the shown mapping (e.g. a record) -- until you unmap the score object. So, if you want to inspect some details of a score object and at the same time use an Inspector action, for example, to play back the score object, you may want to display the same score object twice in two different Inspector widgets. For example, click  `Add new Widget'' from the Inspector menu and switch between widgets with the Tab-key (see http://www.mozart-oz.org/documentation/inspector/node2.html#chapter.basic). 
%% */


%%
%% BUG:
%%
%% Inspecting determined FS vars does not work with ScoreInspector. 
%%
%% When creating a new Inspector object, even without any further
%% configuration, inspecting determined variables hangs.
%%
%% This seems to be a Mac OS problem (not on Linux).
/*
declare
InspectorObject = {Inspector.new unit}

%% hangs
{InspectorObject inspect({FS.value.make [1 2 3]})}

%% works fine
{InspectorObject inspect({FS.var.decl})}
{InspectorObject inspect(foo)}
*/



%%
%% TODO:
%%
%% * output actions (context menu)
%%
%% ?? * Editing action (context menu): shall I allow to reduce the domain of parameter variables? I.e. action for FD ints which opens new GUI window and allows to set a domain as text (expects arg for FD.int)
%%
%% * revise mappings (context menu)
%%
%%  - replace ShowAllEntries with orig from Inspector so that it supports objects of all classes
%%
%% OK? * settings: after defining a new objectMenu,
%%
%%   - the default mapping is set to no mapping: can I change that with API?
%%
%%   - the appearance is set to fixed indend: can I change that with APII? 
%%
%% * ?? define abstraction for showing score object twice on different Inspector widgets?
%%

%% !!?? 
%%
%% set to graph mode (is default)
% {Inspector.configure widgetTreeDisplayMode false}
%%
%% equality setting is the default "token equality" (System.eq), alternative would be with '=' method, but I don't need that for now
%%
% equivalence relations
%% !! after feeding, the Inspector does not work anymore! 
% {Inspector.configure widgetRelationList
%  ['Token Equality'(System.eq)
%   'Score Object Equality'(fun {$ X Y}
% 			     {Score.isScoreObject X} andthen
% 			     {Score.isScoreObject Y} andthen
% 			     {X '=='($ Y)}
% 			  end)
%  ]}

functor 
import
   Inspector % System
   Boot_Object at 'x-oz://boot/Object'
   Boot_Name at 'x-oz://boot/Name'
   
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   
export
   ConfigureActive
   ConfigureAll
   
   Inspect InspectN Close Configure % ConfigureN 
   object: InspectorObject

   new: Inspector_New

   %% tmp
%   ApplyMyConfiguration
   
define

   %% only for exporting new
   Inspector_New = Inspector.new
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Mappings  
%%%

   %% copied from InspectorOptions.oz
   	 local
	    class SpyObject
	       meth getAttr(A $) @A end
	       meth getFeat(A $) self.A end
	    end
	    OOAttr  = {Boot_Name.newUnique 'ooAttr'}
	    OOFeat  = {Boot_Name.newUnique 'ooFeat'}
	    OOPrint = {Boot_Name.newUnique 'ooPrintName'} 
	 in
	    proc {MapAttr As V Res}
	       case As
	       of A|Ar then
		  Res.A = {Boot_Object.send getAttr(A $) SpyObject V} {MapAttr Ar V Res}
	       else skip
	       end
	    end
	    proc {MapFeat As V Res}
	       case As
	       of A|Ar then
		  Res.A = {Boot_Object.send getFeat(A $) SpyObject V} {MapFeat Ar V Res}
	       else skip
	       end
	    end
	    fun {DefaultMapObject V W D}
	       Class = {Boot_Object.getClass V}
	       Name  = Class.OOPrint
	       Attr  = {Record.arity Class.OOAttr}
	       Feat  = {Record.arity Class.OOFeat}
	       AttrR = {Record.make attributes Attr}
	       FeatR = {Record.make features Feat}
	    in
	       {MapAttr Attr V AttrR}
	       {MapFeat Feat V FeatR}
	       {List.toTuple Name [AttrR FeatR]}
	    end
	 end
   
   %% !! args MaxWidth and MaxDepth unused
   fun {ShowHierarchy X MaxWidth MaxDepth}
      if {Score.isScoreObject X}
      then MyLabel = X.label
      in
	 if {X isContainer($)}
	 then MyLabel(info:{X getInfo($)}
		      items:{X getItems($)}
		      parameters:{X getParameters($)})
	 elseif {X isElement($)}
	 then MyLabel(info:{X getInfo($)}
		      parameters:{X getParameters($)})
	 elseif {X isParameter($)}
	 then MyLabel(info:{X getInfo($)}
		      value:{X getValue($)}
		      'unit':{X getUnit($)})
	 end
      else X
      end
   end
   %% !! arg MaxWidth unused
   fun {ShowHierarchyR X MaxWidth MaxDepth}
      if {Score.isScoreObject X} andthen MaxDepth > 0
      then	 
	 fun {Recur X}
	    {ShowHierarchyR X MaxWidth MaxDepth-1}
	 end
	 MyLabel = X.label
      in
	 if {X isContainer($)}
	 then MyLabel(info:{X getInfo($)}
		      items:{Map {X getItems($)} Recur}
		      parameters:{Map {X getParameters($)} Recur})
	 elseif {X isElement($)}
	 then MyLabel(info:{X getInfo($)}
		      parameters:{Map {X getParameters($)} Recur})
	 elseif {X isParameter($)}
	 then MyLabel(info:{X getInfo($)}
		      value:{X getValue($)}
		      'unit':{X getUnit($)})
	 end
      else X
      end
   end
   fun {ShowInitRecord X MaxWidth MaxDepth}      
      if {Score.isScoreObject X}
      then {X toInitRecord($)}
      else X
      end
   end
   fun {ShowAllEntries X MaxWidth MaxDepth}
      if {Score.isScoreObject X}
      then Name = {X getClassName($)}
      in
	 Name({List.toRecord attributes
	       {Map {X getAttrNames($)}
		fun {$ Attr} Attr#{X getAttr($ Attr)} end}}
	      {List.toRecord features
	       {Map {X getFeatNames($)}
		fun {$ Feat} Feat#{X getFeat($ Feat)} end}})
      else {DefaultMapObject X MaxWidth MaxDepth}
      end
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Actions   
%%%
   
   proc {EmptyAction X}
      %% NB: Inspector is blocked until action is finished and
      %% concurrent programming does not help here..
      {GUtils.warnGUI "this is a placeholder for a score output action..."}
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Inspector settings  
%%%

   /** %% [Aux] Configure a specific Inspector instance.
   %% */
   proc {ConfigureInstance InspectorInstance Key Value}
      {InspectorObject configureEntry(Key Value)}
   end

   %% context menu for objects   
   proc {RegisterScoreInspectorObjectMenu MyInspector}
      {ConfigureInstance MyInspector
       objectMenu
       menu([1 5 10 0 ~1 ~5 ~10] % WidthList (0 is separator)
	    [1 5 10 0 ~1 ~5 ~10] % DepthList
	    %% MappingList
	    [%% the default mapping is marked by surrounding it with auto(...). It can not be unmapped...
	     %% auto mappings implicitly work recursively, other mappings do not..
%	  auto('Show Score Hierarchy'(ShowHierarchy))
	     'Show Textual Score'(ShowInitRecord)
	     'Show Score Hierarchy'(ShowHierarchy)
	     'Show Score Hierarchy Recursively'(ShowHierarchyR)
	     'Show All Entries'(ShowAllEntries)]
	    %% ActionList: list of tuples 'Shown Label'(ActionProc)
	    %%
	    %% !! Enter output procs here
	    ['Empty Action'(EmptyAction)]
	   )}
   end

   proc {ApplyMyConfiguration MyInspector}
      {RegisterScoreInspectorObjectMenu MyInspector}
      %% show integers lists are strings 
%      {ConfigureInstance MyInspector widgetShowStrings true}
      %% standard indent (setting must be delayed somewhat to be effective)
      {Delay 50}
      {ConfigureInstance MyInspector widgetUseNodeSet 1}
      %% set to graph mode 
      {ConfigureInstance MyInspector widgetTreeDisplayMode false}
      %% equivalence relations
      %% !! this seems to block inspector
%       {Inspector.configure widgetRelationList
%        ['Token Equality'(System.eq)
% 	'Score Object Equality'(fun {$ X Y}
% 				   if {Score.isScoreObject X} andthen
% 				      {Score.isScoreObject Y} 
% 				   then {X '=='($ Y)}
% 				   else {System.eq X Y}
% 				   end
% 				end)
%        ]}
   end

   %% export proc which configures (all?) "existing" Inspector instances
   %%
   %% two procs:

   /** %% Configure the active inspector instances (affects Inspector.inspect and changes setting of inspectorOptionsRange). 
   %% */
   proc {ConfigureActive}
      {Inspector.configure inspectorOptionsRange active}
      {ApplyMyConfiguration Inspector.object}
   end

   /** %%  Configure all inspector instances, including instances created only later (affects Inspector.inspect and changes setting of inspectorOptionsRange).
   %% */
   proc {ConfigureAll}
      {Inspector.configure inspectorOptionsRange all}
      {ApplyMyConfiguration Inspector.object}
   end

     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Inspector object creation
%%%

      %% export new and configured Inspector instance -- this instance can be used alongside the old Inspector
   %% -> is this possible?
   %% Inspector.new replaces the old class field for safety reasons.

   /** %% A configured score object instance.
   %% */ 
   InspectorObject = {Inspector.new unit} 
   {ApplyMyConfiguration InspectorObject}

   
   /** %% Inspect using the configured inspector (without touching the original inspector).  
   %% */ 
   proc {Inspect X}
      {InspectorObject inspect(X)}
   end
   /** %% InspectN using the configured inspector (without touching the original inspector). 
   %% */ 
   proc {InspectN X}
      {InspectorObject inspectN(X)}
   end
   /** %% Configure the configured inspector (without touching the original inspector). 
   %% */ 
   proc {Configure Key Value}
      {InspectorObject configureEntry(Key Value)}
   end
   /** %% Closing the configured inspector, if any. 
   %% */ 
   proc {Close}
      {InspectorObject close}
   end  

   
end
