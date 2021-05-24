/*
 * Edited by:
 * Sebastian James
 * 5/19/2021
 * Music 220A, Stanford University, Spring 2021
*/

// TODO: cur vs prev

import gab.opencv.*;
import processing.video.*;

// GLOBAL INSTANCES //
PImage prev, cur;
Movie video;
OpenCV opencv;

// CONSTANTS //
int width = 1064;
int length = 680;

void setup() {
    size(1064, 680);

    // load movie
    video = new Movie(this, "fast.mov");
    video.loop();
    
    // initialize prev and cur with width and length of movie obj
    prev = createImage(width, length, RGB);
    cur = createImage(width, length, RGB);
}

// read movie frame-by-frame and load the frame into OpenCV obj
void movieEvent(Movie m) {
    m.read();
    prev = video.get(0, 0, width, length);
    open = new OpenCV(this, prev);
}

// draw() runs repeatedly
// calculate diff between current and past
void draw() {
    cur = video.get(0, 0, width, length);
    image(cur, 0, 0);
}
