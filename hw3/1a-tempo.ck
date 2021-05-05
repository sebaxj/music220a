[12., -12., -8., -6., -1., 0.] @=> float stmt[];
700::ms => dur T;

SawOsc saw => LPF low => ADSR e => NRev rev => dac;

// set sawosc
1.0 => saw.gain;

// mix reverb
.01 => rev.mix;

// set LPF
1000 => low.freq;
1 => low.Q;
0.5 => low.gain;

// note length
80::ms => dur stac;

// to increase speed of sequence
fun void modulateT() {
    while(true) {
        if(T > 80::ms) {
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
            spork ~ playShort();
            T => now;
        }
        
        // increase root by 3 semi-tones
        root + 3 => root;
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