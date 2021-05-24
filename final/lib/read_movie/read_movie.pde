// Sebastian James
// 5/19/2021
// Music 220A, Stanford University, Spring 2021

import processing.video.*;
Movie video;

// CONSTANTS //
int width = 1064;
int length = 680;

void setup() {
  // set window dimension
  size(1064, 680);
  
  // load movie
  video = new Movie(this, "fast.mov");
  video.loop();
}

void draw() {
  //tint(255, 20);
  image(video, 0, 0);
}

// called every time a new frame is available to read
void movieEvent(Movie v) {
  v.read();
}
