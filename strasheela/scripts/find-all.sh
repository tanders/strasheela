#!/bin/sh

# in all Oz source files of Strasheela, search for the occurance of some expression.
# usage: find-all <expression>
# example: find-all 'FD.int'

EXP=$1

# change to scripts directory 
cd `dirname $0`

# All Oz source files of Strasheela (including all examples)
# FILES=$(find ./test -name '*.oz' -print)
FILES=$(find .. -name '*.oz' -print)

grep $EXP $FILES

