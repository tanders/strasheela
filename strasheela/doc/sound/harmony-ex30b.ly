\version "2.11.6"

\paper { 
}

\layout {
\context {
\Staff \consists "Horizontal_bracket_engraver"}}{
<<
 \new Staff { \clef violin 
 { d'4 fis'4 a'4 d'4 d'4 g'4 b'4 d'4 d'4 fis'4 b'4 d'4 d'4 fis'4 a'4 fis'4 } } 
 \new Staff { \clef "bass_29" 
 { d,,,,1_\markup{\column { maj } }  g,,,,1_\markup{\column { maj } }  b,,,,1_\markup{\column { min } }  d,,,,1_\markup{\column { maj } }  } }
>>
}