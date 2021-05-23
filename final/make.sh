# Script to make final project
echo Making final
osascript -e 'tell app "Terminal"
    do script 
        echo Running Procecssing...;
        cd ~;
        ./processing-java
        # --sketch=/Users/sebastianjames/src/music220a/final/lib/BackgroundSubtraction --run;
        ./processing-java --sketch=/Users/sebastianjames/src/music220a/final/lib/oscp5 --run;
    end tell'
chuck lib/OSC_recv.ck lib/OSC_send.ck
echo Exitiing...
