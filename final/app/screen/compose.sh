ffmpeg -i test.ogg -i ck-final.wav -c:v copy -map 0:v:0 -map 1:a:0 -shortest test-new.ogg
ffmpeg -i test.m4v -i ck-final.wav -c:v copy -map 0:v:0 -map 1:a:0 -shortest test-new.mp4
