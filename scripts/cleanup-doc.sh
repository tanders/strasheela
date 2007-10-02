#!/bin/sh

# remove all temporary files in the doc folder, such as *.wav, *.ly etc  

# for now I move into specific dirs explicitly. Later I may use find to traverse doc directory tree to search for files to delete (cf. find-all.sh)

# change to scripts directory 
cd `dirname $0`
cd ../doc/sound

rm *~
rm *.wav
rm *.aiff
rm *.ps
rm *.eps
rm *.pdf
# keep lily files for now...
# rm *.ly 


