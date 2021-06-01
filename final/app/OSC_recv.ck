// TODO
// f determines vel decay in synth?
// f determines reverb mix?

// f determines chuck time progress in playchord loop in synth

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
///////////////////////////////////////

/* GLOBAL INSTANCES */
Synth s;
STKFlute fl;
Kick k;
50 => int T; // initialize chuck time progress in playchord loop in synth
1 => int first_time;

// the patch
s.patch(1);

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
    
    if(first_time) {
        spork ~ rec();
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
                spork ~ k.run(1);         
                spork ~ s.run(60, maj);
                spork ~ fl.run(1);
                <<<"'f' is: ", i>>>;
                <<<"'T' is: ", T>>>;
            } else if(i == 7) {
                80 => T;
                spork ~ k.run(1); 
                spork ~ s.run(57, min);
                spork ~ fl.run(1);
                <<<"'f' is: ", i>>>;
                <<<"'T' is: ", T>>>;
            } else if(i == 8) {
                50 => T;
                spork ~ k.run(2); 
                spork ~ s.run(57, dim);
                spork ~ fl.run(1);
                <<<"'f' is: ", i>>>;
                <<<"'T' is: ", T>>>;             
            } else if(i == 9) {
                30 => T;
                spork ~ k.run(3); 
                spork ~ s.run(57, min);
                spork ~ fl.run(2);
                18::ms => now;
                spork ~ s.run(57, min);
                <<<"'f' is: ", i>>>;
                <<<"'T' is: ", T>>>;               
            } else if(i == 10) {
                // a dim chord
                10 => T;
                spork ~ k.run(4); 
                spork ~ s.run(57, min);
                spork ~ fl.run(2);
                15::ms => now;
                spork ~ s.run(57, dim);
                5::ms => now;
                spork ~ s.run(57, min);
                <<<"'f' is: ", i>>>;
                <<<"'T' is: ", T>>>;              
            }   
        } 
    }
}

fun void rec() {
    "ck-final.wav" => string filename;
    // pull samples from the dac
    dac => Gain g => WvOut w => blackhole;
    // this is the output file name
    filename => w.wavFilename;
    <<<"writing to file:", "'" + w.filename() + "'">>>;
    // any gain you want for the output
    .5 => g.gain;
    
    // temporary workaround to automatically close file on remove-shred
    null @=> w;
    
    // infinite time loop...
    // ctrl-c will stop it, or modify to desired duration
    while( true ) 1::second => now;
}

/////////////////
// SYNTH CLASS //
/////////////////
class Synth {
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
    
    fun void run(int root, float chord[]) {
        play(root, min);
        (T*20)::ms => now;
    }
}

/////////////////
// FLUTE CLASS //
/////////////////
class STKFlute {
    // STK Flute
    
    // patch
    Flute flute => PoleZero f => JCRev r => Gain gain => dac;
    .75 => r.gain;
    .05 => r.mix;
    .99 => f.blockZero;
    0.06 => gain.gain;
    
    // our notes
    [57, 60, 62, 64, 65] @=> int notes[];
    
    // infinite time-loop
    fun void run(int num) {
        
        for(0 => int j; j < num; j++) {
            // clear
            flute.clear(1.0);
            
            // set
            Math.random2f(0.6, 1) => flute.jetDelay;
            Math.random2f(0.0, 0.4) => flute.jetReflection;
            Math.random2f(0.4, 1) => flute.endReflection;
            Math.random2f(0.2, 0.8) => flute.noiseGain;
            Math.random2f(0, 12) => flute.vibratoFreq;
            Math.random2f(0, 1) => flute.vibratoGain;
            Math.random2f(0, 1) => flute.pressure;
            
            // print
            <<< "---", "" >>>;
            <<< "jetDelay:", flute.jetDelay() >>>;
            <<< "jetReflection:", flute.jetReflection() >>>;
            <<< "endReflection:", flute.endReflection() >>>;
            <<< "noiseGain:", flute.noiseGain() >>>;
            <<< "vibratoFreq:", flute.vibratoFreq() >>>;
            <<< "vibratoGain:", flute.vibratoGain() >>>;
            <<< "breath pressure:", flute.pressure() >>>;
            
            // factor
            Math.random2f(.75, 2) => float factor;
            
            for(int i; i < notes.size(); i++) {
                play(24 + notes[i], Math.random2f(.6, .9));
                300::ms * factor => now;
            }
        }
        flute.clear(1.0);
    }
        // basic play function (add more arguments as needed)
        fun void play(float note, float velocity) {
            // start the note
            Std.mtof(note) => flute.freq;
            velocity => flute.noteOn;
        }

}

/////////////////////
// KICK DRUM CLASS //
/////////////////////
class Kick {
    SndBuf buf => dac;
    
    // setup delay line
    adc => DelayL delay => dac;
    
    // set delay parameters
    .75::second => delay.max => delay.delay;
    
    // load the file
    me.dir(-1) + "/assets/Electronic-Kick-1.wav" => buf.read;
    
    // buf gain: don't play yet
    0 => buf.play; 
    
    fun void run(int num) {
        for(0 => int i; i < num; i++) {
            0.5 => buf.play;
            0 => buf.pos;
        }
    }
}
    