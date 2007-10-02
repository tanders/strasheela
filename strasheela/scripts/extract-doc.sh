#!/bin/sh
#
# extract-doc.sh - extracts all documentation files from Strasheela
#
# Usage: extract-doc.sh path 
#
# path is the directory where the extracted documentation is
# stored. This directory is implicitly created, if necessary.
# 
# Warning: only the doc directories are extracted. The Strasheela
# documentation sometimes links to files which are not stored in any
# documentation directory (e.g., to STRASHEELADIR/_ozrc or to the dir
# STRASHEELADIR/contributions/ExtensionTemplate). These links will be
# broken.

# change to scripts directory 
echo "cd `dirname $0`"
cd `dirname $0`

DIR=$1

if test ! -e $DIR
then 
    mkdir -p $DIR
fi

echo "cp -R ../doc $DIR"
cp -R ../doc $DIR
echo "cp -R ../examples $DIR"
cp -R ../examples $DIR
echo "cp -R ../testing $DIR"
cp -R ../testing $DIR

cd ../contributions
MAKEFILES=$(find . -name 'makefile.oz' -print | sed /Path/d)

for FILE in $MAKEFILES
do
    echo "cp -R contributions/$(dirname $FILE)/doc $DIR/contributions/$FILEDIR"
    mkdir -p $DIR/contributions/$(dirname $FILE)
    cp -R $(dirname $FILE)/doc $DIR/contributions/$(dirname $FILE)
    # if dir testing or examples exists, copy these as well
    if test -d $(dirname $FILE)/examples
    then 
	echo "cp -R contributions/$(dirname $FILE)/examples $DIR/contributions/$FILEDIR"
	cp -R $(dirname $FILE)/examples $DIR/contributions/$(dirname $FILE)
    fi
    if test -d $(dirname $FILE)/testing
    then 
	echo "cp -R contributions/$(dirname $FILE)/testing $DIR/contributions/$FILEDIR"
	cp -R $(dirname $FILE)/testing $DIR/contributions/$(dirname $FILE)
    fi
done

