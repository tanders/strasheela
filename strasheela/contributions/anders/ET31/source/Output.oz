/** %% This functor defines Lilypond output (using semitone and quartertone accidentals) and Explorer output actions for 31 ET.
%% */ 
functor
import
   OS FS Explorer
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   ET31 at '../ET31.ozf'
   DB at 'DB.ozf'
   
export
   RenderAndShowLilypond
   AddExplorerOut_ChordsToScore
   
define

   %%
   %% Explorer Output
   %%

%    %% generate seed from date
%    {OS.srand 0}
%    %% today (6 Jan 2006, 12:30) first rand always around 1480000000 (but
%    %% random). So, I further randomise here.
%    {OS.srand {OS.rand}}

   /** %% Creates an Explorer output. The script solution must be a sequential container with chord objects (i.e. without the actual notes).
   %% The Explorer output action creates a CSP with expects a chord sequence and returns a homophonic chord progression. AddExplorerOut_ChordsToScore internally uses ET31.score.chordsToScore for this purpose.  
   %% The result is transformed into music notation (with Lilypond), sound (with Csound), and Strasheela code (archived score objects).
   %% Args are outname and the arguments of ET31.score.chordsToScore. the outname arg sets the output file name (which gets added the space number in the Explorer and then a random number). outname also sets the name under which this action appears in the Explorer menu.
   %%
   %% IMPORTANT: ET31.score.chordsToScore conducts a search which potentially can fail (e.g., if insufficient arguments are provided)!
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
			     MyScore = {ET31.score.chordsToScore
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
				   prefix:"declare \n [ET31] = {ModuleLink ['x-ozlib://anders/strasheela/ET31/ET31.ozf']} \n {HS.db.setDB ET31.db.fullDB}\n ChordSeq \n = {Score.makeScore\n")}
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
   %% Lilypond output for 31 ET
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
   %% and Measure, ET31 etc. in a way that these clauses can be easily
   %% combined.
   %% How about multiple clauses for, say, a plain note object..
   %%
   %%
   %% BUG: 'Ab' is shown as 1/1 and 'C' as 5/4
   %% Anyway, better show chord names...
   %% ?? Really bug? Some chords have silent root below pitches, but ratio factor should not be root in that case.
   %%
   
   local
      /** %% Transforms the pitch class MyPC into a ratio VS. Alternative ratio transformations are given (written like 1/2|1/3). If no transformation existists, 'n/a' is output.
      %% NB: transformation uses the interval specs defined for 31 ET, but because as a temperament just intonation intervals are [ambigious] the returned ratio may be missleading.. 
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
   
      fun {IsEt31Note X}
	 {X isNote($)} andthen 
	 {X getPitchUnit($)} == et31
      end
      fun {IsEt31Chord X}
	 {HS.score.isChord X} andthen 
	 {{X getRootParameter($)} getUnit($)} == et31
      end
      fun {IsEt31Scale X}
	 {HS.score.isScale X} andthen 
	 {{X getRootParameter($)} getUnit($)} == et31
      end

      %% using semitone and quartertone accidentals 
      LilyEt31PCs = pcs(c cih cis des deh 
			d dih 'dis' es eeh
			e eih eis
			f fih fis ges geh
			g gih gis aes aeh
			a aih ais bes beh
			b bih bis)
      %% using semitone and double accidental
      %% This 31-tone equal temperament pitch class mapping follows
      %% http://www.tonalsoft.com/enc/number/31edo.aspx
      %%
%       LilyEt31PCs = pcs(c deses cis des cisis
% 			d eses 'dis' es disis
% 			e fes eis
% 			f geses fis ges fisis
% 			g aeses gis aes gisis
% 			a beses ais bes aisis
% 			b ces bis)
      LilyOctaves = octs(",,,," ",,," ",," "," "" "'" "''" "'''" "''''")
      %% Transform a Pitch (an int) into the corresponding Lily code (a VS)
      fun {ET31PitchToLily MyPitch}
	 MyPC = {Int.'mod' MyPitch 31} + 1
	 Oct = {Int.'div' MyPitch 31} + 1
      in
	 LilyEt31PCs.MyPC # LilyOctaves.Oct
      end

      %% Expects a Strasheela note object and returns the corresponding
      %% Lilypond code (a VS). For simplicity, this transformation does not
      %% support any expessions (e.g. fingering marks, or articulation
      %% marks).
      fun {NoteEt31ToLily MyNote}
	 {{Out.makeNoteToLily2
	   fun {$ N} {ET31PitchToLily {N getPitch($)}} end
	   fun {$ N}
	      if {HS.score.isInChordMixinForNote N}
		 andthen {N isInChord($)} == 0
	      then "^x"
	      else ""
	      end
	   end}
	  MyNote}
      end

      
      fun {SimTo31LilyChord Sim}
	 Items = {Sim getItems($)}
	 Pitches = {Out.listToVS
		    {Map Items
		     fun {$ N} {ET31PitchToLily {N getPitch($)}} end}
		    " "}
	 Rhythms = {Out.lilyMakeRhythms
		    {Items.1 getDurationParameter($)}}
	 FirstChord = {Out.getUserLily Sim}#"\n <"#Pitches#">"#Rhythms.1
      in
	 if {Length Rhythms} == 1
	 then FirstChord
	 else FirstChord#{Out.listToVS
			  {Map Rhythms.2
			   fun {$ R} " ~ <"#Pitches#">"#R end}
			  " "}
	 end
      end


%       /** %% Returns the chord comment.
%       %% */
%       proc {MakeChordComment MyChord ?Result}
% 	 ChordComment = {HS.db.getInternalChordDB}.comment.{MyChord getIndex($)}
%       in
% 	 Result = '#'('\\column { '
% 		      if {IsRecord ChordComment} andthen {HasFeature ChordComment comment}
% 		      then ChordComment.comment
% 		      else ChordComment
% 		      end
% 		      ' } ')
% 	 %% 
% 	 if {Not {IsVirtualString Result}}
% 	 then raise noVS(Result) end
% 	 end
%       end
      /* %% Returns the chord as ratio spec: Transposition x untransposed PCs (a VS).
      %% */
      proc {MakeChordRatios MyChord ?Result}
	 Result = '#'('\\column { '
		      {PC2RatioVS {MyChord getTransposition($)}}
		      ' x ('
		      {Out.listToVS {Map {FS.reflect.lowerBoundList
					  {MyChord getUntransposedPitchClasses($)}}
				     PC2RatioVS}
		       ' '}
		      ') }')
	 %% 
	 if {Not {IsVirtualString Result}}
	 then raise noVS(Result) end
	 end
      end
      /** %% Returns the scale comment. 
      %% */
      proc {MakeScaleComment MyScale ?Result}
	 ScaleComment = {HS.db.getInternalScaleDB}.comment.{MyScale getIndex($)}
      in
	 Result = '#'('\\column {'
		      if {IsRecord ScaleComment} andthen {HasFeature ScaleComment comment}
		      then ScaleComment.comment
		      else ScaleComment
		      end
		      ' } ')
	 %% 
	 if {Not {IsVirtualString Result}}
	 then raise noVS(Result) end
	 end
      end

      %% NB: much code repetition to NoteEt31ToLily and similar definitions
      %%
      fun {ChordEt31ToLily MyChord}
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
	    MyRoot = {ET31PitchToLily {MyChord getRoot($)}}
	    MyPitches = "\\grace {"#{Out.listToVS {Map {HS.score.pcSetToSequence
						       {MyChord getPitchClasses($)}
						       {MyChord getRoot($)}}
						   ET31PitchToLily}
				     %% set Lily grace note duration to quarter notes (4)
				     "4 "}#"} "
	    FirstChord = MyPitches#MyRoot#Rhythms.1#AddedSigns
	 in
	    if {Length Rhythms} == 1 % is tied chord?
	    then FirstChord
	       %% tied chord
	    else FirstChord#{Out.listToVS {Map Rhythms.2
					   fun {$ R} " ~ "#MyRoot#R end}
			     " "}
	    end
	 end
      end

      
      %% Notate all scale pitches as grace notes first, then indicate duration of scale by scale root only 
      fun {ScaleEt31ToLily MyScale}
	 Rhythms = {Out.lilyMakeRhythms {MyScale getDurationParameter($)}}
	 ScaleDescr = {MakeScaleComment MyScale}
	 AddedSigns = '_\\markup{'#ScaleDescr#'}'
      in
	 %% if MyChord is shorter than 64th then skip it (Out.lilyMakeRhythms
	 %% then returns nil)
	 if Rhythms == nil
	 then ''
	 else
	    MyRoot = {ET31PitchToLily {MyScale getRoot($)}}
	    MyPitches = "\\grace {"#{Out.listToVS {Map {HS.score.pcSetToSequence
						       {MyScale getPitchClasses($)}
						       {MyScale getRoot($)}}
						   ET31PitchToLily}
				     %% set Lily grace note duration to 4
				     "4 "}#"} "
	    FirstScale = MyPitches#MyRoot#Rhythms.1#AddedSigns
	 in
	    if {Length Rhythms} == 1 % is tied scale?
	    then FirstScale
	       %% tied scale
	    else FirstScale#{Out.listToVS {Map Rhythms.2
					   fun {$ R} " ~ "#MyRoot#R end}
			     " "}
	    end
	 end
      end


   in
      /** %% Proc is like Out.renderAndShowLilypond, but provides buildin support for notes and chords with pitch units in et31.
      %% Please note that this support is defined by the argument Clauses (see Out.renderAndShowLilypond) -- additional clauses are still possible, but adding new note/chord clauses will overwrite the support for 31 ET.
      %% */
      proc {RenderAndShowLilypond MyScore Args}
	 AddedClauses = [Out.isLilyChord#SimTo31LilyChord
			 IsEt31Note#NoteEt31ToLily
			 IsEt31Chord#ChordEt31ToLily
			 IsEt31Scale#ScaleEt31ToLily]
	 AddedArgs = unit(clauses:if {HasFeature Args clauses}
				  then {Append Args.clauses AddedClauses}
				  else AddedClauses
				  end)
	 As = {Adjoin Args AddedArgs}
      in
	 {Out.renderAndShowLilypond MyScore As}
      end
   end
   
end
