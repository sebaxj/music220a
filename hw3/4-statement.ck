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

k.patch(dac);
spork ~ k.sweepKick();
13::second => now;

// fade shepard tones in
a.setINC(var);
a3.setINC(var);
a3.setOffset(initFreq + 4);
a.setOutput(1 => a.output);
a3.setOutput(1 => a3.output);
spork ~ a.run();
spork ~ a3.run();
13::second => now;

a.setOutput(-1 => a.output);
a3.setOutput(-1 => a3.output);
50::ms => now;
spork ~ b.run();

12600::ms => now;
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
    // initialize output var: 1 = dac, -1 = disconnect
    int output;
    
    // starting pitches (in MIDI note numbers, octaves apart)
    [ 12.0, 24, 36, 48, 60, 72, 84, 96, 108, 120 ] @=> float pitches[];
    // number of tones
    pitches.size() => int N;
    
    // bank of tones
    TriOsc tones[N];
    // overall gain
    Gain gain => LPF low => NRev rev; 1.0/N => gain.gain;
    200 => low.freq;
    1.0 => low.Q;
    10.0 => low.gain;
    
    // initial reverb mix is 0.0
    0.0 => rev.mix;
    1.0 => rev.gain;
    
    // connect to dac
    for( int i; i < N; i++ ) { tones[i] => gain; }
    
    // object functions //
    
    fun void setOutput(int var) {
        if(output == 1) rev => dac;
        if(output == -1) rev !=> dac;
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
    
    fun void sweepF(float min, float max) {
        
        if(min < max) {
            min => low.freq;
            while(max > low.freq()) {
                20.0 + low.freq() => low.freq;
                
                // advance time
                50::ms => now;
            }
        } else if(min > max) {
            min => low.freq;
            while(max < low.freq()) {
                low.freq() - 20.0 => low.freq;
                
                // advance time
                50::ms => now;
            }
        }
    }
    
    fun void sweepRev(float min, float max) {
        
        if(min < max) {
            min => rev.mix;
            while(max > rev.mix()) {
                .01 + rev.mix() => rev.mix;
                
                // advance time
                10::ms => now;
            }
        } else if(min > max) {
            min => rev.mix;
            while(max > rev.mix()) {
                rev.mix() - .01 => rev.mix;
                
                // advance time
                10::ms => now; 
            }
        }
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
    SawOsc osc => ADSR env => LPF lpf => Gain vel => dac;
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
    SndBuf buf => LPF low;
    
    200.0 => low.freq;
    .8 => low.gain;    
    // sound file
    me.dir() + "/misc/Electronic-Kick-1.wav" => string filename;
    if( me.args() ) me.arg(0) => filename;
    filename => buf.read;
    
    // initialize buf.gain
    1.0 => buf.gain;
    // initialize buf.rate
    1.0 => buf.rate;
    
    // CLASS FUNCTIONS //
    
    fun void patch(UGen u) {
        low => u;
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
    LPF low => NRev rev => Gain gain => dac;
    
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