echo A simple branch, pull, ffmpeg-normalize, .md to .html, push script!
read -p "What is the directory for this HW? " hw_name
cd $hw_name/wav

for FILE in *.wav; do ffmpeg-normalize $FILE -ext wav -of /../normalized/; done