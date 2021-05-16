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

spork ~ a.run();
spork ~ b.run();
spork ~ c.run();
spork ~ d.run();

while(true) {
    1::second => now;
}

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

    // starting pitches (in MIDI note numbers, octaves apart)
    [ 12.0, 24, 36, 48, 60, 72, 84, 96, 108, 120 ] @=> float pitches[];
    // number of tones
    pitches.size() => int N;
    
    // bank of tones
    TriOsc tones[N];
    // overall gain
    Gain gain => dac; 1.0/N => gain.gain;
    // connect to dac
    for( int i; i < N; i++ ) { tones[i] => gain; }
    
    // object functions //
    
    fun float setINC(float var) {
        var => INC;
    }
    
    fun float setOffset(float var) {
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
        while( true ) {
            for( int i; i < N; i++ ) {
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
