\version "2.7.40"

\paper { 
}

\layout {
\context {
\Staff \consists "Horizontal_bracket_engraver"}}{
<<
 \new Staff { \clef violin 
 { d'4. f'4 g'8^x a'4. d'4. e'8^x f'4. a'2 d'4. f'4. g'8^x a'4. } } 
 \new Staff { \clef "bass_29" d,,,, \breve _\markup{\column { minor } } d,,,,1.._\markup{\column { minor } }  }
>>
}