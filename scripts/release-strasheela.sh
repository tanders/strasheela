#!/bin/sh

# This script creates a tar-ball release of Strasheela. Expects the
# version as argument (e.g. 0.7) and stores all files in the
# strasheela directory which should be part of a release (e.g. skims
# files such as *~ or subversion data).
#
# TODO: change top-level dir name strasheela into strasheela-$VERSION
#
# Problem: some files in my strasheela dir are not added to the subversion repository (like directories labeled "old"), but they will be included in the release.  I don't want to have them in the release, however.
# Idea to work around this: instead of this script, use subversion tags to denote releases. In that case, however, I must include and update all files which I want to have in the repository (like the file CHANGELOG.txt, which presently is not part of the repository).  
#

VERSION=$1

# change to scripts directory 
cd `dirname $0`

# move into top-level strasheela directory
cd ..

# create CHANGELOG: 
# NB: I first have to do 'svn update' in order to get my local copy in sync with the resposity
# svn update
svn -v log > CHANGELOG.txt

# move into directory above strasheela
cd ..

# create tar (take VERSION as argument)
# tar -cvzf - `find strasheela -type f \! \( -name "*~" -o -name "*.ozf" \) -print | sed /.svn/d -` > strasheela-withSounds-$VERSION.tar.gz


#
# NB: for some reason, I had to remove the trailing - (i.e. hyphen)
# from sed call on MacOS. I have no idea why it worked before on
# Linux, but not on Mac. But this version seems to work on both Linux
# and Mac..
#

# create tar, only of the essential files (take VERSION as argument)
tar -cvzf - `find strasheela -type f \! \( -name "*~" -o -name ".*~" -o -name "*.ozf" -o -name "*.o" -o -name "*.lo" -o -name "*.la" -o -name " #*#" -o -name ".DS_Store" -o -name "*.exe" -o -name "*.fasl" -o -name "*.wav" -o -name "*.aiff" -o -name "*.mp3" -o -name "*.mid" -o -name "*.midi" -o -name "*.ly" -o -name "*.log" -o -name "*.ps" -o -name "*.eps" -o -name "*.pdf" \) -print | sed /.svn/d` > strasheela-$VERSION.tar.gz

# create tar for the essential files plus the mp3 and midi files (take VERSION as argument)
tar -cvzf - `find strasheela -type f \! \( -name "*~" -o -name ".*~" -o -name "*.ozf" -o -name "*.o" -o -name "*.lo" -o -name "*.la" -o -name " #*#" -o -name ".DS_Store" -o -name "*.exe" -o -name "*.fasl" -o -name "*.wav" -o -name "*.aiff" -o -name "*.ly" -o -name "*.log" -o -name "*.ps" -o -name "*.eps" -o -name "*.pdf" \) -print | sed /.svn/d` > strasheela-withSound-$VERSION.tar.gz

# # create tar, only of the essential files (take VERSION as argument)
# tar -cvzf - `find strasheela -type f \! \( -name "*~" -o -name ".*~" -o -name "*.ozf" -o -name "*.o" -o -name "*.lo" -o -name "*.la" -o -name " #*#" -o -name ".DS_Store" -o -name "*.exe" -o -name "*.fasl" -o -name "*.wav" -o -name "*.aiff" -o -name "*.mp3" -o -name "*.mid" -o -name "*.midi" -o -name "*.ly" -o -name "*.log" -o -name "*.ps" -o -name "*.eps" -o -name "*.pdf" \) -print | sed /.svn/d -` > strasheela-$VERSION.tar.gz
#
# # create tar for the essential files plus the mp3 and midi files (take VERSION as argument)
# tar -cvzf - `find strasheela -type f \! \( -name "*~" -o -name ".*~" -o -name "*.ozf" -o -name "*.o" -o -name "*.lo" -o -name "*.la" -o -name " #*#" -o -name ".DS_Store" -o -name "*.exe" -o -name "*.fasl" -o -name "*.wav" -o -name "*.aiff" -o -name "*.ly" -o -name "*.log" -o -name "*.ps" -o -name "*.eps" -o -name "*.pdf" \) -print | sed /.svn/d -` > strasheela-withSound-$VERSION.tar.gz


#
# test
#
# lists all files (no dirs) in . except those which (i) match *~, (ii) *.ozf, or (iii) somewhere in their name contain '.svn'
# find . -type f \! \( -name "*~" -o -name "*.ozf" \) -print | sed /.svn/d - > ../test.log
# find . -type f \( -name "*~" \) -print 

