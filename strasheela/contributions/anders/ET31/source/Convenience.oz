
/** %% This functor provides some procedures for conveniently testing intervals and chords in just intonation (JI) and 31 ET. 
%% */

functor
import
   MUtils at 'x-ozlib://anders/strasheela/source/MusicUtils.ozf'
   LUtils at 'x-ozlib://anders/strasheela/source/ListUtils.ozf'
   Score at 'x-ozlib://anders/strasheela/source/ScoreCore.ozf'
   Out at 'x-ozlib://anders/strasheela/source/Output.ozf'
%   HS at 'x-ozlib://anders/strasheela/HarmonisedScore/HarmonisedScore.ozf'

   ET31 at '../ET31.ozf'
   
export
   
   SetOffset SetDuration
   PlayRChord PlayPCs PlayNames
   
define

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% quick chord playback 
%%% 
%%%
%%%   

   NoteDur = {NewCell 10000}			% in msecs
   NoteOffset = {NewCell 0}			% in msecs
   TimeUnit = msecs

   /** %% Changes globally the offset time between notes (an int, default is 0), so an arpeggio can be perceived. If global Offset = global Duration, then notes don't overlap. 
   %% */
   proc {SetOffset B} NoteOffset := B end
   /* %% Globally sets note duration: Dur is duration in msecs (an int).
   %% */
   proc {SetDuration Dur} NoteDur := Dur end
   
   /** %% Transforms ratios in VS for filename. A list of ratios is notated like 1o1-3o2-5o4
   %% */
   fun {MakeRatiosFileName Ratios}
      {Out.listToVS {Map Ratios fun {$ X#Y} X#o#Y end}
       "-"}
   end
   /** %% Transforms PCs or note names in VS for filename.
   %% */
   fun {MakeFileName PCs}
      {Out.listToVS PCs "-"}
   end
   /** %% Expects pitches in millimidicent
   %% */
   proc {PlayMMidiCentScore Pitches File}
      Offsets = {Map {LUtils.arithmeticSeries 0.0
		      {IntToFloat @NoteOffset} {Length Pitches}}
		 FloatToInt}
      MyScore = {Score.makeScore
		 sim(items:{Map {LUtils.matTrans [Pitches Offsets]}
			    fun {$ [Pitch Offset]}
			       note(offsetTime:Offset
				    duration:@NoteDur
				    pitch:Pitch
				    pitchUnit:millimidicent
				    amplitude:64)
			    end}
		     startTime:0
		     timeUnit:TimeUnit)
		 unit}
   in
      {MyScore wait}
      {Out.renderAndPlayCsound MyScore
       unit(file:File)}
   end
   
   /** %% Play list of Ratios (list of int pairs) in millicent precision using Csound. 1#1 denotes middle C.
   %% Note that the resulting chord is rendered in just intonation -- in contrast to the output of, e.g., PlayPCs and PlayNames. 
   %% Duration specified globally (10 secs, int in msecs).
   %% */
   %%
   %% NOTE: there is beating in the output, how??
   proc {PlayRChord Ratios}
      {PlayMMidiCentScore
       {Map Ratios fun {$ R}
		      OneOverOne = 600000.0 % middle C
		   in
		      {FloatToInt {MUtils.ratioToKeynumInterval R
				   120000.0} + OneOverOne}
		   end}
       {MakeRatiosFileName Ratios}}
   end
   /** %% Plays 31 ET pitch class lists using Csound. 0 denotes middle C.
   %% Duration specified globally (10 secs, int in msecs).
   %% */
   proc {PlayPCs PCs}
      {PlayMMidiCentScore
       {Map PCs fun {$ PC}
		   OneOverOne = 600000.0 % middle C
		in
		   {FloatToInt
		    {IntToFloat PC} * 12.0 / 31.0  % transforms in MIDI
		    * 10000.0			   % in millimidicent
		    + OneOverOne}			   % PC -> pitch
		end}
       {MakeFileName PCs}}
   end
   
   /** %% Plays symbolic note names expressing 31 ET pitch class lists using Csound. 0 denotes middle C.
   %% Duration specified globally (10 secs, int in msecs).
   %% */
   proc {PlayNames Names}
      {PlayMMidiCentScore
       {Map Names fun {$ Name}
		     OneOverOne = 600000.0 % middle C
		  in
		     {FloatToInt
		      {IntToFloat {ET31.pc Name}} * 12.0 / 31.0  % transforms in MIDI
		      * 10000.0			   % in millimidicent
		      + OneOverOne}			   % PC -> pitch
		  end}
       {MakeFileName Names}}
   end
   
end

