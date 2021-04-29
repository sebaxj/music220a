SawOsc osc[4];
LPF low => ADSR e => dac;

// patch osc to low to adsr to dac
for(0 => int i; i < osc.cap(); i++) {
    osc[i] => low;
    0.1 => osc[i].gain;
}

// set LPF
500 => low.freq;
1 => low.Q;
0.5 => low.gain;

// set ADSR
e.set(100::ms, 80::ms, 1.0, 200::ms);

// array of intervals relative to the root; this is a major seventh chord with a "just" major third
[0.,3.863,7.,11.] @=> float chord[];

// Function playQuad plays a chord by taking in an array of
// MIDI intervals relative to a passed root parameter
// Sets the freq of each of the oscs in array (4) to a frequency
// of a note in the chord, and sets the passed ADSR parameters
// and plays the chord for the specific duration.
fun void playQuad(int root, float chord[], float amp, dur T, 
dur a, dur d, float s, dur r) {
    
    for(0 => int i; i < osc.cap(); i++) {
        Std.mtof(root + chord[i]) => osc[i].freq;
        amp => osc[i].gain;
    }
    
    // open env (e is your envelope)
    e.set(a, d, s, r);
    e.keyOn();
    
    // A through end of S
    T-e.releaseTime() => now;
    
    // close env
    e.keyOff();
    
    // release
    e.releaseTime() => now;
}

while(true) {
    
    // root of C major chord is 60
    playQuad(60, chord, 0.1, 1::second, 100::ms, 80::ms, 1.0, 200::ms);
    3::second => now;
}