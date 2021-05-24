/*
 * Edited by:
 * Sebastian James
 * 5/19/2021
 * Music 220A, Stanford University, Spring 2021
*/

import oscP5.*;
import netP5.*;

// GLOBAL INSTANCES //
OscP5 oscP5;
NetAddressList myNetAddressList = new NetAddressList();

// CONSTANTS //
int myListeningPort = 32000;
int myBroadcastPort = 12000;
NetAddress myRemoteLocation;

String myConnectPattern = "/server/connect";
String myDisconnectPattern = "/server/disconnect";

void setup() {
  myRemoteLocation = new NetAddress("127.0.0.1", myBroadcastPort);
  oscP5 = new OscP5(this, myListeningPort);
  frameRate(25);
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

void draw() {
  background(0);
}

// Function to send an OSC message when the mouse presses the background image
void mousePressed() {
  // OSC msg string must match what the reciever is looking for
  OscMessage myMessage = new OscMessage("/mouse/press");

  myMessage.add(random(1, 4)); // density var stored as int in msg

  // send message
  oscP5.send(myMessage, myRemoteLocation);
}
