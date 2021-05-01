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
0.0 => float t;
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

fun void sweepVol(float min_gain, float max_gain, float T) {
    
    float gain;
    
    for(T => float i; i > 0; i - .01 => i) {
        
        // sweep gain from initial gain to 0.8
        min_gain + Std.fabs(Math.sin(t)) * max_gain => gain;
        
        gain => dac.gain;
        
        // move to next wave number
        t + .01  => t;
        
        // wait 10 seconds to change gain
        10::ms => now;
    }
    
}

fun void modulateDensity() {
    while(true) {
        1 + ((Math.sin(now/second * .75) + 1) / 2) * 9 => DENSITY;
        10::ms => now;
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
    // high f
    spork ~ playNote(77, 1.0, 1::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
    
    // D
    spork ~ playNote(62, 0.8, .8::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
    
    // F
    spork ~ playNote(65, 0.8, .6::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
    
    // low b
    spork ~ playNote(47, 0.8, .4::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
    
    // B
    spork ~ playNote(59, 0.9, .2::second, 100::ms, 80::ms, 1.0, 200::ms);
    200::ms => now;
      
    // low d
    spork ~ playNote(50, 1.0, .1::second, 100::ms, 80::ms, 1.0, 200::ms);
    6::second => now;
}

fun void intro4() {
    
    0.5 => float gain;
    spork ~ sweepVol(0.5, 2.0, 10.0);

    // B
    spork ~ playNote(59, gain, 8::second, 800::ms, 80::ms, 0.5, 200::ms);
        
    // D
    spork ~ playNote(62, gain, 8::second, 800::ms, 80::ms, 0.5, 200::ms);
        
    // F
    spork ~ playNote(65, gain, 8::second, 800::ms, 80::ms, 0.5, 200::ms);
        
    // low B
    spork ~ playNote(47, gain, 8::second, 800::ms, 80::ms, 0.5, 200::ms);
        
    // high f
    spork ~ playNote(77, gain, 8::second, 800::ms, 80::ms, 0.5, 200::ms);
        
    // low d
    spork ~ playNote(50, gain, 8::second, 800::ms, 80::ms, 0.5, 200::ms);
}

fun void play(int root, float chord[]) {
    
    .5 => float vel;
    
    for(0 => int i; i < 8; i++) {
        playChord(root, chord, vel, 50::ms, 50::ms, 0.5, 100::ms);
        
        80::ms => now;
        vel - .2 => vel;
    }
}

fun void sweepF(float min, float max, dur) {
    while(true) {
        // sweep the filter resonant frequency 100 Hz to 800 Hz
        min + Std.fabs(Math.sin(t)) * max => low.freq;
        
        t + .01 => t;
        
        // advance time
        10::ms => now;
    }
    // drum section
    me.dir() + "/misc/Heartbeat.wav" => string filename;
    if(me.args()) me.arg(0) => filename;
    
    // patch
    SndBuf buf => low;
    filename => buf.read;
    
    while(true) {
        0 => buf.pos;
        Math.random2f(.2,.5) => buf.gain;
        Math.random2f(.5,1.5) => buf.rate;
        100::ms => now;
    }
    
    // sweep LPF
    
    
    // play
    
    
    
    // sweep LPF
    spork ~ sweepF(50.0, 1000., 2::second);
    
    /
    
    for(2.0 => float i; i > 0.05; i - 0.1 => i) {
        
    }
    // sweep speed
    // Stop
    // low filter
    // Slower beating
    // Stop

}

fun void playBeat() {
    spork ~  modulateDensity();
    spork ~ sweepF(500.0, 50., 2::second);
    
}


///////////////////////////////////////////////////////////////////////

// MUSICAL STATEMENT //

intro1();
intro2();
intro3();
intro4();

10::second => now;
1.0 => dac.gain;

play(60, maj); // c maj
play(65, maj); // f maj
play(55, v7); // g7
play(57, min); // am

2::second => now;

play(57, min); // am
play(62, dim); // ddim
play(55, v7); // g7
play(57, min); // am

play(55, min42); // amg
play(60, maj); // c maj
play(64, min); // em
play(67, dim7); // gdim7
play(57, min); // am

4::second => now;




