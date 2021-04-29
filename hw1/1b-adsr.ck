Noise n => ADSR e => dac;
0.2 => n.gain;

// set A D S R
// attack = 10 ms
// decay = 40 ms
// sustain = .5
// release = 100 ms

e.set(10::ms, 40::ms, .5, 100::ms);

// note length
2::second => dur quarter;

// infitine loop to play noise
while(true) {
    play(quarter);
    off(quarter);
}

fun void play(dur t) {
    e.keyOn();
    t - e.releaseTime() => now;
}

fun void off(dur t) {
    e.keyOff();
    t - e.releaseTime() => now;
}
