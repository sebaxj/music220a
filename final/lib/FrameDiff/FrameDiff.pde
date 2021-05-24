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

// GLOBAL INSTANCES //
Movie video;

// CONSTANTS //
int numPixels;
int[] previousFrame;
int width = 1064;
int length = 680;

void setup() {
  size(1064, 680);

  video = new Movie(this, "fast.mov");
  video.loop(); 

  numPixels = width * length;

  // Create an array to store the previously captured frame
  previousFrame = new int[numPixels];
  loadPixels(); // load pixels data into previousFrame
}

void draw() {
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
      println(movementSum); // Print the total amount of movement to the console
    }
  }
}
