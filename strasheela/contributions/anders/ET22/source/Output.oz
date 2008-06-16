/** %% This functor defines Lilypond output (using semitone and quartertone accidentals) and Explorer output actions for 22 ET.
%%
%% BUG: Lilypond notation problem: using grace notes (for showing chord and scale notes) seems to disable the Staff.instrumentName display. It is possible that this has to do with the missing \score at the beginning of lilypond 22 ET score data. Yet, setting this causes an error related to the \override of Score.Accidental and Score.KeySignature #'glyph-name-alist for 22 ET. For now, I leave it like this -- either I show Staff.instrumentName or scale/chord pitch classes with grace notes. If I want to publish a score with analytical information using grace notes, I will again look into this matter. 
%% */ 
functor
import
   OS Explorer
   Resolve
  Browser(browse:Browse)
   
   %% !! tmp functor until next release with debugged Path of stdlib
   Path at 'x-ozlib://anders/tmp/Path/Path.ozf'

   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'
   ET22 at '../ET22.ozf'
%   DB at 'DB.ozf'
   
export
   RenderAndShowLilypond SetEnharmonicNotationTable
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
      EnharmonicNotationTable = {NewCell unit}
      %% Using my user-def note names. 
      %%  C = c, C/ = ccu (comma up), C#\ = cscd (c sharp, comma down),  C# = cs, C\ = ccd, Cb/ = cfcu, Cb = cf
      TranslationTable = unit('C':c
			      'C/':ccu   'Db':df
			      'C#\\':cscd 'Db/':dfcu
			      'C#':cs   'D\\':dcd
			      'D':d
			      'D/':dcu   'Eb':ef
			      'D#\\':dscd 'Eb/':efcu
			      'D#':ds   'E\\':ecd
			      'E':e
			      'F':f
			      'F/':fcu   'Gb':gf
			      'F#\\':fscd 'Gb/':gfcu
			      'F#':fs   'G\\':gcd
			      'G':g
			      'G/':gcu   'Ab':af
			      'G#\\':gscd 'Ab/':afcu
			      'G#':gs   'A\\':acd
			      'A':a
			      'A/':acu   'Bb':bf
			      'A#\\':ascd 'Bb/':bfcu
			      'A#':as   'B\\':bcd
			      'B':b)
      fun {PitchnameToLily PitchName}
	 TranslationTable.PitchName
      end
   in
      /** %% The enharmonic notation for 22 ET can be customised by specifying for each numeric 22 ET pitch class how it is notated. Note that this setting will be fixed throughout the score though (e.g., pitch class 7 may be notated as 'E\\', but then it is never 'D#'). The enharmonic notation is specified by a record which maps pitch class integers to pitch names. See ET22.pc and friends for an explanation of the pitch names. The default are the default pitch names in Scala for 22 ET (using E22 notation system).
      %% Note that the lowest feature in the table is 0 (i.e., 'C') and not 1 (i.e. Table is not a tuple if all pitch classes are specified, a tuple has no feature 0).
      %% NB: an error will occur if you fail to specify a notation for a 22 ET pitch class in your scores, so Table should specify a notation for every 22 ET pitch class.
      %% */
      %% NOTE: shall I define a better default table.
      proc {SetEnharmonicNotationTable Table}
	 EnharmonicNotationTable := {Record.map Table PitchnameToLily}
      end
      fun {Et22PcToLily MyPC}
	 @EnharmonicNotationTable.MyPC
      end
      %% set default table
      {SetEnharmonicNotationTable
       unit(0:'C' 
	    1:'Db' 
	    2:'C#\\' 
	    3:'C#' 
	    4:'D' 
	    5:'Eb'
	    6:'D#\\'
	    7:'E\\'  
	    8:'E' 
	    9:'F' 
	    10:'Gb' 
	    11:'F#\\' 
	    12:'F#' 
	    13:'G'
	    14:'Ab' 
	    15:'G#\\' 
	    16:'G#' 
	    17:'A'
	    18:'Bb'  
	    19:'A#\\' 
	    20:'B\\' 
	    21:'B'  )}
   end
      
   local
   
      fun {IsEt22Note X}
	 {X isNote($)} andthen 
	 {X getPitchUnit($)} == et22
      end
      fun {IsEt22Chord X}
	 {HS.score.isChord X} andthen 
	 {{X getRootParameter($)} getUnit($)} == et22
      end
      fun {IsEt22Scale X}
	 {HS.score.isScale X} andthen 
	 {{X getRootParameter($)} getUnit($)} == et22
      end


      LilyOctaves = octs(",,,," ",,," ",," "," "" "'" "''" "'''" "''''")
      %% Transform a Pitch (an int) into the corresponding Lily code (a VS)
      fun {ET22PitchToLily MyPitch}
	 MyPC = {Int.'mod' MyPitch 22}
	 Oct = {Int.'div' MyPitch 22} + 1
      in
	 {Et22PcToLily MyPC} # LilyOctaves.Oct
      end
      
      %% Expects a Strasheela note object and returns the corresponding
      %% Lilypond code (a VS). For simplicity, this transformation does not
      %% support any expessions (e.g. fingering marks, or articulation
      %% marks). You could add these nevertheless as lily info tag.
      fun {NoteEt22ToLily MyNote}
	 {{Out.makeNoteToLily2
	   fun {$ N} {ET22PitchToLily {N getPitch($)}} end
	   fun {$ N}
	      if {HS.score.isInChordMixinForNote N}
		 andthen {N isInChord($)} == 0
	      then "^x"
	      else ""
	      end
	   end}
	  MyNote}
      end

      fun {SimTo22LilyChord Sim}
	 Items = {Sim getItems($)}
	 Pitches = {Out.listToVS
		    {Map Items
		     fun {$ N} {ET22PitchToLily {N getPitch($)}} end}
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
      
      /** %% Returns the chord comment (also works for scale). 
      %% */
      proc {MakeChordComment MyChord ?Result}
	 ChordComment = {HS.db.getInternalChordDB}.comment.{MyChord getIndex($)}
      in
	 Result = '#'('\\column {'
		      if {IsRecord ChordComment} andthen {HasFeature ChordComment comment}
		      then ChordComment.comment
		      else ChordComment
		      end
		      ' } ')
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

      %% NB: much code repetition to NoteEt22ToLily and similar definitions
      %%
      fun {ChordEt22ToLily MyChord}
	 Rhythms = {Out.lilyMakeRhythms {MyChord getDurationParameter($)}}
	 ChordDescr = {MakeChordComment MyChord}
%	 ChordDescr = {MakeChordRatios MyChord} 
	 AddedSigns = '_\\markup{'#ChordDescr#'}'
      in
	 %% if MyChord is shorter than 64th then skip it (Out.lilyMakeRhythms
	 %% then returns nil)
	 if Rhythms == nil
	 then ''
	 else  
	    MyRoot = {ET22PitchToLily {MyChord getRoot($)}}
	    MyPitches = "\\grace <"#{Out.listToVS {Map {HS.score.pcSetToSequence
							{MyChord getPitchClasses($)}
							{MyChord getRoot($)}}
						   ET22PitchToLily}
				     %% set Lily grace note duration to quarter notes (4)
				     " "}#">4 "
	    FirstChord = MyPitches#MyRoot#Rhythms.1#AddedSigns
	 in
	    if {Length Rhythms} == 1 % is tied chord?
	    then FirstChord
	       %% tied roots
	    else FirstChord#{Out.listToVS {Map Rhythms.2
					   fun {$ R} " ~ "#MyRoot#R end}
			     " "}
	    end
	 end
      end

      
      %% Notate all scale pitches as grace notes first, then indicate duration of scale by scale root only 
      fun {ScaleEt22ToLily MyScale}
	 Rhythms = {Out.lilyMakeRhythms {MyScale getDurationParameter($)}}
	 ScaleDescr = {MakeScaleComment MyScale}
	 AddedSigns = '_\\markup{'#ScaleDescr#'}'
      in
	 %% if MyChord is shorter than 64th then skip it (Out.lilyMakeRhythms
	 %% then returns nil)
	 if Rhythms == nil
	 then ''
	 else
	    MyRoot = {ET22PitchToLily {MyScale getRoot($)}}
	    MyPitches = "\\grace {"#{Out.listToVS {Map {HS.score.pcSetToSequence
							{MyScale getPitchClasses($)}
							{MyScale getRoot($)}}
						   ET22PitchToLily}
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


      %% code to insert at beginning and end of Lilypond score, defines ET notation 
      LilyHeader = {Out.readFromFile
		    {{Path.make
		      {Resolve.localize
		       'x-ozlib://anders/strasheela/ET22/source/Lilyheader.ly.data'}.1}
		     toString($)}}
      LilyFooter = "\n}"
      
   in
      /** %% Proc is like Out.renderAndShowLilypond, but provides buildin support for notes and chords with pitch units in et22.
      %% Please note that this support is defined by the argument clauses and wrapper (see Out.toLilypond) -- additional clauses are still possible, but adding new note/chord clauses will overwrite the support for 22 ET (the wrapper can be defined like for Out.renderAndShowLilypond).
      %% Also, note that convert-ly (which updates) sometimes breaks the 22 ET notation (e.g., when inserting new explicit staffs).
      %% */
      proc {RenderAndShowLilypond MyScore Args}
	 AddedClauses = [Out.isLilyChord#SimTo22LilyChord
			 IsEt22Note#NoteEt22ToLily
			 IsEt22Chord#ChordEt22ToLily
			 IsEt22Scale#ScaleEt22ToLily]
	 ET22Wrapper = [LilyHeader LilyFooter]
	 AddedArgs = unit(wrapper:if {HasFeature Args wrapper}
				  then [H T] = Args.wrapper in 
				     [H#ET22Wrapper.1 T]
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
