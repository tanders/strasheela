\version "2.11.6"

\paper { 
}

\layout {
\context {
\Staff \consists "Horizontal_bracket_engraver"}}{
<<
 \new Staff { \clef violin 
 { a'4 g'4^x f'4 g'4^x a'4 f'4 d'4 e'4^x f'4 e'4^x d'4 f'4 } } 
 \new Staff { \clef "bass_29" d,,,, \breve _\markup{\column { minor } } d,,,,1_\markup{\column { minor } }  }
>>
}