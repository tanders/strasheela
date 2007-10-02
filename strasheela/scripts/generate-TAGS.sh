#!/bin/sh

# I only want contribution source files, no tests etc..
# i.e. *.oz files directly contained in a contributions root dir or in contributions source dir

cd "`dirname "$0"`/.."

find ./source ./contributions -name '*.oz' | xargs etags \
    --regex='/[ \t]*\(fun\|proc\)[ \t]+{\([^ \t$}]+\)/\2/' \
    --regex='/[ \t]*meth[ \t]+\([^ \t()]+\)/\1/'

echo "Wrote $PWD/TAGS for emacs"

