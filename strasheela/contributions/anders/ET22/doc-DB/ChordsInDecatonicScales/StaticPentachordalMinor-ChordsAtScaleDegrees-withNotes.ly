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
 <c c' efcu' g'>1 
 <c c' efcu' g' a'>1 
 <c c' d' g' a'>1 
 <c c' f' g' a'>1 
 <c c' efcu' fscd'>1 
 <c c' efcu' fscd' a'>1 
 <dfcu dfcu' f' afcu'>1 
 <dfcu dfcu' f' bcd'>1 
 <dfcu c' dfcu' f' afcu'>1 
 <dfcu dfcu' f' g' bcd'>1 
 <dfcu dfcu' f' afcu' bcd'>1 
 <dfcu dfcu' efcu' f' afcu' bcd'>1 
 <dfcu dfcu' fscd' afcu' bcd'>1 
 <dfcu dfcu' efcu' afcu' bcd'>1 
 <d d' f' afcu'>1 
 <d d' f' afcu' bcd'>1 
 <d c' d' f' afcu'>1 
 <d d' fscd' a'>1 
 <d c' d' fscd'>1 
 <d dfcu' d' fscd' a'>1 
 <d d' fscd' a' bcd'>1 
 <d c' d' fscd' afcu'>1 
 <d c' d' fscd' a'>1 
 <d c' d' g' a'>1 
 <d c' d' f' fscd' a'>1 
 <d d' f' a'>1 
 <d d' f' a' bcd'>1 
 <d c' d' f' a'>1 
 <efcu efcu' fscd' a'>1 
 <efcu c' efcu' fscd' a'>1 
 <efcu dfcu' efcu' fscd' a'>1 
 <efcu efcu' g' bcd'>1 
 <efcu dfcu' efcu' g'>1 
 <efcu dfcu' efcu' g' a'>1 
 <f c' f' afcu'>1 
 <f c' efcu' f' afcu'>1 
 <f c' d' f' afcu'>1 
 <f c' d' f' g'>1 
 <f f' afcu' bcd'>1 
 <f d' f' afcu' bcd'>1 
 <f c' d' f' g' afcu'>1 
 <f c' f' a'>1 
 <f d' f' a' bcd'>1 
 <f c' efcu' f' g' a'>1 
 <f c' d' f' a'>1 
 <fscd dfcu' fscd' a'>1 
 <fscd dfcu' efcu' fscd' a'>1 
 <fscd dfcu' efcu' fscd' afcu'>1 
 <fscd dfcu' efcu' fscd' bcd'>1 
 <fscd c' fscd' a'>1 
 <fscd c' efcu' fscd' a'>1 
 <fscd dfcu' efcu' fscd' afcu' a'>1 
 <g d' g' bcd'>1 
 <g f' g' bcd'>1 
 <g d' fscd' g' bcd'>1 
 <g dfcu' f' g' bcd'>1 
 <g d' f' g' bcd'>1 
 <g d' f' g' a' bcd'>1 
 <g c' d' f' g'>1 
 <g d' f' g' a'>1 
 <afcu efcu' afcu' bcd'>1 
 <afcu efcu' f' afcu' bcd'>1 
 <afcu efcu' fscd' afcu' bcd'>1 
 <afcu d' afcu' bcd'>1 
 <afcu d' f' afcu' bcd'>1 
 <afcu d' fscd' afcu' bcd'>1 
 <afcu c' efcu' afcu'>1 
 <afcu c' fscd' afcu'>1 
 <afcu c' efcu' g' afcu'>1 
 <afcu c' efcu' f' afcu'>1 
 <afcu c' d' fscd' afcu'>1 
 <afcu c' efcu' fscd' afcu'>1 
 <afcu dfcu' efcu' fscd' afcu'>1 
 <afcu c' efcu' fscd' afcu' bcd'>1 
 <a c' efcu' a'>1 
 <a c' efcu' fscd' a'>1 
 <a c' efcu' g' a'>1 
 <a dfcu' f' a'>1 
 <a dfcu' g' a'>1 
 <a dfcu' efcu' g' a'>1 
 <bcd efcu' fscd' bcd'>1 
 <bcd efcu' f' afcu' bcd'>1 
 <bcd dfcu' efcu' fscd' a' bcd'>1 
 <bcd efcu' fscd' afcu' bcd'>1 
 <bcd d' fscd' bcd'>1 
 <bcd d' fscd' a' bcd'>1 
 <bcd d' fscd' afcu' bcd'>1 
 <bcd dfcu' fscd' afcu' bcd'>1 
 <bcd d' f' bcd'>1 
 <bcd d' f' afcu' bcd'>1 
 <bcd dfcu' d' fscd' afcu' bcd'>1 
} } 
 \new Staff { \clef "bass_29"  
 {
  \grace <c,,,, d,,,, efcu,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column { } } \grace <c,,,, efcu,,,, g,,,,>4 c,,,,1_\markup{\column {minor } } \grace <c,,,, efcu,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column {subharmonic 6th } } \grace <c,,,, d,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column {supermajor 6th suspended 2nd } } \grace <c,,,, f,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column {supermajor 6th suspended 4th } } \grace <c,,,, efcu,,,, fscd,,,,>4 c,,,,1_\markup{\column {otonal subdiminished } } \grace <c,,,, efcu,,,, fscd,,,, a,,,,>4 c,,,,1_\markup{\column {subdiminished 7th (1) } } \grace <dfcu,,,, f,,,, afcu,,,,>4 dfcu,,,,1_\markup{\column {major } } \grace <dfcu,,,, f,,,, bcd,,,,>4 dfcu,,,,1_\markup{\column {harmonic 7th no 5 } } \grace <dfcu,,,, f,,,, afcu,,,, c,,,,>4 dfcu,,,,1_\markup{\column {major 7th } } \grace <dfcu,,,, f,,,, g,,,, bcd,,,,>4 dfcu,,,,1_\markup{\column {French augmented 6th } } \grace <dfcu,,,, f,,,, afcu,,,, bcd,,,,>4 dfcu,,,,1_\markup{\column {harmonic 7th } } \grace <dfcu,,,, efcu,,,, f,,,, afcu,,,, bcd,,,,>4 dfcu,,,,1_\markup{\column {harmonic 9th } } \grace <dfcu,,,, fscd,,,, afcu,,,, bcd,,,,>4 dfcu,,,,1_\markup{\column {subminor 7th suspended 4th } } \grace <dfcu,,,, efcu,,,, afcu,,,, bcd,,,,>4 dfcu,,,,1_\markup{\column {subminor 7th suspended 2nd } } \grace <d,,,, f,,,, afcu,,,,>4 d,,,,1_\markup{\column {utonal subdiminished } } \grace <d,,,, f,,,, afcu,,,, bcd,,,,>4 d,,,,1_\markup{\column {subdiminished 7th (2) } } \grace <d,,,, f,,,, afcu,,,, c,,,,>4 d,,,,1_\markup{\column {half subdiminished 7th } } \grace <d,,,, fscd,,,, a,,,,>4 d,,,,1_\markup{\column {major } } \grace <d,,,, fscd,,,, c,,,,>4 d,,,,1_\markup{\column {harmonic 7th no 5 } } \grace <d,,,, fscd,,,, a,,,, dfcu,,,,>4 d,,,,1_\markup{\column {major 7th } } \grace <d,,,, fscd,,,, a,,,, bcd,,,,>4 d,,,,1_\markup{\column {minor 6th } } \grace <d,,,, fscd,,,, afcu,,,, c,,,,>4 d,,,,1_\markup{\column {French augmented 6th } } \grace <d,,,, fscd,,,, a,,,, c,,,,>4 d,,,,1_\markup{\column {harmonic 7th } } \grace <d,,,, g,,,, a,,,, c,,,,>4 d,,,,1_\markup{\column {subminor 7th suspended 4th } } \grace <d,,,, f,,,, fscd,,,, a,,,, c,,,,>4 d,,,,1_\markup{\column { } } \grace <d,,,, f,,,, a,,,,>4 d,,,,1_\markup{\column {subminor } } \grace <d,,,, f,,,, a,,,, bcd,,,,>4 d,,,,1_\markup{\column {subminor major 6th } } \grace <d,,,, f,,,, a,,,, c,,,,>4 d,,,,1_\markup{\column {subminor 7th } } \grace <efcu,,,, fscd,,,, a,,,,>4 efcu,,,,1_\markup{\column {utonal subdiminished } } \grace <efcu,,,, fscd,,,, a,,,, c,,,,>4 efcu,,,,1_\markup{\column {subdiminished 7th (2) } } \grace <efcu,,,, fscd,,,, a,,,, dfcu,,,,>4 efcu,,,,1_\markup{\column {half subdiminished 7th } } \grace <efcu,,,, g,,,, bcd,,,,>4 efcu,,,,1_\markup{\column {augmented } } \grace <efcu,,,, g,,,, dfcu,,,,>4 efcu,,,,1_\markup{\column {harmonic 7th no 5 } } \grace <efcu,,,, g,,,, a,,,, dfcu,,,,>4 efcu,,,,1_\markup{\column {French augmented 6th } } \grace <f,,,, afcu,,,, c,,,,>4 f,,,,1_\markup{\column {minor } } \grace <f,,,, afcu,,,, c,,,, efcu,,,,>4 f,,,,1_\markup{\column {minor 7th } } \grace <f,,,, afcu,,,, c,,,, d,,,,>4 f,,,,1_\markup{\column {subharmonic 6th } } \grace <f,,,, g,,,, c,,,, d,,,,>4 f,,,,1_\markup{\column {supermajor 6th suspended 2nd } } \grace <f,,,, afcu,,,, bcd,,,,>4 f,,,,1_\markup{\column {otonal subdiminished } } \grace <f,,,, afcu,,,, bcd,,,, d,,,,>4 f,,,,1_\markup{\column {subdiminished 7th (1) } } \grace <f,,,, g,,,, afcu,,,, c,,,, d,,,,>4 f,,,,1_\markup{\column { } } \grace <f,,,, a,,,, c,,,,>4 f,,,,1_\markup{\column {supermajor } } \grace <f,,,, a,,,, bcd,,,, d,,,,>4 f,,,,1_\markup{\column {supermajor minor 7th } } \grace <f,,,, g,,,, a,,,, c,,,, efcu,,,,>4 f,,,,1_\markup{\column {subharmonic 9th } } \grace <f,,,, a,,,, c,,,, d,,,,>4 f,,,,1_\markup{\column {supermajor 6th } } \grace <fscd,,,, a,,,, dfcu,,,,>4 fscd,,,,1_\markup{\column {minor } } \grace <fscd,,,, a,,,, dfcu,,,, efcu,,,,>4 fscd,,,,1_\markup{\column {subharmonic 6th } } \grace <fscd,,,, afcu,,,, dfcu,,,, efcu,,,,>4 fscd,,,,1_\markup{\column {supermajor 6th suspended 2nd } } \grace <fscd,,,, bcd,,,, dfcu,,,, efcu,,,,>4 fscd,,,,1_\markup{\column {supermajor 6th suspended 4th } } \grace <fscd,,,, a,,,, c,,,,>4 fscd,,,,1_\markup{\column {otonal subdiminished } } \grace <fscd,,,, a,,,, c,,,, efcu,,,,>4 fscd,,,,1_\markup{\column {subdiminished 7th (1) } } \grace <fscd,,,, afcu,,,, a,,,, dfcu,,,, efcu,,,,>4 fscd,,,,1_\markup{\column { } } \grace <g,,,, bcd,,,, d,,,,>4 g,,,,1_\markup{\column {major } } \grace <g,,,, bcd,,,, f,,,,>4 g,,,,1_\markup{\column {harmonic 7th no 5 } } \grace <g,,,, bcd,,,, d,,,, fscd,,,,>4 g,,,,1_\markup{\column {major 7th } } \grace <g,,,, bcd,,,, dfcu,,,, f,,,,>4 g,,,,1_\markup{\column {French augmented 6th } } \grace <g,,,, bcd,,,, d,,,, f,,,,>4 g,,,,1_\markup{\column {harmonic 7th } } \grace <g,,,, a,,,, bcd,,,, d,,,, f,,,,>4 g,,,,1_\markup{\column {harmonic 9th } } \grace <g,,,, c,,,, d,,,, f,,,,>4 g,,,,1_\markup{\column {subminor 7th suspended 4th } } \grace <g,,,, a,,,, d,,,, f,,,,>4 g,,,,1_\markup{\column {subminor 7th suspended 2nd } } \grace <afcu,,,, bcd,,,, efcu,,,,>4 afcu,,,,1_\markup{\column {subminor } } \grace <afcu,,,, bcd,,,, efcu,,,, f,,,,>4 afcu,,,,1_\markup{\column {subminor major 6th } } \grace <afcu,,,, bcd,,,, efcu,,,, fscd,,,,>4 afcu,,,,1_\markup{\column {subminor 7th } } \grace <afcu,,,, bcd,,,, d,,,,>4 afcu,,,,1_\markup{\column {utonal subdiminished } } \grace <afcu,,,, bcd,,,, d,,,, f,,,,>4 afcu,,,,1_\markup{\column {subdiminished 7th (2) } } \grace <afcu,,,, bcd,,,, d,,,, fscd,,,,>4 afcu,,,,1_\markup{\column {half subdiminished 7th } } \grace <afcu,,,, c,,,, efcu,,,,>4 afcu,,,,1_\markup{\column {major } } \grace <afcu,,,, c,,,, fscd,,,,>4 afcu,,,,1_\markup{\column {harmonic 7th no 5 } } \grace <afcu,,,, c,,,, efcu,,,, g,,,,>4 afcu,,,,1_\markup{\column {major 7th } } \grace <afcu,,,, c,,,, efcu,,,, f,,,,>4 afcu,,,,1_\markup{\column {minor 6th } } \grace <afcu,,,, c,,,, d,,,, fscd,,,,>4 afcu,,,,1_\markup{\column {French augmented 6th } } \grace <afcu,,,, c,,,, efcu,,,, fscd,,,,>4 afcu,,,,1_\markup{\column {harmonic 7th } } \grace <afcu,,,, dfcu,,,, efcu,,,, fscd,,,,>4 afcu,,,,1_\markup{\column {subminor 7th suspended 4th } } \grace <afcu,,,, bcd,,,, c,,,, efcu,,,, fscd,,,,>4 afcu,,,,1_\markup{\column { } } \grace <a,,,, c,,,, efcu,,,,>4 a,,,,1_\markup{\column {utonal subdiminished } } \grace <a,,,, c,,,, efcu,,,, fscd,,,,>4 a,,,,1_\markup{\column {subdiminished 7th (2) } } \grace <a,,,, c,,,, efcu,,,, g,,,,>4 a,,,,1_\markup{\column {half subdiminished 7th } } \grace <a,,,, dfcu,,,, f,,,,>4 a,,,,1_\markup{\column {augmented } } \grace <a,,,, dfcu,,,, g,,,,>4 a,,,,1_\markup{\column {harmonic 7th no 5 } } \grace <a,,,, dfcu,,,, efcu,,,, g,,,,>4 a,,,,1_\markup{\column {French augmented 6th } } \grace <bcd,,,, efcu,,,, fscd,,,,>4 bcd,,,,1_\markup{\column {supermajor } } \grace <bcd,,,, efcu,,,, f,,,, afcu,,,,>4 bcd,,,,1_\markup{\column {supermajor minor 7th } } \grace <bcd,,,, dfcu,,,, efcu,,,, fscd,,,, a,,,,>4 bcd,,,,1_\markup{\column {subharmonic 9th } } \grace <bcd,,,, efcu,,,, fscd,,,, afcu,,,,>4 bcd,,,,1_\markup{\column {supermajor 6th } } \grace <bcd,,,, d,,,, fscd,,,,>4 bcd,,,,1_\markup{\column {minor } } \grace <bcd,,,, d,,,, fscd,,,, a,,,,>4 bcd,,,,1_\markup{\column {minor 7th } } \grace <bcd,,,, d,,,, fscd,,,, afcu,,,,>4 bcd,,,,1_\markup{\column {subharmonic 6th } } \grace <bcd,,,, dfcu,,,, fscd,,,, afcu,,,,>4 bcd,,,,1_\markup{\column {supermajor 6th suspended 2nd } } \grace <bcd,,,, d,,,, f,,,,>4 bcd,,,,1_\markup{\column {otonal subdiminished } } \grace <bcd,,,, d,,,, f,,,, afcu,,,,>4 bcd,,,,1_\markup{\column {subdiminished 7th (1) } } \grace <bcd,,,, dfcu,,,, d,,,, fscd,,,, afcu,,,,>4 bcd,,,,1_\markup{\column { } } 
} } 
>>

}