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
read -p "What is the brnach name for this HW? " hw_name
read -p "What is the directory I should look for this HW in ? " dir_name

# pull remote branch into new branch
git checkout -b $hw_name
git branch --set-upstream-to origin/$hw_name
git pull origin $hw_name
cd $dir_name

# run ffmpeg-normalize
cd wav
for FILE in *.wav; do ffmpeg-normalize $FILE -ext wav; done
cd ..

read -p "Choose a page title for the converted HTML webpage: " page_name
# convert markdown to html for webpage
pandoc -s -c ../../../css/style.css index.md -o index.html --metadata pagetitle="$page_name"

# push to remote, prompt user to pull and merge
git status
git add .
git status
read -p "Add a message for this commit: " commit_mes
git commit -m "$commit_mes"
git push origin $hw_name
#
while true; do
    read -p "Pull and merge $hw_name to main? " yn
    case $yn in
        [Yy]* ) echo Checking branch $hw_name is up-to-date...; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
#
# check for changes from host side, pull to ccrma dev branch, merge, delete dev
git checkout $hw_name
git pull origin $hw_name
git checkout main
git branch

echo All Done!
echo Run the following commands:
echo git merge $hw_name
echo git branch -d $hw_name
echo git push -d origin $hw_name
echo git push





