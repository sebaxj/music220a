Shepard a;
Shepard a3;
Bass b;
Kick k;

k.patch(dac);
k.setGain(1.0);

0.008 => float var;
a.setINC(var);
a3.setINC(var);

12 => int initFreq;

a.setOffset(initFreq);
a3.setOffset(initFreq + 4);

a.setOutput(1 => a.output);
a3.setOutput(1 => a3.output);

spork ~ a.run();
spork ~ a3.run();
spork ~ k.sweepKick();

for(var; var < 0.13; 0.01 +=> var) {
    if(var > 0.04 && var < 0.05) spork ~ a.sweepF(200, 4000);
    a.setINC(var);
    1::second => now;
    a.setOffset(12 +=> initFreq);
}

a.setOutput(-1 => a.output);
a3.setOutput(-1 => a3.output);
50::ms => now;

spork ~ b.run();
5::second => now;

spork ~ k.run();
3::second => now;


// Class for Shepard Tone. 
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
    Gain gain => LPF low; 1.0/N => gain.gain;
    200 => low.freq;
    1.0 => low.Q;
    10.0 => low.gain;
    // connect to dac
    for( int i; i < N; i++ ) { tones[i] => gain; }
    
    // object functions //
    
    fun void setOutput(int var) {
        if(output == 1) low => dac;
        if(output == -1) low !=> dac;
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
        
        min => low.freq;
        while(max > low.freq()) {
            // sweep the filter resonant frequency 100 Hz to 2000 Hz
            20.0 + low.freq() => low.freq;
            
            // advance time
            50::ms => now;
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

class Bass {
    SawOsc osc => ADSR env => LPF lpf => Gain vel => dac;
    SinOsc subOsc => env; // sub oscillator
    70 => osc.freq;
    
    200 => lpf.freq;
    
    osc.freq()*0.5 => subOsc.freq;
    5.0 => osc.gain;
    
    env.set(40::ms, 80::ms, 0.1, 100::ms);
    
    Noise pluck => BPF bpf => ADSR pluckEnv => dac; // noise to simulate pluck
    0.4 => pluck.gain;
    pluckEnv.set(1::ms, 20::ms, 0.0, 100::ms);
    500 => bpf.freq;
    5 => bpf.Q;
    
    fun void run() {
        while (true) {
            Math.random2f(40, 80) => osc.freq;
            osc.freq()*0.5 => subOsc.freq;
            
            Math.random2f(0.7, 1.0) => vel.gain;
            env.keyOn();
            pluckEnv.keyOn();
            Math.random2f(400,600) => bpf.freq;
            0.5::second => now;
            
            env.keyOff();
            pluckEnv.keyOff();
            250::ms => now;
        }
    }
} 

// DRUM CLASS:
class Kick {
    
    // CLASS CONSTANTS //
    
    // SndBuf buf instance
    SndBuf buf => LPF low;
    
    200.0 => low.freq;
    
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