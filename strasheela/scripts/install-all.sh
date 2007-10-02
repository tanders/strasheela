#!/bin/sh
#
# install-all.sh - installs all components (ie. functors) of
# Strasheela using ozmake
# 
# Usage: install-all.sh [options]
#
# The options are just forwarded to ozmake, so basically all its options
# are supported. However, ozmake is always called with the option
# --install in a directory with a file makefile.oz. For details see
# http://www.mozart-oz.org/documentation/mozart-ozmake/index.html

# change to scripts directory 
cd `dirname $0`

# first install tmp Path contribution
echo "cd \$StrasheelaDir/contributions/tmp/Path; ozmake --install" "$@"
cd ../contributions/tmp/Path
ozmake --install "$@"

echo "cd \$StrasheelaDir/; ozmake --install" "$@"
cd ../../..
# cd ../source
ozmake --install "$@"

# find all makefiles in contributions, move into their dir and issue ozmake
#
# .. except for the Path contribution (NB: this may remove other
# contributions which accidentially contain the word Path)
cd contributions
MAKEFILES=$(find . -name 'makefile.oz' -print | sed /Path/d)

for FILE in $MAKEFILES
do
  echo "cd \$StrasheelaDir/contributions/$(dirname $FILE); ozmake --install" "$@"
  # $FILE is relative path, thus I use subshell (put in parentheses)
  # where cd has only local effect
  (cd $(dirname $FILE); ozmake --install "$@")
done

