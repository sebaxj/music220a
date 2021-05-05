[0., -10., -8., -6., -3., -1., 0.] @=> float stmt[];
800::ms => dur T;

SawOsc saw => LPF low => ADSR e => NRev rev => dac;

// set sawosc
1.0 => saw.gain;

// mix reverb
.01 => rev.mix;

// set LPF
200 => low.freq;
1 => low.Q;
0.5 => low.gain;

// note length
80::ms => dur stac;

// to increase speed of melody
fun void modulateT() {
    while(true) {
        if(T > 90::ms) {
            T - 20::ms => T;
        }
        1000::ms => now;
    }
}

spork ~ modulateT();

// infitine loop to play noise
while(true) {
    60 => int root;
    for(0 => int j; j < 8; j++) {
        for(0 => int i; i < stmt.cap(); i++) {
            Std.mtof(root + stmt[i]) => saw.freq;
            
            // raise LPF on first note to accent, otherwise keep low.
            if(i < 1) {
                1000 => low.freq;
            } else if(i > 0) {
                200 => low.freq;
            }
            spork ~ playShort();
            T => now;
        }
        
        // intervals to create ascending major scale
        if(j == 0) root + 2 => root;
        if(j == 1) root + 2 => root;
        if(j == 2) root + 1 => root;
        if(j == 3) root + 2 => root;
        if(j == 4) root + 2 => root;
        if(j == 5) root + 2 => root;
        if(j == 6) root + 1 => root;
    }
}


fun void playShort() {
    // set ADSR to short
    e.set(10::ms, 80::ms, .5, 1::ms);
    
    play(stac);
    off(stac);
}

fun void play(dur t) {
    e.keyOn();
    t - e.releaseTime() => now;
}

fun void off(dur t) {
    e.keyOff();
    t - e.releaseTime() => now;
}    