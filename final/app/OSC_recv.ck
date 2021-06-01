// TODO
// f determines vel decay in synth?
// f determines reverb mix?

// f determines chuck time progress in playchord loop in synth

/* GLOBAL INSTANCES */
SndBuf buf;
Synth s;
Gain master;
1.0 => master.gain;
1 => int first_time;
50 => int T; // initialize chuck time progress in playchord loop in synth

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

    // synth is patched to dac on first OSC message
    if(first_time) {
        s.patch(1);
        0 => first_time;
    }
    
    // grab the next message from the queue. 
    while (oin.recv(msg) != 0) { 
        // getFloat fetches the expected float (as indicated by "f")
        msg.getFloat(0) => f;
        <<<"got (via OSC):", f>>>;
        
        if(f >= 6.0) {
            f $ int => int i;
            if(i == 6) {
                100 => T;
                spork ~ s.run();
                <<<"'f' is: ", i>>>;
                <<<"'T' is: ", T>>>;
            } else if(i == 7) {
                80 => T;
                spork ~ s.run();
                <<<"'f' is: ", i>>>;
                <<<"'T' is: ", T>>>;
            } else if(i == 8) {
                50 => T;
                spork ~ s.run();
                <<<"'f' is: ", i>>>;
                <<<"'T' is: ", T>>>;                
            } else if(i == 9) {
                30 => T;
                spork ~ s.run();
                <<<"'f' is: ", i>>>;
                <<<"'T' is: ", T>>>;                
            } else if(i == 10) {
                10 => T;
                spork ~ s.run();
                <<<"'f' is: ", i>>>;
                <<<"'T' is: ", T>>>;                
            }   
        } 
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
            playChord(root, chord, vel, T::ms, T::ms, 0.5, (T*2)::ms);
            
            T::ms => now;
            vel - .2 => vel;
        }
    }
    
    fun void run() {
        play(57, min); // am
        (T*20)::ms => now;
    }
}