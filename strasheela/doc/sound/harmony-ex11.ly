\version "2.11.6"

\paper { 
}

\layout {
\context {
\Staff \consists "Horizontal_bracket_engraver"}}{
<<
 \new Staff { \clef violin 
 { a4 a4 a'4 a4 d'4 d'4 d''4 d'4 f'4 f'4 d''4 a4 a'4 a'4 d''4 a4 } } 
 \new Staff { \clef bass 
 { f4 f4 d'4 f4 a4 a4 a'4 a4 d'4 d'4 a'4 f4 f'4 f'4 a'4 f4 } } 
 \new Staff { \clef bass 
 { d4 e4^x f4 d4 e4^x f4 f'4 f4 g4^x a4 f'4 d4 d'4 e'4^x f'4 d4 } } 
 \new Staff { \clef "bass_29" d,,,, \longa _\markup{\column { minor } }  }
>>
}