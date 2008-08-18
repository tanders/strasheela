#!/bin/sh
#
# clean-all.sh - installs all components (ie. functors) of
# Strasheela using ozmake
# 
# Usage: clean-all.sh [options]
#
# The options are just forwarded to ozmake, so basically all its options
# are supported. However, ozmake is always called with the option
# --clean in a directory with a file makefile.oz. For details see
# http://www.mozart-oz.org/documentation/mozart-ozmake/index.html

#
# TODO: ozmake --clean does not work recursively (e.g., nested source/ dirs are omitted). But it works doing ozmake --clean explicitly in nested dirs. So, I should add that..
#

# change to scripts directory 
cd `dirname $0`
echo "cd \$StrasheelaDir; ozmake --clean" "$@"
cd ..
ozmake --clean "$@"
# cd source
# ozmake --clean "$@"


# find all makefiles in ../contributions, move into their dir and issue ozmake
cd contributions
MAKEFILES=$(find . -name 'makefile.oz' -print)

for FILE in $MAKEFILES
do
  echo "cd \$StrasheelaDir/contributions/$(dirname $FILE); ozmake --clean" "$@"
  # $FILE is relative path, thus I use subshell (put in parentheses)
  # where cd has only local effect
  (cd $(dirname $FILE); ozmake --clean "$@")
done

