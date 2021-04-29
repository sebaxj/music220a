// CHORDS ARRAYS //
// min
[0., 3., 7., 0.] @=> float min[];

// min4/2
[-2., 0., 3., 7.] @=> float min42[];

// dim
[-12., 3., 6., 0.] @=> float dim[];

// Maj
[0., 4., 7., 12.] @=> float maj[];

// V7
[0., 4., 7., 10.] @=> float v7[];

// fully dim 7
[0., 3., 6., 9.] @=> float dim7[];
///////////////////

// CONSTANTS //
5 => float DENSITY;
///////////////

// Global UGen //
// patch low -> rev -> dax ->
LPF low => NRev rev => dac;
/////////////////

// Set Param for UGen //
// mix reverb
.1 => rev.mix;

// set LPF
500 => low.freq;
1 => low.Q;
0.5 => low.gain;
////////////////////////

// FUNCTIONS //
fun void playChord(int root, float chord[], float vel, 
dur a, dur d, float s, dur r)
{
    // ugens "local" to the function
    TriOsc osc[4];
    ADSR e => low;
    
    // patch
    for(0 => int i; i < osc.cap(); i++) {
        osc[i] => e;
    }
    
    // freq and gain
    for(0 => int i; i < osc.cap(); i++) {
        Std.mtof(root + chord[i]) => osc[i].freq;
        vel => osc[i].gain;
    }
    
    
    // open env (e is your envelope)
    e.set(a, d, s, r);
    e.keyOn();
    
    // A through end of S
    e.releaseTime() => now;
    
    // close env
    e.keyOff();
    
    // release
    e.releaseTime() => now;
}

// play a note with local oscillator patch osc -> ADSR -> low
// Sets ADSR envelope with passed parameters and playes 
// for duration T at gain amp.
fun void playNote(float pitch, float amp, dur T, 
dur a, dur d, float s, dur r) {
    
    TriOsc osc => ADSR e => low;

    // set ADSR
    e.set(a, d, s, r);
    
    // set freq (osc is your oscillator)
    pitch => Std.mtof => osc.freq;
    // set amplitude
    amp => osc.gain;
    
    // open env (e is your envelope)
    e.keyOn();
    
    // A through end of S
    T-e.releaseTime() => now;
    
    // close env
    e.keyOff();
    
    // release
    e.releaseTime() => now;
}

fun void modulateDensity() {
    while(true) {
        1 + ((Math.sin(now/second * .75) + 1) / 2) * 9 => DENSITY;
        10::ms => now;
    }
}

fun void playC() {
    // C
    .5 => float vel;
    for(0 => int i; i < 8; i++) {
        playChord(60, maj, vel, 50::ms, 50::ms, 0.5, 100::ms);
        
        80::ms => now;
        vel - .2 => vel;
    }
}

fun void playF() {
    // F
    .5 => float vel;
    for(0 => int i; i < 8; i++) {
        playChord(65, maj, vel, 50::ms, 50::ms, 0.5, 100::ms);
        
        80::ms => now;
        vel - .2 => vel;
    }
}

fun void playG7() {
    // G7
    .5 => float vel;
    for(0 => int i; i < 8; i++) {
        playChord(67, v7, vel, 50::ms, 50::ms, 0.5, 100::ms);
        
        80::ms => now;
        vel - .2 => vel;
    }
}

fun void playAm() {
    // Am
    .5 => float vel;
    for(0 => int i; i < 8; i++) {
        playChord(57, min, vel, 50::ms, 50::ms, 0.5, 100::ms);
        
        80::ms => now;
        vel - .2 => vel;
    }
}

fun void intro1() {
    // B
    spork ~ playNote(59, 0.1, 6::second, 100::ms, 80::ms, 1.0, 200::ms);
    1::second => now;
    
    // D
    spork ~ playNote(62, 0.1, 5::second, 100::ms, 80::ms, 1.0, 200::ms);
    1::second => now;
    
    // F
    spork ~ playNote(65, 0.1, 4::second, 100::ms, 80::ms, 1.0, 200::ms);
    500::ms => now;
    
    // low B
    spork ~ playNote(47, 0.1, 3::second, 100::ms, 80::ms, 1.0, 200::ms);
    500::ms => now;
    
    // high f
    spork ~ playNote(77, 0.1, 2::second, 100::ms, 80::ms, 1.0, 200::ms);
    500::ms => now;
    
    // low d
    spork ~ playNote(50, 0.1, 1::second, 100::ms, 80::ms, 1.0, 200::ms);
    3::second => now;
    
} 

fun void intro2() {
    // B
    spork ~ playNote(59, 0.1, 3.5::second, 100::ms, 80::ms, 1.0, 200::ms);
    500::ms => now;
    
    // D
    spork ~ playNote(62, 0.2, 3::second, 100::ms, 80::ms, 1.0, 200::ms);
    500::ms => now;
    
    // F
    spork ~ playNote(65, 0.3, 2.5::second, 100::ms, 80::ms, 1.0, 200::ms);
    500::ms => now;
    
    // low B
    spork ~ playNote(47, 0.3, 2::second, 100::ms, 80::ms, 1.0, 200::ms);
    500::ms => now;
    
    // high f
    spork ~ playNote(77, 0.4, 1.5::second, 100::ms, 80::ms, 1.0, 200::ms);
    500::ms => now;
    
    // low d
    spork ~ playNote(50, 0.4, 1::second, 100::ms, 80::ms, 1.0, 200::ms);
    1::second => now;
   
    // F
    spork ~ playNote(65, 0.4, 1::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
    
    // low d
    spork ~ playNote(50, 0.5, .8::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
    
    // B
    spork ~ playNote(59, 0.5, .6::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
    
    // high f
    spork ~ playNote(77, 0.5, .4::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
    
    // low B
    spork ~ playNote(47, 0.7, .2::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
      
    // D
    spork ~ playNote(62, 0.7, .1::second, 100::ms, 80::ms, 1.0, 200::ms);
    1::second => now;
}

fun void intro3() {
        // F
    spork ~ playNote(65, 0.8, 1::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
    
    // low d
    spork ~ playNote(50, 0.8, .8::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
    
    // B
    spork ~ playNote(59, 0.8, .6::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
    
    // high f
    spork ~ playNote(77, 0.8, .4::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
    
    // low B
    spork ~ playNote(47, 0.9, .2::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
      
    // D
    spork ~ playNote(62, 1.0, .1::second, 100::ms, 80::ms, 1.0, 200::ms);
    3::second => now;
}

fun void intro4() {
    // B
    spork ~ playNote(59, 0.5, 4::second, 100::ms, 80::ms, 1.0, 200::ms);
    
    // D
    spork ~ playNote(62, 0.5, 4::second, 100::ms, 80::ms, 1.0, 200::ms);
    
    // F
    spork ~ playNote(65, 0.5, 4::second, 100::ms, 80::ms, 1.0, 200::ms);
    
    // low B
    spork ~ playNote(47, 0.5, 4::second, 100::ms, 80::ms, 1.0, 200::ms);
    
    // high f
    spork ~ playNote(77, 0.5, 4::second, 100::ms, 80::ms, 1.0, 200::ms);
    
    // low d
    spork ~ playNote(50, 0.5, 4::second, 100::ms, 80::ms, 1.0, 200::ms);
    6::second => now;
}

///////////////////////////////////////////////////////////////////////

// MUSICAL STATEMENT //

intro1();
intro2();
intro3();
intro4();
playC();
playF();
playG7();
playAm();
