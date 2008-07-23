%%% created by Strasheela at 16:25, 23-6-2008

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
  
 <c c' d' efcu' g' a'>1 
 <c c' e' g'>1 
 <c c' e' fscd' a'>1 
 <c c' e' g' a'>1 
 <c c' efcu' g'>1 
 <c c' efcu' g' a'>1 
 <c c' d' g' a'>1 
 <c c' efcu' fscd'>1 
 <c c' efcu' fscd' a'>1 
 <dfcu dfcu' fscd' afcu' bcd'>1 
 <dfcu dfcu' efcu' afcu' bcd'>1 
 <dfcu dfcu' e' afcu'>1 
 <dfcu dfcu' e' g'>1 
 <d d' fscd' a'>1 
 <d c' d' fscd'>1 
 <d dfcu' d' fscd' a'>1 
 <d d' fscd' a' bcd'>1 
 <d c' d' fscd' afcu'>1 
 <d c' d' fscd' a'>1 
 <d c' d' e' fscd' a'>1 
 <d c' d' g' a'>1 
 <d c' d' e' a'>1 
 <efcu efcu' fscd' a'>1 
 <efcu c' efcu' fscd' a'>1 
 <efcu dfcu' efcu' fscd' a'>1 
 <efcu efcu' g' bcd'>1 
 <efcu dfcu' efcu' g'>1 
 <efcu dfcu' efcu' g' a'>1 
 <e c' e' afcu'>1 
 <e d' e' afcu'>1 
 <fscd dfcu' fscd' a'>1 
 <fscd dfcu' e' fscd' a'>1 
 <fscd dfcu' efcu' fscd' a'>1 
 <fscd dfcu' efcu' fscd' afcu'>1 
 <fscd dfcu' efcu' fscd' bcd'>1 
 <fscd c' fscd' a'>1 
 <fscd c' efcu' fscd' a'>1 
 <fscd dfcu' efcu' fscd' afcu' a'>1 
 <g d' e' g' a'>1 
 <g c' d' e' g'>1 
 <g d' g' bcd'>1 
 <g d' fscd' g' bcd'>1 
 <g d' e' g' a' bcd'>1 
 <afcu efcu' afcu' bcd'>1 
 <afcu efcu' fscd' afcu' bcd'>1 
 <afcu d' afcu' bcd'>1 
 <afcu d' fscd' afcu' bcd'>1 
 <afcu c' efcu' afcu'>1 
 <afcu c' fscd' afcu'>1 
 <afcu c' efcu' g' afcu'>1 
 <afcu c' d' fscd' afcu'>1 
 <afcu c' efcu' fscd' afcu'>1 
 <afcu dfcu' efcu' fscd' afcu'>1 
 <afcu c' efcu' fscd' afcu' bcd'>1 
 <a c' e' a'>1 
 <a c' e' fscd' a'>1 
 <a c' e' g' a'>1 
 <a c' efcu' a'>1 
 <a c' efcu' fscd' a'>1 
 <a c' efcu' g' a'>1 
 <a dfcu' e' a'>1 
 <a dfcu' g' a'>1 
 <a dfcu' e' afcu' a'>1 
 <a dfcu' e' fscd' a'>1 
 <a dfcu' efcu' g' a'>1 
 <a dfcu' e' g' a'>1 
 <a d' e' g' a'>1 
 <a c' dfcu' e' g' a'>1 
 <bcd efcu' fscd' bcd'>1 
 <bcd dfcu' efcu' fscd' a' bcd'>1 
 <bcd efcu' fscd' afcu' bcd'>1 
 <bcd d' fscd' bcd'>1 
 <bcd d' fscd' a' bcd'>1 
 <bcd d' fscd' afcu' bcd'>1 
 <bcd dfcu' fscd' afcu' bcd'>1 
 <bcd dfcu' d' fscd' afcu' bcd'>1 
} } 
 \new Staff { \clef "bass_29"  
 {
  \grace <c,,,, d,,,, efcu,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column { } } \grace <c,,,, e,,,, g,,,,>4 c,,,,1_\markup{\column {supermajor } } \grace <c,,,, e,,,, fscd,,,, a,,,,>4 c,,,,1_\markup{\column {supermajor minor 7th } } \grace <c,,,, e,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column {supermajor 6th } } \grace <c,,,, efcu,,,, g,,,,>4 c,,,,1_\markup{\column {minor } } \grace <c,,,, efcu,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column {subharmonic 6th } } \grace <c,,,, d,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column {supermajor 6th suspended 2nd } } \grace <c,,,, efcu,,,, fscd,,,,>4 c,,,,1_\markup{\column {otonal subdiminished } } \grace <c,,,, efcu,,,, fscd,,,, a,,,,>4 c,,,,1_\markup{\column {subdiminished 7th (1) } } \grace <dfcu,,,, fscd,,,, afcu,,,, bcd,,,,>4 dfcu,,,,1_\markup{\column {subminor 7th suspended 4th } } \grace <dfcu,,,, efcu,,,, afcu,,,, bcd,,,,>4 dfcu,,,,1_\markup{\column {subminor 7th suspended 2nd } } \grace <dfcu,,,, e,,,, afcu,,,,>4 dfcu,,,,1_\markup{\column {minor } } \grace <dfcu,,,, e,,,, g,,,,>4 dfcu,,,,1_\markup{\column {otonal subdiminished } } \grace <d,,,, fscd,,,, a,,,,>4 d,,,,1_\markup{\column {major } } \grace <d,,,, fscd,,,, c,,,,>4 d,,,,1_\markup{\column {harmonic 7th no 5 } } \grace <d,,,, fscd,,,, a,,,, dfcu,,,,>4 d,,,,1_\markup{\column {major 7th } } \grace <d,,,, fscd,,,, a,,,, bcd,,,,>4 d,,,,1_\markup{\column {minor 6th } } \grace <d,,,, fscd,,,, afcu,,,, c,,,,>4 d,,,,1_\markup{\column {French augmented 6th } } \grace <d,,,, fscd,,,, a,,,, c,,,,>4 d,,,,1_\markup{\column {harmonic 7th } } \grace <d,,,, e,,,, fscd,,,, a,,,, c,,,,>4 d,,,,1_\markup{\column {harmonic 9th } } \grace <d,,,, g,,,, a,,,, c,,,,>4 d,,,,1_\markup{\column {subminor 7th suspended 4th } } \grace <d,,,, e,,,, a,,,, c,,,,>4 d,,,,1_\markup{\column {subminor 7th suspended 2nd } } \grace <efcu,,,, fscd,,,, a,,,,>4 efcu,,,,1_\markup{\column {utonal subdiminished } } \grace <efcu,,,, fscd,,,, a,,,, c,,,,>4 efcu,,,,1_\markup{\column {subdiminished 7th (2) } } \grace <efcu,,,, fscd,,,, a,,,, dfcu,,,,>4 efcu,,,,1_\markup{\column {half subdiminished 7th } } \grace <efcu,,,, g,,,, bcd,,,,>4 efcu,,,,1_\markup{\column {augmented } } \grace <efcu,,,, g,,,, dfcu,,,,>4 efcu,,,,1_\markup{\column {harmonic 7th no 5 } } \grace <efcu,,,, g,,,, a,,,, dfcu,,,,>4 efcu,,,,1_\markup{\column {French augmented 6th } } \grace <e,,,, afcu,,,, c,,,,>4 e,,,,1_\markup{\column {augmented } } \grace <e,,,, afcu,,,, d,,,,>4 e,,,,1_\markup{\column {harmonic 7th no 5 } } \grace <fscd,,,, a,,,, dfcu,,,,>4 fscd,,,,1_\markup{\column {minor } } \grace <fscd,,,, a,,,, dfcu,,,, e,,,,>4 fscd,,,,1_\markup{\column {minor 7th } } \grace <fscd,,,, a,,,, dfcu,,,, efcu,,,,>4 fscd,,,,1_\markup{\column {subharmonic 6th } } \grace <fscd,,,, afcu,,,, dfcu,,,, efcu,,,,>4 fscd,,,,1_\markup{\column {supermajor 6th suspended 2nd } } \grace <fscd,,,, bcd,,,, dfcu,,,, efcu,,,,>4 fscd,,,,1_\markup{\column {supermajor 6th suspended 4th } } \grace <fscd,,,, a,,,, c,,,,>4 fscd,,,,1_\markup{\column {otonal subdiminished } } \grace <fscd,,,, a,,,, c,,,, efcu,,,,>4 fscd,,,,1_\markup{\column {subdiminished 7th (1) } } \grace <fscd,,,, afcu,,,, a,,,, dfcu,,,, efcu,,,,>4 fscd,,,,1_\markup{\column { } } \grace <g,,,, a,,,, d,,,, e,,,,>4 g,,,,1_\markup{\column {supermajor 6th suspended 2nd } } \grace <g,,,, c,,,, d,,,, e,,,,>4 g,,,,1_\markup{\column {supermajor 6th suspended 4th } } \grace <g,,,, bcd,,,, d,,,,>4 g,,,,1_\markup{\column {major } } \grace <g,,,, bcd,,,, d,,,, fscd,,,,>4 g,,,,1_\markup{\column {major 7th } } \grace <g,,,, a,,,, bcd,,,, d,,,, e,,,,>4 g,,,,1_\markup{\column { } } \grace <afcu,,,, bcd,,,, efcu,,,,>4 afcu,,,,1_\markup{\column {subminor } } \grace <afcu,,,, bcd,,,, efcu,,,, fscd,,,,>4 afcu,,,,1_\markup{\column {subminor 7th } } \grace <afcu,,,, bcd,,,, d,,,,>4 afcu,,,,1_\markup{\column {utonal subdiminished } } \grace <afcu,,,, bcd,,,, d,,,, fscd,,,,>4 afcu,,,,1_\markup{\column {half subdiminished 7th } } \grace <afcu,,,, c,,,, efcu,,,,>4 afcu,,,,1_\markup{\column {major } } \grace <afcu,,,, c,,,, fscd,,,,>4 afcu,,,,1_\markup{\column {harmonic 7th no 5 } } \grace <afcu,,,, c,,,, efcu,,,, g,,,,>4 afcu,,,,1_\markup{\column {major 7th } } \grace <afcu,,,, c,,,, d,,,, fscd,,,,>4 afcu,,,,1_\markup{\column {French augmented 6th } } \grace <afcu,,,, c,,,, efcu,,,, fscd,,,,>4 afcu,,,,1_\markup{\column {harmonic 7th } } \grace <afcu,,,, dfcu,,,, efcu,,,, fscd,,,,>4 afcu,,,,1_\markup{\column {subminor 7th suspended 4th } } \grace <afcu,,,, bcd,,,, c,,,, efcu,,,, fscd,,,,>4 afcu,,,,1_\markup{\column { } } \grace <a,,,, c,,,, e,,,,>4 a,,,,1_\markup{\column {subminor } } \grace <a,,,, c,,,, e,,,, fscd,,,,>4 a,,,,1_\markup{\column {subminor major 6th } } \grace <a,,,, c,,,, e,,,, g,,,,>4 a,,,,1_\markup{\column {subminor 7th } } \grace <a,,,, c,,,, efcu,,,,>4 a,,,,1_\markup{\column {utonal subdiminished } } \grace <a,,,, c,,,, efcu,,,, fscd,,,,>4 a,,,,1_\markup{\column {subdiminished 7th (2) } } \grace <a,,,, c,,,, efcu,,,, g,,,,>4 a,,,,1_\markup{\column {half subdiminished 7th } } \grace <a,,,, dfcu,,,, e,,,,>4 a,,,,1_\markup{\column {major } } \grace <a,,,, dfcu,,,, g,,,,>4 a,,,,1_\markup{\column {harmonic 7th no 5 } } \grace <a,,,, dfcu,,,, e,,,, afcu,,,,>4 a,,,,1_\markup{\column {major 7th } } \grace <a,,,, dfcu,,,, e,,,, fscd,,,,>4 a,,,,1_\markup{\column {minor 6th } } \grace <a,,,, dfcu,,,, efcu,,,, g,,,,>4 a,,,,1_\markup{\column {French augmented 6th } } \grace <a,,,, dfcu,,,, e,,,, g,,,,>4 a,,,,1_\markup{\column {harmonic 7th } } \grace <a,,,, d,,,, e,,,, g,,,,>4 a,,,,1_\markup{\column {subminor 7th suspended 4th } } \grace <a,,,, c,,,, dfcu,,,, e,,,, g,,,,>4 a,,,,1_\markup{\column { } } \grace <bcd,,,, efcu,,,, fscd,,,,>4 bcd,,,,1_\markup{\column {supermajor } } \grace <bcd,,,, dfcu,,,, efcu,,,, fscd,,,, a,,,,>4 bcd,,,,1_\markup{\column {subharmonic 9th } } \grace <bcd,,,, efcu,,,, fscd,,,, afcu,,,,>4 bcd,,,,1_\markup{\column {supermajor 6th } } \grace <bcd,,,, d,,,, fscd,,,,>4 bcd,,,,1_\markup{\column {minor } } \grace <bcd,,,, d,,,, fscd,,,, a,,,,>4 bcd,,,,1_\markup{\column {minor 7th } } \grace <bcd,,,, d,,,, fscd,,,, afcu,,,,>4 bcd,,,,1_\markup{\column {subharmonic 6th } } \grace <bcd,,,, dfcu,,,, fscd,,,, afcu,,,,>4 bcd,,,,1_\markup{\column {supermajor 6th suspended 2nd } } \grace <bcd,,,, dfcu,,,, d,,,, fscd,,,, afcu,,,,>4 bcd,,,,1_\markup{\column { } } 
} } 
>>

}