#!/bin/bash
#
# Create Git branch, pull main, normalize .wav files with ffmpeg-normalize,
# place in new directory, convert index.md to index.html with pandocs
#
# 1. Prompt HW #
# 2. Pull 'main' into new branch (hw#)
# 3. Run ffmpeg-normalize on .wav files, save to new directory
# 4. Convert index.md to index.html with pandocs
# 5. Push to remote branch, prompt user to merge branches.
# 6. If 'y', merge branch to 'main' and delete branch, if 'n', exit.

echo A simple branch, pull, ffmpeg-normalize, .md to .html, push script!
read -p "What is the directory for this HW? " hw_name

# pull 'main' into new branch
git checkout -b $hw_name
git pull origin main

# run ffmpeg-normalize
mkdir normalized
for FILE in *.wav; do ffmpeg-normalize $FILE; done

# convert markdown to html for webpage
pandoc -f markdown -t html5 -o output.html input.md -c style.css
pandoc -s index.md -o example2.html
# delete branch after succesful merge
git checkout main
git branch -d $hw_name





