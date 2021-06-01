#ffmpeg -i test.ogg -i ck-final.wav -c:v copy -map 0:v:0 -map 1:a:0 -shortest test-new.ogg
#ffmpeg -i test.m4v -i ck-final.wav -c:v copy -map 0:v:0 -map 1:a:0 -shortest test-new.mp4
ffmpeg -framerate 30 -pattern_type glob -i '*.png' -i output.mp3 -c:v libx264 -r 30 -pix_fmt yuv420p -shortest out.mp4
