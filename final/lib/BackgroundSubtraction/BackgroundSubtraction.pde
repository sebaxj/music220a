// Edited by:
// Sebastian James
// 5/19/2021
// Music 220A, Stanford University, Spring 2021

import gab.opencv.*;
import processing.video.*;

Movie video;
OpenCV opencv;

// CONSTANTS //
int width = 1064;
int length = 680;

void setup() {
  size(1064, 680);
  video = new Movie(this, "fast.mov");
  video.loop();
  
  // sometimes neccessary to give video library time to boot up and
  // establish a movie height > 0
  //while(video.height == 0) delay(0);
  
  opencv = new OpenCV(this, width, length);
  
  opencv.startBackgroundSubtraction(5, 3, 0.5);

  video.play();
}

void draw() {
  image(video, 0, 0);  
  opencv.loadImage(video);
  
  opencv.updateBackground();
  
  opencv.dilate();
  opencv.erode();

  noFill();
  stroke(255, 0, 0);
  strokeWeight(3);
  for (Contour contour : opencv.findContours()) {
    contour.draw();
  }
}

void movieEvent(Movie m) {
  m.read();
}
