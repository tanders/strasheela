\version "2.11.6"

\paper { 
}

\layout {
\context {
\Staff \consists "Horizontal_bracket_engraver"}}{
<<
 \new Staff { \clef violin 
 { d4 f4 a4 b4 d'4 f'4 a'4 b'4 } } 
 \new Staff { \clef "bass_29" d,,,, \breve _\markup{\column { minor with sixth } }  }
>>
}