
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Redefinitions (minor changes) of some parts of mozart/share/lib/cp/FD.oz 
%%%
%%% Changes:
%%%
%%% - The distribution argument 'value' now has the interface {MyValue X SelectFn ?Dom}, where X is the distributed data structure, SelectFn is the function given to the select argument, and Dom is the resulting domain specification.
%%%
%%% - Added distribution argument 'trace': if present, each distribution step is traced at STDOUT (*Oz Emulator* buffer).
%%%

functor
   
import    
   FDP at 'x-oz://boot/FDP'
   FD
   Space(waitStable)
   System

export
   FdDistribute
   
define
   
   local
      FddOptVarMap = map(naive:   0
			 size:    1
			 min:     2
			 max:     3
			 nbSusps: 4
			 width:   5)
   
      FddOptValMap = map(min:      0
			 mid:      1
			 max:      2
			 splitMin: 3
			 splitMax: 4)

      fun {VectorToType V}
	 if {IsList V}       then list
	 elseif {IsTuple V}  then tuple
	 elseif {IsRecord V} then record
	 else
	    {Exception.raiseError
	     kernel(type VectorToType [V] vector 1
		    'Vector as input argument expected.')} illegal
	 end
      end
      fun {VectorToList V}
	 if {VectorToType V}==list then V
	 else {Record.toList V}
	 end
      end
      local
	 proc {RecordToTuple As I R T}
	    case As of nil then skip
	    [] A|Ar then R.A=T.I {RecordToTuple Ar I+1 R T}
	    end
	 end
      in
	 proc {VectorToTuple V ?T}
	    case {VectorToType V}
	    of list   then T={List.toTuple '#' V}
	    [] tuple  then T=V
	    [] record then
	       T={MakeTuple '#' {Width V}} {RecordToTuple {Arity V} 1 V T}
	    end
	 end
      end
   
      proc {MakeDistrTuple V ?T}
	 T = {VectorToTuple V}
	 if {Record.all T FD.is} then skip else
	    {Exception.raiseError
	     kernel(type MakeDistrTuple [V T] 'vector(fd)' 1
		    'Distribution vector must contain finite domains.')}
	 end
      end
	 
      %% Optimized and generic
      SelVal = map(min: fun {$ X SelectFn}
			   {FD.reflect.min {SelectFn X}}
			end
		   max: fun {$ X SelectFn}
			   {FD.reflect.max {SelectFn X}}
			end
		   mid: fun {$ X SelectFn}
			   {FD.reflect.mid {SelectFn X}}
			end
		   splitMin: fun {$ X SelectFn}
				0#{FD.reflect.mid {SelectFn X}}
			     end
		   splitMax: fun {$ X SelectFn}
				{FD.reflect.mid {SelectFn X}}+1#FD.sup
			     end
		   %% NOTE: old
% 		   min:      FD.reflect.min
% 		   max:      FD.reflect.max
% 		   mid:      FD.reflect.mid
% 		   splitMin: fun {$ V}
% 				0#{FD.reflect.mid V}
% 			     end
% 		   splitMax: fun {$ V}
% 				{FD.reflect.mid V}+1#FD.sup
% 			     end
		  )
	    
      %% Generic only
      GenSelVar = map(naive:   fun {$ _ _}
				  false
			       end
		      size:    fun {$ X Y}
				  {FD.reflect.size X}<{FD.reflect.size Y}
			       end
		      width:   fun {$ X Y}
				  {FD.reflect.width X}<{FD.reflect.width Y}
			       end
		      nbSusps: fun {$ X Y}
				  L1={FD.reflect.nbSusps X}
				  L2={FD.reflect.nbSusps Y} 
			       in 
				  L1>L2 orelse
				  (L1==L2 andthen
				   {FD.reflect.size X}<{FD.reflect.size Y})
			       end
		      min:     fun {$ X Y}
				  {FD.reflect.min X}<{FD.reflect.min Y}
			       end
		      max:     fun {$ X Y}
				  {FD.reflect.max X}>{FD.reflect.max Y}
			       end)
	    
      GenSelFil = map(undet:  fun {$ X}
				 {FD.reflect.size X} > 1
			      end)

      %% use unit as default value to recognize the case when
      %% we can void the overhead of a procedure call and a synchronization
      %% on stability
      GenSelPro = map(noProc: unit)
	    
      GenSelSel = map(id:     fun {$ X} X end)
	    
      fun {MapSelect Map AOP}
	 if {IsAtom AOP} then Map.AOP else AOP end
      end
	    
      fun {PreProcessSpec Spec}
	 FullSpec = {Adjoin
		     generic(order:     size
			     filter:    undet
			     select:    id
			     value:     min
			     procedure: noProc)
		     case Spec
		     of naive then generic(order:naive)
		     [] ff    then generic
		     [] split then generic(value:splitMin)
		     else Spec
		     end}
	 IsOpt =    case FullSpec
		    of generic(select:id filter:undet procedure:noProc
			       order:OrdSpec value:ValSpec) then
		       {IsAtom OrdSpec} andthen {IsAtom ValSpec}
		    else false
		    end
      in
	 if IsOpt then
	    opt(order: FullSpec.order
		value: FullSpec.value)
	 else
	    gen(order:     {MapSelect GenSelVar FullSpec.order}
		value:     {MapSelect SelVal FullSpec.value}
		select:    {MapSelect GenSelSel FullSpec.select}
		filter:    {MapSelect GenSelFil FullSpec.filter}
		procedure: {MapSelect GenSelPro FullSpec.procedure})
	 end
      end

      %% Same as Choose,  but returns the filtered list of vars
      %% as well as the chosen variable.
      fun {ChooseAndRetFiltVars Vars Order Filter}
	 NewVars
	 fun {Loop Vars Accu NewTail}
	    case Vars of nil then
	       NewTail=nil
	       Accu|NewVars
	    [] H|T then
	       if {Filter H} then LL in NewTail=(H|LL)
		  {Loop T
		   if Accu==unit orelse {Order H Accu}
		   then H else Accu end
		   LL}
	       else {Loop T Accu NewTail} end
	    end
	 end
      in
	 {Loop Vars unit NewVars}
      end

   in
      proc {FdDistribute RawSpec Vec}
	 case {PreProcessSpec RawSpec}
	 of opt(value:SelVal order:SelVar) then
	    {Wait {FDP.distribute FddOptVarMap.SelVar FddOptValMap.SelVal Vec}}
	 [] gen(value:     SelVal
		order:     Order
		select:    Select
		filter:    Fil
		procedure: Proc) then
	    if {Width Vec}>0 then
	       proc {Do Xs}
		  {Space.waitStable}
		  E|Fs={ChooseAndRetFiltVars Xs Order Fil}
	       in
		  if E\=unit then
		     V={Select E}
		     D={SelVal E Select}
		     %% NOTE: old
% 		     D={SelVal V}
		  in
		     if Proc\=unit then
			{Proc}
			{Space.waitStable}
		     end
		     %% Debugging output
		     if {HasFeature RawSpec trace} then
			{ShowTracing E D} 
		     end
		     %% Choice point
		     choice {FD.int D        V}
		     []     {FD.int compl(D) V}
		     end
		     {Do Fs}
		  end
	       end
	    in
	       {Do {VectorToList Vec}}
	    end
	 end
      end
   end

   %%
   %% Aux
   %%

   proc {ShowTracing Param DomVal}
      {System.showInfo
       "Distribute "#{Value.toVirtualString {Param toInitRecord($)} 1000000 1000000}
       #" to "#DomVal}
   end

end   

