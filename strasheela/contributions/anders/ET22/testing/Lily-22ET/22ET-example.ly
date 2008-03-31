
%%
%% TODO
%%
%% - improve/replace grobs for accidentals
%%   - find two suitable comma signs (both up and down)
%%   - combine sharp/flat and comma sign
%%
%%

%%
%% info material
%%

% feta font overview: 
% http://www.lilypond.org/doc/v2.11/Documentation/user/lilypond/The-Feta-font.html
 

% possibly two suitable comma signs (not ideal, though)
%
% "flags.ugrace"
% "flags.dgrace"


%  %{ define alteration <-> symbol mapping. The following glyphs are available.
%   accidentals.sharp 
%   accidentals.sharp.slashslash.stem 
%   accidentals.sharp.slashslashslash.stemstem 
%   accidentals.sharp.slashslashslash.stem 
%   accidentals.sharp.slashslash.stemstemstem 
%   accidentals.natural 
%   accidentals.flat 
%   accidentals.flat.slash 
%   accidentals.flat.slashslash 
%   accidentals.mirroredflat.flat 
%   accidentals.mirroredflat 
%   accidentals.flatflat 
%   accidentals.flatflat.slash 
%   accidentals.doublesharp 
%   %}


% #(make-musicglyph-markup "scripts.rvarcomma")


% \override context.layout_object #'layout_property = #value


%% TODO: try whether I can use / and \\ in pitch names.., alt try | and !
%% TODO: make pitch names below consistent..



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\version "2.11.43"

\paper {
}
\layout {  
}

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


  ;; f for flat.
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


etTwentytwoGlyphs = #'((1 . "accidentals.doublesharp")
;       (5/6 . "accidentals.sharp.slashslashslash.stemstem")
;       (4/6 . "accidentals.sharp.slashslashslash.stemstem")
       (1/2 . "accidentals.sharp")
       (1/3 . "accidentals.sharp.slashslashslash.stem")
       (1/6 . "accidentals.sharp.slashslash.stem")
;       (1/6 . "scripts.upedaltoe")
;       (1/6 . "plus")
       (0 . "accidentals.natural")
;       (-1/6 . "hyphen")
;       (-1/6 . "scripts.dpedaltoe")
       (-1/3 . "accidentals.flat.slash")
       (-1/6 . "accidentals.flat.slashslash")
       (-1/2 . "accidentals.flat")
;       (-4/6 . "accidentals.flat.slashslash")
;       (-5/6 . "accidentals.flat.slashslash")
       (-1 . "accidentals.flatflat")
       )
% etTwentytwoGlyphs = #'((1 . "accidentals.doublesharp")
% ;       (5/6 . "accidentals.sharp.slashslashslash.stemstem")
% ;       (4/6 . "accidentals.sharp.slashslashslash.stemstem")
%        (1/2 . "accidentals.sharp")
%        (1/3 . "accidentals.sharp.slashslashslash.stemstem")
%        (1/6 . "scripts.rvarcomma")
%        (0 . "accidentals.natural")
%        (-1/6 . "scripts.lvarcomma")
%        (-1/3 . "accidentals.flat.slashslash")
%        (-1/2 . "accidentals.flat")
% ;       (-4/6 . "accidentals.flat.slashslash")
% ;       (-5/6 . "accidentals.flat.slashslash")
%        (-1 . "accidentals.flatflat")
%        )

\relative {

  \override Accidental #'glyph-name-alist =  \etTwentytwoGlyphs
  
  \override Staff.KeySignature #'glyph-name-alist = \etTwentytwoGlyphs
  \set Staff.keySignature =  #'(
    (3 .  1/3)
    (6 . -1/6))
  
   c ccu cscd cs d dcd dfcu df c 
}



% "flags.ugrace"
% "flags.dgrace"
