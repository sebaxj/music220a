SawOsc saw => LPF low => ADSR e => dac;

// set sawosc
1.0 => saw.gain;
Std.mtof(60) => saw.freq;

// set LPF
200 => low.freq;
1 => low.Q;
0.5 => low.gain;

// note length
1::second => dur leg;
80::ms => dur stac;

// infitine loop to play noise
while(true) {
    playLong();
    playShort();
}

fun void playLong() {
    // set ADSR to long
    e.set(200::ms, 80::ms, .5, 10::ms);
    
    play(leg);
    off(leg);
}

fun void playShort() {
    // set ADSR to short
    e.set(0::ms, 200::ms, .2, 1::ms);
    
    play(stac);
    off(leg);
}

fun void play(dur t) {
    e.keyOn();
    t - e.releaseTime() => now;
}

fun void off(dur t) {
    e.keyOff();
    t - e.releaseTime() => now;
}