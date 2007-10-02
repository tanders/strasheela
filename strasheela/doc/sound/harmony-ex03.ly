\version "2.11.6"

\paper { 
}

\layout {
\context {
\Staff \consists "Horizontal_bracket_engraver"}}{
<<
 \new Staff { \clef violin 
 { a4 b4 f4 d4 a'4 b'4 f'4 d'4 } } 
 \new Staff { \clef "bass_29" d,,,, \breve _\markup{\column { minor with sixth } }  }
>>
}