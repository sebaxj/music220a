/* GLOBAL INSTANCES */
SndBuf buf;
Synth s;
Gain master;
1.0 => master.gain;
spork ~ s.run();
s.patch(1);

// the patch
buf => master => dac;

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

float f;

// infinite event loop
while (true) {
    // wait for event to arrive
    oin => now;
    
    // grab the next message from the queue. 
    while (oin.recv(msg) != 0) { 
        // getFloat fetches the expected float (as indicated by "f")
        msg.getFloat(0) => f;
        <<<"got (via OSC):", f>>>;
        
        if(master.gain() > 2.0) {
            1.0 => master.gain;
        } else if(master.gain() <= 0.0) {
            1.0 => master.gain;
        }
        
        if(f > 5.0) {
            if(master.gain() + 0.5 < 2.0) {
                master.gain() + 0.5 => master.gain;
            }
        } else if(f < 3.0) {
            if(master.gain() - 0.2 < 0) {
                master.gain() - 0.2 => master.gain;
            }
        }
        
        //if(f > 0) master.gain() + 1 => master.gain;
        //if(f <= 0) master.gain() - 1 => master.gain;
        //f => buf.play;
        // set play pointer to beginning
        //0 => buf.pos;
    }
}

/////////////////
// SYNTH CLASS //
/////////////////

class Synth {
    // CHORDS ARRAYS //
    // min
    [0., 3., 7., 0.] @=> float min[];
    
    // min4/2
    [-2., 0., 3., 7.] @=> float min42[];
    
    // dim
    [-12., 3., 6., 0.] @=> float dim[];
    
    // Maj
    [0., 4., 7., 12.] @=> float maj[];
    
    // V7
    [0., 4., 7., 10.] @=> float v7[];
    
    // fully dim 7
    [0., 3., 6., 9.] @=> float dim7[];
    ///////////////////
    
    // Global UGen //
    // patch low -> rev -> dax ->
    LPF low => NRev rev => Gain gain;
    
    1.0 => gain.gain;
    
    // Set Param for UGen //
    // mix reverb
    0.2 => rev.mix;
    
    // set LPF
    500 => low.freq;
    0.8 => low.Q;
    0.5 => low.gain;
    
    fun void playChord(int root, float chord[], float vel, 
    dur a, dur d, float s, dur r) {
        // ugens "local" to the function
        TriOsc osc[4];
        ADSR e => low;
        
        // patch
        for(0 => int i; i < osc.cap(); i++) {
            osc[i] => e;
        }
        
        // freq and gain
        for(0 => int i; i < osc.cap(); i++) {
            Std.mtof(root + chord[i]) => osc[i].freq;
            vel => osc[i].gain;
        }
        
        // open env (e is your envelope)
        e.set(a, d, s, r);
        e.keyOn();
        
        // A through end of S
        e.releaseTime() => now;
        
        // close env
        e.keyOff();
        
        // release
        e.releaseTime() => now;
    }
    
    fun void patch(int var) {
        if(var == 1) gain => dac;
        if(var == 0) gain !=> dac;
    }
    
    fun void vel(float f) {
        f => gain.gain;
    }
    
    fun float getVel() {
        return gain.gain();
    }
    
    fun void play(int root, float chord[]) {
        
        .5 => float vel;
        
        for(0 => int i; i < 8; i++) {
            playChord(root, chord, vel, 50::ms, 50::ms, 0.5, 100::ms);
            
            50::ms => now;
            vel - .2 => vel;
        }
    }
    
    fun void run() {
        while(true) {
            play(57, min); // am
            1000::ms => now;
        }
    }
}