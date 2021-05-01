SawOsc osc[4];
LPF low => ADSR e => JCRev r => dac;

// set reverb
.4 => r.mix;

// patch osc to low to adsr to dac
for(0 => int i; i < osc.cap(); i++) {
    osc[i] => low;
}

// set LPF
500 => low.freq;
1 => low.Q;
0.5 => low.gain;

// set ADSR
e.set(100::ms, 80::ms, 1.0, 10::ms);

// to tack next wave numbers
0.0 => float t;

// global var for gain
0.0 => float gain;

// CHORDS ARRAYS //

// Am
[0., 3., 7., 0.] @=> float am[];

// Am/G
[-2., 0., 3., 7.] @=> float amg[];

// G dim 7
[0., 3., 6., 9.] @=> float gdim7[];

///////////////////


// Function playChord plays a chord by taking in an array of
// MIDI intervals relative to a passed root parameter
// Sets the freq of each of the oscs in array (4) to a frequency
// of a note in the chord, and sets the passed ADSR parameters
// and plays the chord for the specific duration.
//
// amp parameter isn't enabled to allow the sweepVol() function to
// operate properly
fun void playChord(int root, float chord[], float amp, dur T, 
dur a, dur d, float s, dur r) {
    
    for(0 => int i; i < osc.cap(); i++) {
        Std.mtof(root + chord[i]) => osc[i].freq;
        amp => gain => osc[i].gain;
    }
    
    // open env
    e.set(a, d, s, r);
    e.keyOn();
    
    // A to S
    T-e.releaseTime() => now;
    
    // close env
    e.keyOff();
    
    // release
    e.releaseTime() => now;
}

while(true) {
    // Am
    playChord(57, am, 0.1, 3::second, 100::ms, 40::ms, 1.0, 10::ms);
    
    // Am/G
    playChord(57, amg, 0.3, 1::second, 10::ms, 80::ms, 0.5, 1::ms);
    
    // G dim 7
    playChord(55, gdim7, 0.6, 2::second, 80::ms, 100::ms, 1.0, 10::ms);
    
    // Am
    playChord(57, am, 0.5, 3::second, 100::ms, 40::ms, 1.0, 10::ms);
    
    1::second => now;
}