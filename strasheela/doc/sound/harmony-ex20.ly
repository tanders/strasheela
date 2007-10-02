\version "2.11.6"

\paper { 
}

\layout {
\context {
\Staff \consists "Horizontal_bracket_engraver"}}{
<<
 \new Staff { \clef bass 
 { g2 a2 b2 e'2 } } 
 \new Staff { \clef bass 
 { e2 f2 g2 g2 } } 
 \new Staff { \clef bass 
 { c2 d2 d2 c2 } } 
 \new Staff { \clef "bass_29" 
 { c,,,,2_\markup{\column { major } }  d,,,,2_\markup{\column { minor } }  g,,,,2_\markup{\column { major } }  c,,,,2_\markup{\column { major } }  } }
>>
}