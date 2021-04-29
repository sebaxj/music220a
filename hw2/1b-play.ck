SawOsc osc => ADSR e => dac;

// set ADSR
e.set(100::ms, 80::ms, 1.0, 200::ms);

// play a note (assumes "osc" and "e" are globals)
// Sets ADSR envelope with passed parameters and playes 
// for duration T at gain amp.
fun void playNote(float pitch, float amp, dur T, 
dur a, dur d, float s, dur r) {
    
    // set freq (osc is your oscillator)
    pitch => Std.mtof => osc.freq;
    // set amplitude
    amp => osc.gain;
    
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
    playNote(60, 0.1, 1::second, 20::ms, 80::ms, .5, 10::ms);
    1::second => now;
}