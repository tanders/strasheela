%%% created by Strasheela at 16:31, 14-6-2008

\version "2.10.0"

\header {
  title = "A 22-Tone Equal Temperament Notation"
}

\layout {
    \context {
      \Score
      \override SpacingSpanner
                #'base-shortest-duration = #(ly:make-moment 1 32)
    }
  }
% \paper {
% }
% \layout {  
% }

% Define 22 ET pitches simply as 1/6 tone alterations...
#(define-public Comma 1/6)
#(define-public SharpMinusComma 1/3)
#(define-public Sharp 1/2)


% Define pitch names: C = c, C/ = cu (comma up), C#\ = cscd (c sharp, comma down),  C# = cs, C\ = ccd, Cb/ = cfcu, Cb = cf

etTwentytwoPitchNames = #`(
  (c . ,(ly:make-pitch -1 0 NATURAL))
  (d . ,(ly:make-pitch -1 1 NATURAL))
  (e . ,(ly:make-pitch -1 2 NATURAL))
  (f . ,(ly:make-pitch -1 3 NATURAL))
  (g . ,(ly:make-pitch -1 4 NATURAL))
  (a . ,(ly:make-pitch -1 5 NATURAL))
  (b . ,(ly:make-pitch -1 6 NATURAL))
  
  (ccu . ,(ly:make-pitch -1 0 Comma))
  (dcu . ,(ly:make-pitch -1 1 Comma))
  (ecu . ,(ly:make-pitch -1 2 Comma))
  (fcu . ,(ly:make-pitch -1 3 Comma))
  (gcu . ,(ly:make-pitch -1 4 Comma))
  (acu . ,(ly:make-pitch -1 5 Comma))
  (bcu . ,(ly:make-pitch -1 6 Comma))

  (cscd . ,(ly:make-pitch -1 0 SharpMinusComma))
  (dscd . ,(ly:make-pitch -1 1 SharpMinusComma))
  (escd . ,(ly:make-pitch -1 2 SharpMinusComma))
  (fscd . ,(ly:make-pitch -1 3 SharpMinusComma))
  (gscd . ,(ly:make-pitch -1 4 SharpMinusComma))
  (ascd . ,(ly:make-pitch -1 5 SharpMinusComma))
  (bscd . ,(ly:make-pitch -1 6 SharpMinusComma))

  (cs . ,(ly:make-pitch -1 0 Sharp))
  (ds . ,(ly:make-pitch -1 1 Sharp))
  (es . ,(ly:make-pitch -1 2 Sharp))
  (fs . ,(ly:make-pitch -1 3 Sharp))
  (gs . ,(ly:make-pitch -1 4 Sharp))
  (as . ,(ly:make-pitch -1 5 Sharp))
  (bs . ,(ly:make-pitch -1 6 Sharp))


  (ccd . ,(ly:make-pitch -1 0 (- Comma)))
  (dcd . ,(ly:make-pitch -1 1 (- Comma)))
  (ecd . ,(ly:make-pitch -1 2 (- Comma)))
  (fcd . ,(ly:make-pitch -1 3 (- Comma)))
  (gcd . ,(ly:make-pitch -1 4 (- Comma)))
  (acd . ,(ly:make-pitch -1 5 (- Comma)))
  (bcd . ,(ly:make-pitch -1 6 (- Comma)))
  
  (cfcu . ,(ly:make-pitch -1 0 (- SharpMinusComma)))
  (dfcu . ,(ly:make-pitch -1 1 (- SharpMinusComma)))
  (efcu . ,(ly:make-pitch -1 2 (- SharpMinusComma)))
  (ffcu . ,(ly:make-pitch -1 3 (- SharpMinusComma)))
  (gfcu . ,(ly:make-pitch -1 4 (- SharpMinusComma)))
  (afcu . ,(ly:make-pitch -1 5 (- SharpMinusComma)))
  (bfcu . ,(ly:make-pitch -1 6 (- SharpMinusComma)))

  (cf . ,(ly:make-pitch -1 0 (- Sharp)))
  (df . ,(ly:make-pitch -1 1 (- Sharp)))
  (ef . ,(ly:make-pitch -1 2 (- Sharp)))
  (ff . ,(ly:make-pitch -1 3 (- Sharp)))
  (gf . ,(ly:make-pitch -1 4 (- Sharp)))
  (af . ,(ly:make-pitch -1 5 (- Sharp)))
  (bf . ,(ly:make-pitch -1 6 (- Sharp)))

)

%% set pitch names.
pitchnames = \etTwentytwoPitchNames 
#(ly:parser-set-note-names parser etTwentytwoPitchNames)


% etTwentytwoGlyphs = #'((1 . "accidentals.doublesharp")
%        (1/2 . "accidentals.sharp")
%        (1/3 . "accidentals.sharp.slashslashslash.stem")
%        (1/6 . "accidentals.rightparen")
%        (0 . "accidentals.natural")
%        (-1/6 . "accidentals.leftparen")
%        (-1/3 . "accidentals.flat.slash")
%        (-1/2 . "accidentals.flat")
%        (-1 . "accidentals.flatflat")
%        )

% etTwentytwoGlyphs = #'((1 . "accidentals.doublesharp")
%        (1/2 . "accidentals.sharp")
%        (1/3 . "accidentals.sharp.slashslashslash.stem")
%        (1/6 . "arrowheads.open.11")
%        (0 . "accidentals.natural")
%        (-1/6 . "arrowheads.open.1M1")
%        (-1/3 . "accidentals.flat.slash")
%        (-1/2 . "accidentals.flat")
%        (-1 . "accidentals.flatflat")
%        )

etTwentytwoGlyphs = #'((1 . "accidentals.doublesharp")
       (1/2 . "accidentals.sharp")
       (1/3 . "accidentals.sharp.slashslash.stem")
       (1/6 . "arrowheads.open.01")
       (0 . "accidentals.natural")
       (-1/6 . "arrowheads.open.0M1")
       (-1/3 . "accidentals.mirroredflat")
       (-1/2 . "accidentals.flat")
       (-1 . "accidentals.flatflat")
       )


\markuplines {
  \justified-lines {
    This example demonstrates a notation for 22-tone equal temperament (22-ET, see http://en.wikipedia.org/wiki/22_equal_temperament). This notation is not optimal, but it is the best I managed to do with Lilypond so far :)
  }
  \justified-lines {

  }
  
  \justified-lines {
    The accidentals have the following meaning. See a description of 22-ET for more details. 
  }
  \justified-lines {
    { \musicglyph #"arrowheads.open.01" } / { \musicglyph #"arrowheads.open.0M1" }: raise/flatten by 1 step (quarter-tone, 54.55 cent)
  }
  \justified-lines {
    { \musicglyph #"accidentals.sharp.slashslash.stem" } / { \musicglyph #"accidentals.mirroredflat" }: raise/flatten by 2 steps (diatonic semitone, 109.09 cent)
  }
  \justified-lines {
    { \musicglyph #"accidentals.sharp" } / { \musicglyph #"accidentals.flat" }: raise/flatten by 3 steps (minor whole tone, 163.63 cent)
  }

  \justified-lines {
    
  }
  \justified-lines {
    The following example notates the full 22-tone scale, each bar contains enharmonic equivalents.  
  }
}


{ 
\override Score.Accidental #'glyph-name-alist =  \etTwentytwoGlyphs

\override Score.KeySignature #'glyph-name-alist = \etTwentytwoGlyphs

% test
% \relative { c4 ccu cscd cs d dcd dfcu df c }
% }




 \new Staff 
{ \clef violin  
  \relative 
  { \cadenzaOn

    #(set-accidental-style 'forget)
%    \set Staff.extraNatural = ##t % has no effect
   
   c4 \bar "|" ccu df \bar "|" cscd dfcu \bar "|" cs dcd \bar "|" 
   d \bar "|" dcu ef \bar "|" dscd efcu \bar "|" ds ecd \bar "|" 
   e \bar "|" 
   f \bar "|" fcu gf \bar "|" fscd gfcu \bar "|" fs gcd \bar "|"
   g \bar "|" gcu af \bar "|" gscd afcu \bar "|" gs acd \bar "|" 
   a \bar "|" acu bf \bar "|" ascd bfcu \bar "|" as bcd \bar "|" 
   b \bar "||" 
   
 }
}
}