
%%% *************************************************************
%%% Copyright (C) 2005 Torsten Anders (t.anders@qub.ac.uk) 
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License
%%% as published by the Free Software Foundation; either version 2
%%% of the License, or (at your option) any later version.
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%% *************************************************************

/** %% This Strasheela contribution defines means to constrain formal relations in music. The constribution adds generic means to define motif domains and to impose constraints on motifs. 

%% The general Motif data structure MotifMixin (which is used later in this functor to extend Score.simultaneous and Score.sequential) defines two parameters: 'motifIdentity' and 'motifVariation' (parameter values are FD integers). The parameter value 'motifIdentity' decides for a specific motif out of an user-defined motif database, a list of records with user-defined motif features (a 'motifIdentity' value N denotes the Nth value in the motif database). For example, a possible motif database entry defines absolute note durations and the pitch contour of the motif (the contour defines the sequence of directions of intervals, see Pattern.contour and Pattern.direction for details).

motif(durations:[2 2 2 8] pitchContour:[1 1 0] comment:beethovensFifth)

%% The parameter value 'motifVariation' decides for a specific binary procedure out of a user-defined procedure database, a list of binary procedures (a 'motifVariation' value N denotes the Nth value in the procedure database). The procedure represented by 'motifVariation' constrains the motif score instance in a user defined way -- usually dependent on the motif database entry represented by 'motifIdentity'. Procedure arguments are a motif instance and an 0/1-integer. The 0/1-integer denotes whether or not the motif score instance fulfills the constraint imposed by the procedure (see Mozart/Oz doc for details on 0/1-constraints and reified constraints). For instance, one possible 'motifVariation' procedure may apply a motif database entry in the above-mentioned format by constraining the motif note durations and pitchContour according to the durations and pitchContour specified in the database entry represented by 'motifIdentity'. However, another 'motifVariation' procedure may constraints the motif pitches to follow the inverse of the pitchContour defined by the database entry.

%% The domain of motifs thus depends on three user-controlled dimensions: (a) the set of entries in the motif database, (b) the set of 'motifVariation' procedures, and (c) the ambiguity implicit in the motif definition (e.g. constraining only the pitch contour allows many motif variants with the same 'motifIdentity' and 'motifVariation'). Each of theses dimensions can be freely constrained. For instance, in a succession of several motifs the 'motifIdentity' and 'motifVariation' may be constrained to follow some pattern and the pitches of the motif notes constrained to follows some motif contour may be further constrained to follow some harmonic progression.

%% However, the formalisation of motific relations proposed here is even more general. Entries in the motif database may be undetermined in the definition of the constraint satisfaction problem (CSP). For instance, the user may constrain a set of motif score instances to be the same motif (e.g. all motif indices are equal), but the actual shape of the motif is undetermined in the CSP and may depend, e.g., on contrapunctual motif combinations (e.g. the shape of a fugue subject and counter-subject may only be found during search).

%% Furthermore, the number of notes in a score motif instance may be constrained by the decision, e.g., for a certain 'motifIdentity'. This is archived by some 'trick': notes of duration 0 can be considered non-existent. All entries in the motif database and all motifs in the score instance may actually have the same number of notes. However, in some motif database entries the duration of some notes is set to 0 which effectively reduces the note number of these motifs. The note number of any motif in the score instance may be virtually reduced by constraining certain note durations to 0.
%% However, for efficiency reasons a CSP involving the note duration 0 as an option should eliminate symmetries (for details see www.mozart-oz.org/documentation/fdt/node53.html). Notes with duration 0 must only occur at a certain position in motif (e.g. the motif end). If the duration of a note equals 0 the pitch of the note is arbitrary and should be determined as well to reduce the size of the search space (e.g. (duration = 0) -> (pitch = 0)).
%% See the contribution ConstrainTimingTree for further details.

%% To model free, non-motific sections between motific sections, a specific 'motifVariation' procedure may be defined which does not apply any constraints on the motif score instance (or constrains only the number of notes by setting note durations to 0). In the CSP, a decision for this 'motifVariation' means a decision for a non-motific section. To eliminate symmetries, the 'motifVariation' procedure should also determine the 'motifIdentity'. 

%% The data structure defined in this Strasheela contribution may also serve to define higher-level formal relations (e.g. variated repetitions of motif sequences). Instead of a motif containing notes, a 'higher-level motif' containes motifs. A 'Higher-level motif' constrains the contained submotif in the same way a motif constraints contained notes by deciding for the parameters 'motifIdentity' and 'motifVariation' and thus deciding for an entry in the motif database and an entry in the database of procedures. For example, the user may want to constrain the sequence of motifs contained in a 'higher-level motif' by applying a pattern constraint on submotif indices, or a pattern constraint on the sequence of the maximum pitches of each motif.
%% To control for which level a specific entry in either database is used (e.g. only for motifs of notes or only for 'higher-level motifs'), the user may reduce the domain of 'motifIdentity' and 'motifVariation' according to their motif instance level.

%% Of course, arbitrary parameters can be constrained in a motif. For instance, to model pauses before or between motif notes, the note offsetTimes may be constrained.

%% */


functor
import
   FD Combinator
   Browser(browse:Browse) % temp for debugging
   GUtils at 'x-ozlib://anders/strasheela/source/GeneralUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Pattern at 'x-ozlib://anders/strasheela/Pattern/Pattern.ozf'
export
   Database IsDatabase
   MotifMixin Sequential Simultaneous
   IsMotif IsInMotif
   MakeVariation
prepare
   MotifType = {Name.new}
   DatabaseType = {Name.new}
define
   
   /** %% [concrete class] a data abstraction which encapsulates the two databases in the two attributes motifDescriptionDB and motifVariationDB. An instance of this class is required by <code>MotifMixin, initMotifMixin</code>.
   %% A motif database is a list of arbitrary values. Example:
   [motif(pitchContour:[1 1 0] comment:beethovensFifth)
    motif(pitchContour:[2 0 1] comment:test)]
   %% The format of all motif entries should be uniform. The motif database is used by the procedures defined in the motif constraints database.
   %% NB: In case the motif database gets determined only during search, it is important that all variables have only local scope in the constraint script and consequently the database instance as well is local in the constraint script.
   %% The motif constraint database is a list of binary procedures. The first motifVariation argument is always the constrained motif and the second argument is a 0/1-integer which states whether the constraint is applied or not (arbitrary constraints can be turned into reified constraints with the help of Combinator.'reify'). 
   %% */ 
   class Database
      feat !DatabaseType:unit
      attr motifDescriptionDB motifVariationDB

	 /** %% If you leave one of the args (motifDescriptionDB and motifVariationDB) unset at init time, you must set them later using their accessor methods (getMotifDescriptionDB and getMotifVariationDB).
	 %% */
      meth init(motifDescriptionDB:MDs<=_
		motifVariationDB:MVs<=_)
	 @motifDescriptionDB = MDs
	 @motifVariationDB = MVs
      end

      meth getMotifDescriptionDB(?X) X = @motifDescriptionDB end
      meth getMotifVariationDB(?X) X = @motifVariationDB end
   end  
   fun {IsDatabase X}
      {Object.is X} andthen {HasFeature X DatabaseType}
   end
   
   local
      proc {InitConstraint MyMotif}
	 thread % don't block init if some information (e.g. DB) is still missing
	    MotifDescriptionDB = {MyMotif getMotifDescriptionDB($)}	% list of records
	    MotifVariationDB = {MyMotif getMotifVariationDB($)} % list of binary procs
	 in
	    {MyMotif getMotifIdentity($)} :: 1#{Length MotifDescriptionDB} 
	    {MyMotif getMotifVariation($)} :: 1#{Length MotifVariationDB} % ?? redundant
	    %% main constraint of MotifMixin: every motif variation function is applied to MyMotif, but only one must return true and getMotifVariation points to its position.
	    {Pattern.whichTrue
	     {Map MotifVariationDB fun {$ Var} {Var MyMotif} end}
	     {MyMotif getMotifVariation($)}}
	 end
      end
   in
      class MotifMixin
	 feat !MotifType:unit
	 attr motifIdentity motifVariation database
	    
	    /** %% motifIdentity and motifVariation are parameter values (FD ints), database is an instance of the class Database (see above).
	    %% If the database argument is left unset during the initialisation, you must specify it later using the method getDB.
	    %% */
	 meth initMotifMixin(motifIdentity:MI<=_
			     motifVariation:MV<=_
			     database:DB<=_)
	    @database = DB
	    @motifIdentity = {New Score.parameter init(value:MI info:motifIdentity)}
	    @motifVariation = {New Score.parameter init(value:MV info:motifVariation)}
	    {self bilinkParameters([@motifIdentity @motifVariation])}
	    {InitConstraint self}
	 end
	 
	 meth getMotifIdentity(X) X={@motifIdentity getValue($)} end
	 meth getMotifIdentityParameter(X) X=@motifIdentity end
	 meth getMotifVariation(X) X={@motifVariation getValue($)} end
	 meth getMotifVariationParameter(X) X=@motifVariation end
	 
	 /** %% Returns an instance of class Database.
	 %% */
	 meth getDB(?X) X = @database end
	 /** %% Returns the motif database (a list).
	 %% */
	 meth getMotifDescriptionDB(?X)  X = {{self getDB($)} getMotifDescriptionDB($)} end
	 /** %% Returns the constaint database (a list of binary procedures).
	 %% */
	 meth getMotifVariationDB(?X) X = {{self getDB($)} getMotifVariationDB($)} end
	 %%
%	 meth getMotifMixinAttributes(?X)
%	    X =[motifIdentity motifVariation database]
%	 end
      end
   end
   
   fun {IsMotif X}
      {Object.is X} andthen {HasFeature X MotifType}
   end
   
%    /** %% Some container of X is a motif.
%    %% */
%    fun {IsInMotif X}
%       {Some {X getContainers($)} IsMotif} 
%    end
   
   /** %% Is X contained in a motif and Test is true? Test is a boolean binary function fun {$ X MyMotif} <body> end.
   %% */
   %% !!?? generalise for container?
   fun {IsInMotif X Test}
      MyMotif = {X findContainer($ IsMotif)}
   in
      if MyMotif == nil then false
      else {Test X MyMotif}
      end
   end   

   class Sequential from Score.sequential MotifMixin
      feat label:seqMotif
      meth init(...)  = M
	 Score.sequential, {Record.subtractList M
			    [motifIdentity motifVariation database]}
	 MotifMixin, {Adjoin {GUtils.takeFeatures M
			      [motifIdentity motifVariation database]}
		      initMotifMixin}
      end
      
%       meth getAttributes(?X)
% 	 X = {Append
% 	      Score.sequential, getAttributes($)
% 	      MotifMixin, getMotifMixinAttributes($)}
%       end
%       meth toInitRecord(?X exclude:Excluded<=nil)
% 	 X = {Adjoin
% 	      Score.sequential, toInitRecord($ exclude:Excluded)
% 	      {Record.subtractList
% 	       {self makeInitRecord($ [motifIdentity#getMotifIdentity#noMatch
% 				       motifVariation#getMotifVariation#1
% 				       database#getDatabase#noMatch])}
% 	       Excluded}}
%       end
      meth getInitInfo($ exclude:Excluded)
	 unit(superclass:Score.sequential
	      args:[motifIdentity#getMotifIdentity#noMatch
		    motifVariation#getMotifVariation#noMatch
		    database#getDatabase#noMatch])
      end
      
   end

   class Simultaneous from Score.simultaneous MotifMixin
      feat simMotif
      meth init(...)  = M
	 Score.simultaneous, {Record.subtractList M
			      [motifIdentity motifVariation database]}
	 MotifMixin, {Adjoin {GUtils.takeFeatures M
			      [motifIdentity motifVariation database]}
		      initMotifMixin}
      end
%       meth getAttributes(?X)
% 	 X = {Append
% 	      Score.sequential, getAttributes($)
% 	      MotifMixin, getMotifMixinAttributes($)}
%       end
%       meth toInitRecord(?X exclude:Excluded<=nil)
% 	 X = {Adjoin
% 	      Score.sequential, toInitRecord($ exclude:Excluded)
% 	      {Record.subtractList
% 	       {self makeInitRecord($ [motifIdentity#getMotifIdentity#noMatch
% 				       motifVariation#getMotifVariation#1
% 				       database#getDatabase#noMatch])}
% 	       Excluded}}
%       end
      meth getInitInfo($ exclude:Excluded)
	 unit(superclass:Score.simultaneous
	      args:[motifIdentity#getMotifIdentity#noMatch
		    motifVariation#getMotifVariation#noMatch
		    database#getDatabase#noMatch])
      end
   end

   local
      %% DB is a tuple of records. CollectFeats returns the values of all records in DB at feature Feat in a list. In case some DB lacks Feat, then a list of FD.ints with max domain and no further applied constraints is returned (as dummy for Select.fd in Pattern.selectList). 
      fun {CollectFeats DB Feat}
	 MaxLength = {FoldL {Map DB fun {$ X}
				       if {HasFeature X Feat}
				       then {Length X.Feat}
				       else 0
				       end
				    end}
		      Max 0}
      in
	 {Map DB fun {$ X}
		    if {HasFeature X Feat}
		    then X.Feat
		    else {FD.list MaxLength 0#FD.sup}
		    end
		 end}
%	 {Map DB fun {$ X} X.Feat end}
      end
   in
      /** %% MakeVariation simplifies the definition of a motif variation procedure, while at the same time also somewhat restricting the description format given to the MotifDescriptionDB. MakeVariation expects a declarations and returns a variation procedure (expecting a motif instance and a 0/1-variable). Decl is a record, where each record feature is also a feature in the MotifDescriptionDB. Each record field value is an accessor function or method expecting a motif instance and returning a list of FD integers which corresponds with this feature (this returned list is unified with the database list at the corresponding feature). 
      %% The required motif description format (given to the MotifDescriptionDB) is as follows. Each motif description is a record with descriptive record features (e.g. durations, pitches, pitchContour). The values at these features are lists of FD integers. Entries in the MotifDescriptionDB must be uniform: they have the same features, and lists at the same MotifDescriptionDB feature have the same length.
      %% Exception: MotifDescriptionDB entries may omit features altogether (i.e. entries can effectively differ in the set of features), but in case a feature is present then its value must be a list with same length as in other entries at this feature.
      %% Exception: Decl can omit features, i.e. different variation functions can constrain different sets of features.
      %%
      %% See Motif/testing/Motif-test.oz for usage examples.
      %%
      %% NB: there can be undetermined FD ints in the solution in case motif specs in MotifDescriptionDB may differ in their set of features. 
      %% */
      fun {MakeVariation Decl}
	 proc {$ MyMotif B}
	    {Combinator.'reify'
	     proc {$}
		MotifDescriptionDB = {MyMotif getMotifDescriptionDB($)}
		MotifIdentity = {MyMotif getMotifIdentity($)}
	     in
		{Record.forAllInd Decl
		 proc {$ Feat Accessor}
		    DBValue = {CollectFeats MotifDescriptionDB Feat}
		 in
		    {{GUtils.toFun Accessor} MyMotif}
		      = {Pattern.selectList DBValue MotifIdentity}
		 end}
	     end
	     B}
	 end
      end
   end
   
end

   
