%%% created by Strasheela at 19:5, 30-6-2008

\version "2.10.0"

\layout {
    \context {
      \Score
      \override SpacingSpanner
                #'base-shortest-duration = #(ly:make-moment 1 32)
    }
  }
 
 <<   
 \new Staff { \clef violin  
 {
  
 <c c' e' g'>1 
 <c c' e' g' a'>1 
 <c c' e' g' b'>1 
 <c c' d' e' g' b'>1 
 <c c' e' g' a' b'>1 
 <c c' d' e' g'>1 
 <d d' f' a'>1 
 <d d' f' a' b'>1 
 <d c' d' f' a'>1 
 <e e' g' b'>1 
 <e d' e' g' b'>1 
 <f c' f' a'>1 
 <f c' d' f' a'>1 
 <f c' e' f' a'>1 
 <f c' e' f' g' a'>1 
 <f c' d' e' f' a'>1 
 <f c' f' g' a'>1 
 <g d' g' b'>1 
 <g d' f' g' b'>1 
 <g d' e' g' b'>1 
 <g d' g' a' b'>1 
 <a c' e' a'>1 
 <a c' e' g' a'>1 
 <b d' f' b'>1 
} } 
 \new Staff { \clef "bass_29"  
 {
  \grace <c,,,, e,,,, g,,,,>4 c,,,,1_\markup{\column { 1/1 x (1/1 5/4 3/2) }} \grace <c,,,, e,,,, g,,,, a,,,,>4 c,,,,1_\markup{\column { 1/1 x (1/1 5/4 3/2 5/3) }} \grace <c,,,, e,,,, g,,,, b,,,,>4 c,,,,1_\markup{\column { 1/1 x (1/1 5/4 3/2 15/8) }} \grace <c,,,, d,,,, e,,,, g,,,, b,,,,>4 c,,,,1_\markup{\column { 1/1 x (1/1 9/8 5/4 3/2 15/8) }} \grace <c,,,, e,,,, g,,,, a,,,, b,,,,>4 c,,,,1_\markup{\column { 1/1 x (1/1 5/4 3/2 5/3 15/8) }} \grace <c,,,, d,,,, e,,,, g,,,,>4 c,,,,1_\markup{\column { 1/1 x (1/1 9/8 5/4 3/2) }} \grace <d,,,, f,,,, a,,,,>4 d,,,,1_\markup{\column { 9/8 x (1/1 6/5 3/2) }} \grace <d,,,, f,,,, a,,,, b,,,,>4 d,,,,1_\markup{\column { 9/8 x (1/1 6/5 3/2 5/3) }} \grace <d,,,, f,,,, a,,,, c,,,,>4 d,,,,1_\markup{\column { 9/8 x (1/1 6/5 3/2 9/5) }} \grace <e,,,, g,,,, b,,,,>4 e,,,,1_\markup{\column { 5/4 x (1/1 6/5 3/2) }} \grace <e,,,, g,,,, b,,,, d,,,,>4 e,,,,1_\markup{\column { 5/4 x (1/1 6/5 3/2 9/5) }} \grace <f,,,, a,,,, c,,,,>4 f,,,,1_\markup{\column { 4/3 x (1/1 5/4 3/2) }} \grace <f,,,, a,,,, c,,,, d,,,,>4 f,,,,1_\markup{\column { 4/3 x (1/1 5/4 3/2 5/3) }} \grace <f,,,, a,,,, c,,,, e,,,,>4 f,,,,1_\markup{\column { 4/3 x (1/1 5/4 3/2 15/8) }} \grace <f,,,, g,,,, a,,,, c,,,, e,,,,>4 f,,,,1_\markup{\column { 4/3 x (1/1 9/8 5/4 3/2 15/8) }} \grace <f,,,, a,,,, c,,,, d,,,, e,,,,>4 f,,,,1_\markup{\column { 4/3 x (1/1 5/4 3/2 5/3 15/8) }} \grace <f,,,, g,,,, a,,,, c,,,,>4 f,,,,1_\markup{\column { 4/3 x (1/1 9/8 5/4 3/2) }} \grace <g,,,, b,,,, d,,,,>4 g,,,,1_\markup{\column { 3/2 x (1/1 5/4 3/2) }} \grace <g,,,, b,,,, d,,,, f,,,,>4 g,,,,1_\markup{\column { 3/2 x (1/1 5/4 3/2 9/5) }} \grace <g,,,, b,,,, d,,,, e,,,,>4 g,,,,1_\markup{\column { 3/2 x (1/1 5/4 3/2 5/3) }} \grace <g,,,, a,,,, b,,,, d,,,,>4 g,,,,1_\markup{\column { 3/2 x (1/1 9/8 5/4 3/2) }} \grace <a,,,, c,,,, e,,,,>4 a,,,,1_\markup{\column { 5/3 x (1/1 6/5 3/2) }} \grace <a,,,, c,,,, e,,,, g,,,,>4 a,,,,1_\markup{\column { 5/3 x (1/1 6/5 3/2 9/5) }} \grace <b,,,, d,,,, f,,,,>4 b,,,,1_\markup{\column { 15/8 x (1/1 6/5 10/7) }} 
} } 
>>

}