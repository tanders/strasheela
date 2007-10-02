
This directory contains some Strasheela application examples. Example comments assume that the examples are studied in the alphanumeric order they appear in the folder.


* How to run the examples

  This explanation aims to describe running the examples in this
  folder in such as way that they can be executed by users who do not
  know the Oz programming language yet.
   

  1. After fully installing Strasheela (including the recommendend
     optional installation steps, see the installation instructions in
     the documentation), open the example file in the OPI (i.e. Emacs)

  2. Halt Oz in case it is running (e.g. select 'Halt Oz' in the Oz
     menu or use the Emacs shortcut C-. h)

  3. Feed the buffer to the Oz compiler (e.g. select 'Feed Buffer' in
     the Oz menu or use the Emacs shortcut C-. C-b). This implicitly
     starts Oz..

  4. Move to some solver call statement at the end of the example
     (there is usually some comment like 'call solver' just before
     them). Solver calls are put in comments so they are not fed all
     at once to the compiler when the buffer is fed (a comment is a
     line starting with '%' or text surrounded by '/*' and '*/').
     Position the cursor somewhere in this statement and feed it now
     to the compiler (e.g. select Feed Paragraph in the Oz menu or use
     the Emacs shortcut C-M-x).

  5. This starts the Oz Explorer, a graphical representation of the
     search tree.

  6. Select an output format for the music produced by the CSP in the
     Oz Explorer menu Nodes: Information Action (e.g. select Csound,
     assuming you configured Csound output properly. See the
     installation instructions and the file _ozrc for details). 

  7. Produce this output by clicking on a solution node in the Oz
     Explorer (the green diamond shaped nodes). The output is saved in
     the folder you specified (see installation instructions or
     _ozrc), the default output folder is '/tmp/').

  NB: Some solver calls (e.g. in the first example,
      01-AllIntervalSeries.oz) do not start the Explorer or do not
      allow for output into score formats like Csound or
      Lilypond. Please follow the instructions given in these
      examples.


NB: This is not the only way to run the example (e.g. Oz must not be halted always before feeding an example), but this way simplifies running these examples before details of Emacs, Oz, and Strasheela are better understood ;-) 


* Further Examples

Some of the Strasheela extensions in the STRASHEELA/contribution folder contain further examples. Besides, there are several files containing many small-scale test examples (both in the STRASHEELA/testing folder and in the respective testing folder of Strasheela extensions in STRASHEELA/contribution).
 
Have fun with Strasheela!

Torsten Anders


