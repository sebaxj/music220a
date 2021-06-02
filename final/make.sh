# Script to make final project
echo Making final

echo Starting Processing OSC Broadcast Server... &
echo Starting Frame Differentiation Algorithm for Video... &
~/processing-java --sketch=/Users/sebastianjames/src/music220a/final/app/ --run &
echo Sporking OSC reciever in Chuck... &
chuck app/OSC_recv.ck # keep ChucK task in the foreground, exit with ^C 
echo saving audio as 'ck-final.ck'
echo Exitiing...
