
This is the README for Strasheela. Strasheela is a constraint-based
computer aided composition system.

The Strasheela user creates music by writing a very high-level
description of the intended result. The Strasheela user defines a
music theory by specifying three different information aspects  

  * What is already known about the music (e.g. the number of voices
    in the score, the number of notes per voice, or the duration of
    the full score). This information is expressed by a score
    representation instance.

  * What is not yet known (e.g. the pitches of all the notes).  This
    information is expressed as variables (i.e. unknowns) in the score
    representation.

  * What conditions the variables must fulfil in a solution. This
    information is expressed by compositional rules (implemented by
    constraints, i.e. logic relations between variables) which are
    applied to the score.

The system then creates music which complies this theory. This music
can be output into various formats including MIDI, Csound, and
Lilypond.

Strasheela is build on top of the multi-paradigm programming language
Oz (see www.mozart-oz.org). The language Oz is also used as the user
interface of Strasheela. 

Strasheela runs on all operation systems supported by Oz, that is
Unix-like systems (e.g. Linux, MacOS X) and MS Windows.

Documentation and installation instructions are provided in the folder
Strasheela/doc. This release of the software comes with a few examples
(see folder Strasheela/examples), and a few orthogonal Strasheela
extensions together with their documentation and examples (see folder
Strasheela/contributions).

Strasheela is hosted at Sourceforge (http://strasheela.sourceforge.net/), 
and Sourceforge also provides Strasheela's mailing lists (please visit	
https://sourceforge.net/mail/?group_id=167225).

Strasheela is released under the GNU copyleft Software License. See
gpl.text for the terms of this agreement.

Please feel free to contact me with questions, bug reports, and
suggestions (my email address can be found at www.torsten-anders.de).

Have fun with Strasheela!

Torsten Anders
www.torsten-anders.de

