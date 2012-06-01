#!/bin/sh
#
# reinstall-all.sh - first uninstalls and then again installs all components (ie. functors) of
# Strasheela using ozmake (e.g., for conveniently switching git branches)
# 
# Usage: reinstall-all.sh [options]
#
# The options are just forwarded to ozmake, so basically all its options
# are supported. However, ozmake is always called with the option
# --uninstall (or --install respectively) in a directory with a file makefile.oz. For details see
# http://www.mozart-oz.org/documentation/mozart-ozmake/index.html

# change first to scripts directory 
cd `dirname $0`
./uninstall-all.sh "$@"
cd `dirname $0`
./install-all.sh "$@"