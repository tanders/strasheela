
\version "2.11.38"

\paper {
}

\layout {  
}


% begin verbatim
% Define 1/9 alterations.
#(define-public KOMA 1/9)
#(define-public BAKIYE 4/9)
#(define-public KUCUK 5/9)
#(define-public BUYUKMUCENNEB 8/9)


% Define pitch names
makamPitchNames = #`(
  (c . ,(ly:make-pitch -1 0 NATURAL))
  (d . ,(ly:make-pitch -1 1 NATURAL))
  (e . ,(ly:make-pitch -1 2 NATURAL))
  (f . ,(ly:make-pitch -1 3 NATURAL))
  (g . ,(ly:make-pitch -1 4 NATURAL))
  (a . ,(ly:make-pitch -1 5 NATURAL))
  (b . ,(ly:make-pitch -1 6 NATURAL))
  
  (cc . ,(ly:make-pitch -1 0 KOMA))
  (dc . ,(ly:make-pitch -1 1 KOMA))
  (ec . ,(ly:make-pitch -1 2 KOMA))
  (fc . ,(ly:make-pitch -1 3 KOMA))
  (gc . ,(ly:make-pitch -1 4 KOMA))
  (ac . ,(ly:make-pitch -1 5 KOMA))
  (bc . ,(ly:make-pitch -1 6 KOMA))

  (cb . ,(ly:make-pitch -1 0 BAKIYE))
  (db . ,(ly:make-pitch -1 1 BAKIYE))
  (eb . ,(ly:make-pitch -1 2 BAKIYE))
  (fb . ,(ly:make-pitch -1 3 BAKIYE))
  (gb . ,(ly:make-pitch -1 4 BAKIYE))
  (ab . ,(ly:make-pitch -1 5 BAKIYE))
  (bb . ,(ly:make-pitch -1 6 BAKIYE))

  (ck . ,(ly:make-pitch -1 0 KUCUK))
  (dk . ,(ly:make-pitch -1 1 KUCUK))
  (ek . ,(ly:make-pitch -1 2 KUCUK))
  (fk . ,(ly:make-pitch -1 3 KUCUK))
  (gk . ,(ly:make-pitch -1 4 KUCUK))
  (ak . ,(ly:make-pitch -1 5 KUCUK))
  (bk . ,(ly:make-pitch -1 6 KUCUK))

  (cbm . ,(ly:make-pitch -1 0 BUYUKMUCENNEB))
  (dbm . ,(ly:make-pitch -1 1 BUYUKMUCENNEB))
  (ebm . ,(ly:make-pitch -1 2 BUYUKMUCENNEB))
  (fbm . ,(ly:make-pitch -1 3 BUYUKMUCENNEB))
  (gbm . ,(ly:make-pitch -1 4 BUYUKMUCENNEB))
  (abm . ,(ly:make-pitch -1 5 BUYUKMUCENNEB))
  (bbm . ,(ly:make-pitch -1 6 BUYUKMUCENNEB))

  ;; f for flat.
  (cfc . ,(ly:make-pitch -1 0 (- KOMA)))
  (dfc . ,(ly:make-pitch -1 1 (- KOMA)))
  (efc . ,(ly:make-pitch -1 2 (- KOMA)))
  (ffc . ,(ly:make-pitch -1 3 (- KOMA)))
  (gfc . ,(ly:make-pitch -1 4 (- KOMA)))
  (afc . ,(ly:make-pitch -1 5 (- KOMA)))
  (bfc . ,(ly:make-pitch -1 6 (- KOMA)))
  
  (cfb . ,(ly:make-pitch -1 0 (- BAKIYE)))
  (dfb . ,(ly:make-pitch -1 1 (- BAKIYE)))
  (efb . ,(ly:make-pitch -1 2 (- BAKIYE)))
  (ffb . ,(ly:make-pitch -1 3 (- BAKIYE)))
  (gfb . ,(ly:make-pitch -1 4 (- BAKIYE)))
  (afb . ,(ly:make-pitch -1 5 (- BAKIYE)))
  (bfb . ,(ly:make-pitch -1 6 (- BAKIYE)))

  (cfk . ,(ly:make-pitch -1 0 (- KUCUK)))
  (dfk . ,(ly:make-pitch -1 1 (- KUCUK)))
  (efk . ,(ly:make-pitch -1 2 (- KUCUK)))
  (ffk . ,(ly:make-pitch -1 3 (- KUCUK)))
  (gfk . ,(ly:make-pitch -1 4 (- KUCUK)))
  (afk . ,(ly:make-pitch -1 5 (- KUCUK)))
  (bfk . ,(ly:make-pitch -1 6 (- KUCUK)))

  (cfbm . ,(ly:make-pitch -1 0 (- BUYUKMUCENNEB)))
  (dfbm . ,(ly:make-pitch -1 1 (- BUYUKMUCENNEB)))
  (efbm . ,(ly:make-pitch -1 2 (- BUYUKMUCENNEB)))
  (ffbm . ,(ly:make-pitch -1 3 (- BUYUKMUCENNEB)))
  (gfbm . ,(ly:make-pitch -1 4 (- BUYUKMUCENNEB)))
  (afbm . ,(ly:make-pitch -1 5 (- BUYUKMUCENNEB)))
  (bfbm . ,(ly:make-pitch -1 6 (- BUYUKMUCENNEB)))

)

%% set pitch names.
pitchnames = \makamPitchNames 
#(ly:parser-set-note-names parser makamPitchNames)

makamGlyphs = #'((1 . "accidentals.doublesharp")
       (8/9 . "accidentals.sharp.slashslashslash.stemstem")
       (5/9 . "accidentals.sharp.slashslashslash.stem")
       (4/9 . "accidentals.sharp")
       (1/9 . "accidentals.sharp.slashslash.stem")
       (0 . "accidentals.natural")
       (-1/9 . "accidentals.mirroredflat")
       (-4/9 . "accidentals.flat.slash")
       (-5/9 . "accidentals.flat")
       (-8/9 . "accidentals.flat.slashslash")
       (-1 . "accidentals.flatflat")
       )

\relative {

  %{ define alteration <-> symbol mapping. The following glyphs are available.
  accidentals.sharp 
  accidentals.sharp.slashslash.stem 
  accidentals.sharp.slashslashslash.stemstem 
  accidentals.sharp.slashslashslash.stem 
  accidentals.sharp.slashslash.stemstemstem 
  accidentals.natural 
  accidentals.flat 
  accidentals.flat.slash 
  accidentals.flat.slashslash 
  accidentals.mirroredflat.flat 
  accidentals.mirroredflat 
  accidentals.flatflat 
  accidentals.flatflat.slash 
  accidentals.doublesharp 
  %}

  \override Accidental #'glyph-name-alist =  \makamGlyphs
  
  \override Staff.KeySignature #'glyph-name-alist = \makamGlyphs
  \set Staff.keySignature =  #'(
    (3 .  4/9)
    (6 . -1/9))
  
  c cc db fk gbm gfc gfb efk dfbm
}




