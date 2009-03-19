\version "2.11.6"

\paper { 
}

\layout {
\context {
\Staff \consists "Horizontal_bracket_engraver"}}{
<<
 \new Staff { \clef violin 
 { fis'4 fis'4 a'4 a'4 fis'4 a'4 d'4 fis'4 d'4 fis'4 d'4 a'4 } } 
 \new Staff { \clef "bass_29" d,,,, \breve _\markup{\column { major } } d,,,,1_\markup{\column { major } }  }
>>
}