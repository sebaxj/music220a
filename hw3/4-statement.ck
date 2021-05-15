Shepard a;
Shepard a3;
Bass b;
Kick k;
Synth s;

// start with kick and synth
k.setGain(0.8);
0.008 => float var;
0 => int initFreq;

spork ~ s.run();
s.patch(1);

spork ~ k.sweepKick();
k.patch(1);
13::second => now;

// fade shepard tones in
a.setINC(var);
a3.setINC(var);
a3.setOffset(initFreq + 4);
spork ~ a.sweepF(50, 1000, 0.001);
spork ~ a3.sweepF(50, 1000, 0.1);
spork ~ a.run();
spork ~ a3.run();
a.setOutput(1);
a3.setOutput(1);
5::second => now;

5::second => now;

2500::ms => now;
// kick drop

a.setOutput(0);
a3.setOutput(0);

50::ms => now;
spork ~ b.run();
b.patch(1);

12600::ms => now;
// kick finish

// repeat shepard tones with rev sweep
spork ~ a3.sweepRev(0.0, 0.3, 0.01);
a.setOutput(1);
a3.setOutput(1);
spork ~ a.run();
spork ~ a3.run();
13::second => now;

// fade shepard tones out

a.setOutput(0);
a3.setOutput(0);
k.patch(0);
s.patch(0);

12150::ms => now;
// kick finish


/////////////////////////////////////////////////////////////////////////////

/////////////////////////////
// Class for Shepard Tone. //
///////////////////////////// 

class Shepard {
    
    // object constants //
    
    // set initial OFFSET
    0 => float OFFSET;
    // mean for normal intensity curve
    72 + OFFSET => float MU;
    // standard deviation for normal intensity curve
    42 => float SIGMA;
    // normalize to 1.0 at x==MU
    1 / gauss(MU, MU, SIGMA) => float SCALE;
    // unit time (change interval)
    1::ms => dur T;
    // initialize INC var with a default variable
    0.004 => float INC;
    
    // starting pitches (in MIDI note numbers, octaves apart)
    [ 12.0, 24, 36, 48, 60, 72, 84, 96, 108, 120 ] @=> float pitches[];
    // number of tones
    pitches.size() => int N;
    
    // bank of tones
    TriOsc tones[N];
    // overall gain
    Gain gain => LPF low => NRev rev; 
    1.0/N => gain.gain;
    
    Gain master => dac;
    
    200 => low.freq;
    1.0 => low.Q;
    6.0 => low.gain;
    
    // initial reverb mix is 0.0
    0.0 => rev.mix;
    1.0 => rev.gain;
    
    // connect to dac
    for( int i; i < N; i++ ) { tones[i] => gain; }
    
    // object functions //
    
    fun void setOutput(int var) {
        if(var == 1) rev => master;
        if(var == 0) rev !=> master;
    }
    
    fun void setINC(float var) {
        var => INC;
    }

    fun void setOffset(float var) {
        var => OFFSET;
        for(int i; i < N; i++) {
            OFFSET +=> pitches[i];
        }
    }
    
    fun void sweepF(float min, float max, float interval) {
        // float to track next wave number
        0.0 => float t;
        while(true) {
            // sweep the filter resonant frequency 100 Hz to 800 Hz
            min + Std.fabs(Math.sin(t)) * max => low.freq;
            
            t + interval => t;
            
            // advance time
            10::ms => now;
        }
    }
    
    fun void sweepRev(float min, float max, float interval) {
        0.0 => float t;
        while(true) {
            // sweep the rev mix from min to max
            min + Std.fabs(Math.sin(t)) * max => rev.mix;
            
            t + interval => t;
            
            // advance time
            100::ms => now;
        }
    }
    
    fun void fadeMaster(float min, float max, float interval) {
        // TODO
    }
    
    // normal function for loudness curve
    // NOTE: chuck-1.3.5.3 and later: can use Math.gauss() instead
    fun float gauss( float x, float mu, float sd ) {
        return (1 / (sd*Math.sqrt(2*pi))) 
        * Math.exp( -(x-mu)*(x-mu) / (2*sd*sd) );
    }
    
    fun void run() {
        // infinite time loop
        while(true) {
            for(int i; i < N; i++) {
                // set frequency from pitch
                pitches[i] => Std.mtof => tones[i].freq;
                // compute loundess for each tone
                gauss( pitches[i], MU, SIGMA ) * SCALE => float intensity;
                // map intensity to amplitude
                intensity*96 => Math.dbtorms => tones[i].gain;
                // increment pitch
                INC +=> pitches[i];
                // wrap (for positive INC)
                if( pitches[i] > 120 ) 108 -=> pitches[i];
                // wrap (for negative INC)
                else if( pitches[i] < 12 ) 108 +=> pitches[i];
            }
            
            // advance time
            T => now;
        }
    }
}

////////////////
// BASS CLASS //
////////////////

class Bass {
    SawOsc osc => ADSR env => LPF lpf => Gain vel;
    Std.mtof(33) => osc.freq;
    
    [3, 5, 7, 10, 10, 10, 12] @=> int pent[];
    
    200 => lpf.freq;
    0.6 => osc.gain;
    
    env.set(40::ms, 80::ms, 0.1, 100::ms);
    
    Noise pluck => BPF bpf => ADSR pluckEnv => vel; // noise to simulate pluck
    0.2 => pluck.gain;
    pluckEnv.set(1::ms, 20::ms, 0.0, 100::ms);
    500 => bpf.freq;
    5 => bpf.Q;
    
    fun void patch(int var) {
        if(var == 1) vel => dac;
        if(var == 0) vel !=> dac;
    }
    
    0 => int i;
    
    fun void run() {
        while (true) {
            if(i > 6) 0 => i;
            Std.mtof(33 + pent[i]) => osc.freq;
            
            Math.random2f(4.0, 6.0) => vel.gain;
            env.keyOn();
            pluckEnv.keyOn();
            Math.random2f(400,600) => bpf.freq;
            0.5::second => now;
            
            env.keyOff();
            pluckEnv.keyOff();
            250::ms => now;
            
            1 +=> i;
        }
    }
} 

/////////////////
// DRUM CLASS: //
/////////////////

class Kick {
    
    // CLASS CONSTANTS //
    
    // SndBuf buf instance
    SndBuf buf => LPF low => Gain gain;
    
    200.0 => low.freq;
    .8 => low.gain;   
    1.0 => gain.gain;
     
    // sound file
    me.dir() + "/misc/Electronic-Kick-1.wav" => string filename;
    if( me.args() ) me.arg(0) => filename;
    filename => buf.read;
    
    // initialize buf.gain
    1.0 => buf.gain;
    // initialize buf.rate
    1.0 => buf.rate;
    
    // CLASS FUNCTIONS //
    
    fun void patch(int var) {
        if(var == 1) gain => dac;
        if(var == 0) gain !=> dac;
    }
    
    fun void setGain(float vel) {
        vel => buf.gain;
    }
    
    fun void setRate(float r) {
        r => buf.rate;
    }
    
    fun void sweepKick() {
        // time loop
        500::ms => dur T;
        while(true) {
            if(T == 10::ms) {
                500::ms => T;
            }
            0 => buf.pos;
            T => now;
            10::ms -=> T;
        }
    }
    
    fun void run() {
        // time loop
        while(true) {
            0 => buf.pos;
            500::ms => now;
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
    
    0.4 => gain.gain;
    
    // Set Param for UGen //
    // mix reverb
    0.2 => rev.mix;
    
    // set LPF
    500 => low.freq;
    0.8 => low.Q;
    0.5 => low.gain;
    
    fun void playChord(int root, float chord[], float vel, 
    dur a, dur d, float s, dur r)
    {
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