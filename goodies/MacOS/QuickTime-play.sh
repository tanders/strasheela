#!/bin/sh

#
# USAGE: 
#
#   Quicktime-play myFile
#
#   Starts quicktime player (if not already open), then opens and plays
#   file given as first argument (e.g. a sound file or a midi file).
# 
# NB: this script runs only on MacOS (where osascript and the
# QuickTime Player are both installed by default)
#


# osascript executes the applescript which follows up to the end of this file. Shell variables (e.g. $1) are replaced by their value. 
exec osascript <<EOF
  tell app "QuickTime Player"
    activate
    open POSIX file "$1"
  end tell
