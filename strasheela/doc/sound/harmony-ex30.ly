\version "2.11.6"

\paper { 
}

\layout {
\context {
\Staff \consists "Horizontal_bracket_engraver"}}{
<<
 \new Staff { \clef violin 
 { e'4 g'4 c'4 c''4 gis'4 b'4 gis'4 b'4 gis'4 c''4 gis'4 c''4 c'4 e'4 c'4 c''4 } } 
 \new Staff { \clef "bass_29" 
 { c,,,,1_\markup{\column { maj } }  e,,,,1_\markup{\column { maj } }  gis,,,,1_\markup{\column { maj } }  c,,,,1_\markup{\column { maj } }  } }
>>
}