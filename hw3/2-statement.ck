// initialize instance of object
// set offset of each object
// set asc/dec and speed for each
// connect object to dac
// spork object function to run
// loop time

// keyboard event class instance
KBHit kb;

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

// add drum beat and snare

while(true) {
    
    // wait on kbhit event
    kb => now;
    
    // potentially more than 1 key at a time
    while( kb.more() )
    { 
        kb.getchar() => int ascii;
        
        // w toggles increasing/decreasing
        if(ascii == 119) {
            <<< "ascii: ", ascii>>>;
            a.setINC(a.INC * -1);
            b.setINC(b.INC * -1);
            c.setINC(c.INC * -1);
            d.setINC(d.INC * -1);  
        }
        
        // space is pause or play
        if(ascii == 32) {
            <<< "ascii: ", ascii>>>;
            a.setOutput((a.output * -1 => a.output));
            b.setOutput((b.output * -1 => b.output));
            c.setOutput((c.output * -1 => c.output));
            d.setOutput((d.output * -1 => d.output));
        }
    }
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
    
    fun UGen setOutput(int var) {
        if(output == 1) gain => dac;
        if(output == -1) gain !=> dac;
    }
    
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

// DRUM CLASS:
class Kick {
}