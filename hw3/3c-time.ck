Kick k;

k.patch(dac);
k.setGain(1.0);

Shepard a;
Shepard b;
Shepard c;
Shepard d;

a.setINC(-0.004);
b.setINC(-0.004);
c.setINC(-0.004);
d.setINC(-0.004);

a.setOffset(0);
b.setOffset(3);
c.setOffset(6);
d.setOffset(10);

a.setOutput(1 => a.output);
b.setOutput(1 => b.output);
c.setOutput(1 => c.output);
d.setOutput(1 => d.output);

spork ~ a.run();
spork ~ b.run();
spork ~ c.run();
spork ~ d.run();

spork ~ k.sweepKick();

12900::ms => now;

a.setOutput(-1 => a.output);
b.setOutput(-1 => b.output);
c.setOutput(-1 => c.output);
d.setOutput(-1 => d.output);

1000::ms => now;
spork ~ k.run();
2::second => now;

a.setINC(0.004);
b.setINC(0.004);
c.setINC(0.004);
d.setINC(0.004);
a.setOutput(1 => a.output);
b.setOutput(1 => b.output);
c.setOutput(1 => c.output);
d.setOutput(1 => d.output);

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