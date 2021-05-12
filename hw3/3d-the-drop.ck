Shepard a;
Bass b;

0.008 => float var;
a.setINC(var);

a.setOffset(12);
a.setOutput(1 => a.output);

spork ~ a.run();

for(var; var < 0.1; 0.01 +=> var) {
    a.setINC(var);
    1::second => now;
}

a.setOutput(-1 => a.output);
50::ms => now;

spork ~ b.run();
5::second => now;

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
    Gain gain; 1.0/N => gain.gain;
    // connect to dac
    for( int i; i < N; i++ ) { tones[i] => gain; }
    
    // object functions //
    
    fun void setOutput(int var) {
        if(output == 1) gain => dac;
        if(output == -1) gain !=> dac;
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
    SawOsc osc => LPF lpf => ADSR env => Gain vel => dac;
    SinOsc subOsc => env; // sub oscillator
    90 => osc.freq;
    
    200 => lpf.freq;
    
    osc.freq()*0.5 => subOsc.freq;
    0.5 => dac.gain;
    
    env.set(10::ms, 60::ms, 0.1, 100::ms);
    
    Noise pluck => BPF bpf => ADSR pluckEnv => dac; // noise to simulate pluck
    0.9 => pluck.gain;
    pluckEnv.set(10::ms, 20::ms, 0.0, 100::ms);
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
            100::ms => now;
        }
    }
} 