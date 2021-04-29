#!/bin/bash
#
# A script to take a HW repository for Music 220A, make a new Git branch,
# and pull the code from main to the HW branch.
# Then ssh to sebaxj@ccrma-gate.stanford.edu. Then, the new git commits
# are pulled to the CCMRA mirror of the local directory. 
# 
# ffmpeg-normalize is run on the .wav files and the modified version replaces
# the original.
#
# The Markdown file index.md is converted to index.html using pandoc
#
# The new changes are commited and pushed back to the HW banch.
#
# The changes are pulled to the HW branch on the local machine and the webpage
# is opened locally. 
#
# The changes are reviewed, and if determined alright (probe y/n), y pushes
# HW branch to main, deleted HW branch, pulls main to CCRMA main, deletes HW
# branch. If n, script stops.

say Hello.
