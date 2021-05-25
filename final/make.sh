# Script to make final project
echo Making final

# echo Starting Processing Motion Processing V1 for Movie... &
# ~/processing-java --sketch=/Users/sebastianjames/src/music220a/final/lib/BackgroundSubtraction --run &
# echo Starting Processing Motion Processing V2 for Movie... &
# ~/processing-java --sketch=/Users/sebastianjames/src/music220a/final/lib/FrameDiff --run &
echo Starting Processing OSC Broadcast Server... &
echo Starting Frame Differentiation Algorithm for Video... &
~/processing-java --sketch=/Users/sebastianjames/src/music220a/final/app/ --run &
echo Sporking OSC reciever in Chuck... &
chuck app/OSC_recv.ck && fg # keep ChucK task in the foreground, exit with ^C 
echo Exitiing...
