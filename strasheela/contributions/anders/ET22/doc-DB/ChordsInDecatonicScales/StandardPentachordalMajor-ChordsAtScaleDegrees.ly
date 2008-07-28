%%% created by Strasheela at 16:22, 23-6-2008

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



 \new Staff { \clef "bass_29"  
 {
  \grace {c,,,,4 dfcu,,,,4 d,,,,4 ecd,,,,4 f,,,,4 fscd,,,,4 g,,,,4 acd,,,,4 bf,,,,4 bcd,,,,} c,,,,1_\markup{\column {standard pentachordal major } } \bar "||" \break 
 {
  \grace <c,,,, ecd,,,, g,,,,>4 c,,,,2_\markup{\column {major } } \grace <c,,,, ecd,,,, bf,,,,>4 c,,,,2_\markup{\column {harmonic 7th no 5 } } \grace <c,,,, ecd,,,, g,,,, bcd,,,,>4 c,,,,2_\markup{\column {major 7th } } \grace <c,,,, ecd,,,, g,,,, acd,,,,>4 c,,,,2_\markup{\column {minor 6th } } \grace <c,,,, ecd,,,, fscd,,,, bf,,,,>4 c,,,,2_\markup{\column {French augmented 6th } } \grace <c,,,, ecd,,,, g,,,, bf,,,,>4 c,,,,2_\markup{\column {harmonic 7th } } \grace <c,,,, d,,,, ecd,,,, g,,,, bf,,,,>4 c,,,,2_\markup{\column {harmonic 9th } } \grace <c,,,, f,,,, g,,,, bf,,,,>4 c,,,,2_\markup{\column {subminor 7th suspended 4th } } \grace <c,,,, d,,,, g,,,, bf,,,,>4 c,,,,2_\markup{\column {subminor 7th suspended 2nd } } 
} \bar "||" \break 
 {
  \grace <dfcu,,,, f,,,, acd,,,,>4 dfcu,,,,2_\markup{\column {augmented } } \grace <dfcu,,,, f,,,, bcd,,,,>4 dfcu,,,,2_\markup{\column {harmonic 7th no 5 } } \grace <dfcu,,,, f,,,, g,,,, bcd,,,,>4 dfcu,,,,2_\markup{\column {French augmented 6th } } \grace <dfcu,,,, ecd,,,, g,,,,>4 dfcu,,,,2_\markup{\column {utonal subdiminished } } \grace <dfcu,,,, ecd,,,, g,,,, bf,,,,>4 dfcu,,,,2_\markup{\column {subdiminished 7th (2) } } \grace <dfcu,,,, ecd,,,, g,,,, bcd,,,,>4 dfcu,,,,2_\markup{\column {half subdiminished 7th } } 
} \bar "||" \break 
 {
  \grace <d,,,, fscd,,,, bf,,,,>4 d,,,,2_\markup{\column {augmented } } \grace <d,,,, fscd,,,, c,,,,>4 d,,,,2_\markup{\column {harmonic 7th no 5 } } 
} \bar "||" \break 
 {
  \grace <ecd,,,, g,,,, bf,,,,>4 ecd,,,,2_\markup{\column {otonal subdiminished } } \grace <ecd,,,, g,,,, bf,,,, dfcu,,,,>4 ecd,,,,2_\markup{\column {subdiminished 7th (1) } } \grace <ecd,,,, fscd,,,, g,,,, bcd,,,, dfcu,,,,>4 ecd,,,,2_\markup{\column { } } \grace <ecd,,,, g,,,, bcd,,,,>4 ecd,,,,2_\markup{\column {minor } } \grace <ecd,,,, g,,,, bcd,,,, d,,,,>4 ecd,,,,2_\markup{\column {minor 7th } } \grace <ecd,,,, g,,,, bcd,,,, dfcu,,,,>4 ecd,,,,2_\markup{\column {subharmonic 6th } } \grace <ecd,,,, fscd,,,, bcd,,,, dfcu,,,,>4 ecd,,,,2_\markup{\column {supermajor 6th suspended 2nd } } \grace <ecd,,,, acd,,,, bcd,,,, dfcu,,,,>4 ecd,,,,2_\markup{\column {supermajor 6th suspended 4th } } 
} \bar "||" \break 
 {
  \grace <f,,,, g,,,, c,,,, d,,,,>4 f,,,,2_\markup{\column {supermajor 6th suspended 2nd } } \grace <f,,,, bf,,,, c,,,, d,,,,>4 f,,,,2_\markup{\column {supermajor 6th suspended 4th } } \grace <f,,,, acd,,,, c,,,,>4 f,,,,2_\markup{\column {major } } \grace <f,,,, acd,,,, c,,,, ecd,,,,>4 f,,,,2_\markup{\column {major 7th } } \grace <f,,,, g,,,, acd,,,, c,,,, d,,,,>4 f,,,,2_\markup{\column { } } 
} \bar "||" \break 
 {
  \grace <fscd,,,, acd,,,, c,,,,>4 fscd,,,,2_\markup{\column {utonal subdiminished } } \grace <fscd,,,, acd,,,, c,,,, ecd,,,,>4 fscd,,,,2_\markup{\column {half subdiminished 7th } } \grace <fscd,,,, bf,,,, dfcu,,,,>4 fscd,,,,2_\markup{\column {major } } \grace <fscd,,,, bf,,,, ecd,,,,>4 fscd,,,,2_\markup{\column {harmonic 7th no 5 } } \grace <fscd,,,, bf,,,, dfcu,,,, f,,,,>4 fscd,,,,2_\markup{\column {major 7th } } \grace <fscd,,,, bf,,,, c,,,, ecd,,,,>4 fscd,,,,2_\markup{\column {French augmented 6th } } \grace <fscd,,,, bf,,,, dfcu,,,, ecd,,,,>4 fscd,,,,2_\markup{\column {harmonic 7th } } \grace <fscd,,,, bcd,,,, dfcu,,,, ecd,,,,>4 fscd,,,,2_\markup{\column {subminor 7th suspended 4th } } \grace <fscd,,,, acd,,,, bf,,,, dfcu,,,, ecd,,,,>4 fscd,,,,2_\markup{\column { } } \grace <fscd,,,, acd,,,, dfcu,,,,>4 fscd,,,,2_\markup{\column {subminor } } \grace <fscd,,,, acd,,,, dfcu,,,, ecd,,,,>4 fscd,,,,2_\markup{\column {subminor 7th } } 
} \bar "||" \break 
 {
  \grace <g,,,, bf,,,, d,,,,>4 g,,,,2_\markup{\column {subminor } } \grace <g,,,, bf,,,, d,,,, ecd,,,,>4 g,,,,2_\markup{\column {subminor major 6th } } \grace <g,,,, bf,,,, d,,,, f,,,,>4 g,,,,2_\markup{\column {subminor 7th } } \grace <g,,,, bf,,,, dfcu,,,,>4 g,,,,2_\markup{\column {utonal subdiminished } } \grace <g,,,, bf,,,, dfcu,,,, ecd,,,,>4 g,,,,2_\markup{\column {subdiminished 7th (2) } } \grace <g,,,, bf,,,, dfcu,,,, f,,,,>4 g,,,,2_\markup{\column {half subdiminished 7th } } \grace <g,,,, bcd,,,, d,,,,>4 g,,,,2_\markup{\column {major } } \grace <g,,,, bcd,,,, f,,,,>4 g,,,,2_\markup{\column {harmonic 7th no 5 } } \grace <g,,,, bcd,,,, d,,,, fscd,,,,>4 g,,,,2_\markup{\column {major 7th } } \grace <g,,,, bcd,,,, d,,,, ecd,,,,>4 g,,,,2_\markup{\column {minor 6th } } \grace <g,,,, bcd,,,, dfcu,,,, f,,,,>4 g,,,,2_\markup{\column {French augmented 6th } } \grace <g,,,, bcd,,,, d,,,, f,,,,>4 g,,,,2_\markup{\column {harmonic 7th } } \grace <g,,,, c,,,, d,,,, f,,,,>4 g,,,,2_\markup{\column {subminor 7th suspended 4th } } \grace <g,,,, bf,,,, bcd,,,, d,,,, f,,,,>4 g,,,,2_\markup{\column { } } 
} \bar "||" \break 
 {
  \grace <acd,,,, c,,,, ecd,,,,>4 acd,,,,2_\markup{\column {minor } } \grace <acd,,,, c,,,, ecd,,,, g,,,,>4 acd,,,,2_\markup{\column {minor 7th } } \grace <acd,,,, c,,,, ecd,,,, fscd,,,,>4 acd,,,,2_\markup{\column {subharmonic 6th } } \grace <acd,,,, bcd,,,, ecd,,,, fscd,,,,>4 acd,,,,2_\markup{\column {supermajor 6th suspended 2nd } } \grace <acd,,,, bcd,,,, c,,,, ecd,,,, fscd,,,,>4 acd,,,,2_\markup{\column { } } \grace <acd,,,, dfcu,,,, ecd,,,,>4 acd,,,,2_\markup{\column {supermajor } } \grace <acd,,,, bcd,,,, dfcu,,,, ecd,,,, g,,,,>4 acd,,,,2_\markup{\column {subharmonic 9th } } \grace <acd,,,, dfcu,,,, ecd,,,, fscd,,,,>4 acd,,,,2_\markup{\column {supermajor 6th } } 
} \bar "||" \break 
 {
  \grace <bf,,,, d,,,, f,,,,>4 bf,,,,2_\markup{\column {supermajor } } \grace <bf,,,, d,,,, ecd,,,, g,,,,>4 bf,,,,2_\markup{\column {supermajor minor 7th } } \grace <bf,,,, d,,,, f,,,, g,,,,>4 bf,,,,2_\markup{\column {supermajor 6th } } \grace <bf,,,, dfcu,,,, f,,,,>4 bf,,,,2_\markup{\column {minor } } \grace <bf,,,, dfcu,,,, f,,,, g,,,,>4 bf,,,,2_\markup{\column {subharmonic 6th } } \grace <bf,,,, c,,,, f,,,, g,,,,>4 bf,,,,2_\markup{\column {supermajor 6th suspended 2nd } } \grace <bf,,,, dfcu,,,, ecd,,,,>4 bf,,,,2_\markup{\column {otonal subdiminished } } \grace <bf,,,, dfcu,,,, ecd,,,, g,,,,>4 bf,,,,2_\markup{\column {subdiminished 7th (1) } } \grace <bf,,,, c,,,, dfcu,,,, f,,,, g,,,,>4 bf,,,,2_\markup{\column { } } 
} \bar "||" \break 
 {
  \grace <bcd,,,, d,,,, fscd,,,,>4 bcd,,,,2_\markup{\column {minor } } \grace <bcd,,,, d,,,, f,,,,>4 bcd,,,,2_\markup{\column {otonal subdiminished } } \grace <bcd,,,, ecd,,,, fscd,,,, acd,,,,>4 bcd,,,,2_\markup{\column {subminor 7th suspended 4th } } \grace <bcd,,,, dfcu,,,, fscd,,,, acd,,,,>4 bcd,,,,2_\markup{\column {subminor 7th suspended 2nd } } 
} 
} }

}