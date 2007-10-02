#!/bin/sh

# run latex/pdflatex and bibtex as usual to generate all aux files (e.g. for bibliography).

# run 

# Redirect the output to the specified directory. Stop splitting sections into separate files at this depth. you will get every footnote applied with a subsequent number, to ease readability. Put a link to the index-page in the navigation panel if there is an index. 
latex2html -dir ../../doc/StrasheelaMotivation  -numbered_footnotes -index  "../index.html" StrasheelaMotivation

# -split 2
