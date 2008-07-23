%%% created by Strasheela at 16:24, 23-6-2008

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
  \grace {c,,,,4 dfcu,,,,4 d,,,,4 efcu,,,,4 f,,,,4 fscd,,,,4 g,,,,4 afcu,,,,4 a,,,,4 bfcu,,,,} c,,,,1_\markup{\column {standard pentachordal minor } } \bar "||" \break 
 {
  \grace <c,,,, d,,,, efcu,,,, g,,,, a,,,,>4 c,,,,2_\markup{\column { } } \grace <c,,,, efcu,,,, g,,,,>4 c,,,,2_\markup{\column {minor } } \grace <c,,,, efcu,,,, g,,,, bfcu,,,,>4 c,,,,2_\markup{\column {minor 7th } } \grace <c,,,, efcu,,,, g,,,, a,,,,>4 c,,,,2_\markup{\column {subharmonic 6th } } \grace <c,,,, d,,,, g,,,, a,,,,>4 c,,,,2_\markup{\column {supermajor 6th suspended 2nd } } \grace <c,,,, f,,,, g,,,, a,,,,>4 c,,,,2_\markup{\column {supermajor 6th suspended 4th } } \grace <c,,,, efcu,,,, fscd,,,,>4 c,,,,2_\markup{\column {otonal subdiminished } } \grace <c,,,, efcu,,,, fscd,,,, a,,,,>4 c,,,,2_\markup{\column {subdiminished 7th (1) } } 
} \bar "||" \break 
 {
  \grace <dfcu,,,, f,,,, afcu,,,,>4 dfcu,,,,2_\markup{\column {major } } \grace <dfcu,,,, f,,,, afcu,,,, c,,,,>4 dfcu,,,,2_\markup{\column {major 7th } } \grace <dfcu,,,, efcu,,,, f,,,, afcu,,,, bfcu,,,,>4 dfcu,,,,2_\markup{\column { } } \grace <dfcu,,,, efcu,,,, afcu,,,, bfcu,,,,>4 dfcu,,,,2_\markup{\column {supermajor 6th suspended 2nd } } \grace <dfcu,,,, fscd,,,, afcu,,,, bfcu,,,,>4 dfcu,,,,2_\markup{\column {supermajor 6th suspended 4th } } 
} \bar "||" \break 
 {
  \grace <d,,,, f,,,, afcu,,,,>4 d,,,,2_\markup{\column {utonal subdiminished } } \grace <d,,,, f,,,, afcu,,,, c,,,,>4 d,,,,2_\markup{\column {half subdiminished 7th } } \grace <d,,,, fscd,,,, a,,,,>4 d,,,,2_\markup{\column {major } } \grace <d,,,, fscd,,,, c,,,,>4 d,,,,2_\markup{\column {harmonic 7th no 5 } } \grace <d,,,, fscd,,,, a,,,, dfcu,,,,>4 d,,,,2_\markup{\column {major 7th } } \grace <d,,,, fscd,,,, afcu,,,, c,,,,>4 d,,,,2_\markup{\column {French augmented 6th } } \grace <d,,,, fscd,,,, a,,,, c,,,,>4 d,,,,2_\markup{\column {harmonic 7th } } \grace <d,,,, g,,,, a,,,, c,,,,>4 d,,,,2_\markup{\column {subminor 7th suspended 4th } } \grace <d,,,, f,,,, fscd,,,, a,,,, c,,,,>4 d,,,,2_\markup{\column { } } \grace <d,,,, f,,,, a,,,,>4 d,,,,2_\markup{\column {subminor } } \grace <d,,,, f,,,, a,,,, c,,,,>4 d,,,,2_\markup{\column {subminor 7th } } 
} \bar "||" \break 
 {
  \grace <efcu,,,, fscd,,,, a,,,,>4 efcu,,,,2_\markup{\column {utonal subdiminished } } \grace <efcu,,,, fscd,,,, a,,,, c,,,,>4 efcu,,,,2_\markup{\column {subdiminished 7th (2) } } \grace <efcu,,,, fscd,,,, a,,,, dfcu,,,,>4 efcu,,,,2_\markup{\column {half subdiminished 7th } } \grace <efcu,,,, g,,,, bfcu,,,,>4 efcu,,,,2_\markup{\column {major } } \grace <efcu,,,, g,,,, dfcu,,,,>4 efcu,,,,2_\markup{\column {harmonic 7th no 5 } } \grace <efcu,,,, g,,,, bfcu,,,, d,,,,>4 efcu,,,,2_\markup{\column {major 7th } } \grace <efcu,,,, g,,,, bfcu,,,, c,,,,>4 efcu,,,,2_\markup{\column {minor 6th } } \grace <efcu,,,, g,,,, a,,,, dfcu,,,,>4 efcu,,,,2_\markup{\column {French augmented 6th } } \grace <efcu,,,, g,,,, bfcu,,,, dfcu,,,,>4 efcu,,,,2_\markup{\column {harmonic 7th } } \grace <efcu,,,, afcu,,,, bfcu,,,, dfcu,,,,>4 efcu,,,,2_\markup{\column {subminor 7th suspended 4th } } \grace <efcu,,,, fscd,,,, g,,,, bfcu,,,, dfcu,,,,>4 efcu,,,,2_\markup{\column { } } \grace <efcu,,,, fscd,,,, bfcu,,,,>4 efcu,,,,2_\markup{\column {subminor } } \grace <efcu,,,, fscd,,,, bfcu,,,, c,,,,>4 efcu,,,,2_\markup{\column {subminor major 6th } } \grace <efcu,,,, fscd,,,, bfcu,,,, dfcu,,,,>4 efcu,,,,2_\markup{\column {subminor 7th } } 
} \bar "||" \break 
 {
  \grace <f,,,, afcu,,,, c,,,,>4 f,,,,2_\markup{\column {minor } } \grace <f,,,, afcu,,,, c,,,, efcu,,,,>4 f,,,,2_\markup{\column {minor 7th } } \grace <f,,,, afcu,,,, c,,,, d,,,,>4 f,,,,2_\markup{\column {subharmonic 6th } } \grace <f,,,, g,,,, c,,,, d,,,,>4 f,,,,2_\markup{\column {supermajor 6th suspended 2nd } } \grace <f,,,, g,,,, afcu,,,, c,,,, d,,,,>4 f,,,,2_\markup{\column { } } \grace <f,,,, a,,,, c,,,,>4 f,,,,2_\markup{\column {supermajor } } \grace <f,,,, g,,,, a,,,, c,,,, efcu,,,,>4 f,,,,2_\markup{\column {subharmonic 9th } } \grace <f,,,, a,,,, c,,,, d,,,,>4 f,,,,2_\markup{\column {supermajor 6th } } 
} \bar "||" \break 
 {
  \grace <fscd,,,, a,,,, dfcu,,,,>4 fscd,,,,2_\markup{\column {minor } } \grace <fscd,,,, a,,,, dfcu,,,, efcu,,,,>4 fscd,,,,2_\markup{\column {subharmonic 6th } } \grace <fscd,,,, afcu,,,, dfcu,,,, efcu,,,,>4 fscd,,,,2_\markup{\column {supermajor 6th suspended 2nd } } \grace <fscd,,,, a,,,, c,,,,>4 fscd,,,,2_\markup{\column {otonal subdiminished } } \grace <fscd,,,, a,,,, c,,,, efcu,,,,>4 fscd,,,,2_\markup{\column {subdiminished 7th (1) } } \grace <fscd,,,, afcu,,,, a,,,, dfcu,,,, efcu,,,,>4 fscd,,,,2_\markup{\column { } } \grace <fscd,,,, bfcu,,,, dfcu,,,,>4 fscd,,,,2_\markup{\column {supermajor } } \grace <fscd,,,, bfcu,,,, c,,,, efcu,,,,>4 fscd,,,,2_\markup{\column {supermajor minor 7th } } \grace <fscd,,,, bfcu,,,, dfcu,,,, efcu,,,,>4 fscd,,,,2_\markup{\column {supermajor 6th } } 
} \bar "||" \break 
 {
  \grace <g,,,, bfcu,,,, d,,,,>4 g,,,,2_\markup{\column {minor } } \grace <g,,,, bfcu,,,, dfcu,,,,>4 g,,,,2_\markup{\column {otonal subdiminished } } \grace <g,,,, c,,,, d,,,, f,,,,>4 g,,,,2_\markup{\column {subminor 7th suspended 4th } } \grace <g,,,, a,,,, d,,,, f,,,,>4 g,,,,2_\markup{\column {subminor 7th suspended 2nd } } 
} \bar "||" \break 
 {
  \grace <afcu,,,, c,,,, efcu,,,,>4 afcu,,,,2_\markup{\column {major } } \grace <afcu,,,, c,,,, fscd,,,,>4 afcu,,,,2_\markup{\column {harmonic 7th no 5 } } \grace <afcu,,,, c,,,, efcu,,,, g,,,,>4 afcu,,,,2_\markup{\column {major 7th } } \grace <afcu,,,, c,,,, efcu,,,, f,,,,>4 afcu,,,,2_\markup{\column {minor 6th } } \grace <afcu,,,, c,,,, d,,,, fscd,,,,>4 afcu,,,,2_\markup{\column {French augmented 6th } } \grace <afcu,,,, c,,,, efcu,,,, fscd,,,,>4 afcu,,,,2_\markup{\column {harmonic 7th } } \grace <afcu,,,, bfcu,,,, c,,,, efcu,,,, fscd,,,,>4 afcu,,,,2_\markup{\column {harmonic 9th } } \grace <afcu,,,, dfcu,,,, efcu,,,, fscd,,,,>4 afcu,,,,2_\markup{\column {subminor 7th suspended 4th } } \grace <afcu,,,, bfcu,,,, efcu,,,, fscd,,,,>4 afcu,,,,2_\markup{\column {subminor 7th suspended 2nd } } 
} \bar "||" \break 
 {
  \grace <a,,,, c,,,, efcu,,,,>4 a,,,,2_\markup{\column {utonal subdiminished } } \grace <a,,,, c,,,, efcu,,,, fscd,,,,>4 a,,,,2_\markup{\column {subdiminished 7th (2) } } \grace <a,,,, c,,,, efcu,,,, g,,,,>4 a,,,,2_\markup{\column {half subdiminished 7th } } \grace <a,,,, dfcu,,,, f,,,,>4 a,,,,2_\markup{\column {augmented } } \grace <a,,,, dfcu,,,, g,,,,>4 a,,,,2_\markup{\column {harmonic 7th no 5 } } \grace <a,,,, dfcu,,,, efcu,,,, g,,,,>4 a,,,,2_\markup{\column {French augmented 6th } } 
} \bar "||" \break 
 {
  \grace <bfcu,,,, d,,,, fscd,,,,>4 bfcu,,,,2_\markup{\column {augmented } } \grace <bfcu,,,, d,,,, afcu,,,,>4 bfcu,,,,2_\markup{\column {harmonic 7th no 5 } } 
} 
} }

}