\version "2.11.6"

\paper { 
}

\layout {
\context {
\Staff \consists "Horizontal_bracket_engraver"}}{
<<
 \new Staff { \clef violin 
 { a'4 f'4 a'4 a'4 a'4 f'4 f'4 a'4 } } 
 \new Staff { \clef violin 
 { f'4 f'4 f'4 a'4 f'4 f'4 a'4 a'4 } } 
 \new Staff { \clef violin 
 { a'4 a'4 d'4 a'4 d'4 f'4 d'4 a'4 } } 
 \new Staff { \clef bass d \breve  } 
 \new Staff { \clef "bass_29" d,,,, \breve _\markup{\column { minor } }  }
>>
}