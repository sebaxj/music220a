TriOsc osc[4];
LPF low => ADSR e => NRev r => dac;

// set reverb
.1 => r.mix;

// patch osc to low to adsr to dac
for(0 => int i; i < osc.cap(); i++) {
    osc[i] => low;
}

// set LPF
300 => low.freq;
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

// B dim
[-12., 3., 6., 0.] @=> float bdim[];

// E Maj
[0., 4., 7., 12.] @=> float emaj[];

// Am/G
[-2., 0., 3., 7.] @=> float amg[];

// C Maj
[0., 4., 7., 12.] @=> float cmaj[];

// E min
[0., 3., 7., 12.] @=> float emin[];

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
        //amp => gain => osc[i].gain;
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

fun void sweepVol() {
    
    while(true) {
        
        // sweep gain from initial gain to 0.8
        0.08 + Std.fabs(Math.sin(t)) * 1.0 => gain;
        
        // patch new gain to osc array
        for(0 => int i; i < osc.cap(); i++) {
            gain => osc[i].gain;
        }
        
        // move to next wave number
        t + .01  => t;
        
        // wait 10 seconds to change gain
        8::ms => now;
    }
    
}

spork ~ sweepVol();

while(true) {
    // Am
    playChord(57, am, 0.1, 2::second, 100::ms, 40::ms, .5, 10::ms);
    
    // ii dim
    playChord(59, bdim, 0.5, 4::second, 0::ms, 50::ms, 1.0, 1::ms);
    
    // V
    playChord(64, emaj, 0.1, 2::second, 50::ms, 100::ms, .5, 100::ms);

    // Am
    playChord(57, am, 0.1, 4::second, 500::ms, 100::ms, .5, 1000::ms);
    
    // Am/G
    playChord(57, amg, 0.3, 4::second, 500::ms, 100::ms, .5, 500::ms); 
    
    // C Maj
    playChord(60, cmaj, 0.3, 4::second, 500::ms, 100::ms, 0.5, 500::ms);
    
    // e min
    playChord(64, emin, 0.3, 4::second, 100::ms, 50::ms, 0.5, 100::ms);
    
    // G dim 7
    playChord(55, gdim7, 0.6, 2::second, 0::ms, 50::ms, 1.0, 10::ms);
    
    // Am
    playChord(57, am, 0.5, 3::second, 50::ms, 50::ms, .2, 1000::ms);
    
    1::second => now;
}