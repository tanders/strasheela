#!/bin/sh

# NB: This script once destroyed Strasheela, be careful! 
# ALWAYS DO A BACKUP FIRST BEFORE UNSING THIS SCRIPT
#
# Refactoring script: in all Oz source files of Strasheela, replace all occurances of $OLDEXPR by $NEWEXPR 
# Usage: replace-all <old-expr> <new-expr>
# Example: replace-all 'Pattern.forAllNeighbours' 'Pattern.forNeighbours'
#
# NB: sed special characters (e.g. '/') must be escaped (e.g. '\/')

#
# IMPORTANT: use script on svn reposity with no changes compared with central reposity. Then you can always undo..
#

# set expressions to replace
OLDEXPR=$1
NEWEXPR=$2

# change to scripts directory 
cd `dirname $0`

# all Oz source files of Strasheela (including all examples)
# FILES=$(find ./test -name '*.oz' -print)
FILES=$(find .. -name '*.oz' -print)

# !!?? With grep filter only files to change?

for FILE in $FILES;
  do
  # create an empty tmp output file TMPFILE, write output of sed
  # linewise into TMPFILE, finally cp TMPFILE onto FILE
  echo "processing $FILE"
  TMPFILE="../tmpfile"
#  echo "" > $TMPFILE # writes a single empty line into $TMPFILE
  rm $TMPFILE
  touch $TMPFILE
  sed "s/$OLDEXPR/$NEWEXPR/g" $FILE >> $TMPFILE 
  cp $TMPFILE $FILE
done


# see http://sed.sourceforge.net/grabbag/tutorials/
#
# substitute (find & replace) "foo" with "bar" on each line
#   sed 's/foo/bar/'             # replaces only 1st instance in a line
#   sed 's/foo/bar/4'            # replaces only 4th instance in a line
#   sed 's/foo/bar/g'            # replaces ALL instances in a line

