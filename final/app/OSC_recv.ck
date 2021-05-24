/* GLOBAL INSTANCES */
SndBuf buf;

/* CONSTANTS */
5 => float DENSITY;
0 => float t;

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
oin.addAddress("/mouse/press, f");

spork ~ modulateDensity();  

// infinite event loop
while (true) {
    // wait for event to arrive
    oin => now;

    // grab the next message from the queue. 
    while (oin.recv(msg) != 0) { 
        // check density parameter, adjust if needed
        if(DENSITY < 1) 1 => DENSITY;
        if(DENSITY > 10) 10 => DENSITY;
        
        // Density and wait time between notes are inversely related
        // computer inverse of density and set to wait time
        10/DENSITY * 50 => float min;
        
        // getFloat fetches the expected float (as indicated by "f")
        msg.getFloat(0) => buf.play;
        
        (min + 1 * Math.random2f(0, Math.sqrt(min)))::ms => dur minT;
        
        // spork sound
        spork ~ makeSound(60, .1, DENSITY * Math.random2f(.2, .4)::second);
        minT => now;
        
        // print
        <<<"got (via OSC):", buf.play()>>>;
        
        // set play pointer to beginning
        0 => buf.pos;
    }
}

fun void modulateDensity() {
    while(true) {
        1 + ((Math.sin(now/second * .75) + 1) / 2) * 9 => DENSITY;
        10::ms => now;
    }
}

// function to make Sound
fun void makeSound(float pitch, float vel, dur T) {
    // ugens "local" to the function
    TriOsc s => ADSR e => dac;
    
    // frequency and gain
    Std.mtof(pitch) => s.freq;
    vel => s.gain;
    
    // open env (e is your envelope
    e.set(50::ms, 50::ms, .08, 50::ms);
    e.keyOn();
    
    // A through end of S
    T-e.releaseTime() => now;
    
    // close env
    e.keyOff();
    
    // release
    e.releaseTime() => now;
}
