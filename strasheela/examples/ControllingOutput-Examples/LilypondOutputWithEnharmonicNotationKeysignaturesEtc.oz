
%%
%% Example with support for additional lilypond output support and
%% supporting enharmonic information.
%%
%% In the score, the info attribute of sequential containers supports
%% a record with the label lily. The VS at feature 1 of this record
%% will be inserted at beginning of this sequential. Note that nested
%% sequentials can bring in their own lilypond VS.
%%
%% Enharmonic notation can be encoded (and constrained!) in the
%% score. The note class HS.score.enharmonicNote provides the
%% parameters cMajorDegree and cMajorAccidental. The parameter
%% cMajorDegree denotes the scale degree of the note pitch is a C
%% major scale (e.g., 1 is c, 2 is d etc.), and cMajorAccidental
%% denotes an accidental. The relation between these parameters and
%% related parameters like pitchClass and pitch are constrained in the
%% expected way.  However, note that the accidental value is shifted
%% by an offset (bb is 0 by default), see the documentation of HS for
%% details.  Also note that this example only works for 12 pitches per
%% octave (i.e., not for microtonal music).
%%

declare
fun {SeqToLily Seq Clauses}
   Lily = {Seq getInfoRecord($ lily)}
in
   {Out.listToVS 
    [if Lily == nil then nil else Lily.1 end
     {Out.seqToLily Seq Clauses}]
    " "}
end
fun {NoteToLily N}
   {{Out.makeNoteToLily2
     %% create enharmonic Lily note
     unit(makePitch: fun {$ N}
			Nominal = LilyNominals.{N getCMajorDegree($)}
			Accidental = LilyAccidentals.({N getCMajorAccidental($)} + 1)
			Octave = LilyOctaves.({N getOctave($)} + 2)
		     in
			Nominal#Accidental#Octave
		     end)}
     N}
end
%% Accidentals (incoded as integers): param values of cMajorAccidental
Sharp = {HS.score.absoluteToOffsetAccidental 1}
Natural = {HS.score.absoluteToOffsetAccidental 0}
Flat = {HS.score.absoluteToOffsetAccidental ~1}
%%
LilyNominals = unit(c d e f g a b)
LilyAccidentals = unit(eses es "" is isis)
LilyOctaves = octs(",,,," ",,," ",," "," "" "'" "''" "'''" "''''")
%% 
Clauses = [ isNote#NoteToLily
	    fun {$ X}
	       {X isSequential($)} andthen {X hasThisInfo($ staff)}
	    end#fun {$ Seq}
		   "\\new Staff "#{SeqToLily Seq Clauses}
		end
	    isSequential#fun {$ Seq} {SeqToLily Seq Clauses} end ]
%%
MyScore = {Score.makeScore
	   seq(info:[lily("\\clef treble \\key d \\major \\time 3/4")
		     staff]
	       items:[seq(items:[note(duration:4
				      pitch:62
				      cMajorAccidental:Natural)
				 note(duration:1
				      pitch:64
				      cMajorAccidental:Flat)
				 note(duration:1
				      pitch:66
				      cMajorAccidental:Sharp)])
		      seq(info:lily("\\key f \\minor")
			  items:[note(duration:2
				      pitch:67
				      cMajorAccidental:Natural)
				 note(duration:2
				      pitch:61
				      cMajorAccidental:Flat)
				 note(duration:2
				      pitch:63
				      cMajorAccidental:Flat)])]
	       startTime:0
	       timeUnit:beats(2))
	   add(note:HS.score.enharmonicNote)}
%%
{Out.outputLilypond MyScore
 unit(file:'blahblah'
      clauses:Clauses)}



 
