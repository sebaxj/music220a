/*
 * Edited by:
 * Sebastian James
 * 5/19/2021
 * Music 220A, Stanford University, Spring 2021
*/

import gab.opencv.*;
import processing.video.*;
import oscP5.*;
import netP5.*;

// GLOBAL INSTANCES //
Movie video;
OpenCV opencv;
int prevCont;
OscP5 oscP5;
NetAddressList myNetAddressList = new NetAddressList();

// CONSTANTS //
int width = 1064;
int length = 680;
int threshold = 20;
int myListeningPort = 32000;
int myBroadcastPort = 12000;
NetAddress myRemoteLocation;

String myConnectPattern = "/server/connect";
String myDisconnectPattern = "/server/disconnect";

void setup() {
  size(1064, 680);
  video = new Movie(this, "fast.mov");
  video.loop();

  opencv = new OpenCV(this, width, length);

  opencv.startBackgroundSubtraction(5, 3, 0.5);
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
  
  // keep a count of contours. The next - the current is the amount
  // of motion.
  int numContours = 0;
  for (Contour contour : opencv.findContours()) {
    contour.draw();
    numContours++;
  }
  
  // threshold value is minimum difference in current contours and previous
  if (abs(numContours - prevCont) > threshold) {
    println(abs(numContours - prevCont));
  }
  prevCont = numContours;
}

// callback function everytime a new frame is ready to be read
void movieEvent(Movie m) {
  m.read();
}
