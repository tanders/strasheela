
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% testing
%%

declare

[PMotif] = {ModuleLink ['x-ozlib://anders/strasheela/PrototypeMotif/PrototypeMotif.ozf']}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Plain motif
%%


%% A motif prototype is simply a score object
Motif_A_P = {Score.makeScore seq(info:topLevel
				 items:[note(info:firstNote
					     duration:2
					     pitch:60
					     amplitude:64)
					note(duration:2
					     pitch:62
					     amplitude:64)
					note(duration:2
					     pitch:64
					     amplitude:64)
					note(duration:2
					     pitch:62
					     amplitude:64)]
				 startTime:0)
	     unit}
%% If motif is defined on top-level you better wait until all its
%% parameters are determined by constraint propagation.
%% Hm, not necessary here: solver will block until required prototype vars are determined. If I unset undetermined vars, then that does not matter anyway.
% {Motif_A_P wait}

IsMotif_A
Motif_A
= {PMotif.makeScript Motif_A_P
   unit(
      %% unset all note pitches
      unset: [isNote#pitch]
      %% define optional arguments for Motif_A
      scriptArgs: unit(
		     %% arg range expects the domain of the interval
		     %% between the max and min motif pitch, wrappend
		     %% in a record. Default is dom(3#5)
		     range: proc {$ MyMotif Dom}
			       Ps = {Map {MyMotif collect($ test:isNote)}
				     fun {$ N} {N getPitch($)} end}
			       Interval = {FD.int Dom.1}
			    in
			       Interval =: {Pattern.max Ps} - {Pattern.min Ps}
			    end # dom(3#5)
		     %% arg pitch domain expects the domain of all
		     %% motif notes, wrapped in a record. Default is
		     %% dom(60#72).
		     pitchDomain: proc {$ MyMotif Dom}
				     {ForAll {MyMotif collect($ test:isNote)}
				      proc {$ N} {N getPitch($)} = {FD.int Dom.1} end}
				  end # dom(60#72)
		     ) 
      %% Clauses for constraints which define the relation
      %% between the prototype and the motif instance
      prototypeDependencies:
	 [%% Constrain each motif instance to follow the
	  %% same contour as the orig etc.
	  isContainer#{PMotif.unifyDependency
		       fun {$ X}
			  {Pattern.contour {X map($ getPitch test:isNote)}}
		       end}
% 	  %% Each motif instance starts with same note as prototype
% 	  fun {$ X} {X hasThisInfo($ firstNote)}
% 	  end#proc {$ Orig Copy}
% 		 {Orig getPitch($)} = {Copy getPitch($)}
% 	      end
	 ]
      motifTest:IsMotif_A
      )}



/*


%%%%%%%%%%%%%%%%%%%
%%
%% motif instances created directly on top-level 
%%

declare 
MyScore1 = {Motif_A unit(initScore:true)}

{Browse {MyScore1 toInitRecord($)}}

{MyScore1 getStartTime($)} = 0

{{MyScore1 getItems($)}.1 getPitch($)} = 66


%%%%%%%%%%%%%%%%%
%%
%% motif script used, well, as script 
%%

{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript Motif_A
		     unit(startTime:0
			  timeUnit:beats(4)
			  range:dom([4])
			  pitchDomain:dom(60#72)
			  initScore:true)}
 unit(value:random)}




%%%%%%%%%%%%%%%%%
%%
%% nested case: motif script used within script 
%%

{GUtils.setRandomGeneratorSeed 0}
%% nested case
{SDistro.exploreOne proc {$ MyScore}
		       MyScore = {Score.makeScore
				  seq(items:[{{GUtils.extendedScriptToScript Motif_A
					       unit}}
					     {{GUtils.extendedScriptToScript Motif_A
					       unit}}]
				      startTime:0
				      timeUnit:beats(4))
				  unit}
		    end 
 unit(value:random)}



%%%%%%%%%%%%%%%%%
%%
%% nested case: motif script used as score creator function 
%%

{GUtils.setRandomGeneratorSeed 0}
%% nested case
{SDistro.exploreOne proc {$ MyScore}
		       MyScore = {Score.makeScore seq(info:topLevel
						      items:[motif_A(pitchDomain:dom(62#67))
							     motif_A(pitchDomain:dom(60#64))]
						      startTime:0
						      timeUnit:beats(4)
						     )
				  add(motif_A:Motif_A)}
		    end 
 unit(value:random)}



*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Chord motif: motif which does not consist in notes but in chords
%% (motifs could also contain both)
%%
%% This example unsets variables which are directly contained in the score object and which are FS variables.
%%

%% V -> I progression, using default chord DB
Chord_Motif_P = {Score.makeScore seq(items:[chord(duration:2
						  index:{HS.db.getChordIndex 'major'}
						  transposition:7)
					    chord(duration:2
						  index:{HS.db.getChordIndex 'major'}
						  transposition:0)]
				     startTime:0)
		 add(chord:HS.score.chord)}
%% !!?? necessary?
% {Chord_Motif_P wait}

%% If the chord index or transposition is unset, then these internal variables should be unset too.
%% Comment: How can I make this setting less low-level, e.g., how can the internal vars be unset automatically. I thought about making such info accessible from chord object. Problem is, there is no clear cut between params which define the chord identity (index and transposition) and internal vars. Param root is something in between... So, for now I better specify these internal vars explicitly here.
InternalChordVars = [root untransposedRoot pitchClasses untransposedPitchClasses]

%% Chord motif instances share the indices and the absolute transposition intervals as prototype, but transposition is unset
IsChord_Motif
Chord_Motif
= {PMotif.makeScript Chord_Motif_P
   unit(unset: [HS.score.isChord # (transposition | InternalChordVars)]
	prototypeDependencies:
	   [isContainer#{PMotif.unifyDependency
			 fun {$ X}
			    {Pattern.map2Neighbours {X map($ getTransposition
							   test:HS.score.isChord)}
			     proc {$ T1 T2 ?TranspInterval}
				Offset = {HS.db.getPitchesPerOctave}
			     in
				TranspInterval = {FD.decl}
				TranspInterval =: T1 - T2 + Offset
			     end}
			 end}]
	motifTest:IsChord_Motif
       )}


/*


{GUtils.setRandomGeneratorSeed 0}
{SDistro.exploreOne {GUtils.extendedScriptToScript Chord_Motif
		     unit(startTime:0
			  timeUnit:beats(4)
			  initScore:true)}
 unit(value:random)}

*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% NestedScript
%%

declare
VolFenv = {New Fenv.fenv
	   init(env:fun {$ X} {Sin X} * 100.0 + 27.0 end
		min:0.0
		max:GUtils.pi)}
NestedMotif_AA_P = seq(info:[topLevel
			     fenvs(volume:VolFenv)
			    ]
		       items:[motif_A(info:id(x)
				      pitchDomain:dom(62#67))
			      motif_A(info:id(y)
				      pitchDomain:dom(60#64))
			      motif_A(info:id(z)
				      pitchDomain:dom(60#64))
			     ]
		       % startTime:0
		      )
NestedMotif_AA
= {PMotif.nestedScript NestedMotif_AA_P
   unit(
%       constraints:
% 	 [fun {$ X} {X hasThisInfo($ topLevel)}
% 	  end#proc {$ C}
% 		 %% NOTE: only works for 2 motifs, but thats exactly
% 		 %% what NestedMotif_AA_P defines
% 		 {Pattern.contour {C map($ PMotif.getHighestPitch test:IsMotif_A)}}
% 		 = {Pattern.contour [3 2 1]} % ascending
% 	      end
% 	 ]
      scriptArgs:unit(
		    %% contour specified by an example
		    contour:proc {$ C Default}
			       {Pattern.contour {C map($ PMotif.getHighestPitch
						       test:IsMotif_A)}}
			       = {Pattern.contour Default}
			    end # [1 2 1]
		    )
      constructors:add(motif_A:Motif_A)
      )}


/*

%% BUG: BLOCKS

{SDistro.exploreOne  {GUtils.extendedScriptToScript NestedMotif_AA
		      unit(% startTime:0
			   timeUnit:beats(4)
			   contour:[1 3 1]
			   nestedArgs: [[id(x) id(y)] # unit(pitchDomain:dom(60#72))
					id(z) # unit(pitchDomain:dom(60#72))
					%% test principle
					topLevel # unit(startTime:0)]
			  )}
 unit(value:random)}


*/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% NestedScript: minimum example for debugging the blocking
%%

declare
VolFenv = {New Fenv.fenv
	   init(env:fun {$ X} {Sin X} * 100.0 + 27.0 end
		min:0.0
		max:GUtils.pi)}
NestedMotif_AA_P = seq(info:topLevel
		       items:[motif_A(info:id(x)
				      pitchDomain:dom(62#67))
			      motif_A(info:id(y)
				      pitchDomain:dom(62#67))
			      motif_A(info:id(z)
				      pitchDomain:dom(62#67))])
NestedMotif_AA
= {PMotif.nestedScript NestedMotif_AA_P
   unit(
      scriptArgs:unit(
		    %% contour specified by an example
		    contour:proc {$ C Default}
			       {Pattern.contour {C map($ PMotif.getHighestPitch
						       test:IsMotif_A)}}
			       = {Pattern.contour Default}
			    end # [1 2]
		    )
      constructors:add(motif_A:Motif_A)
      )}


/*

%% create example directly
declare
MyNestedMotif = {NestedMotif_AA
		 unit(% startTime:0
		      timeUnit:beats(4)
		      contour:[1 2 1]
		      nestedArgs: [[id(x) id(y)] # unit(pitchDomain:dom(60#72))
				   id(z) # unit(pitchDomain:dom(60#72))
				   %% test principle
				   topLevel # unit(startTime:0)
				  ]
		      initScore:true
		     )}
{Browse {MyNestedMotif toInitRecord($)}}


%% 
{SDistro.exploreOne  {GUtils.extendedScriptToScript NestedMotif_AA
		      unit(% startTime:0   % as a test, startTime set by nestedArgs arg
			   timeUnit:beats(4)
			   contour:[1 2 1]
			   nestedArgs: [[id(x) id(y)] # unit(pitchDomain:dom(60#72))
					id(z) # unit(pitchDomain:dom(60#72))
					%% test principle
					topLevel # unit(startTime:0)]
			   initScore:true
			  )}
 unit(value:random)}


*/






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/*

declare

declare
NestedMotif_AA_P = seq(info:[topLevel
			     fenvs(volume:bla)
			    ]
		       items:[motif_A(info:id(x)
				      pitchDomain:dom(62#67))
			      motif_A(info:id(y)
				      pitchDomain:dom(60#64))
			      motif_A(info:id(z)
				      pitchDomain:dom(60#64))
			     ]
		       timeUnit: beats(4)
		      )

{Browse {MapScore NestedMotif_AA_P
	 fun {$ X} X end}}


%%
%% Nested arg implementation:
%% Traverse textual score (put that traversal def in ScoreMapping.oz).
%% If info of some score object matches info of some nestedArgs, then adjoin their args and append infos
%%

declare
NestedArgs = [[id(x) id(y)] # unit(pitchDomain:dom(62#67)
				   range:dom(4#6)
				   info:test)
	      id(z) # unit(pitchDomain:dom(60#65))
	      topLevel # unit(startTime:0)]
/** %% Expects a single info datum and traverses nested NestedArgs to find args matching Info
%% */
fun {FindArgs Info}
   Match = {LUtils.find NestedArgs
	    fun {$ ArgInfo#_ /* Args */}
	       case ArgInfo of H | T
	       then {Member Info ArgInfo}
	       else Info == ArgInfo
	       end
	    end}
in
   if Match \= nil then [ Match.2 ] else nil end
end
%% Expects score object spec: if it matches an arg spec, then the arg is returned
fun {GetArgs X}
   if {HasFeature X info}
   then if {IsList X.info}
	then {LUtils.mappend X.info FindArgs}
	else {FindArgs X.info}
	end
   else nil
   end
end
fun {AsList X}
   if {IsList X} then X else [X] end
end
%% TODO:
%% - all motifs should receive arg nestedArgs so that I can hand over args for deeper nested motifs.
%% - it is sufficient that only motifs receive this arg.
%%   Problem: how do I recognise motifs in textual score?
%%   Solution: every record whose label is as feat in NestedScript arg constructors, i.e. every motif def (any other constructor must be defined such that it excepts this arg to -- easy to define proc which just filters it out)
%% - MakeScript created-scripts support or ignore arg nestedArgs (??)
fun {AdjoinMatchingArgs X}
   Args = {GetArgs X}
in
   if Args \= nil
   then As = Args.1 in
      %% TMP:
%      {Adjoin X Args.1}
      if {HasFeature As info}
      then
	 Info = {Append {AsList X.info} {AsList As.info}}
      in
	 {Adjoin {Adjoin {Adjoin X As}
		  unit(info:Info)}
	  {Label X}}
      else
	 {Adjoin X As}
      end
   else X
   end
end
{Browse {SMapping.mapScore NestedMotif_AA_P
	 AdjoinMatchingArgs}}


*/








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% other tests
%%



/*


{Browse {Motif_A_P toInitRecord($)}}


%%%
%%
%% fixed issue 
%%

%%
%% Q: do motif instances share any variables?
%%

declare 
MyScore1 = {{GUtils.extendedScriptToScript Motif_A
	     unit(initScore:true)}}
MyScore2 = {{GUtils.extendedScriptToScript Motif_A
	     unit(initScore:true)}}


declare 
MyScore1 = {Motif_A $ unit(initScore:true)}
MyScore2 = {Motif_A $ unit(initScore:true)}


{Browse {MyScore1 toInitRecord($)}}

{Browse {MyScore2 toInitRecord($)}}

%% BUG: binding MyScore1 startTime binds MyScore2 startTime as well. Also, the startTime of all motif instances created later with Motif_A is then fixed. 
{MyScore1 getStartTime($)} = 0

%% !!?? However, pitch parameters are not shared between motif instances
{{MyScore1 getItems($)}.1 getPitch($)} = 66


%%
%% fixed 
%%


*/


/*

%%
%% unset variables which are not parameters 
%%

declare
MyChord = {Score.makeScore chord(index:1
				 transposition:0
				 startTime:0
				 duration:1
				 timeUnit:beats)
	   unit(chord:HS.score.chord)}
{MyChord wait}



{MyChord toInitRecord($)}


{MyChord toFullRecord($)}

{MyChord isDet($)}


%%
%% unset chord transposition and then create a copy 
%% I should also unset chord transposed PCs
%% and I can even unset chord untransposed PCs

declare


%% define convenience function which returns all chord etc attributes I need to unset when I want to unset transposition / index -- is more save!
{Unbind MyChord transposition}
{Unbind MyChord root}
{Unbind MyChord untransposedRoot}
{Unbind MyChord pitchClasses}
{Unbind MyChord untransposedPitchClasses}



{Unbind MyChord index}

{Unbind MyChord info}


%% Idea: unset arg expects attribute name or list of attribute names 


*/


