/* GLOBAL INSTANCES */
SndBuf buf;

// the patch
buf => dac;

// load the file
me.dir(-1) + "/assets/Electronic-Kick-1.wav" => buf.read;

// buf gain: don't play yet
0 => buf.play; 

// create our OSC receiver
OscIn oin;

// create our OSC message
OscMsg msg;

// see if port is supplied on command line
if(me.args()) me.arg(0) => Std.atoi => oin.port;

// listening port
else 12000 => oin.port;

// create an address in the receiver
// needs to match the Processing message
oin.addAddress("/frame/, f");

// infinite event loop
while (true) {
    // wait for event to arrive
    oin => now;
    
    // grab the next message from the queue. 
    while ( oin.recv(msg) != 0 ) { 
        // getFloat fetches the expected float (as indicated by "f")
        msg.getFloat(0) => buf.play;
        // print
        <<< "got (via OSC):", buf.play() >>>;
        // set play pointer to beginning
        0 => buf.pos;
    }
}