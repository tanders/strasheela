#!/bin/sh

echo "Formatting $1"
cd `dirname "$0"`
emacs --load=ozindent.el --eval="(ozindent \"$1\")" --kill --batch
