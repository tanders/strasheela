%%% created by Strasheela at 19:5, 30-6-2008

\version "2.10.0"

\layout {
    \context {
      \Score
      \override SpacingSpanner
                #'base-shortest-duration = #(ly:make-moment 1 32)
    }
  }

 \new Staff { \clef "bass_29"  
 {
  \grace {c,,,,4 d,,,,4 e,,,,4 f,,,,4 g,,,,4 a,,,,4 b,,,,} c,,,,1_\markup{\column {major } } \bar "||" \break 
 {
  \grace <c,,,, e,,,, g,,,,>4 c,,,,2_\markup{\column { 1/1 x (1/1 5/4 3/2) }} \grace <c,,,, e,,,, g,,,, a,,,,>4 c,,,,2_\markup{\column { 1/1 x (1/1 5/4 3/2 5/3) }} \grace <c,,,, e,,,, g,,,, b,,,,>4 c,,,,2_\markup{\column { 1/1 x (1/1 5/4 3/2 15/8) }} \grace <c,,,, d,,,, e,,,, g,,,, b,,,,>4 c,,,,2_\markup{\column { 1/1 x (1/1 9/8 5/4 3/2 15/8) }} \grace <c,,,, e,,,, g,,,, a,,,, b,,,,>4 c,,,,2_\markup{\column { 1/1 x (1/1 5/4 3/2 5/3 15/8) }} \grace <c,,,, d,,,, e,,,, g,,,,>4 c,,,,2_\markup{\column { 1/1 x (1/1 9/8 5/4 3/2) }} 
} \bar "||" \break 
 {
  \grace <d,,,, f,,,, a,,,,>4 d,,,,2_\markup{\column { 9/8 x (1/1 6/5 3/2) }} \grace <d,,,, f,,,, a,,,, b,,,,>4 d,,,,2_\markup{\column { 9/8 x (1/1 6/5 3/2 5/3) }} \grace <d,,,, f,,,, a,,,, c,,,,>4 d,,,,2_\markup{\column { 9/8 x (1/1 6/5 3/2 9/5) }} 
} \bar "||" \break 
 {
  \grace <e,,,, g,,,, b,,,,>4 e,,,,2_\markup{\column { 5/4 x (1/1 6/5 3/2) }} \grace <e,,,, g,,,, b,,,, d,,,,>4 e,,,,2_\markup{\column { 5/4 x (1/1 6/5 3/2 9/5) }} 
} \bar "||" \break 
 {
  \grace <f,,,, a,,,, c,,,,>4 f,,,,2_\markup{\column { 4/3 x (1/1 5/4 3/2) }} \grace <f,,,, a,,,, c,,,, d,,,,>4 f,,,,2_\markup{\column { 4/3 x (1/1 5/4 3/2 5/3) }} \grace <f,,,, a,,,, c,,,, e,,,,>4 f,,,,2_\markup{\column { 4/3 x (1/1 5/4 3/2 15/8) }} \grace <f,,,, g,,,, a,,,, c,,,, e,,,,>4 f,,,,2_\markup{\column { 4/3 x (1/1 9/8 5/4 3/2 15/8) }} \grace <f,,,, a,,,, c,,,, d,,,, e,,,,>4 f,,,,2_\markup{\column { 4/3 x (1/1 5/4 3/2 5/3 15/8) }} \grace <f,,,, g,,,, a,,,, c,,,,>4 f,,,,2_\markup{\column { 4/3 x (1/1 9/8 5/4 3/2) }} 
} \bar "||" \break 
 {
  \grace <g,,,, b,,,, d,,,,>4 g,,,,2_\markup{\column { 3/2 x (1/1 5/4 3/2) }} \grace <g,,,, b,,,, d,,,, f,,,,>4 g,,,,2_\markup{\column { 3/2 x (1/1 5/4 3/2 9/5) }} \grace <g,,,, b,,,, d,,,, e,,,,>4 g,,,,2_\markup{\column { 3/2 x (1/1 5/4 3/2 5/3) }} \grace <g,,,, a,,,, b,,,, d,,,,>4 g,,,,2_\markup{\column { 3/2 x (1/1 9/8 5/4 3/2) }} 
} \bar "||" \break 
 {
  \grace <a,,,, c,,,, e,,,,>4 a,,,,2_\markup{\column { 5/3 x (1/1 6/5 3/2) }} \grace <a,,,, c,,,, e,,,, g,,,,>4 a,,,,2_\markup{\column { 5/3 x (1/1 6/5 3/2 9/5) }} 
} \bar "||" \break 
 {
  \grace <b,,,, d,,,, f,,,,>4 b,,,,2_\markup{\column { 15/8 x (1/1 6/5 10/7) }} 
} 
} }

}