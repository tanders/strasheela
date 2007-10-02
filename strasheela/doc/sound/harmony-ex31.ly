\version "2.11.6"

\paper { 
}

\layout {
\context {
\Staff \consists "Horizontal_bracket_engraver"}}{
<<
 \new Staff { \clef bass 
 { d4 a4 fis4 g4^x a4^x b4 g4 a4^x b4 a4^x g4^x fis4 a4 fis4 d4 d4 } } 
 \new Staff { \clef bass 
 { fis4 a4 fis4 a4 b4 g4 b4 b4 fis4 g4^x a4^x b4 d4 a4 a4 d4 } } 
 \new Staff { \clef bass 
 { a4 b4^x cis'4^x d'4 b4 a4^x g4 g4 fis4 b4 d4 e4^x fis4 a4 fis4 fis4 } } 
 \new Staff { \clef "bass_29" 
 { d,,,,1_\markup{\column { maj } }  g,,,,1_\markup{\column { maj } }  b,,,,1_\markup{\column { min } }  d,,,,1_\markup{\column { maj } }  } }
>>
}