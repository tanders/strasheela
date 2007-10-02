\version "2.11.6"

\paper { 
}

\layout {
\context {
\Staff \consists "Horizontal_bracket_engraver"}}{
<<
 \new Staff { \clef violin 
 { f'4 g'4^x a'4 ais'4^x c''4^x ais'4^x a'4 f'4 } } 
 \new Staff { \clef "bass_29" d,,,, \breve _\markup{\column { minor } }  }
>>
}