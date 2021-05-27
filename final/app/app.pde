/*
 * Frame Differencing 
 * by Golan Levin. 
 *
 * Quantify the amount of movement in the video frame using frame-differencing.
 * 
 * Edited by:
 * Sebastian James
 * 5/19/2021
 * Music 220A, Stanford University, Spring 2021
 */

import processing.video.*;
import oscP5.*;
import netP5.*;

// GLOBAL INSTANCES //
Movie video;
OscP5 oscP5;
NetAddressList myNetAddressList = new NetAddressList();

// CONSTANTS //
int numPixels;
int[] previousFrame;
int width = 1064;
int length = 680;
int frameDiff = 1;

int myListeningPort = 32000;
int myBroadcastPort = 12000;
NetAddress myRemoteLocation;

String myConnectPattern = "/server/connect";
String myDisconnectPattern = "/server/disconnect";

void setup() {
  size(1064, 680);
  
  // setup OSC Broadcast Server
  myRemoteLocation = new NetAddress("127.0.0.1", myBroadcastPort);
  oscP5 = new OscP5(this, myListeningPort);
  frameRate(25);

  // setup video input
  video = new Movie(this, "fast.mov");
  video.loop(); 

  numPixels = width * length;

  // Create an array to store the previously captured frame
  previousFrame = new int[numPixels];
  loadPixels(); // load pixels data into previousFrame
}

void draw() {
  background(0);
  if (video.available()) {
    video.read(); // Read the new frame from the camera
    video.loadPixels(); // Make its pixels[] array available

    int movementSum = 0; // Amount of movement in the frame
    for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
      color currColor = video.pixels[i];
      color prevColor = previousFrame[i];

      // Extract the red, green, and blue components from current pixel
      int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;

      // Extract red, green, and blue components from previous pixel
      int prevR = (prevColor >> 16) & 0xFF;
      int prevG = (prevColor >> 8) & 0xFF;
      int prevB = prevColor & 0xFF;

      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - prevR);
      int diffG = abs(currG - prevG);
      int diffB = abs(currB - prevB);

      // Add these differences to the running tally
      movementSum += diffR + diffG + diffB;

      // Render the difference image to the screen
      // pixels[i] = color(diffR, diffG, diffB); <- slower
      pixels[i] = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;

      // Save the current color into the 'previous' buffer
      previousFrame[i] = currColor;
    }

    // To prevent flicker from frames that are all black (no movement),
    // only update the screen if the image has changed.
    if (movementSum > 0) {
      updatePixels();
      println(((movementSum - frameDiff + 0.0) / (frameDiff + 0.0)) * 100); // Print the total amount of movement to the console
      frameDiff = movementSum;
    }
  }
}

void oscEvent(OscMessage theOscMessage) {
  // check if the address pattern fits any of our patterns 
  if (theOscMessage.addrPattern().equals(myConnectPattern)) {
    connect(theOscMessage.netAddress().address());
  } else if (theOscMessage.addrPattern().equals(myDisconnectPattern)) {
    disconnect(theOscMessage.netAddress().address());
  } else {
    // if pattern matching was not successful, then broadcast the incoming
    // message to all addresses in the netAddresList. 
    oscP5.send(theOscMessage, myNetAddressList);
  }
}

private void connect(String theIPaddress) {
  if (!myNetAddressList.contains(theIPaddress, myBroadcastPort)) {
    myNetAddressList.add(new NetAddress(theIPaddress, myBroadcastPort));
    println("### adding "+theIPaddress+" to the list.");
  } else {
    println("### "+theIPaddress+" is already connected.");
  }
  println("### currently there are "+myNetAddressList.list().size()+" remote locations connected.");
}

private void disconnect(String theIPaddress) {
  if (myNetAddressList.contains(theIPaddress, myBroadcastPort)) {
    myNetAddressList.remove(theIPaddress, myBroadcastPort);
    println("### removing "+theIPaddress+" from the list.");
  } else {
    println("### "+theIPaddress+" is not connected.");
  }
  println("### currently there are "+myNetAddressList.list().size());
}

// Function to send an OSC message when the mouse presses the background image
void mousePressed() {
  // OSC msg string must match what the reciever is looking for
  OscMessage myMessage = new OscMessage("/mouse/press");

  myMessage.add(random(1, 4)); // density var stored as int in msg

  // send message
  oscP5.send(myMessage, myRemoteLocation);
}
