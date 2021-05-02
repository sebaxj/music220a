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

# pull remote branch into new branch
git checkout -b $hw_name
git branch --set-upstream-to origin/$hw_name
git pull origin $hw_name
cd $hw_name

# run ffmpeg-normalize
cd wav
for FILE in *.wav; do ffmpeg-normalize $FILE -ext wav; done
cd ..

# convert markdown to html for webpage
pandoc -s index.md -o index.html

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
git branch
git checkout $hw_name
git branch
git pull origin $hw_name
git checkout main
git merge $hw_name

# delete branch after succesful merge
git branch -d $hw_name
git push -d origin $hw_name

# final push changes to master
git push





