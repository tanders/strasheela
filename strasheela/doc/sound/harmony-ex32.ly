\version "2.11.6"

\paper { 
}

\layout {
\context {
\Staff \consists "Horizontal_bracket_engraver"}}{
<<
 \new Staff { \clef bass 
 { fis4 a4 g4^x fis4 g4^x a4 b4^x cis'4 b4^x a4 a4 d4 e4^x fis4^x g4 fis4^x e4^x d4 fis4 g4^x a4 a4 fis4 d4 } } 
 \new Staff { \clef bass r1
 { cis4 e4 d4^x cis4 a4 b4^x cis'4^x d'4 cis'4^x b4 b4 g4 a4^x b4 fis4 d4 fis4 d4 d4 a4 } } 
 \new Staff { \clef bass r \breve 
 { a4 fis'4 a4 fis4 b4 g'4 a'4^x b'4 b4 fis4 fis4 e4^x d4 e4^x fis4 fis4 } } 
 \new Staff { \clef "bass_29" 
 { d,,,,1_\markup{\column { maj } }  a,,,,1_\markup{\column { maj } }  d,,,,1_\markup{\column { maj } }  g,,,,1_\markup{\column { maj } }  b,,,,1_\markup{\column { min } }  d,,,,1_\markup{\column { maj } }  } }
>>
}