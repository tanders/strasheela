#!/bin/sh

# I only want contribution source files, no tests etc..
# i.e. *.oz files directly contained in a contributions root dir or in contributions source dir

#
# TODO: 
#
# - add full Oz source code
# - automatically edit resulting TAGS file (with Perl?): for each source file replace all plain tag names (variable names) with the var names preceeded by the functor name. The functor name is deduced from the source file: the functor name for a given source file is either told explicitly or automatically deduced from the name. Example replacing automatically created entries like the following (some chars not shown here!). Exception: class methods.
#
# source/Test.oz,1165
#    fun {FooFoo56,1566
# ...
#
# with this
#
# source/Test.oz,1165
#    fun {FootTest.foo56,1566
# ...
#
#
# approach for transforming TAGS file: 
# read and write file unchanged except noted otherwise 
# regex: for each line with text starting at begining of line: update stateful var with current functor
#   .. details
# regex: for each line starting wiith fun or proc: add functor prefix to var tag and turn tag to downcase
#   .. details  
#
#
#
#

cd "`dirname "$0"`/.."

find ./source ./contributions -name '*.oz' | xargs etags \
    --regex='/[ \t]*\(fun\|proc\)[ \t]+{\([^ \t$}]+\)/\2/' \
    --regex='/[ \t]*meth[ \t]+\([^ \t()]+\)/\1/'

echo "Wrote $PWD/TAGS for emacs"

