#! /bin/sh

#
# this script creates the documentation for Strasheela and all its contributions by calling ozh
#

#
# NB: this script makes use of the outdated mozart version 1.2.5 to run ozh (which has yet not been ported to mozart 1.3.*) . 
# For this purpose, the script simply extends the PATH env var by the installation path of mozart version 1.2.5 -- as it has been installed locally on my development machine!
#
# NB: Required Contribution Coding Convention: For each Strasheela contribution (each subfolder in \$StrasheelaDir/contributions/ with an own 'makefile.oz'), the script calls ozh on EACH *.oz file in the contribution folder. Therefore, there should be only a single top-level file in the root of the contribution dir (e.g. further functors can be contained in some source sub-dir).
#
# NB: The documentation in Strasheela/doc-source is (presently) not rendered with this script (in principle, this could be added using the script MUSEDIR/scripts/publish)  
# 

# #echo "change to mozart version 1.2.5" 
# ## shadow new mozart 1.3.1 (installed by rpm) with my own compile of mozart 1.2.5 because ozh does not work in the current version
# #export PATH=/home/t/oz/mozart-install/bin::$PATH # my own compile
# #export PATH=/home/t/.oz/bin:$PATH


# change to scripts directory 
cd `dirname $0`
echo "rm ../doc/api/*.html; rm ../doc/api/*.gif; ozh ../Strasheela.oz -o ../doc/api/"
rm ../doc/api/*.html
rm ../doc/api/*.gif
ozh ../Strasheela.oz -o ../doc/api/  #  --stylesheet=ozdoc-edit.css

# find all contribution makefiles, move into their dir and generate the documentation for each *.oz file in the directory (this should be only a single one!)
cd ../contributions
MAKEFILES=$(find . -name 'makefile.oz' -print)

for FILE in $MAKEFILES
  do
  echo "cd \$StrasheelaDir/contributions/$(dirname $FILE)"
  # $FILE is relative path, thus I use subshell (put in parentheses)
  # (cd $(dirname $FILE); ozmake --upgrade)
  (cd $(dirname $FILE)
      echo "rm doc/*.html; rm doc/*.gif" 
      rm doc/*.html
      rm doc/*.gif
      for OZFILE in $(ls *.oz | grep -v makefile.oz)
	do
	echo "ozh $OZFILE -o doc/"
	ozh $OZFILE -o doc/
	done)
done

