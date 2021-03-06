#!/bin/sh
#
# upgrade-all.sh - upgrades all components (ie. functors) of
# Strasheela using ozmake
# 
# Usage: upgrade-all.sh [options]
#
# The options are just forwarded to ozmake, so basically all its options
# are supported. However, ozmake is always called with the option
# --upgrade in a directory with a file makefile.oz. For details see
# http://www.mozart-oz.org/documentation/mozart-ozmake/index.html


# change to scripts directory 
cd `dirname $0`
echo "cd \$StrasheelaDir/source; ozmake --upgrade" "$@"
cd ..
ozmake --upgrade "$@"


# find all contribution makefiles, move into their dir and issue ozmake
cd contributions
MAKEFILES=$(find . -name 'makefile.oz' -print)

for FILE in $MAKEFILES
do
  echo "cd \$StrasheelaDir/contributions/$(dirname $FILE); ozmake --upgrade"  "$@"
  # $FILE is relative path, thus I use subshell (put in parentheses)
  # where cd has only local effect
  (cd $(dirname $FILE); 
      ozmake --upgrade "$@")
done

