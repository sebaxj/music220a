// build reverberant space, play "organ" (cathedral, gregorian chant) 
// drone OR, read in many layered conversations.

// use chord generator to play a "string" section playing on top of
// ambient noise space.

// heart beat? 
// extreme LPF, heart beating slowly, beating faster, lessening
// degree of LPF

5 => float DENSITY;

// global UGen
LPF low => NRev rev => dac;

// mix reverb
.1 => rev.mix;

// set LPF
500 => low.freq;
1 => low.Q;
0.5 => low.gain;


// function
fun void makeSound( float pitch, float vel, float cutoff, 
dur attack, dur decay, float sustain, dur release )
{
    // ugens "local" to the function
    TriOsc s => ADSR e => low;
    
    // frequency and gain
    Std.mtof(pitch) => s.freq;
    vel => s.gain;
    
    // open env (e is your envelope
    e.set(attack, decay, sustain, release);
    e.keyOn();
    
    // A through end of S
    e.releaseTime() => now;
    
    // close env
    e.keyOff();
    
    // release
    e.releaseTime() => now;
}

// play a note (assumes "osc" and "e" are globals)
// Sets ADSR envelope with passed parameters and playes 
// for duration T at gain amp.
fun void playNote(float pitch, float amp, dur T, 
dur a, dur d, float s, dur r) {
    
    TriOsc osc => ADSR e => low;

    // set ADSR
    e.set(100::ms, 80::ms, 1.0, 200::ms);
    
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
        spork ~ makeSound( 60, vel, 500, 50::ms, 50::ms, .5, 100::ms );
        spork ~ makeSound( 64, vel, 500, 50::ms, 50::ms, .5, 100::ms ); 
        spork ~ makeSound( 67, vel, 500, 50::ms, 50::ms, .5, 100::ms );
        
        // advance time
        300::ms => now; 
        vel - .2 => vel;
    }
}

fun void intro() {
    // B
    spork ~ playNote(59, 0.1, 6::second, 20::ms, 80::ms, .5, 10::ms);
    
    1::second => now;
    
    // D
    spork ~ playNote(62, 0.1, 5::second, 20::ms, 80::ms, .5, 10::ms);
    
    1::second => now;
    
    // F
    spork ~ playNote(65, 0.1, 4::second, 20::ms, 80::ms, .5, 10::ms);
    
    500::ms => now;
    
    // low B
    spork ~ playNote(47, 0.1, 3::second, 20::ms, 80::ms, .5, 10::ms);
    
    500::ms => now;
    
    // high f
    spork ~ playNote(77, 0.1, 2::second, 20::ms, 80::ms, .5, 10::ms);
    
    500::ms => now;
    
    // low d
    spork ~ playNote(50, 0.1, 1::second, 20::ms, 80::ms, .5, 10::ms);
    
    3::second => now;
    
} 

intro();
playC();
