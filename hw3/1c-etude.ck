[0., -12., -10., -9.] @=> float a[];
[0., -12., 0., -2.] @=> float b[];
[0., -4., -2., 0.] @=> float c[];
[0., -12., 0., -1.] @=> float d[];
[0., -5., -4., -2.] @=> float e2[];
[0., -12.] @=> float f[];

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
    // a
    86 => int root;
    for(0 => int i; i < a.cap(); i++) {
        Std.mtof(root + a[i]) => saw.freq;
        
        // raise LPF on first note to accent, otherwise keep low.
        if(i < 1) {
            1000 => low.freq;
        } else if(i > 0) {
            200 => low.freq;
        }
        spork ~ playShort();
        T => now;
    }
    
    // b
    79 => root;
    for(0 => int i; i < b.cap(); i++) {
        Std.mtof(root + b[i]) => saw.freq;
        
        // raise LPF on first note to accent, otherwise keep low.
        if(i < 1) {
            1000 => low.freq;
        } else if(i > 0) {
            200 => low.freq;
        }
        spork ~ playShort();
        T => now;
    }
    
    // c
    76 => root;
    for(0 => int i; i < c.cap(); i++) {
        Std.mtof(root + c[i]) => saw.freq;
        
        // raise LPF on first note to accent, otherwise keep low.
        if(i < 1) {
            1000 => low.freq;
        } else if(i > 0) {
            200 => low.freq;
        }
        spork ~ playShort();
        T => now;
    }
    
    // d
    77 => root;
    for(0 => int i; i < d.cap(); i++) {
        Std.mtof(root + d[i]) => saw.freq;
        
        // raise LPF on first note to accent, otherwise keep low.
        if(i < 1) {
            1000 => low.freq;
        } else if(i > 0) {
            200 => low.freq;
        }
        spork ~ playShort();
        T => now;
    }
    
    // e
    76 => root;
    for(0 => int i; i < e2.cap(); i++) {
        Std.mtof(root + e2[i]) => saw.freq;
        
        // raise LPF on first note to accent, otherwise keep low.
        if(i < 1) {
            1000 => low.freq;
        } else if(i > 0) {
            200 => low.freq;
        }
        spork ~ playShort();
        T => now;
    }
    
    // f
    76 => root;
    for(0 => int i; i < f.cap(); i++) {
        Std.mtof(root + f[i]) => saw.freq;
        
        // raise LPF on first note to accent, otherwise keep low.
        if(i < 1) {
            1000 => low.freq;
        } else if(i > 0) {
            200 => low.freq;
        }
        spork ~ playShort();
        T => now;
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