%%% created by Strasheela at 19:43, 14-6-2008

\version "2.10.0"

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

{ 
\override Score.Accidental #'glyph-name-alist =  \etTwentytwoGlyphs

\override Score.KeySignature #'glyph-name-alist = \etTwentytwoGlyphs

% test
% \relative { c4 ccu cscd cs d dcd dfcu df c }
% }


 
 <<   
 \new Staff { \clef violin  
 {
  
 <c c' ecd' g'>1 
 <c c' efcu' g'>1 
 <c c' efcu' fscd'>1 
 <c c' ef' fscd'>1 
 <c c' ecd' af'>1 
 <c c' ef' g'>1 
 <c c' e' g'>1 
 <c c' ecd' bf'>1 
 <c c' ecd' g' bcd'>1 
 <c c' efcu' g' bfcu'>1 
 <c c' ecd' g' acd'>1 
 <c c' efcu' fscd' a'>1 
 <c c' ef' fscd' acd'>1 
 <c c' ecd' fscd' bf'>1 
 <c c' ecd' g' bf'>1 
 <c c' efcu' g' a'>1 
 <c c' ef' fscd' bf'>1 
 <c c' ef' g' acd'>1 
 <c c' e' fscd' a'>1 
 <c c' d' ecd' g' bf'>1 
 <c c' d' e' g' bfcu'>1 
 <c c' ef' g' bf'>1 
 <c c' e' g' a'>1 
 <c c' f' g' bf'>1 
 <c c' d' g' a'>1 
 <c c' d' g' bf'>1 
 <c c' f' g' a'>1 
 <c c' ef' ecd' g' bf'>1 
 <c c' d' efcu' g' a'>1 
 <c c' d' ecd' g' a'>1 
} } 
 \new Staff { \clef "bass_29"  
 {
  \grace <c,,,, ecd,,,, g,,,,>4 c,,,,1_\markup{\column {major } } \grace <c,,,, efcu,,,, g,,,,>4 c,,,,1_\markup{\column {minor } } \grace <c,,,, efcu,,,, fscd,,,,>4 c,,,,1_\markup{\column {otonal subdiminished } } \grace <c,,,, ef,,,, fscd,,,,>4 c,,,,1_\markup{\column {utonal subdiminished } } \grace <c,,,, ecd,,,, af,,,,>4 c,,,,1_\markup{\column {augmented } } \grace <c,,,, ef,,,, g,,,,>4 c,,,,1_\markup{\column {subminor } } \grace <c,,,, e,,,, g,,,,>4 c,,,,1_\markup{\column {supermajor } } \grace <c,,,, ecd,,,, bf,,,,>4 c,,,,1_\markup{\column {harmonic 7th no 5 } } \grace <c,,,, ecd,,,, g,,,, bcd,,,,>4 c,,,,1_\markup{\column {major 7th } } \grace <c,,,, efcu,,,, g,,,, bfcu,,,,>4 c,,,,1_\markup{\column {minor 7th } } \grace <c,,,, ecd,,,, g,,,, acd,,,,>4 c,,,,1_\markup{\column {minor 6th } } \grace <c,,,, efcu,,,, fscd,,,, a,,,,>4 c,,,,1_\markup{\column {subdiminished 7th (1) } } \grace <c,,,, ef,,,, fscd,,,, acd,,,,>4 c,,,,1_\markup{\column {subdiminished 7th (2) } } \grace <c,,,, ecd,,,, fscd,,,, bf,,,,>4 c,,,,1_\markup{\column {French augmented 6th } } \grace <c,,,, ecd,,,, g,,,, bf,,,,>4 c,,,,1_\markup{\column {harmonic 7th } } \grace <c,,,, efcu,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column {subharmonic 6th } } \grace <c,,,, ef,,,, fscd,,,, bf,,,,>4 c,,,,1_\markup{\column {half subdiminished 7th } } \grace <c,,,, ef,,,, g,,,, acd,,,,>4 c,,,,1_\markup{\column {subminor major 6th } } \grace <c,,,, e,,,, fscd,,,, a,,,,>4 c,,,,1_\markup{\column {supermajor minor 7th } } \grace <c,,,, d,,,, ecd,,,, g,,,, bf,,,,>4 c,,,,1_\markup{\column {harmonic 9th } } \grace <c,,,, d,,,, e,,,, g,,,, bfcu,,,,>4 c,,,,1_\markup{\column {subharmonic 9th } } \grace <c,,,, ef,,,, g,,,, bf,,,,>4 c,,,,1_\markup{\column {subminor 7th } } \grace <c,,,, e,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column {supermajor 6th } } \grace <c,,,, f,,,, g,,,, bf,,,,>4 c,,,,1_\markup{\column {subminor 7th suspended 4th } } \grace <c,,,, d,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column {supermajor 6th suspended 2nd } } \grace <c,,,, d,,,, g,,,, bf,,,,>4 c,,,,1_\markup{\column {subminor 7th suspended 2nd } } \grace <c,,,, f,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column {supermajor 6th suspended 4th } } \grace <c,,,, ef,,,, ecd,,,, g,,,, bf,,,,>4 c,,,,1_\markup{\column { } } \grace <c,,,, d,,,, efcu,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column { } } \grace <c,,,, d,,,, ecd,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column { } } 
} } 
>>

}