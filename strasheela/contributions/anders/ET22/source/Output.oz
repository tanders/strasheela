/** %% This functor defines Lilypond output (using semitone and quartertone accidentals) and Explorer output actions for 22 ET.
%% */ 
functor
import
   OS FS Explorer
   Resolve
   
   %% !! tmp functor until next release with debugged Path of stdlib
   Path at 'x-ozlib://anders/tmp/Path/Path.ozf'

   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   ET22 at '../ET22.ozf'
   DB at 'DB.ozf'
   
export
   RenderAndShowLilypond
   AddExplorerOut_ChordsToScore
   
define

   %%
   %% Explorer Output
   %%

   /** %% Creates an Explorer output. The script solution must be a sequential container with chord objects (i.e. without the actual notes).
   %% The Explorer output action creates a CSP with expects a chord sequence and returns a homophonic chord progression. AddExplorerOut_ChordsToScore internally uses ET22.score.chordsToScore for this purpose.  
   %% The result is transformed into music notation (with Lilypond), sound (with Csound), and Strasheela code (archived score objects).
   %% Args are outname and the arguments of ET22.score.chordsToScore. the outname arg sets the output file name (which gets added the space number in the Explorer and then a random number). outname also sets the name under which this action appears in the Explorer menu.
   %%
   %% IMPORTANT: ET22.score.chordsToScore conducts a search which potentially can fail (e.g., if insufficient arguments are provided)!
   %% */
   %%
   %% 
   %% render from within the explorer
   %%
   %% OLD: Dir is output directory.
   proc {AddExplorerOut_ChordsToScore Args}
      Defaults = unit(outname:out)
      As = {Adjoin Defaults Args}
   in
      {Explorer.object
       add(information proc {$ I X}
			  FileName = As.outname#"-"#I#"-"#{OS.rand}
		       in
			  if {Score.isScoreObject X}
			  then
			     MyScore = {ET22.score.chordsToScore
					{Map {X collect($ test:HS.score.isChord)}
					 fun {$ C}
					    %% timeUnit is not exported by toInitRecord,
					    %% and ignore sopranoChordDegree
					    {Adjoin {Record.subtract {C toInitRecord($)}
						     sopranoChordDegree}
					     chord(timeUnit:{C getTimeUnit($)})}
					 end}
					As}
			  in
			     %% Lily
			     {RenderAndShowLilypond MyScore
			      unit(file:FileName
				% dir:Dir
				  )}
			     %% Csound output of score
			     {Out.renderAndPlayCsound MyScore
			      unit(file:FileName
				% dir:Dir
				  )}
			     %% Archive output
			     {Out.outputScoreConstructor X
			      unit(file:FileName
				% dir:Dir
				   prefix:"declare \n [ET22] = {ModuleLink ['x-ozlib://anders/strasheela/ET22/ET22.ozf']} \n {HS.db.setDB ET22.db.fullDB}\n ChordSeq \n = {Score.makeScore\n")}
			  end
		       end
	   label: As.outname)}
   end
% /** %% Creates an Explorer output, which writes textual representation of the solution to a file.
% %% OutName sets the output file name (which gets an index added) and also the name under which it appears in the Explorer menu.
% %% */
% proc {AddExplorerOutArchiveChords OutName}
%    {Explorer.object
%     add(information proc {$ I X}
% 		       if {Score.isScoreObject X}
% 		       then 
% 			  FileName = OutName#{GUtils.getCounterAndIncr}
% 		       in
			  
% 		       end
% 		    end
% 	label: OutName#" (archive)")}
% end

    
   %%
   %% Lilypond output for 22 ET
   %%
   %% TODO:
   %%
   %%  - chord: make ratio printing optional (use def MakeChordRatios)
   %%  - chord: make name/comment printing optional (use def MakeChordComment)
   %%  - chord: print root, bass note, (soprano?), (all pitch classes?)
   %%  
   %%
   %% DECIDE:
   %%
   %% Principal Problem: how can I make Lilypond output customisation
   %% better re-usable? Can I export suitable Lily output clauses from
   %% the various Strasheela contributions/extensions such as HS, CTT,
   %% and Measure, ET22 etc. in a way that these clauses can be easily
   %% combined.
   %% How about multiple clauses for, say, a plain note object..
   %%
   
   local
      /** %% Transforms the pitch class MyPC into a ratio VS. Alternative ratio transformations are given (written like 1/2|1/3). If no transformation existists, 'n/a' is output.
      %% NB: transformation uses the interval specs defined for 22 ET, but because as a temperament just intonation intervals are [ambigious] the returned ratio may be missleading.. 
      %% */
      fun {PC2RatioVS MyPC}
	 IntervalDB = DB.fullDB.intervalDB
	 fun {PrettyRatios Rs}
	    %% alternative ratio transformations written as 1/2|1/3
	    {Out.listToVS
	     {Map Rs fun {$ Nom#Den} Nom#'/'#Den end}
	     '|'}
	 end
	 Ratios = {HS.db.pc2Ratios MyPC IntervalDB}
      in
	 if Ratios == nil
	 then 'n/a'
	 else {PrettyRatios Ratios}
	 end
      end
   
      fun {IsEt22Note X}
	 {X isNote($)} andthen 
	 {X getPitchUnit($)} == et22
      end
      fun {IsEt22Chord X}
	 {HS.score.isChord X} andthen 
	 {{X getRootParameter($)} getUnit($)} == et22
      end

      %% Using my user-def note names. 
      %%  C = c, C/ = cu (comma up), C#\ = cscd (c sharp, comma down),  C# = cs, C\ = ccd, Cb/ = cfcu, Cb = cf
      %% NOTE: no enharmonic notation for now
      LilyEt22PCs = pcs(c ccu cscd cs
			d dcu dscd ds
			e
			f fcu fscd fs
			g gcu gscd gs
			a acu ascd as
			b)
      LilyOctaves = octs(",,,," ",,," ",," "," "" "'" "''" "'''" "''''")
      %% Transform a Pitch (an int) into the corresponding Lily code (a VS)
      fun {ET22PitchToLily MyPitch}
	 MyPC = {Int.'mod' MyPitch 22} + 1
	 Oct = {Int.'div' MyPitch 22} + 1
      in
	 LilyEt22PCs.MyPC # LilyOctaves.Oct
      end
      
      %% Expects a Strasheela note object and returns the corresponding
      %% Lilypond code (a VS). For simplicity, this transformation does not
      %% support any expessions (e.g. fingering marks, or articulation
      %% marks).
      fun {NoteEt22ToLily MyNote}
	 {{Out.makeNoteToLily2
	   fun {$ N} {ET22PitchToLily {N getPitch($)}} end
	   fun {$ _} nil end}
	  MyNote}
      end
      
      /** %% Returns the chord comment.
      %% */
      proc {MakeChordComment MyChord ?Result}
	 ChordComment = {HS.db.getInternalChordDB}.comment.{MyChord getIndex($)}
      in
	 Result = '#'('\\column < '
		      if {IsRecord ChordComment} andthen {HasFeature ChordComment comment}
		      then ChordComment.comment
		      else ChordComment
		      end
		      ' > ')
	 %% 
	 if {Not {IsVirtualString Result}}
	 then raise noVS(Result) end
	 end
      end
      /* %% Returns the chord as ratio spec: Transposition x untransposed PCs (a VS).
      %% */
      proc {MakeChordRatios MyChord ?Result}
	 Result = '#'('\\column < '
		      {PC2RatioVS {MyChord getTransposition($)}}
		      ' x ('
		      {Out.listToVS {Map {FS.reflect.lowerBoundList
					  {MyChord getUntransposedPitchClasses($)}}
				     PC2RatioVS}
		       ' '}
		      ') >')
	 %% 
	 if {Not {IsVirtualString Result}}
	 then raise noVS(Result) end
	 end
      end

      %% NB: much code repetition to NoteEt22ToLily and similar definitions
      %%
      fun {ChordEt22ToLily MyChord}
	 Rhythms = {Out.lilyMakeRhythms {MyChord getDurationParameter($)}}
%	 ChordDescr = {MakeChordComment MyChord}
	 ChordDescr = {MakeChordRatios MyChord} 
	 AddedSigns = '_\\markup{'#ChordDescr#'}'
      in
	 %% if MyChord is shorter than 64th then skip it (Out.lilyMakeRhythms
	 %% then returns nil)
	 if Rhythms == nil
	 then ''
	 else  
	    MyPitch = {ET22PitchToLily {MyChord getRoot($)}}
	    FirstChord = MyPitch#Rhythms.1#AddedSigns
	 in
	    if {Length Rhythms} == 1 % is tied chord?
	    then FirstChord
	       %% tied chord
	    else FirstChord#{Out.listToVS {Map Rhythms.2
					   fun {$ R} " ~ "#MyPitch#R end}
			     " "}
	    end
	 end
      end

      %% code to insert at beginning and end of Lilypond score, defines ET notation 
      LilyHeader = {Out.readFromFile
		    {{Path.make
		      {Resolve.localize
		       'x-ozlib://anders/strasheela/ET22/source/Lilyheader.ly'}.1}
		     toString($)}}
      LilyFooter = "\n}"
      
   in
      /** %% Proc is like Out.renderAndShowLilypond, but provides buildin support for notes and chords with pitch units in et22.
      %% Please note that this support is defined by the argument clauses and wrapper (see Out.toLilypond) -- additional clauses are still possible, but adding new note/chord clauses will overwrite the support for 22 ET.
      %% Also, note that convert-ly (which updates) sometimes breaks the 22 ET notation (e.g., when inserting new explicit staffs).
      %% */
      proc {RenderAndShowLilypond MyScore Args}
	 AddedClauses = [IsEt22Note#NoteEt22ToLily
			 IsEt22Chord#ChordEt22ToLily]
	 ET22Wrapper = [LilyHeader LilyFooter]
	 AddedArgs = unit(wrapper:if {HasFeature Args wrapper}
				  then [H T] = Args.wrapper in 
				     [ET22Wrapper.1#H T]
				  else ET22Wrapper
				  end
			  clauses:if {HasFeature Args clauses}
				  then {Append Args.clauses AddedClauses}
				  else AddedClauses
				  end)
	 As = {Adjoin Args AddedArgs}
      in
	 {Out.renderAndShowLilypond MyScore As}
      end
   end
   
end
