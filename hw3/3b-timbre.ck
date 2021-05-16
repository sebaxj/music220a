Shepard a;
Shepard a3;
Shepard b;

0.008 => float var;
a.setINC(var);
a3.setINC(var);

12 => int initFreq;

a.setOffset(initFreq);
a3.setOffset(initFreq + 3);
a.setOutput(1 => a.output);
a3.setOutput(1 => a3.output);

spork ~ a.run();
spork ~ a3.run();

for(var; var < 0.18; 0.01 +=> var) {
    if(var > 0.04 && var < 0.05) spork ~ a.sweepF(200, 4000);
    a.setINC(var);
    1::second => now;
    a.setOffset(12 +=> initFreq);
}

a.setOutput(-1 => a.output);
a3.setOutput(-1 => a.output);

b.setINC(-0.004);
b.setOutput(1 => b.output);

spork ~ b.run();

while(true) 1::second => now;

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